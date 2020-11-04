function ElementSpawnEnemyGroup:spawn_groups()
	local opt = {}
	
	local has_regular_enemies = nil
	
	if not self._values.preferred_spawn_groups then --prevents a crash.
		for cat_name, team in pairs(tweak_data.group_ai.enemy_spawn_groups) do
			if cat_name ~= "Phalanx" then
				table.insert(opt, cat_name)
			end
		end
		
		return opt
	end
	
	for name, name2 in pairs(self._values.preferred_spawn_groups) do
		if name2 == "tac_swat_rifle" or name2 == "tac_bull_rush" then
			--log("fuck yes")
			has_regular_enemies = true
		end
	end
	
	if not has_regular_enemies then
		--log("i hate this")
		return self._values.preferred_spawn_groups
	else
		for cat_name, team in pairs(tweak_data.group_ai.enemy_spawn_groups) do
			if cat_name ~= "Phalanx" then
				table.insert(opt, cat_name)
			end
		end
		
		return opt
	end
end
