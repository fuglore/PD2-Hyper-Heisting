Hooks:PostHook(SkillTreeTweakData, "init", "skillrebalances", function(self, tweak_data)
	if PD2THHSHIN and PD2THHSHIN:IsOverhaulEnabled() then
		table.insert(self.default_upgrades, "carry_movement_penalty_nullifier")		
		table.insert(self.default_upgrades, "player_pick_lock_easy_speed_multiplier_1")
		table.insert(self.default_upgrades, "player_can_free_run")
		table.insert(self.default_upgrades, "player_run_and_reload")
		table.insert(self.default_upgrades, "first_aid_kit_deploy_time_multiplier")
		--table.insert(self.default_upgrades, "first_aid_kit_deploy_time_multiplier") WIP
		
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
		
		self.skills.juggernaut[2].upgrades = {"player_health_increase"}
		self.skills.juggernaut[1].upgrades = {"player_armor_multiplier_cooler", "body_armor6"}
				
		self.skills.overkill[2].upgrades = {"player_overkill_damage_multiplier"}
		self.skills.overkill[1].upgrades = {"player_killshot_close_panic_chance"}	
		
		self.skills.fast_fire[1].upgrades = {"player_automatic_mag_increase_1"}	
		self.skills.fast_fire[2].upgrades = {"player_pop_pop"}

		self.skills.carbon_blade[1].upgrades = {"saw_damage_mult", "saw_enemy_slicer"}	
			
		self.skills.perseverance[2].upgrades = {"temporary_berserker_damage_multiplier_2"}
		self.skills.perseverance[1].upgrades = {"temporary_berserker_damage_multiplier_1"}

		self.skills.oppressor.icon_xy = {2.03, 11.9}
		
		self.skills.tea_time = { 
			{
				upgrades = {
					"player_soldiersyringe_basic"
				},
				cost = self.costs.default
			},
			{
				upgrades = {
					"player_soldiersyringe_aced"
				},
				cost = self.costs.pro
			},
			name_id = "menu_tea_time_beta",
			desc_id = "menu_tea_time_beta_desc",
			icon_xy = {
				1,
				11
			}
		}
		
		self.skills.tea_cookies = {
			{
				upgrades = {
					"first_aid_kit_quantity_increase_1"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"first_aid_kit_auto_recovery_1",
					"first_aid_kit_quantity_increase_2"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_tea_cookies_beta",
			desc_id = "menu_tea_cookies_beta_desc",
			icon_xy = {
				2,
				11
			}
		}
		
		self.skills.medic_2x = {
			{
				upgrades = {
					"doctor_bag_amount_increase1"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"player_antilethal_meds"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_medic_2x_beta",
			desc_id = "menu_medic_2x_beta_desc",
			icon_xy = {
				5,
				8
			}
		}
		
		self.skills.single_shot_ammo_return = {
			{
				upgrades = {
					"player_fineredmist_basic"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"player_fineredmist_aced"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_sniper_graze_damage",
			desc_id = "menu_sniper_graze_damage_desc",
			icon_xy = {
				11,
				9
			}
		}
		
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
	
		self.skills.oppressor = {
			{
				upgrades = {
					"player_flashbang_multiplier_1",
					"player_flashbang_multiplier_2"
				},
				cost = self.costs.default
			},
			{
				upgrades = {
					"player_armor_regen_time_mul_1"
				},
				cost = self.costs.pro
			},
			name_id = "menu_oppressor_beta",
			desc_id = "menu_oppressor_beta_desc",
			icon_xy = {
				2,
				12
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
		
		self.skills.nine_lives = {
			{
				upgrades = {
					"player_comeback"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"player_additional_lives_1"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_nine_lives_beta",
			desc_id = "menu_nine_lives_beta_desc",
			icon_xy = {
				5,
				2
			}
		}
		
		self.skills.feign_death = {
			{
				upgrades = {
					"player_dark_metamorphosis_basic"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"player_dark_metamorphosis_aced"
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_feign_death",
			desc_id = "menu_feign_death_desc",
			icon_xy = {
				11,
				5
			}
		}
		
		self.skills.nine_lives = {
			{
				upgrades = {
					"player_comeback"
				},
				cost = self.costs.hightier
			},
			{
				upgrades = {
					"player_phoenix_down",
				},
				cost = self.costs.hightierpro
			},
			name_id = "menu_nine_lives_beta",
			desc_id = "menu_nine_lives_beta_desc",
			icon_xy = {
				5,
				2
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
					"player_additional_lives_1"
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
	
	self.specializations[11][1].upgrades = { --grinder nerf
		"player_damage_to_hot_1",
		"player_perk_max_health_reduction"
	}
		
	self.trees = {
		{
			skill = "mastermind",
			name_id = "st_menu_mastermind_inspire",
			unlocked = true,
			background_texture = "guis/textures/pd2/skilltree/bg_mastermind",
			tiers = {
				{
					"combat_medic"
				},
				{
					"tea_time",
					"fast_learner"
				},
				{
					"tea_cookies",
					"medic_2x"
				},
				{
					"inspire"
				}
			}
		},
		{
			skill = "mastermind",
			name_id = "st_menu_mastermind_dominate",
			unlocked = true,
			background_texture = "guis/textures/pd2/skilltree/bg_mastermind",
			tiers = {
				{
					"triathlete"
				},
				{
					"cable_guy",
					"joker"
				},
				{
					"stockholm_syndrome",
					"control_freak"
				},
				{
					"black_marketeer"
				}
			}
		},
		{
			skill = "mastermind",
			name_id = "st_menu_mastermind_single_shot",
			unlocked = true,
			background_texture = "guis/textures/pd2/skilltree/bg_mastermind",
			tiers = {
				{
					"stable_shot"
				},
				{
					"rifleman",
					"sharpshooter"
				},
				{
					"spotter_teamwork",
					"speedy_reload"
				},
				{
					"single_shot_ammo_return"
				}
			}
		},
		{
			skill = "enforcer",
			name_id = "st_menu_enforce_shotgun",
			unlocked = true,
			background_texture = "guis/textures/pd2/skilltree/bg_mastermind",
			tiers = {
				{
					"underdog"
				},
				{
					"shotgun_cqb",
					"shotgun_impact"
				},
				{
					"far_away",
					"close_by"
				},
				{
					"overkill"
				}
			}
		},
		{
			skill = "enforcer",
			name_id = "st_menu_enforcer_armor",
			unlocked = true,
			background_texture = "guis/textures/pd2/skilltree/bg_mastermind",
			tiers = {
				{
					"oppressor"
				},
				{
					"show_of_force",
					"pack_mule"
				},
				{
					"iron_man",
					"prison_wife"
				},
				{
					"juggernaut"
				}
			}
		},
		{
			skill = "enforcer",
			name_id = "st_menu_enforcer_ammo",
			unlocked = true,
			background_texture = "guis/textures/pd2/skilltree/bg_mastermind",
			tiers = {
				{
					"scavenging"
				},
				{
					"ammo_reservoir",
					"portable_saw"
				},
				{
					"ammo_2x",
					"carbon_blade"
				},
				{
					"bandoliers"
				}
			}
		},
		{
			skill = "technician",
			name_id = "st_menu_technician_sentry",
			unlocked = true,
			background_texture = "guis/textures/pd2/skilltree/bg_mastermind",
			tiers = {
				{
					"defense_up"
				},
				{
					"sentry_targeting_package",
					"eco_sentry"
				},
				{
					"engineering",
					"jack_of_all_trades"
				},
				{
					"tower_defense"
				}
			}
		},
		{
			skill = "technician",
			name_id = "st_menu_technician_breaching",
			unlocked = true,
			background_texture = "guis/textures/pd2/skilltree/bg_mastermind",
			tiers = {
				{
					"hardware_expert"
				},
				{
					"combat_engineering",
					"drill_expert"
				},
				{
					"more_fire_power",
					"kick_starter"
				},
				{
					"fire_trap"
				}
			}
		},
		{
			skill = "technician",
			name_id = "st_menu_technician_auto",
			unlocked = true,
			background_texture = "guis/textures/pd2/skilltree/bg_mastermind",
			tiers = {
				{
					"steady_grip"
				},
				{
					"heavy_impact",
					"fire_control"
				},
				{
					"shock_and_awe",
					"fast_fire"
				},
				{
					"body_expertise"
				}
			}
		},
		{
			skill = "ghost",
			name_id = "st_menu_ghost_stealth",
			unlocked = true,
			background_texture = "guis/textures/pd2/skilltree/bg_mastermind",
			tiers = {
				{
					"jail_workout"
				},
				{
					"cleaner",
					"chameleon"
				},
				{
					"second_chances",
					"ecm_booster"
				},
				{
					"ecm_2x"
				}
			}
		},
		{
			skill = "ghost",
			name_id = "st_menu_ghost_concealed",
			unlocked = true,
			background_texture = "guis/textures/pd2/skilltree/bg_mastermind",
			tiers = {
				{
					"sprinter"
				},
				{
					"awareness",
					"thick_skin"
				},
				{
					"dire_need",
					"insulation"
				},
				{
					"jail_diet"
				}
			}
		},
		{
			skill = "ghost",
			name_id = "st_menu_ghost_silencer",
			unlocked = true,
			background_texture = "guis/textures/pd2/skilltree/bg_mastermind",
			tiers = {
				{
					"scavenger"
				},
				{
					"optic_illusions",
					"silence_expert"
				},
				{
					"backstab",
					"hitman"
				},
				{
					"unseen_strike"
				}
			}
		},
		{
			skill = "hoxton",
			name_id = "st_menu_fugitive_pistol_akimbo",
			unlocked = true,
			background_texture = "guis/textures/pd2/skilltree/bg_mastermind",
			tiers = {
				{
					"equilibrium"
				},
				{
					"dance_instructor",
					"akimbo"
				},
				{
					"gun_fighter",
					"expert_handling"
				},
				{
					"trigger_happy"
				}
			}
		},
		{
			skill = "hoxton",
			name_id = "st_menu_fugitive_undead",
			unlocked = true,
			background_texture = "guis/textures/pd2/skilltree/bg_mastermind",
			tiers = {
				{
					"running_from_death",
				},
				{
					"nine_lives",
					"up_you_go"
				},
				{
					"perseverance",
					"feign_death"
				},
				{
					"messiah"
				}
			}
		},
		{
			skill = "hoxton",
			name_id = "st_menu_fugitive_berserker",
			unlocked = true,
			background_texture = "guis/textures/pd2/skilltree/bg_mastermind",
			tiers = {
				{
					"martial_arts"
				},
				{
					"bloodthirst",
					"steroids"
				},
				{
					"drop_soap",
					"wolverine"
				},
				{
					"frenzy"
				}
			}
		}
	}

	end
end)