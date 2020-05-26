Hooks:PostHook(EquipmentsTweakData, "init", "bosnian_trick", function(self)
	if PD2THHSHIN and PD2THHSHIN:IsOverhaulEnabled() then
		self.trip_mine.deploy_time = 0
	end
end)