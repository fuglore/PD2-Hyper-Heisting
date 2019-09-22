function SpoocLogicAttack._upd_spooc_attack(data, my_data) --TODO: Optimize it *further*.
	local focus_enemy = data.attention_obj
	
	--Some changes included to make this a bit less weird, I don't know why it calls to the want_to_take_cover but it doesn't do anything good and delays the kick unescessarily.
	if focus_enemy.is_person and focus_enemy.criminal_record and not focus_enemy.criminal_record.status and not my_data.spooc_attack and AIAttentionObject.REACT_SHOOT <= focus_enemy.reaction and not data.unit:movement():chk_action_forbidden("walk") and not SpoocLogicAttack._is_last_standing_criminal(focus_enemy) and not focus_enemy.unit:movement():zipline_unit() and focus_enemy.unit:movement():is_SPOOC_attack_allowed() then
		
		local difficulty_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)
		
		if difficulty_index <= 5 and not Global.game_settings.use_intense_AI then
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
			
			if difficulty_index <= 5 and not Global.game_settings.use_intense_AI then
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

function SpoocLogicAttack.queue_update(data, my_data)
	my_data.update_queued = true

	CopLogicBase.queue_task(my_data, my_data.update_queue_id, SpoocLogicAttack.queued_update, data, data.t + 0.01)
end