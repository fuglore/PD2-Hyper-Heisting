function FlamethrowerEffectExtension:setup_default()
	self._flame_effect = {
		effect = Idstring(tweak_data.weapon[self._name_id].flame_effect)
	}
	self._nozzle_effect = {
		effect = Idstring("effects/payday2/particles/explosions/flamethrower_nosel")
	}
	self._pilot_light = {
		effect = Idstring("effects/payday2/particles/explosions/flamethrower_pilot")
	}
	self._flame_max_range = tweak_data.weapon[self._name_id].flame_max_range
	self._single_flame_effect_duration = tweak_data.weapon[self._name_id].single_flame_effect_duration
	self._distance_to_gun_tip = 50
	self._flamethrower_effect_collection = {}
end

function FlamethrowerEffectExtension:set_range_values(range, duration)
	self._flame_max_range = range or tweak_data.weapon[self._name_id].flame_max_range
	self._single_flame_effect_duration = duration or tweak_data.weapon[self._name_id].single_flame_effect_duration
end	