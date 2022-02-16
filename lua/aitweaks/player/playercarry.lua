PlayerCarry.target_tilt = 0
PlayerCarry.throw_limit_t = 0.2

function PlayerCarry:_update_check_actions(t, dt)
	local input = self:_get_input(t, dt)

	self:_determine_move_direction()
	
	if self._melee_stunned and not self._melee_stunned_expire_t or self._melee_stunned_expire_t and self._melee_stunned_expire_t < t then
		self._melee_stunned = nil
		self:end_melee_stun()
	end
	
	if self._wave_dash_t and self._wave_dash_t < t then
		self._wave_dash_t = nil
		self._speed_is_wavedash_boost = nil
	end
	
	if self._fall_damage_slow_t and self._fall_damage_slow_t < t then
		self._fall_damage_slow_t = nil
	end
	
	if self._no_run_t then
		if self._running then
			self:_interupt_action_running(t)
		end
	
		self._no_run_t = self._no_run_t - dt
		
		if self._no_run_t <= 0 then
			self._no_run_t = nil
		end
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
	new_action = new_action or self:_check_action_interact(t, input)
	
	local projectile_entry = managers.blackmarket:equipped_projectile()
	local projectile_tweak = tweak_data.blackmarket.projectiles[projectile_entry]
		
	if projectile_tweak.ability then
		self:_check_action_use_ability(t, input)
	else
		new_action = new_action or self:_check_action_throw_projectile(t, input)
	end
	
	new_action = new_action or self:_check_action_weapon_gadget(t, input)
	new_action = new_action or self:_check_action_weapon_firemode(t, input)
	new_action = new_action or self:_check_action_melee(t, input)
	new_action = new_action or self:_check_action_reload(t, input)
	new_action = new_action or self:_check_change_weapon(t, input)

	if not new_action then
		new_action = self:_check_action_primary_attack(t, input)

		if not new_action then
			self:_check_stop_shooting()
		end

		self._shooting = new_action
	end
	
	new_action = new_action or self:_check_action_equip(t, input)
	
	if not new_action then
		new_action = self:_check_action_deploy_bipod(t, input)
		new_action = new_action or self:_check_action_deploy_underbarrel(t, input)
	end

	self:_check_action_jump(t, input)
	self:_check_action_run(t, input)
	self:_check_action_ladder(t, input)
	self:_check_action_zipline(t, input)
	self:_check_action_cash_inspect(t, input)
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

if PD2THHSHIN and PD2THHSHIN:IsOverhaulEnabled() then
	local armor_init = tweak_data.player.damage.ARMOR_INIT
	function PlayerCarry:_get_max_walk_speed(...)
		local multiplier = tweak_data.carry.types[self._tweak_data_name].move_speed_modifier
		if managers.player:has_category_upgrade("carry", "movement_penalty_nullifier") then
			multiplier = math.clamp(multiplier * managers.player:upgrade_value("carry", "movement_speed_multiplier", 1), 0, 1)
		else
			multiplier = math.clamp(multiplier * managers.player:upgrade_value("carry", "movement_speed_multiplier", 1), 0, 1)
		end
		if managers.player:has_category_upgrade("player", "armor_carry_bonus") then
			local base_max_armor = armor_init + managers.player:body_armor_value("armor") + managers.player:body_armor_skill_addend()
			local mul = managers.player:upgrade_value("player", "armor_carry_bonus", 1)

			for i = 1, base_max_armor, 1 do
				multiplier = multiplier * mul
			end

			multiplier = math.clamp(multiplier, 0, 1)
		end
			
		return PlayerCarry.super._get_max_walk_speed(self, ...) * multiplier
	end
end	