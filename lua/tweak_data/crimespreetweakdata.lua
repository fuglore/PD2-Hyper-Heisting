function CrimeSpreeTweakData:init_modifiers(tweak_data)
	local health_increase = 25
	local damage_increase = 25
	self.max_modifiers_displayed = 3
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
						20,
						"add"
					},
					damage = {
						15,
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
				id = "medic_heal_1",
				icon = "crime_spree_medic_speed",
				class = "ModifierHealSpeed",
				data = {
					speed = {
						20,
						"add"
					}
				}
			},
			{
				id = "taser_overcharge",
				icon = "crime_spree_taser_overcharge",
				class = "ModifierTaserOvercharge",
				data = {
					speed = {
						50,
						"add"
					}
				}
			},
			{
				id = "heavies",
				icon = "crime_spree_heavies",
				class = "ModifierHeavies",
				data = {}
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
				icon = "cs_modifier_shoryu",
				class = "ModifierNoHurtAnims",
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
				id = "medic_heal_2",
				icon = "crime_spree_medic_speed",
				class = "ModifierHealSpeed",
				data = {
					speed = {
						20,
						"add"
					}
				}
			},
			{
				id = "dozer_lmg",
				icon = "cs_modifier_difficultyspike",
				class = "ModifierSkulldozers",
				data = {}
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
				id = "shield_phalanx",
				icon = "cs_modifier_saigasec",
				class = "ModifierShieldPhalanx",
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
				id = "dozer_immunity",
				icon = "cs_modifier_aggro",
				class = "ModifierExplosionImmunity",
				data = {}
			},
			{
				id = "dozer_medic",
				icon = "cs_modifier_truelotusmaster",
				class = "ModifierDozerMedic",
				data = {}
			},
			{
				id = "assault_extender",
				icon = "crime_spree_assault_extender",
				class = "ModifierAssaultExtender",
				data = {
					duration = {
						50,
						"add"
					},
					spawn_pool = {
						50,
						"add"
					},
					deduction = {
						4,
						"add"
					},
					max_hostages = {
						8,
						"none"
					}
				}
			},
			{
				id = "bouncer_nades",
				icon = "cs_modifier_bouncer",
				class = "ModifierBouncers",
				data = {}
			},
			{
				id = "cloaker_arrest",
				icon = "crime_spree_cloaker_arrest",
				class = "ModifierCloakerArrest",
				data = {}
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
				icon = "cs_modifier_truelotusmaster",
				class = "ModifierMagnetstorm",
				data = {}
			},
			{
				id = "unison",
				icon = "crime_spree_heavies",
				class = "ModifierUnison",
				data = {}
			},
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

function CrimeSpreeTweakData:init_missions(tweak_data)
	local debug_short_add = 5
	local debug_med_add = 7
	local debug_long_add = 10
	self.missions = {
		{
			{
				stage_id = "branchbank_cash",
				id = "bb_cash",
				icon = "csm_branchbank",
				add = 8,
				level = tweak_data.narrative.stages.branchbank_cash
			},
			{
				stage_id = "cage",
				id = "cage",
				icon = "csm_carshop",
				add = 8,
				level = tweak_data.narrative.stages.cage
			},
			{
				stage_id = "kosugi",
				id = "kosugi",
				icon = "csm_shadow_raid",
				add = 6,
				level = tweak_data.narrative.stages.kosugi
			},
			{
				stage_id = "dark",
				id = "dark",
				icon = "csm_murky",
				add = 8,
				level = tweak_data.narrative.stages.dark
			},
			{
				stage_id = "firestarter_2",
				add = 6,
				id = "fs_2",
				icon = "csm_fs_2",
				level = tweak_data.narrative.stages.firestarter_2
			},
			{
				stage_id = "hox_3",
				add = 4,
				id = "hox_3",
				icon = "csm_hoxvenge",
				level = tweak_data.narrative.stages.hox_3
			},
			{
				stage_id = "fish",
				add = 4,
				id = "fish",
				icon = "csm_yacht",
				level = tweak_data.narrative.stages.fish
			},
			{
				stage_id = "election_day_2",
				add = 8,
				id = "ed_2",
				icon = "csm_election_2",
				level = tweak_data.narrative.stages.election_day_2
			},
			{
				stage_id = "crojob1",
				add = 8,
				id = "crojob1",
				icon = "csm_docks",
				level = tweak_data.narrative.stages.crojob1
			},
			{
				stage_id = "framing_frame_3",
				id = "framing_frame_3",
				icon = "csm_framing_3",
				add = 12,
				level = tweak_data.narrative.stages.framing_frame_3
			},
			{
				stage_id = "arm_for",
				id = "arm_for",
				icon = "csm_train_forest",
				add = 10,
				level = tweak_data.narrative.stages.arm_for
			},
			{
				stage_id = "friend",
				add = 14,
				id = "friend",
				icon = "csm_friend",
				level = tweak_data.narrative.stages.friend
			},
			{
				stage_id = "big",
				add = 14,
				id = "big",
				icon = "csm_big",
				level = tweak_data.narrative.stages.big
			},
			{
				stage_id = "mus",
				id = "mus",
				icon = "csm_diamond",
				add = 12,
				level = tweak_data.narrative.stages.mus
			},
			{
				stage_id = "roberts",
				id = "roberts",
				icon = "csm_go",
				add = 10,
				level = tweak_data.narrative.stages.roberts
			},
			{
				stage_id = "red2",
				id = "red2",
				icon = "csm_fwb",
				add = 10,
				level = tweak_data.narrative.stages.red2
			}
		},
		{
			{
				stage_id = "wwh",
				add = 8,
				id = "wwh",
				icon = "csm_wwh",
				level = tweak_data.narrative.stages.wwh
			},
			{
				stage_id = "rvd1",
				add = 8,
				id = "rvd1",
				icon = "csm_rvd_1",
				level = tweak_data.narrative.stages.rvd_1
			},
			{
				stage_id = "rvd2",
				add = 10,
				id = "rvd2",
				icon = "csm_rvd_2",
				level = tweak_data.narrative.stages.rvd_2
			},
			{
				stage_id = "brb",
				add = 8,
				id = "brb",
				icon = "csm_brb",
				level = tweak_data.narrative.stages.brb
			},
			{
				stage_id = "arm_cro",
				id = "arm_cro",
				icon = "csm_crossroads",
				add = 8,
				level = tweak_data.narrative.stages.arm_cro
			},
			{
				stage_id = "help",
				id = "help",
				icon = "csm_prison",
				add = 8,
				level = tweak_data.narrative.stages.help
			},
			{
				stage_id = "cage",
				id = "arm_und",
				icon = "csm_overpass",
				add = 8,
				level = tweak_data.narrative.stages.arm_und
			},
			{
				stage_id = "arm_hcm",
				id = "arm_hcm",
				icon = "csm_downtown",
				add = 8,
				level = tweak_data.narrative.stages.arm_hcm
			},
			{
				stage_id = "arm_par",
				id = "arm_par",
				icon = "csm_park",
				add = 8,
				level = tweak_data.narrative.stages.arm_par
			},
			{
				stage_id = "arm_fac",
				id = "arm_fac",
				icon = "csm_harbor",
				add = 8,
				level = tweak_data.narrative.stages.arm_fac
			},
			{
				stage_id = "chew",
				add = 8,
				id = "biker_2",
				icon = "csm_biker_2",
				level = tweak_data.narrative.stages.chew
			},
			{
				stage_id = "firestarter_1",
				add = 6,
				id = "fs_1",
				icon = "csm_fs_1",
				level = tweak_data.narrative.stages.firestarter_1
			},
			{
				stage_id = "nail",
				id = "nail",
				icon = "csm_labrats",
				add = 20,
				level = tweak_data.narrative.stages.nail
			},
			{
				stage_id = "watchdogs_1_d",
				add = 6,
				id = "watchdogs_1_d",
				icon = "csm_watchdogs_1",
				level = tweak_data.narrative.stages.watchdogs_1_d
			},
			{
				stage_id = "pines",
				id = "pines",
				icon = "csm_white_xmas",
				add = 6,
				level = tweak_data.narrative.stages.pines
			},
			{
				stage_id = "moon",
				id = "moon",
				icon = "csm_stealing_xmas",
				add = 10,
				level = tweak_data.narrative.stages.moon
			},
			{
				stage_id = "spa",
				add = 10,
				id = "spa",
				icon = "csm_brooklyn",
				level = tweak_data.narrative.stages.spa
			},
			{
				stage_id = "cane",
				add = 14,
				id = "cane",
				icon = "csm_santas_workshop",
				level = tweak_data.narrative.stages.cane
			},
			{
				stage_id = "mia_2",
				add = 10,
				id = "mia_2",
				icon = "csm_miami_2",
				level = tweak_data.narrative.stages.mia_2
			}
		},
		{
			{
				stage_id = "pbr2",
				add = 10,
				id = "pbr2",
				icon = "csm_sky",
				level = tweak_data.narrative.stages.pbr2
			},
			{
				stage_id = "pal",
				add = 10,
				id = "pal",
				icon = "csm_counterfeit",
				level = tweak_data.narrative.stages.pal
			},
			{
				stage_id = "flat",
				add = 14,
				id = "flat",
				icon = "csm_panic_room",
				level = tweak_data.narrative.stages.flat
			},
			{
				stage_id = "born",
				id = "born",
				icon = "csm_biker_1",
				add = debug_long_add,
				level = tweak_data.narrative.stages.born
			},
			{
				stage_id = "hox_2",
				add = 16,
				id = "hoxton_2",
				icon = "csm_hoxout_2",
				level = tweak_data.narrative.stages.hox_2
			},
			{
				stage_id = "hox_1",
				add = 12,
				id = "hoxton_1",
				icon = "csm_hoxout_1",
				level = tweak_data.narrative.stages.hox_1
			},
			{
				stage_id = "welcome_to_the_jungle_2",
				add = 20,
				id = "bo_2",
				icon = "csm_bigoil_2",
				level = tweak_data.narrative.stages.welcome_to_the_jungle_2
			},
			{
				stage_id = "mia_1",
				add = 10,
				id = "mia_1",
				icon = "csm_miami_1",
				level = tweak_data.narrative.stages.mia_1
			},
			{
				stage_id = "rat",
				add = 10,
				id = "cook_off",
				icon = "csm_rats_1",
				level = tweak_data.narrative.stages.rat
			},
			{
				stage_id = "pbr",
				id = "pbr",
				icon = "csm_mountain",
				add = debug_long_add,
				level = tweak_data.narrative.stages.pbr
			},
			{
				stage_id = "glace",
				add = 12,
				id = "glace",
				icon = "csm_glace",
				level = tweak_data.narrative.stages.glace
			},
			{
				stage_id = "run",
				add = 14,
				id = "run",
				icon = "csm_run",
				level = tweak_data.narrative.stages.run
			},
			{
				stage_id = "man",
				id = "man",
				icon = "csm_undercover",
				add = debug_long_add,
				level = tweak_data.narrative.stages.man
			},
			{
				stage_id = "dinner",
				add = 12,
				id = "dinner",
				icon = "csm_slaughterhouse",
				level = tweak_data.narrative.stages.dinner
			},
			{
				stage_id = "jolly",
				add = 12,
				id = "jolly",
				icon = "csm_aftershock",
				level = tweak_data.narrative.stages.jolly
			}
		}
	}
end
