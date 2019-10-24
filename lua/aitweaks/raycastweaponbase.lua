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
local tmp_rot1 = Rotation()

--technically a player-side change but also not really.
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
	local suppression_near_angle = 500
	local suppression_far_angle = 200
	local suppression_enemies = nil

	for u_key, enemy_data in pairs(enemies) do
		local enemy = enemy_data.unit

		if not enemy:in_slot(16) then --fuck off, enemies at all ranges get suppressed
			local com = enemy:movement():m_com()

			mvec3_set(tar_vec, com)
			mvec3_sub(tar_vec, from_pos)

			local tar_aim_dot = mvec3_dot(direction, tar_vec)

			if tar_aim_dot > 0 and (not max_dist or tar_aim_dot < 6000) then
				local tar_vec_len = math_clamp(mvec3_norm(tar_vec), 1, far_dis)
				local error_dot = mvec3_dot(direction, tar_vec)
				local error_angle = math.acos(error_dot)
				local dis_lerp = math.pow(tar_aim_dot / far_dis, 0.25)
				local dis_lerp_sup = math.pow(tar_aim_dot / 6000, 0.25)
				local suppression_min_angle = math_lerp(suppression_near_angle, suppression_far_angle, dis_lerp_sup)

				if error_angle < suppression_min_angle then
					suppression_enemies = suppression_enemies or {}
					local percent_error = error_angle / suppression_min_angle
					suppression_enemies[enemy_data] = percent_error
				end

				local autohit_min_angle = math_lerp(autohit_near_angle, autohit_far_angle, dis_lerp)

				if error_angle < autohit_min_angle then
					local percent_error = error_angle / autohit_min_angle

					if not closest_error or percent_error < closest_error then
						tar_vec_len = tar_vec_len + 100

						mvec3_mul(tar_vec, tar_vec_len)
						mvec3_add(tar_vec, from_pos)

						local vis_ray = World:raycast("ray", from_pos, tar_vec, "slot_mask", slotmask, "ignore_unit", ignore_units)

						if vis_ray and vis_ray.unit:key() == u_key and (not closest_error or error_angle < closest_error) then
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

	return closest_ray, suppression_enemies
end

local MIN_KNOCK_BACK = 200
local KNOCK_BACK_CHANCE = 0.8

--Fix for duplicated bullets below, thank you Hoxi <3
function InstantBulletBase:on_collision(col_ray, weapon_unit, user_unit, damage, blank, no_sound)
	if not blank and Network:is_client() and user_unit and alive(user_unit) and user_unit ~= managers.player:player_unit() then
		blank = true
	end

	local hit_unit = col_ray.unit
	local shield_knock = false
	local is_shield = hit_unit:in_slot(managers.slot:get_mask("enemy_shield_check")) and alive(hit_unit:parent())

	if weapon_unit and is_shield and not hit_unit:parent():base().is_phalanx and tweak_data.character[hit_unit:parent():base()._tweak_table].damage.shield_knocked and not hit_unit:parent():character_damage():is_immune_to_shield_knockback() then
		shield_knock = weapon_unit:base()._shield_knock
		local dmg_ratio = math.min(damage, MIN_KNOCK_BACK)
		dmg_ratio = dmg_ratio / MIN_KNOCK_BACK + 1
		local rand = math.random() * dmg_ratio

		if KNOCK_BACK_CHANCE < rand then
			local enemy_unit = hit_unit:parent()

			if shield_knock and enemy_unit:character_damage() then
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

	local play_impact_flesh = not hit_unit:character_damage() or not hit_unit:character_damage()._no_blood

	if hit_unit:damage() and managers.network:session() and col_ray.body:extension() and col_ray.body:extension().damage then
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

	if not blank then
		if alive(weapon_unit) and hit_unit:character_damage() and hit_unit:character_damage().damage_bullet then
			local is_alive = not hit_unit:character_damage():dead()
			local knock_down = weapon_unit:base()._knock_down and weapon_unit:base()._knock_down > 0 and math.random() < weapon_unit:base()._knock_down
			result = self:give_impact_damage(col_ray, weapon_unit, user_unit, damage, weapon_unit:base()._use_armor_piercing, false, knock_down, weapon_unit:base()._stagger, weapon_unit:base()._variant)

			if result ~= "friendly_fire" then
				local is_dead = hit_unit:character_damage():dead()
				local push_multiplier = self:_get_character_push_multiplier(weapon_unit, is_alive and is_dead)

				managers.game_play_central:physics_push(col_ray, push_multiplier)
			else
				play_impact_flesh = false
			end
		else
			managers.game_play_central:physics_push(col_ray)
		end
		
		local fullautonpc = alive(weapon_unit) and weapon_unit:base().weapon_tweak_data and weapon_unit:base():weapon_tweak_data() and weapon_unit:base():weapon_tweak_data().fullautonpc ~= nil
		
		if fullautonpc then --no more destroying my framerate you figgin' fuggin' goose
			if math.random() < 0.25 then
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

	return result
end

function InstantBulletBase:on_collision_effects(col_ray, weapon_unit, user_unit, damage, blank, no_sound)
	local hit_unit = col_ray.unit
	local play_impact_flesh = not hit_unit:character_damage() or not hit_unit:character_damage()._no_blood
	local fullautonpc = alive(weapon_unit) and weapon_unit:base().weapon_tweak_data and weapon_unit:base():weapon_tweak_data() and weapon_unit:base():weapon_tweak_data().fullautonpc ~= nil
	
	if fullautonpc then
		if math.random() < 0.25 then
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