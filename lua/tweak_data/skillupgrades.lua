Hooks:PostHook(UpgradesTweakData, "init", "skillupgrades", function(self, tweak_data)
	if PD2THHSHIN and PD2THHSHIN:IsOverhaulEnabled() then
	
		self.values.player.body_armor = {
			armor = {
				0,
				3,
				4,
				5,
				8,
				9,
				15
			},
			movement = {
				1,
				1,
				1,
				0.95,
				0.9,
				0.75,
				0.7
			},
			concealment = {
				29,
				25,
				23,
				21,
				19,
				15,
				9
			},
			dodge = {
				0.05,
				0,
				-0.05,
				-0.1,
				-0.15,
				-0.2,
				-0.5
			},
			damage_shake = {
				0.5,
				0.5,
				0.5,
				0.5,
				0.5,
				0.5,
				0.5
			},
			stamina = {
				1,
				1,
				1,
				1,
				1,
				1,
				1
			}
		}

		if _G.IS_VR then
			self.values.player.body_armor.armor = {
				2,
				5,
				6,
				7,
				8,
				9,
				16
			}
			self.values.player.body_armor.dodge = {
				0.05,
				0,
				-0.05,
				-0.1,
				-0.15,
				-0.2,
				-0.5
			}
			stamina = {
				2,
				1.75,
				1.5,
				1.25,
				1.1,
				1,
				1
			}
		end
		
		self.values.player.body_armor.skill_max_health_store = {
			11,
			11,
			10,
			9,
			8,
			6,
			5
		}
		
		self.values.temporary.overkill_damage_multiplier = {{1.25, 8}}
		self.values.pistol.damage_addend = {0.5, 1}
		self.values.pistol.fire_rate_multiplier = {1.25}
		self.values.pistol.reload_speed_multiplier = {1.25}
		self.values.player.pick_lock_easy_speed_multiplier = {0.25, 0.5}
		
		self.default_upgrades = { --THE ENTIRE DEFAULT UPGRADES TABLE IN HERE JUST INCASE WE WANNA SCRAP SHIT OR DO WHATEVER. JUST TABLE.INSERT IF WE NOT TOUCHING THIS.
			"player_fall_damage_multiplier",
			"player_fall_health_damage_multiplier",
			"player_silent_kill",
			"player_primary_weapon_when_downed",
			"player_intimidate_enemies",
			"player_special_enemy_highlight",
			"player_hostage_trade",
			"player_sec_camera_highlight",
			"player_corpse_dispose",
			"player_corpse_dispose_amount_1",
			"player_civ_harmless_melee",
			"player_walk_speed_multiplier",
			"player_steelsight_when_downed",
			"player_crouch_speed_multiplier",
			"carry_interact_speed_multiplier_1",
			"carry_interact_speed_multiplier_2",
			"carry_movement_speed_multiplier",
			"trip_mine_sensor_toggle",
			"player_pick_lock_easy_speed_multiplier_1",		
			"trip_mine_sensor_highlight",
			"trip_mine_can_switch_on_off",
			"ecm_jammer_can_activate_feedback",
			"ecm_jammer_interaction_speed_multiplier",
			"ecm_jammer_can_retrigger",
			"ecm_jammer_affects_cameras",
			"striker_reload_speed_default",
			"temporary_first_aid_damage_reduction",
			"temporary_passive_revive_damage_reduction_2",
			"akimbo_recoil_index_addend_1",
			"doctor_bag",
			"ammo_bag",
			"trip_mine",
			"ecm_jammer",
			"first_aid_kit",
			"sentry_gun",
			"bodybags_bag",
			"saw",
			"cable_tie",
			"jowi",
			"x_1911",
			"x_b92fs",
			"x_deagle",
			"x_g22c",
			"x_g17",
			"x_usp",
			"x_sr2",
			"x_mp5",
			"x_akmsu",
			"x_packrat",
			"x_p226",
			"x_m45",
			"x_mp7",
			"x_ppk"
		}		
	end
	
	self.definitions.player_pick_lock_easy_speed_multiplier_1 = {
		name_id = "menu_player_pick_lock_easy_speed_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "pick_lock_easy_speed_multiplier",
			category = "player"
		}
	}
	
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