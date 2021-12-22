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
	
	for name, name2 in pairs(self._values.preferred_spawn_groups) do
		if name2 == "tac_swat_rifle" or name2 == "tac_swat_rifle_flank" or name2 == "tac_bull_rush" then --check for three vanilla enemy groups that might get inserted into the spawngroups, these three are frequent enough in both official maps and custom maps to basically work 90% of the time
			--log("fuck yes")
			has_regular_enemies = true
		end
	end
	
	if not has_regular_enemies then
		
	else
		for cat_name, team in pairs(tweak_data.group_ai.enemy_spawn_groups) do
			if cat_name ~= "Phalanx" then
				table.insert(preferreds, cat_name)
			end
		end
		
		self._values.preferred_spawn_groups = preferreds
	end
end
