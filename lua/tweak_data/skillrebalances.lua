Hooks:PostHook(SkillTreeTweakData, "init", "skillrebalances", function(self, tweak_data)
	if PD2THHSHIN and PD2THHSHIN:IsOverhaulEnabled() then
		table.insert(self.default_upgrades, "carry_movement_penalty_nullifier")		
		table.insert(self.default_upgrades, "player_pick_lock_easy_speed_multiplier_1")
		table.insert(self.default_upgrades, "player_can_free_run")
		table.insert(self.default_upgrades, "player_run_and_reload")
		
		self.skills.spotter_teamwork = {
			{
				upgrades = {
					"player_magic_bullet_basic"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"player_magic_bullet_aced"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_single_shot_ammo_return_beta",
			desc_id = "menu_single_shot_ammo_return_beta_desc",
			icon_xy = {
				8,
				4
			}
		}
		
		self.skills.second_chances[2].upgrades = {"player_pick_lock_easy_speed_multiplier_2", "player_pick_lock_hard"}
		
		self.skills.juggernaut[2].upgrades = {"player_armor_multiplier_cooler"}
		self.skills.juggernaut[1].upgrades = {"player_armor_multiplier", "body_armor6"}
				
		self.skills.overkill[2].upgrades = {"player_overkill_damage_multiplier"}
		self.skills.overkill[1].upgrades = {"player_killshot_close_panic_chance"}	
		
		self.skills.fast_fire[1].upgrades = {"player_automatic_mag_increase_1"}	
		self.skills.fast_fire[2].upgrades = {"player_pop_pop"}

		
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
		
		self.skills.messiah = {
			{
				upgrades = {
					"player_messiah_revive_from_bleed_out_1"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"player_phoenix_down"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_pistol_beta_messiah",
			desc_id = "menu_pistol_beta_messiah_desc",
			icon_xy = {
				2,
				9
			}
		}
		
		--nice name, "awareness", like, you can totally tell this fucking skilltree didnt go through 30 iterations
		self.skills.awareness = {
			{
				upgrades = {
					"player_wavedash"
				},
				cost = self.costs.default
			},
			{
				upgrades = {
					"start_action_stam_drain_reduct"
				},
				cost = self.costs.pro
			},
			name_id = "menu_awareness_beta",
			desc_id = "menu_awareness_beta_desc",
			icon_xy = {
				10,
				6
			}
		}
		
		self.skills.backstab = {
			{
				upgrades = {
					"player_detection_risk_add_crit_chance_1",
					"player_detection_risk_add_crit_chance_2"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"player_crit_damage_up"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_backstab_beta",
			desc_id = "menu_backstab_beta_desc",
			icon_xy = {
				0,
				12
			}
		}
		
		--High Vigour
		self.skills.sprinter = {
			{
				upgrades = {
					"player_stamina_regen_timer_multiplier",
					"player_stamina_regen_multiplier"
				},
				cost = self.costs.default
			},
			{
				upgrades = {
					"player_highvigour_aced"
				},
				cost = self.costs.pro
			},
			name_id = "menu_sprinter_beta",
			desc_id = "menu_sprinter_beta_desc",
			icon_xy = {
				10,
				5
			}
		}
		
		--Sneakier Bastard
		self.skills.jail_diet = {
			{
				upgrades = {
					"player_detection_risk_add_dodge_chance_1",
					"player_detection_risk_add_dodge_chance_2"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"player_sneakier_aced"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_jail_diet_beta",
			desc_id = "menu_jail_diet_beta_desc",
			icon_xy = {
				1,
				12
			}
		}
		
		self.skills.steroids = {
			{
				upgrades = {
					"player_non_special_melee_multiplier",
					"player_melee_damage_multiplier",
					"player_beatemup_basic"
				},
				cost = self.costs.default
			},
			{
				upgrades = {
					"player_beatemup_aced"
				},
				cost = self.costs.pro
			},
			name_id = "menu_steroids_beta",
			desc_id = "menu_steroids_beta_desc",
			icon_xy = {
				1,
				3
			}
		}
		
		self.skills.bloodthirst = {
			{
				upgrades = {
					"player_momentummaker_basic"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"player_momentummaker_aced"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_bloodthirst",
			desc_id = "menu_bloodthirst_desc",
			icon_xy = {
				11,
				6
			}
		}

	end
end)