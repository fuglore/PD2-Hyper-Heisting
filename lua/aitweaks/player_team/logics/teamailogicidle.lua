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