function TeamAILogicBase.on_objective_unit_destroyed(data, unit)
	if not data.objective.taserrescue then
		data.objective.destroy_clbk_key = nil
		data.objective.death_clbk_key = nil

		data.objective_failed_clbk(data.unit, data.objective)
	else
		data.objective_complete_clbk(data.unit, data.objective)
	end
end