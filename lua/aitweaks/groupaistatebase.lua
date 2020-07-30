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

function GroupAIStateBase:get_assault_hud_state()
	local nr_players = 0
	local nr_players_alive = 0

	for u_key, u_data in pairs(self:all_player_criminals()) do
		nr_players = nr_players + 1
		if not u_data.status then
			nr_players_alive = nr_players_alive + 1
		end
	end
	
	local nr_ai = 0
	local nr_ai_alive = 0

	for u_key, u_data in pairs(self:all_AI_criminals()) do
		nr_ai = nr_ai + 1
		if not u_data.status then
			nr_ai_alive = nr_ai_alive + 1
		end
	end	
	
	local nr_people = nr_players + nr_ai
	local nr_people_alive = nr_players_alive + nr_ai_alive
	
	if nr_people < 3 or nr_people_alive < nr_people then
		local lastcrimstanding = nr_people_alive < 2
		
		if lastcrimstanding then
			self._current_assault_state = "lastcrimstanding"
		else
			if nr_people_alive < 3 then
				self._current_assault_state = "danger"
			end
		end
	else
		if self._activeassaultbreak then
			self._current_assault_state = "heat"
		else
			self._current_assault_state = "normal"
		end
	end
	
end

function GroupAIStateBase:update(t, dt)
	self._t = t

	self:_upd_criminal_suspicion_progress()
	self:_claculate_drama_value()
	-- self:_draw_current_logics()
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
	if self._t and self._last_killed_cop_t and self._t - self._last_killed_cop_t < math.random(0.15, 1.2) then
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

	local objective = unit:brain():objective()

	if objective and objective.fail_clbk then
		local fail_clbk = objective.fail_clbk
		objective.fail_clbk = nil

		fail_clbk(unit)
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
			if self._task_data and self._task_data.assault and self._task_data.assault.phase == "sustain" and self._task_data.assault.active then
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

local _remove_group_member_ori = GroupAIStateBase._remove_group_member
function GroupAIStateBase:_remove_group_member(group, u_key, is_casualty)
	_remove_group_member_ori(self, group, u_key, is_casualty)
	if is_casualty then
		local unit_to_scream = group.units[math.random(#group.units)]
		if unit_to_scream then
			unit_to_scream:sound():say("buddy_died", true)
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
