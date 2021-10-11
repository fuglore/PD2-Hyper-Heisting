function DramaTweakData:init()
	self:_create_table_structure()

	self.drama_actions = {
		criminal_hurt = 0.2,
		criminal_hurt_armor = 0.1,
		criminal_dead = 0.6,
		criminal_disabled = 0.2,
		enemy_dead = 0.02,
		armor_regenerated = {0, -0.2}
	}
	self.decay_period = 30
	self.max_dis = 6000
	self.max_dis_mul = 0.3
	self.max_dis_armor = 2000
	self.max_dis_mul_armor = 0.1
	self.high_3rd = 0.6
	self.high_2nd = 0.7
	self.low = 0.1
	self.assaultstart = 0.2
	self.peak = 0.8
	self.consistentcombat = 0.2
	self.assault_fade_end = 0.25
end