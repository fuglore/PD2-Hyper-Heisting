function ObjectivesManager:activate_objective(id, load_data, data)
	if not id or not self._objectives[id] then
		Application:stack_dump_error("Bad id to activate objective, " .. tostring(id) .. ".")

		return
	end

	Telemetry:send_on_player_tutorial(id)
	Telemetry:on_start_objective(id)

	local objective = self._objectives[id]

	for _, sub_objective in pairs(objective.sub_objectives) do
		sub_objective.completed = false
	end

	objective.current_amount = load_data and load_data.current_amount or data and data.amount and 0 or objective.current_amount
	objective.amount = load_data and load_data.amount or data and data.amount or objective.amount
	
	--log(tostring(id))
	local activate_params = {
		id = id,
		text = objective.text,
		sub_objectives = objective.sub_objectives,
		amount = objective.amount,
		current_amount = objective.current_amount,
		amount_text = objective.amount_text
	}
	self._delayed_presentation = nil

	if data and data.delay_presentation then
		self._delayed_presentation = {
			t = 1,
			activate_params = activate_params
		}
	else
		managers.hud:activate_objective(activate_params)
	end

	if not load_data then
		local title_message = data and data.title_message or managers.localization:text("mission_objective_activated")
		local text = objective.text

		if self._delayed_presentation then
			self._delayed_presentation.mid_text_params = {
				time = 4,
				text = text,
				title = title_message,
				event = self:get_stinger_id()
			}
		else
			managers.hud:present_mid_text({
				time = 4,
				text = text,
				title = title_message,
				event = self:get_stinger_id()
			})
		end
	end

	self._active_objectives[id] = objective
	self._remind_objectives[id] = {
		next_t = Application:time() + self.REMINDER_INTERVAL
	}
end