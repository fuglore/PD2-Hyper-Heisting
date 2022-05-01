function ElementSpawnEnemyGroup:_finalize_values()
	local values = self._values

	if values.team == "default" then
		values.team = nil
	end
	
	local has_regular_enemies = nil
	
	local preferreds = {}
	
	if not self._values.preferred_spawn_groups then --prevents a crash.
		self._values.preferred_spawn_groups = {}
		
		for cat_name, team in pairs(tweak_data.group_ai.enemy_spawn_groups) do
			if cat_name ~= "Phalanx" then
				table.insert(self._values.preferred_spawn_groups, cat_name)
			end
		end
		
		return
	end
	
	local has_regular_enemies = true
	local cloaker_allowed = true
	
	for name, name2 in pairs(self._values.preferred_spawn_groups) do
		if name2 == "single_spooc" or name2 == "Phalanx" then
			has_regular_enemies = nil
			
			if name2 == "phalanx" then
				cloaker_allowed = nil
			end
			
			break
		end
	end
	
	if not has_regular_enemies then
		if cloaker_allowed then
			table.insert(preferreds, "FBI_spoocs")
			
			self._values.preferred_spawn_groups = preferreds
		end
	else
		for cat_name, team in pairs(tweak_data.group_ai.enemy_spawn_groups) do
			if cat_name ~= "Phalanx" then
				table.insert(preferreds, cat_name)
			end
		end
		
		self._values.preferred_spawn_groups = preferreds
	end
end
