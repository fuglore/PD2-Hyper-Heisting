local mvec3_dot = mvector3.dot
local mvec3_set = mvector3.set
local mvec3_cpy = mvector3.copy
local mvec3_sub = mvector3.subtract
local mvec3_dis = mvector3.distance
local mvec3_dis_sq = mvector3.distance_sq
local mvec3_dir = mvector3.direction
local mvec3_l_sq = mvector3.length_sq
local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()
local ids_unit = Idstring("unit")

local math_clamp = math.clamp
local math_up = math.UP
local math_random = math.random
local math_lerp = math.lerp
local math_min = math.min
local math_abs = math.abs

local table_insert = table.insert
local table_remove = table.remove
local table_size = table.size

local pairs_g = pairs
local next_g = next
local tostring_g = tostring
local alive_g = alive

-- Andole's dozer spawncap fix
local origfunc3 = GroupAIStateBase._init_misc_data
function GroupAIStateBase:_init_misc_data(...)
	origfunc3(self, ...)

	self._assault_was_hell = nil
	self._stealth_strikes = 0
	self._mass_pager_id = "GroupAIStateBase:HHSTEALTHMASSPAGER"
	self._pager_timer_clbks = {}
	self._next_allowed_enemykill_drama_t = nil
	self._next_mass_pager_t = 3
	self._in_mexico = nil
	self._downleniency = 1
	self._downs_during_assault = 0
	self._downcountleniency = 0
	self._guard_detection_mul = 1
	self._guard_delay_deduction = 1
	self._last_killed_cop_t = 0
	self._heat_bonus_count = 0
	self._heat_bonus_clbk_id = "GroupAIStateBase:HEATBONUS"
	self._client_ecm_data = {}
	self._current_assault_state = "normal"
	local drama_tweak = tweak_data.drama
	self._drama_data = {
		amount = 0,
		zone = "low",
		pulse = true,
		last_calculate_t = 0,
		decay_period = tweak_data.drama.decay_period,
		low_p = drama_tweak.low,
		high_p = drama_tweak.peak,
		high_p_reduction = 0,
		actions = drama_tweak.drama_actions,
		max_dis = drama_tweak.max_dis,
		dis_mul = drama_tweak.max_dis_mul,
		max_dis_armor = drama_tweak.max_dis_armor,
		dis_mul_armor = drama_tweak.max_dis_mul_armor
	}
	self._nr_important_cops = 8
	self._special_unit_types = {
		shield = true,
		medic = true,
		taser = true,
		tank = true,
		spooc = true,
		fbi = true
	}
	self._current_objective_pos = nil
	self._registered_escorts = {}
	
	self._rolled_dramatalk_chance = nil
end

function GroupAIStateBase:set_current_objective_area(pos)
	if not Network:is_server() then
		return
	end
	
	self._current_objective_pos = pos or nil
	
	if self._current_objective_pos then
		local navseg = managers.navigation:get_nav_seg_from_pos(pos, true)
		self._current_objective_navseg = navseg
		self._current_objective_area = self:get_area_from_nav_seg_id(navseg)
	else
		self._current_objective_area = nil
		self._current_objective_navseg = nil
	end
	
	self._current_objective_dir = nil
	self._current_objective_dis = nil
end

local invalid_player_bot_warp_states = {
	jerry1 = true,
	jerry2 = true,
	driving = true
}

local teleport_SO_anims = {
	e_so_teleport_var1 = true,
	e_so_teleport_var2 = true,
	e_so_teleport_var3 = true
}

function GroupAIStateBase:upd_team_AI_distance()
	if not Network:is_server() then
		return
	end

	local t = self._t
	local check_t = self._team_ai_dist_t

	if check_t and t < check_t then
		return
	end

	self._team_ai_dist_t = t + 1

	if not self:team_ai_enabled() then
		return
	end

	local ai_criminals = self:all_AI_criminals()

	if not next_g(ai_criminals) then
		return
	end

	local player_criminals = self:all_player_criminals()

	if not next_g(player_criminals) then
		return
	end

	local teleport_distance = tweak_data.team_ai.stop_action.teleport_distance * tweak_data.team_ai.stop_action.teleport_distance
	local nav_manager = managers.navigation
	local find_cover_f = nav_manager.find_cover_in_nav_seg_3
	local search_coarse_f = nav_manager.search_coarse

	for ai_key, ai in pairs_g(ai_criminals) do
		local unit = ai.unit
		local ai_mov_ext = unit:movement()

		if not ai_mov_ext:cool() then
			local objective = unit:brain():objective()
			local has_warp_objective = nil

			if objective then
				if objective.path_style == "warp" or teleport_SO_anims[objective.action]then
					has_warp_objective = true
				else
					local followup = objective.followup_objective

					if followup then
						if followup.path_style == "warp" or teleport_SO_anims[followup.action] then
							has_warp_objective = true
						end
					end
				end
			end

			if not has_warp_objective then
				if not ai_mov_ext:chk_action_forbidden("walk") then
					local bot_pos = ai.m_pos
					local valid_players = {}

					for _, player in pairs_g(self:all_player_criminals()) do
						if player.status ~= "dead" then
							local distance = mvec3_dis_sq(bot_pos, player.m_pos)

							if distance > teleport_distance then
								valid_players[#valid_players + 1] = {player, distance}
							else
								valid_players = {}

								break
							end
						end
					end

					local closest_distance, closest_player, closest_tracker = nil
					local ai_tracker, ai_access = ai.tracker, ai.so_access

					for i = 1, #valid_players do
						local player = valid_players[i][1]
						local tracker = player.tracker

						if not tracker:obstructed() and not tracker:lost() then
							local player_unit = player.unit
							local player_mov_ext = player_unit:movement()

							if not player_mov_ext:zipline_unit() then
								local player_state = player_mov_ext:current_state_name()

								if not invalid_player_bot_warp_states[player_state] then
									local in_air = nil

									if player_unit:base().is_local_player then
										in_air = player_mov_ext:in_air() and true
									else
										in_air = player_mov_ext._in_air and true
									end

									if not in_air then
										local distance = valid_players[i][2]

										if not closest_distance or distance < closest_distance then
											local params = {
												from_tracker = ai_tracker,
												to_seg = tracker:nav_segment(),
												access = {
													"walk"
												},
												id = "warp_coarse_check" .. tostring_g(ai_key),
												access_pos = ai_access
											}

											local can_path = search_coarse_f(nav_manager, params) and true

											if can_path then
												closest_distance = distance
												closest_player = player
												closest_tracker = tracker
											end
										end
									end
								end
							end
						end
					end

					if closest_player then
						local near_cover_point = find_cover_f(nav_manager, closest_tracker:nav_segment(), 1200, closest_tracker:field_position())
						local position = near_cover_point and near_cover_point[1] or closest_player.m_pos
						local action_desc = {
							body_part = 1,
							type = "warp",
							position = mvec3_cpy(position)
						}

						ai_mov_ext:action_request(action_desc)
					end
				end
			end
		end
	end
end

function GroupAIStateBase:on_enemy_registered(unit)
	if self._anticipated_police_force > 0 then
		self._anticipated_police_force = self._anticipated_police_force - 1
	else
		self._police_force = self._police_force + 1
	end

	local unit_tags = unit:base()._char_tweak.tags or {unit:base()._tweak_table}
	
	for i = 1, #unit_tags do
		if self._special_unit_types[unit_tags[i]] then
			self:register_special_unit(unit:key(), unit_tags[i])
		end
	end
	
	if Network:is_client() then
		unit:movement():set_team(self._teams[tweak_data.levels:get_default_team_ID(unit:base():char_tweak().access == "gangster" and "gangster" or "combatant")])
	end
end

function GroupAIStateBase:is_enemy_special(unit)
	if not unit:base() or not unit:base()._char_tweak then
		return false
	end

	local unit_tags = unit:base()._char_tweak.tags or {unit:base()._tweak_table}
	local category = nil
	
	for i = 1, #unit_tags do
		category = self._special_units[unit_tags[i]]
		
		if category then
			break
		end
	end
	

	if not category then
		return false
	end

	return category[unit:key()]
end

local origfunc2 = GroupAIStateBase.on_simulation_started
function GroupAIStateBase:on_simulation_started(...)
	origfunc2(self, ...)
	self._assault_was_hell = nil
	self._next_allowed_enemykill_drama_t = nil
	self._next_mass_pager_t = 10
	self._in_mexico = nil
	self._downleniency = 1
	self._downs_during_assault = 0
	self._downcountleniency = 0
	self._guard_detection_mul = 1
	self._guard_delay_deduction = 1
	self._last_killed_cop_t = 0
	self._heat_bonus_count = 0
	self._current_assault_state = "normal"
	local drama_tweak = tweak_data.drama
	self._drama_data = {
		amount = 0,
		zone = "low",
		pulse = true,
		last_calculate_t = 0,
		decay_period = tweak_data.drama.decay_period,
		low_p = drama_tweak.low,
		high_p = drama_tweak.peak,
		actions = drama_tweak.drama_actions,
		max_dis = drama_tweak.max_dis,
		dis_mul = drama_tweak.max_dis_mul
	}
	self._nr_important_cops = 8
	self._special_unit_types = {
		shield = true,
		medic = true,
		taser = true,
		tank = true,
		spooc = true,
		fbi = true
	}
	self._rolled_dramatalk_chance = nil
end

function GroupAIStateBase:chk_guard_detection_mul()
	if self._hostages_killed and self._hostages_killed > 0 then
		return self._guard_detection_mul * (self._hostages_killed + 1)
	else
		return self._guard_detection_mul * 1
	end
end

function GroupAIStateBase:chk_guard_delay_deduction()
	if self._hostages_killed then
		return self._guard_delay_deduction * (1 + self._hostages_killed * 0.5)
	else
		return self._guard_delay_deduction
	end
end

function GroupAIStateBase:criminal_hurt_drama(unit, attacker, dmg_percent, armor)
	local drama_data = self._drama_data
	local drama_amount = armor and drama_data.actions.criminal_hurt_armor or drama_data.actions.criminal_hurt

	if alive(attacker) then
		local dis_mul = armor and drama_data.dis_mul_armor or drama_data.dis_mul
		local max_dis = armor and drama_data.max_dis_armor or drama_data.max_dis
		local dis = mvec3_dis(attacker:movement():m_pos(), unit:movement():m_pos())
		
		if dis > max_dis then
			return
		end
		
		local dis_lerp = math.min(1, dis / max_dis)
		dis_lerp = math.lerp(dis_mul, 1, dis_lerp)
		drama_amount = drama_amount * dis_lerp
	end
	
	if Network:is_server() then
		self:_add_drama(drama_amount)
	else
		managers.network:session():send_to_host("send_drama", drama_amount)
	end
end

function GroupAIStateBase:chk_area_leads_to_enemy(start_nav_seg_id, test_nav_seg_id, enemy_is_criminal)
	local enemy_areas = {}

	for c_key, c_data in pairs_g(enemy_is_criminal and self._criminals or self._police) do
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

		for neighbour_seg_id, door_list in pairs_g(neighbours) do
			if not all_nav_segs[neighbour_seg_id].disabled and not found_nav_segs[neighbour_seg_id] then
				found_nav_segs[neighbour_seg_id] = true

				table.insert(to_search_nav_segs, neighbour_seg_id)
			end
		end
	until #to_search_nav_segs == 0
end

function GroupAIStateBase:get_assault_hud_state()
	local nr_players = 0
	local nr_players_alive = 0

	for u_key, u_data in pairs_g(self:all_player_criminals()) do
		nr_players = nr_players + 1
		if not u_data.status or u_data.status and u_data.status == "electrified" then
			nr_players_alive = nr_players_alive + 1
		end
	end
	
	local nr_ai = 0
	local nr_ai_alive = 0

	for u_key, u_data in pairs_g(self:all_AI_criminals()) do
		nr_ai = nr_ai + 1
		if not u_data.status or u_data.status and u_data.status == "electrified" then
			nr_ai_alive = nr_ai_alive + 1
		end
	end	
	
	local nr_people = nr_players + nr_ai
	local nr_people_alive = nr_players_alive + nr_ai_alive
	
	if self._activeassaultbreak then
		self._current_assault_state = "heat"
		
		if not self._celebrated_heat then
			self._celebrated_heat = true
			
			local params = {heat = 0}
			
			managers.enemy:add_delayed_clbk(self._heat_bonus_clbk_id, callback(self, self, "chk_celebrate_heat", params), TimerManager:game():time() + math_lerp(1, 2, math_random()))
		end
			
		if self._commented_on_danger then
			self._commented_on_danger = nil
		end
		
		if self._danger_state and self._danger_state ~= "forced" then
			self._danger_state = nil
		end
	elseif nr_people < 3 or nr_people_alive < nr_people then
		local lastcrimstanding = nr_people_alive < 2
		
		if lastcrimstanding then
			self._danger_state = true
			self._current_assault_state = "lastcrimstanding"
			if not self._commented_on_danger or self._commented_on_danger < 2 then
				self:chk_random_drama_comment(true)
			end
		else
			if nr_people_alive < 3 then
				self._danger_state = true
				self._current_assault_state = "danger"
				if not self._commented_on_danger then
					self:chk_random_drama_comment()
				end
			end
		end
	else
		self._current_assault_state = "normal"
		
		if self._commented_on_danger then
			self._commented_on_danger = nil
		end
		
		if self._danger_state and self._danger_state ~= "forced" then
			self._danger_state = nil
		end
		
		if self._celebrated_heat then
			self._celebrated_heat = nil
		end
		
	end
	
end

function GroupAIStateBase:on_wgt_report_empty(u_key)
	if u_key then
		local e_data = self._police[u_key]

		if e_data and e_data.importance > 0 then
			--log("you're a cock")
			
			e_data.importance = 0
			
			for c_key, c_data in pairs_g(self._player_criminals) do
				local imp_keys = c_data.important_enemies
				
				for i = 1, #imp_keys do
					local test_e_key = imp_keys[i]

					if test_e_key == u_key then
						table_remove(imp_keys, i)
						table_remove(c_data.important_dis, i)

						break
					end
				end
			end
			
			e_data.unit:brain():set_important(nil)
		end
	end
end 

function GroupAIStateBase:on_enemy_logic_intimidated(u_key)
	if u_key then
		local e_data = self._police[u_key]

		if e_data and e_data.importance > 0 then
			--log("you're a cock")
			
			e_data.importance = 0
			
			for c_key, c_data in pairs_g(self._player_criminals) do
				local imp_keys = c_data.important_enemies
				
				for i = 1, #imp_keys do
					local test_e_key = imp_keys[i]

					if test_e_key == u_key then
						table_remove(imp_keys, i)
						table_remove(c_data.important_dis, i)

						break
					end
				end
			end
			
			e_data.unit:brain():set_important(nil)
		end
	end
end

function GroupAIStateBase:set_importance_weight(u_key, wgt_report)
	if not wgt_report or #wgt_report == 0 then
		self:on_wgt_report_empty(u_key)
		
		return
	end

	local t_rem = table_remove
	local t_ins = table_insert
	local max_nr_imp = self._nr_important_cops
	local imp_adj = 0
	local criminals = self._player_criminals
	

	for i_dis_rep = #wgt_report - 1, 1, -2 do
		local c_key = wgt_report[i_dis_rep]
		local c_dis = wgt_report[i_dis_rep + 1]
		local c_record = criminals[c_key]
		local imp_enemies = c_record.important_enemies
		local imp_dis = c_record.important_dis
		local was_imp = nil

		for i_imp = #imp_enemies, 1, -1 do
			if imp_enemies[i_imp] == u_key then
				t_rem(imp_enemies, i_imp)
				t_rem(imp_dis, i_imp)

				was_imp = true

				break
			end
		end

		local i_imp = #imp_dis

		while i_imp > 0 do
			if imp_dis[i_imp] < c_dis then
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

function GroupAIStateBase:_draw_enemy_importancies()
	for e_key, e_data in pairs_g(self._police) do
		local imp = e_data.importance

		while imp > 0 do
			local tint_r = 1
			local tint_g = 1
			local tint_b = 1
			
			if e_data.unit:brain().active_searches and next(e_data.unit:brain().active_searches) then
				tint_g = tint_g - 0.5
			end
			
			if e_data.unit:brain()._logic_data and e_data.unit:brain()._logic_data.internal_data then
				if e_data.unit:brain()._logic_data.internal_data.processing_cover_path then
					tint_g = tint_g - 0.5
				end
				
				if e_data.unit:brain()._logic_data.internal_data.want_to_take_cover and e_data.unit:brain()._logic_data.internal_data.in_cover then
					tint_r = 0
				end
			end
			
			Application:draw_sphere(e_data.m_pos, 50 * imp, tint_r, tint_g, tint_b)

			imp = imp - 1
		end

		if e_data.unit:brain()._important then
			local tint_r = 0
			local tint_g = 1
			local tint_b = 0
			
			if e_data.unit:brain().active_searches and next(e_data.unit:brain().active_searches) then
				tint_b = tint_b + 0.5
			end
			
			if e_data.unit:brain()._logic_data and e_data.unit:brain()._logic_data.internal_data then
				if e_data.unit:brain()._logic_data.internal_data.processing_cover_path then
					tint_b = tint_b + 0.5
				end
				
				if e_data.unit:brain()._logic_data.internal_data.want_to_take_cover and e_data.unit:brain()._logic_data.internal_data.in_cover then
					tint_g = 0
					tint_r = 1
				end
			end
			
			
			Application:draw_cylinder(e_data.m_pos, e_data.m_pos + math_up * 300, 35, tint_r, tint_g, tint_b)
		end
	end

	for c_key, c_data in pairs_g(self._player_criminals) do
		local imp_enemies = c_data.important_enemies

		for imp, e_key in ipairs(imp_enemies) do
			local tint = math_clamp(1 - imp / self._nr_important_cops, 0, 1)

			Application:draw_cylinder(self._police[e_key].m_pos, c_data.m_pos, 10, tint, 0, 0, 1 - tint)
		end
	end
end

--[[local draw_color = {
    [1] = Color.green:with_alpha(0.5),
    [2] = Color.blue:with_alpha(0.5),
    [3] = Color.yellow:with_alpha(0.5),
    [4] = Color.red:with_alpha(0.5)
}

local math_DOWN = math.DOWN
local pairs_g = pairs]]

function GroupAIStateBase:_claculate_drama_value(t, dt)
	local drama_data = self._drama_data
	local adj = nil
	local task_data = self._task_data.assault
	
	if not task_data or not task_data.active or task_data.phase == "fade" or self._activeassaultbreak or self._last_killed_cop_t and t - self._last_killed_cop_t < 5 and not self._danger_state then
		drama_data.pulse = true
		
		local player_count = table.size(self._player_criminals)
		local mul = 1
		
		if player_count <= 1 then
			mul = 2
		else
			player_count = player_count * 0.25
			
			mul = 2 - player_count
		end
		
		
		local decay_period = drama_data.decay_period / mul
		adj = -dt / decay_period
	else
		drama_data.pulse = false
		
		if not self._too_drama then
			if task_data.phase == "sustain" or self._hunt_mode then
				local mul = 1.5
				
				if self._danger_state then
					mul = 1
				end
				
				local decay_period = drama_data.decay_period * mul
				
				adj = dt / decay_period
			end
		end
	end
	
	drama_data.last_calculate_t = self._t
	
	if adj then
		self:_add_drama(adj)
	end
	
	if task_data.active and self._drama_data.amount > 0.5 then
		if not self._reset_heat_bonus_t then
			self._reset_heat_bonus_t = 10
		elseif self._reset_heat_bonus_t <= 0 then
			--log("oof")
			self:reset_heat_bonus()
			self._next_heatbonus_reset = self._downs_during_assault + 2
			self._reset_heat_bonus_t = nil
		else
			self._reset_heat_bonus_t = self._reset_heat_bonus_t - dt
		end
	else
		self._reset_heat_bonus_t = nil
	end	
end

function GroupAIStateBase:_add_drama(amount)
	local drama_data = self._drama_data
	local new_val = math_clamp(drama_data.amount + amount, 0, 1)
	drama_data.amount = new_val

	if drama_data.high_p <= new_val then
		if drama_data.zone ~= "high" then
			drama_data.zone = "high"

			self:_on_drama_zone_change()
		end
	elseif new_val <= drama_data.low_p then
		if drama_data.zone ~= "low" then
			drama_data.zone = "low"

			self:_on_drama_zone_change()
		end
	elseif drama_data.zone then
		drama_data.zone = nil

		self:_on_drama_zone_change()
	end
end

local strikes = {
	hung_up = "alarm_pager_hang_up",
	unanswered = "alarm_pager_not_answered"
}

function GroupAIStateBase:register_strike(reason, do_not_change_t)
	self._stealth_strikes = self._stealth_strikes + 1
	
	local num_strikes = self._stealth_strikes
	
	if num_strikes >= 4 then
		if reason then 
			if strikes[reason] then
				local reason = strikes[reason]
				self:on_police_called(reason)
				
			elseif self.BLAME_SYNC[reason] then
				self:on_police_called(reason)
			else
				self:on_police_called("cop_alarm")
			end
		else
			self:on_police_called("cop_alarm")
		end
		
		if managers.network:session() then
			managers.network:session():send_to_peers_synched("sync_client_whisper_wipe_clbks", false)
		end
	else
		local strikes_left = 3 - num_strikes
		local sync_reason = 0
		local title_text = "ANSWER FAILED"
		
		if reason == "unanswered" then
			title_text = "!!! PAGER CALL NOT ANSWERED !!!"
			sync_reason = 1
		elseif reason == "hung_up" then
			title_text = "!!! PAGER CALL HUNG UP !!!"
			sync_reason = 2
		elseif reason == "camera" then
			title_text = "!!! A CAMERA HAS DETECTED SUSPICIOUS ACTIVITY !!!"
			sync_reason = 3
		end
		
		if strikes_left <= 0 then
			managers.hud:present_mid_text({
				title = title_text,
				text = "!!! WARNING: THE NEXT STRIKE WILL SOUND THE ALARM !!!",
				time = 2
			})
		else
			managers.hud:present_mid_text({
				title = title_text,
				text = "NUMBER OF STRIKES LEFT: ".. tostring(strikes_left) .. "",
				time = 2
			})
		end
		
		if managers.network:session() then
			managers.network:session():send_to_peers_synched("sync_client_whisper_strike_message", sync_reason, num_strikes)
		end
		
		if not do_not_change_t then
			self:start_mass_pager_timer(true)
		end
	end
end

function GroupAIStateBase:run_mass_pager()
	local police = self._police
	local running_mass_pager = nil
	
	for key, u_data in pairs_g(police) do
		local unit = u_data.unit
		
		if alive(unit) then
			if unit:unit_data().has_alarm_pager and unit:brain()._can_do_alarm_pager and not unit:brain():is_pager_started() then
				unit:brain():begin_alarm_pager(true)
				running_mass_pager = true
			end
		end
	end
	
	local corpses = managers.enemy._enemy_data.corpses
	
	for key, u_data in pairs_g(corpses) do
		local unit = u_data.unit
		
		if alive(unit) then
			if unit:unit_data().has_alarm_pager and unit:brain()._can_do_alarm_pager and not unit:brain():is_pager_started() then
				unit:brain():begin_alarm_pager(true)
				running_mass_pager = true
			end
		end
	end
	
	self._running_mass_pager = running_mass_pager
	
	if not running_mass_pager then
		local timer, text = self:start_mass_pager_timer()
		
		if managers.network:session() then
			managers.network:session():send_to_peers_synched("sync_client_whisper_mass_pager_t", timer, 2)
		end
		
		managers.hud:present_mid_text({
			title = "NO PAGERS TO ANSWER",
			text = text,
			time = 4
		})
	end
end

function GroupAIStateBase:check_mass_pager_done(t)
	if self._stealth_strikes >= 4 then
		return
	end

	if not self._running_mass_pager_chk_t or self._running_mass_pager_chk_t < t then
		local police = self._police
		local pager = nil
		
		for key, u_data in pairs_g(police) do
			local unit = u_data.unit
			
			if alive(unit) then
				if unit:unit_data().has_alarm_pager and unit:brain():is_pager_started() then
					pager = true
					break
				end
			end
		end
		
		if not pager then
			local corpses = managers.enemy._enemy_data.corpses
	
			for key, u_data in pairs_g(corpses) do
				local unit = u_data.unit
				
				if alive(unit) then
					if unit:unit_data().has_alarm_pager and unit:brain():is_pager_started() then
						pager = true
						break
					end
				end
			end
		end

		if not pager then
			self._running_mass_pager = nil
			local timer, text = self:start_mass_pager_timer()
			
			if managers.network:session() then
				managers.network:session():send_to_peers_synched("sync_client_whisper_mass_pager_t", timer, 1)
			end
			
			managers.hud:present_mid_text({
				title = "ANSWER SUCCESSFUL",
				text = text, 
				time = 4
			})
		end
		
		self._running_mass_pager_chk_t = t + 2
	end
end

function GroupAIStateBase:_send_next_call_immediately(t)
	local timer_clbk_id_table = self._pager_timer_clbks
	local enemy_manager = managers.enemy
	local remove_clbk_f = enemy_manager.remove_delayed_clbk
	
	for i = 1, #timer_clbk_id_table do
		local clbk_id = timer_clbk_id_table[i]
		
		remove_clbk_f(enemy_manager, clbk_id)
	end

	self._pager_timer_clbks = {}
	
	local clbk_time = TimerManager:game():time() + t
	
	enemy_manager:reschedule_delayed_clbk(self._mass_pager_id, clbk_time)
end

function GroupAIStateBase:stop_all_pagers()
	local police = self._police

	for key, u_data in pairs_g(police) do
		local unit = u_data.unit
		
		if alive(unit) then
			if unit:unit_data().has_alarm_pager then
				unit:brain():end_alarm_pager()
			end
		end
	end
	
	local corpses = managers.enemy._enemy_data.corpses
	
	for key, u_data in pairs_g(corpses) do
		local unit = u_data.unit
		
		if alive(unit) then
			if unit:unit_data().has_alarm_pager then
				unit:brain():end_alarm_pager()
			end
		end
	end
end

function GroupAIStateBase:start_mass_pager_timer(display_timer_text)
	self:stop_all_pagers()

	local timer = 720 / (table.size(self:all_player_criminals()) + self._stealth_strikes * 0.25)
	timer = timer / self:chk_guard_delay_deduction()
	timer = math.floor(timer)
	local enemy_manager = managers.enemy
	self._running_mass_pager = nil
	local t = TimerManager:game():time()
	local minutes = 0
	local clbk_time = timer - 60
	local add_delayed_clbk_f = managers.enemy.add_delayed_clbk
	local hud_manager =	managers.hud
	
	enemy_manager:add_delayed_clbk(self._mass_pager_id, callback(self, self, "run_mass_pager"), t + timer)
	
	self._pager_timer_clbks = {}
	local clbk_table = {}
	
	if timer > 20 then
		local tensecstimer = timer - 10
		local tensecs_id = "HHSTEALTHCALLIN10SECSPRESENTER"
		clbk_table[#clbk_table + 1] = tensecs_id
		
		enemy_manager:add_delayed_clbk(tensecs_id, callback(hud_manager, hud_manager, "present_mid_text", {text = "NEXT PAGER CALL INCOMING IN 10 SECONDS"}), t + tensecstimer)
	end

	while clbk_time >= 0 do
		clbk_time = clbk_time - 60
		minutes = minutes + 1
	end
	
	local text = nil
	local seconds = clbk_time + 60
	
	if minutes > 0 then
		local m_suffix = minutes == 1 and "" or "s"
		local s_suffix = seconds == 1 and "" or "s"
		
		if seconds == 0 then
			seconds = "00"
		end
		
		text = "NEXT PAGER CALL INCOMING IN " .. minutes .. ":" .. seconds .. " MINUTE" .. m_suffix
		
		local callback_t = 60
		
		for i = 1, minutes do
			local current_minute = minutes - i
			local clbk_id = "HHSTEALTHCALLIN" .. i .. "MINUTESPRESENTER"
			clbk_table[#clbk_table + 1] = clbk_id
			local clbk_text = {text = "NEXT PAGER CALL INCOMING IN " .. current_minute .. " MINUTE"}
			
			if current_minute > 1 then
				clbk_text.text = clbk_text.text .. "S"
			end
			
			add_delayed_clbk_f(enemy_manager, clbk_id, callback(hud_manager, hud_manager, "present_mid_text", clbk_text), t + callback_t) --test.
			callback_t = callback_t + 60
		end
	else
		local s_suffix = timer == 1 and "" or "s"
		text = "NEXT PAGER CALL INCOMING IN " .. seconds .. " SECOND" .. s_suffix
	end
	
	self._pager_timer_clbks = clbk_table
	
	if display_timer_text then
		managers.hud:present_mid_text({
			text = text,
			time = 4
 		})
		
		if managers.network:session() then
			managers.network:session():send_to_peers_synched("sync_client_whisper_mass_pager_t", timer, 3)
		end
	end
	
	return timer, text
end

function GroupAIStateBase:sync_client_whisper_mass_pager_t(timer, title_index)
	local title_text = nil
	
	if title_index == 1 then
		title_text = "ANSWER SUCCESSFUL"
	elseif title_index == 2 then
		title_text = "NO PAGERS TO ANSWER"
	end
	
	local timer_clbk_id_table = self._pager_timer_clbks
	local enemy_manager = managers.enemy
	local remove_clbk_f = enemy_manager.remove_delayed_clbk
	
	for i = 1, #timer_clbk_id_table do --clients don't really have the timer value, so i just wipe the table whenever anything gets synced
		local clbk_id = timer_clbk_id_table[i]
		
		remove_clbk_f(enemy_manager, clbk_id)
	end

	self._pager_timer_clbks = {}

	local t = TimerManager:game():time()
	local minutes = 0
	local clbk_time = timer - 60
	local add_delayed_clbk_f = enemy_manager.add_delayed_clbk
	local hud_manager =	managers.hud
	
	self._pager_timer_clbks = {}
	local clbk_table = {}
	
	if timer > 20 then
		local tensecstimer = timer - 10
		local tensecs_id = "HHSTEALTHCALLIN10SECSPRESENTER"
		clbk_table[#clbk_table + 1] = tensecs_id
		
		enemy_manager:add_delayed_clbk(tensecs_id, callback(hud_manager, hud_manager, "present_mid_text", {text = "NEXT PAGER CALL INCOMING IN 10 SECONDS"}), t + tensecstimer)
	end

	while clbk_time >= 0 do
		clbk_time = clbk_time - 60
		minutes = minutes + 1
	end
	
	local text = nil
	local seconds = clbk_time + 60
	
	if minutes > 0 then
		local m_suffix = minutes == 1 and "" or "s"
		local s_suffix = seconds == 1 and "" or "s"
		
		if seconds == 0 then
			seconds = "00"
		end
		
		text = "NEXT PAGER CALL INCOMING IN " .. minutes .. ":" .. seconds .. " MINUTE" .. m_suffix
		
		local callback_t = 60
		
		for i = 1, minutes do
			local current_minute = minutes - i
			local clbk_id = "HHSTEALTHCALLIN" .. i .. "MINUTESPRESENTER"
			clbk_table[#clbk_table + 1] = clbk_id
			local clbk_text = {text = "NEXT PAGER CALL INCOMING IN " .. current_minute .. " MINUTE"}
			
			if current_minute > 1 then
				clbk_text.text = clbk_text.text .. "S"
			end
			
			add_delayed_clbk_f(enemy_manager, clbk_id, callback(hud_manager, hud_manager, "present_mid_text", clbk_text), t + callback_t) --test.
			callback_t = callback_t + 60
		end
	else
		local s_suffix = timer == 1 and "" or "s"
		text = "NEXT PAGER CALL INCOMING IN " .. seconds .. " SECOND" .. s_suffix
	end
	
	self._pager_timer_clbks = clbk_table

	managers.hud:present_mid_text({
		title = title_text,
		text = text,
		time = 4
	})
end

function GroupAIStateBase:sync_client_whisper_strike_message(strike_reason, strike_count)
	local title_text = nil
	
	if strike_reason == 1 then
		title_text = "!!! PAGER CALL NOT ANSWERED !!!"
	elseif strike_reason == 2 then
		title_text = "!!! PAGER CALL HUNG UP !!!"
	elseif strike_reason == 3 then
		title_text = "!!! A CAMERA HAS DETECTED SUSPICIOUS ACTIVITY !!!"
	end

	local strikes_left = 3 - strike_count

	if strikes_left <= 0 then
		managers.hud:present_mid_text({
			title = title_text,
			text = "!!! WARNING: THE NEXT STRIKE WILL SOUND THE ALARM !!!",
			time = 2
		})
	else
		managers.hud:present_mid_text({
			title = title_text,
			text = "NUMBER OF STRIKES LEFT: ".. tostring(strikes_left) .. "",
			time = 2
		})
	end
	
	if strike_reason == 3 then
		managers.hud:present_mid_text({
			title = "!!! A CAMERA HAS DETECTED SUSPICIOUS ACTIVITY !!!",
			text = "NEXT PAGER CALL INCOMING IN 10 SECONDS",
			time = 4
		})
	end
	
	local timer_clbk_id_table = self._pager_timer_clbks
	local enemy_manager = managers.enemy
	local remove_clbk_f = enemy_manager.remove_delayed_clbk
	
	for i = 1, #timer_clbk_id_table do --timer usually gets synced after a strike, wipe clbks
		local clbk_id = timer_clbk_id_table[i]
		
		remove_clbk_f(enemy_manager, clbk_id)
	end

	self._pager_timer_clbks = {}
end

function GroupAIStateBase:sync_client_whisper_wipe_clbks(display_camera_message) --sync this if things go loud so clients can wipe their asses
	local timer_clbk_id_table = self._pager_timer_clbks
	local enemy_manager = managers.enemy
	local remove_clbk_f = enemy_manager.remove_delayed_clbk
	
	for i = 1, #timer_clbk_id_table do
		local clbk_id = timer_clbk_id_table[i]
		
		remove_clbk_f(enemy_manager, clbk_id)
	end
	
	self._pager_timer_clbks = {}
	
	if display_camera_message then
		managers.hud:present_mid_text({
			title = "!!! A CAMERA HAS DETECTED SUSPICIOUS ACTIVITY !!!",
			text = "NEXT PAGER CALL INCOMING IN 5 SECONDS",
			time = 4
		})
	end
end

function GroupAIStateBase:kill_hh_stealth()
	if managers.network:session() then
		managers.network:session():send_to_peers_synched("sync_client_whisper_wipe_clbks", false)
	end
	
	local enemy_manager = managers.enemy
	
	enemy_manager:remove_delayed_clbk(self._mass_pager_id)
	
	local timer_clbk_id_table = self._pager_timer_clbks
	local remove_clbk_f = enemy_manager.remove_delayed_clbk
	
	for i = 1, #timer_clbk_id_table do
		local clbk_id = timer_clbk_id_table[i]
		
		remove_clbk_f(enemy_manager, clbk_id)
	end
	
	self._pager_timer_clbks = {}
end

function GroupAIStateBase:whisper_chatter_clbk()
	if self._ai_enabled and not self._enemy_weapons_hot then
		local t = self._t
		local optimal_dist = 500
		local best_cop = nil
		
		for e_key, cop in pairs_g(self._police) do
			local cop_unit = cop.unit
			
			if cop_unit:movement():cool() and not cop_unit:sound():speaking(t) then
				local clear_whisper = cop.char_tweak.chatter.clear_whisper

				if clear_whisper then
					if not best_cop or math_random() > 0.5 then
						best_cop = cop
					end
				end
			end
		end

		if best_cop then	
			local voiceline = math_random()
			
			if voiceline > 0.3 then
				voiceline = "clear_whisper"
			else
				voiceline = "clear_whisper_2"
			end
		
			self:chk_say_enemy_chatter(best_cop.unit, best_cop.m_pos, voiceline)
		end
		
		self._radio_clbk = callback(self, self, "whisper_chatter_clbk")

		managers.enemy:add_delayed_clbk("whisper_chatter_clbk", self._radio_clbk, t + math_random(0.5, 20))
	end
end

function GroupAIStateBase:on_enemy_weapons_hot(is_delayed_callback)
	if not self._ai_enabled then
		return
	end

	if not is_delayed_callback and self._police_call_clbk_id then
		managers.enemy:remove_delayed_clbk(self._police_call_clbk_id)
	end

	self._police_call_clbk_id = nil

	if not self._enemy_weapons_hot then
		self._police_called = true
		self._enemy_weapons_hot = true

		managers.music:post_event(tweak_data.levels:get_music_event("control"))
		managers.enemy:add_delayed_clbk("notify_bain_weapons_hot", callback(self, self, "notify_bain_weapons_hot", self._called_reason), Application:time() + 0)

		self:kill_hh_stealth()

		if managers.network:session() then
			managers.network:session():send_to_peers_synched("group_ai_event", self:get_sync_event_id("enemy_weapons_hot"), self:get_sync_blame_id(self._called_reason))
		else
			print("here it would crash before")
		end
		
		managers.enemy:remove_delayed_clbk("whisper_chatter_clbk")
		
		self._radio_clbk = callback(self, self, "_radio_chatter_clbk")

		managers.enemy:add_delayed_clbk("_radio_chatter_clbk", self._radio_clbk, Application:time() + 30)

		if not self._switch_to_not_cool_clbk_id then
			self._switch_to_not_cool_clbk_id = "GroupAI_delayed_not_cool"

			managers.enemy:add_delayed_clbk(self._switch_to_not_cool_clbk_id, callback(self, self, "_clbk_switch_enemies_to_not_cool"), self._t + 1)
		end

		if not self._hstg_hint_clbk then
			self._first_hostage_hint = true
			self._hstg_hint_clbk = callback(self, self, "_hostage_hint_clbk")

			managers.enemy:add_delayed_clbk("_hostage_hint_clbk", self._hstg_hint_clbk, Application:time() + 45)
		end

		managers.mission:call_global_event("police_weapons_hot")
		self:_call_listeners("enemy_weapons_hot")
		managers.enemy:set_corpse_disposal_enabled(true)
	end
end

function GroupAIStateBase:set_whisper_mode(enabled)
	enabled = enabled and true or false

	if enabled == self._whisper_mode then
		return
	end
  
	self._whisper_mode = enabled
	self._whisper_mode_change_t = TimerManager:game():time()

	self:set_ambience_flag()

	if Network:is_server() and not enabled and not self._switch_to_not_cool_clbk_id then
		self._switch_to_not_cool_clbk_id = "GroupAI_delayed_not_cool"

		managers.enemy:add_delayed_clbk(self._switch_to_not_cool_clbk_id, callback(self, self, "_clbk_switch_enemies_to_not_cool"), self._t + 0.35)
	end

	self:_call_listeners("whisper_mode", enabled)

	if not enabled then
		if Network:is_server() then
			self:kill_hh_stealth()
		end
		
		self:_clear_criminal_suspicion_data()
	end
end

function GroupAIStateBase:register_ecm_jammer(unit, jam_settings)
	if not Network:is_server() then
		return
	end

	local was_jammer_active = next(self._ecm_jammers) and true or false
	self._ecm_jammers[unit:key()] = jam_settings and {
		unit = unit,
		settings = jam_settings
	} or nil
	local is_jammer_active = next(self._ecm_jammers) and true or false
	
	if was_jammer_active then
		if not is_jammer_active then
			managers.mission:call_global_event("ecm_jammer_off", unit)
			
			if managers.network:session() then
				managers.network:session():send_to_peers_synched("set_client_groupai_ecm_data", false, false, false)
			end
		end
	elseif is_jammer_active then
		managers.mission:call_global_event("ecm_jammer_on", unit)
		
		if managers.network:session() then
			managers.network:session():send_to_peers_synched("set_client_groupai_ecm_data", jam_settings.call, jam_settings.camera, jam_settings.pager)
		end
	end
end

function GroupAIStateBase:_set_client_groupai_ecm_data(ecm_settings)
	if not ecm_settings then
		return
	end
	
	self._client_ecm_data = ecm_settings
end

function GroupAIStateBase:is_ecm_jammer_active(medium)
	if Network:is_server() then
		for u_key, data in pairs(self._ecm_jammers) do
			if data.settings[medium] then
				return true
			end
		end
	else
		if self._client_ecm_data[medium] then
			return true
		end
	end
end

function GroupAIStateBase:begin_HH_stealth()
	managers.hud:present_mid_text({
		text = "PAGER CALL INCOMING...",
		time = 3
	})
		
	self:run_mass_pager()
	
	self._stealth_has_begun = true
	
	if managers.network:session() then
		managers.network:session():send_to_peers_synched("sync_begin_hh_stealth_message")
	end
end

function GroupAIStateBase:_update_HH_stealth(t, dt)
	if self._running_mass_pager then
		self:check_mass_pager_done(t)
	end
end

function GroupAIStateBase:update(t, dt)
    --[[local cam_pos = nil
    local player = managers.player:player_unit()

    if player then
        cam_pos = player:movement():m_head_pos()
    elseif managers.viewport:get_current_camera() then
        cam_pos = managers.viewport:get_current_camera_position()
    end

    if cam_pos then
        local from_pos = cam_pos + math_DOWN * 50

        for key, data in pairs_g(self._police) do
            local unit = data.unit
            local ext_base = unit:base()
            local vis_state = ext_base:lod_stage() or 4

            local brush = Draw:brush(draw_color[vis_state], 0.1)
            brush:cylinder(from_pos, unit:movement():m_com(), 1)
        end

        for key, data in pairs_g(managers.enemy:all_civilians()) do
            local unit = data.unit
            local ext_base = unit:base()
            local vis_state = ext_base:lod_stage() or 4

            local brush = Draw:brush(draw_color[vis_state], 0.1)
            brush:cylinder(from_pos, unit:movement():m_com(), 1)
        end

        for key, data in pairs_g(self._ai_criminals) do
            local unit = data.unit
            local ext_base = unit:base()
            local vis_state = ext_base:lod_stage() or 4

            local brush = Draw:brush(draw_color[vis_state], 0.1)
            brush:cylinder(from_pos, unit:movement():m_com(), 1)
        end
    end]]
	
	self._t = t
	
	if not self._radio_clbk then
		self:whisper_chatter_clbk()
	end
	
	--self:_draw_enemy_importancies()

	self:_upd_criminal_suspicion_progress()
	
	if self._enemy_weapons_hot then
		self:_claculate_drama_value(t, dt)
		--log("drama : " .. tostring(self._drama_data.amount))
	elseif self._stealth_has_begun then
		self:_update_HH_stealth(t, dt)
	end
	
	--self:_draw_current_logics()
	
	if Network:is_server() then
		if not Global.game_settings.single_player then
			local new_value = 8 / table.size(self:all_player_criminals()) 

			self._nr_important_cops = new_value
		end
	end
	

	self:_upd_debug_draw_attentions()
	self:upd_team_AI_distance()	
end

function GroupAIStateBase:save(save_data)
	local my_save_data = {}
	save_data.group_ai = my_save_data
	my_save_data.control_value = self._control_value
	my_save_data._assault_mode = self._assault_mode
	my_save_data._hunt_mode = self._hunt_mode
	my_save_data._fake_assault_mode = self._fake_assault_mode
	my_save_data._whisper_mode = self._whisper_mode
	my_save_data._bain_state = self._bain_state
	my_save_data._point_of_no_return_timer = self._point_of_no_return_timer
	my_save_data._point_of_no_return_id = self._point_of_no_return_id
	my_save_data._police_called = self._police_called
	my_save_data._enemy_weapons_hot = self._enemy_weapons_hot
	my_save_data._activeassaultbreak = self._activeassaultbreak
	my_save_data._enemy_speed_mul = self._enemy_speed_mul
	my_save_data._heat_bonus_count = self._heat_bonus_count

	if self._hostage_headcount > 0 then
		my_save_data.hostage_headcount = self._hostage_headcount
	end

	my_save_data.teams = self._teams
	my_save_data.endscreen_variant = self._endscreen_variant
	my_save_data.assault_number = self._assault_number
	my_save_data.nr_successful_alarm_pager_bluffs = self._nr_successful_alarm_pager_bluffs
end

function GroupAIStateBase:load(load_data)
	local my_load_data = load_data.group_ai
	self._control_value = my_load_data.control_value

	self:_calculate_difficulty_ratio()

	self._hunt_mode = my_load_data._hunt_mode
	self._assault_number = my_load_data.assault_number
	
	self._activeassaultbreak = my_load_data._activeassaultbreak
	self._enemy_speed_mul = my_load_data._enemy_speed_mul
	self._heat_bonus_count = my_load_data._heat_bonus_count
	
	self:sync_assault_mode(my_load_data._assault_mode)
	self:set_fake_assault_mode(my_load_data._fake_assault_mode)
	self:set_whisper_mode(my_load_data._whisper_mode)
	self:set_bain_state(my_load_data._bain_state)
	self:set_point_of_no_return_timer(my_load_data._point_of_no_return_timer, my_load_data._point_of_no_return_id)

	if my_load_data.hostage_headcount then
		self:sync_hostage_headcount(my_load_data.hostage_headcount)
	end

	self._police_called = my_load_data._police_called
	self._enemy_weapons_hot = my_load_data._enemy_weapons_hot

	if self._enemy_weapons_hot then
		managers.enemy:set_corpse_disposal_enabled(true)
	end

	self._teams = my_load_data.teams
	self._endscreen_variant = my_load_data.endscreen_variant
	self._nr_successful_alarm_pager_bluffs = my_load_data.nr_successful_alarm_pager_bluffs

	self:_call_listeners("team_def")
	self:set_damage_reduction_buff_hud()
end

function GroupAIStateBase:set_point_of_no_return_timer(time, point_of_no_return_id)
	if time == nil or setup:has_queued_exec() then
		return
	end
	
	local level = Global.level_data and Global.level_data.level_id
	
	if level and level == "bph" then
		self._hunt_mode = true
		self._danger_state = "forced"
		
		if not Global.game_settings or not Global.game_settings.one_down then
			return
		else
			time = time + 90
		end
	end

	self._forbid_drop_in = true

	managers.network.matchmake:set_server_joinable(false)

	if not self._peers_inside_point_of_no_return then
		self._peers_inside_point_of_no_return = {}
	end

	self._point_of_no_return_timer = time
	self._point_of_no_return_id = point_of_no_return_id
	self._point_of_no_return_areas = nil

	managers.hud:show_point_of_no_return_timer()
	managers.hud:add_updator("point_of_no_return", callback(self, self, "_update_point_of_no_return"))
end

function GroupAIStateBase:_check_drama_low_p()
	local drama_tweak = tweak_data.drama
	if not self._assault_number or self._assault_number and self._assault_number == 1 then
		self._drama_data.high_p = drama_tweak.peak
	elseif self._assault_number == 2 then
		self._drama_data.high_p = drama_tweak.high_2nd
	elseif self._assault_number >= 3 then
		self._drama_data.high_p = drama_tweak.high_3rd
	end
	
	self._drama_data.high_p = self._drama_data.high_p - self._drama_data.high_p_reduction
end

function GroupAIStateBase:_check_assault_panic_chatter()
	if self._t and self._last_killed_cop_t and self._t - self._last_killed_cop_t < 5 then
		return true
	end
	
	return
end

function GroupAIStateBase:chk_celebrate_heat(params)
	if params.heat < 4 then
		local random_comments = {
			"v46",
			"v18"
		}
		
		local random_comment = random_comments[math_random(#random_comments)]
		
		if params.heat < 1 then
			managers.player:speak("v46", false, nil)
		else
			local valid_crims = {}
			local lucky_talker = nil
			local last_chosen_ukey = params.last_spoke_ukey
			for u_key, u_data in pairs(self._criminals) do
				if not last_chosen_ukey or last_chosen_ukey ~= u_key then
					if not u_data.is_deployable and not u_data.unit:base().is_local_player and alive(u_data.unit) and not u_data.unit:movement():downed() and not u_data.unit:sound():speaking() then
						valid_crims[#valid_crims + 1] = u_data.unit
					end
				end
			end
			
			lucky_talker = valid_crims[math_random(#valid_crims)]
			
			if lucky_talker then
				lucky_talker:sound():say(random_comment, nil, true)
				params.last_spoke_ukey = lucky_talker:key()		
			end
		end
		
		params.heat = params.heat + 1
		managers.enemy:add_delayed_clbk(self._heat_bonus_clbk_id, callback(self, self, "chk_celebrate_heat", params), TimerManager:game():time() + math_lerp(0.7, 2, math_random()))
	end
end

function GroupAIStateBase:chk_random_drama_comment(lastcrimstanding)
	if not self._criminals or #self._criminals <= 0 then
		return
	end
	
	local random_comments = {
		"g68",
		"g60",
		"g69",
		"g29",
		"g16"
	}
	
	local random_comment = random_comments[math_random(#random_comments)]
	
	local valid_crims = {}
	
	for u_key, u_data in pairs(self._criminals) do
		if not u_data.is_deployable and alive(u_data.unit) and not u_data.unit:movement():downed() and not u_data.unit:sound():speaking() then
			valid_crims[#valid_crims + 1] = u_data.unit
		end
	end
			
	lucky_talker = valid_crims[math_random(#valid_crims)]
			
	if lucky_talker then
		lucky_talker:sound():say(random_comment, nil, true)
	end
	
	if lastcrimstanding then
		self._commented_on_danger = 2
	else
		self._commented_on_danger = 1
	end
end

function GroupAIStateBase:play_heat_bonus_dialog()
	if managers and managers.dialog._narrator_prefix and managers.dialog._narrator_prefix == "Play_ban_" then
		managers.dialog:queue_narrator_dialog_raw("play_pln_gen_lkgo_01", nil)
	end
	
	self._said_heat_bonus_dialog = true
end

function GroupAIStateBase:criminal_spotted(unit)
	local u_key = unit:key()
	local u_sighting = self._criminals[u_key]

	u_sighting.undetected = nil
	u_sighting.det_t = self._t

	u_sighting.tracker:m_position(u_sighting.pos)

	local seg = u_sighting.tracker:nav_segment()
	u_sighting.seg = seg

	local prev_area = u_sighting.area
	local area = nil

	if prev_area and prev_area.nav_segs[seg] then
		area = prev_area
	else
		area = self:get_area_from_nav_seg_id(seg)
	end

	if prev_area ~= area then
		u_sighting.area = area

		if prev_area then
			prev_area.criminal.units[u_key] = nil
		end

		area.criminal.units[u_key] = u_sighting
	end

	if area.is_safe then
		area.is_safe = nil

		self:_on_area_safety_status(area, {
			reason = "criminal",
			record = u_sighting
		})
	end
	
	if not self:whisper_mode() and self._task_data.assault and self._task_data.assault.active then
		self:mass_identify_criminal(unit)
	end
end

function GroupAIStateBase:mass_identify_criminal(unit)
	local u_key = unit:key()
	for group_id, group in pairs_g(self._groups) do
		for u_key, u_data in pairs_g(group.units) do
			u_data.unit:brain():clbk_group_member_attention_identified(nil, u_key)
		end
	end
end

function GroupAIStateBase:on_criminal_nav_seg_change(unit, nav_seg_id)
	local u_key = unit:key()
	local u_sighting = self._criminals[u_key]

	if not u_sighting then
		return
	end

	local seg = nav_seg_id

	u_sighting.seg = seg

	local prev_area = u_sighting.area
	local area = nil

	if prev_area and prev_area.nav_segs[seg] then
		area = prev_area
	else
		area = self:get_area_from_nav_seg_id(seg)
	end

	if prev_area ~= area then
		u_sighting.area = area

		if prev_area then
			prev_area.criminal.units[u_key] = nil
		end

		area.criminal.units[u_key] = u_sighting
	end
end

function GroupAIStateBase:chk_taunt()
	for group_id, group in pairs_g(self._groups) do
		for u_key, u_data in pairs_g(group.units) do
			if u_data.unit:base()._tweak_table == "akuma" then
				--log("heheheh")
				u_data.unit:sound():say("i03", true, nil, true, nil)
			end
		end
	end
end

function GroupAIStateBase:_draw_current_logics()
	for key, data in pairs_g(self._police) do
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
				local new_brush = Draw:brush(Color.blue:with_alpha(0.1), draw_duration)
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
		
		if self._task_data and self._task_data.assault and self._task_data.assault.phase == "anticipation" and self._task_data.assault.phase_end_t and self._task_data.assault.phase_end_t < self._t then
			self._assault_number = self._assault_number + 1

			managers.mission:call_global_event("start_assault")
			managers.hud:start_assault(self._assault_number)
			managers.groupai:dispatch_event("start_assault", self._assault_number)

			for group_id, group in pairs_g(self._groups) do
				for u_key, u_data in pairs_g(group.units) do
					u_data.unit:sound():say("att", true)
				end
			end
			
			if managers.modifiers:check_boolean("itmightrain") then
				self._enemy_speed_mul = self._enemy_speed_mul + 0.1
			end
					
			LuaNetworking:SendToPeers("shin_sync_speed_mul",tostring_g(self._enemy_speed_mul))

			self._task_data.assault.phase = "build"
			self._task_data.assault.phase_end_t = self._t + self._tweak_data.assault.build_duration
			self._task_data.assault.is_hesitating = nil

			self:set_assault_mode(true)
			managers.trade:set_trade_countdown(false)
		end
		
		for key, data in pairs_g(self._police) do
			data.unit:brain():on_criminal_neutralized(criminal_key, unit)
		end

		self:_add_drama(self._drama_data.actions.criminal_dead)
		self:check_gameover_conditions()
	end
end

function GroupAIStateBase:on_criminal_disabled(unit, custom_status)
	local criminal_key = unit:key()
	local record = self._criminals[criminal_key]

	if not record then
		return
	end

	record.disabled_t = self._t
	record.status = custom_status or "disabled"

	if Network:is_server() then
		if not custom_status or custom_status ~= "electrified" then
			self._downs_during_assault = self._downs_during_assault + 1

			for key, data in pairs(self._police) do
				data.unit:brain():on_criminal_neutralized(criminal_key)
			end

			self:_add_drama(self._drama_data.actions.criminal_disabled)
			
			if self._task_data and self._task_data.assault and self._task_data.assault.phase == "anticipation" and self._task_data.assault.phase_end_t and self._task_data.assault.phase_end_t < self._t then
				self._assault_number = self._assault_number + 1

				managers.mission:call_global_event("start_assault")
				managers.hud:start_assault(self._assault_number)
				managers.groupai:dispatch_event("start_assault", self._assault_number)

				for group_id, group in pairs_g(self._groups) do
					for u_key, u_data in pairs_g(group.units) do
						u_data.unit:sound():say("att", true)
					end
				end
				
				if managers.modifiers:check_boolean("itmightrain") then
					self._enemy_speed_mul = self._enemy_speed_mul + 0.1
				end
						
				LuaNetworking:SendToPeers("shin_sync_speed_mul",tostring_g(self._enemy_speed_mul))

				self._task_data.assault.phase = "build"
				self._task_data.assault.phase_end_t = self._t + self._tweak_data.assault.build_duration
				self._task_data.assault.is_hesitating = nil

				self:set_assault_mode(true)
				managers.trade:set_trade_countdown(false)
			end
					
			if Global.game_settings and Global.game_settings.one_down then
				--no
			elseif self._next_heatbonus_reset and self._downs_during_assault == self._next_heatbonus_reset or self._downs_during_assault == 2 then
				self:reset_heat_bonus()
				
				self._next_heatbonus_reset = self._downs_during_assault + 2
			end
		end
		self:check_gameover_conditions()
	end
end

function GroupAIStateBase:reset_heat_bonus()
	if self._activeassaultbreak then
		self._activeassaultbreak = nil
		self._stopassaultbreak_t = nil
		if not Global.game_settings.single_player then
			LuaNetworking:SendToPeers("shin_sync_hud_assault_color",tostring(self._activeassaultbreak))
		end
	end
	
	self._said_heat_bonus_dialog = nil
	
	local task_data = self._task_data.assault
	
	if self._activeassaultnextbreak_t then
		self._activeassaultnextbreak_t = self._t + 30
		
		local diff_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)
		
		if diff_index > 6 or managers.modifiers and managers.modifiers:check_boolean("TotalAnarchy") then
			self._activeassaultnextbreak_t = self._activeassaultnextbreak_t + 30
		end
		
		local small_map = self._small_map
		
		local value = 64
		
		if self._force_pool then
			if small_map then
				value = self._force_pool / 2
			else
				value = self._force_pool / 3
			end
			
			value = value
		end
		
		if self._enemies_killed_sustain_guaranteed_break then
			self._enemies_killed_sustain_guaranteed_break = self._enemies_killed_sustain_guaranteed_break + value
		end
	end
	
	self._heat_bonus_count = 0
end

function GroupAIStateBase:enemy_killed(unit, attack_data)
	if not attack_data or not attack_data.attacker_unit or not alive(attack_data.attacker_unit) then
		return
	end
	
	local attacker_unit = attack_data.attacker_unit
	
	if attacker_unit:base() then
		if attacker_unit:base().thrower_unit then
			attacker_unit = attacker_unit:base():thrower_unit()
		end
	end
	
	if not alive(attacker_unit) then
		return
	end
	
	local au_key = attacker_unit:key()
	
	if self._criminals[au_key] then
		if self._task_data and self._task_data.assault and self._task_data.assault.phase == "anticipation" and self._task_data.assault.phase_end_t and self._task_data.assault.phase_end_t < self._t then
			self._assault_number = self._assault_number + 1

			managers.mission:call_global_event("start_assault")
			managers.hud:start_assault(self._assault_number)
			managers.groupai:dispatch_event("start_assault", self._assault_number)

			for group_id, group in pairs_g(self._groups) do
				for u_key, u_data in pairs_g(group.units) do
					u_data.unit:sound():say("g90", true)
				end
			end
			
			if managers.modifiers:check_boolean("itmightrain") then
				self._enemy_speed_mul = self._enemy_speed_mul + 0.1
			end
					
			LuaNetworking:SendToPeers("shin_sync_speed_mul",tostring_g(self._enemy_speed_mul))

			self._task_data.assault.phase = "build"
			self._task_data.assault.phase_end_t = self._t + self._tweak_data.assault.build_duration
			self._task_data.assault.is_hesitating = nil

			self:set_assault_mode(true)
			managers.trade:set_trade_countdown(false)
		end
		
		if self._task_data and self._task_data.assault and self._task_data.assault.active then	
			if self._hunt_mode or self._task_data.assault.phase == "sustain" then
				self._enemies_killed_sustain = self._enemies_killed_sustain + 1
			end
		end
		
		local mul = 5 - table.size(self._player_criminals) 
		local val = self._drama_data.actions.enemy_dead * mul

		self:_add_drama(-val)
	end
	
	if self._player_criminals[au_key] or unit:character_damage()._damage_ratio_dealt_by_player and unit:character_damage()._damage_ratio_dealt_by_player > 0.25 then
		self._last_killed_cop_t = self._t
	end
end

function GroupAIStateBase:hostage_killed(killer_unit)
	if not alive(killer_unit) then
		return
	end

	if killer_unit:base() and killer_unit:base().thrower_unit then
		killer_unit = killer_unit:base():thrower_unit()

		if not alive(killer_unit) then
			return
		end
	end

	local key = killer_unit:key()
	local criminal = self._criminals[key]

	if not criminal then
		return
	end

	self._hostages_killed = (self._hostages_killed or 0) + 1

	if not self._hunt_mode then
		if self._hostages_killed >= 1 and not self._hostage_killed_warning_lines then
			if self:sync_hostage_killed_warning(1) then
				managers.network:session():send_to_peers_synched("sync_hostage_killed_warning", 1)

				self._hostage_killed_warning_lines = 1
			end
		elseif self._hostages_killed >= 3 and self._hostage_killed_warning_lines == 1 then
			if self:sync_hostage_killed_warning(2) then
				managers.network:session():send_to_peers_synched("sync_hostage_killed_warning", 2)

				self._hostage_killed_warning_lines = 2
			end
		elseif self._hostages_killed >= 7 and self._hostage_killed_warning_lines == 2 and self:sync_hostage_killed_warning(3) then
			managers.network:session():send_to_peers_synched("sync_hostage_killed_warning", 3)

			self._hostage_killed_warning_lines = 3
		end
	end

	if not criminal.is_deployable then
		local tweak = nil

		if killer_unit:base().is_local_player or killer_unit:base().is_husk_player then
			tweak = tweak_data.player.damage
		else
			tweak = tweak_data.character[killer_unit:base()._tweak_table].damage
		end

		local respawn_penalty = criminal.respawn_penalty or tweak.base_respawn_time_penalty
		criminal.respawn_penalty = respawn_penalty + tweak.respawn_time_penalty
		criminal.hostages_killed = (criminal.hostages_killed or 0) + 1
		
		if Network:is_server() then
			self:_add_drama(0.2)
			
			if criminal.hostage_killed_pen then
				criminal.hostage_killed_pen = criminal.hostage_killed_pen + 0.1
			else
				criminal.hostage_killed_pen = 0.1
			end
			
			if self._hostages_killed > 3 then
				self._drama_data.high_p_reduction = self._drama_data.high_p_reduction + 0.05
			end
		end
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

	local objective = unit:brain():objective()

	if objective and objective.fail_clbk then
		local fail_clbk = objective.fail_clbk
		objective.fail_clbk = nil

		fail_clbk(unit)
	end
	
	--log("dude dead")

	local e_data = self._police[u_key]

	if e_data.importance > 0 then
		for c_key, c_data in pairs_g(self._player_criminals) do
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
	
	--if not self._next_allowed_enemykill_drama_t or self._next_allowed_enemykill_drama_t < self._t then
	--	self:_add_drama(self._drama_data.actions.enemy_dead)
	--	self._next_allowed_enemykill_drama_t = self._t + 2
	--end

	for crim_key, record in pairs_g(self._ai_criminals) do
		record.unit:brain():on_cop_neutralized(u_key)
	end
	
	local unit_tags = unit:base()._char_tweak.tags or {unit:base()._tweak_table}
	
	for i = 1, #unit_tags do
		if self._special_unit_types[unit_tags[i]] then
			self:unregister_special_unit(u_key, unit_tags[i])
		end
	end

	local dead = unit:character_damage():dead()

	if e_data.group then
		self:_remove_group_member(e_data.group, u_key, dead)
	end
	
	if dead and managers.groupai:state():whisper_mode() then
		self._guard_delay_deduction = self._guard_delay_deduction + 0.1
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
		local rotation = Rotation(math_random() * 360, 0, 0)
		local flash_grenade = World:spawn_unit(Idstring(flashbang_unit), data.detonate_pos, rotation)

		flash_grenade:base():activate(data.detonate_pos, data.duration)

		self._smoke_grenades[id] = nil
	else
		data.duration = data.duration == 0 and 15 or data.duration
		
		local smoke_name = Idstring("units/weapons/smoke_grenade_quick/smoke_grenade_quick")
		
		if managers.modifiers and managers.modifiers:check_boolean("HHLetsTryGas") then
			smoke_name = Idstring("units/pd2_dlc_drm/weapons/wpn_gas_smoke/wpn_gas_smoke")
		end
		
		local smoke_grenade = World:spawn_unit(smoke_name, data.detonate_pos, Rotation())

		smoke_grenade:base():activate(data.detonate_pos, data.duration)
		managers.groupai:state():teammate_comment(nil, "g40x_any", data.detonate_pos, true, 2000, false)

		data.grenade = smoke_grenade
	end

	if Network:is_server() then
		managers.network:session():send_to_peers_synched("sync_smoke_grenade", data.detonate_pos, data.detonate_pos, data.duration, data.flashbang and true or false)
	end
end

function GroupAIStateBase:is_area_safe_assault(area)
	for u_key, u_data in pairs_g(self._criminals) do
		if not u_data.is_deployable and area.nav_segs[u_data.tracker:nav_segment()] then
			return
		end
	end

	return true
end

function GroupAIStateBase:_set_rescue_state(state)
	self._rescue_allowed = true
end

function GroupAIStateBase:print_objective(objective)
	if objective then
		log("objective info:")
		
		log(objective.type)
		
		if objective.is_default then
			log("objective is default")
		end
		
		if objective.forced then
			log("forced objective")
		end
		
		if objective.stance then
			log(objective.stance)
		end
		
		if objective.attitude then
			log(objective.attitude)
		end
		
		if objective.path_style then
			log(objective.path_style)
		end
		
		if objective.action then
			log("objective has action type " ..tostring(objective.action.type)..":"..tostring(objective.action.variant))
		end
		
		if objective.element then
			log("objective has element: " .. tostring(objective.element._id))
		end
	else
		log("no objective")
		
		return
	end

	local cmpl_clbk = objective.complete_clbk
	
	if cmpl_clbk then
		log("objective has completion clbk")
	end
	
	local fail_clbk = objective.fail_clbk
	
	if fail_clbk then
		log("objective has fail clbk")
	end
	
	local act_start_clbk = objective.action_start_clbk
	
	if act_start_clbk then
		log("objective has action start clbk")
	end
	
	local ver_clbk = objective.verification_clbk
	
	if ver_clbk then
		log("objective has verification clbk")
	end
	
	local area = objective.area
	
	if area then
		log("objective has area, drawing pillar")
		
		local line = Draw:brush(Color.blue:with_alpha(0.5), 5)
		line:cylinder(area.pos, area.pos + math_up * 1000, 100)
	end
	
	local followup_SO = objective.followup_SO
	
	if followup_SO then
		log("objective has follow up SO")
		
		if followup_SO.type then
			local followup_SO_type_str = followup_SO.type and tostring(followup_SO.type) or "lmao what"
			
			log("f. SO has type: " .. followup_SO_type_str .. "")
		end
	end
	
	local grp_objective = objective.grp_objective
	
	if grp_objective then
		local grp_objective_type_str = grp_objective.type and tostring(grp_objective.type) or "lmao what"
	
		log("objective has group objective!!! type: " .. grp_objective_type_str .. "")
	end
	
	local followup_objective = objective.followup_objective
	
	if followup_objective then
		log("objective has followup objective")
		
		if followup_objective.type then
			local followup_objective_type_str = followup_objective.type and tostring(followup_objective.type) or "lmao what"
			
			log("f. objective has type: " .. followup_objective_type_str .. "")
		end
	end
end

function GroupAIStateBase:_get_anticipation_duration(anticipation_duration_table, is_first)	
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
		return 5
	end
end

function GroupAIStateBase:_merge_coarse_path_by_area(coarse_path)
	local i_nav_seg = #coarse_path
	local last_area = nil

	while i_nav_seg > 0 do
		if #coarse_path > 2 then
			local nav_seg = coarse_path[i_nav_seg][1]
			local area = self:get_area_from_nav_seg_id(nav_seg)

			if last_area and last_area == area then
				table.remove(coarse_path, i_nav_seg)
			else
				last_area = area
			end
		end

		i_nav_seg = i_nav_seg - 1
	end
end

function GroupAIStateBase:set_whisper_mode(state)
	state = state and true or false

	if state == self._whisper_mode then
		return
	end

	self._whisper_mode = state
	self._whisper_mode_change_t = TimerManager:game():time()

	self:set_ambience_flag()

	if Network:is_server() then
		if state then
			self:chk_register_removed_attention_objects()
		else
			self:chk_unregister_irrelevant_attention_objects()

			if not self._switch_to_not_cool_clbk_id then
				self._switch_to_not_cool_clbk_id = "GroupAI_delayed_not_cool"

				managers.enemy:add_delayed_clbk(self._switch_to_not_cool_clbk_id, callback(self, self, "_clbk_switch_enemies_to_not_cool"), self._t + 1)
			end
		end
	end

	self:_call_listeners("whisper_mode", state)

	if not state then
		self:_clear_criminal_suspicion_data()
	end
end

function GroupAIStateBase:register_AI_attention_object(unit, handler, nav_tracker, team, SO_access)
	local store_instead = nil

	if Network:is_server() and not self:whisper_mode() then
		if not nav_tracker and not unit:vehicle_driving() or unit:in_slot(1) then
			store_instead = true
		end
	end

	if store_instead then
		local attention_info = {
			unit = unit,
			handler = handler,
			nav_tracker = nav_tracker,
			team = team,
			SO_access = SO_access
		}

		self:store_removed_attention_object(unit:key(), attention_info)

		return
	end

	self._attention_objects.all[unit:key()] = {
		unit = unit,
		handler = handler,
		nav_tracker = nav_tracker,
		team = team,
		SO_access = SO_access
	}

	self:on_AI_attention_changed(unit:key())
end

function GroupAIStateBase:chk_register_removed_attention_objects()
	if not self._removed_attention_objects then
		return
	end

	local all_attention_objects = self:get_all_AI_attention_objects()

	for u_key, att_info in pairs_g (self._removed_attention_objects) do
		if all_attention_objects[u_key] then
			self._removed_attention_objects[u_key] = nil
		elseif alive_g(att_info.unit) then
			self:register_AI_attention_object(att_info.unit, att_info.handler, att_info.nav_tracker, att_info.team, att_info.SO_access)
			self._removed_attention_objects[u_key] = nil
		end
	end

	self._removed_attention_objects = nil
end

function GroupAIStateBase:store_removed_attention_object(u_key, attention_info)
	self._removed_attention_objects = self._removed_attention_objects or {}

	self._removed_attention_objects[u_key] = attention_info
end

function GroupAIStateBase:chk_unregister_irrelevant_attention_objects()
	local all_attention_objects = self:get_all_AI_attention_objects()

	for u_key, att_info in pairs_g (all_attention_objects) do
		if not att_info.nav_tracker and not att_info.unit:vehicle_driving() or att_info.unit:in_slot(1) then
			self:store_removed_attention_object(u_key, att_info)
			att_info.handler:set_attention(nil)
		end
	end
end

function GroupAIStateBase:on_criminal_suspicion_progress(u_suspect, u_observer, status, client_id)
	if not self._ai_enabled or not self._whisper_mode or self._stealth_hud_disabled then
		return
	end

	local ignore_suspicion = u_observer:brain() and u_observer:brain()._ignore_suspicion
	local observer_is_dead = u_observer:character_damage() and u_observer:character_damage():dead()

	if ignore_suspicion or observer_is_dead then
		return
	end

	local obs_key = u_observer:key()

	if managers.groupai:state():all_AI_criminals()[obs_key] then
		return
	end

	local susp_data = self._suspicion_hud_data
	local susp_key = u_suspect and u_suspect:key()

	local function _sync_status(sync_status_code)
		if Network:is_server() and managers.network:session() then
			if client_id then
				managers.network:session():send_to_peers_synched_except(client_id, "suspicion_hud", u_observer, sync_status_code)
			else
				managers.network:session():send_to_peers_synched("suspicion_hud", u_observer, sync_status_code)
			end
		end
	end

	local obs_susp_data = susp_data[obs_key]

	if status == "called" then
		if obs_susp_data then
			if status == obs_susp_data.status then
				return
			else
				obs_susp_data.suspects = nil
			end
		else
			local icon_id = "susp1" .. tostring_g(obs_key)
			local icon_pos = self._create_hud_suspicion_icon(obs_key, u_observer, "wp_calling_in", tweak_data.hud.suspicion_color, icon_id)
			obs_susp_data = {
				u_observer = u_observer,
				icon_id = icon_id,
				icon_pos = icon_pos
			}
			susp_data[obs_key] = obs_susp_data
		end

		managers.hud:change_waypoint_icon(obs_susp_data.icon_id, "wp_calling_in")
		managers.hud:change_waypoint_arrow_color(obs_susp_data.icon_id, tweak_data.hud.detected_color)

		if obs_susp_data.icon_id2 then
			managers.hud:remove_waypoint(obs_susp_data.icon_id2)

			obs_susp_data.icon_id2 = nil
			obs_susp_data.icon_pos2 = nil
		end

		obs_susp_data.status = "called"
		obs_susp_data.alerted = true
		obs_susp_data.expire_t = self._t + 8
		obs_susp_data.persistent = true

		_sync_status(4)
	elseif status == "calling" then
		if obs_susp_data then
			if status == obs_susp_data.status then
				return
			else
				obs_susp_data.suspects = nil
			end
		else
			local icon_id = "susp1" .. tostring_g(obs_key)
			local icon_pos = self._create_hud_suspicion_icon(obs_key, u_observer, "wp_calling_in", tweak_data.hud.detected_color, icon_id)
			obs_susp_data = {
				u_observer = u_observer,
				icon_id = icon_id,
				icon_pos = icon_pos
			}
			susp_data[obs_key] = obs_susp_data
		end

		if not obs_susp_data.icon_id2 then
			local hazard_icon_id = "susp2" .. tostring_g(obs_key)
			local hazard_icon_pos = self._create_hud_suspicion_icon(obs_key, u_observer, "wp_calling_in_hazard", tweak_data.hud.detected_color, hazard_icon_id)
			obs_susp_data.icon_id2 = hazard_icon_id
			obs_susp_data.icon_pos2 = hazard_icon_pos
		end

		managers.hud:change_waypoint_icon(obs_susp_data.icon_id, "wp_calling_in")
		managers.hud:change_waypoint_arrow_color(obs_susp_data.icon_id, tweak_data.hud.detected_color)
		managers.hud:change_waypoint_icon(obs_susp_data.icon_id2, "wp_calling_in_hazard")
		managers.hud:change_waypoint_arrow_color(obs_susp_data.icon_id2, tweak_data.hud.detected_color)

		obs_susp_data.status = "calling"
		obs_susp_data.alerted = true

		_sync_status(3)
	elseif status == true or status == "call_interrupted" then
		if obs_susp_data then
			if obs_susp_data.status == status then
				return
			else
				obs_susp_data.suspects = nil
			end
		else
			local icon_id = "susp1" .. tostring_g(obs_key)
			local icon_pos = self._create_hud_suspicion_icon(obs_key, u_observer, "wp_detected", tweak_data.hud.detected_color, icon_id)
			obs_susp_data = {
				u_observer = u_observer,
				icon_id = icon_id,
				icon_pos = icon_pos
			}
			susp_data[obs_key] = obs_susp_data
		end

		managers.hud:change_waypoint_icon(obs_susp_data.icon_id, "wp_detected")
		managers.hud:change_waypoint_arrow_color(obs_susp_data.icon_id, tweak_data.hud.detected_color)

		if obs_susp_data.icon_id2 then
			managers.hud:remove_waypoint(obs_susp_data.icon_id2)

			obs_susp_data.icon_id2 = nil
			obs_susp_data.icon_pos2 = nil
		end

		obs_susp_data.status = status
		obs_susp_data.alerted = true

		_sync_status(2)
	elseif not status then
		if obs_susp_data then
			if obs_susp_data.suspects and susp_key then
				obs_susp_data.suspects[susp_key] = nil

				if not next_g(obs_susp_data.suspects) then
					obs_susp_data.suspects = nil
				end
			end

			if not susp_key or not obs_susp_data.alerted and (not obs_susp_data.suspects or not next_g(obs_susp_data.suspects)) then
				managers.hud:remove_waypoint(obs_susp_data.icon_id)

				if obs_susp_data.icon_id2 then
					managers.hud:remove_waypoint(obs_susp_data.icon_id2)
				end

				susp_data[obs_key] = nil

				_sync_status(0)
			end
		end
	else
		if obs_susp_data then
			if obs_susp_data.alerted then
				return
			end

			_sync_status(1)
		elseif not obs_susp_data then
			local icon_id = "susp1" .. tostring_g(obs_key)
			local icon_pos = self._create_hud_suspicion_icon(obs_key, u_observer, "wp_suspicious", tweak_data.hud.suspicion_color, icon_id)
			obs_susp_data = {
				u_observer = u_observer,
				icon_id = icon_id,
				icon_pos = icon_pos
			}
			susp_data[obs_key] = obs_susp_data

			managers.hud:change_waypoint_icon(obs_susp_data.icon_id, "wp_suspicious")
			managers.hud:change_waypoint_arrow_color(obs_susp_data.icon_id, tweak_data.hud.suspicion_color)

			if obs_susp_data.icon_id2 then
				managers.hud:remove_waypoint(obs_susp_data.icon_id2)

				obs_susp_data.icon_id2 = nil
				obs_susp_data.icon_pos2 = nil
			end

			_sync_status(1)
		end

		if susp_key then
			obs_susp_data.suspects = obs_susp_data.suspects or {}

			if obs_susp_data.suspects[susp_key] then
				obs_susp_data.suspects[susp_key].status = status
			else
				obs_susp_data.suspects[susp_key] = {
					status = status,
					u_suspect = u_suspect
				}
			end
		end
	end
end

function GroupAIStateBase:_get_spawn_unit_name(weights, wanted_access_type)
	local unit_categories = tweak_data.group_ai.unit_categories
	local total_weight = 0
	local candidates = {}
	local candidate_weights = {}

	for cat_name, cat_weights in pairs_g(weights) do
		local cat_weight = self:_get_difficulty_dependent_value(cat_weights)
		local suitable = cat_weight > 0
		local cat_data = unit_categories[cat_name]

		if suitable and cat_data.special_type then
			local special_type = cat_data.special_type
			local nr_active = self._special_units[special_type] and table.size(self._special_units[special_type]) or 0
			local active_plus_one = nr_active + 1
			
			
			if active_plus_one > tweak_data.group_ai.special_unit_spawn_limits[special_type] then
				suitable = false
			end
		end

		if suitable and wanted_access_type then
			suitable = false

			for _, available_access_type in ipairs(cat_data.access) do
				if wanted_access_type == available_access_type then
					suitable = true

					break
				end
			end
		end

		if suitable then
			total_weight = total_weight + cat_weight

			table.insert(candidates, cat_name)
			table.insert(candidate_weights, total_weight)
		end
	end

	if total_weight <= 0 then
		return
	end

	local lucky_nr = math_random() * total_weight
	local i_candidate = 1

	while candidate_weights[i_candidate] < lucky_nr do
		i_candidate = i_candidate + 1
	end

	local lucky_cat_name = candidates[i_candidate]
	local lucky_unit_names = unit_categories[lucky_cat_name].units
	local spawn_unit_name = lucky_unit_names[math_random(#lucky_unit_names)]

	return spawn_unit_name, lucky_cat_name
end

function GroupAIStateBase:chk_enemy_calling_in_area(area, except_key)
	local u_data = self._police[except_key]

	if u_data and CopLogicArrest._chk_already_calling_in_area(u_data.unit:brain()._logic_data) then
		return true
	end
end

function GroupAIStateBase:chk_say_teamAI_combat_chatter(unit)
	if not self._assault_mode or self._current_assault_state == "danger" or self._current_assault_state == "lastcrimstanding" or not self:is_detection_persistent() then
		return
	end

	local t = self._t

	local delay = math_lerp(60, 120, math_random())
	local delay_t = self._teamAI_last_combat_chatter_t + delay

	if t < delay_t then
		return
	end

	self._teamAI_last_combat_chatter_t = t

	unit:sound():say("g90", true, true)
end

function GroupAIStateBase:_determine_objective_for_criminal_AI(unit)
	local objective, closest_dis, closest_player = nil
	local ai_pos = unit:movement():m_pos()

	for pl_key, player in pairs_g(self:all_player_criminals()) do
		if player.status ~= "dead" then
			local my_dis = mvec3_dis_sq(ai_pos, player.m_pos)

			if not closest_dis or my_dis < closest_dis then
				closest_dis = my_dis
				closest_player = player
			end
		end
	end

	if closest_player then
		objective = {
			scan = true,
			is_default = true,
			type = "follow",
			follow_unit = closest_player.unit
		}
	end

	if not objective then
		local mov_ext = unit:movement()

		if mov_ext._should_stay then
			mov_ext:set_should_stay(false)
		end

		if self:is_ai_trade_possible() then
			local hostage = managers.trade:get_best_hostage(ai_pos)

			if hostage and mvec3_dis_sq(ai_pos, hostage.m_pos) > 250000 then
				objective = {
					scan = true,
					type = "free",
					haste = "run",
					nav_seg = hostage.tracker:nav_segment()
				}
			end
		end
	end

	return objective
end

function GroupAIStateBase:chk_say_enemy_chatter(unit, unit_pos, chatter_type)
	if unit:sound():speaking(self._t) then
		return
	end

	local chatter_tweak = tweak_data.group_ai.enemy_chatter[chatter_type]
	local chatter_type_hist = unit:sound()._chatter[chatter_type]
	local chatter_type_events = self._enemy_chatter[chatter_type]

	if not chatter_type_hist then
		chatter_type_hist = {
			cooldown_t = 0
		}
		unit:sound()._chatter[chatter_type] = chatter_type_hist
	end
	
	if not chatter_type_events then
		chatter_type_events = {
			events = {},
			global_cooldown_t = 0
		}
		self._enemy_chatter[chatter_type] = chatter_type_events
	end

	local t = self._t

	if t < chatter_type_hist.cooldown_t then
		return
	end
	
	if t < chatter_type_events.global_cooldown_t then
		return
	end
	
	local nr_events_in_area = 0

	for i_event, event_data in pairs_g(chatter_type_events.events) do
		if event_data.expire_t < t then
			chatter_type_hist[i_event] = nil
		elseif mvec3_dis(unit_pos, event_data.epicenter) < chatter_tweak.radius then
			if nr_events_in_area == chatter_tweak.max_nr - 1 then
				return
			else
				nr_events_in_area = nr_events_in_area + 1
			end
		end
	end

	local group_requirement = chatter_tweak.group_min

	if group_requirement and group_requirement > 1 then
		local u_data = self._police[unit:key()]
		
		if not u_data then --fix for a weird as fuck edge-case relating to scripted unit spawns *sigh*
			return
		end
		
		local nr_in_group = 1

		if u_data.group then
			nr_in_group = u_data.group.size
		end

		if nr_in_group < group_requirement then
			return
		end
	end

	chatter_type_hist.cooldown_t = t + math_lerp(chatter_tweak.interval[1], chatter_tweak.interval[2], math_random())
	chatter_type_events.global_cooldown_t = t + math_lerp(chatter_tweak.duration[1], chatter_tweak.duration[2], math_random())
	
	local new_event = {
		epicenter = mvec3_cpy(unit_pos),
		expire_t = chatter_type_hist.cooldown_t
	}
	table.insert(chatter_type_events.events, new_event)

	unit:sound():say(chatter_tweak.queue, true)

	return true
end

function GroupAIStateBase:_try_use_task_spawn_event(t, target_area, task_type, target_pos, force)
	local max_dis = 8000
	local min_dis = 1000
	local mvec3_dis = mvec3_dis
	target_pos = target_pos or target_area.pos

	for event_id, event_data in pairs_g(self._spawn_events) do
		if event_data.task_type == task_type or event_data.task_type == "any" then
			local dis = mvec3_dis(target_pos, event_data.pos)

			if dis > min_dis and dis < max_dis then
				if force or math_random() < event_data.chance then
					self._anticipated_police_force = self._anticipated_police_force + event_data.amount
					self._police_force = self._police_force + event_data.amount

					self:_use_spawn_event(event_data)

					return
				else
					event_data.chance = math_min(1, event_data.chance + event_data.chance_inc)
				end
			end
		end
	end
end

function GroupAIStateBase:is_area_safe_assault(area)
	if next_g(self._player_criminals) then
		for u_key, u_data in pairs_g(self._player_criminals) do
			if area.nav_segs[u_data.tracker:nav_segment()] then
				return
			end
		end
	else
		for u_key, u_data in pairs_g(self._criminals) do
			if not u_data.is_deployable and area.nav_segs[u_data.tracker:nav_segment()] then
				return
			end
		end
	end

	return true
end