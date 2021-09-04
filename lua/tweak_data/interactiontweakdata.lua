Hooks:PostHook(InteractionTweakData, "init", "hh_interactions", function(self, tweak_data)
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
	
	self.pick_lock_easy.timer = 5
	self.pick_lock_easy_no_skill.timer = 5
	self.pick_lock_deposit_transport.timer = 6
	self.pick_lock_hard.timer = 10
	self.pick_lock_hard_no_skill.timer = 10
	self.pex_pick_lock_easy_no_skill.timer = 5
	
	self.drill_upgrade.timer = 6
	self.drill_jammed.timer = 6
	self.glass_cutter_jammed.timer = 6
	self.hack_ipad_bp1.timer = 6
	self.hack_ipad_jammed.timer = 6
	self.security_station_jammed.timer = 6
	
	self.hold_moon_attach_winch.timer = 2
	self.hold_friend_attach_winch.timer = 2
	self.rewire_friend_fuse_box.timer = 4
	self.hold_born_receive_item_blow_torch.timer = 0
	self.hold_born_search_tools.timer = 3
	self.hold_turn_off_gas.timer = 3
	self.hold_remove_hand.timer = 3
	self.dark_screw_down.timer = 1
	self.drk_hold_hack_computer.timer = 5
	self.man_trunk_picklock.timer = 15
	self.hold_insert_paper_roll.timer = 2
	
	--Henry's Rock
	self.hold_charge_gun.timer = 3
	self.hold_remove_battery.timer = 2
	
	--FEX
	self.fex_take_fertilizer.timer = 1
	self.fex_take_fertilizer_axis.timer = 1
	self.fex_take_diesel.timer = 1
	self.fex_take_diesel_axis.timer = 1
	self.fex_place_scythe.timer = 2
	self.fex_place_globe.timer = 2
	self.fex_place_fertilizer.timer = 1
	self.fex_place_diesel.timer = 1
	self.fex_place_gasoline.timer = 1
	
end)