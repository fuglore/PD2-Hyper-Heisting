Hooks:PostHook(UpgradesTweakData, "init", "skillupgrades", function(self, tweak_data)
	if PD2THHSHIN and PD2THHSHIN:IsOverhaulEnabled() then
		self.values.temporary.overkill_damage_multiplier = {{1.25, 8}}
		self.values.pistol.damage_addend = {0.5, 1}
		self.values.pistol.fire_rate_multiplier = {1.25}
		self.values.pistol.reload_speed_multiplier = {1.25}
	end
	
	self.definitions.player_jackpot_safety = {
		name_id = "menu_jackpot_safety",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "jackpot_safety",
			category = "player"
		}
	}
	
	self.values.player.jackpot_safety = {
		true
	}
	
end )