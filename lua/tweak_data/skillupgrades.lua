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
		
		self.values.temporary.overkill_damage_multiplier = {{1.35, 8}}
		self.values.pistol.damage_addend = {0.5, 1}
		--[[
            self.values.player.head_shot_ammo_return = {
			{
				headshots = 2,
				ammo = 1,
				time = 6
			},
			{
				headshots = 1,
				ammo = 1,
				time = 6}
		}
            --]]	
		self.values.saw.damage_multiplier = {1.528} --closest i Could get!!! atleast the menu rounds up correctly. still, without perkdecks the 100% increase is somehow wrong. shouldn't matter regardless cause everyone and their grandma plays with an aced perk deck.
		self.values.pistol.fire_rate_multiplier = {1.25}
		self.values.pistol.reload_speed_multiplier = {1.25}		
		self.values.player.melee_knockdown_mul = {2}		
		self.values.player.pick_lock_easy_speed_multiplier = {0.75, 0.5}	
		self.values.player.armor_multiplier = {1.3, 1.5}
		--temp resmod anarchist values--
		self.values.player.armor_grinding = {
			{
				{2.4, 3.0},
				{2.8, 3.5},
				{3.2, 4.0},
				{3.6, 4.5},
				{4.0, 5.0},
				{4.4, 5.5},
				{4.8, 6.0}
			}
		}
		--Temp values for stoic nerf
		self.values.player.armor_to_health_conversion = {
			100
		}
		self.values.player.damage_control_passive = {
			{
				66,
				9
			}
		}
		self.values.player.damage_control_auto_shrug = {
			5
		}
		self.values.player.damage_control_cooldown_drain = {
			{
				0,
				0.5
			},
			{
				35,
				1
			}
		}
		self.values.player.damage_control_healing = {
			50
		}
		
		self.values.player.health_decrease = {0.5}
		
		self.values.player.armor_increase = {
			0.50,
			0.75,
			1.00
		}

		self.values.player.damage_to_armor = {
			{
				{2.1, 3},
				{2.4, 3},
				{2.7, 3},
				{3.0, 3},
				{3.2, 3},
				{3.4, 3},
				{3.6, 3}
			}
		}
		
		end
		
	if PD2THHSHIN and PD2THHSHIN:IsOverhaulEnabled() then		
		--fuck you you piece of shit i'm not doing all this shit to make you function properly you fuck i hate your guts i hate you i hate you FUCK YOU
		
		--[[ note if anyone wants to actually fix this: this is supposed to stack with the perk deck speed bonus which is why i did this.
		self.values.player.passive_armor_movement_penalty_multiplier_bigguy = {0.75}						
		self.definitions.player_passive_armor_movement_penalty_multiplier_bigguy = { 
			name_id = "menu_passive_armor_movement_penalty_multiplier",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "passive_armor_movement_penalty_multiplier_bigguy",
				category = "player"
			}
		}--]]
		
		self.definitions.player_armor_multiplier_cooler = {
			name_id = "menu_player_armor_multiplier",
			category = "feature",
			upgrade = {
				value = 2,
				upgrade = "armor_multiplier",
				category = "player"
			}
		}

		self.definitions.saw_damage_mult = { --this should work better. watch it not actually work and only display an increased on the menu or some bullshit. i don't like you.
			name_id = "menu_saw_damage_mult",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "damage_multiplier",
				category = "saw"
			}
		}
		
		self.definitions.saw_damage_mult_sec = { --this should work better. watch it not actually work and only display an increased on the menu or some bullshit. i don't like you.
			name_id = "menu_saw_damage_mult",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "damage_multiplier",
				category = "saw"
			}
		}
				
		self.definitions.player_pick_lock_easy_speed_multiplier_1 = {
			name_id = "menu_player_pick_lock_easy_speed_multiplier",
			category = "feature",
			upgrade = {
				value = 1,
				upgrade = "pick_lock_easy_speed_multiplier",
				category = "player"
			}
		}
		self.definitions.player_pick_lock_easy_speed_multiplier_2 = {
			name_id = "menu_player_pick_lock_easy_speed_multiplier",
			category = "feature",
			upgrade = {
				value = 2,
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
		self.weapon_movement_penalty.lmg = 0.8
		self.weapon_movement_penalty.minigun = 0.6
	end
end)
