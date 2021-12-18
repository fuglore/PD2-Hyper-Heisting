local tmp_rot1 = Rotation()

function SecurityCamera:update(unit, t, dt)
	self:_update_tape_loop_restarting(unit, t, dt)
	
	if not Network:is_server() or Global.game_settings.difficulty ~= "sm_wish" and not managers.groupai:state()._stealth_has_begun then
		return
	end

	if managers.groupai:state():is_ecm_jammer_active("camera") or self._tape_loop_expired_clbk_id or self._tape_loop_restarting_t then
		self:_destroy_all_detected_attention_object_data()
		self:_stop_all_sounds()
	else
		self:_upd_detection(t)
	end

	self:_upd_sound(unit, t)
end

function SecurityCamera:_upd_sound(unit, t)
	if not self._detected_attention_objects then 
		return
	end

	if self._destroyed then
		return
	end

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

function SecurityCamera:_upd_detection(t)
	local dt = t - self._last_detect_t

	self._last_detect_t = t

	if self.update_position then
		self._yaw_obj:m_position(self._pos)

		if self._look_fwd then
			self._look_obj:m_rotation(tmp_rot1)
			mrotation.y(tmp_rot1, self._look_fwd)
		end
	end

	if managers.groupai:state()._draw_enabled then
		self._brush = self._brush or Draw:brush(Color(0.2, 1, 1, 1), self._detection_interval)

		self._look_obj:m_position(self._tmp_vec1)

		local cone_base = self._look_obj:rotation():y()

		mvector3.multiply(cone_base, self._range)
		mvector3.add(cone_base, self._tmp_vec1)

		local cone_base_rad = math.tan(self._cone_angle * 0.5) * self._range

		self._brush:cone(self._tmp_vec1, cone_base, cone_base_rad, 8)
	end

	if not self._look_fwd then
		self._look_obj:m_rotation(tmp_rot1)

		self._look_fwd = Vector3()

		mrotation.y(tmp_rot1, self._look_fwd)
	end

	self:_upd_acquire_new_attention_objects(t)
	self:_upd_detect_attention_objects(t)
	self:_upd_suspicion(t)
end

function SecurityCamera:set_detection_enabled(state, settings, mission_element)
	if self._destroyed then
		return
	end

	self:set_update_enabled(state)

	self._mission_script_element = mission_element or self._mission_script_element

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
			
			self._newest_settings = settings
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

function SecurityCamera:_upd_detect_attention_objects(t)
	local detected_obj = self._detected_attention_objects
	local my_key = self._u_key
	local my_pos = self._pos
	local my_fwd = self._look_fwd
	local det_delay = self._detection_delay or {0, 0}

	for u_key, attention_info in pairs(detected_obj) do
		if t >= attention_info.next_verify_t then
			attention_info.next_verify_t = t + (attention_info.identified and attention_info.verified and attention_info.settings.verification_interval * 1.3 or attention_info.settings.verification_interval * 0.3)

			if not attention_info.identified then
				local noticable = nil
				local angle, dis_multiplier = self:_detection_angle_and_dis_chk(my_pos, my_fwd, attention_info.handler, attention_info.settings, attention_info.handler:get_detection_m_pos())

				if angle then
					local attention_pos = attention_info.handler:get_detection_m_pos()
					local vis_ray = self._unit:raycast("ray", my_pos, attention_pos, "slot_mask", self._visibility_slotmask, "ray_type", "ai_vision")

					if not vis_ray or vis_ray.unit:key() == u_key then
						noticable = true
					end
				end

				local delta_prog = nil
				local dt = t - attention_info.prev_notice_chk_t

				if noticable then
					if angle == -1 then
						delta_prog = 1
					else
						local min_delay = det_delay[1]
						local max_delay = det_delay[2]
						local angle_mul_mod = 0.15 * math.min(angle / self._cone_angle, 1)
						local dis_mul_mod = 0.85 * dis_multiplier
						local notice_delay_mul = attention_info.settings.notice_delay_mul or 1

						if attention_info.settings.detection and attention_info.settings.detection.delay_mul then
							notice_delay_mul = notice_delay_mul * attention_info.settings.detection.delay_mul
						end

						local notice_delay_modified = math.lerp(min_delay * notice_delay_mul, max_delay, dis_mul_mod + angle_mul_mod)
						delta_prog = notice_delay_modified > 0 and dt / notice_delay_modified or 1
					end
				else
					delta_prog = det_delay[2] > 0 and -dt / det_delay[2] or -1
				end

				attention_info.notice_progress = attention_info.notice_progress + delta_prog

				if attention_info.notice_progress > 1 then
					attention_info.notice_progress = nil
					attention_info.prev_notice_chk_t = nil
					attention_info.identified = true
					attention_info.release_t = t + attention_info.settings.release_delay
					attention_info.identified_t = t
					noticable = true

					if AIAttentionObject.REACT_SCARED <= attention_info.settings.reaction then
						managers.groupai:state():on_criminal_suspicion_progress(attention_info.unit, self._unit, true)
					end
				elseif attention_info.notice_progress < 0 then
					self:_destroy_detected_attention_object_data(attention_info)

					noticable = false
				else
					noticable = attention_info.notice_progress
					attention_info.prev_notice_chk_t = t

					if AIAttentionObject.REACT_SCARED <= attention_info.settings.reaction then
						managers.groupai:state():on_criminal_suspicion_progress(attention_info.unit, self._unit, noticable)
					end
				end

				if noticable ~= false and attention_info.settings.notice_clbk then
					attention_info.settings.notice_clbk(self._unit, noticable)
				end
			end

			if attention_info.identified then
				attention_info.nearly_visible = nil
				local verified, vis_ray = nil
				local attention_pos = attention_info.handler:get_detection_m_pos()
				local dis = mvector3.distance(my_pos, attention_info.m_pos)

				if dis < self._range * 1.2 then
					local detect_pos = nil

					if attention_info.is_husk_player and attention_info.unit:anim_data().crouch then
						detect_pos = self._tmp_vec1

						mvector3.set(detect_pos, attention_info.m_pos)
						mvector3.add(detect_pos, tweak_data.player.stances.default.crouched.head.translation)
					else
						detect_pos = attention_pos
					end

					local in_FOV = self:_detection_angle_chk(my_pos, my_fwd, detect_pos, 0.8)

					if in_FOV then
						vis_ray = self._unit:raycast("ray", my_pos, detect_pos, "slot_mask", self._visibility_slotmask, "ray_type", "ai_vision")

						if not vis_ray or vis_ray.unit:key() == u_key then
							verified = true
						end
					end

					attention_info.verified = verified
				end

				attention_info.dis = dis

				if verified then
					attention_info.release_t = nil
					attention_info.verified_t = t

					mvector3.set(attention_info.verified_pos, attention_pos)

					attention_info.last_verified_pos = mvector3.copy(attention_pos)
					attention_info.verified_dis = dis
				elseif attention_info.release_t and attention_info.release_t < t then
					self:_destroy_detected_attention_object_data(attention_info)
				else
					attention_info.release_t = attention_info.release_t or t + attention_info.settings.release_delay
				end
			end
		end
	end
end

function SecurityCamera:sync_alarm_to_host(unit)
	managers.network:session():send_to_host("sync_alarm_to_host", self._unit, unit)
end

function SecurityCamera:_sound_the_alarm(detected_unit)
	if self._alarm_sound then
		return
	end

	if Network:is_server() then
		self:_send_net_event(self._NET_EVENTS.alarm_start)
		
		if Global.game_settings.difficulty ~= "sm_wish" then
			managers.groupai:state():_send_next_call_immediately(5)
			managers.hud:present_mid_text({
				title = "!!! A CAMERA HAS DETECTED SUSPICIOUS ACTIVITY !!! ",
				text = "NEXT PAGER CALL INCOMING IN 5 SECONDS",
				time = 4
			})
			
			self._reenable_id = "cam_renable" .. tostring(self._unit:key())
			managers.enemy:add_delayed_clbk(self._reenable_id, callback(self, self, "_clear_camera_detection"), Application:time() + 4)	
		elseif managers.groupai:state()._stealth_strikes >= 3 then
			if self._mission_script_element then
				self._mission_script_element:on_alarm(self._unit)
			end
		
			self._call_police_clbk_id = "cam_call_cops" .. tostring(self._unit:key())

			managers.enemy:add_delayed_clbk(self._call_police_clbk_id, callback(self, self, "clbk_call_the_police"), Application:time() + 4)
			
			local reason_called = managers.groupai:state().analyse_giveaway("security_camera", detected_unit, {})
			self._reason_called = managers.groupai:state():fetch_highest_giveaway(self._reason_called, reason_called)
		else
			managers.groupai:state():register_strike("camera", true)
			
			if managers.groupai:state()._stealth_has_begun then
				managers.groupai:state():_send_next_call_immediately(10)
				managers.hud:present_mid_text({
					title = "!!! A CAMERA HAS DETECTED SUSPICIOUS ACTIVITY !!!",
					text = "NEXT PAGER CALL INCOMING IN 10 SECONDS",
					time = 4
				})
			end
			
			self._reenable_id = "cam_renable" .. tostring(self._unit:key())
			managers.enemy:add_delayed_clbk(self._reenable_id, callback(self, self, "_clear_camera_detection"), Application:time() + 4)	
		end

		self:_destroy_all_detected_attention_object_data()
		self:set_detection_enabled(false, nil, nil)
	end

	if self._suspicion_sound then
		self._suspicion_sound = nil

		self._unit:sound_source():post_event("camera_suspicious_signal_stop")
	end
	
	self._alarm_sound = self._unit:sound_source():post_event("camera_alarm_signal")
end

function SecurityCamera:_clear_camera_detection()
	self:_stop_all_sounds()
	managers.groupai:state():on_criminal_suspicion_progress(nil, self._unit, nil)
	
	if self._reenable_id then
		managers.enemy:add_delayed_clbk(self._reenable_id, callback(self, self, "_reenable_camera_detection"), Application:time() + 15)
	end
end

function SecurityCamera:_reenable_camera_detection()
	self:_stop_all_sounds()
	managers.groupai:state():on_criminal_suspicion_progress(nil, self._unit, nil)
	self:set_detection_enabled(true, self._newest_settings)
	self._reenable_id = nil
end

function SecurityCamera:_stop_all_sounds()
	if Network:is_server() and (self._alarm_sound or self._suspicion_sound) then
		self:_send_net_event(self._NET_EVENTS.sound_off)
	end

	if self._alarm_sound or self._suspicion_sound then
		self._alarm_sound = nil
		self._suspicion_sound = nil

		self._unit:sound_source():post_event("camera_silent")
	end
	
	self._shut_up_id = nil

	self._suspicion_lvl_sync = 0
	self._suspicion_sound_lvl = 0
end

function SecurityCamera:destroy(unit)
	table.delete(SecurityCamera.cameras, self._unit)

	self._destroying = true

	self:set_detection_enabled(false)

	if self._call_police_clbk_id then
		managers.enemy:remove_delayed_clbk(self._call_police_clbk_id)

		self._call_police_clbk_id = nil
	end

	if self._tape_loop_expired_clbk_id then
		managers.enemy:remove_delayed_clbk(self._tape_loop_expired_clbk_id)

		self._tape_loop_expired_clbk_id = nil
	end
	
	if self._reenable_id then
		managers.enemy:remove_delayed_clbk(self._reenable_id)

		self._reenable_id = nil
	end
	
	if self._shut_up_id then
		managers.enemy:remove_delayed_clbk(self._shut_up_id)

		self._shut_up_id = nil
	end

	if SecurityCamera.active_tape_loop_unit and SecurityCamera.active_tape_loop_unit == self._unit then
		SecurityCamera.active_tape_loop_unit = nil
	end
end