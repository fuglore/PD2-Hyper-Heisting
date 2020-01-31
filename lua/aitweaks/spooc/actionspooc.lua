ActionSpooc = ActionSpooc or class()
ActionSpooc._walk_anim_velocities = CopActionWalk._walk_anim_velocities
ActionSpooc._walk_anim_lengths = CopActionWalk._walk_anim_lengths
ActionSpooc._matching_walk_anims = CopActionWalk._matching_walk_anims
ActionSpooc._walk_side_rot = CopActionWalk._walk_side_rot
ActionSpooc._anim_movement = CopActionWalk._anim_movement
ActionSpooc._get_max_walk_speed = CopActionWalk._get_max_walk_speed
ActionSpooc._get_current_max_walk_speed = CopActionWalk._get_current_max_walk_speed
ActionSpooc._global_incremental_action_ID = 1
ActionSpooc._apply_freefall = CopActionWalk._apply_freefall
ActionSpooc._tmp_vec1 = Vector3()
ActionSpooc._tmp_vec2 = Vector3()

function ActionSpooc:init(action_desc, common_data)
	self._common_data = common_data
	self._ext_movement = common_data.ext_movement
	self._ext_anim = common_data.ext_anim
	self._ext_base = common_data.ext_base
	self._ext_network = common_data.ext_network
	self._stance = common_data.stance
	self._machine = common_data.machine
	self._unit = common_data.unit

	if not self._ext_anim.pose then
		print("[ActionSpooc:init] no pose in anim", self._machine:segment_state(Idstring("base")), common_data.unit)
		common_data.ext_movement:play_redirect("idle")

		if not self._ext_anim.pose then
			debug_pause()

			return
		end
	end

	self._action_desc = action_desc
	self._nav_path = action_desc.nav_path or {
		mvector3.copy(common_data.pos)
	}

	self._ext_movement:enable_update()

	self._host_stop_pos_inserted = action_desc.host_stop_pos_inserted
	self._stop_pos = action_desc.stop_pos
	self._nav_index = action_desc.path_index or 1
	self._stroke_t = tonumber(action_desc.stroke_t)
	self._beating_end_t = self._stroke_t and self._stroke_t + math.lerp(self._common_data.char_tweak.spooc_attack_beating_time[1], self._common_data.char_tweak.spooc_attack_beating_time[2], math.random())
	self._strike_nav_index = action_desc.strike_nav_index
	self._haste = "run"
	self._nr_expected_nav_points = action_desc.nr_expected_nav_points
	self._last_vel_z = 0
	self._was_interrupted = action_desc.interrupted
	local is_server = Network:is_server()

	if is_server then
		self._action_id = ActionSpooc._global_incremental_action_ID

		if ActionSpooc._global_incremental_action_ID == 256 then
			ActionSpooc._global_incremental_action_ID = 1
		else
			ActionSpooc._global_incremental_action_ID = ActionSpooc._global_incremental_action_ID + 1
		end
	else
		self._action_id = action_desc.action_id
	end

	local is_local = nil

	if self._was_interrupted then
		is_local = action_desc.is_local

		if is_local then
			local attention = self._ext_movement:attention()
			self._target_unit = attention and attention.unit
		end
	else
		local attention = self._ext_movement:attention()

		if not attention then
			return
		end

		self._target_unit = attention and attention.unit
		is_local = alive(self._target_unit) and (self._target_unit:base().is_local_player or is_server and not self._target_unit:base().is_husk_player)
	end

	if not is_server then
		local host_stop_pos = self._ext_movement:m_host_stop_pos()

		if host_stop_pos ~= common_data.pos then
			table.insert(self._nav_path, 2, mvector3.copy(host_stop_pos))

			self._host_stop_pos_inserted = (self._host_stop_pos_inserted or 0) + 1
		end
	end

	self._is_local = is_local

	if is_local and self._target_unit and self._target_unit:base().is_local_player then
		self._target_unit:movement():on_targetted_for_attack(false, self._common_data.unit)
	end

	if is_server then
		self._ext_network:send("action_spooc_start", self._target_unit:movement():m_pos(), action_desc.flying_strike, self._action_id)
	end

	self._walk_velocity = self:_get_max_walk_speed()
	self._cur_vel = 0
	self._last_pos = mvector3.copy(common_data.pos)

	CopActionAct._create_blocks_table(self, action_desc.blocks)

	if self._was_interrupted then
		self._last_sent_pos = action_desc.last_sent_pos

		if self._nav_path[self._nav_index + 1] then
			self:_start_sprint()
		else
			self:_wait()
		end
	elseif is_local then
		if not is_server and self:_chk_target_invalid() then
			if not action_desc.flying_strike then
				self._last_sent_pos = mvector3.copy(common_data.pos)
			end

			self:_wait()
		elseif action_desc.flying_strike then
			if is_server or ActionSpooc.chk_can_start_flying_strike(self._unit, self._target_unit) then
				self:_set_updator("_upd_flying_strike_first_frame")
			else
				self._ext_network:send_to_host("action_spooc_stop", self._ext_movement:m_pos(), 1, self._action_id)
				self:_wait()
			end
		else
			if action_desc.target_u_pos then
				table.insert(self._nav_path, action_desc.target_u_pos)
			end

			self._chase_tracker = self._target_unit:movement():nav_tracker()
			local chase_pos = self._chase_tracker:field_position()

			table.insert(self._nav_path, chase_pos)

			self._last_sent_pos = mvector3.copy(common_data.pos)

			self:_start_sprint()
		end
	else
		self:_wait()
	end
	local difficulty_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)
	
	if difficulty_index <= 7 then
		if Global.mutators and Global.mutators.telespooc then
			--nothing
		else
			self._unit:sound():play(self:get_sound_event("detect"))
		end
	end
	
	self._unit:damage():run_sequence_simple("kill_spooc_lights")

	local r = LevelsTweakData.LevelType.Russia
	local ai_type = tweak_data.levels:get_ai_group_type()
	self._taunt_during_assault = "cloaker_taunt_during_assault"
	self._taunt_after_assault = "cloaker_taunt_after_assault"

	if ai_type == r then
		self._taunt_during_assault = "rcloaker_taunt_during_assault"
		self._taunt_after_assault = "rcloaker_taunt_after_assault"
	end

	local spooc_sound_events = self._common_data.char_tweak.spooc_sound_events or {}
	self._taunt_during_assault = spooc_sound_events.taunt_during_assault or self._taunt_during_assault
	self._taunt_after_assault = spooc_sound_events.taunt_after_assault or self._taunt_after_assault

	return true
end

function ActionSpooc:on_exit()
	if self._unit:character_damage():dead() then
		self._unit:sound():play(self:get_sound_event("detect_stop"))
	else
		self._unit:sound():play(self._unit:base():char_tweak().spawn_sound_event)
		
		if not Global.mutators.telespooc then
			self._unit:damage():run_sequence_simple("turn_on_spook_lights")
		end
		
		if self._is_local and self._taunt_at_beating_played and not self._unit:sound():speaking(TimerManager:game():time()) then
			self._unit:sound():say(self._taunt_after_assault, true, true)
		end
	end

	if self._root_blend_disabled then
		self._ext_movement:set_root_blend(true)
	end

	if self._expired and self._common_data.ext_anim.move then
		self:_stop_walk()
	end

	self._ext_movement:drop_held_items()

	if Network:is_server() then
		local stop_nav_index = math.min(256, self._nav_index - (self._host_stop_pos_inserted or 0))

		self._ext_network:send("action_spooc_stop", mvector3.copy(self._ext_movement:m_pos()), stop_nav_index, self._action_id)
	else
		self._ext_movement:set_m_host_stop_pos(self._ext_movement:m_pos())
	end

	if alive(self._target_unit) and self._target_unit:base().is_local_player then
		self._target_unit:movement():on_targetted_for_attack(false, self._common_data.unit)
	end
end

function ActionSpooc:complete()
	local complete = self._beating_end_t and self._beating_end_t < TimerManager:game():time() or self._beating_end_t and self._last_vel_z >= 0
	
	return complete --https://www.youtube.com/watch?v=XvGRaxtPb3Y
end

function ActionSpooc:_upd_strike_first_frame(t)
	if self._is_local and self:_chk_target_invalid() then
		if Network:is_server() then
			self:_expire()
		else
			self:_wait()
		end

		return
	end

	local redir_result = self._ext_movement:play_redirect("spooc_strike")
	self._unit:damage():run_sequence_simple("kill_spooc_lights")
	
	if redir_result then
		self._ext_movement:spawn_wanted_items()
	elseif self._is_local then
		if Network:is_server() then
			self:_expire()
		else
			self._ext_network:send_to_host("action_spooc_stop", self._ext_movement:m_pos(), 1, self._action_id)
			self:_wait()
		end

		return
	end

	if self._is_local then
		mvector3.set(self._last_sent_pos, self._common_data.pos)
		self._ext_network:send("action_spooc_strike", mvector3.copy(self._common_data.pos), self._action_id)

		self._nav_path[self._nav_index + 1] = mvector3.copy(self._common_data.pos)

		if self._target_unit:base().is_local_player then
			local enemy_vec = mvector3.copy(self._common_data.pos)

			mvector3.subtract(enemy_vec, self._target_unit:movement():m_pos())
			mvector3.set_z(enemy_vec, 0)
			mvector3.normalize(enemy_vec)
			--self._target_unit:camera():camera_unit():base():clbk_aim_assist({
			--	ray = enemy_vec
			--})
			--no more aim assist BS
		end
	end

	self._last_vel_z = 0

	self:_set_updator("_upd_striking")
	self._common_data.unit:base():chk_freeze_anims()
end

function ActionSpooc:_upd_flying_strike_first_frame(t)
	local target_pos = nil

	if self._is_local then
		target_pos = self._target_unit:movement():m_pos()

		self:_send_nav_point(target_pos)
	else
		target_pos = self._nav_path[#self._nav_path]
	end
	
	self._unit:damage():run_sequence_simple("kill_spooc_lights")
	
	local my_pos = self._unit:movement():m_pos()
	local target_vec = self._tmp_vec1

	mvector3.set(target_vec, target_pos)
	mvector3.subtract(target_vec, my_pos)

	local target_dis = mvector3.length(target_vec)
	local redir_result = self._ext_movement:play_redirect("spooc_flying_strike")

	if not redir_result then
		debug_pause_unit(self._unit, "[ActionSpooc:_chk_start_flying_strike] failed redirect spooc_flying_strike in ", self._machine:segment_state(Idstring("base")), self._unit)

		return
	end

	self._ext_movement:spawn_wanted_items()

	local anim_travel_dis_xy = 470
	self._flying_strike_data = {
		start_pos = mvector3.copy(my_pos),
		start_rot = self._unit:rotation(),
		target_pos = mvector3.copy(target_pos),
		target_rot = Rotation(target_vec:with_z(0), math.UP),
		start_t = TimerManager:game():time(),
		travel_dis_scaling_xy = target_dis / anim_travel_dis_xy
	}
	local speed_mul = math.lerp(3, 1, math.min(1, self._flying_strike_data.travel_dis_scaling_xy))

	self._machine:set_speed(redir_result, speed_mul)

	if alive(self._target_unit) and self._target_unit:base().is_local_player then
		local enemy_vec = mvector3.copy(self._common_data.pos)

		mvector3.subtract(enemy_vec, self._target_unit:movement():m_pos())
		mvector3.set_z(enemy_vec, 0)
		mvector3.normalize(enemy_vec)
		--self._target_unit:camera():camera_unit():base():clbk_aim_assist({
		--	ray = enemy_vec
		--})
	end

	self:_set_updator("_upd_flying_strike")
end

function ActionSpooc:get_sound_event(sound)
	local sound_events = self._unit:base():char_tweak().spooc_sound_events
	local event = sound_events and sound_events[sound]
	
	if not sound_events then
		local sound_events = {
			detect_stop = "cloaker_detect_stop",
			detect = "cloaker_detect_mono"
		}
		event = sound_events[sound] or event
	end

	if self:_use_christmas_sounds() then
		local christmas_events = {
			detect_stop = "cloaker_detect_christmas_stop",
			detect = "cloaker_detect_christmas_mono"
		}
		event = christmas_events[sound] or event
	end

	return event
end