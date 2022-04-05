if BLT.Mods:GetModByName("WeaponLib") then
	return
end

if PD2THHSHIN and PD2THHSHIN:IsOverhaulEnabled() then
	
	local mvec3_set = mvector3.set
	local mvec3_add = mvector3.add
	local mvec3_dot = mvector3.dot
	local mvec3_sub = mvector3.subtract
	local mvec3_mul = mvector3.multiply
	local mvec3_norm = mvector3.normalize
	local mvec3_dir = mvector3.direction
	local mvec3_set_l = mvector3.set_length
	local mvec3_len = mvector3.length
	local math_clamp = math.clamp
	local math_lerp = math.lerp
	local tmp_vec1 = Vector3()
	local tmp_vec2 = Vector3()
	local mvec_to = Vector3()
	local mvec_spread_direction = Vector3()

	local original_init = SawWeaponBase.init
	function SawWeaponBase:init(unit)
		original_init(self, unit)

		self._shield_knock = false
		self._use_armor_piercing = true
	end

	--i hate doing this so much but i couldn't figure out a proper way to posthook this. hopefully someone else can figure out how but for now i guess i'll just die
	function SawWeaponBase:fire(from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)
		if self:get_ammo_remaining_in_clip() == 0 then
			return
		end

		local user_unit = self._setup.user_unit
		local ray_res, hit_something, drain_ammo = self:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)

		if hit_something then
			self:_start_sawing_effect()

			if drain_ammo and not managers.player:has_active_temporary_property("bullet_storm") then
				local ammo_usage = 5

				if ray_res.hit_enemy then
					if managers.player:has_category_upgrade("saw", "enemy_slicer") then
						ammo_usage = 0
					else
						ammo_usage = 15
					end
				end

				if ammo_usage > 0 then
					ammo_usage = ammo_usage + math.ceil(math.random() * 10)

					if managers.player:has_category_upgrade("saw", "consume_no_ammo_chance") then
						local roll = math.rand(1)
						local chance = managers.player:upgrade_value("saw", "consume_no_ammo_chance", 0)

						if roll < chance then
							ammo_usage = 0
						end
					end

					if ammo_usage > 0 then
						ammo_usage = math.min(ammo_usage, self:get_ammo_remaining_in_clip())

						self:set_ammo_remaining_in_clip(math.max(self:get_ammo_remaining_in_clip() - ammo_usage, 0))
						self:set_ammo_total(math.max(self:get_ammo_total() - ammo_usage, 0))
						self:_check_ammo_total(user_unit)
					end
				end
			end
		else
			self:_stop_sawing_effect()
		end

		if self._alert_events and ray_res.rays then
			if hit_something then
				self._alert_size = self._hit_alert_size
			else
				self._alert_size = self._no_hit_alert_size
			end

			self._current_stats.alert_size = self._alert_size

			self:_check_alert(ray_res.rays, from_pos, direction, user_unit)
		end

		return ray_res
	end

	local mvec_to = Vector3()
	local mvec_spread_direction = Vector3()

	function SawWeaponBase:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul)
		local result = {}
		local hit_unit = nil
		local valid_hit = false
		local drain_ammo = false
		from_pos = self._obj_fire:position()
		direction = self._obj_fire:rotation():y()

		mvector3.add(from_pos, direction * -30)
		mvector3.set(mvec_spread_direction, direction)
		mvector3.set(mvec_to, mvec_spread_direction)
		mvector3.multiply(mvec_to, 100)
		mvector3.add(mvec_to, from_pos)

		local damage = self:_get_current_damage(dmg_mul)

		local shield_mask = managers.slot:get_mask("enemy_shield_check")
		local enemy_mask = managers.slot:get_mask("enemies")
		local civilian_mask = managers.slot:get_mask("civilians")
		local wall_mask = managers.slot:get_mask("world_geometry", "vehicles")

		local ray_hits = World:raycast_all("ray", from_pos, mvec_to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units, "ray_type", "body bullet lock")
		local units_hit = {}
		local unique_hits = {}

		for i, hit in ipairs(ray_hits) do
			if not units_hit[hit.unit:key()] then
				units_hit[hit.unit:key()] = true
				unique_hits[#unique_hits + 1] = hit
				hit.hit_position = hit.position
				drain_ammo = drain_ammo or hit.unit:in_slot(shield_mask) or hit.unit:in_slot(enemy_mask) or hit.unit:in_slot(civilian_mask) or hit.unit:in_slot(wall_mask)

				if hit.unit:in_slot(shield_mask) then
					if not self._saw_through_shields then
						break
					end
				elseif hit.unit:in_slot(enemy_mask) or hit.unit:in_slot(wall_mask) then
					break
				end
			end
		end

		for i, hit in ipairs(unique_hits) do
			hit_unit = SawHit:on_collision(hit, self._unit, user_unit, damage, direction)
		end

		valid_hit = #ray_hits > 0

		result.hit_enemy = hit_unit

		if self._alert_events then
			result.rays = {
				ray_hits
			}
		end

		if ray_hits then
			managers.statistics:shot_fired({
				hit = true,
				weapon_unit = self._unit
			})
		end

		return result, valid_hit, drain_ammo
	end

	function SawHit:on_collision(col_ray, weapon_unit, user_unit, damage)
		local hit_unit = col_ray.unit

		if self._saw_through_shields and hit_unit and hit_unit.base and hit_unit:base() and hit_unit:base().has_tag and hit_unit:base():has_tag("tank") then
			damage = damage + 50
		end

		local result = InstantBulletBase.on_collision(self, col_ray, weapon_unit, user_unit, damage)

		if hit_unit:damage() and col_ray.body:extension() and col_ray.body:extension().damage then
			damage = math.clamp(damage * managers.player:upgrade_value("saw", "lock_damage_multiplier", 1) * 4, 0, 200)

			col_ray.body:extension().damage:damage_lock(user_unit, col_ray.normal, col_ray.position, col_ray.direction, damage)

			if hit_unit:id() ~= -1 then
				managers.network:session():send_to_peers_synched("sync_body_damage_lock", col_ray.body, damage)
			end
		end

		return result
	end

	function SawHit:play_impact_sound_and_effects(weapon_unit, col_ray)
		local decal = "saw"

		if col_ray.unit:character_damage() and not col_ray.unit:character_damage()._no_blood then
			decal = nil
		end

		managers.game_play_central:play_impact_sound_and_effects({
			decal = decal,
			no_sound = true,
			col_ray = col_ray
		})
	end
end
