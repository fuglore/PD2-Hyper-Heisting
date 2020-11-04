

local filters = {
	"rvsb"
}

for index, filter in pairs(filters) do
	table.insert(tweak_data.color_grading, {
		value = "color_" .. filter,
		text_id = "menu_color_" .. filter
	})
end

if not tweak_data then 
	return 
end

--Why are projectile's damage stats handled here? I don't know! Fuck you Jules!
tweak_data.projectiles.wpn_prj_ace.damage = 10
tweak_data.projectiles.wpn_prj_jav.damage = 300
tweak_data.projectiles.wpn_prj_target.damage = 40
tweak_data.projectiles.wpn_prj_hur.damage = 60
tweak_data.projectiles.fir_com.fire_dot_data = {
	dot_trigger_chance = 100,
	dot_damage = 16,
	dot_length = 2.1,
	dot_trigger_max_distance = 3000,
	dot_tick_period = 0.5
}

function TweakData:_set_normal()
	self.player:_set_normal()
	self.character:_set_normal()
	self.money_manager:init(self)
	self.group_ai:init(self)
	self.weapon:_set_normal()
	
	self.medic.radius = 600
	self.medic.cooldown = 1.5
	self.experience_manager.civilians_killed = 35
	self.difficulty_name_id = self.difficulty_name_ids.normal
	self.experience_manager.total_level_objectives = 2000
	self.experience_manager.total_criminals_finished = 50
	self.experience_manager.total_objectives_finished = 1000
end

function TweakData:_set_hard()
	self.player:_set_hard()
	self.character:_set_hard()
	self.money_manager:init(self)
	self.group_ai:init(self)
	self.weapon:_set_hard()
	
	self.medic.radius = 600
	self.medic.cooldown = 1.5
	self.experience_manager.civilians_killed = 75
	self.difficulty_name_id = self.difficulty_name_ids.hard
	self.experience_manager.total_level_objectives = 2500
	self.experience_manager.total_criminals_finished = 150
	self.experience_manager.total_objectives_finished = 1500
end

function TweakData:_set_overkill()
	self.player:_set_overkill()
	self.character:_set_overkill()
	self.money_manager:init(self)
	self.group_ai:init(self)
	self.weapon:_set_overkill()
	
	self.medic.radius = 600
	self.medic.cooldown = 1.5
	self.experience_manager.civilians_killed = 150
	self.difficulty_name_id = self.difficulty_name_ids.overkill
	self.experience_manager.total_level_objectives = 5000
	self.experience_manager.total_criminals_finished = 500
	self.experience_manager.total_objectives_finished = 3000
end

function TweakData:_set_overkill_145()
	self.player:_set_overkill_145()
	self.character:_set_overkill_145()
	self.money_manager:init(self)
	self.group_ai:init(self)
	self.weapon:_set_overkill_145()
	
	self.medic.radius = 600
	self.medic.cooldown = 1.5
	self.experience_manager.civilians_killed = 550
	self.difficulty_name_id = self.difficulty_name_ids.overkill_145
	self.experience_manager.total_level_objectives = 5000
	self.experience_manager.total_criminals_finished = 2000
	self.experience_manager.total_objectives_finished = 3000
end

function TweakData:_set_easy_wish()
	self.player:_set_easy_wish()
	self.character:_set_easy_wish()
	self.money_manager:init(self)
	self.group_ai:init(self)
	self.weapon:_set_easy_wish()
	
	self.medic.radius = 600
	self.medic.cooldown = 1
	self.experience_manager.civilians_killed = 10000
	self.difficulty_name_id = self.difficulty_name_ids.easy_wish
	self.experience_manager.total_level_objectives = 5000
	self.experience_manager.total_criminals_finished = 2000
	self.experience_manager.total_objectives_finished = 3000
end

function TweakData:_set_overkill_290()
	self.player:_set_overkill_290()
	self.character:_set_overkill_290()
	self.money_manager:init(self)
	self.group_ai:init(self)
	self.weapon:_set_overkill_290()
	
	self.medic.radius = 600
	self.medic.cooldown = 1
	self.experience_manager.civilians_killed = 10000
	self.difficulty_name_id = self.difficulty_name_ids.overkill_290
	self.experience_manager.total_level_objectives = 5000
	self.experience_manager.total_criminals_finished = 2000
	self.experience_manager.total_objectives_finished = 3000
end

function TweakData:_set_sm_wish()
	self.player:_set_sm_wish()
	self.character:_set_sm_wish()
	self.money_manager:init(self)
	self.group_ai:init(self)
	self.weapon:_set_sm_wish()
	
	self.medic.radius = 600
	self.medic.cooldown = 0
	self.experience_manager.civilians_killed = 10000
	self.difficulty_name_id = self.difficulty_name_ids.sm_wish
	self.experience_manager.total_level_objectives = 5000
	self.experience_manager.total_criminals_finished = 2000
	self.experience_manager.total_objectives_finished = 3000
end