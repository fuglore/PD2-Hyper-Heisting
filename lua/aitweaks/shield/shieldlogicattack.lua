function ShieldLogicAttack.queue_update(data, my_data)
	CopLogicBase.queue_task(my_data, my_data.update_queue_id, ShieldLogicAttack.queued_update, data, data.t + (data.important and 0.01 or 0.01), data.important and true)
end

function ShieldLogicAttack._chk_request_action_walk_to_optimal_pos(data, my_data, end_rot)
	local diff_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)
	local shield_sound = diff_index == 8 and "hos_shield_identification" or "shield_identification"
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
			local shield_knock_cooldown = math.random(5, 8)

			if data.group and data.group.leader_key == data.key and data.char_tweak.chatter.follow_me and mvector3.distance(new_action_data.nav_path[#new_action_data.nav_path], data.m_pos) > 800 and not data.unit:sound():speaking(data.t) and not data.attack_sound_t or data.t - data.attack_sound_t > shield_knock_cooldown then
				data.unit:sound():play(shield_sound, nil, true)
			end
		end
	end
end