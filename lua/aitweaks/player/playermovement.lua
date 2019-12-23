function PlayerMovement:is_taser_attack_allowed()
	if self._unit:character_damage():get_mission_blocker("invulnerable") or self._current_state_name == "driving" or self._unit:base().parachuting then
		return
	end

	return true
end