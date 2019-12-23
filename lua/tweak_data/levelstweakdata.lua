--the fact i have to do this is why i dont like overkill and their weird, weird little systems
LevelsTweakData = LevelsTweakData or class()
LevelsTweakData.LevelType = {
	America = "america",
	Russia = "russia",
	Zombie = "zombie",
	Murkywater = "murkywater"
}

local old_level_init = LevelsTweakData.init
function LevelsTweakData:init()
    old_level_init(self)
	local america = LevelsTweakData.LevelType.America
	local russia = LevelsTweakData.LevelType.Russia
	local zombie = LevelsTweakData.LevelType.Zombie
	local murkywater = LevelsTweakData.LevelType.Murkywater
	self.ai_groups = {
		default = america,
		america = america,
		russia = russia,
		zombie = zombie,
		murkywater = murkywater
	}
    self.chill_combat.group_ai_state = "besiege"
	self.mad.package = {"packages/hhnewreapers", "packages/lvl_mad"}	
	
	-- Murkywater Heists
	self.shoutout_raid.package = {"packages/hhmurkies", "packages/vlad_shout"}
	self.pbr.package = {"packages/hhmurkies", "packages/narr_jerry1"}
	self.des.package = {"packages/hhmurkies", "packages/job_des"}
	self.bph.package = {"packages/hhmurkies", "packages/dlcs/bph/job_bph"}
	self.vit.package = {"packages/hhmurkies", "packages/dlcs/vit/job_vit"}
	self.wwh.package = {"packages/hhmurkies", "packages/lvl_wwh"}
	self.arm_for.package = {"packages/hhmurkies", "packages/narr_arm_for"}
	self.mex.package = {"packages/hhmurkies", "packages/job_mex"}
	self.mex_cooking.package = {"packages/hhmurkies", "packages/job_mex2"}
	
	--fix missing ganster vo, ty rino
	self.short2_stage1.package = {"packages/job_short2_stage1", "levels/narratives/dentist/mia/stage2/world_sounds"}
	self.nightclub.package = {"packages/vlad_nightclub", "levels/narratives/dentist/mia/stage2/world_sounds"}
	self.spa.package = {"packages/job_spa", "levels/narratives/dentist/mia/stage2/world_sounds"}
	self.friend.package = {"levels/narratives/h_alex_must_die/stage_1/world_sounds", "packages/lvl_friend"}
	self.cane.package = {"packages/cane", "levels/narratives/e_welcome_to_the_jungle/stage_1/world_sounds"}
	
	local gamemode_chk = game_state_machine and game_state_machine:gamemode()
	if not gamemode_chk or gamemode_chk and not gamemode_chk == "crime_spree" then
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