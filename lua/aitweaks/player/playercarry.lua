function PlayerCarry:_update_check_actions(t, dt)
	local input = self:_get_input(t, dt)

	self:_determine_move_direction()
	
	if self._melee_stunned and not self._melee_stunned_expire_t or self._melee_stunned_expire_t and self._melee_stunned_expire_t < t then
		self._melee_stunned = nil
		self:end_melee_stun()
	end
	
	self:_update_interaction_timers(t)
	self:_update_throw_projectile_timers(t, input)
	self:_update_reload_timers(t, dt, input)
	self:_update_melee_timers(t, input)
	self:_update_equip_weapon_timers(t, input)
	self:_update_running_timers(t)
	self:_update_zipline_timers(t, dt)
	self:_update_steelsight_timers(t, dt)

	if input.btn_stats_screen_press then
		self._unit:base():set_stats_screen_visible(true)
	elseif input.btn_stats_screen_release then
		self._unit:base():set_stats_screen_visible(false)
	end

	self:_update_foley(t, input)

	local new_action = nil
	new_action = new_action or self:_check_action_weapon_gadget(t, input)
	new_action = new_action or self:_check_action_weapon_firemode(t, input)
	new_action = new_action or self:_check_action_melee(t, input)
	new_action = new_action or self:_check_action_reload(t, input)
	new_action = new_action or self:_check_change_weapon(t, input)
	new_action = new_action or self:_check_action_equip(t, input)

	if not new_action then
		new_action = self:_check_action_primary_attack(t, input)

		if not new_action then
			self:_check_stop_shooting()
		end

		self._shooting = new_action
	end

	new_action = new_action or self:_check_action_throw_projectile(t, input)
	new_action = new_action or self:_check_action_deploy_underbarrel(t, input)

	self:_check_action_interact(t, input)
	self:_check_action_jump(t, input)
	self:_check_action_run(t, input)
	self:_check_action_ladder(t, input)
	self:_check_action_zipline(t, input)
	self:_check_action_cash_inspect(t, input)
	self:_check_action_deploy_bipod(t, input)
	self:_check_action_duck(t, input)
	self:_check_action_steelsight(t, input)
	self:_check_use_item(t, input)
	self:_update_use_item_timers(t, input)
	self:_check_action_change_equipment(t, input)
	self:_find_pickups(t)
	self:_check_action_night_vision(t, input)
end

function PlayerCarry:_check_use_item(t, input)
	local new_action = nil
	local action_wanted = input.btn_use_item_release and self._throw_time and t and t < self._throw_time

	if input.btn_use_item_press then
		self._throw_down = true
		self._second_press = false
		self._throw_time = t + PlayerCarry.throw_limit_t
	end

	if action_wanted then
		local action_forbidden = self._use_item_expire_t or self:_changing_weapon() or self:_interacting() or self._ext_movement:has_carry_restriction() or self:_is_throwing_projectile() or self:_on_zipline() or self._melee_stunned

		if not action_forbidden then
			managers.player:drop_carry()

			new_action = true
		end
	end

	if self._throw_down then
		if input.btn_use_item_release then
			self._throw_down = false
			self._second_press = false

			return PlayerCarry.super._check_use_item(self, t, input)
		elseif self._throw_time < t then
			if not self._second_press then
				input.btn_use_item_press = true
				self._second_press = true
			end

			return PlayerCarry.super._check_use_item(self, t, input)
		end
	end

	return new_action
end