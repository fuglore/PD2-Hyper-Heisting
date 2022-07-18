--local mvec3_x = mvector3.x
--local mvec3_y = mvector3.y
--local mvec3_z = mvector3.z
local pairs_g = pairs
local mvec3_set = mvector3.set
local mvec3_set_z = mvector3.set_z
local mvec3_sub = mvector3.subtract
local mvec3_dir = mvector3.direction
local mvec3_dot = mvector3.dot
local mvec3_dis = mvector3.distance
local mvec3_dis_sq = mvector3.distance_sq
local mvec3_lerp = mvector3.lerp
local mvec3_norm = mvector3.normalize
local mvec3_add = mvector3.add
local mvec3_mul = mvector3.multiply
--local mvec3_cross = mvector3.cross
--local mvec3_rand_ortho = mvector3.random_orthogonal
--local mvec3_negate = mvector3.negate
--local mvec3_len = mvector3.length
local mvec3_len_sq = mvector3.length_sq
local mvec3_cpy = mvector3.copy
--local mvec3_set_stat = mvector3.set_static
local mvec3_set_length = mvector3.set_length
--local mvec3_angle = mvector3.angle
local mvec3_step = mvector3.step
local mvec3_rotate_with = mvector3.rotate_with

local temp_vec1 = Vector3()
local temp_vec2 = Vector3()
local temp_vec3 = Vector3()

local math_lerp = math.lerp
local math_random = math.random
local math_up = math.UP
local math_abs = math.abs
local math_clamp = math.clamp
local math_min = math.min
local math_max = math.max
local math_sign = math.sign

local table_insert = table.insert

local clone_g = clone

local REACT_AIM = AIAttentionObject.REACT_AIM
local REACT_COMBAT = AIAttentionObject.REACT_COMBAT
local REACT_SHOOT = AIAttentionObject.REACT_SHOOT

function CopLogicAttack.enter(data, new_logic_name, enter_params)
	CopLogicBase.enter(data, new_logic_name, enter_params)
	data.brain:cancel_all_pathing_searches()

	local old_internal_data = data.internal_data
	local my_data = {
		unit = data.unit
	}
	my_data.detection = data.char_tweak.detection.combat

	if old_internal_data then
		my_data.turning = old_internal_data.turning
		my_data.firing = old_internal_data.firing
		my_data.shooting = old_internal_data.shooting
		my_data.attention_unit = old_internal_data.attention_unit
		my_data.advancing = old_internal_data.advancing

		CopLogicAttack._set_best_cover(data, my_data, old_internal_data.best_cover)
	end

	data.internal_data = my_data

	if data.cool then
		data.unit:movement():set_cool(false)

		if my_data ~= data.internal_data then
			return
		end
	end

	local objective = data.objective

	if not my_data.shooting then
		local new_stance = objective and objective.stance ~= "ntl" and objective.stance or "hos"

		if data.char_tweak.allowed_stances and not data.char_tweak.allowed_stances[new_stance] then
			if new_stance ~= "hos" and data.char_tweak.allowed_stances.hos then
				new_stance = "hos"
			elseif new_stance ~= "cbt" and data.char_tweak.allowed_stances.cbt then
				new_stance = "cbt"
			else
				new_stance = nil
			end
		end

		if new_stance then
			data.unit:movement():set_stance(new_stance)

			if my_data ~= data.internal_data then
				return
			end
		end
	end

	my_data.cover_test_step = 1

	CopLogicIdle._chk_has_old_action(data, my_data)

	local key_str = tostring(data.key)
	my_data.detection_task_key = "CopLogicAttack._upd_enemy_detection" .. key_str

	if data.unit:base():has_tag("medic") then
		my_data.attitude = "avoid"
	else
		my_data.attitude = objective and objective.attitude or "avoid"
	end
	my_data.weapon_range = clone_g(data.char_tweak.weapon[data.unit:inventory():equipped_unit():base():weapon_tweak_data().usage].range)
	
	if data.tactics then
		if data.tactics.ranged_fire or data.tactics.elite_ranged_fire then
			
			if my_data.weapon_range.aggressive then
				my_data.weapon_range.aggressive = my_data.weapon_range.aggressive * 1.5
			end
			
			my_data.weapon_range.close = my_data.weapon_range.close * 2
			my_data.weapon_range.optimal = my_data.weapon_range.optimal * 1.5
		end
	end
	
	CopLogicAttack._upd_enemy_detection(data)
	
	if my_data ~= data.internal_data then
		return
	end

	if objective then
		if objective.action_duration or objective.action_timeout_t and data.t < objective.action_timeout_t then
			my_data.action_timeout_clbk_id = "CopLogicIdle_action_timeout" .. key_str
			local action_timeout_t = objective.action_timeout_t or data.t + objective.action_duration
			objective.action_timeout_t = action_timeout_t

			CopLogicBase.add_delayed_clbk(my_data, my_data.action_timeout_clbk_id, callback(CopLogicIdle, CopLogicIdle, "clbk_action_timeout", data), action_timeout_t)
		end
	end
	
	if data.unit:base():has_tag("special") then
		my_data.use_brain = true
	end

	data.brain:set_attention_settings({
		cbt = true
	})
	data.brain:set_update_enabled_state(true)
end

function CopLogicAttack.exit(data, new_logic_name, enter_params)
	CopLogicBase.exit(data, new_logic_name, enter_params)

	local my_data = data.internal_data
	
	TaserLogicAttack._cancel_tase_attempt(data, my_data)
	data.brain:cancel_all_pathing_searches()
	CopLogicBase.cancel_queued_tasks(my_data)
	CopLogicBase.cancel_delayed_clbks(my_data)

	if my_data.best_cover then
		managers.navigation:release_cover(my_data.best_cover[1])
	end

	data.brain:rem_pos_rsrv("path")
	data.brain:set_update_enabled_state(true)
end

function CopLogicAttack.on_importance(data)
	CopLogicBase.on_importance(data)
	
	if data.name == "attack" then
		if not data.internal_data.exiting then
			local my_data = data.internal_data
			
			if data.attention_obj and REACT_COMBAT <= data.attention_obj.reaction then
				my_data.want_to_take_cover = CopLogicAttack._chk_wants_to_take_cover(data, my_data)
				CopLogicAttack._update_cover(data)
				data.logic._upd_combat_movement(data)
			end
			
			data.logic._upd_aim(data, my_data)
		end
	end
end

function CopLogicAttack.update(data)
	local my_data = data.internal_data

	if not my_data.update_queue_id then
		data.t = TimerManager:game():time()
	end

	if my_data.has_old_action then
		CopLogicAttack._upd_stop_old_action(data, my_data)

		if my_data.has_old_action then
			if not my_data.use_brain and not my_data.update_queue_id then
				data.brain:set_update_enabled_state(false)

				my_data.update_queue_id = "CopLogicAttack.queued_update" .. tostring(data.key)

				CopLogicAttack.queue_update(data, my_data)
			end

			return
		end
	end

	local groupai = managers.groupai:state()
	
	if data.is_converted or data.check_crim_jobless or data.team.id == "criminal1" then
		if not data.objective or data.objective.type == "free" then
			if not data.path_fail_t or data.t - data.path_fail_t > 6 then
				groupai:on_criminal_jobless(data.unit)

				if my_data ~= data.internal_data then
					return
				end
			end
		end
	end

	if CopLogicIdle._chk_relocate(data) or CopLogicAttack._chk_exit_non_walkable_area(data) then
		return
	end

	if not data.attention_obj or data.attention_obj.reaction < REACT_AIM then
		CopLogicAttack._upd_enemy_detection(data, true)

		if my_data ~= data.internal_data then
			return
		end
	end

	CopLogicAttack._process_pathing_results(data, my_data)
	
	if not my_data.tasing then
		CopLogicAttack._chk_chatter_and_movement(data, my_data)
	end

	if not my_data.use_brain and not my_data.update_queue_id then
		data.brain:set_update_enabled_state(false)

		my_data.update_queue_id = "CopLogicAttack.queued_update" .. tostring(data.key)

		CopLogicAttack.queue_update(data, my_data)
	end
end

function CopLogicAttack._chk_dodge(data, my_data)
	local my_data = data.internal_data
	local t = data.t
	local unit = data.unit
	local focus_enemy = data.attention_obj
	local action_taken = nil
	
	if not focus_enemy then
		return
	end

	if not focus_enemy.verified and not my_data.turning and CopLogicAttack._can_move(data) and not unit:movement():chk_action_forbidden("walk") then
		if data.is_suppressed and t - unit:character_damage():last_suppression_t() < 0.7 then
			action_taken = CopLogicBase.chk_start_action_dodge(data, "scared")
		end

		if not action_taken and focus_enemy.is_person and focus_enemy.aimed_at and focus_enemy.dis < 2000 then
			local dodge = nil

			if focus_enemy.is_local_player then
				local e_movement_state = focus_enemy.unit:movement():current_state()

				if not e_movement_state:_is_reloading() and not e_movement_state:_interacting() and not e_movement_state:is_equipping() then
					dodge = true
				end
			else
				local e_anim_data = focus_enemy.unit:anim_data()

				if not e_anim_data.reload then
					if e_anim_data.move or e_anim_data.idle then
						dodge = true
					end
				end
			end

			if dodge then
				action_taken = CopLogicBase.chk_start_action_dodge(data, "preemptive")
			end
		end
	end
	
	return action_taken
end

function CopLogicAttack._chk_chatter_and_movement(data, my_data)
	CopLogicAttack.check_chatter(data, my_data, data.objective)
	
	local action_taken = CopLogicAttack._chk_dodge(data, my_data) or data.logic.action_taken(data, my_data)
	
	if not action_taken then
		action_taken = CopLogicAttack._move_back_into_field_position(data, my_data)
	end
	
	if not action_taken then
		action_taken = CopLogicAttack._chk_start_action_move_out_of_the_way(data, my_data)
	end
	
	action_taken = action_taken or CopLogicAttack._upd_pose(data, my_data)

	if data.attention_obj and REACT_COMBAT <= data.attention_obj.reaction then
		if not data.unit:base():has_tag("medic") then
			my_data.attitude = data.objective and data.objective.attitude or "avoid"
		end
		
		my_data.want_to_take_cover = CopLogicAttack._chk_wants_to_take_cover(data, my_data)

		CopLogicAttack._update_cover(data)
		
		--[[uncomment to draw cover stuff or whatever
		
		if my_data.moving_to_cover then
			local height = my_data.best_cover[4] and 165 or 82.5
			local line = Draw:brush(Color.blue:with_alpha(0.5), 0.2)
			line:cylinder(data.m_pos, my_data.moving_to_cover[1][1], 5)
			line:cylinder(my_data.moving_to_cover[1][1], my_data.moving_to_cover[1][1] + math_up * height, 5)
		elseif my_data.best_cover then
			local height = my_data.best_cover[4] and 165 or 82.5
			local line = Draw:brush(Color.green:with_alpha(0.5), 0.2)
			line:cylinder(data.m_pos, my_data.best_cover[1][1], 5)
			line:cylinder(my_data.best_cover[1][1], my_data.best_cover[1][1] + math_up * height, 5)
		end
			
		if my_data.in_cover then
			local height = my_data.best_cover[4] and 165 or 82.5
			local line = Draw:brush(Color.red:with_alpha(0.5), 0.2)
			line:cylinder(my_data.best_cover[1][1], my_data.best_cover[1][1] + math_up * height, 100)
		end]]
		
		if not action_taken then
			action_taken = CopLogicAttack._upd_combat_movement(data)
		end
	end
end

function CopLogicAttack._warp_to_pos(data, my_data, pos)
	CopLogicAttack._cancel_cover_pathing(data, my_data)
	CopLogicAttack._cancel_charge(data, my_data)
	
	local new_action_data = {
		body_part = 1,
		type = "warp",
		position = mvec3_cpy(pos)
	}
	
	if data.brain:action_request(new_action_data) then
		return true
	end
end

function CopLogicAttack._move_back_into_field_position(data, my_data)
	local my_tracker = data.unit:movement():nav_tracker()
	
	if my_tracker:lost() then
		local field_position = my_tracker:field_position()
		
		if mvec3_dis_sq(data.m_pos, field_position) > 3600 then	
			return CopLogicAttack._warp_to_pos(data, my_data, field_position)
		end
	end
end

function CopLogicAttack._find_group_medic_pos(data)
	if not data.group then
		return
	end

	if data.unit:base():has_tag("medic") then
		return
	end

	local my_pos = data.m_pos
	local best_pos, best_dis

	for u_key, u_data in pairs_g(data.group.units) do
		if u_key ~= data.key then
			if u_data.unit:base().has_tag and u_data.unit:base():has_tag("medic") then
				local follow_unit = u_data.unit
				local follow_tracker = follow_unit:movement():nav_tracker()
				local advance_pos = follow_unit:brain() and follow_unit:brain():is_advancing()
				local follow_unit_pos = advance_pos or follow_tracker:field_position()
				local dis = mvec3_dis_sq(my_pos, follow_unit_pos)

				if not best_dis or dis < best_dis then
					best_pos = follow_unit_pos
					best_dis = dis
				end
			end
		end
	end

	if best_pos then
		best_pos = CopLogicTravel._find_near_free_pos(best_pos, 400, nil, data.pos_rsrv_id)

		return best_pos
	end
end

function CopLogicAttack._find_group_shield_pos(data, focus_enemy)
	if not data.group then
		return
	end
	
	if data.unit:base():has_tag("shield") then
		return
	end

	local my_pos = data.m_pos
	local best_dis, best_pos

	for u_key, u_data in pairs_g(data.group.units) do
		if u_key ~= data.key then
			if u_data.unit:base().has_tag and u_data.unit:base():has_tag("shield") then
				local follow_unit = u_data.unit
				local follow_tracker = follow_unit:movement():nav_tracker()
				local advance_pos = follow_unit:brain() and follow_unit:brain():is_advancing()
				local follow_unit_pos = advance_pos or follow_tracker:field_position()
				local dis = mvec3_dis_sq(my_pos, follow_unit_pos)

				if not best_dis or dis < best_dis then
					best_dis = dis
					best_pos = follow_unit_pos
				end
			end
		end
	end

	if best_pos then
		local threat_pos = focus_enemy.m_pos
		local threat_head_pos = focus_enemy.m_head_pos
		local threat_tracker = focus_enemy.nav_tracker
		
		local retreat_pos = CopLogicAttack._find_retreat_position(data, best_pos, threat_pos, threat_head_pos, threat_tracker, 200, nil, "crouch")
		
		if retreat_pos then
			return retreat_pos
		end
	end
end

function CopLogicAttack._find_friend_pos(data, focus_enemy)
	local my_pos = data.m_pos
	local friend_pos = nil
	
	if not data.group then
		return
	end
	
	if not data.unit:base():has_tag("law") or data.is_converted then
		return
	end
	
	local found_friend_pos = nil
	
	friend_pos = CopLogicAttack._find_group_medic_pos(data)

	if not friend_pos then
		friend_pos = CopLogicAttack._find_group_shield_pos(data, focus_enemy)
	end
	
	if not friend_pos then
		return
	end
	
	return friend_pos
end

function CopLogicAttack._upd_combat_movement(data)
	local my_data = data.internal_data
	local t = data.t
	local unit = data.unit
	local focus_enemy = data.attention_obj
	local action_taken = nil
	local want_to_take_cover = my_data.want_to_take_cover
	
	action_taken = action_taken or data.logic.action_taken(data, my_data)
	
	if not my_data.failed_to_find_cover then
		if want_to_take_cover then
			my_data.friend_pos = CopLogicAttack._find_friend_pos(data, focus_enemy)
			
			if my_data.friend_pos and data.important then
				CopLogicAttack._update_cover(data)
			end
		elseif my_data.friend_pos then
			my_data.friend_pos = nil
			
			if data.important then
				CopLogicAttack._update_cover(data)
			end
		end
	elseif my_data.friend_pos then
		my_data.friend_pos = nil
		
		if data.important then
			CopLogicAttack._update_cover(data)
		end
	end
	
	local tactics = data.tactics
	local engage_range = my_data.weapon_range.aggressive or my_data.weapon_range.close
	local soft_t = 2
	local softer_t = 7

	local enemy_visible_soft = focus_enemy.verified_t and t - focus_enemy.verified_t < soft_t
	local enemy_visible_softer = focus_enemy.verified_t and t - focus_enemy.verified_t < softer_t

	if my_data.cover_test_step ~= 1 and not enemy_visible_softer then
		if action_taken or want_to_take_cover or not my_data.in_cover then
			my_data.cover_test_step = 1
		end
	end

	local remove_stay_out_time = nil

	if my_data.stay_out_time then
		if not my_data.charging and enemy_visible_soft or not my_data.at_cover_shoot_pos and not my_data.walking_to_cover_shoot_pos or want_to_take_cover then
			remove_stay_out_time = true
		end
	end

	if remove_stay_out_time then
		my_data.stay_out_time = nil
		my_data.charging = nil
	elseif my_data.attitude == "engage" then
		my_data.stay_out_time = t + softer_t
	end

	local move_to_cover = nil
	local valid_harass = nil
	
	if tactics and tactics.harass then		
		if not data.unit:in_slot(16) and not data.is_converted and focus_enemy.is_person then
			if focus_enemy.is_local_player then
				local e_movement_state = focus_enemy.unit:movement():current_state()
							
				if e_movement_state:_is_reloading() then
					valid_harass = true
				end
			else
				local e_anim_data = focus_enemy.unit:anim_data()

				if e_anim_data.reload then
					valid_harass = true
				end
			end
		end
					
		if valid_harass then
			managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "reload")
		end
	end

	local in_cover = my_data.in_cover
	local best_cover = my_data.best_cover
	local want_flank_cover = my_data.flank_cover and not my_data.flank_cover.failed

	if not action_taken then
		if not action_taken and my_data.attitude == "engage" then
			if my_data.charge_path then
				local path = my_data.charge_path
				my_data.charge_path = nil
				my_data.charging = not tactics or not tactics.hitnrun
				my_data.flank_cover = nil

				action_taken = CopLogicAttack._chk_request_action_walk_to_cover_shoot_pos(data, my_data, path, "run")
			end
		else
			my_data.charge_path = nil
		end
		
		if my_data.attitude ~= "engage" and not in_cover then
			move_to_cover = true
		elseif not my_data.flank_cover or not my_data.flank_cover.failed then
			if my_data.at_cover_shoot_pos then
				if not my_data.stay_out_time or my_data.stay_out_time < t then
					if want_to_take_cover then
						move_to_cover = true
					end
					
					if my_data.cover_test_step > 2 or math_random() < 0.5 then
						want_flank_cover = true
					end
				end
			elseif best_cover and in_cover and not enemy_visible_soft then
				if my_data.attitude == "engage" then
					if my_data.cover_test_step <= 2 then
						local height = nil

						if best_cover[4] then --has obstructed high_ray
							height = 165
						else
							height = 82.5
						end

						local my_tracker = unit:movement():nav_tracker()
						local shoot_from_pos = CopLogicAttack._peek_for_pos_sideways(data, my_data, my_tracker, focus_enemy.m_head_pos, height)

						if shoot_from_pos then
							local path = {
								mvec3_cpy(data.m_pos),
								shoot_from_pos
							}
							action_taken = CopLogicAttack._chk_request_action_walk_to_cover_shoot_pos(data, my_data, path, "walk")
						else
							my_data.cover_test_step = my_data.cover_test_step + 1
							
							if my_data.cover_test_step > 2 then
								want_flank_cover = true
							end
						end
					else
						want_flank_cover = true
					end
				end
			elseif best_cover and want_to_take_cover and not in_cover then
				move_to_cover = true
			end
		end

		if want_flank_cover or tactics and data.tactics.flank then
			if not my_data.flank_cover then
				local sign = math_random() < 0.5 and -1 or 1
				local step = 30
				my_data.flank_cover = {
					step = step,
					angle = step * sign,
					sign = sign
				}
			end
		else
			my_data.flank_cover = nil
		end
		
		if not action_taken and not move_to_cover and not want_to_take_cover and my_data.attitude == "engage" then
			if not data.is_converted and my_data.flank_cover and my_data.flank_cover.failed then
				if data.important or not my_data.charge_path_failed_t or t - my_data.charge_path_failed_t > 2 then --not gonna bother renaming and adding stuff to be used as flank_path as well, so I'm sharing the name even though they're kinda different
					if not my_data.charge_path_search_id and focus_enemy.nav_tracker then
						my_data.charge_pos = CopLogicAttack._find_flank_pos(data, my_data, focus_enemy.nav_tracker, my_data.weapon_range.optimal) --charge to a position that would put the unit in a flanking position, not really a flanking path

						if my_data.charge_pos then
							local my_pos = data.unit:movement():nav_tracker():field_position()
							local unobstructed_line = CopLogicTravel._check_path_is_straight_line(my_pos, my_data.charge_pos, data)

							if unobstructed_line then
								local path = {
									mvec3_cpy(my_pos),
									my_data.charge_pos
								}

								--[[local line = Draw:brush(Color.blue:with_alpha(0.5), 5)
								line:cylinder(my_pos, my_data.charge_pos, 25)]]
								
								my_data.charging = not tactics or not tactics.hitnrun
								my_data.flank_cover = nil

								action_taken = CopLogicAttack._chk_request_action_walk_to_cover_shoot_pos(data, my_data, path, "run")
							else
								data.brain:add_pos_rsrv("path", {
									radius = 60,
									position = mvec3_cpy(my_data.charge_pos)
								})

								my_data.charge_path_search_id = "charge" .. tostring(data.key)

								data.brain:search_for_path(my_data.charge_path_search_id, my_data.charge_pos, nil, nil, nil)
							end
						else
							--debug_pause_unit(unit, "failed to find charge_pos", unit)

							want_flank_cover = nil
							my_data.charge_path_failed_t = t
						end
					end
				end
			end
			
			local can_charge = not tactics or not tactics.ranged_fire and not tactics.elite_ranged_fire
			
			if can_charge or valid_harass then
				if data.important or not my_data.charge_path_failed_t or t - my_data.charge_path_failed_t > 2 then
					if not my_data.charge_path_search_id and focus_enemy.nav_tracker then
						if not tactics or tactics.flank then
							my_data.charge_pos = CopLogicAttack._find_flank_pos(data, my_data, focus_enemy.nav_tracker, engage_range) --charge to a position that would put the unit in a flanking position, not a flanking path
						else
							my_data.charge_pos = CopLogicTravel._get_pos_on_wall(focus_enemy.nav_tracker:field_position(), engage_range, 45, nil, data.pos_rsrv_id)
						end

						--my_data.charge_pos = CopLogicTravel._get_pos_on_wall(focus_enemy.nav_tracker:field_position(), my_data.weapon_range.optimal, 45, nil, data.pos_rsrv_id)

						if my_data.charge_pos then
							local my_pos = data.unit:movement():nav_tracker():field_position()
							local unobstructed_line = CopLogicTravel._check_path_is_straight_line(my_pos, my_data.charge_pos, data)

							if unobstructed_line then
								local path = {
									mvec3_cpy(my_pos),
									my_data.charge_pos
								}
								
								my_data.charging = not tactics or not tactics.hitnrun
								
								--[[local line = Draw:brush(Color.blue:with_alpha(0.5), 5)
								line:cylinder(my_pos, my_data.charge_pos, 25)]]

								action_taken = CopLogicAttack._chk_request_action_walk_to_cover_shoot_pos(data, my_data, path, "run")
							else
								data.brain:add_pos_rsrv("path", {
									radius = 60,
									position = mvec3_cpy(my_data.charge_pos)
								})

								my_data.charge_path_search_id = "charge" .. tostring(data.key)

								data.brain:search_for_path(my_data.charge_path_search_id, my_data.charge_pos, nil, nil, nil)
							end
						else
							--debug_pause_unit(unit, "failed to find charge_pos", unit)

							my_data.charge_path_failed_t = t
						end
					end
				end
			end
		end
	end
	
	if not action_taken and not in_cover and move_to_cover then
		if not data.spooc_warped and data.spooc_attack_timeout_t then
			data.spooc_warped = true
			local to_cover_pos = my_data.best_cover[1][1]
			action_taken = CopLogicAttack._warp_to_pos(data, my_data, to_cover_pos)
		elseif my_data.cover_path then
			action_taken = CopLogicAttack._chk_request_action_walk_to_cover(data, my_data)
		end
	end

	if not action_taken then
		if data.important or not my_data.cover_path_failed_t or t - my_data.cover_path_failed_t > 2 then
			local best_cover = my_data.best_cover

			if best_cover and not my_data.processing_cover_path and not my_data.charge_path_search_id then
				if not in_cover then
					CopLogicAttack._cancel_cover_pathing(data, my_data)

					local my_pos = data.unit:movement():nav_tracker():field_position()
					local to_cover_pos = my_data.best_cover[1][1]
					local unobstructed_line = CopLogicTravel._check_path_is_straight_line(my_pos, to_cover_pos, data)

					if unobstructed_line then
						local path = {
							mvec3_cpy(my_pos),
							mvec3_cpy(to_cover_pos)
						}
						
						my_data.cover_path = path
						
						if move_to_cover then
							action_taken = CopLogicAttack._chk_request_action_walk_to_cover(data, my_data)
						end
					else
						data.brain:add_pos_rsrv("path", {
							radius = 60,
							position = mvec3_cpy(my_data.best_cover[1][1])
						})

						my_data.cover_path_search_id = tostring(data.key) .. "cover"
						my_data.processing_cover_path = best_cover

						data.brain:search_for_path_to_cover(my_data.cover_path_search_id, best_cover[1])
					end
				end
			end
		end
	end
	
	if not action_taken and want_to_take_cover and not best_cover then
		action_taken = CopLogicAttack._chk_start_action_move_back(data, my_data, focus_enemy, my_data.attitude == "engage" and not data.is_suppressed)
	end
	
	return action_taken
end

function CopLogicAttack._chk_start_action_move_back(data, my_data, focus_enemy, vis_required)
	if not focus_enemy or not focus_enemy.verified or not CopLogicAttack._can_move(data) then
		return
	end

	local attempt_retreat = nil
	local bigger_retreat = my_data.want_to_take_cover == "reload" or my_data.want_to_take_cover == "low_ammo" or  my_data.want_to_take_cover == "eliterangedfire"

	if bigger_retreat then
		if focus_enemy.dis < 1000 then
			attempt_retreat = true
			vis_required = nil
		end
	elseif focus_enemy.dis < 250 then
		attempt_retreat = true
	end

	if not attempt_retreat then
		return
	end

	local threat_tracker = focus_enemy.nav_tracker
	local temp_tracker = nil

	if vis_required and not threat_tracker then --this shouldn't even happen, but just in case, we want the unit to still be able to retreat
		local tracker_pos = mvec3_cpy(focus_enemy.m_pos)
		threat_tracker = managers.navigation:create_nav_tracker(tracker_pos)
		temp_tracker = true
	end

	local from_pos = mvec3_cpy(data.m_pos)
	local threat_head_pos = focus_enemy.m_head_pos
	local max_walk_dis = reloading_or_low_ammo and 800 or 400
	local pose = data.is_suppressed and "crouch" or "stand"
	local end_pose = pose

	if pose == "crouch" and not data.char_tweak.crouch_move then
		pose = "stand"
	end

	if data.char_tweak.allowed_poses then
		if not data.char_tweak.allowed_poses.crouch then
			pose = "stand"
			end_pose = "stand"
		elseif not data.char_tweak.allowed_poses.stand then
			pose = "crouch"
			end_pose = "crouch"
		end
	end

	local retreat_to = CopLogicAttack._find_retreat_position(data, from_pos, focus_enemy.m_pos, threat_head_pos, threat_tracker, max_walk_dis, vis_required, end_pose)

	if retreat_to and mvec3_dis_sq(from_pos, retreat_to) > 10000 then
		CopLogicAttack._cancel_cover_pathing(data, my_data)

		local new_action_data = {
			variant = reloading_or_low_ammo and "run" or "walk",
			body_part = 2,
			type = "walk",
			nav_path = {
				from_pos,
				retreat_to
			},
			pose = pose,
			end_pose = end_pose
		}
		my_data.advancing = data.brain:action_request(new_action_data)

		if my_data.advancing then
			my_data.at_cover_shoot_pos = nil
			my_data.surprised = true

			data.brain:rem_pos_rsrv("path")

			if temp_tracker then
				managers.navigation:destroy_nav_tracker(threat_tracker)
			end

			return true
		end
	end

	if temp_tracker then
		managers.navigation:destroy_nav_tracker(threat_tracker)
	end
end

function CopLogicAttack._chk_start_action_move_out_of_the_way(data, my_data)
	local reservation = {
		radius = 30,
		position = data.m_pos,
		filter = data.pos_rsrv_id
	}

	if not managers.navigation:is_pos_free(reservation) then
		local to_pos = CopLogicTravel._find_near_free_pos(data.m_pos, 500, nil, data.pos_rsrv_id)

		if to_pos then
			local path = {
				mvec3_cpy(data.m_pos),
				to_pos
			}

			return CopLogicAttack._chk_request_action_walk_to_cover_shoot_pos(data, my_data, path, "run")
		end
	end
end

function CopLogicAttack.check_chatter(data, my_data, objective)
	if not objective then
		return
	end
	
	if data.is_converted then
		return
	end
	
	if data.cool then
		return
	end
	
	if managers.groupai:state():whisper_mode() then
		if my_data.firing then
			managers.groupai:state():chk_say_enemy_standardized_chatter(data.unit, data.m_pos, "lk3b", "controlidle")
		end
		
		
		return
	end
	
	if data.char_tweak.chatter.cloakergeneral then
		if not data.cloakertauntvc then
			local ai_type = tweak_data.levels:get_ai_group_type()
			local level_types = LevelsTweakData.LevelType
			local r = level_types.Russia
			local f = level_types.Federales

			if ai_type == r then
				data.cloakertauntvc = "rcloaker_taunt_during_assault"
			elseif ai_type == f then
				data.cloakertauntvc = "mcloaker_taunt_during_assault"
			else
				data.cloakertauntvc = "cloaker_taunt_during_assault"
			end
		end
	
		if data.attention_obj and not data.attention_obj.verified and REACT_SHOOT <= data.attention_obj.reaction and data.attention_obj.dis < 1200 then
			if data.spooc_attack_timeout_t and data.spooc_attack_timeout_t > data.t and data.attention_obj.verified_t and data.t - data.attention_obj.verified_t > 2 then
				local dmg_ext = data.attention_obj.unit:character_damage()
				
				if dmg_ext.health_ratio and dmg_ext:health_ratio() < 0.6 then
					if managers.groupai:state():register_chatter_event(data.unit, data.m_pos, "cloakergeneral") then
						data.unit:sound():say(data.cloakertauntvc, true, true)
					end
				end
			end
		end
		
		return
	end
	
	if data.char_tweak.chatter.imamedicionlyhaveliketwovoicelineshaha then
		if data.attention_obj and REACT_SHOOT <= data.attention_obj.reaction then
			if data.attention_obj.verified_t and data.t - data.attention_obj.verified_t < 15 then
				managers.groupai:state():chk_say_enemy_standardized_chatter(data.unit, data.m_pos, "g90", "medicgeneral")
			end
		end
		
		return
	end
	
	if data.char_tweak.chatter.tasergeneral then
		managers.groupai:state():chk_say_enemy_standardized_chatter(data.unit, data.m_pos, "g90", "tasergeneral")
		
		return
	end
	
	if not data.char_tweak.chatter.idlechatter then
		return
	end
	
	local chosen_panic_chatter = "g90" --set default generic chatter
	local assault_active =  managers.groupai:state():chk_assault_active_atm() 
	local panic_chatter_qualify = managers.groupai:state():_check_assault_panic_chatter() 
	local attention_obj_qualify = data.attention_obj and REACT_SHOOT <= data.attention_obj.reaction 
	
	if attention_obj_qualify then
		if my_data.firing then
			--nothing
		elseif data.attention_obj.verified_t then
			attention_obj_qualify = data.t - data.attention_obj.verified_t < 15
		else
			attention_obj_qualify = nil
		end
	end
	
	local hostage_count = not assault_active and managers.groupai:state():get_hostage_count_for_chatter() or 0 --check current hostage count

	if hostage_count > 0 then --make sure the hostage count is actually above zero before replacing any of the lines
		if hostage_count > 3 then 
			if math_random() > 0.4 then --40% chance for regular panic if hostages are present
				chosen_panic_chatter = "p02" --more panicky "GET THOSE HOSTAGES OUT RIGHT NOW!!!" line for when theres too many hostages on the map
			end
		else
			if math_random() > 0.6 then
				chosen_panic_chatter = "p01" --less panicky "Delay the assault until those hostages are out." line
			end
		end

		if managers.groupai:state():chk_has_civilian_hostages() then
			--log("they got sausages!")
			if math_random() < 0.5 then
				chosen_panic_chatter = chosen_panic_chatter
			else
				chosen_panic_chatter = "bak"
			end
		end
	elseif managers.groupai:state():chk_had_hostages() then
		if math_random() > 0.4 then
			chosen_panic_chatter = "p03" -- no more hostages!!! full force!!!
		end
	end
	
	if assault_active then
		if panic_chatter_qualify then
			if attention_obj_qualify then
				local ask_for_help = data.is_suppressed or my_data.want_to_take_cover
				
				if ask_for_help then
					if math_random() > 0.75 then
						if math_random() < 0.5 then
							chosen_panic_chatter = "hlp"
						else
							chosen_panic_chatter = "lk3b"
						end
					end
				end
				
				if ask_for_help and math_random() > 0.9 or math_random() > 0.75 then
					if my_data.flank_cover then
						managers.groupai:state():chk_say_enemy_standardized_chatter(data.unit, data.m_pos, "t01", "assaultidle")
					elseif objective.grp_objective and objective.grp_objective.open_fire and my_data.firing then
						managers.groupai:state():chk_say_enemy_standardized_chatter(data.unit, data.m_pos, "att", "assaultidle")
					end
				else
					managers.groupai:state():chk_say_enemy_standardized_chatter(data.unit, data.m_pos, chosen_panic_chatter, "assaultidle")
				end
			elseif not objective.in_place then
				managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "clear")
			else
				managers.groupai:state():chk_say_enemy_standardized_chatter(data.unit, data.m_pos, chosen_panic_chatter, "assaultidle")
			end
		else
			if my_data.flank_cover and math_random() > 0.6 then
				managers.groupai:state():chk_say_enemy_standardized_chatter(data.unit, data.m_pos, "t01", "assaultidle")
			elseif objective.grp_objective and objective.grp_objective.open_fire and my_data.firing and math_random() < 0.5 then
				managers.groupai:state():chk_say_enemy_standardized_chatter(data.unit, data.m_pos, "att", "assaultidle")
			elseif objective.grp_objective and objective.grp_objective.moving_in then
				managers.groupai:state():chk_say_enemy_standardized_chatter(data.unit, data.m_pos, "pus", "assaultidle")
			end
		end
	else
		local chosen_sabotage_chatter = "e04"
		local skirmish_map = managers.skirmish:is_skirmish() --these shouldnt play on holdout
		local ignore_radio_rules = nil

		
		if objective and objective.hostagejob then
			--log("sausage removal squadron")
			chosen_sabotage_chatter = "civ"
			ignore_radio_rules = true 
		elseif objective and objective.bagjob then
			--log("oh, worm")
			chosen_sabotage_chatter = "l01"
			ignore_radio_rules = true
		end
		
		
		if not attention_obj_qualify then
			if math_random() > 0.75 then
				managers.groupai:state():chk_say_enemy_standardized_chatter(data.unit, data.m_pos, chosen_sabotage_chatter, "sabotage")
			elseif not objective.in_place and math_random() > 0.5 then
				managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "clear")
			else
				managers.groupai:state():chk_say_enemy_standardized_chatter(data.unit, data.m_pos, chosen_panic_chatter, "controlidle")
			end
		else
			if data.is_suppressed then
				if math_random() < 0.5 then
					if math_random() < 0.5 then
						managers.groupai:state():chk_say_enemy_standardized_chatter(data.unit, data.m_pos, "hlp", "controlidle")
					else
						managers.groupai:state():chk_say_enemy_standardized_chatter(data.unit, data.m_pos, "lk3b", "controlidle")
					end
				end
			else
				managers.groupai:state():chk_say_enemy_standardized_chatter(data.unit, data.m_pos, "att", "controlidle")
			end
		end
	end
end

function CopLogicAttack.queued_update(data)
	local my_data = data.internal_data
	data.t = TimerManager:game():time()

	CopLogicAttack.update(data)

	if data.internal_data == my_data then
		CopLogicAttack.queue_update(data, data.internal_data)
	end
end

function CopLogicAttack._peek_for_pos_sideways(data, my_data, my_tracker, peek_to_pos, height)
	local unit = data.unit
	local enemy_pos = peek_to_pos
	local my_pos = unit:movement():m_pos()
	local back_vec = my_pos - enemy_pos

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
	local shoot_from_pos = nil
	local ray_softness = 150
	local stand_ray = unit:raycast("ray", ray_params.trace[1] + math_up * height, enemy_pos, "slot_mask", data.visibility_slotmask, "ray_type", "ai_vision")

	if not stand_ray or mvec3_dis(stand_ray.position, enemy_pos) < ray_softness then
		local test_pos = ray_params.trace[1]
		local reservation = {
			radius = 30,
			position = test_pos,
			filter = data.pos_rsrv_id
		}

		if managers.navigation:is_pos_free(reservation) then
			shoot_from_pos = test_pos
		end
	end

	if not shoot_from_pos then
		local left_pos = back_pos - right_vec
		ray_params.pos_to = left_pos
		local ray_res = managers.navigation:raycast(ray_params)
		local stand_ray = unit:raycast("ray", ray_params.trace[1] + math_up * height, enemy_pos, "slot_mask", data.visibility_slotmask, "ray_type", "ai_vision")

		if not stand_ray or mvec3_dis(stand_ray.position, enemy_pos) < ray_softness then
			local test_pos = ray_params.trace[1]
			local reservation = {
				radius = 30,
				position = test_pos,
				filter = data.pos_rsrv_id
			}

			if managers.navigation:is_pos_free(reservation) then
				shoot_from_pos = test_pos
			end
		end
	end

	return shoot_from_pos
end

function CopLogicAttack._cancel_cover_pathing(data, my_data)
	if my_data.processing_cover_path then
		if data.active_searches[my_data.cover_path_search_id] then
			managers.navigation:cancel_pathing_search(my_data.cover_path_search_id)

			data.active_searches[my_data.cover_path_search_id] = nil
		elseif data.pathing_results then
			data.pathing_results[my_data.cover_path_search_id] = nil
		end

		my_data.processing_cover_path = nil
		my_data.cover_path_search_id = nil
	end

	my_data.cover_path = nil
end

function CopLogicAttack._cancel_charge(data, my_data)
	my_data.charge_pos = nil
	my_data.charge_path = nil

	if my_data.charge_path_search_id then
		if data.active_searches[my_data.charge_path_search_id] then
			managers.navigation:cancel_pathing_search(my_data.charge_path_search_id)

			data.active_searches[my_data.charge_path_search_id] = nil
		elseif data.pathing_results then
			data.pathing_results[my_data.charge_path_search_id] = nil
		end

		my_data.charge_path_search_id = nil
	end
end

function CopLogicAttack._cancel_expected_pos_path(data, my_data)
	my_data.expected_pos_path = nil

	if my_data.expected_pos_path_search_id then
		if data.active_searches[my_data.expected_pos_path_search_id] then
			managers.navigation:cancel_pathing_search(my_data.expected_pos_path_search_id)

			data.active_searches[my_data.expected_pos_path_search_id] = nil
		elseif data.pathing_results then
			data.pathing_results[my_data.expected_pos_path_search_id] = nil
		end

		my_data.expected_pos_path_search_id = nil
	end
end

function CopLogicAttack._chk_request_action_turn_to_enemy(data, my_data, my_pos, enemy_pos)
	local fwd = data.unit:movement():m_rot():y()
	local target_vec = enemy_pos - my_pos
	mvec3_set_z(target_vec, 0) --not really sure if this will be doing anything, but if my guess is right, z variations might be causing enemies to try to turn when they don't need to...? which would be weird
	local error_spin = target_vec:to_polar_with_reference(fwd, math_up).spin

	if math_abs(error_spin) > 27 then
		local new_action_data = {
			type = "turn",
			body_part = 2,
			angle = error_spin
		}
		my_data.turning = data.brain:action_request(new_action_data)

		if my_data.turning then
			return true
		end
	end
end

function CopLogicAttack._cancel_walking_to_cover(data, my_data, skip_action)
	my_data.cover_path = nil
	CopLogicAttack._set_best_cover(data, my_data, nil)

	if my_data.moving_to_cover then
		if not skip_action then
			local new_action = {
				body_part = 2,
				type = "idle"
			}

			data.brain:action_request(new_action)
		end
	elseif my_data.processing_cover_path then
		data.brain:cancel_all_pathing_searches()

		my_data.cover_path_search_id = nil
		my_data.processing_cover_path = nil
	end
end

function CopLogicAttack._chk_request_action_walk_to_cover(data, my_data)
	if not CopLogicAttack._can_move(data) then
		return
	end
	
	CopLogicAttack._correct_path_start_pos(data, my_data.cover_path)
	
	local haste = nil
	local pose = nil
	local i = 1
	local travel_dis = 0
	
	repeat
		if my_data.cover_path[i + 1] then
			travel_dis = travel_dis + mvec3_dis(my_data.cover_path[i], my_data.cover_path[i + 1])
			i = i + 1
		else
			break
		end
	until travel_dis > 400 or i >= #my_data.cover_path
	
	if travel_dis > 200 then
		haste = "run"
	end
	
	if travel_dis > 400 then
		pose = "stand"
	else
		pose = data.unit:anim_data().crouch and "crouch"
	end

	haste = haste or "walk"
	pose = pose or data.is_suppressed and "crouch" or "stand"

	local end_pose = not my_data.best_cover[4] and "crouch" or "stand"

	if pose == "crouch" and not data.char_tweak.crouch_move then
		pose = "stand"
	end

	if data.char_tweak.allowed_poses then
		if not data.char_tweak.allowed_poses.crouch then
			pose = "stand"
			end_pose = "stand"
		elseif not data.char_tweak.allowed_poses.stand then
			pose = "crouch"
			end_pose = "crouch"
		end
	end

	local new_action_data = {
		type = "walk",
		body_part = 2,
		nav_path = my_data.cover_path,
		variant = haste,
		pose = pose,
		end_pose = end_pose
	}
	my_data.cover_path = nil
	my_data.advancing = data.brain:action_request(new_action_data)

	if my_data.advancing then
		my_data.moving_to_cover = my_data.best_cover
		my_data.at_cover_shoot_pos = nil

		data.brain:rem_pos_rsrv("path")

		return true
	end
end

function CopLogicAttack._correct_path_start_pos(data, path)
	local first_nav_point = path[1]
	local my_pos = data.m_pos

	if first_nav_point.x ~= my_pos.x or first_nav_point.y ~= my_pos.y then
		table_insert(path, 1, mvec3_cpy(my_pos))
	end
end

function CopLogicAttack._chk_request_action_walk_to_cover_shoot_pos(data, my_data, path, speed)
	if not CopLogicAttack._can_move(data) then
		return
	end
	
	CopLogicAttack._cancel_cover_pathing(data, my_data)
	CopLogicAttack._cancel_charge(data, my_data)
	CopLogicAttack._correct_path_start_pos(data, path)

	local haste = nil
	local pose = nil
	local i = 1
	local travel_dis = 0
	local run_dis = 200
	local stand_dis = 400
	
	if data.unit:base().has_tag and data.unit:base():has_tag("tank") then
		run_dis = run_dis * 2
	end
	
	repeat
		if path[i + 1] then
			travel_dis = travel_dis + mvec3_dis(path[i], path[i + 1])
			i = i + 1
		else
			break
		end
	until travel_dis > stand_dis or i >= #path
	
	if travel_dis > run_dis then
		haste = "run"
	end
	
	if travel_dis > stand_dis then
		pose = "stand"
	else
		pose = data.unit:anim_data().crouch and "crouch"
	end

	haste = haste or "walk"
	pose = pose or data.is_suppressed and "crouch" or "stand"

	local end_pose = pose

	if pose == "crouch" and not data.char_tweak.crouch_move then
		pose = "stand"
	end

	if data.char_tweak.allowed_poses then
		if not data.char_tweak.allowed_poses.crouch then
			pose = "stand"
			end_pose = "stand"
		elseif not data.char_tweak.allowed_poses.stand then
			pose = "crouch"
			end_pose = "crouch"
		end
	end

	local new_action_data = {
		body_part = 2,
		type = "walk",
		nav_path = path,
		variant = speed or "walk",
		pose = pose,
		end_pose = end_pose
	}
	my_data.cover_path = nil
	my_data.advancing = data.brain:action_request(new_action_data)

	if my_data.advancing then
		my_data.walking_to_cover_shoot_pos = my_data.advancing
		my_data.at_cover_shoot_pos = nil
		--my_data.in_cover = nil

		data.brain:rem_pos_rsrv("path")

		return true
	end
end

function CopLogicAttack._upd_pose(data, my_data)
	local allowed_poses = data.char_tweak.allowed_poses
	
	if allowed_poses then
		if allowed_poses.stand then
			return CopLogicAttack._chk_request_action_stand(data)
		elseif allowed_poses.crouch then
			return CopLogicAttack._chk_request_action_crouch(data)
		end
	end
	
	if data.is_suppressed then
		return CopLogicAttack._chk_request_action_crouch(data)
	else
		local best_cover = my_data.best_cover
		local in_cover = my_data.in_cover
		
		if best_cover then
			if want_to_take_cover and in_cover and not best_cover[4] then
				return CopLogicAttack._chk_request_action_crouch(data)
			elseif best_cover[3] and my_data.cover_test_step > 2 then
				return CopLogicAttack._chk_request_action_stand(data)
			end
		end
	end
end

function CopLogicAttack._chk_request_action_crouch(data)
	if data.unit:anim_data().crouch or data.unit:movement():chk_action_forbidden("crouch") then
		return
	end

	local new_action_data = {
		body_part = 4,
		type = "crouch"
	}
	local res = data.brain:action_request(new_action_data)

	return res
end

function CopLogicAttack._chk_request_action_stand(data)
	if data.unit:anim_data().stand or data.unit:movement():chk_action_forbidden("stand") then
		return
	end

	local new_action_data = {
		body_part = 4,
		type = "stand"
	}
	local res = data.brain:action_request(new_action_data)

	return res
end

function CopLogicAttack._update_cover(data)
	local my_data = data.internal_data
	local best_cover = my_data.best_cover
	local satisfied = true --defined properly through the function, but currently unused
	local my_pos = nil

	if my_data.advancing then
		if data.pos_rsrv.move_dest then
			my_pos = data.pos_rsrv.move_dest.position
		else
			my_pos = my_data.advancing:get_walk_to_pos()
		end
	else
		my_pos = data.m_pos
	end
	
	local focus_enemy = data.attention_obj
	
	if focus_enemy and focus_enemy.nav_tracker and REACT_COMBAT <= focus_enemy.reaction then
		local find_new_cover = data.important or not my_data.cover_path_failed_t or data.t - my_data.cover_path_failed_t > 1

		if find_new_cover then
			if my_data.processing_cover_path or my_data.charge_path_search_id then
				find_new_cover = nil
			end
			
			if find_new_cover then
				find_new_cover = not best_cover or not best_cover[3]
			end
		end

		if find_new_cover then
			local weapon_ranges = my_data.weapon_range
			local threat_pos = focus_enemy.nav_tracker:field_position()
			
			if my_data.friend_pos then
				local near_pos = my_data.friend_pos
				
				if not best_cover or not CopLogicAttack._verify_follow_cover(best_cover, near_pos, threat_pos, nil, 400) then
					local nav_seg = managers.navigation:get_nav_seg_from_pos(near_pos)
					local area = managers.groupai:state():get_area_from_nav_seg_id(nav_seg)
					local dis = data.objective and data.objective.distance and data.objective.distance * 0.9 or 700
					local found_cover = managers.navigation:find_cover_in_nav_seg_3(area.nav_segs, dis, near_pos, threat_pos)

					if found_cover then
						local better_cover = {
							found_cover
						}

						--[[local offset_pos, yaw = CopLogicAttack._get_cover_offset_pos(data, better_cover, threat_pos)

						if offset_pos then
							better_cover[5] = offset_pos
							better_cover[6] = yaw
						end]]

						if data.char_tweak.wall_fwd_offset then
							better_cover[1][1] = CopLogicTravel.apply_wall_offset_to_cover(data, my_data, better_cover[1], data.char_tweak.wall_fwd_offset)
						end
						
						better_cover[3], better_cover[4] = CopLogicAttack._chk_covered(data, found_cover[1], focus_enemy.m_head_pos, data.visibility_slotmask)

						CopLogicAttack._set_best_cover(data, my_data, better_cover)
					end
				end
			elseif data.objective and data.objective.type == "follow" then
				local max_near_dis = data.objective.distance and data.objective.distance * 0.9 or nil
				
				if max_near_dis then
					max_near_dis = max_near_dis * max_near_dis
				end
				
				local near_pos = data.objective.follow_unit:movement():nav_tracker():field_position() --small clarification, follow_unit and focus_enemy can easily not be the same thing -- also using field_position if possible for valid navigation purposes

				if not best_cover or not CopLogicAttack._verify_follow_cover(best_cover, near_pos, threat_pos, min_dis, max_near_dis, data.objective.distance) then
					local follow_unit_area = managers.groupai:state():get_area_from_nav_seg_id(data.objective.follow_unit:movement():nav_tracker():nav_segment())
					local dis = data.objective and data.objective.distance and data.objective.distance * 0.9 or 700

					local found_cover = managers.navigation:find_cover_in_nav_seg_3(follow_unit_area.nav_segs, dis, near_pos, threat_pos)

					if found_cover then
						local better_cover = {
							found_cover
						}

						--[[local offset_pos, yaw = CopLogicAttack._get_cover_offset_pos(data, better_cover, threat_pos)

						if offset_pos then
							better_cover[5] = offset_pos
							better_cover[6] = yaw
						end]]

						if data.char_tweak.wall_fwd_offset then
							better_cover[1][1] = CopLogicTravel.apply_wall_offset_to_cover(data, my_data, better_cover[1], data.char_tweak.wall_fwd_offset)
						end
						
						better_cover[3], better_cover[4] = CopLogicAttack._chk_covered(data, found_cover[1], focus_enemy.m_head_pos, data.visibility_slotmask)

						CopLogicAttack._set_best_cover(data, my_data, better_cover)
					end
				end
			else
				local want_to_take_cover = my_data.want_to_take_cover
				local flank_cover = my_data.flank_cover
				local min_dis, max_dis = nil

				if want_to_take_cover then
					min_dis = math.max(data.attention_obj.dis * 0.9, data.attention_obj.dis - 200)
				elseif my_data.attitude == "engage" and my_data.cover_enter_t and data.t - my_data.cover_enter_t > 5 then
					max_dis = math.min(data.attention_obj.dis * 0.9, data.attention_obj.dis - 200)
				end

				if not my_data.processing_cover_path and (not best_cover or flank_cover or not CopLogicAttack._verify_cover(best_cover, threat_pos, min_dis, max_dis) or my_data.cover_enter_t and data.t - my_data.cover_enter_t > 2) then
					satisfied = false
					local my_vec = my_pos - threat_pos

					if flank_cover then
						local angle = flank_cover.angle
						local sign = flank_cover.sign

						if math.sign(angle) ~= sign then
							angle = -angle + flank_cover.step * sign

							if math.abs(angle) > 90 then
								flank_cover.failed = true
							else
								flank_cover.angle = angle
							end
						else
							flank_cover.angle = -angle
						end
					end

					if flank_cover and not flank_cover.failed then
						mvector3.rotate_with(my_vec, Rotation(flank_cover.angle))
					end

					local optimal_dis = my_vec:length()

					if want_to_take_cover then
						if optimal_dis < my_data.weapon_range.far then
							optimal_dis = optimal_dis + 400

							mvector3.set_length(my_vec, optimal_dis)
						end

						max_dis = math.max(optimal_dis + 800, my_data.weapon_range.far)
					elseif optimal_dis > my_data.weapon_range.optimal * 1.2 then
						optimal_dis = my_data.weapon_range.optimal

						mvector3.set_length(my_vec, optimal_dis)

						max_dis = my_data.weapon_range.far
					elseif max_dis then
						optimal_dis = max_dis * 0.9
						
						mvector3.set_length(my_vec, optimal_dis)
					end

					local my_side_pos = threat_pos + my_vec

					mvector3.set_length(my_vec, max_dis)

					local furthest_side_pos = threat_pos + my_vec

					local min_threat_dis, cone_angle = nil

					if flank_cover then
						cone_angle = flank_cover.step
					else
						cone_angle = math.lerp(90, 30, math.min(1, optimal_dis / 3000))
					end

					local search_nav_seg = nil

					if data.objective and data.objective.type == "defend_area" then
						search_nav_seg = data.objective.area and data.objective.area.nav_segs or data.objective.nav_seg
					end

					local found_cover = managers.navigation:find_cover_in_cone_from_threat_pos_1(threat_pos, furthest_side_pos, my_side_pos, nil, cone_angle, min_threat_dis, search_nav_seg, nil, data.pos_rsrv_id)

					--log(tostring(i))
					
					if found_cover then
						local better_cover = {
							found_cover
						}

						--[[local offset_pos, yaw = CopLogicAttack._get_cover_offset_pos(data, better_cover, threat_pos)

						if offset_pos then
							better_cover[5] = offset_pos
							better_cover[6] = yaw
						end]]

						if data.char_tweak.wall_fwd_offset then
							better_cover[1][1] = CopLogicTravel.apply_wall_offset_to_cover(data, my_data, better_cover[1], data.char_tweak.wall_fwd_offset)
						end
						
						better_cover[3], better_cover[4] = CopLogicAttack._chk_covered(data, found_cover[1], focus_enemy.m_head_pos, data.visibility_slotmask)

						CopLogicAttack._set_best_cover(data, my_data, better_cover)
					else
						if flank_cover then
							flank_cover.failed = true
						end
						
						my_data.cover_path_failed_t = data.t
					end
				end
			end
		end
	end
	
	if my_data.best_cover then
		local cover_release_dis = 100
		local check_pos = data.m_pos

		if cover_release_dis < mvec3_dis(my_data.best_cover[1][1], check_pos) then
			my_data.in_cover = nil
		else
			my_data.in_cover = true
			my_data.cover_enter_t = data.t
		end
		
		if focus_enemy and focus_enemy.nav_tracker and REACT_COMBAT <= focus_enemy.reaction then
			my_data.best_cover[3], my_data.best_cover[4] = CopLogicAttack._chk_covered(data, my_data.best_cover[1][1], focus_enemy.m_head_pos, data.visibility_slotmask)
		end
	else
		my_data.in_cover = nil
	end
end

function CopLogicAttack._verify_cover(cover, threat_pos, min_dis, max_dis)
	if min_dis then
		min_dis = min_dis * min_dis
	end
	
	if max_dis then
		max_dis = max_dis * max_dis
	end
	
	local threat_dis = mvec3_dis_sq(cover[1][1], threat_pos)

	if min_dis and threat_dis < min_dis or max_dis and max_dis < threat_dis then
		return
	end
	
	if not cover[3] then
		return
	end
	
	--better off commenting this out bc nobody actually makes cover use unique directional placement anymore, this is more likely to get in the way
	--local cover_dot = mvec3_dot(temp_vec1, cover[2]) 

    --if cover_dot < 0.67 then
    --    return
    --end

	return true
end

function CopLogicAttack._verify_follow_cover(cover, near_pos, threat_pos, min_dis, max_dis, follow_dis)
	if not follow_dis or mvec3_dis(near_pos, cover[1][1]) < follow_dis then
		return CopLogicAttack._verify_cover(cover, threat_pos, min_dis, max_dis)
	end
end

function CopLogicAttack._chk_covered(data, cover_pos, threat_pos, slotmask)
	local ray_from = temp_vec1

	mvec3_set(ray_from, math_up)
	mvec3_mul(ray_from, 82)
	mvec3_add(ray_from, cover_pos)

	local ray_to_pos = threat_pos

	local low_ray = data.unit:raycast("ray", ray_from, ray_to_pos, "slot_mask", slotmask, "ray_type", "ai_vision", "report")
	local high_ray = nil

	if low_ray then		
		mvec3_set_z(ray_from, ray_from.z + 82)

		high_ray = data.unit:raycast("ray", ray_from, ray_to_pos, "slot_mask", slotmask, "ray_type", "ai_vision", "report")
	end

	return low_ray, high_ray
end

function CopLogicAttack._pathing_complete_clbk(data)
	local my_data = data.internal_data
	
	if my_data.exiting then
		return
	end
	
	data.logic._process_pathing_results(data, my_data)
	
	if not my_data.tasing then
		if data.attention_obj and REACT_COMBAT <= data.attention_obj.reaction then
			local action_taken = data.logic.action_taken(data, my_data)
			
			if not data.unit:base():has_tag("medic") then
				my_data.attitude = data.objective and data.objective.attitude or "avoid"
			end
			
			my_data.want_to_take_cover = data.logic._chk_wants_to_take_cover(data, my_data)
			
			if not action_taken then
				CopLogicAttack._upd_combat_movement_no_searches(data)
			end
		end
	end
end

function CopLogicAttack._upd_combat_movement_no_searches(data)
	local my_data = data.internal_data
	local t = data.t
	local unit = data.unit
	local action_taken = nil
	local want_to_take_cover = my_data.want_to_take_cover

	local move_to_cover = nil
	local valid_harass = nil

	local in_cover = my_data.in_cover
	local best_cover = my_data.best_cover
	local want_flank_cover = my_data.flank_cover and not my_data.flank_cover.failed

	if not action_taken then
		if my_data.attitude == "engage" and my_data.charge_path then
			local path = my_data.charge_path
			my_data.charge_path = nil
			my_data.charging = not tactics or not tactics.hitnrun
			my_data.flank_cover = nil

			action_taken = CopLogicAttack._chk_request_action_walk_to_cover_shoot_pos(data, my_data, path, "run")
		end
		
		if not action_taken then 
			if my_data.attitude ~= "engage" and not in_cover then
				move_to_cover = true
			elseif not my_data.flank_cover or not my_data.flank_cover.failed then
				if my_data.at_cover_shoot_pos then
					if not my_data.stay_out_time or my_data.stay_out_time < t then
						move_to_cover = true
					end
				elseif best_cover and not in_cover then
					move_to_cover = true
				end
			end
		end
		
		if not action_taken and not in_cover and move_to_cover then
			if not data.spooc_warped and data.spooc_attack_timeout_t then
				data.spooc_warped = true
				local to_cover_pos = my_data.best_cover[1][1]
				action_taken = CopLogicAttack._warp_to_pos(data, my_data, to_cover_pos)
			elseif my_data.cover_path then
				action_taken = CopLogicAttack._chk_request_action_walk_to_cover(data, my_data)
			end
		end

	end

	return action_taken
end

function CopLogicAttack._process_pathing_results(data, my_data)
	if not data.pathing_results then
		return
	end

	local pathing_results = data.pathing_results
	data.pathing_results = nil
	local path = pathing_results[my_data.cover_path_search_id]

	if path then
		if path ~= "failed" then
			my_data.cover_path = path
			my_data.cover_path_failed_t = nil
		else
			--print(data.unit, "[CopLogicAttack._process_pathing_results] cover path failed", data.unit)
			CopLogicAttack._set_best_cover(data, my_data, nil)

			my_data.cover_path_failed_t = data.t
		end

		my_data.processing_cover_path = nil
		my_data.cover_path_search_id = nil
	end

	path = pathing_results[my_data.charge_path_search_id]

	if path then
		if path ~= "failed" then
			my_data.charge_path = path
			my_data.charge_path_failed_t = nil
		else
			my_data.charge_path_failed_t = data.t
		end

		my_data.charge_path_search_id = nil
	end

	path = pathing_results[my_data.expected_pos_path_search_id]

	if path then
		if path ~= "failed" then
			my_data.expected_pos_path = path
		end

		my_data.expected_pos_path_search_id = nil
	end
end

function CopLogicAttack._upd_enemy_detection(data, is_synchronous)
	managers.groupai:state():on_unit_detection_updated(data.unit)

	data.t = TimerManager:game():time()
	local my_data = data.internal_data
	local tasing = my_data.tasing

	if tasing then
		if data.unit:movement()._active_actions[3] and data.unit:movement()._active_actions[3]:type() == "tase" then
			if data.attention_obj and data.logic.chk_should_turn(data, my_data) then
				local enemy_pos = data.attention_obj.m_head_pos
				CopLogicAttack._chk_request_action_turn_to_enemy(data, my_data, data.m_pos, enemy_pos)
			end
		
			local tase_action = data.unit:movement()._active_actions[3]

			if tase_action._discharging or tase_action._firing_at_husk or tase_action._discharging_on_husk then
				if not is_synchronous then
					CopLogicBase.queue_task(my_data, my_data.detection_task_key, CopLogicAttack._upd_enemy_detection, data, data.t, true)
				end
				
				return
			end
		end
	end
	
	local min_reaction = REACT_AIM
	local delay = CopLogicBase._upd_attention_obj_detection(data, min_reaction, nil)
	local react_func = nil
	
	if data.unit:base():has_tag("taser") then
		react_func = TaserLogicAttack._chk_reaction_to_attention_object
	end
	
	local new_attention, new_prio_slot, new_reaction = CopLogicIdle._get_priority_attention(data, data.detected_attention_objects, react_func)
	local old_att_obj = data.attention_obj

	CopLogicBase._set_attention_obj(data, new_attention, new_reaction)
	data.logic._chk_exit_attack_logic(data, new_reaction)

	if my_data ~= data.internal_data then
		return
	end

	if new_attention then
		if old_att_obj and old_att_obj.u_key ~= new_attention.u_key then
			my_data.flank_cover = nil

			if not data.unit:movement():chk_action_forbidden("walk") then
				CopLogicAttack._cancel_walking_to_cover(data, my_data)
			end

			CopLogicAttack._set_best_cover(data, my_data, nil)
		end
	elseif old_att_obj then
		my_data.flank_cover = nil
	end
	
	if data.wants_to_dark_bomb then
		if data.attention_obj.verified and REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.dis < 300 then
			data.unit:movement():_detonate_dark_bomb(not data.is_converted) --i'll work more on this later i guess, currently causes crashes}
			
			return
		end
	end

	CopLogicBase._chk_call_the_police(data)

	if my_data ~= data.internal_data then
		return
	end
	
	data.logic._upd_aim(data, my_data)
	
	if not data.entrance and new_attention and data.char_tweak.chatter and data.char_tweak.chatter.entrance then
		if new_attention.criminal_record and new_reaction >= REACT_COMBAT and new_attention.dis < 1200 and math_abs(data.m_pos.z - new_attention.m_pos.z) < 250 then
			local voiceline = data.brain.entrance_chatter_cue or data.char_tweak.spawn_sound_event or "entrance"

			data.unit:sound():say(voiceline, true, nil)

			data.entrance = true
		end
	end

	if not is_synchronous then
		CopLogicBase.queue_task(my_data, my_data.detection_task_key, CopLogicAttack._upd_enemy_detection, data, data.t + delay, data.important and true)
	end

	CopLogicBase._report_detections(data.detected_attention_objects)
end

function CopLogicAttack._confirm_retreat_position(data, retreat_pos, threat_head_pos, threat_tracker, end_pose)
	local ray_params = {
		trace = true,
		pos_from = retreat_pos,
		tracker_to = threat_tracker
	}
	local walk_ray_res = managers.navigation:raycast(ray_params)

	if not walk_ray_res then
		return true
	end

	local retreat_head_pos = mvec3_cpy(retreat_pos)

	if end_pose == "stand" then
		mvec3_set_z(retreat_head_pos, retreat_head_pos.z + 160)
	else
		mvec3_set_z(retreat_head_pos, retreat_head_pos.z + 82)
	end

	local ray_res = data.unit:raycast("ray", retreat_head_pos, threat_head_pos, "slot_mask", data.visibility_slotmask, "ray_type", "ai_vision", "report")

	if not ray_res then
		return true
	end

	return false
end

function CopLogicAttack._find_retreat_position(data, from_pos, threat_pos, threat_head_pos, threat_tracker, max_dist, vis_required, end_pose)
	local nav_manager = managers.navigation
	local nr_rays = 10
	local ray_dis = max_dist or 1000
	local step = 180 / nr_rays
	local offset = math_random(step)
	local dir = math_random() < 0.5 and -1 or 1
	step = step * dir
	local step_rot = Rotation(step)
	local offset_rot = Rotation(offset)
	local offset_vec = mvec3_cpy(threat_pos)

	mvec3_sub(offset_vec, from_pos)
	mvec3_norm(offset_vec)
	mvec3_mul(offset_vec, ray_dis)
	mvec3_rotate_with(offset_vec, Rotation((90 + offset) * dir))

	local to_pos = nil
	local from_tracker = nav_manager:create_nav_tracker(from_pos)
	local ray_params = {
		trace = true,
		tracker_from = from_tracker
	}
	local rsrv_desc = {
		radius = 30,
		filter = data.pos_rsrv_id
	}
	local fail_position = nil

	repeat
		to_pos = mvec3_cpy(from_pos)

		mvec3_add(to_pos, offset_vec)

		ray_params.pos_to = to_pos
		local ray_res = nav_manager:raycast(ray_params)

		rsrv_desc.position = ray_params.trace[1]
		local is_free = nav_manager:is_pos_free(rsrv_desc)

		if is_free then
			if not vis_required or CopLogicAttack._confirm_retreat_position(data, ray_params.trace[1], threat_head_pos, threat_tracker, end_pose) then
				nav_manager:destroy_nav_tracker(from_tracker)

				return ray_params.trace[1]
			end
		end

		mvec3_rotate_with(offset_vec, step_rot)

		nr_rays = nr_rays - 1
	until nr_rays == 0

	nav_manager:destroy_nav_tracker(from_tracker)

	return nil
end

function CopLogicAttack.action_complete_clbk(data, action)
	local my_data = data.internal_data
	local action_type = action:type()
	
	if action_type == "walk" then
		my_data.advancing = nil

		CopLogicAttack._cancel_cover_pathing(data, my_data)
		CopLogicAttack._cancel_charge(data, my_data)

		if my_data.surprised then
			my_data.surprised = nil
		elseif my_data.moving_to_cover then
			my_data.moving_to_cover = nil
		elseif my_data.walking_to_cover_shoot_pos then
			my_data.walking_to_cover_shoot_pos = nil
			my_data.at_cover_shoot_pos = true
		end

		if action:expired() and data.important then	
			if data.attention_obj and REACT_COMBAT <= data.attention_obj.reaction then
				my_data.want_to_take_cover = CopLogicAttack._chk_wants_to_take_cover(data, my_data)
				CopLogicAttack._update_cover(data)
				data.logic._upd_combat_movement(data)
			end
		end
	elseif action_type == "act" then
		if my_data.gesture_arrest then
			my_data.gesture_arrest = nil
		elseif my_data.starting_idle_action_from_act or action:expired() then
			data.logic._upd_aim(data, my_data)
			
			if data.important then
				if data.attention_obj and REACT_COMBAT <= data.attention_obj.reaction then
					my_data.want_to_take_cover = CopLogicAttack._chk_wants_to_take_cover(data, my_data)
					CopLogicAttack._update_cover(data)
					data.logic._upd_combat_movement(data)
				end
			end
			
			my_data.old_action_started = nil
		end
	elseif action_type == "shoot" then
		my_data.shooting = nil
	elseif action_type == "tase" then
		if my_data.tasing then
			managers.groupai:state():on_tase_end(my_data.tasing.target_u_key)
		end

		my_data.tasing = nil
	elseif action_type == "reload" or action_type == "heal" then
		if action:expired() then
			data.logic._upd_aim(data, my_data)
		end
	elseif action_type == "act" then

	elseif action_type == "turn" then
		my_data.turning = nil
	elseif action_type == "hurt" or action_type == "healed" then
		CopLogicAttack._cancel_cover_pathing(data, my_data)

		if action:expired() and not CopLogicBase.chk_start_action_dodge(data, "hit") then
			data.logic._upd_aim(data, my_data)
			
			if data.important then
				if data.attention_obj and REACT_COMBAT <= data.attention_obj.reaction then
					my_data.want_to_take_cover = CopLogicAttack._chk_wants_to_take_cover(data, my_data)
					CopLogicAttack._update_cover(data)
					data.logic._upd_combat_movement(data)
				end
			end
		end
	elseif action_type == "dodge" then
		my_data.at_cover_shoot_pos = nil
	
		local timeout = action:timeout()

		if timeout then
			data.dodge_timeout_t = TimerManager:game():time() + math_lerp(timeout[1], timeout[2], math_random())
		end

		CopLogicAttack._cancel_cover_pathing(data, my_data)

		if action:expired() then
			data.logic._upd_aim(data, my_data)
			
			if data.important then
				if data.attention_obj and REACT_COMBAT <= data.attention_obj.reaction then
					my_data.want_to_take_cover = CopLogicAttack._chk_wants_to_take_cover(data, my_data)
					CopLogicAttack._update_cover(data)
					data.logic._upd_combat_movement(data)
				end
			end
		end
	end
end

function CopLogicAttack._chk_use_throwable(data, my_data, focus)
	local throwable = data.char_tweak.throwable

	if not throwable then
		return
	end

	if not focus.criminal_record or focus.is_deployable then
		return
	end

	if not focus.last_verified_pos then
		return
	end

	if data.used_throwable_t and data.t < data.used_throwable_t then
		return
	end

	local time_since_verification = focus.verified_t

	if not time_since_verification then
		return
	end

	time_since_verification = data.t - time_since_verification

	if time_since_verification > 5 then
		return
	end

	local mov_ext = data.unit:movement()

	if mov_ext:chk_action_forbidden("action") then
		return
	end

	local head_pos = mov_ext:m_head_pos()
	local throw_dis = focus.verified_dis

	if throw_dis < 400 then
		return
	end

	if throw_dis > 2000 then
		return
	end

	local throw_from = head_pos + mov_ext:m_head_rot():y() * 50
	local last_seen_pos = focus.last_verified_pos
	local slotmask = managers.slot:get_mask("world_geometry")
	local obstructed = data.unit:raycast("ray", throw_from, last_seen_pos, "sphere_cast_radius", 15, "slot_mask", slotmask, "report")

	if obstructed then
		return
	end

	local throw_dir = Vector3()

	mvec3_lerp(throw_dir, throw_from, last_seen_pos, 0.3)
	mvec3_sub(throw_dir, throw_from)

	local dis_lerp = math_clamp((throw_dis - 1000) / 1000, 0, 1)
	local compensation = math_lerp(0, 300, dis_lerp)

	mvec3_set_z(throw_dir, throw_dir.z + compensation)
	mvec3_norm(throw_dir)

	data.used_throwable_t = data.t + 10

	if mov_ext:play_redirect("throw_grenade") then
		managers.network:session():send_to_peers_synched("play_distance_interact_redirect", data.unit, "throw_grenade")
	end

	ProjectileBase.throw_projectile_npc(throwable, throw_from, throw_dir, data.unit)
end

function CopLogicAttack._upd_aim(data, my_data)
	data.t = TimerManager:game():time()

	local aim, shoot, expected_pos = nil
	local focus_enemy = data.attention_obj
	local tase = nil
	
	if focus_enemy then
		tase = focus_enemy.reaction == AIAttentionObject.REACT_SPECIAL_ATTACK

		if tase and data.unit:base():has_tag("taser") then
			shoot = true
		elseif REACT_AIM <= focus_enemy.reaction then
			local running = my_data.advancing and not my_data.advancing:stopping() and my_data.advancing:haste() == "run"
			
			local firing_range = 500

			if my_data.weapon_range then
				firing_range = running and my_data.weapon_range.close or my_data.weapon_range.far
			elseif not running then
				firing_range = 1000
			end
			
			if running and not data.char_tweak.always_face_enemy and firing_range < focus_enemy.dis then ----check always_face_enemy
				local walk_to_pos = data.unit:movement():get_walk_to_pos()

				if walk_to_pos then
					mvec3_dir(temp_vec1, data.m_pos, walk_to_pos)
					mvec3_dir(temp_vec2, data.m_pos, focus_enemy.m_pos)

					local dot = mvec3_dot(temp_vec1, temp_vec2)

					if dot <= 0.5 then
						shoot = false
						aim = false
					end
				end
			end
			
			if focus_enemy.verified or focus_enemy.nearly_visible then
				if aim == nil then
					if REACT_SHOOT <= focus_enemy.reaction then
						if REACT_SHOOT == focus_enemy.reaction then
							shoot = true
						end
						
						if not shoot and my_data.attitude == "engage" then
							shoot = true
						end
						
						if not shoot then
							if data.unit:base():has_tag("law") and not data.is_converted then
								if focus_enemy.criminal_record and focus_enemy.criminal_record.assault_t and data.t - focus_enemy.criminal_record.assault_t < 7 then
									shoot = true
								else
									aim = true
								end
							else
								shoot = true
							end
						end

						aim = aim or shoot
					else
						aim = true
					end
				end
			elseif aim == nil then 
				local time_since_verification = focus_enemy.verified_t and data.t - focus_enemy.verified_t
				
				if time_since_verification then
					if running then
						local dis_lerp = math_clamp((focus_enemy.verified_dis - firing_range) / firing_range, 0, 1)

						if time_since_verification < math_lerp(0.5, 3.5, dis_lerp) then
							aim = true
						end
					elseif focus_enemy.dis < firing_range then
						if time_since_verification < 7 then
							aim = true
						end
					end

					if aim then
						if REACT_SHOOT == focus_enemy.reaction then
							shoot = true
						end
						
						if not shoot and my_data.attitude == "engage" then
							shoot = true
						end
						
						if not shoot then
							if data.unit:base():has_tag("law") and not data.is_converted then
								if focus_enemy.criminal_record and focus_enemy.criminal_record.assault_t and data.t - focus_enemy.criminal_record.assault_t < 4 then
									shoot = true
								else
									aim = true
								end
							else
								shoot = true
							end
						end
					end
				end
			end
		end

		if not aim and data.char_tweak.always_face_enemy and REACT_COMBAT <= focus_enemy.reaction then
			aim = true
		end
		
		CopLogicAttack._chk_use_throwable(data, my_data, focus_enemy) --AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA
	end
	
	local is_moving = my_data.advancing or my_data.walking_to_cover_shoot_pos or my_data.moving_to_cover or data.unit:anim_data().run or data.unit:anim_data().move

	if tase and is_moving and not data.unit:movement():chk_action_forbidden("walk") then
		local new_action = {
			body_part = 2,
			type = "idle"
		}

		data.unit:brain():action_request(new_action)
	end

	if aim or shoot then
		local time_since_verification = focus_enemy.verified_t and data.t - focus_enemy.verified_t
		
		if not tase then
			local shoot_action = data.unit:movement()._active_actions[3]
			
			if shoot_action and type(shoot_action) ~= "boolean" and shoot_action._last_target_pos then
				local shoot_pos = shoot_action._last_target_pos

				if data.logic.chk_should_turn(data, my_data) then
					CopLogicAttack._chk_request_action_turn_to_enemy(data, my_data, data.m_pos, shoot_pos)
				end
			end
			
			
			if focus_enemy.verified or focus_enemy.nearly_visible or time_since_verification and time_since_verification < 1 then
				if my_data.attention_unit ~= focus_enemy.u_key then
					CopLogicBase._set_attention(data, focus_enemy)

					my_data.attention_unit = focus_enemy.u_key
				end
				
				if not my_data.shooting then
					if data.logic.chk_should_turn(data, my_data) then
						local enemy_pos = focus_enemy.m_head_pos
						CopLogicAttack._chk_request_action_turn_to_enemy(data, my_data, data.m_pos, enemy_pos)
					end
				end
			else
				local look_pos = nil
				
				if time_since_verification and time_since_verification <= 7 or focus_enemy.dis <= 1000 and focus_enemy.alert_t and data.t - focus_enemy.alert_t < 7 then
					look_pos = focus_enemy.last_verified_pos or focus_enemy.verified_pos
				end
				
				if look_pos then
					if my_data.attention_unit ~= look_pos then
						CopLogicBase._set_attention_on_pos(data, mvec3_cpy(look_pos))

						my_data.attention_unit = mvec3_cpy(look_pos)
					end
					
					if not my_data.shooting then
						if data.logic.chk_should_turn(data, my_data) then
							CopLogicAttack._chk_request_action_turn_to_enemy(data, my_data, data.m_pos, look_pos)
						end
					end
				end
			end
		end
		
		local nottasingortargetwrong = not my_data.tasing or my_data.tasing.target_u_data ~= focus_enemy
		
		if tase then
			if nottasingortargetwrong and not data.unit:movement():chk_action_forbidden("walk") and not focus_enemy.unit:movement():zipline_unit() then
				if my_data.attention_unit ~= focus_enemy.u_key then
					CopLogicBase._set_attention(data, focus_enemy)

					my_data.attention_unit = focus_enemy.u_key
				end
				
				if data.logic.chk_should_turn(data, my_data) then
					local enemy_pos = focus_enemy.m_head_pos
					CopLogicAttack._chk_request_action_turn_to_enemy(data, my_data, data.m_pos, enemy_pos)
				end
				
				if my_data.shooting then
					local new_action = {
						body_part = 3,
						type = "idle"
					}

					data.brain:action_request(new_action)
				end

				local tase_action = {
					body_part = 3,
					type = "tase"
				}

				if data.unit:brain():action_request(tase_action) then
					my_data.tasing = {
						target_u_data = focus_enemy,
						target_u_key = focus_enemy.u_key,
						start_t = data.t
					}
					
					TaserLogicAttack._cancel_charge(data, my_data)
					managers.groupai:state():on_tase_start(data.key, focus_enemy.u_key)
				end
			end
		elseif not my_data.spooc_attack and not data.unit:anim_data().reload and not data.unit:movement():chk_action_forbidden("action") then
			if not my_data.shooting then
				local shoot_action = {
					body_part = 3,
					type = "shoot"
				}
				
				if my_data.last_target_pos then
					shoot_action.target_pos = mvec3_cpy(my_data.last_target_pos)
					my_data.last_target_pos = nil
				end

				if data.brain:action_request(shoot_action) then
					my_data.shooting = true
				end
			elseif not shoot then
				local ammo_max, ammo = data.unit:inventory():equipped_unit():base():ammo_info()

				if ammo / ammo_max < 0.75 then
					local new_action = {
						body_part = 3,
						type = "reload",
						idle_reload = true
					}

					data.brain:action_request(new_action)
				end
			end
		end
	else
		if not data.unit:anim_data().reload then
			if my_data.shooting or my_data.tasing then
				local new_action = {
					body_part = 3,
					type = "idle"
				}

				data.brain:action_request(new_action)
			elseif not data.unit:movement():chk_action_forbidden("action") then
				local ammo_max, ammo = data.unit:inventory():equipped_unit():base():ammo_info()

				if ammo / ammo_max < 0.75 then
					local new_action = {
						body_part = 3,
						type = "reload",
						idle_reload = true
					}

					data.brain:action_request(new_action)
				end
			end
		end

		if focus_enemy and aim == nil then
			local time_since_verification = focus_enemy.verified_t and data.t - focus_enemy.verified_t
			
			if focus_enemy.verified or focus_enemy.nearly_visible or time_since_verification and time_since_verification < 2 then
				if my_data.attention_unit ~= focus_enemy.u_key then
					CopLogicBase._set_attention(data, focus_enemy)

					my_data.attention_unit = focus_enemy.u_key
				end
				
				if data.logic.chk_should_turn(data, my_data) then
					local enemy_pos = focus_enemy.m_head_pos
					CopLogicAttack._chk_request_action_turn_to_enemy(data, my_data, data.m_pos, enemy_pos)
				end
			elseif time_since_verification and time_since_verification <= 7 or focus_enemy.dis <= 1000 and focus_enemy.alert_t and data.t - focus_enemy.alert_t < 7 then
				local look_pos = focus_enemy.last_verified_pos
				
				if look_pos then
					if my_data.attention_unit ~= look_pos then
						CopLogicBase._set_attention_on_pos(data, mvec3_cpy(look_pos))

						my_data.attention_unit = mvec3_cpy(look_pos)
					end
					
					if data.logic.chk_should_turn(data, my_data) then
						CopLogicAttack._chk_request_action_turn_to_enemy(data, my_data, data.m_pos, look_pos)
					end
				end
			elseif my_data.attention_unit then
				CopLogicBase._reset_attention(data)

				my_data.attention_unit = nil
			end
		elseif my_data.attention_unit then
			CopLogicBase._reset_attention(data)

			my_data.attention_unit = nil
		end
	end
	
	my_data.last_target_pos = nil

	CopLogicAttack.aim_allow_fire(shoot, aim, data, my_data)
end

function CopLogicAttack.aim_allow_fire(shoot, aim, data, my_data)
	if shoot then
		if not my_data.firing then
			data.unit:movement():set_allow_fire(true)

			my_data.firing = true
		end
	elseif my_data.firing then
		data.unit:movement():set_allow_fire(false)

		my_data.firing = nil
	end
end

function CopLogicAttack.chk_should_turn(data, my_data)
	return not my_data.turning and not my_data.has_old_action and not my_data.advancing and not my_data.moving_to_cover and not my_data.walking_to_cover_shoot_pos and not my_data.surprised and not my_data.menacing and not data.unit:movement():chk_action_forbidden("walk")
end

function CopLogicAttack._get_cover_offset_pos(data, cover_data, threat_pos)
	local threat_vec = threat_pos - cover_data[1][1]

	mvec3_set_z(threat_vec, 0)

	local threat_polar = threat_vec:to_polar_with_reference(cover_data[1][2], math_up)
	local threat_spin = threat_polar.spin
	local rot = nil

	if threat_spin < -20 then
		rot = Rotation(90)
	elseif threat_spin > 20 then
		rot = Rotation(-90)
	else
		rot = Rotation(180)
	end

	local offset_pos = mvec3_cpy(cover_data[1][2])

	mvec3_rotate_with(offset_pos, rot)
	mvec3_set_length(offset_pos, 25)
	mvec3_add(offset_pos, cover_data[1][1])

	local ray_params = {
		trace = true,
		tracker_from = cover_data[1][3],
		pos_to = offset_pos
	}

	managers.navigation:raycast(ray_params)

	return ray_params.trace[1], rot:yaw()
end

function CopLogicAttack._find_flank_pos(data, my_data, flank_tracker, max_dist)
	local pos = flank_tracker:position()
	local vec_to_pos = pos - data.m_pos

	mvec3_set_z(vec_to_pos, 0)

	local max_dis = max_dist or 1500

	mvec3_set_length(vec_to_pos, max_dis)

	local nav_manager = managers.navigation
	local accross_positions = nav_manager:find_walls_accross_tracker(flank_tracker, vec_to_pos, 160, 5)

	if accross_positions then
		local optimal_dis = max_dis
		local best_error_dis, best_pos, best_is_hit, best_is_miss, best_has_too_much_error = nil
		local reservation = {
			radius = 30,
			filter = data.pos_rsrv_id
		}

		for _, accross_pos in ipairs(accross_positions) do
			local error_dis = math_abs(mvec3_dis(accross_pos[1], pos) - optimal_dis)
			local too_much_error = error_dis / optimal_dis > 0.2
			local is_hit = accross_pos[2]

			if best_is_hit then
				if is_hit then
					if error_dis < best_error_dis then
						reservation.position = accross_pos[1]

						if nav_manager:is_pos_free(reservation) then
							best_pos = accross_pos[1]
							best_error_dis = error_dis
							best_has_too_much_error = too_much_error
						end
					end
				elseif best_has_too_much_error then
					reservation.position = accross_pos[1]

					if nav_manager:is_pos_free(reservation) then
						best_pos = accross_pos[1]
						best_error_dis = error_dis
						best_is_miss = true
						best_is_hit = nil
					end
				end
			elseif best_is_miss then
				if not too_much_error then
					reservation.position = accross_pos[1]

					if nav_manager:is_pos_free(reservation) then
						best_pos = accross_pos[1]
						best_error_dis = error_dis
						best_has_too_much_error = nil
						best_is_miss = nil
						best_is_hit = true
					end
				end
			else
				reservation.position = accross_pos[1]

				if nav_manager:is_pos_free(reservation) then
					best_pos = accross_pos[1]
					best_is_hit = is_hit
					best_is_miss = not is_hit
					best_has_too_much_error = too_much_error
					best_error_dis = error_dis
				end
			end
		end

		return best_pos
	end
end

function CopLogicAttack.damage_clbk(data, damage_info)
	CopLogicIdle.damage_clbk(data, damage_info)
end

function CopLogicAttack.is_available_for_assignment(data, new_objective)
	local my_data = data.internal_data

	if my_data.exiting then
		return
	end

	if new_objective and new_objective.forced then
		return true
	end

	if data.unit:movement():chk_action_forbidden("walk") then
		return
	end

	data.t = TimerManager:game():time()

	if data.path_fail_t then
		local fail_t_chk = data.important and 1 or 3
		if data.t < data.path_fail_t + fail_t_chk then
			return
		end
	end

	local att_obj = data.attention_obj

	if not att_obj or att_obj.reaction < REACT_AIM then
		return true
	end

	if not new_objective or new_objective.type == "free" then
		return true
	end

	if new_objective then
		local allow_trans, obj_fail = CopLogicBase.is_obstructed(data, new_objective, 0.2, att_obj)

		if obj_fail then
			return
		end
	end

	return true
end

function CopLogicAttack._chk_wants_to_take_cover(data, my_data)
	if not data.attention_obj or data.attention_obj.reaction < REACT_COMBAT then
		return
	end

	local groupai = managers.groupai:state()
	
	if data.unit:base():has_tag("tank") then
		if my_data.attitude == "engage" and data.attention_obj.dis < 1400 then
			return true
		end
		
		return
	end
	
	if data.unit:base():has_tag("spooc") then
		if data.spooc_attack_timeout_t and data.t < data.spooc_attack_timeout_t then
			return true
		end
		
		if groupai:chk_heat_bonus_retreat() then
			return true
		end
		
		return
	end
	
	if data.is_suppressed then
		return true
	end
	
	if groupai._drama_data.zone == "high" then	
		return
	end
	
	if not groupai._enemy_weapons_hot then
		return true
	end
	
	if data.tactics then
		if data.tactics.spoocavoidance and data.attention_obj.dis < 2000 and data.attention_obj.aimed_at then
			return "spoocavoidance"
		elseif data.tactics.hitnrun and data.attention_obj.verified_dis < 1000 then
			return "hitnrun"
		end
	end
	
	local ammo_max, ammo = data.unit:inventory():equipped_unit():base():ammo_info()

	if ammo / ammo_max < 0.2 then
		return true
	end
	
	if data.name == "attack" and my_data.moving_to_cover then 
		return true
	end
	
	if Global.game_settings.one_down then
		return
	end
	
	local diff_index = my_data.attitude == "avoid" and 0 or managers.modifiers and managers.modifiers:check_boolean("TotalAnarchy") and 8 or tweak_data:difficulty_to_index(Global.game_settings.difficulty)
	
	if diff_index < 7 then
		if data.attention_obj.dmg_t and data.t - data.attention_obj.dmg_t < 4 then
			return true
		end
		
		if diff_index < 4 then
			local last_sup_t = data.unit:character_damage():last_suppression_t()
			
			if last_sup_t then
				if data.t - last_sup_t < 7 then
					return true
				end
			end
		end
		
		if diff_index < 2 then
			if my_data.firing then
				return true
			end
		end
	end
	
	if groupai:chk_heat_bonus_retreat() then
		return true
	end
end

function CopLogicAttack._set_best_cover(data, my_data, cover_data)
	local current_best_cover = my_data.best_cover

	if current_best_cover then
		managers.navigation:release_cover(current_best_cover[1])
		CopLogicAttack._cancel_cover_pathing(data, my_data)
	end

	if cover_data and not cover_data[1][4] then
		managers.navigation:reserve_cover(cover_data[1], data.pos_rsrv_id)

		my_data.best_cover = cover_data

		if not my_data.in_cover and not my_data.walking_to_cover_shoot_pos and not my_data.moving_to_cover and mvec3_dis_sq(cover_data[1][1], data.m_pos) < 100 then
			my_data.in_cover = true
			my_data.cover_enter_t = data.t
		end
	else
		my_data.best_cover = nil
		my_data.flank_cover = nil
		my_data.in_cover = nil
	end
end

function CopLogicAttack._set_nearest_cover(my_data, cover_data)
	local nearest_cover = my_data.nearest_cover

	if nearest_cover then
		managers.navigation:release_cover(nearest_cover[1])
	end

	if cover_data then
		local pos_rsrv_id = my_data.unit:movement():pos_rsrv_id()

		managers.navigation:reserve_cover(cover_data[1], pos_rsrv_id)

		my_data.nearest_cover = cover_data
	else
		my_data.nearest_cover = nil
	end
end

function CopLogicAttack._can_move(data)
	if not data.unit:movement():chk_action_forbidden("walk") then
		return not data.objective or not data.objective.pos or not data.objective.in_place
	end
end

function CopLogicAttack.on_new_objective(data, old_objective)
	CopLogicIdle.on_new_objective(data, old_objective)
end

function CopLogicAttack.queue_update(data, my_data)
	local delay = data.important and 0.5 or 1

	CopLogicBase.queue_task(my_data, my_data.update_queue_id, data.logic.queued_update, data, data.t + delay, data.important and true)
end

function CopLogicAttack._get_expected_attention_position(data, my_data)
	local main_enemy = data.attention_obj
	local e_nav_tracker = main_enemy.nav_tracker

	if not e_nav_tracker then
		return
	end

	local my_nav_seg = data.unit:movement():nav_tracker():nav_segment()
	local e_pos = main_enemy.m_pos
	local e_nav_seg = e_nav_tracker:nav_segment()

	if e_nav_seg == my_nav_seg then
		mvec3_set(temp_vec1, main_enemy.m_head_pos)

		return temp_vec1
	end

	local expected_path = my_data.expected_pos_path
	local from_nav_seg, to_nav_seg = nil

	if expected_path then
		local i_from_seg = nil

		for i, k in ipairs(expected_path) do
			if k[1] == my_nav_seg then
				i_from_seg = i

				break
			end
		end

		if i_from_seg then
			local groupai_manager = managers.groupai:state()
			local nav_manager = managers.navigation

			local function _find_aim_pos(from_nav_seg, to_nav_seg)
				local is_criminal = main_enemy.criminal_record and true

				if groupai_manager:chk_area_leads_to_enemy(from_nav_seg, to_nav_seg, is_criminal) then ----check if this changes anything, draw expected_pos to check
					local closest_dis = 1000000000
					local closest_door = nil
					local min_point_dis_sq = 10000
					local found_doors = nav_manager:find_segment_doors(from_nav_seg, callback(CopLogicAttack, CopLogicAttack, "_chk_is_right_segment", to_nav_seg))

					for _, door in pairs(found_doors) do
						mvec3_set(temp_vec1, door.center)

						local same_height = math_abs(temp_vec1.z - data.m_pos.z) < 160

						if same_height then
							local dis = mvec3_dis_sq(e_pos, temp_vec1)

							if dis < closest_dis then
								closest_dis = dis
								closest_door = door
							end
						end
					end

					if closest_door then
						mvec3_set(temp_vec1, closest_door.center)
						mvec3_sub(temp_vec1, data.m_pos)
						mvec3_set_z(temp_vec1, 0)

						if min_point_dis_sq < mvec3_len_sq(temp_vec1) then
							mvec3_set(temp_vec1, closest_door.center)
							mvec3_set_z(temp_vec1, data.unit:movement():m_head_pos().z)

							return temp_vec1
						else
							return false, true
						end
					end
				end
			end

			local i = #expected_path

			while i > 0 do
				if expected_path[i][1] == e_nav_seg then
					to_nav_seg = expected_path[math_clamp(i, i_from_seg - 1, i_from_seg + 1)][1]
					local aim_pos, too_close = _find_aim_pos(my_nav_seg, to_nav_seg)

					if aim_pos then
						do return aim_pos end
						break
					end

					if too_close then
						local next_nav_seg = expected_path[math_clamp(i, i_from_seg - 2, i_from_seg + 2)][1]

						if next_nav_seg ~= to_nav_seg then
							local from_nav_seg = to_nav_seg
							to_nav_seg = next_nav_seg
							aim_pos = _find_aim_pos(from_nav_seg, to_nav_seg)
						end

						return aim_pos
					end

					break
				end

				i = i - 1
			end
		end

		if not i_from_seg or not to_nav_seg then
			expected_path = nil
			my_data.expected_pos_path = nil
		end
	end

	if not expected_path and not my_data.expected_pos_path_search_id then
		my_data.expected_pos_path_search_id = "ExpectedPos" .. tostring(data.key)

		data.brain:search_for_coarse_path(my_data.expected_pos_path_search_id, e_nav_seg)
	end
end

function CopLogicAttack._chk_is_right_segment(ignore_this, enemy_nav_seg, test_nav_seg)
	return enemy_nav_seg == test_nav_seg
end

function CopLogicAttack.is_advancing(data)
	local my_data = data.internal_data

	if my_data.advancing then
		return data.pos_rsrv.move_dest and data.pos_rsrv.move_dest.position or my_data.advancing:get_walk_to_pos()
	end

	if my_data.moving_to_cover then
		return my_data.moving_to_cover[1][1]
	end

	if my_data.walking_to_cover_shoot_pos then
		return my_data.walking_to_cover_shoot_pos:get_walk_to_pos()
	end
end

function CopLogicAttack._get_all_paths(data)
	return {
		cover_path = data.internal_data.cover_path,
		charge_path = data.internal_data.charge_path
	}
end

function CopLogicAttack._set_verified_paths(data, verified_paths)
	data.internal_data.cover_path = verified_paths.cover_path
	data.internal_data.charge_path = verified_paths.charge_path
end

function CopLogicAttack._chk_exit_attack_logic(data, new_reaction)
	if not data.unit:movement():chk_action_forbidden("walk") then
		local objective = data.objective
		local wanted_state = CopLogicBase._get_logic_state_from_reaction(data, new_reaction)
				
		if wanted_state ~= data.name then		
			local allow_trans, obj_failed = CopLogicBase.is_obstructed(data, objective, nil, data.attention_obj)

			if allow_trans then
				if objective and objective.stop_on_trans and wanted_state == "attack" then
					local my_tracker = data.unit:movement():nav_tracker()
					objective.pos = nil
					objective.in_place = not my_tracker:obstructed()
				end
			
				if obj_failed then
					data.objective_failed_clbk(data.unit, objective)
				elseif wanted_state ~= "idle" or not managers.groupai:state():on_cop_jobless(data.unit) then
					CopLogicBase._exit(data.unit, wanted_state)
				end

				CopLogicBase._report_detections(data.detected_attention_objects)
			end
		elseif objective and objective.stop_on_trans then
			local allow_trans, obj_failed = CopLogicBase.is_obstructed(data, objective, nil, data.attention_obj)
			
			if obj_failed then
				data.objective_failed_clbk(data.unit, objective)
			elseif not allow_trans then
				objective.in_place = nil
				objective.pos = objective.grp_objective.pos
				
				CopLogicIdle.on_new_objective(data)
			end
		end
	end
end

function CopLogicAttack.action_taken(data, my_data)
	return my_data.turning or my_data.has_old_action or my_data.advancing or my_data.moving_to_cover or my_data.walking_to_cover_shoot_pos or my_data.surprised or my_data.menacing or data.unit:movement():chk_action_forbidden("walk")
end

function CopLogicAttack._upd_stop_old_action(data, my_data)
	if my_data.advancing then
		if not data.unit:movement():chk_action_forbidden("idle") then
			data.brain:action_request({
				body_part = 2,
				type = "idle"
			})
		end
	elseif data.unit:anim_data().act or data.unit:anim_data().act_idle or data.unit:anim_data().to_idle then
		if not my_data.starting_idle_action_from_act then
			my_data.starting_idle_action_from_act = true
			CopLogicIdle._start_idle_action_from_act(data)
		end
	else
		my_data.starting_idle_action_from_act = nil
	end

	CopLogicIdle._chk_has_old_action(data, my_data)
end

function CopLogicAttack._chk_exit_non_walkable_area(data)
	local my_data = data.internal_data

	if my_data.advancing or not data.objective or not data.objective.nav_seg or data.unit:movement():chk_action_forbidden("walk") then
		return
	end

	local my_tracker = data.unit:movement():nav_tracker()

	if my_tracker:obstructed() then
		local nav_seg_id = my_tracker:nav_segment()

		if not managers.navigation._nav_segments[nav_seg_id].disabled then
			data.objective.in_place = nil

			data.logic.on_new_objective(data)

			return true
		end
	end
end