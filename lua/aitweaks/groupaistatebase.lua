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
	self._current_assault_state = "normal"
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
	self._special_unit_types['fbi'] = true
	self._special_unit_types['fbi_xc45'] = true
	self._special_unit_types['tank_mini'] = true
	self._special_unit_types['sniper'] = true
	self._special_unit_types['armored_sniper'] = true
	self._special_unit_types['assault_sniper'] = true
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
	self._current_assault_state = "normal"
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
	self._special_unit_types['fbi'] = true
	self._special_unit_types['fbi_xc45'] = true
	self._special_unit_types['tank_mini'] = true
	self._special_unit_types['sniper'] = true	
	self._special_unit_types['armored_sniper'] = true
	self._special_unit_types['assault_sniper'] = true	
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
end

function GroupAIStateBase:get_assault_hud_state()
	local nr_players = 0
	local nr_players_alive = 0

	for u_key, u_data in pairs(self:all_player_criminals()) do
		nr_players = nr_players + 1
		if not u_data.status or u_data.status and u_data.status == "electrified" then
			nr_players_alive = nr_players_alive + 1
		end
	end
	
	local nr_ai = 0
	local nr_ai_alive = 0

	for u_key, u_data in pairs(self:all_AI_criminals()) do
		nr_ai = nr_ai + 1
		if not u_data.status or u_data.status and u_data.status == "electrified" then
			nr_ai_alive = nr_ai_alive + 1
		end
	end	
	
	local nr_people = nr_players + nr_ai
	local nr_people_alive = nr_players_alive + nr_ai_alive
	
	if self._activeassaultbreak then
		self._current_assault_state = "heat"
	elseif nr_people < 3 or nr_people_alive < nr_people then
		local lastcrimstanding = nr_people_alive < 2
		
		if lastcrimstanding then
			self._current_assault_state = "lastcrimstanding"
		else
			if nr_people_alive < 3 then
				self._current_assault_state = "danger"
			end
		end
	else
		self._current_assault_state = "normal"
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

	self:_upd_criminal_suspicion_progress()
	self:_claculate_drama_value()
	--self:_draw_current_logics()
	if Network:is_server() then
		local new_value = self._police_force * 0.15 * table.size(self:all_player_criminals())

		self._nr_important_cops = new_value
	end
	
	if self._draw_drama then
		self:_debug_draw_drama(t)
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
		self._danger_state = true
		
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
		self._drama_data.low_p = drama_tweak.low
	elseif self._assault_number == 2 then
		self._drama_data.low_p = drama_tweak.low_2nd
	elseif self._assault_number >= 3 then
		self._drama_data.low_p = drama_tweak.low_3rd
	end
end

function GroupAIStateBase:_check_assault_panic_chatter()
	if self._t and self._last_killed_cop_t and self._t - self._last_killed_cop_t < 5 then
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
	for group_id, group in pairs(self._groups) do
		for u_key, u_data in pairs(group.units) do
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

			for group_id, group in pairs(self._groups) do
				for u_key, u_data in pairs(group.units) do
					u_data.unit:sound():say("att", true)
				end
			end
			
			if managers.modifiers:check_boolean("itmightrain") then
				self._enemy_speed_mul = self._enemy_speed_mul + 0.1
			end
					
			LuaNetworking:SendToPeers("shin_sync_speed_mul",tostring(self._enemy_speed_mul))

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

	local objective = unit:brain():objective()

	if objective and objective.fail_clbk then
		local fail_clbk = objective.fail_clbk
		objective.fail_clbk = nil

		fail_clbk(unit)
	end
	
	--log("dude dead")

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
	
	if self._task_data and self._task_data.assault and self._task_data.assault.phase == "anticipation" and self._task_data.assault.phase_end_t and self._task_data.assault.phase_end_t < self._t then
		self._assault_number = self._assault_number + 1

		managers.mission:call_global_event("start_assault")
		managers.hud:start_assault(self._assault_number)
		managers.groupai:dispatch_event("start_assault", self._assault_number)

		for group_id, group in pairs(self._groups) do
			for u_key, u_data in pairs(group.units) do
				u_data.unit:sound():say("g90", true)
			end
		end
		
		if managers.modifiers:check_boolean("itmightrain") then
			self._enemy_speed_mul = self._enemy_speed_mul + 0.1
		end
				
		LuaNetworking:SendToPeers("shin_sync_speed_mul",tostring(self._enemy_speed_mul))

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
			--self:_voice_friend_dead(e_data.group)
			self._last_killed_cop_t = self._t
		end
		
		if dead and self._task_data and self._task_data.assault and self._task_data.assault.phase == "sustain" and self._task_data.assault.active then
			self._enemies_killed_sustain = self._enemies_killed_sustain + 1
		end
	end
	
	if dead and managers.groupai:state():whisper_mode() then
		self._guard_detection_mul = self._guard_detection_mul + 1
		self._guard_delay_deduction = self._guard_delay_deduction + 0.2
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

function GroupAIStateBase:criminal_hurt_drama_armor(unit, attacker)
	local drama_data = self._drama_data

	if alive(attacker) then
		local drama_amount = 0.1
		local max_dis = drama_data.max_dis_armor
		local dis_lerp = math.min(1, mvec3_dis(attacker:movement():m_pos(), unit:movement():m_pos()) / drama_data.max_dis_armor)
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

function GroupAIStateBase:_set_rescue_state(state)
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

	for u_key, att_info in pairs (self._removed_attention_objects) do
		if all_attention_objects[u_key] then
			self._removed_attention_objects[u_key] = nil
		elseif alive(att_info.unit) then
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

	for u_key, att_info in pairs (all_attention_objects) do
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
			local icon_id = "susp1" .. tostring(obs_key)
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
			local icon_id = "susp1" .. tostring(obs_key)
			local icon_pos = self._create_hud_suspicion_icon(obs_key, u_observer, "wp_calling_in", tweak_data.hud.detected_color, icon_id)
			obs_susp_data = {
				u_observer = u_observer,
				icon_id = icon_id,
				icon_pos = icon_pos
			}
			susp_data[obs_key] = obs_susp_data
		end

		if not obs_susp_data.icon_id2 then
			local hazard_icon_id = "susp2" .. tostring(obs_key)
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
			local icon_id = "susp1" .. tostring(obs_key)
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

				if not next(obs_susp_data.suspects) then
					obs_susp_data.suspects = nil
				end
			end

			if not susp_key or not obs_susp_data.alerted and (not obs_susp_data.suspects or not next(obs_susp_data.suspects)) then
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
			local icon_id = "susp1" .. tostring(obs_key)
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

	for cat_name, cat_weights in pairs(weights) do
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

	local lucky_nr = math.random() * total_weight
	local i_candidate = 1

	while candidate_weights[i_candidate] < lucky_nr do
		i_candidate = i_candidate + 1
	end

	local lucky_cat_name = candidates[i_candidate]
	local lucky_unit_names = unit_categories[lucky_cat_name].units
	local spawn_unit_name = lucky_unit_names[math.random(#lucky_unit_names)]

	return spawn_unit_name, lucky_cat_name
end

function GroupAIStateBase:_determine_objective_for_criminal_AI(unit)
	local objective, closest_dis, closest_record = nil
	local ai_pos = (self._ai_criminals[unit:key()] or self._police[unit:key()]).m_pos

	for pl_key, pl_record in pairs(self._player_criminals) do
		if pl_record.status ~= "dead" then
			local my_dis = mvec3_dis(ai_pos, pl_record.m_pos)

			if not closest_dis or my_dis < closest_dis then
				closest_dis = my_dis
				closest_record = pl_record
			end
		end
	end

	if closest_record then
		objective = {
			scan = true,
			is_default = true,
			type = "follow",
			follow_unit = closest_record.unit
		}
	end

	local ai_pos = (self._ai_criminals[unit:key()] or self._police[unit:key()]).m_pos
	local skip_hostage_trade_time_reset = nil

	if not objective and self:is_ai_trade_possible() then
		local guard_time = managers.trade:get_guard_hostage_time()

		if guard_time >= 3 then
			local hostage = managers.trade:get_best_hostage(ai_pos)
			skip_hostage_trade_time_reset = hostage

			if hostage then
				self._guard_hostage_trade_time_map = self._guard_hostage_trade_time_map or {}
				local time = Application:time()
				local unit_key = unit:key()
				local last_time = self._guard_hostage_trade_time_map[unit_key]

				if not last_time or time > last_time + 6 then
					self._guard_hostage_trade_time_map[unit_key] = time

					return {
						scan = true,
						type = "free",
						stance = "hos",
						guard_unit = hostage.unit,
						nav_seg = hostage.tracker:nav_segment()
					}
				end
			end
		end
	end

	if not skip_hostage_trade_time_reset then
		self._guard_hostage_trade_time_map = nil
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

	for i_event, event_data in pairs(chatter_type_events.events) do
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

	chatter_type_hist.cooldown_t = t + math.lerp(chatter_tweak.interval[1], chatter_tweak.interval[2], math.random())
	chatter_type_events.global_cooldown_t = t + math.lerp(chatter_tweak.duration[1], chatter_tweak.duration[2], math.random())
	
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

	for event_id, event_data in pairs(self._spawn_events) do
		if event_data.task_type == task_type or event_data.task_type == "any" then
			local dis = mvec3_dis(target_pos, event_data.pos)

			if dis > min_dis and dis < max_dis then
				if force or math.random() < event_data.chance then
					self._anticipated_police_force = self._anticipated_police_force + event_data.amount
					self._police_force = self._police_force + event_data.amount

					self:_use_spawn_event(event_data)

					return
				else
					event_data.chance = math.min(1, event_data.chance + event_data.chance_inc)
				end
			end
		end
	end
end

function GroupAIStateBase:_execute_so(so_data, so_rooms, so_administered)
	local max_dis = so_data.search_dis_sq
	local pos = so_data.search_pos
	local ai_group = so_data.AI_group
	local so_access = so_data.access
	local mvec3_dis_sq = mvector3.distance_sq
	local closest_u_data, closest_dis = nil
	local so_objective = so_data.objective
	local nav_manager = managers.navigation
	local access_f = nav_manager.check_access

	local function check_allowed(u_key, u_unit_dat)
		return (not so_administered or not so_administered[u_key]) and (so_objective.forced or u_unit_dat.unit:brain():is_available_for_assignment(so_objective)) and (not so_data.verification_clbk or so_data.verification_clbk(u_unit_dat.unit)) and access_f(nav_manager, so_access, u_unit_dat.so_access, 0)
	end

	if ai_group == "enemies" then
		for e_key, enemy_unit_data in pairs(self._police) do
			if check_allowed(e_key, enemy_unit_data) and not enemy_unit_data.unit:brain():surrendered() then
				local dis = max_dis and mvec3_dis_sq(enemy_unit_data.m_pos, pos)

				if (not closest_dis or dis < closest_dis) and (not max_dis or dis < max_dis) then
					closest_u_data = enemy_unit_data
					closest_dis = dis
				end
			end
		end
	elseif ai_group == "friendlies" then
		for u_key, u_unit_data in pairs(self._ai_criminals) do
			if check_allowed(u_key, u_unit_data) then
				local dis = mvec3_dis_sq(u_unit_data.m_pos, pos)

				if (not closest_dis or dis < closest_dis) and (not max_dis or dis < max_dis) then
					closest_u_data = u_unit_data
					closest_dis = dis
				end
			end
		end
	elseif ai_group == "civilians" then
		for u_key, u_unit_data in pairs(managers.enemy:all_civilians()) do
			if check_allowed(u_key, u_unit_data) then
				local dis = mvec3_dis_sq(u_unit_data.m_pos, pos)

				if (not closest_dis or dis < closest_dis) and (not max_dis or dis < max_dis) then
					closest_u_data = u_unit_data
					closest_dis = dis
				end
			end
		end
	else
		for u_key, civ_unit_data in pairs(managers.enemy:all_civilians()) do
			if access_f(nav_manager, so_access, civ_unit_data.so_access, 0) then
				closest_u_data = civ_unit_data

				break
			end
		end
	end

	if closest_u_data then
		if so_data.admin_clbk then
			so_data.admin_clbk(closest_u_data.unit)
		end

		local objective_copy = self.clone_objective(so_objective)

		closest_u_data.unit:brain():set_objective(objective_copy)
	end

	return closest_u_data
end

function GroupAIStateBase:is_area_safe_assault(area)
	if next(self._player_criminals) then
		for u_key, u_data in pairs(self._player_criminals) do
			if area.nav_segs[u_data.tracker:nav_segment()] then
				return
			end
		end
	else
		for u_key, u_data in pairs(self._criminals) do
			if not u_data.is_deployable and area.nav_segs[u_data.tracker:nav_segment()] then
				return
			end
		end
	end

	return true
end