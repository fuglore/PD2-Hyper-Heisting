local world_g = World
local mvec3_set = mvector3.set
local mvec3_mul = mvector3.multiply
local mvec3_add = mvector3.add

function PlayerMovement:clbk_attention_notice_sneak(observer_unit, status, local_client_detection)
	if alive(observer_unit) then
		self:on_suspicion(observer_unit, status, local_client_detection)
	end
end

function PlayerMovement:on_suspicion(observer_unit, status, local_client_detection)
	if Network:is_server() or local_client_detection then
		self._suspicion_debug = self._suspicion_debug or {}
		self._suspicion_debug[observer_unit:key()] = {
			unit = observer_unit,
			name = observer_unit:name(),
			status = status
		}
		local visible_status = nil

		if managers.groupai:state():whisper_mode() and not managers.groupai:state():stealth_hud_disabled() then
			visible_status = status
		else
			visible_status = false
		end

		self._suspicion = self._suspicion or {}

		if visible_status == false or visible_status == true then
			self._suspicion[observer_unit:key()] = nil

			if not next(self._suspicion) then
				self._suspicion = nil
			end

			if visible_status and observer_unit:movement() and not observer_unit:movement():cool() and TimerManager:game():time() - observer_unit:movement():not_cool_t() > 1 then
				self._suspicion_ratio = false

				self:_feed_suspicion_to_hud()

				return
			end
		elseif type(visible_status) == "number" and (not observer_unit:movement() or observer_unit:movement():cool()) then
			self._suspicion[observer_unit:key()] = visible_status
		else
			return
		end

		self:_calc_suspicion_ratio_and_sync(observer_unit, visible_status, local_client_detection)
	else
		self._suspicion_ratio = status
	end

	self:_feed_suspicion_to_hud()
end

function PlayerMovement:_calc_suspicion_ratio_and_sync(observer_unit, status, local_client_detection)
	local suspicion_sync = nil

	if self._suspicion and status ~= true then
		local max_suspicion = nil

		for u_key, val in pairs(self._suspicion) do
			if not max_suspicion or max_suspicion < val then
				max_suspicion = val
			end
		end

		if max_suspicion then
			self._suspicion_ratio = max_suspicion
			suspicion_sync = math.ceil(self._suspicion_ratio * 254)
		else
			self._suspicion_ratio = false
			suspicion_sync = false
		end
	elseif type(status) == "boolean" then
		self._suspicion_ratio = status
		suspicion_sync = status and 255 or 0
	else
		self._suspicion_ratio = false
		suspicion_sync = 0
	end

	if not local_client_detection and suspicion_sync ~= self._synced_suspicion then
		self._synced_suspicion = suspicion_sync
		local peer = managers.network:session():peer_by_unit(self._unit)

		if peer then
			managers.network:session():send_to_peers_synched("suspicion", peer:id(), suspicion_sync)
		end
	end
end

function PlayerMovement:play_taser_boom(local_unit)
	local pos = Vector3()
	
	if local_unit then
		mvec3_set(pos, self._m_head_rot:y())
		mvec3_mul(pos, 20)
		mvec3_add(pos, self:m_head_pos())
	else
		mvec3_set(pos, self._unit:movement():m_pos())
	end
	
	world_g:effect_manager():spawn({
		effect = Idstring("effects/pd2_mod_hh/particles/weapons/explosion/electric_explosion"),
		position = pos,
		normal = math.UP
	})
	
	self._unit:sound():play("c4_explode_metal")
end

function PlayerMovement:subtract_stamina(value)
	if managers.player._syringe_stam then
		return
	end

	if managers.player:has_category_upgrade("player", "stamina_ammo_refill_single") then
		self._subtracted_stamina_single = (self._subtracted_stamina_single or 0) + math.abs(value)
		local stamina_needed, ammo_refill = unpack(managers.player:upgrade_value("player", "stamina_ammo_refill_single"))

		if stamina_needed < self._subtracted_stamina_single then
			for i = 1, 2 do
				local weapon = self._unit:inventory():unit_by_selection(i):base()

				if weapon:fire_mode() == "single" then
					local ammo = math.ceil(weapon:get_ammo_max() * ammo_refill)

					weapon:add_ammo_to_pool(ammo, i)
				end
			end

			self._subtracted_stamina_single = self._subtracted_stamina_single - stamina_needed
		end
	end

	if managers.player:has_category_upgrade("player", "stamina_ammo_refill_auto") then
		self._subtracted_stamina_auto = (self._subtracted_stamina_auto or 0) + math.abs(value)
		local stamina_needed, ammo_refill = unpack(managers.player:upgrade_value("player", "stamina_ammo_refill_auto"))

		if stamina_needed < self._subtracted_stamina_auto then
			for i = 1, 2 do
				local weapon = self._unit:inventory():unit_by_selection(i):base()

				if weapon:fire_mode() == "auto" then
					local ammo = math.ceil(weapon:get_ammo_max() * ammo_refill)

					weapon:add_ammo_to_pool(ammo, i)
				end
			end

			self._subtracted_stamina_auto = self._subtracted_stamina_auto - stamina_needed
		end
	end

	self:_change_stamina(-math.abs(value))
end

function PlayerMovement:is_above_stamina_threshold()
	if managers.player._syringe_stam then
		return true
	end

	local threshold = tweak_data.player.movement_state.stamina.MIN_STAMINA_THRESHOLD
	
	if managers.player:has_category_upgrade("player", "start_action_stam_drain_reduct") then
		threshold = threshold * 0.5
	end

	return threshold < self._stamina
end

function PlayerMovement:update_stamina(t, dt, ignore_running)
	local dt = self._last_stamina_regen_t and t - self._last_stamina_regen_t or dt
	self._last_stamina_regen_t = t
	
	if not ignore_running and self._is_running and not managers.player._syringe_stam then
		self:subtract_stamina(dt * tweak_data.player.movement_state.stamina.STAMINA_DRAIN_RATE)
	elseif not self._state_data.in_air then
		if self:_max_stamina() > self._stamina then
			local regen = tweak_data.player.movement_state.stamina.STAMINA_REGEN_RATE
			
			if managers.player:has_category_upgrade("player", "stamina_regen_multiplier") then
				regen = regen * 1.25
			end
			
			self:add_stamina(dt * regen)
		end
	end

	if _G.IS_VR then
		managers.hud:set_stamina({
			current = self._stamina,
			total = self:_max_stamina()
		})
	end
end

function PlayerMovement:on_SPOOCed(enemy_unit)
	if managers.player:has_category_upgrade("player", "counter_strike_spooc") and self._current_state.in_melee and self._current_state:in_melee() then
		self._current_state:discharge_melee()

		return "countered"
	end

	if self._unit:character_damage()._god_mode or self._unit:character_damage():get_mission_blocker("invulnerable") then
		return true
	end
	
	local push_mul = 2000
	local height_mul = 0.2
	
	if managers.modifiers and managers.modifiers:check_boolean("woahtheyjomp") then
		push_mul = 4000
		height_mul = 0.1
	end
	
	local push_vec = Vector3()
	local distance = mvector3.direction(push_vec, enemy_unit:movement():m_head_pos(), self._unit:movement():m_pos())
	mvector3.normalize(push_vec)
	mvector3.set_z(push_vec, height_mul)
	local attack_data = {
		attacker_unit = enemy_unit,
		is_cloaker_kick = true,
		melee_armor_piercing = true,
		damage = 23.75,
		push_vel = push_vec * push_mul
	}
	self._unit:character_damage():damage_melee(attack_data)
		
	return true
end