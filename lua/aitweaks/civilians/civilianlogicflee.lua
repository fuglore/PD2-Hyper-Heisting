
function CivilianLogicFlee.action_complete_clbk(data, action)
	local my_data = data.internal_data

	if action:type() == "walk" then
		if Global.game_settings.one_down then
			my_data.next_action_t = TimerManager:game():time() - 1
		else
			my_data.next_action_t = TimerManager:game():time() + math.random(0.25, 1)
		end

		if action:expired() then
			if my_data.moving_to_cover then
				data.unit:sound():say("a03x_any", true)

				my_data.in_cover = my_data.moving_to_cover

				CopLogicAttack._set_nearest_cover(my_data, my_data.in_cover)
				CivilianLogicFlee._chk_add_delayed_rescue_SO(data, my_data)
			end

			if my_data.coarse_path_index then
				my_data.coarse_path_index = my_data.coarse_path_index + 1
			end
		end

		my_data.moving_to_cover = nil
		my_data.advancing = nil

		if not my_data.coarse_path_index then
			data.unit:brain():set_update_enabled_state(false)
		end
	elseif action:type() == "act" and my_data.calling_the_police then
		my_data.calling_the_police = nil

		if not my_data.called_the_police then
			managers.groupai:state():on_criminal_suspicion_progress(nil, data.unit, "call_interrupted")
		end
	end
end
