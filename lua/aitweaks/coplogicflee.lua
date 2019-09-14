function CopLogicFlee._update_enemy_detection(data)
	managers.groupai:state():on_unit_detection_updated(data.unit)

	data.t = TimerManager:game():time()
	local my_data = data.internal_data
	local min_reaction = AIAttentionObject.REACT_COMBAT
	local focus_enemy = data.attention_obj
	local in_combat = focus_enemy and focus_enemy.verified and focus_enemy.dis <= 3000
	local delay = in_combat and 0.35 or 1.05
	local new_attention, new_prio_slot, new_reaction = CopLogicIdle._get_priority_attention(data, data.detected_attention_objects, CopLogicFlee._chk_reaction_to_attention_object)
	local old_att_obj = data.attention_obj

	CopLogicBase._set_attention_obj(data, new_attention, new_reaction)

	my_data.advance_blocked = nil
	my_data.path_blocked = false

	if new_attention then
		my_data.want_cover = true

		CopLogicFlee._upd_shoot(data, my_data)
	else
		if my_data.attention_unit then
			CopLogicBase._reset_attention(data)

			my_data.attention_unit = nil
		end

		if my_data.shooting then
			local new_action = {
				body_part = 3,
				type = "idle"
			}

			data.unit:brain():action_request(new_action)
			data.unit:movement():set_allow_fire(false)
		end

		my_data.want_cover = nil
	end

	CopLogicBase.queue_task(my_data, my_data.detection_task_key, CopLogicFlee._update_enemy_detection, data, data.t + delay)
	CopLogicBase._report_detections(data.detected_attention_objects)
end


function CopLogicFlee.action_complete_clbk(data, action)
	local action_type = action:type()

	if action_type == "walk" then
		local my_data = data.internal_data

		if my_data.moving_to_cover then
			if action:expired() then
				if my_data.best_cover then
					managers.navigation:release_cover(my_data.best_cover[1])
				end

				my_data.best_cover = my_data.moving_to_cover

				managers.navigation:reserve_cover(my_data.best_cover[1], data.pos_rsrv_id)

				my_data.in_cover = my_data.best_cover

				if my_data.advancing then
					my_data.cover_leave_t = data.t
				end
			end

			my_data.moving_to_cover = nil
		elseif my_data.best_cover then
			local dis = mvector3.distance(my_data.best_cover[1][1], data.unit:movement():m_pos())

			if dis > 100 then
				managers.navigation:release_cover(my_data.best_cover[1])

				my_data.best_cover = nil
			end
		end

		if my_data.advancing then
			if action:expired() then
				my_data.coarse_path_index = my_data.coarse_path_index + 1
			end

			my_data.advancing = nil
		end
	elseif action_type == "turn" then
		data.internal_data.turning = nil
	elseif action_type == "shoot" then
		data.internal_data.shooting = nil
	elseif action_type == "hurt" then
		if action:expired() then
			local action_data = CopLogicBase.chk_start_action_dodge(data, "hit")
			local my_data = data.internal_data

			if action_data then
				CopLogicFlee._cancel_cover_pathing(data, my_data)
				CopLogicFlee._cancel_flee_pathing(data, my_data)
			end
		end
	elseif action_type == "dodge" then
		local my_data = data.internal_data

		CopLogicFlee._cancel_cover_pathing(data, my_data)
		CopLogicFlee._cancel_flee_pathing(data, my_data)
	end
end
