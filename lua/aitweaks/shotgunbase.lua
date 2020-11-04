function ShotgunBase:get_damage_falloff(damage, col_ray, user_unit)
	local distance = col_ray.distance or mvector3.distance(col_ray.unit:position(), user_unit:position())
	local inc_range_mul = 1
	local current_state = user_unit:movement()._current_state

	if current_state and current_state:in_steelsight() then
		inc_range_mul = managers.player:upgrade_value("shotgun", "steelsight_range_inc", 1)
	end
	
	local damage_percent_min = damage * 0.1
	local new_damage = 1 - math.min(1, math.max(0, distance - self._damage_near * inc_range_mul) / (self._damage_far * inc_range_mul))
	new_damage = new_damage * damage
	
	if new_damage < damage_percent_min then
		new_damage = damage_percent_min
	end

	--log("damage is: " .. tostring(new_damage) .. "")

	return new_damage
end