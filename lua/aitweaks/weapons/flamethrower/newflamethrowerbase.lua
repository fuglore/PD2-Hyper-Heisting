local mvec3_set = mvector3.set
local mvec3_add = mvector3.add
local mvec3_mul = mvector3.multiply
local mvec3_dis_sq = mvector3.distance_sq
local mvec3_lerp = mvector3.lerp
local mvec3_dir = mvector3.direction
local mvec3_cpy = mvector3.copy
local tmp_vec1 = Vector3()
local mrot_set_look_at = mrotation.set_look_at
local tmp_rot = Rotation()
local math_up = math.UP
local math_lerp = math.lerp

function NewFlamethrowerBase:_update_stats_values()
	self._bullet_class = nil

	NewFlamethrowerBase.super._update_stats_values(self)
	self:setup_default()
	
	local custom_stats = managers.weapon_factory:get_custom_stats_from_weapon(self._factory_id, self._blueprint)
	
	for part_id, stats in pairs(custom_stats) do
		if stats.range_mul then 
			self._range = self._range * stats.range_mul
			self._flame_max_range = self._flame_max_range * stats.range_mul
			self._flame_max_range_sq = self._flame_max_range * self._flame_max_range
		end
	end

	local ammo_data = self._ammo_data

	if ammo_data then
		local rays = ammo_data.rays

		if rays ~= nil then
			self._rays = rays
		end

		local bullet_class = ammo_data.bullet_class

		if bullet_class ~= nil then
			bullet_class = CoreSerialize.string_to_classtable(bullet_class)

			if bullet_class then
				self._bullet_class = bullet_class
				self._bullet_slotmask = bullet_class:bullet_slotmask()
				self._blank_slotmask = bullet_class:blank_slotmask()
			else
				print("[NewFlamethrowerBase:_update_stats_values] Unexisting class for bullet_class string ", ammo_data.bullet_class, "defined in ammo_data for tweak data ID ", self._name_id)
			end
		end
	end
end

local mvec_to = Vector3()
local mvec_direction = Vector3()
local mvec_spread_direction = Vector3()

function NewFlamethrowerBase:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, shoot_through_data)
	local result = {}
	local damage = self:_get_current_damage(dmg_mul)
	local damage_range = self._flame_max_range or self._range

	mvec3_set(mvec_to, direction)
	mvec3_mul(mvec_to, damage_range)
	mvec3_add(mvec_to, from_pos)

	local col_ray = World:raycast("ray", mvector3.copy(from_pos), mvec_to, "sphere_cast_radius", self._flame_radius, "disable_inner_ray", "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units)
	
	if col_ray then
		local col_dis = col_ray.distance

		if col_dis < damage_range then
			damage_range = col_dis or damage_range
		end

		mvec3_set(mvec_to, direction)
		mvec3_mul(mvec_to, damage_range)
		mvec3_add(mvec_to, from_pos)
	end

	self:_spawn_flame_effect(mvec_to, direction)

	local hit_bodies = World:find_bodies("intersect", "capsule", from_pos, mvec_to, self._flame_radius, self._bullet_slotmask)
	local weap_unit = self._unit
	local hit_enemies = 0
	local hit_body, hit_unit, hit_u_key = nil
	local units_hit = {}
	local valid_hit_bodies = {}
	local ignore_units = self._setup.ignore_units
	local t_contains = table.contains

	for i = 1, #hit_bodies do
		hit_body = hit_bodies[i]
		hit_unit = hit_body:unit()

		if not t_contains(ignore_units, hit_unit) then
			hit_u_key = hit_unit:key()

			if not units_hit[hit_u_key] then
				units_hit[hit_u_key] = true
				valid_hit_bodies[#valid_hit_bodies + 1] = hit_body

				if hit_unit:character_damage() then
					hit_enemies = hit_enemies + 1
				end
			end
		end
	end

	local bullet_class = self._bullet_class
	local fake_ray_dir, fake_ray_dis = nil

	for i = 1, #valid_hit_bodies do
		hit_body = valid_hit_bodies[i]
		fake_ray_dir = hit_body:center_of_mass()
		fake_ray_dis = mvec3_dir(fake_ray_dir, from_pos, fake_ray_dir)
		local hit_pos = hit_body:position()
		local fake_ray = {
			body = hit_body,
			unit = hit_body:unit(),
			ray = fake_ray_dir,
			normal = fake_ray_dir,
			distance = fake_ray_dis,
			position = hit_pos,
			hit_position = hit_pos
		}

		bullet_class:on_collision(fake_ray, weap_unit, user_unit, damage)
	end

	local suppression = self._suppression

	if suppression then
		local max_suppression_range = self._flame_max_range * 1.5
	
		self:_suppress_units(mvector3.copy(from_pos), mvector3.copy(direction), max_suppression_range, managers.slot:get_mask("enemies"), user_unit, suppr_mul)
	end

	if self._alert_events then
		result.rays = {
			{
				position = from_pos
			}
		}
	end

	if hit_enemies > 0 then
		result.hit_enemy = true

		managers.statistics:shot_fired({
			hit = true,
			hit_count = hit_enemies,
			weapon_unit = weap_unit
		})
	else
		result.hit_enemy = false

		managers.statistics:shot_fired({
			hit = false,
			weapon_unit = weap_unit
		})
	end

	return result
end