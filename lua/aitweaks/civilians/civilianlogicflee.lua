local mvec3_cpy = mvector3.copy

function CivilianLogicFlee.register_rescue_SO(ignore_this, data)
	local my_data = data.internal_data

	CopLogicBase.on_delayed_clbk(my_data, my_data.delayed_rescue_SO_id)

	my_data.delayed_rescue_SO_id = nil

	if data.unit:anim_data().dont_flee then
		return
	end

	local my_tracker = data.unit:movement():nav_tracker()
	local objective_pos = my_tracker:field_position()
	local side = data.unit:movement():m_rot():x()

	mvector3.multiply(side, 65)

	local test_pos = mvector3.copy(objective_pos)

	mvector3.add(test_pos, side)

	local so_pos, so_rot = nil
	local ray_params = {
		allow_entry = false,
		trace = true,
		tracker_from = data.unit:movement():nav_tracker(),
		pos_to = test_pos
	}

	if not managers.navigation:raycast(ray_params) then
		so_pos = test_pos
		so_rot = Rotation(-side, math.UP)
	else
		test_pos = mvector3.copy(objective_pos)

		mvector3.subtract(test_pos, side)

		ray_params.pos_to = test_pos

		if not managers.navigation:raycast(ray_params) then
			so_pos = test_pos
			so_rot = Rotation(side, math.UP)
		else
			so_pos = mvector3.copy(objective_pos)
			so_rot = nil
		end
	end
	
	local diff_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)	
	
	local interrupt_health = nil
	local interrupt_dis = nil
	
	local objective = {
		type = "act",
		interrupt_health = interrupt_health,
		destroy_clbk_key = false,
		stance = "hos",
		scan = true,
		interrupt_dis = interrupt_dis,
		follow_unit = data.unit,
		pos = so_pos,
		rot = so_rot,
		nav_seg = data.unit:movement():nav_tracker():nav_segment(),
		fail_clbk = callback(CivilianLogicFlee, CivilianLogicFlee, "on_rescue_SO_failed", data),
		complete_clbk = callback(CivilianLogicFlee, CivilianLogicFlee, "on_rescue_SO_completed", data),
		action = {
			variant = "untie",
			body_part = 1,
			type = "act",
			blocks = {
				action = -1,
				walk = -1
			}
		},
		action_duration = tweak_data.interaction.free.timer
	}
	local receiver_areas = managers.groupai:state():get_areas_from_nav_seg_id(objective.nav_seg)
	
	local so_descriptor = {
		interval = 10,
		search_dis_sq = 25000000,
		AI_group = "enemies",
		base_chance = 1,
		chance_inc = 0,
		usage_amount = 1,
		objective = objective,
		search_pos = mvector3.copy(data.m_pos),
		admin_clbk = callback(CivilianLogicFlee, CivilianLogicFlee, "on_rescue_SO_administered", data),
		verification_clbk = callback(CivilianLogicFlee, CivilianLogicFlee, "rescue_SO_verification", {
			logic_data = data,
			areas = receiver_areas
		})
	}
	local so_id = "rescue" .. tostring(data.key)
	my_data.rescue_SO_id = so_id

	managers.groupai:state():add_special_objective(so_id, so_descriptor)
	managers.groupai:state():register_rescueable_hostage(data.unit, nil)
end

function CivilianLogicFlee.on_intimidated(data, amount, aggressor_unit)
	if not data.char_tweak.intimidateable or data.unit:base().unintimidateable or data.unit:anim_data().unintimidateable then
		return
	end

	CivilianLogicFlee._delayed_intimidate_clbk(nil, {data, amount, aggressor_unit})
end

function CivilianLogicFlee.action_complete_clbk(data, action)
	local my_data = data.internal_data

	if action:type() == "walk" then
		my_data.next_action_t = -1

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

function CivilianLogicFlee.on_rescue_SO_administered(ignore_this, data, receiver_unit)
	managers.groupai:state():on_civilian_try_freed()

	local my_data = data.internal_data
	my_data.rescuer = receiver_unit
	my_data.rescue_SO_id = nil

	receiver_unit:sound():say("cr1", true) --"We'll come to you!"

	managers.groupai:state():unregister_rescueable_hostage(data.key)
end

function CivilianLogicFlee.reset_actions(data)
	data.brain:action_request({
		variant = "cmf_so_surrender",
		body_part = 1,
		type = "act",
		clamp_to_graph = true
	})
end

function CivilianLogicFlee.update(data)
	local exit_state = nil
	local unit = data.unit
	local my_data = data.internal_data
	local objective = data.objective
	local t = data.t

	if my_data.calling_the_police then
		-- Nothing
	elseif my_data.flee_path_search_id or my_data.coarse_path_search_id then
		CivilianLogicFlee._update_pathing(data, my_data)
	elseif my_data.flee_path then
		if not unit:movement():chk_action_forbidden("walk") then
			CivilianLogicFlee._start_moving_to_cover(data, my_data)
		end
	elseif my_data.coarse_path then
		if not my_data.advancing and my_data.next_action_t < data.t then
			local coarse_path = my_data.coarse_path
			local cur_index = my_data.coarse_path_index
			local total_nav_points = #coarse_path

			if cur_index == total_nav_points then
				if data.unit:unit_data().mission_element then
					data.unit:unit_data().mission_element:event("fled", data.unit)
				end

				data.unit:base():set_slot(unit, 0)
			else
				local to_pos, to_cover = nil

				if cur_index == total_nav_points - 1 then
					to_pos = my_data.flee_target.pos
				else
					local next_area = managers.groupai:state():get_area_from_nav_seg_id(coarse_path[cur_index + 1][1])
					local cover = managers.navigation:find_cover_in_nav_seg_1(next_area.nav_segs)

					if cover then
						CopLogicAttack._set_best_cover(data, my_data, {
							cover
						})

						to_cover = my_data.best_cover
					else
						to_pos = CopLogicTravel._get_pos_on_wall(coarse_path[cur_index + 1][2], 700)
					end
				end

				my_data.flee_path_search_id = "civ_flee" .. tostring(data.key)
				
				local pos_to = to_cover and to_cover[1][1] or to_pos
				local unobstructed_line = CopLogicTravel._check_path_is_straight_line(data.m_pos, pos_to, data)
				
				if unobstructed_line then
					my_data.flee_path = {
						mvec3_cpy(data.m_pos),
						pos_to
					}
					
					if not unit:movement():chk_action_forbidden("walk") then
						CivilianLogicFlee._start_moving_to_cover(data, my_data)
					end	
				elseif to_cover then
					my_data.pathing_to_cover = to_cover

					unit:brain():search_for_path_to_cover(my_data.flee_path_search_id, to_cover[1], nil, nil)
				else
					data.brain:add_pos_rsrv("path", {
						radius = 30,
						position = to_pos
					})
					unit:brain():search_for_path(my_data.flee_path_search_id, to_pos)
				end
			end
		end
	elseif my_data.best_cover then
		local best_cover = my_data.best_cover

		if not my_data.moving_to_cover or my_data.moving_to_cover ~= best_cover then
			if not my_data.in_cover or my_data.in_cover ~= best_cover then
				if not unit:anim_data().panic then
					local action_data = {
						clamp_to_graph = true,
						variant = "panic",
						body_part = 1,
						type = "act"
					}

					data.unit:brain():action_request(action_data)
					data.unit:brain():set_update_enabled_state(true)
					CopLogicBase._reset_attention(data)
				end
				
				local pos_to = my_data.best_cover[1][1]
				local unobstructed_line = CopLogicTravel._check_path_is_straight_line(data.m_pos, pos_to, data)
				
				if unobstructed_line then
					my_data.flee_path = {
						mvec3_cpy(data.m_pos),
						pos_to
					}
					
					if not unit:movement():chk_action_forbidden("walk") then
						CivilianLogicFlee._start_moving_to_cover(data, my_data)
					end	
				else
					my_data.pathing_to_cover = my_data.best_cover
					local search_id = "civ_cover" .. tostring(data.key)
					my_data.flee_path_search_id = search_id

					data.unit:brain():search_for_path_to_cover(search_id, my_data.best_cover[1])
				end
			end
		end
	end
end