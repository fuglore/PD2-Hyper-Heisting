function DramaTweakData:init()
	self:_create_table_structure()

	self.drama_actions = {
		criminal_hurt = 0.25,
		criminal_dead = 0.4,
		criminal_disabled = 0.1,
		--enemy_dead = 0.2
	}
	self.decay_period = 16
	self.max_dis = 4000
	self.max_dis_mul = 0.75
	self.max_dis_armor = 2000
	self.max_dis_mul_armor = 0.1
	self.low_3rd = 0.2
	self.low_2nd = 0.15
	self.low = 0.01
	self.assaultstart = 0.15
	self.peak = 0.95
	self.consistentcombat = 0.2
	self.assault_fade_end = 0.25
end