function BlackMarketManager:equipped_grenade_allows_pickups()
	local id = self:equipped_grenade()
	local grenade_tweak = id and tweak_data.blackmarket.projectiles[id]

	return grenade_tweak and grenade_tweak.throwable
end

function BlackMarketManager:equipped_melee_weapon_damage_info(lerp_value)
	lerp_value = lerp_value or 0
	local melee_entry = self:equipped_melee_weapon()
	local stats = tweak_data.blackmarket.melee_weapons[melee_entry].stats
	local primary = self:equipped_primary()
	local bayonet_id = self:equipped_bayonet(primary.weapon_id)
	local player = managers.player:player_unit()

	if bayonet_id and player:movement():current_state()._equipped_unit:base():selection_index() == 2 and melee_entry == "weapon" then
		stats = tweak_data.weapon.factory.parts[bayonet_id].stats
	end
	
	local max_damage = stats.max_damage
	
	--log("max damage is:" .. max_damage .. "")
	
	if managers.player:has_category_upgrade("player", "momentummaker_aced") then
		max_damage = max_damage * 2
		
		--log("mod damage is:" .. max_damage .. "")
	end

	local dmg = math.lerp(stats.min_damage, max_damage, lerp_value)
	local dmg_effect = dmg * math.lerp(stats.min_damage_effect, stats.max_damage_effect, lerp_value)

	return dmg, dmg_effect
end

function BlackMarketManager:recoil_addend(name, categories, recoil_index, silencer, blueprint, current_state, is_single_shot)
	local addend = 0

	if recoil_index and recoil_index >= 1 and recoil_index <= #tweak_data.weapon.stats.recoil then
		local index = recoil_index
		index = index + managers.player:upgrade_value("weapon", "recoil_index_addend", 0)
		index = index + managers.player:upgrade_value("player", "stability_increase_bonus_1", 0)
		index = index + managers.player:upgrade_value("player", "stability_increase_bonus_2", 0)
		index = index + managers.player:upgrade_value(name, "recoil_index_addend", 0)

		for i = 1, #categories do
			local category = categories[i]
			index = index + managers.player:upgrade_value(category, "recoil_index_addend", 0)
			
			if category == "shotgun" then 
				index = index + managers.player:upgrade_value("player", "shot_shoulders_recoil_addend", 0)
			end
		end
		
		if managers.player:player_unit() and managers.player:player_unit():character_damage():is_suppressed() then
			for _, category in ipairs(categories) do
				if managers.player:has_team_category_upgrade(category, "suppression_recoil_index_addend") then
					index = index + managers.player:team_upgrade_value(category, "suppression_recoil_index_addend", 0)
				end
			end

			if managers.player:has_team_category_upgrade("weapon", "suppression_recoil_index_addend") then
				index = index + managers.player:team_upgrade_value("weapon", "suppression_recoil_index_addend", 0)
			end
		else
			for _, category in ipairs(categories) do
				if managers.player:has_team_category_upgrade(category, "recoil_index_addend") then
					index = index + managers.player:team_upgrade_value(category, "recoil_index_addend", 0)
				end
			end

			if managers.player:has_team_category_upgrade("weapon", "recoil_index_addend") then
				index = index + managers.player:team_upgrade_value("weapon", "recoil_index_addend", 0)
			end
		end

		if silencer then
			index = index + managers.player:upgrade_value("weapon", "silencer_recoil_index_addend", 0)

			for _, category in ipairs(categories) do
				index = index + managers.player:upgrade_value(category, "silencer_recoil_index_addend", 0)
			end
		end

		if blueprint and self:is_weapon_modified(managers.weapon_factory:get_factory_id_by_weapon_id(name), blueprint) then
			index = index + managers.player:upgrade_value("weapon", "modded_recoil_index_addend", 0)
		end

		index = math.clamp(index, 1, #tweak_data.weapon.stats.recoil)

		if index ~= recoil_index then
			local diff = tweak_data.weapon.stats.recoil[index] - tweak_data.weapon.stats.recoil[recoil_index]
			addend = addend + diff
		end
	end

	return addend
end

function BlackMarketManager:damage_multiplier(name, categories, silencer, detection_risk, current_state, blueprint)
	local multiplier = 1
	
	if tweak_data.weapon[name] and tweak_data.weapon[name].ignore_damage_upgrades then
		return multiplier
	end
	
	if managers.player:has_category_upgrade("player", "flexmode") then
		multiplier = multiplier - 0.25
	end
	
	if managers.player:has_category_upgrade("player", "criticalmode") then
		multiplier = multiplier - 0.25
	end
	
	for _, category in ipairs(categories) do
		multiplier = multiplier + 1 - managers.player:upgrade_value(category, "damage_multiplier", 1)
	end

	multiplier = multiplier + 1 - managers.player:upgrade_value(name, "damage_multiplier", 1)
	multiplier = multiplier + 1 - managers.player:upgrade_value("player", "passive_damage_multiplier", 1)
	multiplier = multiplier + 1 - managers.player:upgrade_value("weapon", "passive_damage_multiplier", 1)

	if silencer then
		multiplier = multiplier + 1 - managers.player:upgrade_value("weapon", "silencer_damage_multiplier", 1)
	end

	local detection_risk_damage_multiplier = managers.player:upgrade_value("player", "detection_risk_damage_multiplier")
	multiplier = multiplier - managers.player:get_value_from_risk_upgrade(detection_risk_damage_multiplier, detection_risk)

	if managers.player:has_category_upgrade("player", "overkill_health_to_damage_multiplier") then
		local damage_ratio = managers.player:upgrade_value("player", "overkill_health_to_damage_multiplier", 1) - 1
		multiplier = multiplier + damage_ratio
	end

	if current_state and not current_state:in_steelsight() then
		for _, category in ipairs(categories) do
			multiplier = multiplier + 1 - managers.player:upgrade_value(category, "hip_fire_damage_multiplier", 1)
		end
	end

	if blueprint and self:is_weapon_modified(managers.weapon_factory:get_factory_id_by_weapon_id(name), blueprint) then
		multiplier = multiplier + 1 - managers.player:upgrade_value("weapon", "modded_damage_multiplier", 1)
	end

	multiplier = multiplier + 1 - managers.player:get_property("trigger_happy", 1)

	return self:_convert_add_to_mul(multiplier)
end
