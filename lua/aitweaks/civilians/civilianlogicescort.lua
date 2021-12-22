local mvec3_cpy = mvector3.copy

function CivilianLogicEscort.update(data)
	local my_data = data.internal_data
	local unit = data.unit
	local objective = data.objective
	local t = data.t

	if my_data._say_random_t and my_data._say_random_t < t then
		data.unit:sound():say("a02x_any", true)

		my_data._say_random_t = t + math.random(30, 60)
	end

	if my_data.has_old_action then
		CivilianLogicTravel._upd_stop_old_action(data, my_data)
		
		if my_data.has_old_action then
			return
		end
	end

	local scared_reason = CivilianLogicEscort.too_scared_to_move(data)

	if scared_reason and not data.unit:anim_data().panic then
		my_data.commanded_to_move = nil

		data.unit:movement():action_request({
			clamp_to_graph = true,
			variant = "panic",
			body_part = 1,
			type = "act"
		})
	end

	if my_data.processing_advance_path or my_data.processing_coarse_path then
		CivilianLogicEscort._upd_pathing(data, my_data)
	elseif not my_data.advancing then
		if my_data.getting_up then
			-- Nothing
		elseif my_data.advance_path then
			if my_data.commanded_to_move then
				if data.unit:anim_data().standing_hesitant then
					CivilianLogicEscort._begin_advance_action(data, my_data)
				else
					CivilianLogicEscort._begin_stand_hesitant_action(data, my_data)
				end
			end
		elseif objective then
			if my_data.coarse_path then
				local coarse_path = my_data.coarse_path
				local cur_index = my_data.coarse_path_index
				local total_nav_points = #coarse_path

				if cur_index == total_nav_points then
					objective.in_place = true

					data.objective_complete_clbk(unit, objective)

					return
				else
					local to_pos = coarse_path[cur_index + 1][2]
					local unobstructed_line = CopLogicTravel._check_path_is_straight_line(data.m_pos, to_pos, data)
					
					if unobstructed_line then
						my_data.advance_path = {
							mvec3_cpy(data.m_pos),
							to_pos
						}
						
						if my_data.commanded_to_move then
							if data.unit:anim_data().standing_hesitant then
								CivilianLogicEscort._begin_advance_action(data, my_data)
							else
								CivilianLogicEscort._begin_stand_hesitant_action(data, my_data)
							end
						end
					else
						my_data.processing_advance_path = true

						unit:brain():search_for_path(my_data.advance_path_search_id, to_pos)
					end
				end
			elseif unit:brain():search_for_coarse_path(my_data.coarse_path_search_id, objective.nav_seg) then
				my_data.processing_coarse_path = true
			end
		else
			CopLogicBase._exit(data.unit, "idle")
		end
	end
end
