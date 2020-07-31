function PlayerTased:enter(state_data, enter_data)
	PlayerTased.super.enter(self, state_data, enter_data)
	self:_start_action_tased(managers.player:player_timer():time(), state_data.non_lethal_electrocution)

	if state_data.non_lethal_electrocution then
		state_data.non_lethal_electrocution = nil
		self._is_non_lethal = true
		local recover_time = Application:time() + 5 * managers.player:upgrade_value("player", "electrocution_resistance_multiplier", 1)
		self._recover_delayed_clbk = "PlayerTased_recover_delayed_clbk"

		managers.enemy:add_delayed_clbk(self._recover_delayed_clbk, callback(self, self, "clbk_exit_to_std"), recover_time)
	else
		self._fatal_delayed_clbk = "PlayerTased_fatal_delayed_clbk"
		local tased_time = 9999
		--tased_time = managers.modifiers:modify_value("PlayerTased:TasedTime", tased_time)

		managers.enemy:add_delayed_clbk(self._fatal_delayed_clbk, callback(self, self, "clbk_exit_to_fatal"), TimerManager:game():time() + tased_time)
	end

	self._next_shock = 0.75
	self._taser_value = 1
	self._num_shocks = 0

	managers.groupai:state():on_criminal_disabled(self._unit, "electrified")

	if Network:is_server() then
		self:_register_revive_SO()
	end

	self._equipped_unit:base():on_reload()

	local projectile_entry = managers.blackmarket:equipped_projectile()

	if tweak_data.blackmarket.projectiles[projectile_entry].is_a_grenade then
		self:_interupt_action_throw_grenade()
	else
		self:_interupt_action_throw_projectile()
	end

	self:_interupt_action_reload()
	self:_interupt_action_steelsight()
	self:_interupt_action_melee(managers.player:player_timer():time())
	self:_interupt_action_ladder(managers.player:player_timer():time())
	self:_interupt_action_charging_weapon(managers.player:player_timer():time())

	self._rumble_electrified = managers.rumble:play("electrified")
	self.tased = true
	self._state_data = state_data

	if managers.player:has_category_upgrade("player", "taser_malfunction") then
		local data = managers.player:upgrade_value("player", "taser_malfunction")

		if data then
			managers.player:register_message(Message.SendTaserMalfunction, "taser_malfunction", function ()
				self:_on_malfunction_to_taser_event()
			end)
			managers.player:add_coroutine("taser_malfunction", PlayerAction.TaserMalfunction, managers.player, data.interval, data.chance_to_trigger)
		end
	end

	if managers.player:has_category_upgrade("player", "escape_taser") then
		local interact_string = managers.localization:text("hud_int_escape_taser", {
			BTN_INTERACT = managers.localization:btn_macro("interact", false)
		})

		managers.hud:show_interact({
			icon = "mugshot_electrified",
			text = interact_string
		})

		local target_time = managers.player:upgrade_value("player", "escape_taser", 2)

		managers.player:add_coroutine("escape_tase", PlayerAction.EscapeTase, managers.player, managers.hud, Application:time() + target_time)
		
		local function clbk()
			self:give_shock_to_taser_no_damage()
		end

		managers.player:register_message(Message.EscapeTase, "escape_tase", clbk)
	end

	CopDamage.register_listener("on_criminal_tased", {
		"on_criminal_tased"
	}, callback(self, self, "_on_tased_event"))
end

function PlayerTased:_check_action_shock(t, input)
		
	if self._next_shock < t then
		
		self._num_shocks = self._num_shocks + 1
		self._next_shock = t + 0.75

		self._unit:camera():play_shaker("player_taser_shock", 1, 10)
		self._unit:camera():camera_unit():base():set_target_tilt((math.random(2) == 1 and -1 or 1) * math.random(10))

		self._unit:sound():play("tasered_shock")
		managers.rumble:play("electric_shock")
		if self._unit:character_damage()._tase_data and not self._is_non_lethal then
			local attack_data = {
				attacker_unit = self._unit:character_damage()._tase_data.attacker_unit,
				is_taser_shock = true,
				armor_piercing = true,
				damage = 4.1
			}
			self._unit:character_damage():damage_bullet(attack_data)
		end

		if not alive(self._counter_taser_unit) then
			self._camera_unit:base():start_shooting()
			
			self._recoil_t = t + 0.5
			
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

function PlayerTased:on_tase_ended()
	self._tase_ended = true

	if self._fatal_delayed_clbk then
		managers.enemy:remove_delayed_clbk(self._fatal_delayed_clbk)

		self._fatal_delayed_clbk = nil
	end

	local current_state_name = managers.player:current_state()

	if not self._recover_delayed_clbk and current_state_name == "tased" and managers.network:session() then
		self._recover_delayed_clbk = "PlayerTased_recover_delayed_clbk"

		managers.enemy:add_delayed_clbk(self._recover_delayed_clbk, callback(self, self, "clbk_exit_to_std"), TimerManager:game():time())
	end

	self._taser_unit = nil
end

function PlayerTased:update(t, dt)
	
	PlayerTased.super.update(self, t, dt)
end