function CrimeSpreeTweakData:init_modifiers(tweak_data)
	self.max_modifiers_displayed = 1
	self.modifier_levels = {
		loud = 10,
		forced = 25,
		stealth = math.huge
	}
	self.modifiers = {
		forced = {
			{
				class = "ModifierEnemyHealthAndDamage",
				id = "damage_health_1",
				icon = "crime_spree_health",
				level = 50,
				data = {
					health = {
						5,
						"add"
					},
					damage = {
						10,
						"add"
					}
				}
			}
		},
		loud = {
			{
				id = "shield_reflect",
				icon = "crime_spree_shield_reflect",
				class = "ModifierShieldReflect",
				data = {}
			},
			{
				id = "cloaker_smoke",
				icon = "crime_spree_cloaker_smoke",
				class = "ModifierCloakerKick",
				data = {
					effect = {
						"smoke",
						"none"
					}
				}
			},
			{
				id = "dozer_rage",
				icon = "cs_modifier_bronconinja",
				class = "ModifierDozerRage",
				data = {
					damage = {
						100,
						"add"
					}
				}
			},
			{
				id = "heavies",
				icon = "crime_spree_heavies",
				class = "ModifierHeavies",
				data = {
					boolean = {
						1,
						"none"
					}
				}
			},
			{
				id = "medic_1",
				icon = "crime_spree_more_medics",
				class = "ModifierMoreMedics",
				data = {
					inc = {
						2,
						"add"
					}
				}
			},
			{
				id = "no_hurt",
				icon = "crime_spree_no_hurt",
				class = "ModifierHurtResist",
				data = {
					multiplier = {
						0.75,
						"add"
					},
				}
			},
			{
				id = "aggro",
				icon = "cs_modifier_aggro",
				class = "ModifierAggro",
				level = 100,
				data = {
					boolean = {
						1,
						"none"
					}
				}
			},
			{
				id = "shield_phalanx",
				icon = "cs_modifier_saigasec",
				class = "ModifierShieldPhalanx",
				data = {}
			},
			{
				id = "heavy_sniper",
				icon = "cs_modifier_ftsudozer",
				class = "ModifierHeavySniper",
				data = {
					spawn_chance = {
						5,
						"add"
					}
				}
			},
			{
				id = "cloaker_tear_gas",
				icon = "cs_modifier_telespooc",
				class = "ModifierCloakerTearGas",
				data = {
					diameter = {
						4,
						"none"
					},
					damage = {
						30,
						"none"
					},
					duration = {
						10,
						"none"
					}
				}
			},
			{
				id = "taser_overcharge",
				icon = "crime_spree_taser_overcharge",
				class = "ModifierTaserOvercharge",
				data = {
					boolean = {
						1,
						"none"
					}
				}
			},
			{
				id = "dozer_1",
				icon = "crime_spree_more_dozers",
				class = "ModifierMoreDozers",
				data = {
					inc = {
						2,
						"add"
					}
				}
			},
			{
				id = "dozer_lmg",
				icon = "cs_modifier_difficultyspike",
				class = "ModifierSkulldozers",
				level = 200,
				data = {
					boolean = {
						1,
						"none"
					}
				}
			},
			{
				id = "medic_adrenaline",
				icon = "cs_modifier_zealot",
				class = "ModifierMedicAdrenaline",
				data = {
					damage = {
						100,
						"add"
					}
				}
			},
			{
				id = "voltergas",
				icon = "crime_spree_cloaker_tear_gas",
				class = "ModifierVolter",
				data = {
					boolean = {
						1,
						"none"
					}
				}
			},
			{
				id = "winters",
				icon = "cs_modifier_truelotusmaster",
				class = "ModifierDozerMedic",
				data = {}
			},
			{
				id = "dozer_2",
				icon = "crime_spree_more_dozers",
				class = "ModifierMoreDozers",
				data = {
					inc = {
						2,
						"add"
					}
				}
			},
			{
				id = "medic_deathwish",
				icon = "crime_spree_medic_deathwish",
				class = "ModifierMedicDeathwish",
				data = {}
			},
			{
				id = "dozer_minigun",
				icon = "crime_spree_dozer_minigun",
				class = "ModifierDozerMinigun",
				data = {}
			},
			{
				id = "medic_2",
				icon = "crime_spree_more_medics",
				class = "ModifierMoreMedics",
				data = {
					inc = {
						2,
						"add"
					}
				}
			},
			{
				id = "shin",
				icon = "cs_modifier_shoryu",
				class = "ModifierShin",
				level = 300,
				data = {}
			},
			{
				id = "bouncer_nades",
				icon = "cs_modifier_bouncer",
				class = "ModifierBouncers",
				data = {}
			},
			{
				id = "megacloakers",
				icon = "cs_modifier_themegas",
				class = "ModifierMegaCloakers",
				data = {
					boolean = {
						1,
						"none"
					}
				}
			},
			{
				id = "medic_rage",
				icon = "crime_spree_medic_rage",
				class = "ModifierMedicRage",
				data = {
					damage = {
						20,
						"add"
					}
				}
			},
			{
				id = "magnetstorm",
				icon = "cs_modifier_magnetstorm",
				class = "ModifierMagnetstorm",
				data = {
					boolean = {
						1,
						"none"
					}
				}
			}
		},
		stealth = {
			{
				class = "ModifierLessPagers",
				id = "pagers_1",
				icon = "crime_spree_pager",
				level = math.huge,
				data = {
					count = {
						1,
						"max"
					}
				}
			},
			{
				class = "ModifierCivilianAlarm",
				id = "civs_1",
				icon = "crime_spree_civs_killed",
				level = math.huge,
				data = {
					count = {
						10,
						"min"
					}
				}
			},
			{
				class = "ModifierLessConcealment",
				id = "conceal_1",
				icon = "crime_spree_concealment",
				level = math.huge,
				data = {
					conceal = {
						3,
						"add"
					}
				}
			},
			{
				class = "ModifierCivilianAlarm",
				id = "civs_2",
				icon = "crime_spree_civs_killed",
				level = math.huge,
				data = {
					count = {
						7,
						"min"
					}
				}
			},
			{
				class = "ModifierLessPagers",
				id = "pagers_2",
				icon = "crime_spree_pager",
				level = math.huge,
				data = {
					count = {
						2,
						"max"
					}
				}
			},
			{
				class = "ModifierLessConcealment",
				id = "conceal_2",
				icon = "crime_spree_concealment",
				level = math.huge,
				data = {
					conceal = {
						3,
						"add"
					}
				}
			},
			{
				class = "ModifierLessPagers",
				id = "pagers_3",
				icon = "crime_spree_pager",
				level = math.huge,
				data = {
					count = {
						3,
						"max"
					}
				}
			},
			{
				class = "ModifierCivilianAlarm",
				id = "civs_3",
				icon = "crime_spree_civs_killed",
				level = math.huge,
				data = {
					count = {
						4,
						"min"
					}
				}
			},
			{
				class = "ModifierLessPagers",
				id = "pagers_4",
				icon = "crime_spree_pager",
				level = math.huge,
				data = {
					count = {
						4,
						"max"
					}
				}
			}
		}
	}
	self.repeating_modifiers = {
		forced = {
			{
				class = "ModifierEnemyHealthAndDamage",
				id = "damage_health_rpt_",
				icon = "crime_spree_health",
				level = 5,
				data = {
					health = {
						20,
						"add"
					},
					damage = {
						15,
						"add"
					}
				}
			}
		}
	}
end

function CrimeSpreeTweakData:init_gage_assets(tweak_data)
	local asset_cost = 18
	self.max_assets_unlocked = 4
	self.assets = {
		increased_health = {}
	}
	self.assets.increased_health.name_id = "menu_cs_ga_increased_health"
	self.assets.increased_health.unlock_desc_id = "menu_cs_ga_increased_health_desc"
	self.assets.increased_health.icon = "csb_health"
	self.assets.increased_health.cost = asset_cost
	self.assets.increased_health.data = {
		health = 10
	}
	self.assets.increased_health.class = "GageModifierMaxHealth"
	self.assets.increased_armor = {
		name_id = "menu_cs_ga_increased_armor",
		unlock_desc_id = "menu_cs_ga_increased_armor_desc",
		icon = "csb_armor",
		cost = asset_cost,
		data = {
			armor = 10
		},
		class = "GageModifierMaxArmor"
	}
	self.assets.increased_stamina = {
		name_id = "menu_cs_ga_increased_stamina",
		unlock_desc_id = "menu_cs_ga_increased_stamina_desc",
		icon = "csb_stamina",
		cost = asset_cost,
		data = {
			stamina = 100
		},
		class = "GageModifierMaxStamina"
	}
	self.assets.increased_ammo = {
		name_id = "menu_cs_ga_increased_ammo",
		unlock_desc_id = "menu_cs_ga_increased_ammo_desc",
		icon = "csb_ammo",
		cost = asset_cost,
		data = {
			ammo = 15
		},
		class = "GageModifierMaxAmmo"
	}
	self.assets.increased_lives = {
		name_id = "menu_cs_ga_increased_lives",
		unlock_desc_id = "menu_cs_ga_increased_lives_desc",
		icon = "csb_lives",
		cost = asset_cost,
		data = {
			lives = 1
		},
		class = "GageModifierMaxLives"
	}
	self.assets.increased_deployables = {
		name_id = "menu_cs_ga_increased_deployables",
		unlock_desc_id = "menu_cs_ga_increased_deployables_desc",
		icon = "csb_deployables",
		cost = asset_cost,
		data = {
			deployables = 50
		},
		class = "GageModifierMaxDeployables"
	}
	self.assets.increased_absorption = {
		name_id = "menu_cs_ga_increased_absorption",
		unlock_desc_id = "menu_cs_ga_increased_absorption_desc",
		icon = "csb_absorb",
		cost = asset_cost,
		data = {
			absorption = 0.5
		},
		class = "GageModifierDamageAbsorption"
	}
	self.assets.quick_reload = {
		name_id = "menu_cs_ga_quick_reload",
		unlock_desc_id = "menu_cs_ga_quick_reload_desc",
		icon = "csb_reload",
		cost = asset_cost,
		data = {
			speed = 25
		},
		class = "GageModifierQuickReload"
	}
	self.assets.quick_switch = {
		name_id = "menu_cs_ga_quick_switch",
		unlock_desc_id = "menu_cs_ga_quick_switch_desc",
		icon = "csb_switch",
		cost = asset_cost,
		data = {
			speed = 50
		},
		class = "GageModifierQuickSwitch"
	}
	self.assets.melee_invulnerability = {
		name_id = "menu_cs_ga_melee_invulnerability",
		unlock_desc_id = "menu_cs_ga_melee_invulnerability_desc",
		icon = "csb_melee",
		cost = asset_cost,
		data = {
			time = 5
		},
		class = "GageModifierMeleeInvincibility"
	}
	self.assets.life_steal = {
		name_id = "menu_cs_ga_life_steal",
		unlock_desc_id = "menu_cs_ga_life_steal_desc",
		icon = "csb_lifesteal",
		cost = asset_cost,
		data = {
			cooldown = 5,
			armor_restored = 0.05,
			health_restored = 0.05
		},
		class = "GageModifierLifeSteal"
	}
	self.assets.quick_pagers = {
		name_id = "menu_cs_ga_quick_pagers",
		unlock_desc_id = "menu_cs_ga_quick_pagers_desc",
		icon = "csb_pagers",
		cost = asset_cost,
		data = {
			speed = 50
		},
		stealth = true,
		class = "GageModifierQuickPagers"
	}
	self.assets.increased_body_bags = {
		name_id = "menu_cs_ga_increased_body_bags",
		unlock_desc_id = "menu_cs_ga_increased_body_bags_desc",
		icon = "csb_bodybags",
		cost = asset_cost,
		data = {
			bags = 2
		},
		stealth = true,
		class = "GageModifierMaxBodyBags"
	}
	self.assets.quick_locks = {
		name_id = "menu_cs_ga_quick_locks",
		unlock_desc_id = "menu_cs_ga_quick_locks_desc",
		icon = "csb_locks",
		cost = asset_cost,
		data = {
			speed = 25
		},
		stealth = true,
		class = "GageModifierQuickLocks"
	}
end