--the fact i have to do this is why i dont like overkill and their weird, weird little systems
local old_level_init = LevelsTweakData.init
function LevelsTweakData:init()
    old_level_init(self)
    self.chill_combat.group_ai_state = "besiege"
	if game_state_machine then
		local gamemode_chk = game_state_machine:gamemode() 
		if gamemode_chk ~= "crime_spree" then
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
end