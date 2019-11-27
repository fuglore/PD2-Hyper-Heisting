GroupAITweakData = GroupAITweakData or class()

function GroupAITweakData:init(tweak_data)
	local difficulty = Global.game_settings and Global.game_settings.difficulty or "normal"
	local difficulty_index = tweak_data:difficulty_to_index(difficulty)

	--print("[GroupAITweakData:init] difficulty", difficulty, "difficulty_index", difficulty_index)

	self.ai_tick_rate =  0.012499990

	self:_read_mission_preset(tweak_data)
	self:_create_table_structure()
	self:_init_task_data(difficulty_index)
	self:_init_chatter_data()
	self:_init_unit_categories(difficulty_index)
	self:_init_enemy_spawn_groups(difficulty_index)
end

function GroupAITweakData:_init_chatter_data()
	self.enemy_chatter = {}
	--[[
		notes:
		radius seems to do nothing no discernable difference between 10 and 90000000000000000000000000000000, game theory how many cops in a radius can say a certain chatter
		max_nr probably how many chatters can go off at once
		duration ??? longer ones i grabbed from v009/pdth
		inerval is cooldown
		group_min seems to be how many cops need to be in a group for the line to play
		queue what call is used in chatter
	]]--
	self.enemy_chatter.aggressive = {
		radius = 2000,
		max_nr = 40,
		duration = {3, 4},
		interval = {1.5, 2},
		group_min = 0,
		queue = "g90"
	}
	self.enemy_chatter.approachingspecial = {
		radius = 4000,
		max_nr = 4,
		duration = {1, 1},
		interval = {6, 10},
		group_min = 0,
		queue = "g90"
	}
	self.enemy_chatter.aggressivecontrolsurprised1 = {
		radius = 2000,
	    max_nr = 4,
	    duration = {0.5, 0.5},
	    interval = {0.75, 1.5},
	    group_min = 0,
	    queue = "lk3b"
	}
	self.enemy_chatter.aggressivecontrolsurprised2 = {
		radius = 2000,
	    max_nr = 4,
	    duration = {0.5, 0.5},
	    interval = {0.75, 1.5},
	    group_min = 0,
	    queue = "hlp"
	}
	self.enemy_chatter.aggressivecontrol = {
		radius = 2000,
	    max_nr = 40,
	    duration = {0.5, 0.5},
	    interval = {1, 2},
	    group_min = 0,
	    queue = "c01"
	}
	self.enemy_chatter.assaultpanic = {
		radius = 2000,
		max_nr = 40,
		duration = {3, 4},
		interval = {3, 6},
		group_min = 0,
		queue = "g90"
	}
	self.enemy_chatter.open_fire = {
		radius = 2000,
		max_nr = 40,
		duration = {2, 4},
		interval = {2, 4},
		group_min = 0,
		queue = "att"
	}		
	self.enemy_chatter.retreat = {
		radius = 2000,
		max_nr = 20,
		duration = {2, 4},
		interval = {0.25, 0.75},
		group_min = 0,
		queue = "m01"
	}		
	self.enemy_chatter.deathguard = { --this isnt actually kill lines those are done in playerdamage
		radius = 2000,
		max_nr = 5,
		duration = {2, 4},
		interval = {0.5, 3},
		group_min = 0,
		queue = "rdy"
	}
	self.enemy_chatter.contact = {
		radius = 2000,
		max_nr = 20,
		duration = {1, 3},
		interval = {4, 6},
		group_min = 0,
		queue = "c01"
	}
	self.enemy_chatter.cloakercontact = {
		radius = 1500,
		max_nr = 4,
		duration = {1, 1},
		interval = {2, 4},
		group_min = 0,
		queue = "c01x_plu"
	}
	self.enemy_chatter.cloakeravoidance = {
		radius = 4000,
		max_nr = 4,
		duration = {1, 1},
		interval = {2, 4},
		group_min = 0,
		queue = "m01x_plu"
	}
	self.enemy_chatter.controlpanic = {
		radius = 2000,
	    max_nr = 1,
	    duration = {60, 60},
	    interval = {2, 2.5},
	    group_min = 3,
	    queue = "g90"
	}
	self.enemy_chatter.clear = {
		radius = 2000,
	    max_nr = 1,
	    duration = {60, 60},
	    interval = {4, 5},
	    group_min = 2,
	    queue = "clr"
	}
	self.enemy_chatter.csalpha = {
		radius = 6000,
	    max_nr = 1,
	    duration = {3, 4},
		interval = {2, 4},
		group_min = 0,
	    queue = "gr2a"
	}
	self.enemy_chatter.csbravo = {
		radius = 6000,
	    max_nr = 1,
	    duration = {3, 4},
		interval = {2, 4},
		group_min = 0,
	    queue = "gr2b"
	}
	self.enemy_chatter.cscharlie = {
		radius = 6000,
	    max_nr = 1,
	    duration = {3, 4},
		interval = {2, 4},
		group_min = 0,
	    queue = "gr2c"
	}
	self.enemy_chatter.csdelta = {
		radius = 6000,
	    max_nr = 1,
	    duration = {3, 4},
		interval = {2, 4},
		group_min = 0,
	    queue = "gr2d"
	}
	self.enemy_chatter.hrtalpha = {
		radius = 6000,
	    max_nr = 1,
	    duration = {3, 4},
		interval = {2, 4},
		group_min = 0,
	    queue = "gr1a"
	}
	self.enemy_chatter.hrtbravo = {
		radius = 6000,
	    max_nr = 1,
	    duration = {3, 4},
		interval = {2, 4},
		group_min = 0,
	    queue = "gr1b"
	}
	self.enemy_chatter.hrtcharlie = {
		radius = 6000,
	    max_nr = 1,
	    duration = {3, 4},
		interval = {2, 4},
		group_min = 0,
	    queue = "gr1c"
	}
	self.enemy_chatter.hrtdelta = {
		radius = 6000,
	    max_nr = 1,
	    duration = {3, 4},
		interval = {2, 4},
		group_min = 0,
	    queue = "gr1d"
	}
	self.enemy_chatter.dodge = {
		radius = 2000,
	    max_nr = 1,
	    duration = {0.5, 0.5},
	    interval = {0.75, 1.5},
	    group_min = 0,
	    queue = "lk3b"
	}
	self.enemy_chatter.clear_whisper = {
		radius = 2000,
		max_nr = 1,
		duration = {60, 60},
		interval = {10, 20},
		group_min = 0,
		queue = "a05"
	}
	self.enemy_chatter.go_go = {
		radius = 2000,
		max_nr = 40,
		duration = {2, 2},
		interval = {3, 6},
		group_min = 0,
		queue = "mov"
	}
	self.enemy_chatter.push = {
		radius = 2000,
		max_nr = 40,
		duration = {2, 4},
		interval = {3, 6},
		group_min = 0,
		queue = "pus"
	}
	self.enemy_chatter.reload = {
		radius = 2000,
		max_nr = 40,
		duration = {2, 4},
		interval = {2, 5},
		group_min = 2,
		queue = "rrl"
	}
	self.enemy_chatter.look_for_angle = {
		radius = 2000,
		max_nr = 40,
		duration = {2, 4},
		interval = {2, 3},
		group_min = 0,
		queue = "t01"
	}
	self.enemy_chatter.ready = {
		radius = 2000,
		max_nr = 16,
		duration = {2, 4},
		interval = {1, 3.5},
		group_min = 1,
		queue = "rdy"
	}
	self.enemy_chatter.affirmative = {
		radius = 2000,
		max_nr = 8,
		duration = {2, 4},
		interval = {0.75, 1.5},
		group_min = 2,
		queue = "r01"
	}
	self.enemy_chatter.inpos = {
		radius = 2000,
		max_nr = 16,
		duration = {2, 4},
		interval = {0.75, 1.5},
		group_min = 0,
		queue = "pos"
	}
	self.enemy_chatter.smoke = {
		radius = 1000,
		max_nr = 3,
	    duration = {2, 2},
		interval = {0.1, 0.1},
		group_min = 0,
		queue = "d01"
	}
	self.enemy_chatter.flash_grenade = {
		radius = 1000,
		max_nr = 3,
		duration = {2, 2},
	    interval = {0.1, 0.1},
		group_min = 0,
		queue = "d02"
	}
	self.enemy_chatter.ecm = {
		radius = 1000,
		max_nr = 20,
		duration = {2, 4},
		interval = {0.75, 1.5},
		group_min = 0,
		queue = "ch3"
	}
	self.enemy_chatter.saw = {
		radius = 2000,
		max_nr = 10,
		duration = {2, 4},
		interval = {4, 10},
		group_min = 0,
		queue = "ch4"
	}
	self.enemy_chatter.trip_mines = {
		radius = 2000,
		max_nr = 10,
		duration = {2, 4},
		interval = {0.75, 1.5},
		group_min = 0,
		queue = "ch1"
	}
	self.enemy_chatter.sentry = {
		radius = 2000,
		max_nr = 10,
		duration = {2, 4},
		interval = {4, 10},
		group_min = 0,
		queue = "ch2"
	}
	self.enemy_chatter.incomming_tank = {
		radius = 1500,
		max_nr = 0,
		duration = {10, 10},
		interval = {0.5, 1},
		group_min = 0,
		queue = "bdz"
	}
	self.enemy_chatter.incomming_spooc = {
		radius = 1200,
		max_nr = 0,
		duration = {10, 10},
		interval = {0.5, 1},
		group_min = 0,
		queue = "clk"
	}
	self.enemy_chatter.incomming_shield = {
		radius = 1500,
		max_nr = 0,
		duration = {10, 10},
		interval = {0.5, 1},
		group_min = 0,
		queue = "shd"
	}
	self.enemy_chatter.incomming_taser = {
		radius = 1500,
		max_nr = 0,
		duration = {60, 60},
		interval = {0.5, 1},
		group_min = 0,
		queue = "tsr"
	}
end

Hooks:PostHook(GroupAITweakData, "_init_unit_categories", "cock_init_unit_categories", function(self, difficulty_index)
	local access_type_walk_only = {
		walk = true
	}
	local access_type_all = {
		acrobatic = true,
		walk = true
	}
	if Global.game_settings and Global.game_settings.use_intense_AI then -- spicy
		self.special_unit_spawn_limits = {
			shield = 8,
			medic = 8,
			taser = 3,
			tank = 1,
			spooc = 3
		}
	elseif difficulty_index <= 2 then
		self.special_unit_spawn_limits = { --start normal with the idea that specials can and will inconvenience the player in any way possible if not taken care of, two tasers.
			shield = 4,
			medic = 0,
			taser = 2,
			tank = 0,
			spooc = 0
		}
	elseif difficulty_index == 3 then
		self.special_unit_spawn_limits = { --hard escalates this, enables medics to keep tasers alive, adds a rare occasional dozer
			shield = 4,
			medic = 3,
			taser = 2,
			tank = 1,
			spooc = 0
		}
	elseif difficulty_index == 4 then
		self.special_unit_spawn_limits = { --very hard enables satan himself to come visit you, increases max medics and shields
			shield = 6,
			medic = 4,
			taser = 2,
			tank = 1,
			spooc = 1
		}
	elseif difficulty_index == 5 then
		self.special_unit_spawn_limits = { --overkill enables two spoocs, adds another taser, escalate the game meaningfully every difficulty by increasing complexity
			shield = 6,
			medic = 4,
			taser = 3,
			tank = 1,
			spooc = 2
		}
	elseif difficulty_index == 6 then
		self.special_unit_spawn_limits = { --begin coordinated spawngroups to heighten gameplay complexity, start pushing the boundaries, no big special limit change here outside of the cloakers, medics and shields, its fine though
			shield = 8,
			medic = 6,
			taser = 3,
			tank = 1,
			spooc = 3
		}
	elseif difficulty_index == 7 then
		self.special_unit_spawn_limits = { --setting medic limit to six allows for survivability within common enemy spawngroups since special enemies are now paired commonly with medics to keep them alive consistently
			shield = 8,
			medic = 6,
			taser = 3,
			tank = 1,
			spooc = 3
		}
	elseif difficulty_index == 8 then
		self.special_unit_spawn_limits = { --game reaches boiling point, 2 dozers, 4-5 tasers, 8-10 medics, 3-4 cloakers and 8-10 shields.
			shield = 8,
			medic = 8,
			taser = 3,
			tank = 1,
			spooc = 3
		}
	else
		self.special_unit_spawn_limits = {
			shield = 8,
			medic = 8,
			taser = 3,
			tank = 1,
			spooc = 3
		}
	end

	self.unit_categories = {}

	if difficulty_index == 8 then
		self.unit_categories.spooc = {
			special_type = "spooc",
			unit_types = {
				america = {
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_cloaker/ene_zeal_cloaker")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_spooc_asval_smg/ene_akan_fbi_spooc_asval_smg")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_spook_hvh_1/ene_spook_hvh_1")
				},
				murkywater = {
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_cloaker/ene_murkywater_cloaker")
				},
				shared = {
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_cloaker/ene_murkywater_cloaker"),
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_cloaker/ene_zeal_cloaker")
				}
			},
			access = access_type_all
		}
	else
		self.unit_categories.spooc = {
			special_type = "spooc",
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_spook_1/ene_spook_1")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_spooc_asval_smg/ene_akan_fbi_spooc_asval_smg")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_spook_hvh_1/ene_spook_hvh_1")
				},
				murkywater = {
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_cloaker/ene_murkywater_cloaker")
				},
				shared = {
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_cloaker/ene_murkywater_cloaker"),
					Idstring("units/payday2/characters/ene_spook_1/ene_spook_1")
				}
			},
			access = access_type_all
		}
	end
	
	if difficulty_index <= 3 then
		self.unit_categories.punk_group = {
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_cop_3/ene_cop_3"),
					Idstring("units/payday2/characters/ene_cop_2/ene_cop_2"),
					Idstring("units/payday2/characters/ene_cop_4/ene_cop_4")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_r870/ene_akan_cs_cop_r870"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_akmsu_smg/ene_akan_cs_cop_akmsu_smg"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_ak47_ass/ene_akan_cs_cop_ak47_ass")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_1/ene_cop_hvh_1"),
					Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_3/ene_cop_hvh_3"),
					Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_4/ene_cop_hvh_4")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_punk_moss/ene_murky_punk_moss"),
					Idstring("units/payday2/characters/ene_cop_1/ene_cop_1"),
					Idstring("units/payday2/characters/ene_cop_4/ene_cop_4")
				}
			},
			access = access_type_walk_only
		}
	elseif difficulty_index == 4 or difficulty_index == 5 then
		self.unit_categories.punk_group = {
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_cop_3/ene_cop_3"),
					Idstring("units/payday2/characters/ene_cop_2/ene_cop_2"),
					Idstring("units/payday2/characters/ene_cop_4/ene_cop_4")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_r870/ene_akan_cs_cop_r870"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_akmsu_smg/ene_akan_cs_cop_akmsu_smg"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_ak47_ass/ene_akan_cs_cop_ak47_ass")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_1/ene_cop_hvh_1"),
					Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_3/ene_cop_hvh_3"),
					Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_4/ene_cop_hvh_4")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_punk_moss/ene_murky_punk_moss"),
					Idstring("units/payday2/characters/ene_cop_2/ene_cop_2"),
					Idstring("units/payday2/characters/ene_cop_4/ene_cop_4")
				}
			},
			access = access_type_walk_only
		}
		
	elseif difficulty_index == 6 or difficulty_index == 7 then
		self.unit_categories.punk_group = {
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_cop_3/ene_cop_3"),
					Idstring("units/payday2/characters/ene_cop_2/ene_cop_2"),
					Idstring("units/payday2/characters/ene_cop_4/ene_cop_4")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_r870/ene_akan_cs_cop_r870"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_akmsu_smg/ene_akan_cs_cop_akmsu_smg"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_ak47_ass/ene_akan_cs_cop_ak47_ass")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_1/ene_cop_hvh_1"),
					Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_3/ene_cop_hvh_3"),
					Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_4/ene_cop_hvh_4")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_punk_moss/ene_murky_punk_moss"),
					Idstring("units/payday2/characters/ene_cop_1/ene_cop_1"),
					Idstring("units/payday2/characters/ene_cop_4/ene_cop_4")
				}
			},
			access = access_type_walk_only
		}
	else
		self.unit_categories.punk_group = {
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_cop_3/ene_cop_3"),
					Idstring("units/payday2/characters/ene_cop_2/ene_cop_2"),
					Idstring("units/payday2/characters/ene_cop_4/ene_cop_4")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_r870/ene_akan_cs_cop_r870"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_akmsu_smg/ene_akan_cs_cop_akmsu_smg"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_ak47_ass/ene_akan_cs_cop_ak47_ass")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_1/ene_cop_hvh_1"),
					Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_3/ene_cop_hvh_3"),
					Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_4/ene_cop_hvh_4")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_punk_moss/ene_murky_punk_moss"),
					Idstring("units/payday2/characters/ene_cop_1/ene_cop_1"),
					Idstring("units/payday2/characters/ene_cop_4/ene_cop_4")
				}
			},
			access = access_type_walk_only
		}
	end
	
	if difficulty_index < 6 then
		self.unit_categories.FBI_LHmix = {
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_fbi_swat_1/ene_fbi_swat_1"),
					Idstring("units/payday2/characters/ene_fbi_heavy_1/ene_fbi_heavy_1"),
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_ak47_ass/ene_akan_fbi_swat_ak47_ass"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_g36/ene_akan_fbi_heavy_g36")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_1/ene_fbi_swat_hvh_1"),
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_1/ene_fbi_heavy_hvh_1")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_scar/ene_murky_heavy_scar")
				},
				shared = {
					Idstring("units/payday2/characters/ene_fbi_swat_1/ene_fbi_swat_1"),
					Idstring("units/payday2/characters/ene_fbi_swat_1/ene_fbi_swat_1"),
					Idstring("units/payday2/characters/ene_fbi_3/ene_fbi_3"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_ump/ene_murky_light_ump")
				}
			},
			access = access_type_all
		}
	elseif difficulty_index == 6 then
		self.unit_categories.FBI_LHmix = {
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_fbi_swat_1/ene_fbi_swat_1"),
					Idstring("units/payday2/characters/ene_city_swat_1/ene_city_swat_1"),
					Idstring("units/payday2/characters/ene_fbi_heavy_1/ene_fbi_heavy_1"),				
					Idstring("units/payday2/characters/ene_city_heavy_g36/ene_city_heavy_g36")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_dw_ak47_ass/ene_akan_fbi_swat_dw_ak47_ass"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_g36/ene_akan_fbi_heavy_g36")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_1/ene_fbi_swat_hvh_1"),
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_1/ene_fbi_heavy_hvh_1")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_scar/ene_murky_heavy_scar")
				},
				shared = {
					Idstring("units/payday2/characters/ene_city_swat_1/ene_city_swat_1"),					
					Idstring("units/payday2/characters/ene_city_swat_1/ene_city_swat_1"),
					Idstring("units/payday2/characters/ene_city_swat_3/ene_city_swat_3"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_ump/ene_murky_light_ump")
				}
			},
			access = access_type_all
		}		
	elseif difficulty_index == 7 then
		self.unit_categories.FBI_LHmix = {
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_city_swat_1/ene_city_swat_1"),
					Idstring("units/payday2/characters/ene_city_heavy_g36/ene_city_heavy_g36")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_dw_ak47_ass/ene_akan_fbi_swat_dw_ak47_ass"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_g36/ene_akan_fbi_heavy_g36")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_1/ene_fbi_swat_hvh_1"),
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_1/ene_fbi_heavy_hvh_1")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_scar/ene_murky_heavy_scar")
				},
				shared = {
					Idstring("units/payday2/characters/ene_city_swat_1/ene_city_swat_1"),					
					Idstring("units/payday2/characters/ene_city_swat_1/ene_city_swat_1"),
					Idstring("units/payday2/characters/ene_city_swat_3/ene_city_swat_3"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_ump/ene_murky_light_ump")
				}
			},
			access = access_type_all
		}
	else
		self.unit_categories.FBI_LHmix = {
			unit_types = {
				america = {
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_city_1/ene_zeal_city_1"),
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy_hh/ene_zeal_swat_heavy_hh")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_dw_ak47_ass/ene_akan_fbi_swat_dw_ak47_ass"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_g36/ene_akan_fbi_heavy_g36")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_1/ene_fbi_swat_hvh_1"),
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_1/ene_fbi_heavy_hvh_1")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_scar/ene_murky_heavy_scar")
				},
				shared = {
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_city_1/ene_zeal_city_1"),
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_city_1/ene_zeal_city_1"),
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_city_3/ene_zeal_city_3"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_ump/ene_murky_light_ump")
				}
			},
			access = access_type_all
		}
	end
	
	self.unit_categories.CS_cop_C45_R870 = {
		unit_types = {
			america = {
				Idstring("units/payday2/characters/ene_cop_1/ene_cop_1"),
				Idstring("units/payday2/characters/ene_cop_3/ene_cop_3"),
				Idstring("units/payday2/characters/ene_cop_4/ene_cop_4")
			},
			russia = {
				Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_r870/ene_akan_cs_cop_r870"),
				Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_akmsu_smg/ene_akan_cs_cop_akmsu_smg"),
				Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_ak47_ass/ene_akan_cs_cop_ak47_ass")
			},
			zombie = {
				Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_1/ene_cop_hvh_1"),
				Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_3/ene_cop_hvh_3"),
				Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_4/ene_cop_hvh_4")
			},
			murkywater = {
				Idstring("units/pd2_dlc_bph/characters/ene_murkywater_light_r870/ene_murkywater_light_r870")
			}
		},
		access = access_type_walk_only
	}
	self.unit_categories.CS_cop_stealth_MP5 = {
		unit_types = {
			america = {
				Idstring("units/payday2/characters/ene_cop_2/ene_cop_2")
			},
			russia = {
				Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_akmsu_smg/ene_akan_cs_cop_akmsu_smg")
			},
			zombie = {
				Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_2/ene_cop_hvh_2")
			},
			murkywater = {
				Idstring("units/pd2_dlc_bph/characters/ene_murkywater_light/ene_murkywater_light")
			}
		},
		access = access_type_walk_only
	}

	if difficulty_index == 8 then
		self.unit_categories.CS_swat_MP5 = {
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_swat_1/ene_swat_1")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_swat_ak47_ass/ene_akan_cs_swat_ak47_ass")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_swat_hvh_1/ene_swat_hvh_1")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_ump/ene_murky_light_ump")
				},
				shared = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_ump/ene_murky_light_ump"),
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_city_1/ene_zeal_city_1"),
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_city_1/ene_zeal_city_1"),
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_city_3/ene_zeal_city_3")
				}
			},
			access = access_type_all
		}
		self.unit_categories.CS_swat_R870 = {
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_swat_2/ene_swat_2")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_swat_r870/ene_akan_cs_swat_r870")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_swat_hvh_2/ene_swat_hvh_2")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_r870/ene_murky_light_r870")
				}
			},
			access = access_type_all
		}
	else
		self.unit_categories.CS_swat_MP5 = {
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_swat_1/ene_swat_1"),
					Idstring("units/payday2/characters/ene_swat_1/ene_swat_1"),
					Idstring("units/payday2/characters/ene_cop_5/ene_cop_5")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_swat_ak47_ass/ene_akan_cs_swat_ak47_ass"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_swat_ak47_ass/ene_akan_cs_swat_ak47_ass"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_hyper_swat_akmsu_smg/ene_akan_hyper_swat_akmsu_smg")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_swat_hvh_1/ene_swat_hvh_1"),
					Idstring("units/pd2_dlc_hvh/characters/ene_swat_hvh_1/ene_swat_hvh_1"),
					Idstring("units/payday2/characters/ene_cop_5/ene_cop_5")				
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_ump/ene_murky_light_ump")
				},
				shared = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_ump/ene_murky_light_ump"),
					Idstring("units/payday2/characters/ene_swat_1/ene_swat_1"),
					Idstring("units/payday2/characters/ene_swat_1/ene_swat_1"),
					Idstring("units/payday2/characters/ene_cop_3/ene_cop_5"),
				}	
			},
			access = access_type_all
		}
		self.unit_categories.CS_swat_R870 = {
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_swat_2/ene_swat_2")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_swat_r870/ene_akan_cs_swat_r870")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_swat_hvh_2/ene_swat_hvh_2")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_r870/ene_murky_light_r870")
				},
				shared = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_r870/ene_murky_light_r870"),
					Idstring("units/payday2/characters/ene_swat_2/ene_swat_2")
				}
			},
			access = access_type_all
		}
	end

	if difficulty_index == 8 then
		self.unit_categories.CS_heavy_M4 = {
			unit_types = {
				america = {
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy/ene_zeal_swat_heavy")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_heavy_ak47_ass/ene_akan_cs_heavy_ak47_ass")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_swat_heavy_hvh_1/ene_swat_heavy_hvh_1")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_NH_rifle/ene_murky_NH_rifle")
				}
			},
			access = access_type_all
		}
		self.unit_categories.CS_heavy_R870 = {
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_city_heavy_r870/ene_city_heavy_r870")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_heavy_r870/ene_akan_cs_heavy_r870")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_swat_heavy_hvh_r870/ene_swat_heavy_hvh_r870")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_NH_r870/ene_murky_NH_r870")
				}
			},
			access = access_type_all
		}
		self.unit_categories.CS_heavy_M4_w = {
			unit_types = {
				america = {
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy/ene_zeal_swat_heavy")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_heavy_ak47_ass/ene_akan_cs_heavy_ak47_ass")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_swat_heavy_hvh_1/ene_swat_heavy_hvh_1")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_NH_rifle/ene_murky_NH_rifle")
				}
			},
			access = access_type_walk_only
		}
	else
		self.unit_categories.CS_heavy_M4 = {
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_swat_heavy_1/ene_swat_heavy_1")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_heavy_ak47_ass/ene_akan_cs_heavy_ak47_ass")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_swat_heavy_hvh_1/ene_swat_heavy_hvh_1")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_NH_rifle/ene_murky_NH_rifle")
				},
				shared = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_NH_rifle/ene_murky_NH_rifle"),
					Idstring("units/payday2/characters/ene_swat_heavy_1/ene_swat_heavy_1")
				}
			},
			access = access_type_all
		}
		self.unit_categories.CS_heavy_R870 = {
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_swat_heavy_r870/ene_swat_heavy_r870")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_heavy_r870/ene_akan_cs_heavy_r870")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_swat_heavy_hvh_r870/ene_swat_heavy_hvh_r870")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_NH_r870/ene_murky_NH_r870")
				},
				shared = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_NH_r870/ene_murky_NH_r870"),
					Idstring("units/payday2/characters/ene_swat_heavy_r870/ene_swat_heavy_r870")
				}
			},
			access = access_type_all
		}
		self.unit_categories.CS_heavy_M4_w = {
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_swat_heavy_1/ene_swat_heavy_1")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_heavy_ak47_ass/ene_akan_cs_heavy_ak47_ass")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_swat_heavy_hvh_1/ene_swat_heavy_hvh_1")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_NH_rifle/ene_murky_NH_rifle")
				},
				shared = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_NH_rifle/ene_murky_NH_rifle"),
					Idstring("units/payday2/characters/ene_swat_heavy_1/ene_swat_heavy_1")
				}
			},
			access = access_type_walk_only
		}
	end

	if difficulty_index == 8 then
		self.unit_categories.CS_tazer = {
			special_type = "taser",
			unit_types = {
				america = {
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_tazer_hh/ene_zeal_tazer_hh")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_tazer_ak47_ass/ene_akan_cs_tazer_ak47_ass")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_tazer_hvh_1/ene_tazer_hvh_1")
				},
				murkywater = {
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_tazer/ene_murkywater_tazer")
				},
				shared = {
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_tazer_hh/ene_zeal_tazer_hh"),
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_tazer/ene_murkywater_tazer")
				}
			},
			access = access_type_all
		}
	else
		self.unit_categories.CS_tazer = {
			special_type = "taser",
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_tazer_1/ene_tazer_1")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_tazer_ak47_ass/ene_akan_cs_tazer_ak47_ass")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_tazer_hvh_1/ene_tazer_hvh_1")
				},
				murkywater = {
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_tazer/ene_murkywater_tazer")
				},
				shared = {
					Idstring("units/payday2/characters/ene_tazer_1/ene_tazer_1"),
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_tazer/ene_murkywater_tazer")
				}
			},
			access = access_type_all
		}
	end

	if difficulty_index == 8 then
		self.unit_categories.CS_shield = {
			special_type = "shield",
			unit_types = {
				america = {
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_swat_shield_hh/ene_zeal_swat_shield_hh")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_shield_c45/ene_akan_cs_shield_c45")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_shield_hvh_2/ene_shield_hvh_2")
				},
				murkywater = {
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_shield/ene_murkywater_shield")
				},
				shared = {
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_shield/ene_murkywater_shield")
				}
			},
			access = access_type_walk_only
		}
	else
		self.unit_categories.CS_shield = {
			special_type = "shield",
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_shield_2/ene_shield_2")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_shield_c45/ene_akan_cs_shield_c45")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_shield_hvh_2/ene_shield_hvh_2")
				},
				murkywater = {
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_shield/ene_murkywater_shield")
				},
				shared = {
					Idstring("units/payday2/characters/ene_shield_2/ene_shield_2"),
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_shield/ene_murkywater_shield")
				}
			},
			access = access_type_walk_only
		}
	end

	self.unit_categories.FBI_suit_C45_M4 = {
		unit_types = {
			america = {
				Idstring("units/payday2/characters/ene_fbi_1/ene_fbi_1"),
				Idstring("units/payday2/characters/ene_fbi_2/ene_fbi_2")
			},
			russia = {
				Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_ak47_ass/ene_akan_cs_cop_ak47_ass"),
				Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_ak47_ass/ene_akan_cs_cop_ak47_ass")
			},
			zombie = {
				Idstring("units/pd2_dlc_hvh/characters/ene_fbi_hvh_1/ene_fbi_hvh_1"),
				Idstring("units/pd2_dlc_hvh/characters/ene_fbi_hvh_2/ene_fbi_hvh_2")
			},
			murkywater = {
				Idstring("units/pd2_dlc_bph/characters/ene_murkywater_light_fbi/ene_murkywater_light_fbi")
			}
		},
		access = access_type_all
	}
	
	if difficulty_index < 6 then
		self.unit_categories.FBI_suit_M4_MP5 = {
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_fbi_1/ene_fbi_1"),
					Idstring("units/payday2/characters/ene_fbi_2/ene_fbi_2"),
					Idstring("units/payday2/characters/ene_fbi_3/ene_fbi_3")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_hyper_fbi_akmsu_smg/ene_akan_hyper_fbi_akmsu_smg"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_hyper_fbininja_ak47_ass/ene_akan_hyper_fbininja_ak47_ass"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_hyper_fbininja_c45/ene_akan_hyper_fbininja_c45")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_hvh_1/ene_fbi_hvh_1"),
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_hvh_2/ene_fbi_hvh_2"),
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_hvh_3/ene_fbi_hvh_3")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_fbigod_c45/ene_murky_fbigod_c45"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_fbigod_m4/ene_murky_fbigod_m4"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_ump/ene_murky_light_ump")
				},
				shared = {
					Idstring("units/payday2/characters/ene_fbi_1/ene_fbi_1"),
					Idstring("units/payday2/characters/ene_fbi_2/ene_fbi_2"),
					Idstring("units/payday2/characters/ene_fbi_3/ene_fbi_3"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_fbigod_c45/ene_murky_fbigod_c45"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_fbigod_m4/ene_murky_fbigod_m4"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_ump/ene_murky_light_ump")
				}
			},
			access = access_type_all
		}
	elseif difficulty_index == 6 or difficulty_index == 7 then
		self.unit_categories.FBI_suit_M4_MP5 = {
			unit_types = {
				america = {
					Idstring("units/pd2_mod_ftsu/characters/ene_gensec_fbigod_c45/ene_gensec_fbigod_c45"),
					Idstring("units/pd2_mod_ftsu/characters/ene_gensec_fbigod_m4/ene_gensec_fbigod_m4"),
					Idstring("units/payday2/characters/ene_fbi_3/ene_fbi_3")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_hyper_fbi_akmsu_smg/ene_akan_hyper_fbi_akmsu_smg"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_hyper_fbininja_ak47_ass/ene_akan_hyper_fbininja_ak47_ass"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_hyper_fbininja_c45/ene_akan_hyper_fbininja_c45")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_hvh_1/ene_fbi_hvh_1"),
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_hvh_2/ene_fbi_hvh_2"),
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_hvh_3/ene_fbi_hvh_3")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_fbigod_c45/ene_murky_fbigod_c45"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_fbigod_m4/ene_murky_fbigod_m4"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_ump/ene_murky_light_ump")
				},
				shared = {
					Idstring("units/payday2/characters/ene_fbi_1/ene_fbi_1"),
					Idstring("units/payday2/characters/ene_fbi_2/ene_fbi_2"),
					Idstring("units/payday2/characters/ene_fbi_3/ene_fbi_3"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_fbigod_c45/ene_murky_fbigod_c45"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_fbigod_m4/ene_murky_fbigod_m4"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_ump/ene_murky_light_ump")
				}
			},
			access = access_type_all
		}
	else
		self.unit_categories.FBI_suit_M4_MP5 = {
			unit_types = {
				america = {
					Idstring("units/pd2_dlc_gitgud/characters/ene_fbigod_m4/ene_fbigod_m4"),
					Idstring("units/payday2/characters/ene_fbi_1/ene_fbi_1")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_hyper_fbininja_ak47_ass/ene_akan_hyper_fbininja_ak47_ass"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_hyper_fbininja_c45/ene_akan_hyper_fbininja_c45")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_hvh_1/ene_fbi_hvh_1"),
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_hvh_2/ene_fbi_hvh_2")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_fbigod_c45/ene_murky_fbigod_c45"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_fbigod_m4/ene_murky_fbigod_m4")
				},
				shared = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_fbigod_c45/ene_murky_fbigod_c45"),
					Idstring("units/pd2_dlc_gitgud/characters/ene_fbigod_m4/ene_fbigod_m4")
				}
			},
			access = access_type_all
		}
	end
	
	self.unit_categories.FBI_suit_stealth_MP5 = {
		unit_types = {
			america = {
				Idstring("units/payday2/characters/ene_fbi_3/ene_fbi_3")
			},
			russia = {
				Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_asval_smg/ene_akan_cs_cop_asval_smg")
			},
			zombie = {
				Idstring("units/pd2_dlc_hvh/characters/ene_fbi_hvh_3/ene_fbi_hvh_3")
			},
			murkywater = {
				Idstring("units/pd2_mod_psc/characters/ene_murky_light_ump/ene_murky_light_ump")
			}
		},
		access = access_type_all
	}

	if difficulty_index < 6 then
		self.unit_categories.FBI_swat_M4 = {
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_fbi_swat_1/ene_fbi_swat_1"),
					Idstring("units/payday2/characters/ene_fbi_swat_1/ene_fbi_swat_1"),
					Idstring("units/payday2/characters/ene_fbi_3/ene_fbi_3")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_ak47_ass/ene_akan_fbi_swat_ak47_ass"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_ak47_ass/ene_akan_fbi_swat_ak47_ass"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_hyper_fbi_akmsu_smg/ene_akan_hyper_fbi_akmsu_smg")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_1/ene_fbi_swat_hvh_1"),
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_1/ene_fbi_swat_hvh_1"),
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_hvh_3/ene_fbi_hvh_3")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_ump/ene_murky_light_ump")
				},
				shared = {
					Idstring("units/payday2/characters/ene_fbi_swat_1/ene_fbi_swat_1"),
					Idstring("units/payday2/characters/ene_fbi_swat_1/ene_fbi_swat_1"),
					Idstring("units/payday2/characters/ene_fbi_3/ene_fbi_3"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_ump/ene_murky_light_ump")
				}
			},
			access = access_type_all
		}
	elseif difficulty_index == 6 then
		self.unit_categories.FBI_swat_M4 = {
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_fbi_swat_1/ene_fbi_swat_1"),
					Idstring("units/payday2/characters/ene_fbi_swat_1/ene_fbi_swat_1"),
					Idstring("units/payday2/characters/ene_city_swat_1/ene_city_swat_1"),					
					Idstring("units/payday2/characters/ene_city_swat_1/ene_city_swat_1"),
					Idstring("units/payday2/characters/ene_city_swat_3/ene_city_swat_3"),
					Idstring("units/payday2/characters/ene_city_swat_3/ene_city_swat_3")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_dw_ak47_ass/ene_akan_fbi_swat_dw_ak47_ass"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_dw_ak47_ass/ene_akan_fbi_swat_dw_ak47_ass"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_hyper_fbi_akmsu_smg/ene_akan_hyper_fbi_akmsu_smg")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_1/ene_fbi_swat_hvh_1"),
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_1/ene_fbi_swat_hvh_1"),
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_hvh_3/ene_fbi_hvh_3")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_ump/ene_murky_light_ump")
				},
				shared = {
					Idstring("units/payday2/characters/ene_city_swat_1/ene_city_swat_1"),					
					Idstring("units/payday2/characters/ene_city_swat_1/ene_city_swat_1"),
					Idstring("units/payday2/characters/ene_city_swat_3/ene_city_swat_3"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_ump/ene_murky_light_ump")
				}
			},
			access = access_type_all
		}		
	elseif difficulty_index == 7 then
		self.unit_categories.FBI_swat_M4 = {
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_city_swat_1/ene_city_swat_1"),
					Idstring("units/payday2/characters/ene_city_swat_1/ene_city_swat_1"),
					Idstring("units/payday2/characters/ene_city_swat_3/ene_city_swat_3")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_dw_ak47_ass/ene_akan_fbi_swat_dw_ak47_ass"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_dw_ak47_ass/ene_akan_fbi_swat_dw_ak47_ass"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_hyper_fbi_akmsu_smg/ene_akan_hyper_fbi_akmsu_smg")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_1/ene_fbi_swat_hvh_1"),
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_1/ene_fbi_swat_hvh_1"),
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_hvh_3/ene_fbi_hvh_3")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_ump/ene_murky_light_ump")
				},
				shared = {
					Idstring("units/payday2/characters/ene_city_swat_1/ene_city_swat_1"),					
					Idstring("units/payday2/characters/ene_city_swat_1/ene_city_swat_1"),
					Idstring("units/payday2/characters/ene_city_swat_3/ene_city_swat_3"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_ump/ene_murky_light_ump")
				}
			},
			access = access_type_all
		}
	else
		self.unit_categories.FBI_swat_M4 = {
			unit_types = {
				america = {
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_city_1/ene_zeal_city_1"),
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_city_1/ene_zeal_city_1"),
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_city_3/ene_zeal_city_3")					
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_dw_ak47_ass/ene_akan_fbi_swat_dw_ak47_ass"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_dw_ak47_ass/ene_akan_fbi_swat_dw_ak47_ass"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_hyper_fbi_akmsu_smg/ene_akan_hyper_fbi_akmsu_smg")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_1/ene_fbi_swat_hvh_1"),
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_1/ene_fbi_swat_hvh_1"),
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_hvh_3/ene_fbi_hvh_3")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_ump/ene_murky_light_ump")
				},
				shared = {
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_city_1/ene_zeal_city_1"),
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_city_1/ene_zeal_city_1"),
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_city_3/ene_zeal_city_3"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_ump/ene_murky_light_ump")
				}
			},
			access = access_type_all
		}
	end

	if difficulty_index < 6 then
		self.unit_categories.FBI_swat_R870 = {
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_fbi_swat_2/ene_fbi_swat_2"),
					Idstring("units/payday2/characters/ene_fbi_swat_2/ene_fbi_swat_2") -- set up for crime spree
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_r870/ene_akan_fbi_swat_r870")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_2/ene_fbi_swat_hvh_2")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_r870/ene_murky_light_r870"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_r870/ene_murky_light_r870")
				},
				shared = {
					Idstring("units/payday2/characters/ene_fbi_swat_2/ene_fbi_swat_2"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_r870/ene_murky_light_r870")
				}
			},
			access = access_type_all
		}
	elseif difficulty_index == 6 then
		self.unit_categories.FBI_swat_R870 = {
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_fbi_swat_2/ene_fbi_swat_2"),
					Idstring("units/payday2/characters/ene_fbi_swat_2/ene_fbi_swat_2"),					
					Idstring("units/payday2/characters/ene_city_swat_2/ene_city_swat_2")		
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_r870/ene_akan_fbi_swat_r870"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_r870/ene_akan_fbi_swat_r870"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_dw_r870/ene_akan_fbi_swat_dw_r870"),					
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_2/ene_fbi_swat_hvh_2")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_r870/ene_murky_light_r870")
				},
				shared = {
					Idstring("units/payday2/characters/ene_city_swat_2/ene_city_swat_2"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_r870/ene_murky_light_r870")
				}
			},
			access = access_type_all
		}		
	elseif difficulty_index == 7 then
		self.unit_categories.FBI_swat_R870 = {
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_city_swat_2/ene_city_swat_2")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_dw_r870/ene_akan_fbi_swat_dw_r870")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_2/ene_fbi_swat_hvh_2")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_r870/ene_murky_light_r870")
				},
				shared = {
					Idstring("units/payday2/characters/ene_city_swat_2/ene_city_swat_2"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_r870/ene_murky_light_r870")
				}
			},
			access = access_type_all
		}
	else
		self.unit_categories.FBI_swat_R870 = {
			unit_types = {
				america = {
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_city_2/ene_zeal_city_2")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_dw_r870/ene_akan_fbi_swat_dw_r870")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_2/ene_fbi_swat_hvh_2")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_r870/ene_murky_light_r870")
				},
				shared = {
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_city_2/ene_zeal_city_2"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_r870/ene_murky_light_r870")
				}
			},
			access = access_type_all
		}
	end

	if difficulty_index < 6 then
		self.unit_categories.FBI_heavy_G36 = {
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_fbi_heavy_1/ene_fbi_heavy_1")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_g36/ene_akan_fbi_heavy_g36")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_1/ene_fbi_heavy_hvh_1")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_scar/ene_murky_heavy_scar")
				},
				shared = {
					Idstring("units/payday2/characters/ene_fbi_heavy_1/ene_fbi_heavy_1"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_scar/ene_murky_heavy_scar")
				}
			},
			access = access_type_all
		}
	elseif difficulty_index == 6 then
		self.unit_categories.FBI_heavy_G36 = {
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_fbi_heavy_1/ene_fbi_heavy_1"),
					Idstring("units/payday2/characters/ene_fbi_heavy_1/ene_fbi_heavy_1"),				
					Idstring("units/payday2/characters/ene_city_heavy_g36/ene_city_heavy_g36")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_g36/ene_akan_fbi_heavy_g36")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_1/ene_fbi_heavy_hvh_1")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_scar/ene_murky_heavy_scar")
				},
				shared = {
					Idstring("units/payday2/characters/ene_city_heavy_g36/ene_city_heavy_g36"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_scar/ene_murky_heavy_scar")
				}
			},
			access = access_type_all
		}
	elseif difficulty_index == 7 then
		self.unit_categories.FBI_heavy_G36 = {
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_city_heavy_g36/ene_city_heavy_g36")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_g36/ene_akan_fbi_heavy_g36")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_1/ene_fbi_heavy_hvh_1")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_scar/ene_murky_heavy_scar")
				},
				shared = {
					Idstring("units/payday2/characters/ene_city_heavy_g36/ene_city_heavy_g36"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_scar/ene_murky_heavy_scar")
				}
			},
			access = access_type_all
		}				
	else
		self.unit_categories.FBI_heavy_G36 = {
			unit_types = {
				america = {
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy_hh/ene_zeal_swat_heavy_hh")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_g36/ene_akan_fbi_heavy_g36")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_1/ene_fbi_heavy_hvh_1")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_scar/ene_murky_heavy_scar")
				},
				shared = {
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy_hh/ene_zeal_swat_heavy_hh"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_scar/ene_murky_heavy_scar")
				}
			},
			access = access_type_all
		}
	end

	if difficulty_index < 6 then
		self.unit_categories.FBI_heavy_R870 = {
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_fbi_heavy_r870/ene_fbi_heavy_r870"), --set up for crime spree
					Idstring("units/payday2/characters/ene_fbi_heavy_r870/ene_fbi_heavy_r870")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_r870/ene_akan_fbi_heavy_r870")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_r870/ene_fbi_heavy_hvh_r870")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_r870/ene_murky_heavy_r870"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_r870/ene_murky_heavy_r870")
				},
				shared = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_r870/ene_murky_heavy_r870"),
					Idstring("units/payday2/characters/ene_fbi_heavy_r870/ene_fbi_heavy_r870")
				}
			},
			access = access_type_all
		}
	elseif difficulty_index == 6 then
		self.unit_categories.FBI_heavy_R870 = {
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_fbi_heavy_r870/ene_fbi_heavy_r870"),
					Idstring("units/payday2/characters/ene_fbi_heavy_r870/ene_fbi_heavy_r870"),
					Idstring("units/payday2/characters/ene_city_heavy_r870/ene_city_heavy_r870")					
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_r870/ene_akan_fbi_heavy_r870")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_r870/ene_fbi_heavy_hvh_r870")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_r870/ene_murky_heavy_r870")
				},
				shared = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_r870/ene_murky_heavy_r870"),
					Idstring("units/payday2/characters/ene_city_heavy_r870/ene_city_heavy_r870")
				}
			},
			access = access_type_all
		}		
	elseif difficulty_index == 7 then
		self.unit_categories.FBI_heavy_R870 = {
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_city_heavy_r870/ene_city_heavy_r870")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_r870/ene_akan_fbi_heavy_r870")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_r870/ene_fbi_heavy_hvh_r870")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_r870/ene_murky_heavy_r870")
				},
				shared = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_r870/ene_murky_heavy_r870"),
					Idstring("units/payday2/characters/ene_city_heavy_r870/ene_city_heavy_r870")
				}
			},
			access = access_type_all
		}
	else
		self.unit_categories.FBI_heavy_R870 = {
			unit_types = {
				america = {
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy_r870/ene_zeal_swat_heavy_r870")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_r870/ene_akan_fbi_heavy_r870")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_r870/ene_fbi_heavy_hvh_r870")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_r870/ene_murky_heavy_r870")
				},
				shared = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_r870/ene_murky_heavy_r870"),
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy_r870/ene_zeal_swat_heavy_r870")
				}
			},
			access = access_type_all
		}
	end

	if difficulty_index < 8 then
		self.unit_categories.FBI_heavy_G36_w = {
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_fbi_heavy_1/ene_fbi_heavy_1")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_g36/ene_akan_fbi_heavy_g36")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_1/ene_fbi_heavy_hvh_1")
				},
				murkywater = {
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_heavy/ene_murkywater_heavy")
				}
			},
			access = access_type_walk_only
		}
	else
		self.unit_categories.FBI_heavy_G36_w = {
			unit_types = {
				america = {
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy/ene_zeal_swat_heavy")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_g36/ene_akan_fbi_heavy_g36")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_1/ene_fbi_heavy_hvh_1")
				},
				murkywater = {
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_heavy/ene_murkywater_heavy")
				}
			},
			access = access_type_walk_only
		}
	end

	if difficulty_index < 6 then
		self.unit_categories.FBI_shield = {
			special_type = "shield",
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_shield_1/ene_shield_1")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_shield_sr2_smg/ene_akan_fbi_shield_sr2_smg")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_shield_hvh_1/ene_shield_hvh_1")
				},
				murkywater = {
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_shield/ene_murkywater_shield")
				},
				shared = {
					Idstring("units/payday2/characters/ene_shield_1/ene_shield_1"),
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_shield/ene_murkywater_shield")
				}
			},
			access = access_type_walk_only
		}
	elseif difficulty_index < 8 then
		self.unit_categories.FBI_shield = {
			special_type = "shield",
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_city_shield/ene_city_shield")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_shield_dw_sr2_smg/ene_akan_fbi_shield_dw_sr2_smg")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_shield_hvh_1/ene_shield_hvh_1")
				},
				murkywater = {
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_shield/ene_murkywater_shield")
				},
				shared = {
					Idstring("units/payday2/characters/ene_city_shield/ene_city_shield"),
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_shield/ene_murkywater_shield")
				}
			},
			access = access_type_walk_only
		}
	else
		self.unit_categories.FBI_shield = {
			special_type = "shield",
			unit_types = {
				america = {
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_swat_shield_hh/ene_zeal_swat_shield_hh")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_hyper_DS_shield/ene_akan_hyper_DS_shield")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_shield_armoured_hvh/ene_shield_armoured_hvh")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_DS_shield/ene_murky_DS_shield")
				},
				shared = {
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_swat_shield_hh/ene_zeal_swat_shield_hh"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_DS_shield/ene_murky_DS_shield")
				}
			},
			access = access_type_walk_only
		}
	end
	
	--murky dozers, 2 = green, 3 = black, 4 = skull, 1 = mini
	if difficulty_index <= 4 then
		self.unit_categories.FBI_tank = {
			special_type = "tank",
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_r870/ene_akan_fbi_tank_r870")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_1/ene_bulldozer_hvh_1")
				},
				murkywater = {
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_2/ene_murkywater_bulldozer_2")
				},
				shared = { 
					Idstring("units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1"),
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_2/ene_murkywater_bulldozer_2")
				}
			},
			access = access_type_walk_only
		}
	elseif difficulty_index == 5 then
		self.unit_categories.FBI_tank = {
			special_type = "tank",
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1"),
					Idstring("units/payday2/characters/ene_bulldozer_2/ene_bulldozer_2")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_saiga/ene_akan_fbi_tank_saiga"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_r870/ene_akan_fbi_tank_r870")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_1/ene_bulldozer_hvh_1"),
					Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_2/ene_bulldozer_hvh_2")
				},
				murkywater = {
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_2/ene_murkywater_bulldozer_2"),
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_3/ene_murkywater_bulldozer_3")
				},
				shared = { 
					Idstring("units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1"),
					Idstring("units/payday2/characters/ene_bulldozer_2/ene_bulldozer_2"),
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_2/ene_murkywater_bulldozer_2"),
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_3/ene_murkywater_bulldozer_3")
				}
			},
			access = access_type_walk_only
		}
	elseif difficulty_index == 6 then
		self.unit_categories.FBI_tank = {
			special_type = "tank",
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1"),
					Idstring("units/payday2/characters/ene_bulldozer_2/ene_bulldozer_2"),
					Idstring("units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_saiga/ene_akan_fbi_tank_saiga"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_r870/ene_akan_fbi_tank_r870"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_rpk_lmg/ene_akan_fbi_tank_rpk_lmg")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_1/ene_bulldozer_hvh_1"),
					Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_2/ene_bulldozer_hvh_2"),
					Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_3/ene_bulldozer_hvh_3")
				},
				murkywater = {
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_4/ene_murkywater_bulldozer_4"),
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_2/ene_murkywater_bulldozer_2"),
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_3/ene_murkywater_bulldozer_3")
				},
				shared = {
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_4/ene_murkywater_bulldozer_4"),
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_2/ene_murkywater_bulldozer_2"),
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_3/ene_murkywater_bulldozer_3"),
					Idstring("units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1"),
					Idstring("units/payday2/characters/ene_bulldozer_2/ene_bulldozer_2"),
					Idstring("units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3")
				}
			},
			access = access_type_walk_only
		}
	elseif difficulty_index == 7 then
		self.unit_categories.FBI_tank = {
			special_type = "tank",
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1"),
					Idstring("units/payday2/characters/ene_bulldozer_2/ene_bulldozer_2"),
					Idstring("units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3"),
					Idstring("units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1"),
					Idstring("units/payday2/characters/ene_bulldozer_2/ene_bulldozer_2"),
					Idstring("units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3"),
					Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_minigun_classic/ene_bulldozer_minigun_classic")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_r870/ene_akan_fbi_tank_r870"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_saiga/ene_akan_fbi_tank_saiga"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_rpk_lmg/ene_akan_fbi_tank_rpk_lmg"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_r870/ene_akan_fbi_tank_r870"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_saiga/ene_akan_fbi_tank_saiga"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_rpk_lmg/ene_akan_fbi_tank_rpk_lmg"),
					Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_minigun_classic/ene_bulldozer_minigun_classic")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_1/ene_bulldozer_hvh_1"),
					Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_2/ene_bulldozer_hvh_2"),
					Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_3/ene_bulldozer_hvh_3"),
					Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_1/ene_bulldozer_hvh_1"),
					Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_2/ene_bulldozer_hvh_2"),
					Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_3/ene_bulldozer_hvh_3"),
					Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_minigun_classic/ene_bulldozer_minigun_classic")
				},
				murkywater = {
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_2/ene_murkywater_bulldozer_2"),
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_3/ene_murkywater_bulldozer_3"),
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_4/ene_murkywater_bulldozer_4"),
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_2/ene_murkywater_bulldozer_2"),
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_3/ene_murkywater_bulldozer_3"),
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_4/ene_murkywater_bulldozer_4"),
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_1/ene_murkywater_bulldozer_1"),
				},
				--Lord, I hate everything about how this physically and visually presents itself.
				shared = {
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_2/ene_murkywater_bulldozer_2"),
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_3/ene_murkywater_bulldozer_3"),
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_4/ene_murkywater_bulldozer_4"),
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_2/ene_murkywater_bulldozer_2"),
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_3/ene_murkywater_bulldozer_3"),
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_4/ene_murkywater_bulldozer_4"),
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_1/ene_murkywater_bulldozer_1"),
					Idstring("units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1"),
					Idstring("units/payday2/characters/ene_bulldozer_2/ene_bulldozer_2"),
					Idstring("units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3"),
					Idstring("units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1"),
					Idstring("units/payday2/characters/ene_bulldozer_2/ene_bulldozer_2"),
					Idstring("units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3"),
					Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_minigun_classic/ene_bulldozer_minigun_classic")
				}
			},
			access = access_type_walk_only
		}
	else
		self.unit_categories.FBI_tank = {
			special_type = "tank",
			unit_types = {
				america = {
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer/ene_zeal_bulldozer"),
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer_2/ene_zeal_bulldozer_2"),
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer_3/ene_zeal_bulldozer_3"),
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer/ene_zeal_bulldozer"),
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer_2/ene_zeal_bulldozer_2"),
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer_3/ene_zeal_bulldozer_3"),
					Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_medic/ene_bulldozer_medic"),
					Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_minigun/ene_bulldozer_minigun")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_r870/ene_akan_fbi_tank_r870"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_saiga/ene_akan_fbi_tank_saiga"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_rpk_lmg/ene_akan_fbi_tank_rpk_lmg"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_r870/ene_akan_fbi_tank_r870"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_saiga/ene_akan_fbi_tank_saiga"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_rpk_lmg/ene_akan_fbi_tank_rpk_lmg"),
					Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_medic/ene_bulldozer_medic"),
					Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_minigun/ene_bulldozer_minigun")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_1/ene_bulldozer_hvh_1"),
					Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_2/ene_bulldozer_hvh_2"),
					Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_3/ene_bulldozer_hvh_3"),
					Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_1/ene_bulldozer_hvh_1"),
					Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_2/ene_bulldozer_hvh_2"),
					Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_3/ene_bulldozer_hvh_3"),
					Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_medic/ene_bulldozer_medic"),
					Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_minigun/ene_bulldozer_minigun")
				},
				murkywater = {
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_2/ene_murkywater_bulldozer_2"),
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_3/ene_murkywater_bulldozer_3"),
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_4/ene_murkywater_bulldozer_4"),
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_2/ene_murkywater_bulldozer_2"),
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_3/ene_murkywater_bulldozer_3"),
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_4/ene_murkywater_bulldozer_4"),
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_1/ene_murkywater_bulldozer_1"),
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_medic/ene_murkywater_bulldozer_medic")
				},
				shared = {
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_2/ene_murkywater_bulldozer_2"),
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_3/ene_murkywater_bulldozer_3"),
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_4/ene_murkywater_bulldozer_4"),
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_2/ene_murkywater_bulldozer_2"),
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_3/ene_murkywater_bulldozer_3"),
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_4/ene_murkywater_bulldozer_4"),
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_1/ene_murkywater_bulldozer_1"),
					Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_medic/ene_murkywater_bulldozer_medic"),
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer/ene_zeal_bulldozer"),
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer_2/ene_zeal_bulldozer_2"),
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer_3/ene_zeal_bulldozer_3"),
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer/ene_zeal_bulldozer"),
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer_2/ene_zeal_bulldozer_2"),
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer_3/ene_zeal_bulldozer_3"),
					Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_medic/ene_bulldozer_medic"),
					Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_minigun/ene_bulldozer_minigun")
				}
			},
			access = access_type_walk_only
		}
	end

	self.unit_categories.medic_M4 = {
		special_type = "medic",
		unit_types = {
			america = {
				Idstring("units/payday2/characters/ene_medic_m4/ene_medic_m4")
			},
			russia = {
				Idstring("units/pd2_dlc_mad/characters/ene_akan_medic_ak47_ass/ene_akan_medic_ak47_ass")
			},
			zombie = {
				Idstring("units/pd2_dlc_hvh/characters/ene_medic_hvh_m4/ene_medic_hvh_m4")
			},
			murkywater = {
				Idstring("units/pd2_dlc_bph/characters/ene_murkywater_medic/ene_murkywater_medic")
			},
			shared = {
				Idstring("units/pd2_dlc_bph/characters/ene_murkywater_medic/ene_murkywater_medic"),
				Idstring("units/payday2/characters/ene_medic_m4/ene_medic_m4")
			}
		},
		access = access_type_all
	}
	self.unit_categories.medic_R870 = {
		special_type = "medic",
		unit_types = {
			america = {
				Idstring("units/payday2/characters/ene_medic_r870/ene_medic_r870")
			},
			russia = {
				Idstring("units/pd2_dlc_mad/characters/ene_akan_medic_r870/ene_akan_medic_r870")
			},
			zombie = {
				Idstring("units/pd2_dlc_hvh/characters/ene_medic_hvh_r870/ene_medic_hvh_r870")
			},
			murkywater = {
				Idstring("units/pd2_dlc_bph/characters/ene_murkywater_medic_r870/ene_murkywater_medic_r870")
			},
			shared = {
				Idstring("units/pd2_dlc_bph/characters/ene_murkywater_medic_r870/ene_murkywater_medic_r870"),
				Idstring("units/payday2/characters/ene_medic_r870/ene_medic_r870")
			}
		},
		access = access_type_all
	}
	self.unit_categories.Phalanx_minion = {
		special_type = "shield",
		unit_types = {
			america = {
				Idstring("units/pd2_dlc_vip/characters/ene_phalanx_1/ene_phalanx_1")
			},
			russia = {
				Idstring("units/pd2_dlc_vip/characters/ene_phalanx_1/ene_phalanx_1")
			},
			zombie = {
				Idstring("units/pd2_dlc_vip/characters/ene_phalanx_1/ene_phalanx_1")
			},
			murkywater = {
				Idstring("units/pd2_dlc_vip/characters/ene_phalanx_1/ene_phalanx_1")
			}
		},
		access = access_type_walk_only
	}
	self.unit_categories.Phalanx_vip = {
		is_captain = true,
		special_type = "shield",
		unit_types = {
			america = {
				Idstring("units/pd2_dlc_vip/characters/ene_vip_1/ene_vip_1")
			},
			russia = {
				Idstring("units/pd2_dlc_vip/characters/ene_vip_1/ene_vip_1")
			},
			zombie = {
				Idstring("units/pd2_dlc_vip/characters/ene_vip_1/ene_vip_1")
			},
			murkywater = {
				Idstring("units/pd2_dlc_vip/characters/ene_phalanx_1/ene_phalanx_1") --pfft what
			}
		},
		access = access_type_walk_only
	}
end)

Hooks:PostHook(GroupAITweakData, "_init_enemy_spawn_groups", "cock_init_enemy_spawn_groups", function(self, difficulty_index)
	self._tactics = {	
		Phalanx_minion = {
			"shield",
			"ranged_fire"
		},
		Phalanx_vip = {
			"shield",
			"ranged_fire"
		},
		swat_rifle_civil = {
			"ranged_fire",
			"provide_coverfire",
			"flash_grenade",
			"provide_support",
			"groupany"
		},
		swat_rifle_flank_civil = {
			"flank",
			"provide_coverfire",
			"ranged_fire",
			"smoke_grenade",
			"provide_support",
			"groupany"
		},
		swat_rifle_complex = {
			"elite_ranged_fire",
			"provide_coverfire",
			"flash_grenade",
			"provide_support",
			"groupany"
		},
		swat_rifle_flank_complex = {
			"hunter",
			"flank",
			"provide_coverfire",
			"elite_ranged_fire",
			"smoke_grenade",
			"provide_support",
			"groupany"
		},
		swat_rifle = {
			"elite_ranged_fire",
			"provide_coverfire",
			"flash_grenade",
			"provide_support",
			"harass",
			"groupany"
		},
		swat_rifle_flank = {
			"hunter",
			"flank",
			"provide_coverfire",
			"elite_ranged_fire",
			"smoke_grenade",
			"provide_support",
			"groupany"
		},
		swat_shotgun_rush_civil = {
			"charge",
			"provide_coverfire",
			"flash_grenade", --pushers use flashes
			"provide_support",
			"groupany"
		},
		swat_shotgun_rush_complex = {
			"deathguard",
			"charge",
			"provide_coverfire",
			"flash_grenade", --pushers use flashes
			"provide_support",
			"groupany"
		},
		swat_shotgun_rush = {
			"deathguard",
			"charge",
			"provide_coverfire",
			"flash_grenade", --pushers use flashes
			"provide_support",
			"harass",
			"groupany"
		},
		swat_shotgun_flank_civil = {
			"flank",
			"provide_coverfire",
			"smoke_grenade", --flank uses smoke
			"provide_support",
			"groupany"
		},		
		swat_shotgun_flank_complex = {
			"hunter",
			"flank",
			"provide_coverfire",
			"smoke_grenade", --flank uses smoke
			"provide_support",
			"groupany",
			"hitnrun" --the idea is after they open fire, and you're near, they'll run away to a safe spot before striking again since they'll only decide to back off after opening fire
		},
		swat_shotgun_flank = {
			"hunter",
			"flank",
			"provide_coverfire",
			"smoke_grenade", --flank uses smoke
			"provide_support",
			"hitnrun", --the idea is after they open fire, and you're near, they'll run away to a safe spot before striking again since they'll only decide to back off after opening fire
			"groupany"
		},	
		shield_wall_ranged = {
			"shield",
			"ranged_fire",
			"provide_support",
			"provide_coverfire"
		},
		shield_support_ranged = {
			"shield_cover",
			"ranged_fire",
			"provide_coverfire",
			"smoke_grenade" 
		},
		shield_wall_charge = {
			"deathguard",
			"shield",
			"charge",
			"provide_support"
		},
		shield_support_charge = {
			"deathguard", 
			"shield_cover",
			"charge",
			"provide_coverfire",
			"flash_grenade", --pushers use flashes
			"provide_support" --important, when they lose the shield, they can protect eachother
		},
		shield_wall = {
			"hunter",
			"deathguard",
			"shield_cover", 
			"shield",
			"charge",
			"hitnrun", --they'll charge, barrage and back off
			"provide_support",
			"murder"
		},
		tazer_flanking = {
			"hunter",
			"flank",
			"provide_coverfire",
			"smoke_grenade",
			"murder"		 
		},
		tazer_charge = {
			"deathguard",
			"charge",
			"harass",
			"flash_grenade",
			"provide_coverfire"
		},
		tank_rush = {
			"deathguard",
			"charge",
			"flash_grenade", --use flashes
			"provide_coverfire",
			"shield_cover", --if he spawns with a shield, he'll get covered so he can bust your fucking ass
			"murder"
		},
		spooc = {
			"shield_cover",
			"flank",
			"smoke_grenade",
			"spooctargeting"			
		},
		spoocaggressive = {
			"shield_cover",
			"charge",
			"flash_grenade",
			"spooctargeting"
		},
		spoocelite = {
			"hunter",
			"shield_cover",
			"flank",
			"smoke_grenade",
			"harass"
		},
		spoocaggressiveelite = {
			"hunter",
			"shield_cover",
			"charge",
			"flash_grenade",
			"harass"		
		},
		spooccreep = {
			"hunter",
			"shield_cover",
			"charge",
			"spoocavoidance",
			"harass"
		}
	}
	self.enemy_spawn_groups = {}
	
	if difficulty_index <= 3 then
		self.enemy_spawn_groups.punks_A = {
			amount = {
				2,
				4
			},
			spawn = {
				{
					freq = 1.25,
					amount_min = 1,
					amount_max = 2,
					rank = 2,
					unit = "punk_group",
					tactics = self._tactics.swat_rifle_civil
				},
				{
					freq = 0.75,
					amount_max = 2,
					rank = 2,
					unit = "punk_group",
					tactics = self._tactics.swat_shotgun_rush_civil
				},
				{
					amount_min = 0,
					freq = 2,
					amount_max = 2,
					rank = 3,
					unit = "CS_shield",
					tactics = self._tactics.shield_wall_ranged
				}
			}
		}
		self.enemy_spawn_groups.punks_B = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 2,
					unit = "CS_swat_MP5",
					tactics = self._tactics.swat_rifle_civil
				},
				{
					freq = 1.5,
					amount_min = 1,
					amount_max = 2,
					rank = 1,
					unit = "punk_group",
					tactics = self._tactics.swat_shotgun_rush_civil
				},
				{
					amount_min = 0,
					freq = 0.5,
					amount_max = 1,
					rank = 3,
					unit = "medic_M4",
					tactics = self._tactics.swat_rifle_civil
				}
			}
		}
		if difficulty_index == 2 then
			self.enemy_spawn_groups.punks_C = {
				amount = {
					2,
					4
				},
				spawn = {
					{
						amount_min = 1,
						freq = 1,
						amount_max = 1,
						rank = 2,
						unit = "CS_heavy_R870",
						tactics = self._tactics.swat_shotgun_rush_civil
					},
					{
						amount_min = 0,
						freq = 1.25,
						amount_max = 2,
						rank = 2,
						unit = "CS_swat_MP5",
						tactics = self._tactics.swat_shotgun_rifle_civil
					},
					{
						freq = 1.5,
						amount_min = 0,
						amount_max = 3,
						rank = 1,
						unit = "punk_group",
						tactics = self._tactics.swat_shotgun_rush_civil
					}
				}
			}
		else
			self.enemy_spawn_groups.punks_C = {
				amount = {
					2,
					3
				},
				spawn = {
					{
						amount_min = 0,
						freq = 0.5,
						amount_max = 1,
						rank = 2,
						unit = "CS_heavy_R870",
						tactics = self._tactics.swat_shotgun_rush_civil
					},
					{
						amount_min = 0,
						freq = 0.5,
						amount_max = 1,
						rank = 2,
						unit = "FBI_tank",
						tactics = self._tactics.tank_rush
					},
					{
						freq = 1.5,
						amount_min = 1,
						amount_max = 2,
						rank = 1,
						unit = "punk_group",
						tactics = self._tactics.swat_shotgun_rush_civil
					}
				}
			}
		end
	elseif difficulty_index <= 5 then
		self.enemy_spawn_groups.punks_A = {
			amount = {
				3,
				5
			},
			spawn = {
				{
					freq = 1.5,
					amount_min = 2,
					amount_max = 2,
					rank = 2,
					unit = "punk_group",
					tactics = self._tactics.swat_rifle_civil
				},
				{
					freq = 0.75,
					amount_max = 2,
					rank = 2,
					unit = "FBI_swat_M4",
					tactics = self._tactics.shield_support_ranged
				},
				{
					freq = 0.75,
					amount_max = 1,
					rank = 2,
					unit = "medic_M4",
					tactics = self._tactics.shield_support_ranged
				},
				{
					amount_min = 0,
					freq = 1,
					amount_max = 2,
					rank = 3,
					unit = "FBI_shield",
					tactics = self._tactics.shield_wall_ranged
				}
			}
		}
		self.enemy_spawn_groups.punks_B = {
			amount = {
				4,
				5
			},
			spawn = {
				{
					amount_min = 0,
					freq = 2,
					amount_max = 1,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_rush_civil
				},
				{
					amount_min = 1,
					freq = 2,
					amount_max = 1,
					rank = 2,
					unit = "FBI_swat_M4",
					tactics = self._tactics.swat_rifle_civil
				},
				{
					freq = 2.25,
					amount_min = 2,
					amount_max = 3,
					rank = 1,
					unit = "punk_group",
					tactics = self._tactics.swat_shotgun_rush_civil
				},
				{
					amount_min = 0,
					freq = 0.5,
					amount_max = 1,
					rank = 3,
					unit = "medic_M4",
					tactics = self._tactics.swat_rifle_civil
				}
			}
		}
		self.enemy_spawn_groups.punks_C = {
			amount = {
				3,
				5
			},
			spawn = {
				{
					amount_min = 0,
					freq = 1,
					amount_max = 2,
					rank = 2,
					unit = "FBI_LHmix",
					tactics = self._tactics.swat_shotgun_rifle_civil
				},
				{
					amount_min = 0,
					freq = 0.5,
					amount_max = 1,
					rank = 2,
					unit = "CS_tazer",
					tactics = self._tactics.tazer_charge
				},
				{
					amount_min = 0,
					freq = 0.5,
					amount_max = 1,
					rank = 2,
					unit = "medic_R870",
					tactics = self._tactics.swat_shotgun_rush
				},
				{
					freq = 1,
					amount_min = 2,
					amount_max = 2,
					rank = 1,
					unit = "punk_group",
					tactics = self._tactics.swat_shotgun_rush_civil
				}
			}
		}
	else
		self.enemy_spawn_groups.punks_A = {
			amount = {
				3,
				5
			},
			spawn = {
				{
					freq = 1.5,
					amount_min = 2,
					amount_max = 2,
					rank = 2,
					unit = "punk_group",
					tactics = self._tactics.swat_rifle_civil
				},
				{
					freq = 0.75,
					amount_max = 2,
					rank = 2,
					unit = "FBI_swat_M4",
					tactics = self._tactics.shield_support_ranged
				},
				{
					freq = 0.75,
					amount_max = 1,
					rank = 2,
					unit = "medic_M4",
					tactics = self._tactics.shield_support_ranged
				},
				{
					amount_min = 0,
					freq = 1,
					amount_max = 2,
					rank = 3,
					unit = "FBI_shield",
					tactics = self._tactics.shield_wall_ranged
				}
			}
		}
		self.enemy_spawn_groups.punks_B = {
			amount = {
				4,
				5
			},
			spawn = {
				{
					amount_min = 0,
					freq = 2,
					amount_max = 1,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_rush_civil
				},
				{
					amount_min = 1,
					freq = 2,
					amount_max = 1,
					rank = 2,
					unit = "FBI_swat_M4",
					tactics = self._tactics.swat_rifle_civil
				},
				{
					freq = 2.25,
					amount_min = 2,
					amount_max = 3,
					rank = 1,
					unit = "punk_group",
					tactics = self._tactics.swat_shotgun_rush_civil
				},
				{
					amount_min = 0,
					freq = 0.5,
					amount_max = 1,
					rank = 3,
					unit = "medic_M4",
					tactics = self._tactics.swat_rifle_civil
				}
			}
		}
		self.enemy_spawn_groups.punks_C = {
			amount = {
				3,
				5
			},
			spawn = {
				{
					amount_min = 0,
					freq = 1,
					amount_max = 2,
					rank = 2,
					unit = "FBI_LHmix",
					tactics = self._tactics.swat_shotgun_rifle_civil
				},
				{
					amount_min = 0,
					freq = 0.5,
					amount_max = 1,
					rank = 2,
					unit = "CS_tazer",
					tactics = self._tactics.tazer_charge
				},
				{
					amount_min = 0,
					freq = 0.5,
					amount_max = 1,
					rank = 2,
					unit = "medic_R870",
					tactics = self._tactics.swat_shotgun_rush
				},
				{
					freq = 1,
					amount_min = 2,
					amount_max = 2,
					rank = 1,
					unit = "punk_group",
					tactics = self._tactics.swat_shotgun_rush_civil
				}
			}
		}
	end
	
	if Global.game_settings and Global.game_settings.use_intense_AI then
		self.enemy_spawn_groups.tac_swat_shotgun_rush = {
			amount = {
				4,
				6
			},
			spawn = {
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 3,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_rush
				},
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 3,
					unit = "FBI_heavy_R870",
					tactics = self._tactics.swat_shotgun_rush
				},
				{
					amount_min = 0,
					freq = 0.5,
					amount_max = 1,
					rank = 2,
					unit = "medic_R870",
					tactics = self._tactics.swat_shotgun_rush
				},
				{
					amount_min = 0,
					freq = 1,
					amount_max = 1,
					rank = 3,
					unit = "CS_tazer",
					tactics = self._tactics.tazer_flanking --Pinch.
				},
				{
					amount_min = 0,
					freq = 1.9,
					amount_max = 2,
					rank = 2,
					unit = "FBI_swat_R870", --punks
					tactics = self._tactics.swat_shotgun_flank_civil
				}
			}
		}
	elseif difficulty_index <= 2 then
		self.enemy_spawn_groups.tac_swat_shotgun_rush = {
			amount = {
				3,
				3
			},
			spawn = {
				{
					amount_min = 2,
					freq = 1,
					amount_max = 2,
					rank = 2,
					unit = "CS_swat_R870",
					tactics = self._tactics.swat_shotgun_rush_civil
				},
				{
					amount_min = 1,
					freq = 1,
					amount_max = 1,
					rank = 3,
					unit = "CS_heavy_R870",
					tactics = self._tactics.swat_shotgun_rush_civil
				}
			}
		}
	elseif difficulty_index == 3 then
		self.enemy_spawn_groups.tac_swat_shotgun_rush = {
			amount = {
				4,
				5
			},
			spawn = {
				{
					amount_min = 2,
					freq = 1,
					amount_max = 2,
					rank = 2,
					unit = "CS_swat_R870",
					tactics = self._tactics.swat_shotgun_rush_civil
				},
				{
					amount_min = 2,
					freq = 1,
					amount_max = 2,
					rank = 3,
					unit = "CS_heavy_R870",
					tactics = self._tactics.swat_shotgun_rush_civil
				},
				{
					amount_min = 0,
					freq = 0.1,
					amount_max = 1,
					rank = 2,
					unit = "medic_R870",
					tactics = self._tactics.swat_shotgun_rush_civil
				}
			}
		}
	elseif difficulty_index == 4 then
		self.enemy_spawn_groups.tac_swat_shotgun_rush = {
			amount = {
				4,
				5
			},
			spawn = {
				{
					amount_min = 3,
					freq = 1,
					amount_max = 3,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_rush_civil
				},
				{
					amount_min = 1,
					freq = 1,
					amount_max = 1,
					rank = 3,
					unit = "FBI_heavy_R870",
					tactics = self._tactics.swat_shotgun_rush_civil
				},
				{
					amount_min = 0,
					freq = 0.15,
					amount_max = 1,
					rank = 2,
					unit = "medic_R870",
					tactics = self._tactics.swat_shotgun_rush_civil
				}
			}
		}
	elseif difficulty_index == 5 then
		self.enemy_spawn_groups.tac_swat_shotgun_rush = {
			amount = {
				4,
				5
			},
			spawn = {
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_rush_civil
				},
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 3,
					unit = "FBI_heavy_R870",
					tactics = self._tactics.swat_shotgun_rush_civil
				},
				{
					amount_min = 0,
					freq = 0.2,
					amount_max = 1,
					rank = 2,
					unit = "medic_R870",
					tactics = self._tactics.swat_shotgun_rush_civil
				}
			}
		}
	elseif difficulty_index == 6 then
		self.enemy_spawn_groups.tac_swat_shotgun_rush = {
			amount = {
				4,
				6
			},
			spawn = {
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 3,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_rush_complex
				},
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 3,
					unit = "FBI_heavy_R870",
					tactics = self._tactics.swat_shotgun_rush_complex
				},
				{
					amount_min = 0,
					freq = 0.35,
					amount_max = 1,
					rank = 2,
					unit = "medic_R870",
					tactics = self._tactics.swat_shotgun_rush_complex
				},
				{
					amount_min = 0,
					freq = 0.35,
					amount_max = 1,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_flank_civil --forced pinch, no hit and run
				}
			}
		}
	elseif difficulty_index == 7 then
		self.enemy_spawn_groups.tac_swat_shotgun_rush = {
			amount = {
				4,
				6
			},
			spawn = {
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 3,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_rush_complex
				},
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 3,
					unit = "FBI_heavy_R870",
					tactics = self._tactics.swat_shotgun_rush_complex
				},
				{
					amount_min = 0,
					freq = 0.35,
					amount_max = 1,
					rank = 2,
					unit = "medic_R870",
					tactics = self._tactics.swat_shotgun_rush_complex
				},
				{
					amount_min = 0,
					freq = 1.99,
					amount_max = 2,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_flank_civil --forced pinch, no hit and run
				}
			}
		}
	else
		self.enemy_spawn_groups.tac_swat_shotgun_rush = {
			amount = {
				4,
				6
			},
			spawn = {
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 3,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_rush
				},
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 3,
					unit = "FBI_heavy_R870",
					tactics = self._tactics.swat_shotgun_rush
				},
				{
					amount_min = 0,
					freq = 0.5,
					amount_max = 1,
					rank = 2,
					unit = "medic_R870",
					tactics = self._tactics.swat_shotgun_rush
				},
				{
					amount_min = 0,
					freq = 1,
					amount_max = 1,
					rank = 3,
					unit = "CS_tazer",
					tactics = self._tactics.tazer_flanking --Pinch.
				},
				{
					amount_min = 0,
					freq = 1.9,
					amount_max = 2,
					rank = 2,
					unit = "FBI_swat_R870", --They're just heavies.
					tactics = self._tactics.swat_shotgun_flank_civil
				}
			}
		}
	end
	
	if Global.game_settings and Global.game_settings.use_intense_AI then
		self.enemy_spawn_groups.tac_swat_shotgun_flank = {
			amount = {
				4,
				7
			},
			spawn = {
				{
					amount_min = 2,
					freq = 1,
					amount_max = 2,
					rank = 3,
					unit = "FBI_heavy_G36",
					tactics = self._tactics.swat_rifle
				},
				{
					freq = 0.5,
					rank = 3,
					unit = "FBI_suit_M4_MP5", 
					tactics = self._tactics.swat_rifle
				},
				{
					amount_min = 2,
					freq = 3,
					amount_max = 2,
					rank = 3,
					unit = "FBI_heavy_R870",
					tactics = self._tactics.swat_shotgun_flank
				},
				{
					amount_min = 0,
					freq = 0.35,
					amount_max = 1,
					rank = 2,
					unit = "medic_R870",
					tactics = self._tactics.swat_shotgun_flank
				},
				{
					amount_min = 0,
					freq = 0.35,
					amount_max = 1,
					rank = 3,
					unit = "FBI_tank",
					tactics = self._tactics.tank_rush --Basically your worst nightmare.
				}
			}
		}
	elseif difficulty_index <= 2 then
		self.enemy_spawn_groups.tac_swat_shotgun_flank = {
			amount = {
				3,
				3
			},
			spawn = {
				{
					amount_min = 2,
					freq = 1,
					amount_max = 2,
					rank = 2,
					unit = "CS_swat_R870",
					tactics = self._tactics.swat_shotgun_flank_civil
				},
				{
					amount_min = 1,
					freq = 1,
					amount_max = 1,
					rank = 3,
					unit = "CS_heavy_R870",
					tactics = self._tactics.swat_shotgun_flank_civil
				}
			}
		}
	elseif difficulty_index == 3 then
		self.enemy_spawn_groups.tac_swat_shotgun_flank = {
			amount = {
				4,
				5
			},
			spawn = {
				{
					amount_min = 2,
					freq = 1,
					amount_max = 2,
					rank = 2,
					unit = "CS_swat_R870",
					tactics = self._tactics.swat_shotgun_flank_civil
				},
				{
					amount_min = 2,
					freq = 1,
					amount_max = 2,
					rank = 3,
					unit = "CS_heavy_R870",
					tactics = self._tactics.swat_shotgun_flank_civil
				},
				{
					amount_min = 0,
					freq = 0.1,
					amount_max = 1,
					rank = 2,
					unit = "medic_R870",
					tactics = self._tactics.swat_shotgun_flank_civil
				}
			}
		}
	elseif difficulty_index == 4 then
		self.enemy_spawn_groups.tac_swat_shotgun_flank = {
			amount = {
				4,
				5
			},
			spawn = {
				{
					amount_min = 3,
					freq = 1,
					amount_max = 3,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_flank_civil
				},
				{
					amount_min = 1,
					freq = 1,
					amount_max = 1,
					rank = 3,
					unit = "FBI_heavy_R870",
					tactics = self._tactics.swat_shotgun_flank_civil
				},
				{
					amount_min = 0,
					freq = 0.15,
					amount_max = 1,
					rank = 2,
					unit = "medic_R870",
					tactics = self._tactics.swat_shotgun_flank_civil
				}
			}
		}
	elseif difficulty_index == 5 then
		self.enemy_spawn_groups.tac_swat_shotgun_flank = {
			amount = {
				4,
				5
			},
			spawn = {
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_flank_civil
				},
				{
					freq = 1,
					rank = 3,
					unit = "FBI_suit_M4_MP5",
					tactics = self._tactics.swat_shotgun_rush_civil --oh no they're dumb
				},
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 3,
					unit = "FBI_heavy_R870",
					tactics = self._tactics.swat_shotgun_flank_civil
				},
				{
					amount_min = 0,
					freq = 0.2,
					amount_max = 1,
					rank = 2,
					unit = "medic_R870",
					tactics = self._tactics.swat_shotgun_flank_civil
				}
			}
		}
	elseif difficulty_index == 6 then
		self.enemy_spawn_groups.tac_swat_shotgun_flank = {
			amount = {
				4,
				6
			},
			spawn = {
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 3,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_rush_complex --these guys are dumb too but at least that means the heavy and medic can flank
				},
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 3,
					unit = "FBI_heavy_R870",
					tactics = self._tactics.swat_shotgun_flank
				},
				{
					amount_min = 0,
					freq = 0.35,
					amount_max = 1,
					rank = 2,
					unit = "medic_R870",
					tactics = self._tactics.swat_shotgun_flank
				},
				{
					freq = 1,
					rank = 3,
					unit = "FBI_suit_M4_MP5",
					tactics = self._tactics.swat_rifle_complex --oh no they're dumb
				}
			}
		}
	elseif difficulty_index == 7 then
		self.enemy_spawn_groups.tac_swat_shotgun_flank = {
			amount = {
				4,
				7
			},
			spawn = {
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 3,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_flank_complex
				},
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 3,
					unit = "FBI_heavy_R870",
					tactics = self._tactics.swat_shotgun_rush_complex --flankers do hit and run while heavies and medic do a raw charge
				},
				{
					amount_min = 0,
					freq = 0.35,
					amount_max = 1,
					rank = 2,
					unit = "medic_R870",
					tactics = self._tactics.swat_shotgun_rush_complex
				},
				{
					freq = 1,
					rank = 3,
					unit = "FBI_suit_M4_MP5",
					tactics = self._tactics.swat_rifle_flank_complex --they're coordinated
				}
			}
		}
	else
		self.enemy_spawn_groups.tac_swat_shotgun_flank = {
			amount = {
				4,
				7
			},
			spawn = {
				{
					amount_min = 2,
					freq = 1,
					amount_max = 2,
					rank = 3,
					unit = "FBI_heavy_G36",
					tactics = self._tactics.swat_rifle
				},
				{
					freq = 0.5,
					rank = 3,
					unit = "FBI_suit_M4_MP5", 
					tactics = self._tactics.swat_rifle
				},
				{
					amount_min = 2,
					freq = 3,
					amount_max = 2,
					rank = 3,
					unit = "FBI_heavy_R870",
					tactics = self._tactics.swat_shotgun_flank
				},
				{
					amount_min = 0,
					freq = 0.35,
					amount_max = 1,
					rank = 2,
					unit = "medic_R870",
					tactics = self._tactics.swat_shotgun_flank
				},
				{
					amount_min = 0,
					freq = 0.35,
					amount_max = 1,
					rank = 3,
					unit = "FBI_tank",
					tactics = self._tactics.tank_rush --Basically your worst nightmare.
				}
			}
		}
	end
	
	if Global.game_settings and Global.game_settings.use_intense_AI then
		self.enemy_spawn_groups.tac_swat_rifle = { --spamming three heavies is not interesting fuck off, no changes needed otherwise tbh
			amount = {
				4,
				5
			},
			spawn = {
				{
					amount_min = 2,
					freq = 1,
					amount_max = 2,
					rank = 2,
					unit = "FBI_swat_M4",
					tactics = self._tactics.swat_rifle
				},
				{
					amount_min = 2,
					freq = 3,
					amount_max = 2,
					rank = 3,
					unit = "FBI_heavy_G36",
					tactics = self._tactics.swat_rifle
				},
				{
					amount_min = 0,
					freq = 0.5,
					amount_max = 1,
					rank = 2,
					unit = "medic_M4",
					tactics = self._tactics.swat_rifle
				}
			}
		}
	elseif difficulty_index <= 2 then
		self.enemy_spawn_groups.tac_swat_rifle = {
			amount = {
				3,
				3
			},
			spawn = {
				{
					amount_min = 2,
					freq = 1,
					amount_max = 2,
					rank = 2,
					unit = "CS_swat_MP5",
					tactics = self._tactics.swat_rifle_civil
				},
				{
					amount_min = 1,
					freq = 1,
					amount_max = 1,
					rank = 3,
					unit = "CS_heavy_M4",
					tactics = self._tactics.swat_rifle_civil
				}
			}
		}
	elseif difficulty_index == 3 then
		self.enemy_spawn_groups.tac_swat_rifle = {
			amount = {
				4,
				5
			},
			spawn = {
				{
					amount_min = 2,
					freq = 1,
					amount_max = 2,
					rank = 2,
					unit = "CS_swat_MP5",
					tactics = self._tactics.swat_rifle_civil
				},
				{
					amount_min = 2,
					freq = 1,
					amount_max = 2,
					rank = 3,
					unit = "CS_heavy_M4",
					tactics = self._tactics.swat_rifle_civil
				},
				{
					amount_min = 0,
					freq = 0.1,
					amount_max = 1,
					rank = 2,
					unit = "medic_M4",
					tactics = self._tactics.swat_rifle_civil
				}
			}
		}
	elseif difficulty_index == 4 then
		self.enemy_spawn_groups.tac_swat_rifle = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					amount_min = 3,
					freq = 1,
					amount_max = 3,
					rank = 2,
					unit = "FBI_swat_M4",
					tactics = self._tactics.swat_rifle_civil
				},
				{
					amount_min = 1,
					freq = 1,
					amount_max = 1,
					rank = 3,
					unit = "FBI_heavy_G36",
					tactics = self._tactics.swat_rifle_civil
				},
				{
					amount_min = 0,
					freq = 0.15,
					amount_max = 1,
					rank = 2,
					unit = "medic_M4",
					tactics = self._tactics.swat_rifle_civil
				}
			}
		}
	elseif difficulty_index == 5 then
		self.enemy_spawn_groups.tac_swat_rifle = {
			amount = {
				4,
				5
			},
			spawn = {
				{
					amount_min = 3,
					freq = 2,
					amount_max = 3,
					rank = 2,
					unit = "FBI_swat_M4",
					tactics = self._tactics.swat_rifle_civil
				},
				{
					amount_min = 1,
					freq = 2,
					amount_max = 1,
					rank = 3,
					unit = "FBI_heavy_G36",
					tactics = self._tactics.swat_rifle_civil
				},
				{
					amount_min = 0,
					freq = 0.2,
					amount_max = 1,
					rank = 2,
					unit = "medic_M4",
					tactics = self._tactics.swat_rifle_civil
				}
			}
		}
	elseif difficulty_index == 6 then
		self.enemy_spawn_groups.tac_swat_rifle = {
			amount = {
				4,
				5
			},
			spawn = {
				{
					amount_min = 3,
					freq = 3,
					amount_max = 3,
					rank = 2,
					unit = "FBI_swat_M4",
					tactics = self._tactics.swat_rifle_complex
				},
				{
					amount_min = 1,
					freq = 1,
					amount_max = 1,
					rank = 3,
					unit = "FBI_heavy_G36",
					tactics = self._tactics.swat_rifle_complex
				},
				{
					amount_min = 0,
					freq = 0.35,
					amount_max = 1,
					rank = 2,
					unit = "medic_M4",
					tactics = self._tactics.swat_rifle_complex
				}
			}
		}
	elseif difficulty_index == 7 then
		self.enemy_spawn_groups.tac_swat_rifle = {
			amount = {
				4,
				5
			},
			spawn = {
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 2,
					unit = "FBI_swat_M4",
					tactics = self._tactics.swat_rifle_complex
				},
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 3,
					unit = "FBI_heavy_G36",
					tactics = self._tactics.swat_rifle_complex
				},
				{
					amount_min = 0,
					freq = 0.35,
					amount_max = 1,
					rank = 2,
					unit = "medic_M4",
					tactics = self._tactics.swat_rifle_complex
				}
			}
		}
	else
		self.enemy_spawn_groups.tac_swat_rifle = { --spamming three heavies is not interesting fuck off, no changes needed otherwise tbh
			amount = {
				4,
				5
			},
			spawn = {
				{
					amount_min = 2,
					freq = 1,
					amount_max = 2,
					rank = 2,
					unit = "FBI_swat_M4",
					tactics = self._tactics.swat_rifle
				},
				{
					amount_min = 2,
					freq = 3,
					amount_max = 2,
					rank = 3,
					unit = "FBI_heavy_G36",
					tactics = self._tactics.swat_rifle
				},
				{
					amount_min = 0,
					freq = 0.5,
					amount_max = 1,
					rank = 2,
					unit = "medic_M4",
					tactics = self._tactics.swat_rifle
				}
			}
		}
	end
	
	if Global.game_settings and Global.game_settings.use_intense_AI then
		self.enemy_spawn_groups.tac_swat_rifle_flank = { --spamming 3 heavies is not interesting fuck off
			amount = {
				4,
				6
			},
			spawn = {
				{
					amount_min = 2,
					freq = 1,
					amount_max = 2,
					rank = 2,
					unit = "FBI_swat_M4",
					tactics = self._tactics.swat_rifle_flank
				},
				{
					freq = 0.5,
					rank = 1,
					unit = "FBI_suit_M4_MP5",
					tactics = self._tactics.swat_rifle_flank
				},
				{
					amount_min = 2,
					freq = 3,
					amount_max = 2,
					rank = 3,
					unit = "FBI_heavy_G36", 
					tactics = self._tactics.swat_rifle
				},
				{
					amount_min = 0,
					freq = 0.35,
					amount_max = 1,
					rank = 2,
					unit = "medic_M4",
					tactics = self._tactics.swat_rifle --others push while medic and heavies distract
				},
				{
					amount_min = 0,
					freq = 0.35,
					amount_max = 1,
					rank = 2,
					unit = "CS_tazer",
					tactics = self._tactics.tazer_flanking --asshole-brand taser
				}
			}
		}
	elseif difficulty_index <= 2 then
		self.enemy_spawn_groups.tac_swat_rifle_flank = {
			amount = {
				3,
				3
			},
			spawn = {
				{
					amount_min = 2,
					freq = 1,
					amount_max = 2,
					rank = 2,
					unit = "CS_swat_MP5",
					tactics = self._tactics.swat_rifle_flank_civil
				},
				{
					amount_min = 1,
					freq = 1,
					amount_max = 1,
					rank = 3,
					unit = "CS_heavy_M4",
					tactics = self._tactics.swat_rifle_flank_civil
				}
			}
		}
	elseif difficulty_index == 3 then
		self.enemy_spawn_groups.tac_swat_rifle_flank = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					amount_min = 2,
					freq = 1,
					amount_max = 2,
					rank = 2,
					unit = "CS_swat_MP5",
					tactics = self._tactics.swat_rifle_flank_civil
				},
				{
					amount_min = 2,
					freq = 1,
					amount_max = 2,
					rank = 3,
					unit = "CS_heavy_M4",
					tactics = self._tactics.swat_rifle_flank_civil
				},
				{
					amount_min = 0,
					freq = 0.1,
					amount_max = 1,
					rank = 2,
					unit = "medic_M4",
					tactics = self._tactics.swat_rifle_flank_civil
				}
			}
		}
	elseif difficulty_index == 4 then
		self.enemy_spawn_groups.tac_swat_rifle_flank = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					amount_min = 3,
					freq = 1,
					amount_max = 3,
					rank = 2,
					unit = "FBI_swat_M4",
					tactics = self._tactics.swat_rifle_flank_civil
				},
				{
					amount_min = 1,
					freq = 1,
					amount_max = 1,
					rank = 3,
					unit = "FBI_heavy_G36",
					tactics = self._tactics.swat_rifle_flank_civil
				},
				{
					amount_min = 0,
					freq = 0.15,
					amount_max = 1,
					rank = 2,
					unit = "medic_M4",
					tactics = self._tactics.swat_rifle_flank_civil
				}
			}
		}
	elseif difficulty_index == 5 then
		self.enemy_spawn_groups.tac_swat_rifle_flank = {
			amount = {
				4,
				5
			},
			spawn = {
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 2,
					unit = "FBI_swat_M4",
					tactics = self._tactics.swat_rifle_flank_civil
				},
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 3,
					unit = "FBI_heavy_G36",
					tactics = self._tactics.swat_rifle_flank_civil
				},
				{
					amount_min = 0,
					freq = 0.2,
					amount_max = 1,
					rank = 2,
					unit = "medic_M4",
					tactics = self._tactics.swat_rifle_flank_civil
				}
			}
		}
	elseif difficulty_index == 6 then
		self.enemy_spawn_groups.tac_swat_rifle_flank = {
			amount = {
				4,
				5
			},
			spawn = {
				{
					amount_min = 3,
					freq = 3,
					amount_max = 3,
					rank = 2,
					unit = "FBI_swat_M4",
					tactics = self._tactics.swat_rifle_flank_complex
				},
				{
					freq = 0.5,
					rank = 1,
					unit = "FBI_suit_M4_MP5",
					tactics = self._tactics.swat_rifle_complex --they're uncoordinated
				},
				{
					amount_min = 1,
					freq = 1,
					amount_max = 1,
					rank = 3,
					unit = "FBI_heavy_G36",
					tactics = self._tactics.swat_rifle_flank_complex
				},
				{
					amount_min = 0,
					freq = 0.3,
					amount_max = 1,
					rank = 2,
					unit = "medic_M4",
					tactics = self._tactics.swat_rifle_flank_complex
				}
			}
		}
	elseif difficulty_index == 7 then
		self.enemy_spawn_groups.tac_swat_rifle_flank = { --spamming 3 heavies is not interesting fuck off
			amount = {
				4,
				6
			},
			spawn = {
				{
					amount_min = 2,
					freq = 1,
					amount_max = 2,
					rank = 2,
					unit = "FBI_swat_M4",
					tactics = self._tactics.swat_rifle_flank_complex
				},
				{
					freq = 0.5,
					rank = 1,
					unit = "FBI_suit_M4_MP5",
					tactics = self._tactics.swat_rifle_flank_complex --they're coordinated
				},
				{
					amount_min = 2,
					freq = 3,
					amount_max = 2,
					rank = 3,
					unit = "FBI_heavy_G36", 
					tactics = self._tactics.swat_rifle_flank_complex
				},
				{
					amount_min = 0,
					freq = 0.35,
					amount_max = 1,
					rank = 2,
					unit = "medic_M4",
					tactics = self._tactics.swat_rifle_flank_complex
				},
				{
					amount_min = 0,
					freq = 0.2,
					amount_max = 1,
					rank = 2,
					unit = "CS_tazer",
					tactics = self._tactics.tazer_flanking --asshole-brand taser
				}
			}
		}
	else
		self.enemy_spawn_groups.tac_swat_rifle_flank = { --spamming 3 heavies is not interesting fuck off
			amount = {
				4,
				6
			},
			spawn = {
				{
					amount_min = 2,
					freq = 1,
					amount_max = 2,
					rank = 2,
					unit = "FBI_swat_M4",
					tactics = self._tactics.swat_rifle_flank
				},
				{
					freq = 0.5,
					rank = 1,
					unit = "FBI_suit_M4_MP5",
					tactics = self._tactics.swat_rifle_flank
				},
				{
					amount_min = 2,
					freq = 3,
					amount_max = 2,
					rank = 3,
					unit = "FBI_heavy_G36", 
					tactics = self._tactics.swat_rifle
				},
				{
					amount_min = 0,
					freq = 0.35,
					amount_max = 1,
					rank = 2,
					unit = "medic_M4",
					tactics = self._tactics.swat_rifle --others push while medic and heavies distract
				},
				{
					amount_min = 0,
					freq = 0.35,
					amount_max = 1,
					rank = 2,
					unit = "CS_tazer",
					tactics = self._tactics.tazer_flanking --asshole-brand taser
				}
			}
		}
	end
	
	if Global.game_settings and Global.game_settings.use_intense_AI then
		self.enemy_spawn_groups.tac_shield_wall_ranged = { --surprisingly im fine with this, its a fairly balanced spawn group
			amount = {
				4,
				6
			},
			spawn = {
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 2,
					unit = "FBI_heavy_G36",
					tactics = self._tactics.shield_support_ranged
				},
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 3,
					unit = "FBI_shield",
					tactics = self._tactics.shield_wall_ranged
				},
				{
					amount_min = 0,
					freq = 1,
					amount_max = 2,
					rank = 2,
					unit = "medic_M4",
					tactics = self._tactics.shield_support_ranged
				},
				{
					amount_min = 0,
					freq = 1,
					amount_max = 1,
					rank = 2,
					unit = "spooc",
					tactics = self._tactics.spoocavoidance
				},
				{
					amount_min = 0,
					freq = 1,
					amount_max = 2,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_flank
				}
			}
		}
	elseif difficulty_index <= 2 then
		self.enemy_spawn_groups.tac_shield_wall_ranged = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					amount_min = 2,
					freq = 1,
					amount_max = 2,
					rank = 2,
					unit = "CS_swat_MP5",
					tactics = self._tactics.shield_support_ranged
				},
				{
					amount_min = 2,
					freq = 1,
					amount_max = 2,
					rank = 3,
					unit = "CS_shield",
					tactics = self._tactics.shield_wall_ranged
				}
			}
		}
	elseif difficulty_index == 3 then
		self.enemy_spawn_groups.tac_shield_wall_ranged = {
			amount = {
				4,
				5
			},
			spawn = {
				{
					amount_min = 2,
					freq = 1,
					amount_max = 2,
					rank = 2,
					unit = "CS_heavy_M4",
					tactics = self._tactics.shield_support_ranged
				},
				{
					amount_min = 2,
					freq = 1,
					amount_max = 2,
					rank = 3,
					unit = "CS_shield",
					tactics = self._tactics.shield_wall_ranged
				},
				{
					amount_min = 0,
					freq = 0.5,
					amount_max = 1,
					rank = 2,
					unit = "medic_M4",
					tactics = self._tactics.swat_rifle_civil
				}
			}
		}
	elseif difficulty_index == 4 then
		self.enemy_spawn_groups.tac_shield_wall_ranged = {
			amount = {
				4,
				5
			},
			spawn = {
				{
					amount_min = 2,
					freq = 1,
					amount_max = 2,
					rank = 2,
					unit = "FBI_swat_M4",
					tactics = self._tactics.shield_support_ranged
				},
				{
					amount_min = 2,
					freq = 1,
					amount_max = 2,
					rank = 3,
					unit = "FBI_shield",
					tactics = self._tactics.shield_wall_ranged
				},
				{
					amount_min = 0,
					freq = 0.5,
					amount_max = 1,
					rank = 2,
					unit = "medic_M4",
					tactics = self._tactics.swat_rifle_civil
				}
			}
		}
	elseif difficulty_index == 5 then
		self.enemy_spawn_groups.tac_shield_wall_ranged = {
			amount = {
				4,
				5
			},
			spawn = {
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 2,
					unit = "FBI_heavy_G36",
					tactics = self._tactics.shield_support_ranged
				},
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 3,
					unit = "FBI_shield",
					tactics = self._tactics.shield_wall_ranged
				},
				{
					amount_min = 0,
					freq = 1, --start enforcing medics spawning with shields and specials when possible
					amount_max = 1,
					rank = 2,
					unit = "medic_M4",
					tactics = self._tactics.shield_support_ranged
				}
			}
		}
	elseif difficulty_index == 6 then
		self.enemy_spawn_groups.tac_shield_wall_ranged = {
			amount = {
				4,
				6
			},
			spawn = {
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 2,
					unit = "FBI_heavy_G36",
					tactics = self._tactics.shield_support_ranged
				},
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 3,
					unit = "FBI_shield",
					tactics = self._tactics.shield_wall_ranged
				},
				{
					amount_min = 0,
					freq = 1,
					amount_max = 1,
					rank = 2,
					unit = "medic_M4",
					tactics = self._tactics.shield_support_ranged
				},
				{
					amount_min = 0,
					freq = 1,
					amount_max = 2,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_flank_complex
				}
			}
		}
	elseif difficulty_index == 7 then
		self.enemy_spawn_groups.tac_shield_wall_ranged = {
			amount = {
				4,
				6
			},
			spawn = {
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 2,
					unit = "FBI_heavy_G36",
					tactics = self._tactics.shield_support_ranged
				},
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 3,
					unit = "FBI_shield",
					tactics = self._tactics.shield_wall_ranged
				},
				{
					amount_min = 0,
					freq = 1, --they're not required by any means to spawn, so if they dont, a spooc probably will
					amount_max = 1,
					rank = 2,
					unit = "medic_M4",
					tactics = self._tactics.shield_support_ranged
				},
				{
					amount_min = 0,
					freq = 1,
					amount_max = 1,
					rank = 2,
					unit = "spooc",
					tactics = self._tactics.spooc
				},
				{
					amount_min = 0,
					freq = 1,
					amount_max = 2,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_flank_complex
				}
			}
		}
	else
		self.enemy_spawn_groups.tac_shield_wall_ranged = { --surprisingly im fine with this, its a fairly balanced spawn group
			amount = {
				4,
				6
			},
			spawn = {
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 2,
					unit = "FBI_heavy_G36",
					tactics = self._tactics.shield_support_ranged
				},
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 3,
					unit = "FBI_shield",
					tactics = self._tactics.shield_wall_ranged
				},
				{
					amount_min = 0,
					freq = 1,
					amount_max = 2,
					rank = 2,
					unit = "medic_M4",
					tactics = self._tactics.shield_support_ranged
				},
				{
					amount_min = 0,
					freq = 1,
					amount_max = 1,
					rank = 2,
					unit = "spooc",
					tactics = self._tactics.spoocavoidance
				},
				{
					amount_min = 0,
					freq = 1,
					amount_max = 2,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_flank
				}
			}
		}
	end
	
	if Global.game_settings and Global.game_settings.use_intense_AI then
		self.enemy_spawn_groups.tac_shield_wall_charge = {
			amount = {
				4,
				7
			},
			spawn = {
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.shield_support_charge
				},
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 3,
					unit = "FBI_shield",
					tactics = self._tactics.shield_wall_charge
				},
				{
					amount_min = 0,
					freq = 1,
					amount_max = 1,
					rank = 2,
					unit = "medic_R870",
					tactics = self._tactics.shield_support_charge
				},
				{
					amount_min = 0,
					freq = 0.35,
					amount_max = 1,
					rank = 3,
					unit = "CS_tazer",
					tactics = self._tactics.tazer_flanking --pinch boi
				},
				{
					amount_min = 0,
					freq = 0.35,
					amount_max = 1,
					rank = 3,
					unit = "FBI_heavy_G36",
					tactics = self._tactics.swat_rifle --distant support
				}
			}
		}
	elseif difficulty_index <= 2 then
		self.enemy_spawn_groups.tac_shield_wall_charge = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					amount_min = 2,
					freq = 1,
					amount_max = 2,
					rank = 2,
					unit = "CS_swat_R870",
					tactics = self._tactics.shield_support_charge
				},
				{
					amount_min = 2,
					freq = 1,
					amount_max = 2,
					rank = 3,
					unit = "CS_shield",
					tactics = self._tactics.shield_wall_charge
				}
			}
		}
	elseif difficulty_index == 3 then
		self.enemy_spawn_groups.tac_shield_wall_charge = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					amount_min = 2,
					freq = 1,
					amount_max = 2,
					rank = 2,
					unit = "CS_heavy_R870",
					tactics = self._tactics.shield_support_charge
				},
				{
					amount_min = 2,
					freq = 1,
					amount_max = 2,
					rank = 3,
					unit = "CS_shield",
					tactics = self._tactics.shield_wall_charge
				}
			}
		}
	elseif difficulty_index == 4 then
		self.enemy_spawn_groups.tac_shield_wall_charge = {
			amount = {
				4,
				5
			},
			spawn = {
				{
					amount_min = 2,
					freq = 1,
					amount_max = 2,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.shield_support_charge
				},
				{
					amount_min = 2,
					freq = 1,
					amount_max = 2,
					rank = 3,
					unit = "FBI_shield",
					tactics = self._tactics.shield_wall_charge
				},
				{
					amount_min = 0,
					freq = 0.25,
					amount_max = 1,
					rank = 3,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_flank_civil --pinchy boi
				}
			}
		}
	elseif difficulty_index == 5 then
		self.enemy_spawn_groups.tac_shield_wall_charge = {
			amount = {
				4,
				6
			},
			spawn = {
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 2,
					unit = "FBI_heavy_R870",
					tactics = self._tactics.shield_support_charge
				},
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 3,
					unit = "FBI_shield",
					tactics = self._tactics.shield_wall_charge
				},
				{
					amount_min = 0,
					freq = 1,
					amount_max = 1,
					rank = 2,
					unit = "medic_R870",
					tactics = self._tactics.shield_support_charge
				},
				{
					amount_min = 0,
					freq = 0.35,
					amount_max = 1,
					rank = 3,
					unit = "FBI_heavy_R870",
					tactics = self._tactics.swat_shotgun_flank_civil --pinchy boi
				}
			}
		}
	elseif difficulty_index == 6 then
		self.enemy_spawn_groups.tac_shield_wall_charge = {
			amount = {
				4,
				6
			},
			spawn = {
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.shield_support_charge
				},
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 3,
					unit = "FBI_shield",
					tactics = self._tactics.shield_wall_charge
				},
				{
					amount_min = 0,
					freq = 1,
					amount_max = 1,
					rank = 2,
					unit = "medic_R870",
					tactics = self._tactics.shield_support_charge
				},
				{
					amount_min = 0,
					freq = 0.35,
					amount_max = 1,
					rank = 3,
					unit = "FBI_heavy_R870",
					tactics = self._tactics.swat_shotgun_flank_complex --pinchy boi
				}
			}
		}
	elseif difficulty_index == 7 then
		self.enemy_spawn_groups.tac_shield_wall_charge = {
			amount = {
				4,
				6
			},
			spawn = {
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.shield_support_charge
				},
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 3,
					unit = "FBI_shield",
					tactics = self._tactics.shield_wall_charge
				},
				{
					amount_min = 0,
					freq = 1,
					amount_max = 1,
					rank = 2,
					unit = "medic_R870",
					tactics = self._tactics.shield_support_charge
				},
				{
					amount_min = 0,
					freq = 0.35,
					amount_max = 1,
					rank = 3,
					unit = "CS_tazer",
					tactics = self._tactics.tazer_flanking --pinch boi
				}
			}
		}
	else
		self.enemy_spawn_groups.tac_shield_wall_charge = {
			amount = {
				4,
				7
			},
			spawn = {
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.shield_support_charge
				},
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 3,
					unit = "FBI_shield",
					tactics = self._tactics.shield_wall_charge
				},
				{
					amount_min = 0,
					freq = 1,
					amount_max = 1,
					rank = 2,
					unit = "medic_R870",
					tactics = self._tactics.shield_support_charge
				},
				{
					amount_min = 0,
					freq = 0.35,
					amount_max = 1,
					rank = 3,
					unit = "CS_tazer",
					tactics = self._tactics.tazer_flanking --pinch boi
				},
				{
					amount_min = 0,
					freq = 0.35,
					amount_max = 1,
					rank = 3,
					unit = "FBI_heavy_G36",
					tactics = self._tactics.swat_rifle --distant support
				}
			}
		}
	end
	
	if Global.game_settings and Global.game_settings.use_intense_AI then
		self.enemy_spawn_groups.tac_shield_wall = {
			amount = {
				6,
				6
			},
			spawn = {
				{
					amount_min = 3,
					freq = 3,
					amount_max = 3,
					rank = 3,
					unit = "FBI_shield",
					tactics = self._tactics.shield_wall
				},
				{
					amount_min = 0,
					freq = 0.8,
					amount_max = 1,
					rank = 2,
					unit = "spooc",
					tactics = self._tactics.spoocaggressiveelite
				},
				{
					amount_min = 0,
					freq = 0.8,
					amount_max = 1,
					rank = 3,
					unit = "FBI_tank",
					tactics = self._tactics.tank_rush
				},
				{
					amount_min = 2,
					freq = 2,
					amount_max = 3,
					rank = 2,
					unit = "FBI_heavy_G36",
					tactics = self._tactics.shield_support_ranged
				}
			}
		}
	elseif difficulty_index <= 2 then
		self.enemy_spawn_groups.tac_shield_wall = {
			amount = {
				4,
				4
			},
			spawn = {{
				amount_min = 4,
				freq = 1,
				amount_max = 4,
				rank = 3,
				unit = "FBI_shield",
				tactics = self._tactics.shield_wall
			}}
		}
	elseif difficulty_index == 3 then
		self.enemy_spawn_groups.tac_shield_wall = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					amount_min = 2,
					freq = 1,
					amount_max = 2,
					rank = 3,
					unit = "FBI_shield",
					tactics = self._tactics.shield_wall
				},
				{
					amount_min = 2,
					freq = 1,
					amount_max = 2,
					rank = 2,
					unit = "CS_heavy_R870",
					tactics = self._tactics.shield_support_charge
				}
			}
		}
	elseif difficulty_index == 4 then
		self.enemy_spawn_groups.tac_shield_wall = {
			amount = {
				4,
				4
			},
			spawn = {
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 3,
					unit = "FBI_shield",
					tactics = self._tactics.shield_wall
				},
				{
					amount_min = 2,
					freq = 2,
					amount_max = 2,
					rank = 3,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_rush_civil
				}
			}
		}
	elseif difficulty_index == 5 then
		self.enemy_spawn_groups.tac_shield_wall = { --like im sorry but what the fuck is this spawn group actually supposed to be, gameplay-wise, what does it even do that the other shield spawn groups dont????
			amount = {
				6,
				6
			},
			spawn = {
				{
					amount_min = 3,
					freq = 3,
					amount_max = 3,
					rank = 3,
					unit = "FBI_shield",
					tactics = self._tactics.shield_wall
				},
				{
					amount_min = 3,
					freq = 1,
					amount_max = 3,
					rank = 3,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_rush_civil
				}
			}
		}
	elseif difficulty_index == 6 then
		self.enemy_spawn_groups.tac_shield_wall = {
			amount = {
				6,
				6
			},
			spawn = {
				{
					amount_min = 3,
					freq = 3,
					amount_max = 3,
					rank = 3,
					unit = "FBI_shield",
					tactics = self._tactics.shield_wall
				},
				{
					amount_min = 2,
					freq = 1,
					amount_max = 3,
					rank = 2,
					unit = "FBI_swat_M4",
					tactics = self._tactics.shield_support_ranged
				},
				{
					amount_min = 0,
					freq = 0.25,
					amount_max = 1,
					rank = 2,
					unit = "spooc",
					tactics = self._tactics.spoocaggressive
				},
			}
		}
	elseif difficulty_index == 7 then
		self.enemy_spawn_groups.tac_shield_wall = {
			amount = {
				6,
				6
			},
			spawn = {
				{
					amount_min = 3,
					freq = 3,
					amount_max = 3,
					rank = 3,
					unit = "FBI_shield",
					tactics = self._tactics.shield_wall
				},
				{
					amount_min = 2,
					freq = 1,
					amount_max = 3,
					rank = 2,
					unit = "FBI_heavy_G36",
					tactics = self._tactics.shield_support_ranged
				},
				{
					amount_min = 0,
					freq = 0.6,
					amount_max = 1,
					rank = 2,
					unit = "spooc",
					tactics = self._tactics.spoocaggressive
				}
			}
		}
	else
		self.enemy_spawn_groups.tac_shield_wall = {
			amount = {
				6,
				6
			},
			spawn = {
				{
					amount_min = 3,
					freq = 3,
					amount_max = 3,
					rank = 3,
					unit = "FBI_shield",
					tactics = self._tactics.shield_wall
				},
				{
					amount_min = 0,
					freq = 0.8,
					amount_max = 1,
					rank = 2,
					unit = "spooc",
					tactics = self._tactics.spoocaggressiveelite
				},
				{
					amount_min = 0,
					freq = 0.8,
					amount_max = 1,
					rank = 3,
					unit = "FBI_tank",
					tactics = self._tactics.tank_rush
				},
				{
					amount_min = 2,
					freq = 2,
					amount_max = 3,
					rank = 2,
					unit = "FBI_heavy_G36",
					tactics = self._tactics.shield_support_ranged
				}
			}
		}
	end
	
	if Global.game_settings and Global.game_settings.use_intense_AI then
		self.enemy_spawn_groups.tac_tazer_flanking = {
			amount = {
				1,
				4
			},
			spawn = {
				{
					amount_min = 1,
					freq = 2,
					amount_max = 2,
					rank = 2,
					unit = "CS_tazer",
					tactics = self._tactics.tazer_flanking
				},
				{
					freq = 0.5,
					rank = 1,
					unit = "FBI_suit_M4_MP5",
					tactics = self._tactics.swat_rifle_civil
				},
				{
					amount_min = 0,
					freq = 0.2,
					amount_max = 1,
					rank = 2,
					unit = "spooc",
					tactics = self._tactics.spoocelite
				},
				{
					amount_min = 0,
					freq = 1,
					amount_max = 1,
					rank = 2,
					unit = "medic_M4",
					tactics = self._tactics.swat_rifle_flank_civil
				}
			}
		}
	elseif difficulty_index <= 2 then
		self.enemy_spawn_groups.tac_tazer_flanking = {
			amount = {
				1,
				1
			},
			spawn = {{
				amount_min = 1,
				freq = 1,
				amount_max = 1,
				rank = 3,
				unit = "CS_tazer",
				tactics = self._tactics.tazer_flanking
			}}
		}
	elseif difficulty_index == 3 then
		self.enemy_spawn_groups.tac_tazer_flanking = {
			amount = {
				1,
				1
			},
			spawn = {{
				amount_min = 1,
				freq = 1,
				amount_max = 1,
				rank = 3,
				unit = "CS_tazer",
				tactics = self._tactics.tazer_flanking
			}}
		}
	elseif difficulty_index == 4 then
		self.enemy_spawn_groups.tac_tazer_flanking = {
			amount = {
				1,
				1
			},
			spawn = {{
				amount_min = 1,
				freq = 1,
				amount_max = 1,
				rank = 3,
				unit = "CS_tazer",
				tactics = self._tactics.tazer_flanking
			}}
		}
	elseif difficulty_index == 5 then
		self.enemy_spawn_groups.tac_tazer_flanking = {
			amount = {
				1,
				4
			},
			spawn = {
				{
					amount_min = 1,
					freq = 1,
					amount_max = 1,
					rank = 3,
					unit = "CS_tazer",
					tactics = self._tactics.tazer_flanking
				},
				{
					freq = 0.5,
					rank = 1,
					unit = "FBI_suit_M4_MP5",
					tactics = self._tactics.swat_rifle_civil
				}
			}
		}
	elseif difficulty_index == 6 then
		self.enemy_spawn_groups.tac_tazer_flanking = {
			amount = {
				1,
				4
			},
			spawn = {
				{
					amount_min = 1,
					freq = 2,
					amount_max = 1,
					rank = 2,
					unit = "CS_tazer",
					tactics = self._tactics.tazer_flanking
				},
				{
					freq = 0.5,
					rank = 1,
					unit = "FBI_suit_M4_MP5",
					tactics = self._tactics.swat_rifle_civil
				},
				{
					amount_min = 0,
					freq = 0.15,
					amount_max = 1,
					rank = 2,
					unit = "spooc",
					tactics = self._tactics.spooc
				},
				{
					freq = 0.3,
					rank = 1,
					unit = "FBI_swat_M4",
					tactics = self._tactics.swat_rifle_flank
				}
			}
		}
	elseif difficulty_index == 7 then
		self.enemy_spawn_groups.tac_tazer_flanking = {
			amount = {
				1,
				4
			},
			spawn = {
				{
					amount_min = 1,
					freq = 2,
					amount_max = 2,
					rank = 2,
					unit = "CS_tazer",
					tactics = self._tactics.tazer_flanking
				},
				{
					freq = 0.5,
					rank = 1,
					unit = "FBI_suit_M4_MP5",
					tactics = self._tactics.swat_rifle_civil
				},
				{
					amount_min = 0,
					freq = 0.2,
					amount_max = 1,
					rank = 2,
					unit = "spooc",
					tactics = self._tactics.spooc
				},
				{
					amount_min = 0,
					freq = 1,
					amount_max = 1,
					rank = 2,
					unit = "medic_M4",
					tactics = self._tactics.swat_rifle_flank_civil
				}
			}
		}
	else
		self.enemy_spawn_groups.tac_tazer_flanking = {
			amount = {
				1,
				4
			},
			spawn = {
				{
					amount_min = 1,
					freq = 2,
					amount_max = 2,
					rank = 2,
					unit = "CS_tazer",
					tactics = self._tactics.tazer_flanking
				},
				{
					freq = 0.5,
					rank = 1,
					unit = "FBI_suit_M4_MP5",
					tactics = self._tactics.swat_rifle_civil
				},
				{
					amount_min = 0,
					freq = 0.2,
					amount_max = 1,
					rank = 2,
					unit = "spooc",
					tactics = self._tactics.spoocelite
				},
				{
					amount_min = 0,
					freq = 1,
					amount_max = 1,
					rank = 2,
					unit = "medic_M4",
					tactics = self._tactics.swat_rifle_flank_civil
				}
			}
		}
	end

	if Global.game_settings and Global.game_settings.use_intense_AI then
		self.enemy_spawn_groups.tac_tazer_charge = {
			amount = {
				1,
				5
			},
			spawn = {
				{
					amount_min = 1,
					freq = 2,
					amount_max = 2,
					rank = 2,
					unit = "CS_tazer",
					tactics = self._tactics.shield_support_charge
				},
				{
					freq = 0.5,
					rank = 1,
					unit = "FBI_suit_M4_MP5",
					tactics = self._tactics.swat_rifle_flank_civil
				},
				{
					freq = 0.5,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.shield_support_charge
				},
				{
					amount_min = 0,
					freq = 0.25,
					amount_max = 1,
					rank = 3,
					unit = "FBI_tank",
					tactics = self._tactics.tank_rush
				},
				{
					amount_min = 0,
					freq = 0.35,
					amount_max = 1,
					rank = 4,
					unit = "FBI_shield",
					tactics = self._tactics.shield_wall_charge
				}
			}
		}
	elseif difficulty_index <= 2 then
		self.enemy_spawn_groups.tac_tazer_charge = {
			amount = {
				1,
				1
			},
			spawn = {{
				amount_min = 1,
				freq = 1,
				amount_max = 1,
				rank = 3,
				unit = "CS_tazer",
				tactics = self._tactics.tazer_charge
			}}
		}
	elseif difficulty_index == 3 then
		self.enemy_spawn_groups.tac_tazer_charge = {
			amount = {
				1,
				1
			},
			spawn = {{
				amount_min = 1,
				freq = 1,
				amount_max = 1,
				rank = 3,
				unit = "CS_tazer",
				tactics = self._tactics.tazer_charge
			}}
		}
	elseif difficulty_index == 4 then
		self.enemy_spawn_groups.tac_tazer_charge = {
			amount = {
				1,
				1
			},
			spawn = {{
				amount_min = 1,
				freq = 1,
				amount_max = 1,
				rank = 3,
				unit = "CS_tazer",
				tactics = self._tactics.tazer_charge
			}}
		}
	elseif difficulty_index == 5 then
		self.enemy_spawn_groups.tac_tazer_charge = {
			amount = {
				1,
				1
			},
			spawn = {{
				amount_min = 1,
				freq = 1,
				amount_max = 1,
				rank = 3,
				unit = "CS_tazer",
				tactics = self._tactics.tazer_charge
			}}
		}
	elseif difficulty_index == 6 then
		self.enemy_spawn_groups.tac_tazer_charge = {
			amount = {
				1,
				4
			},
			spawn = {
				{
					amount_min = 1,
					freq = 1,
					amount_max = 2,
					rank = 3,
					unit = "CS_tazer",
					tactics = self._tactics.tazer_charge
				},
				{
					freq = 0.5,
					rank = 2,
					unit = "FBI_suit_M4_MP5",
					tactics = self._tactics.swat_rifle_flank_civil
				},
				{
					amount_min = 0,
					freq = 0.15,
					amount_max = 1,
					rank = 1,
					unit = "FBI_tank",
					tactics = self._tactics.tank_rush
				}
			}
		}
	else
		self.enemy_spawn_groups.tac_tazer_charge = {
			amount = {
				1,
				5
			},
			spawn = {
				{
					amount_min = 1,
					freq = 2,
					amount_max = 2,
					rank = 2,
					unit = "CS_tazer",
					tactics = self._tactics.shield_support_charge
				},
				{
					freq = 0.5,
					rank = 1,
					unit = "FBI_suit_M4_MP5",
					tactics = self._tactics.swat_rifle_flank_civil
				},
				{
					freq = 0.5,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.shield_support_charge
				},
				{
					amount_min = 0,
					freq = 0.25,
					amount_max = 1,
					rank = 3,
					unit = "FBI_tank",
					tactics = self._tactics.tank_rush
				},
				{
					amount_min = 0,
					freq = 0.35,
					amount_max = 1,
					rank = 4,
					unit = "FBI_shield",
					tactics = self._tactics.shield_wall_charge
				}
			}
		}
	end
	
	if Global.game_settings and Global.game_settings.use_intense_AI then
		self.enemy_spawn_groups.tac_bull_rush = {
			amount = {
				1,
				5
			},
			spawn = {
				{
					amount_min = 1,
					freq = 1,
					amount_max = 2,
					rank = 2,
					unit = "FBI_tank",
					tactics = self._tactics.tank_rush
				},
				{
					amount_min = 0,
					freq = 2,
					amount_max = 2,
					rank = 3,
					unit = "FBI_shield",
					tactics = self._tactics.shield_wall_charge
				},
				{
					freq = 0.5,
					rank = 2,
					unit = "FBI_heavy_R870",
					tactics = self._tactics.tank_rush
				},
				{
					amount_min = 0,
					freq = 1,
					amount_max = 1,
					rank = 1,
					unit = "medic_R870",
					tactics = self._tactics.tank_rush
				}
			}
		}
	elseif difficulty_index <= 2 then
		self.enemy_spawn_groups.tac_bull_rush = {
			amount = {
				1,
				1
			},
			spawn = {{
				amount_min = 1,
				freq = 1,
				amount_max = 1,
				rank = 3,
				unit = "FBI_tank",
				tactics = self._tactics.tank_rush
			}}
		}
	elseif difficulty_index == 3 then
		self.enemy_spawn_groups.tac_bull_rush = {
			amount = {
				1,
				1
			},
			spawn = {{
				amount_min = 1,
				freq = 1,
				amount_max = 1,
				rank = 3,
				unit = "FBI_tank",
				tactics = self._tactics.tank_rush
			}}
		}
	elseif difficulty_index == 4 then
		self.enemy_spawn_groups.tac_bull_rush = {
			amount = {
				1,
				1
			},
			spawn = {{
				amount_min = 1,
				freq = 1,
				amount_max = 1,
				rank = 3,
				unit = "FBI_tank",
				tactics = self._tactics.tank_rush
			}}
		}
	elseif difficulty_index == 5 then
		self.enemy_spawn_groups.tac_bull_rush = {
			amount = {
				1,
				2
			},
			spawn = {
			{
				amount_min = 1,
				freq = 1,
				amount_max = 1,
				rank = 3,
				unit = "FBI_tank",
				tactics = self._tactics.tank_rush
			},
			{
				amount_min = 0,
				freq = 1,
				amount_max = 1,
				rank = 2,
				unit = "medic_R870",
				tactics = self._tactics.tank_rush
			}
		}
	}
	elseif difficulty_index == 6 then
		self.enemy_spawn_groups.tac_bull_rush = {
			amount = {
				1,
				3
			},
			spawn = {
				{
					amount_min = 1,
					freq = 1,
					amount_max = 2,
					rank = 3,
					unit = "FBI_tank",
					tactics = self._tactics.tank_rush
				},
				{
					amount_min = 0,
					freq = 1,
					amount_max = 1,
					rank = 2,
					unit = "medic_R870",
					tactics = self._tactics.tank_rush
				}
			}
		}
	else
		self.enemy_spawn_groups.tac_bull_rush = {
			amount = {
				1,
				5
			},
			spawn = {
				{
					amount_min = 1,
					freq = 1,
					amount_max = 2,
					rank = 2,
					unit = "FBI_tank",
					tactics = self._tactics.tank_rush
				},
				{
					amount_min = 0,
					freq = 2,
					amount_max = 2,
					rank = 3,
					unit = "FBI_shield",
					tactics = self._tactics.shield_wall_charge
				},
				{
					freq = 0.5,
					rank = 2,
					unit = "FBI_heavy_R870",
					tactics = self._tactics.tank_rush
				},
				{
					amount_min = 0,
					freq = 1,
					amount_max = 1,
					rank = 1,
					unit = "medic_R870",
					tactics = self._tactics.tank_rush
				}
			}
		}
	end

	self.enemy_spawn_groups.Phalanx = {
		amount = {
			self.phalanx.minions.amount + 1,
			self.phalanx.minions.amount + 1
		},
		spawn = {
			{
				amount_min = 1,
				freq = 1,
				amount_max = 1,
				rank = 2,
				unit = "Phalanx_vip",
				tactics = self._tactics.Phalanx_vip
			},
			{
				freq = 1,
				amount_min = 1,
				rank = 1,
				unit = "Phalanx_minion",
				tactics = self._tactics.Phalanx_minion
			}
		}
	}
	
	--have to work with this unholy mess of bile because otherwise, cloakers don't spawn right
	if Global.game_settings and Global.game_settings.use_intense_AI then
		self.enemy_spawn_groups.FBI_spoocs = {
			amount = {
				2, --guaranteed two on DS
				3 
			},
			spawn = {
				{
					freq = 1.25,
					rank = 1,
					unit = "spooc",
					tactics = self._tactics.spoocelite
				},
				{
					freq = 1.25,
					rank = 1,
					unit = "spooc",
					tactics = self._tactics.spoocaggressiveelite
				},
				{
					freq = 1.25,
					rank = 1,
					unit = "spooc",
					tactics = self._tactics.spooccreep --pretty much jerks, they'll hide from sight once aimed at, will otherwise attempt to rush you
				}
			}
		}
	elseif difficulty_index <= 4 then
		self.enemy_spawn_groups.FBI_spoocs = {
			amount = {
				1,
				1
			},
			spawn = {
				{
					freq = 1,
					amount_min = 1,
					rank = 1,
					unit = "spooc",
					tactics = self._tactics.spooc
				}
			}
		}
	elseif difficulty_index == 5 then
		self.enemy_spawn_groups.FBI_spoocs = {
			amount = {
				1,
				2
			},
			spawn = {
				{
					freq = 1.5,
					rank = 1,
					unit = "spooc",
					tactics = self._tactics.spooc
				}
			}
		}
	elseif difficulty_index == 6 then
		self.enemy_spawn_groups.FBI_spoocs = {
			amount = {
				1,
				2
			},
			spawn = {
				{
					freq = 1.5,
					rank = 1,
					unit = "spooc",
					tactics = self._tactics.spooc
				},
				{
					freq = 1.5,
					rank = 1,
					unit = "spooc",
					tactics = self._tactics.spoocaggressive --these spoocs go hard instead of their normal approach, and use flashes, essentially randomly a pinch group
				}
			}
		}
	elseif difficulty_index == 7 then
		self.enemy_spawn_groups.FBI_spoocs = {
			amount = {
				1,
				3 --fucking power rangers insta-down squad bullshit
			},
			spawn = {
				{
					freq = 1.5,
					rank = 1,
					unit = "spooc",
					tactics = self._tactics.spooc
				},
				{
					freq = 1.5,
					rank = 1,
					unit = "spooc",
					tactics = self._tactics.spoocaggressive --these spoocs go hard instead of their normal approach, and use flashes, essentially randomly a pinch group
				}
			}
		}
	else
		self.enemy_spawn_groups.FBI_spoocs = {
			amount = {
				2, --guaranteed two on DS
				3 
			},
			spawn = {
				{
					freq = 1.25,
					rank = 1,
					unit = "spooc",
					tactics = self._tactics.spoocelite
				},
				{
					freq = 1.25,
					rank = 1,
					unit = "spooc",
					tactics = self._tactics.spoocaggressiveelite
				},
				{
					freq = 1.25,
					rank = 1,
					unit = "spooc",
					tactics = self._tactics.spooccreep --pretty much jerks, they'll hide from sight once aimed at, will otherwise attempt to rush you
				}
			}
		}
	end
end)

Hooks:PostHook(GroupAITweakData, "_init_task_data", "cock_init_task_data", function(self, difficulty_index, difficulty)
	local is_console = SystemInfo:platform() ~= Idstring("WIN32")
	local level = Global.level_data and Global.level_data.level_id
	self.max_nr_simultaneous_boss_types = 0
	self.difficulty_curve_points = {
		0.5
	}

	if difficulty_index < 6 then
		self.smoke_and_flash_grenade_timeout = {
			25,
			18
		}
	else
		self.smoke_and_flash_grenade_timeout = {
			20,
			15
		}
	end

	if difficulty_index < 6 then
		self.smoke_grenade_lifetime = 7.5
	else
		self.smoke_grenade_lifetime = 12
	end

	self.flash_grenade_lifetime = 7.5
	self.flash_grenade = {
		timer = 3,
		light_range = 300,
		range = 1000,
		light_specular = 1,
		beep_fade_speed = 4,
		beep_multi = 0.3,
		light_color = Vector3(255, 0, 0),
		beep_speed = {
			0.1,
			0.025
		}
	}

	if difficulty_index <= 5 then
		self.flash_grenade.timer = 3
	elseif difficulty_index == 6 then
		self.flash_grenade.timer = 2
	elseif difficulty_index == 7 then
		self.flash_grenade.timer = 2
	else
		self.flash_grenade.timer = 1.35
	end

	self.optimal_trade_distance = {
		0,
		0
	}
	self.bain_assault_praise_limits = {
		1,
		3
	}

	if difficulty_index <= 2 then
		self.besiege.recurring_group_SO = {
			recurring_cloaker_spawn = {
				retire_delay = 30,
				interval = {
					180,
					300
				}
			},
			recurring_spawn_1 = {
				interval = {
					30,
					60
				}
			}
		}
	elseif difficulty_index == 3 then
		self.besiege.recurring_group_SO = {
			recurring_cloaker_spawn = {
				retire_delay = 30,
				interval = {
					60,
					120
				}
			},
			recurring_spawn_1 = {
				interval = {
					30,
					60
				}
			}
		}
	elseif difficulty_index == 4 then
		self.besiege.recurring_group_SO = {
			recurring_cloaker_spawn = {
				retire_delay = 30,
				interval = {
					45,
					60
				}
			},
			recurring_spawn_1 = {
				interval = {
					30,
					60
				}
			}
		}
	elseif difficulty_index == 5 then
		self.besiege.recurring_group_SO = {
			recurring_cloaker_spawn = {
				retire_delay = 30,
				interval = {
					20,
					40
				}
			},
			recurring_spawn_1 = {
				interval = {
					30,
					60
				}
			}
		}
	else
		self.besiege.recurring_group_SO = {
			recurring_cloaker_spawn = {
				retire_delay = 30,
				interval = {
					15,
					30
				}
			},
			recurring_spawn_1 = {
				interval = {
					30,
					60
				}
			}
		}
	end

	self.besiege.regroup.duration = {
		20,
		20,
		20
	}
	self.besiege.assault = {
		anticipation_duration = {
			{
				25,
				1
			},
			{
				25,
				1
			},
			{
				25,
				1
			}
		},
		build_duration = 35,
		sustain_duration_min = {
			240,
			240,
			240
		},
		sustain_duration_max = {
			240,
			240,
			240
		},
		sustain_duration_balance_mul = {
			1,
			1,
			1,
			1
		},
		fade_duration = 30
	}

	if difficulty_index <= 2 then
		self.besiege.assault.delay = {
			45,
			35,
			30
		}
	elseif difficulty_index == 3 then
		self.besiege.assault.delay = {
			45,
			35,
			30
		}
	elseif difficulty_index == 4 then
		self.besiege.assault.delay = {
			45,
			35,
			30
		}
	elseif difficulty_index == 5 then
		self.besiege.assault.delay = {
			45,
			35,
			30
		}
	else
		self.besiege.assault.delay = {
			45,
			35,
			30
		}
	end

	if difficulty_index <= 5 then
		self.besiege.assault.hostage_hesitation_delay = {
			20,
			20,
			20
		}
	else
		self.besiege.assault.hostage_hesitation_delay = {
			15,
			15,
			15
		}
	end

	if level == "sah" or level == "chew" or level == "help" or level == "peta" then
		self.besiege.assault.force = {
			1,
			1,
			1
		}
		self.besiege.assault.force_pool = {
			75,
			75,
			75
		}
	else
		self.besiege.assault.force = {
			16,
			16,
			16
		}
		self.besiege.assault.force_pool = {
			125,
			125,
			125
		}
	end

	if level == "sah" or level == "chew" or level == "help" or level == "peta" then
		if difficulty_index <= 7 then
			self.besiege.assault.force_balance_mul = {
				16,
				20,
				24,
				24
			}
			self.besiege.assault.force_pool_balance_mul = {
				1,
				2,
				3,
				4
			}
		else
			self.besiege.assault.force_balance_mul = {
				20,
				24,
				32,
				32
			}
			self.besiege.assault.force_pool_balance_mul = {
				1,
				2,
				3,
				4
			}
		end
	elseif difficulty_index <= 7 then
		self.besiege.assault.force_balance_mul = {
			1.25,
			2.5,
			4,
			4
		}
		self.besiege.assault.force_pool_balance_mul = {
			1,
			2,
			3,
			4
		}
	else
		self.besiege.assault.force_balance_mul = {
			1.5,
			3,
			4.5,
			4.5
		}
		self.besiege.assault.force_pool_balance_mul = {
			1,
			2,
			3,
			4
		}
	end

	if difficulty_index <= 2 then
		self.besiege.assault.groups = {
			tac_swat_shotgun_rush = {
				11,
				11,
				11
			},
			tac_swat_shotgun_flank = {
				11,
				11,
				11
			},
			tac_swat_rifle = {
				15,
				15,
				15
			},
			tac_swat_rifle_flank = {
				15,
				15,
				15
			},
			punks_A = {
				4,
				4,
				4
			},
			punks_B = {
				4,
				4,
				4
			},
			punks_C = {
				4,
				4,
				4
			},
			tac_shield_wall_ranged = {
				16,
				16,
				16
			},
			tac_shield_wall_charge = {
				0,
				0,
				0
			},
			tac_shield_wall = {
				0,
				0,
				0
			},
			tac_tazer_flanking = {
				20,
				20,
				20
			},
			tac_tazer_charge = {
				0,
				0,
				0
			},
			single_spooc = {
				0,
				0,
				0
			},
			tac_bull_rush = {
				0,
				0,
				0
			}
		}
	elseif difficulty_index == 3 then
		self.besiege.assault.groups = {
			tac_swat_shotgun_rush = {
				9,
				9,
				9
			},
			tac_swat_shotgun_flank = {
				9,
				9,
				9
			},
			tac_swat_rifle = {
				10,
				10,
				10
			},
			tac_swat_rifle_flank = {
				10,
				10,
				10
			},
			punks_A = {
				4,
				4,
				4
			},
			punks_B = {
				4,
				4,
				4
			},
			punks_C = {
				4,
				4,
				4
			},
			tac_shield_wall_ranged = {
				10,
				10,
				10
			},
			tac_shield_wall_charge = {
				9.1,
				9.1,
				9.1
			},
			tac_shield_wall = {
				7,
				7,
				7
			},
			tac_tazer_flanking = {
				7,
				7,
				7
			},
			tac_tazer_charge = {
				7,
				7,
				7
			},
			single_spooc = {
				0,
				0,
				0
			},
			tac_bull_rush = {
				10,
				10,
				10
			}
		}
	elseif difficulty_index == 4 then
		self.besiege.assault.groups = {
			tac_swat_shotgun_rush = {
				14,
				14,
				14
			},
			tac_swat_shotgun_flank = {
				14,
				14,
				14
			},
			tac_swat_rifle = {
				15,
				15,
				15
			},
			tac_swat_rifle_flank = {
				15,
				15,
				15
			},
			punks_A = {
				3,
				3,
				3
			},
			punks_B = {
				3,
				3,
				3
			},
			punks_C = {
				3,
				3,
				3
			},
			tac_shield_wall_ranged = {
				3,
				3,
				3
			},
			tac_shield_wall_charge = {
				3,
				3,
				3
			},
			tac_shield_wall = {
				3,
				3,
				3
			},
			tac_tazer_flanking = {
				5.5,
				5.5,
				5.5
			},
			tac_tazer_charge = {
				5.5,
				5.5,
				5.5
			},
			FBI_spoocs = {
				6,
				6,
				6
			},
			tac_bull_rush = {
				7,
				7,
				7,
			}
		}
	elseif difficulty_index == 5 then
		self.besiege.assault.groups = {
			tac_swat_shotgun_rush = {
				13.05,
				13.05,
				13.05
			},
			tac_swat_shotgun_flank = {
				13.05,
				13.05,
				13.05
			},
			tac_swat_rifle = {
				13.2,
				13.2,
				13.2
			},
			tac_swat_rifle_flank = {
				13.2,
				13.2,
				13.2
			},
			punks_A = {
				5,
				5,
				5
			},
			punks_B = {
				5,
				5,
				5
			},
			punks_C = {
				5,
				5,
				5
			},
			tac_shield_wall_ranged = {
				3,
				3,
				3
			},
			tac_shield_wall_charge = {
				3,
				3,
				3
			},
			tac_shield_wall = {
				3,
				3,
				3
			},
			tac_tazer_flanking = {
				5.25,
				5.25,
				5.25
			},
			tac_tazer_charge = {
				5.25,
				5.25,
				5.25
			},
			FBI_spoocs = {
				6.50,
				6.50,
				6.50
			},
			tac_bull_rush = {
				6.50,
				6.50,
				6.50
			}
		}
	elseif difficulty_index == 6 then
		self.besiege.assault.groups = {
			tac_swat_shotgun_rush = {
				13.05,
				13.05,
				13.05
			},
			tac_swat_shotgun_flank = {
				13.05,
				13.05,
				13.05
			},
			tac_swat_rifle = {
				13.2,
				13.2,
				13.2
			},
			tac_swat_rifle_flank = {
				13.2,
				13.2,
				13.2
			},
			punks_A = {
				5,
				5,
				5
			},
			punks_B = {
				5,
				5,
				5
			},
			punks_C = {
				5,
				5,
				5
			},
			tac_shield_wall_ranged = {
				3,
				3,
				3
			},
			tac_shield_wall_charge = {
				3,
				3,
				3
			},
			tac_shield_wall = {
				3,
				3,
				3
			},
			tac_tazer_flanking = {
				5.25,
				5.25,
				5.25
			},
			tac_tazer_charge = {
				5.25,
				5.25,
				5.25
			},
			FBI_spoocs = {
				6.50,
				6.50,
				6.50
			},
			tac_bull_rush = {
				6.50,
				6.50,
				6.50
			}
		}
	elseif difficulty_index == 7 then
		self.besiege.assault.groups = {
			tac_swat_shotgun_rush = {
				13.05,
				13.05,
				13.05
			},
			tac_swat_shotgun_flank = {
				13.05,
				13.05,
				13.05
			},
			tac_swat_rifle = {
				13.2,
				13.2,
				13.2
			},
			tac_swat_rifle_flank = {
				13.2,
				13.2,
				13.2
			},
			punks_A = {
				5,
				5,
				5
			},
			punks_B = {
				5,
				5,
				5
			},
			punks_C = {
				5,
				5,
				5
			},
			tac_shield_wall_ranged = {
				3,
				3,
				3
			},
			tac_shield_wall_charge = {
				3,
				3,
				3
			},
			tac_shield_wall = {
				3,
				3,
				3
			},
			tac_tazer_flanking = {
				5.25,
				5.25,
				5.25
			},
			tac_tazer_charge = {
				5.25,
				5.25,
				5.25
			},
			FBI_spoocs = {
				6.50,
				6.50,
				6.50
			},
			tac_bull_rush = {
				6.50,
				6.50,
				6.50
			}
		}
	elseif difficulty_index == 8 then
		self.besiege.assault.groups = {
			tac_swat_shotgun_rush = {
				13.05,
				13.05,
				13.05
			},
			tac_swat_shotgun_flank = {
				13.05,
				13.05,
				13.05
			},
			tac_swat_rifle = {
				13.2,
				13.2,
				13.2
			},
			tac_swat_rifle_flank = {
				13.2,
				13.2,
				13.2
			},
			punks_A = {
				5,
				5,
				5
			},
			punks_B = {
				5,
				5,
				5
			},
			punks_C = {
				5,
				5,
				5
			},
			tac_shield_wall_ranged = {
				3,
				3,
				3
			},
			tac_shield_wall_charge = {
				3,
				3,
				3
			},
			tac_shield_wall = {
				3,
				3,
				3
			},
			tac_tazer_flanking = {
				5.25,
				5.25,
				5.25
			},
			tac_tazer_charge = {
				5.25,
				5.25,
				5.25
			},
			FBI_spoocs = {
				6.50,
				6.50,
				6.50
			},
			tac_bull_rush = {
				6.50,
				6.50,
				6.50
			}
		}
	else
		self.besiege.assault.groups = {
			tac_swat_shotgun_rush = {
				13.05,
				13.05,
				13.05
			},
			tac_swat_shotgun_flank = {
				13.05,
				13.05,
				13.05
			},
			tac_swat_rifle = {
				13.2,
				13.2,
				13.2
			},
			tac_swat_rifle_flank = {
				13.2,
				13.2,
				13.2
			},
			punks_A = {
				5,
				5,
				5
			},
			punks_B = {
				5,
				5,
				5
			},
			punks_C = {
				5,
				5,
				5
			},
			tac_shield_wall_ranged = {
				3,
				3,
				3
			},
			tac_shield_wall_charge = {
				3,
				3,
				3
			},
			tac_shield_wall = {
				3,
				3,
				3
			},
			tac_tazer_flanking = {
				5.25,
				5.25,
				5.25
			},
			tac_tazer_charge = {
				5.25,
				5.25,
				5.25
			},
			FBI_spoocs = {
				6.50,
				6.50,
				6.50
			},
			tac_bull_rush = {
				6.50,
				6.50,
				6.50
			}
		}
	end
	
	self.besiege.assault.groups.single_spooc = {
		0,
		0,
		0
	}
	self.besiege.assault.groups.Phalanx = {
		0,
		0,
		0
	}
	self.besiege.reenforce.interval = {
		5,
		5,
		5
	}

	if difficulty_index <= 2 then
		self.besiege.reenforce.groups = {
			punks_A = {
				25,
				25,
				25
			},
			tac_swat_shotgun_flank = {
				25,
				25,
				25
			},
			punks_B = {
				25,
				25,
				25
			},
			tac_swat_rifle_flank = {
				25,
				25,
				25
			}
		}
	elseif difficulty_index == 3 then
		self.besiege.reenforce.groups = {
			tac_swat_shotgun_rush = {
				25,
				25,
				25
			},
			punks_C = {
				25,
				25,
				25
			},
			tac_swat_rifle = {
				25,
				25,
				25
			},
			punks_B = {
				25,
				25,
				25
			}
		}
	elseif difficulty_index == 4 then
		self.besiege.reenforce.groups = {
			tac_swat_shotgun_rush = {
				22.5,
				22.5,
				22.5
			},
			tac_swat_shotgun_flank = {
				20,
				20,
				20
			},
			tac_swat_rifle = {
				22.5,
				22.5,
				22.5
			},
			tac_swat_rifle_flank = {
				20,
				20,
				20
			},
			punks_A = {
				7.5,
				7.5,
				7.5
			},
			punks_B = {
				7.5,
				7.5,
				7.5
			}
		}
	elseif difficulty_index == 5 then
		self.besiege.reenforce.groups = {
			tac_swat_shotgun_rush = {
				22.5,
				22.5,
				22.5
			},
			tac_swat_shotgun_flank = {
				20,
				20,
				20
			},
			tac_swat_rifle = {
				22.5,
				22.5,
				22.5
			},
			tac_swat_rifle_flank = {
				20,
				20,
				20
			},
			punks_A = {
				7.5,
				7.5,
				7.5
			},
			punks_B = {
				7.5,
				7.5,
				7.5
			}
		}
	else
		self.besiege.reenforce.groups = {
			tac_swat_shotgun_rush = {
				22.5,
				22.5,
				22.5
			},
			tac_swat_shotgun_flank = {
				20,
				20,
				20
			},
			tac_swat_rifle = {
				22.5,
				22.5,
				22.5
			},
			tac_swat_rifle_flank = {
				20,
				20,
				20
			},
			punks_A = {
				7.5,
				7.5,
				7.5
			},
			punks_B = {
				7.5,
				7.5,
				7.5
			}
		}
	end

	self.besiege.recon.interval = {
		10,
		10,
		10
	}
	self.besiege.recon.interval_variation = 20

	if difficulty_index < 6 then
		self.besiege.recon.force = {
			4,
			4,
			4
		}
	else
		self.besiege.recon.force = {
			6,
			6,
			6
		}
	end

	if difficulty_index <= 2 then
		self.besiege.recon.groups = {
			tac_swat_shotgun_flank = {
				30,
				30,
				30
			},
			punks_A = {
				20,
				20,
				20
			},
			punks_B = {
				20,
				20,
				20
			},
			tac_swat_rifle_flank = {
				30,
				30,
				30
			}
		}
	elseif difficulty_index == 3 then
		self.besiege.recon.groups = {
			tac_swat_shotgun_flank = {
				30,
				30,
				30
			},
			punks_A = {
				20,
				20,
				20
			},
			punks_B = {
				20,
				20,
				20
			},
			tac_swat_rifle_flank = {
				30,
				30,
				30
			}
		}
	elseif difficulty_index == 4 then
		self.besiege.recon.groups = {
			tac_swat_shotgun_flank = {
				30,
				30,
				30
			},
			punks_A = {
				20,
				20,
				20
			},
			punks_B = {
				20,
				20,
				20
			},
			tac_swat_rifle_flank = {
				30,
				30,
				30
			}
		}
	elseif difficulty_index == 5 then
		self.besiege.recon.groups = {
			FBI_spoocs = {
				12.5,
				12.5,
				12.5
			},
			tac_tazer_flanking = {
				12.5,
				12.5,
				12.5
			},
			punks_A = {
				12.5,
				12.5,
				12.5
			},
			punks_B = {
				12.5,
				12.5,
				12.5
			},
			tac_swat_shotgun_flank = {
				25,
				25,
				25
			},
			tac_swat_rifle_flank = {
				25,
				25,
				25
			}
		}
	else
		self.besiege.recon.groups = {
			tac_tazer_flanking = {
				15,
				15,
				15
			},
			punks_C = {
				15,
				15,
				15
			},
			punks_B = {
				15,
				15,
				15
			},
			tac_swat_shotgun_flank = {
				19,
				19,
				19
			},
			tac_tazer_charge = {
				15,
				15,
				15
			},
			FBI_spoocs = {
				15,
				15,
				15
			},
			tac_swat_rifle_flank = {
				19,
				19,
				19
			}
		}
	end

	self.besiege.recon.groups.single_spooc = {
		0,
		0,
		0
	}
	self.besiege.recon.groups.Phalanx = {
		0,
		0,
		0
	}
	self.besiege.cloaker.groups = {
		single_spooc = {
			1,
			1,
			1
		}
	}
	self.street = deep_clone(self.besiege)
	self.phalanx.minions.min_count = 4
	self.phalanx.minions.amount = 10
	self.phalanx.minions.distance = 100
	self.phalanx.vip.health_ratio_flee = 0.2
	self.phalanx.vip.damage_reduction = {
		max = 0.5,
		start = 0.1,
		increase_intervall = 5,
		increase = 0.05
	}
	self.phalanx.check_spawn_intervall = 3000
	self.phalanx.chance_increase_intervall = 3000

	if difficulty_index == 4 then
		self.phalanx.spawn_chance = {
			decrease = 0,
			start = 0,
			respawn_delay = 3000,
			increase = 0,
			max = 0
		}
	elseif difficulty_index == 5 then
		self.phalanx.spawn_chance = {
			decrease = 0,
			start = 0,
			respawn_delay = 3000,
			increase = 0,
			max = 0
		}
	elseif difficulty_index == 6 then
		self.phalanx.spawn_chance = {
			decrease = 0,
			start = 0,
			respawn_delay = 3000,
			increase = 0,
			max = 0
		}
	elseif difficulty_index == 7 then
		self.phalanx.spawn_chance = {
			decrease = 0,
			start = 0,
			respawn_delay = 3000,
			increase = 0,
			max = 0
		}
	elseif difficulty_index == 8 then
		self.phalanx.spawn_chance = {
			decrease = 0,
			start = 0,
			respawn_delay = 3000,
			increase = 0,
			max = 0
		}
	else
		self.phalanx.spawn_chance = {
			decrease = 0,
			start = 0,
			respawn_delay = 120,
			increase = 0,
			max = 0
		}
	end

	self.safehouse = self.besiege
end
)
