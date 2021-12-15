Hooks:PostHook(BlackMarketTweakData, "_init_textures", "bmtsyncshit", function(self, tweak_data)
		self.textures.truthrunes = {
			name_id = "pattern_truthrunes_title",
			pcs = {},
			texture = "patterns/真_fv",
			value = 0,
			global_value = "hyperheist"
		}
end)

Hooks:PostHook(BlackMarketTweakData, "_init_projectiles", "hhthrowable", function(self, tweak_data)
	if PD2THHSHIN and PD2THHSHIN:IsOverhaulEnabled() then
		--stoic hip flask change
		self.projectiles.damage_control = {
			name_id = "bm_grenade_damage_control",
			desc_id = "bm_grenade_damage_control_desc",
			icon = "damage_control",
			ability = true,
			texture_bundle_folder = "myh",
			max_amount = 1,
			base_cooldown = 15,
			sounds = {
				cooldown = "perkdeck_cooldown_over"
			}
		}
		
		self.projectiles.frag.pickup_chance = 0.05
		self.projectiles.frag_com.pickup_chance = 0.05
		self.projectiles.dada_com.pickup_chance = 0.05
		self.projectiles.dynamite.pickup_chance = 0.025
		self.projectiles.molotov.pickup_chance = 0.02
		self.projectiles.molotov.max_amount = 2
		self.projectiles.fir_com.pickup_chance = 0.03
		self.projectiles.fir_com.max_amount = 3
		self.projectiles.concussion.pickup_chance = 0.1
		self.projectiles.concussion.max_amount = 2
		self.projectiles.wpn_prj_four.pickup_chance = 0.1
		--self.projectiles.wpn_prj_ace.damage = 100
		self.projectiles.wpn_prj_ace.pickup_chance = 0.1
		--self.projectiles.wpn_prj_hur.damage = 60
		self.projectiles.wpn_prj_hur.pickup_chance = 0.05
		self.projectiles.wpn_prj_hur.max_amount = 5
		--self.projectiles.wpn_prj_target.damage = 40
		self.projectiles.wpn_prj_target.pickup_chance = 0.05
		self.projectiles.wpn_prj_target.max_amount = 8
		--self.projectiles.wpn_prj_jav.damage = 300
		self.projectiles.wpn_prj_jav.pickup_chance = 0.03
		self.projectiles.wpn_prj_jav.max_amount = 1
		self.projectiles.wpn_gre_electric.pickup_chance = 0.025
		self.projectiles.xmas_snowball.pickup_chance = 0.02
		
	end
end)

Hooks:PostHook(BlackMarketTweakData, "_init_melee_weapons", "hhmelee", function(self, tweak_data)
	self.melee_weapons.weapon.stats = {
		min_damage = 12,
		max_damage = 12,
		min_damage_effect = 1,
		max_damage_effect = 1,
		charge_time = 0,
		range = 250,
		weapon_type = "blunt"
	}
	self.melee_weapons.weapon.expire_t = 0.5
	self.melee_weapons.weapon.repeat_expire_t = 0.5
	
	self.melee_weapons.fists.stats.min_damage = 12
	self.melee_weapons.fists.stats.max_damage = 32
	self.melee_weapons.fists.stats.min_damage_effect = 1
	self.melee_weapons.fists.stats.max_damage_effect = 3
	self.melee_weapons.fists.stats.charge_time = 1
	self.melee_weapons.fists.stats.range = 250
	
	self.melee_weapons.kabar.stats.min_damage = 24
	self.melee_weapons.kabar.stats.max_damage = 48
	self.melee_weapons.kabar.stats.charge_time = 1.4
	self.melee_weapons.kabar.stats.range = 285
	
	self.melee_weapons.rambo.stats.min_damage = 24
	self.melee_weapons.rambo.stats.max_damage = 48
	self.melee_weapons.rambo.stats.charge_time = 1.4
	self.melee_weapons.rambo.stats.range = 285
	
	self.melee_weapons.gerber.stats.min_damage = 12
	self.melee_weapons.gerber.stats.max_damage = 64
	self.melee_weapons.gerber.stats.charge_time = 2
	self.melee_weapons.gerber.stats.range = 285
	
	self.melee_weapons.kampfmesser.stats.min_damage = 12
	self.melee_weapons.kampfmesser.stats.max_damage = 64
	self.melee_weapons.kampfmesser.stats.charge_time = 2
	self.melee_weapons.kampfmesser.stats.range = 285
	
	self.melee_weapons.brass_knuckles.stats.min_damage = 24
	self.melee_weapons.brass_knuckles.stats.max_damage = 64
	self.melee_weapons.brass_knuckles.stats.range = 254
	self.melee_weapons.brass_knuckles.stats.charge_time = 2
	
	self.melee_weapons.tomahawk.stats.min_damage = 32
	self.melee_weapons.tomahawk.stats.max_damage = 64
	self.melee_weapons.tomahawk.stats.range = 285
	
	self.melee_weapons.baton.stats.min_damage = 12
	self.melee_weapons.baton.stats.max_damage = 32
	self.melee_weapons.baton.stats.min_damage_effect = 3
	self.melee_weapons.baton.stats.max_damage_effect = 3
	self.melee_weapons.baton.stats.range = 350
	
	self.melee_weapons.swagger.stats.min_damage = 12
	self.melee_weapons.swagger.stats.max_damage = 32
	self.melee_weapons.swagger.stats.min_damage_effect = 3
	self.melee_weapons.swagger.stats.max_damage_effect = 3
	self.melee_weapons.swagger.stats.range = 350
	
	self.melee_weapons.shovel.stats.min_damage = 32
	self.melee_weapons.shovel.stats.max_damage = 32
	self.melee_weapons.shovel.stats.min_damage_effect = 3
	self.melee_weapons.shovel.stats.max_damage_effect = 6
	self.melee_weapons.shovel.stats.charge_time = 2
	self.melee_weapons.shovel.stats.range = 330
	
	self.melee_weapons.becker.stats.min_damage = 24
	self.melee_weapons.becker.stats.max_damage = 48
	self.melee_weapons.becker.stats.charge_time = 1.4
	self.melee_weapons.becker.stats.range = 285
	
	self.melee_weapons.moneybundle.stats.min_damage = 12
	self.melee_weapons.moneybundle.stats.max_damage = 12
	self.melee_weapons.moneybundle.stats.min_damage_effect = 1
	self.melee_weapons.moneybundle.stats.max_damage_effect = 1
	self.melee_weapons.moneybundle.stats.charge_time = 0
	self.melee_weapons.moneybundle.stats.range = 250
	
	self.melee_weapons.barbedwire.stats.min_damage = 40
	self.melee_weapons.barbedwire.stats.max_damage = 80
	self.melee_weapons.barbedwire.stats.min_damage_effect = 1.25
	self.melee_weapons.barbedwire.stats.max_damage_effect = 1.25
	self.melee_weapons.barbedwire.stats.charge_time = 1.8
	self.melee_weapons.barbedwire.stats.range = 320
	
	self.melee_weapons.baseballbat.stats.min_damage = 40
	self.melee_weapons.baseballbat.stats.max_damage = 80
	self.melee_weapons.baseballbat.stats.min_damage_effect = 1
	self.melee_weapons.baseballbat.stats.max_damage_effect = 1
	self.melee_weapons.baseballbat.stats.charge_time = 1.4
	self.melee_weapons.baseballbat.stats.range = 320
	
	self.melee_weapons.x46.stats.min_damage = 24
	self.melee_weapons.x46.stats.max_damage = 48
	self.melee_weapons.x46.stats.min_damage_effect = 1
	self.melee_weapons.x46.stats.max_damage_effect = 1
	self.melee_weapons.x46.stats.charge_time = 1.4
	
	self.melee_weapons.dingdong.stats.min_damage = 60
	self.melee_weapons.dingdong.stats.max_damage = 100
	self.melee_weapons.dingdong.stats.min_damage_effect = 1
	self.melee_weapons.dingdong.stats.max_damage_effect = 3
	self.melee_weapons.dingdong.stats.charge_time = 2
	self.melee_weapons.dingdong.stats.range = 375
	
	self.melee_weapons.spoon.stats.min_damage = 60
	self.melee_weapons.spoon.stats.max_damage = 100
	self.melee_weapons.spoon.stats.min_damage_effect = 1
	self.melee_weapons.spoon.stats.max_damage_effect = 1
	self.melee_weapons.spoon.stats.charge_time = 1.4
	self.melee_weapons.spoon.stats.range = 375
	
	self.melee_weapons.spoon_gold.stats.concealment = 26
	self.melee_weapons.spoon_gold.stats.min_damage = 60
	self.melee_weapons.spoon_gold.stats.max_damage = 100
	self.melee_weapons.spoon_gold.stats.min_damage_effect = 1
	self.melee_weapons.spoon_gold.stats.max_damage_effect = 1
	self.melee_weapons.spoon_gold.stats.charge_time = 1.4
	self.melee_weapons.spoon_gold.stats.range = 375
	self.melee_weapons.spoon_gold.fire_dot_data = nil
	
	self.melee_weapons.bayonet.stats.min_damage = 24
	self.melee_weapons.bayonet.stats.max_damage = 24
	self.melee_weapons.bayonet.stats.min_damage_effect = 1
	self.melee_weapons.bayonet.stats.max_damage_effect = 1
	self.melee_weapons.bayonet.stats.charge_time = 0
	self.melee_weapons.bayonet.stats.range = 285
	
	self.melee_weapons.bullseye.stats.min_damage = 24
	self.melee_weapons.bullseye.stats.max_damage = 64
	self.melee_weapons.bullseye.stats.charge_time = 2.4
	self.melee_weapons.bullseye.stats.range = 250
	self.melee_weapons.bullseye.stats.concealment = 30
	
	self.melee_weapons.cleaver.stats.min_damage = 12
	self.melee_weapons.cleaver.stats.max_damage = 48
	self.melee_weapons.cleaver.stats.min_damage_effect = 1
	self.melee_weapons.cleaver.stats.max_damage_effect = 1
	self.melee_weapons.cleaver.stats.charge_time = 1
	self.melee_weapons.cleaver.stats.range = 250
	self.melee_weapons.cleaver.stats.panic_on_kill = true
	self.melee_weapons.cleaver.stats.concealment = 30
	
	self.melee_weapons.fireaxe.stats.min_damage = 80
	self.melee_weapons.fireaxe.stats.max_damage = 80
	self.melee_weapons.fireaxe.stats.min_damage_effect = 1
	self.melee_weapons.fireaxe.stats.max_damage_effect = 1
	self.melee_weapons.fireaxe.stats.charge_time = 0
	self.melee_weapons.fireaxe.stats.range = 375
	self.melee_weapons.fireaxe.stats.concealment = 24
	self.melee_weapons.fireaxe.stats.panic_on_kill = true
	
	self.melee_weapons.machete.stats.min_damage = 32
	self.melee_weapons.machete.stats.max_damage = 32
	self.melee_weapons.machete.stats.min_damage_effect = 1
	self.melee_weapons.machete.stats.max_damage_effect = 1
	self.melee_weapons.machete.stats.charge_time = 0
	self.melee_weapons.machete.stats.range = 340
	self.melee_weapons.machete.stats.concealment = 26
	
	self.melee_weapons.briefcase.stats.min_damage = 12
	self.melee_weapons.briefcase.stats.max_damage = 12
	self.melee_weapons.briefcase.stats.min_damage_effect = 3
	self.melee_weapons.briefcase.stats.max_damage_effect = 8
	self.melee_weapons.briefcase.stats.charge_time = 1
	self.melee_weapons.briefcase.stats.range = 250
	
	self.melee_weapons.kabartanto.stats.min_damage = 10
	self.melee_weapons.kabartanto.stats.max_damage = 10
	self.melee_weapons.kabartanto.stats.min_damage_effect = 1
	self.melee_weapons.kabartanto.stats.max_damage_effect = 1
	self.melee_weapons.kabartanto.stats.charge_time = 0
	self.melee_weapons.kabartanto.stats.range = 250
	self.melee_weapons.kabartanto.stats.concealment = 30
	self.melee_weapons.kabartanto.stats.can_headshot = true
	
	self.melee_weapons.toothbrush.stats.min_damage = 6
	self.melee_weapons.toothbrush.stats.max_damage = 6
	self.melee_weapons.toothbrush.stats.charge_time = 0
	self.melee_weapons.toothbrush.stats.range = 250
	
	self.melee_weapons.fairbair.stats.min_damage = 6
	self.melee_weapons.fairbair.stats.max_damage = 6
	self.melee_weapons.fairbair.stats.charge_time = 0
	self.melee_weapons.fairbair.stats.range = 250
	
	self.melee_weapons.chef.stats.min_damage = 16
	self.melee_weapons.chef.stats.max_damage = 80
	self.melee_weapons.chef.stats.min_damage_effect = 1
	self.melee_weapons.chef.stats.max_damage_effect = 1
	self.melee_weapons.chef.stats.charge_time = 2
	self.melee_weapons.chef.stats.range = 250
	self.melee_weapons.chef.stats.panic_on_kill = true
	
	self.melee_weapons.freedom.stats.min_damage = 80
	self.melee_weapons.freedom.stats.max_damage = 80
	self.melee_weapons.freedom.stats.min_damage_effect = 1
	self.melee_weapons.freedom.stats.max_damage_effect = 1
	self.melee_weapons.freedom.stats.charge_time = 0
	self.melee_weapons.freedom.stats.range = 375
	self.melee_weapons.freedom.stats.lunge = true
	self.melee_weapons.freedom.stats.concealment = 24
	
	self.melee_weapons.model24.stats.min_damage = 16
	self.melee_weapons.model24.stats.max_damage = 16
	self.melee_weapons.model24.stats.min_damage_effect = 1
	self.melee_weapons.model24.stats.max_damage_effect = 1
	self.melee_weapons.model24.stats.charge_time = 0
	self.melee_weapons.model24.stats.range = 250
	self.melee_weapons.model24.stats.on_death_explosion = true
	
	
end)