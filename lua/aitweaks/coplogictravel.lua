local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()
local tmp_vec3 = Vector3()
local cone_top = Vector3()
local tmp_vec_cone_dir = Vector3()
local mvec3_not_eq = mvector3.not_equal
local mvec3_neg = mvector3.negate
local mvec3_set = mvector3.set
local mvec3_sub = mvector3.subtract
local mvec3_add = mvector3.add
local mvec3_div = mvector3.divide
local mvec3_mul = mvector3.multiply
local mvec3_cross = mvector3.cross
local mvec3_set_z = mvector3.set_z
local mvec3_set_static = mvector3.set_static
local mvec3_set_length = mvector3.set_length
local mvec3_dir = mvector3.direction
local mvec3_dot = mvector3.dot
local mvec3_copy = mvector3.copy
local mvec3_norm = mvector3.normalize
local mvec3_len = mvector3.length
local mvec3_dis = mvector3.distance
local mvec3_dis_sq = mvector3.distance_sq
local mvec3_step = mvector3.step
local mvec3_rotate_with = mvector3.rotate_with
local math_lerp = math.lerp
local math_random = math.random
local math_up = math.UP
local math_abs = math.abs
local math_clamp = math.clamp
local math_min = math.min
local math_max = math.max
local math_sign = math.sign
local mrot_y = mrotation.y
local mrot_z = mrotation.z
local table_insert = table.insert



function CopLogicTravel.enter(data, new_logic_name, enter_params)
	CopLogicBase.enter(data, new_logic_name, enter_params)
	data.unit:brain():cancel_all_pathing_searches()

	local old_internal_data = data.internal_data
	local my_data = {
		unit = data.unit
	}
	local is_cool = data.unit:movement():cool()

	if is_cool then
		my_data.detection = data.char_tweak.detection.ntl
	else
		my_data.detection = data.char_tweak.detection.combat
	end
	
	if data.unit:base():has_tag("backliner") then
		my_data.cowardly = true
	end
	
	if data.unit:base():has_tag("frontliner") then
		my_data.frontliner = true
	end

	if old_internal_data then
		my_data.turning = old_internal_data.turning
		my_data.firing = old_internal_data.firing
		my_data.shooting = old_internal_data.shooting
		my_data.attention_unit = old_internal_data.attention_unit

		if old_internal_data.nearest_cover then
			my_data.nearest_cover = old_internal_data.nearest_cover

			managers.navigation:reserve_cover(my_data.nearest_cover[1], data.pos_rsrv_id)
		end

		if old_internal_data.best_cover then
			my_data.best_cover = old_internal_data.best_cover

			managers.navigation:reserve_cover(my_data.best_cover[1], data.pos_rsrv_id)
		end
	end

	if data.char_tweak.announce_incomming then
		my_data.announce_t = data.t + 2
	end

	data.internal_data = my_data
	local key_str = tostring(data.key)
	my_data.upd_task_key = "CopLogicTravel.queued_update" .. key_str

	CopLogicTravel.queue_update(data, my_data)

	my_data.cover_update_task_key = "CopLogicTravel._update_cover" .. key_str

	if my_data.nearest_cover or my_data.best_cover then
		CopLogicBase.add_delayed_clbk(my_data, my_data.cover_update_task_key, callback(CopLogicTravel, CopLogicTravel, "_update_cover", data), data.t + 0.01)
	end

	my_data.advance_path_search_id = "CopLogicTravel_detailed" .. tostring(data.key)
	my_data.coarse_path_search_id = "CopLogicTravel_coarse" .. tostring(data.key)

	CopLogicIdle._chk_has_old_action(data, my_data)

	if my_data.advancing then
		my_data.old_action_advancing = true
	end

	local objective = data.objective
	local path_data = objective.path_data

	if objective.path_style == "warp" then
		my_data.warp_pos = objective.pos
	elseif path_data then	
		local path_style = objective.path_style

		if path_style == "precise" then
			local path = {
				mvec3_copy(data.m_pos)
			}

			for _, point in ipairs(path_data.points) do
				table.insert(path, mvec3_copy(point.position))
			end

			my_data.advance_path = path
			my_data.coarse_path_index = 1
			local start_seg = data.unit:movement():nav_tracker():nav_segment()
			local end_pos = mvec3_copy(path[#path])
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
			my_data.path_is_precise = true
		elseif path_style == "coarse" then
			local nav_manager = managers.navigation
			local f_get_nav_seg = nav_manager.get_nav_seg_from_pos
			local start_seg = data.unit:movement():nav_tracker():nav_segment()
			local path = {
				{
					start_seg
				}
			}

			for _, point in ipairs(path_data.points) do
				local pos = mvec3_copy(point.position)
				local nav_seg = f_get_nav_seg(nav_manager, pos)

				table.insert(path, {
					nav_seg,
					pos
				})
			end

			my_data.coarse_path = path
			my_data.coarse_path_index = CopLogicTravel.complete_coarse_path(data, my_data, path)
		elseif path_style == "coarse_complete" then
			my_data.coarse_path_index = 1
			my_data.coarse_path = deep_clone(objective.path_data)
			my_data.coarse_path_index = CopLogicTravel.complete_coarse_path(data, my_data, my_data.coarse_path)		
		end
	end

	if objective.stance then
		local upper_body_action = data.unit:movement()._active_actions[3]

		if not upper_body_action or upper_body_action:type() ~= "shoot" then
			data.unit:movement():set_stance(objective.stance)
		end
	end

	if data.attention_obj and AIAttentionObject.REACT_AIM < data.attention_obj.reaction then
		data.unit:movement():set_cool(false, managers.groupai:state().analyse_giveaway(data.unit:base()._tweak_table, data.attention_obj.unit))
	end

	if is_cool then
		data.unit:brain():set_attention_settings({
			peaceful = true
		})
	else
		data.unit:brain():set_attention_settings({
			cbt = true
		})
	end

	my_data.attitude = data.objective.attitude or "avoid"
	local range = {
		optimal = 3000,
		far = 4000, 
		close = 2000
	}
	
	my_data.weapon_range = data.char_tweak.weapon[data.unit:inventory():equipped_unit():base():weapon_tweak_data().usage].range or range
	if not data.team then
		data.unit:movement():set_team(managers.groupai:state()._teams["law1"])
	end
	my_data.path_safely = data.objective and data.objective.grp_objective and data.objective.grp_objective.type == "recon_area" or data.objective and data.objective.running or nil
	my_data.path_ahead = data.cool or objective.path_ahead or data.is_converted or data.unit:in_slot(16) or data.team.id == tweak_data.levels:get_default_team_ID("player")

	data.unit:brain():set_update_enabled_state(false)
end

function CopLogicTravel.exit(data, new_logic_name, enter_params)
	CopLogicBase.exit(data, new_logic_name, enter_params)

	local my_data = data.internal_data

	data.unit:brain():cancel_all_pathing_searches()
	TaserLogicAttack._cancel_tase_attempt(data, my_data)
	SpoocLogicAttack._cancel_spooc_attempt(data, my_data)
	CopLogicBase.cancel_queued_tasks(my_data)
	CopLogicBase.cancel_delayed_clbks(my_data)

	if my_data.moving_to_cover then
		managers.navigation:release_cover(my_data.moving_to_cover[1])
	end

	if my_data.nearest_cover then
		managers.navigation:release_cover(my_data.nearest_cover[1])
	end

	if my_data.best_cover then
		managers.navigation:release_cover(my_data.best_cover[1])
	end

	data.brain:rem_pos_rsrv("path")
	data.unit:brain():set_update_enabled_state(true)
end

function CopLogicTravel._upd_enemy_detection(data)
	managers.groupai:state():on_unit_detection_updated(data.unit)

	local my_data = data.internal_data
	local min_reaction = nil
	if data.unit:base():has_tag("special") then
		min_reaction = AIAttentionObject.REACT_AIM
	end
	local delay = CopLogicBase._upd_attention_obj_detection(data, min_reaction, nil)
	local detected_enemies = data.detected_attention_objects
	local tasing = my_data.tasing
	local tased_u_key = tasing and tasing.target_u_key
	local tase_in_effect = nil
	local get_new_target = true

	if tasing then
		if data.unit:movement()._active_actions[3] and data.unit:movement()._active_actions[3]:type() == "tase" then
			local tase_action = data.unit:movement()._active_actions[3]

			if tase_action._discharging or tase_action._firing_at_husk or tase_action._discharging_on_husk then
				tase_in_effect = true
			end
		end
	end

	if tase_in_effect then
		return
	end
	
	local reaction_func = nil
	
	if data.unit:base():has_tag("taser") then
		reaction_func = TaserLogicAttack._chk_reaction_to_attention_object
	elseif data.unit:base():has_tag("spooc") then
		reaction_func = SpoocLogicAttack.chk_reaction_to_attention_object
	end
	
	local use_optimal_pos_stuff = not my_data.protector and data.important and not data.unit:base():has_tag("takedown")
	
	if get_new_target then
		local new_attention, new_prio_slot, new_reaction = CopLogicIdle._get_priority_attention(data, detected_enemies, reaction_func)
		local old_att_obj = data.attention_obj
		
		CopLogicBase._set_attention_obj(data, new_attention, new_reaction)
		
		local near_vis_or_verified = nil
		
		if new_attention then
			if new_attention.nearly_visible or new_attention.verified then
				near_vis_or_verified = true
				if old_att_obj and old_att_obj.u_key ~= new_attention.u_key then
					CopLogicAttack._cancel_charge(data, my_data)
					
					if not my_data.protected then
						ShieldLogicAttack._cancel_optimal_attempt(data, my_data)
					end
				end
			end
		end
		
		if use_optimal_pos_stuff and new_attention and new_reaction then
			local path_fail_t_chk = 2
			if not my_data.optimal_path_fail_t or data.t - my_data.optimal_path_fail_t > path_fail_t_chk then
				if near_vis_or_verified and AIAttentionObject.REACT_COMBAT <= new_reaction and new_attention.dis < 2000 and new_attention.nav_tracker and not my_data.walking_to_optimal_pos and not my_data.pathing_to_optimal_pos then
					if alive(data.unit:inventory() and data.unit:inventory()._shield_unit) then
						my_data.optimal_pos = CopLogicAttack._find_flank_pos(data, my_data, new_attention.nav_tracker)
					elseif data.tactics and data.tactics.flank then
						local flank_pos = CopLogicAttack._find_flank_pos(data, my_data, new_attention.nav_tracker)
						
						if flank_pos then
							my_data.optimal_pos = flank_pos
							--if my_data.optimal_pos then
							--	local draw_duration = 2
							--	local line3 = Draw:brush(Color.blue:with_alpha(0.5), draw_duration)
							--	line3:cylinder(data.m_pos, my_data.optimal_pos, 2)
							--end
						else
							my_data.optimal_path_fail_t = data.t
						end
					elseif data.tactics and data.tactics.charge then
						local charge_pos = CopLogicTravel._get_pos_on_wall(new_attention.nav_tracker:field_position(), 400, 45, nil)
						
						if charge_pos then
							my_data.optimal_pos = charge_pos
							--if my_data.optimal_pos then
							--	local draw_duration = 2
							--	local line4 = Draw:brush(Color.red:with_alpha(0.5), draw_duration)
							--	line4:cylinder(data.m_pos, my_data.optimal_pos, 2)
							--end
						else
							my_data.optimal_path_fail_t = data.t
						end
					end
				end
			end
		end
	
	end
	
	local chosen_attention = focus_enemy or new_attention or nil
	
	if not my_data.optimal_pos and my_data.optimal_pos and chosen_attention then
		mvec3_set_z(my_data.optimal_pos, chosen_attention.m_pos.z)
	end
	
	local objective = data.objective
	local allow_trans, obj_failed = CopLogicBase.is_obstructed(data, objective, nil, new_attention)

	if allow_trans and (obj_failed or not objective or objective.type ~= "follow") then
		local wanted_state = CopLogicBase._get_logic_state_from_reaction(data)

		if wanted_state and wanted_state ~= data.name then
			if obj_failed then
				data.objective_failed_clbk(data.unit, data.objective)
			end

			if my_data == data.internal_data and not objective.is_default then
				debug_pause_unit(data.unit, "[CopLogicTravel._upd_enemy_detection] exiting without discarding objective", data.unit, inspect(objective))
				
				CopLogicBase._exit(data.unit, wanted_state)
			end

			CopLogicBase._report_detections(detected_enemies)

			return delay
		end
	end

	if my_data == data.internal_data then
		if data.cool and new_reaction == AIAttentionObject.REACT_SUSPICIOUS and CopLogicBase._upd_suspicion(data, my_data, new_attention) then
			CopLogicBase._report_detections(detected_enemies)

			return delay
		elseif new_reaction and new_reaction <= AIAttentionObject.REACT_SCARED then
			local set_attention = data.unit:movement():attention()

			if not set_attention or set_attention.u_key ~= new_attention.u_key then
				CopLogicBase._set_attention(data, new_attention, nil)
			end
		end

		CopLogicAttack._upd_aim(data, my_data)
	end

	CopLogicBase._report_detections(detected_enemies)

	if new_attention and data.char_tweak.chatter.entrance and not data.entrance and new_attention.criminal_record and AIAttentionObject.REACT_COMBAT <= new_reaction and new_attention.dis < 1200 then
		data.unit:sound():say(data.brain.entrance_chatter_cue or "entrance", true, nil)

		data.entrance = true
	end

	if data.cool then
		CopLogicTravel.upd_suspicion_decay(data)
	end

	return delay
end

function CopLogicTravel._get_pos_on_wall(from_pos, max_dist, step_offset, is_recurse)
	local nav_manager = managers.navigation
	local nr_rays = 8
	local ray_dis = max_dist or 1000
	local step = 360 / nr_rays
	local offset = step_offset or math.random(360)
	local step_rot = Rotation(step)
	local offset_rot = Rotation(offset)
	local offset_vec = Vector3(ray_dis, 0, 0)

	mvec3_rotate_with(offset_vec, offset_rot)

	local to_pos = mvec3_copy(from_pos)

	mvec3_add(to_pos, offset_vec)

	local from_tracker = nav_manager:create_nav_tracker(from_pos)
	local ray_params = {
		allow_entry = false,
		trace = true,
		tracker_from = from_tracker,
		pos_to = to_pos
	}
	local rsrv_desc = {
		false,
		60
	}
	local fail_position = nil

	repeat
		to_pos = mvec3_copy(from_pos)

		mvec3_add(to_pos, offset_vec)

		ray_params.pos_to = to_pos
		local ray_res = nav_manager:raycast(ray_params)

		if ray_res then
			rsrv_desc.position = ray_params.trace[1]
			local is_free = nav_manager:is_pos_free(rsrv_desc)

			if is_free then
				managers.navigation:destroy_nav_tracker(from_tracker)

				return ray_params.trace[1]
			end
		elseif not fail_position then
			rsrv_desc.position = ray_params.trace[1]
			local is_free = nav_manager:is_pos_free(rsrv_desc)

			if is_free then
				fail_position = ray_params.trace[1]
			end
		end

		mvec3_rotate_with(offset_vec, step_rot)

		nr_rays = nr_rays - 1
	until nr_rays == 0

	managers.navigation:destroy_nav_tracker(from_tracker)

	if fail_position then
		return fail_position
	end

	if not is_recurse then
		return CopLogicTravel._get_pos_on_wall(from_pos, ray_dis * 0.5, offset + step * 0.5, true)
	end

	return from_pos
end

function CopLogicTravel._peek_for_pos_sideways(data, my_data, from_tracker, peek_to_pos, height)
	local unit = data.unit
	local my_tracker = from_tracker
	local enemy_pos = peek_to_pos
	local my_pos = unit:movement():m_pos()
	local back_vec = my_pos - enemy_pos
	local height = nil
	
	if not height then
		local low_ray, high_ray = CopLogicAttack._chk_covered(data, data.m_pos, enemy_pos, data.visibility_slotmask)
					
		if low_ray then
			height = 80
		else
			height = 150
		end
	end

	mvec3_set_z(back_vec, 0)
	mvec3_set_length(back_vec, 75)

	local back_pos = my_pos + back_vec
	local ray_params = {
		allow_entry = true,
		trace = true,
		tracker_from = my_tracker,
		pos_to = back_pos
	}
	local ray_res = managers.navigation:raycast(ray_params)
	back_pos = ray_params.trace[1]
	local back_polar = (back_pos - my_pos):to_polar()
	local right_polar = back_polar:with_spin(back_polar.spin + 90):with_r(100 + 80 * my_data.cover_test_step)
	local right_vec = right_polar:to_vector()
	local right_pos = back_pos + right_vec
	ray_params.pos_to = right_pos
	local ray_res = managers.navigation:raycast(ray_params)
	local shoot_from_pos, found_shoot_from_pos = nil
	local ray_softness = 150
	local stand_ray = World:raycast("ray", ray_params.trace[1] + math.UP * height, enemy_pos, "slot_mask", data.visibility_slotmask, "ray_type", "ai_vision")

	if not stand_ray or mvec3_dis(stand_ray.position, enemy_pos) < ray_softness then
		shoot_from_pos = ray_params.trace[1]
		found_shoot_from_pos = true
	end

	if not found_shoot_from_pos then
		local left_pos = back_pos - right_vec
		ray_params.pos_to = left_pos
		local ray_res = managers.navigation:raycast(ray_params)
		local stand_ray = World:raycast("ray", ray_params.trace[1] + math.UP * height, enemy_pos, "slot_mask", data.visibility_slotmask, "ray_type", "ai_vision")

		if not stand_ray or mvec3_dis(stand_ray.position, enemy_pos) < ray_softness then
			shoot_from_pos = ray_params.trace[1]
			found_shoot_from_pos = true
		end
	end

	return shoot_from_pos
end

function CopLogicTravel:_reserve_pos_step_clbk(data, test_pos)
	if not data.step_vector then
		data.step_vector = mvec3_copy(data.unit_pos)

		mvec3_sub(data.step_vector, test_pos)

		data.distance = mvec3_norm(data.step_vector)

		mvec3_set_length(data.step_vector, 25)

		data.num_steps = 0
	end

	local step_length = mvec3_len(data.step_vector)

	if data.distance < step_length or data.num_steps > 4 then
		return false
	end

	mvec3_add(test_pos, data.step_vector)

	data.distance = data.distance - step_length

	mvec3_set_length(data.step_vector, step_length * 2)

	data.num_steps = data.num_steps + 1

	return true
end

function CopLogicTravel._upd_combat_movement(data, ignore_walks)
	local my_data = data.internal_data
	local t = data.t
	local unit = data.unit
	local diff_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)
	--ignore_walks = true --currently disabling optimal_pos out of interest
	
	if not data.unit:base():has_tag("law") then
		return
	end
	
	if not data.attention_obj then
		--if not data.cool and not my_data.advancing then
		--	CopLogicTravel.upd_advance(data)
		--end
		
		return
	else
		local definitely_not_reactions_chk = AIAttentionObject.REACT_COMBAT > data.attention_obj.reaction

		if definitely_not_reactions_chk then
			--if not data.cool and not my_data.advancing then
			--	CopLogicTravel.upd_advance(data)
			--end
			
			return
		end
	end
	
	local engage_range = my_data.weapon_range and my_data.weapon_range.close or 1500

	local action_taken = data.logic.action_taken(data, my_data)
	local focus_enemy = data.attention_obj
	
	if not managers.groupai:state():chk_heat_bonus_retreat() then
		my_data.assault_break_retreat_complete = nil
	end
	
	local do_something_else = true
	
	if not ignore_walks then
		if not my_data.assault_break_retreat_complete and not action_taken and managers.groupai:state():chk_heat_bonus_retreat() then
			action_taken = CopLogicTravel._chk_start_action_move_back(data, my_data, focus_enemy, nil, true)
			do_something_else = nil
			if data.char_tweak.chatter and data.char_tweak.chatter.cloakeravoidance then
				managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "cloakeravoidance")
			end
		end
	end
	
	if not do_something_else then
		return true
	end
	
	--hitnrun: approach enemies, back away once the enemy is visible, creating a variating degree of aggressiveness
	--eliterangedfire: open fire at enemies from longer distances, back away if the enemy gets too close for comfort
	--spoocavoidance: attempt to approach enemies, if aimed at/seen, retreat away into cover and disengage until ready to try again
	local hitnrunmovementqualify = data.tactics and data.tactics.hitnrun and focus_enemy and focus_enemy.verified and focus_enemy.verified_dis <= 500 and math_abs(data.m_pos.z - data.attention_obj.m_pos.z) < 200
	local spoocavoidancemovementqualify = data.tactics and data.tactics.spoocavoidance and focus_enemy and focus_enemy.verified and focus_enemy.verified_dis <= 2000 and focus_enemy.aimed_at
	local eliterangedfiremovementqualify = data.tactics and data.tactics.elite_ranged_fire and focus_enemy and focus_enemy.verified and focus_enemy.verified_dis <= 700
	local freakoutovermissingpathingqualify = my_data.just_reset_info and focus_enemy and focus_enemy.verified
	
	local ammo_max, ammo = data.unit:inventory():equipped_unit():base():ammo_info()
	local reloadingretreatmovementqualify = ammo / ammo_max < 0.2 and data.tactics and data.tactics.reloadingretreat and focus_enemy and focus_enemy.verified
	
	if not ignore_walks then
		if not action_taken and hitnrunmovementqualify and not pantsdownchk or not action_taken and eliterangedfiremovementqualify and not pantsdownchk or not action_taken and spoocavoidancemovementqualify and not pantsdownchk or not action_taken and reloadingretreatmovementqualify or not action_taken and freakoutovermissingpathingqualify then
			action_taken = CopLogicTravel._chk_start_action_move_back(data, my_data, focus_enemy, nil, nil)
			do_something_else = nil
			if data.char_tweak.chatter and data.char_tweak.chatter.cloakeravoidance then
				managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "cloakeravoidance")
			end
		end
	end
	
	if not do_something_else then
		return true
	end
	
	if not ignore_walks and not my_data.protector and data.important and data.attention_obj.dis < 1000 then
		local path_fail_t_chk = 2
		if not my_data.optimal_path_fail_t or t - my_data.optimal_path_fail_t > path_fail_t_chk then
			if alive(data.unit:inventory() and data.unit:inventory()._shield_unit) then
				if not action_taken then
					if my_data.pathing_to_optimal_pos then
						-- Nothing
					elseif my_data.walking_to_optimal_pos then
						-- nothing
					elseif my_data.optimal_path then
						action_taken = CopLogicTravel._chk_request_action_walk_to_optimal_pos(data, my_data)
						do_something_else = nil
					elseif my_data.optimal_pos and focus_enemy.nav_tracker then
						local to_pos = my_data.optimal_pos
						my_data.optimal_pos = nil
						local ray_params = {
							trace = true,
							tracker_from = unit:movement():nav_tracker(),
							pos_to = to_pos
						}
						local ray_res = managers.navigation:raycast(ray_params)
						to_pos = ray_params.trace[1]

						if ray_res then
							local vec = data.m_pos - to_pos

							mvec3_norm(vec)

							local fwd = unit:movement():m_fwd()
							local fwd_dot = fwd:dot(vec)

							if fwd_dot > 0 then
								local enemy_tracker = focus_enemy.nav_tracker

								if enemy_tracker:lost() then
									ray_params.tracker_from = nil
									ray_params.pos_from = enemy_tracker:field_position()
								else
									ray_params.tracker_from = enemy_tracker
								end

								ray_res = managers.navigation:raycast(ray_params)
								to_pos = ray_params.trace[1]
							end
						end

						local fwd_bump = nil
						to_pos, fwd_bump = ShieldLogicAttack.chk_wall_distance(data, my_data, to_pos)
						local do_move = mvec3_dis_sq(to_pos, data.m_pos) > 10000 

						if not do_move then
							local to_pos_current, fwd_bump_current = ShieldLogicAttack.chk_wall_distance(data, my_data, data.m_pos)

							if fwd_bump_current then
								do_move = true
							end
						end

						if do_move and not my_data.walking_to_optimal_pos then
							my_data.pathing_to_optimal_pos = true
							my_data.optimal_path_search_id = tostring(unit:key()) .. "optimal"
							local reservation = managers.navigation:reserve_pos(nil, nil, to_pos, callback(CopLogicTravel, CopLogicTravel, "_reserve_pos_step_clbk", {
								unit_pos = data.m_pos
							}), 70, data.pos_rsrv_id)

							if reservation then
								to_pos = reservation.position
							else
								reservation = {
									radius = 60,
									position = mvec3_copy(to_pos),
									filter = data.pos_rsrv_id
								}

								managers.navigation:add_pos_reservation(reservation)
							end

							data.brain:set_pos_rsrv("path", reservation)
							--log("shit")
							data.brain:search_for_path(my_data.optimal_path_search_id, to_pos)
						end
					end
				end
			else
				if data.unit:base():has_tag("takedown") then
					if my_data.pathing_to_optimal_pos or my_data.walking_to_optimal_pos then
						-- nothing
					elseif my_data.optimal_path then
						CopLogicTravel._chk_request_action_walk_to_optimal_pos(data, my_data)
					elseif focus_enemy.unit then
						my_data.pathing_to_optimal_pos = true
						my_data.optimal_path_search_id = tostring(data.key) .. "optimal"
										
						local focus_enemy_tracker = focus_enemy.nav_tracker		
						local pos_to = focus_enemy_tracker:field_position()
											
						pos_to = CopLogicTravel._get_pos_on_wall(pos_to, 120)
										
						data.brain:search_for_path(my_data.optimal_path_search_id, pos_to)
					end
				elseif data.tactics then
					if my_data.pathing_to_optimal_pos then
						-- Nothing
						--log("im fucking")
					elseif my_data.walking_to_optimal_pos then
						-- nothing
					elseif my_data.optimal_path then
						--my_data.aggro_move_t = t + math.random(0, 1.25)
						action_taken = CopLogicTravel._chk_request_action_walk_to_optimal_pos(data, my_data)
						do_something_else = nil
					elseif my_data.optimal_pos and focus_enemy.nav_tracker then
						local to_pos = my_data.optimal_pos
						my_data.pathing_to_optimal_pos = true
						my_data.optimal_path_search_id = tostring(data.key) .. "optimal"
						data.brain:search_for_path(my_data.optimal_path_search_id, to_pos)
					end
				end
			end
		end
	end
	
	if not do_something_else then
		return true
	end
	
	if not my_data.cover_test_step then
		my_data.cover_test_step = 1
	end
	
	if not action_taken and not my_data.turning and not data.unit:movement():chk_action_forbidden("walk") and not my_data.has_old_action and CopLogicAttack._can_move(data) and data.attention_obj.verified and not spoocavoidancemovementqualify then
		if data.is_suppressed and data.t - data.unit:character_damage():last_suppression_t() < 0.7 then
			action_taken = CopLogicBase.chk_start_action_dodge(data, "scared")
			do_something_else = nil
			if data.char_tweak.chatter and data.char_tweak.chatter.dodge then
				managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "dodge")
			end
			
			if data.char_tweak.chatter and data.char_tweak.chatter.cloakeravoidance then
				managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "cloakeravoidance")
			end
		end

		if not action_taken and focus_enemy.is_person then
			local dodge = nil

			if focus_enemy.is_local_player then
				local e_movement_state = focus_enemy.unit:movement():current_state()

				if not e_movement_state:_is_reloading() and not e_movement_state:_interacting() and not e_movement_state:is_equipping() then
					dodge = true
				end
			else
				local e_anim_data = focus_enemy.unit:anim_data()
				local movingoridle = e_anim_data.move or e_anim_data.idle

				if movingoridle and not e_anim_data.reload then
					dodge = true
				end
			end

			if dodge and focus_enemy.aimed_at then
				action_taken = CopLogicBase.chk_start_action_dodge(data, "preemptive")
				do_something_else = nil
				if data.char_tweak.chatter and data.char_tweak.chatter.dodge then
					managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "dodge")
				end
				if data.char_tweak.chatter and data.char_tweak.chatter.cloakeravoidance then
					managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "cloakeravoidance")
				end
			end
		end
	end
end

function CopLogicTravel.is_advancing(data)
	local my_data = data.internal_data

	if my_data.advancing then
		return data.pos_rsrv.move_dest and data.pos_rsrv.move_dest.position or my_data.advancing:get_walk_to_pos()
	end
end

function CopLogicTravel._upd_pathing(data, my_data)
	if data.pathing_results then
		local pathing_results = data.pathing_results
		data.pathing_results = nil
		
		local path = pathing_results[my_data.optimal_path_search_id]
		
		if path then
			--log("ghsanh")
			if path ~= "failed" then
			--log("hgh")
				my_data.optimal_path = path
			else
				my_data.optimal_path_fail_t = data.t
				--print("[ShieldLogicAttack._process_pathing_results] optimal path failed")
			end

			my_data.pathing_to_optimal_pos = nil
			my_data.optimal_path_search_id = nil
		end
		
		local path = pathing_results[my_data.advance_path_search_id]

		if path and my_data.processing_advance_path then
			my_data.processing_advance_path = nil

			if path ~= "failed" then
				my_data.advance_path = path
			else
				data.path_fail_t = data.t

				data.objective_failed_clbk(data.unit, data.objective)

				return
			end
		end

		local path = pathing_results[my_data.coarse_path_search_id]

		if path and my_data.processing_coarse_path then
			my_data.processing_coarse_path = nil

			if path ~= "failed" then
				my_data.coarse_path = path
				my_data.coarse_path_index = 1
			elseif my_data.path_safely then
				my_data.path_safely = nil
			else
				print("[CopLogicTravel:_upd_pathing] coarse_path failed unsafe", data.unit, my_data.coarse_path_index)

				data.path_fail_t = data.t

				data.objective_failed_clbk(data.unit, data.objective)

				return
			end
		end
		
		local path = pathing_results[my_data.cover_path_search_id]

		if path then
			if path ~= "failed" then
				my_data.cover_path = path
			else
				print(data.unit, "[CopLogicAttack._process_pathing_results] cover path failed", data.unit)
				--CopLogicAttack._set_engage_cover(data, my_data, nil)
				--log("hmm")

				my_data.cover_path_failed_t = TimerManager:game():time()
			end

			my_data.processing_cover_path = nil
			my_data.cover_path_search_id = nil
		end

		path = pathing_results[my_data.charge_path_search_id]

		if path then
			if path ~= "failed" then
				my_data.charge_path = path
			else
				print("[CopLogicAttack._process_pathing_results] charge path failed", data.unit)
				--log("hmm")
			end

			my_data.charge_path_search_id = nil
			my_data.charge_path_failed_t = TimerManager:game():time()
		end
		
		path = pathing_results[my_data.expected_pos_path_search_id]

		if path then
			if path ~= "failed" then
				my_data.expected_pos_path = path
			end

			my_data.expected_pos_path_search_id = nil
		end
		
	end
end

function CopLogicTravel._chk_wants_to_take_cover(data, my_data)
	if not data.attention_obj or data.attention_obj.reaction < AIAttentionObject.REACT_COMBAT then
		return
	end
	
	if my_data.moving_to_cover or data.is_suppressed or my_data.attitude ~= "engage" or data.unit:anim_data().reload then
		--log("i want cover")
		return true
	end

	local ammo_max, ammo = data.unit:inventory():equipped_unit():base():ammo_info()

	if ammo / ammo_max < 0.2 then
		return true
	end
end

function CopLogicTravel.is_available_for_assignment(data, new_objective)
	if new_objective and new_objective.forced then
		return true
	elseif data.objective and data.objective.type == "act" then
		if (not new_objective or new_objective and new_objective.type == "free") and data.objective.interrupt_dis == -1 then
			return true
		end

		return
	elseif not data.internal_data.protector then
		return CopLogicAttack.is_available_for_assignment(data, new_objective)
	end
end

local tmp_vec_tosex = Vector3()
local tmp_vec_nottosex = Vector3()

function CopLogicTravel.queued_update(data)
    local my_data = data.internal_data
	local objective = data.objective or nil
    data.t = TimerManager:game():time()
    my_data.close_to_criminal = nil
	my_data.objective_outdated = nil
    local delay = CopLogicTravel._upd_enemy_detection(data)
	
	if data.internal_data ~= my_data then
    	return
    end
	
	local focus_enemy = data.attention_obj
	
	if my_data.tasing then
		action_taken = action_taken or CopLogicAttack._chk_request_action_turn_to_enemy(data, my_data, data.m_pos, focus_enemy.m_pos)
		
		if data.internal_data == my_data then
			CopLogicBase._report_detections(data.detected_attention_objects)
			CopLogicTravel.queue_update(data, my_data)
		end

		return
	end
	
	if my_data.spooc_attack then
		if data.internal_data == my_data then
			CopLogicTravel.queue_update(data, data.internal_data, delay)
		end

		return
	end
	
	if not data.is_converted and data.unit:base():has_tag("law") then
		if objective then 
			--[[if Global.game_settings.one_down or data.tactics and data.tactics.lonewolf then --currently trying to get rawed by 9 lonewolves at the burger king drive-in in front of 81 other cops
				if objective.follow_unit then
					if objective.follow_unit:brain() and objective.follow_unit:brain().objective and objective.follow_unit:brain():objective() ~= nil then
						local new_objective = objective.follow_unit:brain():objective() --ignore following the "follow_unit", copy their objective and become standalone instead in order to execute pinches and flanking manuevers freely
						--log("ay caramba!")
						if new_objective.type == "defend_area" and new_objective.grp_objective and new_objective.grp_objective.type ~= "retire" or new_objective.type == "hunt" then
							--local old_objective = objective
							data.unit:brain():set_objective(new_objective, nil)
							CopLogicIdle.on_new_objective(data, nil)
							
							return
						end
					end
				end
			end]]
			
			if not my_data.protected then
				if objective.type == "defend_area" and objective.grp_objective and objective.grp_objective.type ~= "retire" or objective.type == "hunt" then
					if CopLogicIdle._chk_relocate(data) then
						my_data.objective_outdated = true
						--log("fuck you")
					else
						my_data.objective_outdated = nil
						--log("nani")
					end
				end
			end
		end
	end
	
	if data.internal_data ~= my_data then
    	return
    end
	
	if data.unit:base():has_tag("spooc") or data.unit:base()._tweak_table == "shadow_spooc" then
		SpoocLogicAttack._upd_spooc_attack(data, my_data)
	end

	if my_data.spooc_attack then
		if data.internal_data == my_data then
			CopLogicTravel.queue_update(data, data.internal_data, delay)
		end

		return
	end
	
	local should_update_combat_movement = my_data.just_reset_info or nil
	
	if not data.unit:base():has_tag("law") or data.team and data.team.id == tweak_data.levels:get_default_team_ID("player") or data.is_converted or data.unit:in_slot(16) or data.unit:in_slot(managers.slot:get_mask("criminals")) or data.unit:movement():cool() then
		--nothing
	elseif data.unit:base():has_tag("law") and my_data.has_advanced_once then
		if not my_data.frontliner then
			if data.group and data.group.size > 1 then
				if not my_data.protector or not alive(my_data.protector) or my_data.protector:character_damage().dead then
					my_data.protector = nil --refresh this fucker
					my_data.protected = nil
					
					
					if not my_data.protector_find_fail_t or my_data.protector_find_fail_t < data.t then
						local protector = CopLogicTravel.get_protector(data, my_data)
						
						if protector then
							my_data.protector = protector
						else
							my_data.protected = nil
							ShieldLogicAttack._cancel_optimal_attempt(data, my_data)
						end
					end
				end
			elseif my_data.protector then
				my_data.protector = nil
				my_data.protected = nil
				ShieldLogicAttack._cancel_optimal_attempt(data, my_data)
			end
		end
		
		local ignore_walks = my_data.optimal_path_fail_t and data.t - my_data.optimal_path_fail_t < 2
		if not objective or objective.type == "defend_area" and objective.grp_objective and objective.grp_objective.type ~= "retire" or objective.type == "hunt" then
			if not data.objective.pos then
				if my_data.protector and not data.unit:base():has_tag("takedown") then
					my_data.protected = true
					
					if my_data.optimal_path and not my_data.walking_to_optimal_pos then --check if there was a path previous update that didnt go through
						CopLogicTravel._chk_request_action_walk_to_optimal_pos(data, my_data)
					end
					
					if my_data.pathing_to_optimal_pos then
						CopLogicTravel._upd_pathing(data, my_data)
					elseif not my_data.optimal_pos then
						
						local follow_unit = my_data.protector
						local follow_tracker = follow_unit:movement():nav_tracker()
						local field_pos = follow_tracker:field_position()
						local advance_pos = follow_unit:brain() and follow_unit:brain():is_advancing()
						local follow_unit_pos = advance_pos or field_pos
						
						if not my_data.walking_to_optimal_pos or mvec3_dis(data.pos_rsrv.move_dest.position, follow_unit_pos) > 240 then
							my_data.optimal_pos = CopLogicTravel._get_pos_on_wall(follow_unit_pos, 180, 180, nil)
							
							local prio = data.logic.get_pathing_prio(data)
							local to_pos = my_data.optimal_pos
							my_data.pathing_to_optimal_pos = true
							my_data.optimal_path_search_id = tostring(data.key) .. "optimal"
							
							if my_data.walking_to_optimal_pos then
								from_pos = data.pos_rsrv.move_dest.position
								data.unit:brain():search_for_path_from_pos(my_data.optimal_path_search_id, from_pos, to_pos, prio)
								--local draw_duration = 1
								--local line = Draw:brush(Color.red:with_alpha(0.5), draw_duration)
								--line:cylinder(from_pos, to_pos, 4)
								--line:sphere(from_pos, 20)
								--line:sphere(to_pos, 20)
							else
								data.brain:search_for_path(my_data.optimal_path_search_id, to_pos, prio)
								--local draw_duration = 1
								--local line = Draw:brush(Color.blue:with_alpha(0.5), draw_duration)
								--line:cylinder(data.m_pos, to_pos, 4)
								--line:sphere(data.unit:movement():m_head_pos(), 20)
							end	
						end						
					end
					
					if my_data.optimal_path and not my_data.walking_to_optimal_pos then --check it twice in case theres a path now
						CopLogicTravel._chk_request_action_walk_to_optimal_pos(data, my_data)
					end
				
					if focus_enemy and AIAttentionObject.REACT_COMBAT <= focus_enemy.reaction and focus_enemy.nav_tracker then
						should_update_combat_movement = nil
						--CopLogicTravel._upd_combat_movement(data, true)
					
						if managers.groupai:state():is_smoke_grenade_active() and data.attention_obj.dis < 3000 then
							CopLogicBase.do_smart_grenade(data, my_data, data.attention_obj)
						end
					end
				end	
			elseif focus_enemy and AIAttentionObject.REACT_COMBAT <= focus_enemy.reaction and focus_enemy.nav_tracker then
				if data.unit:base():has_tag("takedown") then
					ignore_walks = true
					if focus_enemy.dis < 1000 then
						if my_data.pathing_to_optimal_pos then
							-- Nothing
						elseif my_data.walking_to_optimal_pos then
							-- nothing
						elseif my_data.optimal_path then
							CopLogicTravel._chk_request_action_walk_to_optimal_pos(data, my_data)
						elseif focus_enemy.unit then
							my_data.pathing_to_optimal_pos = true
							my_data.optimal_path_search_id = tostring(data.key) .. "optimal"
										
							local focus_enemy_tracker = focus_enemy.nav_tracker		
							local pos_to = focus_enemy_tracker:field_position()
												
							pos_to = CopLogicTravel._get_pos_on_wall(pos_to, 120)
											
							data.brain:search_for_path(my_data.optimal_path_search_id, pos_to)
						end
					end
				end
				

				should_update_combat_movement = nil
				CopLogicTravel._upd_combat_movement(data, ignore_walks)
					
				if managers.groupai:state():is_smoke_grenade_active() and data.attention_obj.dis < 3000 then
					CopLogicBase.do_smart_grenade(data, my_data, data.attention_obj)
				end
			end
		else
			if my_data.protector or my_data.protected then
				my_data.protected = nil
				my_data.protector = nil
				ShieldLogicAttack._cancel_optimal_attempt(data, my_data)
			end
		end
	end

	if should_update_combat_movement and not my_data.protected then
		CopLogicTravel._upd_combat_movement(data)
		my_data.just_reset_info = nil
	end
	
    if data.internal_data ~= my_data then
    	return
    end
	
	if not my_data.protected then
		if data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction then
			if not managers.groupai:state():chk_heat_bonus_retreat() then
				if not data.tactics or not data.tactics.sniper or data.tactics.sniper and not data.attention_obj.verified or data.tactics.sniper and data.attention_obj.dis > 4000 then
					CopLogicTravel.upd_advance(data)
				end
			end
		else
			CopLogicTravel.upd_advance(data)
		end
	end
	
	if data.internal_data ~= my_data then
		return
	end
	
	if data.important then
		data.logic._upd_stance_and_pose(data, data.internal_data, objective)
	end
	
	if data.internal_data ~= my_data then
		return
	end
	    
    if not delay then
    	debug_pause_unit(data.unit, "crap!!!", inspect(data))	
    
    	delay = 0.35
    end
	
	local hostage_count = managers.groupai:state():get_hostage_count_for_chatter() --check current hostage count
	local chosen_panic_chatter = "controlpanic" --set default generic assault break chatter
	
	if hostage_count > 0 then --make sure the hostage count is actually above zero before replacing any of the lines
		if hostage_count > 3 then  -- hostage count needs to be above 3
			if math_random() < 0.4 then --40% chance for regular panic if hostages are present
				chosen_panic_chatter = "controlpanic"
			else
				chosen_panic_chatter = "hostagepanic2" --more panicky "GET THOSE HOSTAGES OUT RIGHT NOW!!!" line for when theres too many hostages on the map
			end
		else
			if math_random() < 0.4 then
				chosen_panic_chatter = "controlpanic"
			else
				chosen_panic_chatter = "hostagepanic1" --less panicky "Delay the assault until those hostages are out." line
			end
		end
			
		if managers.groupai:state():chk_has_civilian_hostages() then
			--log("they got sausages!")
			if math_random() < 0.5 then
				chosen_panic_chatter = chosen_panic_chatter
			else
				chosen_panic_chatter = "civilianpanic"
			end
		end
			
	elseif managers.groupai:state():chk_had_hostages() then
		if math_random() < 0.4 then
			chosen_panic_chatter = "controlpanic"
		else
			chosen_panic_chatter = "hostagepanic3" -- no more hostages!!! full force!!!
		end
	end
	
	local chosen_sabotage_chatter = "sabotagegeneric" --set default sabotage chatter for variety's sake
	local skirmish_map = managers.skirmish:is_skirmish()--these shouldnt play on holdout
	local ignore_radio_rules = nil
	local ignore_skirmish_rules = nil
	--local movement_chatter = nil
	
	if objective and objective.bagjob then
		--log("oh, worm")
		chosen_sabotage_chatter = "sabotagebags"
		ignore_radio_rules = true
	elseif objective and objective.hostagejob then
		--log("sausage removal squadron")
		chosen_sabotage_chatter = "sabotagehostages"
		ignore_radio_rules = true 
	else
		chosen_sabotage_chatter = "sabotagegeneric" --if none of these levels are the current one, use a generic "Break their gear!" line
	end
	
	if objective and objective.running and objective.retiring then
		ignore_radio_rules = true
		ignore_skirmish_rules = true		
		chosen_sabotage_chatter = "retreat"
	elseif data.tactics then
		if math_random() < 0.5 then
			ignore_radio_rules = true 
			ignore_skirmish_rules = true
			if data.tactics.flank then
				chosen_sabotage_chatter = "look_for_angle"
			elseif data.tactics.charge then
				if math_random() < 0.5 then
					chosen_sabotage_chatter = "go_go"
				else
					chosen_sabotage_chatter = "push"
				end
			end
		end
	end
		
	local clear_t_chk = not data.attention_obj or not data.attention_obj.verified_t or data.t - data.attention_obj.verified_t > math_random(2.5, 5)	
		
	local cant_say_clear = data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and not clear_t_chk
		
	if not data.unit:base():has_tag("special") and not cant_say_clear and not data.is_converted then
		if data.unit:movement():cool() and data.char_tweak.chatter and data.char_tweak.chatter.clear_whisper then
			if math_random() < 0.5 then
				managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "clear_whisper" )
			else
				managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "clear_whisper_2" )
			end
		elseif not data.unit:movement():cool() then
			if not managers.groupai:state():chk_assault_active_atm() then
				if data.char_tweak.chatter and data.char_tweak.chatter.controlpanic then
					local clearchk = math_lerp(0, 90, math_random())
					local say_clear = 30
					if clearchk > 60 then
						managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "clear" )
					elseif clearchk > 30 then
						if not skirmish_map and my_data.radio_voice or not skirmish_map and ignore_radio_rules then
							managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, chosen_sabotage_chatter )
						else
							managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, chosen_panic_chatter )
						end
					else
						managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, chosen_panic_chatter )
					end
				elseif data.char_tweak.chatter and data.char_tweak.chatter.clear then
					managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "clear" )
				end
			end
		end
	end
	
	if data.unit:base():has_tag("special") and not cant_say_clear then
		if data.unit:base():has_tag("tank") or data.unit:base():has_tag("taser") or data.unit:base():has_tag("medic") then
			local say_the_other_thing = true
			
			if data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.dis <= 1000 then
				if not data.next_entry_chatter_t or data.next_entry_chatter_t < data.t then
					say_the_other_thing = nil
					data.next_entry_chatter_t = data.t + math.lerp(10, 30, math_random())
					data.unit:sound():play(data.unit:base():char_tweak().spawn_sound_event, nil, true)
				end
			end
			
			if say_the_other_thing and not data.unit:base():has_tag("medic") then
				managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "approachingspecial" )
			end
		elseif data.unit:base()._tweak_table == "shield" then
			--fuck off
		elseif data.unit:base()._tweak_table == "akuma" then
			managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "lotusapproach" )
		end
	end
		
	--mid-assault panic for cops based on alerts instead of opening fire, since its supposed to be generic action lines instead of for opening fire and such
	--I'm adding some randomness to these since the delays in groupaitweakdata went a bit overboard but also arent able to really discern things proper
				
	if data.char_tweak and data.char_tweak.chatter and data.char_tweak.chatter.enemyidlepanic and not data.is_converted then
		if not data.unit:base():has_tag("special") and data.unit:base():has_tag("law") then
			if managers.groupai:state():chk_assault_active_atm() then
				if managers.groupai:state():_check_assault_panic_chatter() then
					if math_random() < 0.25 then
						local say_the_other_thing = true
						
						if not skirmish_map or ignore_skirmish_rules then
							if my_data.radio_voice or ignore_radio_rules then
								managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, chosen_sabotage_chatter )
								say_the_other_thing = nil
							end
						end
						
						if say_the_other_thing then
							managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "assaultpanic" )
						end
					else
						managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "assaultpanic" )
					end
				else	
					if math_random() > 0.75 then
						if not skirmish_map or ignore_skirmish_rules then
							if my_data.radio_voice or ignore_radio_rules then
								managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, chosen_sabotage_chatter )
							end
						end
					end
				end
			end
		elseif not data.unit:base():has_tag("special") and data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.verified_t or not data.unit:base():has_tag("special") and data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.alert_t then
			managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "assaultpanic" )
		end	
	end
      
    CopLogicTravel.queue_update(data, data.internal_data, delay)
end

function CopLogicTravel.chk_group_ready_to_move(data, my_data)
	
	if not data.unit:base():has_tag("law") or not data.group or data.group.size <= 1 or data.team and data.team.id == tweak_data.levels:get_default_team_ID("player") or data.is_converted or data.unit:in_slot(16) or data.unit:in_slot(managers.slot:get_mask("criminals")) then
		return true
	end
	
	if my_data.protector then
		return true
	else
		for u_key, u_data in pairs(data.group.units) do
			if u_key ~= data.key then
				local his_dis = mvec3_dis_sq(data.m_pos, u_data.m_pos)

				if 800 < his_dis then
					return false
				end
			end
		end
	end

	return true
end

function CopLogicTravel.get_protector(data, my_data)
	local best_protector, best_protector_rank, rank, unit, unit_base, unit_damage = nil
			
	for u_key, u_data in pairs(data.group.units) do
		if u_key ~= data.key then
			unit = u_data.unit
			unit_base = unit:base()
			unit_damage = unit:character_damage()
			
			if not my_data.frontliner then
				if unit_base:has_tag("frontliner") then
					if unit_base:has_tag("shield") then
						rank = 1
					elseif unit_base:has_tag("tank") then
						rank = 2
					end
				elseif unit_damage._HEALTH_INIT > data.unit:character_damage()._HEALTH_INIT then
					rank = 3
				else
					if my_data.cowardly then
						rank = 4
					else
						rank = 5
					end
				end
			end
					
			if rank then
				if not best_protector_rank or best_protector_rank > rank then
					best_protector = u_data.unit
					best_protector_rank = rank
				end
			end
		end
	end
			
	if best_protector and best_protector_rank < 5 then
		return best_protector
	else
		my_data.protector_find_fail_t = data.t + 5
	end
end

function CopLogicTravel._chk_request_action_walk_to_cover(data, my_data)
	CopLogicAttack._correct_path_start_pos(data, my_data.cover_path)
	
	local haste = nil
	
	local can_perform_walking_action = not data.unit:movement():chk_action_forbidden("walk") and not my_data.turning or data.unit:anim_data().act_idle
	local pose = nil
	
	local mook_units = {
		"security",
		"security_undominatable",
		"cop",
		"cop_scared",
		"cop_female",
		"gensec",
		"fbi",
		"fbi_xc45",
		"swat",
		"heavy_swat",
		"fbi_swat",
		"fbi_heavy_swat",
		"city_swat",
		"gangster",
		"biker",
		"mobster",
		"bolivian",
		"bolivian_indoors",
		"medic",
		"taser",
		"spooc",
		"shadow_spooc",
		"spooc_heavy",
		"tank_ftsu",
		"tank_mini",
		"tank",
		"tank_medic"
	}
	local is_mook = nil
	for _, name in ipairs(mook_units) do
		if data.unit:base()._tweak_table == name then
			is_mook = true
		end
	end
	
	if can_perform_walking_action then 
		
		--enemies at long distances makes cops run, enemies at shorter distances makes cops walk, keeps pacing in small maps consistent and manageable, while making the cops seem cooler
		local pose_chk = not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.crouch
		local enemyseeninlast4secs = data.attention_obj and data.attention_obj.verified_t and data.t - data.attention_obj.verified_t < 4
		local enemy_seen_range_bonus = enemyseeninlast4secs and 500 or 0
		local enemy_has_height_difference = data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.dis >= 1200 and data.attention_obj.verified_t and data.t - data.attention_obj.verified_t < 4 and math.abs(data.m_pos.z - data.attention_obj.m_pos.z) > 250
		local height_difference_penalty = math.abs(data.m_pos.z - data.attention_obj.m_pos.z) < 250 and 400 or 0
		--local testing = true
		
		if data.unit:movement():cool() then
			haste = "walk"
		elseif Global.game_settings.one_down then
			haste = "run"
		elseif data.attention_obj and data.attention_obj.dis > 10000 or data.team and data.team.id == tweak_data.levels:get_default_team_ID("player") or data.is_converted or data.unit:in_slot(16) or data.unit:in_slot(managers.slot:get_mask("criminals")) then
			haste = "run"
		elseif data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.dis > 800 + enemy_seen_range_bonus and not data.unit:movement():cool() and not managers.groupai:state():whisper_mode() then
			haste = "run"
		elseif data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.dis <= 800 + enemy_seen_range_bonus - height_difference_penalty and is_mook and data.tactics and not data.tactics.hitnrun then
			haste = "walk"
		else
			haste = "run"
		end
		
		local crouch_roll = math_random()
		local stand_chance = nil
		local end_pose = nil
		local enemy_visible15m_or_10m_chk = data.attention_obj.verified and data.attention_obj.dis <= 1500 or data.attention_obj.dis <= 1000
	
		if data.attention_obj and data.attention_obj.dis > 10000 or data.team and data.team.id == tweak_data.levels:get_default_team_ID("player") or data.is_converted or data.unit:in_slot(16) or data.unit:in_slot(managers.slot:get_mask("criminals")) then
			stand_chance = 1
			pose = "stand"
			end_pose = "stand"
		elseif data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.dis > 2000 then
			stand_chance = 0.75
		elseif enemy_has_height_difference and pose_chk and is_mook then
			stand_chance = 0.25
		elseif data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and enemy_visible15m_or_10m_chk and CopLogicTravel._chk_close_to_criminal(data, my_data) and data.tactics and data.tactics.flank and haste == "walk" and is_mook then
			stand_chance = 0.25
		elseif my_data.moving_to_cover and pose_chk then
			stand_chance = 0.5
		else
			stand_chance = 1
			pose = "stand"
			end_pose = "stand"
		end
	
		--randomize enemy crouching to make enemies feel less easy to aim at, the fact they're always crouching all over the place always bugged me, plus, they shouldn't need to crouch so often when you're at long distances from them
		
		if not data.unit:movement():cool() and not managers.groupai:state():whisper_mode() then
			if stand_chance ~= 1 and crouch_roll > stand_chance and pose_chk or data.char_tweak.allowed_poses and data.char_tweak.allowed_poses.crouch then
				end_pose = "crouch"
				pose = "crouch"
			else
				end_pose = "stand"
				pose = "stand"
			end
		end
				
		if not pose then
			pose = not data.char_tweak.crouch_move and "stand" or data.char_tweak.allowed_poses and not data.char_tweak.allowed_poses.stand and "crouch" or "stand"
			end_pose = pose
		end
		
		if not data.unit:anim_data()[pose] then
			CopLogicAttack["_chk_request_action_" .. pose](data)
		end
		
		local new_action_data = {
			type = "walk",
			body_part = 2,
			pose = pose,
			nav_path = my_data.cover_path,
			variant = haste,
			end_pose = end_pose
		}
		my_data.cover_path = nil
		my_data.combat_cover_movement = data.unit:brain():action_request(new_action_data)

		if my_data.combat_cover_movement then
			my_data.at_cover_shoot_pos = nil
			
			if data.name == "travel" and my_data.nearest_cover and notdelayclbksornotdlclbks_chk then
				CopLogicBase.add_delayed_clbk(my_data, my_data.cover_update_task_key, callback(CopLogicTravel, CopLogicTravel, "_update_cover", data), data.t + 0.066)
			end

			data.brain:rem_pos_rsrv("path")
		end
	end
end

function CopLogicTravel.queue_update(data, my_data, delay)
	delay = data.important and 0 or delay or 0

	CopLogicBase.queue_task(my_data, my_data.upd_task_key, CopLogicTravel.queued_update, data, data.t + delay, data.important and true)
end

function CopLogicTravel._chk_request_action_walk_to_cover_shoot_pos(data, my_data, path, speed)
	local can_perform_walking_action = not data.unit:movement():chk_action_forbidden("walk") and not my_data.turning or data.unit:anim_data().act_idle
	
	local pose = nil
	
	local mook_units = {
		"security",
		"security_undominatable",
		"cop",
		"cop_scared",
		"cop_female",
		"gensec",
		"fbi",
		"fbi_xc45",
		"fbi_pager",
		"swat",
		"heavy_swat",
		"fbi_swat",
		"fbi_heavy_swat",
		"city_swat",
		"gangster",
		"biker",
		"mobster",
		"bolivian",
		"bolivian_indoors",
		"medic",
		"taser",
		"spooc",
		"trolliam_epicson",
		"gangster_ninja",						
		"shadow_spooc",
		"spooc_heavy",
		"tank_ftsu",
		"tank_mini",
		"tank",
		"tank_medic"
	}
	local is_mook = nil
	for _, name in ipairs(mook_units) do
		if data.unit:base()._tweak_table == name then
			is_mook = true
		end
	end
	
	local haste = nil
	
	if can_perform_walking_action then
		CopLogicAttack._cancel_cover_pathing(data, my_data)
		CopLogicAttack._cancel_charge(data, my_data)
		CopLogicAttack._correct_path_start_pos(data, path)
		
		--enemies at long distances makes cops run, enemies at shorter distances makes cops walk, keeps pacing in small maps consistent and manageable, while making the cops seem cooler
		local pose_chk = not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.crouch
		local enemyseeninlast4secs = data.attention_obj and data.attention_obj.verified_t and data.t - data.attention_obj.verified_t < 4
		local enemy_seen_range_bonus = enemyseeninlast4secs and 500 or 0
		local enemy_has_height_difference = data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.dis >= 1200 and data.attention_obj.verified_t and data.t - data.attention_obj.verified_t < 4 and math.abs(data.m_pos.z - data.attention_obj.m_pos.z) > 250
		local height_difference_penalty = math.abs(data.m_pos.z - data.attention_obj.m_pos.z) < 250 and 400 or 0
		--local testing = true
		
		if data.unit:movement():cool() then
			haste = "walk"
		elseif Global.game_settings.one_down then
			haste = "run"
		elseif data.team and data.team.id == tweak_data.levels:get_default_team_ID("player") or data.is_converted or data.unit:in_slot(16) or data.unit:in_slot(managers.slot:get_mask("criminals")) or data.attention_obj and data.attention_obj.dis > 10000 then 
			haste = "run"
		elseif data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.dis > 800 + enemy_seen_range_bonus and not data.unit:movement():cool() and not managers.groupai:state():whisper_mode() then
			haste = "run"
		elseif data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.dis <= 800 + enemy_seen_range_bonus - height_difference_penalty and is_mook and data.tactics and not data.tactics.hitnrun then
			haste = "walk"
		else
			haste = "run"
		end
		
		local crouch_roll = math_random()
		local stand_chance = nil
		local end_pose = nil
		
		local enemy_visible15m_or_10m_chk = data.attention_obj.verified and data.attention_obj.dis <= 1500 or data.attention_obj.dis <= 1000
		
		if data.attention_obj and data.attention_obj.dis > 10000 or data.team and data.team.id == tweak_data.levels:get_default_team_ID("player") or data.is_converted or data.unit:in_slot(16) or data.unit:in_slot(managers.slot:get_mask("criminals")) then
			stand_chance = 1
			pose = "stand"
			end_pose = "stand"
		elseif data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.dis > 2000 and is_mook then
			stand_chance = 0.75
		elseif enemy_has_height_difference and pose_chk and is_mook then
			stand_chance = 0.25
		elseif data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and enemy_visible15m_or_10m_chk and CopLogicTravel._chk_close_to_criminal(data, my_data) and data.tactics and data.tactics.flank and haste == "walk" and is_mook then
			stand_chance = 0.25
		elseif my_data.moving_to_cover and pose_chk then
			stand_chance = 0.5
		else
			stand_chance = 1
			pose = "stand"
			end_pose = "stand"
		end
	
		--randomize enemy crouching to make enemies feel less easy to aim at, the fact they're always crouching all over the place always bugged me, plus, they shouldn't need to crouch so often when you're at long distances from them
		
		if not data.unit:movement():cool() and not managers.groupai:state():whisper_mode() then
			if stand_chance ~= 1 and crouch_roll > stand_chance and pose_chk or data.char_tweak.allowed_poses and data.char_tweak.allowed_poses.crouch then
				end_pose = "crouch"
				pose = "crouch"
			else
				end_pose = "stand"
				pose = "stand"
			end
		end
				
		if not pose then
			pose = not data.char_tweak.crouch_move and "stand" or data.char_tweak.allowed_poses and not data.char_tweak.allowed_poses.stand and "crouch" or "stand"
			end_pose = pose
		end
		
		if not data.unit:anim_data()[pose] then
			CopLogicAttack["_chk_request_action_" .. pose](data)
		end
		
		local new_action_data = {
			body_part = 2,
			type = "walk",
			nav_path = path,
			pose = pose,
			end_pose = end_pose,
			variant = haste or "walk"
		}
		my_data.cover_path = nil
		my_data.walking_to_cover_shoot_pos = data.unit:brain():action_request(new_action_data)

		if my_data.walking_to_cover_shoot_pos then
			--my_data.walking_to_cover_shoot_pos = my_data.advancing
			my_data.at_cover_shoot_pos = nil
			
			if data.name == "travel" and my_data.nearest_cover and notdelayclbksornotdlclbks_chk then
				CopLogicBase.add_delayed_clbk(my_data, my_data.cover_update_task_key, callback(CopLogicTravel, CopLogicTravel, "_update_cover", data), data.t + 0.066)
			end

			data.brain:rem_pos_rsrv("path")
		end
	end
end

function CopLogicTravel._chk_request_action_walk_to_advance_pos(data, my_data, speed, end_rot, no_strafe, pose, end_pose)
	if not data.unit:movement():chk_action_forbidden("walk") and not my_data.turning or data.unit:anim_data().act_idle then
		CopLogicAttack._correct_path_start_pos(data, my_data.advance_path)
		
		if data.cool then
			no_strafe = true
		end
		
		local path = my_data.advance_path
		local new_action_data = {
			type = "walk",
			body_part = 2,
			nav_path = path,
			variant = speed or "run",
			end_rot = end_rot,
			path_simplified = my_data.path_is_precise,
			no_strafe = no_strafe,
			pose = pose,
			end_pose = end_pose
		}
		my_data.advance_path = nil
		my_data.starting_advance_action = true
		my_data.advancing = data.unit:brain():action_request(new_action_data)
		my_data.starting_advance_action = false

		if my_data.advancing then
			data.brain:rem_pos_rsrv("path")
			
			if data.tactics then
				if data.objective.pos and my_data.coarse_path and my_data.coarse_path_index then
					local cur_index = my_data.coarse_path_index
					local total_nav_points = #my_data.coarse_path
					
					if cur_index == total_nav_points - 1 then
						local flash = nil
						if data.tactics.smoke_grenade or data.tactics.flash_grenade then
							if data.tactics.smoke_grenade and data.tactics.flash_grenade then
								local flashchance = math_random()
								
								if flashchance < 0.5 then
									flash = true
								end
							else
								if data.tactics.flash_grenade then
									flash = true
								end
							end
							
							CopLogicBase.do_grenade(data, data.objective.pos + math.UP * 5, flash)
						end
					end
				end
			end
			
			
			local notdelayclbksornotdlclbks_chk = not my_data.delayed_clbks or not my_data.delayed_clbks[my_data.cover_update_task_key]
			my_data.has_advanced_once = true
			if my_data.nearest_cover and notdelayclbksornotdlclbks_chk then
				CopLogicBase.add_delayed_clbk(my_data, my_data.cover_update_task_key, callback(CopLogicTravel, CopLogicTravel, "_update_cover", data), data.t + 0.066)
			end
			
			return true
		end
	end
end

function CopLogicTravel._chk_request_action_walk_to_optimal_pos(data, my_data, end_rot)
	if not data.unit:movement():chk_action_forbidden("walk") and not my_data.turning or data.unit:anim_data().act_idle then
		CopLogicAttack._correct_path_start_pos(data, my_data.optimal_path)
		
		local haste = nil
		local pose = nil

		if data.unit:movement():cool() then
			haste = "walk"
		elseif data.attention_obj then
			--enemies at long distances makes cops run, enemies at shorter distances makes cops walk, keeps pacing in small maps consistent and manageable, while making the cops seem cooler
			local pose_chk = not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.crouch
			local enemyseeninlast4secs = data.attention_obj and data.attention_obj.verified_t and data.t - data.attention_obj.verified_t < 4
			local enemy_seen_range_bonus = enemyseeninlast4secs and 600 or 0
			local enemy_has_height_difference = data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.dis >= 1200 and data.attention_obj.verified_t and data.t - data.attention_obj.verified_t < 4 and math.abs(data.m_pos.z - data.attention_obj.m_pos.z) > 250
			local height_difference_penalty = math.abs(data.m_pos.z - data.attention_obj.m_pos.z) < 250 and 600 or 0
			--local testing = true
			
			local enemy_visible8m_or_3m_chk = data.attention_obj.verified and data.attention_obj.dis <= 800 or data.attention_obj.dis <= 300
			
			if Global.game_settings.one_down then
				haste = "run"
			elseif data.team and data.team.id == tweak_data.levels:get_default_team_ID("player") or data.is_converted or data.unit:in_slot(16) or data.unit:in_slot(managers.slot:get_mask("criminals")) or data.attention_obj and data.attention_obj.dis > 10000 then 
				haste = "run"
			elseif data.is_suppressed and data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and enemy_visible8m_or_6m_chk then
				haste = "walk"
			elseif data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.dis > 300 + enemy_seen_range_bonus and not data.unit:movement():cool() and not managers.groupai:state():whisper_mode() then
				haste = "run"
			elseif data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.dis <= 300 + enemy_seen_range_bonus - height_difference_penalty and data.tactics and not data.tactics.hitnrun then
				haste = "walk"
			else
				haste = "run"
			end
		else
			haste = "run"
		end
		
		local crouch_roll = math_random()
		local stand_chance = nil
		local end_pose = nil
		
		if data.char_tweak.allowed_poses and data.char_tweak.allowed_poses.crouch then
			pose = "crouch"
			end_pose = "crouch"
		elseif data.char_tweak.allowed_poses and data.char_tweak.allowed_poses.stand then
			pose = "stand"
			end_pose = "stand"
		elseif data.attention_obj and data.attention_obj.dis > 10000 or data.unit:in_slot(16) or data.is_converted then
			stand_chance = 1
			pose = "stand"
			end_pose = "stand"
		elseif data.is_suppressed then
			stand_chance = 0.25
		elseif data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and not enemy_visible8m_or_3m_chk then
			stand_chance = 0.75
		elseif enemy_has_height_difference and enemy_visible8m_or_3m_chk then
			stand_chance = 0.25
		elseif data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and enemy_visible8m_or_3m_chk and CopLogicTravel._chk_close_to_criminal(data, my_data) and data.tactics and data.tactics.flank and haste == "walk" then
			stand_chance = 0.25
		else
			stand_chance = 0.5
		end
		
		--randomize enemy crouching to make enemies feel less easy to aim at, the fact they're always crouching all over the place always bugged me, plus, they shouldn't need to crouch so often when you're at long distances from them
		
		if not data.unit:movement():cool() and not managers.groupai:state():whisper_mode() then
			if data.char_tweak.allowed_poses and data.char_tweak.allowed_poses.crouch then
				end_pose = "crouch"
				pose = "crouch"
			elseif data.char_tweak.allowed_poses and data.char_tweak.allowed_poses.stand then
				end_pose = "stand"
				pose = "stand"
			elseif stand_chance ~= 1 and crouch_roll > stand_chance then
				end_pose = "crouch"
				pose = "crouch"
			else
				end_pose = "stand"
				pose = "stand"
			end
		end
		
		--log("piss")
		local new_action_data = {
			type = "walk",
			body_part = 2,
			pose = pose,
			end_pose = end_pose,
			variant = haste or "run",
			nav_path = my_data.optimal_path,
			end_rot = end_rot
		}
		
		my_data.walking_to_optimal_pos = data.unit:brain():action_request(new_action_data)
						
		if my_data.walking_to_optimal_pos then
			my_data.optimal_path = nil
			my_data.optimal_pos = nil
			data.brain:rem_pos_rsrv("path")
			
			if data.name == "travel" and my_data.nearest_cover and notdelayclbksornotdlclbks_chk then
				CopLogicBase.add_delayed_clbk(my_data, my_data.cover_update_task_key, callback(CopLogicTravel, CopLogicTravel, "_update_cover", data), data.t + 0.066)
			end

			return true
		end
	end
end

function CopLogicTravel._chk_begin_advance(data, my_data)
	if my_data.turning or data.unit:movement():chk_action_forbidden("walk") then
		return
	end

	local objective = data.objective
	local haste = nil
	local pose = nil
	local can_perform_walking_action = true
		
	--this is a mess, but it should keep enemy movement tacticool overall, by having them prefer slower apporoaches at close ranges
	if can_perform_walking_action then
		
		--local testing = true
		
		if data.unit:movement():cool() then
			haste = "walk"
		elseif data.attention_obj then
			local enemyseeninlast4secs = data.attention_obj and data.attention_obj.verified_t and data.t - data.attention_obj.verified_t < 4
			local enemy_seen_range_bonus = enemyseeninlast4secs and 600 or 0
			local enemy_has_height_difference = data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.dis >= 800 and data.attention_obj.verified_t and data.t - data.attention_obj.verified_t < 4 and math.abs(data.m_pos.z - data.attention_obj.m_pos.z) > 250
			local height_difference_penalty = math.abs(data.m_pos.z - data.attention_obj.m_pos.z) < 250 and 600 or 0	
			local enemy_visible8m_or_3m_chk = data.attention_obj.verified and data.attention_obj.dis <= 800 or data.attention_obj.dis <= 300
			
			if Global.game_settings.one_down then
				haste = "run"
			elseif data.team and data.team.id == tweak_data.levels:get_default_team_ID("player") or data.is_converted or data.unit:in_slot(16) or data.unit:in_slot(managers.slot:get_mask("criminals")) or data.attention_obj and data.attention_obj.dis > 10000 then 
				haste = "run"
			elseif data.is_suppressed and data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and enemy_visible8m_or_6m_chk then
				haste = "walk"
			elseif data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.dis > 300 + enemy_seen_range_bonus then
				haste = "run"
			elseif data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.dis <= 300 + enemy_seen_range_bonus - height_difference_penalty and data.tactics and not data.tactics.hitnrun then
				haste = "walk"
			else
				haste = "run"
			end
		else
			haste = "run"
		end

		local should_crouch = nil

		local end_rot = nil

		if my_data.coarse_path and my_data.coarse_path_index >= #my_data.coarse_path - 1 then
			end_rot = objective and objective.rot
		end

		local no_strafe, end_pose = nil
		
		local crouch_roll = math_random(0.01, 1)
		local stand_chance = nil
		
		
		if data.unit:movement():cool() then
			stand_chance = 1	
			pose = "stand"
			end_pose = "stand"
		elseif data.char_tweak.allowed_poses and data.char_tweak.allowed_poses.crouch then
			pose = "crouch"
			end_pose = "crouch"
		elseif data.char_tweak.allowed_poses and data.char_tweak.allowed_poses.stand then
			pose = "stand"
			end_pose = "stand"
		elseif data.attention_obj and data.attention_obj.dis > 10000 or data.unit:in_slot(16) or data.is_converted then
			stand_chance = 1
			pose = "stand"
			end_pose = "stand"
		elseif data.is_suppressed then
			stand_chance = 0.25
		elseif data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and not enemy_visible8m_or_3m_chk then
			stand_chance = 0.75
		elseif enemy_has_height_difference and enemy_visible8m_or_3m_chk then
			stand_chance = 0.25
		elseif data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and enemy_visible8m_or_3m_chk and CopLogicTravel._chk_close_to_criminal(data, my_data) and data.tactics and data.tactics.flank and haste == "walk" and is_mook then
			stand_chance = 0.25
		else
			stand_chance = 0.5
		end
		
		--randomize enemy crouching to make enemies feel less easy to aim at, the fact they're always crouching all over the place always bugged me, plus, they shouldn't need to crouch so often when you're at long distances from them
		
		if not data.unit:movement():cool() and not managers.groupai:state():whisper_mode() then
			if data.char_tweak.allowed_poses and data.char_tweak.allowed_poses.crouch then
				end_pose = "crouch"
				pose = "crouch"
			elseif data.char_tweak.allowed_poses and data.char_tweak.allowed_poses.stand then
				end_pose = "stand"
				pose = "stand"
			elseif stand_chance ~= 1 and crouch_roll > stand_chance then
				end_pose = "crouch"
				pose = "crouch"
			else
				end_pose = "stand"
				pose = "stand"
			end
		end
		
		if not pose then
			pose = not data.char_tweak.crouch_move and "stand" or data.char_tweak.allowed_poses and not data.char_tweak.allowed_poses.stand and "crouch" or "stand"
		end
		
		if not data.unit:anim_data()[pose] then
			CopLogicAttack["_chk_request_action_" .. pose](data)
		end
		
		CopLogicTravel._chk_request_action_walk_to_advance_pos(data, my_data, haste, end_rot, no_strafe, pose, end_pose)
	end
end

function CopLogicTravel._chk_start_action_move_out_of_the_way(data, my_data)
	local my_tracker = data.unit:movement():nav_tracker()
	local reservation = {
		radius = 30,
		position = data.m_pos,
		filter = data.pos_rsrv_id
	}

	if not managers.navigation:is_pos_free(reservation) then
		local to_pos = CopLogicTravel._get_pos_on_wall(data.m_pos, 500)

		if to_pos then
			local path = {
				my_tracker:position(),
				to_pos
			}

			CopLogicTravel._chk_request_action_walk_to_cover_shoot_pos(data, my_data, path, "run")
		end
	end
end

function CopLogicTravel.reset_travel_information(data, my_data)
	--local draw_duration = 1
	--local new_brush = Draw:brush(Color.red:with_alpha(1), draw_duration)
	--new_brush:sphere(data.unit:movement():m_head_pos(), 20)
	
	if my_data.protected then
		return
	end
	
	my_data.coarse_path = nil
	my_data.advance_path = nil
	my_data.coarse_path_index = nil
	
	my_data.desynced_from_pathing = nil
	my_data.objective_outdated = nil
	
	if my_data.coarse_path_search_id then
		data.unit:brain():abort_detailed_pathing(my_data.coarse_path_search_id)
	end
	
	if my_data.advance_path_search_id then
		data.unit:brain():abort_detailed_pathing(my_data.advance_path_search_id)
	end
	
	my_data.coarse_path_search_id = nil
	my_data.processing_coarse_path = nil
	
	CopLogicTravel._begin_coarse_pathing(data, my_data)
	
	my_data.just_reset_info = true
end

function CopLogicTravel._chk_start_action_move_back(data, my_data, focus_enemy, engage, assault_break)

	local pantsdownchk = nil
	
	if focus_enemy.is_person and focus_enemy.is_husk_player or focus_enemy.is_person and focus_enemy.is_local_player then
		if focus_enemy.is_local_player then
			local e_movement_state = focus_enemy.unit:movement():current_state()
			if e_movement_state:_is_reloading() or e_movement_state:_interacting() or e_movement_state:is_equipping() then
				pantsdownchk = true
			end
		else
			local e_anim_data = focus_enemy.unit:anim_data()
			local movingoridle = e_anim_data.move or e_anim_data.idle
			if not movingoridle or e_anim_data.reload then
				pantsdownchk = true
			end
		end
	end
	
	local can_perform_walking_action = not my_data.turning and not data.unit:movement():chk_action_forbidden("walk") and not my_data.has_old_action
	
	if can_perform_walking_action then
	--what the fuck is my code rn tbh
			
		local from_pos = mvec3_copy(data.m_pos)
		local threat_tracker = focus_enemy.nav_tracker
		local threat_head_pos = focus_enemy.m_head_pos
		local max_walk_dis = nil
		local should_crouch = nil
		local vis_required = nil
			
		if assault_break then 	
			max_walk_dis = 5000
			vis_required = nil
		elseif data.tactics and data.tactics.elite_ranged_fire then
			max_walk_dis = 2000
			vis_required = true
		elseif data.tactics and data.tactics.spoocavoidance then
			max_walk_dis = 1500
			should_crouch = true
		elseif data.tactics and data.tactics.reloadingretreat then
			max_walk_dis = 1500
		elseif data.tactics and data.tactics.hitnrun then
			max_walk_dis = 800
		else
			max_walk_dis = 400
		end
		
		local pose = "stand"
		
		if data.char_tweak.allowed_poses and data.char_tweak.allowed_poses.stand then
			pose = "stand"
		elseif data.char_tweak.allowed_poses and data.char_tweak.allowed_poses.crouch or data.is_suppressed or should_crouch then
			pose = "crouch"
		end
		
		
				
		local retreat_to = CopLogicAttack._find_retreat_position(data, from_pos, focus_enemy.m_pos, threat_head_pos, threat_tracker, max_walk_dis, vis_required)

		if retreat_to then
			CopLogicAttack._cancel_cover_pathing(data, my_data)
				
			if data.unit:anim_data().move or data.unit:anim_data().run then
				local new_action = {
					body_part = 2,
					type = "idle"
				}
				data.unit:brain():action_request(new_action)
			end
					
				--if data.tactics and data.tactics.hitnrun or data.tactics and data.tactics.elite_ranged_fire then
					--log("hitnrun or eliteranged just backed up properly")
				--end
					
				
			local new_action_data = {
				variant = "run",
				body_part = 2,
				type = "walk",
				pose = pose,
				end_pose = pose,
				nav_path = {
					from_pos,
					retreat_to
				}
			}
			my_data.retreating = data.unit:brain():action_request(new_action_data)
					
			if my_data.retreating then
				my_data.surprised = true
				
				if assault_break then
					my_data.assault_break_retreat_complete = true
				end
				
				local flash = nil
					
				if data.tactics then
					if data.tactics.smoke_grenade or data.tactics.flash_grenade then
						if data.tactics.smoke_grenade and data.tactics.flash_grenade then
							local flashchance = math_random()
								
							if flashchance < 0.5 then
								flash = true
							end
						else
							if data.tactics.flash_grenade then
								flash = true
							end
						end
								
						CopLogicBase.do_grenade(data, data.m_pos + math.UP * 5, flash, true)
					end
				end
					
				if data.tactics and data.tactics.elite_ranged_fire then
					if not data.unit:in_slot(16) and data.char_tweak.chatter.dodge then
						managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "dodge")
					end
				end

				return true
			end
		end
	end
end

function CopLogicTravel._update_cover(ignore_this, data)
	local my_data = data.internal_data

	CopLogicBase.on_delayed_clbk(my_data, my_data.cover_update_task_key)

	local cover_release_dis = 100
	local nearest_cover = my_data.nearest_cover
	local best_cover = my_data.best_cover
	local m_pos = data.m_pos

	if not my_data.in_cover and nearest_cover and cover_release_dis < mvec3_dis(nearest_cover[1][1], m_pos) then
		local fucking = managers.navigation:release_cover(nearest_cover[1])

		my_data.nearest_cover = nil
		nearest_cover = nil
	end

	if best_cover and cover_release_dis < mvec3_dis(best_cover[1][1], m_pos) then
		local fucking = managers.navigation:release_cover(best_cover[1])
		
		my_data.best_cover = nil
		best_cover = nil
	end

	if nearest_cover or best_cover then
		CopLogicBase.add_delayed_clbk(my_data, my_data.cover_update_task_key, callback(CopLogicTravel, CopLogicTravel, "_update_cover", data), data.t + 0.2)
	end
end

function CopLogicTravel.action_complete_clbk(data, action)
	local my_data = data.internal_data
	local action_type = action:type()
	data.t = TimerManager:game():time()
	
	local engage_range = nil
	
	if my_data.weapon_range and my_data.weapon_range.close then
		engage_range = my_data.weapon_range.close
	else
		engage_range = 1500
	end
	
	if action_type == "act" then
		if not data.unit:in_slot(managers.slot:get_mask("criminals")) then
			if not data.unit:character_damage():dead() and action:expired() then
				if data.unit:base():has_tag("spooc") or data.unit:base()._tweak_table == "shadow_spooc" then
					SpoocLogicAttack._upd_spooc_attack(data, my_data)
				end
				CopLogicAttack._upd_aim(data, my_data)
				data.logic._upd_stance_and_pose(data, data.internal_data)
				if my_data.has_advanced_once then
					CopLogicTravel._upd_combat_movement(data)
				else
					CopLogicTravel.upd_advance(data)
				end
			end
		end
	elseif action_type == "healed" then
		CopLogicAttack._cancel_cover_pathing(data, my_data)
		CopLogicAttack._cancel_charge(data, my_data)
	
		if not data.unit:character_damage():dead() and action:expired() then
			if data.unit:base():has_tag("spooc") or data.unit:base()._tweak_table == "shadow_spooc" then
				SpoocLogicAttack._upd_spooc_attack(data, my_data)
			end
			CopLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
			CopLogicTravel._upd_combat_movement(data)
		end
	elseif action_type == "heal" then
		CopLogicAttack._cancel_cover_pathing(data, my_data)
		CopLogicAttack._cancel_charge(data, my_data)
	
		if not data.unit:character_damage():dead() and action:expired() then
			if data.unit:base():has_tag("spooc") or data.unit:base()._tweak_table == "shadow_spooc" then
				SpoocLogicAttack._upd_spooc_attack(data, my_data)
			end
			CopLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
			CopLogicTravel._upd_combat_movement(data)
		end
	elseif action_type == "walk" then
		if action:expired() and my_data.coarse_path and my_data.advancing and not my_data.old_action_advancing and not my_data.has_old_action and not my_data.starting_advance_action and my_data.coarse_path_index then
			my_data.coarse_path_index = my_data.coarse_path_index + 1

			if my_data.coarse_path_index > #my_data.coarse_path then
				CopLogicTravel.reset_travel_information(data, my_data)
				--log("bad!!!")
			end
		end

		my_data.advancing = nil
		my_data.old_action_advancing = nil
		
		if my_data.retreating then
			my_data.retreating = nil
			my_data.surprised = nil
			if action:expired() then
				if data.unit:base():has_tag("spooc") or data.unit:base()._tweak_table == "shadow_spooc" then
					SpoocLogicAttack._upd_spooc_attack(data, my_data)
				end
				
				CopLogicAttack._upd_aim(data, my_data)
				data.logic._upd_stance_and_pose(data, data.internal_data)
				CopLogicTravel._upd_combat_movement(data, true)
			end
		elseif my_data.walking_to_optimal_pos then
			my_data.walking_to_optimal_pos = nil
			
			if action:expired() then
				if data.unit:base():has_tag("spooc") or data.unit:base()._tweak_table == "shadow_spooc" then
					SpoocLogicAttack._upd_spooc_attack(data, my_data)
				end

				CopLogicAttack._upd_aim(data, my_data)
				data.logic._upd_stance_and_pose(data, data.internal_data)
				if my_data.protected and my_data.optimal_path then
					CopLogicTravel._chk_request_action_walk_to_optimal_pos(data, my_data)
					
					if data.important then
						if my_data.walking_to_optimal_pos and not my_data.pathing_to_optimal_pos then	
							local follow_unit = my_data.protector
							local follow_tracker = follow_unit:movement():nav_tracker()
							local field_pos = follow_tracker:field_position()
							local advance_pos = follow_unit:brain() and follow_unit:brain():is_advancing()
							local follow_unit_pos = advance_pos or field_pos
							
							if mvec3_dis(data.pos_rsrv.move_dest.position, follow_unit_pos) > 240 then
										
								my_data.optimal_pos = CopLogicTravel._get_pos_on_wall(follow_unit_pos, 180, 180, nil)
								
								local prio = data.logic.get_pathing_prio(data)
								local to_pos = my_data.optimal_pos
								my_data.pathing_to_optimal_pos = true
								my_data.optimal_path_search_id = tostring(data.key) .. "optimal"
								
								if my_data.walking_to_optimal_pos then
									local from_pos = data.pos_rsrv.move_dest.position
									data.unit:brain():search_for_path_from_pos(my_data.optimal_path_search_id, from_pos, to_pos, prio, nil)
									--local draw_duration = 1
									--local line = Draw:brush(Color.red:with_alpha(0.5), draw_duration)
									--line:cylinder(from_pos, to_pos, 4)
									--line:sphere(data.unit:movement():m_head_pos(), 20)
								end	
							end						
						end
					end
					
				else
					CopLogicTravel._upd_combat_movement(data, true)
				end
			end
		end
		
		if my_data.moving_to_cover then
			if action:expired() then
				if my_data.best_cover then
					managers.navigation:release_cover(my_data.best_cover[1])
				end

				my_data.best_cover = my_data.moving_to_cover

				CopLogicBase.chk_cancel_delayed_clbk(my_data, my_data.cover_update_task_key)

				local high_ray = CopLogicTravel._chk_cover_height(data, my_data.best_cover[1], data.visibility_slotmask)
				my_data.best_cover[4] = high_ray
				my_data.in_cover = true
				local cover_wait_time = 0.6 + 0.4 * math_random()

				if not CopLogicTravel._chk_close_to_criminal(data, my_data) then
					cover_wait_time = 0
				end

				my_data.cover_leave_t = data.t + cover_wait_time
			else
				managers.navigation:release_cover(my_data.moving_to_cover[1])

				if my_data.best_cover then
					local dis = mvec3_dis(my_data.best_cover[1][1], data.unit:movement():m_pos())

					if dis > 100 then
						managers.navigation:release_cover(my_data.best_cover[1])

						my_data.best_cover = nil
					end
				end
			end

			my_data.moving_to_cover = nil
		elseif my_data.best_cover then
			local dis = mvec3_dis(my_data.best_cover[1][1], data.unit:movement():m_pos())

			if dis > 100 then
				managers.navigation:release_cover(my_data.best_cover[1])

				my_data.best_cover = nil
			end
		end

		if not action:expired() then
			if my_data.processing_advance_path then
				local pathing_results = data.pathing_results

				if pathing_results and pathing_results[my_data.advance_path_search_id] then
					data.pathing_results[my_data.advance_path_search_id] = nil
					my_data.processing_advance_path = nil
				end
			elseif my_data.advance_path then
				my_data.advance_path = nil
			end

			data.unit:brain():abort_detailed_pathing(my_data.advance_path_search_id)
		end

		if my_data.coarse_path then
			local my_seg = data.unit:movement():nav_tracker():nav_segment()
			local continue_pathing = nil
			for _, fuckingtable in pairs(my_data.coarse_path) do
					--log("the actual table check is working")
				if fuckingtable[1] == my_seg then
					--log("i got some jelly beans")
					continue_pathing = true
				end
			end
					
			if not continue_pathing then
				--log("you want some jelly beans")
				my_data.desynced_from_pathing = true
			end	
		end
	elseif action_type == "shoot" then		
		my_data.shooting = nil
	elseif action_type == "tase" then
		if not data.unit:character_damage():dead() and action:expired() and my_data.tasing then
			local record = managers.groupai:state():criminal_record(my_data.tasing.target_u_key)

			if record and record.status then
				data.tase_delay_t = TimerManager:game():time() + 45
			end
			CopLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
			CopLogicTravel._upd_combat_movement(data)
		end
		
		if my_data.tasing then
			managers.groupai:state():on_tase_end(my_data.tasing.target_u_key)
		end

		my_data.tasing = nil
	elseif action_type == "spooc" then
		data.spooc_attack_timeout_t = TimerManager:game():time() + math_lerp(data.char_tweak.spooc_attack_timeout[1], data.char_tweak.spooc_attack_timeout[2], math_random())

		if action:complete() and data.char_tweak.spooc_attack_use_smoke_chance > 0 and math_random() <= data.char_tweak.spooc_attack_use_smoke_chance and not managers.groupai:state():is_smoke_grenade_active() then
			managers.groupai:state():detonate_smoke_grenade(data.m_pos + math_UP * 10, data.unit:movement():m_head_pos(), math_lerp(15, 30, math_random()), false)
		end
		
		if not data.unit:character_damage():dead() and action:expired() then
			CopLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
			CopLogicTravel._upd_combat_movement(data)
		end

		my_data.spooc_attack = nil
		
		if action:complete() then
			if my_data.coarse_path then
				local my_seg = data.unit:movement():nav_tracker():nav_segment()
				local continue_pathing = nil
				for _, fuckingtable in pairs(my_data.coarse_path) do
					--log("the actual table check is working")
					if fuckingtable[1] == my_seg then
						--log("this should be fine")
						continue_pathing = true
					end
				end
					
				if not continue_pathing then
					--log("you want some jelly beans")
					my_data.desynced_from_pathing = true
				end	
			end
		end
	elseif action_type == "reload" then
		--Removed the requirement for being important here.
		if not data.unit:character_damage():dead() and action:expired() then
			if data.unit:base():has_tag("spooc") or data.unit:base()._tweak_table == "shadow_spooc" then
				SpoocLogicAttack._upd_spooc_attack(data, my_data)
			end
			CopLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
			CopLogicTravel._upd_combat_movement(data)
		end
	elseif action_type == "turn" then
		if not data.unit:character_damage():dead() and action:expired() then
			if data.unit:base():has_tag("spooc") or data.unit:base()._tweak_table == "shadow_spooc" then
				SpoocLogicAttack._upd_spooc_attack(data, my_data)
			end
			CopLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
			CopLogicTravel._upd_combat_movement(data)
		end
		
		my_data.turning = nil
		
		local objective = data.objective
		local allow_trans, obj_failed = CopLogicBase.is_obstructed(data, objective, nil, nil)

		if allow_trans then
			local wanted_state = data.logic._get_logic_state_from_reaction(data)

			if wanted_state and wanted_state ~= data.name and obj_failed then
				if data.unit:in_slot(managers.slot:get_mask("enemies")) or data.unit:in_slot(17) then
					data.objective_failed_clbk(data.unit, data.objective)
				elseif data.unit:in_slot(managers.slot:get_mask("criminals")) then
					managers.groupai:state():on_criminal_objective_failed(data.unit, data.objective, false)
				end

				if my_data == data.internal_data then
					debug_pause_unit(data.unit, "[CopLogicTravel.action_complete_clbk] exiting without discarding objective", data.unit, inspect(data.objective))
					CopLogicBase._exit(data.unit, wanted_state)
				end
			end
		end
	elseif action_type == "hurt" then
		CopLogicAttack._cancel_cover_pathing(data, my_data)
		CopLogicAttack._cancel_charge(data, my_data)
		
		--Removed the requirement for being important here.
		if not data.unit:character_damage():dead() and action:expired() and not CopLogicBase.chk_start_action_dodge(data, "hit") then
			if data.unit:base():has_tag("spooc") or data.unit:base()._tweak_table == "shadow_spooc" then
				SpoocLogicAttack._upd_spooc_attack(data, my_data)
			end
			CopLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
			CopLogicTravel._upd_combat_movement(data)
		end
		
		if my_data.coarse_path then
			local my_seg = data.unit:movement():nav_tracker():nav_segment()
			local continue_pathing = nil
			for _, fuckingtable in pairs(my_data.coarse_path) do
				--log("the actual table check is working")
				if fuckingtable[1] == my_seg then
					--log("this should be fine")
					continue_pathing = true
				end
			end
					
			if not continue_pathing then
				--log("you want some jelly beans")
				my_data.desynced_from_pathing = true
			end	
		end
		
		local objective = data.objective
		local allow_trans, obj_failed = CopLogicBase.is_obstructed(data, objective, nil, nil)

		if allow_trans then
			local wanted_state = data.logic._get_logic_state_from_reaction(data)

			if wanted_state and wanted_state ~= data.name and obj_failed then
				if data.unit:in_slot(managers.slot:get_mask("enemies")) or data.unit:in_slot(17) then
					data.objective_failed_clbk(data.unit, data.objective)
				elseif data.unit:in_slot(managers.slot:get_mask("criminals")) then
					managers.groupai:state():on_criminal_objective_failed(data.unit, data.objective, false)
				end

				if my_data == data.internal_data then
					debug_pause_unit(data.unit, "[CopLogicTravel.action_complete_clbk] exiting without discarding objective", data.unit, inspect(data.objective))
					CopLogicBase._exit(data.unit, wanted_state)
				end
			end
		end	
	elseif action_type == "dodge" then
		local timeout = action:timeout()

		if timeout then
			data.dodge_timeout_t = TimerManager:game():time() + math_lerp(timeout[1], timeout[2], math_random())
		end

		CopLogicAttack._cancel_cover_pathing(data, my_data)
		CopLogicAttack._cancel_charge(data, my_data)
		
		if not data.unit:character_damage():dead() and action:expired() then
			if data.unit:base():has_tag("spooc") or data.unit:base()._tweak_table == "shadow_spooc" then
				SpoocLogicAttack._upd_spooc_attack(data, my_data)
			end
			CopLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
			CopLogicTravel._upd_combat_movement(data)
		end
		
		if my_data.coarse_path then
			local my_seg = data.unit:movement():nav_tracker():nav_segment()
			local continue_pathing = nil
			for _, fuckingtable in pairs(my_data.coarse_path) do
				--log("the actual table check is working")
				if fuckingtable[1] == my_seg then
					--log("this should be fine")
					continue_pathing = true
				end
			end
					
			if not continue_pathing then
				--log("you want some jelly beans")
				my_data.desynced_from_pathing = true
			end	
		end
		
		local objective = data.objective
		local allow_trans, obj_failed = CopLogicBase.is_obstructed(data, objective, nil, nil)

		if allow_trans then
			local wanted_state = data.logic._get_logic_state_from_reaction(data)

			if wanted_state and wanted_state ~= data.name and obj_failed then
				if data.unit:in_slot(managers.slot:get_mask("enemies")) or data.unit:in_slot(17) then
					data.objective_failed_clbk(data.unit, data.objective)
				elseif data.unit:in_slot(managers.slot:get_mask("criminals")) then
					managers.groupai:state():on_criminal_objective_failed(data.unit, data.objective, false)
				end

				if my_data == data.internal_data then
					debug_pause_unit(data.unit, "[CopLogicTravel.action_complete_clbk] exiting without discarding objective", data.unit, inspect(data.objective))
					CopLogicBase._exit(data.unit, wanted_state)
				end
			end
		end
	end	
end

function CopLogicTravel._find_cover(data, search_nav_seg, near_pos)
	local cover = nil
	local search_area = managers.groupai:state():get_area_from_nav_seg_id(search_nav_seg)
	local my_data = data.internal_data

	if data.unit:movement():cool() then
		cover = managers.navigation:find_cover_in_nav_seg_1(search_area.nav_segs)
	else
		local search_start_pos, cone_base, cone_angle, variation_z, optimal_threat_dis, max_dist, threat_pos = nil

		near_pos = near_pos or nil
		
		local all_criminals = managers.groupai:state():all_char_criminals()
		local closest_crim_u_data, closest_crim_dis = nil
		
		if data.unit:in_slot(managers.slot:get_mask("enemies")) and not data.is_converted then
			if data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction then
				threat_pos = data.attention_obj.nav_tracker:field_position()
			else
				for u_key, u_data in pairs(all_criminals) do
					local crim_area = managers.groupai:state():get_area_from_nav_seg_id(u_data.tracker:nav_segment())

					if crim_area == search_area then
						threat_pos = u_data.m_pos

						break
					else
						local pos_to_check = near_pos or search_area.pos
						local crim_dis = mvec3_dis_sq(pos_to_check, u_data.m_pos)

						if not closest_crim_dis or crim_dis < closest_crim_dis then
							threat_pos = u_data.unit:movement():nav_tracker():field_position()
							closest_crim_dis = crim_dis
						end
					end
				end
			end
			
			if my_data.protector then
				if my_data.cowardly or data.tactics and data.tactics.shield_cover then
					local follow_unit = my_data.protector
					local follow_tracker = follow_unit:movement():nav_tracker()
					local field_pos = follow_tracker:field_position()
					local advance_pos = follow_unit:brain() and follow_unit:brain():is_advancing()
					local follow_unit_pos = advance_pos or field_pos
					local pos = Vector3()
							
					if not alive(data.unit:inventory() and data.unit:inventory()._shield_unit) then --this is probably better than sex.
						mvec3_set(pos, follow_unit:movement()._m_rot:y())
						mvec3_mul(pos, -60)
						mvec3_add(pos, follow_unit_pos)
					else
						mvec3_set(pos, follow_unit:movement()._m_rot:x())
						local dir = math.random() < 0.5 and -60 or 60
						mvec3_mul(pos, dir)
						mvec3_add(pos, follow_unit_pos)
					end

					near_pos = pos
				end
			else
				my_data.protector = nil
			end
		
			if threat_pos then		
				if data.objective.attitude == "engage" then
					if not near_pos then
						search_start_pos = threat_pos or nil
					end
					optimal_threat_dis = nil
				else
					optimal_threat_dis = my_data.weapon_range.far
				end			
			end
		end
		
		if near_pos then
			if not data.objective.distance then
				max_dist = 600

				if data.objective.called or data.team and data.team.id == tweak_data.levels:get_default_team_ID("player") or data.is_converted or data.unit:in_slot(16) or data.unit:in_slot(managers.slot:get_mask("criminals")) or data.tactics and data.tactics.shield_cover then
					max_dist = 300
				end
			else
				max_dist = data.objective.distance * 0.9
			end
			--variation_z = 250 causes an access violation crash, probably needs something else...
		end
		
		--things commented out here need setups that i wouldnt know how to make...
		local search_params = {
			in_nav_seg = search_nav_seg, 
			optimal_threat_dis = optimal_threat_dis or nil, 
			near_pos = near_pos or nil, 
			threat_pos = threat_pos or nil,
			--cone_base = cone_base or nil,
			--cone_angle = cone_angle or nil,
			max_dist = max_dist or nil,
			--variation_z = variation_z or nil,
			search_start_pos = search_start_pos or near_pos or nil
		}

		cover = managers.navigation:find_cover_from_literally_anything(search_params) --custom function, pay attention
	end

	return cover
end

function CopLogicTravel.get_pathing_prio(data)
    local prio = nil
    local objective = data.objective

    if objective then
        prio = 0

        if objective.type == "phalanx" then
            prio = 4
        elseif objective.follow_unit then
            if objective.follow_unit:base().is_local_player or objective.follow_unit:base().is_husk_player or managers.groupai:state():is_unit_team_AI(objective.follow_unit) then
                prio = 4
            end
        end
    end

    if data.is_converted or data.unit:in_slot(16) then
        if not prio then
            prio = 0
        end

        prio = prio + 2
    elseif data.team.id == tweak_data.levels:get_default_team_ID("player") then
        if not prio then
            prio = 0
        end

        prio = prio + 1
    end

    return prio
end

function CopLogicTravel._get_all_paths(data)
	return {
		optimal_path = data.internal_data.optimal_path,
		advance_path = data.internal_data.advance_path,
		cover_path = data.internal_data.cover_path,
		coarse_path = data.internal_data.coarse_path,
		flank_path = data.internal_data.flank_path,
		expected_pos_path = data.internal_data.expected_pos_path,
		charge_path = data.internal_data.charge_path
	}
end

function CopLogicTravel._set_verified_paths(data, verified_paths)
	data.internal_data.optimal_path = verified_paths.optimal_path
	data.internal_data.advance_path = verified_paths.advance_path
	data.internal_data.cover_path = verified_paths.cover_path
	data.internal_data.coarse_path = verified_paths.coarse_path
	data.internal_data.flank_path = verified_paths.flank_path
	data.internal_data.expected_pos_path = verified_paths.expected_pos_path
	data.internal_data.charge_path = verified_paths.charge_path
end

function CopLogicTravel._investigate_safe_flank_path(shait, nav_seg)
	return managers.groupai:state():is_nav_seg_populated_and_safe(nav_seg)
end

function CopLogicTravel._investigate_flank_path(shait, nav_seg)
	return managers.groupai:state():is_nav_seg_populated(nav_seg)
end

function CopLogicTravel._begin_coarse_pathing(data, my_data)
	local verify_clbk = nil
	
	if my_data.path_safely then --I am laughing maniacally right now.
		if not data.objective.follow_unit and data.tactics and data.tactics.flank then
			verify_clbk = callback(CopLogicTravel, CopLogicTravel, "_investigate_safe_flank_path")
		else
			verify_clbk = callback(CopLogicTravel, CopLogicTravel, "_investigate_coarse_path_verify_clbk")
		end
	elseif data.tactics and data.tactics.flank then
		verify_clbk = callback(CopLogicTravel, CopLogicTravel, "_investigate_flank_path")
	end

	local nav_seg = nil
	
	if not my_data.coarse_path_search_id then
		my_data.coarse_path_search_id = "CopLogicTravel_coarse" .. tostring(data.key)
	end

	if data.objective.follow_unit then
		nav_seg = data.objective.follow_unit:movement():nav_tracker():nav_segment()
	else
		nav_seg = data.objective.nav_seg
	end

	if data.unit:brain():search_for_coarse_path(my_data.coarse_path_search_id, nav_seg, verify_clbk) then
		my_data.processing_coarse_path = true
		--my_data.objective_outdated = nil
	end
end

function CopLogicTravel._chk_start_pathing_to_next_nav_point(data, my_data)
	local to_pos = nil
	
	if data.objective.pos and my_data.coarse_path and my_data.coarse_path_index then
		local cur_index = my_data.coarse_path_index
		local total_nav_points = #my_data.coarse_path
		
		if cur_index == total_nav_points - 1 then
			to_pos = data.objective.pos
		end
	end
	
	if not to_pos and my_data.coarse_path_index then
		to_pos = CopLogicTravel._get_exact_move_pos(data, my_data.coarse_path_index + 1)
	end
	
	my_data.advance_pos = to_pos
	
	my_data.processing_advance_path = true
	local prio = CopLogicTravel.get_pathing_prio(data)
	local nav_segs = CopLogicTravel._get_allowed_travel_nav_segs(data, my_data, to_pos)

	data.unit:brain():search_for_path(my_data.advance_path_search_id, to_pos, prio, nil, nav_segs)
end

local vec_from = Vector3()
local vec_to = Vector3()

function CopLogicTravel._determine_destination_occupation(data, objective, path_pos)
	local occupation = nil
	local my_data = data.internal_data

	if objective.type == "defend_area" then
		if objective.cover then
			occupation = {
				type = "defend",
				seg = objective.nav_seg,
				cover = objective.cover,
				radius = objective.radius
			}
		elseif objective.pos then
			occupation = {
				type = "defend",
				seg = objective.nav_seg,
				pos = objective.pos,
				radius = objective.radius
			}
		else
			local near_pos = nil
			
			if not my_data.protector then
				if objective.follow_unit then
					local follow_unit = objective.follow_unit
					local advance_pos = follow_unit:brain() and follow_unit:brain():is_advancing()
					local follow_unit_pos = advance_pos or follow_unit:movement():m_pos()
					near_pos = follow_unit_pos
				end
			else
				local follow_unit = my_data.protector
				local advance_pos = follow_unit:brain() and follow_unit:brain():is_advancing()
				local follow_unit_pos = advance_pos or follow_unit:movement():m_pos()
				near_pos = follow_unit_pos
			end
			
			local cover = nil
			
			if not data.cool then
				cover = CopLogicTravel._find_cover(data, objective.nav_seg, near_pos)
			end

			local max_dist = 1200
			local max_dist_fail = 1200

			if my_data.cowardly or objective.called or data.team and data.team.id == tweak_data.levels:get_default_team_ID("player") or data.is_converted or data.unit:in_slot(16) or data.unit:in_slot(managers.slot:get_mask("criminals")) or data.tactics and data.tactics.shield_cover then
				max_dist = 300
				max_dist_fail = 300
			end
		
			if cover then
				local cover_entry = {
					cover
				}
				occupation = {
					type = "defend",
					seg = objective.nav_seg,
					cover = cover_entry,
					radius = objective.radius
				}
			else
				local pos = nil
				
				if my_data.protector then
					local follow_unit = my_data.protector
					local follow_tracker = follow_unit:movement():nav_tracker()
					local field_pos = follow_tracker:field_position()
					local advance_pos = follow_unit:brain() and follow_unit:brain():is_advancing()
					local follow_pos = advance_pos or field_pos
					
					if my_data.cowardly or data.tactics and data.tactics.shield_cover then
						local ray_params = {
							allow_entry = false,
							trace = true,
							tracker_from = follow_tracker,
							pos_from = vec_from,
							pos_to = vec_to
						}
							
						pos = Vector3()
							
						if not alive(data.unit:inventory() and data.unit:inventory()._shield_unit) then --this is probably better than sex.
							mvec3_set(ray_params.pos_from, follow_pos)
							mvec3_set(ray_params.pos_to, follow_unit:movement()._m_rot:y())
							mvec3_mul(ray_params.pos_to, -60)
							mvec3_add(ray_params.pos_to, follow_pos)
								
							local ray_res = managers.navigation:raycast(ray_params)
							
							mvec3_set(pos, ray_params.trace[1])
								
							--local draw_duration = 1
							--local line = Draw:brush(Color.blue:with_alpha(0.5), draw_duration)
							--line:cylinder(data.m_pos, pos, 4)
								
						else
							local dir = math.random() < 0.5 and -60 or 60
								
							mvec3_set(ray_params.pos_from, follow_pos)
							mvec3_set(ray_params.pos_to, follow_unit:movement()._m_rot:x())
							mvec3_mul(ray_params.pos_to, dir)
							mvec3_add(ray_params.pos_to, follow_pos)
								
							local ray_res = managers.navigation:raycast(ray_params)
								
							mvec3_set(pos, ray_params.trace[1])
								
							--local draw_duration = 1
							--local line = Draw:brush(Color.blue:with_alpha(0.5), draw_duration)
							--line:cylinder(data.m_pos, pos, 4)
						end
					end
				end
				
				if not pos then
					pos = near_pos or path_pos or managers.navigation._nav_segments[objective.nav_seg].pos
				end
				
				local wall_pos = CopLogicTravel._get_pos_on_wall(pos, max_dist_fail)
				occupation = {
					type = "defend",
					seg = objective.nav_seg,
					pos = wall_pos,
					radius = objective.radius
				}
			end
		end
	elseif objective.type == "phalanx" then
		local logic = data.unit:brain():get_logic_by_name(objective.type)

		logic.register_in_group_ai(data.unit)

		local phalanx_circle_pos = logic.calc_initial_phalanx_pos(data.m_pos, objective)
		occupation = {
			type = "defend",
			seg = objective.nav_seg,
			pos = phalanx_circle_pos,
			radius = objective.radius
		}
	elseif objective.type == "act" then
		occupation = {
			type = "act",
			seg = objective.nav_seg,
			pos = objective.pos
		}
	elseif objective.type == "follow" then
		local my_data = data.internal_data
		local follow_unit = objective.follow_unit
		local follow_tracker = follow_unit:movement():nav_tracker()
		local dest_nav_seg_id = my_data.coarse_path[#my_data.coarse_path][1]
		local dest_area = managers.groupai:state():get_area_from_nav_seg_id(dest_nav_seg_id)
		local field_pos = follow_tracker:field_position()
		local advance_pos = follow_unit:brain() and follow_unit:brain():is_advancing()
		local follow_pos = advance_pos or field_pos
		local threat_pos = nil

		if data.attention_obj and data.attention_obj.nav_tracker and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction then
			threat_pos = data.attention_obj.nav_tracker:field_position()
		end

		local cover = nil
		
		if not data.cool then
			cover = CopLogicTravel._find_cover(data, dest_area.nav_segs, follow_pos)
		end
		
		local max_dist = 1200
		local max_dist_fail = 1200

		if my_data.cowardly or objective.called or data.team and data.team.id == tweak_data.levels:get_default_team_ID("player") or data.is_converted or data.unit:in_slot(16) or data.unit:in_slot(managers.slot:get_mask("criminals")) or data.tactics and data.tactics.shield_cover then
			max_dist = 300
			max_dist_fail = 300
		end
		
		if cover then
			local cover_entry = {
				cover
			}
			occupation = {
				type = "defend",
				cover = cover_entry
			}
		else
			if my_data.cowardly or data.tactics and data.tactics.shield_cover then
				if not follow_unit:in_slot(managers.slot:get_mask("criminals")) then
					local ray_params = {
						allow_entry = false,
						trace = true,
						tracker_from = follow_tracker,
						pos_from = vec_from,
						pos_to = vec_to
					}
					local pos = Vector3()
					if not alive(data.unit:inventory() and data.unit:inventory()._shield_unit) then --this is probably better than sex.
						mvec3_set(ray_params.pos_from, follow_pos)
						mvec3_set(ray_params.pos_to, follow_unit:movement()._m_rot:y())
						mvec3_mul(ray_params.pos_to, -60)
						mvec3_add(ray_params.pos_to, follow_pos)
						
						local ray_res = managers.navigation:raycast(ray_params)
					
						mvec3_set(pos, ray_params.trace[1])
						
						follow_pos = pos
						
						--local draw_duration = 1
						--local line = Draw:brush(Color.blue:with_alpha(0.5), draw_duration)
						--line:cylinder(data.m_pos, pos, 4)
						--local sphere = Draw:brush(Color.blue:with_alpha(0.5), draw_duration)
						--line:sphere(pos, 20)
					else
						local dir = math.random() < 0.5 and -60 or 60
						
						mvec3_set(ray_params.pos_from, follow_pos)
						mvec3_set(ray_params.pos_to, follow_unit:movement()._m_rot:x())
						mvec3_mul(ray_params.pos_to, dir)
						mvec3_add(ray_params.pos_to, follow_pos)
						
						local ray_res = managers.navigation:raycast(ray_params)
						
						mvec3_set(pos, ray_params.trace[1])
						
						follow_pos = pos
						
						--local draw_duration = 1
						--local line = Draw:brush(Color.blue:with_alpha(0.5), draw_duration)
						--line:cylinder(data.m_pos, pos, 4)
						--local sphere = Draw:brush(Color.blue:with_alpha(0.5), draw_duration)
						--line:sphere(pos, 20)
					end

				end
			end
			
			local to_pos = CopLogicTravel._get_pos_on_wall(follow_pos, max_dist_fail)
			occupation = {
				type = "defend",
				pos = to_pos
			}
		end
	elseif objective.type == "revive" then
		local is_local_player = objective.follow_unit:base().is_local_player
		local revive_u_mv = objective.follow_unit:movement()
		local revive_u_tracker = revive_u_mv:nav_tracker()
		local revive_u_rot = is_local_player and Rotation(0, 0, 0) or revive_u_mv:m_rot()
		local revive_u_fwd = revive_u_rot:y()
		local revive_u_right = revive_u_rot:x()
		local revive_u_pos = revive_u_tracker:lost() and revive_u_tracker:field_position() or revive_u_mv:m_pos()
		local ray_params = {
			trace = true,
			tracker_from = revive_u_tracker
		}

		if revive_u_tracker:lost() then
			ray_params.pos_from = revive_u_pos
		end

		local stand_dis = nil

		if is_local_player or objective.follow_unit:base().is_husk_player then
			stand_dis = 120
		else
			stand_dis = 90
			local mid_pos = mvec3_copy(revive_u_fwd)

			mvec3_mul(mid_pos, -20)
			mvec3_add(mid_pos, revive_u_pos)

			ray_params.pos_to = mid_pos
			local ray_res = managers.navigation:raycast(ray_params)
			revive_u_pos = ray_params.trace[1]
		end

		local rand_side_mul = math_random() > 0.5 and 1 or -1
		local revive_pos = mvec3_copy(revive_u_right)

		mvec3_mul(revive_pos, rand_side_mul * stand_dis)
		mvec3_add(revive_pos, revive_u_pos)

		ray_params.pos_to = revive_pos
		local ray_res = managers.navigation:raycast(ray_params)

		if ray_res then
			local opposite_pos = mvec3_copy(revive_u_right)

			mvec3_mul(opposite_pos, -rand_side_mul * stand_dis)
			mvec3_add(opposite_pos, revive_u_pos)

			ray_params.pos_to = opposite_pos
			local old_trace = ray_params.trace[1]
			local opposite_ray_res = managers.navigation:raycast(ray_params)

			if opposite_ray_res then
				if mvec3_dis(revive_pos, revive_u_pos) < mvec3_dis(ray_params.trace[1], revive_u_pos) then
					revive_pos = ray_params.trace[1]
				else
					revive_pos = old_trace
				end
			else
				revive_pos = ray_params.trace[1]
			end
		else
			revive_pos = ray_params.trace[1]
		end

		local revive_rot = revive_u_pos - revive_pos
		local revive_rot = Rotation(revive_rot, math.UP)
		occupation = {
			type = "revive",
			pos = revive_pos,
			rot = revive_rot
		}
	else
		occupation = {
			seg = objective.nav_seg,
			pos = objective.pos
		}
	end

	return occupation
end

function CopLogicTravel._get_exact_move_pos(data, nav_index)
	local my_data = data.internal_data
	local objective = data.objective
	local to_pos = nil
	local coarse_path = my_data.coarse_path
	local total_nav_points = #coarse_path
	local reservation, wants_reservation = nil

	if total_nav_points <= nav_index then
		local path_pos = coarse_path[nav_index][2] or nil
		local nav_seg = coarse_path[nav_index][1] or nil
			
		local new_occupation = data.logic._determine_destination_occupation(data, objective, path_pos)

		if new_occupation then
			if new_occupation.type == "guard" then
				local guard_door = new_occupation.door
				local guard_pos = CopLogicTravel._get_pos_accross_door(guard_door, objective.nav_seg)

				if guard_pos then
					reservation = CopLogicTravel._reserve_pos_along_vec(guard_door.center, guard_pos)

					if reservation then
						local guard_object = {
							type = "door",
							door = guard_door,
							from_seg = new_occupation.from_seg
						}
						objective.guard_obj = guard_object
						to_pos = reservation.pos
					end
				end
			elseif new_occupation.type == "defend" then
				if new_occupation.cover then
					to_pos = new_occupation.cover[1][1]
					
					local offset = data.char_tweak.wall_fwd_offset or 60

					to_pos = CopLogicTravel.apply_wall_offset_to_cover(data, my_data, new_occupation.cover[1], offset)

					local new_cover = new_occupation.cover

					managers.navigation:reserve_cover(new_cover[1], data.pos_rsrv_id)

					my_data.moving_to_cover = new_cover
				elseif new_occupation.pos then
					to_pos = new_occupation.pos
				end

				wants_reservation = true
			elseif new_occupation.type == "act" then
				to_pos = new_occupation.pos
				wants_reservation = true
			elseif new_occupation.type == "revive" then
				to_pos = new_occupation.pos
				objective.rot = new_occupation.rot
				wants_reservation = true
			else
				to_pos = new_occupation.pos
				wants_reservation = true
			end
		end

		if not to_pos then
			local orig_pos = managers.navigation:find_random_position_in_segment(nav_seg)
			local wall_pos = CopLogicTravel._get_pos_on_wall(orig_pos)
			
			if mvec3_not_eq(orig_pos, wall_pos) then
				to_pos = wall_pos
				wants_reservation = true
			else
				to_pos = path_pos
			end
		end
	else
		local nav_seg = coarse_path[nav_index][1]
		local area = managers.groupai:state():get_area_from_nav_seg_id(nav_seg)
		local near_pos = objective.follow_unit and objective.follow_unit:movement():nav_tracker():field_position() or nil
				
		if data.cool then
			--cover = managers.navigation:find_cover_in_nav_seg_1(area.nav_segs)
		else
			cover = CopLogicTravel._find_cover(data, nav_seg, near_pos)
		end

		if my_data.moving_to_cover then
			managers.navigation:release_cover(my_data.moving_to_cover[1])

			my_data.moving_to_cover = nil
		end

		if cover then
			managers.navigation:reserve_cover(cover, data.pos_rsrv_id)

			my_data.moving_to_cover = {
				cover
			}
			to_pos = cover[1]
			
			wants_reservation = true
		else
			local orig_pos = managers.navigation:find_random_position_in_segment(nav_seg)
			local wall_pos = CopLogicTravel._get_pos_on_wall(orig_pos, 1200)
			
			if mvec3_not_eq(orig_pos, wall_pos) then
				to_pos = wall_pos
				wants_reservation = true
			else
				to_pos = coarse_path[nav_index][2]
			end
		end
	end

	if not reservation and wants_reservation then
		data.brain:add_pos_rsrv("path", {
			radius = 60,
			position = mvec3_copy(to_pos)
		})
	end

	return to_pos
end

function CopLogicTravel.upd_advance(data)
	local unit = data.unit
	local my_data = data.internal_data
	local objective = data.objective
	
	local t = TimerManager:game():time()
	data.t = t
	
	if my_data.objective_outdated or my_data.desynced_from_pathing then
		CopLogicTravel.reset_travel_information(data, my_data)
				
		return
	end
	
	if my_data.has_old_action then
		CopLogicAttack._upd_stop_old_action(data, my_data)
	elseif my_data.warp_pos then
		local action_desc = {
			body_part = 1,
			type = "warp",
			position = mvec3_copy(objective.pos),
			rotation = objective.rot
		}

		if unit:movement():action_request(action_desc) then
			CopLogicTravel._on_destination_reached(data)
			my_data.has_advanced_once = true
		end
	elseif my_data.advancing then
		if not my_data.old_action_advancing and my_data.coarse_path then
			if data.announce_t and data.announce_t < data.t then
				CopLogicTravel._try_anounce(data)
			end

			CopLogicTravel._chk_stop_for_follow_unit(data, my_data)
		end
            
		if my_data ~= data.internal_data then
			return
		end
	elseif my_data.advance_path and not my_data.objective_outdated and not my_data.desynced_from_pathing then

		CopLogicTravel._chk_begin_advance(data, my_data)

		if my_data.coarse_path_index and my_data.advancing and my_data.path_ahead then
			CopLogicTravel._check_start_path_ahead(data)
		end
	elseif my_data.processing_advance_path or my_data.processing_coarse_path then
		CopLogicTravel._upd_pathing(data, my_data)

		if my_data ~= data.internal_data then
			return
		end
	elseif objective and objective.nav_seg or objective and objective.type == "follow" then
		if my_data.coarse_path then
			if my_data.coarse_path_index == #my_data.coarse_path then
				CopLogicTravel._on_destination_reached(data)
				
				return
			else
				CopLogicTravel._chk_start_pathing_to_next_nav_point(data, my_data)
			end
		else
			CopLogicTravel._begin_coarse_pathing(data, my_data)
		end
	else
		CopLogicBase._exit(data.unit, "idle")

		return
	end
end

function CopLogicTravel._chk_request_action_turn_to_cover(data, my_data)
	local fwd = data.unit:movement():m_rot():y()

	mvec3_set(tmp_vec1, my_data.best_cover[1][2])
	mvec3_neg(tmp_vec1)

	local error_spin = tmp_vec1:to_polar_with_reference(fwd, math.UP).spin

	if math.abs(error_spin) > 25 then
		local speed = 1.25
	
		if data.team and data.team.id == tweak_data.levels:get_default_team_ID("player") or data.is_converted or data.unit:in_slot(16) or data.unit:in_slot(managers.slot:get_mask("criminals")) then
			speed = 2
		elseif data.unit:base():has_tag("law") then
			local difficulty_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)

			if managers.modifiers and managers.modifiers:check_boolean("TotalAnarchy") or difficulty_index == 8 then
				speed = 1.75
			elseif difficulty_index == 6 or difficulty_index == 7 then
				speed = 1.5
			end
		end

		local new_action_data = {
			type = "turn",
			body_part = 2,
			angle = error_spin,
			speed = speed
		}
		my_data.turning = data.unit:brain():action_request(new_action_data)

		if my_data.turning then
			return true
		end
	end
end


function CopLogicTravel._chk_stop_for_follow_unit(data, my_data)
	local objective = data.objective

	if objective.type ~= "follow" or data.unit:movement():chk_action_forbidden("walk") or data.unit:anim_data().act_idle then
		return
	end

	if not my_data.coarse_path_index then
		debug_pause_unit(data.unit, "[CopLogicTravel._chk_stop_for_follow_unit]", data.unit, inspect(data), inspect(my_data))

		return
	end

	local follow_unit_nav_seg = data.objective.follow_unit:movement():nav_tracker():nav_segment()
	
	if not follow_unit_nav_seg or not my_data.coarse_path or not my_data.coarse_path_index or not my_data.coarse_path[my_data.coarse_path_index + 1] or not my_data.coarse_path[my_data.coarse_path_index + 1][1] then 
		--log("FUCKINGAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA")
		return
	end

	if my_data.coarse_path[my_data.coarse_path_index + 1] and follow_unit_nav_seg ~= my_data.coarse_path[my_data.coarse_path_index + 1][1] or my_data.coarse_path_index ~= #my_data.coarse_path - 1 then
		local my_nav_seg = data.unit:movement():nav_tracker():nav_segment()

		if follow_unit_nav_seg == my_nav_seg then
			objective.in_place = true

			data.logic.on_new_objective(data)
		end
	end
end