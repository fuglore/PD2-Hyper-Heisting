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