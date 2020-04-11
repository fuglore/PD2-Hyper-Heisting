Hooks:PostHook(InteractionTweakData, "init", "hh_interactions", function(self, tweak_data)
	if PD2THHSHIN and PD2THHSHIN:IsOverhaulEnabled() then
		self.c4.timer = 2
		self.requires_ecm_jammer_double.timer = 4
		self.c4_special.timer = 2
		self.shaped_sharge.timer = 2		
		self.shape_charge_plantable.timer = 2				
		self.hold_blow_torch.timer = 0
		self.gen_pku_blow_torch.timer = 0		
		self.hold_start_scan.timer = 3
		self.hold_new_hack.timer = 3
		self.hold_type_in_password.timer = 5
		self.take_pardons.timer = 0		
		self.take_pardons.sound_start = "money_grab"	
		self.take_pardons.sound_event = "money_grab"	
		self.take_pardons.sound_done = "money_grab"			
		self.gage_assignment.timer = 0		
		self.gage_assignment.sound_start = "money_grab"	
		self.gage_assignment.sound_event = "money_grab"	
		self.gage_assignment.sound_done = "money_grab"	
	end
end)