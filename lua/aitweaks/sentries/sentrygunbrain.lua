local mvec3_dir = mvector3.direction
local mvec3_dist_sq = mvector3.distance_sq
local mvec3_dot = mvector3.dot
local mvec3_cross = mvector3.cross
local mvec3_sub = mvector3.subtract
local mvec3_add = mvector3.add
local mvec3_mul = mvector3.multiply
local math_max = math.max
local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()
SentryGunBrain = SentryGunBrain or class()
SentryGunBrain._create_attention_setting_from_descriptor = PlayerMovement._create_attention_setting_from_descriptor
SentryGunBrain.attention_target_offset_hor = 75
SentryGunBrain.attention_target_offset_ver = 75

function SentryGunBrain:_upd_detection(t)
	if self._ext_movement:is_activating() or self._ext_movement:is_inactivating() then
		return
	end

	if t < self._next_detection_upd_t then
		return
	end

	--local delay = 1
	local my_SO_access_str = self._SO_access_str
	local my_SO_access = self._SO_access
	local my_tracker = self._unit:movement():nav_tracker()
	local chk_vis_func = my_tracker.check_visibility
	local detected_objects = self._detected_attention_objects
	local my_key = self._unit:key()
	local my_team = self._ext_movement:team()
	local my_pos = self._ext_movement:m_head_pos()
	local my_tracker = self._ext_movement:nav_tracker()
	local chk_vis_func = my_tracker.check_visibility
	local max_detection_range = self._tweak_data.DETECTION_RANGE
	local all_attention_objects = managers.groupai:state():get_AI_attention_objects_by_filter(my_SO_access_str, my_team)

	-- Lines 164-175
	local function _distance_chk(handler, settings, attention_pos)
		attention_pos = attention_pos or handler:get_detection_m_pos()
		local dis_sq = mvec3_dist_sq(my_pos, attention_pos)
		local max_dis = math.min(max_detection_range, settings.max_range or max_detection_range)

		if settings.detection and settings.detection.range_mul then
			max_dis = max_dis * settings.detection.range_mul
		end

		if dis_sq < max_dis * max_dis then
			return math.sqrt(dis_sq)
		end
	end

	local ignore_units = {
		self._unit
	}

	-- Lines 180-208
	local function _nearly_visible_chk(attention_info, detect_pos)
		local near_pos = tmp_vec1

		if attention_info.verified_dis < 2000 and math.abs(detect_pos.z - my_pos.z) < 300 then
			mvector3.set(near_pos, detect_pos)
			mvector3.set_z(near_pos, near_pos.z + 100)

			local near_vis_ray = World:raycast("ray", my_pos, near_pos, "ignore_unit", ignore_units, "slot_mask", self._visibility_slotmask, "ray_type", "ai_vision", "report")

			if near_vis_ray then
				local side_vec = tmp_vec1

				mvector3.set(side_vec, detect_pos)
				mvec3_sub(side_vec, my_pos)
				mvec3_cross(side_vec, side_vec, math.UP)
				mvector3.set_length(side_vec, 150)
				mvector3.set(near_pos, detect_pos)
				mvec3_add(near_pos, side_vec)

				local near_vis_ray = World:raycast("ray", my_pos, near_pos, "ignore_unit", ignore_units, "slot_mask", self._visibility_slotmask, "ray_type", "ai_vision", "report")

				if near_vis_ray then
					mvec3_mul(side_vec, -2)
					mvec3_add(near_pos, side_vec)

					near_vis_ray = World:raycast("ray", my_pos, near_pos, "ignore_unit", ignore_units, "slot_mask", self._visibility_slotmask, "ray_type", "ai_vision", "report")
				end
			end

			if not near_vis_ray then
				attention_info.nearly_visible = true
				attention_info.last_verified_pos = mvector3.copy(near_pos)
			end
		end
	end

	for u_key, attention_info in pairs(all_attention_objects) do
		if u_key ~= my_key and not detected_objects[u_key] and (not attention_info.nav_tracker or chk_vis_func(my_tracker, attention_info.nav_tracker)) then
			local settings = attention_info.handler:get_attention(my_SO_access, AIAttentionObject.REACT_SUSPICIOUS, nil, my_team)

			if settings then
				local attention_pos = attention_info.handler:get_detection_m_pos()

				if _distance_chk(attention_info.handler, settings, attention_pos) then
					ignore_units[2] = attention_info.unit or nil
					local vis_ray = World:raycast("ray", my_pos, attention_pos, "ignore_unit", ignore_units, "slot_mask", self._visibility_slotmask, "ray_type", "ai_vision")

					if not vis_ray or vis_ray.unit:key() == u_key then
						detected_objects[u_key] = CopLogicBase._create_detected_attention_object_data(t, self._unit, u_key, attention_info, settings)
					end
				end
			end
		end
	end

	local update_delay = 0.35

	for u_key, attention_info in pairs(detected_objects) do
		if t < attention_info.next_verify_t then
			update_delay = math.min(attention_info.next_verify_t - t, update_delay)
		else
			ignore_units[2] = attention_info.unit or nil
			attention_info.next_verify_t = t + (attention_info.identified and attention_info.verified and attention_info.settings.verification_interval or attention_info.settings.notice_interval or attention_info.settings.verification_interval)
			update_delay = math.min(update_delay, attention_info.settings.verification_interval)

			if not attention_info.identified then
				local health_ratio = self:_attention_health_ratio(attention_info)
				local objective = self:_attention_objective(attention_info)
				local noticable = nil
				local distance = _distance_chk(attention_info.handler, attention_info.settings, nil)
				local skip = objective == "surrender" or health_ratio <= 0

				if distance then
					local attention_pos = attention_info.handler:get_detection_m_pos()
					local vis_ray = World:raycast("ray", my_pos, attention_pos, "ignore_unit", ignore_units, "slot_mask", self._visibility_slotmask, "ray_type", "ai_vision", "report")

					if not vis_ray then
						noticable = true
					end
				end

				local delta_prog = nil
				local dt = t - attention_info.prev_notice_chk_t

				if noticable and not skip then
					local min_delay = self._tweak_data.DETECTION_DELAY[1][2]
					local max_delay = self._tweak_data.DETECTION_DELAY[2][2]
					local dis_ratio = (distance - self._tweak_data.DETECTION_DELAY[1][1]) / (self._tweak_data.DETECTION_DELAY[2][1] - self._tweak_data.DETECTION_DELAY[1][1])
					local dis_mul_mod = math.lerp(min_delay, max_delay, dis_ratio)
					local notice_delay_mul = attention_info.settings.notice_delay_mul or 1

					if attention_info.settings.detection and attention_info.settings.detection.delay_mul then
						notice_delay_mul = notice_delay_mul * attention_info.settings.detection.delay_mul
					end

					local notice_delay_modified = math.lerp(min_delay * notice_delay_mul, max_delay, dis_mul_mod)
					delta_prog = notice_delay_modified > 0 and dt / notice_delay_modified or 1
				else
					delta_prog = dt * -0.125
				end

				attention_info.notice_progress = attention_info.notice_progress + delta_prog

				if attention_info.notice_progress > 1 and not skip then
					attention_info.notice_progress = nil
					attention_info.prev_notice_chk_t = nil
					attention_info.identified = true
					attention_info.release_t = t + attention_info.settings.release_delay
					attention_info.identified_t = t
					noticable = true
				elseif attention_info.notice_progress < 0 or skip then
					self:_destroy_detected_attention_object_data(attention_info)

					noticable = false
				else
					noticable = attention_info.notice_progress
					attention_info.prev_notice_chk_t = t
				end

				if noticable ~= false and attention_info.settings.notice_clbk then
					attention_info.settings.notice_clbk(self._unit, noticable)
				end
			end

			if attention_info.identified then
				update_delay = math.min(update_delay, attention_info.settings.verification_interval)
				attention_info.nearly_visible = nil
				local verified, vis_ray = nil
				local attention_pos = attention_info.handler:get_detection_m_pos()
				local dis = mvector3.distance(my_pos, attention_info.m_head_pos)
				local thingy_chk1 = attention_info.settings.detection and attention_info.settings.detection.range_mul or 1
				local thingy_chk2 = not attention_info.settings.max_range or dis < attention_info.settings.max_range * thingy_chk1 * 1.2

				if dis < max_detection_range * 1.2 and thingy_chk2 then
					local detect_pos = nil

					if attention_info.is_husk_player and attention_info.unit:anim_data().crouch then
						detect_pos = tmp_vec1

						mvector3.set(detect_pos, attention_info.m_pos)
						mvec3_add(detect_pos, tweak_data.player.stances.default.crouched.head.translation)
					else
						detect_pos = attention_pos
					end

					vis_ray = World:raycast("ray", my_pos, detect_pos, "ignore_unit", ignore_units, "slot_mask", self._visibility_slotmask, "ray_type", "ai_vision")

					if not vis_ray then
						verified = true
					end

					attention_info.verified = verified
				end

				attention_info.dis = dis
				attention_info.vis_ray = vis_ray and vis_ray.dis or nil
				local is_downed = false

				if attention_info.unit:movement() and attention_info.unit:movement().downed then
					is_downed = attention_info.unit:movement():downed()
				end

				local is_ignored_target = self:_attention_health_ratio(attention_info) <= 0 or self:_attention_objective(attention_info) == "surrender" or is_downed

				if is_ignored_target then
					self:_destroy_detected_attention_object_data(attention_info)
				elseif verified and dis < self._tweak_data.FIRE_RANGE then
					attention_info.release_t = nil
					attention_info.verified_t = t

					mvector3.set(attention_info.verified_pos, attention_pos)

					attention_info.last_verified_pos = mvector3.copy(attention_pos)
					attention_info.verified_dis = dis
				elseif attention_info.has_team and my_team.foes[attention_info.unit:movement():team().id] then
					if attention_info.criminal_record and AIAttentionObject.REACT_COMBAT <= attention_info.settings.reaction then
						local seeninlast5seconds = attention_info.verified_t and attention_info.verified_t - t <= 3
						if not seeninlast5seconds and mvector3.distance(attention_pos, attention_info.verified_pos) > 250 or max_detection_range < dis then
							self:_destroy_detected_attention_object_data(attention_info)
						else
							if diff_index > 6 or Global.game_settings.use_intense_AI then
								attention_info.verified_pos = mvector3.copy(attention_info.criminal_record.pos)
								attention_info.verified_dis = dis
							end

							if vis_ray then
								_nearly_visible_chk(attention_info, attention_pos)
							end
						end
					elseif attention_info.release_t and attention_info.release_t < t then
						self:_destroy_detected_attention_object_data(attention_info)
					else
						attention_info.release_t = attention_info.release_t or t + attention_info.settings.release_delay
					end
				elseif attention_info.release_t and attention_info.release_t < t then
					self:_destroy_detected_attention_object_data(attention_info)
				else
					attention_info.release_t = attention_info.release_t or t + attention_info.settings.release_delay
				end
			end
		end
	end

	self._next_detection_upd_t = t + update_delay
end

function SentryGunBrain:_select_focus_attention(t)
	local current_focus = self._attention_obj
	local current_pos = self._ext_movement:m_head_pos()
	local current_fwd = nil

	if current_focus then
		current_fwd = tmp_vec2

		mvec3_dir(current_fwd, self._ext_movement:m_head_pos(), current_focus.m_head_pos)
	else
		current_fwd = self._ext_movement:m_head_fwd()
	end

	local max_dis = self._tweak_data.DETECTION_RANGE

	local function _get_weight(attention_info)
		if not attention_info.identified then
			return
		end

		local weight_mul = attention_info.settings.weight_mul or 1
		local distance = attention_info.dis

		if attention_info.health_ratio and attention_info.unit:character_damage():health_ratio() <= 0 then
			return 0
		elseif attention_info.verified_t and t - attention_info.verified_t < 3 then
			local max_duration = 3
			local elapsed_t = t - attention_info.verified_t
			weight_mul = weight_mul * math.lerp(1, 0.6, elapsed_t / max_duration)
		else
			return 0
		end
		
		local att_unit = attention_info.unit
		
		if attention_info.is_local_player then
			if not att_unit:movement():current_state()._moving and att_unit:movement():current_state():ducking() then
				weight_mul = (weight_mul or 1) * managers.player:upgrade_value("player", "stand_still_crouch_camouflage_bonus", 1)
			end

			if managers.player:has_activate_temporary_upgrade("temporary", "chico_injector") and managers.player:upgrade_value("player", "chico_preferred_target", false) then
				weight_mul = (weight_mul or 1) * 1000
			end

			if _G.IS_VR and tweak_data.vr.long_range_damage_reduction_distance[1] < distance then
				local mul = math.clamp(distance / tweak_data.vr.long_range_damage_reduction_distance[2] / 2, 0, 1) + 1
				weight_mul = (weight_mul or 1) * mul
			end
		elseif att_unit:base() and att_unit:base().upgrade_value then
			if att_unit:movement() and not att_unit:movement()._move_data and att_unit:movement()._pose_code and att_unit:movement()._pose_code == 2 then
				weight_mul = (weight_mul or 1) * (att_unit:base():upgrade_value("player", "stand_still_crouch_camouflage_bonus") or 1)
			end

			if att_unit:base().has_activate_temporary_upgrade and att_unit:base():has_activate_temporary_upgrade("temporary", "chico_injector") and att_unit:base():upgrade_value("player", "chico_preferred_target") then
				weight_mul = (weight_mul or 1) * 1000
			end

			if att_unit:movement().is_vr and att_unit:movement():is_vr() and tweak_data.vr.long_range_damage_reduction_distance[1] < distance then
				local mul = math.clamp(distance / tweak_data.vr.long_range_damage_reduction_distance[2] / 2, 0, 1) + 1
				weight_mul = (weight_mul or 1) * mul
			end
		end
		
		local dis = mvec3_dir(tmp_vec1, current_pos, attention_info.m_head_pos)
		local dis_weight = math_max(0, (max_dis - dis) / max_dis)
		weight_mul = weight_mul * dis_weight
		local dot_weight = 1 + mvec3_dot(tmp_vec1, current_fwd)
		dot_weight = dot_weight * dot_weight * dot_weight
		weight_mul = weight_mul * dot_weight

		if self:_ignore_shield({
			self._unit
		}, current_pos, attention_info) then
			weight_mul = weight_mul * 0.01
		end

		return weight_mul
	end

	local best_focus_attention, best_focus_weight = nil
	local best_focus_reaction = 6

	for u_key, attention_info in pairs(self._detected_attention_objects) do
		local weight = _get_weight(attention_info)

		if weight and (best_focus_reaction < attention_info.reaction or best_focus_reaction == attention_info.reaction and (not best_focus_weight or best_focus_weight < weight)) then
			best_focus_weight = weight
			best_focus_attention = attention_info
			best_focus_reaction = attention_info.reaction
		end
	end

	if current_focus ~= best_focus_attention then
		if best_focus_attention then
			local attention_data = {
				unit = best_focus_attention.unit,
				u_key = best_focus_attention.u_key,
				handler = best_focus_attention.handler,
				reaction = best_focus_attention.reaction
			}

			self._ext_movement:set_attention(attention_data)
		else
			self._ext_movement:set_attention()
		end

		self._attention_obj = best_focus_attention
	end
end