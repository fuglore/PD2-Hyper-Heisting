function WeaponTweakData:_set_characters_weapon_preset(rifle_spread, smg_spread, lmg_spread, mini_spread)
	--uh oh sisters *melts into dust leaving only my bones behind*
	local all_rifles = {
		"m4_npc",
		"m4_yellow_npc",
		"ak47_npc",
		"g36_npc",
		"smoke_npc",
		"scar_npc",
		"lazer_npc"
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
end

Hooks:PostHook(WeaponTweakData, "init", "lore_init", function(self, tweakdata)
	
	self.ak47_ass_npc.DAMAGE = 1
	self.mp5_npc.DAMAGE = 1
	self.ump_npc.DAMAGE = 1
	self.akmsu_smg_npc.DAMAGE = 1
	self.m4_npc.DAMAGE = 1
	self.m4_yellow_npc.DAMAGE = 1
	self.g36_npc.DAMAGE = 1
	self.ak47_npc.DAMAGE = 1
	self.smoke_npc.DAMAGE = 1
	self.saiga_npc.DAMAGE = 5
	self.scar_npc.DAMAGE = 1.5
	
	--New adjustment for consistent firing times, I found that the amount of time an enemy could go on without reloading was causing gaps of breathing room in the chaos, these should always be a LITTLE bit.
	self.m4_npc.auto.fire_rate = 0.08
	self.m4_yellow_npc.auto.fire_rate = 0.08
	self.g36_npc.auto.fire_rate = 0.08
	self.smoke_npc.auto.fire_rate = 0.08
	self.ak47_ass_npc.auto.fire_rate = 0.08
	self.ak47_npc.auto.fire_rate = 0.08
	
	--This...is important, suppression needs to be changed between enemies due to the way suppression works being partially modified on the player's side, as such, minimum suppression for a few things that I want to really lay suppression on the player on have been greatly increased.
	self.m4_npc.suppression = 1
	self.m4_yellow_npc.suppression = 1
	self.ak47_npc.suppression = 1
	self.ak47_ass_npc.suppression = 1
	self.g36_npc.suppression = 1
	self.smoke_npc.suppression = 1
	self.mp5_npc.suppression = 5
	self.saiga_npc.suppression = 1
	self.r870_npc.suppression = 2
	self.benelli_npc.suppression = 2
	self.m249_npc.suppression = 5
	self.mini_npc.suppression = 5
	
	--heheheheheh
	self.smoke_npc.muzzleflash = "effects/payday2/particles/weapons/556_auto"
	self.lazer_npc = deep_clone(self.g36_npc)
	self.lazer_npc.sounds.prefix = "tecci_npc"
	self.lazer_npc.muzzleflash = "effects/pd2_mod_hh/particles/weapons/muzzles/blue_muzzle"
	self.lazer_npc.b_trail = true
	self.blazter_npc = deep_clone(self.benelli_npc)
	self.blazter_npc.sounds.prefix = "boot_npc"
	self.blazter_npc.muzzleflash = "effects/pd2_mod_hh/particles/weapons/muzzles/red_muzzle"
	self.blazter_npc.r_trail = true

	
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
	self.ak47_ass_npc = deep_clone(self.m4_npc)
	self.ak47_ass_npc.sounds.prefix = "akm_npc"
	self.ak47_ass_npc.muzzleflash = "effects/payday2/particles/weapons/762_auto"
	self.mp5_tactical_npc = deep_clone(self.mp5_npc)
	self.mp5_tactical_npc.has_suppressor = "suppressed_a"
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
	self.m14_sniper_npc.muzzleflash = "effects/pd2_mod_hh/particles/weapons/muzzles/hivis_muzzle"
	self.svd_snp_npc.muzzleflash = "effects/pd2_mod_hh/particles/weapons/muzzles/hivis_muzzle"
	self.svdsil_snp_npc.muzzleflash = "effects/pd2_mod_hh/particles/weapons/muzzles/hivis_muzzle"
	self.heavy_snp_npc.muzzleflash = "effects/pd2_mod_hh/particles/weapons/muzzles/hivis_muzzle"
	self.mini_npc.muzzleflash = "effects/pd2_mod_hh/particles/weapons/muzzles/hivis_muzzle"
	self.r870_npc.muzzleflash = "effects/pd2_mod_hh/particles/weapons/muzzles/hivis_muzzle"
	self.benelli_npc.muzzleflash = "effects/pd2_mod_hh/particles/weapons/muzzles/hivis_muzzle"
	self.saiga_npc.muzzleflash = "effects/pd2_mod_hh/particles/weapons/muzzles/hivis_muzzle"
	self.m249_npc.muzzleflash = "effects/pd2_mod_hh/particles/weapons/muzzles/hivis_muzzle"
	self.rpk_lmg_npc.muzzleflash = "effects/pd2_mod_hh/particles/weapons/muzzles/hivis_muzzle"
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
	self.smoke_npc.DAMAGE = 0.5
	self.r870_npc.DAMAGE = 2.5
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
	
	self:_set_characters_weapon_preset(40, 20, 20, 100)
	
	--Turret Tweaks.
	self.swat_van_turret_module.HEALTH_INIT = 3500
	self.swat_van_turret_module.SHIELD_HEALTH_INIT = 70
	self.swat_van_turret_module.DAMAGE = 0.5
	self.ceiling_turret_module.HEALTH_INIT = 875
	self.ceiling_turret_module.SHIELD_HEALTH_INIT = 70
	self.ceiling_turret_module.DAMAGE = 0.5
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
	self.smoke_npc.DAMAGE = 0.5
	self.r870_npc.DAMAGE = 2.5
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
	
	self:_set_characters_weapon_preset(40, 20, 20, 100) --setting enemy weapon spread
	
	--Turret Tweaks.
	self.swat_van_turret_module.HEALTH_INIT = 3500
	self.swat_van_turret_module.SHIELD_HEALTH_INIT = 70
	self.swat_van_turret_module.DAMAGE = 0.5
	self.ceiling_turret_module.HEALTH_INIT = 875
	self.ceiling_turret_module.SHIELD_HEALTH_INIT = 70
	self.ceiling_turret_module.DAMAGE = 0.5
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
	
	--rifle tweaks, 2 seconds of firing
	self.m4_npc.CLIP_AMMO_MAX = 25
	self.m4_yellow_npc.CLIP_AMMO_MAX = 25
	self.g36_npc.CLIP_AMMO_MAX = 25
	self.smoke_npc.CLIP_AMMO_MAX = 25
	self.ak47_ass_npc.CLIP_AMMO_MAX = 25
	self.ak47_npc.CLIP_AMMO_MAX = 25
	
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
	self.ceiling_turret_module.SHIELD_HEALTH_INIT = 150
	self.ceiling_turret_module.DAMAGE = 2
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
	self.ceiling_turret_module.SHIELD_HEALTH_INIT = 150
	self.ceiling_turret_module.DAMAGE = 2
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
	self.ceiling_turret_module.HEALTH_INIT = 19500
	self.ceiling_turret_module.SHIELD_HEALTH_INIT = 200
	self.ceiling_turret_module.DAMAGE = 3.5
	self.ceiling_turret_module.CLIP_SIZE = 800
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
	self.ceiling_turret_module.HEALTH_INIT = 19500
	self.ceiling_turret_module.SHIELD_HEALTH_INIT = 200
	self.ceiling_turret_module.DAMAGE = 3.5
	self.ceiling_turret_module.CLIP_SIZE = 800
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
	
	--Turret tweaks.
	self.swat_van_turret_module.HEALTH_INIT = 25000
	self.swat_van_turret_module.SHIELD_HEALTH_INIT = 400
	self.swat_van_turret_module.DAMAGE = 2
	self.swat_van_turret_module.CLIP_SIZE = 800
	self.ceiling_turret_module.HEALTH_INIT = 19500
	self.ceiling_turret_module.SHIELD_HEALTH_INIT = 200
	self.ceiling_turret_module.DAMAGE = 3.5
	self.ceiling_turret_module.CLIP_SIZE = 800
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
