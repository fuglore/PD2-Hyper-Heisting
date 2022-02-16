Hooks:PostHook(UpgradesTweakData, "init", "skillupgrades", function(self, tweak_data)
	self.values.player.body_armor = {
		armor = {
			0,
			4,
			5.5,
			7,
			11.5,
			13,
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
			0,
			-0.05,
			-0.1,
			-0.15,
			-0.2,
			-0.3,
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
	
	--Leech cooldown
	self.copr_ability_cooldown = 60
	self.copr_risen_cooldown_add = 60
	
	self.values.player.body_armor.skill_max_health_store = {
		8,
		8,
		7,
		6,
		5,
		4,
		3
	}
	self.values.player.perkdeck_movespeed_mult = {
		1.15,
		1.2,
		1.25,
		1.3
	}
	self.doctor_bag_base = 1
	self.values.doctor_bag.amount_increase = {
		1
	}
	self.values.first_aid_kit.quantity = {
		2,
		4
	}
	self.ecm_feedback_retrigger_interval = 240 --4 minutes is fine!
	self.ecm_feedback_min_duration = 15
	self.ecm_feedback_max_duration = 15
	self.ecm_feedback_interval = 1
	self.values.shape_charge.quantity = {
		1,
		5
	}
	self.values.player.taser_malfunction = {
		{
			interval = 3,
			chance_to_trigger = 0.25
		}
	}
	self.values.player.escape_taser = { --TEMP until i get QTE working
		0.4
	}
	
	self.values.temporary.overkill_damage_multiplier = {{1.50, 3}}
	self.values.pistol.damage_addend = {0.5, 1}
	self.values.pistol.stacking_hit_damage_multiplier = {
		{
			max_stacks = 1,
			max_time = 1.25,
			damage_bonus = 1.4
		},
		{
			max_stacks = 1,
			max_time = 2,
			damage_bonus = 1.4
		}
	}
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
	self.values.cooldown.long_dis_revive = {
		{
			1,
			30
		}
	}
	self.morale_boost_speed_bonus = 1.3
	self.morale_boost_reload_speed_bonus = 1.3
	self.morale_boost_suppression_resistance = 0.5
	self.values.player.melee_knockdown_mul = {2}		
	self.values.player.pick_lock_easy_speed_multiplier = {0.75, 0.5}	
	self.values.player.armor_multiplier = {1.3, 1.5}
	
	self.values.player.health_increase = {
		11.5
	}
	
	self.definitions.player_health_increase = {
		name_id = "menu_player_health_increase",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "health_increase",
			category = "player"
		}
	}
	
	self.values.player.armor_conversion = {
		0.25,
		0.5
	}
	self.definitions.player_armor_conversion_1 = {
		name_id = "menu_player_health_decrease",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "armor_conversion",
			category = "player"
		}
	}
	self.definitions.player_armor_conversion_2 = {
		name_id = "menu_player_health_decrease",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "armor_conversion",
			category = "player"
		}
	}
	
	self.values.player.health_decrease_2_decrease_harder = {
		0.5,
		0.25
	}
	
	self.definitions.player_health_decrease_1 = {
		name_id = "menu_player_health_decrease",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "health_decrease_2_decrease_harder",
			category = "player"
		}
	}
	
	self.definitions.player_health_decrease_2 = {
		name_id = "menu_player_health_decrease",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "health_decrease_2_decrease_harder",
			category = "player"
		}
	}

	self.values.player.armor_grinding = {
		{
			{1.2, 6},
			{2, 6.5},
			{3, 7},
			{4, 8},
			{5, 9},
			{7, 9.5},
			{8, 10}
		}
	}
	
	self.values.player.armor_grinding_regen_t_on_kill = {
		20,
		10
	}
	self.definitions.player_armor_grinding_regen_t_on_kill_1 = {
		name_id = "menu_anarchdeck1",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "armor_grinding_regen_t_on_kill",
			category = "player"
		}
	}
	self.definitions.player_armor_grinding_regen_t_on_kill_2 = {
		name_id = "menu_anarchdeck6",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "armor_grinding_regen_t_on_kill",
			category = "player"
		}
	}
	
	self.values.player.armor_grinding_on_dmg_regen = {true}
	self.definitions.player_armor_grinding_on_dmg_regen = {
		name_id = "menu_anarchdeck8",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "armor_grinding_on_dmg_regen",
			category = "player"
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
		0.25,
		0.5,
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
	
	self.values.player.passive_health_multiplier = {
		1.05,
		1.1,
		1.15,
		1.2,
		1.2
	}

	self.values.player.passive_health_regen = {
		0.01
	}
	
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
	
	self.values.player.flashbang_multiplier = {
		0.75,
		0.75
	}
	
	self.values.player.coolheaded_basic = {
		0.5
	}
	self.definitions.player_coolheaded_basic = {
		name_id = "menu_coolheaded_basic",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "coolheaded_basic",
			category = "player"
		}
	}
	
	self.values.player.soldiersyringe_basic = { --Trooper's Syringe Basic
		1
	}
	self.definitions.player_soldiersyringe_basic = {
		name_id = "menu_player_soldiersyringe_basic",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "soldiersyringe_basic",
			synced = true,
			category = "player"
		}
	}
	
	self.values.player.soldiersyringe_aced = { --Trooper's Syringe Aced
		1
	}
	self.definitions.player_soldiersyringe_aced = {
		name_id = "menu_player_soldiersyringe_aced",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "soldiersyringe_aced",
			synced = true,
			category = "player"
		}
	}
	
	self.values.player.antilethal_meds = {
		1
	}
	self.definitions.player_antilethal_meds = {
		name_id = "menu_antilethal_meds",
		category = "feature",
		upgrade = {
			value = 1,
			synced = true,
			upgrade = "antilethal_meds",
			category = "player"
		}
	}
	
	self.values.player.magic_bullet_basic = {
		true
	}
	self.definitions.player_magic_bullet_basic = {
		name_id = "menu_magic_bullet_basic",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "magic_bullet_basic",
			category = "player"
		}
	}
	
	self.values.player.magic_bullet_aced = {
		true
	}
	self.definitions.player_magic_bullet_aced = {
		name_id = "menu_magic_bullet_aced",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "magic_bullet_aced",
			category = "player"
		}
	}
	
	self.values.player.fineredmist_basic = { --fine red mist
		true
	}
	self.definitions.player_fineredmist_basic = {
		name_id = "menu_fineredmist_basic",
		category = "feature",
		upgrade = {
			value = 1,
			synced = true,
			upgrade = "fineredmist_basic",
			category = "player"
		}
	}
	
	self.values.player.fineredmist_aced = { --fine red mist
		true
	}
	self.definitions.player_fineredmist_aced = {
		name_id = "menu_fineredmist_aced",
		category = "feature",
		upgrade = {
			value = 1,
			synced = true,
			upgrade = "fineredmist_aced",
			category = "player"
		}
	}
	
	self.values.player.hq_grease_basic = {
		1.5
	}
	self.values.player.hq_grease_aced = {
		{1.2, 1.4}
	}
	self.definitions.player_hq_grease_basic = {
		name_id = "menu_hq_grease_basic",
		category = "feature",
		upgrade = {
			value = 1,
			--synced = true,
			upgrade = "hq_grease_basic",
			category = "player"
		}
	}
	self.definitions.player_hq_grease_aced = {
		name_id = "menu_hq_grease_aced",
		category = "feature",
		upgrade = {
			value = 1,
			--synced = true,
			upgrade = "hq_grease_aced",
			category = "player"
		}
	}
	
	self.values.player.shot_shoulders_recoil_addend = {
		3
	}
	self.values.player.shot_shoulders_crowbar = {
		1.25
	}
	self.definitions.player_shot_shoulders_basic = {
		name_id = "menu_shot_shoulders_basic",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "shot_shoulders_recoil_addend",
			category = "player"
		}
	}
	self.definitions.player_shot_shoulders_aced = {
		name_id = "menu_shot_shoulders_aced",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "shot_shoulders_crowbar",
			category = "player"
		}
	}
	
	self.values.shotgun.magazine_capacity_inc = {
		8
	}

	self.values.player.cool_hunting_basic = {
		1.25
	}
	self.values.player.cool_hunting_aced = {
		true
	}
	self.definitions.player_cool_hunting_basic = {
		name_id = "menu_cool_hunting_basic",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "cool_hunting_basic",
			category = "player"
		}
	}
	self.definitions.player_cool_hunting_aced = {
		name_id = "menu_cool_hunting_aced",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "cool_hunting_aced",
			category = "player"
		}
	}
	
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
	
	self.values.player.jackpot_safety = { --jackpot
		true
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
	
	self.values.player.muscle_memory_basic = { --muscle memory basic
		1.5
	}
	self.definitions.player_muscle_memory_basic = {
		name_id = "menu_muscle_memory_basic",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "muscle_memory_basic",
			category = "player"
		}
	}
	
	self.values.player.muscle_memory_aced = { --muscle memory aced
		0.8
	}
	self.definitions.player_muscle_memory_aced = {
		name_id = "menu_muscle_memory_aced",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "muscle_memory_aced",
			category = "player"
		}
	}
	
	self.values.player.lead_demi_basic = {
		1.5
	}
	self.definitions.player_lead_demi_basic = {
		name_id = "menu_lead_demi_basic",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "lead_demi_basic",
			category = "player"
		}
	}
	
	self.values.player.pop_pop = { --pop pop aced
		true
	}
	self.definitions.player_pop_pop = {
		name_id = "menu_pop_pop",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "pop_pop",
			category = "player"
		}
	}
	
	self.values.player.ridethebull_basic = { --confiscate basic
		true
	}
	self.definitions.player_ridethebull_basic = {
		name_id = "menu_ridethebull_basic",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "ridethebull_basic",
			category = "player"
		}
	}
	self.values.player.ridethebull_aced = { --confiscate aced
		true
	}
	self.definitions.player_ridethebull_aced = {
		name_id = "menu_ridethebull_aced",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "ridethebull_aced",
			category = "player"
		}
	}
	
	self.values.player.comeback = { --ressurection
		true
	}
	self.definitions.player_comeback = {
		name_id = "menu_comeback",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "comeback",
			category = "player"
		}
	}
	
	self.values.player.dark_metamorphosis_basic = {
		true
	}
	self.definitions.player_dark_metamorphosis_basic = {
		name_id = "menu_dark_metamorphosis_basic",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "dark_metamorphosis_basic",
			category = "player"
		}
	}
	
	self.values.player.dark_metamorphosis_aced = {
		true
	}
	self.definitions.player_dark_metamorphosis_aced = {
		name_id = "menu_dark_metamorphosis_aced",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "dark_metamorphosis_aced",
			category = "player"
		}
	}
	
	self.values.player.phoenix_down = { --ressurection
		true
	}
	self.definitions.player_phoenix_down = {
		name_id = "menu_phoenix_down",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "phoenix_down",
			category = "player"
		}
	}
	
	self.values.player.move_while_tased = {
		true
	}
	
	self.definitions.player_move_while_tased = {
		name_id = "menu_move_while_tased",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "move_while_tased",
			category = "player"
		}
	}
	
	--Sneakier Bastard ACED
	self.values.player.sneakier_aced = {
		true
	}
	self.definitions.player_sneakier_aced = {
		name_id = "menu_sneakier_aced",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "sneakier_aced",
			category = "player"
		}
	}
	
	--High Vigour ACED
	self.values.player.highvigour_aced = {
		true
	}
	self.definitions.player_highvigour_aced = {
		name_id = "menu_highvigour_aced",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "highvigour_aced",
			category = "player"
		}
	}
	
	--Lower Blow ACED
	self.values.player.crit_damage_up = {
		true
	}
	self.definitions.player_crit_damage_up = {
		name_id = "menu_crit_damage_up",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "crit_damage_up",
			category = "player"
		}
	}
	
	--WAVE DASH BASIC
	self.values.player.wavedash = {
		true
	}
	self.definitions.player_wavedash = {
		name_id = "menu_wavedash",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "wavedash",
			category = "player"
		}
	}
	
	self.values.player.start_action_stam_drain_reduct = { --wave dash aced
		true
	}
	self.definitions.player_start_action_stam_drain_reduct = {
		name_id = "menu_start_action_stam_drain_reduct",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "start_action_stam_drain_reduct",
			category = "player"
		}
	}
	
	--Something To Prove
	
	self.values.player.max_health_reduction = {
		0.5
	}
	self.values.player.flexmode = {
		true
	}
	self.values.player.criticalmode = {
		true
	}
	self.definitions.player_flexmode = {
		name_id = "menu_flexmode",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "flexmode",
			category = "player"
		}
	}
	self.definitions.player_criticalmode = {
		name_id = "menu_criticalmode",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "criticalmode",
			category = "player"
		}
	}
	
	--Unstoppable tier 1
	self.values.player.melee_damage_health_ratio_multiplier = {
		5
	}
	self.player_damage_health_ratio_threshold = 0.99
	
	--Unstoppable tier 2
	self.values.player.strong_spirit = {
		true
	}
	self.definitions.player_strong_spirit = {
		name_id = "menu_strong_spirit",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "strong_spirit",
			category = "player"
		}
	}
	
	self.values.player.momentummaker_basic = {
		true
	}
	self.definitions.player_momentummaker_basic = {
		name_id = "menu_momentummaker_basic",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "momentummaker_basic",
			category = "player"
		}
	}
	self.values.player.momentummaker_aced = {
		true
	}
	self.definitions.player_momentummaker_aced = {
		name_id = "menu_momentummaker_aced",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "momentummaker_aced",
			category = "player"
		}
	}
	
	self.values.player.beatemup_basic = {
		true
	}
	self.definitions.player_beatemup_basic = {
		name_id = "menu_beatemup_basic",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "beatemup_basic",
			category = "player"
		}
	}
	
	self.values.player.beatemup_aced = {
		true
	}
	self.definitions.player_beatemup_aced = {
		name_id = "menu_beatemup_aced",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "beatemup_aced",
			category = "player"
		}
	}
	
	self.weapon_movement_penalty.lmg = 0.8
	self.weapon_movement_penalty.minigun = 0.6
	
	self.definitions.player_damage_dampener_outnumbered_strong = { --Infiltrator/Sociopath movement speed buff stuff
		name_id = "menu_player_infilpath_1",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "perkdeck_movespeed_mult",
			category = "player"
		}
	}
	self.definitions.player_damage_dampener_close_contact_1 = {
		name_id = "menu_player_infilpath_2",
		category = "feature",
		upgrade = {
			value = 2,
			upgrade = "perkdeck_movespeed_mult",
			category = "player"
		}
	}
	self.definitions.player_damage_dampener_close_contact_2 = {
		name_id = "menu_player_infilpath_3",
		category = "feature",
		upgrade = {
			value = 3,
			upgrade = "perkdeck_movespeed_mult",
			category = "player"
		}
	}
	self.definitions.player_damage_dampener_close_contact_3 = {
		name_id = "menu_player_infilpath_4",
		category = "feature",
		upgrade = {
			value = 4,
			upgrade = "perkdeck_movespeed_mult",
			category = "player"
		}
	}
	self.values.temporary.melee_life_leech = {
		{
			2.5,
			5
		}
	}
	self.values.player.pick_up_ammo_multiplier = {
		1, --walk-in close pickup boost removal
		2
	}
	
	self.values.player.perk_received_suppression_mul = { 
		0.5
	}
	self.definitions.weapon_passive_headshot_damage_multiplier = {
		name_id = "menu_weapon_headshot_damage_multiplier",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "perk_received_suppression_mul",
			category = "player"
		}
	}
	
	self.values.player.perk_max_health_reduction = { --grinder health reduction, multiplicative ontop of other health reductions
		0.5
	}
	self.definitions.player_perk_max_health_reduction = {
		name_id = "menu_perk_max_health_reduction",
		category = "feature",
		upgrade = {
			value = 1,
			upgrade = "perk_max_health_reduction",
			category = "player"
		}
	}
	
	self.values.team.crew_interact = {
		{
			0.9,
			0.75,
			0.5
		}
	}
	
	--all dodge needs to not be ridiculous now
	self.values.player.passive_dodge_chance = {
		0.05,
		0.15,
		0.25
	}
	self.values.player.tier_dodge_chance = {
		0.05,
		0.1,
		0.15
	}
	self.values.player.level_2_dodge_addend = {
		0.05,
		0.1,
		0.15
	}
	self.values.player.level_3_dodge_addend = {
		0.05,
		0.1,
		0.15
	}
	self.values.player.level_4_dodge_addend = {
		0.05,
		0.1,
		0.15
	}
	
	self.values.player.dodge_shot_gain = {
		{
			0.05,
			6
		}
	}
	self.values.temporary.pocket_ecm_kill_dodge = {
		{
			0.15,
			30,
			1
		}
	}
	
end)
