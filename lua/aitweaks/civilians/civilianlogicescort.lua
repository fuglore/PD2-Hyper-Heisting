local mvec3_cpy = mvector3.copy

function CivilianLogicEscort._get_objective_path_data(data, my_data)
	local objective = data.objective
	local path_data = objective.path_data
	local path_style = objective.path_style

	if path_data then
		if path_style == "precise" then
			local path = {
				mvector3.copy(data.m_pos)
			}

			for _, point in ipairs(path_data.points) do
				table.insert(path, point.position)
			end

			if CopLogicTravel._path_is_straight_line(data.m_pos, #path, data) then
				path = {
					path[1],
					path[#path]
				}
			else
				path = CopLogicTravel._optimize_path(path, data)
			end

			my_data.advance_path = path
			my_data.coarse_path_index = 1
			local start_seg = data.unit:movement():nav_tracker():nav_segment()
			local end_pos = mvector3.copy(path[#path])
			local end_seg = managers.navigation:get_nav_seg_from_pos(end_pos)
			my_data.coarse_path = {
				{
					start_seg
				},
				{
					end_seg,
					end_pos
				}
			}
		elseif path_style == "coarse" then
			local t_ins = table.insert
			my_data.coarse_path_index = 1
			local m_tracker = data.unit:movement():nav_tracker()
			local start_seg = m_tracker:nav_segment()
			my_data.coarse_path = {
				{
					start_seg
				}
			}
			local points = path_data.points
			local i_point = 1
			
			local target_pos = points[#path_data.points].position
			local target_seg = managers.navigation:get_nav_seg_from_pos(target_pos)
			
			local alt_coarse_params = {
				from_tracker = m_tracker,
				to_seg = target_seg,
				to_pos = target_pos,
				access = {
					"walk"
				},
				id = "CivilianLogicEscort.alt_coarse_search" .. tostring(data.key),
				access_pos = data.char_tweak.access
			}
			
			local alt_coarse = managers.navigation:search_coarse(alt_coarse_params)

			if alt_coarse and #alt_coarse <= #points then
				my_data.coarse_path = alt_coarse
			else
				local coarse_path = my_data.coarse_path
				
				while i_point <= #path_data.points do
					local next_pos = points[i_point].position
					local next_seg = managers.navigation:get_nav_seg_from_pos(next_pos)

					t_ins(coarse_path, {
						next_seg,
						mvector3.copy(next_pos)
					})

					i_point = i_point + 1
				end
			end
			
		elseif path_style == "destination" then
			my_data.coarse_path_index = 1
			local start_seg = data.unit:movement():nav_tracker():nav_segment()
			local end_pos = mvector3.copy(path_data.points[#path_data.points].position)
			local end_seg = managers.navigation:get_nav_seg_from_pos(end_pos)
			my_data.coarse_path = {
				{
					start_seg
				},
				{
					end_seg,
					end_pos
				}
			}
		end
	end
end

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
