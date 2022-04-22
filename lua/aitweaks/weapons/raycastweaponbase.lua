local mvec3_set = mvector3.set
local mvec3_add = mvector3.add
local mvec3_dot = mvector3.dot
local mvec3_sub = mvector3.subtract
local mvec3_mul = mvector3.multiply
local mvec3_norm = mvector3.normalize
local mvec3_dis = mvector3.distance
local mvec3_dis_sq = mvector3.distance_sq
local mvec3_dir = mvector3.direction
local mvec3_set_l = mvector3.set_length
local mvec3_len = mvector3.length
local mvec3_cpy = mvector3.copy
local mvec3_add_scaled = mvector3.add_scaled

local mvec_from = Vector3()
local mvec_to = Vector3()
local mvec_spread_direction = Vector3()
local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()

local tmp_rot1 = Rotation()
local pairs_g = pairs

local table_insert = table.insert
local table_contains = table.contains

local math_pow = math.pow
local math_acos = math.acos
local math_ceil = math.ceil
local math_random = math.random
local math_clamp = math.clamp
local math_min = math.min
local math_cos = math.cos
local math_sin = math.sin
local math_rad = math.rad
local math_lerp = math.lerp
local math_floor = math.floor

local t_cont = table.contains

local next_g = next
local alive_g = alive
local world_g = World

local idstr_func = Idstring

local afsf_blacklist = {
	["saw"] = true,
	["saw_secondary"] = true,
	["flamethrower_mk2"] = true,
	["m134"] = true,
	["mg42"] = true,
	["shuno"] = true,
	["system"] = true
}

function RaycastWeaponBase:setup(setup_data, damage_multiplier)
	self._autoaim = setup_data.autoaim
	local stats = tweak_data.weapon[self._name_id].stats
	self._alert_events = setup_data.alert_AI and {} or nil
	self._alert_fires = {}
	local weapon_stats = tweak_data.weapon.stats

	if stats then
		self._zoom = self._zoom or weapon_stats.zoom[stats.zoom]
		self._alert_size = self._alert_size or weapon_stats.alert_size[stats.alert_size]
		self._suppression = self._suppression or weapon_stats.suppression[stats.suppression]
		self._spread = self._spread or weapon_stats.spread[stats.spread]
		self._recoil = self._recoil or weapon_stats.recoil[stats.recoil]
		self._spread_moving = self._spread_moving or weapon_stats.spread_moving[stats.spread_moving]
		self._concealment = self._concealment or weapon_stats.concealment[stats.concealment]
		self._value = self._value or weapon_stats.value[stats.value]
		self._reload = self._reload or weapon_stats.reload[stats.reload]

		for i, _ in pairs(weapon_stats) do
			local stat = self["_" .. tostring(i)]

			if not stat then
				self["_" .. tostring(i)] = weapon_stats[i][5]

				debug_pause("[RaycastWeaponBase] Weapon \"" .. tostring(self._name_id) .. "\" is missing stat \"" .. tostring(i) .. "\"!")
			end
		end
	else
		debug_pause("[RaycastWeaponBase] Weapon \"" .. tostring(self._name_id) .. "\" is missing stats block!")

		self._zoom = 60
		self._alert_size = 5000
		self._suppression = 1
		self._spread = 1
		self._recoil = 1
		self._spread_moving = 1
		self._reload = 1
	end

	self._bullet_slotmask = setup_data.hit_slotmask or self._bullet_slotmask
	self._bullet_slotmask = managers.mutators:modify_value("ProjectileBase:create_sweep_data:slot_mask", self._bullet_slotmask)
	self._panic_suppression_chance = setup_data.panic_suppression_skill and self:weapon_tweak_data().panic_suppression_chance

	if self._panic_suppression_chance == 0 then
		self._panic_suppression_chance = false
	end

	self._setup = setup_data
	self._fire_mode = self._fire_mode or tweak_data.weapon[self._name_id].FIRE_MODE or "auto"

	if self._setup.timer then
		self:set_timer(self._setup.timer)
	end
end

function RaycastWeaponBase:get_panic_sup_chance()
	if self._panic_suppression_chance then
		return self._panic_suppression_chance
	else
		return 0
	end
end

function RaycastWeaponBase:get_suppression()
	if self._suppression then
		return self._suppression
	else
		return 0
	end
end

function RaycastWeaponBase:update_next_shooting_time()
	local next_fire = (tweak_data.weapon[self._name_id].fire_mode_data and tweak_data.weapon[self._name_id].fire_mode_data.fire_rate or 0) / self:fire_rate_multiplier()
	
	local mul = 1
	
	if managers.player._magic_bullet_aced_t then
		mul = mul * 0.8
	end
	
	if managers.player._pop_pop_mul then
		local pop_pop_mul_true = managers.player._pop_pop_mul + 1
		mul = mul * pop_pop_mul_true
	end
	
	if managers.player._cool_chain_mul then
		mul = mul * managers.player._cool_chain_mul
	end
	
	next_fire = next_fire * mul
	
	if next_fire < 0 then
		next_fire = 0
	end
	
	self._next_fire_allowed = self._next_fire_allowed + next_fire
end

local mvec_to = Vector3()
local mvec_spread_direction = Vector3()
local mvec1 = Vector3()

if not BLT.Mods:GetModByName("WeaponLib") then

function RaycastWeaponBase:check_autoaim(from_pos, direction, max_dist, use_aim_assist, autohit_override_data, spread_mul)
	local spread_index = self._current_stats_indices and self._current_stats_indices.spread or 1
	local autohit_mul = tweak_data.weapon.stats.target_acquisition[spread_index]

	local autohit = use_aim_assist and self._aim_assist_data or self._autohit_data
	autohit = autohit_override_data or autohit
	local autohit_constant_angle = nil
	
	if autohit.min_angle then
		autohit_constant_angle = autohit.min_angle / autohit_mul
	else
		autohit_constant_angle = autohit.near_angle / autohit_mul
	end
	
	local autohit_near_angle = autohit.near_angle / autohit_mul
	local autohit_far_angle = autohit.far_angle / autohit_mul
	local far_dis = autohit.far_dis
	local closest_error, closest_ray = nil
	local tar_vec = tmp_vec1
	local ignore_units = self._setup.ignore_units
	local slotmask = self._bullet_slotmask

	local cone_distance = max_dist or self:weapon_range() or 20000
	local tmp_vec_to = Vector3()
	mvector3.set(tmp_vec_to, mvector3.copy(direction))
	mvector3.multiply(tmp_vec_to, cone_distance)
	mvector3.add(tmp_vec_to, mvector3.copy(from_pos))

	local cone_radius = mvector3.distance(mvector3.copy(from_pos), mvector3.copy(tmp_vec_to)) / 4
	local enemies_in_cone = self._unit:find_units("cone", from_pos, tmp_vec_to, cone_radius, managers.slot:get_mask("player_autoaim"))
	local ignore_rng = nil
	
	for _, enemy in pairs(enemies_in_cone) do
		local com = enemy:movement():m_head_pos()

		mvec3_set(tar_vec, com)
		mvec3_sub(tar_vec, from_pos)

		local tar_aim_dot = mvec3_dot(direction, tar_vec)

		if tar_aim_dot > 0 and (not max_dist or tar_aim_dot < max_dist) then
			local tar_vec_len = math_clamp(mvec3_norm(tar_vec), 1, far_dis)
			local error_dot = mvec3_dot(direction, tar_vec)
			local error_angle = math.acos(error_dot)
			local dis_lerp = math.pow(tar_aim_dot / far_dis, 0.25)
			local autohit_min_angle = math.max(autohit_constant_angle, math_lerp(autohit_near_angle, autohit_far_angle, dis_lerp))

			if error_angle <= autohit_min_angle then
				if error_angle <= autohit_constant_angle then
					ignore_rng = true
				end
				
				local percent_error = error_angle / autohit_min_angle

				if not closest_error or percent_error < closest_error then
					ignore_rng = true
					tar_vec_len = tar_vec_len + 100

					mvec3_mul(tar_vec, tar_vec_len)
					mvec3_add(tar_vec, from_pos)

					local hit_enemy = false
					local enemy_mask = managers.slot:get_mask("player_autoaim")
					local wall_mask = managers.slot:get_mask("world_geometry", "vehicles")
					local shield_mask = managers.slot:get_mask("enemy_shield_check")
					local ai_vision_ids = Idstring("ai_vision")
					local bulletproof_ids = Idstring("bulletproof")

					local vis_ray = World:raycast_all("ray", from_pos, tar_vec, "slot_mask", slotmask, "ignore_unit", ignore_units)
					local units_hit = {}
					local unique_hits = {}

					for i, hit in ipairs(vis_ray) do
						if not units_hit[hit.unit:key()] then
							units_hit[hit.unit:key()] = true
							unique_hits[#unique_hits + 1] = hit
							hit.hit_position = hit.position
							hit_enemy = hit_enemy or hit.unit:in_slot(enemy_mask)
							local weak_body = hit.body:has_ray_type(ai_vision_ids)
							weak_body = weak_body or hit.body:has_ray_type(bulletproof_ids)

							if hit_enemy then
								break
							elseif hit.unit:in_slot(wall_mask) then
								if weak_body then
									break
								end
							elseif not self._can_shoot_through_shield and hit.unit:in_slot(shield_mask) then
								break
							end
						end
					end

					for _, vis_ray in ipairs(unique_hits) do
						if vis_ray and vis_ray.unit:key() == enemy:key() and (not closest_error or error_angle < closest_error) then
							closest_error = error_angle
							closest_ray = vis_ray

							mvec3_set(tmp_vec1, com)
							mvec3_sub(tmp_vec1, from_pos)

							local d = mvec3_dot(direction, tmp_vec1)

							mvec3_set(tmp_vec1, direction)
							mvec3_mul(tmp_vec1, d)
							mvec3_add(tmp_vec1, from_pos)
							mvec3_sub(tmp_vec1, com)

							closest_ray.distance_to_aim_line = mvec3_len(tmp_vec1)

							break
						end
					end
				end
			end
		end
	end

	return closest_ray, ignore_rng, enemies_in_cone
end

function RaycastWeaponBase:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul)
	if self:gadget_overrides_weapon_functions() then
		return self:gadget_function_override("_fire_raycast", self, user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul)
	end

	local result = {}
	local spread_x, spread_y = self:_get_spread(user_unit)
	local ray_distance = self:weapon_range()
	local right = direction:cross(Vector3(0, 0, 1)):normalized()
	local up = direction:cross(right):normalized()
	local r = math.random()
	local theta = math.random() * 360
	local ax = math.tan(r * spread_x * (spread_mul or 1)) * math.cos(theta)
	local ay = math.tan(r * spread_y * (spread_mul or 1)) * math.sin(theta) * -1

	mvector3.set(mvec_spread_direction, direction)
	mvector3.add(mvec_spread_direction, right * ax)
	mvector3.add(mvec_spread_direction, up * ay)
	mvector3.set(mvec_to, mvec_spread_direction)
	mvector3.multiply(mvec_to, ray_distance)
	mvector3.add(mvec_to, from_pos)

	local damage = self:_get_current_damage(dmg_mul)
	local ray_hits, hit_enemy = self:_collect_hits(from_pos, mvec_to)
	local hit_anyone = false

	if self._autoaim then
		local weight = 0.1
		
		local auto_hit_candidate, ignore_rng = not hit_enemy and self:check_autoaim(from_pos, direction, nil, nil, nil, spread_mul)
		
		--log(tostring(self._autohit_current))
		
		if auto_hit_candidate then
			self._autohit_current = math.clamp(self._autohit_current, self._autohit_data.MIN_RATIO, self._autohit_data.MAX_RATIO)
			local autohit_chance = self._autohit_current
			
			if autohit_mul then
				autohit_chance = autohit_chance * autohit_mul
			end

			if math.random() < autohit_chance or ignore_rng then
				self._autohit_current = self._autohit_data.MIN_RATIO

				mvector3.set(mvec_to, from_pos)
				mvector3.add_scaled(mvec_to, auto_hit_candidate.ray, ray_distance)

				ray_hits, hit_enemy = self:_collect_hits(from_pos, mvec_to)
				mvector3.set(mvec_spread_direction, mvec_to)
			else
				local lerp = math.clamp(autohit_chance / self._autohit_data.MAX_RATIO, 0, 0.8)
				mvector3.lerp(mvec_spread_direction, mvec_spread_direction, auto_hit_candidate.ray, autohit_chance)
				mvector3.set(mvec_to, mvec_spread_direction)
				mvector3.multiply(mvec_to, ray_distance)
				mvector3.add(mvec_to, from_pos)
				
				ray_hits, hit_enemy = self:_collect_hits(from_pos, mvec_to)
			end
		end

		if hit_enemy then 
			local lerp = weight / (1 + weight)
			local add = math.lerp(self._autohit_data.MIN_RATIO, self._autohit_data.MAX_RATIO, lerp)
			self._autohit_current = self._autohit_current - add
		elseif auto_hit_candidate then
			local lerp = weight / (1 + weight)
			local add = math.lerp(self._autohit_data.MIN_RATIO, self._autohit_data.MAX_RATIO, lerp)
			self._autohit_current = self._autohit_current + add
		else
			self._autohit_current = self._autohit_data.MIN_RATIO
		end
	end

	local hit_count = 0
	local cop_kill_count = 0
	local hit_through_wall = false
	local hit_through_shield = false
	local hit_result = nil

	for _, hit in ipairs(ray_hits) do
		damage = self:get_damage_falloff(damage, hit, user_unit)
		hit_result = self._bullet_class:on_collision(hit, self._unit, user_unit, damage)

		if hit_result and hit_result.type == "death" then
			local unit_type = hit.unit:base() and hit.unit:base()._tweak_table
			local is_civilian = unit_type and CopDamage.is_civilian(unit_type)

			if not is_civilian then
				cop_kill_count = cop_kill_count + 1
			end

			if self:is_category(tweak_data.achievement.easy_as_breathing.weapon_type) and not is_civilian then
				self._kills_without_releasing_trigger = (self._kills_without_releasing_trigger or 0) + 1

				if tweak_data.achievement.easy_as_breathing.count <= self._kills_without_releasing_trigger then
					managers.achievment:award(tweak_data.achievement.easy_as_breathing.award)
				end
			end
		end

		if hit_result then
			hit.damage_result = hit_result
			hit_anyone = true
			hit_count = hit_count + 1
		end

		if hit.unit:in_slot(managers.slot:get_mask("world_geometry")) then
			hit_through_wall = true
		elseif hit.unit:in_slot(managers.slot:get_mask("enemy_shield_check")) then
			hit_through_shield = hit_through_shield or alive(hit.unit:parent())
		end

		if hit_result and hit_result.type == "death" and cop_kill_count > 0 then
			local unit_type = hit.unit:base() and hit.unit:base()._tweak_table
			local multi_kill, enemy_pass, obstacle_pass, weapon_pass, weapons_pass, weapon_type_pass = nil

			for achievement, achievement_data in pairs(tweak_data.achievement.sniper_kill_achievements) do
				multi_kill = not achievement_data.multi_kill or cop_kill_count == achievement_data.multi_kill
				enemy_pass = not achievement_data.enemy or unit_type == achievement_data.enemy
				obstacle_pass = not achievement_data.obstacle or achievement_data.obstacle == "wall" and hit_through_wall or achievement_data.obstacle == "shield" and hit_through_shield
				weapon_pass = not achievement_data.weapon or self._name_id == achievement_data.weapon
				weapons_pass = not achievement_data.weapons or table.contains(achievement_data.weapons, self._name_id)
				weapon_type_pass = not achievement_data.weapon_type or self:is_category(achievement_data.weapon_type)

				if multi_kill and enemy_pass and obstacle_pass and weapon_pass and weapons_pass and weapon_type_pass then
					if achievement_data.stat then
						managers.achievment:award_progress(achievement_data.stat)
					elseif achievement_data.award then
						managers.achievment:award(achievement_data.award)
					elseif achievement_data.challenge_stat then
						managers.challenge:award_progress(achievement_data.challenge_stat)
					elseif achievement_data.trophy_stat then
						managers.custom_safehouse:award(achievement_data.trophy_stat)
					elseif achievement_data.challenge_award then
						managers.challenge:award(achievement_data.challenge_award)
					end
				end
			end
		end
	end

	if not tweak_data.achievement.tango_4.difficulty or table.contains(tweak_data.achievement.tango_4.difficulty, Global.game_settings.difficulty) then
		if self._gadgets and table.contains(self._gadgets, "wpn_fps_upg_o_45rds") and cop_kill_count > 0 and managers.player:player_unit():movement():current_state():in_steelsight() then
			if self._tango_4_data then
				if self._gadget_on == self._tango_4_data.last_gadget_state then
					self._tango_4_data = nil
				else
					self._tango_4_data.last_gadget_state = self._gadget_on
					self._tango_4_data.count = self._tango_4_data.count + 1
				end

				if self._tango_4_data and tweak_data.achievement.tango_4.count <= self._tango_4_data.count then
					managers.achievment:_award_achievement(tweak_data.achievement.tango_4, "tango_4")
				end
			else
				self._tango_4_data = {
					count = 1,
					last_gadget_state = self._gadget_on
				}
			end
		elseif self._tango_4_data then
			self._tango_4_data = nil
		end
	end

	result.hit_enemy = hit_anyone

	if self._autoaim then
		self._shot_fired_stats_table.hit = hit_anyone
		self._shot_fired_stats_table.hit_count = hit_count

		if (not self._ammo_data or not self._ammo_data.ignore_statistic) and not self._rays then
			managers.statistics:shot_fired(self._shot_fired_stats_table)
		end
	end

	local furthest_hit = ray_hits[#ray_hits]

	if (furthest_hit and furthest_hit.distance > 600 or not furthest_hit) and alive(self._obj_fire) then
		local trail_direction = furthest_hit and furthest_hit.ray or mvec_spread_direction

		self._obj_fire:m_position(self._trail_effect_table.position)
		mvector3.set(self._trail_effect_table.normal, trail_direction)

		local trail = World:effect_manager():spawn(self._trail_effect_table)

		if furthest_hit then
			World:effect_manager():set_remaining_lifetime(trail, math.clamp((furthest_hit.distance - 600) / 10000, 0, furthest_hit.distance))
		else
			World:effect_manager():set_remaining_lifetime(trail, math.clamp((ray_distance - 600) / 10000, 0, ray_distance))
		end
	end

	if self._alert_events then
		result.rays = ray_hits
	end

	if self._suppression then
		self:_suppress_units(mvector3.copy(from_pos), mvector3.copy(direction), ray_distance, managers.slot:get_mask("enemies"), user_unit, suppr_mul)
	end

	return result
end

end

function RaycastWeaponBase:damage_player(col_ray, from_pos, direction, params)
	local player_man = managers.player
	local unit = player_man:player_unit()

	if not unit then
		return
	end

	local ray_data = {
		ray = direction,
		normal = -direction
	}
	local head_pos = unit:movement():m_head_pos()
	local head_dir = tmp_vec1
	local head_dis = mvec3_dir(head_dir, from_pos, head_pos)
	local shoot_dir = tmp_vec2

	mvec3_set(shoot_dir, col_ray and col_ray.ray or direction)

	local cos_f = mvec3_dot(shoot_dir, head_dir)

	if not col_ray then
		local max_range = self._weapon_range or self._range or 20000

		if head_dis > max_range then
			return
		end
	end

	if cos_f <= 0.1 then
		return
	end

	local b = head_dis / cos_f

	if not col_ray or b < col_ray.distance then
		if col_ray and b - col_ray.distance < 60 then
			unit:character_damage():build_suppression(self._suppression)
			player_man:add_style("dodge")
		end

		mvec3_set_l(shoot_dir, b)
		mvec3_mul(head_dir, head_dis)
		mvec3_sub(shoot_dir, head_dir)

		local proj_len = mvec3_len(shoot_dir)
		ray_data.position = head_pos + shoot_dir

		if not col_ray and proj_len < 60 then
			unit:character_damage():build_suppression(self._suppression)
			player_man:add_style("dodge")
		end

		if proj_len < 30 and (not params or not params.guaranteed_miss) then
			if World:raycast("ray", from_pos, head_pos, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units, "report") then
				return nil, ray_data
			else
				return true, ray_data
			end
		elseif proj_len < 100 and b > 500 then
			unit:character_damage():play_whizby(ray_data.position)
		end
	elseif b - col_ray.distance < 60 then
		unit:character_damage():build_suppression(self._suppression)
	end

	return nil, ray_data
end

--Fix for duplicated bullets below, thank you Hoxi <3
function InstantBulletBase:on_collision(col_ray, weapon_unit, user_unit, damage, blank, no_sound)
	if Network:is_client() and not blank and user_unit ~= managers.player:player_unit() then
		blank = true
	end

	local hit_unit = col_ray.unit
	local shield_knock = false
	local is_shield = hit_unit:in_slot(managers.slot:get_mask("enemy_shield_check")) and alive(hit_unit:parent())

	if alive(weapon_unit) and is_shield and weapon_unit:base()._shield_knock then
		local enemy_unit = hit_unit:parent()

		--it never hurts to add these checks 
		if enemy_unit:character_damage() and enemy_unit:character_damage().dead and not enemy_unit:character_damage():dead() then
			if enemy_unit:base():char_tweak() then
				if not enemy_unit:base():char_tweak().immune_to_ranged_knock_back and enemy_unit:base():char_tweak().damage.shield_knocked and not enemy_unit:character_damage():is_immune_to_shield_knockback() then
					local MIN_KNOCK_BACK = 200
					local KNOCK_BACK_CHANCE = 0.8
					local dmg_ratio = math.min(damage, MIN_KNOCK_BACK)
					dmg_ratio = dmg_ratio / MIN_KNOCK_BACK + 1

					local rand = math.random() * dmg_ratio

					if KNOCK_BACK_CHANCE < rand then
						local damage_info = {
							damage = 0,
							type = "shield_knock",
							variant = "melee",
							col_ray = col_ray,
							result = {
								variant = "melee",
								type = "shield_knock"
							}
						}

						enemy_unit:character_damage():_call_listeners(damage_info)
					end
				end
			end
		end
	end

	local play_impact_flesh = not hit_unit:character_damage() or not hit_unit:character_damage()._no_blood

	if hit_unit:damage() and managers.network:session() and col_ray.body:extension() and col_ray.body:extension().damage then
		local damage_body_extension = true
		local character_unit = nil

		if hit_unit:character_damage() then
			character_unit = hit_unit
		elseif is_shield and hit_unit:parent():character_damage() then
			character_unit = hit_unit:parent()
		end

		if character_unit and character_unit:character_damage().is_friendly_fire and character_unit:character_damage():is_friendly_fire(user_unit) then
			damage_body_extension = false
		end

		--do a friendly fire check if the unit hit is a character or a character's shield before damaging the body extension that was hit
		if damage_body_extension then
			local sync_damage = not blank and hit_unit:id() ~= -1
			local network_damage = math.ceil(damage * 163.84)
			damage = network_damage / 163.84

			if sync_damage then
				local normal_vec_yaw, normal_vec_pitch = self._get_vector_sync_yaw_pitch(col_ray.normal, 128, 64)
				local dir_vec_yaw, dir_vec_pitch = self._get_vector_sync_yaw_pitch(col_ray.ray, 128, 64)

				managers.network:session():send_to_peers_synched("sync_body_damage_bullet", col_ray.unit:id() ~= -1 and col_ray.body or nil, user_unit:id() ~= -1 and user_unit or nil, normal_vec_yaw, normal_vec_pitch, col_ray.position, dir_vec_yaw, dir_vec_pitch, math.min(16384, network_damage))
			end

			local local_damage = not blank or hit_unit:id() == -1

			if local_damage then
				col_ray.body:extension().damage:damage_bullet(user_unit, col_ray.normal, col_ray.position, col_ray.ray, 1)
				col_ray.body:extension().damage:damage_damage(user_unit, col_ray.normal, col_ray.position, col_ray.ray, damage)

				if alive(weapon_unit) and weapon_unit:base().categories and weapon_unit:base():categories() then
					for _, category in ipairs(weapon_unit:base():categories()) do
						col_ray.body:extension().damage:damage_bullet_type(category, user_unit, col_ray.normal, col_ray.position, col_ray.ray, 1)
					end
				end
			end
		end
	end

	local result = nil
	
	local damage_lerp = math.clamp(damage, 2.4, 40) / 40
	local push_multiplier = math.lerp(0.166, 4, damage_lerp)

	if alive(weapon_unit) and hit_unit:character_damage() and hit_unit:character_damage().damage_bullet then
		local is_alive = not hit_unit:character_damage():dead()

		if not blank then
			local knock_down = weapon_unit:base()._knock_down and weapon_unit:base()._knock_down > 0 and math.random() < weapon_unit:base()._knock_down

			result = self:give_impact_damage(col_ray, weapon_unit, user_unit, damage, weapon_unit:base()._use_armor_piercing, false, knock_down, weapon_unit:base()._stagger, weapon_unit:base()._variant)
		end

		local is_dead = hit_unit:character_damage():dead()

		if not is_dead then
			if not result or result == "friendly_fire" then
				play_impact_flesh = false
			end
		end
		
		--uncomment below for fun :)
		--if is_dead then
		--	local damage_lerp_for_pm_multipler = math.clamp(damage, 2.4, 40) / 40
		--	local push_multiplier_multiplier = math.lerp(push_multiplier, 8, damage_lerp_for_pm_multipler)
			
		--	push_multiplier = push_multiplier * push_multiplier_multiplier
		--end

		managers.game_play_central:physics_push(col_ray, push_multiplier)
	else
		managers.game_play_central:physics_push(col_ray, push_multiplier)
	end

	if play_impact_flesh then

		if self.low_prio then --*sigh*
			if math.random() < 0.1 then
				managers.game_play_central:play_impact_flesh({
					col_ray = col_ray,
					no_sound = no_sound
				})
				self:play_impact_sound_and_effects(weapon_unit, col_ray, no_sound)
			end
		else
			managers.game_play_central:play_impact_flesh({
				col_ray = col_ray,
				no_sound = no_sound
			})
			self:play_impact_sound_and_effects(weapon_unit, col_ray, no_sound)
		end
	end

	return result
end

function RaycastWeaponBase:add_ratio_plus_ammo(ammo_ratio_increase)
	local function _add_ammo(ammo_base, ammo_ratio_increase)
		if ammo_base:get_ammo_max() == ammo_base:get_ammo_total() then
			return
		end

		local ammo_max = ammo_base:get_ammo_max()
		local ammo_to_add = ammo_max * ammo_ratio_increase
		local ammo_total = ammo_base:get_ammo_total()
		ammo_total = math.ceil(ammo_total + ammo_to_add)
		ammo_total = math.clamp(ammo_total, 0, ammo_max)

		ammo_base:set_ammo_total(ammo_total)
	end

	_add_ammo(self, ammo_ratio_increase)

	for _, gadget in ipairs(self:get_all_override_weapon_gadgets()) do
		if gadget and gadget.ammo_base then
			_add_ammo(gadget:ammo_base(), ammo_ratio_increase)
		end
	end
end

if not BLT.Mods:GetModByName("WeaponLib") then

function RaycastWeaponBase:_suppress_units(from_pos, direction, distance, slotmask, user_unit, suppr_mul)
	local tmp_to = Vector3()

	mvector3.set(tmp_to, mvector3.copy(direction))
	mvector3.multiply(tmp_to, distance)
	mvector3.add(tmp_to, mvector3.copy(from_pos))

	local cone_radius = distance / 16
	
	cone_radius = cone_radius * self._suppression

	local enemies_in_cone = World:find_units(user_unit, "cone", from_pos, tmp_to, cone_radius, slotmask)
	local enemies_to_suppress = {}

	--draw the cone to see where it goes
	local draw_suppression_cone = false
	--mark valid enemies (specials can count even if they end up denying suppression anyway)
	local mark_suppressed_enemies = false

	if draw_suppression_cone and user_unit == managers.player:player_unit() then
		local draw_duration = 0.1
		local new_brush = Draw:brush(Color.white:with_alpha(0.5), draw_duration)
		new_brush:cone(from_pos, tmp_to, cone_radius)
	end

	if #enemies_in_cone > 0 then
		for i = 1, #enemies_in_cone do
			enemy = enemies_in_cone[i]
			
			if Network:is_server() or user_unit == managers.player:player_unit() or enemy == managers.player:player_unit() then --clients only allow the local player to suppress or be suppressed (so that NPC husks don't suppress each other)
				if not table_contains(enemies_to_suppress, enemy) and enemy.character_damage and enemy:character_damage() and enemy:character_damage().build_suppression then --valid enemy + has suppression function
					if not enemy:movement().cool or enemy:movement().cool and not enemy:movement():cool() then --is alerted or can't be alerted at all (player)
						if enemy:character_damage().is_friendly_fire and not enemy:character_damage():is_friendly_fire(user_unit) then --not in the same team as the shooter
							local obstructed = World:raycast("ray", from_pos, enemy:movement():m_com(), "slot_mask", managers.slot:get_mask("AI_visibility"), "ray_type", "ai_vision", "report") --imitating AI checking for visibility for things like shouting

							if not obstructed then
								table_insert(enemies_to_suppress, enemy)
							end
						end
					end
				end
			end
		end

		if #enemies_to_suppress > 0 then
			for i = 1, #enemies_to_suppress do
				enemy = enemies_in_cone[i]

				local total_suppression = self._suppression

				if suppr_mul then
					total_suppression = total_suppression * suppr_mul
				end

				if total_suppression > 0 then
					if mark_suppressed_enemies and enemy:contour() then
						enemy:contour():add("medic_heal")
					end

					enemy:character_damage():build_suppression(total_suppression, total_panic_chance)
				end
			end
		end
	end
end

function InstantBulletBase:on_collision_effects(col_ray, weapon_unit, user_unit, damage, blank, no_sound)
	local hit_unit = col_ray.unit
	local play_impact_flesh = not hit_unit:character_damage() or not hit_unit:character_damage()._no_blood
	local fullautonpc = alive(weapon_unit) and weapon_unit:base().weapon_tweak_data and weapon_unit:base():weapon_tweak_data() and weapon_unit:base():weapon_tweak_data().fullautonpc ~= nil
	
	if fullautonpc then
		if math.random() < 0.1 then
			managers.game_play_central:play_impact_flesh({
				col_ray = col_ray,
				no_sound = no_sound
			})
			self:play_impact_sound_and_effects(weapon_unit, col_ray, no_sound)
		end
	elseif play_impact_flesh then
		managers.game_play_central:play_impact_flesh({
			col_ray = col_ray,
			no_sound = no_sound
		})
		self:play_impact_sound_and_effects(weapon_unit, col_ray, no_sound)
	end
end

function RaycastWeaponBase:fire(from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)
	if managers.player:has_activate_temporary_upgrade("temporary", "no_ammo_cost_buff") then
		managers.player:deactivate_temporary_upgrade("temporary", "no_ammo_cost_buff")

		if managers.player:has_category_upgrade("temporary", "no_ammo_cost") then
			managers.player:activate_temporary_upgrade("temporary", "no_ammo_cost")
		end
	end

	if self._bullets_fired then
		--i've commented and preserved the vanilla code that caused the need for this AFSF2 update:
		--the game plays starts the firesound when firing, in addition to calling _fire_sound()
		--this causes some firesounds to play twice, while also not playing the correct fire sound.
		--so U200 both broke AutoFireSoundFix, made the existing problem worse, and then added a new problem on top of that

	--		if self._bullets_fired == 1 and self:weapon_tweak_data().sounds.fire_single then
	--			self:play_tweak_data_sound("stop_fire")
	--			self:play_tweak_data_sound("fire_auto", "fire")
	--		end

		self:play_tweak_data_sound(self:weapon_tweak_data().sounds.fire_single,"fire_single")
		
		self._bullets_fired = self._bullets_fired + 1
	end

	local is_player = self._setup.user_unit == managers.player:player_unit()
	local consume_ammo = not managers.player:has_active_temporary_property("bullet_storm") and (not managers.player:has_activate_temporary_upgrade("temporary", "berserker_damage_multiplier") or not managers.player:has_category_upgrade("player", "berserker_no_ammo_cost")) or not is_player

	if consume_ammo and (is_player or Network:is_server()) then
		local base = self:ammo_base()

		if base:get_ammo_remaining_in_clip() == 0 then
			return
		end

		local ammo_usage = 1

		if is_player then
			for _, category in ipairs(self:weapon_tweak_data().categories) do
				if managers.player:has_category_upgrade(category, "consume_no_ammo_chance") then
					local roll = math.rand(1)
					local chance = managers.player:upgrade_value(category, "consume_no_ammo_chance", 0)

					if roll < chance then
						ammo_usage = 0

						print("NO AMMO COST")
					end
				end
			end
		end

		local mag = base:get_ammo_remaining_in_clip()
		local remaining_ammo = mag - ammo_usage

		if mag > 0 and remaining_ammo <= (self.AKIMBO and 1 or 0) then
			local w_td = self:weapon_tweak_data()

			if w_td.animations and w_td.animations.magazine_empty then
				self:tweak_data_anim_play("magazine_empty")
			end

			if w_td.sounds and w_td.sounds.magazine_empty then
				self:play_tweak_data_sound("magazine_empty")
			end

			if w_td.effects and w_td.effects.magazine_empty then
				self:_spawn_tweak_data_effect("magazine_empty")
			end

			self:set_magazine_empty(true)
		end

		base:set_ammo_remaining_in_clip(base:get_ammo_remaining_in_clip() - ammo_usage)
		self:use_ammo(base, ammo_usage)
	end

	local user_unit = self._setup.user_unit

	self:_check_ammo_total(user_unit)

	if alive(self._obj_fire) then
		self:_spawn_muzzle_effect(from_pos, direction)
	end

	self:_spawn_shell_eject_effect()

	local ray_res = self:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)

	if self._alert_events and ray_res.rays then
		self:_check_alert(ray_res.rays, from_pos, direction, user_unit)
	end

	managers.player:send_message(Message.OnWeaponFired, nil, self._unit, ray_res)

	return ray_res
end

end

function FlameBulletBase:bullet_slotmask()
	return managers.slot:get_mask("bullet_impact_targets")
end

function FlameBulletBase:on_collision(col_ray, weapon_unit, user_unit, damage, blank, use_damage_mul)
	local hit_unit = col_ray.unit
	local play_impact_flesh = false

	if hit_unit:damage() and col_ray.body:extension() and col_ray.body:extension().damage then
		local sync_damage = not blank and hit_unit:id() ~= -1
		local network_damage = math.ceil(damage * 163.84)
		damage = network_damage / 163.84

		if sync_damage then
			local normal_vec_yaw, normal_vec_pitch = self._get_vector_sync_yaw_pitch(col_ray.normal, 128, 64)
			local dir_vec_yaw, dir_vec_pitch = self._get_vector_sync_yaw_pitch(col_ray.ray, 128, 64)

			managers.network:session():send_to_peers_synched("sync_body_damage_bullet", col_ray.unit:id() ~= -1 and col_ray.body or nil, user_unit:id() ~= -1 and user_unit or nil, normal_vec_yaw, normal_vec_pitch, col_ray.position, dir_vec_yaw, dir_vec_pitch, math.min(16384, network_damage))
		end

		local local_damage = not blank or hit_unit:id() == -1

		if local_damage then
			col_ray.body:extension().damage:damage_bullet(user_unit, col_ray.normal, col_ray.position, col_ray.ray, 1)
			col_ray.body:extension().damage:damage_damage(user_unit, col_ray.normal, col_ray.position, col_ray.ray, damage)

			if alive(weapon_unit) and weapon_unit:base().categories and weapon_unit:base():categories() then
				for _, category in ipairs(weapon_unit:base():categories()) do
					col_ray.body:extension().damage:damage_bullet_type(category, user_unit, col_ray.normal, col_ray.position, col_ray.ray, 1)
				end
			end
		end
	end

	local result = nil

	if hit_unit:character_damage() and hit_unit:character_damage().damage_fire then
		local is_alive = not hit_unit:character_damage():dead()
		result = self:give_fire_damage(col_ray, weapon_unit, user_unit, damage, nil, use_damage_mul)

		if result ~= "friendly_fire" then
			local is_dead = hit_unit:character_damage():dead()

			if weapon_unit:base()._ammo_data and weapon_unit:base()._ammo_data.push_units then
				local push_multiplier = self:_get_character_push_multiplier(weapon_unit, is_alive and is_dead)

				managers.game_play_central:physics_push(col_ray, push_multiplier)
			end
		else
			play_impact_flesh = false
		end
	elseif weapon_unit:base()._ammo_data and weapon_unit:base()._ammo_data.push_units then
		managers.game_play_central:physics_push(col_ray)
	end

	if play_impact_flesh then
		managers.game_play_central:play_impact_flesh({
			no_sound = true,
			col_ray = col_ray
		})
	end

	self:play_impact_sound_and_effects(weapon_unit, col_ray)

	return result
end

function FlameBulletBase:give_fire_damage(col_ray, weapon_unit, user_unit, damage, armor_piercing, use_damage_mul)
	local fire_dot_data = nil

	if weapon_unit.base and weapon_unit:base()._ammo_data and weapon_unit:base()._ammo_data.bullet_class == "FlameBulletBase" then
		fire_dot_data = weapon_unit:base()._ammo_data.fire_dot_data
	elseif weapon_unit.base and weapon_unit:base()._name_id then
		local weapon_name_id = weapon_unit:base()._name_id

		if tweak_data.weapon[weapon_name_id] and tweak_data.weapon[weapon_name_id].fire_dot_data then
			fire_dot_data = tweak_data.weapon[weapon_name_id].fire_dot_data
		end
	end

	local action_data = {
		variant = "fire",
		damage = damage,
		weapon_unit = weapon_unit,
		attacker_unit = user_unit,
		use_damage_mul = use_damage_mul,
		col_ray = col_ray,
		armor_piercing = armor_piercing,
		fire_dot_data = fire_dot_data
	}
	local defense_data = col_ray.unit:character_damage():damage_fire(action_data)

	return defense_data
end

local mvec_from_pos = Vector3()

function RaycastWeaponBase:_check_alert(rays, fire_pos, direction, user_unit)
	local group_ai = managers.groupai:state()
	
	if self._stealth_alert and not group_ai:whisper_mode() then --after the game goes loud, set the alert to be AT LEAST 20m wide
		self._alert_size = 2000
		self._stealth_alert = nil
	end
	
	local t = TimerManager:game():time()
	local exp_t = t + 1.5
	local mvec3_dis = mvec3_dis_sq
	local all_alerts = self._alert_events
	local alert_rad = self._alert_size / 4
	local from_pos = mvec_from_pos
	local tolerance = 250000

	mvector3.set(from_pos, direction)
	mvector3.multiply(from_pos, -alert_rad)
	mvector3.add(from_pos, fire_pos)

	for i = #all_alerts, 1, -1 do
		if all_alerts[i][3] < t then
			table.remove(all_alerts, i)
		end
	end

	if #rays > 0 then
		for _, ray in ipairs(rays) do
			local event_pos = ray.position

			for i = #all_alerts, 1, -1 do
				if mvec3_dis(all_alerts[i][1], event_pos) < tolerance and mvec3_dis(all_alerts[i][2], from_pos) < tolerance then
					event_pos = nil

					break
				end
			end

			if event_pos then
				table.insert(all_alerts, {
					event_pos,
					from_pos,
					exp_t
				})

				local new_alert = {
					"bullet",
					event_pos,
					alert_rad,
					self._setup.alert_filter,
					user_unit,
					from_pos
				}

				group_ai:propagate_alert(new_alert)
			end
		end
	end

	local fire_alerts = self._alert_fires
	local cached = false

	for i = #fire_alerts, 1, -1 do
		if fire_alerts[i][2] < t then
			table.remove(fire_alerts, i)
		elseif mvec3_dis(fire_alerts[i][1], fire_pos) < tolerance then
			cached = true

			break
		end
	end

	if not cached then
		table.insert(fire_alerts, {
			fire_pos,
			exp_t
		})

		local new_alert = {
			"bullet",
			fire_pos,
			self._alert_size,
			self._setup.alert_filter,
			user_unit,
			from_pos
		}

		group_ai:propagate_alert(new_alert)
	end
end

function RaycastWeaponBase:get_aim_assist(from_pos, direction, max_dist, use_aim_assist)
	local autohit = use_aim_assist and self._aim_assist_data or self._autohit_data
	local autohit_near_angle = autohit.near_angle
	local autohit_far_angle = autohit.far_angle
	local far_dis = autohit.far_dis
	local far_dis_sq = far_dis * far_dis
	local closest_error, closest_ray = nil
	local tar_vec = tmp_vec1
	local tar_vec2 = tmp_vec2
	local ignore_units = self._setup.ignore_units
	local slotmask = self._bullet_slotmask
	local enemies = managers.enemy:all_enemies()

	for u_key, enemy_data in pairs_g(enemies) do
		local enemy = enemy_data.unit
		local vis_state = enemy:base():lod_stage()
		local enemy_head_pos = enemy:movement():m_head_pos()
		
		if vis_state and mvec3_dis_sq(from_pos, enemy_head_pos) < far_dis_sq and not enemy:in_slot(16) then
			local com = enemy:movement():m_com()

			mvec3_set(tar_vec, com)
			mvec3_sub(tar_vec, from_pos)

			local tar_aim_dot = mvec3_dot(direction, tar_vec)
			local tar_vec_len = math_clamp(mvec3_norm(tar_vec), 1, far_dis)

			if tar_aim_dot > 0 then
				if not max_dist or tar_aim_dot < max_dist then
					local error_dot = mvec3_dot(direction, tar_vec)
					local error_angle = math_acos(error_dot)
					local dis_lerp = math_pow(tar_aim_dot / far_dis, 0.25)
					local autohit_min_angle = math_lerp(autohit_near_angle, autohit_far_angle, dis_lerp)

					if error_angle < autohit_min_angle then
						local percent_error = error_angle / autohit_min_angle

						if not closest_error or percent_error < closest_error then
							tar_vec_len = tar_vec_len + 100

							mvec3_mul(tar_vec, tar_vec_len)
							mvec3_add(tar_vec, from_pos)

							local vis_ray = World:raycast("ray", from_pos, tar_vec, "slot_mask", slotmask, "ignore_unit", ignore_units)

							if vis_ray and vis_ray.unit:key() == u_key then
								if not closest_error or error_angle < closest_error then
									closest_error = error_angle
									closest_ray = vis_ray

									mvec3_set(tmp_vec1, com)
									mvec3_sub(tmp_vec1, from_pos)

									local d = mvec3_dot(direction, tmp_vec1)

									mvec3_set(tmp_vec1, direction)
									mvec3_mul(tmp_vec1, d)
									mvec3_add(tmp_vec1, from_pos)
									mvec3_sub(tmp_vec1, com)

									closest_ray.distance_to_aim_line = mvec3_len(tmp_vec1)
								end
							end
						end
					end
				end
			end
			
			mvec3_set(tar_vec2, enemy_head_pos)
			mvec3_sub(tar_vec2, from_pos)

			local tar_aim_dot = mvec3_dot(direction, tar_vec2)
			local tar_vec_len = math_clamp(mvec3_norm(tar_vec2), 1, far_dis)

			if tar_aim_dot > 0 then
				if not max_dist or tar_aim_dot < max_dist then
					local error_dot = mvec3_dot(direction, tar_vec2)
					local error_angle = math_acos(error_dot)
					local dis_lerp = math_pow(tar_aim_dot / far_dis, 0.25)
					local autohit_min_angle = math_lerp(autohit_near_angle, autohit_far_angle, dis_lerp)

					if error_angle < autohit_min_angle then
						local percent_error = error_angle / autohit_min_angle

						if not closest_error or percent_error < closest_error then
							tar_vec_len = tar_vec_len + 100

							mvec3_mul(tar_vec2, tar_vec_len)
							mvec3_add(tar_vec2, from_pos)

							local vis_ray = World:raycast("ray", from_pos, tar_vec2, "slot_mask", slotmask, "ignore_unit", ignore_units)

							if vis_ray and vis_ray.unit:key() == u_key then
								if not closest_error or error_angle < closest_error then
									closest_error = error_angle
									closest_ray = vis_ray

									mvec3_set(tmp_vec1, enemy_head_pos)
									mvec3_sub(tmp_vec1, from_pos)

									local d = mvec3_dot(direction, tmp_vec1)

									mvec3_set(tmp_vec1, direction)
									mvec3_mul(tmp_vec1, d)
									mvec3_add(tmp_vec1, from_pos)
									mvec3_sub(tmp_vec1, enemy_head_pos)

									closest_ray.distance_to_aim_line = mvec3_len(tmp_vec1)
								end
							end
						end
					end
				end
			end
		end
	end

	return closest_ray
end

function RaycastWeaponBase:on_bull_event(aced)
	if self:ammo_full() then
		return
	end
	
	local is_player = self._setup.user_unit == managers.player:player_unit()
	local consume_ammo = not managers.player:has_active_temporary_property("bullet_storm") and (not managers.player:has_activate_temporary_upgrade("temporary", "berserker_damage_multiplier") or not managers.player:has_category_upgrade("player", "berserker_no_ammo_cost")) or not is_player
	
	if consume_ammo then
		if is_player or Network:is_server() then
			local ammo_base = self._reload_ammo_base or self:ammo_base()
			local ammo_total = ammo_base:get_ammo_total()
			local max_ammo_in_clip = ammo_base:get_ammo_max_per_clip()
			local ammo_in_clip = ammo_base:get_ammo_remaining_in_clip()
			local amount = ammo_in_clip + math.ceil(max_ammo_in_clip * 0.1)
			
			if aced then	
				amount = amount + 1
			end

			if self._setup.expend_ammo then
				ammo_base:set_ammo_remaining_in_clip(math.min(math.min(ammo_total, max_ammo_in_clip), amount))
			end
		end
	end
end

if not BLT.Mods:GetModByName("WeaponLib") then

--Original mod by 90e, uploaded by DarKobalt.
--Reverb fixed by Doctor Mister Cool, aka Didn'tMeltCables, aka DinoMegaCool
--New version uploaded and maintained by Offyerrocker.
--At this point all of my previous code is bad and obsolete yay

--This blacklist defines which weapons are prevented from playing their single-fire sound in AFSF.
	--Weapons not on this list will repeatedly play their single-fire sound rather than their auto-fire loop.
	--Weapons on this list will play their sound as normal
	-- either due to being an unconventional weapon (saw, flamethrower, other saw, other flamethrower), or lacking a singlefire sound (minigun, mg42, other minigun).
--I could define this in the function but meh	
	

--Check for manual blacklist.
--If check passed, check for if the weapon has a singlefire sound to play
--This is both for future-proofing and for custom weapon support, I think. I'm actually not sure which part of AFSF fixes custom weapon sounds otherwise
--Check for if AFSF's fix code should apply to this particular weapon
function RaycastWeaponBase:_soundfix_should_play_normal()
	local name_id = self:get_name_id() or "xX69dank420blazermachineXx" --if somehow get_name_id() returns nil, crashing won't be my fault. though i guess you'll have bigger problems in that case. also you'll look dank af B)
	if not self._setup.user_unit == managers.player:player_unit() then
		--don't apply fix for NPCs or other players
		return true
	elseif tweak_data.weapon[name_id].use_fix == true then 
		--for custom weapons
		return false
	elseif afsf_blacklist[name_id] then
		--blacklisted sound
		return true
	elseif not tweak_data.weapon[name_id].sounds.fire_single then
		--no singlefire sound; should play normal
		return true
	end
	return false
	--else, AFSF2 can apply fix to this weapon
end


--Prevent playing sounds except for blacklisted weapons
local orig_fire_sound = RaycastWeaponBase._fire_sound
function RaycastWeaponBase:_fire_sound(...)
	if self:_soundfix_should_play_normal() then
		orig_fire_sound(self,...)
	end
end

--Play sounds here instead for fix-applicable weapons; or else if blacklisted, use original function and don't play the fixed fire sound

--stop_shooting is only used for fire sound loops, so playing individual single-fire sounds means it doesn't need to be called
local orig_stop_shooting = RaycastWeaponBase.stop_shooting
function RaycastWeaponBase:stop_shooting(...)
	if self:_soundfix_should_play_normal() then
		orig_stop_shooting(self,...)
	end
end


end

--previous conditions:
	--1.lacking a singlefire sound
	--2.currently in gadget override such as underbarrel mode
	--3.minigun and mg42 will have a silent fire sound if not blacklisted
	--4. is NPC. Not sure why this started crashing now though, since that was fixed in v1 of AFSF2

function RaycastWeaponBase:_get_anim_start_offset(anim)
	return false
end