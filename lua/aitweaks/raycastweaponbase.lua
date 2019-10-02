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
