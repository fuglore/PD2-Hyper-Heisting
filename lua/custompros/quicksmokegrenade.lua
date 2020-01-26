function QuickSmokeGrenade:_play_sound_and_effects()
	local diff_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)
	if self._state == 1 then
		local sound_source = SoundDevice:create_source("grenade_fire_source")

		sound_source:set_position(self._shoot_position)
		sound_source:post_event("grenade_gas_npc_fire")
	elseif self._state == 2 then
		local bounce_point = Vector3()

		mvector3.lerp(bounce_point, self._shoot_position, self._unit:position(), 0.65)

		local sound_source = SoundDevice:create_source("grenade_bounce_source")

		sound_source:set_position(bounce_point)
		sound_source:post_event("grenade_gas_bounce")
	elseif self._state == 3 then
		World:effect_manager():spawn({
			effect = Idstring("effects/particles/explosions/explosion_smoke_grenade"),
			position = self._unit:position(),
			normal = self._unit:rotation():y()
		})
		self._unit:sound_source():post_event("grenade_gas_explode")

		local parent = self._unit:orientation_object()
		if diff_index <= 7 then
			self._smoke_effect = World:effect_manager():spawn({
				effect = Idstring("effects/pd2_mod_hh/particles/weapons/explosion/smoke_hh_complex"),
				parent = parent
			})
		else
			self._smoke_effect = World:effect_manager():spawn({
				effect = Idstring("effects/pd2_mod_hh/particles/weapons/explosion/smoke_hh_anarchy"),
				parent = parent
			})
		end
	end
end