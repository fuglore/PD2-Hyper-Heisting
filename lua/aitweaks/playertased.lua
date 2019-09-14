function PlayerTased:_check_action_shock(t, input)
	if self._next_shock < t then
		
		if Global.game_settings.one_down or managers.skirmish:is_skirmish() then
			self._num_shocks = self._num_shocks + 1
			self._next_shock = t + 0.25 --no more positive rng

			self._unit:camera():play_shaker("player_taser_shock", 1, 10)
			self._unit:camera():camera_unit():base():set_target_tilt((math.random(2) == 1 and -1 or 1) * math.random(20))
		else
			self._num_shocks = self._num_shocks + 1
			self._next_shock = t + 0.25 + math.rand(1)

			self._unit:camera():play_shaker("player_taser_shock", 1, 10)
			self._unit:camera():camera_unit():base():set_target_tilt((math.random(2) == 1 and -1 or 1) * math.random(10))
		end
		
		self._taser_value = math.max(self._taser_value - 0.25, 0)

		self._unit:sound():play("tasered_shock")
		managers.rumble:play("electric_shock")

		if not alive(self._counter_taser_unit) then
			self._camera_unit:base():start_shooting()
			
			if Global.game_settings.one_down then
				self._recoil_t = t + 0.1 --active tase
			else
				self._recoil_t = t + 0.5
			end
			
			if not managers.player:has_category_upgrade("player", "resist_firing_tased") then
				input.btn_primary_attack_state = true
				input.btn_primary_attack_press = true
			end

			self._camera_unit:base():recoil_kick(-5, 5, -5, 5)
			self._unit:camera():play_redirect(self:get_animation("tased_boost"))
		end
	elseif self._recoil_t then
		if not managers.player:has_category_upgrade("player", "resist_firing_tased") then
			input.btn_primary_attack_state = true
		end

		if self._recoil_t < t then
			self._recoil_t = nil

			self._camera_unit:base():stop_shooting()
		end
	end
end
