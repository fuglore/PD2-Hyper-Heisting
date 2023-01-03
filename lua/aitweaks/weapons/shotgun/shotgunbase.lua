local math_min = math.min
local math_max = math.max

local math_random = math.random
local math_sin = math.sin
local math_cos = math.cos
local math_rad = math.rad
local math_clamp = math.clamp
local math_tan = math.tan

local mvec3_dis = mvector3.distance
local mvec3_dis_sq = mvector3.distance_sq
local mvec3_set = mvector3.set
local mvec3_add = mvector3.add
local mvec3_mul = mvector3.multiply
local mvec3_cpy = mvector3.copy
local mvec3_set_static = mvector3.set_static
local mvec3_divide = mvector3.divide

function ShotgunBase:get_damage_falloff(damage, col_ray, user_unit)
	local distance = col_ray.distance or mvec3_dis(col_ray.unit:position(), user_unit:position())
	local inc_range_mul = 1
	local current_state = user_unit:movement()._current_state

	if current_state and current_state:in_steelsight() then
		inc_range_mul = managers.player:upgrade_value("shotgun", "steelsight_range_inc", 1)
	end
	
	local spread_mul = 2
	local spread_index = self._current_stats_indices and self._current_stats_indices.spread or 1
	local spread_mul_reduction = self:_get_spread_index(current_state, spread_index)
	
	spread_mul = spread_mul - spread_mul_reduction
	inc_range_mul = math.max(1, spread_mul * inc_range_mul)
	
	local damage_percent_min = inc_range_mul * 0.1
	damage_percent_min = damage * damage_percent_min
	local new_damage = 1 - math_min(1, math_max(0, distance - self._damage_near * inc_range_mul) / (self._damage_far * inc_range_mul))
	new_damage = new_damage * damage
	
	if new_damage < damage_percent_min then
		new_damage = damage_percent_min
	end

	--log("damage is: " .. tostring(new_damage) .. "")

	return new_damage
end