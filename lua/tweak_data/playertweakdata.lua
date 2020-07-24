Hooks:PostHook(PlayerTweakData, "init", "hhplayertweakbullshit", function(self, tweak_data)
	if PD2THHSHIN and PD2THHSHIN:IsOverhaulEnabled() then
		self.put_on_mask_time = 1
	end
end)

--TODO: Nothing currently.

function PlayerTweakData:_set_normal()
	self.damage.automatic_respawn_time = 120
	self.damage.MIN_DAMAGE_INTERVAL = 0.35
	self.suspicion.range_mul = 0.8
	self.suspicion.buildup_mul = 0.5
	self.damage.REVIVE_HEALTH_STEPS = {
		0.8
	}
	self.suppression = {
		receive_mul = 10,
		decay_start_delay = 1.5,
		spread_mul = 1,
		tolerance = 0,
		max_value = 20,
		autohit_chance_mul = 1
	}
	self.damage.TASED_TIME = 5
	self.damage.BLEED_OUT_HEALTH_INIT = 69
end

function PlayerTweakData:_set_hard()
	self.damage.automatic_respawn_time = 120
	self.damage.DOWNED_TIME_DEC = 7
	self.damage.DOWNED_TIME_MIN = 5
	self.damage.MIN_DAMAGE_INTERVAL = 0.35
	self.suspicion.range_mul = 0.8
	self.suspicion.buildup_mul = 0.5
	self.damage.REVIVE_HEALTH_STEPS = {
		0.8
	}
	self.suppression = {
		receive_mul = 10,
		decay_start_delay = 1.5,
		spread_mul = 1,
		tolerance = 0,
		max_value = 20,
		autohit_chance_mul = 1
	}
	self.damage.TASED_TIME = 5
	self.damage.BLEED_OUT_HEALTH_INIT = 69
end

function PlayerTweakData:_set_overkill()
	self.damage.automatic_respawn_time = 240
	self.damage.DOWNED_TIME_DEC = 10
	self.damage.DOWNED_TIME_MIN = 5
	self.damage.MIN_DAMAGE_INTERVAL = 0.35
	self.suspicion.buildup_mul = 0.8
	self.damage.REVIVE_HEALTH_STEPS = {
		0.6
	}
	self.suppression = {
		receive_mul = 10,
		decay_start_delay = 1.5,
		spread_mul = 1,
		tolerance = 0,
		max_value = 20,
		autohit_chance_mul = 1
	}
	self.damage.TASED_TIME = 5
	self.damage.BLEED_OUT_HEALTH_INIT = 69
end

function PlayerTweakData:_set_overkill_145()
	self.damage.automatic_respawn_time = 240
	self.damage.DOWNED_TIME_DEC = 15
	self.damage.DOWNED_TIME_MIN = 1
	self.damage.MIN_DAMAGE_INTERVAL = 0.35
	self.suspicion.max_value = 10
	self.suspicion.buildup_mul = 0.8
	self.damage.REVIVE_HEALTH_STEPS = {
		0.6
	}
	self.suppression = {
		receive_mul = 10,
		decay_start_delay = 1.5,
		spread_mul = 1,
		tolerance = 0,
		max_value = 20,
		autohit_chance_mul = 1
	}
	self.damage.TASED_TIME = 5
	self.damage.BLEED_OUT_HEALTH_INIT = 69
end

function PlayerTweakData:_set_easy_wish()
	self.damage.automatic_respawn_time = 240
	self.damage.DOWNED_TIME_DEC = 20
	self.damage.DOWNED_TIME_MIN = 1
	self.damage.BLEED_OT_TIME = 10
	self.damage.MIN_DAMAGE_INTERVAL = 0.35
	self.damage.REVIVE_HEALTH_STEPS = {
		0.5
	}
	self.suppression = {
		receive_mul = 10,
		decay_start_delay = 1.5,
		spread_mul = 1,
		tolerance = 0,
		max_value = 20,
		autohit_chance_mul = 1
	}
	self.damage.TASED_TIME = 5
	self.damage.BLEED_OUT_HEALTH_INIT = 69
	if Global.game_settings.single_player then
		--Nothing.
	else
		self.damage.LIVES_INIT = 3 --This increases complexity immediately, effectively and satisfyingly, requires more scrutinity though.
		self.damage.INCAPACITATED_TIME = 25
		self.damage.DOWNED_TIME = 25
	end 
end

function PlayerTweakData:_set_overkill_290()
	self.damage.automatic_respawn_time = 360
	self.damage.DOWNED_TIME_DEC = 20
	self.damage.DOWNED_TIME_MIN = 1
	self.damage.BLEED_OT_TIME = 10
	self.damage.MIN_DAMAGE_INTERVAL = 0.35
	self.damage.REVIVE_HEALTH_STEPS = {
		0.5
	}
	self.suppression = {
		receive_mul = 10,
		decay_start_delay = 1.5,
		spread_mul = 1,
		tolerance = 0,
		max_value = 20,
		autohit_chance_mul = 1
	}
	self.damage.TASED_TIME = 5
	self.damage.BLEED_OUT_HEALTH_INIT = 69
	if Global.game_settings.single_player then
		--Nothing.
	else
		self.damage.LIVES_INIT = 3
		self.damage.INCAPACITATED_TIME = 25
		self.damage.DOWNED_TIME = 25
	end
end

function PlayerTweakData:_set_sm_wish()
	self.damage.automatic_respawn_time = 360
	self.damage.DOWNED_TIME_DEC = 20
	self.damage.DOWNED_TIME_MIN = 1
	self.damage.BLEED_OT_TIME = 10
	self.suspicion.buildup_mul = 1.5
	self.damage.MIN_DAMAGE_INTERVAL = 0.35
	self.damage.REVIVE_HEALTH_STEPS = {
		0.5
	}
	self.suppression = {
		receive_mul = 10,
		decay_start_delay = 1.5,
		spread_mul = 1,
		tolerance = 0,
		max_value = 20,
		autohit_chance_mul = 1
	}
	self.damage.TASED_TIME = 4
	self.damage.BLEED_OUT_HEALTH_INIT = 69
	if Global.game_settings.single_player then
		self.damage.LIVES_INIT = 3
	else
		self.damage.LIVES_INIT = 2
		self.damage.INCAPACITATED_TIME = 20
		self.damage.DOWNED_TIME = 20
	end
end

function PlayerTweakData:_set_singleplayer()
	--self.damage.REGENERATE_TIME = 1.75
	--stop artificially biasing my fucking design thanks
end