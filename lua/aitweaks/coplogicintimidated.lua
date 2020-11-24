function CopLogicIntimidated._add_delayed_rescue_SO(data, my_data)
	if data.char_tweak.flee_type ~= "hide" then
		if data.unit:unit_data() and data.unit:unit_data().not_rescued then
			-- Nothing
		elseif my_data.delayed_clbks and my_data.delayed_clbks[my_data.delayed_rescue_SO_id] then
			managers.enemy:reschedule_delayed_clbk(my_data.delayed_rescue_SO_id, TimerManager:game():time() + 2)
		else
			if my_data.rescuer then
				local rescuer = my_data.rescuer
								
				if alive(rescuer) and rescuer:brain() and rescuer:brain():objective() then
					managers.groupai:state():on_objective_failed(rescuer, rescuer:brain():objective())
				end
				my_data.rescuer = nil
			elseif my_data.rescue_SO_id then
				managers.groupai:state():remove_special_objective(my_data.rescue_SO_id)

				my_data.rescue_SO_id = nil
			end

			--my_data.delayed_rescue_SO_id = "rescue" .. tostring(data.unit:key())

			 CopLogicIntimidated.register_rescue_SO(nil, data)
		end
	end
end

function CopLogicIntimidated.register_rescue_SO(ignore_this, data)
	local my_data = data.internal_data

	--CopLogicBase.on_delayed_clbk(my_data, my_data.delayed_rescue_SO_id)

	my_data.delayed_rescue_SO_id = nil
	local my_tracker = nil
	local objective_pos = nil
	
	if data.unit and data.unit:character_damage() and not data.unit:character_damage():dead() and data.unit:movement() and data.unit:movement():nav_tracker() then
		my_tracker = data.unit:movement():nav_tracker()
		objective_pos = my_tracker:field_position()
	end
	
	if not my_tracker then
		--log("go fuck yourself")
		
		return
	end
	
	local followup_objective = {
		scan = true,
		type = "act",
		stance = "hos",
		action = {
			variant = "idle",
			body_part = 1,
			type = "act",
			blocks = {
				action = -1,
				walk = -1
			}
		},
		action_duration = tweak_data.interaction.free.timer
	}
	
	local diff_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)	
	
	local interrupt_health = nil
	local interrupt_dis = nil
	
	if not Global.game_settings.one_down then
		if diff_index < 4 then
			interrupt_health = 0.75
			interrupt_dis = 700
		elseif diff_index < 6 then
			interrupt_health = 0.5
			interrupt_dis = nil
		else
			interrupt_health = 0.1
			interrupt_dis = nil
		end
	end
	
	local objective = {
		stance = "hos",
		type = "act",
		scan = true,
		interrupt_health = interrupt_health,
		interrupt_dis = interrupt_dis,
		destroy_clbk_key = false,
		follow_unit = data.unit,
		pos = mvector3.copy(objective_pos),
		nav_seg = data.unit:movement():nav_tracker():nav_segment(),
		fail_clbk = callback(CopLogicIntimidated, CopLogicIntimidated, "on_rescue_SO_failed", data),
		complete_clbk = callback(CopLogicIntimidated, CopLogicIntimidated, "on_rescue_SO_completed", data),
		action = {
			variant = "untie",
			body_part = 1,
			type = "act",
			blocks = {
				light_hurt = -1,
				action = -1,
				walk = -1
			}
		},
		action_duration = tweak_data.interaction.free.timer,
		followup_objective = followup_objective
	}
	
	local interval = nil
	
	if Global.game_settings.one_down then
		interval = 0.1
	else
		if diff_index < 4 then
			interval = 8
		elseif diff_index < 6 then
			interval = 5
		else
			interval = 0.1
		end
	end
	
	local so_descriptor = {
		interval = interval,
		search_dis_sq = 4000000,
		AI_group = "enemies",
		base_chance = 1,
		chance_inc = 0,
		usage_amount = 1,
		objective = objective,
		search_pos = mvector3.copy(data.m_pos),
		admin_clbk = callback(CopLogicIntimidated, CopLogicIntimidated, "on_rescue_SO_administered", data),
		verification_clbk = callback(CopLogicIntimidated, CopLogicIntimidated, "rescue_SO_verification", data)
	}
	local so_id = "rescue" .. tostring(data.unit:key())
	my_data.rescue_SO_id = so_id

	managers.groupai:state():add_special_objective(so_id, so_descriptor)
end

function CopLogicIntimidated._unregister_rescue_SO(data, my_data)
	if my_data.rescuer then
		local rescuer = my_data.rescuer
		if alive(rescuer) and rescuer:brain() and rescuer:brain():objective() then
			managers.groupai:state():on_objective_failed(rescuer, rescuer:brain():objective())
		end
		my_data.rescuer = nil
	elseif my_data.rescue_SO_id then
		managers.groupai:state():remove_special_objective(my_data.rescue_SO_id)

		my_data.rescue_SO_id = nil
	elseif my_data.delayed_rescue_SO_id then
		CopLogicBase.chk_cancel_delayed_clbk(my_data, my_data.delayed_rescue_SO_id)
	end
end

function CopLogicIntimidated.on_rescue_SO_failed(ignore_this, data)
	local my_data = data.internal_data

	if my_data.rescuer then
		my_data.rescuer = nil
		my_data.delayed_rescue_SO_id = "rescue" .. tostring(data.unit:key())

		CopLogicIntimidated.register_rescue_SO(nil, data)
	end
end
