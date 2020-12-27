function WeaponTweakData:_set_characters_weapon_preset(rifle_spread, smg_spread, lmg_spread, mini_spread) --useless, leave here just in case.
	--uh oh sisters *melts into dust leaving only my bones behind*
	local all_rifles = {
		"m4_npc",
		"m4_yellow_npc",
		"ak47_npc",
		"ak47_ass_npc",		
		"g36_npc",
		"smoke_npc",
		"scar_npc",
		"lazer_npc",
		"s552_npc",
		"quagmire_npc"
	}
	
	local all_smgs = {
		"mp5_npc",
		"mac11_npc",
		"mp9_npc",
		"akmsu_smg_npc",
		"ump_npc",
		"asval_smg_npc"
	}

	for _, rname in ipairs(all_rifles) do
		self[rname].spread = rifle_spread
		self[rname].fanpcwep = true
		self[rname].hold = "rifle"
	end
	
	for _, sname in ipairs(all_smgs) do
		self[sname].spread = smg_spread
		self[sname].fanpcwep = true
	end
	
	self.m249_npc.spread = lmg_spread
	self.m249_npc.fanpcwep = true
	self.m60_npc.spread = lmg_spread
	self.m249_npc.fanpcwep = true
	self.rpk_lmg_npc.spread = lmg_spread
	self.rpk_lmg_npc.fanpcwep = true
	self.mini_npc.spread = mini_spread
	self.mini_npc.fanpcwep = true
	
	self.r870_npc.spread = 1
	self.blazter_npc.spread = 1
	self.benelli_npc.spread = 1
	self.silserbu_npc.spread = 1
	self.mossberg_npc.spread = 1
	self.bayou_npc.spread = 1
end

Hooks:PostHook(WeaponTweakData, "init", "lore_init", function(self, tweakdata)
	
	--begin new weapon setup
	self.degle_npc = deep_clone(self.raging_bull_npc)
	self.degle_npc.CLIP_AMMO_MAX = 10
	self.degle_npc.armor_piercing = true	
	self.degle_npc.sounds.prefix = "deagle_npc"	
	self.xkill_npc = deep_clone(self.c45_npc)
	self.xkill_npc.sounds.prefix = "c45_npc"
	self.trolliam_sidearm_npc = deep_clone(self.saiga_npc)
	self.trolliam_sidearm_npc.CLIP_AMMO_MAX = 128
	self.trolliam_sidearm_npc.sounds.prefix = "g17_npc"	
	self.trolliam_sidearm_npc.muzzleflash = "effects/payday2/particles/weapons/big_762_auto"	
	self.trolliam_sidearm_npc.DAMAGE = 15 --150 damage it works well trust me
	self.streak_npc = deep_clone(self.c45_npc)
	self.streak_npc.sounds.prefix = "pl14_npc"	
	self.kmtac_npc = deep_clone(self.c45_npc)
	self.kmtac_npc.sounds.prefix = "usp45_npc"		
	self.x_xkill_npc = deep_clone(self.x_c45_npc)
	self.x_xkill_npc.sounds.prefix = "c45_npc"	
	self.x_streak_npc = deep_clone(self.x_c45_npc)
	self.x_streak_npc.sounds.prefix = "pl14_npc"
	self.x_kmtac_npc = deep_clone(self.x_c45_npc)
	self.x_kmtac_npc.sounds.prefix = "usp45_npc"			
	self.bayou_npc = deep_clone(self.r870_npc)
	self.bayou_npc.sounds.prefix = "spas_npc"
	self.quagmire_npc = deep_clone(self.m4_npc)
	self.quagmire_npc.sounds.prefix = "contraband_npc"
	self.quagmire_npc.muzzleflash = "effects/payday2/particles/weapons/556_auto"
	self.quagmire_npc.shell_ejection = "effects/payday2/particles/weapons/shells/shell_556"
	self.silserbu_npc = deep_clone(self.r870_npc)
	self.silserbu_npc.sounds.prefix = "serbu_npc"
	self.silserbu_npc.has_suppressor = "suppressed_a"
	self.smoke_npc.muzzleflash = "effects/payday2/particles/weapons/556_auto"
	self.lazer_npc = deep_clone(self.m4_npc)
	self.lazer_npc.sounds.prefix = "tecci_npc"
	self.lazer_npc.shell_ejection = "effects/payday2/particles/weapons/shells/shell_empty"
	self.lazer_npc.muzzleflash = "effects/pd2_mod_hh/particles/weapons/muzzles/blue_muzzle"
	self.lazer_npc.b_trail = true
	self.blazter_npc = deep_clone(self.benelli_npc)
	self.blazter_npc.sounds.prefix = "boot_npc"
	self.blazter_npc.shell_ejection = "effects/payday2/particles/weapons/shells/shell_empty"
	self.blazter_npc.muzzleflash = "effects/pd2_mod_hh/particles/weapons/muzzles/red_muzzle"
	self.blazter_npc.r_trail = true
	
	--shotgun reload stuff
	self.r870_npc.hold = "rifle"
	self.r870_npc.reload = "looped"
	self.r870_npc.looped_reload_speed = 0.8
	
	self.bayou_npc.hold = "rifle"
	self.bayou_npc.reload = "looped"
	self.bayou_npc.looped_reload_speed = 0.8
	
	self.benelli_npc.hold = "rifle"
	self.benelli_npc.reload = "looped"
	self.benelli_npc.looped_reload_speed = 0.8
	
	self.silserbu_npc.hold = "rifle"
	self.silserbu_npc.reload = "looped"
	self.silserbu_npc.looped_reload_speed = 0.8
	
	self.blazter_npc.hold = "rifle"
	self.blazter_npc.reload = "looped"
	self.blazter_npc.looped_reload_speed = 0.8
	
	self.ak47_ass_npc.DAMAGE = 1
	self.mp5_npc.DAMAGE = 1
	self.ump_npc.DAMAGE = 1
	self.akmsu_smg_npc.DAMAGE = 1
	self.m4_npc.DAMAGE = 1
	self.m4_yellow_npc.DAMAGE = 1
	self.g36_npc.DAMAGE = 1
	self.ak47_npc.DAMAGE = 1
	self.smoke_npc.DAMAGE = 1
	self.quagmire_npc.DAMAGE = 1
	self.scar_npc.DAMAGE = 1
	self.saiga_npc.DAMAGE = 5
	
	--New adjustment for consistent firing times, I found that the amount of time an enemy could go on without reloading was causing gaps of breathing room in the chaos, these should always be a LITTLE bit.
	self.m4_npc.auto.fire_rate = 0.08
	self.m4_yellow_npc.auto.fire_rate = 0.08
	self.g36_npc.auto.fire_rate = 0.08
	self.smoke_npc.auto.fire_rate = 0.08
	self.ak47_ass_npc.auto.fire_rate = 0.08
	self.ak47_npc.auto.fire_rate = 0.08
	self.quagmire_npc.fire_rate = 0.08
	self.scar_npc.fire_rate = 0.08
	
	--This...is important, suppression needs to be changed between enemies due to the way suppression works being partially modified on the player's side, as such, minimum suppression for a few things that I want to really lay suppression on the player on have been greatly increased.
	self.m4_npc.suppression = 1
	self.m4_yellow_npc.suppression = 1
	self.ak47_npc.suppression = 1
	self.ak47_ass_npc.suppression = 1
	self.scar_npc.suppression = 1
	self.g36_npc.suppression = 1
	self.smoke_npc.suppression = 1
	self.quagmire_npc.suppression = 1
	self.lazer_npc.suppression = 1
	self.mp5_npc.suppression = 2.5
	self.ump_npc.suppression = 2.5
	self.mp9_npc.suppression = 2.5
	self.saiga_npc.suppression = 1
	self.r870_npc.suppression = 5
	self.blazter_npc.suppression = 5
	self.silserbu_npc.suppression = 5
	self.benelli_npc.suppression = 2
	self.m249_npc.suppression = 5
	self.mini_npc.suppression = 5
	
	--Sniper stuff starts here
	self.m14_sniper_npc.suppression = 5 --this gets boosted more and more as difficulties go up.
	self.m14_sniper_npc.armor_piercing = false --New type of sniper that works differently, I don't really dig how cheap the current ones feel.
	self.m14_sniper_npc.spread = 1 --Spread for internal changes
	self.svd_snp_npc.suppression = 5
	self.svd_snp_npc.armor_piercing = false
	self.svd_snp_npc.spread = 1 --Spread for internal changes
	self.svdsil_snp_npc.suppression = 5
	self.svdsil_snp_npc.armor_piercing = false
	self.svdsil_snp_npc.spread = 1 --Spread for internal changes
	self.heavy_snp_npc.suppression = 5
	self.heavy_snp_npc.armor_piercing = false --Crime spree sniper also gets the same treatment, making him a more fun unit to fight.
	self.heavy_snp_npc.spread = 1 --Spread for internal changes
	
	--A bunch of NPC weapon clone/consistency issues, fixed in minutes back when I made fixed weapon preset scaling because OVERKILL sucks.
	self.c45_npc.sounds.prefix = "g17_npc"
	self.x_c45_npc.sounds.prefix = "g17_npc"
	self.s552_npc = deep_clone(self.m4_npc)
	self.s552_npc.sounds.prefix = "sig552_npc"
	self.s552_npc.muzzleflash = "effects/payday2/particles/weapons/556_auto"
	self.s552_npc.shell_ejection = "effects/payday2/particles/weapons/shells/shell_556"
	self.ak47_ass_npc = deep_clone(self.m4_npc)
	self.ak47_ass_npc.sounds.prefix = "ak74_npc"
	self.ak47_ass_npc.muzzleflash = "effects/payday2/particles/weapons/762_auto"
	self.mp5_tactical_npc = deep_clone(self.mp5_npc)
	self.mp5_tactical_npc.muzzleflash = "effects/payday2/particles/weapons/9mm_auto_silence"
	self.mp5_tactical_npc.has_suppressor = "suppressed_a"
	self.mp5_tactical_npc.no_vis = true
	self.ump_npc = deep_clone(self.mp5_npc)
	self.ump_npc.sounds.prefix = "schakal_npc"
	self.akmsu_smg_npc = deep_clone(self.mp5_npc)
	self.akmsu_smg_npc.sounds.prefix = "coal_npc"
	self.akmsu_smg_npc.shell_ejection = "effects/payday2/particles/weapons/shells/shell_556"
	self.asval_smg_npc = deep_clone(self.mp5_npc)
	self.asval_smg_npc.sounds.prefix = "akmsu_npc"
	self.asval_smg_npc.shell_ejection = "effects/payday2/particles/weapons/shells/shell_556"
	self.asval_smg_npc.muzzleflash = "effects/payday2/particles/weapons/9mm_auto_silence"
	self.asval_smg_npc.no_vis = true
	self.mac11_npc.sounds.prefix = "mac10_npc"
	self.benelli_npc.sounds.prefix = "benelli_m4_npc"
	
	--LMG weapon usage fix for Dozers and other enemies, this will do some damn good with NPC bosses.
	self.m249_npc.anim_usage = "is_rifle"
	self.m249_npc.usage = "is_lmg"
	self.rpk_lmg_npc = deep_clone(self.m249_npc)
	self.rpk_lmg_npc.anim_usage = "is_rifle"
	self.rpk_lmg_npc.sounds.prefix = "rpk_npc"
	self.rpk_lmg_npc.usage = "is_lmg"
	self.rpk_lmg_npc.auto.fire_rate = 0.08
	self.m60_npc = deep_clone(self.m249_npc) --custom m60 for murkyboys
	self.m60_npc.anim_usage = "is_rifle"
	self.m60_npc.sounds.prefix = "m60_npc"
	self.m60_npc.usage = "is_lmg"
	self.m60_npc.hold = "rifle"
	
	--punk mossberg
	self.mossberg_npc.usage = "is_shotgun_pump"
	self.mossberg_npc.hold = "rifle"
	self.mossberg_npc.reload = "looped"
	self.mossberg_npc.looped_reload_speed = 1
	self.mossberg_npc.sounds.prefix = "remington_npc"
	self.mossberg_npc.DAMAGE = 3
	self.mossberg_npc.spread = 1
	self.mossberg_npc.CLIP_AMMO_MAX = 2
	
	self.mini_npc.CLIP_AMMO_MAX = 100000 --new minigun dozer buff setup
	self.mini_npc.NR_CLIPS_MAX = 1

	-- Bot Weapon Changes
	self.sr2_crew.use_data.selection_index = 2
	self.cobray_crew.use_data.selection_index = 2
	self.baka_crew.use_data.selection_index = 2
	self.shepheard_crew.use_data.selection_index = 2
	
	--high vis trails for high damage/important enemy weapons
	self.m14_sniper_npc.hivis = true
	self.svd_snp_npc.hivis = true
	self.svdsil_snp_npc.hivis = true
	self.heavy_snp_npc.hivis = true
	self.mini_npc.hivis = true
	self.r870_npc.hivis = true
	self.benelli_npc.hivis = true
	self.saiga_npc.hivis = true
	self.m249_npc.hivis = true
	self.rpk_lmg_npc.hivis = true
	self.silserbu_npc.hi_vis = true
	self.mossberg_npc.hi_vis = true
	self.bayou_npc.hi_vis = true
	self.m14_sniper_npc.muzzleflash = "effects/pd2_mod_hh/particles/weapons/muzzles/hivis_muzzle"
	self.svd_snp_npc.muzzleflash = "effects/pd2_mod_hh/particles/weapons/muzzles/hivis_muzzle"
	self.svdsil_snp_npc.muzzleflash = "effects/pd2_mod_hh/particles/weapons/muzzles/hivis_muzzle"
	self.heavy_snp_npc.muzzleflash = "effects/pd2_mod_hh/particles/weapons/muzzles/hivis_muzzle"
	self.mini_npc.muzzleflash = "effects/pd2_mod_hh/particles/weapons/muzzles/hivis_muzzle"
	self.r870_npc.muzzleflash = "effects/pd2_mod_hh/particles/weapons/muzzles/hivis_muzzle_shotgun_civil"
	self.benelli_npc.muzzleflash = "effects/pd2_mod_hh/particles/weapons/muzzles/hivis_muzzle_shotgun_civil"
	self.bayou_npc.muzzleflash = "effects/pd2_mod_hh/particles/weapons/muzzles/hivis_muzzle_shotgun_civil"
	self.silserbu_npc.muzzleflash = "effects/pd2_mod_hh/particles/weapons/muzzles/hivis_muzzle"
	self.saiga_npc.muzzleflash = "effects/pd2_mod_hh/particles/weapons/muzzles/hivis_muzzle"
	self.m249_npc.muzzleflash = "effects/pd2_mod_hh/particles/weapons/muzzles/hivis_muzzle"
	self.rpk_lmg_npc.muzzleflash = "effects/pd2_mod_hh/particles/weapons/muzzles/hivis_muzzle"
	self.mossberg_npc.muzzleflash = "effects/pd2_mod_hh/particles/weapons/muzzles/hivis_muzzle"
	
	self.swat_van_turret_module.DAMAGE_MUL_RANGE = {
		{
			800,
			1
		},
		{
			1000,
			1
		},
		{
			3000,
			0.5
		},
		{
			5000,
			0
		}
	}
	self.swat_van_turret_module.dontsuppressonmiss = true
	self.swat_van_turret_module.enemy_turret = true
	self.swat_van_turret_module.FIRE_DMG_MUL = 4
	self.swat_van_turret_module.BAG_DMG_MUL = 4
	self.ceiling_turret_module.DAMAGE_MUL_RANGE = {
		{
			800,
			1
		},
		{
			1000,
			1
		},
		{
			3000,
			1
		}
	}
	self.ceiling_turret_module.dontsuppressonmiss = true
	self.ceiling_turret_module.enemy_turret = true
	self.ceiling_turret_module.FIRE_DMG_MUL = 4
	self.ceiling_turret_module.BAG_DMG_MUL = 4
	self.aa_turret_module.DAMAGE_MUL_RANGE = {
		{
			800,
			1
		},
		{
			1000,
			1
		},
		{
			1500,
			1
		}
	}
	self.aa_turret_module.dontsuppressonmiss = true
	self.aa_turret_module.enemy_turret = true
	self.aa_turret_module.FIRE_DMG_MUL = 4
	self.aa_turret_module.BAG_DMG_MUL = 4
	self.crate_turret_module.DAMAGE_MUL_RANGE = {
		{
			800,
			1
		},
		{
			1000,
			1
		},
		{
			1500,
			1
		}
	}
	self.crate_turret_module.dontsuppressonmiss = true
	self.crate_turret_module.enemy_turret = true
	self.crate_turret_module.FIRE_DMG_MUL = 4
	self.crate_turret_module.BAG_DMG_MUL = 4
	
	self.emp_npc = deep_clone(self.mp9_npc)
	self.emp_npc.CLIP_AMMO_MAX = 100000
	self.emp_npc.shell_ejection = "effects/payday2/particles/weapons/shells/shell_empty"
	self.emp_npc.muzzleflash = "effects/pd2_mod_hh/particles/weapons/muzzles/lotus_muzzle"
	self.emp_npc.lotus_vis = true
	self.emp_npc.damage = 0
	self.emp_npc.suppression = 99
	self.emp_npc.apply_emp = true

	
	
end)

--TODO: it is done

--Locke really did it though, he really got us ka-tar-he-roh.

function WeaponTweakData:_set_normal() 	
	self.ak47_ass_npc.DAMAGE = 0.5
	self.mp5_npc.DAMAGE = 0.5
	self.ump_npc.DAMAGE = 0.5
	self.akmsu_smg_npc.DAMAGE = 0.5
	self.m4_npc.DAMAGE = 0.5
	self.m4_yellow_npc.DAMAGE = 0.5
	self.g36_npc.DAMAGE = 0.5
	self.ak47_npc.DAMAGE = 0.5
	self.scar_npc.DAMAGE = 0.5
	self.smoke_npc.DAMAGE = 0.5
	self.quagmire_npc.DAMAGE = 0.5
	self.r870_npc.DAMAGE = 2.5
	self.bayou_npc.DAMAGE = 2.5
	self.benelli_npc.DAMAGE = 2.5
	self.blazter_npc.DAMAGE = 2.5
	self.m14_sniper_npc.damage = 1
	
	--rifle tweaks, roughly 1.2 seconds of firing
	self.m4_npc.CLIP_AMMO_MAX = 16
	self.m4_yellow_npc.CLIP_AMMO_MAX = 16
	self.g36_npc.CLIP_AMMO_MAX = 16
	self.smoke_npc.CLIP_AMMO_MAX = 16
	self.ak47_ass_npc.CLIP_AMMO_MAX = 16
	self.ak47_npc.CLIP_AMMO_MAX = 16
	self.lazer_npc.CLIP_AMMO_MAX = 16
	self.quagmire_npc.CLIP_AMMO_MAX = 16
	
	--shotgun tweaks, fires 3 times before reload on SWAT-tier
	self.r870_npc.CLIP_AMMO_MAX = 3
	self.bayou_npc.CLIP_AMMO_MAX = 3
	self.benelli_npc.CLIP_AMMO_MAX = 3
	self.blazter_npc.CLIP_AMMO_MAX = 3
	
	--self:_set_characters_weapon_preset(15, 10, 15, 60) --setting enemy weapon spread, unused
	
	--Turret tweaks.
	self.swat_van_turret_module.HEALTH_INIT = 750
	self.swat_van_turret_module.SHIELD_HEALTH_INIT = 300
	self.swat_van_turret_module.DAMAGE = 2
	self.swat_van_turret_module.CLIP_SIZE = 400
	self.ceiling_turret_module.HEALTH_INIT = 400
	self.ceiling_turret_module.SHIELD_HEALTH_INIT = 150
	self.ceiling_turret_module.DAMAGE = 2
	self.ceiling_turret_module.CLIP_SIZE = 150
	self.aa_turret_module.HEALTH_INIT = 1500
	self.aa_turret_module.SHIELD_HEALTH_INIT = 300
	self.aa_turret_module.DAMAGE = 4
	self.aa_turret_module.auto.fire_rate = 0.6 --sadly, the firing sound doesnt match but, functionally its a lot of fun
	self.aa_turret_module.suppression = 8
	self.aa_turret_module.CLIP_SIZE = 800
	self.crate_turret_module.HEALTH_INIT = 500
	self.crate_turret_module.SHIELD_HEALTH_INIT = 150
	self.crate_turret_module.DAMAGE = 4
	self.crate_turret_module.auto.fire_rate = 0.6
	self.crate_turret_module.suppression = 8
	self.crate_turret_module.CLIP_SIZE = 400
	
	--ceiling turret clones
	self.ceiling_turret_module_no_idle.HEALTH_INIT = 400
	self.ceiling_turret_module_no_idle.SHIELD_HEALTH_INIT = 150
	self.ceiling_turret_module_no_idle.DAMAGE = 2
	self.ceiling_turret_module_no_idle.CLIP_SIZE = 150
	self.ceiling_turret_module_longer_range.HEALTH_INIT = 400
	self.ceiling_turret_module_longer_range.SHIELD_HEALTH_INIT = 150
	self.ceiling_turret_module_longer_range.DAMAGE = 2
	self.ceiling_turret_module_longer_range.CLIP_SIZE = 150
end

function WeaponTweakData:_set_hard() --He's only done it for the fuck-ing.
	self.ak47_ass_npc.DAMAGE = 0.5
	self.mp5_npc.DAMAGE = 0.5
	self.ump_npc.DAMAGE = 0.5
	self.akmsu_smg_npc.DAMAGE = 0.5
	self.m4_npc.DAMAGE = 0.5
	self.m4_yellow_npc.DAMAGE = 0.5
	self.g36_npc.DAMAGE = 0.5
	self.ak47_npc.DAMAGE = 0.5
	self.scar_npc.DAMAGE = 0.5
	self.smoke_npc.DAMAGE = 0.5
	self.quagmire_npc.DAMAGE = 0.5
	self.r870_npc.DAMAGE = 2.5
	self.bayou_npc.DAMAGE = 2.5
	self.benelli_npc.DAMAGE = 2.5
	self.blazter_npc.DAMAGE = 2.5
	self.m14_sniper_npc.damage = 1
	
	--rifle tweaks, roughly 1.2 seconds of firing
	self.m4_npc.CLIP_AMMO_MAX = 16
	self.m4_yellow_npc.CLIP_AMMO_MAX = 16
	self.g36_npc.CLIP_AMMO_MAX = 16
	self.smoke_npc.CLIP_AMMO_MAX = 16
	self.ak47_ass_npc.CLIP_AMMO_MAX = 16
	self.ak47_npc.CLIP_AMMO_MAX = 16
	self.lazer_npc.CLIP_AMMO_MAX = 16
	self.quagmire_npc.CLIP_AMMO_MAX = 16
	
	--shotgun tweaks, fires 3 times before reload on SWAT-tier
	self.r870_npc.CLIP_AMMO_MAX = 3
	self.bayou_npc.CLIP_AMMO_MAX = 3
	self.benelli_npc.CLIP_AMMO_MAX = 3
	self.blazter_npc.CLIP_AMMO_MAX = 3
	
	--self:_set_characters_weapon_preset(15, 10, 15, 60) --setting enemy weapon spread, unused
	
	--Turret tweaks.
	self.swat_van_turret_module.HEALTH_INIT = 750
	self.swat_van_turret_module.SHIELD_HEALTH_INIT = 300
	self.swat_van_turret_module.DAMAGE = 2
	self.swat_van_turret_module.CLIP_SIZE = 400
	self.ceiling_turret_module.HEALTH_INIT = 400
	self.ceiling_turret_module.SHIELD_HEALTH_INIT = 150
	self.ceiling_turret_module.DAMAGE = 2
	self.ceiling_turret_module.CLIP_SIZE = 150
	self.aa_turret_module.HEALTH_INIT = 1500
	self.aa_turret_module.SHIELD_HEALTH_INIT = 300
	self.aa_turret_module.DAMAGE = 4
	self.aa_turret_module.auto.fire_rate = 0.6 --sadly, the firing sound doesnt match but, functionally its a lot of fun
	self.aa_turret_module.suppression = 8
	self.aa_turret_module.CLIP_SIZE = 800
	self.crate_turret_module.HEALTH_INIT = 500
	self.crate_turret_module.SHIELD_HEALTH_INIT = 150
	self.crate_turret_module.DAMAGE = 4
	self.crate_turret_module.auto.fire_rate = 0.6
	self.crate_turret_module.suppression = 8
	self.crate_turret_module.CLIP_SIZE = 400
	
	--ceiling turret clones
	self.ceiling_turret_module_no_idle.HEALTH_INIT = 400
	self.ceiling_turret_module_no_idle.SHIELD_HEALTH_INIT = 150
	self.ceiling_turret_module_no_idle.DAMAGE = 2
	self.ceiling_turret_module_no_idle.CLIP_SIZE = 150
	self.ceiling_turret_module_longer_range.HEALTH_INIT = 400
	self.ceiling_turret_module_longer_range.SHIELD_HEALTH_INIT = 150
	self.ceiling_turret_module_longer_range.DAMAGE = 2
	self.ceiling_turret_module_longer_range.CLIP_SIZE = 150
end

function WeaponTweakData:_set_overkill() --aldstone? shit id be more worried about fdsamkfjdsakials
	self.ak47_ass_npc.DAMAGE = 1
	self.mp5_npc.DAMAGE = 1
	self.ump_npc.DAMAGE = 1
	self.akmsu_smg_npc.DAMAGE = 1
	self.m4_npc.DAMAGE = 1
	self.m4_yellow_npc.DAMAGE = 1
	self.g36_npc.DAMAGE = 1
	self.ak47_npc.DAMAGE = 1
	self.smoke_npc.DAMAGE = 1
	self.quagmire_npc.DAMAGE = 1
	
	--rifle tweaks, 2 seconds of firing
	self.m4_npc.CLIP_AMMO_MAX = 25
	self.m4_yellow_npc.CLIP_AMMO_MAX = 25
	self.g36_npc.CLIP_AMMO_MAX = 25
	self.smoke_npc.CLIP_AMMO_MAX = 25
	self.ak47_ass_npc.CLIP_AMMO_MAX = 25
	self.ak47_npc.CLIP_AMMO_MAX = 25
	self.lazer_npc.CLIP_AMMO_MAX = 25
	self.quagmire_npc.CLIP_AMMO_MAX = 25
	
	--shotgun tweaks, fires 4 times before reload on FBI+ tiers
	self.r870_npc.CLIP_AMMO_MAX = 4
	self.bayou_npc.CLIP_AMMO_MAX = 4
	self.benelli_npc.CLIP_AMMO_MAX = 4
	self.blazter_npc.CLIP_AMMO_MAX = 4
	
	--self:_set_characters_weapon_preset(10, 8, 10, 60) --setting enemy weapon spread, unused
	
	--sniper tweak
	self.m14_sniper_npc.suppression = 8
	self.m14_sniper_npc.CLIP_AMMO_MAX = 12
	self.svd_snp_npc.suppression = 8
	self.svd_snp_npc.CLIP_AMMO_MAX = 12
	self.svdsil_snp_npc.suppression = 8
	self.svdsil_snp_npc.CLIP_AMMO_MAX = 12
	
	--Turret tweaks.
	self.swat_van_turret_module.HEALTH_INIT = 750
	self.swat_van_turret_module.SHIELD_HEALTH_INIT = 300
	self.swat_van_turret_module.DAMAGE = 2
	self.swat_van_turret_module.CLIP_SIZE = 400
	self.ceiling_turret_module.HEALTH_INIT = 400
	self.ceiling_turret_module.SHIELD_HEALTH_INIT = 150
	self.ceiling_turret_module.DAMAGE = 2
	self.ceiling_turret_module.CLIP_SIZE = 150
	self.aa_turret_module.HEALTH_INIT = 1500
	self.aa_turret_module.SHIELD_HEALTH_INIT = 300
	self.aa_turret_module.DAMAGE = 4
	self.aa_turret_module.auto.fire_rate = 0.6 --sadly, the firing sound doesnt match but, functionally its a lot of fun
	self.aa_turret_module.suppression = 8
	self.aa_turret_module.CLIP_SIZE = 800
	self.crate_turret_module.HEALTH_INIT = 500
	self.crate_turret_module.SHIELD_HEALTH_INIT = 150
	self.crate_turret_module.DAMAGE = 4
	self.crate_turret_module.auto.fire_rate = 0.6
	self.crate_turret_module.suppression = 8
	self.crate_turret_module.CLIP_SIZE = 400
	
	--ceiling turret clones
	self.ceiling_turret_module_no_idle.HEALTH_INIT = 400
	self.ceiling_turret_module_no_idle.SHIELD_HEALTH_INIT = 150
	self.ceiling_turret_module_no_idle.DAMAGE = 2
	self.ceiling_turret_module_no_idle.CLIP_SIZE = 150
	self.ceiling_turret_module_longer_range.HEALTH_INIT = 400
	self.ceiling_turret_module_longer_range.SHIELD_HEALTH_INIT = 150
	self.ceiling_turret_module_longer_range.DAMAGE = 2
	self.ceiling_turret_module_longer_range.CLIP_SIZE = 150
end

function WeaponTweakData:_set_overkill_145()
	self.ak47_ass_npc.DAMAGE = 1
	self.mp5_npc.DAMAGE = 1
	self.ump_npc.DAMAGE = 1
	self.akmsu_smg_npc.DAMAGE = 1
	self.m4_npc.DAMAGE = 1
	self.m4_yellow_npc.DAMAGE = 1
	self.g36_npc.DAMAGE = 1
	self.ak47_npc.DAMAGE = 1
	self.smoke_npc.DAMAGE = 1
	
	--rifle tweaks, 2 seconds of firing
	self.m4_npc.CLIP_AMMO_MAX = 25
	self.m4_yellow_npc.CLIP_AMMO_MAX = 25
	self.g36_npc.CLIP_AMMO_MAX = 25
	self.smoke_npc.CLIP_AMMO_MAX = 25
	self.ak47_ass_npc.CLIP_AMMO_MAX = 25
	self.ak47_npc.CLIP_AMMO_MAX = 25
	self.lazer_npc.CLIP_AMMO_MAX = 25
	self.quagmire_npc.CLIP_AMMO_MAX = 25
	
	--shotgun tweaks, fires 4 times before reload on FBI-tier
	self.r870_npc.CLIP_AMMO_MAX = 4
	self.bayou_npc.CLIP_AMMO_MAX = 4
	self.benelli_npc.CLIP_AMMO_MAX = 4
	self.blazter_npc.CLIP_AMMO_MAX = 4
	
	--self:_set_characters_weapon_preset(10, 8, 10, 60) --setting enemy weapon spread, unused
	
	--sniper tweak
	self.m14_sniper_npc.suppression = 8
	self.m14_sniper_npc.CLIP_AMMO_MAX = 12
	self.svd_snp_npc.suppression = 8
	self.svd_snp_npc.CLIP_AMMO_MAX = 12
	self.svdsil_snp_npc.suppression = 8
	self.svdsil_snp_npc.CLIP_AMMO_MAX = 12
	self.heavy_snp_npc.DAMAGE = 1
	self.heavy_snp_npc.suppression = 8
	self.heavy_snp_npc.CLIP_AMMO_MAX = 12
	
	--Turret tweaks.
	self.swat_van_turret_module.HEALTH_INIT = 1500
	self.swat_van_turret_module.SHIELD_HEALTH_INIT = 300
	self.swat_van_turret_module.DAMAGE = 2
	self.swat_van_turret_module.CLIP_SIZE = 800
	self.ceiling_turret_module.HEALTH_INIT = 1000
	self.ceiling_turret_module.SHIELD_HEALTH_INIT = 150
	self.ceiling_turret_module.DAMAGE = 2
	self.ceiling_turret_module.CLIP_SIZE = 300
	self.aa_turret_module.HEALTH_INIT = 3000
	self.aa_turret_module.SHIELD_HEALTH_INIT = 300
	self.aa_turret_module.DAMAGE = 4
	self.aa_turret_module.auto.fire_rate = 0.6 --sadly, the firing sound doesnt match but, functionally its a lot of fun
	self.aa_turret_module.suppression = 8
	self.aa_turret_module.CLIP_SIZE = 800
	self.crate_turret_module.HEALTH_INIT = 500
	self.crate_turret_module.SHIELD_HEALTH_INIT = 150
	self.crate_turret_module.DAMAGE = 4
	self.crate_turret_module.auto.fire_rate = 0.6
	self.crate_turret_module.suppression = 8
	self.crate_turret_module.CLIP_SIZE = 800
	
	--ceiling turret clones
	self.ceiling_turret_module_no_idle.HEALTH_INIT = 1000
	self.ceiling_turret_module_no_idle.SHIELD_HEALTH_INIT = 150
	self.ceiling_turret_module_no_idle.DAMAGE = 2
	self.ceiling_turret_module_no_idle.CLIP_SIZE = 300
	self.ceiling_turret_module_longer_range.HEALTH_INIT = 1000
	self.ceiling_turret_module_longer_range.SHIELD_HEALTH_INIT = 150
	self.ceiling_turret_module_longer_range.DAMAGE = 2
	self.ceiling_turret_module_longer_range.CLIP_SIZE = 300
end

function WeaponTweakData:_set_easy_wish()
	--saiga tweak
	self.saiga_npc.CLIP_AMMO_MAX = 16
	
	--tweaks for smgs
	self.mp5_npc.CLIP_AMMO_MAX = 64
	self.mp5_tactical_npc.CLIP_AMMO_MAX = 64
	self.ump_npc.CLIP_AMMO_MAX = 64
	self.akmsu_smg_npc.CLIP_AMMO_MAX = 64
	self.asval_smg_npc.CLIP_AMMO_MAX = 64
	self.mp9_npc.CLIP_AMMO_MAX = 64
	
	--tweaks for rifles, 2.4 seconds of firing
	self.m4_npc.CLIP_AMMO_MAX = 30
	self.m4_yellow_npc.CLIP_AMMO_MAX = 30
	self.g36_npc.CLIP_AMMO_MAX = 30
	self.smoke_npc.CLIP_AMMO_MAX = 30
	self.ak47_ass_npc.CLIP_AMMO_MAX = 30
	self.ak47_npc.CLIP_AMMO_MAX = 30
	self.lazer_npc.CLIP_AMMO_MAX = 30
	self.quagmire_npc.CLIP_AMMO_MAX = 30
	
	--shotgun tweaks, fires 4 times before reload on FBI+ tiers
	self.r870_npc.CLIP_AMMO_MAX = 4
	self.bayou_npc.CLIP_AMMO_MAX = 4
	self.benelli_npc.CLIP_AMMO_MAX = 4
	self.blazter_npc.CLIP_AMMO_MAX = 4
	
	--custom smoke trail muzzleflash to telegraph when they'll next be able to attack
	self.r870_npc.muzzleflash = "effects/pd2_mod_hh/particles/weapons/muzzles/hivis_muzzle_shotgun_complexup"
	self.benelli_npc.muzzleflash = "effects/pd2_mod_hh/particles/weapons/muzzles/hivis_muzzle_shotgun_complexup"
	self.bayou_npc.muzzleflash = "effects/pd2_mod_hh/particles/weapons/muzzles/hivis_muzzle_shotgun_complexup"
	
	--self:_set_characters_weapon_preset(8, 6, 8, 60) --setting enemy weapon spread, unsued after court
	
	--sniper tweak
	self.m14_sniper_npc.suppression = 16
	self.m14_sniper_npc.CLIP_AMMO_MAX = 24
	self.svd_snp_npc.suppression = 16
	self.svd_snp_npc.CLIP_AMMO_MAX = 24
	self.svdsil_snp_npc.suppression = 16
	self.svdsil_snp_npc.CLIP_AMMO_MAX = 24
	self.heavy_snp_npc.DAMAGE = 1
	self.heavy_snp_npc.suppression = 16
	self.heavy_snp_npc.CLIP_AMMO_MAX = 24
	
	self.ak47_ass_npc.DAMAGE = 1
	self.mp5_npc.DAMAGE = 1
	self.ump_npc.DAMAGE = 1
	self.akmsu_smg_npc.DAMAGE = 1
	self.m4_npc.DAMAGE = 1
	self.m4_yellow_npc.DAMAGE = 1
	self.g36_npc.DAMAGE = 1
	self.ak47_npc.DAMAGE = 1
	self.smoke_npc.DAMAGE = 1
	
	--Turret tweaks.
	self.swat_van_turret_module.HEALTH_INIT = 2000
	self.swat_van_turret_module.SHIELD_HEALTH_INIT = 400
	self.swat_van_turret_module.DAMAGE = 2
	self.swat_van_turret_module.CLIP_SIZE = 800
	self.ceiling_turret_module.HEALTH_INIT = 1250
	self.ceiling_turret_module.SHIELD_HEALTH_INIT = 400
	self.ceiling_turret_module.DAMAGE = 2
	self.ceiling_turret_module.CLIP_SIZE = 300
	self.aa_turret_module.HEALTH_INIT = 4000
	self.aa_turret_module.SHIELD_HEALTH_INIT = 400
	self.aa_turret_module.DAMAGE = 4
	self.aa_turret_module.auto.fire_rate = 0.6 --sadly, the firing sound doesnt match but, functionally its a lot of fun
	self.aa_turret_module.suppression = 8
	self.aa_turret_module.CLIP_SIZE = 800
	self.crate_turret_module.HEALTH_INIT = 500
	self.crate_turret_module.SHIELD_HEALTH_INIT = 300
	self.crate_turret_module.DAMAGE = 4
	self.crate_turret_module.auto.fire_rate = 0.6
	self.crate_turret_module.suppression = 8
	self.crate_turret_module.CLIP_SIZE = 800
	
	--ceiling turret clones
	self.ceiling_turret_module_no_idle.HEALTH_INIT = 1250
	self.ceiling_turret_module_no_idle.SHIELD_HEALTH_INIT = 400
	self.ceiling_turret_module_no_idle.DAMAGE = 2
	self.ceiling_turret_module_no_idle.CLIP_SIZE = 300
	self.ceiling_turret_module_longer_range.HEALTH_INIT = 1250
	self.ceiling_turret_module_longer_range.SHIELD_HEALTH_INIT = 400
	self.ceiling_turret_module_longer_range.DAMAGE = 2
	self.ceiling_turret_module_longer_range.CLIP_SIZE = 300
end

function WeaponTweakData:_set_overkill_290()
	--saiga tweak
	self.saiga_npc.CLIP_AMMO_MAX = 16
	
	--tweaks for smgs
	self.mp5_npc.CLIP_AMMO_MAX = 64
	self.mp5_tactical_npc.CLIP_AMMO_MAX = 64
	self.ump_npc.CLIP_AMMO_MAX = 64
	self.akmsu_smg_npc.CLIP_AMMO_MAX = 64
	self.asval_smg_npc.CLIP_AMMO_MAX = 64
	self.mp9_npc.CLIP_AMMO_MAX = 64
	
	--tweaks for rifles, 2.4 seconds of firing
	self.m4_npc.CLIP_AMMO_MAX = 30
	self.m4_yellow_npc.CLIP_AMMO_MAX = 30
	self.g36_npc.CLIP_AMMO_MAX = 30
	self.smoke_npc.CLIP_AMMO_MAX = 30
	self.ak47_ass_npc.CLIP_AMMO_MAX = 30
	self.ak47_npc.CLIP_AMMO_MAX = 30
	self.lazer_npc.CLIP_AMMO_MAX = 30
	self.quagmire_npc.CLIP_AMMO_MAX = 30
	
	--shotgun tweaks, fires 4 times before reload on FBI+ tiers
	self.r870_npc.CLIP_AMMO_MAX = 4
	self.bayou_npc.CLIP_AMMO_MAX = 4
	self.benelli_npc.CLIP_AMMO_MAX = 4
	self.blazter_npc.CLIP_AMMO_MAX = 4
	
	--custom smoke trail muzzleflash to telegraph when they'll next be able to attack
	self.r870_npc.muzzleflash = "effects/pd2_mod_hh/particles/weapons/muzzles/hivis_muzzle_shotgun_complexup"
	self.benelli_npc.muzzleflash = "effects/pd2_mod_hh/particles/weapons/muzzles/hivis_muzzle_shotgun_complexup"
	self.bayou_npc.muzzleflash = "effects/pd2_mod_hh/particles/weapons/muzzles/hivis_muzzle_shotgun_complexup"
	
	--self:_set_characters_weapon_preset(8, 6, 8, 20) --setting enemy weapon spread, unbased
	
	--sniper tweak
	self.m14_sniper_npc.suppression = 16
	self.m14_sniper_npc.CLIP_AMMO_MAX = 24
	self.svd_snp_npc.suppression = 16
	self.svd_snp_npc.CLIP_AMMO_MAX = 24
	self.svdsil_snp_npc.suppression = 16
	self.svdsil_snp_npc.CLIP_AMMO_MAX = 24
	self.heavy_snp_npc.DAMAGE = 1
	self.heavy_snp_npc.suppression = 16
	self.heavy_snp_npc.CLIP_AMMO_MAX = 24
	
	self.ak47_ass_npc.DAMAGE = 1
	self.mp5_npc.DAMAGE = 1
	self.ump_npc.DAMAGE = 1
	self.akmsu_smg_npc.DAMAGE = 1
	self.m4_npc.DAMAGE = 1
	self.m4_yellow_npc.DAMAGE = 1
	self.g36_npc.DAMAGE = 1
	self.ak47_npc.DAMAGE = 1
	self.smoke_npc.DAMAGE = 1
	
	--Turret tweaks.
	self.swat_van_turret_module.HEALTH_INIT = 2000
	self.swat_van_turret_module.SHIELD_HEALTH_INIT = 400
	self.swat_van_turret_module.DAMAGE = 2
	self.swat_van_turret_module.CLIP_SIZE = 800
	self.ceiling_turret_module.HEALTH_INIT = 1250
	self.ceiling_turret_module.SHIELD_HEALTH_INIT = 400
	self.ceiling_turret_module.DAMAGE = 2
	self.ceiling_turret_module.CLIP_SIZE = 300
	self.aa_turret_module.HEALTH_INIT = 4000
	self.aa_turret_module.SHIELD_HEALTH_INIT = 400
	self.aa_turret_module.DAMAGE = 4
	self.aa_turret_module.auto.fire_rate = 0.6 --sadly, the firing sound doesnt match but, functionally its a lot of fun
	self.aa_turret_module.suppression = 8
	self.aa_turret_module.CLIP_SIZE = 800
	self.crate_turret_module.HEALTH_INIT = 500
	self.crate_turret_module.SHIELD_HEALTH_INIT = 300
	self.crate_turret_module.DAMAGE = 4
	self.crate_turret_module.auto.fire_rate = 0.6
	self.crate_turret_module.suppression = 8
	self.crate_turret_module.CLIP_SIZE = 800
	
	--ceiling turret clones
	self.ceiling_turret_module_no_idle.HEALTH_INIT = 1250
	self.ceiling_turret_module_no_idle.SHIELD_HEALTH_INIT = 400
	self.ceiling_turret_module_no_idle.DAMAGE = 2
	self.ceiling_turret_module_no_idle.CLIP_SIZE = 300
	self.ceiling_turret_module_longer_range.HEALTH_INIT = 1250
	self.ceiling_turret_module_longer_range.SHIELD_HEALTH_INIT = 400
	self.ceiling_turret_module_longer_range.DAMAGE = 2
	self.ceiling_turret_module_longer_range.CLIP_SIZE = 300
end

function WeaponTweakData:_set_sm_wish()
	--saiga tweak
	self.saiga_npc.CLIP_AMMO_MAX = 32
	
	--tweaks for smgs
	self.mp5_npc.CLIP_AMMO_MAX = 64
	self.mp5_tactical_npc.CLIP_AMMO_MAX = 64
	self.ump_npc.CLIP_AMMO_MAX = 64
	self.akmsu_smg_npc.CLIP_AMMO_MAX = 64
	self.asval_smg_npc.CLIP_AMMO_MAX = 64
	self.mp9_npc.CLIP_AMMO_MAX = 64
	
	--tweaks for rifles, 3.6 seconds of firing
	self.m4_npc.CLIP_AMMO_MAX = 45
	self.m4_yellow_npc.CLIP_AMMO_MAX = 45
	self.g36_npc.CLIP_AMMO_MAX = 45
	self.smoke_npc.CLIP_AMMO_MAX = 45
	self.ak47_ass_npc.CLIP_AMMO_MAX = 45
	self.ak47_npc.CLIP_AMMO_MAX = 45
	self.lazer_npc.CLIP_AMMO_MAX = 45
	self.quagmire_npc.CLIP_AMMO_MAX = 45
	
	--shotgun tweaks, fires 4 times before reload on FBI+ tiers
	self.r870_npc.CLIP_AMMO_MAX = 4
	self.bayou_npc.CLIP_AMMO_MAX = 4
	self.benelli_npc.CLIP_AMMO_MAX = 4
	self.blazter_npc.CLIP_AMMO_MAX = 4
	
	--custom smoke trail muzzleflash to telegraph when they'll next be able to attack
	self.r870_npc.muzzleflash = "effects/pd2_mod_hh/particles/weapons/muzzles/hivis_muzzle_shotgun_complexup"
	self.benelli_npc.muzzleflash = "effects/pd2_mod_hh/particles/weapons/muzzles/hivis_muzzle_shotgun_complexup"
	self.bayou_npc.muzzleflash = "effects/pd2_mod_hh/particles/weapons/muzzles/hivis_muzzle_shotgun_complexup"
	
	--self:_set_characters_weapon_preset(4, 2, 4, 10) --setting enemy weapon spread, uncringed
	
	--sniper tweak
	self.m14_sniper_npc.suppression = 40 --They'll lock your armor regen down after breaking it for a little while, but can't pierce your armor anymore.
	self.m14_sniper_npc.CLIP_AMMO_MAX = 24
	self.svd_snp_npc.suppression = 40
	self.svd_snp_npc.CLIP_AMMO_MAX = 24
	self.svdsil_snp_npc.suppression = 40
	self.svdsil_snp_npc.CLIP_AMMO_MAX = 24
	self.heavy_snp_npc.DAMAGE = 1
	self.heavy_snp_npc.suppression = 16
	self.heavy_snp_npc.CLIP_AMMO_MAX = 24
	
	self.ak47_ass_npc.DAMAGE = 1
	self.mp5_npc.DAMAGE = 1
	self.ump_npc.DAMAGE = 1
	self.akmsu_smg_npc.DAMAGE = 1
	self.m4_npc.DAMAGE = 1
	self.m4_yellow_npc.DAMAGE = 1
	self.g36_npc.DAMAGE = 1
	self.ak47_npc.DAMAGE = 1
	self.smoke_npc.DAMAGE = 1
	self.lazer_npc.DAMAGE = 1
	self.quagmire_npc.DAMAGE = 1
	
	--Turret tweaks.
	self.swat_van_turret_module.HEALTH_INIT = 2500
	self.swat_van_turret_module.SHIELD_HEALTH_INIT = 400
	self.swat_van_turret_module.DAMAGE = 2
	self.swat_van_turret_module.CLIP_SIZE = 800
	self.ceiling_turret_module.HEALTH_INIT = 1500
	self.ceiling_turret_module.SHIELD_HEALTH_INIT = 400
	self.ceiling_turret_module.DAMAGE = 2
	self.ceiling_turret_module.CLIP_SIZE = 300
	self.aa_turret_module.HEALTH_INIT = 4000
	self.aa_turret_module.SHIELD_HEALTH_INIT = 400
	self.aa_turret_module.DAMAGE = 4
	self.aa_turret_module.auto.fire_rate = 0.6 --sadly, the firing sound doesnt match but, functionally its a lot of fun
	self.aa_turret_module.suppression = 8
	self.aa_turret_module.CLIP_SIZE = 800
	self.crate_turret_module.HEALTH_INIT = 500
	self.crate_turret_module.SHIELD_HEALTH_INIT = 300
	self.crate_turret_module.DAMAGE = 4
	self.crate_turret_module.auto.fire_rate = 0.6
	self.crate_turret_module.suppression = 8
	self.crate_turret_module.CLIP_SIZE = 800
	
	--ceiling turret clones
	self.ceiling_turret_module_no_idle.HEALTH_INIT = 1500
	self.ceiling_turret_module_no_idle.SHIELD_HEALTH_INIT = 400
	self.ceiling_turret_module_no_idle.DAMAGE = 2
	self.ceiling_turret_module_no_idle.CLIP_SIZE = 300
	self.ceiling_turret_module_longer_range.HEALTH_INIT = 1500
	self.ceiling_turret_module_longer_range.SHIELD_HEALTH_INIT = 400
	self.ceiling_turret_module_longer_range.DAMAGE = 2
	self.ceiling_turret_module_longer_range.CLIP_SIZE = 300
end

--glowstick
function WeaponTweakData:_init_data_npc_melee()
	self.npc_melee = {
		baton = {}
	}
	self.npc_melee.baton.unit_name = Idstring("units/payday2/characters/ene_acc_baton/ene_acc_baton")
	self.npc_melee.baton.damage = 10
	self.npc_melee.baton.animation_param = "melee_baton"
	self.npc_melee.baton.player_blood_effect = true
	self.npc_melee.knife_1 = {
		unit_name = Idstring("units/payday2/characters/ene_acc_knife_1/ene_acc_knife_1"),
		damage = 15,
		animation_param = "melee_knife",
		player_blood_effect = true
	}
	self.npc_melee.glowstick = {
		unit_name = Idstring("units/pd2_dlc_gitgud/characters/ene_acc_glowstick/ene_acc_glowstick"),
		damage = 15,
		animation_param = "melee_knife",
		player_blood_effect = true
	}
	self.npc_melee.fists = {
		unit_name = nil,
		damage = 8,
		animation_param = "melee_fist",
		player_blood_effect = true
	}
	self.npc_melee.helloween = {
		unit_name = Idstring("units/pd2_halloween/weapons/wpn_mel_titan_hammer/wpn_mel_titan_hammer"),
		damage = 10,
		animation_param = "melee_fireaxe",
		player_blood_effect = true
	}
end

--OVERHAUL STUFF

Hooks:PostHook( WeaponTweakData, "init", "gambyt_weapons", function(self)

-- SUBMACHINE GUNS

-- Chicago Typewriter
self.m1928.stats.spread = 16
self.m1928.AMMO_MAX = 120  
self.x_m1928.AMMO_MAX = 150  
self.m1928.kick.standing = self.new_m4.kick.standing
self.m1928.kick.crouching = self.new_m4.kick.crouching
self.m1928.kick.steelsight = self.new_m4.kick.steelsight
self.x_m1928.kick = {
standing = {
		1.0,
		2.1,
		-0.6,
		0.6
},
steelsight = {
		1.0,
		2.1,
		-0.6,
		0.6
},
crouching = {
		1.0,
		2.1,
		-0.6,
		0.6
}
}

-- Jackal
self.schakal.stats.spread = 17
self.schakal.AMMO_PICKUP = {3, 6.5}
self.schakal.AMMO_MAX = 100
self.schakal.stats.damage = 78

self.x_schakal.stats.damage = 78
self.x_schakal.AMMO_PICKUP = {3, 6.5}
self.x_schakal.AMMO_MAX = 120
self.x_schakal.AMMO_PICKUP = {2, 5}
self.x_schakal.kick = {
standing = {
		1.3,
		2.5,
		-1.2,
		1
},
steelsight = {
		0.7,
		1.6,
		-0.8,
		0.6
},
crouching = {
		0.7,
		1.6,
		-0.8,
		0.6
}
}

-- MP40
self.erma.stats.damage = 59
self.x_erma.stats.damage = 59
self.erma.stats.spread = 16
self.erma.stats.recoil = 15
self.erma.AMMO_MAX = 150
self.x_erma.AMMO_MAX = 200
self.x_erma.stats.spread = 16
self.erma.AMMO_PICKUP = {1.5, 7}
self.x_erma.AMMO_PICKUP = {1.5, 7}
self.erma.kick.standing = self.new_m4.kick.standing
self.erma.kick.crouching = self.new_m4.kick.crouching
self.erma.kick.steelsight = self.new_m4.kick.steelsight
self.x_erma.kick = {
standing = {
		1.0,
		2.1,
		-0.6,
		0.6
},
steelsight = {
		1.0,
		2.1,
		-0.6,
		0.6
},
crouching = {
		1.0,
		2.1,
		-0.6,
		0.6
}
}

-- Heather
self.sr2.AMMO_MAX = 120
self.sr2.stats.spread = 17
self.sr2.AMMO_PICKUP = {1.5, 7}
self.x_sr2.AMMO_MAX = 150  
self.sr2.kick.standing = self.new_m4.kick.standing
self.sr2.kick.crouching = self.new_m4.kick.crouching
self.sr2.kick.steelsight = self.new_m4.kick.steelsight
self.x_sr2.kick = {
standing = {
		1.0,
		2.1,
		-0.6,
		0.6
},
steelsight = {
		1.0,
		2.1,
		-0.6,
		0.6
},
crouching = {
		1.0,
		2.1,
		-0.6,
		0.6
}
}

-- Para
self.olympic.CLIP_AMMO_MAX = 30
self.olympic.AMMO_MAX = 120  
self.x_olympic.AMMO_MAX = 150  
self.olympic.kick.standing = self.new_m4.kick.standing
self.olympic.kick.crouching = self.new_m4.kick.crouching
self.olympic.kick.steelsight = self.new_m4.kick.steelsight
self.x_olympic.kick = {
standing = {
		1.0,
		2.1,
		-0.6,
		0.6
},
steelsight = {
		1.0,
		2.1,
		-0.6,
		0.6
},
crouching = {
		1.0,
		2.1,
		-0.6,
		0.6
}
}

-- Patchett
self.sterling.stats.damage = 128
self.sterling.stats.spread = 16
self.sterling.AMMO_PICKUP = {1, 3}
self.sterling.AMMO_MAX = 60
self.sterling.kick = {
standing = {
		1.3,
		2.5,
		-1.2,
		1
},
steelsight = {
		0.7,
		1.6,
		-0.8,
		0.6
},
crouching = {
		0.7,
		1.6,
		-0.8,
		0.6
}
}

self.x_sterling.stats.damage = 128
self.x_sterling.stats.spread = 17
self.x_sterling.AMMO_PICKUP = {1, 3}
self.x_sterling.AMMO_MAX = 50
self.x_sterling.kick = {
standing = {
		1.0,
		2.1,
		-0.6,
		0.6
},
steelsight = {
		1.0,
		2.1,
		-0.6,
		0.6
},
crouching = {
		1.0,
		2.1,
		-0.6,
		0.6
}
}

-- Micro Uzi
self.baka.stats.damage = 49
self.baka.AMMO_MAX = 200  
self.x_baka.AMMO_MAX = 200  
self.baka.kick = {
standing = {
	-0.2,
	0.4,
	-1,
	1
},
steelsight = {
	0.1,
	0.4,
	-0.5,
	0.5
},
crouching = {
	0.1,
	0.4,
	-0.5,
	0.5
}}
self.x_baka.kick = {
standing = {
		1.0,
		2.1,
		-0.6,
		0.6
},
steelsight = {
		1.0,
		2.1,
		-0.6,
		0.6
},
crouching = {
		1.0,
		2.1,
		-0.6,
		0.6
}
}

-- Swedish K
self.m45.AMMO_MAX = 80
self.x_m45.AMMO_MAX = 90
self.m45.AMMO_PICKUP = {2, 5}
self.m45.kick = {
standing = {
		1.3,
		2.5,
		-1.2,
		1
},
steelsight = {
		0.7,
		1.6,
		-0.8,
		0.6
},
crouching = {
		0.7,
		1.6,
		-0.8,
		0.6
}
}
self.x_m45.kick = {
standing = {
		1.0,
		2.1,
		-0.6,
		0.6
},
steelsight = {
		1.0,
		2.1,
		-0.6,
		0.6
},
crouching = {
		1.0,
		2.1,
		-0.6,
		0.6
}
}


-- Tatonka
self.coal.AMMO_PICKUP = {4, 8}
self.coal.AMMO_MAX = 120
self.coal.stats.spread = 17
self.coal.stats.damage = 59
self.coal.kick.standing = self.new_m4.kick.standing
self.coal.kick.crouching = self.new_m4.kick.crouching
self.coal.kick.steelsight = self.new_m4.kick.steelsight

self.x_coal.AMMO_MAX = 150
self.x_coal.stats.spread = 17
self.x_coal.stats.damage = 59
self.x_coal.AMMO_PICKUP = {1.5, 7}
self.x_m45.kick = {
standing = {
		1.0,
		2.1,
		-0.6,
		0.6
},
steelsight = {
		1.0,
		2.1,
		-0.6,
		0.6
},
crouching = {
		1.0,
		2.1,
		-0.6,
		0.6
}
}

-- Cobra
self.scorpion.stats.spread = 16
self.scorpion.AMMO_MAX = 150
self.scorpion.stats.damage = 49
self.scorpion.kick = {
standing = {
	-0.2,
	0.4,
	-1,
	1
},
steelsight = {
	0.1,
	0.4,
	-0.5,
	0.5
},
crouching = {
	0.1,
	0.4,
	-0.5,
	0.5
}}
self.x_scorpion.AMMO_MAX = 200
self.x_scorpion.kick = {
standing = {
		1.0,
		2.1,
		-0.6,
		0.6
},
steelsight = {
		1.0,
		2.1,
		-0.6,
		0.6
},
crouching = {
		1.0,
		2.1,
		-0.6,
		0.6
}
}

-- CMP
self.mp9.stats.spread = 16
self.mp9.AMMO_MAX = 150
self.mp9.stats.damage = 49
self.x_mp9.AMMO_MAX = 200
self.mp9.kick = {
standing = {
	-0.2,
	0.4,
	-1,
	1
},
steelsight = {
	0.1,
	0.4,
	-0.5,
	0.5
},
crouching = {
	0.1,
	0.4,
	-0.5,
	0.5
}}
self.x_mp9.kick = {
standing = {
		1.0,
		2.1,
		-0.6,
		0.6
},
steelsight = {
		1.0,
		2.1,
		-0.6,
		0.6
},
crouching = {
		1.0,
		2.1,
		-0.6,
		0.6
}
}
-- Jacket's Piece
self.cobray.stats.spread = 15
self.cobray.AMMO_MAX = 120
self.x_cobray.AMMO_MAX = 150  
self.cobray.stats.damage = 61
self.x_cobray.stats.damage = 61
self.cobray.kick.standing = self.new_m4.kick.standing
self.cobray.kick.crouching = self.new_m4.kick.crouching
self.cobray.kick.steelsight = self.new_m4.kick.steelsight
self.x_cobray.kick = {
standing = {
		1.0,
		2.1,
		-0.6,
		0.6
},
steelsight = {
		1.0,
		2.1,
		-0.6,
		0.6
},
crouching = {
		1.0,
		2.1,
		-0.6,
		0.6
}
}

-- Kross Vertex
self.polymer.stats.spread = 15
self.polymer.AMMO_MAX = 120  
self.x_polymer.AMMO_MAX = 150  
self.polymer.kick.standing = self.new_m4.kick.standing
self.polymer.kick.crouching = self.new_m4.kick.crouching
self.polymer.kick.steelsight = self.new_m4.kick.steelsight
self.x_polymer.kick = {
standing = {
		1.0,
		2.1,
		-0.6,
		0.6
},
steelsight = {
		1.0,
		2.1,
		-0.6,
		0.6
},
crouching = {
		1.0,
		2.1,
		-0.6,
		0.6
}
}

-- Kobus 90
self.p90.AMMO_PICKUP = {0.5, 3}
self.x_p90.AMMO_PICKUP = {0.5, 3}
self.p90.stats.spread = 12
self.x_p90.stats.spread = 12
self.p90.stats.damage = 39
self.x_p90.stats.damage = 39
self.p90.AMMO_MAX = 100
self.x_p90.AMMO_MAX = 120
self.p90.can_shoot_through_shield = true
self.p90.can_shoot_through_enemy = true
self.p90.can_shoot_through_wall = true
self.x_p90.can_shoot_through_shield = true
self.x_p90.can_shoot_through_enemy = true
self.x_p90.can_shoot_through_wall = true
self.p90.kick.standing = self.akm.kick.standing
self.p90.kick.crouching = self.akm.kick.crouching
self.p90.kick.steelsight = self.akm.kick.steelsight
self.x_p90.kick = {
standing = {
		1.0,
		2.1,
		-0.6,
		0.6
},
steelsight = {
		1.0,
		2.1,
		-0.6,
		0.6
},
crouching = {
		1.0,
		2.1,
		-0.6,
		0.6
}
}

-- Blaster 9mm
self.tec9.stats.spread = 16
self.tec9.AMMO_MAX = 150
self.tec9.stats.damage = 49
self.tec9.kick = {
standing = {
	-0.2,
	0.4,
	-1,
	1
},
steelsight = {
	0.1,
	0.4,
	-0.5,
	0.5
},
crouching = {
	0.1,
	0.4,
	-0.5,
	0.5
}}
self.x_tec9.kick = {
standing = {
		1.0,
		2.1,
		-0.6,
		0.6
},
steelsight = {
		1.0,
		2.1,
		-0.6,
		0.6
},
crouching = {
		1.0,
		2.1,
		-0.6,
		0.6
}
}

self.x_tec9.stats.spread = 16
self.x_tec9.AMMO_MAX = 200
self.x_tec9.stats.damage = 49

-- Signature SMG
self.shepheard.stats.spread = 16
self.shepheard.stats.damage = 59
self.shepheard.stats.recoil = 15
self.shepheard.AMMO_PICKUP = {4, 8}
self.shepheard.AMMO_MAX = 120 
self.shepheard.kick.standing = self.new_m4.kick.standing
self.shepheard.kick.crouching = self.new_m4.kick.crouching
self.shepheard.kick.steelsight = self.new_m4.kick.steelsight
self.x_shepheard.AMMO_MAX = 150   
self.x_shepheard.stats.spread = 16
self.x_shepheard.stats.damage = 59
self.x_shepheard.stats.recoil = 15
self.x_shepheard.AMMO_PICKUP = {1.5, 7}
self.x_shepheard.kick = {
standing = {
		1.0,
		2.1,
		-0.6,
		0.6
},
steelsight = {
		1.0,
		2.1,
		-0.6,
		0.6
},
crouching = {
		1.0,
		2.1,
		-0.6,
		0.6
}
}

-- Uzi
self.uzi.AMMO_MAX = 150
self.uzi.stats.damage = 49
self.x_uzi.AMMO_MAX = 200
self.uzi.kick = {
standing = {
	-0.2,
	0.4,
	-1,
	1
},
steelsight = {
	0.1,
	0.4,
	-0.5,
	0.5
},
crouching = {
	0.1,
	0.4,
	-0.5,
	0.5
}}
self.x_uzi.kick = {
standing = {
		1.0,
		2.1,
		-0.6,
		0.6
},
steelsight = {
		1.0,
		2.1,
		-0.6,
		0.6
},
crouching = {
		1.0,
		2.1,
		-0.6,
		0.6
}
}

-- Compact-5
self.new_mp5.stats.spread = 16
self.new_mp5.stats.damage = 59
self.new_mp5.stats.recoil = 15
self.new_mp5.AMMO_PICKUP = {4, 8}
self.new_mp5.AMMO_MAX = 120  
self.x_mp5.AMMO_MAX = 150  
self.x_mp5.stats.spread = 16
self.x_mp5.stats.damage = 59
self.x_mp5.stats.recoil = 15
self.x_mp5.AMMO_PICKUP = {1.5, 7}
self.new_mp5.kick.standing = self.new_m4.kick.standing
self.new_mp5.kick.crouching = self.new_m4.kick.crouching
self.new_mp5.kick.steelsight = self.new_m4.kick.steelsight
self.x_mp5.kick = {
standing = {
		1.0,
		2.1,
		-0.6,
		0.6
},
steelsight = {
		1.0,
		2.1,
		-0.6,
		0.6
},
crouching = {
		1.0,
		2.1,
		-0.6,
		0.6
}
}

-- Mark 10
self.mac10.AMMO_MAX = 120  
self.x_mac10.AMMO_MAX = 150  
self.mac10.kick.standing = self.new_m4.kick.standing
self.mac10.kick.crouching = self.new_m4.kick.crouching
self.mac10.kick.steelsight = self.new_m4.kick.steelsight
self.x_mac10.kick = {
standing = {
		1.0,
		2.1,
		-0.6,
		0.6
},
steelsight = {
		1.0,
		2.1,
		-0.6,
		0.6
},
crouching = {
		1.0,
		2.1,
		-0.6,
		0.6
}
}

-- SpecOps
self.mp7.AMMO_MAX = 120
self.x_mp7.AMMO_MAX = 150  
self.mp7.kick.standing = self.new_m4.kick.standing
self.mp7.kick.crouching = self.new_m4.kick.crouching
self.mp7.kick.steelsight = self.new_m4.kick.steelsight
self.x_mp7.kick = {
standing = {
		1.0,
		2.1,
		-0.6,
		0.6
},
steelsight = {
		1.0,
		2.1,
		-0.6,
		0.6
},
crouching = {
		1.0,
		2.1,
		-0.6,
		0.6
}
}

--Krinkov
self.akmsu.AMMO_PICKUP = {3, 6.5}
self.akmsu.AMMO_MAX = 100
self.akmsu.stats.damage = 78
self.akmsu.kick = {
standing = {
		1.3,
		2.5,
		-1.2,
		1
},
steelsight = {
		0.7,
		1.6,
		-0.8,
		0.6
},
crouching = {
		0.7,
		1.6,
		-0.8,
		0.6
}
}
self.x_akmsu.kick = {
standing = {
		1.0,
		2.1,
		-0.6,
		0.6
},
steelsight = {
		1.0,
		2.1,
		-0.6,
		0.6
},
crouching = {
		1.0,
		2.1,
		-0.6,
		0.6
}
}

self.x_akmsu.AMMO_MAX = 120
self.x_akmsu.stats.damage = 78
self.x_akmsu.AMMO_PICKUP = {2, 5}

--CR805B
self.hajk.AMMO_PICKUP = {2, 5}
self.hajk.AMMO_MAX = 80 
self.hajk.kick = {
standing = {
		1.3,
		2.5,
		-1.2,
		1
},
steelsight = {
		0.7,
		1.6,
		-0.8,
		0.6
},
crouching = {
		0.7,
		1.6,
		-0.8,
		0.6
}
}
self.x_hajk.kick = {
standing = {
		1.0,
		2.1,
		-0.6,
		0.6
},
steelsight = {
		1.0,
		2.1,
		-0.6,
		0.6
},
crouching = {
		1.0,
		2.1,
		-0.6,
		0.6
}
}

self.x_hajk.AMMO_MAX = 90

--RIFLES--

--AMCAR
self.amcar.stats.damage = 41
self.amcar.AMMO_MAX = 180
self.amcar.stats.spread = 15
self.amcar.CLIP_AMMO_MAX = 30
self.amcar.stats.damage = 49
self.amcar.AMMO_PICKUP = {6, 10}
self.amcar.kick = {
standing = {
	-0.2,
	0.4,
	-1,
	1
},
steelsight = {
	0.1,
	0.4,
	-0.5,
	0.5
},
crouching = {
	0.1,
	0.4,
	-0.5,
	0.5
}}

--CAR-4
self.new_m4.stats.damage = 55
self.new_m4.kick = {
standing = {
		1,
		2,
		-0.5,
		0.8
},
steelsight = {
		0.5,
		1,
		-0.1,
		0.1
},
crouching = {
		0.5,
		1,
		-0.1,
		0.1
}
}

--AK
self.ak74.stats.damage = 57

--Bootleg
self.tecci.CLIP_AMMO_MAX = 100 
self.tecci.AMMO_MAX = 200  
self.tecci.stats.damage = 59
self.tecci.stats.concealment = 8
self.tecci.stats.spread = 11
self.tecci.stats.recoil = 13
self.tecci.AMMO_PICKUP = {4, 8}
self.tecci.kick.standing = self.new_m4.kick.standing
self.tecci.kick.crouching = self.new_m4.kick.crouching
self.tecci.kick.steelsight = self.new_m4.kick.steelsight

--Union 5.56
self.corgi.kick.standing = self.new_m4.kick.standing
self.corgi.kick.crouching = self.new_m4.kick.crouching
self.corgi.kick.steelsight = self.new_m4.kick.steelsight

-- JP36
self.g36.AMMO_PICKUP = {6, 10}
self.g36.AMMO_MAX = 180
self.g36.stats.damage = 49
self.g36.stats.spread = 14
self.g36.kick = {
standing = {
	-0.2,
	0.4,
	-1,
	1
},
steelsight = {
	0.1,
	0.4,
	-0.5,
	0.5
},
crouching = {
	0.1,
	0.4,
	-0.5,
	0.5
}}

--UAR
self.aug.kick.standing = self.new_m4.kick.standing
self.aug.kick.crouching = self.new_m4.kick.crouching
self.aug.kick.steelsight = self.new_m4.kick.steelsight

--Queen's Wrath
self.l85a2.kick.standing = self.new_m4.kick.standing
self.l85a2.kick.crouching = self.new_m4.kick.crouching
self.l85a2.kick.steelsight = self.new_m4.kick.steelsight

-- Clarion
self.famas.AMMO_PICKUP = {6, 10}
self.famas.AMMO_MAX = 180
self.famas.stats.spread = 14
self.famas.stats.damage = 49
self.famas.kick = {
standing = {
	-0.2,
	0.4,
	-1,
	1
},
steelsight = {
	0.1,
	0.4,
	-0.5,
	0.5
},
crouching = {
	0.1,
	0.4,
	-0.5,
	0.5
}}

--Little Friend
self.contraband.AMMO_PICKUP = {3, 5}
self.contraband.stats.damage = 59
self.contraband.stats.spread = 18
self.contraband.stats.recoil = 17
self.contraband.AMMO_MAX = 120
self.contraband.CLIP_AMMO_MAX = 30
self.contraband.kick = {
standing = {
		1.2,
		2.2,
		-0.7,
		0.9
},
steelsight = {
		0.5,
		1,
		-0.1,
		0.1
},
crouching = {
		0.5,
		1,
		-0.1,
		0.1
}
}

self.contraband_m203.CLIP_AMMO_MAX = 1
self.contraband_m203.AMMO_MAX = 1
self.contraband_m203.AMMO_PICKUP = {0, 0.6}

--Commando 553
self.s552.CLIP_AMMO_MAX = 30
self.s552.AMMO_MAX = 150
self.s552.stats.damage = 59
self.s552.stats.spread = 14
self.s552.stats.recoil = 16
self.s552.AMMO_PICKUP = {4, 8}
self.s552.kick.standing = self.new_m4.kick.standing
self.s552.kick.crouching = self.new_m4.kick.crouching
self.s552.kick.steelsight = self.new_m4.kick.steelsight

--Gewehr
self.g3.AMMO_MAX = 120
self.g3.stats.damage = 79
self.g3.AMMO_PICKUP = {3, 6.5}
self.g3.stats.recoil = 17
self.g3.kick = {
standing = {
		1.3,
		2.5,
		-1.2,
		1
},
steelsight = {
		0.7,
		1.6,
		-0.8,
		0.6
},
crouching = {
		0.7,
		1.6,
		-0.8,
		0.6
}
}

--Valkyria
self.asval.AMMO_MAX = 100
self.asval.stats.spread = 18
self.asval.stats.recoil = 16
self.asval.stats.damage = 61
self.asval.can_shoot_through_shield = true
self.asval.can_shoot_through_enemy = true
self.asval.can_shoot_through_wall = true
self.asval.kick.standing = self.akm.kick.standing
self.asval.kick.crouching = self.akm.kick.crouching
self.asval.kick.steelsight = self.akm.kick.steelsight
self.asval.AMMO_PICKUP = {2, 4}

--Tempest
self.komodo.AMMO_MAX = 150
self.komodo.stats.spread = 16
self.komodo.stats.recoil = 17
self.komodo.stats.damage = 59
self.komodo.kick.standing = self.new_m4.kick.standing
self.komodo.kick.crouching = self.new_m4.kick.crouching
self.komodo.kick.steelsight = self.new_m4.kick.steelsight

--Eagle Heavy
self.scar.CLIP_AMMO_MAX = 30
self.scar.AMMO_MAX = 100
self.scar.AMMO_PICKUP = {2, 6}
self.scar.kick = {
standing = {
		1.3,
		2.5,
		-1.2,
		1
},
steelsight = {
		0.7,
		1.6,
		-0.8,
		0.6
},
crouching = {
		0.7,
		1.6,
		-0.8,
		0.6
}
}


--AK 762
self.akm.AMMO_PICKUP = {2, 6}
self.akm.AMMO_MAX = 100
self.akm.kick = {
standing = {
		1.3,
		2.5,
		-1.2,
		1
},
steelsight = {
		0.7,
		1.6,
		-0.8,
		0.6
},
crouching = {
		0.7,
		1.6,
		-0.8,
		0.6
}
}

--Gold AK
self.akm_gold.AMMO_PICKUP = {2, 6}
self.akm_gold.AMMO_MAX = 100
self.akm_gold.kick = {
standing = {
		1.3,
		2.5,
		-1.2,
		1
},
steelsight = {
		0.7,
		1.6,
		-0.8,
		0.6
},
crouching = {
		0.7,
		1.6,
		-0.8,
		0.6
}
}

--AK17
self.flint.AMMO_PICKUP = {2, 6}
self.flint.AMMO_MAX = 100
self.flint.CLIP_AMMO_MAX = 30
self.flint.kick = {
standing = {
		1.3,
		2.5,
		-1.2,
		1
},
steelsight = {
		0.7,
		1.6,
		-0.8,
		0.6
},
crouching = {
		0.7,
		1.6,
		-0.8,
		0.6
}
}

--Falcon
self.fal.AMMO_PICKUP = {2, 6}
self.fal.kick = {
standing = {
		1.3,
		2.5,
		-1.2,
		1
},
steelsight = {
		0.7,
		1.6,
		-0.8,
		0.6
},
crouching = {
		0.7,
		1.6,
		-0.8,
		0.6
}
}

--AMR16
self.m16.AMMO_PICKUP = {2, 6}
self.m16.AMMO_MAX = 100
self.m16.kick = {
standing = {
		1.3,
		2.5,
		-1.2,
		1
},
steelsight = {
		0.7,
		1.6,
		-0.8,
		0.6
},
crouching = {
		0.7,
		1.6,
		-0.8,
		0.6
}
}

--Lion's Roar
self.vhs.AMMO_MAX = 120
self.vhs.stats.spread = 15
self.vhs.stats.damage = 79
self.vhs.AMMO_PICKUP = {3, 6.5}
self.vhs.stats.recoil = 17
self.vhs.kick = {
standing = {
		1.3,
		2.5,
		-1.2,
		1
},
steelsight = {
		0.7,
		1.6,
		-0.8,
		0.6
},
crouching = {
		0.7,
		1.6,
		-0.8,
		0.6
}
}

--Gecko
self.galil.AMMO_MAX = 120
self.galil.stats.spread = 13
self.galil.stats.damage = 79
self.galil.AMMO_PICKUP = {3, 6.5}
self.galil.stats.recoil = 18
self.galil.kick = {
standing = {
		1.3,
		2.5,
		-1.2,
		1
},
steelsight = {
		0.7,
		1.6,
		-0.8,
		0.6
},
crouching = {
		0.7,
		1.6,
		-0.8,
		0.6
}
}
self.galil.CLIP_AMMO_MAX = 25

--M308
self.new_m14.AMMO_PICKUP = {1, 2.7}
self.new_m14.AMMO_MAX = 60
self.new_m14.fire_mode_data.fire_rate = .12
self.new_m14.kick = {
standing = {
		3,
		4,
		-0.5,
		0.5
},
steelsight = {
		2,
		2.5,
		-0.5,
		0.5
},
crouching = {
		1.3,
		2,
		-0.2,
		0.2
}
}


--Galant
self.ching.fire_mode_data.fire_rate = .12
self.ching.AMMO_PICKUP = {1, 2.7}
self.ching.AMMO_MAX = 60
self.ching.kick.standing = self.new_m14.kick.standing
self.ching.kick.crouching = self.new_m14.kick.crouching
self.ching.kick.steelsight = self.new_m14.kick.steelsight

--Cavity
self.sub2000.AMMO_PICKUP = {1, 3}
self.sub2000.stats.damage = 120
self.sub2000.AMMO_MAX = 70

--SHOTGUNS--

--Goliath
self.rota.AMMO_MAX = 40
self.x_rota.AMMO_MAX = 40
self.x_rota.stats.damage = 130
self.rota.stats.damage = 130
self.rota.damage_near = 550
self.rota.damage_far = 1050
self.x_rota.damage_near = 550
self.x_rota.damage_far = 1050
self.x_rota.AMMO_PICKUP = {2, 5}
self.rota.AMMO_PICKUP = {2, 5}
self.rota.kick = {
standing = {
		4.5,
		5.5,
		-1.5,
		1.5
},
steelsight = {
		3.5,
		4,
		-1.5,
		1.5
},
crouching = {
		3.5,
		4,
		-1.5,
		1.5
}
}
self.x_rota.kick = {
standing = {
		4.5,
		5.5,
		-1.5,
		1.5
},
steelsight = {
		3.5,
		4,
		-1.5,
		1.5
},
crouching = {
		3.5,
		4,
		-1.5,
		1.5
}
}

--Reinfeld
self.r870.fire_mode_data.fire_rate = 0.35294117647
self.r870.stats.damage = 190
self.r870.damage_near = 650
self.r870.damage_far = 1120
self.r870.AMMO_PICKUP = {1.8, 2.9}
self.r870.kick = {
standing = {
		3,
		4,
		-0.5,
		0.5
},
steelsight = {
		2,
		3,
		-0.2,
		0.2
},
crouching = {
		2,
		3,
		-0.2,
		0.2
}
}

--Locomotive
self.serbu.AMMO_MAX = 30
self.serbu.stats.damage = 190
self.serbu.damage_near = 500
self.serbu.damage_far = 1050
self.serbu.AMMO_PICKUP = {1.8, 2.9}
self.serbu.fire_mode_data.fire_rate = 0.35294117647
self.serbu.kick = {
standing = {
		3,
		4,
		-0.5,
		0.5
},
steelsight = {
		2,
		3,
		-0.2,
		0.2
},
crouching = {
		2,
		3,
		-0.2,
		0.2
}
}

--Reinfeld 88
self.m1897.AMMO_MAX = 42
self.m1897.fire_mode_data.fire_rate = 0.4 
self.m1897.stats.damage = 190
self.m1897.damage_near = 650
self.m1897.damage_far = 1120
self.m1897.AMMO_PICKUP = {1.8, 2.9}
self.m1897.kick = {
standing = {
		3,
		4,
		-0.5,
		0.5
},
steelsight = {
		2,
		3,
		-0.2,
		0.2
},
crouching = {
		2,
		3,
		-0.2,
		0.2
}
}

--M1014
self.benelli.stats.damage = 130
self.benelli.damage_near = 650
self.benelli.damage_far = 1120
self.benelli.AMMO_PICKUP = {2, 5}
self.benelli.fire_mode_data.fire_rate = 0.12
self.benelli.AMMO_MAX = 50
self.benelli.kick = {
standing = {
		4.5,
		5.5,
		-1.5,
		1.5
},
steelsight = {
		3.5,
		4,
		-1.5,
		1.5
},
crouching = {
		3.5,
		4,
		-1.5,
		1.5
}
}

--Predator
self.spas12.stats.damage = 130
self.spas12.damage_near = 650
self.spas12.damage_far = 1120
self.spas12.AMMO_PICKUP = {2, 4}
self.spas12.fire_mode_data.fire_rate = 0.12
self.spas12.AMMO_MAX = 50
self.spas12.kick = {
standing = {
		4.5,
		5.5,
		-1.5,
		1.5
},
steelsight = {
		3.5,
		4,
		-1.5,
		1.5
},
crouching = {
		3.5,
		4,
		-1.5,
		1.5
}
}

--Steakout
self.aa12.stats.damage = 100
self.aa12.damage_near = 650
self.aa12.damage_far = 1120
self.aa12.AMMO_PICKUP = {2, 5}
self.aa12.AMMO_MAX = 60
self.aa12.kick = {
standing = {
		4,
		5,
		-1,
		1
},
steelsight = {
		3,
		3.5,
		-1,
		1
},
crouching = {
		3,
		3.5,
		-1,
		1
}
}

--Raven
self.ksg.stats.damage = 190
self.ksg.damage_near = 600
self.ksg.damage_far = 1100
self.ksg.AMMO_PICKUP = {1.8, 2.9}
self.ksg.kick = {
standing = {
		3,
		4,
		-0.5,
		0.5
},
steelsight = {
		2,
		3,
		-0.2,
		0.2
},
crouching = {
		2,
		3,
		-0.2,
		0.2
}
}

--Grimm
self.x_basset.AMMO_MAX = 50
self.x_basset.stats.damage = 85
self.basset.stats.damage = 85
self.basset.damage_near = 550
self.basset.AMMO_MAX = 50
self.basset.damage_far = 1050
self.x_basset.damage_near = 550
self.x_basset.damage_far = 1050
self.basset.AMMO_PICKUP = {2, 5}
self.x_basset.AMMO_PICKUP = {2, 5}
self.basset.kick = {
standing = {
		4,
		5,
		-1,
		1
},
steelsight = {
		3,
		3.5,
		-1,
		1
},
crouching = {
		3,
		3.5,
		-1,
		1
}
}
self.x_basset.kick = {
standing = {
		4,
		5,
		-1,
		1
},
steelsight = {
		3,
		3.5,
		-1,
		1
},
crouching = {
		3,
		3.5,
		-1,
		1
}
}

--Izhma
self.saiga.stats.damage = 100
self.saiga.damage_near = 650
self.saiga.damage_far = 1120
self.saiga.AMMO_PICKUP = {2, 5}
self.saiga.AMMO_MAX = 60
self.saiga.kick = {
standing = {
		4,
		5,
		-1,
		1
},
steelsight = {
		3,
		3.5,
		-1,
		1
},
crouching = {
		3,
		3.5,
		-1,
		1
}
}

--Claire
self.coach.stats.damage = 200
self.coach.stats_modifiers = {damage = 2}
self.coach.stats.damage = 200
self.coach.stats_modifiers = {damage = 2}
self.coach.AMMO_MAX = 24
self.coach.damage_near = 650
self.coach.damage_far = 1120
self.coach.fire_mode_data.fire_rate = 0.075
self.coach.kick = {
standing = {
		4,
		5,
		-1,
		1
},
steelsight = {
		3,
		3.5,
		-1,
		1
},
crouching = {
		3,
		3.5,
		-1,
		1
}
}

--Mosconi
self.huntsman.stats.damage = 200
self.huntsman.stats_modifiers = {damage = 2}
self.huntsman.fire_mode_data.fire_rate = 0.075
self.huntsman.damage_near = 750
self.huntsman.damage_far = 1450
self.huntsman.kick = {
standing = {
		4,
		5,
		-1,
		1
},
steelsight = {
		3,
		3.5,
		-1,
		1
},
crouching = {
		3,
		3.5,
		-1,
		1
}
}

--Joceline
self.b682.stats.damage = 200
self.b682.stats_modifiers = {damage = 2}
self.b682.damage_near = 750
self.b682.damage_far = 1450
self.b682.fire_mode_data.fire_rate = 0.075
self.b682.kick = {
standing = {
		4,
		5,
		-1,
		1
},
steelsight = {
		3,
		3.5,
		-1,
		1
},
crouching = {
		3,
		3.5,
		-1,
		1
}
}

--Judge
self.judge.stats.damage = 200
self.judge.stats_modifiers = {damage = 2}
self.x_judge.stats.damage = 200
self.x_judge.stats_modifiers = {damage = 2}
self.judge.damage_near = 400
self.judge.damage_far = 900
self.x_judge.damage_near = 400
self.x_judge.damage_far = 900
self.judge.AMMO_PICKUP = {0.28, 0.88}
self.judge.AMMO_MAX = 25
self.x_judge.AMMO_MAX = 35
self.judge.kick = {
standing = {
		4,
		5,
		-1,
		1
},
steelsight = {
		3,
		3.5,
		-1,
		1
},
crouching = {
		3,
		3.5,
		-1,
		1
}
}
self.x_judge.kick = {
standing = {
		4,
		5,
		-1,
		1
},
steelsight = {
		3,
		3.5,
		-1,
		1
},
crouching = {
		3,
		3.5,
		-1,
		1
}
}

--Breaker
self.boot.stats.damage = 200
self.boot.stats_modifiers = {damage = 2}
self.boot.damage_near = 650
self.boot.damage_far = 1120
self.boot.AMMO_MAX = 30
self.boot.AMMO_PICKUP = {0.32, 1.12}
self.boot.kick = {
standing = {
		4,
		5,
		-1,
		1
},
steelsight = {
		3,
		3.5,
		-1,
		1
},
crouching = {
		3,
		3.5,
		-1,
		1
}
}

--Street Sweeper
self.striker.stats.damage = 130
self.striker.damage_near = 550
self.striker.damage_far = 1050
self.striker.AMMO_PICKUP = {2, 5}
self.striker.fire_mode_data.fire_rate = 0.10695187165
self.striker.AMMO_MAX = 36
self.striker.kick = {
standing = {
		4.5,
		5.5,
		-1.5,
		1.5
},
steelsight = {
		3.5,
		4,
		-1.5,
		1.5
},
crouching = {
		3.5,
		4,
		-1.5,
		1.5
}
}


--GSPS
self.m37.AMMO_MAX = 24
self.m37.stats.damage = 200
self.m37.stats_modifiers = {damage = 2}
self.m37.damage_near = 650
self.m37.damage_far = 1120
self.m37.kick = {
standing = {
		4,
		5,
		-1,
		1
},
steelsight = {
		3,
		3.5,
		-1,
		1
},
crouching = {
		3,
		3.5,
		-1,
		1
}
}

--LMGS--

--KSP 58
self.par.AMMO_PICKUP = {6, 14}
self.par.stats.damage = 59
self.par.stats.recoil = 12
self.par.kick = {
standing = {
		2.0,
		4.2,
		-0.6,
		0.6
},
steelsight = {
		1.0,
		2.1,
		-0.6,
		0.6
},
crouching = {
		1.5,
		3,
		-0.6,
		0.6
}
}

--M60
self.m60.AMMO_MAX = 300 
self.m60.AMMO_PICKUP = {2, 8}
self.m60.stats.damage = 79
self.m60.stats.recoil = 10
self.m60.kick = {
standing = {
		2.0,
		4.2,
		-0.6,
		0.6
},
steelsight = {
		1.0,
		2.1,
		-0.6,
		0.6
},
crouching = {
		1.5,
		3,
		-0.6,
		0.6
}
}

--KSP
self.m249.AMMO_PICKUP = {6, 14}
self.m249.stats.damage = 59
self.m249.stats.recoil = 9
self.m249.kick = {
standing = {
		2.0,
		4.2,
		-0.6,
		0.6
},
steelsight = {
		1.0,
		2.1,
		-0.6,
		0.6
},
crouching = {
		1.5,
		3,
		-0.6,
		0.6
}
}

--Buzzsaw
self.mg42.AMMO_PICKUP = {6, 14}
self.mg42.stats.damage = 59
self.mg42.stats.recoil = 9
self.mg42.stats.spread = 15
self.mg42.kick = {
standing = {
		2.0,
		4.2,
		-0.6,
		0.6
},
steelsight = {
		1.0,
		2.1,
		-0.6,
		0.6
},
crouching = {
		1.5,
		3,
		-0.6,
		0.6
}
}

--Brenner
self.hk21.AMMO_PICKUP = {2, 8}
self.hk21.stats.damage = 79
self.hk21.stats.recoil = 10
self.hk21.kick = {
standing = {
		2.0,
		4.2,
		-0.6,
		0.6
},
steelsight = {
		1.0,
		2.1,
		-0.6,
		0.6
},
crouching = {
		1.5,
		3,
		-0.6,
		0.6
}
}

--RPK
self.rpk.AMMO_PICKUP = {4, 8}
self.rpk.stats.damage = 59
self.rpk.stats.recoil = 18
self.rpk.kick = {
standing = {
		2.0,
		4.2,
		-0.6,
		0.6
},
steelsight = {
		1.0,
		2.1,
		-0.6,
		0.6
},
crouching = {
		1.5,
		3,
		-0.6,
		0.6
}
}

--Microgun
self.shuno.stats.damage = 40

--Vulcan
self.m134.stats.damage = 30

--SNIPERS--

--Nagant
self.mosin.AMMO_MAX = 30
self.mosin.fire_mode_data.fire_rate = .75

--Lever action I forgot the name of
self.sbl.AMMO_MAX = 60

--r7000
self.r700.fire_mode_data.fire_rate = .75

--R93
self.r93.fire_mode_data.fire_rate = .75
self.r93.fire_mode_data.fire_rate = .75

--Desert Fox
self.desertfox.fire_mode_data.fire_rate = .75
self.desertfox.fire_mode_data.fire_rate = .75

--Platypus 70
self.model70.fire_mode_data.fire_rate = .75
self.model70.fire_mode_data.fire_rate = .75

--Rattlesnake
self.msr.fire_mode_data.fire_rate = .75

--Contractor 308
self.tti.fire_mode_data.fire_rate = .2
self.tti.AMMO_MAX = 50
self.tti.AMMO_PICKUP = {1, 2.7}

--Grom
self.siltstone.fire_mode_data.fire_rate = .2
self.siltstone.AMMO_MAX = 50
self.siltstone.AMMO_PICKUP = {1, 2.7}

--Lebensauger
self.wa2000.fire_mode_data.fire_rate = .15
self.wa2000.AMMO_MAX = 50
self.wa2000.AMMO_PICKUP = {1, 2.7}
self.wa2000.CLIP_AMMO_MAX = 15

--Thanatos
self.m95.stats.damage = 200
self.m95.stats_modifiers = {
	damage = 24
}

--GRENADE LAUNCHERS--

--Arbiter
self.arbiter.fire_mode_data.fire_rate = 0.35294117647
self.arbiter.AMMO_MAX = 5

--GL40
self.gre_m79.AMMO_MAX = 6

--Piglet
self.m32.AMMO_MAX = 6

--Compact 40mm
self.slap.AMMO_MAX = 3

--China Puff
self.china.AMMO_MAX = 3

--PISTOLS--

--Baby Deagle
self.sparrow.fire_mode_data.fire_rate = 0.13
self.sparrow.AMMO_MAX = 100
self.sparrow.stats.damage = 96
self.sparrow.AMMO_PICKUP = {0.75, 2.5}

--White Streak
self.pl14.fire_mode_data.fire_rate = 0.13
self.pl14.stats.recoil = 8
self.pl14.AMMO_MAX = 80

--Bernetti
self.b92fs.fire_mode_data.fire_rate = 0.09
self.b92fs.stats.damage = 59
self.b92fs.stats.spread = 17
self.b92fs.AMMO_MAX = 150
self.b92fs.stats.recoil = 19
self.b92fs.kick = {
standing = {
	-0.2,
	0.4,
	-1,
	1
},
steelsight = {
	0.1,
	0.4,
	-0.5,
	0.5
},
crouching = {
	0.1,
	0.4,
	-0.5,
	0.5
}}

--Chimano 88
self.glock_17.stats.spread = 17
self.glock_17.stats.damage = 59
self.glock_17.fire_mode_data.fire_rate = 0.09
self.glock_17.AMMO_MAX = 150
self.glock_17.stats.recoil = 19
self.glock_17.kick = {
standing = {
	-0.2,
	0.4,
	-1,
	1
},
steelsight = {
	0.1,
	0.4,
	-0.5,
	0.5
},
crouching = {
	0.1,
	0.4,
	-0.5,
	0.5
}}
	
--Contractor 9mm
self.packrat.AMMO_MAX = 120
self.packrat.stats.damage = 79
self.packrat.fire_mode_data.fire_rate = 0.09

--Interceptor
self.usp.AMMO_MAX = 120
self.usp.stats.damage = 79
self.usp.fire_mode_data.fire_rate = 0.09

--Signature 40
self.p226.AMMO_MAX = 120
self.p226.stats.damage = 79
self.p226.fire_mode_data.fire_rate = 0.09
self.p226.AMMO_PICKUP = {1.5, 4}

--Chimano Compact
self.g26.fire_mode_data.fire_rate = 0.09
self.g26.stats.recoil = 19
self.g26.stats.spread = 16
self.g26.stats.damage = 59
self.g26.AMMO_MAX = 150
self.g26.kick = {
standing = {
	-0.2,
	0.4,
	-1,
	1
},
steelsight = {
	0.1,
	0.4,
	-0.5,
	0.5
},
crouching = {
	0.1,
	0.4,
	-0.5,
	0.5
}}

--Chimano Custom
self.g22c.stats.damage = 79
self.g22c.AMMO_MAX = 120
self.g22c.fire_mode_data.fire_rate = 0.09

--holt
self.holt.stats.damage = 79
self.holt.AMMO_MAX = 120
self.holt.fire_mode_data.fire_rate = 0.09

--Stryk
self.glock_18c.stats.damage = 45
self.glock_18c.stats.spread = 16
self.glock_18c.stats.recoil = 6
self.glock_18c.AMMO_MAX = 160

--Automatic Bernetti
self.beer.stats.damage = 36
self.beer.stats.spread = 16
self.beer.AMMO_MAX = 200
self.x_beer.stats.damage = 36
self.x_beer.stats.spread = 16
self.x_beer.AMMO_MAX = 220

--Czech 92
self.czech.stats.damage = 42
self.czech.AMMO_MAX = 160
self.x_czech.stats.damage = 42
self.x_czech.AMMO_MAX = 180

--Igor
self.stech.AMMO_MAX = 100
self.stech.stats.damage = 79
self.stech.stats.spread = 18
self.stech.fire_mode_data.fire_rate = 0.075
self.x_stech.fire_mode_data.fire_rate = 0.075
self.x_stech.stats.spread = 18
self.x_stech.stats.damage = 79
self.x_stech.AMMO_MAX = 110

--Gruber Kurz
self.ppk.fire_mode_data.fire_rate = 0.09
self.ppk.stats.spread = 15
self.ppk.AMMO_MAX = 150
self.ppk.stats.damage = 59
self.ppk.CLIP_AMMO_MAX = 22
self.ppk.stats.recoil = 19
self.ppk.kick = {
standing = {
	-0.2,
	0.4,
	-1,
	1
},
steelsight = {
	0.1,
	0.4,
	-0.5,
	0.5
},
crouching = {
	0.1,
	0.4,
	-0.5,
	0.5
}}

--LEO
self.hs2000.AMMO_MAX = 120
self.hs2000.stats.damage = 79
self.hs2000.fire_mode_data.fire_rate = 0.09

--Model 3
self.model3.AMMO_MAX = 78
self.model3.upgrade_blocks = nil
self.x_model3.AMMO_MAX = 90
self.x_model3.upgrade_blocks = nil

--Crosskill
self.colt_1911.AMMO_MAX = 120
self.colt_1911.stats.damage = 79
self.colt_1911.fire_mode_data.fire_rate = 0.09

--Deagle
self.deagle.fire_mode_data.fire_rate = 0.166
self.deagle.stats.recoil = 3
self.deagle.stats.damage = 145
self.deagle.AMMO_MAX = 70

--Broomstick
self.c96.AMMO_MAX = 100
self.c96.stats.damage = 96
self.c96.fire_mode_data.fire_rate = 0.13
self.c96.AMMO_PICKUP = {0.75, 2.5}

--5/7
self.lemming.fire_mode_data.fire_rate = 0.13
self.lemming.stats.spread = 17
self.lemming.AMMO_MAX = 90
self.lemming.stats.recoil = 9
self.lemming.stats.damage = 50
self.lemming.AMMO_PICKUP = {1, 3}

--Peacemaker
self.peacemaker.AMMO_MAX = 48
self.peacemaker.upgrade_blocks = nil
self.peacemaker.fire_mode_data.fire_rate = 0.09
self.peacemaker.stats.damage = 200
self.peacemaker.stats_modifiers = {damage = 2}
self.peacemaker.AMMO_PICKUP = {0.54, 1}

--Parabellum
self.breech.fire_mode_data.fire_rate = 0.13
self.x_breech.fire_mode_data.fire_rate = 0.13
self.breech.AMMO_MAX = 54
self.breech.AMMO_PICKUP = {0.54, 1}
self.breech.stats.spread = 16
self.breech.stats.recoil = 3
self.x_breech.stats.recoil = 3
self.x_breech.stats.spread = 16
self.breech.stats.concealment = 25
self.x_breech.stats.concealment = 25

--M13
self.legacy.stats.damage = 60
self.legacy.stats.spread = 18
self.legacy.AMMO_MAX = 120
self.legacy.fire_mode_data.fire_rate = 0.09
self.legacy.CLIP_AMMO_MAX = 22
self.legacy.stats.recoil = 19
self.legacy.kick = {
standing = {
	-0.2,
	0.4,
	-1,
	1
},
steelsight = {
	0.1,
	0.4,
	-0.5,
	0.5
},
crouching = {
	0.1,
	0.4,
	-0.5,
	0.5
}}

--Bronco
self.new_raging_bull.AMMO_PICKUP = {0.54, 1}
self.new_raging_bull.upgrade_blocks = nil

--Castigo
self.chinchilla.AMMO_PICKUP = {0.54, 1}
self.chinchilla.upgrade_blocks = nil

--Matever
self.mateba.AMMO_PICKUP = {0.54, 1}
self.mateba.upgrade_blocks = nil

--Crosskill Guard
self.shrew.stats.damage = 59
self.shrew.stats.recoil = 19
self.shrew.fire_mode_data.fire_rate = 0.09
self.shrew.stats.spread = 18
self.shrew.AMMO_MAX = 150
self.shrew.kick = {
standing = {
	-0.2,
	0.4,
	-1,
	1
},
steelsight = {
	0.1,
	0.4,
	-0.5,
	0.5
},
crouching = {
	0.1,
	0.4,
	-0.5,
	0.5
}}

-- AKIMBO PISTOLS--

--Baby Deagle
self.x_sparrow.fire_mode_data.fire_rate = 0.13
self.x_sparrow.AMMO_MAX = 120
self.x_sparrow.stats.damage = 96

--White Streak
self.x_pl14.fire_mode_data.fire_rate = 0.13
self.x_pl14.stats.recoil = 8
self.x_pl14.AMMO_MAX = 100

--Bernetti
self.x_b92fs.fire_mode_data.fire_rate = 0.09
self.x_b92fs.stats.damage = 59
self.x_b92fs.stats.spread = 17
self.x_b92fs.AMMO_MAX = 160
self.x_b92fs.stats.recoil = 19
self.x_b92fs.kick = {
standing = {
	-0.2,
	0.4,
	-1,
	1
},
steelsight = {
	0.1,
	0.4,
	-0.5,
	0.5
},
crouching = {
	0.1,
	0.4,
	-0.5,
	0.5
}}

--Chimano 88
self.x_g17.stats.spread = 17
self.x_g17.stats.damage = 59
self.x_g17.fire_mode_data.fire_rate = 0.09
self.x_g17.AMMO_MAX = 160
self.x_g17.stats.recoil = 19
self.x_g17.kick = {
standing = {
	-0.2,
	0.4,
	-1,
	1
},
steelsight = {
	0.1,
	0.4,
	-0.5,
	0.5
},
crouching = {
	0.1,
	0.4,
	-0.5,
	0.5
}}
	
--Contractor 9mm
self.x_packrat.AMMO_MAX = 130
self.x_packrat.stats.damage = 79
self.x_packrat.fire_mode_data.fire_rate = 0.09

--Interceptor
self.x_usp.AMMO_MAX = 130
self.x_usp.stats.damage = 79
self.x_usp.fire_mode_data.fire_rate = 0.09

--holt
self.x_holt.AMMO_MAX = 130
self.x_holt.stats.damage = 79
self.x_holt.fire_mode_data.fire_rate = 0.09

--Signature 40
self.x_p226.AMMO_MAX = 130
self.x_p226.stats.damage = 79
self.x_p226.fire_mode_data.fire_rate = 0.09
self.x_p226.AMMO_PICKUP = {1.5, 4}

--Chimano Compact
self.jowi.fire_mode_data.fire_rate = 0.09
self.jowi.stats.recoil = 19
self.jowi.stats.spread = 16
self.jowi.stats.damage = 59
self.jowi.AMMO_MAX = 160
self.jowi.kick = {
standing = {
	-0.2,
	0.4,
	-1,
	1
},
steelsight = {
	0.1,
	0.4,
	-0.5,
	0.5
},
crouching = {
	0.1,
	0.4,
	-0.5,
	0.5
}}

--Chimano Custom
self.x_g22c.stats.damage = 79
self.x_g22c.AMMO_MAX = 130
self.x_g22c.fire_mode_data.fire_rate = 0.09

--Stryk
self.x_g18c.stats.damage = 45
self.x_g18c.stats.spread = 16
self.x_g18c.stats.recoil = 6
self.x_g18c.AMMO_MAX = 180

--Gruber Kurz
self.x_ppk.fire_mode_data.fire_rate = 0.09
self.x_ppk.stats.spread = 15
self.x_ppk.AMMO_MAX = 160
self.x_ppk.stats.damage = 59
self.x_ppk.CLIP_AMMO_MAX = 44
self.x_ppk.stats.recoil = 19
self.x_ppk.kick = {
standing = {
	-0.2,
	0.4,
	-1,
	1
},
steelsight = {
	0.1,
	0.4,
	-0.5,
	0.5
},
crouching = {
	0.1,
	0.4,
	-0.5,
	0.5
}}

--LEO
self.x_hs2000.AMMO_MAX = 130
self.x_hs2000.stats.damage = 79
self.x_hs2000.fire_mode_data.fire_rate = 0.09

--Crosskill
self.x_1911.AMMO_MAX = 130
self.x_1911.stats.damage = 79
self.x_1911.fire_mode_data.fire_rate = 0.09

--Deagle
self.x_deagle.fire_mode_data.fire_rate = 0.166
self.x_deagle.stats.recoil = 3
self.x_deagle.stats.damage = 145
self.x_deagle.AMMO_MAX = 70

--Broomstick
self.x_c96.AMMO_MAX = 110
self.x_c96.stats.damage = 96
self.x_c96.fire_mode_data.fire_rate = 0.13

--Parabellum
self.x_breech.AMMO_MAX = 60
self.x_breech.AMMO_PICKUP = {0.54, 1}

--M13
self.x_legacy.stats.damage = 60
self.x_legacy.stats.spread = 18
self.x_legacy.AMMO_MAX = 160
self.x_legacy.fire_mode_data.fire_rate = 0.09
self.x_legacy.CLIP_AMMO_MAX = 44
self.x_legacy.stats.recoil = 19
self.x_legacy.kick = {
standing = {
	-0.2,
	0.4,
	-1,
	1
},
steelsight = {
	0.1,
	0.4,
	-0.5,
	0.5
},
crouching = {
	0.1,
	0.4,
	-0.5,
	0.5
}}

--Bronco
self.x_rage.AMMO_PICKUP = {0.54, 1}
self.x_rage.upgrade_blocks = nil

--Castigo
self.x_chinchilla.AMMO_PICKUP = {0.54, 1}
self.x_chinchilla.upgrade_blocks = nil

--Matever
self.x_2006m.AMMO_PICKUP = {0.54, 1}
self.x_2006m.upgrade_blocks = nil

--Crosskill Guard
self.x_shrew.stats.damage = 59
self.x_shrew.stats.recoil = 19
self.x_shrew.fire_mode_data.fire_rate = 0.09
self.x_shrew.stats.spread = 18
self.x_shrew.AMMO_MAX = 160
self.x_shrew.kick = {
standing = {
	-0.2,
	0.4,
	-1,
	1
},
steelsight = {
	0.1,
	0.4,
	-0.5,
	0.5
},
crouching = {
	0.1,
	0.4,
	-0.5,
	0.5
}}

--BOWS--

--Pistol Crossbow
self.hunter.AMMO_MAX = 50

--Modern Bow

--Airbow

--Plainsrider Bow

--Light Crossbow

--Longbow

--Heavy Crossbow

-- VANILLA MOD PACK

--AMR12
if self.amr12 then 
self.amr12.stats.damage = 130
self.amr12.damage_near = 550
self.amr12.damage_far = 1050
self.amr12.AMMO_PICKUP = {2, 5}
self.amr12.AMMO_MAX = 50
self.amr12.kick = {
standing = {
		4.5,
		5.5,
		-1.5,
		1.5
},
steelsight = {
		3.5,
		4,
		-1.5,
		1.5
},
crouching = {
		3.5,
		4,
		-1.5,
		1.5
}
}
end

--Guerilla 308
if self.sgs then 
self.sgs.fire_mode_data.fire_rate = .2
self.sgs.AMMO_MAX = 45
self.sgs.AMMO_PICKUP = {1, 2.1}
end

--Breaker
self.boot.stats.damage = 200
self.boot.stats_modifiers = {damage = 2}
self.boot.damage_near = 650
self.boot.damage_far = 1120
self.boot.AMMO_MAX = 30
self.boot.AMMO_PICKUP = {0.32, 1.12}
self.boot.kick = {
standing = {
		4,
		5,
		-1,
		1
},
steelsight = {
		3,
		3.5,
		-1,
		1
},
crouching = {
		3,
		3.5,
		-1,
		1
}
}

--Hammer 23
if self.bs23 then 
self.bs23.stats.damage = 148
self.bs23.damage_near = 650
self.bs23.damage_far = 1120
self.bs23.AMMO_MAX = 24
self.bs23.stats_modifiers = {damage = 4}
self.bs23.kick = {
standing = {
		4,
		5,
		-1,
		1
},
steelsight = {
		3,
		3.5,
		-1,
		1
},
crouching = {
		3,
		3.5,
		-1,
		1
}
}
end

--Reinbeck
if self.beck then 
self.beck.stats.damage = 190
self.beck.damage_near = 650
self.beck.damage_far = 1120
self.beck.AMMO_PICKUP = {1.8, 2.9}
self.beck.AMMO_MAX = 42
self.beck.fire_mode_data.fire_rate = 0.35294117647
self.beck.kick = {
standing = {
		4,
		5,
		-1,
		1
},
steelsight = {
		3,
		3.5,
		-1,
		1
},
crouching = {
		3,
		3.5,
		-1,
		1
}
}
end

--Reinbeck Auto
if self.minibeck then 
self.minibeck.stats.damage = 150
self.minibeck.damage_near = 550
self.minibeck.damage_far = 1050
self.minibeck.AMMO_PICKUP = {2, 4}
self.minibeck.fire_mode_data.fire_rate = 0.16
self.minibeck.AMMO_MAX = 44
self.minibeck.kick = {
standing = {
		4.5,
		5.5,
		-1.5,
		1.5
},
steelsight = {
		3.5,
		4,
		-1.5,
		1.5
},
crouching = {
		3.5,
		4,
		-1.5,
		1.5
}
}
end

--SG416
if self.sg416 then 
self.sg416.CLIP_AMMO_MAX = 30
self.sg416.AMMO_MAX = 150
self.sg416.stats.damage = 59
self.sg416.stats.spread = 14
self.sg416.stats.recoil = 16
self.sg416.AMMO_PICKUP = {4, 8}
self.sg416.kick.standing = self.new_m4.kick.standing
self.sg416.kick.crouching = self.new_m4.kick.crouching
self.sg416.kick.steelsight = self.new_m4.kick.steelsight
end

--Crosskill Classic
if self.cold then 
self.cold.stats.damage = 98
self.cold.AMMO_MAX = 80
self.cold.fire_mode_data.fire_rate = 0.13
self.cold.stats.spread = 18
end

if self.x_cold then 
self.x_cold.stats.damage = 98
self.x_cold.AMMO_MAX = 90
self.x_cold.fire_mode_data.fire_rate = 0.13
self.x_cold.stats.spread = 18
end

--Dragon 5.45
if self.smolak then 
self.smolak.AMMO_MAX = 60
end

--Spiker
if self.spike then
self.spike.kick.standing = self.new_m4.kick.standing
self.spike.kick.crouching = self.new_m4.kick.crouching
self.spike.kick.steelsight = self.new_m4.kick.steelsight
end

--Automat
if self.ak5s then
self.ak5s.kick = {
standing = {
	-0.2,
	0.4,
	-1,
	1
},
steelsight = {
	0.1,
	0.4,
	-0.5,
	0.5
},
crouching = {
	0.1,
	0.4,
	-0.5,
	0.5
}}
end


--ACAR 9
if self.car9 then
self.car9.kick = {
standing = {
	-0.2,
	0.4,
	-1,
	1
},
steelsight = {
	0.1,
	0.4,
	-0.5,
	0.5
},
crouching = {
	0.1,
	0.4,
	-0.5,
	0.5
}}
end

--Thank you for all your work, Gambyt!
end)
