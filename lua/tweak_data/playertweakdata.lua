Hooks:PostHook(PlayerTweakData, "init", "hhplayertweakbullshit", function(self, tweak_data)
	self.damage.HEALTH_INIT = 34.5
	self.damage.ARMOR_INIT = 3
	self.put_on_mask_time = 1
	self.movement_state.stamina.STAMINA_REGEN_RATE = 6
	self.movement_state.stamina.JUMP_STAMINA_DRAIN = 5
	self.movement_state.stamina.MIN_STAMINA_THRESHOLD = 5
	self.movement_state.standard.movement.speed.RUNNING_MAX = 862.50
	self.movement_state.standard.movement.jump_velocity.xy.walk = self.movement_state.standard.movement.speed.STANDARD_MAX
	self.movement_state.standard.gravity = 982
	self.movement_state.standard.terminal_velocity = 5500
	
	self.style_multipliers = {
		1,
		1.08,
		1.166,
		1.333,
		1.5,
		1.833,
		2
	}
	
	self.alarm_pager = {
		first_call_delay = {
			2,
			4
		},
		call_duration = {
			{
				6,
				6
			},
			{
				6,
				6
			}
		},
		nr_of_calls = {
			2,
			2
		},
		bluff_success_chance = {
			1,
			1,
			1,
			0,
			0
		},
		bluff_success_chance_w_skill = {
			1,
			1,
			1,
			0,
			0
		}
	}
end)

--TODO: Nothing currently.

function PlayerTweakData:_set_normal()
	self.damage.automatic_respawn_time = 120
	self.damage.MIN_DAMAGE_INTERVAL = 0.35

	self.damage.REVIVE_HEALTH_STEPS = {
		0.8
	}
	self.suppression = {
		receive_mul = 2,
		decay_start_delay = 1.5,
		spread_mul = 3,
		tolerance = 0,
		max_value = 100,
		autohit_chance_mul = 1
	}
	self.suspicion = {
		range_mul = 0.2,
		max_value = 8,
		buildup_mul = 0.2
	}
	self.damage.TASED_TIME = 11
	self.damage.LIVES_INIT = 2
	self.damage.BLEED_OUT_HEALTH_INIT = 69
end

function PlayerTweakData:_set_hard()
	self.damage.automatic_respawn_time = 120
	self.damage.DOWNED_TIME_DEC = 7
	self.damage.DOWNED_TIME_MIN = 5
	self.damage.MIN_DAMAGE_INTERVAL = 0.35

	self.damage.REVIVE_HEALTH_STEPS = {
		0.8
	}
	self.suppression = {
		receive_mul = 2,
		decay_start_delay = 1.5,
		spread_mul = 3,
		tolerance = 0,
		max_value = 100,
		autohit_chance_mul = 1
	}
	self.suspicion = {
		range_mul = 0.2,
		max_value = 8,
		buildup_mul = 0.2
	}
	self.damage.TASED_TIME = 11
	self.damage.LIVES_INIT = 2
	self.damage.BLEED_OUT_HEALTH_INIT = 69
end

function PlayerTweakData:_set_overkill()
	self.damage.automatic_respawn_time = 240
	self.damage.DOWNED_TIME_DEC = 10
	self.damage.DOWNED_TIME_MIN = 5
	self.damage.MIN_DAMAGE_INTERVAL = 0.35
	self.damage.REVIVE_HEALTH_STEPS = {
		0.6
	}
	self.suppression = {
		receive_mul = 2,
		decay_start_delay = 1.5,
		spread_mul = 3,
		tolerance = 0,
		max_value = 100,
		autohit_chance_mul = 1
	}
	self.suspicion = {
		range_mul = 0.5,
		max_value = 8,
		buildup_mul = 0.5
	}
	self.damage.TASED_TIME = 11
	self.damage.LIVES_INIT = 2
	self.damage.BLEED_OUT_HEALTH_INIT = 69
end

function PlayerTweakData:_set_overkill_145()
	self.damage.automatic_respawn_time = 240
	self.damage.DOWNED_TIME_DEC = 15
	self.damage.DOWNED_TIME_MIN = 1
	self.damage.MIN_DAMAGE_INTERVAL = 0.35
	self.damage.REVIVE_HEALTH_STEPS = {
		0.6
	}
	self.suppression = {
		receive_mul = 2,
		decay_start_delay = 1.5,
		spread_mul = 3,
		tolerance = 0,
		max_value = 100,
		autohit_chance_mul = 1
	}
	self.suspicion = {
		range_mul = 0.5,
		max_value = 8,
		buildup_mul = 0.5
	}
	self.damage.TASED_TIME = 11
	self.damage.LIVES_INIT = 2
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
		receive_mul = 2,
		decay_start_delay = 1.5,
		spread_mul = 3,
		tolerance = 0,
		max_value = 100,
		autohit_chance_mul = 1
	}
	self.suspicion = {
		range_mul = 0.8,
		max_value = 8,
		buildup_mul = 0.8
	}
	self.damage.TASED_TIME = 11
	self.damage.BLEED_OUT_HEALTH_INIT = 69
	self.damage.LIVES_INIT = 2
	self.damage.INCAPACITATED_TIME = 25
	self.damage.DOWNED_TIME = 25
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
		receive_mul = 2,
		decay_start_delay = 1.5,
		spread_mul = 3,
		tolerance = 0,
		max_value = 100,
		autohit_chance_mul = 1
	}
	self.suspicion = {
		range_mul = 0.8,
		max_value = 8,
		buildup_mul = 0.8
	}
	self.damage.TASED_TIME = 11
	self.damage.BLEED_OUT_HEALTH_INIT = 69
	self.damage.LIVES_INIT = 2
	self.damage.INCAPACITATED_TIME = 25
	self.damage.DOWNED_TIME = 25
end

function PlayerTweakData:_set_sm_wish()
	self.damage.automatic_respawn_time = 360
	self.damage.DOWNED_TIME_DEC = 20
	self.damage.DOWNED_TIME_MIN = 1
	self.damage.BLEED_OT_TIME = 10
	self.damage.MIN_DAMAGE_INTERVAL = 0.35
	self.damage.REVIVE_HEALTH_STEPS = {
		0.5
	}
	self.suppression = {
		receive_mul = 2,
		decay_start_delay = 1.5,
		spread_mul = 3,
		tolerance = 0,
		max_value = 100,
		autohit_chance_mul = 1
	}
	self.suspicion = {
		range_mul = 1,
		max_value = 8,
		buildup_mul = 1
	}
	self.damage.TASED_TIME = 11
	self.damage.BLEED_OUT_HEALTH_INIT = 69
	self.damage.LIVES_INIT = 2
	self.damage.INCAPACITATED_TIME = 20
	self.damage.DOWNED_TIME = 20
end

function PlayerTweakData:_set_singleplayer()
	--self.damage.REGENERATE_TIME = 1.75
	--stop artificially biasing my fucking design thanks
end