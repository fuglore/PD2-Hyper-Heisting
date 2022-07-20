GroupAITweakData = GroupAITweakData or class()

function GroupAITweakData:init(tweak_data)
	local difficulty = Global.game_settings and Global.game_settings.difficulty or "normal"
	local difficulty_index = tweak_data:difficulty_to_index(difficulty)

	--print("[GroupAITweakData:init] difficulty", difficulty, "difficulty_index", difficulty_index)

	self.ai_tick_rate = 0.016666666666666666
	local level = Global.level_data and Global.level_data.level_id
	local level_data = tweak_data.levels[level]
	
	if level_data then
		self.small_map = level_data.meatgrinder
		
		if level == "haunted" then
			self.haunted = true
		end
		
		if level == "chill_combat" or level == "hvh" then
			self._chill = true
		end
	end
	
	if managers.mutators and managers.mutators:is_mutator_active(MutatorBirthday) then
		self._party = true
		Global.game_settings.one_down = true
	end

	self:_read_mission_preset(tweak_data)
	self:_create_table_structure()
	self:_init_task_data(difficulty_index)
	self:_init_chatter_data()
	self:_init_unit_categories(difficulty_index)
	self:_init_enemy_spawn_groups(difficulty_index)
end

Hooks:PostHook(GroupAITweakData, "_init_chatter_data", "hh_init_chatter_data", function(self, difficulty_index)
	--Clear Whisper
	self.enemy_chatter.clear_whisper = {
		radius = 700,
		max_nr = 2,
		duration = {60, 60},
		interval = {5, 5},
		group_min = 0,
		queue = "a05"
	}		
	self.enemy_chatter.clear_whisper_2 = {
		radius = 700,
		max_nr = 2,
		duration = {60, 60},
		interval = {5, 5},
		group_min = 0,
		queue = "a06"
	}		
	

	--Spawn Lines
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
	
	--Standardized Chatter
	self.enemy_chatter.assaultidle = {
		radius = 700,
		max_nr = 3,
		interval = {2, 3},
		duration = {3, 5},
		group_min = 1,
		queue = "https://www.youtube.com/watch?v=waj2mAas9Bc"
	}
	self.enemy_chatter.sabotage = {
		radius = 1200,
		max_nr = 2,
		interval = {1, 3},
		duration = {10, 20},
		group_min = 1,
		queue = "beastie boys"
	}
	self.enemy_chatter.controlidle = {
		radius = 1200,
		max_nr = 2,
		interval = {3, 6},
		duration = {7, 15},
		group_min = 1,
		queue = "https://www.youtube.com/watch?v=XEuZgnb_vOo"
	}
	self.enemy_chatter.contact = {
		radius = 6000,
		max_nr = 1,
		interval = {7, 15},
		duration = {7, 15},
		group_min = 0,
		queue = "lollmao"
	}
	
	--Special Stuff
	self.enemy_chatter.cloakergeneral = {
		radius = 1200,
		max_nr = 1,
		interval = {8, 16}, --global chatter cooldown, prevents spam
		duration = {8, 16},	--local chatter cooldown
		group_min = 0,
		queue = "I BET YOU WEAR THAT SHIT IN YOUR PANTS PROUDLY LIKE A BADGE OF HONOR"
	}
	self.enemy_chatter.medicgeneral = {
		radius = 400, --chatter event epicenter, units check against this to add to the nr
		max_nr = 3, --how many chatter events before the local chatter cooldown kicks in
		interval = {4, 8}, --global chatter cooldown, prevents spam
		duration = {4, 8},	--local chatter cooldown
		group_min = 0, --minimum units in the group in order for the chatter to play
		queue = "g90"
	}
	self.enemy_chatter.tasergeneral = {
		radius = 400, 
		max_nr = 3, 
		interval = {4, 8}, 
		duration = {4, 8},	
		group_min = 0,
		queue = "g90"
	}
	self.enemy_chatter.tankgeneral = {
		radius = 400, 
		max_nr = 3, 
		interval = {4, 8}, 
		duration = {4, 8},	
		group_min = 0,
		queue = "g90"
	}
	
	--Chatter
	self.enemy_chatter.aggressive = {
		radius = 400, --chatter event epicenter, units check against this to add to the nr
		max_nr = 3, --how many chatter events before the local chatter cooldown kicks in
		interval = {1, 3}, --global chatter cooldown, prevents spam
		duration = {2, 5},	--local chatter cooldown
		group_min = 2, --minimum units in the group in order for the chatter to play
		queue = "g90"
	}
	self.enemy_chatter.reload = {
		radius = 700,
		max_nr = 4,
		duration = {5, 10},
		interval = {4, 5},
		group_min = 0,
		queue = "rrl"
	}
	self.enemy_chatter.push = {
		radius = 700,
		max_nr = 4,
		duration = {5, 10},
		interval = {2.25, 3},
		group_min = 2,
		queue = "pus"
	}
	self.enemy_chatter.open_fire = {
		radius = 700,
		max_nr = 4,
		duration = {5, 10},
		interval = {2.25, 3},
		group_min = 2,
		queue = "att"
	}
	self.enemy_chatter.go_go = {
		radius = 700,
		max_nr = 4,
		duration = {5, 10},
		interval = {2.25, 3},
		group_min = 2,
		queue = "mov"
	}
	self.enemy_chatter.retreat = {
		radius = 700,
		max_nr = 2,
		duration = {2, 4},
		interval = {0.75, 1.5},
		group_min = 2,
		queue = "m01"
	}
	self.enemy_chatter.clear = {
		radius = 700,
		max_nr = 1,
		duration = {5, 10},
		interval = {2.25, 3},
		group_min = 2,
		queue = "clr"
	}
	self.enemy_chatter.go_go = {
		radius = 700,
		max_nr = 4,
		duration = {5, 10},
		interval = {2.25, 3},
		group_min = 2,
		queue = "mov"
	}
	self.enemy_chatter.ready = {
		radius = 700,
		max_nr = 4,
		duration = {5, 10},
		interval = {2.25, 3},
		group_min = 2,
		queue = "rdy"
	}
	self.enemy_chatter.smoke = {
		radius = 0,
		max_nr = 1,
		duration = {0, 0},
		interval = {0, 0},
		group_min = 2,
		queue = "d01"
	}
	self.enemy_chatter.flash_grenade = {
		radius = 0,
		max_nr = 1,
		duration = {0, 0},
		interval = {0, 0},
		group_min = 2,
		queue = "d02"
	}
	self.enemy_chatter.look_for_angle = {
		radius = 700,
		max_nr = 2,
		duration = {5, 10},
		interval = {1, 2},
		group_min = 2,
		queue = "t01"
	}
	self.enemy_chatter.follow_me = {
		radius = 700,
		max_nr = 2,
		queue = "prm",
		group_min = 2,
		duration = {
			5,
			10
		},
		interval = {
			1,
			3
		}
	}
	self.enemy_chatter.in_pos = {
		radius = 700,
		max_nr = 1,
		queue = "pos",
		group_min = 2,
		duration = {
			5,
			10
		},
		interval = {
			0.75,
			1.2
		}
	}
end)

Hooks:PostHook(GroupAITweakData, "_init_unit_categories", "cock_init_unit_categories", function(self, difficulty_index)
	local access_type_walk_only = {
		walk = true
	}
	local access_type_all = {
		acrobatic = true,
		walk = true
	}
	
	if self._party then
		self.special_unit_spawn_limits = {
			shield = 12,
			medic = 8,
			taser = 4,
			tank = 4,
			sniper = 3,						
			spooc = 4,
			fbi = 16
		}
	elseif managers.modifiers and managers.modifiers:check_boolean("TotalAnarchy") then -- spicy
		self.special_unit_spawn_limits = {
			shield = 6,
			medic = 8,
			taser = 2,
			tank = 2,
			sniper = 3,						
			spooc = 2,
			fbi = 8
		}
	elseif difficulty_index <= 2 then
		self.special_unit_spawn_limits = { --start normal with the idea that specials can and will inconvenience the player in any way possible if not taken care of, two tasers.
			shield = 4,
			medic = 0,
			taser = 2,
			tank = 0,
			sniper = 3,			
			spooc = 0
		}
	elseif difficulty_index == 3 then
		self.special_unit_spawn_limits = { --hard escalates this, enables medics to keep tasers alive, adds a rare occasional dozer
			shield = 4,
			medic = 3,
			taser = 2,
			tank = 1,
			sniper = 3,			
			spooc = 0
		}
	elseif difficulty_index == 4 then
		self.special_unit_spawn_limits = { --very hard enables satan himself to come visit you, increases max medics and shields
			shield = 4,
			medic = 4,
			taser = 1,
			tank = 1,
			sniper = 3,			
			spooc = 1,
			fbi = 4
		}
	elseif difficulty_index == 5 then
		self.special_unit_spawn_limits = { --overkill enables two spoocs, adds another taser, escalate the game meaningfully every difficulty by increasing complexity
			shield = 6,
			medic = 6,
			taser = 1,
			sniper = 3,						
			tank = 1,
			spooc = 1,
			fbi = 6
		}
	elseif difficulty_index == 6 then
		self.special_unit_spawn_limits = {
			shield = 6,
			medic = 6,
			taser = 1,
			tank = 1,
			sniper = 3,						
			spooc = 1,
			fbi = 8
		}
	elseif difficulty_index == 7 then
		self.special_unit_spawn_limits = {
			shield = 6,
			medic = 8,
			taser = 2,
			tank = 2,
			sniper = 3,						
			spooc = 2,
			fbi = 8
		}
	elseif difficulty_index == 8 then
		self.special_unit_spawn_limits = {
			shield = 6,
			medic = 8,
			taser = 2,
			tank = 2,
			sniper = 3,						
			spooc = 2,
			fbi = 8
		}
	else
		self.special_unit_spawn_limits = {
			shield = 4,
			medic = 8,
			taser = 3,
			tank = 2,
			sniper = 3,						
			spooc = 3,
			fbi = 12
		}
	end

	if difficulty_index == 8 then
		self.unit_categories.spooc = {
			special_type = "spooc",
			unit_types = {
				america = {
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_cloaker/ene_zeal_cloaker")
				},
				bo_hh = {
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_cloaker/ene_zeal_cloaker")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_spooc_asval_smg/ene_akan_fbi_spooc_asval_smg")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_spook_hvh_1/ene_spook_hvh_1")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_cloaker/ene_murky_cloaker")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_cloaker_policia_federale/ene_swat_cloaker_policia_federale")
				},
				shared = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_cloaker/ene_murky_cloaker"),
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
				bo_hh = {
					Idstring("units/payday2/characters/ene_spook_1/ene_spook_1")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_spooc_asval_smg/ene_akan_fbi_spooc_asval_smg")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_spook_hvh_1/ene_spook_hvh_1")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_cloaker/ene_murky_cloaker")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_cloaker_policia_federale/ene_swat_cloaker_policia_federale")
				},
				shared = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_cloaker/ene_murky_cloaker"),
					Idstring("units/payday2/characters/ene_spook_1/ene_spook_1")
				}
			},
			access = access_type_all
		}
	end

	if difficulty_index < 4 then
		self.unit_categories.sniper_ass = { --babe it's 4 pm, time for your brain flattening!
			special_type = "sniper",  --yes honey...
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_sniper_1/ene_sniper_1")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_swat_sniper_svd_snp/ene_akan_cs_swat_sniper_svd_snp")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_sniper_hvh_2/ene_sniper_hvh_2")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_sniper/ene_murkywater_sniper")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_sniper/ene_swat_policia_sniper")
				},
				shared = {
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_sniper/ene_murkywater_sniper"),
					Idstring("units/payday2/characters/ene_sniper_1/ene_sniper_1")					
				}
			},
			access = access_type_all
		}
	elseif difficulty_index == 5 then
		self.unit_categories.sniper_ass = {
			special_type = "sniper",
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_sniper_2/ene_sniper_2")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_swat_sniper_svd_snp/ene_akan_cs_swat_sniper_svd_snp")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_sniper_hvh_2/ene_sniper_hvh_2")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_sniper/ene_murkywater_sniper")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_sniper/ene_swat_policia_sniper")
				},
				shared = {
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_sniper/ene_murkywater_sniper"),
					Idstring("units/payday2/characters/ene_sniper_2/ene_sniper_2")					
				}
			},
			access = access_type_all
		}
	elseif difficulty_index <= 7 then
		self.unit_categories.sniper_ass = {
			special_type = "sniper",
			unit_types = {
				america = {
					Idstring("units/pd2_mod_ftsu/characters/ene_gensec_sniper/ene_gensec_sniper")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_swat_sniper_svd_snp/ene_akan_cs_swat_sniper_svd_snp")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_sniper_hvh_2/ene_sniper_hvh_2")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_sniper/ene_murkywater_sniper")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_sniper/ene_swat_policia_sniper")
				},
				shared = {
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_sniper/ene_murkywater_sniper"),
					Idstring("units/pd2_mod_ftsu/characters/ene_gensec_sniper/ene_gensec_sniper")					
				}
			},
			access = access_type_all
		}
	else 
		self.unit_categories.sniper_ass = {
			special_type = "sniper",
			unit_types = {
				america = {
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_sniper/ene_zeal_sniper")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_swat_sniper_svd_snp/ene_akan_cs_swat_sniper_svd_snp")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_sniper_hvh_2/ene_sniper_hvh_2")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_sniper/ene_murkywater_sniper")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_sniper/ene_swat_policia_sniper")
				},
				shared = {
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_sniper/ene_murkywater_sniper"),
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_sniper/ene_zeal_sniper")					
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
				bo_hh = {
					Idstring("units/pd2_mod_ftsu/characters/ene_gensec_punk_mp5/ene_gensec_punk_mp5"),
					Idstring("units/pd2_mod_ftsu/characters/ene_gensec_punk_moss/ene_gensec_punk_moss"),
					Idstring("units/pd2_mod_ftsu/characters/ene_gensec_punk_bronco/ene_gensec_punk_bronco")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_r870/ene_akan_cs_cop_r870"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_akmsu_smg/ene_akan_cs_cop_akmsu_smg"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_ak47_ass/ene_akan_cs_cop_ak47_ass")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_2/ene_cop_hvh_2"),
					Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_moss/ene_cop_hvh_moss"),
					Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_4/ene_cop_hvh_4")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_punk_moss/ene_murky_punk_moss"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_punk_mp5/ene_murky_punk_mp5"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_punk_bronco/ene_murky_punk_bronco")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_policia_02/ene_policia_02"),
					Idstring("units/pd2_dlc_bex/characters/ene_policia_punk_bronco/ene_policia_punk_bronco"),
					Idstring("units/pd2_dlc_bex/characters/ene_policia_03/ene_policia_03")
				},
				shared = {
					Idstring("units/payday2/characters/ene_cop_3/ene_cop_3"),
					Idstring("units/payday2/characters/ene_cop_2/ene_cop_2"),
					Idstring("units/payday2/characters/ene_cop_4/ene_cop_4"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_punk_moss/ene_murky_punk_moss"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_punk_mp5/ene_murky_punk_mp5"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_punk_bronco/ene_murky_punk_bronco")					
				}				
			},
			access = access_type_all
		}		
	elseif difficulty_index == 4 or difficulty_index == 5 then
		self.unit_categories.punk_group = {
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_cop_3/ene_cop_3"),
					Idstring("units/payday2/characters/ene_cop_2/ene_cop_2"),
					Idstring("units/payday2/characters/ene_cop_4/ene_cop_4")
				},
				bo_hh = {
					Idstring("units/pd2_mod_ftsu/characters/ene_gensec_punk_mp5/ene_gensec_punk_mp5"),
					Idstring("units/pd2_mod_ftsu/characters/ene_gensec_punk_moss/ene_gensec_punk_moss"),
					Idstring("units/pd2_mod_ftsu/characters/ene_gensec_punk_bronco/ene_gensec_punk_bronco")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_r870/ene_akan_cs_cop_r870"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_akmsu_smg/ene_akan_cs_cop_akmsu_smg"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_ak47_ass/ene_akan_cs_cop_ak47_ass")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_2/ene_cop_hvh_2"),
					Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_moss/ene_cop_hvh_moss"),
					Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_4/ene_cop_hvh_4")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_punk_moss/ene_murky_punk_moss"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_punk_mp5/ene_murky_punk_mp5"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_punk_bronco/ene_murky_punk_bronco")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_policia_02/ene_policia_02"),
					Idstring("units/pd2_dlc_bex/characters/ene_policia_punk_bronco/ene_policia_punk_bronco"),
					Idstring("units/pd2_dlc_bex/characters/ene_policia_03/ene_policia_03")
				},
				shared = {
					Idstring("units/payday2/characters/ene_cop_3/ene_cop_3"),
					Idstring("units/payday2/characters/ene_cop_2/ene_cop_2"),
					Idstring("units/payday2/characters/ene_cop_4/ene_cop_4"),				
					Idstring("units/pd2_mod_psc/characters/ene_murky_punk_moss/ene_murky_punk_moss"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_punk_mp5/ene_murky_punk_mp5"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_punk_bronco/ene_murky_punk_bronco")
				}				
			},
			access = access_type_all
		}
	elseif difficulty_index == 6 or difficulty_index == 7 then
		self.unit_categories.punk_group = {
			unit_types = {
				america = {
					Idstring("units/pd2_mod_ftsu/characters/ene_gensec_punk_mp5/ene_gensec_punk_mp5"),
					Idstring("units/pd2_mod_ftsu/characters/ene_gensec_punk_moss/ene_gensec_punk_moss"),
					Idstring("units/pd2_mod_ftsu/characters/ene_gensec_punk_bronco/ene_gensec_punk_bronco")
				},
				bo_hh = {
					Idstring("units/pd2_mod_ftsu/characters/ene_gensec_punk_mp5/ene_gensec_punk_mp5"),
					Idstring("units/pd2_mod_ftsu/characters/ene_gensec_punk_moss/ene_gensec_punk_moss"),
					Idstring("units/pd2_mod_ftsu/characters/ene_gensec_punk_bronco/ene_gensec_punk_bronco")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_r870/ene_akan_cs_cop_r870"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_akmsu_smg/ene_akan_cs_cop_akmsu_smg"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_ak47_ass/ene_akan_cs_cop_ak47_ass")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_2/ene_cop_hvh_2"),
					Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_moss/ene_cop_hvh_moss"),
					Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_4/ene_cop_hvh_4")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_punk_moss/ene_murky_punk_moss"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_punk_mp5/ene_murky_punk_mp5"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_punk_bronco/ene_murky_punk_bronco")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_policia_02/ene_policia_02"),
					Idstring("units/pd2_dlc_bex/characters/ene_policia_punk_bronco/ene_policia_punk_bronco"),
					Idstring("units/pd2_dlc_bex/characters/ene_policia_03/ene_policia_03")
				},
				shared = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_punk_moss/ene_murky_punk_moss"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_punk_mp5/ene_murky_punk_mp5"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_punk_bronco/ene_murky_punk_bronco"),
					Idstring("units/pd2_mod_ftsu/characters/ene_gensec_punk_mp5/ene_gensec_punk_mp5"),
					Idstring("units/pd2_mod_ftsu/characters/ene_gensec_punk_moss/ene_gensec_punk_moss"),
					Idstring("units/pd2_mod_ftsu/characters/ene_gensec_punk_bronco/ene_gensec_punk_bronco")					
				}				
			},
			access = access_type_all
		}
	else
		self.unit_categories.punk_group = {
			unit_types = {
				america = {
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_punk_mp5/ene_zeal_punk_mp5"),
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_punk_moss/ene_zeal_punk_moss"),
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_punk_bronco/ene_zeal_punk_bronco")
				},
				bo_hh = {
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
					Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_2/ene_cop_hvh_2"),
					Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_moss/ene_cop_hvh_moss"),
					Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_4/ene_cop_hvh_4")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_punk_moss/ene_murky_punk_moss"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_punk_mp5/ene_murky_punk_mp5"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_punk_bronco/ene_murky_punk_bronco")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_policia_02/ene_policia_02"),
					Idstring("units/pd2_dlc_bex/characters/ene_policia_punk_bronco/ene_policia_punk_bronco"),
					Idstring("units/pd2_dlc_bex/characters/ene_policia_03/ene_policia_03")
				},
				shared = {
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_punk_mp5/ene_zeal_punk_mp5"),
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_punk_moss/ene_zeal_punk_moss"),
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_punk_bronco/ene_zeal_punk_bronco"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_punk_moss/ene_murky_punk_moss"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_punk_mp5/ene_murky_punk_mp5"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_punk_bronco/ene_murky_punk_bronco")
				}								
			},
			access = access_type_all
		}
	end

	if difficulty_index < 6 then
		self.unit_categories.FBI_LHmix = {
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_fbi_swat_1/ene_fbi_swat_1"),
					Idstring("units/payday2/characters/ene_fbi_heavy_1/ene_fbi_heavy_1"),
				},
				bo_hh = {
					Idstring("units/pd2_mod_bofa/characters/ovk_units/ene_ovk_m4/ene_ovk_m4"),
					Idstring("units/pd2_mod_bofa/characters/ovk_units/ene_ovk_heavy_m4/ene_ovk_heavy_m4")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_ak47_ass/ene_akan_fbi_swat_ak47_ass"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_g36_hh/ene_akan_fbi_heavy_g36_hh")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_1/ene_fbi_swat_hvh_1"),
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_1/ene_fbi_heavy_hvh_1")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_scar/ene_murky_heavy_scar")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale_fbi/ene_swat_policia_federale_fbi"),
					Idstring("units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale_fbi/ene_swat_heavy_policia_federale_fbi")
				},
				shared = {
					Idstring("units/payday2/characters/ene_fbi_swat_1/ene_fbi_swat_1"),
					Idstring("units/payday2/characters/ene_fbi_swat_1/ene_fbi_swat_1"),
					Idstring("units/payday2/characters/ene_fbi_swat_3/ene_fbi_swat_3"),
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
				bo_hh = {
					Idstring("units/pd2_mod_bofa/characters/ovk_units/ene_ovk_m4/ene_ovk_m4"),
					Idstring("units/pd2_mod_bofa/characters/ovk_units/ene_ovk_heavy_m4/ene_ovk_heavy_m4"),
					Idstring("units/pd2_mod_bofa/characters/bofa_units/ene_bofa_g36/ene_bofa_g36"),
					Idstring("units/pd2_mod_bofa/characters/bofa_units/ene_bofa_heavy_g36/ene_bofa_heavy_g36")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_ak47_ass/ene_akan_fbi_swat_ak47_ass"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_g36_hh/ene_akan_fbi_heavy_g36_hh")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_1/ene_fbi_swat_hvh_1"),
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_1/ene_fbi_heavy_hvh_1")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_scar/ene_murky_heavy_scar")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale_fbi/ene_swat_policia_federale_fbi"),
					Idstring("units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale_fbi/ene_swat_heavy_policia_federale_fbi")
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
				bo_hh = {
					Idstring("units/pd2_mod_bofa/characters/bofa_units/ene_bofa_g36/ene_bofa_g36"),
					Idstring("units/pd2_mod_bofa/characters/bofa_units/ene_bofa_heavy_g36/ene_bofa_heavy_g36")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_ak47_ass/ene_akan_fbi_swat_ak47_ass"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_g36_hh/ene_akan_fbi_heavy_g36_hh")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_1/ene_fbi_swat_hvh_1"),
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_1/ene_fbi_heavy_hvh_1")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_scar/ene_murky_heavy_scar")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale_fbi/ene_swat_policia_federale_fbi"),
					Idstring("units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale_fbi/ene_swat_heavy_policia_federale_fbi")
				},
				shared = {
					Idstring("units/payday2/characters/ene_city_swat_1/ene_city_swat_1"),
					Idstring("units/payday2/characters/ene_city_heavy_g36/ene_city_heavy_g36"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),					
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_scar/ene_murky_heavy_scar")
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
				bo_hh = {
					Idstring("units/pd2_mod_bofa/characters/bofa_units/ene_bofa_g36/ene_bofa_g36"),
					Idstring("units/pd2_mod_bofa/characters/bofa_units/ene_bofa_heavy_g36/ene_bofa_heavy_g36")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_ak47_ass/ene_akan_fbi_swat_ak47_ass"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_g36_hh/ene_akan_fbi_heavy_g36_hh")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_1/ene_fbi_swat_hvh_1"),
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_1/ene_fbi_heavy_hvh_1")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_scar/ene_murky_heavy_scar")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale_fbi/ene_swat_policia_federale_fbi"),
					Idstring("units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale_fbi/ene_swat_heavy_policia_federale_fbi")
				},
				shared = {
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_city_1/ene_zeal_city_1"),
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy_hh/ene_zeal_swat_heavy_hh"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_scar/ene_murky_heavy_scar")
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
				Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_moss/ene_cop_hvh_moss"),
				Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_4/ene_cop_hvh_4")
			},
			federales = {
				Idstring("units/payday2/characters/ene_cop_1/ene_cop_1"),
				Idstring("units/payday2/characters/ene_cop_3/ene_cop_3"),
				Idstring("units/payday2/characters/ene_cop_4/ene_cop_4")
			},
			murkywater = {
				Idstring("units/pd2_mod_psc/characters/ene_murky_punk_c45/ene_murky_punk_c45"),
				Idstring("units/pd2_mod_psc/characters/ene_murky_punk_mp5/ene_murky_punk_mp5"),
				Idstring("units/pd2_mod_psc/characters/ene_murkywater_light_r870/ene_murkywater_light_r870")				
			},
			shared = {
				Idstring("units/payday2/characters/ene_cop_1/ene_cop_1"),
				Idstring("units/payday2/characters/ene_cop_3/ene_cop_3"),
				Idstring("units/payday2/characters/ene_cop_4/ene_cop_4"),			
				Idstring("units/pd2_mod_psc/characters/ene_murky_punk_c45/ene_murky_punk_c45"), --PLACEHOLDER BEATCOP
				Idstring("units/pd2_mod_psc/characters/ene_murky_punk_mp5/ene_murky_punk_mp5"),
				Idstring("units/pd2_mod_psc/characters/ene_murkywater_light_r870/ene_murkywater_light_r870")				
			}			
		},
		access = access_type_all
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
				Idstring("units/pd2_mod_psc/characters/ene_murkywater_light/ene_murkywater_light")
			},
			federales = {
				Idstring("units/payday2/characters/ene_cop_2/ene_cop_2")
			},
			shared = {
				Idstring("units/payday2/characters/ene_cop_2/ene_cop_2"),
				Idstring("units/pd2_mod_psc/characters/ene_murkywater_light/ene_murkywater_light")				
			}			
		},
		access = access_type_all
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
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale/ene_swat_policia_federale"),
					Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale/ene_swat_policia_federale"),
					Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale_mp5/ene_swat_policia_federale_mp5")
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
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale_r870_hh/ene_swat_policia_federale_r870_hh")
				},
				shared = {
					Idstring("units/payday2/characters/ene_swat_2/ene_swat_2"),
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
					Idstring("units/payday2/characters/ene_swat_3/ene_swat_3")
				},
				bo_hh = {
					Idstring("units/pd2_mod_bofa/characters/ovk_units/ene_ovk_m4/ene_ovk_m4"),
					Idstring("units/pd2_mod_bofa/characters/ovk_units/ene_ovk_m4/ene_ovk_m4"),
					Idstring("units/pd2_mod_bofa/characters/sbz_units/ene_sbz_mp5/ene_sbz_mp5")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_ak47_ass/ene_akan_fbi_swat_ak47_ass"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_ak47_ass/ene_akan_fbi_swat_ak47_ass"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_hyper_fbi_akmsu_smg/ene_akan_hyper_fbi_akmsu_smg")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_swat_hvh_1/ene_swat_hvh_1"),
					Idstring("units/pd2_dlc_hvh/characters/ene_swat_hvh_1/ene_swat_hvh_1"),
					Idstring("units/pd2_dlc_hvh/characters/ene_swat_hvh_3/ene_swat_hvh_3")				
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_ump/ene_murky_light_ump")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale/ene_swat_policia_federale"),
					Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale/ene_swat_policia_federale"),
					Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale_mp5/ene_swat_policia_federale_mp5")
				},
				shared = {
					Idstring("units/payday2/characters/ene_swat_1/ene_swat_1"),
					Idstring("units/payday2/characters/ene_swat_1/ene_swat_1"),
					Idstring("units/payday2/characters/ene_swat_3/ene_swat_3"),				
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_ump/ene_murky_light_ump")
				}	
			},
			access = access_type_all
		}
		self.unit_categories.CS_swat_R870 = {
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_swat_2/ene_swat_2")
				},
				bo_hh = {
					Idstring("units/pd2_mod_bofa/characters/sbz_units/ene_sbz_r870/ene_sbz_r870")
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
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale_r870_hh/ene_swat_policia_federale_r870_hh")
				},
				shared = {
					Idstring("units/payday2/characters/ene_swat_2/ene_swat_2"),				
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_r870/ene_murky_light_r870")
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
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale/ene_swat_heavy_policia_federale")
				},
				shared = {
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy/ene_zeal_swat_heavy"),				
					Idstring("units/pd2_mod_psc/characters/ene_murky_NH_rifle/ene_murky_NH_rifle")
				}				
			},
			access = access_type_all
		}
		self.unit_categories.CS_heavy_R870 = {
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_city_heavy_r870/ene_city_heavy_r870") --what
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
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale_fbi_r870_hh/ene_swat_heavy_policia_federale_fbi_r870_hh")
				},
				shared = {
					Idstring("units/payday2/characters/ene_city_heavy_r870/ene_city_heavy_r870"),				
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
				},
				federales = {				
					Idstring("units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale/ene_swat_heavy_policia_federale")
				},
				shared = {		
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy/ene_zeal_swat_heavy"),				
					Idstring("units/pd2_mod_psc/characters/ene_murky_NH_rifle/ene_murky_NH_rifle")		
				}				
			},
			access = access_type_all
		}
	else
		self.unit_categories.CS_heavy_M4 = {
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_swat_heavy_1/ene_swat_heavy_1")
				},
				bo_hh = {
					Idstring("units/pd2_mod_bofa/characters/sbz_units/ene_sbz_heavy_m4/ene_sbz_heavy_m4")
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
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale/ene_swat_heavy_policia_federale")
				},
				shared = {
					Idstring("units/payday2/characters/ene_swat_heavy_1/ene_swat_heavy_1"),				
					Idstring("units/pd2_mod_psc/characters/ene_murky_NH_rifle/ene_murky_NH_rifle")
				}
			},
			access = access_type_all
		}
		self.unit_categories.CS_heavy_R870 = {
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_swat_heavy_r870/ene_swat_heavy_r870")
				},
				bo_hh = {
					Idstring("units/pd2_mod_bofa/characters/sbz_units/ene_sbz_heavy_r870/ene_sbz_heavy_r870")
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
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale_r870/ene_swat_heavy_policia_federale_r870")
				},
				shared = {
					Idstring("units/payday2/characters/ene_swat_heavy_r870/ene_swat_heavy_r870"),				
					Idstring("units/pd2_mod_psc/characters/ene_murky_NH_r870/ene_murky_NH_r870")
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
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale/ene_swat_heavy_policia_federale")
				},
				shared = {
					Idstring("units/payday2/characters/ene_swat_heavy_1/ene_swat_heavy_1"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_NH_rifle/ene_murky_NH_rifle")					
				}
			},
			access = access_type_all
		}
	end

	if difficulty_index == 8 then
		self.unit_categories.CS_tazer = {
			special_type = "taser",
			unit_types = {
				america = {
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_tazer_hh/ene_zeal_tazer_hh")
				},
				bo_hh = {
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_tazer_hh/ene_zeal_tazer_hh")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_tazer_ak47_ass/ene_akan_cs_tazer_ak47_ass")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_tazer_hvh_1/ene_tazer_hvh_1")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_tazer/ene_murkywater_tazer")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_tazer_1/ene_tazer_1")
				},
				shared = {
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_tazer_hh/ene_zeal_tazer_hh"),
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_tazer/ene_murkywater_tazer")
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
				bo_hh = {
					Idstring("units/payday2/characters/ene_tazer_1/ene_tazer_1")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_tazer_ak47_ass/ene_akan_cs_tazer_ak47_ass")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_tazer_hvh_1/ene_tazer_hvh_1")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_tazer/ene_murkywater_tazer")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_tazer_1/ene_tazer_1")
				},
				shared = {
					Idstring("units/payday2/characters/ene_tazer_1/ene_tazer_1"),
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_tazer/ene_murkywater_tazer")
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
					Idstring("units/pd2_mod_psc/characters/ene_murky_DS_shield/ene_murky_DS_shield")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_shield_policia_federale_mp9/ene_swat_shield_policia_federale_mp9")
				},
				shared = {
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_swat_shield_hh/ene_zeal_swat_shield_hh"),				
					Idstring("units/pd2_mod_psc/characters/ene_murky_DS_shield/ene_murky_DS_shield")
				}
			},
			access = access_type_all
		}
	else
		self.unit_categories.CS_shield = {
			special_type = "shield",
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_shield_2/ene_shield_2")
				},
				bo_hh = {
					Idstring("units/pd2_mod_bofa/characters/sbz_units/ene_sbz_shield_c45/ene_sbz_shield_c45")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_shield_c45/ene_akan_cs_shield_c45")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_shield_hvh_2/ene_shield_hvh_2")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_shield_ld/ene_murky_shield_ld")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_shield_policia_federale_c45/ene_swat_shield_policia_federale_c45")
				},
				shared = {
					Idstring("units/payday2/characters/ene_shield_2/ene_shield_2"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_shield_ld/ene_murky_shield_ld")
				}
			},
			access = access_type_all
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
				Idstring("units/pd2_dlc_hvh/characters/ene_fbigod_hvh_c45/ene_fbigod_hvh_c45"),
				Idstring("units/pd2_dlc_hvh/characters/ene_fbigod_hvh_m4/ene_fbigod_hvh_m4")
			},
			murkywater = {
				Idstring("units/pd2_mod_psc/characters/ene_murky_fbigod_c45/ene_murky_fbigod_c45"),
				Idstring("units/pd2_mod_psc/characters/ene_murky_fbigod_m4/ene_murky_fbigod_m4")				
			},
			federales = {
				Idstring("units/payday2/characters/ene_fbi_1/ene_fbi_1"),
				Idstring("units/payday2/characters/ene_fbi_2/ene_fbi_2")
			},
			shared = {
				Idstring("units/payday2/characters/ene_fbi_1/ene_fbi_1"),
				Idstring("units/payday2/characters/ene_fbi_2/ene_fbi_2"),
				Idstring("units/pd2_mod_psc/characters/ene_murky_fbigod_c45/ene_murky_fbigod_c45"),
				Idstring("units/pd2_mod_psc/characters/ene_murky_fbigod_m4/ene_murky_fbigod_m4")				
			}			
		},
		access = access_type_all
	}
	
	if difficulty_index < 6 then
		self.unit_categories.FBI_suit_M4_MP5 = {
			special_type = "fbi",
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_fbi_1/ene_fbi_1"),
					Idstring("units/payday2/characters/ene_fbi_2/ene_fbi_2")
				},
				bo_hh = {
					Idstring("units/pd2_mod_ftsu/characters/ene_gensec_fbigod_c45/ene_gensec_fbigod_c45"),
					Idstring("units/pd2_mod_ftsu/characters/ene_gensec_fbigod_m4/ene_gensec_fbigod_m4")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_hyper_fbininja_ak47_ass/ene_akan_hyper_fbininja_ak47_ass"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_hyper_fbininja_c45/ene_akan_hyper_fbininja_c45")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbigod_hvh_c45/ene_fbigod_hvh_c45"),
					Idstring("units/pd2_dlc_hvh/characters/ene_fbigod_hvh_m4/ene_fbigod_hvh_m4")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_fbigod_c45/ene_murky_fbigod_c45"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_fbigod_m4/ene_murky_fbigod_m4")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_bex_ninja_c45/ene_bex_ninja_c45"),
					Idstring("units/pd2_dlc_pex/characters/ene_male_office_cop_04/ene_male_office_cop_04")
				},
				shared = {
					Idstring("units/payday2/characters/ene_fbi_1/ene_fbi_1"),
					Idstring("units/payday2/characters/ene_fbi_2/ene_fbi_2"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_fbigod_c45/ene_murky_fbigod_c45"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_fbigod_m4/ene_murky_fbigod_m4")
				}
			},
			access = access_type_all
		}
	elseif difficulty_index == 6 or difficulty_index == 7 then
		self.unit_categories.FBI_suit_M4_MP5 = {
			special_type = "fbi",
			unit_types = {
				america = {
					Idstring("units/pd2_mod_ftsu/characters/ene_gensec_fbigod_c45/ene_gensec_fbigod_c45"),
					Idstring("units/pd2_mod_ftsu/characters/ene_gensec_fbigod_m4/ene_gensec_fbigod_m4")
				},
				bo_hh = {
					Idstring("units/pd2_mod_ftsu/characters/ene_gensec_fbigod_c45/ene_gensec_fbigod_c45"),
					Idstring("units/pd2_mod_ftsu/characters/ene_gensec_fbigod_m4/ene_gensec_fbigod_m4")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_hyper_fbininja_ak47_ass/ene_akan_hyper_fbininja_ak47_ass"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_hyper_fbininja_c45/ene_akan_hyper_fbininja_c45")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbigod_hvh_c45/ene_fbigod_hvh_c45"),
					Idstring("units/pd2_dlc_hvh/characters/ene_fbigod_hvh_m4/ene_fbigod_hvh_m4")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_fbigod_c45/ene_murky_fbigod_c45"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_fbigod_m4/ene_murky_fbigod_m4")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_bex_ninja_c45/ene_bex_ninja_c45"),
					Idstring("units/pd2_dlc_pex/characters/ene_male_office_cop_04/ene_male_office_cop_04")
				},
				shared = {
					Idstring("units/pd2_mod_ftsu/characters/ene_gensec_fbigod_c45/ene_gensec_fbigod_c45"),
					Idstring("units/pd2_mod_ftsu/characters/ene_gensec_fbigod_m4/ene_gensec_fbigod_m4"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_fbigod_c45/ene_murky_fbigod_c45"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_fbigod_m4/ene_murky_fbigod_m4")
				}
			},
			access = access_type_all
		}
	else
		self.unit_categories.FBI_suit_M4_MP5 = {
			special_type = "fbi",
			unit_types = {
				america = {
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_fbigod_m4/ene_zeal_fbigod_m4"),
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_fbigod_c45/ene_zeal_fbigod_c45")
				},
				bo_hh = {
					Idstring("units/pd2_mod_ftsu/characters/ene_gensec_fbigod_c45/ene_gensec_fbigod_c45"),
					Idstring("units/pd2_mod_ftsu/characters/ene_gensec_fbigod_m4/ene_gensec_fbigod_m4")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_hyper_fbininja_ak47_ass/ene_akan_hyper_fbininja_ak47_ass"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_hyper_fbininja_c45/ene_akan_hyper_fbininja_c45")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbigod_hvh_c45/ene_fbigod_hvh_c45"),
					Idstring("units/pd2_dlc_hvh/characters/ene_fbigod_hvh_m4/ene_fbigod_hvh_m4")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_fbigod_c45/ene_murky_fbigod_c45"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_fbigod_m4/ene_murky_fbigod_m4")
				},
				federales = {
					Idstring("units/pd2_dlc_pex/characters/ene_male_office_cop_04/ene_male_office_cop_04"),
					Idstring("units/pd2_dlc_bex/characters/ene_bex_ninja_c45/ene_bex_ninja_c45")
				},
				shared = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_fbigod_c45/ene_murky_fbigod_c45"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_fbigod_m4/ene_murky_fbigod_m4"),
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_fbigod_c45/ene_zeal_fbigod_c45"),					
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_fbigod_m4/ene_zeal_fbigod_m4")
				}
			},
			access = access_type_all
		}
	end
	
	self.unit_categories.FBI_suit_stealth_MP5 = {
		unit_types = {
			america = {
				Idstring("units/payday2/characters/ene_fbi_swat_3/ene_fbi_swat_3")
			},
			russia = {
				Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_asval_smg/ene_akan_cs_cop_asval_smg")
			},
			zombie = {
				Idstring("units/pd2_dlc_hvh/characters/ene_fbi_hvh_3/ene_fbi_hvh_3")
			},
			federales = {
				Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale/ene_swat_policia_federale")
			},
			murkywater = {
				Idstring("units/pd2_mod_psc/characters/ene_murky_light_ump/ene_murky_light_ump")
			},
			shared = {
				Idstring("units/payday2/characters/ene_fbi_swat_3/ene_fbi_swat_3"),			
				Idstring("units/pd2_mod_psc/characters/ene_murky_light_ump/ene_murky_light_ump")
			}			
		},
		access = access_type_all
	}
	
	if difficulty_index <= 3 then
		self.unit_categories.CS_swat_SMG = {
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_swat_3/ene_swat_3")
				},
				bo_hh = {
					Idstring("units/pd2_mod_bofa/characters/sbz_units/ene_sbz_mp5/ene_sbz_mp5")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_hyper_fbi_akmsu_smg/ene_akan_hyper_fbi_akmsu_smg")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_swat_hvh_3/ene_swat_hvh_3")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_ump/ene_murky_light_ump")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale_mp5/ene_swat_policia_federale_mp5")
				},
				shared = {
					Idstring("units/payday2/characters/ene_swat_3/ene_swat_3"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_ump/ene_murky_light_ump")
				}
			},
			access = access_type_all
		}
	elseif difficulty_index <= 5 then
		self.unit_categories.CS_swat_SMG = {
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_fbi_swat_3/ene_fbi_swat_3")
				},
				bo_hh = {
					Idstring("units/pd2_mod_bofa/characters/sbz_units/ene_sbz_mp5/ene_sbz_mp5")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_hyper_fbi_akmsu_smg/ene_akan_hyper_fbi_akmsu_smg")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_3/ene_fbi_swat_hvh_3")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_ump/ene_murky_light_ump")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale_mp5/ene_swat_policia_federale_mp5")
				},
				shared = {
					Idstring("units/payday2/characters/ene_fbi_swat_3/ene_fbi_swat_3"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_ump/ene_murky_light_ump")
				}
			},
			access = access_type_all
		}
	elseif difficulty_index <= 7 then
		self.unit_categories.CS_swat_SMG = {
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_city_swat_3/ene_city_swat_3")
				},
				bo_hh = {
					Idstring("units/pd2_mod_bofa/characters/bofa_units/ene_bofa_ump/ene_bofa_ump")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_hyper_fbi_akmsu_smg/ene_akan_hyper_fbi_akmsu_smg")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_3/ene_fbi_swat_hvh_3")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_ump/ene_murky_light_ump")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale_mp5/ene_swat_policia_federale_mp5")
				},
				shared = {
					Idstring("units/payday2/characters/ene_city_swat_3/ene_city_swat_3"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_ump/ene_murky_light_ump")
				}
			},
			access = access_type_all
		}
	else
		self.unit_categories.CS_swat_SMG = {
			unit_types = {
				america = {
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_city_3/ene_zeal_city_3")
				},
				bo_hh = {
					Idstring("units/pd2_mod_bofa/characters/bofa_units/ene_bofa_ump/ene_bofa_ump")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_hyper_fbi_akmsu_smg/ene_akan_hyper_fbi_akmsu_smg")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_3/ene_fbi_swat_hvh_3")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_ump/ene_murky_light_ump")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale_mp5/ene_swat_policia_federale_mp5")
				},
				shared = {
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_city_3/ene_zeal_city_3"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_ump/ene_murky_light_ump")
				}
			},
			access = access_type_all
		}
	end
	
	if difficulty_index < 6 then
		self.unit_categories.FBI_swat_M4 = {
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_fbi_swat_1/ene_fbi_swat_1"),
					Idstring("units/payday2/characters/ene_fbi_swat_1/ene_fbi_swat_1"),
					Idstring("units/payday2/characters/ene_fbi_swat_3/ene_fbi_swat_3")
				},
				bo_hh = {
					Idstring("units/pd2_mod_bofa/characters/ovk_units/ene_ovk_m4/ene_ovk_m4"),
					Idstring("units/pd2_mod_bofa/characters/ovk_units/ene_ovk_m4/ene_ovk_m4"),
					Idstring("units/pd2_mod_bofa/characters/sbz_units/ene_sbz_mp5/ene_sbz_mp5")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_ak47_ass/ene_akan_fbi_swat_ak47_ass"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_ak47_ass/ene_akan_fbi_swat_ak47_ass"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_hyper_fbi_akmsu_smg/ene_akan_hyper_fbi_akmsu_smg")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_1/ene_fbi_swat_hvh_1"),
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_1/ene_fbi_swat_hvh_1"),
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_3/ene_fbi_swat_hvh_3")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_ump/ene_murky_light_ump")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale/ene_swat_policia_federale"),
					Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale/ene_swat_policia_federale"),
					Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale_mp5/ene_swat_policia_federale_mp5")
				},
				shared = {
					Idstring("units/payday2/characters/ene_fbi_swat_1/ene_fbi_swat_1"),
					Idstring("units/payday2/characters/ene_fbi_swat_1/ene_fbi_swat_1"),
					Idstring("units/payday2/characters/ene_fbi_swat_3/ene_fbi_swat_3"),
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
				bo_hh = {
					Idstring("units/pd2_mod_bofa/characters/ovk_units/ene_ovk_m4/ene_ovk_m4"),
					Idstring("units/pd2_mod_bofa/characters/ovk_units/ene_ovk_m4/ene_ovk_m4"),
					Idstring("units/pd2_mod_bofa/characters/bofa_units/ene_bofa_g36/ene_bofa_g36"),					
					Idstring("units/pd2_mod_bofa/characters/bofa_units/ene_bofa_g36/ene_bofa_g36"),
					Idstring("units/pd2_mod_bofa/characters/bofa_units/ene_bofa_ump/ene_bofa_ump"),
					Idstring("units/pd2_mod_bofa/characters/bofa_units/ene_bofa_ump/ene_bofa_ump")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_ak47_ass/ene_akan_fbi_swat_ak47_ass"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_ak47_ass/ene_akan_fbi_swat_ak47_ass"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_hyper_fbi_akmsu_smg/ene_akan_hyper_fbi_akmsu_smg")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_1/ene_fbi_swat_hvh_1"),
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_1/ene_fbi_swat_hvh_1"),
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_3/ene_fbi_swat_hvh_3")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_ump/ene_murky_light_ump")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale/ene_swat_policia_federale"),
					Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale/ene_swat_policia_federale"),
					Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale_mp5/ene_swat_policia_federale_mp5")
				},
				shared = {
					Idstring("units/payday2/characters/ene_city_swat_1/ene_city_swat_1"),					
					Idstring("units/payday2/characters/ene_city_swat_1/ene_city_swat_1"),
					Idstring("units/payday2/characters/ene_city_swat_3/ene_city_swat_3"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
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
				bo_hh = {
					Idstring("units/pd2_mod_bofa/characters/bofa_units/ene_bofa_g36/ene_bofa_g36"),					
					Idstring("units/pd2_mod_bofa/characters/bofa_units/ene_bofa_g36/ene_bofa_g36"),
					Idstring("units/pd2_mod_bofa/characters/bofa_units/ene_bofa_ump/ene_bofa_ump")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_ak47_ass/ene_akan_fbi_swat_ak47_ass"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_ak47_ass/ene_akan_fbi_swat_ak47_ass"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_hyper_fbi_akmsu_smg/ene_akan_hyper_fbi_akmsu_smg")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_1/ene_fbi_swat_hvh_1"),
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_1/ene_fbi_swat_hvh_1"),
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_3/ene_fbi_swat_hvh_3")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_ump/ene_murky_light_ump")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale/ene_swat_policia_federale"),
					Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale/ene_swat_policia_federale"),
					Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale_mp5/ene_swat_policia_federale_mp5")
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
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_ak47_ass/ene_akan_fbi_swat_ak47_ass"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_ak47_ass/ene_akan_fbi_swat_ak47_ass"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_hyper_fbi_akmsu_smg/ene_akan_hyper_fbi_akmsu_smg")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_1/ene_fbi_swat_hvh_1"),
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_1/ene_fbi_swat_hvh_1"),
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_3/ene_fbi_swat_hvh_3")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_ump/ene_murky_light_ump")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale/ene_swat_policia_federale"),
					Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale/ene_swat_policia_federale"),
					Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale_mp5/ene_swat_policia_federale_mp5")
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
				bo_hh = {
					Idstring("units/pd2_mod_bofa/characters/ovk_units/ene_ovk_r870/ene_ovk_r870")
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
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale_r870_hh/ene_swat_policia_federale_r870_hh")
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
				bo_hh = {
					Idstring("units/pd2_mod_bofa/characters/ovk_units/ene_ovk_r870/ene_ovk_r870"),
					Idstring("units/pd2_mod_bofa/characters/ovk_units/ene_ovk_r870/ene_ovk_r870"),
					Idstring("units/pd2_mod_bofa/characters/bofa_units/ene_bofa_r870/ene_bofa_r870")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_r870/ene_akan_fbi_swat_r870"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_r870/ene_akan_fbi_swat_r870"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_r870/ene_akan_fbi_swat_r870"),					
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_2/ene_fbi_swat_hvh_2")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_r870/ene_murky_light_r870")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale_r870_hh/ene_swat_policia_federale_r870_hh")
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
				bo_hh = {
					Idstring("units/pd2_mod_bofa/characters/bofa_units/ene_bofa_r870/ene_bofa_r870")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_r870/ene_akan_fbi_swat_r870")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_2/ene_fbi_swat_hvh_2")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_r870/ene_murky_light_r870")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale_r870_hh/ene_swat_policia_federale_r870_hh")
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
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_swat_r870/ene_akan_fbi_swat_r870")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_2/ene_fbi_swat_hvh_2")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_light_r870/ene_murky_light_r870")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale_r870_hh/ene_swat_policia_federale_r870_hh")
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
					Idstring("units/payday2/characters/ene_fbi_heavy_1/ene_fbi_heavy_1"),
					Idstring("units/payday2/characters/ene_fbi_heavy_1/ene_fbi_heavy_1")
				},
				bo_hh = {
					Idstring("units/pd2_mod_bofa/characters/ovk_units/ene_ovk_heavy_m4/ene_ovk_heavy_m4")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_g36_hh/ene_akan_fbi_heavy_g36_hh"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_g36_hh/ene_akan_fbi_heavy_g36_hh")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_1/ene_fbi_heavy_hvh_1"),
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_1/ene_fbi_heavy_hvh_1")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_scar/ene_murky_heavy_scar"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_scar/ene_murky_heavy_scar")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale_fbi/ene_swat_heavy_policia_federale_fbi"),
					Idstring("units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale_fbi/ene_swat_heavy_policia_federale_fbi")
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
				bo_hh = {
					Idstring("units/pd2_mod_bofa/characters/ovk_units/ene_ovk_heavy_m4/ene_ovk_heavy_m4"),
					Idstring("units/pd2_mod_bofa/characters/ovk_units/ene_ovk_heavy_m4/ene_ovk_heavy_m4"),
					Idstring("units/pd2_mod_bofa/characters/bofa_units/ene_bofa_heavy_g36/ene_bofa_heavy_g36")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_g36_hh/ene_akan_fbi_heavy_g36_hh")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_1/ene_fbi_heavy_hvh_1")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_scar/ene_murky_heavy_scar")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale_fbi/ene_swat_heavy_policia_federale_fbi")
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
				bo_hh = {
					Idstring("units/pd2_mod_bofa/characters/bofa_units/ene_bofa_heavy_g36/ene_bofa_heavy_g36")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_g36_hh/ene_akan_fbi_heavy_g36_hh")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_1/ene_fbi_heavy_hvh_1")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_scar/ene_murky_heavy_scar")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale_fbi/ene_swat_heavy_policia_federale_fbi")
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
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_g36_hh/ene_akan_fbi_heavy_g36_hh")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_1/ene_fbi_heavy_hvh_1")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_scar/ene_murky_heavy_scar")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale_fbi/ene_swat_heavy_policia_federale_fbi")
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
				bo_hh = {
					Idstring("units/pd2_mod_bofa/characters/ovk_units/ene_ovk_r870/ene_ovk_r870")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_r870_hh/ene_akan_fbi_heavy_r870_hh")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_r870/ene_fbi_heavy_hvh_r870")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_r870/ene_murky_heavy_r870"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_r870/ene_murky_heavy_r870")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale_fbi_r870_hh/ene_swat_heavy_policia_federale_fbi_r870_hh")
				},
				shared = {
					Idstring("units/payday2/characters/ene_fbi_heavy_r870/ene_fbi_heavy_r870"),				
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_r870/ene_murky_heavy_r870")
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
				bo_hh = {
					Idstring("units/pd2_mod_bofa/characters/ovk_units/ene_ovk_r870/ene_ovk_r870"),
					Idstring("units/pd2_mod_bofa/characters/ovk_units/ene_ovk_r870/ene_ovk_r870"),
					Idstring("units/pd2_mod_bofa/characters/bofa_units/ene_bofa_heavy_r870/ene_bofa_heavy_r870")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_r870_hh/ene_akan_fbi_heavy_r870_hh")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_r870/ene_fbi_heavy_hvh_r870")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_r870/ene_murky_heavy_r870")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale_fbi_r870_hh/ene_swat_heavy_policia_federale_fbi_r870_hh")
				},
				shared = {
					Idstring("units/payday2/characters/ene_city_heavy_r870/ene_city_heavy_r870"),				
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_r870/ene_murky_heavy_r870")
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
				bo_hh = {
					Idstring("units/pd2_mod_bofa/characters/bofa_units/ene_bofa_heavy_r870/ene_bofa_heavy_r870")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_r870_hh/ene_akan_fbi_heavy_r870_hh")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_r870/ene_fbi_heavy_hvh_r870")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_r870/ene_murky_heavy_r870")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale_fbi_r870_hh/ene_swat_heavy_policia_federale_fbi_r870_hh")
				},
				shared = {
					Idstring("units/payday2/characters/ene_city_heavy_r870/ene_city_heavy_r870"),				
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_r870/ene_murky_heavy_r870")
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
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_r870_hh/ene_akan_fbi_heavy_r870_hh")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_r870/ene_fbi_heavy_hvh_r870")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_r870/ene_murky_heavy_r870")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale_fbi_r870_hh/ene_swat_heavy_policia_federale_fbi_r870_hh")
				},
				shared = {
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy_r870/ene_zeal_swat_heavy_r870"),				
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_r870/ene_murky_heavy_r870")
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
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_g36_hh/ene_akan_fbi_heavy_g36_hh")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_1/ene_fbi_heavy_hvh_1")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_scar/ene_murky_heavy_scar")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale_fbi/ene_swat_heavy_policia_federale_fbi")
				},
				shared = {
					Idstring("units/payday2/characters/ene_fbi_heavy_1/ene_fbi_heavy_1"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_scar/ene_murky_heavy_scar")					
				}				
			},
			access = access_type_all
		}
	else
		self.unit_categories.FBI_heavy_G36_w = {
			unit_types = {
				america = {
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy/ene_zeal_swat_heavy")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_g36_hh/ene_akan_fbi_heavy_g36_hh")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_1/ene_fbi_heavy_hvh_1")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_scar/ene_murky_heavy_scar")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale_fbi/ene_swat_heavy_policia_federale_fbi")
				},
				shared = {
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy/ene_zeal_swat_heavy"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_scar/ene_murky_heavy_scar")					
				}							
			},
			access = access_type_all
		}
	end

	if difficulty_index < 6 then
		self.unit_categories.FBI_shield = {
			special_type = "shield",
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_shield_1/ene_shield_1"),
					Idstring("units/payday2/characters/ene_shield_1/ene_shield_1"),
					Idstring("units/payday2/characters/ene_shield_1/ene_shield_1"),
					Idstring("units/payday2/characters/ene_shield_1/ene_shield_1")
				},
				bo_hh = {
					Idstring("units/pd2_mod_bofa/characters/ovk_units/ene_ovk_shield_mp9/ene_ovk_shield_mp9")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_shield_sr2_smg/ene_akan_fbi_shield_sr2_smg")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_shield_hvh_1/ene_shield_hvh_1")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_shield/ene_murky_shield"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_shield/ene_murky_shield"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_shield/ene_murky_shield"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_shield/ene_murky_shield")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_shield_policia_federale_mp9/ene_swat_shield_policia_federale_mp9"),
					Idstring("units/pd2_dlc_bex/characters/ene_swat_shield_policia_federale_mp9/ene_swat_shield_policia_federale_mp9"),
					Idstring("units/pd2_dlc_bex/characters/ene_swat_shield_policia_federale_mp9/ene_swat_shield_policia_federale_mp9"),
					Idstring("units/pd2_dlc_bex/characters/ene_swat_shield_policia_federale_mp9/ene_swat_shield_policia_federale_mp9")
				},
				shared = {
					Idstring("units/payday2/characters/ene_shield_1/ene_shield_1"),
					Idstring("units/payday2/characters/ene_shield_1/ene_shield_1"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_shield/ene_murky_shield"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_shield/ene_murky_shield")
				}
			},
			access = access_type_all
		}
	elseif difficulty_index < 8 then
		self.unit_categories.FBI_shield = {
			special_type = "shield",
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_city_shield/ene_city_shield")
				},
				bo_hh = {
					Idstring("units/pd2_mod_bofa/characters/bofa_units/ene_bofa_shield_mp9/ene_bofa_shield_mp9")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_shield_sr2_smg/ene_akan_fbi_shield_sr2_smg")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_shield_hvh_1/ene_shield_hvh_1")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_shield/ene_murky_shield")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_shield_policia_federale_mp9/ene_swat_shield_policia_federale_mp9")
				},
				shared = {
					Idstring("units/payday2/characters/ene_city_shield/ene_city_shield"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_shield/ene_murky_shield")
				}
			},
			access = access_type_all
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
					Idstring("units/pd2_dlc_hvh/characters/ene_fbi_swat_shield_ds/ene_fbi_swat_shield_ds")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murky_DS_shield/ene_murky_DS_shield")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_heavy_swat_shield_federale_ds/ene_heavy_swat_shield_federale_ds")
				},
				shared = {
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_swat_shield_hh/ene_zeal_swat_shield_hh"),
					Idstring("units/pd2_mod_psc/characters/ene_murky_DS_shield/ene_murky_DS_shield")
				}
			},
			access = access_type_all
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
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_2/ene_murkywater_bulldozer_2")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_r870/ene_swat_dozer_policia_federale_r870")
				},
				shared = { 
					Idstring("units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1"),
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_2/ene_murkywater_bulldozer_2")
				}
			},
			access = access_type_all
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
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_2/ene_murkywater_bulldozer_2"),
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_3/ene_murkywater_bulldozer_3")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_saiga/ene_swat_dozer_policia_federale_saiga"),
					Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_r870/ene_swat_dozer_policia_federale_r870")
				},
				shared = { 
					Idstring("units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1"),
					Idstring("units/payday2/characters/ene_bulldozer_2/ene_bulldozer_2"),
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_2/ene_murkywater_bulldozer_2"),
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_3/ene_murkywater_bulldozer_3")
				}
			},
			access = access_type_all
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
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_4/ene_murkywater_bulldozer_4"),
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_2/ene_murkywater_bulldozer_2"),
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_3/ene_murkywater_bulldozer_3")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_r870/ene_swat_dozer_policia_federale_r870"),
					Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_saiga/ene_swat_dozer_policia_federale_saiga"),
					Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_m249/ene_swat_dozer_policia_federale_m249")
				},
				shared = {
					Idstring("units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1"),
					Idstring("units/payday2/characters/ene_bulldozer_2/ene_bulldozer_2"),
					Idstring("units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3"),
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_4/ene_murkywater_bulldozer_4"),
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_2/ene_murkywater_bulldozer_2"),
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_3/ene_murkywater_bulldozer_3")					
				}
			},
			access = access_type_all
		}
	elseif difficulty_index == 7 then
		self.unit_categories.FBI_tank = {
			special_type = "tank",
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1"),
					Idstring("units/payday2/characters/ene_bulldozer_2/ene_bulldozer_2"),
					Idstring("units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3"),
					Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_minigun_classic/ene_bulldozer_minigun_classic")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_r870/ene_akan_fbi_tank_r870"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_saiga/ene_akan_fbi_tank_saiga"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_rpk_lmg/ene_akan_fbi_tank_rpk_lmg"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_dozer_mini/ene_akan_dozer_mini")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_1/ene_bulldozer_hvh_1"),
					Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_2/ene_bulldozer_hvh_2"),
					Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_3/ene_bulldozer_hvh_3"),
					Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_minigun_classic/ene_bulldozer_minigun_classic")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_2/ene_murkywater_bulldozer_2"),
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_3/ene_murkywater_bulldozer_3"),
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_4/ene_murkywater_bulldozer_4"),
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_1/ene_murkywater_bulldozer_1"),
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_r870/ene_swat_dozer_policia_federale_r870"),
					Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_saiga/ene_swat_dozer_policia_federale_saiga"),
					Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_m249/ene_swat_dozer_policia_federale_m249"),
					Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_minigun/ene_swat_dozer_policia_federale_minigun")
				},
				--Lord, I hate everything about how this physically and visually presents itself.
				shared = {
					Idstring("units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1"),
					Idstring("units/payday2/characters/ene_bulldozer_2/ene_bulldozer_2"),
					Idstring("units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3"),
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_2/ene_murkywater_bulldozer_2"),
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_3/ene_murkywater_bulldozer_3"),
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_4/ene_murkywater_bulldozer_4"),
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_1/ene_murkywater_bulldozer_1"),					
					Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_minigun_classic/ene_bulldozer_minigun_classic")
				}
			},
			access = access_type_all
		}
	else
		self.unit_categories.FBI_tank = {
			special_type = "tank",
			unit_types = {
				america = {
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
					Idstring("units/pd2_dlc_mad/characters/ene_akan_dozer_medic/ene_akan_dozer_medic"),
					Idstring("units/pd2_dlc_mad/characters/ene_akan_dozer_mini/ene_akan_dozer_mini")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_1/ene_bulldozer_hvh_1"),
					Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_2/ene_bulldozer_hvh_2"),
					Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_3/ene_bulldozer_hvh_3"),
					Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_medic/ene_bulldozer_medic"),
					Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_minigun/ene_bulldozer_minigun")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_2/ene_murkywater_bulldozer_2"),
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_3/ene_murkywater_bulldozer_3"),
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_4/ene_murkywater_bulldozer_4"),
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_1/ene_murkywater_bulldozer_1"),
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_medic/ene_murkywater_bulldozer_medic")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_r870/ene_swat_dozer_policia_federale_r870"),
					Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_saiga/ene_swat_dozer_policia_federale_saiga"),
					Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_m249/ene_swat_dozer_policia_federale_m249"),
					Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_minigun/ene_swat_dozer_policia_federale_minigun"),
					Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_medic_policia_federale/ene_swat_dozer_medic_policia_federale")
				},
				shared = {
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer/ene_zeal_bulldozer"),
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer_2/ene_zeal_bulldozer_2"),
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer_3/ene_zeal_bulldozer_3"),
					Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_medic/ene_bulldozer_medic"),
					Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_minigun/ene_bulldozer_minigun"),
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_2/ene_murkywater_bulldozer_2"),
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_3/ene_murkywater_bulldozer_3"),
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_4/ene_murkywater_bulldozer_4"),
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_1/ene_murkywater_bulldozer_1"),
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_medic/ene_murkywater_bulldozer_medic")					
				}
			},
			access = access_type_all
		}
	end
	
	if difficulty_index <= 7 then
		self.unit_categories.medic_M4 = {
			special_type = "medic",
			unit_types = {
				america = {
					Idstring("units/payday2/characters/ene_medic_m4_hh/ene_medic_m4_hh")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_medic_ak47_ass_hh/ene_akan_medic_ak47_ass_hh")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_medic_hvh_m4/ene_medic_hvh_m4")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_medic/ene_murkywater_medic")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_medic_federale_rifle_hh/ene_medic_federale_rifle_hh")
				},
				shared = {
					Idstring("units/payday2/characters/ene_medic_m4/ene_medic_m4"),				
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_medic/ene_murkywater_medic")
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
				bo_hh = {
					Idstring("units/pd2_mod_bofa/characters/special_units/ene_bofa_medic_r870/ene_bofa_medic_r870")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_medic_r870/ene_akan_medic_r870")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_medic_hvh_r870/ene_medic_hvh_r870")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_medic_r870/ene_murkywater_medic_r870")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_medic_federale_r870_hh/ene_medic_federale_r870_hh")
				},
				shared = {
					Idstring("units/payday2/characters/ene_medic_r870/ene_medic_r870"),
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_medic_r870/ene_murkywater_medic_r870")					
				}
			},
			access = access_type_all
		}
	else
		self.unit_categories.medic_M4 = {
			special_type = "medic",
			unit_types = {
				america = {
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_medic/ene_zeal_medic")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_medic_ak47_ass_hh/ene_akan_medic_ak47_ass_hh")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_medic_hvh_m4/ene_medic_hvh_m4")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_medic/ene_murkywater_medic")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_medic_federale_rifle_hh/ene_medic_federale_rifle_hh")
				},
				shared = {
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_medic/ene_murkywater_medic"),
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_medic/ene_zeal_medic")
				}
			},
			access = access_type_all
		}
		self.unit_categories.medic_R870 = {
			special_type = "medic",
			unit_types = {
				america = {
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_medic_r870/ene_zeal_medic_r870")
				},
				russia = {
					Idstring("units/pd2_dlc_mad/characters/ene_akan_medic_r870/ene_akan_medic_r870")
				},
				zombie = {
					Idstring("units/pd2_dlc_hvh/characters/ene_medic_hvh_r870/ene_medic_hvh_r870")
				},
				murkywater = {
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_medic_r870/ene_murkywater_medic_r870")
				},
				federales = {
					Idstring("units/pd2_dlc_bex/characters/ene_medic_federale_r870_hh/ene_medic_federale_r870_hh")
				},
				shared = {
					Idstring("units/pd2_mod_psc/characters/ene_murkywater_medic_r870/ene_murkywater_medic_r870"),
					Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_medic_r870/ene_zeal_medic_r870")
				}
			},
			access = access_type_all
		}
	end
		
	self.unit_categories.Phalanx_minion = {
		is_captain = true,
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
			},
			federales = {
				Idstring("units/pd2_dlc_vip/characters/ene_phalanx_1/ene_phalanx_1")
			},
			shared = {
				Idstring("units/pd2_dlc_vip/characters/ene_phalanx_1/ene_phalanx_1")
			}			
		},
		access = access_type_all
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
				Idstring("units/pd2_dlc_vip/characters/ene_phalanx_1/ene_phalanx_1")
			},
			federales = {
				Idstring("units/pd2_dlc_vip/characters/ene_phalanx_1/ene_phalanx_1")
			},
			shared = {
				Idstring("units/pd2_dlc_vip/characters/ene_phalanx_1/ene_phalanx_1")
			}			
		},
		access = access_type_all
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
		swat_rifle_civil_indenpendant = {
			"ranged_fire",
			"provide_coverfire",
			"flash_grenade",
			"provide_support",
			--"lonewolf",
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
		swat_rifle_flank_civil_independant = {
			"flank",
			"provide_coverfire",
			"ranged_fire",
			"smoke_grenade",
			"provide_support",
			--"lonewolf",
			"groupany"
		},
		swat_rifle_complex = {
			"elite_ranged_fire",
			"provide_coverfire",
			"flash_grenade",
			"provide_support",
			"groupany"
		},
		swat_rifle_complex_independant = {
			"elite_ranged_fire",
			"provide_coverfire",
			"flash_grenade",
			"provide_support",
			--"lonewolf",
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
		swat_rifle_flank_complex_independant = {
			"hunter",
			"flank",
			"provide_coverfire",
			"elite_ranged_fire",
			"smoke_grenade",
			"provide_support",
			--"lonewolf",
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
		swat_rifle_independant = {
			"elite_ranged_fire",
			"provide_coverfire",
			"flash_grenade",
			"provide_support",
			"harass",
			--"lonewolf",
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
		swat_rifle_flank_independant = {
			"hunter",
			"flank",
			"provide_coverfire",
			"elite_ranged_fire",
			"smoke_grenade",
			"provide_support",
			--"lonewolf",
			"groupany"
		},
		sniper_direct = {
			"elite_ranged_fire",
			"provide_coverfire",
			"flash_grenade",
			"provide_support",
			"harass",
			"groupany",
			"sniper"
		},
		sniper_flank = {
			"flank",
			"elite_ranged_fire",
			"provide_coverfire",
			"flash_grenade",
			"provide_support",
			"harass",
			"groupany",
			"sniper"
		},
		swat_shotgun_rush_civil = {
			"charge",
			"provide_coverfire",
			"flash_grenade", --pushers use flashes
			"provide_support",
			"groupany"
		},
		swat_shotgun_rush_civil_independant = {
			"charge",
			"provide_coverfire",
			"flash_grenade", --pushers use flashes
			"provide_support",
			--"lonewolf",
			"groupany"
		},
		swat_shotgun_rush_complex = {
			"charge",
			"provide_coverfire",
			"flash_grenade", --pushers use flashes
			"provide_support",
			"groupany"
		},
		swat_shotgun_rush_complex_independant = {
			"charge",
			"provide_coverfire",
			"flash_grenade", --pushers use flashes
			"provide_support",
			--"lonewolf",
			"groupany"
		},
		swat_shotgun_rush = {
			"charge",
			"provide_coverfire",
			"flash_grenade", --pushers use flashes
			"provide_support",
			"harass",
			"groupany"
		},
		swat_shotgun_rush_independant = {
			"charge",
			"provide_coverfire",
			"flash_grenade", --pushers use flashes
			"provide_support",
			"harass",
			--"lonewolf",
			"groupany"
		},
		swat_shotgun_flank_civil = {
			"flank",
			"provide_coverfire",
			"smoke_grenade", --flank uses smoke
			"provide_support",
			"groupany"
		},
		swat_shotgun_flank_civil_independant = {
			"flank",
			"provide_coverfire",
			"smoke_grenade", --flank uses smoke
			"provide_support",
			"groupany"
		},
		swat_shotgun_flank_complex = {
			"deathguard",
			"flank",
			"provide_coverfire",
			"smoke_grenade", --flank uses smoke
			"provide_support",
			"groupany",
			"hitnrun" --the idea is after they open fire, and you're near, they'll run away to a safe spot before striking again since they'll only decide to back off after opening fire
		},
		swat_shotgun_flank_complex_independant = {
			"deathguard",
			"flank",
			"provide_coverfire",
			"smoke_grenade", --flank uses smoke
			"provide_support",
			--"lonewolf",
			"groupany",
			"hitnrun" --the idea is after they open fire, and you're near, they'll run away to a safe spot before striking again since they'll only decide to back off after opening fire
		},
		swat_shotgun_flank = {
			"deathguard",
			"flank",
			"provide_coverfire",
			"smoke_grenade", --flank uses smoke
			"provide_support",
			"hitnrun", --the idea is after they open fire, and you're near, they'll run away to a safe spot before striking again since they'll only decide to back off after opening fire
			"groupany"
		},
		swat_shotgun_flank_independant = {
			"deathguard",
			"flank",
			"provide_coverfire",
			"smoke_grenade", --flank uses smoke
			"provide_support",
			--"lonewolf",
			"hitnrun", --the idea is after they open fire, and you're near, they'll run away to a safe spot before striking again since they'll only decide to back off after opening fire
			"groupany"
		},
		shield_wall_ranged = {
			"shield_cover",
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
			"shield_cover",
			"deathguard",
			"shield",
			"charge",
			"provide_support"
		},
		shield_support_charge = {
			"shield_cover",
			"deathguard", 
			"charge",
			"provide_coverfire",
			"flash_grenade", --pushers use flashes
			"provide_support" --important, when they lose the shield, they can protect eachother
		},
		shield_wall = {
			"hunter",
			"shield_cover", 
			"shield",
			"charge",
			"hitnrun", --they'll charge, barrage and back off
			"provide_support",
			--"tunnel"
		},
		tazer_flanking = {
			"shield_cover",
			"hunter",
			"flank",
			"provide_coverfire",
			"smoke_grenade",
			--"tunnel"		 
		},
		tazer_flanking_independant = {
			"hunter",
			"flank",
			"provide_coverfire",
			"smoke_grenade",
			--"lonewolf",
			--"tunnel"		 
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
			--"tunnel"
		},
		tank_rush_independant = {
			"deathguard",
			"charge",
			"flash_grenade", --use flashes
			"provide_coverfire",
			"shield_cover", --if he spawns with a shield, he'll get covered so he can bust your fucking ass
			--"lonewolf",
			--"tunnel"
		},
		spooc = {
			"shield_cover",
			"flank",
			"smoke_grenade",
			--"lonewolf",
			--"spooctargeting"			
		},
		spoocaggressive = {
			"shield_cover",
			"charge",
			"flash_grenade",
			--"spooctargeting"
		},
		spoocelite = {
			"hunter",
			"shield_cover",
			"flank",
			"smoke_grenade",
			--"lonewolf",
			"harass"
		},
		spoocaggressiveelite = {
			"hunter",
			"shield_cover",
			"charge",
			"flash_grenade",
			--"lonewolf",
			"harass"		
		},
		spooccreep = {
			"hunter",
			"shield_cover",
			"charge",
			"spoocavoidance",
			--"lonewolf",
			"harass"
		},
		marshal_marksman = {
			"ranged_fire",
			"flank"
		}
	}

	if managers.modifiers and managers.modifiers:check_boolean("TotalAnarchy")  then
		self.enemy_spawn_groups.recon_squad_A = {
			amount = {
				2,
				4
			},
			spawn = {
				{
					freq = 1.25,
					amount_min = 1,
					amount_max = 3,
					rank = 2,
					unit = "punk_group",
					tactics = self._tactics.swat_rifle_flank
				},
				{
					freq = 1,
					amount_max = 2,
					rank = 2,
					unit = "CS_swat_SMG",
					tactics = self._tactics.swat_rifle_flank
				}
			}
		}
		self.enemy_spawn_groups.recon_squad_B = {
			amount = {
				3,
				3
			},
			spawn = {
				{
					freq = 1,
					amount_max = 2,
					rank = 2,
					unit = "CS_swat_SMG",
					tactics = self._tactics.swat_rifle_flank
				},
				{
					freq = 0.5,
					amount_max = 1,
					rank = 2,
					unit = "FBI_LHmix",
					tactics = self._tactics.swat_rifle_flank
				},
			}
		}
		self.enemy_spawn_groups.recon_squad_C = {
			amount = {
				5,
				5
			},
			spawn = {
				{
					freq = 0.5,
					amount_max = 2,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_flank
				},
				{
					freq = 1,
					amount_min = 1,
					amount_max = 1,
					rank = 3,
					unit = "FBI_shield",
					tactics = self._tactics.shield_wall_charge
				},
				{
					freq = 0.5,
					amount_max = 2,
					rank = 2,
					unit = "CS_swat_SMG",
					tactics = self._tactics.shield_support_charge
				},
				{
					freq = 0.5,
					amount_max = 2,
					rank = 2,
					unit = "punk_group",
					tactics = self._tactics.swat_shotgun_flank
				},
			}
		}
		self.enemy_spawn_groups.recon_squad_D = {
			amount = {
				4,
				5
			},
			spawn = {
				{
					freq = 1,
					amount_max = 1,
					rank = 2,
					unit = "FBI_heavy_R870",
					tactics = self._tactics.swat_shotgun_flank
				},
				{
					freq = 1.25,
					amount_max = 1,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_flank
				},
				{
					freq = 1.25,
					amount_min = 1,
					amount_max = 3,
					rank = 2,
					unit = "CS_swat_SMG",
					tactics = self._tactics.swat_shotgun_flank
				},
				{
					freq = 1.5,
					amount_max = 2,
					rank = 2,
					unit = "punk_group",
					tactics = self._tactics.swat_shotgun_flank
				},
			}
		}
	elseif difficulty_index <= 3 then
		self.enemy_spawn_groups.recon_squad_A = {
			amount = {
				2,
				4
			},
			spawn = {
				{
					freq = 1.25,
					amount_min = 1,
					amount_max = 3,
					rank = 2,
					unit = "punk_group",
					tactics = self._tactics.swat_rifle_flank_civil
				},
				{
					freq = 1,
					amount_max = 2,
					rank = 2,
					unit = "CS_swat_SMG",
					tactics = self._tactics.swat_rifle_flank_civil
				}
			}
		}
		self.enemy_spawn_groups.recon_squad_B = {
			amount = {
				3,
				3
			},
			spawn = {
				{
					freq = 1,
					amount_max = 2,
					rank = 2,
					unit = "CS_swat_SMG",
					tactics = self._tactics.swat_rifle_civil
				},
				{
					freq = 0.5,
					amount_max = 1,
					rank = 2,
					unit = "punk_group",
					tactics = self._tactics.swat_rifle_civil
				},
			}
		}
		self.enemy_spawn_groups.recon_squad_C = {
			amount = {
				3,
				3
			},
			spawn = {
				{
					freq = 0.5,
					amount_max = 2,
					rank = 2,
					unit = "CS_swat_R870",
					tactics = self._tactics.swat_rifle_civil
				},
				{
					freq = 0.3,
					amount_max = 1,
					rank = 2,
					unit = "CS_shield",
					tactics = self._tactics.shield_wall_charge
				},
				{
					freq = 0.5,
					amount_max = 2,
					rank = 2,
					unit = "CS_swat_SMG",
					tactics = self._tactics.shield_support_charge
				},
				{
					freq = 0.5,
					amount_max = 2,
					rank = 2,
					unit = "punk_group",
					tactics = self._tactics.swat_shotgun_rush_civil
				},
			}
		}
		self.enemy_spawn_groups.recon_squad_D = {
			amount = {
				3,
				3
			},
			spawn = {
				{
					freq = 1.25,
					amount_max = 1,
					rank = 2,
					unit = "CS_swat_R870",
					tactics = self._tactics.swat_shotgun_flank_civil
				},
				{
					freq = 1.25,
					amount_min = 1,
					amount_max = 1,
					rank = 2,
					unit = "CS_swat_SMG",
					tactics = self._tactics.swat_shotgun_flank_civil
				},
				{
					freq = 1.5,
					amount_max = 2,
					rank = 2,
					unit = "punk_group",
					tactics = self._tactics.swat_shotgun_flank_civil
				},
			}
		}
	elseif difficulty_index <= 5 then
		self.enemy_spawn_groups.recon_squad_A = {
			amount = {
				2,
				4
			},
			spawn = {
				{
					freq = 1.25,
					amount_min = 1,
					amount_max = 3,
					rank = 2,
					unit = "punk_group",
					tactics = self._tactics.swat_rifle_flank_civil
				},
				{
					freq = 1,
					amount_max = 2,
					rank = 2,
					unit = "CS_swat_SMG",
					tactics = self._tactics.swat_rifle_flank_civil
				}
			}
		}
		self.enemy_spawn_groups.recon_squad_B = {
			amount = {
				3,
				3
			},
			spawn = {
				{
					freq = 1,
					amount_max = 2,
					rank = 2,
					unit = "CS_swat_SMG",
					tactics = self._tactics.swat_rifle_flank_civil
				},
				{
					freq = 0.5,
					amount_max = 1,
					rank = 2,
					unit = "FBI_swat_M4",
					tactics = self._tactics.swat_rifle_flank_civil
				},
			}
		}
		self.enemy_spawn_groups.recon_squad_C = {
			amount = {
				5,
				5
			},
			spawn = {
				{
					freq = 0.5,
					amount_max = 2,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_flank_civil
				},
				{
					freq = 1,
					amount_min = 1,
					amount_max = 1,
					rank = 2,
					unit = "FBI_shield",
					tactics = self._tactics.shield_wall_charge
				},
				{
					freq = 0.5,
					amount_max = 2,
					rank = 2,
					unit = "CS_swat_SMG",
					tactics = self._tactics.shield_support_charge
				},
				{
					freq = 0.5,
					amount_max = 2,
					rank = 2,
					unit = "punk_group",
					tactics = self._tactics.swat_shotgun_flank_civil
				},
			}
		}
		self.enemy_spawn_groups.recon_squad_D = {
			amount = {
				4,
				5
			},
			spawn = {
				{
					freq = 1.25,
					amount_max = 1,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_flank_civil
				},
				{
					freq = 1.25,
					amount_min = 1,
					amount_max = 3,
					rank = 2,
					unit = "CS_swat_SMG",
					tactics = self._tactics.swat_shotgun_flank_civil
				},
				{
					freq = 1.5,
					amount_max = 2,
					rank = 2,
					unit = "punk_group",
					tactics = self._tactics.swat_shotgun_flank_civil
				},
			}
		}
	elseif difficulty_index <= 7 then
		self.enemy_spawn_groups.recon_squad_A = {
			amount = {
				2,
				4
			},
			spawn = {
				{
					freq = 1.25,
					amount_min = 1,
					amount_max = 3,
					rank = 2,
					unit = "punk_group",
					tactics = self._tactics.swat_rifle_flank_complex
				},
				{
					freq = 1,
					amount_max = 2,
					rank = 2,
					unit = "CS_swat_SMG",
					tactics = self._tactics.swat_rifle_flank_complex
				}
			}
		}
		self.enemy_spawn_groups.recon_squad_B = {
			amount = {
				3,
				3
			},
			spawn = {
				{
					freq = 1,
					amount_max = 2,
					rank = 2,
					unit = "CS_swat_SMG",
					tactics = self._tactics.swat_rifle_flank_complex
				},
				{
					freq = 0.5,
					amount_max = 1,
					rank = 2,
					unit = "FBI_swat_M4",
					tactics = self._tactics.swat_rifle_flank_complex
				},
			}
		}
		self.enemy_spawn_groups.recon_squad_C = {
			amount = {
				5,
				5
			},
			spawn = {
				{
					freq = 0.5,
					amount_max = 2,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_flank_complex
				},
				{
					freq = 1,
					amount_min = 1,
					amount_max = 1,
					rank = 2,
					unit = "FBI_shield",
					tactics = self._tactics.shield_wall_charge
				},
				{
					freq = 0.5,
					amount_max = 2,
					rank = 2,
					unit = "CS_swat_SMG",
					tactics = self._tactics.shield_support_charge
				},
				{
					freq = 0.5,
					amount_max = 2,
					rank = 2,
					unit = "punk_group",
					tactics = self._tactics.swat_shotgun_flank_complex
				},
			}
		}
		self.enemy_spawn_groups.recon_squad_D = {
			amount = {
				4,
				5
			},
			spawn = {
				{
					freq = 1.25,
					amount_max = 1,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_flank_complex
				},
				{
					freq = 1.25,
					amount_min = 1,
					amount_max = 3,
					rank = 2,
					unit = "CS_swat_SMG",
					tactics = self._tactics.swat_shotgun_flank_complex
				},
				{
					freq = 1.5,
					amount_max = 2,
					rank = 2,
					unit = "punk_group",
					tactics = self._tactics.swat_shotgun_flank_complex
				},
			}
		}
	else
		self.enemy_spawn_groups.recon_squad_A = {
			amount = {
				2,
				4
			},
			spawn = {
				{
					freq = 1.25,
					amount_min = 1,
					amount_max = 3,
					rank = 2,
					unit = "punk_group",
					tactics = self._tactics.swat_rifle_flank
				},
				{
					freq = 1,
					amount_max = 2,
					rank = 2,
					unit = "CS_swat_SMG",
					tactics = self._tactics.swat_rifle_flank
				}
			}
		}
		self.enemy_spawn_groups.recon_squad_B = {
			amount = {
				3,
				3
			},
			spawn = {
				{
					freq = 1,
					amount_max = 2,
					rank = 2,
					unit = "CS_swat_SMG",
					tactics = self._tactics.swat_rifle_flank
				},
				{
					freq = 0.5,
					amount_max = 1,
					rank = 2,
					unit = "FBI_LHmix",
					tactics = self._tactics.swat_rifle_flank
				},
			}
		}
		self.enemy_spawn_groups.recon_squad_C = {
			amount = {
				5,
				5
			},
			spawn = {
				{
					freq = 0.5,
					amount_max = 2,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_flank
				},
				{
					freq = 1,
					amount_min = 1,
					amount_max = 1,
					rank = 2,
					unit = "FBI_shield",
					tactics = self._tactics.shield_wall_charge
				},
				{
					freq = 0.5,
					amount_max = 2,
					rank = 2,
					unit = "CS_swat_SMG",
					tactics = self._tactics.shield_support_charge
				},
				{
					freq = 0.5,
					amount_max = 2,
					rank = 2,
					unit = "punk_group",
					tactics = self._tactics.swat_shotgun_flank
				},
			}
		}
		self.enemy_spawn_groups.recon_squad_D = {
			amount = {
				4,
				5
			},
			spawn = {
				{
					freq = 1,
					amount_max = 1,
					rank = 2,
					unit = "FBI_heavy_R870",
					tactics = self._tactics.swat_shotgun_flank
				},
				{
					freq = 1.25,
					amount_max = 1,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_flank
				},
				{
					freq = 1.25,
					amount_min = 1,
					amount_max = 3,
					rank = 2,
					unit = "CS_swat_SMG",
					tactics = self._tactics.swat_shotgun_flank
				},
				{
					freq = 1.5,
					amount_max = 2,
					rank = 2,
					unit = "punk_group",
					tactics = self._tactics.swat_shotgun_flank
				},
			}
		}
	end
	
	if managers.modifiers and managers.modifiers:check_boolean("TotalAnarchy")  then
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
					tactics = self._tactics.swat_rifle_complex
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
					freq = 0.5,
					amount_max = 1,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_rush_complex
				},
				{
					amount_min = 1,
					freq = 2,
					amount_max = 1,
					rank = 2,
					unit = "FBI_swat_M4",
					tactics = self._tactics.swat_rifle_complex
				},
				{
					freq = 2.25,
					amount_min = 2,
					amount_max = 3,
					rank = 1,
					unit = "punk_group",
					tactics = self._tactics.swat_shotgun_rush_complex
				},
				{
					amount_min = 0,
					freq = 0.5,
					amount_max = 1,
					rank = 3,
					unit = "medic_M4",
					tactics = self._tactics.swat_rifle_complex
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
					tactics = self._tactics.swat_rifle_complex
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
					unit = "FBI_tank",
					tactics = self._tactics.tank_rush
				},
				{
					amount_min = 0,
					freq = 0.5,
					amount_max = 1,
					rank = 2,
					unit = "medic_R870",
					tactics = self._tactics.swat_shotgun_rush_complex
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
	elseif difficulty_index <= 3 then
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
						unit = "CS_swat_SMG",
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
					unit = "CS_swat_SMG",
					tactics = self._tactics.shield_support_ranged
				},
				{
					freq = 0.75,
					amount_max = 2,
					rank = 2,
					unit = "FBI_swat_M4",
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
					tactics = self._tactics.swat_shotgun_rush_civil
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
					tactics = self._tactics.swat_rifle_complex
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
					freq = 0.5,
					amount_max = 1,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_rush_complex
				},
				{
					amount_min = 1,
					freq = 2,
					amount_max = 1,
					rank = 2,
					unit = "FBI_swat_M4",
					tactics = self._tactics.swat_rifle_complex
				},
				{
					freq = 2.25,
					amount_min = 2,
					amount_max = 3,
					rank = 1,
					unit = "punk_group",
					tactics = self._tactics.swat_shotgun_rush_complex
				},
				{
					amount_min = 0,
					freq = 0.5,
					amount_max = 1,
					rank = 3,
					unit = "medic_M4",
					tactics = self._tactics.swat_rifle_complex
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
					tactics = self._tactics.swat_rifle_complex
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
					unit = "FBI_tank",
					tactics = self._tactics.tank_rush
				},
				{
					amount_min = 0,
					freq = 0.5,
					amount_max = 1,
					rank = 2,
					unit = "medic_R870",
					tactics = self._tactics.swat_shotgun_rush_complex
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
	
	if managers.modifiers and managers.modifiers:check_boolean("TotalAnarchy") then
		self.enemy_spawn_groups.tac_swat_shotgun_rush = {
			amount = {
				4,
				6
			},
			spawn = {
				{
					amount_min = 3,
					freq = 2,
					amount_max = 3,
					rank = 3,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_rush
				},
				{
					amount_min = 1,
					freq = 2,
					amount_max = 1,
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
					tactics = self._tactics.tazer_flanking_independant --Pinch.
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
					amount_min = 3,
					freq = 1,
					amount_max = 3,
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
					amount_min = 3,
					freq = 2,
					amount_max = 3,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_rush_civil
				},
				{
					amount_min = 1,
					freq = 2,
					amount_max = 1,
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
					amount_min = 3,
					freq = 2,
					amount_max = 3,
					rank = 3,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_rush_complex
				},
				{
					amount_min = 1,
					freq = 2,
					amount_max = 1,
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
					tactics = self._tactics.swat_shotgun_flank_civil_independant --forced pinch, no hit and run
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
					amount_min = 3,
					freq = 2,
					amount_max = 3,
					rank = 3,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_rush_complex
				},
				{
					amount_min = 1,
					freq = 2,
					amount_max = 1,
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
					tactics = self._tactics.swat_shotgun_flank_civil_independant --forced pinch, no hit and run
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
					amount_min = 3,
					freq = 2,
					amount_max = 3,
					rank = 3,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_rush
				},
				{
					amount_min = 1,
					freq = 2,
					amount_max = 1,
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
					tactics = self._tactics.tazer_flanking_independant --Pinch.
				},
				{
					amount_min = 0,
					freq = 1.9,
					amount_max = 2,
					rank = 2,
					unit = "FBI_swat_R870", --They're just heavies.
					tactics = self._tactics.swat_shotgun_flank_civil_independant
				}
			}
		}
	end
	
	if managers.modifiers and managers.modifiers:check_boolean("TotalAnarchy") then
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
					freq = 0.75,
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
					tactics = self._tactics.swat_shotgun_flank_independant
				},
				{
					amount_min = 0,
					freq = 0.35,
					amount_max = 1,
					rank = 2,
					unit = "medic_R870",
					tactics = self._tactics.swat_shotgun_flank_independant
				},
				{
					amount_min = 0,
					freq = 0.35,
					amount_max = 1,
					rank = 3,
					unit = "FBI_tank",
					tactics = self._tactics.tank_rush_independant --Basically your worst nightmare.
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
					amount_min = 3,
					freq = 2,
					amount_max = 3,
					rank = 2,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_flank_civil
				},
				{
					freq = 0.75,
					rank = 3,
					unit = "FBI_suit_M4_MP5",
					tactics = self._tactics.swat_shotgun_rush_civil_independant --oh no they're dumb
				},
				{
					amount_min = 1,
					freq = 2,
					amount_max = 1,
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
					amount_min = 3,
					freq = 2,
					amount_max = 3,
					rank = 3,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_rush_complex_independant --these guys are dumb too but at least that means the heavy and medic can flank
				},
				{
					amount_min = 1,
					freq = 2,
					amount_max = 1,
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
					freq = 0.5,
					rank = 3,
					unit = "FBI_suit_M4_MP5",
					tactics = self._tactics.swat_rifle_complex_independant --oh no they're dumb
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
					amount_min = 3,
					freq = 2,
					amount_max = 3,
					rank = 3,
					unit = "FBI_swat_R870",
					tactics = self._tactics.swat_shotgun_flank_complex
				},
				{
					amount_min = 1,
					freq = 2,
					amount_max = 1,
					rank = 3,
					unit = "FBI_heavy_R870",
					tactics = self._tactics.swat_shotgun_rush_complex_independant --flankers do hit and run while heavies and medic do a raw charge
				},
				{
					amount_min = 0,
					freq = 0.35,
					amount_max = 1,
					rank = 2,
					unit = "medic_R870",
					tactics = self._tactics.swat_shotgun_rush_complex_independant
				},
				{
					freq = 0.5,
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
				6
			},
			spawn = {
				{
					amount_min = 1,
					freq = 1,
					amount_max = 1,
					rank = 3,
					unit = "FBI_heavy_G36",
					tactics = self._tactics.swat_rifle_independant
				},
				{
					freq = 0.75,
					rank = 3,
					unit = "FBI_suit_M4_MP5", 
					tactics = self._tactics.swat_rifle_independant
				},
				{
					amount_min = 1,
					freq = 3,
					amount_max = 1,
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
					tactics = self._tactics.tank_rush_independant --Basically your worst nightmare.
				}																				
			}
		}
	end
	
	if managers.modifiers and managers.modifiers:check_boolean("TotalAnarchy") then
		self.enemy_spawn_groups.tac_swat_rifle = { --spamming three heavies is not interesting fuck off, no changes needed otherwise tbh
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
					unit = "FBI_swat_M4",
					tactics = self._tactics.swat_rifle
				},
				{
					amount_min = 1,
					freq = 3,
					amount_max = 1,
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
					amount_min = 3,
					freq = 1,
					amount_max = 3,
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
				},
				{
					amount_min = 0,
					freq = 0.25,
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
				5
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
					freq = 0.3,
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
					amount_min = 3,
					freq = 2,
					amount_max = 3,
					rank = 2,
					unit = "FBI_swat_M4",
					tactics = self._tactics.swat_rifle_complex
				},
				{
					amount_min = 1,
					freq = 2,
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
	else
		self.enemy_spawn_groups.tac_swat_rifle = { --spamming three heavies is not interesting fuck off
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
					unit = "FBI_swat_M4",
					tactics = self._tactics.swat_rifle
				},
				{
					amount_min = 1,
					freq = 3,
					amount_max = 1,
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
	
	if managers.modifiers and managers.modifiers:check_boolean("TotalAnarchy") then
		self.enemy_spawn_groups.tac_swat_rifle_flank = { --spamming 3 heavies is not interesting fuck off
			amount = {
				5,
				6
			},
			spawn = {
				{
					amount_min = 3,
					freq = 1,
					amount_max = 3,
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
					amount_min = 1,
					freq = 3,
					amount_max = 1,
					rank = 3,
					unit = "FBI_heavy_G36", 
					tactics = self._tactics.swat_rifle_independant
				},
				{
					amount_min = 0,
					freq = 0.35,
					amount_max = 1,
					rank = 2,
					unit = "medic_M4",
					tactics = self._tactics.swat_rifle_independant --others push while medic and heavies distract
				},
				{
					amount_min = 0,
					freq = 0.35,
					amount_max = 1,
					rank = 2,
					unit = "CS_tazer",
					tactics = self._tactics.tazer_flanking_independant --asshole-brand taser
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
				5
			},
			spawn = {
				{
					amount_min = 3,
					freq = 1,
					amount_max = 3,
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
				},
				{
					amount_min = 0,
					freq = 0.25,
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
				5
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
					freq = 0.3,
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
					amount_min = 3,
					freq = 2,
					amount_max = 3,
					rank = 2,
					unit = "FBI_swat_M4",
					tactics = self._tactics.swat_rifle_flank_civil
				},
				{
					amount_min = 1,
					freq = 2,
					amount_max = 1,
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
				},
				{
					freq = 0.2,
					rank = 1,
					unit = "FBI_suit_M4_MP5",
					tactics = self._tactics.swat_rifle_civil
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
					tactics = self._tactics.swat_rifle_complex_independant --they're uncoordinated
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
					amount_min = 3,
					freq = 1,
					amount_max = 3,
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
					amount_min = 1,
					freq = 3,
					amount_max = 1,
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
					amount_min = 3,
					freq = 1,
					amount_max = 3,
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
					amount_min = 1,
					freq = 3,
					amount_max = 1,
					rank = 3,
					unit = "FBI_heavy_G36", 
					tactics = self._tactics.swat_rifle_independant
				},
				{
					amount_min = 0,
					freq = 0.35,
					amount_max = 1,
					rank = 2,
					unit = "medic_M4",
					tactics = self._tactics.swat_rifle_independant --others push while medic and heavies distract
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
	
	if managers.modifiers and managers.modifiers:check_boolean("TotalAnarchy") then
		self.enemy_spawn_groups.tac_shield_wall_ranged = { --surprisingly im fine with this, its a fairly balanced spawn group
			amount = {
				4,
				6
			},
			special = "shield",
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
					tactics = self._tactics.swat_shotgun_flank_independant
				}
			}
		}
	elseif difficulty_index <= 2 then
		self.enemy_spawn_groups.tac_shield_wall_ranged = {
			amount = {
				4,
				4
			},
			special = "shield",
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
			special = "shield",
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
			special = "shield",
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
			special = "shield",
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
			special = "shield",
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
					tactics = self._tactics.swat_shotgun_flank_complex_independant
				}
			}
		}
	elseif difficulty_index == 7 then
		self.enemy_spawn_groups.tac_shield_wall_ranged = {
			amount = {
				4,
				6
			},
			special = "shield",
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
					tactics = self._tactics.swat_shotgun_flank_complex_independant
				}
			}
		}
	else
		self.enemy_spawn_groups.tac_shield_wall_ranged = { --surprisingly im fine with this, its a fairly balanced spawn group
			amount = {
				4,
				6
			},
			special = "shield",
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
					tactics = self._tactics.swat_shotgun_flank_independant
				}
			}
		}
	end
	
	if managers.modifiers and managers.modifiers:check_boolean("TotalAnarchy") then
		self.enemy_spawn_groups.tac_shield_wall_charge = {
			amount = {
				4,
				7
			},
			special = "shield",
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
					tactics = self._tactics.tazer_flanking_independant --pinch boi
				},
				{
					amount_min = 0,
					freq = 0.35,
					amount_max = 1,
					rank = 3,
					unit = "FBI_heavy_G36",
					tactics = self._tactics.swat_rifle_independant --distant support
				}
			}
		}
	elseif difficulty_index <= 2 then
		self.enemy_spawn_groups.tac_shield_wall_charge = {
			amount = {
				4,
				4
			},
			special = "shield",
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
			special = "shield",
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
			special = "shield",
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
					tactics = self._tactics.swat_shotgun_flank_civil_independant --pinchy boi
				}
			}
		}
	elseif difficulty_index == 5 then
		self.enemy_spawn_groups.tac_shield_wall_charge = {
			amount = {
				4,
				6
			},
			special = "shield",
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
					tactics = self._tactics.swat_shotgun_flank_civil_independant --pinchy boi
				}
			}
		}
	elseif difficulty_index == 6 then
		self.enemy_spawn_groups.tac_shield_wall_charge = {
			amount = {
				4,
				6
			},
			special = "shield",
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
					tactics = self._tactics.swat_shotgun_flank_complex_independant --pinchy boi
				}
			}
		}
	elseif difficulty_index == 7 then
		self.enemy_spawn_groups.tac_shield_wall_charge = {
			amount = {
				4,
				6
			},
			special = "shield",
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
					rank = 1,
					unit = "CS_tazer",
					tactics = self._tactics.tazer_flanking_independant --pinch boi
				}
			}
		}
	else
		self.enemy_spawn_groups.tac_shield_wall_charge = {
			amount = {
				4,
				7
			},
			special = "shield",
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
					tactics = self._tactics.tazer_flanking_independant --pinch boi
				},
				{
					amount_min = 0,
					freq = 0.35,
					amount_max = 1,
					rank = 3,
					unit = "FBI_heavy_G36",
					tactics = self._tactics.swat_rifle_independant --distant support
				}
			}
		}
	end
	
	if managers.modifiers and managers.modifiers:check_boolean("TotalAnarchy") then
		self.enemy_spawn_groups.tac_shield_wall = {
			amount = {
				6,
				6
			},
			special = "shield",
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
			special = "shield",
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
			special = "shield",
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
			special = "shield",
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
			special = "shield",
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
					unit = "FBI_heavy_R870",
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
			special = "shield",
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
					unit = "FBI_heavy_R870",
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
			special = "shield",
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
					unit = "FBI_heavy_R870",
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
			special = "shield",
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
					unit = "FBI_heavy_R870",
					tactics = self._tactics.shield_support_ranged
				}
			}
		}
	end
	
	if managers.modifiers and managers.modifiers:check_boolean("TotalAnarchy") then
		self.enemy_spawn_groups.tac_tazer_flanking = {
			amount = {
				1,
				4
			},
			special = "taser",
			spawn = {
				{
					amount_min = 1,
					freq = 1,
					amount_max = 1,
					rank = 2,
					unit = "CS_tazer",
					tactics = self._tactics.tazer_flanking
				},
				{
					freq = 0.5,
					rank = 1,
					unit = "FBI_suit_M4_MP5",
					tactics = self._tactics.swat_rifle_civil_indenpendant
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
			special = "taser",
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
			special = "taser",
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
			special = "taser",
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
			special = "taser",
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
					tactics = self._tactics.swat_rifle_civil_indenpendant
				}
			}
		}
	elseif difficulty_index == 6 then
		self.enemy_spawn_groups.tac_tazer_flanking = {
			amount = {
				1,
				4
			},
			special = "taser",
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
					tactics = self._tactics.swat_rifle_civil_indenpendant
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
			special = "taser",
			spawn = {
				{
					amount_min = 1,
					freq = 1,
					amount_max = 1,
					rank = 2,
					unit = "CS_tazer",
					tactics = self._tactics.tazer_flanking
				},
				{
					freq = 0.5,
					rank = 1,
					unit = "FBI_suit_M4_MP5",
					tactics = self._tactics.swat_rifle_civil_indenpendant
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
			special = "taser",
			spawn = {
				{
					amount_min = 1,
					freq = 1,
					amount_max = 1,
					rank = 2,
					unit = "CS_tazer",
					tactics = self._tactics.tazer_flanking
				},
				{
					freq = 0.5,
					rank = 1,
					unit = "FBI_suit_M4_MP5",
					tactics = self._tactics.swat_rifle_civil_indenpendant
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

	if managers.modifiers and managers.modifiers:check_boolean("TotalAnarchy") then
		self.enemy_spawn_groups.tac_tazer_charge = {
			amount = {
				1,
				5
			},
			special = "taser",
			spawn = {
				{
					amount_min = 1,
					freq = 1,
					amount_max = 1,
					rank = 2,
					unit = "CS_tazer",
					tactics = self._tactics.shield_support_charge
				},
				{
					freq = 0.5,
					rank = 1,
					unit = "FBI_suit_M4_MP5",
					tactics = self._tactics.swat_rifle_flank_civil_independant
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
			special = "taser",
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
			special = "taser",
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
			special = "taser",
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
			special = "taser",
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
				3
			},
			special = "taser",
			spawn = {
				{
					amount_min = 1,
					freq = 1,
					amount_max = 1,
					rank = 3,
					unit = "CS_tazer",
					tactics = self._tactics.tazer_charge
				},
				{
					amount_max = 2,
					freq = 0.5,
					rank = 2,
					unit = "FBI_suit_M4_MP5",
					tactics = self._tactics.swat_rifle_flank_civil_independant
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
			special = "taser",
			spawn = {
				{
					amount_min = 1,
					freq = 1,
					amount_max = 1,
					rank = 2,
					unit = "CS_tazer",
					tactics = self._tactics.shield_support_charge
				},
				{
					amount_max = 2,
					freq = 0.5,
					rank = 1,
					unit = "FBI_suit_M4_MP5",
					tactics = self._tactics.swat_rifle_flank_civil_independant
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
	
	if managers.modifiers and managers.modifiers:check_boolean("TotalAnarchy") then
		self.enemy_spawn_groups.tac_bull_rush = {
			amount = {
				1,
				5
			},
			special = "tank",
			spawn = {
				{
					amount_min = 1,
					freq = 1,
					amount_max = 1,
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
			special = "tank",
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
			special = "tank",
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
			special = "tank",
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
			special = "tank",
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
			special = "tank",
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
	else
		self.enemy_spawn_groups.tac_bull_rush = {
			amount = {
				1,
				5
			},
			special = "tank",
			spawn = {
				{
					amount_min = 1,
					freq = 1,
					amount_max = 1,
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
	if managers.modifiers and managers.modifiers:check_boolean("TotalAnarchy") then
		self.enemy_spawn_groups.FBI_spoocs = {
			amount = {
				1,
				1 
			},
			special = "spooc",
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
			special = "spooc",
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
				1
			},
			special = "spooc",
			spawn = {
				{
					freq = 1,
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
				1
			},
			special = "spooc",
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
				1
			},
			special = "spooc",
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
				1, 
				1
			},
			special = "spooc",
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
	
	if Global.game_settings and Global.game_settings.level_id == "ranc" then
		self.enemy_spawn_groups.marshal_squad = {
			spawn_cooldown = 60,
			max_nr_simultaneous_groups = 3,
			initial_spawn_delay = 0,
			amount = {
				4,
				4
			},
			spawn = {
				{
					respawn_cooldown = 20,
					amount_min = 4,
					rank = 1,
					freq = 1,
					unit = "marshal_marksman",
					tactics = self._tactics.marshal_marksman
				}
			},
			spawn_point_chk_ref = table.list_to_set({
				"tac_swat_rifle_flank",
				"tac_swat_rifle"
			})
		}
	end

end)

Hooks:PostHook(GroupAITweakData, "_init_task_data", "cock_init_task_data", function(self, difficulty_index, difficulty)
	local is_console = SystemInfo:platform() ~= Idstring("WIN32")
	
	self.max_nr_simultaneous_boss_types = 0
	self.difficulty_curve_points = {
		0.1
	}
	
	self.smoke_and_flash_grenade_timeout = {
		30,
		20
	}

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
	
	self.bouncer_grenade = {
		timer = 3,
		light_range = 600,
		range = 500,
		light_specular = 2,
		beep_fade_speed = 4,
		beep_multi = 0.3,
		light_color = Vector3(255, 255, 0),
		beep_speed = {
			1,
			0.33
		}
	}
	
	if managers.modifiers and managers.modifiers:check_boolean("TotalAnarchy") or difficulty_index > 6 then
		self.flash_grenade.timer = 1.35
	elseif difficulty_index <= 5 then
		self.flash_grenade.timer = 3
	elseif difficulty_index == 6 then
		self.flash_grenade.timer = 2
	end

	self.optimal_trade_distance = {
		0,
		0
	}
	self.bain_assault_praise_limits = {
		2,
		5
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
		sustain_duration_min = {
			0,
			0,
			0
		},
		sustain_duration_max = {
			0,
			0,
			0
		},
		sustain_duration_balance_mul = {
			1,
			1,
			1,
			1
		},
		build_duration = 30,
		fade_duration = 5
	}
	
	if difficulty_index == 7 or difficulty_index == 8 or managers.modifiers and managers.modifiers:check_boolean("TotalAnarchy") then
		self.besiege.assault.build_duration = 60
	end
	
	if managers.modifiers and managers.modifiers:check_boolean("TotalAnarchy")  then
		self.besiege.assault.delay = {
			30,
			30,
			30
		}	
	elseif difficulty_index <= 2 then
		self.besiege.assault.delay = {
			40,
			40,
			40
		}
	elseif difficulty_index == 3 then
		self.besiege.assault.delay = {
			40,
			40,
			40
		}
	elseif difficulty_index == 4 then
		self.besiege.assault.delay = {
			40,
			40,
			40
		}
	elseif difficulty_index == 5 or difficulty_index == 6 then
		self.besiege.assault.delay = {
			40,
			40,
			40
		}
	else
		self.besiege.assault.delay = {
			30,
			30,
			30
		}
	end

	if managers.modifiers and managers.modifiers:check_boolean("TotalAnarchy")  then
		self.besiege.assault.hostage_hesitation_delay = {
			15,
			15,
			15	
		}
	elseif difficulty_index <= 5 then
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

	if self.small_map or self.haunted then
		self.besiege.assault.force = {
			1,
			1,
			1
		}
		self.besiege.assault.force_pool = {
			32,
			32,
			32
		}
	else
		self.besiege.assault.force = {
			1,
			1,
			1
		}
		self.besiege.assault.force_pool = {
			64,
			64,
			64
		}
	end
	
	if self.haunted then
		self.besiege.assault.force_balance_mul = {
			4,
			6,
			8,
			8
		}
		self.besiege.assault.force_pool_balance_mul = {
			1,
			2,
			4,
			4
		}
	elseif self._chill then
		self.besiege.assault.force_balance_mul = {
			12,
			16,
			24,
			24
		}
		self.besiege.assault.force_pool_balance_mul = {
			1,
			2,
			4,
			4
		}
	elseif not self._party and self.small_map then
		if managers.modifiers and managers.modifiers:check_boolean("TotalAnarchy") then
			self.besiege.assault.force_balance_mul = {
				16,
				20,
				24,
				24
			}
			self.besiege.assault.force_pool_balance_mul = {
				1,
				2,
				4,
				4
			}
		elseif difficulty_index < 7 then
			self.besiege.assault.force_balance_mul = {
				12,
				16,
				20,
				20
			}
			self.besiege.assault.force_pool_balance_mul = {
				1,
				2,
				4,
				4
			}
		else
			self.besiege.assault.force_balance_mul = {
				16,
				20,
				24,
				24
			}
			self.besiege.assault.force_pool_balance_mul = {
				1,
				2,
				4,
				4
			}
		end
	elseif managers.modifiers and managers.modifiers:check_boolean("TotalAnarchy") then
		self.besiege.assault.force_balance_mul = {
			32,
			48,
			72,
			72
		}
		self.besiege.assault.force_pool_balance_mul = {
			1,
			1.5,
			2,
			2
		}
	elseif not self._party and difficulty_index < 7 then
		self.besiege.assault.force_balance_mul = {
			16,
			24,
			64,
			64
		}
		self.besiege.assault.force_pool_balance_mul = {
			0.25,
			0.5,
			1,
			1
		}
	elseif self._party then
		self.besiege.assault.force_balance_mul = {
			48,
			96,
			108,
			108
		}
		self.besiege.assault.force_pool_balance_mul = {
			1,
			2,
			4,
			4
		}
	else
		self.besiege.assault.force_balance_mul = {
			32,
			48,
			72,
			72
		}
		self.besiege.assault.force_pool_balance_mul = {
			0.5,
			1,
			2,
			2
		}
	end
	
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
			5.25,
			5.25,
			5.25
		},
		punks_B = {
			5.25,
			5.25,
			5.25
		},
		punks_C = {
			5.25,
			5.25,
			5.25
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
			5,
			5,
			5
		},
		tac_tazer_charge = {
			5,
			5,
			5
		},
		FBI_spoocs = {
			6.25,
			6.25,
			6.25
		},
		tac_bull_rush = {
			6.50,
			6.50,
			6.50
		}
	}
	
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
	self.besiege.assault.groups.marshal_squad = {
		0,
		0,
		0
	}
	self.besiege.reenforce.interval = {
		5,
		5,
		5
	}
	
	self.besiege.reenforce.groups = {
		recon_squad_A = {
			25,
			25,
			25
		},
		recon_squad_B = {
			25,
			25,
			25
		},
		recon_squad_C = {
			25, 
			25,
			25
		},
		recon_squad_D = {
			25,
			25,
			25
		}
	}

	self.besiege.recon.interval = {
		10,
		10,
		10
	}
	self.besiege.recon.interval_variation = 10
	
	if managers.modifiers and managers.modifiers:check_boolean("TotalAnarchy") then
		self.besiege.recon.force = {
			4,
			4,
			4
		}
	elseif difficulty_index < 6 then
		self.besiege.recon.force = {
			4,
			4,
			4
		}
	else
		self.besiege.recon.force = {
			4,
			4,
			4
		}
	end
	
	if managers.modifiers and managers.modifiers:check_boolean("TotalAnarchy") then
		self.besiege.recon.groups = {
			recon_squad_B = {
				25,
				25,
				25
			},
			recon_squad_C = {
				25,
				25,
				25
			},
			recon_squad_D = {
				25,
				25,
				25
			},
			recon_squad_A = {
				25,
				25,
				25
			}
		}
	elseif difficulty_index <= 2 then
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
			recon_squad_A = {
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
			recon_squad_B = {
				30,
				30,
				30
			}
		}
	elseif difficulty_index == 4 then
		self.besiege.recon.groups = {
			recon_squad_A = {
				30,
				30,
				30
			},
			recon_squad_B = {
				20,
				20,
				20
			},
			recon_squad_C = {
				20,
				20,
				20
			},
			recon_squad_D = {
				30,
				30,
				30
			}
		}
	elseif difficulty_index == 5 then
		self.besiege.recon.groups = {
			recon_squad_B = {
				25,
				25,
				25
			},
			recon_squad_C = {
				25,
				25,
				25
			},
			recon_squad_D = {
				25,
				25,
				25
			},
			recon_squad_A = {
				25,
				25,
				25
			}
		}
	else
		self.besiege.recon.groups = {
			recon_squad_B = {
				25,
				25,
				25
			},
			recon_squad_C = {
				25,
				25,
				25
			},
			recon_squad_D = {
				25,
				25,
				25
			},
			recon_squad_A = {
				25,
				25,
				25
			}
		}
	end

	self.besiege.recon.groups.single_spooc = {
		0,
		0,
		0
	}
	self.besiege.recon.groups.marshal_squad = {
		0,
		0,
		0
	}
	self.besiege.recon.groups.Phalanx = {
		0,
		0,
		0
	}
	self.besiege.assault.groups.custom = {
		0,
		0,
		0
	}
	self.besiege.recon.groups.custom = {
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
end)
