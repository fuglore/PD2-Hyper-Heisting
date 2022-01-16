function ElementMissionEnd:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	if self._values.state ~= "none" and managers.platform:presence() == "Playing" then
		if self._values.state == "success" then
			local num_winners = managers.network:session():amount_of_alive_players()
			
			if managers.groupai:state()._point_of_no_return_timer then
				managers.network:session():send_to_peers("mission_ended", true, num_winners)
				game_state_machine:change_state_by_name("victoryscreen", {
					num_winners = num_winners,
					personal_win = alive(managers.player:player_unit())
				})
			else
				managers.enemy:add_delayed_clbk("hh_mission_ended", callback(managers.game_play_central, managers.game_play_central, "end_heist", num_winners), Application:time() + 4)
			end
			
		elseif self._values.state == "failed" then
			managers.network:session():send_to_peers("mission_ended", false, 0)
			game_state_machine:change_state_by_name("gameoverscreen")
		elseif self._values.state == "leave" then
			MenuCallbackHandler:leave_mission()
		elseif self._values.state == "leave_safehouse" and instigator:base().is_local_player then
			MenuCallbackHandler:leave_safehouse()
		end
	elseif Application:editor() then
		managers.editor:output_error("Cant change to state " .. self._values.state .. " in mission end element " .. self._editor_name .. ".")
	end

	ElementMissionEnd.super.on_executed(self, instigator)
end