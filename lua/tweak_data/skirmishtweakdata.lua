function SkirmishTweakData:_init_wave_modifiers()
	self.wave_modifiers = {}
	local health_damage_multipliers = {
		{
			damage = 1,
			health = 1
		},
		{
			damage = 1,
			health = 1
		},
		{
			damage = 1,
			health = 1
		},
		{
			damage = 1.25,
			health = 1
		},
		{
			damage = 1.25,
			health = 1
		},
		{
			damage = 1.25,
			health = 1
		},
		{
			damage = 1.25,
			health = 1.25
		},
		{
			damage = 1.25,
			health = 1.25
		},
		{
			damage = 1.25,
			health = 1.25
		},
		{
			damage = 1.4,
			health = 1.4
		},
		{
			damage = 1.4,
			health = 1.4
		},
		{
			damage = 1.4,
			health = 1.4
		},
		{
			damage = 1.4,
			health = 1.4
		},
		{
			damage = 1.4,
			health = 1.25
		},
		{
			damage = 1.4,
			health = 1.25
		},
		{
			damage = 1.4,
			health = 1.25
		},
		{
			damage = 1.4,
			health = 1.25
		},
		{
			damage = 1.4,
			health = 1.25
		},
		{
			damage = 1.4,
			health = 1.25
		},
		{
			damage = 1.4,
			health = 1.25
		},
		{
			damage = 1.4,
			health = 1.25
		}
	}
	self.wave_modifiers[1] = {
		{
			class = "ModifierEnemyHealthAndDamageByWave",
			data = {
				waves = health_damage_multipliers
			}
		},
		{
			class = "ModifierCloakerArrest"
		}
	}
	self.wave_modifiers[3] = {
		{
			class = "ModifierSkulldozers"
		}
	}
	self.wave_modifiers[5] = {
		{
			class = "ModifierHeavySniper",
			data = {
				spawn_chance = 5
			}
		}
	}
	self.wave_modifiers[6] = {
		{
			class = "ModifierDozerRage"
		}
	}	
	self.wave_modifiers[7] = {
		{
			class = "ModifierDozerMedic"
		}
	}
	self.wave_modifiers[9] = {
		{
			class = "ModifierDozerMinigun"
		}
	}
end

function SkirmishTweakData:_init_special_unit_spawn_limits()
	self.special_unit_spawn_limits = {
		{
			shield = 4,
			medic = 4,
			taser = 2,
			tank = 1,
			spooc = 2
		},
		{
			shield = 4,
			medic = 6,
			taser = 2,
			tank = 1,
			spooc = 2
		},
		{
			shield = 4,
			medic = 6,
			taser = 2,
			tank = 1,
			spooc = 2
		},
		{
			shield = 5,
			medic = 8,
			taser = 2,
			tank = 1,
			spooc = 2
		},
		{
			shield = 5,
			medic = 8,
			taser = 2,
			tank = 2,
			spooc = 2
		},
		{
			shield = 6,
			medic = 8,
			taser = 3,
			tank = 2,
			spooc = 2
		},
		{
			shield = 6,
			medic = 8,
			taser = 3,
			tank = 2,
			spooc = 3
		},
		{
			shield = 6,
			medic = 8,
			taser = 3,
			tank = 2,
			spooc = 3
		},
		{
			shield = 7,
			medic = 10,
			taser = 3,
			tank = 2,
			spooc = 3
		},
		{
			shield = 7,
			medic = 10,
			taser = 3,
			tank = 2,
			spooc = 3
		},
		{
			shield = 8,
			medic = 4,
			taser = 4,
			tank = 2,
			spooc = 3
		},
		{
			shield = 8,
			medic = 4,
			taser = 4,
			tank = 2,
			spooc = 3
		},
		{
			shield = 8,
			medic = 4,
			taser = 4,
			tank = 2,
			spooc = 3
		},
		{
			shield = 9,
			medic = 4,
			taser = 4,
			tank = 2,
			spooc = 3
		},
		{
			shield = 9,
			medic = 5,
			taser = 4,
			tank = 2,
			spooc = 3
		},
		{
			shield = 10,
			medic = 5,
			taser = 5,
			tank = 2,
			spooc = 3
		},
		{
			shield = 10,
			medic = 5,
			taser = 5,
			tank = 2,
			spooc = 3
		},
		{
			shield = 10,
			medic = 5,
			taser = 5,
			tank = 2,
			spooc = 3
		},
		{
			shield = 11,
			medic = 5,
			taser = 5,
			tank = 2,
			spooc = 3
		},
		{
			shield = 11,
			medic = 5,
			taser = 5,
			tank = 2,
			spooc = 3
		},
		{
			shield = 12,
			medic = 6,
			taser = 6,
			tank = 2,
			spooc = 4
		}
	}
end

function SkirmishTweakData:_init_group_ai_data(tweak_data)
	local skirmish_data = deep_clone(tweak_data.group_ai.besiege)
	skirmish_data.assault.groups = nil
	tweak_data.group_ai.skirmish = skirmish_data
end

function SkirmishTweakData:_init_wave_phase_durations(tweak_data)
	local skirmish_data = tweak_data.group_ai.skirmish
	skirmish_data.assault.anticipation_duration = {
		{
			15,
			1
		}
	}
	skirmish_data.assault.build_duration = 30
	skirmish_data.assault.sustain_duration_min = {
		150,
		150,
		150
	}
	skirmish_data.assault.sustain_duration_max = {
		150,
		150,
		150
	}
	skirmish_data.assault.sustain_duration_balance_mul = {
		1,
		1,
		1,
		1
	}
	skirmish_data.assault.fade_duration = 20
	skirmish_data.assault.delay = {
		30,
		30,
		30
	}
	skirmish_data.assault.force_balance_mul = {
		1.5,
		3,
		4,
		4
	}	
	skirmish_data.assault.force = {
		16,
		16,
		16
	}
	skirmish_data.assault.force_pool_balance_mul = {
		0.32,
		0.5,
		0.75,
		0.75
	}
	skirmish_data.assault.force_pool = {
		256,
		256,
		256
	}
	skirmish_data.recon.force = {
		0,
		0,
		0
	}
end

function SkirmishTweakData:_init_spawn_group_weights(tweak_data)
	local nice_human_readable_table = {
		{
			18,
			18,
			18,
			18,
			3,
			4,
			3,
			5,
			5,
			3,
			5
		},
		{
			17,
			17,
			17,
			17,
			4,
			4,
			4,
			5,
			5,
			4,
			5
		},
		{
			17,
			16,
			17,
			16,
			4,
			4,
			4,
			6,
			6,
			4,
			5
		},
		{
			17,
			16,
			17,
			16,
			4,
			4,
			4,
			6,
			6,
			4,
			5
		},
		{
			16,
			15,
			16,
			15,
			4,
			5,
			4,
			6,
			6,
			6,
			6
		},
		{
			15,
			14,
			15,
			14,
			4,
			5,
			4,
			7,
			7,
			7,
			7
		},
		{
			14,
			14,
			14,
			14,
			5,
			5,
			5,
			7,
			7,
			7,
			7
		},
		{
			14,
			14,
			14,
			14,
			5,
			5,
			5,
			6,
			6,
			7,
			9
		},
		{
			14,
			14,
			14,
			14,
			4,
			4,
			4,
			7,
			7,
			8,
			10
		},
		{
			14,
			14,
			14,
			14,
			4,
			4,
			4,
			7,
			7,
			8,
			10
		},
		{
			14,
			14,
			14,
			14,
			4,
			4,
			4,
			7,
			7,
			8,
			10
		},
		{
			14,
			14,
			14,
			14,
			4,
			4,
			4,
			7,
			7,
			8,
			10
		},
		{
			14,
			14,
			14,
			14,
			4,
			4,
			4,
			7,
			7,
			8,
			10
		},
		{
			14,
			14,
			14,
			14,
			4,
			4,
			4,
			7,
			7,
			8,
			10
		},
		{
			14,
			14,
			14,
			14,
			4,
			4,
			4,
			7,
			7,
			8,
			10
		},
		{
			14,
			14,
			14,
			14,
			4,
			4,
			4,
			7,
			7,
			8,
			10
		},
		{
			14,
			14,
			14,
			14,
			4,
			4,
			4,
			7,
			7,
			8,
			10
		},
		{
			14,
			14,
			14,
			14,
			4,
			4,
			4,
			7,
			7,
			8,
			10
		},
		{
			14,
			14,
			14,
			14,
			4,
			4,
			4,
			7,
			7,
			8,
			10
		},
		{
			14,
			14,
			14,
			14,
			4,
			4,
			4,
			7,
			7,
			8,
			10
		},
		{
			14,
			14,
			14,
			14,
			4,
			4,
			4,
			7,
			7,
			8,
			10
		},
	}
	local ordered_spawn_group_names = {
		"tac_swat_shotgun_rush",
		"tac_swat_shotgun_flank",
		"tac_swat_rifle",
		"tac_swat_rifle_flank",
		"tac_shield_wall_ranged",
		"tac_shield_wall_charge",
		"tac_shield_wall",
		"tac_tazer_flanking",
		"tac_tazer_charge",
		"FBI_spoocs",
		"tac_bull_rush"
	}

	for _, wave in ipairs(nice_human_readable_table) do
		local total_weight = 0

		for _, weight in ipairs(wave) do
			total_weight = total_weight + weight
		end

		for i, weight in ipairs(wave) do
			wave[i] = weight / total_weight
		end
	end

	self.assault = {
		groups = {}
	}

	for i, src_weights in ipairs(nice_human_readable_table) do
		local dst_weights = {}

		for j, weight in ipairs(src_weights) do
			local group_name = ordered_spawn_group_names[j]
			dst_weights[group_name] = {
				weight,
				weight,
				weight
			}
		end

		self.assault.groups[i] = dst_weights
	end

	local skirmish_assault_meta = {
		__index = function (t, key)
			if key == "groups" then
				local current_wave = managers.skirmish:current_wave_number()
				local current_wave_index = math.clamp(current_wave, 1, #self.assault.groups)

				return self.assault.groups[current_wave_index]
			else
				return rawget(t, key)
			end
		end
	}

	setmetatable(tweak_data.group_ai.skirmish.assault, skirmish_assault_meta)
end
