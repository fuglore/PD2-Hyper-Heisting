Hooks:PostHook(SkillTreeTweakData, "init", "skillrebalances", function(self, tweak_data)
	if PD2THHSHIN and PD2THHSHIN:IsOverhaulEnabled() then
	
	self.skills.overkill[2].upgrades = {"player_overkill_damage_multiplier"}
	self.skills.overkill[1].upgrades = {"player_killshot_close_panic_chance"}	
	self.skills.perseverance[2].upgrades = {"temporary_berserker_damage_multiplier_2"}
	self.skills.perseverance[1].upgrades = {"temporary_berserker_damage_multiplier_1"}
	
	end
end)