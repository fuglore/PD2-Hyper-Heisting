local flashbang_test_offset = Vector3(0, 0, 150)

function CoreEnvironmentControllerManager:set_flashbang(flashbang_pos, line_of_sight, travel_dis, linear_dis, duration)
	local flash = self:test_line_of_sight(flashbang_pos + flashbang_test_offset, 200, 1000, 3000, true)
	self._flashbang_duration = duration

	if flash > 0 then
		self._current_flashbang = math.min(self._current_flashbang + flash, 1.5) * self._flashbang_duration
		self._current_flashbang_flash = math.min(self._current_flashbang_flash + flash, 1.5) * self._flashbang_duration
	end

	World:effect_manager():spawn({
		effect = Idstring("effects/particles/explosions/explosion_grenade"),
		position = flashbang_pos,
		normal = Vector3(0, 0, 1)
	})
end

function CoreEnvironmentControllerManager:test_line_of_sight(test_pos, min_distance, dot_distance, max_distance, is_flashbang)
	local tmp_vec1 = Vector3()
	local tmp_vec2 = Vector3()
	local tmp_vec3 = Vector3()
	local vp = managers.viewport:first_active_viewport()

	if not vp then
		return 0
	end

	local camera = vp:camera()
	local cam_pos = tmp_vec1

	camera:m_position(cam_pos)

	local test_vec = tmp_vec2
	local dis = mvector3.direction(test_vec, cam_pos, test_pos)

	if max_distance < dis then
		return 0
	end

	if dis < min_distance then
		if is_flashbang then
			managers.player:player_unit():sound():say("g41x_any", true)
		end

		return 1
	end

	local dot_mul = 1
	local max_dot = math.cos(75)
	local cam_rot = camera:rotation()
	local cam_fwd = camera:rotation():y()

	if mvector3.dot(cam_fwd, test_vec) < max_dot then
		if dis < dot_distance then
			dot_mul = 0.5
		else
			return 0
		end
	end

	local ray_hit = World:raycast("ray", cam_pos, test_pos, "slot_mask", managers.slot:get_mask("AI_visibility"), "ray_type", "ai_vision", "report")

	if ray_hit then
		return 0
	end

	local flash = math.max(dis - min_distance, 0) / (max_distance - min_distance)
	flash = (1 - flash) * dot_mul

	if is_flashbang and dot_mul == 1 then
		managers.player:player_unit():sound():say("g41x_any", true)
	end

	return flash
end

if PD2THHSHIN and PD2THHSHIN:BlurzoneEnabled() then

function CoreEnvironmentControllerManager:set_blurzone(id, mode, pos, radius, height, delete_after_fadeout)
	local blurzone = self._blurzones[id]

	if id then
		blurzone = blurzone or {
			opacity = 0,
			radius = 0,
			mode = -1,
			height = 0,
			delete_after_fadeout = false
		}

		if mode > 0 then
			blurzone.mode = mode
			blurzone.pos = pos
			blurzone.radius = radius
			blurzone.height = height

			if mode == 2 then
				blurzone.opacity = 1
				blurzone.mode = 1
				blurzone.update = self.blurzone_flash_in_line_of_sight
			elseif mode == 3 then
				blurzone.opacity = 1
				blurzone.mode = 1
				blurzone.update = self.blurzone_flash_in
			else
				blurzone.opacity = 0
				blurzone.update = self.blurzone_fade_in
			end

			if height > 0 then
				blurzone.check = self.blurzone_check_cylinder
			else
				blurzone.check = self.blurzone_check_sphere
			end

			blurzone.delete_after_fadeout = delete_after_fadeout
		elseif blurzone and blurzone.mode > 0 then
			blurzone.mode = mode
			blurzone.pos = blurzone.pos or pos
			blurzone.radius = blurzone.radius or radius
			blurzone.height = blurzone.height or height
			blurzone.opacity = 0.4
			blurzone.update = self.blurzone_fade_out

			if blurzone.height > 0 then
				blurzone.check = self.blurzone_check_cylinder
			else
				blurzone.check = self.blurzone_check_sphere
			end
		end

		self._blurzones[id] = blurzone
	end
end

function CoreEnvironmentControllerManager:blurzone_fade_in(self, t, dt, camera_pos, blurzone)
	blurzone.opacity = blurzone.opacity + dt

	if blurzone.opacity > 0.4 then
		blurzone.opacity = 0.4
		blurzone.update = self.blurzone_fade_idle
	end

	return blurzone:check(blurzone, camera_pos)
end

end