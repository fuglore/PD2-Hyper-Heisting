Hooks:PostHook(LootDropTweakData, "init", "lootdroptweakshit", function(self, tweak_data)		   
	self.global_values.hyperheist = {}
    self.global_values.hyperheist.name_id = "menu_l_global_value_hyperheisting"
    self.global_values.hyperheist.desc_id = "menu_l_global_value_hyperheisting_desc"
    self.global_values.hyperheist.color = Color('#010000')
    self.global_values.hyperheist.dlc = false
    self.global_values.hyperheist.chance = 0
    self.global_values.hyperheist.value_multiplier = tweak_data:get_value("money_manager", "global_value_multipliers", "normal")
    self.global_values.hyperheist.durability_multiplier = 1
    self.global_values.hyperheist.drops = false
    self.global_values.hyperheist.track = false
    self.global_values.hyperheist.sort_number = 30
    self.global_values.hyperheist.category = "hyperheist"	
end)