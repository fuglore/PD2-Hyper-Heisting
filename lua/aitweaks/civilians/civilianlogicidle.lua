function CivilianLogicIdle.on_alert(data, alert_data)
	local my_data = data.internal_data
	local my_dis, alert_delay = nil
	local my_listen_pos = data.unit:movement():m_head_pos()
	local alert_epicenter = alert_data[2]

	if CopLogicBase._chk_alert_obstructed(data.unit:movement():m_head_pos(), alert_data) then
		return
	end
	
	if CopLogicBase.is_alert_aggressive(alert_data[1]) and not data.unit:base().unintimidateable then
		if not data.unit:movement():cool() then
			local aggressor = alert_data[5]

			if aggressor and aggressor:base() then
				local is_intimidation = nil

				if aggressor:base().is_local_player then
					if managers.player:has_category_upgrade("player", "civ_calming_alerts") then
						is_intimidation = true
					end
				elseif aggressor:base().is_husk_player and aggressor:base():upgrade_value("player", "civ_calming_alerts") then
					is_intimidation = true
				end

				if is_intimidation then
					if not data.brain:interaction_voice() then
						data.unit:brain():on_intimidated(1, aggressor)
					end

					return
				end
			end
		end

		data.unit:movement():set_cool(false, managers.groupai:state().analyse_giveaway(data.unit:base()._tweak_table, alert_data[5], alert_data))
		data.unit:movement():set_stance(data.is_tied and "cbt" or "hos")
	end

	if alert_data[5] then
		local att_obj_data, is_new = CopLogicBase.identify_attention_obj_instant(data, alert_data[5]:key())
	end

	if my_data == data.internal_data and not data.char_tweak.ignores_aggression then
		if not my_data.delayed_alert_id then
			my_data.delayed_alert_id = "alert" .. tostring(data.key)

			CopLogicBase.add_delayed_clbk(my_data, my_data.delayed_alert_id, callback(CivilianLogicIdle, CivilianLogicIdle, "_delayed_alert_clbk", {
				data = data,
				alert_data = clone(alert_data)
			}), TimerManager:game():time())
		end
	end
end

function CivilianLogicIdle._upd_outline_detection(data)
	local my_data = data.internal_data

	if data.been_outlined or data.has_outline then
		return
	end

	local t = TimerManager:game():time()
	local visibility_slotmask = managers.slot:get_mask("AI_visibility")
	local seen = false
	local seeing_unit = nil
	local my_tracker = data.unit:movement():nav_tracker()
	local chk_vis_func = my_tracker.check_visibility

	for e_key, record in pairs(managers.groupai:state():all_criminals()) do
		local enemy_pos = record.m_det_pos
		local my_pos = data.unit:movement():m_head_pos()

		if mvector3.distance_sq(enemy_pos, my_pos) < 1440000 then
			local not_hit = World:raycast("ray", my_pos, enemy_pos, "slot_mask", visibility_slotmask, "ray_type", "ai_vision", "report")

			if not not_hit then
				seen = true
				seeing_unit = record.unit

				break
			end
		end
	end

	if seen then
		CivilianLogicIdle._enable_outline(data)
	else
		CopLogicBase.queue_task(my_data, my_data.outline_detection_task_key, CivilianLogicIdle._upd_outline_detection, data, t + 0.33)
	end
end

function CivilianLogicIdle._upd_detection(data)
	managers.groupai:state():on_unit_detection_updated(data.unit)

	data.t = TimerManager:game():time()
	local my_data = data.internal_data
	local delay = CopLogicBase._upd_attention_obj_detection(data, nil, nil)
	local new_attention, new_reaction = CivilianLogicIdle._get_priority_attention(data, data.detected_attention_objects)

	CivilianLogicIdle._set_attention_obj(data, new_attention, new_reaction)

	if new_reaction and AIAttentionObject.REACT_SCARED <= new_reaction then
		local objective = data.objective
		local trans_objective = CivilianLogicIdle.is_obstructed(data, new_attention.unit)
		local allow_trans, obj_failed = CopLogicBase.is_obstructed(data, objective, nil, new_attention)

		if trans_objective then
			local alert = {
				"vo_cbt",
				new_attention.m_head_pos,
				[5] = new_attention.unit
			}

			CivilianLogicIdle.on_alert(data, alert)

			if my_data ~= data.internal_data then
				return
			end
		end
	elseif not data.char_tweak.ignores_attention_focus then
		CopLogicIdle._chk_focus_on_attention_object(data, my_data)
	end

	if not data.unit:movement():cool() and (not my_data.acting or not not data.unit:anim_data().act_idle) then
		local objective = data.objective

		if not objective or objective.interrupt_dis == -1 or objective.is_default then
			local alert = {
				"vo_cbt",
				data.m_pos
			}

			CivilianLogicIdle.on_alert(data, alert)

			if my_data ~= data.internal_data then
				return
			end
		end
	end

	if CopLogicIdle._chk_relocate(data) then
		return
	end

	CopLogicBase.queue_task(my_data, my_data.detection_task_key, CivilianLogicIdle._upd_detection, data, data.t + delay)
end