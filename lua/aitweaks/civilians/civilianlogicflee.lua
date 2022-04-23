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