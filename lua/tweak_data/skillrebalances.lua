Hooks:PostHook(SkillTreeTweakData, "init", "skillrebalances", function(self, tweak_data)
	if PD2THHSHIN and PD2THHSHIN:IsOverhaulEnabled() then
		table.insert(self.default_upgrades, "carry_movement_penalty_nullifier")		
		table.insert(self.default_upgrades, "player_pick_lock_easy_speed_multiplier_1")
		
		self.skills.second_chances[2].upgrades = {"player_pick_lock_easy_speed_multiplier_2", "player_pick_lock_hard"}
		
		self.skills.juggernaut[2].upgrades = {"player_armor_multiplier_cooler"}
		self.skills.juggernaut[1].upgrades = {"player_armor_multiplier", "body_armor6"}
				
		self.skills.overkill[2].upgrades = {"player_overkill_damage_multiplier"}
		self.skills.overkill[1].upgrades = {"player_killshot_close_panic_chance"}	
		
		self.skills.fast_fire[2].upgrades = {"player_automatic_mag_increase_1"}
		self.skills.fast_fire[1].upgrades = {"player_ap_bullets_1"}	
		
		self.skills.carbon_blade[1].upgrades = {"saw_damage_mult", "saw_enemy_slicer"}	
			
		self.skills.perseverance[2].upgrades = {"temporary_berserker_damage_multiplier_2"}
		self.skills.perseverance[1].upgrades = {"temporary_berserker_damage_multiplier_1"}

		self.skills.oppressor.icon_xy = {2.03, 11.9}
		
		self.skills.prison_wife = {
			{
				upgrades = {
					"player_headshot_regen_armor_bonus_1"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"player_jackpot_safety"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_prison_wife_beta",
			desc_id = "menu_prison_wife_beta_desc",
			icon_xy = {
				6,
				11
			}
		}
		
		self.skills.wolverine = {
			{
				upgrades = {
					"player_melee_damage_health_ratio_multiplier"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"player_strong_spirit"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_wolverine_beta",
			desc_id = "menu_wolverine_beta_desc",
			icon_xy = {
				2,
				2
			}
		}
		
		self.skills.frenzy = {
			{
				upgrades = {
					"player_max_health_reduction_1",
					"player_flexmode"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"player_criticalmode"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_frenzy",
			desc_id = "menu_frenzy_desc",
			icon_xy = {
				11,
				8
			}
		}

	end
end)