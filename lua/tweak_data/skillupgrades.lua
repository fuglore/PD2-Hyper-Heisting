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
	
	
		self.values.temporary.overkill_damage_multiplier = {{1.25, 8}}
		self.values.pistol.damage_addend = {0.5, 1}
		self.values.pistol.fire_rate_multiplier = {1.25}
		self.values.pistol.reload_speed_multiplier = {1.25}
	end
	
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