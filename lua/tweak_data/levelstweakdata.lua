--the fact i have to do this is why i dont like overkill and their weird, weird little systems
local old_level_init = LevelsTweakData.init
function LevelsTweakData:init()
    old_level_init(self)
    self.chill_combat.group_ai_state = "besiege"
end
