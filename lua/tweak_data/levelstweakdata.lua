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
	self.mad.package = {"packages/hhnewreapers", "packages/lvl_mad"}	
	
	-- Murkywater Heists
	self.shoutout_raid.package = {"packages/hhmurkies", "packages/vlad_shout"}
	self.shoutout_raid.ai_group_type = shared
	self.pbr2.package = {"packages/hhmurkies", "packages/narr_jerry2"}
	self.pbr.ai_group_type = shared
	self.pbr.package = {"packages/hhmurkies", "packages/narr_jerry1"}
	self.dinner.ai_group_type = shared
	self.dinner.package = {"packages/narr_dinner", "packages/hhmurkies", "packages/thabeatpricks"}
	self.des.package = {"packages/hhmurkies", "packages/job_des"}
	self.bph.package = {"packages/hhmurkies", "packages/dlcs/bph/job_bph"}	
	self.vit.package = {"packages/hhmurkies", "packages/dlcs/vit/job_vit"}
	self.wwh.package = {"packages/hhmurkies", "packages/lvl_wwh"}
	self.arm_for.package = {"packages/hhmurkies", "packages/narr_arm_for"}
	self.mex.package = {"packages/hhmurkies", "packages/job_mex"}
	self.mex_cooking.package = {"packages/hhmurkies", "packages/job_mex2"}
	
	-- Federales heists
	self.bex.package = {"packages/hhbex", "packages/job_bex"}
	
	--fix missing ganster vo, ty rino
	self.short2_stage1.package = {"packages/job_short2_stage1", "levels/narratives/dentist/mia/stage2/world_sounds"}
	self.nightclub.package = {"packages/vlad_nightclub", "levels/narratives/dentist/mia/stage2/world_sounds"}
	self.spa.package = {"packages/job_spa", "levels/narratives/dentist/mia/stage2/world_sounds", "packages/thabeatpricks"}
	self.friend.package = {"levels/narratives/h_alex_must_die/stage_1/world_sounds", "packages/lvl_friend"}
	self.cane.package = {"packages/cane", "levels/narratives/e_welcome_to_the_jungle/stage_1/world_sounds"}

	--nypd beatfucks or some bullshit
	self.glace.package = {"packages/narr_glace", "packages/thabeatpricks"}
	self.flat.package = {"packages/narr_flat", "packages/thabeatpricks"}
	self.red2.package = {"packages/narr_red2", "packages/thabeatpricks"}
	self.brb.package = {"packages/lvl_brb", "packages/thabeatpricks"}
	self.run.package = {"packages/narr_run", "packages/thabeatpricks"}
	
	-- lapd beatfucks
	self.rvd1.package = {"packages/job_rvd", "packages/thabeatpricks"}
	self.rvd2.package = {"packages/job_rvd2", "packages/thabeatpricks"}
	self.jolly.package = {"packages/jolly", "packages/thabeatpricks"}
	
	if Global.game_settings and not Global.game_settings.incsmission then
		self.haunted.package = {
			"packages/narr_haunted", 
			"packages/narr_hvh", 
			"levels/narratives/bain/hvh/world_sounds"
		}
		self.nail.package = {
			"packages/job_nail", 
			"packages/narr_hvh", 
			"levels/narratives/bain/hvh/world_sounds"
		}
		self.help.package = {
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
			return "murkywater"			
		elseif ai_group_type then
			--log("group type name is" .. ai_group_type .. "woo")
			return ai_group_type
		end
	end

	--print("[LevelsTweakData:get_ai_group_type] group is not defined for this level, fallback on default")

	return self.ai_groups.default
end