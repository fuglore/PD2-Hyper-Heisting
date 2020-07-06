function CopLogicIntimidated._add_delayed_rescue_SO(data, my_data)
	if data.char_tweak.flee_type ~= "hide" then
		if data.unit:unit_data() and data.unit:unit_data().not_rescued then
			-- Nothing
		elseif my_data.delayed_clbks and my_data.delayed_clbks[my_data.delayed_rescue_SO_id] then
			managers.enemy:reschedule_delayed_clbk(my_data.delayed_rescue_SO_id, TimerManager:game():time() + 2)
		else
			if my_data.rescuer then
				local objective = my_data.rescuer:brain():objective()
				local rescuer = my_data.rescuer
				my_data.rescuer = nil

				managers.groupai:state():on_objective_failed(rescuer, objective)
			elseif my_data.rescue_SO_id then
				managers.groupai:state():remove_special_objective(my_data.rescue_SO_id)

				my_data.rescue_SO_id = nil
			end

			my_data.delayed_rescue_SO_id = "rescue" .. tostring(data.unit:key())

			CopLogicBase.add_delayed_clbk(my_data, my_data.delayed_rescue_SO_id, callback(CopLogicIntimidated, CopLogicIntimidated, "register_rescue_SO", data), TimerManager:game():time() + 2)
		end
	end
end

function CopLogicIntimidated.register_rescue_SO(ignore_this, data)
	local my_data = data.internal_data

	CopLogicBase.on_delayed_clbk(my_data, my_data.delayed_rescue_SO_id)

	my_data.delayed_rescue_SO_id = nil
	local my_tracker = data.unit:movement():nav_tracker()
	local objective_pos = my_tracker:field_position()
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
	local objective = {
		stance = "hos",
		type = "act",
		scan = true,
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
				action = -1,
				walk = -1
			}
		},
		action_duration = tweak_data.interaction.free.timer,
		followup_objective = followup_objective
	}
	local so_descriptor = {
		interval = 2,
		search_dis_sq = 1000000,
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