-- Andole's dozer spawncap fix
local origfunc3 = GroupAIStateBase._init_misc_data
function GroupAIStateBase:_init_misc_data(...)
	origfunc3(self, ...)
	self._assault_was_hell = nil
	self._next_allowed_enemykill_drama_t = nil
	self._downleniency = 1
	self._downcountleniency = 0
	self._guard_detection_mul = 1
	self._guard_delay_deduction = 0
	local drama_tweak = tweak_data.drama
	self._drama_data = {
		amount = 0,
		zone = "low",
		last_calculate_t = 0,
		decay_period = tweak_data.drama.decay_period,
		low_p = drama_tweak.low,
		high_p = drama_tweak.peak,
		actions = drama_tweak.drama_actions,
		max_dis = drama_tweak.max_dis,
		dis_mul = drama_tweak.max_dis_mul
	}
	self._special_unit_types = self._special_unit_types or {}
	self._special_unit_types['tank_mini'] = true
	self._special_unit_types['tank_hw'] = true
	self._special_unit_types['tank_medic'] = true
	self._special_unit_types['tank_ftsu'] = true
	self._special_unit_types['spooc_heavy'] = true
	self._special_unit_types['phalanx_minion'] = true
	self._rolled_dramatalk_chance = nil
end

local origfunc2 = GroupAIStateBase.on_simulation_started
function GroupAIStateBase:on_simulation_started(...)
	origfunc2(self, ...)
	self._assault_was_hell = nil
	self._next_allowed_enemykill_drama_t = nil
	self._downleniency = 1
	self._downcountleniency = 0
	self._guard_detection_mul = 1
	self._guard_delay_deduction = 0
	local drama_tweak = tweak_data.drama
	self._drama_data = {
		amount = 0,
		zone = "low",
		last_calculate_t = 0,
		decay_period = tweak_data.drama.decay_period,
		low_p = drama_tweak.low,
		high_p = drama_tweak.peak,
		actions = drama_tweak.drama_actions,
		max_dis = drama_tweak.max_dis,
		dis_mul = drama_tweak.max_dis_mul
	}
	self._special_unit_types = self._special_unit_types or {}
	self._special_unit_types['tank_mini'] = true
	self._special_unit_types['tank_hw'] = true
	self._special_unit_types['tank_medic'] = true
	self._special_unit_types['tank_ftsu'] = true
	self._special_unit_types['spooc_heavy'] = true
	self._special_unit_types['phalanx_minion'] = true
	self._rolled_dramatalk_chance = nil
end

function GroupAIStateBase:chk_guard_detection_mul()
	if self._hostages_killed then
		return self._guard_detection_mul * (self._hostages_killed + 1)
	else
		return self._guard_detection_mul * 1
	end
end

function GroupAIStateBase:chk_guard_delay_deduction()
	if self._hostages_killed then
		return self._guard_delay_deduction * (self._hostages_killed * 0.25)
	else
		return self._guard_delay_deduction * 1
	end
end

function GroupAIStateBase:update(t, dt)
	self._t = t

	self:_upd_criminal_suspicion_progress()
	self:_claculate_drama_value()
	self:_check_drama_low_p()
	
	if self._draw_drama then
		self:_debug_draw_drama(t)
	end

	self:_upd_debug_draw_attentions()
	self:upd_team_AI_distance()
end

function GroupAIStateBase:_check_drama_low_p()
	local drama_tweak = tweak_data.drama
	if not self._assault_number or self._assault_number and self._assault_number == 1 then
		self._drama_data.low_p = drama_tweak.low
	elseif self._assault_number == 2 then
		self._drama_data.low_p = drama_tweak.low_2nd
	elseif self._assault_number >= 3 then
		self._drama_data.low_p = drama_tweak.low_3rd
	end
end

function GroupAIStateBase:chk_random_drama_comment()
	local chance = math.random(1, 100)
	--local bain_chance = math.random(1, 100)
	--local bainchtchance = math.random(1, 50)
	local randomcommentchance = math.random(1, 40)
	local selfchance = math.random()
	
	if self._feddensityhigh and not self._rolled_dramatalk_chance then
		if chance > 75 then
			if randomcommentchance < 10 then
				if selfchance < 0.5 then
					managers.groupai:state():teammate_comment(nil, "g68", nil, false, nil, true)
				else
					managers.player:speak("g68", false, nil)
				end
			elseif randomcommentchance > 10 and randomcommentchance < 20 then
				if selfchance < 0.5 then
					managers.groupai:state():teammate_comment(nil, "g69", nil, false, nil, true)
				else
					managers.player:speak("g69", false, nil)
				end
			elseif randomcommentchance > 20 and randomcommentchance < 30 then
				if selfchance < 0.5 then
					managers.groupai:state():teammate_comment(nil, "g29", nil, false, nil, true)
				else
					managers.player:speak("g29", false, nil)
				end
			else
				if selfchance < 0.5 then
					managers.groupai:state():teammate_comment(nil, "g16", nil, false, nil, true)
				else
					managers.player:speak("g16", false, nil)
				end
			end
		end
	end
	self._rolled_dramatalk_chance = true
end

function GroupAIStateBase:set_importance_weight(u_key, wgt_report)
	if #wgt_report == 0 then
		return
	end

	local t_rem = table.remove
	local t_ins = table.insert
	local max_nr_imp = 6969 --no reason to have this anymore, i think i adjusted reaction times enough to justify removing importance altogether
	local imp_adj = 0
	local criminals = self._player_criminals
	local cops = self._police

	for i_dis_rep = #wgt_report - 1, 1, -2 do
		local c_key = wgt_report[i_dis_rep]
		local c_dis = wgt_report[i_dis_rep + 1]
		local c_record = criminals[c_key]
		local imp_enemies = c_record.important_enemies
		local imp_dis = c_record.important_dis
		local was_imp = nil

		for i_imp = #imp_enemies, 1, -1 do
			if imp_enemies[i_imp] == u_key then
				table.remove(imp_enemies, i_imp)
				table.remove(imp_dis, i_imp)

				was_imp = true

				break
			end
		end

		local i_imp = #imp_dis

		while i_imp > 0 do
			if imp_dis[i_imp] <= c_dis then
				break
			end

			i_imp = i_imp - 1
		end

		if i_imp < max_nr_imp then
			i_imp = i_imp + 1

			while max_nr_imp <= #imp_enemies do
				local dump_e_key = imp_enemies[#imp_enemies]

				self:_adjust_cop_importance(dump_e_key, -1)
				t_rem(imp_enemies)
				t_rem(imp_dis)
			end

			t_ins(imp_enemies, i_imp, u_key)
			t_ins(imp_dis, i_imp, c_dis)

			if not was_imp then
				imp_adj = imp_adj + 1
			end
		elseif was_imp then
			imp_adj = imp_adj - 1
		end
	end

	if imp_adj ~= 0 then
		self:_adjust_cop_importance(u_key, imp_adj)
	end
end

function GroupAIStateBase:on_criminal_neutralized(unit)
	local criminal_key = unit:key()
	local record = self._criminals[criminal_key]

	if not record then
		return
	end

	record.status = "dead"
	record.arrest_timeout = 0

	if Network:is_server() then
		if self._task_data and self._task_data.assault and self._task_data.assault.phase == "anticipation" and self._task_data.assault.active and self._task_data.assault.phase_end_t and self._task_data.assault.phase_end_t < self._t then
			self._assault_number = self._assault_number + 1

			managers.mission:call_global_event("start_assault")
			managers.hud:start_assault(self._assault_number)
			managers.groupai:dispatch_event("start_assault", self._assault_number)
			self:_set_rescue_state(false)
			for group_id, group in pairs(self._groups) do
				for u_key, u_data in pairs(group.units) do
					u_data.unit:sound():say("g90", true)
				end
			end

			self._task_data.assault.phase = "build"
			self._task_data.assault.phase_end_t = self._t + self._tweak_data.assault.build_duration
			self._task_data.assault.is_hesitating = nil

			self:set_assault_mode(true)
			managers.trade:set_trade_countdown(false)
		end
		
		self._downs_during_assault = self._downs_during_assault + 1
		if self._downcountleniency and self._downcountleniency < 5 then
			self._downcountleniency = self._downcountleniency + 1
		end
		
		if self._downleniency and self._downleniency > 0.5 then 
			self._downleniency = self._downleniency - 0.1
			--log("down leniency increased")
		end

		for key, data in pairs(self._police) do
			data.unit:brain():on_criminal_neutralized(criminal_key)
		end

		self:_add_drama(self._drama_data.actions.criminal_dead)
		self:check_gameover_conditions()
	end
end

function GroupAIStateBase:on_enemy_unregistered(unit)
	local level = Global.level_data and Global.level_data.level_id
	if self:is_unit_in_phalanx_minion_data(unit:key()) then
		self:unregister_phalanx_minion(unit:key())
		CopLogicPhalanxMinion:chk_should_breakup()
		CopLogicPhalanxMinion:chk_should_reposition()
	end

	self._police_force = self._police_force - 1
	local u_key = unit:key()

	self:_clear_character_criminal_suspicion_data(u_key)

	if not Network:is_server() then
		return
	end

	local e_data = self._police[u_key]

	if e_data.importance > 0 then
		for c_key, c_data in pairs(self._player_criminals) do
			local imp_keys = c_data.important_enemies

			for i, test_e_key in ipairs(imp_keys) do
				if test_e_key == u_key then
					table.remove(imp_keys, i)
					table.remove(c_data.important_dis, i)

					break
				end
			end
		end
	end
	
	if self._task_data and self._task_data.assault and self._task_data.assault.phase == "anticipation" and self._task_data.assault.active and self._task_data.assault.phase_end_t and self._task_data.assault.phase_end_t < self._t then
		self._assault_number = self._assault_number + 1

		managers.mission:call_global_event("start_assault")
		managers.hud:start_assault(self._assault_number)
		managers.groupai:dispatch_event("start_assault", self._assault_number)
		self:_set_rescue_state(false)
		for group_id, group in pairs(self._groups) do
			for u_key, u_data in pairs(group.units) do
				u_data.unit:sound():say("g90", true)
			end
		end

		self._task_data.assault.phase = "build"
		self._task_data.assault.phase_end_t = self._t + self._tweak_data.assault.build_duration
		self._task_data.assault.is_hesitating = nil

		self:set_assault_mode(true)
		managers.trade:set_trade_countdown(false)
	end
	
	--if not self._next_allowed_enemykill_drama_t or self._next_allowed_enemykill_drama_t < self._t then
	--	self:_add_drama(self._drama_data.actions.enemy_dead)
	--	self._next_allowed_enemykill_drama_t = self._t + 2
	--end

	for crim_key, record in pairs(self._ai_criminals) do
		record.unit:brain():on_cop_neutralized(u_key)
	end

	local unit_type = unit:base()._tweak_table

	if self._special_unit_types[unit_type] then
		self:unregister_special_unit(u_key, unit_type)
	end

	local dead = unit:character_damage():dead()

	if e_data.group then
		self:_remove_group_member(e_data.group, u_key, dead)
		if dead and self._task_data and self._task_data.assault then
			self:_voice_friend_dead(e_data.group)
		end
	end
	
	if dead and managers.groupai:state():whisper_mode() then
		self._guard_detection_mul = self._guard_detection_mul + 0.5
		self._guard_delay_deduction = self._guard_delay_deduction - 0.1
	end
	
	if dead and self._task_data and self._task_data.assault and self._task_data.assault.phase == "sustain" and self._task_data.assault.active then
		self._enemies_killed_sustain = self._enemies_killed_sustain + 1
	end
	
	if dead then
		local spawn_point = unit:unit_data().mission_element
		
		if spawn_point and not level == "sah" then
			local spawn_pos = spawn_point:value("position")
			local u_pos = e_data.m_pos

			if mvector3.distance(spawn_pos, u_pos) < 3000 then
				local found = nil

				for area_id, area_data in pairs(self._area_data) do
					local area_spawn_points = area_data.spawn_points

					if area_spawn_points then
						for _, sp_data in ipairs(area_spawn_points) do
							if sp_data.spawn_point == spawn_point then
								found = true
								if level == "chew" then --fuck.
									sp_data.interval = self._t + math.random(15, 20)
									sp_data.delay_t = self._t + math.random(15, 20)
								else
									sp_data.interval = self._t + math.random(7.5, 10)
									sp_data.delay_t = self._t + math.random(7.5, 10)
								end

								break
							end
						end

						if found then
							break
						end
					end

					local area_spawn_points = area_data.spawn_groups

					if area_spawn_points then
						for _, sp_data in ipairs(area_spawn_points) do
							if sp_data.spawn_point == spawn_point then
								found = true
								if level == "chew" then
									sp_data.interval = self._t + math.random(15, 20)
									sp_data.delay_t = self._t + math.random(15, 20)
								else
									sp_data.interval = self._t + math.random(7.5, 10)
									sp_data.delay_t = self._t + math.random(7.5, 10)
								end
								
								break
							end
						end

						if found then
							break
						end
					end
				end
			elseif mvector3.distance(spawn_pos, u_pos) < 4000 and mvector3.distance(spawn_pos, u_pos) > 3000 then
				local found = nil

				for area_id, area_data in pairs(self._area_data) do
					local area_spawn_points = area_data.spawn_points

					if area_spawn_points then
						for _, sp_data in ipairs(area_spawn_points) do
							if sp_data.spawn_point == spawn_point then
								found = true
								if level == "chew" then
									sp_data.interval = self._t + math.random(10, 15)
									sp_data.interval = self._t + math.random(10, 15)
								else
									sp_data.interval = self._t + math.random(5, 7.5)
									sp_data.delay = self._t + math.random(5, 7.5)
								end

								break
							end
						end

						if found then
							break
						end
					end

					local area_spawn_points = area_data.spawn_groups

					if area_spawn_points then
						for _, sp_data in ipairs(area_spawn_points) do
							if sp_data.spawn_point == spawn_point then
								found = true
								if level == "chew" then
									sp_data.interval = self._t + math.random(10, 15)
									sp_data.delay_t = self._t + math.random(10, 15)
								else
									sp_data.interval = self._t + math.random(5, 7.5)
									sp_data.delay_t = self._t + math.random(5, 7.5)
								end

								break
							end
						end

						if found then
							break
						end
					end
				end
			elseif mvector3.distance(spawn_pos, u_pos) < 5000 and mvector3.distance(spawn_pos, u_pos) > 4000 then
				local found = nil

				for area_id, area_data in pairs(self._area_data) do
					local area_spawn_points = area_data.spawn_points

					if area_spawn_points then
						for _, sp_data in ipairs(area_spawn_points) do
							if sp_data.spawn_point == spawn_point then
								found = true
								if level == "chew" then
									sp_data.interval = self._t + math.random(7.5, 10)
									sp_data.delay_t = self._t + math.random(7.5, 10)
								else
									sp_data.interval = self._t + math.random(5, 7.5)
									sp_data.delay_t = self._t + math.random(5, 7.5)
								end
								
								break
							end
						end

						if found then
							break
						end
					end

					local area_spawn_points = area_data.spawn_groups

					if area_spawn_points then
						for _, sp_data in ipairs(area_spawn_points) do
							if sp_data.spawn_point == spawn_point then
								found = true
								if level == "chew" then
									sp_data.interval = self._t + math.random(7.5, 10)
									sp_data.delay_t = self._t + math.random(7.5, 10)
								else
									sp_data.interval = self._t + math.random(5, 7.5)
									sp_data.delay_t = self._t + math.random(5, 7.5)
								end

								break
							end
						end

						if found then
							break
						end
					end
				end
			elseif mvector3.distance(spawn_pos, u_pos) < 6000 and mvector3.distance(spawn_pos, u_pos) > 4000 then
				local found = nil

				for area_id, area_data in pairs(self._area_data) do
					local area_spawn_points = area_data.spawn_points

					if area_spawn_points then
						for _, sp_data in ipairs(area_spawn_points) do
							if sp_data.spawn_point == spawn_point then
								found = true
								if level == "chew" then
									sp_data.delay_t = self._t + 10
									sp_data.interval = self._t + 10
								else
									sp_data.delay_t = self._t + 5
									sp_data.interval = self._t + 5
								end

								break
							end
						end

						if found then
							break
						end
					end

					local area_spawn_points = area_data.spawn_groups

					if area_spawn_points then
						for _, sp_data in ipairs(area_spawn_points) do
							if sp_data.spawn_point == spawn_point then
								found = true
								
								if level == "chew" then
									sp_data.delay_t = self._t + 10
									sp_data.interval = self._t + 10
								else
									sp_data.delay_t = self._t + 5
									sp_data.interval = self._t + 5
								end

								break
							end
						end

						if found then
							break
						end
					end
				end
			end
		end
	end
end

function GroupAIStateBase:_map_spawn_points_to_respective_areas(id, spawn_points)
	local nav_manager = managers.navigation

	for _, new_spawn_point in ipairs(spawn_points) do
		local pos = new_spawn_point:value("position")
		local interval = new_spawn_point:value("interval")
		local amount = new_spawn_point:get_random_table_value(new_spawn_point:value("amount"))
		local nav_seg = nav_manager:get_nav_seg_from_pos(pos, true)
		local area = self:get_area_from_nav_seg_id(nav_seg)
		local accessibility = new_spawn_point:accessibility()
		local corrected_interval = nil
		
		if interval < 2.5 then
			corrected_interval = 2.5
		else
			corrected_interval = interval
		end
		
		local new_spawn_point_data = {
			delay_t = -1,
			id = id,
			pos = pos,
			nav_seg = nav_seg,
			area = area,
			spawn_point = new_spawn_point,
			amount = amount > 0 and amount,
			interval = corrected_interval,
			accessibility = accessibility ~= "any" and accessibility
		}
		local area_spawn_points = area.spawn_points

		if area_spawn_points then
			table.insert(area_spawn_points, new_spawn_point_data)
		else
			area_spawn_points = {
				new_spawn_point_data
			}
			area.spawn_points = area_spawn_points
		end
	end
end

function GroupAIStateBase:criminal_hurt_drama_armor(unit, attacker)
	local drama_data = self._drama_data

	if alive(attacker) then
		local drama_amount = 0.1
		local max_dis = drama_data.max_dis_armor
		local dis_lerp = math.min(1, mvector3.distance(attacker:movement():m_pos(), unit:movement():m_pos()) / drama_data.max_dis_armor)
		dis_lerp = math.lerp(1, drama_data.max_dis_mul_armor, dis_lerp)
		drama_amount = drama_amount * dis_lerp
	end
	
	if drama_amount and drama_amount >= 0.01 then 
		self:_add_drama(drama_amount)
	end
end

function GroupAIStateBase:_get_anticipation_duration(anticipation_duration_table, is_first)
	local anticipation_duration = anticipation_duration_table[1][1]

	if not is_first then
		local rand = math.random()
		local accumulated_chance = 0

		for i, setting in pairs(anticipation_duration_table) do
			accumulated_chance = accumulated_chance + setting[2]

			if rand <= accumulated_chance then
				anticipation_duration = setting[1]

				break
			end
		end
	end
	
	if not managers.skirmish:is_skirmish() then
		if is_first or self._assault_number and self._assault_number == 1 then
			return 45
		elseif self._assault_number and self._assault_number == 2 then
			return 45
		elseif self._assault_number and self._assault_number == 3 then
			return 35
		elseif self._assault_number and self._assault_number >= 4 then
			return 25
		else
			return 45
		end
	else
		return anticipation_duration
	end
	
end