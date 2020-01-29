function CopLogicArrest.enter(data, new_logic_name, enter_params)
	CopLogicBase.enter(data, new_logic_name, enter_params)
	data.unit:brain():cancel_all_pathing_searches()

	local old_internal_data = data.internal_data
	local my_data = {
		unit = data.unit
	}
	data.internal_data = my_data
	my_data.detection = data.char_tweak.detection.guard
	my_data.arrest_targets = {}

	if old_internal_data then
		if old_internal_data.best_cover then
			my_data.best_cover = old_internal_data.best_cover

			managers.navigation:reserve_cover(my_data.best_cover[1], data.pos_rsrv_id)
		end

		if old_internal_data.nearest_cover then
			my_data.nearest_cover = old_internal_data.nearest_cover

			managers.navigation:reserve_cover(my_data.nearest_cover[1], data.pos_rsrv_id)
		end
	end

	local key_str = tostring(data.key)
	my_data.update_task_key = "CopLogicArrest.queued_update" .. key_str

	CopLogicBase.queue_task(my_data, my_data.update_task_key, CopLogicArrest.queued_update, data, data.t)
	data.unit:brain():set_update_enabled_state(false)

	if (not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.stand) and not data.unit:anim_data().stand then
		CopLogicAttack._chk_request_action_stand(data)
	end

	data.unit:movement():set_cool(false)

	if my_data ~= data.internal_data then
		return
	end

	if data.objective and (data.objective.nav_seg or data.objective.type == "follow") and not data.objective.in_place then
		debug_pause_unit(data.unit, "[CopLogicArrest.enter] wrong logic1", data.unit, "objective", inspect(data.objective))
	end

	if data.unit:movement():stance_name() == "ntl" then
		data.unit:movement():set_stance("cbt")
	end

	CopLogicIdle._chk_has_old_action(data, my_data)
	data.unit:brain():set_attention_settings({
		cbt = true
	})

	my_data.next_action_delay_t = data.t + math.random(1, 2.5)
	my_data.weapon_range = data.char_tweak.weapon[data.unit:inventory():equipped_unit():base():weapon_tweak_data().usage].range
	
	local objective_chk = data.objective and data.objective.nav_seg or data.objective and data.objective.type == "follow"

	if objective_chk and not data.objective.in_place then
		--log("woahwhat")
		--debug_pause_unit(data.unit, "[CopLogicArrest.enter] wrong logic2", data.unit, "objective", inspect(data.objective))
	end
end

function CopLogicArrest.queued_update(data)
	data.t = TimerManager:game():time()
	local my_data = data.internal_data

	CopLogicArrest._upd_enemy_detection(data)

	if my_data ~= data.internal_data then
		return
	end

	if my_data.has_old_action then
		CopLogicIdle._upd_stop_old_action(data, my_data, data.objective)
		CopLogicBase.queue_task(my_data, my_data.update_task_key, CopLogicArrest.queued_update, data, data.t, data.important)

		return
	end

	local attention_obj = data.attention_obj
	local arrest_data = attention_obj and my_data.arrest_targets[attention_obj.u_key]

	if not data.unit:anim_data().reload and not data.unit:movement():chk_action_forbidden("action") then
		if attention_obj and AIAttentionObject.REACT_ARREST <= attention_obj.reaction then
			if not my_data.shooting and not data.unit:anim_data().reload then
				local shoot_action = {
					body_part = 3,
					type = "shoot"
				}

				if data.unit:brain():action_request(shoot_action) then
					my_data.shooting = true
				end
			end
		elseif my_data.shooting and not data.unit:anim_data().reload then
			local idle_action = {
				body_part = 3,
				type = "idle"
			}

			data.unit:brain():action_request(idle_action)
		elseif data.unit:movement():stance_name() == "ntl" then
			data.unit:movement():set_stance("cbt")
		end
	end

	if arrest_data then
		if not arrest_data.intro_t then
			arrest_data.intro_t = data.t

			data.unit:sound():say("i01", true)

			if not attention_obj.is_human_player then
				attention_obj.unit:brain():on_intimidated(1, data.unit)
			end

			if not data.unit:movement():chk_action_forbidden("action") then
				local new_action = {
					variant = "arrest",
					body_part = 1,
					type = "act"
				}

				if data.unit:brain():action_request(new_action) then
					my_data.gesture_arrest = true
				end
			end
		elseif not arrest_data.intro_pos and data.t - arrest_data.intro_t > 1 then
			arrest_data.intro_pos = mvector3.copy(attention_obj.m_pos)
		end
	end

	if arrest_data and arrest_data.intro_pos or my_data.should_stand_close then
		CopLogicArrest._upd_advance(data, my_data, attention_obj, arrest_data)
	end

	if attention_obj and not my_data.turning and not my_data.advancing and not data.unit:movement():chk_action_forbidden("walk") then
		CopLogicIdle._chk_request_action_turn_to_look_pos(data, my_data, data.m_pos, attention_obj.m_pos)
	end

	CopLogicArrest._upd_cover(data)
	CopLogicBase.queue_task(my_data, my_data.update_task_key, CopLogicArrest.queued_update, data, data.t + 0.032, data.important)
	CopLogicBase._report_detections(data.detected_attention_objects)
end

function CopLogicArrest._upd_advance(data, my_data, attention_obj, arrest_data)
	local action_taken = my_data.turning or data.unit:movement():chk_action_forbidden("walk")

	if arrest_data and my_data.should_arrest then
		if attention_obj.dis < 180 then
			if not action_taken then
				if not data.unit:anim_data().idle_full_blend then
					if attention_obj.dis < 150 and not data.unit:anim_data().idle then
						local action_data = {
							body_part = 1,
							type = "idle"
						}

						data.unit:brain():action_request(action_data)
					end
				end

				if data.unit:anim_data().idle_full_blend then
					attention_obj.unit:movement():on_cuffed()
					data.unit:sound():say("i03", true, false)

					return
				end
			end
		elseif not arrest_data.approach_snd and attention_obj.dis < 600 and attention_obj.dis > 500 and not data.unit:sound():speaking(data.t) then
			arrest_data.approach_snd = true

			data.unit:sound():say("i02", true)
		end
	elseif my_data.should_arrest and attention_obj.dis < 300 and not data.unit:sound():speaking(data.t) then
		CopLogicArrest._chk_say_approach(data, my_data, attention_obj)
	end

	if action_taken then
		return
	end
	local pose_chk = not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses and data.char_tweak.allowed_poses.stand
	
	if my_data.advancing then
		-- Nothing
	elseif my_data.advance_path then
		if my_data.next_action_delay_t < data.t and not data.unit:movement():chk_action_forbidden("walk") then
			if pose_chk and my_data.should_stand_close and not data.unit:anim_data().stand then
				CopLogicAttack._chk_request_action_stand(data)
			end

			local new_action_data = {
				variant = "walk",
				body_part = 2,
				type = "walk",
				nav_path = my_data.advance_path
			}
			my_data.advance_path = nil
			my_data.advancing = data.unit:brain():action_request(new_action_data)
		end
	elseif my_data.processing_path then
		CopLogicArrest._process_pathing_results(data, my_data)
	elseif not my_data.in_position and my_data.next_action_delay_t < data.t then
		if my_data.should_arrest then
			my_data.path_search_id = "cuff" .. tostring(data.key)
			my_data.processing_path = true

			if attention_obj.nav_tracker:lost() then
				data.unit:brain():search_for_path(my_data.path_search_id, attention_obj.nav_tracker:field_position(), 1)
			else
				data.unit:brain():search_for_path_to_unit(my_data.path_search_id, attention_obj.unit)
			end
		elseif my_data.should_stand_close and attention_obj then
			CopLogicArrest._say_scary_stuff_discovered(data)

			local close_pos = CopLogicArrest._get_att_obj_close_pos(data, my_data)

			if close_pos then
				my_data.path_search_id = "stand_close" .. tostring(data.key)
				my_data.processing_path = true

				data.unit:brain():search_for_path(my_data.path_search_id, close_pos, 1, nil)
			else
				my_data.in_position = true
			end
		else
			--log("oh.")
			--debug_pause_unit(data.unit, "not sure what I am supposed to do", data.unit, inspect(data.attention_obj), inspect(my_data))
		end
	end
end

function CopLogicArrest._upd_enemy_detection(data)
	managers.groupai:state():on_unit_detection_updated(data.unit)

	data.t = TimerManager:game():time()
	local my_data = data.internal_data
	local delay = CopLogicBase._upd_attention_obj_detection(data, nil, nil)
	local all_attention_objects = data.detected_attention_objects
	local arrest_targets = my_data.arrest_targets

	CopLogicArrest._verify_arrest_targets(data, my_data)

	local new_attention, new_prio_slot, new_reaction = CopLogicArrest._get_priority_attention(data, data.detected_attention_objects)
	local old_att_obj = data.attention_obj

	CopLogicBase._set_attention_obj(data, new_attention, new_reaction)

	local should_arrest = new_reaction == AIAttentionObject.REACT_ARREST
	local should_stand_close = new_reaction == AIAttentionObject.REACT_SCARED or new_attention and new_attention.criminal_record and new_attention.criminal_record.status

	if should_arrest ~= my_data.should_arrest or should_stand_close ~= my_data.should_stand_close then
		my_data.should_arrest = should_arrest
		my_data.should_stand_close = should_stand_close

		CopLogicArrest._cancel_advance(data, my_data)
	end

	if should_arrest and not my_data.arrest_targets[new_attention.u_key] then
		my_data.arrest_targets[new_attention.u_key] = {
			attention_obj = new_attention
		}

		managers.groupai:state():on_arrest_start(data.key, new_attention.u_key)
	end

	CopLogicArrest._mark_call_in_event(data, my_data, new_attention)
	CopLogicArrest._chk_say_discovery(data, my_data, new_attention)

	if not my_data.should_arrest and not my_data.should_stand_close then
		my_data.in_position = true
	end

	local current_attention = data.unit:movement():attention()

	if new_attention and not current_attention or current_attention and not new_attention or new_attention and current_attention.u_key ~= new_attention.u_key then
		if new_attention then
			CopLogicBase._set_attention(data, new_attention)
		else
			CopLogicBase._reset_attention(data)
		end
	end

	if new_reaction ~= AIAttentionObject.REACT_ARREST then
		local new_reaction_chk = not new_reaction or new_reaction < AIAttentionObject.REACT_SHOOT or not new_attention.verified or new_attention.dis >= 1500
		local arrest_chk = my_data.in_position or not my_data.should_arrest and not my_data.should_stand_close
		if new_reaction_chk and arrest_chk then
			if data.char_tweak.calls_in and my_data.next_action_delay_t < data.t and not managers.groupai:state():is_police_called() and not my_data.calling_the_police and not my_data.turning and not data.unit:sound():speaking(data.t) then
				CopLogicArrest._call_the_police(data, my_data, true)

				return
			end
			
			local police_called_chk = managers.groupai:state():is_police_called() or managers.groupai:state():chk_enemy_calling_in_area(managers.groupai:state():get_area_from_nav_seg_id(data.unit:movement():nav_tracker():nav_segment()), data.key)
			
			if police_called_chk and not my_data.calling_the_police then
				local wanted_state = CopLogicBase._get_logic_state_from_reaction(data) or "idle"

				CopLogicBase._exit(data.unit, wanted_state)
				CopLogicBase._report_detections(data.detected_attention_objects)

				return
			end
		else
			local wanted_state = CopLogicBase._get_logic_state_from_reaction(data)

			if wanted_state and wanted_state ~= data.name then
				if my_data.calling_the_police then
					local action_data = {
						body_part = 3,
						type = "idle"
					}

					data.unit:brain():action_request(action_data)
				end
				--log("cop that was " .. data.name .. " just became " .. wanted_state .. ".")
				CopLogicBase._exit(data.unit, wanted_state)
				CopLogicBase._report_detections(data.detected_attention_objects)

				return
			end
		end
	end
end