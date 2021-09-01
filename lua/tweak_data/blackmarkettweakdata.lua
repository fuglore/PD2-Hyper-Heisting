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
		self.projectiles.wpn_gre_electric.pickup_chance = 0.03
		
	end
end)