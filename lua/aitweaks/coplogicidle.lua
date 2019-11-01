local tmp_vec1 = Vector3()

function CopLogicIdle.queued_update(data)
	local my_data = data.internal_data
	local delay = data.logic._upd_enemy_detection(data)

	if data.internal_data ~= my_data then
		CopLogicBase._report_detections(data.detected_attention_objects)

		return
	end

	local objective = data.objective

	if my_data.has_old_action then
		CopLogicIdle._upd_stop_old_action(data, my_data, objective)
		CopLogicBase.queue_task(my_data, my_data.detection_task_key, CopLogicIdle.queued_update, data, data.t + delay)

		return
	end

	if data.is_converted and (not data.objective or data.objective.type == "free") and (not data.path_fail_t or data.t - data.path_fail_t > 3) then
		managers.groupai:state():on_criminal_jobless(data.unit)

		if my_data ~= data.internal_data then
			return
		end
	end

	if CopLogicIdle._chk_exit_non_walkable_area(data) then
		return
	end

	if CopLogicIdle._chk_relocate(data) then
		return
	end

	CopLogicIdle._perform_objective_action(data, my_data, objective)
	CopLogicIdle._upd_stance_and_pose(data, my_data, objective)
	CopLogicIdle._upd_pathing(data, my_data)
	CopLogicIdle._upd_scan(data, my_data)
	CopLogicIdle._update_haste(data, my_data)
	
	if data.unit:base()._tweak_table == "spooc" and data.attention_obj and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction then
		CopLogicIdle._upd_spooc_attack(data, my_data)
	end

	if data.cool then
		CopLogicIdle.upd_suspicion_decay(data)
	end

	if data.internal_data ~= my_data then
		CopLogicBase._report_detections(data.detected_attention_objects)

		return
	end
	
	if data.is_converted then
		delay = 0
	else
		delay = data.logic._upd_enemy_detection(data)
	end
	
	CopLogicBase.queue_task(my_data, my_data.detection_task_key, CopLogicIdle.queued_update, data, data.t + delay)
end

--Ported to here for more frequent updates to activity, should result in more consistency.
function CopLogicIdle._upd_spooc_attack(data, my_data) --TODO: Optimize it *further*.
	local focus_enemy = data.attention_obj
	
	--Some changes included to make this a bit less weird, I don't know why it calls to the want_to_take_cover but it doesn't do anything good and delays the kick unescessarily.
	if focus_enemy.is_person and focus_enemy.criminal_record and not focus_enemy.criminal_record.status and not my_data.spooc_attack and AIAttentionObject.REACT_SHOOT <= focus_enemy.reaction and not data.unit:movement():chk_action_forbidden("walk") and not SpoocLogicAttack._is_last_standing_criminal(focus_enemy) and not focus_enemy.unit:movement():zipline_unit() and focus_enemy.unit:movement():is_SPOOC_attack_allowed() then
		
		local difficulty_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)
		
		if difficulty_index <= 5 then
			--Nothing, do not execute quick-kicks outside of MH and up.
		else
			--If they're close, just do the kick, no raycast needed, I tested this, and it didn't have any negative effects, just made them kick more often.
			if focus_enemy.verified and focus_enemy.dis <= 250 and math.abs(data.m_pos.z - focus_enemy.m_pos.z) < 100 then 
				if my_data.attention_unit ~= focus_enemy.u_key then
					CopLogicBase._set_attention(data, focus_enemy)
					
					my_data.attention_unit = focus_enemy.u_key
				end

				local action = SpoocLogicAttack._chk_request_action_spooc_attack(data, my_data)

				if action then
					my_data.spooc_attack = {
						start_t = data.t,
						target_u_data = focus_enemy,
						action = action
					}

					return true
				end
			end
		end
		
		--This works great, I'm not sure whether 15m is too little, the original was set to 15m if the cloaker was in cover, and 20m if he wasn't, but this was inconsistent.
		if focus_enemy.verified and focus_enemy.nav_tracker and ActionSpooc.chk_can_start_spooc_sprint(data.unit, focus_enemy.unit) and not data.unit:raycast("ray", data.unit:movement():m_head_pos(), focus_enemy.m_head_pos, "slot_mask", managers.slot:get_mask("bullet_impact_targets_no_criminals"), "ignore_unit", focus_enemy.unit, "report") then
			
			if difficulty_index <= 5 then
				if focus_enemy.dis <= 1000 then --On OVK and below, cloakers can only kick if the player is 10m or closer.
					if my_data.attention_unit ~= focus_enemy.u_key then
						CopLogicBase._set_attention(data, focus_enemy)

						my_data.attention_unit = focus_enemy.u_key
					end

					local action = SpoocLogicAttack._chk_request_action_spooc_attack(data, my_data)

 					if action then
						my_data.spooc_attack = {
							start_t = data.t,
							target_u_data = focus_enemy,
							action = action
						}

						return true
					end
				end
			else
				if focus_enemy.dis <= 1500 then --15m or closer for MH and up.
					if my_data.attention_unit ~= focus_enemy.u_key then
						CopLogicBase._set_attention(data, focus_enemy)

						my_data.attention_unit = focus_enemy.u_key
					end

					local action = SpoocLogicAttack._chk_request_action_spooc_attack(data, my_data)

					if action then
						my_data.spooc_attack = {
							start_t = data.t,
							target_u_data = focus_enemy,
							action = action
						}

						return true
					end
				end
			end

			--No problems here, surprisingly.
			if ActionSpooc.chk_can_start_flying_strike(data.unit, focus_enemy.unit) and focus_enemy.nav_tracker then
				if my_data.attention_unit ~= focus_enemy.u_key then
					CopLogicBase._set_attention(data, focus_enemy)

					my_data.attention_unit = focus_enemy.u_key
				end

				local action = SpoocLogicAttack._chk_request_action_spooc_attack(data, my_data, true)

				if action then
					my_data.spooc_attack = {
						start_t = data.t,
						target_u_data = focus_enemy,
						action = action
					}

					return true
				end
			end
		end
	end
end

function CopLogicIdle._upd_stance_and_pose(data, my_data, objective)
	if data.unit:movement():chk_action_forbidden("walk") then
		return
	end
	
	local diff_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)

	local obj_has_stance, obj_has_pose, agg_pose = nil
	
	if not data.is_converted then
		if data.is_suppressed then
			if diff_index <= 5 and not Global.game_settings.use_intense_AI then
				if not data.unit:anim_data().crouch and (not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.crouch) then
					CopLogicAttack._chk_request_action_crouch(data)
					agg_pose = true
				end
			else
				if not data.unit:anim_data().crouch and (not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.crouch) then
					CopLogicAttack._chk_request_action_crouch(data)
					agg_pose = true
				elseif data.unit:anim_data().crouch and (not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.stand) then
					CopLogicAttack._chk_request_action_stand(data)
					agg_pose = true
				end
			end
		elseif data.attention_obj and data.attention_obj.verified and data.attention_obj.aimed_at and data.attention_obj.reaction >= AIAttentionObject.REACT_COMBAT and data.attention_obj.is_person then
			if diff_index <= 5 and not Global.game_settings.use_intense_AI then
				--nothing
			else
				if not data.unit:anim_data().crouch and (not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.crouch) then
					CopLogicAttack._chk_request_action_crouch(data)
					agg_pose = true
				elseif data.unit:anim_data().crouch and (not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.stand) then
					CopLogicAttack._chk_request_action_stand(data)
					agg_pose = true
				end
			end
		end
	end

	if objective  and not agg_pose then
		if objective.stance and (not data.char_tweak.allowed_stances or data.char_tweak.allowed_stances[objective.stance]) then
			obj_has_stance = true
			local upper_body_action = data.unit:movement()._active_actions[3]

			if not upper_body_action or upper_body_action:type() ~= "shoot" then
				data.unit:movement():set_stance(objective.stance)
			end
		end

		if objective.pose and not agg_pose and (not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses[objective.pose]) then
			obj_has_pose = true

			if objective.pose == "crouch" then
				CopLogicAttack._chk_request_action_crouch(data)
			elseif objective.pose == "stand" then
				CopLogicAttack._chk_request_action_stand(data)
			end
		end
	end

	if not obj_has_stance and data.char_tweak.allowed_stances and not data.char_tweak.allowed_stances[data.unit:anim_data().stance] and not agg_pose then
		for stance_name, state in pairs(data.char_tweak.allowed_stances) do
			if state then
				data.unit:movement():set_stance(stance_name)

				break
			end
		end
	end
	
	if not obj_has_pose and not agg_pose then
		if data.char_tweak.allowed_poses and not data.char_tweak.allowed_poses[data.unit:anim_data().pose] then
			for pose_name, state in pairs(data.char_tweak.allowed_poses) do
				if state then
					if pose_name == "crouch" then
						CopLogicAttack._chk_request_action_crouch(data)

						break
					end

					if pose_name == "stand" then
						CopLogicAttack._chk_request_action_stand(data)
					end

					break
				end
			end
		end
	end
end

function CopLogicIdle._update_haste(data, my_data)
	local diff_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)
	local mook_units = {
		"security",
		"security_undominatable",
		"cop",
		"cop_scared",
		"cop_female",
		"gensec",
		"fbi",
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
		"taser"
	}
	local is_mook = nil
	for _, name in ipairs(mook_units) do
		if data.unit:base()._tweak_table == name then
			is_mook = true
		end
	end
	
	local haste = nil
	local enemyseeninlast4secs = data.attention_obj and data.attention_obj.verified_t and data.t - data.attention_obj.verified_t < 4
	local enemy_seen_range_bonus = enemyseeninlast4secs and 500 or 0
	local enemy_has_height_difference = data.attention_obj and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction and data.attention_obj.dis >= 1200 and data.attention_obj.verified_t and data.t - data.attention_obj.verified_t < 4 and math.abs(data.m_pos.z - data.attention_obj.m_pos.z) > 250
	local should_crouch = nil	
	
	if my_data.cover_path or my_data.charge_path or my_data.chase_path then	
		if is_mook then
			if data.unit:movement():cool() then
				haste = "walk"
			elseif data.attention_obj and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction and data.attention_obj.dis > 1200 + enemy_seen_range_bonus and not data.unit:movement():cool() and not managers.groupai:state():whisper_mode() and data.unit:anim_data().move and is_mook then
				haste = "run"
				my_data.has_reset_walk_cycle = nil
			elseif data.attention_obj and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction and data.attention_obj.dis <= 1200 + enemy_seen_range_bonus - (math.abs(data.m_pos.z - data.attention_obj.m_pos.z) < 250 and 400 or 0) and is_mook and data.tactics and not data.tactics.hitnrun and data.unit:anim_data().run then
				haste = "walk"
				my_data.has_reset_walk_cycle = nil
			 else
				if data.unit:anim_data().move then
					my_data.has_reset_walk_cycle = nil
				end
				haste = "run"
			 end
				 
			local crouch_roll = math.random(0.01, 1)
			local stand_chance = nil
			
			if data.attention_obj and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction and data.attention_obj.dis > 2000 then
				stand_chance = 0.75
			elseif enemy_has_height_difference and (not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.crouch) then
				stand_chance = 0.25
			elseif data.attention_obj and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction and (data.attention_obj.verified and data.attention_obj.dis <= 1500 or data.attention_obj.dis <= 1000) and CopLogicTravel._chk_close_to_criminal(data, my_data) and data.tactics and data.tactics.flank and haste == "walk" then
				stand_chance = 0.25
			elseif my_data.moving_to_cover and (not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.crouch) then
				stand_chance = 0.5
			else
				stand_chance = 0.5
			end
			
			--randomize enemy crouching to make enemies feel less easy to aim at, the fact they're always crouching all over the place always bugged me, plus, they shouldn't need to crouch so often when you're at long distances from them
			
			if not data.unit:movement():cool() and not managers.groupai:state():whisper_mode() then
				if crouch_roll > stand_chance and (not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.crouch) then
					end_pose = "crouch"
					pose = "crouch"
					should_crouch = true
				end
			end
			
			local pose = nil
			pose = not data.char_tweak.crouch_move and "stand" or data.char_tweak.allowed_poses and not data.char_tweak.allowed_poses.stand and "crouch" or should_crouch and "crouch" or "stand"

			if not data.unit:anim_data()[pose] then
				CopLogicAttack["_chk_request_action_" .. pose](data)
			end
			
			if managers.groupai:state():chk_high_fed_density() and data.attention_obj and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction and data.attention_obj.dis < 3000 then
				local randomwalkchance = math.random(0.01, 1)
				if randomwalkchance > 0.10 then
					haste = "walk"
				else
					haste = haste
				end
			end
			
			if not pose then
				pose = not data.char_tweak.crouch_move and "stand" or data.char_tweak.allowed_poses and not data.char_tweak.allowed_poses.stand and "crouch" or "stand"
			end
		elseif data.unit:base()._tweak_table == "tank" or data.unit:base()._tweak_table == "tank_medic" then
			local run_dist = nil
			if difficulty_index == 8 then
				run_dist = 900
				--log("aggressive dozer active")
			else
				run_dist = data.attention_obj.verified and 1200 or 900
			end
			
			if data.attention_obj and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction and data.attention_obj.verified_dis <= run_dist and data.unit:anim_data().run then
				haste = "walk"
				my_data.has_reset_walk_cycle = nil
			elseif data.attention_obj and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction and data.attention_obj.dis > run_dist and data.unit:anim_data().move then
				haste = "run"
				my_data.has_reset_walk_cycle = nil
			end
		end
	end	
	 
	if data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and haste then
		local path = my_data.chase_path or my_data.charge_path or my_data.cover_path
		if not my_data.has_reset_walk_cycle then
			local new_action = {
				body_part = 2,
				type = "idle"
			}

			data.unit:brain():action_request(new_action)
			my_data.has_reset_walk_cycle = true
		else
			local new_action_data = {
				type = "walk",
				body_part = 2,
				nav_path = path,
				variant = haste,
				pose = pose,
				end_pose = end_pose
			}
			my_data.cover_path = nil
			my_data.advancing = data.unit:brain():action_request(new_action_data)

			if my_data.advancing then
				my_data.moving_to_cover = my_data.best_cover
				my_data.at_cover_shoot_pos = nil
				my_data.in_cover = nil

				data.brain:rem_pos_rsrv("path")
			end
		end
	end
end 

function CopLogicIdle._upd_scan(data, my_data)
	if CopLogicIdle._chk_focus_on_attention_object(data, my_data) then
		return
	end
	
	local diff_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)

	if not data.logic.is_available_for_assignment(data) or data.unit:movement():chk_action_forbidden("walk") then
		return
	end

	if not my_data.stare_pos or not my_data.next_scan_t or data.t < my_data.next_scan_t then
		if not my_data.turning and my_data.fwd_offset then
			local return_spin = my_data.rubberband_rotation:to_polar_with_reference(data.unit:movement():m_rot():y(), math.UP).spin

			if math.abs(return_spin) < 15 then
				my_data.fwd_offset = nil
			end

			CopLogicIdle._turn_by_spin(data, my_data, return_spin)
		end

		return
	end

	local beanbag = my_data.scan_beanbag

	if not beanbag then
		beanbag = {}

		for i_pos, pos in ipairs(my_data.stare_pos) do
			table.insert(beanbag, pos)
		end

		my_data.scan_beanbag = beanbag
	end

	local nr_pos = #beanbag
	local scan_pos = nil
	local lucky_i_pos = math.random(nr_pos)
	scan_pos = beanbag[lucky_i_pos]

	if #beanbag == 1 then
		my_data.scan_beanbag = nil
	else
		beanbag[lucky_i_pos] = beanbag[#beanbag]

		table.remove(beanbag)
	end

	CopLogicBase._set_attention_on_pos(data, scan_pos)

	if CopLogicIdle._chk_request_action_turn_to_look_pos(data, my_data, data.m_pos, scan_pos) then
		if my_data.rubberband_rotation then
			my_data.fwd_offset = true
		end

		local upper_body_action = data.unit:movement()._active_actions[3]

		if not upper_body_action then
			local idle_action = {
				body_part = 3,
				type = "idle"
			}

			data.unit:movement():action_request(idle_action)
		end
	end
	
	local reaction_time = nil
	
	if diff_index <= 7 and not Global.game_settings.use_intense_AI then
		reaction_time = 1.4
	else
		reaction_time = 0.7
	end

	my_data.next_scan_t = data.t + reaction_time
end

function CopLogicIdle._get_priority_attention(data, attention_objects, reaction_func)
	reaction_func = reaction_func or CopLogicIdle._chk_reaction_to_attention_object
	local best_target, best_target_priority_slot, best_target_priority, best_target_reaction = nil
	local forced_attention_data = managers.groupai:state():force_attention_data(data.unit)

	if forced_attention_data then
		if data.attention_obj and data.attention_obj.unit == forced_attention_data.unit then
			return data.attention_obj, 1, AIAttentionObject.REACT_SHOOT
		end

		local forced_attention_object = managers.groupai:state():get_AI_attention_object_by_unit(forced_attention_data.unit)

		if forced_attention_object then
			for u_key, attention_info in pairs(forced_attention_object) do
				if forced_attention_data.ignore_vis_blockers then
					local vis_ray = World:raycast("ray", data.unit:movement():m_head_pos(), attention_info.handler:get_detection_m_pos(), "slot_mask", data.visibility_slotmask, "ray_type", "ai_vision")

					if not vis_ray or vis_ray.unit:key() == u_key or not vis_ray.unit:visible() then
						best_target = CopLogicBase._create_detected_attention_object_data(data.t, data.unit, u_key, attention_info, attention_info.handler:get_attention(data.SO_access), true)
						best_target.verified = true
					end
				else
					best_target = CopLogicBase._create_detected_attention_object_data(data.t, data.unit, u_key, attention_info, attention_info.handler:get_attention(data.SO_access), true)
				end
			end
		else
			Application:error("[CopLogicIdle._get_priority_attention] No attention object available for unit", inspect(forced_attention_data))
		end

		if best_target then
			return best_target, 1, AIAttentionObject.REACT_SHOOT
		end
	end

	local near_threshold = data.internal_data.weapon_range.optimal
	local too_close_threshold = data.internal_data.weapon_range.close

	for u_key, attention_data in pairs(attention_objects) do
		local att_unit = attention_data.unit
		local crim_record = attention_data.criminal_record

		if not attention_data.identified then
			-- Nothing
		elseif attention_data.pause_expire_t then
			if attention_data.pause_expire_t < data.t then
				if not attention_data.settings.attract_chance or math.random() < attention_data.settings.attract_chance then
					attention_data.pause_expire_t = nil
				else
					debug_pause_unit(data.unit, "[ CopLogicIdle._get_priority_attention] skipping attraction")

					attention_data.pause_expire_t = data.t + math.lerp(attention_data.settings.pause[1], attention_data.settings.pause[2], math.random())
				end
			end
		elseif attention_data.stare_expire_t and attention_data.stare_expire_t < data.t then
			if attention_data.settings.pause then
				attention_data.stare_expire_t = nil
				attention_data.pause_expire_t = data.t + math.lerp(attention_data.settings.pause[1], attention_data.settings.pause[2], math.random())
			end
		else
			local distance = attention_data.dis
			local reaction = reaction_func(data, attention_data, not CopLogicAttack._can_move(data))

			if data.cool and AIAttentionObject.REACT_SCARED <= reaction then
				data.unit:movement():set_cool(false, managers.groupai:state().analyse_giveaway(data.unit:base()._tweak_table, att_unit))
			end

			local reaction_too_mild = nil

			if not reaction or best_target_reaction and reaction < best_target_reaction then
				reaction_too_mild = true
			elseif distance < 150 and reaction == AIAttentionObject.REACT_IDLE then
				reaction_too_mild = true
			end

			if not reaction_too_mild then
				local aimed_at = CopLogicIdle.chk_am_i_aimed_at(data, attention_data, attention_data.aimed_at and 0.95 or 0.985)
				attention_data.aimed_at = aimed_at
				local alert_dt = attention_data.alert_t and data.t - attention_data.alert_t or 10000
				local dmg_dt = attention_data.dmg_t and data.t - attention_data.dmg_t or 10000
				local status = crim_record and crim_record.status
				local nr_enemies = crim_record and crim_record.engaged_force
				local old_enemy = false

				if data.attention_obj and data.attention_obj.u_key == u_key and data.t - attention_data.acquire_t < 4 then
					old_enemy = true
				end

				local weight_mul = attention_data.settings.weight_mul

				if attention_data.is_local_player then
					if not att_unit:movement():current_state()._moving and att_unit:movement():current_state():ducking() then
						weight_mul = (weight_mul or 1) * managers.player:upgrade_value("player", "stand_still_crouch_camouflage_bonus", 1)
					end

					if managers.player:has_activate_temporary_upgrade("temporary", "chico_injector") and managers.player:upgrade_value("player", "chico_preferred_target", false) then
						weight_mul = (weight_mul or 1) * 1000
					end

					if _G.IS_VR and tweak_data.vr.long_range_damage_reduction_distance[1] < distance then
						local mul = math.clamp(distance / tweak_data.vr.long_range_damage_reduction_distance[2] / 2, 0, 1) + 1
						weight_mul = (weight_mul or 1) * mul
					end
				elseif att_unit:base() and att_unit:base().upgrade_value then
					if att_unit:movement() and not att_unit:movement()._move_data and att_unit:movement()._pose_code and att_unit:movement()._pose_code == 2 then
						weight_mul = (weight_mul or 1) * (att_unit:base():upgrade_value("player", "stand_still_crouch_camouflage_bonus") or 1)
					end

					if att_unit:base().has_activate_temporary_upgrade and att_unit:base():has_activate_temporary_upgrade("temporary", "chico_injector") and att_unit:base():upgrade_value("player", "chico_preferred_target") then
						weight_mul = (weight_mul or 1) * 1000
					end

					if att_unit:movement().is_vr and att_unit:movement():is_vr() and tweak_data.vr.long_range_damage_reduction_distance[1] < distance then
						local mul = math.clamp(distance / tweak_data.vr.long_range_damage_reduction_distance[2] / 2, 0, 1) + 1
						weight_mul = (weight_mul or 1) * mul
					end
				end

				if weight_mul and weight_mul ~= 1 then
					weight_mul = 1 / weight_mul
					alert_dt = alert_dt and alert_dt * weight_mul
					dmg_dt = dmg_dt and dmg_dt * weight_mul
					distance = distance * weight_mul
				end

				local assault_reaction = reaction == AIAttentionObject.REACT_SPECIAL_ATTACK
				local visible = attention_data.verified
				local near = distance < near_threshold
				local too_near = distance < too_close_threshold and math.abs(attention_data.m_pos.z - data.m_pos.z) < 250
				local free_status = status == nil
				local has_alerted = alert_dt < 3.5
				local has_damaged = dmg_dt < 5
				local reviving = nil
				local focus_enemy = attention_data
				
				if not data.unit:in_slot(16) and focus_enemy and (focus_enemy.is_local_player or focus_enemy.is_husk_player) then
					local anim_data = att_unit:anim_data()
					if focus_enemy.is_local_player then
						local e_movement_state = att_unit:movement():current_state()

						if e_movement_state:_is_reloading() or e_movement_state:_interacting() or e_movement_state:is_equipping() then
							pantsdownchk = true
							--log("MURDER TIME, WOO")
						end
					else
						local e_anim_data = att_unit:anim_data()

						if not (e_anim_data.move or e_anim_data.idle) or e_anim_data.reload then
							pantsdownchk = true
							--log("MURDER TIME, WOO")
						end
					end
				end

				if attention_data.is_local_player then
					local iparams = att_unit:movement():current_state()._interact_params

					if iparams and managers.criminals:character_name_by_unit(iparams.object) ~= nil then
						reviving = true
					end
				else
					reviving = att_unit:anim_data() and att_unit:anim_data().revive
				end

				local target_priority = distance
				local target_priority_slot = 0
				
				if visible then
					local murderorspooctargeting = data.tactics and data.tactics.murder or data.tactics and data.tactics.spooctargeting
					local justmurder = data.tactics and data.tactics.murder
					local justharass = data.tactics and data.tactics.harass
					
					if data.tactics and data.tactics.spooctargeting and distance < 1500 then
						target_priority_slot = 1
					elseif distance < 250 and not murderorspooctargeting then
						target_priority_slot = 1
					elseif distance < 500 and not murderorspooctargeting then
						target_priority_slot = 2
					elseif distance < 1500 and not murderorspooctargeting then
						target_priority_slot = 4
					elseif not justmurder then
						target_priority_slot = 6
					end

					if has_damaged and not murderorspooctargeting then
						target_priority_slot = target_priority_slot - 2
					elseif has_alerted and not murderorspooctargeting then
						target_priority_slot = target_priority_slot - 1
					elseif data.tactics and data.tactics.harass and pantsdownchk then
						target_priority_slot = 1
					else
						target_priority_slot = target_priority_slot
					end
					
					if old_enemy then
						target_priority_slot = target_priority_slot - 3
					end
					
					target_priority_slot = math.clamp(target_priority_slot, 1, 10)
				elseif free_status and not justmurder or pantsdownchk and not justharass then
					target_priority_slot = 7
				end
				
				if old_enemy and data.tactics and data.tactics.murder then
					target_priority_slot = 1
					--log("*heavy breathing*")
				end
				
				if assault_reaction and data.unit:base()._tweak_table == "taser" and distance < 1500 then
					target_priority_slot = 1
				end

				if reaction < AIAttentionObject.REACT_COMBAT or data.tactics and data.tactics.murder and not old_enemy then
					target_priority_slot = 20 + target_priority_slot + math.max(0, AIAttentionObject.REACT_COMBAT - reaction)
				end

				if target_priority_slot ~= 0 then
					local best = false

					if not best_target then
						best = true
					elseif target_priority_slot < best_target_priority_slot then
						best = true
					elseif target_priority_slot == best_target_priority_slot and target_priority < best_target_priority then
						best = true
					end

					if best then
						best_target = attention_data
						best_target_reaction = reaction
						best_target_priority_slot = target_priority_slot
						best_target_priority = target_priority
					end
				end
			end
		end
	end

	return best_target, best_target_priority_slot, best_target_reaction
end

function CopLogicIdle.on_alert(data, alert_data)
	local alert_type = alert_data[1]
	local alert_unit = alert_data[5]

	if CopLogicBase._chk_alert_obstructed(data.unit:movement():m_head_pos(), alert_data) then
		return
	end

	local was_cool = data.cool

	if CopLogicBase.is_alert_aggressive(alert_type) then
		data.unit:movement():set_cool(false, managers.groupai:state().analyse_giveaway(data.unit:base()._tweak_table, alert_data[5], alert_data))
	end

	if alert_unit and alive(alert_unit) and alert_unit:in_slot(data.enemy_slotmask) then
		local att_obj_data, is_new = CopLogicBase.identify_attention_obj_instant(data, alert_unit:key())

		if not att_obj_data then
			return
		end

		if alert_type == "bullet" or alert_type == "aggression" or alert_type == "explosion" then
			att_obj_data.alert_t = TimerManager:game():time()
		end

		local action_data = nil

		--if is_new and (not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.stand) and AIAttentionObject.REACT_SURPRISED <= att_obj_data.reaction and data.unit:anim_data().idle and not data.unit:movement():chk_action_forbidden("walk") then
		--	action_data = {
		--		variant = "surprised",
		--		body_part = 1,
		--		type = "act"
		--	}

		--	data.unit:brain():action_request(action_data)
		--end

		if not action_data and alert_type == "bullet" and data.logic.should_duck_on_alert(data, alert_data) then
			action_data = CopLogicAttack._chk_request_action_crouch(data)
		end

		if att_obj_data.criminal_record then
			managers.groupai:state():criminal_spotted(alert_unit)

			if alert_type == "bullet" or alert_type == "aggression" or alert_type == "explosion" then
				managers.groupai:state():report_aggression(alert_unit)
			end
		end
	elseif was_cool and (alert_type == "footstep" or alert_type == "bullet" or alert_type == "aggression" or alert_type == "explosion" or alert_type == "vo_cbt" or alert_type == "vo_intimidate" or alert_type == "vo_distress") then
		local attention_obj = alert_unit and alert_unit:brain() and alert_unit:brain()._logic_data.attention_obj

		if attention_obj then
			slot6, slot7 = CopLogicBase.identify_attention_obj_instant(data, attention_obj.u_key)
		end
	end
end
