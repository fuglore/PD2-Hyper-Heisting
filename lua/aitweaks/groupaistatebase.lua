-- Andole's dozer spawncap fix
local origfunc3 = GroupAIStateBase._init_misc_data
function GroupAIStateBase:_init_misc_data(...)
	origfunc3(self, ...)
	self._assault_was_hell = nil
	self._next_allowed_enemykill_drama_t = nil
	self._in_mexico = nil
	self._downleniency = 1
	self._downcountleniency = 0
	self._guard_detection_mul = 1
	self._guard_delay_deduction = 0
	self._last_killed_cop_t = 0
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
	self._special_unit_types['akuma'] = true
	self._special_unit_types['phalanx_minion'] = true
	self._rolled_dramatalk_chance = nil
end

local origfunc2 = GroupAIStateBase.on_simulation_started
function GroupAIStateBase:on_simulation_started(...)
	origfunc2(self, ...)
	self._assault_was_hell = nil
	self._next_allowed_enemykill_drama_t = nil
	self._in_mexico = nil
	self._downleniency = 1
	self._downcountleniency = 0
	self._guard_detection_mul = 1
	self._guard_delay_deduction = 0
	self._last_killed_cop_t = 0
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
	self._special_unit_types['akuma'] = true
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
	--self:_draw_current_logics()
	
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

function GroupAIStateBase:_check_assault_panic_chatter()
	if self._t and self._last_killed_cop_t and self._t - self._last_killed_cop_t < math.random(1, 3.5) then
		return true
	end
	
	return
end

function GroupAIStateBase:chk_random_drama_comment()
	local chance = math.random(1, 100)
	--local bain_chance = math.random(1, 100)
	--local bainchtchance = math.random(1, 50)
	local randomcommentchance = math.random(1, 40)
	local selfchance = math.random()
	
	if self._feddensityhigh and not self._rolled_dramatalk_chance then
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
	
	self._rolled_dramatalk_chance = true
end

function GroupAIStateBase:set_importance_weight(u_key, wgt_report)
	if #wgt_report == 0 then
		return
	end

	local t_rem = table.remove
	local t_ins = table.insert
	local max_nr_imp = 32 --oh hey mod runs ok again
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

function GroupAIStateBase:chk_taunt()
	for group_id, group in pairs(self._groups) do
		for u_key, u_data in pairs(group.units) do
			if u_data.unit:base()._tweak_table == "akuma" then
				--log("heheheh")
				u_data.unit:sound():say("i03", true, nil, true, nil)
			end
		end
	end
end

function GroupAIStateBase:_draw_current_logics()
	for key, data in pairs(self._police) do
		if data.unit:brain() and data.unit:brain().is_current_logic then
			local brain = data.unit:brain()
			
			if brain:is_current_logic("attack") then
				local draw_duration = 0.1
				local new_brush = Draw:brush(Color.red:with_alpha(1), draw_duration)
				new_brush:sphere(data.unit:movement():m_head_pos(), 20)
			elseif brain:is_current_logic("base") then
				local draw_duration = 0.1
				local new_brush = Draw:brush(Color.white:with_alpha(0.5), draw_duration)
				new_brush:sphere(data.unit:movement():m_head_pos(), 20)
			elseif brain:is_current_logic("idle") then
				local draw_duration = 0.1
				local new_brush = Draw:brush(Color.green:with_alpha(0.5), draw_duration)
				new_brush:sphere(data.unit:movement():m_head_pos(), 20)
			elseif brain:is_current_logic("sniper") then
				local draw_duration = 0.1
				local new_brush = Draw:brush(Color.red:with_alpha(0.1), draw_duration)
				new_brush:sphere(data.unit:movement():m_head_pos(), 20)
			elseif brain:is_current_logic("travel") then
				local draw_duration = 0.1
				local new_brush = Draw:brush(Color.yellow:with_alpha(0.5), draw_duration)
				new_brush:sphere(data.unit:movement():m_head_pos(), 20)
			end
		end
	end
end

function GroupAIStateBase:on_criminal_neutralized(unit)
	local criminal_key = unit:key()
	local record = self._criminals[criminal_key]
	local criminal = unit

	if not record then
		return
	end

	record.status = "dead"
	record.arrest_timeout = 0

	if Network:is_server() then
	
		--if criminal and criminal:character_damage() and criminal:character_damage()._akuma_effect then
			
		--end
		
		if self._task_data and self._task_data.assault and self._task_data.assault.phase == "anticipation" and self._task_data.assault.active and self._task_data.assault.phase_end_t and self._task_data.assault.phase_end_t < self._t then
			self._assault_number = self._assault_number + 1

			managers.mission:call_global_event("start_assault")
			managers.hud:start_assault(self._assault_number)
			managers.groupai:dispatch_event("start_assault", self._assault_number)
			self:_set_rescue_state(false)
			for group_id, group in pairs(self._groups) do
				for u_key, u_data in pairs(group.units) do
					u_data.unit:sound():say("att", true)
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
			data.unit:brain():on_criminal_neutralized(criminal_key, unit)
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
		if dead and self._task_data and self._task_data.assault and self._task_data.assault.active then
			self:_voice_friend_dead(e_data.group)
			self._last_killed_cop_t = self._t
		end
	end
	
	if dead and managers.groupai:state():whisper_mode() then
		self._guard_detection_mul = self._guard_detection_mul + 1
		self._guard_delay_deduction = self._guard_delay_deduction + 0.2
	end
	
	if dead and self._task_data and self._task_data.assault and self._task_data.assault.phase == "sustain" and self._task_data.assault.active then
		self._enemies_killed_sustain = self._enemies_killed_sustain + 1
	end
end

function GroupAIStateBase:detonate_world_smoke_grenade(id)
	self._smoke_grenades = self._smoke_grenades or {}

	if not self._smoke_grenades[id] then
		Application:error("Could not detonate smoke grenade as it was not queued!", id)

		return
	end

	local data = self._smoke_grenades[id]

	if data.flashbang then
		if Network:is_client() then
			return
		end
				
		local flashbang_unit = nil
		
		--local testing = true
		
		if testing then
			flashbang_unit = "units/pd2_dlc_drm/weapons/wpn_frag_bouncer/wpn_frag_bouncer"
		else
			flashbang_unit = "units/payday2/weapons/wpn_frag_flashbang/wpn_frag_flashbang"
		end
		
		local pos = data.detonate_pos + Vector3(0, 0, 1)
		local rotation = Rotation(math.random() * 360, 0, 0)
		local flash_grenade = World:spawn_unit(Idstring(flashbang_unit), data.detonate_pos, rotation)

		flash_grenade:base():activate(data.detonate_pos, data.duration)

		self._smoke_grenades[id] = nil
	else
		data.duration = data.duration == 0 and 15 or data.duration
		local smoke_grenade = World:spawn_unit(Idstring("units/weapons/smoke_grenade_quick/smoke_grenade_quick"), data.detonate_pos, Rotation())

		smoke_grenade:base():activate(data.detonate_pos, data.duration)
		managers.groupai:state():teammate_comment(nil, "g40x_any", data.detonate_pos, true, 2000, false)

		data.grenade = smoke_grenade
	end

	if Network:is_server() then
		managers.network:session():send_to_peers_synched("sync_smoke_grenade", data.detonate_pos, data.detonate_pos, data.duration, data.flashbang and true or false)
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

function GroupAIStateBase:is_area_safe_assault(area)
	for u_key, u_data in pairs(self._criminals) do
		if not u_data.is_deployable and area.nav_segs[u_data.tracker:nav_segment()] then
			return
		end
	end

	return true
end

function GroupAIStateBase:chk_area_leads_to_enemy(start_nav_seg_id, test_nav_seg_id, enemy_is_criminal)
	local enemy_areas = {}

	for c_key, c_data in pairs(enemy_is_criminal and self._criminals or self._police) do
		enemy_areas[c_data.tracker:nav_segment()] = true
	end

	local all_nav_segs = managers.navigation._nav_segments
	local found_nav_segs = {
		[start_nav_seg_id] = true,
		[test_nav_seg_id] = true
	}
	local to_search_nav_segs = {
		test_nav_seg_id
	}

	repeat
		local chk_nav_seg_id = table.remove(to_search_nav_segs)
		local chk_nav_seg = all_nav_segs[chk_nav_seg_id]

		if enemy_areas[chk_nav_seg_id] then
			--log("executing")
			return true
		end

		local neighbours = chk_nav_seg.neighbours

		for neighbour_seg_id, door_list in pairs(neighbours) do
			if not all_nav_segs[neighbour_seg_id].disabled and not found_nav_segs[neighbour_seg_id] then
				found_nav_segs[neighbour_seg_id] = true

				table.insert(to_search_nav_segs, neighbour_seg_id)
			end
		end
	until #to_search_nav_segs == 0
	--log("fuckoff")
	
	return
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

function GroupAIStateBase:_merge_coarse_path_by_area(coarse_path)
	local i_nav_seg = #coarse_path
	local last_area = nil

	while i_nav_seg > 0 do
		local nav_seg = coarse_path[i_nav_seg][1]
		local area = self:get_area_from_nav_seg_id(nav_seg)

		if last_area and last_area == area and #coarse_path > 2 then
			table.remove(coarse_path, i_nav_seg)
		end

		i_nav_seg = i_nav_seg - 1
	end
	
	return coarse_path
end
