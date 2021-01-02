function SecurityCamera:_upd_suspicion(t)

	local function _exit_func(attention_data)
		attention_data.unit:movement():on_uncovered(self._unit)
		self:_sound_the_alarm(attention_data)
	end

	local max_suspicion = 0

	for u_key, attention_data in pairs(self._detected_attention_objects) do
		if attention_data.identified and attention_data.reaction == AIAttentionObject.REACT_SUSPICIOUS then
			if not attention_data.verified then
				if attention_data.uncover_progress then
					local dt = t - attention_data.last_suspicion_t
					attention_data.uncover_progress = attention_data.uncover_progress - dt

					if attention_data.uncover_progress <= 0 then
						attention_data.uncover_progress = nil
						attention_data.last_suspicion_t = nil

						attention_data.unit:movement():on_suspicion(self._unit, false)
						managers.groupai:state():on_criminal_suspicion_progress(attention_data.unit, self._unit, false)
					else
						max_suspicion = math.max(max_suspicion, attention_data.uncover_progress)

						attention_data.unit:movement():on_suspicion(self._unit, attention_data.uncover_progress)

						attention_data.last_suspicion_t = t
					end
				end
			else
				local dis = attention_data.dis
				local susp_settings = attention_data.unit:base():suspicion_settings()
				local suspicion_range = self._suspicion_range
				local uncover_range = 0
				local max_range = self._range

				if attention_data.settings.uncover_range and dis < math.min(max_range, uncover_range) * susp_settings.range_mul then
					attention_data.unit:movement():on_suspicion(self._unit, true)
					managers.groupai:state():on_criminal_suspicion_progress(attention_data.unit, self._unit, true)
					managers.groupai:state():criminal_spotted(attention_data.unit)

					max_suspicion = 1

					_exit_func(attention_data)
				elseif suspicion_range and dis < math.min(max_range, suspicion_range) * susp_settings.range_mul then
					if attention_data.last_suspicion_t then
						local dt = t - attention_data.last_suspicion_t
						local range_max = (suspicion_range - uncover_range) * susp_settings.range_mul
						local range_min = uncover_range
						local mul = 1 - (dis - range_min) / range_max
						local progress = dt * 0.5 * mul * susp_settings.buildup_mul
						attention_data.uncover_progress = (attention_data.uncover_progress or 0) + progress
						max_suspicion = math.max(max_suspicion, attention_data.uncover_progress)

						if attention_data.uncover_progress < 1 then
							attention_data.unit:movement():on_suspicion(self._unit, attention_data.uncover_progress)

							attention_data.last_suspicion_t = t
						else
							attention_data.unit:movement():on_suspicion(self._unit, true)
							managers.groupai:state():on_criminal_suspicion_progress(attention_data.unit, self._unit, true)
							managers.groupai:state():criminal_spotted(attention_data.unit)
							_exit_func(attention_data)
						end
					else
						attention_data.uncover_progress = 0

						managers.groupai:state():on_criminal_suspicion_progress(attention_data.unit, self._unit, 0)

						attention_data.last_suspicion_t = t
					end
				elseif attention_data.uncover_progress and attention_data.last_suspicion_t then
					local dt = t - attention_data.last_suspicion_t
					attention_data.uncover_progress = attention_data.uncover_progress - dt

					if attention_data.uncover_progress <= 0 then
						attention_data.uncover_progress = nil
						attention_data.last_suspicion_t = nil

						attention_data.unit:movement():on_suspicion(self._unit, false)
						managers.groupai:state():on_criminal_suspicion_progress(attention_data.unit, self._unit, false)
					else
						attention_data.last_suspicion_t = t
						max_suspicion = math.max(max_suspicion, attention_data.uncover_progress)

						attention_data.unit:movement():on_suspicion(self._unit, attention_data.uncover_progress)
					end
				end
			end
		end
	end

	self._suspicion = max_suspicion > 0 and max_suspicion
end

function SecurityCamera:_upd_sound(unit, t)
	if self._alarm_sound then
		return
	end

	local suspicion_level = self._suspicion

	for u_key, attention_info in pairs(self._detected_attention_objects) do
		if AIAttentionObject.REACT_SCARED <= attention_info.reaction then
			if attention_info.identified then
				self:_sound_the_alarm(attention_info)

				return
			elseif not suspicion_level or suspicion_level < attention_info.notice_progress then
				suspicion_level = attention_info.notice_progress
			end
		end
	end

	if not suspicion_level then
		self:_set_suspicion_sound(0)
		self:_stop_all_sounds()

		return
	end

	self:_set_suspicion_sound(suspicion_level)
end

function SecurityCamera:_sound_the_alarm(attention_info)
	if self._alarm_sound then
		return
	end

	if Network:is_server() then
		self:_send_net_event(self._NET_EVENTS.alarm_start)

		self._continue_detecting_clbk_id = "cam_restart_detection" .. tostring(self._unit:key())

		managers.enemy:add_delayed_clbk(self._continue_detecting_clbk_id, callback(self, self, "restart_detection"), Application:time() + 10)
		
		local pos = nil
		
		if attention_info.nav_tracker then
			pos = attention_info.nav_tracker:field_position()
		else
			local unit_pos = attention_info.unit:position()
			local temp_tracker = managers.navigation:create_nav_tracker(unit_pos, false)
			pos = temp_tracker:field_position()

			managers.navigation:destroy_nav_tracker(temp_tracker)	
		end
		
		self:_register_investigate_SO(pos)
		
		self:_destroy_all_detected_attention_object_data()
		managers.groupai:state():on_criminal_suspicion_progress(nil, self._unit, nil)
		self:set_detection_enabled(false, nil, nil)
	end

	if self._suspicion_sound then
		self._suspicion_sound = nil

		self._unit:sound_source():post_event("camera_suspicious_signal_stop")
	end

	--self._alarm_sound = self._unit:sound_source():post_event("camera_alarm_signal")
end

function SecurityCamera:restart_detection()
	if self._destroyed or self._destroying or not alive(self._unit) or managers.groupai:state():enemy_weapons_hot() or not managers.groupai:state():whisper_mode() then
		return
	end

	self._continue_detecting_clbk_id = nil
	self:set_detection_enabled(true, self._camera_settings or nil, nil)
end

function SecurityCamera:_register_investigate_SO(pos) --Ahah! I've spotted you!
	if self._investigate_SO_data then
		return
	end

	if not Network:is_server() or not managers.navigation:is_data_ready() then
		return
	end
	
	if self._destroyed or self._destroying or not alive(self._unit) or managers.groupai:state():enemy_weapons_hot() or not managers.groupai:state():whisper_mode() then
		return
	end

	local SO_category = "enemies"
	local SO_filter = managers.navigation:convert_SO_AI_group_to_access(SO_category)
	local nav_manager = managers.navigation
	local f_get_nav_seg = nav_manager.get_nav_seg_from_pos
	local nav_seg = f_get_nav_seg(nav_manager, pos)
	local area = managers.groupai:state():get_area_from_nav_seg_id(nav_seg)
	
	local investigate_objective = {
		pose = "stand",
		type = "free",
		interrupt_health = 1,
		stance = "ntl",
		haste = "run",
		investigating = true,
		interrupt_dis = -1,
		area = area,
		nav_seg = nav_seg,
		pos = pos,
		fail_clbk = callback(self, self, "on_investigate_SO_failed"),
		complete_clbk = callback(self, self, "on_investigate_SO_completed"),
		action_duration = math.lerp(2, 4, math.random())
	}
	local so_descriptor = {
		interval = 0,
		base_chance = 1,
		AI_group = "enemies",
		chance_inc = 0,
		usage_amount = 1,
		objective = investigate_objective,
		search_pos = pos,
		verification_clbk = callback(self, self, "clbk_investigate_SO_verification"),
		admin_clbk = callback(self, self, "on_investigate_SO_administered")
	}
	local so_id = "Camera_investigate" .. tostring(self._unit:key())
	self._investigate_SO_data = {
		SO_registered = true,
		SO_id = so_id,
		SO_area = area
	}

	managers.groupai:state():add_special_objective(so_id, so_descriptor)
end

function SecurityCamera:_unregister_investigate_SO()
	if not self._investigate_SO_data then
		return
	end

	if self._investigate_SO_data.SO_registered then
		managers.groupai:state():remove_special_objective(self._investigate_SO_data.SO_id)
	elseif self._investigate_SO_data.receiver_unit then
		local receiver_unit = self._investigate_SO_data.receiver_unit
		self._investigate_SO_data.receiver_unit = nil

		if alive(receiver_unit) then
			if self._investigate_SO_data.old_objective and receiver_unit:movement():cool() then
				receiver_unit:brain():set_objective(self._investigate_SO_data.old_objective)
			else
				receiver_unit:brain():set_objective(nil)
			end
		end
	end

	self._investigate_SO_data = nil
end

function SecurityCamera:clbk_investigate_SO_verification(candidate_unit)
	if not self._investigate_SO_data or not self._investigate_SO_data.SO_id then
		return
	end

	if not candidate_unit:movement():cool() then
		return
	end

	return true
end

function SecurityCamera:on_investigate_SO_administered(receiver_unit)
	if alive(receiver_unit) and receiver_unit:brain() and receiver_unit:brain():objective() then
		self._investigate_SO_data.old_objective = receiver_unit:brain():objective()
	end
	
	self._investigate_SO_data.receiver_unit = receiver_unit
	self._investigate_SO_data.SO_registered = false
end

function SecurityCamera:on_investigate_SO_completed(receiver_unit)
	if receiver_unit ~= self._investigate_SO_data.receiver_unit then
		return
	end
	
	--[[if self._investigate_SO_data.area then
		local area = self._investigate_SO_data.area
		
		if not next(area.criminal.units) then
			if self._investigate_SO_data.old_objective then
				receiver_unit:brain():set_objective(self._investigate_SO_data.old_objective)
			end
		else		
			local patrol_objective = {
				pose = "stand",
				type = "patrol",
				area = area,
				interrupt_health = 1,
				stance = "ntl",
				interrupt_dis = -1,
				followup_objective = self._investigate_SO_data.old_objective
			}
			receiver_unit:brain():set_objective(patrol_objective)
		end
	end]]--
	
	if self._investigate_SO_data.old_objective then
		receiver_unit:brain():set_objective(self._investigate_SO_data.old_objective)
		self._investigate_SO_data.old_objective = nil
	end
	
	local area = self._investigate_SO_data and self._investigate_SO_data.SO_area
	self._investigate_SO_data = nil
	
	if next(area.criminal.units) then
		for u_key, u_data in pairs(area.criminal.units) do
			self:_register_investigate_SO(u_data.tracker:field_position())
			
			break
		end
	end
end

function SecurityCamera:on_investigate_SO_failed(receiver_unit)
	if not self._investigate_SO_data.receiver_unit then
		return
	end

	if receiver_unit ~= self._investigate_SO_data.receiver_unit then
		return
	end
	
	if self._investigate_SO_data.old_objective and receiver_unit:movement():cool() then
		receiver_unit:brain():set_objective(self._investigate_SO_data.old_objective)
		self._investigate_SO_data.old_objective = nil
	end
	
	local area = self._investigate_SO_data and self._investigate_SO_data.SO_area
	self._investigate_SO_data = nil
	
	if next(area.criminal.units) then
		for u_key, u_data in pairs(area.criminal.units) do
			self:_register_investigate_SO(u_data.tracker:field_position())
			
			break
		end
	end
end

function SecurityCamera:set_detection_enabled(state, settings, mission_element)
	if self._destroyed then
		return
	end

	self:set_update_enabled(state)

	self._mission_script_element = mission_element or self._mission_script_element
	
	if settings then
		if not self._camera_settings or self._camera_settings ~= settings then
			self._camera_settings = settings
		end
	end

	if state then
		self._u_key = self._unit:key()
		self._last_detect_t = self._last_detect_t or TimerManager:game():time()
		self._detection_interval = 0.1
		self._SO_access_str = "security"
		self._SO_access = managers.navigation:convert_access_filter_to_number({
			self._SO_access_str
		})
		self._visibility_slotmask = managers.slot:get_mask("AI_visibility")

		if settings then
			self._cone_angle = settings.fov
			self._detection_delay = settings.detection_delay
			self._range = settings.detection_range
			self._suspicion_range = settings.suspicion_range
			self._team = managers.groupai:state():team_data(settings.team_id or tweak_data.levels:get_default_team_ID("combatant"))
		end

		self._detected_attention_objects = self._detected_attention_objects or {}
		self._look_obj = self._unit:get_object(Idstring("CameraLens"))
		self._yaw_obj = self._unit:get_object(Idstring("CameraYaw"))
		self._pitch_obj = self._unit:get_object(Idstring("CameraPitch"))
		self._pos = self._yaw_obj:position()
		self._look_fwd = nil
		self._tmp_vec1 = self._tmp_vec1 or Vector3()
		self._suspicion_lvl_sync = 0
	else
		self._last_detect_t = nil

		self:_destroy_all_detected_attention_object_data()

		self._brush = nil
		self._visibility_slotmask = nil
		self._detection_delay = nil
		self._look_obj = nil
		self._yaw_obj = nil
		self._pitch_obj = nil
		self._pos = nil
		self._look_fwd = nil
		self._tmp_vec1 = nil
		self._detected_attention_objects = nil
		self._suspicion_lvl_sync = nil
		self._team = nil

		if not self._destroying then
			self:_stop_all_sounds()
			self:_deactivate_tape_loop()
		end
	end

	if settings then
		self:apply_rotations(settings.yaw, settings.pitch)
	end

	managers.groupai:state():register_security_camera(self._unit, state)
end
