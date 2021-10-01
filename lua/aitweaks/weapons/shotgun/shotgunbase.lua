local math_min = math.min
local math_max = math.max

local math_random = math.random
local math_sin = math.sin
local math_cos = math.cos
local math_rad = math.rad
local math_clamp = math.clamp

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

local pairs_g = pairs
local type_g = type

local mvec_temp = Vector3()
local mvec_to = Vector3()
local mvec_direction = Vector3()
local mvec_spread_direction = Vector3()

local table_insert = table.insert
local table_contains = table.contains

function ShotgunBase:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, shoot_through_data)
	local result = nil
	local hit_enemies = {}
	local hit_objects = {}
	local hit_something, col_rays = nil

	if self._alert_events then
		col_rays = {}
	end

	local damage = self:_get_current_damage(dmg_mul)
	local autoaim, dodge_enemies = self:check_autoaim(from_pos, direction, 20000)
	local weight = 0.1
	local enemy_died = false
	local bullet_class = self._bullet_class
	local on_collision_f = bullet_class.on_collision
	local on_collision_effects_f = bullet_class.on_collision_effects
	local pierce_shield = self._can_shoot_through_shield
	local pierce_enemies = self._can_shoot_through_enemy
	local pierce_wall = self._can_shoot_through_wall
	local use_tracers = self._can_shoot_through_shield or self._use_tracers
	
	local ASTB_hit_enemy = pierce_shield or pierce_wall

	local function hit_enemy(col_ray)
		if col_ray.unit:character_damage() then
			local char_dmg = col_ray.unit:character_damage()
			local enemy_key = col_ray.unit:key()

			if not hit_enemies[enemy_key] or char_dmg.is_head and char_dmg:is_head(col_ray.body) then
				hit_enemies[enemy_key] = col_ray
			end

			if not char_dmg.is_head then
				if not char_dmg.is_friendly_fire or char_dmg.is_friendly_fire and not char_dmg:is_friendly_fire(user_unit) then
					on_collision_effects_f(bullet_class, col_ray, self._unit, user_unit, damage)
				end
			end
		else
			if ASTB_hit_enemy then
				hit_objects[col_ray.unit:key()] = hit_objects[col_ray.unit:key()] or {}

				table_insert(hit_objects[col_ray.unit:key()], col_ray)
			else
				on_collision_f(bullet_class, col_ray, self._unit, user_unit, damage)
			end
		end
	end

	local spread_x, spread_y = self:_get_spread(user_unit)
	local right = direction:cross(Vector3(0, 0, 1)):normalized()
	local up = direction:cross(right):normalized()

	mvec3_set(mvec_direction, direction)

	for i = 1, shoot_through_data and 1 or self._rays do
		local theta = math_random() * 360
		local ax = math_sin(theta) * math_random() * spread_x * (spread_mul or 1)
		local ay = math_cos(theta) * math_random() * spread_y * (spread_mul or 1)

		mvec3_set(mvec_spread_direction, mvec_direction)
		mvec3_add(mvec_spread_direction, right * math_rad(ax))
		mvec3_add(mvec_spread_direction, up * math_rad(ay))
		mvec3_set(mvec_to, mvec_spread_direction)
		mvec3_mul(mvec_to, 20000)
		mvec3_add(mvec_to, from_pos)

		local ray_from_unit = shoot_through_data and alive(shoot_through_data.ray_from_unit) and shoot_through_data.ray_from_unit or nil
		local col_ray = (ray_from_unit or World):raycast("ray", from_pos, mvec_to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units)

		if col_rays then
			if col_ray then
				col_rays[#col_rays + 1] = col_ray
			else
				local ray_to = mvec3_cpy(mvec_to)
				local spread_direction = mvec3_cpy(mvec_spread_direction)
				local col_ray = {position = ray_to, ray = spread_direction}
				col_rays[#col_rays + 1] = col_ray
			end
		end

		if self._autoaim and autoaim then
			if col_ray and col_ray.unit:in_slot(managers.slot:get_mask("enemies")) then
				self._autohit_current = (self._autohit_current + weight) / (1 + weight)

				hit_enemy(col_ray)

				autoaim = false
			else
				autoaim = false
				local autohit = self:check_autoaim(from_pos, direction, 20000)

				if autohit then
					local autohit_chance = 1 - math_clamp((self._autohit_current - self._autohit_data.MIN_RATIO) / (self._autohit_data.MAX_RATIO - self._autohit_data.MIN_RATIO), 0, 1)

					if math_random() < autohit_chance then
						self._autohit_current = (self._autohit_current + weight) / (1 + weight)
						hit_something = true

						hit_enemy(autohit)
					else
						self._autohit_current = self._autohit_current / (1 + weight)
					end
				elseif col_ray then
					hit_something = true

					hit_enemy(col_ray)
				end
			end
		elseif col_ray then
			hit_something = true

			hit_enemy(col_ray)
		end
		
		if use_tracers then
			if alive(self._obj_fire) then
				local furthest_hit = col_ray
			
				if furthest_hit and furthest_hit.distance > 600 or not furthest_hit then --last collision made by the ray or no collision, both used to spawn the cosmetic tracers from the barrel of the gun
					local trail_direction = furthest_hit and furthest_hit.ray or mvec_spread_direction

					self._obj_fire:m_position(self._trail_effect_table.position)
					mvector3.set(self._trail_effect_table.normal, trail_direction)

					local trail = World:effect_manager():spawn(self._trail_effect_table)

					if furthest_hit then
						World:effect_manager():set_remaining_lifetime(trail, math.clamp((furthest_hit.distance - 600) / 10000, 0, furthest_hit.distance))
					else
						World:effect_manager():set_remaining_lifetime(trail, math.clamp((20000 - 600) / 10000, 0, 20000))
					end
				end
			end
		end
	end

	for _, col_rays in pairs_g(hit_objects) do
		local center_ray = col_rays[1]
		local nr_rays = #col_rays

		if nr_rays > 1 then
			mvec3_set_static(mvec_temp, center_ray)

			for i = 1, nr_rays do
				local col_ray = col_rays[i]
				mvec3_add(mvec_temp, col_ray.position)
			end

			mvec3_divide(mvec_temp, nr_rays)

			local closest_dist_sq = mvec3_dis_sq(mvec_temp, center_ray.position)
			local dist_sq = nil

			for i = 1, nr_rays do
				local col_ray = col_rays[i]
				dist_sq = mvec3_dis_sq(mvec_temp, col_ray.position)

				if dist_sq < closest_dist_sq then
					closest_dist_sq = dist_sq
					center_ray = col_ray
				end
			end
		end

		ShotgunBase.super._fire_raycast(self, user_unit, from_pos, center_ray.ray, dmg_mul, shoot_player, 0, autohit_mul, suppr_mul, shoot_through_data)
	end

	local kill_data = {
		kills = 0,
		headshots = 0,
		civilian_kills = 0
	}
	
	local ASTB_colrays = pierce_shield or pierce_enemies or pierce_wall

	for _, col_ray in pairs_g(hit_enemies) do
		local damage = self:get_damage_falloff(damage, col_ray, user_unit)

		if damage > 0 then
			local my_result = nil

			if ASTB_colrays then
				my_result = ShotgunBase.super._fire_raycast(self, user_unit, from_pos, col_ray.ray, dmg_mul, shoot_player, 0, autohit_mul, suppr_mul, shoot_through_data)
			else
				my_result = bullet_class:on_collision(col_ray, self._unit, user_unit, damage)
			end

			my_result = managers.mutators:modify_value("ShotgunBase:_fire_raycast", my_result)

			if my_result and my_result.type == "death" then
				managers.game_play_central:do_shotgun_push(col_ray.unit, col_ray.position, col_ray.ray, col_ray.distance, user_unit)

				kill_data.kills = kill_data.kills + 1

				if col_ray.body and col_ray.body:name() == Idstring("head") then
					kill_data.headshots = kill_data.headshots + 1
				end

				if col_ray.unit and col_ray.unit:base() and (col_ray.unit:base()._tweak_table == "civilian" or col_ray.unit:base()._tweak_table == "civilian_female") then
					kill_data.civilian_kills = kill_data.civilian_kills + 1
				end
			end
		end
	end

	if dodge_enemies and self._suppression then
		for enemy_data, dis_error in pairs_g(dodge_enemies) do
			enemy_data.unit:character_damage():build_suppression(suppr_mul * dis_error * self._suppression, self._panic_suppression_chance)
		end
	end

	if not result then
		result = {
			hit_enemy = next(hit_enemies) and true or false
		}

		if self._alert_events then
			result.rays = #col_rays > 0 and col_rays
		end
	end

	if not shoot_through_data then
		managers.statistics:shot_fired({
			hit = false,
			weapon_unit = self._unit
		})
	end

	for _, d in pairs_g(hit_enemies) do
		managers.statistics:shot_fired({
			skip_bullet_count = true,
			hit = true,
			weapon_unit = self._unit
		})
	end

	for key, data in pairs_g(tweak_data.achievement.shotgun_single_shot_kills) do
		if data.headshot and data.count <= kill_data.headshots - kill_data.civilian_kills or data.count <= kill_data.kills - kill_data.civilian_kills then
			local should_award = true

			if data.blueprint then
				local missing_parts = false
				
				for i = 1, #data.blueprint do
					local part_or_parts = data.blueprint[i]
					
					if type_g(part_or_parts) == "string" then
						if not table_contains(self._blueprint or {}, part_or_parts) then
							missing_parts = true

							break
						end
					else
						local found_part = false
						
						for i = 1, #part_or_parts do
							local part = part_or_parts[i]
							
							if table_contains(self._blueprint or {}, part) then
								found_part = true

								break
							end
						end

						if not found_part then
							missing_parts = true

							break
						end
					end
				end

				if missing_parts then
					should_award = false
				end
			end

			if should_award then
				managers.achievment:_award_achievement(data, key)
			end
		end
	end

	return result
end
