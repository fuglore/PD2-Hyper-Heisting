local mvec3_set = mvector3.set
local mvec3_dir = mvector3.direction
local mvec3_dis_sq = mvector3.distance_sq
local mvec3_add = mvector3.add
local mvec3_copy = mvector3.copy
local tmp_pos = Vector3()
local math_min = math.min
local math_max = math.max
local math_round = math.round
local math_ceil = math.ceil
local table_insert = table.insert
local table_remove = table.remove
local draw_explosion_sphere = nil
local draw_sync_explosion_sphere = nil
local draw_splinters = nil
local draw_obstructed_splinters = nil
local draw_splinter_hits = nil

function FireManager:update(t, dt)
	for index = #self._doted_enemies, 1, -1 do
		local dot_info = self._doted_enemies[index]

		--no grace period means that DoT ticks will consistently trigger as long as the enemy is "doted"
		--instead of resetting the timer each time a new DoT instance is applied, correctly allowing players
		--to dose enemies continuously to maximize damage, as the latest update to flamethrower stats intended
		if dot_info.fire_dot_counter >= 0.5 then
			self:_damage_fire_dot(dot_info)

			dot_info.fire_dot_counter = 0
		end

		if t > dot_info.fire_damage_received_time + dot_info.dot_length then
			if dot_info.fire_effects then
				for _, fire_effect_id in ipairs(dot_info.fire_effects) do
					World:effect_manager():fade_kill(fire_effect_id)
				end
			end

			--fix for fire effects dissappearing on their own
			--self:_remove_flame_effects_from_doted_unit(dot_info.enemy_unit)

			if dot_info.sound_source then
				self:_stop_burn_body_sound(dot_info.sound_source)
			end

			table_remove(self._doted_enemies, index)

			if dot_info.enemy_unit and alive(dot_info.enemy_unit) then
				self._dozers_on_fire[dot_info.enemy_unit:id()] = nil
			end
		else
			dot_info.fire_dot_counter = dot_info.fire_dot_counter + dt
		end
	end
end

function FireManager:check_achievemnts(unit, t)
	if not unit and not alive(unit) then
		return
	end

	if not unit:base() or not unit:base()._tweak_table then
		return
	end

	if CopDamage.is_civilian(unit:base()._tweak_table) then
		return
	end

	--grant achievements only for the local player when they're the attackers
	if self._doted_enemies then
		for _, dot_info in ipairs(self._doted_enemies) do
			if not dot_info.user_unit or dot_info.user_unit ~= managers.player:player_unit() then
				return
			end
		end
	else
		return
	end

	for i = #self._enemies_on_fire, 1, -1 do
		local data = self._enemies_on_fire[i]

		if t - data.t > 5 or data.unit == unit then
			table_remove(self._enemies_on_fire, i)
		end
	end

	table_insert(self._enemies_on_fire, {
		unit = unit,
		t = t
	})

	if tweak_data.achievement.disco_inferno then
		local count = #self._enemies_on_fire

		if count >= 10 then
			managers.achievment:award(tweak_data.achievement.disco_inferno)
		end
	end

	--proper Dozer check
	if unit:base().has_tag and unit:base():has_tag("tank") then
		local unit_id = unit:id()

		self._dozers_on_fire[unit_id] = self._dozers_on_fire[unit_id] or {
			t = t,
			unit = unit
		}
	end

	if tweak_data.achievement.overgrill then
		for dozer_id, dozer_info in pairs(self._dozers_on_fire) do
			if t - dozer_info.t >= 10 then
				managers.achievment:award(tweak_data.achievement.overgrill)
			end
		end
	end
end

function FireManager:add_doted_enemy(enemy_unit, fire_damage_received_time, weapon_unit, dot_length, dot_damage, user_unit, is_molotov)
	local dot_info = self:_add_doted_enemy(enemy_unit, fire_damage_received_time, weapon_unit, dot_length, dot_damage, user_unit, is_molotov)

	managers.network:session():send_to_peers_synched("sync_add_doted_enemy", enemy_unit, 0, weapon_unit, dot_length, dot_damage, user_unit, is_molotov)
end

function FireManager:_add_doted_enemy(enemy_unit, fire_damage_received_time, weapon_unit, dot_length, dot_damage, user_unit, is_molotov)
	local contains = false

	if self._doted_enemies then
		for _, dot_info in ipairs(self._doted_enemies) do
			if dot_info.enemy_unit == enemy_unit then
				--instead of always updating fire_damage_received_time, only do so (plus update the dot length) if the new length
				--is longer than the remaining DoT time (DoT damage also gets replaced as it's pretty much a new DoT instance)
				if dot_info.fire_damage_received_time + dot_info.dot_length < fire_damage_received_time + dot_length then
					dot_info.fire_damage_received_time = fire_damage_received_time
					dot_info.dot_length = dot_length
					dot_info.dot_damage = dot_damage
				else
					--to avoid a higher damage DoT from not applying, or applying with a longer timer
					if dot_info.dot_damage < dot_damage then
						dot_info.fire_damage_received_time = fire_damage_received_time
						dot_info.dot_length = dot_length
						dot_info.dot_damage = dot_damage
					end
				end

				--always override the attacker and weapons used so that the latest attacker gets credited properly
				dot_info.weapon_unit = weapon_unit
				dot_info.user_unit = user_unit
				dot_info.is_molotov = is_molotov

				contains = true
			end
		end

		if not contains then
			local dot_info = {
				fire_dot_counter = 0,
				enemy_unit = enemy_unit,
				fire_damage_received_time = fire_damage_received_time,
				weapon_unit = weapon_unit,
				dot_length = dot_length,
				dot_damage = dot_damage,
				user_unit = user_unit,
				is_molotov = is_molotov
			}

			table_insert(self._doted_enemies, dot_info)
			self:_start_enemy_fire_effect(dot_info)
			self:start_burn_body_sound(dot_info)
		end

		self:check_achievemnts(enemy_unit, fire_damage_received_time)
	end
end

function FireManager:_apply_body_damage(is_server, hit_body, user_unit, dir, damage)
	local hit_unit = hit_body:unit()
	local local_damage = is_server or hit_unit:id() == -1
	local sync_damage = is_server and hit_unit:id() ~= -1

	if not local_damage and not sync_damage then
		print("_apply_body_damage skipped")

		return
	end

	local normal = dir
	local prop_damage = math_min(damage, 200)

	if prop_damage < 0.25 then
		prop_damage = math_round(prop_damage, 0.25)
	end

	if prop_damage > 0 then
		local network_damage = math_ceil(prop_damage * 163.84)
		prop_damage = network_damage / 163.84

		if local_damage then
			hit_body:extension().damage:damage_fire(user_unit, normal, hit_body:position(), dir, prop_damage)
			hit_body:extension().damage:damage_damage(user_unit, normal, hit_body:position(), dir, prop_damage)
		end

		if sync_damage and managers.network:session() then
			if alive(user_unit) then
				managers.network:session():send_to_peers_synched("sync_body_damage_fire", hit_body, user_unit, normal, hit_body:position(), dir, math_min(32768, network_damage))
			else
				managers.network:session():send_to_peers_synched("sync_body_damage_fire_no_attacker", hit_body, normal, hit_body:position(), dir, math_min(32768, network_damage))
			end
		end
	end
end

function FireManager:client_damage_and_push(position, normal, user_unit, dmg, range, curve_pow)
	local hit_pos = position

	if draw_sync_explosion_sphere then
		local draw_duration = 3
		local new_brush = Draw:brush(Color.red:with_alpha(0.5), draw_duration)
		new_brush:sphere(hit_pos, range)
	end

	local bodies = World:find_bodies("intersect", "sphere", hit_pos, range, managers.slot:get_mask("explosion_targets"))
	local units_to_push = {}

	for _, hit_body in ipairs(bodies) do
		if alive(hit_body) then
			local hit_unit = hit_body:unit()
			units_to_push[hit_unit:key()] = hit_unit
			local apply_dmg = hit_body:extension() and hit_body:extension().damage and hit_unit:id() == -1
			local dir, damage = nil

			if apply_dmg then
				dir = hit_body:center_of_mass()
				mvec3_dir(dir, hit_pos, dir)
				damage = dmg

				self:_apply_body_damage(false, hit_body, user_unit, dir, damage)
			end
		end
	end

	managers.explosion:units_to_push(units_to_push, position, range)
end
