function HuskCopDamage:damage_bullet(attack_data)
	if self._dead or self._invulnerable then
		return
	end

	local attacker_unit = attack_data.attacker_unit
	local attacker_base = alive(attacker_unit) and attacker_unit.base and attacker_unit:base()
	if attacker_base.is_local_player then
		return HuskCopDamage.super.damage_bullet(self, attack_data)
	end

	return self:is_friendly_fire(attacker_unit) and 'friendly_fire' or nil
end