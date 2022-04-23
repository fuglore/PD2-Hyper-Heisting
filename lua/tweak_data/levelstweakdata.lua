--the fact i have to do this is why i dont like overkill and their weird, weird little systems
LevelsTweakData = LevelsTweakData or class()
LevelsTweakData.LevelType = {
	America = "america",
	Shared = "shared",	
	Russia = "russia",
	Zombie = "zombie",
	Murkywater = "murkywater",
	Federales = "federales"
} 
local old_level_init = LevelsTweakData.init
function LevelsTweakData:init()
    old_level_init(self)
	local america = LevelsTweakData.LevelType.America
	local shared = LevelsTweakData.LevelType.Shared	
	local russia = LevelsTweakData.LevelType.Russia
	local zombie = LevelsTweakData.LevelType.Zombie
	local murkywater = LevelsTweakData.LevelType.Murkywater
	local federales = LevelsTweakData.LevelType.Federales
	self.ai_groups = {
		default = america,
		america = america,
		shared = Shared,		
		russia = russia,
		zombie = zombie,
		murkywater = murkywater,
		federales = federales
	}
    self.chill_combat.group_ai_state = "besiege"
	self.mad.package = {"packages/akanassets", "packages/lvl_mad"}	
	
	self.rvd1.teams = {
		criminal1 = {
			foes = {
				law1 = true,
				mobster1 = true
			},
			friends = {
				converted_enemy = true
			}
		},
		law1 = {
			foes = {
				converted_enemy = true,
				criminal1 = true,
				mobster1 = true
			},
			friends = {}
		},
		mobster1 = {
			foes = {
				converted_enemy = true,
				law1 = true,
				criminal1 = true
			},
			friends = {}
		},
		converted_enemy = {
			foes = {
				law1 = true,
				mobster1 = true
			},
			friends = {
				criminal1 = true
			}
		},
		neutral1 = {
			foes = {
				law1 = true,
				mobster1 = true
			},
			friends = {
				converted_enemy = true
			}
		},
		hacked_turret = {
			foes = {
				law1 = true,
				mobster1 = true
			},
			friends = {}
		}
	}
	self.rvd2.trigger_follower_behavior_element = {} --empty table means it just, wont
	self.rvd2.teams = {
		criminal1 = {
			foes = {
				law1 = true,
				mobster1 = true
			},
			friends = {
				converted_enemy = true
			}
		},
		law1 = {
			foes = {
				converted_enemy = true,
				criminal1 = true,
				mobster1 = true
			},
			friends = {}
		},
		mobster1 = {
			foes = {
				converted_enemy = true,
				law1 = true,
				criminal1 = true
			},
			friends = {}
		},
		converted_enemy = {
			foes = {
				law1 = true,
				mobster1 = true
			},
			friends = {
				criminal1 = true
			}
		},
		neutral1 = {
			foes = {
				law1 = true,
				mobster1 = true
			},
			friends = {
				converted_enemy = true
			}
		},
		hacked_turret = {
			foes = {
				law1 = true,
				mobster1 = true
			},
			friends = {}
		}
	}
	
	-- Murkywater Heists
	self.shoutout_raid.package = {"packages/murkyassets", "packages/vlad_shout"}
	self.shoutout_raid.ai_group_type = murkywater
	self.pbr2.package = {"packages/murkyassets", "packages/narr_jerry2"}
	-- self.pbr2.ai_group_type = shared
	self.pbr.package = {"packages/murkyassets", "packages/narr_jerry1"}
	-- self.dinner.ai_group_type = shared
	self.dinner.package = {"packages/narr_dinner", "packages/murkyassets"}
	self.des.package = {"packages/murkyassets", "packages/job_des"}
	self.bph.package = {"packages/murkyassets", "packages/dlcs/bph/job_bph"}	
	self.vit.package = {"packages/holyfuckingshitghosts", "packages/murkyassets", "packages/dlcs/vit/job_vit"}
	self.mex.package = {"packages/murkyassets", "packages/job_mex"}
	self.mex_cooking.package = {"packages/murkyassets", "packages/job_mex2"}
	self.kosugi.package = {"packages/murkyassets", "packages/kosugi"}
	
	-- Federales heists
	self.bex.package = {"packages/mexicoassets", "packages/job_bex"}
	self.pex.package = {"packages/mexicoassets", "packages/job_pex"}
	self.fex.package = {"packages/mexicoassets", "packages/job_fex"}
	self.skm_bex.package = {"packages/mexicoassets", "packages/dlcs/skm/job_bex_skm"}
	
	self.haunted.package = {"packages/holyfuckingshitghosts", "packages/narr_haunted"}
	self.hvh.package = {"packages/zombieassets", "packages/narr_hvh"}
	
	--fix missing ganster vo, ty rino
	self.short2_stage1.package = {"packages/job_short2_stage1", "levels/narratives/dentist/mia/stage2/world_sounds"}
	self.nightclub.package = {"packages/vlad_nightclub", "levels/narratives/dentist/mia/stage2/world_sounds"}
	self.spa.package = {"packages/job_spa", "levels/narratives/dentist/mia/stage2/world_sounds"}
	self.spa.ignored_so_elements = {
		[101834] = true,
		[135495] = true,
		[103318] = true
	}
	self.spa.trigger_follower_behavior_element = {[135558] = true}
	self.hox_2.ignored_so_elements = {[102290] = true}
	
	self.friend.package = {"levels/narratives/h_alex_must_die/stage_1/world_sounds", "packages/lvl_friend"}
	self.cane.package = {"packages/cane", "levels/narratives/e_welcome_to_the_jungle/stage_1/world_sounds"}

	--halloween heists (designed to have the zombie faction disabled in crime spree)
	if not Global.crime_spree or not Global.crime_spree.current_mission then
		self.nail.package = {
			"packages/zombieassets",
			"packages/job_nail", 
			"packages/narr_hvh", 
			"levels/narratives/bain/hvh/world_sounds"
		}
		self.help.package = {
			"packages/zombieassets",
			"packages/lvl_help",
			"packages/narr_hvh", 
			"levels/narratives/bain/hvh/world_sounds"
		}	
		self.nail.ai_group_type = zombie
		self.help.ai_group_type = zombie
	end
	
	--Meatgrinder Maps
	self.jewelry_store.meatgrinder = true
	self.ukrainian_job.meatgrinder = true
	self.four_stores.meatgrinder = true
	self.nightclub.meatgrinder = true
	self.sah.meatgrinder = true
	self.born.meatgrinder = true
	self.chew.meatgrinder = true
	self.pines.meatgrinder = true
	self.help.meatgrinder = true
	self.peta.meatgrinder = true
	self.hox_1.meatgrinder = true
	self.mad.meatgrinder = true
	self.glace.meatgrinder = true
	self.nail.meatgrinder = true
	self.watchdogs_1.meatgrinder = true
	self.watchdogs_1_night.meatgrinder = true
	self.crojob3.meatgrinder = true
	self.crojob3_night.meatgrinder = true
	self.hvh.meatgrinder = true
	self.run.meatgrinder = true
	self.arm_cro.meatgrinder = true
	self.arm_und.meatgrinder = true
	self.arm_hcm.meatgrinder = true
	self.arm_par.meatgrinder = true
	self.arm_fac.meatgrinder = true
	self.mia_2.meatgrinder = true
	self.rvd1.meatgrinder = true
	self.rvd2.meatgrinder = true
	self.nmh.meatgrinder = true
	self.des.meatgrinder = true
	self.mex.meatgrinder = true
	self.mex_cooking.meatgrinder = true
	self.bph.meatgrinder = true
	self.spa.meatgrinder = true
	self.chill_combat.meatgrinder = true
	self.dinner.meatgrinder = true
	self.mallcrasher.meatgrinder = true
	self.moon.meatgrinder = true
	self.cane.meatgrinder = true
	self.flat.meatgrinder = true
	
	if self.nmh_hyper then
		self.nmh_hyper.meatgrinder = true
	end
	
	if self.flat_hh then
		self.flat_hh.meatgrinder = true
	end
	
	if self.physics_tower then
		self.physics_tower.meatgrinder = true
	end
	
	if self.physics_core then
		self.physics_core.meatgrinder = true
	end
	
	if self.mia_2_new then
		self.mia_2_new.meatgrinder = true
	end

	--Street maps
	self.hox_1.street = true
	self.run.street = true
	self.glace.street = true
	self.rvd2.street = true
	
	--Over-Exposure maps
	self.chill_combat.too_drama = true
	self.hox_1.too_drama = true
	self.run.too_drama = true
	self.glace.too_drama = true
end

function LevelsTweakData:get_ai_group_type()
	local level_data = Global.level_data and Global.level_data.level_id and self[Global.level_data.level_id]
	
	
	if level_data then
		local ai_group_type = level_data.ai_group_type
		
		if ai_group_type then
			local sm_wish = Global.game_settings.difficulty == "sm_wish"
			
			if ai_group_type == "bo" and sm_wish then
				return "america"
			elseif ai_group_type == "zombie" and Global.game_settings and Global.game_settings.incsmission then
				return "america"	
			elseif ai_group_type == "shared" and Global.game_settings and Global.game_settings.incsmission then
				return "america"					
			else
				--log("group type name is" .. ai_group_type .. "woo")
				return ai_group_type
			end
		end
	end

	--print("[LevelsTweakData:get_ai_group_type] group is not defined for this level, fallback on default")

	return self.ai_groups.america
end