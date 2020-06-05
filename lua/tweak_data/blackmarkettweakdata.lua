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
	end
end)