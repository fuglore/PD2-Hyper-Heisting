function SentryGunDamage:damage_fire(attack_data)
	if self._dead or self._invulnerable or Network:is_client() and self._ignore_client_damage or attack_data.variant == "stun" then
		return
	end
	
	local fire_mul = nil
	
	if tweak_data.weapon[self._unit:base():get_name_id()].FIRE_DMG_MUL then
		fire_mul = tweak_data.weapon[self._unit:base():get_name_id()].FIRE_DMG_MUL
	else
		fire_mul = 1
	end
	
	local attacker_unit = attack_data.attacker_unit

	if attacker_unit and attacker_unit:base() and attacker_unit:base().thrower_unit then
		attacker_unit = attacker_unit:base():thrower_unit()
	end

	if attacker_unit and PlayerDamage.is_friendly_fire(self, attacker_unit) then
		return
	end

	local damage = attack_data.damage * fire_mul
	damage = damage * (self._marked_dmg_mul or 1)
	damage = damage + self._sync_dmg_leftover
	local damage_sync = self:_apply_damage(damage, true, true, true, attacker_unit, "fire")

	if self._ignore_client_damage then
		local health_percent = math.ceil(self._health / self._HEALTH_INIT_PERCENT)

		self._unit:network():send("sentrygun_health", health_percent)
	else
		if not damage_sync or damage_sync == 0 then
			return
		end

		local attacker = attack_data.attacker_unit

		if not attacker or attacker:id() == -1 then
			attacker = self._unit
		end

		local i_attack_variant = CopDamage._get_attack_variant_index(self, attack_data.variant)

		self._unit:network():send("damage_fire", attacker, damage_sync, false, self._dead and true or false, attack_data.col_ray.ray, nil, nil, false)
	end

	if not self._dead then
		self._unit:brain():on_damage_received(attack_data.attacker_unit)
	end

	local attacker_unit = attack_data and attack_data.attacker_unit

	if alive(attacker_unit) and attacker_unit:base() and attacker_unit:base().thrower_unit then
		attacker_unit = attacker_unit:base():thrower_unit()
	end

	if attacker_unit == managers.player:player_unit() and attack_data then
		managers.player:on_damage_dealt(self._unit, attack_data)
	end
end

function SentryGunDamage:damage_explosion(attack_data)
	if self._dead or self._invulnerable or Network:is_client() and self._ignore_client_damage or attack_data.variant == "stun" then
		return
	end
	
	local explosion_mul = nil
	
	if tweak_data.weapon[self._unit:base():get_name_id()].EXPLOSION_DMG_MUL then
		explosion_mul = tweak_data.weapon[self._unit:base():get_name_id()].EXPLOSION_DMG_MUL
	else
		explosion_mul = 1
	end

	local attacker_unit = attack_data.attacker_unit

	if attacker_unit and attacker_unit:base() and attacker_unit:base().thrower_unit then
		attacker_unit = attacker_unit:base():thrower_unit()
	end

	if attacker_unit and PlayerDamage.is_friendly_fire(self, attacker_unit) then
		return
	end

	local damage = attack_data.damage * explosion_mul
	attack_data.damage = damage

	if attacker_unit and attacker_unit == managers.player:player_unit() then
		self._char_tweak = tweak_data.weapon[self._unit:base():get_name_id()]
		local critical_hit, crit_damage = CopDamage.roll_critical_hit(self, attack_data)
		damage = crit_damage

		if critical_hit then
			managers.hud:on_crit_confirmed()
		else
			managers.hud:on_hit_confirmed()
		end
	end

	damage = damage * (self._marked_dmg_mul or 1)
	damage = damage + self._sync_dmg_leftover
	local damage_sync = self:_apply_damage(damage, true, true, true, attacker_unit, "explosion")

	if self._ignore_client_damage then
		local health_percent = math.ceil(self._health / self._HEALTH_INIT_PERCENT)

		self._unit:network():send("sentrygun_health", health_percent)
	else
		if not damage_sync or damage_sync == 0 then
			return
		end

		local attacker = attack_data.attacker_unit

		if not attacker or attacker:id() == -1 then
			attacker = self._unit
		end

		local i_attack_variant = CopDamage._get_attack_variant_index(self, attack_data.variant)

		self._unit:network():send("damage_explosion_fire", attacker, damage_sync, i_attack_variant, self._dead and true or false, attack_data.col_ray.ray, attack_data.weapon_unit)
	end

	if not self._dead then
		self._unit:brain():on_damage_received(attacker_unit)
	end

	local attacker_unit = attack_data and attack_data.attacker_unit

	if alive(attacker_unit) and attacker_unit:base() and attacker_unit:base().thrower_unit then
		attacker_unit = attacker_unit:base():thrower_unit()
	end

	if attacker_unit == managers.player:player_unit() and attack_data then
		managers.player:on_damage_dealt(self._unit, attack_data)
	end
end
