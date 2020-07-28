function TeamAILogicIdle.is_available_for_assignment(data, new_objective)
	if data.internal_data.exiting then
		return
	elseif data.path_fail_t and data.t < data.path_fail_t + 3 then
		return
		--log("really")
	elseif data.objective then
		if data.internal_data.performing_act_objective and not data.unit:anim_data().act_idle then
			return
		end

		if new_objective and (new_objective.type ~= "follow" and not new_objective.called) and CopLogicBase.is_obstructed(data, new_objective, 0.2) then
			return
			--log("heck")
		end

		local old_objective_type = data.objective.type

		if not new_objective then
			-- Nothing
		elseif old_objective_type == "revive" then
			return
		elseif old_objective_type == "follow" and data.objective.called then
			return
			--log("aight")
		end
	end

	return true
end

function TeamAILogicIdle._get_priority_attention(data, attention_objects, reaction_func)
	reaction_func = reaction_func or TeamAILogicBase._chk_reaction_to_attention_object
	local best_target, best_target_priority_slot, best_target_priority, best_target_reaction = nil
	local has_special_in_sight = nil
	local has_enemy_in_face = nil
	local targeting_medic = nil
	
	for u_key, attention_data in pairs(attention_objects) do
		local att_unit = attention_data.unit
		local crim_record = attention_data.criminal_record

		if not attention_data.identified then
			-- Nothing
		elseif attention_data.pause_expire_t then
			if attention_data.pause_expire_t < data.t then
				attention_data.pause_expire_t = nil
			end
		elseif attention_data.stare_expire_t and attention_data.stare_expire_t < data.t then
			if attention_data.settings.pause then
				attention_data.stare_expire_t = nil
				attention_data.pause_expire_t = data.t + math.lerp(attention_data.settings.pause[1], attention_data.settings.pause[2], math.random())
			end
		else
			local distance = mvector3.distance(data.m_pos, attention_data.m_pos)
			local reaction = reaction_func(data, attention_data, not CopLogicAttack._can_move(data))
			local aimed_at = TeamAILogicIdle.chk_am_i_aimed_at(data, attention_data, attention_data.aimed_at and 0.95 or 0.985)
			attention_data.aimed_at = aimed_at
			local reaction_too_mild = nil

			if not reaction or best_target_reaction and reaction < best_target_reaction then
				reaction_too_mild = true
			elseif distance < 150 and reaction <= AIAttentionObject.REACT_SURPRISED then
				reaction_too_mild = true
			end

			if not reaction_too_mild then
				local alert_dt = attention_data.alert_t and data.t - attention_data.alert_t or 10000
				local dmg_dt = attention_data.dmg_t and data.t - attention_data.dmg_t or 10000
				local mark_dt = attention_data.mark_t and data.t - attention_data.mark_t or 10000
				local old_enemy = nil
				local near_threshold = 1500

				if data.attention_obj and data.attention_obj.u_key == u_key then
					old_enemy = true
				end

				local visible = attention_data.verified
				local near = distance < near_threshold
				local literallyinmyface = distance <= 80
				local meleerange = distance <= 200
				local threemeters = distance <= 300
				local fourmeters = distance <= 400
				local fivemeters = distance <= 500
				local sixmeters = distance <= 600
				local sevenmeters = distance <= 700
				local has_alerted = alert_dt < 2.5
				local has_damaged = dmg_dt < 2
				local been_marked = mark_dt < 8
				local dangerous_special = attention_data.unit:base().has_tag and attention_data.unit:base():has_tag("takedown")
				local is_shield = attention_data.is_shield
				local is_dozer = attention_data.unit:base().has_tag and attention_data.unit:base():has_tag("tank")
				local is_medic = attention_data.unit:base().has_tag and attention_data.unit:base():has_tag("medic")
				local is_cloaker = attention_data.unit:base().has_tag and attention_data.unit:base():has_tag("spooc")
				local is_taser = attention_data.unit:base().has_tag and attention_data.unit:base():has_tag("taser")
				local target_priority = distance
				local target_priority_slot = 0
				local is_shielded = TeamAILogicIdle._ignore_shield and TeamAILogicIdle._ignore_shield(data.unit, attention_data) or nil
				
				if visible then
					if is_medic then
						target_priority_slot = 1
						has_special_in_sight = true
						targeting_medic = true
					elseif dangerous_special or been_marked then
						if is_taser or is_cloaker then
							target_priority_slot = 1
							has_special_in_sight = true
						elseif is_dozer then
							if sevenmeters then
								target_priority_slot = 1
								has_special_in_sight = true
							else
								target_priority_slot = 3
							end
						else
							target_priority_slot = 3
						end
					elseif literallyinmyface and reaction >= AIAttentionObject.REACT_COMBAT and not has_enemy_in_face and not targeting_medic and not has_special_in_sight then
						target_priority_slot = 1
						has_enemy_in_face = true
					elseif aimed_at then		
						if meleerange and not has_enemy_in_face then
							target_priority_slot = 1
						elseif threemeters then
							target_priority_slot = 2
						elseif fourmeters then
							target_priority_slot = 3
						elseif fivemeters then
							target_priority_slot = 4
						elseif sevenmeters then
							target_priority_slot = 5
						elseif near and (has_alerted and has_damaged or been_marked or is_shield and not is_shielded) then
							target_priority_slot = 6
						else
							target_priority_slot = 7
						end
					elseif has_damaged then
						target_priority_slot = 8
					elseif has_alerted then
						target_priority_slot = 9
					else
						target_priority_slot = 10
					end
						
					if old_enemy and not has_enemy_in_face and not targeting_medic then
						target_priority_slot = target_priority_slot - 1
					end
					
					if has_special_in_sight and not dangerous_special then
						target_priority_slot = target_priority_slot + 1
					end
					
					if has_damaged then
						target_priority_slot = target_priority_slot - 1
					end

					if is_shielded then
						target_priority_slot = math.min(8, target_priority_slot + 1)
					end
				elseif has_damaged then
					target_priority_slot = 5
				elseif has_alerted then
					target_priority_slot = 7
				else
					target_priority_slot = 8
				end

				if is_shielded then
					target_priority = target_priority * 10
				end

				if reaction < AIAttentionObject.REACT_COMBAT then
					target_priority_slot = 20 + target_priority_slot + math.max(0, AIAttentionObject.REACT_COMBAT - reaction)
				end

				if target_priority_slot then
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
						best_target_priority_slot = target_priority_slot
						best_target_priority = target_priority
						best_target_reaction = reaction
					end
				end
			end
		end
	end

	return best_target, best_target_priority_slot, best_target_reaction
end
