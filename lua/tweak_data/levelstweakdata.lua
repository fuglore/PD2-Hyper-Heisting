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
	self.vit.package = {"packages/murkyassets", "packages/dlcs/vit/job_vit"}
	self.mex.package = {"packages/murkyassets", "packages/job_mex"}
	self.mex_cooking.package = {"packages/murkyassets", "packages/job_mex2"}
	self.kosugi.package = {"packages/murkyassets", "packages/kosugi"}
	
	-- Federales heists
	self.bex.package = {"packages/mexicoassets", "packages/job_bex"}
	self.pex.package = {"packages/mexicoassets", "packages/job_pex"}
	self.fex.package = {"packages/mexicoassets", "packages/job_fex"}
	self.skm_bex.package = {"packages/mexicoassets", "packages/dlcs/skm/job_bex_skm"}
	
	self.hvh.package = {"packages/zombieassets", "packages/narr_hvh"}
	
	--fix missing ganster vo, ty rino
	self.short2_stage1.package = {"packages/job_short2_stage1", "levels/narratives/dentist/mia/stage2/world_sounds"}
	self.nightclub.package = {"packages/vlad_nightclub", "levels/narratives/dentist/mia/stage2/world_sounds"}
	self.spa.package = {"packages/job_spa", "levels/narratives/dentist/mia/stage2/world_sounds"}
	self.friend.package = {"levels/narratives/h_alex_must_die/stage_1/world_sounds", "packages/lvl_friend"}
	self.cane.package = {"packages/cane", "levels/narratives/e_welcome_to_the_jungle/stage_1/world_sounds"}

	--halloween heists (designed to have the zombie faction disabled in crime spree)
	if not Global.crime_spree or not Global.crime_spree.current_mission then
		self.haunted.package = {
			"packages/zombieassets",
			"packages/narr_haunted", 
			"packages/narr_hvh", 
			"levels/narratives/bain/hvh/world_sounds"
		}
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
		self.haunted.ai_group_type = zombie		
		self.nail.ai_group_type = zombie
		self.help.ai_group_type = zombie
	end
	
end

function LevelsTweakData:get_ai_group_type()
	local level_data = Global.level_data and Global.level_data.level_id and self[Global.level_data.level_id]

	if level_data then
		local ai_group_type = level_data.ai_group_type
		if ai_group_type and ai_group_type == "zombie" and Global.game_settings and Global.game_settings.incsmission then
			return "america"	
		elseif ai_group_type and ai_group_type == "shared" and Global.game_settings and Global.game_settings.incsmission then
			return "america"					
		elseif ai_group_type then
			--log("group type name is" .. ai_group_type .. "woo")
			return ai_group_type
		end
	end

	--print("[LevelsTweakData:get_ai_group_type] group is not defined for this level, fallback on default")

	return self.ai_groups.default
end