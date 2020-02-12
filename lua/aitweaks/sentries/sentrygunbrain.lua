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