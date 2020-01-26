function WeaponTweakData:_set_characters_weapon_preset(rifle_spread, smg_spread, lmg_spread, mini_spread)
	--uh oh sisters *melts into dust leaving only my bones behind*
	local all_rifles = {
		"m4_npc",
		"m4_yellow_npc",
		"ak47_npc",
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
	end
	
	for _, sname in ipairs(all_smgs) do
		self[sname].spread = smg_spread
		self[sname].fanpcwep = true
	end
	
	self.m249_npc.spread = lmg_spread
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
	self.mp5_npc.suppression = 5
	self.ump_npc.suppression = 5
	self.mp9_npc.suppression = 5
	self.saiga_npc.suppression = 1
	self.r870_npc.suppression = 2
	self.blazter_npc.suppression = 2
	self.silserbu_npc.suppression = 2
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
	self.s552_npc = deep_clone(self.m4_npc)
	self.s552_npc.sounds.prefix = "sig552_npc"
	self.s552_npc.muzzleflash = "effects/payday2/particles/weapons/556_auto"
	self.s552_npc.shell_ejection = "effects/payday2/particles/weapons/shells/shell_556"
	self.ak47_ass_npc = deep_clone(self.m4_npc)
	self.ak47_ass_npc.sounds.prefix = "akm_npc"
	self.ak47_ass_npc.muzzleflash = "effects/payday2/particles/weapons/762_auto"
	self.mp5_tactical_npc = deep_clone(self.mp5_npc)
	self.mp5_tactical_npc.has_suppressor = "suppressed_a"
	self.mp5_tactical_npc.no_vis = true
	self.ump_npc = deep_clone(self.mp5_npc)
	self.ump_npc.sounds.prefix = "schakal_npc"
	self.akmsu_smg_npc = deep_clone(self.mp5_npc)
	self.akmsu_smg_npc.sounds.prefix = "akmsu_npc"
	self.akmsu_smg_npc.shell_ejection = "effects/payday2/particles/weapons/shells/shell_556"
	self.akmsu_smg_npc.has_suppressor = "suppressed_b"
	self.asval_smg_npc = deep_clone(self.mp5_npc)
	self.asval_smg_npc.sounds.prefix = "val_npc"
	self.asval_smg_npc.shell_ejection = "effects/payday2/particles/weapons/shells/shell_556"
	self.asval_smg_npc.has_suppressor = "suppressed_a"
	self.asval_smg_npc.no_vis = true
	self.mac11_npc.sounds.prefix = "mac10_npc"
	self.benelli_npc.sounds.prefix = "benelli_m4_npc"
	
	--LMG weapon usage fix for Dozers and other enemies, this will do some damn good with NPC bosses.
	self.m249_npc.hold = "rifle"
	self.m249_npc.usage = "is_lmg"
	self.rpk_lmg_npc = deep_clone(self.m249_npc)
	self.rpk_lmg_npc.hold = "rifle"
	self.rpk_lmg_npc.sounds.prefix = "rpk_npc"
	self.rpk_lmg_npc.usage = "is_lmg"
	self.rpk_lmg_npc.auto.fire_rate = 0.08
	self.mossberg_npc.usage = "is_shotgun_mag"
	self.mossberg_npc.DAMAGE = 2
	self.mossberg_npc.CLIP_AMMO_MAX = 2
	
	self.mini_npc.CLIP_AMMO_MAX = 100000 --new minigun dozer buff setup
	self.mini_npc.NR_CLIPS_MAX = 1
	
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
			0.5
		}
	}
	self.ceiling_turret_module.dontsuppressonmiss = true
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
	
	self.emp_npc = deep_clone(self.mp9_npc)
	self.emp_npc.CLIP_AMMO_MAX = 100000
	self.emp_npc.shell_ejection = "effects/payday2/particles/weapons/shells/shell_empty"
	self.emp_npc.muzzleflash = "effects/payday2/particles/weapons/shells/shell_empty"
	self.emp_npc.no_vis = true
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
	
	self:_set_characters_weapon_preset(40, 20, 20, 100)
	
	--Turret Tweaks.
	self.swat_van_turret_module.HEALTH_INIT = 3500
	self.swat_van_turret_module.SHIELD_HEALTH_INIT = 70
	self.swat_van_turret_module.DAMAGE = 0.5
	self.ceiling_turret_module.HEALTH_INIT = 875
	self.ceiling_turret_module.SHIELD_HEALTH_INIT = 25
	self.ceiling_turret_module.DAMAGE = 0.5
	self.ceiling_turret_module.CLIP_SIZE = 100
	self.aa_turret_module.HEALTH_INIT = 3500
	self.aa_turret_module.SHIELD_HEALTH_INIT = 70
	self.aa_turret_module.DAMAGE = 1
	self.aa_turret_module.auto.fire_rate = 0.6 
	self.aa_turret_module.suppression = 2
	self.crate_turret_module.HEALTH_INIT = 875
	self.crate_turret_module.SHIELD_HEALTH_INIT = 70
	self.crate_turret_module.DAMAGE = 2.5
	self.crate_turret_module.auto.fire_rate = 0.6
	self.crate_turret_module.suppression = 2
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
	
	self:_set_characters_weapon_preset(40, 20, 20, 100) --setting enemy weapon spread
	
	--Turret Tweaks.
	self.swat_van_turret_module.HEALTH_INIT = 3500
	self.swat_van_turret_module.SHIELD_HEALTH_INIT = 70
	self.swat_van_turret_module.DAMAGE = 0.5
	self.ceiling_turret_module.HEALTH_INIT = 875
	self.ceiling_turret_module.SHIELD_HEALTH_INIT = 25
	self.ceiling_turret_module.DAMAGE = 0.5
	self.ceiling_turret_module.CLIP_SIZE = 100
	self.aa_turret_module.HEALTH_INIT = 3500
	self.aa_turret_module.SHIELD_HEALTH_INIT = 70
	self.aa_turret_module.DAMAGE = 1
	self.aa_turret_module.auto.fire_rate = 0.6 
	self.aa_turret_module.suppression = 2
	self.crate_turret_module.HEALTH_INIT = 875
	self.crate_turret_module.SHIELD_HEALTH_INIT = 70
	self.crate_turret_module.DAMAGE = 2.5
	self.crate_turret_module.auto.fire_rate = 0.6
	self.crate_turret_module.suppression = 2
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
	
	self:_set_characters_weapon_preset(30, 15, 40, 80) --setting enemy weapon spread
	
	--sniper tweak
	self.m14_sniper_npc.suppression = 8
	self.m14_sniper_npc.CLIP_AMMO_MAX = 12
	self.svd_snp_npc.suppression = 8
	self.svd_snp_npc.CLIP_AMMO_MAX = 12
	self.svdsil_snp_npc.suppression = 8
	self.svdsil_snp_npc.CLIP_AMMO_MAX = 12
	
	--turret tweaks
	self.swat_van_turret_module.HEALTH_INIT = 15000
	self.swat_van_turret_module.SHIELD_HEALTH_INIT = 300
	self.swat_van_turret_module.DAMAGE = 1
	self.ceiling_turret_module.HEALTH_INIT = 9375
	self.ceiling_turret_module.SHIELD_HEALTH_INIT = 50
	self.ceiling_turret_module.DAMAGE = 2
	self.ceiling_turret_module.CLIP_SIZE = 100
	self.aa_turret_module.HEALTH_INIT = 12500 --Fuck this thing, it sucks at the end of a sucky heist already, I've made it more fun to fight, but that won't do much.
	self.aa_turret_module.SHIELD_HEALTH_INIT = 600
	self.aa_turret_module.DAMAGE = 2.5
	self.aa_turret_module.auto.fire_rate = 0.6 
	self.aa_turret_module.suppression = 4
	self.crate_turret_module.HEALTH_INIT = 9375
	self.crate_turret_module.SHIELD_HEALTH_INIT = 150
	self.crate_turret_module.DAMAGE = 2.5
	self.crate_turret_module.auto.fire_rate = 0.6
	self.crate_turret_module.suppression = 4
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
	
	self:_set_characters_weapon_preset(30, 15, 40, 80) --setting enemy weapon spread
	
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
	
	--turret tweaks
	self.swat_van_turret_module.HEALTH_INIT = 15000
	self.swat_van_turret_module.SHIELD_HEALTH_INIT = 300
	self.swat_van_turret_module.DAMAGE = 1
	self.ceiling_turret_module.HEALTH_INIT = 9375
	self.ceiling_turret_module.SHIELD_HEALTH_INIT = 50
	self.ceiling_turret_module.DAMAGE = 2
	self.ceiling_turret_module.CLIP_SIZE = 100
	self.aa_turret_module.HEALTH_INIT = 12500 --Fuck this thing, it sucks at the end of a sucky heist already, I've made it more fun to fight, but that won't do much.
	self.aa_turret_module.SHIELD_HEALTH_INIT = 600
	self.aa_turret_module.DAMAGE = 2.5
	self.aa_turret_module.auto.fire_rate = 0.6 
	self.aa_turret_module.suppression = 4
	self.crate_turret_module.HEALTH_INIT = 9375
	self.crate_turret_module.SHIELD_HEALTH_INIT = 150
	self.crate_turret_module.DAMAGE = 2.5
	self.crate_turret_module.auto.fire_rate = 0.6
	self.crate_turret_module.suppression = 4
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
	
	self:_set_characters_weapon_preset(20, 15, 20, 60) --setting enemy weapon spread
	
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
	self.swat_van_turret_module.HEALTH_INIT = 25000
	self.swat_van_turret_module.SHIELD_HEALTH_INIT = 400
	self.swat_van_turret_module.DAMAGE = 2
	self.swat_van_turret_module.CLIP_SIZE = 800
	self.ceiling_turret_module.HEALTH_INIT = 10000
	self.ceiling_turret_module.SHIELD_HEALTH_INIT = 100
	self.ceiling_turret_module.DAMAGE = 2
	self.ceiling_turret_module.CLIP_SIZE = 200
	self.aa_turret_module.HEALTH_INIT = 25000
	self.aa_turret_module.SHIELD_HEALTH_INIT = 600
	self.aa_turret_module.DAMAGE = 4
	self.aa_turret_module.auto.fire_rate = 0.6 --sadly, the firing sound doesnt match but, functionally its a lot of fun
	self.aa_turret_module.suppression = 8
	self.aa_turret_module.CLIP_SIZE = 800
	self.crate_turret_module.HEALTH_INIT = 9750
	self.crate_turret_module.SHIELD_HEALTH_INIT = 300
	self.crate_turret_module.DAMAGE = 4
	self.crate_turret_module.auto.fire_rate = 0.6
	self.crate_turret_module.suppression = 8
	self.crate_turret_module.CLIP_SIZE = 800
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
	
	self:_set_characters_weapon_preset(20, 15, 20, 60) --setting enemy weapon spread
	
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
	self.swat_van_turret_module.HEALTH_INIT = 25000
	self.swat_van_turret_module.SHIELD_HEALTH_INIT = 400
	self.swat_van_turret_module.DAMAGE = 2
	self.swat_van_turret_module.CLIP_SIZE = 800
	self.ceiling_turret_module.HEALTH_INIT = 10000
	self.ceiling_turret_module.SHIELD_HEALTH_INIT = 100
	self.ceiling_turret_module.DAMAGE = 2
	self.ceiling_turret_module.CLIP_SIZE = 200
	self.aa_turret_module.HEALTH_INIT = 25000
	self.aa_turret_module.SHIELD_HEALTH_INIT = 600
	self.aa_turret_module.DAMAGE = 4
	self.aa_turret_module.auto.fire_rate = 0.6 --sadly, the firing sound doesnt match but, functionally its a lot of fun
	self.aa_turret_module.suppression = 8
	self.aa_turret_module.CLIP_SIZE = 800
	self.crate_turret_module.HEALTH_INIT = 9750
	self.crate_turret_module.SHIELD_HEALTH_INIT = 300
	self.crate_turret_module.DAMAGE = 4
	self.crate_turret_module.auto.fire_rate = 0.6
	self.crate_turret_module.suppression = 8
	self.crate_turret_module.CLIP_SIZE = 800
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
	
	self:_set_characters_weapon_preset(20, 15, 20, 60) --setting enemy weapon spread
	
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
	self.swat_van_turret_module.HEALTH_INIT = 25000
	self.swat_van_turret_module.SHIELD_HEALTH_INIT = 400
	self.swat_van_turret_module.DAMAGE = 2
	self.swat_van_turret_module.CLIP_SIZE = 800
	self.ceiling_turret_module.HEALTH_INIT = 10000
	self.ceiling_turret_module.SHIELD_HEALTH_INIT = 150
	self.ceiling_turret_module.DAMAGE = 2
	self.ceiling_turret_module.CLIP_SIZE = 300
	self.aa_turret_module.HEALTH_INIT = 25000
	self.aa_turret_module.SHIELD_HEALTH_INIT = 600
	self.aa_turret_module.DAMAGE = 4
	self.aa_turret_module.auto.fire_rate = 0.6 --sadly, the firing sound doesnt match but, functionally its a lot of fun
	self.aa_turret_module.suppression = 8
	self.aa_turret_module.CLIP_SIZE = 800
	self.crate_turret_module.HEALTH_INIT = 9750
	self.crate_turret_module.SHIELD_HEALTH_INIT = 300
	self.crate_turret_module.DAMAGE = 4
	self.crate_turret_module.auto.fire_rate = 0.6
	self.crate_turret_module.suppression = 8
	self.crate_turret_module.CLIP_SIZE = 800
end

--OVERHAUL STUFF

Hooks:PostHook( WeaponTweakData, "init", "hh_overhaul_init", function(self)
	if PD2THHSHIN and PD2THHSHIN:IsOverhaulEnabled() then
	-- SUBMACHINE GUNS

	-- Chicago Typewriter
		self.m1928.stats.spread = 16
		self.m1928.AMMO_MAX = 120  
		self.x_m1928.AMMO_MAX = 150  
		self.m1928.kick.standing = self.new_m4.kick.standing
		self.m1928.kick.crouching = self.new_m4.kick.crouching
		self.m1928.kick.steelsight = self.new_m4.kick.steelsight

		-- Jackal
		self.schakal.stats.spread = 17
		self.schakal.AMMO_PICKUP = {3, 6.5}
		self.schakal.AMMO_MAX = 100
		self.schakal.stats.damage = 78

		self.x_schakal.stats.damage = 78
		self.x_schakal.AMMO_PICKUP = {3, 6.5}
		self.x_schakal.AMMO_MAX = 120
		self.x_schakal.AMMO_PICKUP = {2, 5}

		-- MP40
		self.erma.stats.spread = 20
		self.erma.stats.recoil = 15
		self.erma.AMMO_MAX = 80
		self.x_erma.AMMO_MAX = 90
		self.erma.AMMO_PICKUP = {2, 5}
		self.erma.kick = {
		standing = {
				1.5,
				2.5,
				-0.2,
				0.5
		},
		steelsight = {
				0.7,
				1.6,
				-0.1,
				0.2
		},
		crouching = {
				0.7,
				1.6,
				-0.1,
				0.2
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

		-- Para
		self.olympic.CLIP_AMMO_MAX = 30
		self.olympic.AMMO_MAX = 120  
		self.x_olympic.AMMO_MAX = 150  
		self.olympic.kick.standing = self.new_m4.kick.standing
		self.olympic.kick.crouching = self.new_m4.kick.crouching
		self.olympic.kick.steelsight = self.new_m4.kick.steelsight

		-- Patchett
		self.sterling.stats.damage = 128
		self.sterling.stats.spread = 16
		self.sterling.AMMO_PICKUP = {1, 3}
		self.sterling.AMMO_MAX = 60
		self.sterling.kick = {
		standing = {
				1.5,
				2.5,
				-0.2,
				0.5
		},
		steelsight = {
				0.7,
				1.6,
				-0.1,
				0.2
		},
		crouching = {
				0.7,
				1.6,
				-0.1,
				0.2
		}
		}

		self.x_sterling.stats.damage = 128
		self.x_sterling.stats.spread = 17
		self.x_sterling.AMMO_PICKUP = {1, 3}
		self.x_sterling.AMMO_MAX = 50

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

		-- Swedish K
		self.m45.AMMO_MAX = 80
		self.x_m45.AMMO_MAX = 90
		self.m45.AMMO_PICKUP = {2, 5}
		self.m45.kick = {
		standing = {
				1.5,
				2.5,
				-0.2,
				0.5
		},
		steelsight = {
				0.7,
				1.6,
				-0.1,
				0.2
		},
		crouching = {
				0.7,
				1.6,
				-0.1,
				0.2
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

		-- Jacket's Piece
		self.cobray.stats.spread = 15
		self.cobray.AMMO_MAX = 120
		self.x_cobray.AMMO_MAX = 150  
		self.cobray.kick.standing = self.new_m4.kick.standing
		self.cobray.kick.crouching = self.new_m4.kick.crouching
		self.cobray.kick.steelsight = self.new_m4.kick.steelsight

		-- Kross Vertex
		self.polymer.stats.spread = 15
		self.polymer.AMMO_MAX = 120  
		self.x_polymer.AMMO_MAX = 150  
		self.polymer.kick.standing = self.new_m4.kick.standing
		self.polymer.kick.crouching = self.new_m4.kick.crouching
		self.polymer.kick.steelsight = self.new_m4.kick.steelsight

		-- Kobus 90
		self.p90.stats.spread = 16
		self.p90.AMMO_MAX = 120
		self.x_p90.AMMO_MAX = 150    
		self.p90.kick.standing = self.new_m4.kick.standing
		self.p90.kick.crouching = self.new_m4.kick.crouching
		self.p90.kick.steelsight = self.new_m4.kick.steelsight

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

		-- Mark 10
		self.mac10.AMMO_MAX = 120  
		self.x_mac10.AMMO_MAX = 150  
		self.mac10.kick.standing = self.new_m4.kick.standing
		self.mac10.kick.crouching = self.new_m4.kick.crouching
		self.mac10.kick.steelsight = self.new_m4.kick.steelsight

		-- SpecOps
		self.mp7.AMMO_MAX = 120
		self.x_mp7.AMMO_MAX = 150  
		self.mp7.kick.standing = self.new_m4.kick.standing
		self.mp7.kick.crouching = self.new_m4.kick.crouching
		self.mp7.kick.steelsight = self.new_m4.kick.steelsight

		--Krinkov
		self.akmsu.AMMO_PICKUP = {3, 6.5}
		self.akmsu.AMMO_MAX = 100
		self.akmsu.stats.damage = 78

		self.x_akmsu.AMMO_MAX = 120
		self.x_akmsu.stats.damage = 78
		self.x_akmsu.AMMO_PICKUP = {2, 5}

		--CR805B
		self.hajk.AMMO_PICKUP = {2, 5}
		self.hajk.AMMO_MAX = 80 
		self.hajk.kick = {
		standing = {
				1.5,
				2.5,
				-0.2,
				0.5
		},
		steelsight = {
				0.7,
				1.6,
				-0.1,
				0.2
		},
		crouching = {
				0.7,
				1.6,
				-0.1,
				0.2
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
		self.contraband.kick.standing = self.new_m4.kick.standing
		self.contraband.kick.crouching = self.new_m4.kick.crouching
		self.contraband.kick.steelsight = self.new_m4.kick.steelsight

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
		self.g3.CLIP_AMMO_MAX = 30
		self.g3.AMMO_PICKUP = {2, 6}
		self.g3.fire_mode_data.fire_rate = 0.08571428571
		self.g3.kick = {
		standing = {
				2,
				3,
				-0.2,
				0.5
		},
		steelsight = {
				1,
				2,
				-0.1,
				0.3
		},
		crouching = {
				1,
				2,
				-0.1,
				0.3
		}
		}

		--Valkyria
		self.asval.AMMO_MAX = 150
		self.asval.stats.spread = 19
		self.asval.stats.recoil = 16
		self.asval.stats.damage = 59

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
				1.5,
				2.5,
				-0.2,
				0.5
		},
		steelsight = {
				0.7,
				1.6,
				-0.1,
				0.2
		},
		crouching = {
				0.7,
				1.6,
				-0.1,
				0.2
		}
		}


		--AK 762
		self.akm.AMMO_PICKUP = {2, 6}
		self.akm.AMMO_MAX = 100
		self.akm.kick = {
		standing = {
				1.5,
				2.5,
				-0.2,
				0.5
		},
		steelsight = {
				0.7,
				1.6,
				-0.1,
				0.2
		},
		crouching = {
				0.7,
				1.6,
				-0.1,
				0.2
		}
		}

		--Gold AK
		self.akm_gold.AMMO_PICKUP = {2, 6}
		self.akm_gold.AMMO_MAX = 100
		self.akm_gold.kick = {
		standing = {
				1.5,
				2.5,
				-0.2,
				0.5
		},
		steelsight = {
				0.7,
				1.6,
				-0.1,
				0.2
		},
		crouching = {
				0.7,
				1.6,
				-0.1,
				0.2
		}
		}

		--AK17
		self.flint.AMMO_PICKUP = {2, 6}
		self.flint.AMMO_MAX = 100
		self.flint.CLIP_AMMO_MAX = 30
		self.flint.kick = {
		standing = {
				1.5,
				2.5,
				-0.2,
				0.5
		},
		steelsight = {
				0.7,
				1.6,
				-0.1,
				0.2
		},
		crouching = {
				0.7,
				1.6,
				-0.1,
				0.2
		}
		}

		--Falcon
		self.fal.AMMO_PICKUP = {2, 6}
		self.fal.kick = {
		standing = {
				1.5,
				2.5,
				-0.2,
				0.5
		},
		steelsight = {
				0.7,
				1.6,
				-0.1,
				0.2
		},
		crouching = {
				0.7,
				1.6,
				-0.1,
				0.2
		}
		}

		--AMR16
		self.m16.AMMO_PICKUP = {2, 6}
		self.m16.AMMO_MAX = 100
		self.m16.kick = {
		standing = {
				1.5,
				2.5,
				-0.2,
				0.5
		},
		steelsight = {
				0.7,
				1.6,
				-0.1,
				0.2
		},
		crouching = {
				0.7,
				1.6,
				-0.1,
				0.2
		}
		}

		--Lion's Roar
		self.vhs.AMMO_MAX = 120
		self.vhs.stats.spread = 15
		self.vhs.stats.damage = 79
		self.vhs.AMMO_PICKUP = {3, 6.5}
		self.vhs.stats.recoil = 17
		self.vhs.kick.standing = self.galil.kick.standing
		self.vhs.kick.steelsight = self.galil.kick.standing
		self.vhs.kick.crouching = self.galil.kick.standing

		--Gecko
		self.galil.AMMO_MAX = 120
		self.galil.stats.spread = 13
		self.galil.stats.damage = 79
		self.galil.AMMO_PICKUP = {3, 6.5}
		self.galil.stats.recoil = 18
		self.galil.kick.steelsight = self.galil.kick.standing
		self.galil.kick.crouching = self.galil.kick.standing
		self.galil.kick = {standing = {
				-0.8,
				1,
				-1.4,
				1.4
			}}
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
				1.5,
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
		self.rota.AMMO_MAX = 50
		self.x_rota.AMMO_MAX = 50
		self.x_rota.stats.damage = 130
		self.rota.stats.damage = 130
		self.rota.damage_near = 400
		self.rota.damage_far = 900
		self.x_rota.damage_near = 400
		self.x_rota.damage_far = 900
		self.x_rota.AMMO_PICKUP = {2, 3}
		self.rota.AMMO_PICKUP = {2, 3}
		self.rota.kick = {
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

		--Reinfeld
		self.r870.fire_mode_data.fire_rate = 0.35294117647
		self.r870.stats.damage = 190
		self.r870.damage_near = 400
		self.r870.damage_far = 900
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
		self.serbu.stats.damage = 190
		self.serbu.damage_near = 400
		self.serbu.damage_far = 900
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

		--M1014
		self.benelli.stats.damage = 130
		self.benelli.damage_near = 400
		self.benelli.damage_far = 900
		self.benelli.AMMO_PICKUP = {2, 3}
		self.benelli.AMMO_MAX = 50
		self.benelli.kick = {
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

		--Predator
		self.spas12.stats.damage = 130
		self.spas12.damage_near = 400
		self.spas12.damage_far = 900
		self.spas12.AMMO_PICKUP = {2, 4}
		self.spas12.fire_mode_data.fire_rate = 0.14
		self.spas12.AMMO_MAX = 50
		self.spas12.kick = {
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

		--Steakout
		self.aa12.stats.damage = 80
		self.aa12.damage_near = 400
		self.aa12.damage_far = 900
		self.aa12.AMMO_PICKUP = {2, 3}
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
		self.ksg.damage_near = 400
		self.ksg.damage_far = 900
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
		self.x_basset.AMMO_MAX = 60
		self.x_basset.stats.damage = 80
		self.basset.stats.damage = 80
		self.basset.damage_near = 400
		self.basset.AMMO_MAX = 60
		self.basset.damage_far = 900
		self.x_basset.damage_near = 400
		self.x_basset.damage_far = 900
		self.basset.AMMO_PICKUP = {2, 3}
		self.x_basset.AMMO_PICKUP = {2, 3}
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

		--Izhma
		self.saiga.stats.damage = 80
		self.saiga.damage_near = 400
		self.saiga.damage_far = 900
		self.saiga.AMMO_PICKUP = {2, 3}
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
		self.coach.AMMO_MAX = 36
		self.coach.damage_near = 400
		self.coach.damage_far = 900
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
		self.b682.damage_near = 400
		self.b682.damage_far = 900
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

		--Breaker
		self.boot.stats.damage = 200
		self.boot.stats_modifiers = {damage = 2}
		self.boot.damage_near = 400
		self.boot.damage_far = 900
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
		self.striker.damage_near = 400
		self.striker.damage_far = 900
		self.striker.AMMO_PICKUP = {2, 3}
		self.striker.fire_mode_data.fire_rate = 0.10695187165
		self.striker.AMMO_MAX = 50
		self.striker.kick = {
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


		--GSPS
		self.m37.stats.damage = 200
		self.m37.stats_modifiers = {damage = 2}
		self.m37.damage_near = 400
		self.m37.damage_far = 900
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
		self.par.stats.recoil = 11
		self.par.kick = {
		standing = {
				1.5,
				2.5,
				-2,
				2
		},
		steelsight = {
				1.5,
				2.5,
				-2,
				2
		},
		crouching = {
				1.5,
				2.5,
				-2,
				2
		}
		}

		--KSP
		self.m249.AMMO_PICKUP = {6, 14}
		self.m249.stats.damage = 59
		self.m249.stats.recoil = 7
		self.m249.kick = {
		standing = {
				1.5,
				2.5,
				-1,
				1
		},
		steelsight = {
				1.5,
				2.5,
				-1,
				1
		},
		crouching = {
				1.5,
				2.5,
				-1,
				1
		}
		}

		--Buzzsaw
		self.mg42.AMMO_PICKUP = {6, 14}
		self.mg42.stats.damage = 59
		self.mg42.stats.recoil = 9
		self.mg42.stats.spread = 13
		self.mg42.kick = {
		standing = {
				0.7,
				1.7,
				-0.8,
				0.8
		},
		steelsight = {
				0.7,
				1.7,
				-0.8,
				0.8
		},
		crouching = {
				0.7,
				1.7,
				-0.8,
				0.8
		}
		}

		--Brenner
		self.hk21.AMMO_PICKUP = {2, 8}
		self.hk21.stats.damage = 79
		self.hk21.stats.recoil = 8
		self.hk21.kick = {
		standing = {
				1.5,
				2.5,
				-1,
				1
		},
		steelsight = {
				1.5,
				2.5,
				-1,
				1
		},
		crouching = {
				1.5,
				2.5,
				-1,
				1
		}
		}

		--RPK
		self.rpk.AMMO_PICKUP = {2, 8}
		self.rpk.stats.damage = 79
		self.rpk.stats.recoil = 17
		self.rpk.kick = {
		standing = {
				1.5,
				2.5,
				-1,
				1
		},
		steelsight = {
				1.5,
				2.5,
				-1,
				1
		},
		crouching = {
				1.5,
				2.5,
				-1,
				1
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


		--GRENADE LAUNCHERS--

		--Arbiter
		self.arbiter.fire_mode_data.fire_rate = 0.35294117647
		self.arbiter.AMMO_MAX = 10

		--GL40
		self.gre_m79.AMMO_MAX = 12

		--PISTOLS--

		--Baby Deagle
		self.sparrow.fire_mode_data.fire_rate = 0.13
		self.sparrow.AMMO_MAX = 80
		self.sparrow.stats.damage = 96
		self.sparrow.AMMO_PICKUP = {0.75, 2.5}

		--White Streak
		self.pl14.fire_mode_data.fire_rate = 0.13
		self.pl14.stats.recoil = 8
		self.pl14.AMMO_MAX = 65

		--Bernetti
		self.b92fs.fire_mode_data.fire_rate = 0.09
		self.b92fs.stats.damage = 59
		self.b92fs.stats.spread = 17
		self.b92fs.AMMO_MAX = 120
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
		self.glock_17.AMMO_MAX = 120
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
		self.packrat.AMMO_MAX = 90
		self.packrat.stats.damage = 79
		self.packrat.fire_mode_data.fire_rate = 0.09

		--Interceptor
		self.usp.AMMO_MAX = 90
		self.usp.stats.damage = 79
		self.usp.fire_mode_data.fire_rate = 0.09

		--Signature 40
		self.p226.AMMO_MAX = 90
		self.p226.stats.damage = 79
		self.p226.fire_mode_data.fire_rate = 0.09
		self.p226.AMMO_PICKUP = {0.91, 3.18}

		--Chimano Compact
		self.g26.fire_mode_data.fire_rate = 0.09
		self.g26.stats.recoil = 19
		self.g26.stats.spread = 16
		self.g26.stats.damage = 59
		self.g26.AMMO_MAX = 120
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
		self.g22c.AMMO_MAX = 90
		self.g22c.fire_mode_data.fire_rate = 0.09

		--Stryk
		self.glock_18c.stats.damage = 45
		self.glock_18c.stats.spread = 16
		self.glock_18c.stats.recoil = 6
		self.glock_18c.AMMO_MAX = 140

		--Gruber Kurz
		self.ppk.fire_mode_data.fire_rate = 0.09
		self.ppk.stats.spread = 15
		self.ppk.AMMO_MAX = 120
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
		self.hs2000.AMMO_MAX = 90
		self.hs2000.stats.damage = 79
		self.hs2000.fire_mode_data.fire_rate = 0.09

		--Crosskill
		self.colt_1911.AMMO_MAX = 90
		self.colt_1911.stats.damage = 79
		self.colt_1911.fire_mode_data.fire_rate = 0.09

		--Deagle
		self.deagle.fire_mode_data.fire_rate = 0.166
		self.deagle.stats.recoil = 3
		self.deagle.stats.damage = 145
		self.deagle.AMMO_MAX = 60

		--Broomstick
		self.c96.AMMO_MAX = 80
		self.c96.stats.damage = 96
		self.c96.fire_mode_data.fire_rate = 0.13
		self.c96.AMMO_PICKUP = {0.75, 2.5}

		--5/7
		self.lemming.fire_mode_data.fire_rate = 0.166
		self.lemming.stats.spread = 17
		self.lemming.AMMO_MAX = 50
		self.lemming.stats.recoil = 8
		self.lemming.AMMO_PICKUP = {0.5, 1}

		--Peacemaker
		self.peacemaker.fire_mode_data.fire_rate = 0.09
		self.peacemaker.stats.damage = 150
		self.peacemaker.stats_modifiers = {damage = 2}
		self.peacemaker.AMMO_PICKUP = {0.54, 1}

		--Parabellum
		self.breech.AMMO_MAX = 54
		self.breech.AMMO_PICKUP = {0.54, 1}
		self.breech.stats.recoil = 2
		self.x_breech.stats.recoil = 2
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

		--Castigo
		self.chinchilla.AMMO_PICKUP = {0.54, 1}

		--Matever
		self.mateba.AMMO_PICKUP = {0.54, 1}

		--Crosskill Guard
		self.shrew.stats.damage = 59
		self.shrew.stats.recoil = 19
		self.shrew.fire_mode_data.fire_rate = 0.09
		self.shrew.stats.spread = 18
		self.shrew.AMMO_MAX = 120
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
		self.x_sparrow.AMMO_MAX = 90
		self.x_sparrow.stats.damage = 96

		--White Streak
		self.x_pl14.fire_mode_data.fire_rate = 0.13
		self.x_pl14.stats.recoil = 8
		self.x_pl14.AMMO_MAX = 75

		--Bernetti
		self.x_b92fs.fire_mode_data.fire_rate = 0.09
		self.x_b92fs.stats.damage = 59
		self.x_b92fs.stats.spread = 17
		self.x_b92fs.AMMO_MAX = 140
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
		self.x_g17.AMMO_MAX = 140
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
		self.x_packrat.AMMO_MAX = 100
		self.x_packrat.stats.damage = 79
		self.x_packrat.fire_mode_data.fire_rate = 0.09

		--Interceptor
		self.x_usp.AMMO_MAX = 100
		self.x_usp.stats.damage = 79
		self.x_usp.fire_mode_data.fire_rate = 0.09

		--Signature 40
		self.x_p226.AMMO_MAX = 100
		self.x_p226.stats.damage = 79
		self.x_p226.fire_mode_data.fire_rate = 0.09
		self.x_p226.AMMO_PICKUP = {0.91, 3.18}

		--Chimano Compact
		self.jowi.fire_mode_data.fire_rate = 0.09
		self.jowi.stats.recoil = 19
		self.jowi.stats.spread = 16
		self.jowi.stats.damage = 59
		self.jowi.AMMO_MAX = 140
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
		self.x_g22c.AMMO_MAX = 100
		self.x_g22c.fire_mode_data.fire_rate = 0.09

		--Stryk
		self.x_g18c.stats.damage = 45
		self.x_g18c.stats.spread = 16
		self.x_g18c.stats.recoil = 6
		self.x_g18c.AMMO_MAX = 140

		--Gruber Kurz
		self.x_ppk.fire_mode_data.fire_rate = 0.09
		self.x_ppk.stats.spread = 15
		self.x_ppk.AMMO_MAX = 140
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
		self.x_hs2000.AMMO_MAX = 100
		self.x_hs2000.stats.damage = 79
		self.x_hs2000.fire_mode_data.fire_rate = 0.09

		--Crosskill
		self.x_1911.AMMO_MAX = 100
		self.x_1911.stats.damage = 79
		self.x_1911.fire_mode_data.fire_rate = 0.09

		--Deagle
		self.x_deagle.fire_mode_data.fire_rate = 0.166
		self.x_deagle.stats.recoil = 3
		self.x_deagle.stats.damage = 145
		self.x_deagle.AMMO_MAX = 60

		--Broomstick
		self.x_c96.AMMO_MAX = 90
		self.x_c96.stats.damage = 96
		self.x_c96.fire_mode_data.fire_rate = 0.13

		--Parabellum
		self.x_breech.AMMO_MAX = 60
		self.x_breech.AMMO_PICKUP = {0.54, 1}

		--M13
		self.x_legacy.stats.damage = 60
		self.x_legacy.stats.spread = 18
		self.x_legacy.AMMO_MAX = 140
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

		--Castigo
		self.x_chinchilla.AMMO_PICKUP = {0.54, 1}

		--Matever
		self.x_2006m.AMMO_PICKUP = {0.54, 1}

		--Crosskill Guard
		self.x_shrew.stats.damage = 59
		self.x_shrew.stats.recoil = 19
		self.x_shrew.fire_mode_data.fire_rate = 0.09
		self.x_shrew.stats.spread = 18
		self.x_shrew.AMMO_MAX = 140
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
		self.hunter.AMMO_PICKUP = {1, 2}

		--Modern Bow
		self.elastic.AMMO_PICKUP = {0.54, 1}

		--Airbow
		self.ecp.AMMO_PICKUP = {0.54, 1}

		--Plainsrider Bow
		self.plainsrider.AMMO_PICKUP = {1, 2}

		--Light Crossbow
		self.frankish.AMMO_PICKUP = {0.54, 1}

		--Longbow
		self.long.AMMO_PICKUP = {0.54, 1}

		--Heavy Crossbow
		self.arblast.AMMO_PICKUP = {0.54, 1}

		--AMR12
		if self.amr12 then 
		self.amr12.stats.damage = 130
		self.amr12.damage_near = 400
		self.amr12.damage_far = 900
		self.amr12.AMMO_PICKUP = {2, 3}
		self.amr12.AMMO_MAX = 50
		self.amr12.kick = {
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
		self.beck.damage_near = 400
		self.beck.damage_far = 900
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

		--PX4
		if self.px4 then 
		self.px4.AMMO_MAX = 90
		self.px4.stats.damage = 79
		self.px4.fire_mode_data.fire_rate = 0.09
		self.px4.AMMO_PICKUP = {0.91, 3.18}
		end		

		--Mars
		if self.mars then 
		self.mars.AMMO_MAX = 60
		self.mars.stats.damage = 145
		self.mars.fire_mode_data.fire_rate = 0.166
		self.mars.AMMO_PICKUP = {0.5, 1.9}

		end

		--M&P40
		if self.swmp40 then 
		self.swmp40.AMMO_MAX = 90
		self.swmp40.stats.damage = 79
		self.swmp40.fire_mode_data.fire_rate = 0.09
		self.swmp40.AMMO_PICKUP = {0.91, 3.18}
		end			

		--P99
		if self.p99 then 
		self.p99.stats.spread = 16
		self.p99.stats.damage = 59
		self.p99.fire_mode_data.fire_rate = 0.09
		self.p99.AMMO_MAX = 120
		self.p99.stats.recoil = 19
		self.p99.kick = {
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
		self.p99.AMMO_PICKUP = {1.53, 5.36}
		end	

		--HK USP
		if self.ctfavourite then 
		self.ctfavourite.AMMO_MAX = 90
		self.ctfavourite.stats.damage = 79
		self.ctfavourite.fire_mode_data.fire_rate = 0.09
		self.ctfavourite.AMMO_PICKUP = {0.91, 3.18}
		end			


		--Norinco
		if self.chinesium then 
		self.chinesium.AMMO_MAX = 90
		self.chinesium.stats.damage = 79
		self.chinesium.fire_mode_data.fire_rate = 0.09
		self.chinesium.AMMO_PICKUP = {0.91, 3.18}
		end			

		--Makarov
		if self.pm then 
		self.pm.stats.spread = 16
		self.pm.stats.damage = 59
		self.pm.fire_mode_data.fire_rate = 0.09
		self.pm.AMMO_MAX = 120
		self.pm.stats.recoil = 19
		self.pm.kick = {
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
		self.pm.AMMO_PICKUP = {1.53, 5.36}
		end	

		--GSH
		if self.gsh18 then 
		self.gsh18.stats.spread = 16
		self.gsh18.stats.damage = 59
		self.gsh18.fire_mode_data.fire_rate = 0.09
		self.gsh18.AMMO_MAX = 120
		self.gsh18.stats.recoil = 19
		self.gsh18.kick = {
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
		self.gsh18.AMMO_PICKUP = {1.53, 5.36}
		end	

		--P225
		if self.sammy then 
		self.sammy.AMMO_MAX = 90
		self.sammy.stats.damage = 79
		self.sammy.fire_mode_data.fire_rate = 0.09
		self.sammy.AMMO_PICKUP = {0.91, 3.18}
		end			

		--SW659
		if self.sw659 then 
		self.sw659.stats.spread = 16
		self.sw659.stats.damage = 59
		self.sw659.fire_mode_data.fire_rate = 0.09
		self.sw659.AMMO_MAX = 120
		self.sw659.stats.recoil = 19
		self.sw659.kick = {
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
		self.sw659.AMMO_PICKUP = {1.53, 5.36}
		end	

		--TT33
		if self.gtt33 then 
		self.gtt33.AMMO_MAX = 90
		self.gtt33.stats.damage = 79
		self.gtt33.fire_mode_data.fire_rate = 0.09
		self.gtt33.AMMO_PICKUP = {0.91, 3.18}
		end		

		--Glock 19
		if self.g19 then 
		self.g19.AMMO_MAX = 90
		self.g19.stats.damage = 79
		self.g19.fire_mode_data.fire_rate = 0.09
		self.g19.AMMO_PICKUP = {0.91, 3.18}
		end	

		--CZ75 Shadow
		if self.cz then 
		self.cz.AMMO_MAX = 90
		self.cz.stats.damage = 79
		self.cz.fire_mode_data.fire_rate = 0.09
		self.cz.AMMO_PICKUP = {0.91, 3.18}
		self.cz.stats.spread = 17
		end	

		--Weird CZ75
		if self.axewscope then 
		self.axewscope.fire_mode_data.fire_rate = 0.13
		self.axewscope.AMMO_MAX = 65
		end	

		--Bren Ten
		if self.sonny then 
		self.sonny.fire_mode_data.fire_rate = 0.13
		self.sonny.AMMO_MAX = 65
		end	

		--Funky Silenced Pistol
		if self.max9 then 
		self.max9.AMMO_MAX = 90
		self.max9.stats.damage = 79
		self.max9.fire_mode_data.fire_rate = 0.09
		self.max9.AMMO_PICKUP = {0.91, 3.18}
		end		

		--PB
		if self.pb then 
		self.pb.stats.spread = 16
		self.pb.stats.damage = 59
		self.pb.fire_mode_data.fire_rate = 0.09
		self.pb.AMMO_MAX = 120
		self.pb.stats.recoil = 19
		self.pb.kick = {
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
		self.pb.AMMO_PICKUP = {1.53, 5.36}
		end	

		--SOME P220 PISTOL AHFJKAHFlk WHAT EVEN 
		if self.noodle then 
		self.noodle.AMMO_MAX = 90
		self.noodle.stats.damage = 79
		self.noodle.fire_mode_data.fire_rate = 0.09
		self.noodle.AMMO_PICKUP = {0.91, 3.18}
		end		

		--BHP
		if self.hpb then 
		self.hpb.AMMO_MAX = 90
		self.hpb.stats.damage = 79
		self.hpb.fire_mode_data.fire_rate = 0.09
		self.hpb.AMMO_PICKUP = {0.91, 3.18}
		end		

		--FNP
		if self.fnp45 then 
		self.fnp45.AMMO_MAX = 90
		self.fnp45.stats.damage = 79
		self.fnp45.fire_mode_data.fire_rate = 0.09
		self.fnp45.AMMO_PICKUP = {0.91, 3.18}
		end		

		--ugly russian gun
		if self.mp443 then 
		self.mp443.AMMO_MAX = 90
		self.mp443.stats.damage = 79
		self.mp443.fire_mode_data.fire_rate = 0.09
		self.mp443.AMMO_PICKUP = {0.91, 3.18}
		end	


		--another glock
		if self.glawk then 
		self.glawk.AMMO_MAX = 90
		self.glawk.stats.damage = 79
		self.glawk.fire_mode_data.fire_rate = 0.09
		self.glawk.AMMO_PICKUP = {0.91, 3.18}
		end		

		-- Crosskill but from Insurgency
		if self.m45a1 then 
		self.m45a1.AMMO_MAX = 80
		self.m45a1.fire_mode_data.fire_rate = 0.13
		self.m45a1.AMMO_PICKUP = {0.75, 2.5}
		end	

		--Developer's Note: The suffering I am feeling from adding all of these custom weapons is unimaginable
			
	end
end)