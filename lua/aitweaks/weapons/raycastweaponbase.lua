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

function RaycastWeaponBase:calculate_ammo_max_per_clip()
	local ammo = tweak_data.weapon[self._name_id].CLIP_AMMO_MAX
	
	if self:weapon_tweak_data().ignore_player_skills then
		return ammo
	end
	
	ammo = ammo + managers.player:upgrade_value(self._name_id, "clip_ammo_increase")

	if not self:upgrade_blocked("weapon", "clip_ammo_increase") then
		ammo = ammo + managers.player:upgrade_value("weapon", "clip_ammo_increase", 0)
	end

	for _, category in ipairs(tweak_data.weapon[self._name_id].categories) do
		if not self:upgrade_blocked(category, "clip_ammo_increase") then
			ammo = ammo + managers.player:upgrade_value(category, "clip_ammo_increase", 0)
		end
	end

	ammo = ammo + (self._extra_ammo or 0)

	return ammo
end

function RaycastWeaponBase:replenish()
	local ammo_max_per_clip = self:calculate_ammo_max_per_clip()
	local ammo_max
	
	if self:weapon_tweak_data().ignore_player_skills then
		ammo_max_multiplier = 1
		ammo_max = tweak_data.weapon[self._name_id].AMMO_MAX
	else
		local ammo_max_multiplier = managers.player:upgrade_value("player", "extra_ammo_multiplier", 1)

		for _, category in ipairs(self:weapon_tweak_data().categories) do
			ammo_max_multiplier = ammo_max_multiplier + managers.player:upgrade_value(category, "extra_ammo_multiplier", 1)
		end

		ammo_max_multiplier = ammo_max_multiplier + ammo_max_multiplier * (self._total_ammo_mod or 0)

		if managers.player:has_category_upgrade("player", "add_armor_stat_skill_ammo_mul") then
			ammo_max_multiplier = ammo_max_multiplier * managers.player:body_armor_value("skill_ammo_mul", nil, 1)
		end
			
		ammo_max_multiplier = managers.modifiers:modify_value("WeaponBase:GetMaxAmmoMultiplier", ammo_max_multiplier)
		
		ammo_max = math.round((tweak_data.weapon[self._name_id].AMMO_MAX + managers.player:upgrade_value(self._name_id, "clip_amount_increase") * ammo_max_per_clip) * ammo_max_multiplier)
	end

	ammo_max_per_clip = math.min(ammo_max_per_clip, ammo_max)

	self:set_ammo_max_per_clip(ammo_max_per_clip)
	self:set_ammo_max(ammo_max)
	self:set_ammo_total(ammo_max)
	self:set_ammo_remaining_in_clip(ammo_max_per_clip)


	self._ammo_pickup = tweak_data.weapon[self._name_id].AMMO_PICKUP

	self:update_damage()
end

function RaycastWeaponBase:_get_anim_start_offset(anim)
	return false
end

local mvec3_set = mvector3.set
local mvec3_cpy = mvector3.copy
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
local mvec3_len_sq = mvector3.length_sq
local math_clamp = math.clamp
local math_lerp = math.lerp
local math_acos = math.acos
local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()
local tmp_rot1 = Rotation()

function RaycastWeaponBase:add_ammo(ratio, add_amount_override)
	local function _add_ammo(ammo_base, ratio, add_amount_override)
		if ammo_base:get_ammo_max() == ammo_base:get_ammo_total() then
			return false, 0
		end

		local multiplier_min = 1
		local multiplier_max = 1

		if ammo_base._ammo_data and ammo_base._ammo_data.ammo_pickup_min_mul then
			multiplier_min = ammo_base._ammo_data.ammo_pickup_min_mul
		end
		
		multiplier_min = multiplier_min * managers.player:upgrade_value("player", "pick_up_ammo_multiplier", 1)
		multiplier_min = multiplier_min + managers.player:upgrade_value("player", "pick_up_ammo_multiplier_2", 1) - 1
		multiplier_min = multiplier_min + managers.player:crew_ability_upgrade_value("crew_scavenge", 0)

		if ammo_base._ammo_data and ammo_base._ammo_data.ammo_pickup_max_mul then
			multiplier_max = ammo_base._ammo_data.ammo_pickup_max_mul
		end
		
		multiplier_max = multiplier_max * managers.player:upgrade_value("player", "pick_up_ammo_multiplier", 1)
		multiplier_max = multiplier_max + managers.player:upgrade_value("player", "pick_up_ammo_multiplier_2", 1) - 1
		multiplier_max = multiplier_max + managers.player:crew_ability_upgrade_value("crew_scavenge", 0)

		local add_amount = add_amount_override
		local picked_up = true

		if not add_amount then
			local rng_ammo = math.lerp(math.max(0.5, ammo_base._ammo_pickup[1] * multiplier_min), ammo_base._ammo_pickup[2] * multiplier_max, math.random())
			picked_up = rng_ammo > 0
			add_amount = math.max(0, math.round(rng_ammo))
		end

		add_amount = math.floor(add_amount * (ratio or 1))

		ammo_base:set_ammo_total(math.clamp(ammo_base:get_ammo_total() + add_amount, 0, ammo_base:get_ammo_max()))

		return picked_up, add_amount
	end

	local picked_up, add_amount = nil
	picked_up, add_amount = _add_ammo(self, ratio, add_amount_override)

	if self.AKIMBO then
		local akimbo_rounding = self:get_ammo_total() % 2 + #self._fire_callbacks

		if akimbo_rounding > 0 then
			_add_ammo(self, nil, akimbo_rounding)
		end
	end

	for _, gadget in ipairs(self:get_all_override_weapon_gadgets()) do
		if gadget and gadget.ammo_base then
			local p, a = _add_ammo(gadget:ammo_base(), ratio, add_amount_override)
			picked_up = p or picked_up
			add_amount = add_amount + a

			if self.AKIMBO then
				local akimbo_rounding = gadget:ammo_base():get_ammo_total() % 2 + #self._fire_callbacks

				if akimbo_rounding > 0 then
					_add_ammo(gadget:ammo_base(), nil, akimbo_rounding)
				end
			end
		end
	end

	return picked_up, add_amount
end

function RaycastWeaponBase:check_autoaim(from_pos, direction, max_dist, use_aim_assist, autohit_override_data)
	local autohit = use_aim_assist and self._aim_assist_data or self._autohit_data
	autohit = autohit_override_data or autohit
	local autohit_near_angle = autohit.near_angle
	local autohit_far_angle = autohit.far_angle
	local far_dis = autohit.far_dis
	local closest_error, closest_ray = nil
	local tar_vec = tmp_vec1
	local ignore_units = self._setup.ignore_units
	local slotmask = self._bullet_slotmask
	local enemies = managers.enemy:all_enemies()
	local max_range = self._weapon_range or self._range or 20000
	max_range = max_range * max_range
	local suppression_near_angle = 50
	local suppression_far_angle = 5
	local suppression_enemies = nil

	for u_key, enemy_data in pairs(enemies) do
		local enemy = enemy_data.unit
		
		if not enemy:in_slot(16) and enemy:base():lod_stage() then
			local com = mvec3_cpy(enemy:movement()._obj_head:position())
			local tar_vec_len = math_clamp(mvec3_dir(tar_vec, from_pos, com), 1, far_dis)

			if not max_dist or max_dist > tar_vec_len then
				local error_dot = mvec3_dot(direction, tar_vec)
				local error_angle = math_acos(error_dot)
				local dis_lerp = tar_vec_len / far_dis
				
				local vis_ray = World:raycast("ray", from_pos, com, "slot_mask", slotmask, "ignore_unit", ignore_units)
				
				if not vis_ray or vis_ray.unit:key() == u_key or mvec3_dis_sq(vis_ray.position, com) < 3600 then
					local suppression_min_angle = math_lerp(suppression_near_angle, suppression_far_angle, dis_lerp)

					if error_angle < suppression_min_angle then
						suppression_enemies = suppression_enemies or {}
						local percent_error = 1 - math_clamp(error_angle / suppression_min_angle, 0, 1)
						suppression_enemies[enemy_data] = percent_error
					end
				end

				local autohit_min_angle = math_lerp(autohit_near_angle, autohit_far_angle, dis_lerp)

				if error_angle < autohit_min_angle then
					if vis_ray and vis_ray.unit:key() == u_key and (not closest_error or error_angle < closest_error) then
						closest_error = error_angle
						closest_ray = vis_ray
					end
				end
			end
		end
	end

	return closest_ray, suppression_enemies
end

function RaycastWeaponBase:_build_suppression(enemies_in_cone, suppr_mul)
	if self:gadget_overrides_weapon_functions() then
		local r = self:gadget_function_override("_build_suppression", self, enemies_in_cone, suppr_mul)

		if r ~= nil then
			return
		end
	end

	if enemies_in_cone then
		for enemy_data, dis_error in pairs(enemies_in_cone) do
			print(enemy_data.unit)

			if not enemy_data.unit:movement():cool() then
				enemy_data.unit:character_damage():build_suppression(suppr_mul * dis_error * self._suppression, self._panic_suppression_chance)
			end
		end
	end
end

function RaycastWeaponBase:calculate_ammo_max_per_clip()
	local ammo = tweak_data.weapon[self._name_id].CLIP_AMMO_MAX
	
	if self:weapon_tweak_data().ignore_player_skills then
		return ammo
	end
	
	ammo = ammo + managers.player:upgrade_value(self._name_id, "clip_ammo_increase")

	if not self:upgrade_blocked("weapon", "clip_ammo_increase") then
		ammo = ammo + managers.player:upgrade_value("weapon", "clip_ammo_increase", 0)
	end

	for _, category in ipairs(tweak_data.weapon[self._name_id].categories) do
		if not self:upgrade_blocked(category, "clip_ammo_increase") then
			ammo = ammo + managers.player:upgrade_value(category, "clip_ammo_increase", 0)
		end
	end

	ammo = ammo + (self._extra_ammo or 0)

	return ammo
end