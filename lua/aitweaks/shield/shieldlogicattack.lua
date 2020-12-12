function ShieldLogicAttack.queue_update(data, my_data)
	CopLogicBase.queue_task(my_data, my_data.update_queue_id, ShieldLogicAttack.queued_update, data, data.t + (data.important and 0.01 or 0.01), data.important and true)
end

function ShieldLogicAttack._cancel_optimal_attempt(data, my_data)
	if my_data.optimal_path then
		my_data.optimal_path = nil
	elseif my_data.walking_to_optimal_pos then
		local new_action = {
			body_part = 2,
			type = "idle"
		}

		data.unit:brain():action_request(new_action)
	elseif my_data.pathing_to_optimal_pos then
		if data.active_searches[my_data.optimal_path_search_id] then
			data.unit:brain():abort_detailed_pathing(my_data.optimal_path_search_id)
		elseif data.pathing_results then
			data.pathing_results[my_data.optimal_path_search_id] = nil
		end

		my_data.optimal_path_search_id = nil
		my_data.pathing_to_optimal_pos = nil
	end
end

function ShieldLogicAttack._chk_request_action_walk_to_optimal_pos(data, my_data, end_rot)
	if not data.unit:movement():chk_action_forbidden("walk") then
		local new_action_data = {
			type = "walk",
			body_part = 2,
			variant = "walk",
			nav_path = my_data.optimal_path,
			end_rot = end_rot
		}
		my_data.optimal_path = nil
		my_data.walking_to_optimal_pos = data.unit:brain():action_request(new_action_data)

		if my_data.walking_to_optimal_pos then
			data.brain:rem_pos_rsrv("path")

			if data.group and data.group.leader_key == data.key and data.char_tweak.chatter.follow_me and mvector3.distance(new_action_data.nav_path[#new_action_data.nav_path], data.m_pos) > 800 and not data.unit:sound():speaking(data.t) then
				managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "follow_me")
			end
		end
	end
end