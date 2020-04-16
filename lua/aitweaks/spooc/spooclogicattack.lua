function SpoocLogicAttack.queued_update(data)
	local t = TimerManager:game():time()
	data.t = t
	local unit = data.unit
	local my_data = data.internal_data

	if my_data.spooc_attack then
		
		if data.internal_data == my_data then
			CopLogicBase._report_detections(data.detected_attention_objects)
			SpoocLogicAttack.queue_update(data, my_data)
		end

		return
	end

	if my_data.has_old_action then
		SpoocLogicAttack._upd_stop_old_action(data, my_data)
		SpoocLogicAttack.queue_update(data, my_data)

		return
	end

	if CopLogicIdle._chk_relocate(data) then
		return
	end

	if my_data.wants_stop_old_walk_action then
		if not data.unit:anim_data().to_idle and not data.unit:movement():chk_action_forbidden("walk") then
			data.unit:movement():action_request({
				body_part = 2,
				type = "idle"
			})

			my_data.wants_stop_old_walk_action = nil
		end

		SpoocLogicAttack.queue_update(data, my_data)

		return
	end

	SpoocLogicAttack._process_pathing_results(data, my_data)

	if not data.attention_obj or data.attention_obj.reaction < AIAttentionObject.REACT_AIM then
		SpoocLogicAttack._upd_enemy_detection(data, true)

		if my_data ~= data.internal_data or not data.attention_obj then
			return
		end
	end

	SpoocLogicAttack._upd_spooc_attack(data, my_data)

	if my_data.spooc_attack then
		SpoocLogicAttack.queue_update(data, my_data)

		return
	end

	if AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction then
		my_data.want_to_take_cover = SpoocLogicAttack._chk_wants_to_take_cover(data, my_data)

		SpoocLogicAttack._update_cover(data)
		SpoocLogicAttack._upd_combat_movement(data)
	end

	SpoocLogicAttack.queue_update(data, my_data)
	CopLogicBase._report_detections(data.detected_attention_objects)
end

function SpoocLogicAttack._upd_spooc_attack(data, my_data)

	if not my_data then
		return
	end

	if my_data.spooc_attack then
		return
	end

	if not data.is_converted and data.spooc_attack_timeout_t and data.spooc_attack_timeout_t >= data.t then
		return
	end

	local focus_enemy = data.attention_obj

	if focus_enemy and focus_enemy.nav_tracker and focus_enemy.is_person and AIAttentionObject.REACT_SHOOT <= focus_enemy.reaction and not data.unit:movement():chk_action_forbidden("walk") then
		if focus_enemy.criminal_record then
			if focus_enemy.criminal_record.status then
				return
			else
				if SpoocLogicAttack._is_last_standing_criminal(focus_enemy) then
					return
				end
			end
		end

		if focus_enemy.unit:movement().zipline_unit and focus_enemy.unit:movement():zipline_unit() then
			return
		end

		if focus_enemy.unit:movement().is_SPOOC_attack_allowed and not focus_enemy.unit:movement():is_SPOOC_attack_allowed() then
			return
		end

		if focus_enemy.unit:movement().chk_action_forbidden and focus_enemy.unit:movement():chk_action_forbidden("hurt") then
			return true
		end

		if focus_enemy.verified and focus_enemy.verified_dis <= 2500 and ActionSpooc.chk_can_start_spooc_sprint(data.unit, focus_enemy.unit) and not data.unit:raycast("ray", data.unit:movement():m_head_pos(), focus_enemy.m_head_pos, "slot_mask", managers.slot:get_mask("bullet_impact_targets_no_criminals"), "ignore_unit", focus_enemy.unit, "report") then
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

		if ActionSpooc.chk_can_start_flying_strike(data.unit, focus_enemy.unit) then
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

function SpoocLogicAttack._chk_request_action_spooc_attack(data, my_data, flying_strike)
	if data.unit:anim_data().crouch then
		CopLogicAttack._chk_request_action_stand(data)
	end

	data.unit:movement():set_stance_by_code(2)

	local new_action = {
		body_part = 3,
		type = "idle"
	}

	data.unit:brain():action_request(new_action)

	local new_action_data = {
		body_part = 1,
		type = "spooc",
		flying_strike = flying_strike
	}

	if flying_strike then
		new_action_data.blocks = {
			light_hurt = -1,
			heavy_hurt = -1,
			idle = -1,
			turn = -1,
			fire_hurt = -1,
			walk = -1,
			act = -1,
			hurt = -1,
			expl_hurt = -1,
			taser_tased = -1
		}
	end

	local action = data.unit:brain():action_request(new_action_data)

	return action
end

function SpoocLogicAttack.queue_update(data, my_data)
	my_data.update_queued = true
	
	CopLogicBase.queue_task(my_data, my_data.update_queue_id, SpoocLogicAttack.queued_update, data, data.t + 0)
end

function SpoocLogicAttack.action_complete_clbk(data, action)
	local my_data = data.internal_data
	local action_type = action:type()
	
	if action_type == "healed" then
		SpoocLogicAttack._cancel_cover_pathing(data, my_data)
		SpoocLogicAttack._cancel_charge(data, my_data)
	
		if action:expired() then
			SpoocLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
			SpoocLogicAttack._upd_spooc_attack(data)
		end
	elseif action_type == "heal" then
		SpoocLogicAttack._cancel_cover_pathing(data, my_data)
		SpoocLogicAttack._cancel_charge(data, my_data)
	
		if action:expired() then
			--log("hey this actually works!")
			SpoocLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
			SpoocLogicAttack._upd_spooc_attack(data)
		end
	elseif action_type == "walk" then
		my_data.advancing = nil
		if my_data.flank_cover then
			my_data.taking_flank_cover = true
		end
		my_data.flank_cover = nil
		SpoocLogicAttack._cancel_cover_pathing(data, my_data)
		SpoocLogicAttack._cancel_charge(data, my_data)
		if my_data.has_retreated and managers.groupai:state():chk_active_assault_break() then
			my_data.in_retreat_pos = true
		elseif my_data.surprised then
			my_data.surprised = false
		elseif my_data.moving_to_cover then
			if action:expired() then
				if my_data.taking_flank_cover then
					my_data.taken_flank_cover = true
				end
				my_data.taking_flank_cover = nil
				my_data.in_cover = my_data.moving_to_cover
				my_data.cover_enter_t = data.t
			end

			my_data.moving_to_cover = nil
		elseif my_data.walking_to_cover_shoot_pos then
			my_data.walking_to_cover_shoot_pos = nil
			my_data.at_cover_shoot_pos = true
		end
		
		if action:expired() then
			SpoocLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
			SpoocLogicAttack._upd_spooc_attack(data, my_data)
		end
		
	elseif action_type == "shoot" then
		my_data.shooting = nil
	elseif action_type == "tase" then
		if action:expired() and my_data.tasing then
			local record = managers.groupai:state():criminal_record(my_data.tasing.target_u_key)

			if record and record.status then
				data.tase_delay_t = TimerManager:game():time() + 45
			end
			TaserLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
			--SpoocLogicAttack._upd_combat_movement(data)
		end

		managers.groupai:state():on_tase_end(my_data.tasing.target_u_key)

		my_data.tasing = nil
	elseif action_type == "spooc" then
		data.spooc_attack_timeout_t = TimerManager:game():time() + math.lerp(data.char_tweak.spooc_attack_timeout[1], data.char_tweak.spooc_attack_timeout[2], math.random())

		if action:complete() and data.char_tweak.spooc_attack_use_smoke_chance > 0 and math.random() <= data.char_tweak.spooc_attack_use_smoke_chance and not managers.groupai:state():is_smoke_grenade_active() then
			managers.groupai:state():detonate_smoke_grenade(data.m_pos + math.UP * 10, data.unit:movement():m_head_pos(), math.lerp(15, 30, math.random()), false)
		end
		
		if action:expired() then
			data.logic._upd_stance_and_pose(data, data.internal_data)
			--SpoocLogicAttack._upd_combat_movement(data)
			SpoocLogicAttack._upd_spooc_attack(data, my_data)
		end

		my_data.spooc_attack = nil
	elseif action_type == "reload" then
		--Removed the requirement for being important here.
		if action:expired() then
			SpoocLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
			--SpoocLogicAttack._upd_combat_movement(data)
			SpoocLogicAttack._upd_spooc_attack(data, my_data)
		end
	elseif action_type == "turn" then
		if action:expired() then
			SpoocLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
			--SpoocLogicAttack._upd_combat_movement(data)
			SpoocLogicAttack._upd_spooc_attack(data, my_data)
		end
		
		my_data.turning = nil
	elseif action_type == "hurt" then
		SpoocLogicAttack._cancel_cover_pathing(data, my_data)
		SpoocLogicAttack._cancel_charge(data, my_data)
		
		--Removed the requirement for being important here.
		if action:expired() and not CopLogicBase.chk_start_action_dodge(data, "hit") then
			SpoocLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
			--SpoocLogicAttack._upd_combat_movement(data)
			SpoocLogicAttack._upd_spooc_attack(data, my_data)
		end
		
	elseif action_type == "dodge" then
		local timeout = action:timeout()

		if timeout then
			data.dodge_timeout_t = TimerManager:game():time() + math.lerp(timeout[1], timeout[2], math.random())
		end

		SpoocLogicAttack._cancel_cover_pathing(data, my_data)
		SpoocLogicAttack._cancel_charge(data, my_data)
		
		if action:expired() then
			SpoocLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
			--SpoocLogicAttack._upd_combat_movement(data)
			SpoocLogicAttack._upd_spooc_attack(data, my_data)
		end
	end
end

SpoocLogicTravel = class(CopLogicTravel)

function SpoocLogicTravel.action_complete_clbk(data, action)
	local my_data = data.internal_data
	local action_type = action:type()
	
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
	
	local engage_range = my_data.weapon_range.close or 1500
	
	
	--if is_mook then
		--log("AHAHAHAHAH FUCK YEAH IS_MOOK")
	--end
	if action_type == "healed" then
		SpoocLogicAttack._cancel_cover_pathing(data, my_data)
		SpoocLogicAttack._cancel_charge(data, my_data)
	
		if action:expired() then
			SpoocLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
			SpoocLogicAttack._upd_spooc_attack(data, my_data)
			
			if data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.verified_dis <= engage_range and data.attention_obj.verified_t and data.attention_obj.verified_t - data.t < 2 then
				SpoocLogicTravel._upd_combat_movement(data)
			else
				SpoocLogicTravel.upd_advance(data)
			end
		end
	elseif action_type == "heal" then
		SpoocLogicAttack._cancel_cover_pathing(data, my_data)
		SpoocLogicAttack._cancel_charge(data, my_data)
		SpoocLogicAttack._upd_spooc_attack(data, my_data)
	
		if action:expired() then
			SpoocLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
			if data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.verified_dis <= engage_range and data.attention_obj.verified_t and data.attention_obj.verified_t - data.t < 2 then
				SpoocLogicTravel._upd_combat_movement(data)
			else
				SpoocLogicTravel.upd_advance(data)
			end
		end
	elseif action_type == "walk" then
		
		if action:expired() and not my_data.starting_advance_action and my_data.coarse_path_index and not my_data.has_old_action and my_data.advancing then
			my_data.coarse_path_index = my_data.coarse_path_index + 1

			if my_data.coarse_path_index > #my_data.coarse_path then
				debug_pause_unit(data.unit, "[SpoocLogicTravel.action_complete_clbk] invalid coarse path index increment", data.unit, inspect(my_data.coarse_path), my_data.coarse_path_index)

				my_data.coarse_path_index = my_data.coarse_path_index - 1
			end
		end

		my_data.advancing = nil

		if my_data.moving_to_cover then
			if action:expired() then
				if my_data.best_cover then
					managers.navigation:release_cover(my_data.best_cover[1])
				end

				my_data.best_cover = my_data.moving_to_cover

				CopLogicBase.chk_cancel_delayed_clbk(my_data, my_data.cover_update_task_key)

				local high_ray = SpoocLogicTravel._chk_cover_height(data, my_data.best_cover[1], data.visibility_slotmask)
				my_data.best_cover[4] = high_ray
				my_data.in_cover = true
				
				local cover_wait_time = nil
				
				local should_tacticool_wait = data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.dis >= 1200 and data.attention_obj.verified_t and data.t - data.attention_obj.verified_t < math.random(0.35, 1) and math.abs(data.m_pos.z - data.attention_obj.m_pos.z) > 250 --if an enemy is not at semi equal height, and further than 12 meters, and we've seen him at least two to four seconds ago, do a slower, more tacticool approach
				
				if should_tacticool_wait then
					cover_wait_time = math.random(0.4, 0.64) --If there is a height advantage/disadvantage, act tacticool and approach slower.
					--log("HH: cop waiting due to height difference")
				else
					cover_wait_time = math.random(0.35, 0.5) --Keep enemies aggressive and active while still preserving some semblance of what used to be the original pacing while not in Shin Shootout mode
				end
				
				if not is_mook or Global.game_settings.one_down or managers.skirmish.is_skirmish() or data.tactics and data.tactics.hitnrun or data.tactics and data.tactics.murder or data.unit:base():has_tag("takedown") or Global.game_settings.aggroAI or data.is_converted or data.unit:in_slot(16) or data.unit:in_slot(managers.slot:get_mask("criminals")) or data.team and data.team.id == tweak_data.levels:get_default_team_ID("player") then
					my_data.cover_leave_t = data.t - 1
				else
					my_data.cover_leave_t = data.t + cover_wait_time
				end
				
			else
				managers.navigation:release_cover(my_data.moving_to_cover[1])

				if my_data.best_cover then
					local facing_cover = nil
					local dis = mvector3.distance(my_data.best_cover[1][1], data.unit:movement():m_pos())
					local cover_search_dis = nil
					
					if no_cover_search_dis_change or not is_mook then
						cover_search_dis = 100
					else
						cover_search_dis = 250
					end
					
					--if cover_search_dis == 200 then
						--log("thats hot")
					--end

					if dis > cover_search_dis then
						managers.navigation:release_cover(my_data.best_cover[1])

						my_data.best_cover = nil
					end
				end
			end

			my_data.moving_to_cover = nil
		elseif my_data.walking_to_cover_shoot_pos then
			if action:expired() then
				my_data.walking_to_cover_shoot_pos = nil
				my_data.at_cover_shoot_pos = true
			end
		elseif my_data.best_cover then
			local dis = mvector3.distance(my_data.best_cover[1][1], data.unit:movement():m_pos())
			local cover_search_dis = nil
					
			if not is_mook then
				cover_search_dis = 100
			else
				cover_search_dis = 250
			end
			
			if dis > cover_search_dis then
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
		
		if action:expired() then
			SpoocLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
			SpoocLogicAttack._upd_spooc_attack(data, my_data)
			if data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.verified_dis <= engage_range and data.attention_obj.verified_t and data.attention_obj.verified_t - data.t < 2 then
				SpoocLogicTravel._upd_combat_movement(data)
			else
				SpoocLogicTravel.upd_advance(data)
			end
		end
	elseif action_type == "shoot" then		
		my_data.shooting = nil
	elseif action_type == "tase" then
		if action:expired() and my_data.tasing then
			local record = managers.groupai:state():criminal_record(my_data.tasing.target_u_key)

			if record and record.status then
				data.tase_delay_t = TimerManager:game():time() + 45
			end
			TaserLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
			SpoocLogicAttack._upd_spooc_attack(data, my_data)
			if data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.verified_dis <= engage_range and data.attention_obj.verified_t and data.attention_obj.verified_t - data.t < 2 then
				SpoocLogicTravel._upd_combat_movement(data)
			else
				SpoocLogicTravel.upd_advance(data)
			end
		end

		managers.groupai:state():on_tase_end(my_data.tasing.target_u_key)

		my_data.tasing = nil
	elseif action_type == "spooc" then
		data.spooc_attack_timeout_t = TimerManager:game():time() + math.lerp(data.char_tweak.spooc_attack_timeout[1], data.char_tweak.spooc_attack_timeout[2], math.random())

		if action:complete() and data.char_tweak.spooc_attack_use_smoke_chance > 0 and math.random() <= data.char_tweak.spooc_attack_use_smoke_chance and not managers.groupai:state():is_smoke_grenade_active() then
			managers.groupai:state():detonate_smoke_grenade(data.m_pos + math.UP * 10, data.unit:movement():m_head_pos(), math.lerp(15, 30, math.random()), false)
		end
		
		if action:expired() then
			data.logic._upd_stance_and_pose(data, data.internal_data)
			SpoocLogicAttack._upd_spooc_attack(data, my_data)
			if data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.verified_dis <= engage_range and data.attention_obj.verified_t and data.attention_obj.verified_t - data.t < 2 then
				SpoocLogicTravel._upd_combat_movement(data)
			else
				SpoocLogicTravel.upd_advance(data)
			end
		end

		my_data.spooc_attack = nil
	elseif action_type == "reload" then
		--Removed the requirement for being important here.
		if action:expired() then
			SpoocLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
			SpoocLogicAttack._upd_spooc_attack(data, my_data)
			if data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.verified_dis <= engage_range and data.attention_obj.verified_t and data.attention_obj.verified_t - data.t < 2 then
				SpoocLogicTravel._upd_combat_movement(data)
			else
				SpoocLogicTravel.upd_advance(data)
			end
		end
	elseif action_type == "turn" then
		if action:expired() then
			SpoocLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
			SpoocLogicAttack._upd_spooc_attack(data, my_data)
			if data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.verified_dis <= engage_range and data.attention_obj.verified_t and data.attention_obj.verified_t - data.t < 2 then
				SpoocLogicTravel._upd_combat_movement(data)
			else
				SpoocLogicTravel.upd_advance(data)
			end
		end
		
		my_data.turning = nil
	elseif action_type == "hurt" then
		SpoocLogicAttack._cancel_cover_pathing(data, my_data)
		SpoocLogicAttack._cancel_charge(data, my_data)
		
		--Removed the requirement for being important here.
		if action:expired() and not CopLogicBase.chk_start_action_dodge(data, "hit") then
			SpoocLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
			SpoocLogicAttack._upd_spooc_attack(data, my_data)
			if data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.verified_dis <= engage_range and data.attention_obj.verified_t and data.attention_obj.verified_t - data.t < 2 then
				SpoocLogicTravel._upd_combat_movement(data)
			else
				SpoocLogicTravel.upd_advance(data)
			end
		end
		
	elseif action_type == "dodge" then
		local timeout = action:timeout()

		if timeout then
			data.dodge_timeout_t = TimerManager:game():time() + math.lerp(timeout[1], timeout[2], math.random())
		end

		SpoocLogicAttack._cancel_cover_pathing(data, my_data)
		SpoocLogicAttack._cancel_charge(data, my_data)
		
		if action:expired() then
			SpoocLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
			SpoocLogicAttack._upd_spooc_attack(data, my_data)
			if data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.verified_dis <= engage_range and data.attention_obj.verified_t and data.attention_obj.verified_t - data.t < 2 then
				SpoocLogicTravel._upd_combat_movement(data)
			else
				SpoocLogicTravel.upd_advance(data)
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
					debug_pause_unit(data.unit, "[SpoocLogicTravel.action_complete_clbk] exiting without discarding objective", data.unit, inspect(data.objective))
					CopLogicBase._exit(data.unit, wanted_state)
				end
			end
		end
	end
end

function SpoocLogicTravel.queued_update(data)
    local my_data = data.internal_data
    data.t = TimerManager:game():time()
    my_data.close_to_criminal = nil
    local delay = SpoocLogicTravel._upd_enemy_detection(data)
    
    if data.internal_data ~= my_data then
    	return
    end
    
    SpoocLogicTravel.upd_advance(data)
    
    if data.internal_data ~= my_data then
    	return
    end
    
    if not delay then
    	debug_pause_unit(data.unit, "crap!!!", inspect(data))	
    
    	delay = 0.35
    end
	
	local level = Global.level_data and Global.level_data.level_id
	local hostage_count = managers.groupai:state():get_hostage_count_for_chatter() --check current hostage count
	local chosen_panic_chatter = "controlpanic" --set default generic assault break chatter
	
	if hostage_count > 0 and not managers.groupai:state():chk_assault_active_atm() then --make sure the hostage count is actually above zero before replacing any of the lines
		if hostage_count > 3 then  -- hostage count needs to be above 3
			if math.random() < 0.4 then --40% chance
				chosen_panic_chatter = "controlpanic"
			else
				chosen_panic_chatter = "hostagepanic2" --more panicky "GET THOSE HOSTAGES OUT RIGHT NOW!!!" line for when theres too many hostages on the map
			end
		else
			if math.random() < 0.4 then
				chosen_panic_chatter = "controlpanic"
			else
				chosen_panic_chatter = "hostagepanic1" --less panicky "Delay the assault until those hostages are out." line
			end
		end
	end
	
	local chosen_sabotage_chatter = "sabotagegeneric" --set default sabotage chatter for variety's sake
	local skirmish_map = level == "skm_mus" or level == "skm_red2" or level == "skm_run" or level == "skm_watchdogs_stage2" --these shouldnt play on holdout
	local ignore_radio_rules = nil
	
	if level == "branchbank" then --bank heist
		chosen_sabotage_chatter = "sabotagedrill"
	elseif level == "nmh" or level == "man" or level == "framing_frame_3" or level == "rat" or level == "election_day_1" then --various heists where turning off the power is a frequent occurence
		chosen_sabotage_chatter = "sabotagepower"
	elseif level == "chill_combat" or level == "watchdogs_1" or level == "watchdogs_1_night" or level == "watchdogs_2" or level == "watchdogs_2_day" or level == "cane" then
		chosen_sabotage_chatter = "sabotagebags"
		ignore_radio_rules = true
	else
		chosen_sabotage_chatter = "sabotagegeneric" --if none of these levels are the current one, use a generic "Break their gear!" line
	end
	
	local cant_say_clear = data.attention_obj and data.attention_obj.reaction <= AIAttentionObject.REACT_COMBAT and data.attention_obj.verified_t and data.attention_obj.verified_t - data.t < 5
	
    if not data.unit:base():has_tag("special") then
    	if data.char_tweak.chatter.clear and not cant_say_clear and not data.is_converted then
			if data.unit:movement():cool() then
				managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "clear_whisper" )
			else
				local clearchk = math.random(0, 90)
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
			end
		end
    end
	
	if data.unit:base():has_tag("tank") or data.unit:base():has_tag("taser") then
    	if not cant_say_clear then
			managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "approachingspecial" )
		end
    end
	
	if data.unit:base()._tweak_table == "akuma" then
		managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "lotusapproach" )
	end
	
	--mid-assault panic for cops based on alerts instead of opening fire, since its supposed to be generic action lines instead of for opening fire and such
	--I'm adding some randomness to these since the delays in groupaitweakdata went a bit overboard but also arent able to really discern things proper
	
	if data.char_tweak and data.char_tweak.chatter and data.char_tweak.chatter.enemyidlepanic and not data.is_converted and not data.unit:base():has_tag("special") then
		if managers.groupai:state():chk_assault_active_atm() or not data.unit:base():has_tag("law") then
			if data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.alert_t and data.t - data.attention_obj.alert_t < 1 and data.attention_obj.dis <= 3000 then
				if data.attention_obj.verified and data.attention_obj.dis <= 500 or data.is_suppressed and data.attention_obj.verified then
					local roll = math.random(1, 100)
					local chance_suppanic = 30
					
					if roll <= chance_suppanic then
						local nroll = math.random(1, 100)
						local chance_help = 50
						if roll <= chance_suppanic or not data.unit:base():has_tag("law") then
							managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "assaultpanicsuppressed1" )
						else
							managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "assaultpanicsuppressed2" )
						end
					else
						managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "assaultpanic" )
					end
				else
					if math.random() < 0.1 and data.unit:base():has_tag("law") then
						managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, chosen_sabotage_chatter )
					else
						managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "assaultpanic" )
					end
				end
			end
		end
	end
	
	local objective = data.objective or nil
	
	data.logic._update_haste(data, data.internal_data)
	data.logic._upd_stance_and_pose(data, data.internal_data, objective)
	SpoocLogicAttack._upd_spooc_attack(data, my_data)
	
	if CopLogicBase.should_enter_attack(data) then
		CopLogicBase._exit(data.unit, "attack")
		return
	end
      
    SpoocLogicTravel.queue_update(data, data.internal_data, delay)
end

function SpoocLogicTravel._upd_enemy_detection(data)
	managers.groupai:state():on_unit_detection_updated(data.unit)

	local my_data = data.internal_data
	local delay = CopLogicBase._upd_attention_obj_detection(data, nil, nil)
	local new_attention, new_prio_slot, new_reaction = CopLogicIdle._get_priority_attention(data, data.detected_attention_objects, SpoocLogicAttack._chk_reaction_to_attention_object)
	local old_att_obj = data.attention_obj

	CopLogicBase._set_attention_obj(data, new_attention, new_reaction)

	local objective = data.objective
	local allow_trans, obj_failed = CopLogicBase.is_obstructed(data, objective, nil, new_attention)

	if allow_trans and (obj_failed or not objective or objective.type ~= "follow") then
		local wanted_state = CopLogicBase._get_logic_state_from_reaction(data)

		if wanted_state and wanted_state ~= data.name then
			if obj_failed then
				data.objective_failed_clbk(data.unit, data.objective)
			end

			if my_data == data.internal_data and not objective.is_default then
				debug_pause_unit(data.unit, "[SpoocLogicTravel._upd_enemy_detection] exiting without discarding objective", data.unit, inspect(objective))
				CopLogicBase._exit(data.unit, wanted_state)
			end

			CopLogicBase._report_detections(data.detected_attention_objects)

			return delay
		end
	end

	if my_data == data.internal_data then
		if data.cool and new_reaction == AIAttentionObject.REACT_SUSPICIOUS and CopLogicBase._upd_suspicion(data, my_data, new_attention) then
			CopLogicBase._report_detections(data.detected_attention_objects)

			return delay
		elseif new_reaction and new_reaction <= AIAttentionObject.REACT_SCARED then
			local set_attention = data.unit:movement():attention()

			if not set_attention or set_attention.u_key ~= new_attention.u_key then
				CopLogicBase._set_attention(data, new_attention, nil)
			end
		end

		SpoocLogicAttack._upd_aim(data, my_data)
	end

	CopLogicBase._report_detections(data.detected_attention_objects)

	if new_attention and data.char_tweak.chatter.entrance and not data.entrance and new_attention.criminal_record and new_attention.verified and AIAttentionObject.REACT_SCARED <= new_reaction and math.abs(data.m_pos.z - new_attention.m_pos.z) < 4000 then
		data.unit:sound():say(data.brain.entrance_chatter_cue or "entrance", true, nil)

		data.entrance = true
	end

	if data.cool then
		SpoocLogicTravel.upd_suspicion_decay(data)
	end

	return delay
end
