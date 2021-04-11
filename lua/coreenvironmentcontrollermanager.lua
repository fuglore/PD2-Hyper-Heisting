local HH = PD2THHSHIN
local flashbang_test_offset = Vector3(0, 0, 150)

local ids_dof_near_plane = Idstring("near_plane")
local ids_dof_far_plane = Idstring("far_plane")
local ids_dof_settings = Idstring("settings")
local mvec1 = Vector3()
local mvec2 = Vector3()

function CoreEnvironmentControllerManager:_update_dof(t, dt)
	local mvec_set = mvector3.set_static
	local mvec = mvec1

	if self._dof_override then
		if self._dof_override_transition_params then
			local params = self._dof_override_transition_params
			params.time = math.max(0, params.time - dt)
			local lerp_v = math.bezier({
				0,
				0,
				1,
				1
			}, 1 - params.time / params.total_t)
			self._dof_override_near = math.lerp(params.start.near, params.stop.near, lerp_v)
			self._dof_override_near_pad = math.lerp(params.start.near_pad, params.stop.near_pad, lerp_v)
			self._dof_override_far = math.lerp(params.start.far, params.stop.far, lerp_v)
			self._dof_override_far_pad = math.lerp(params.start.far_pad, params.stop.far_pad, lerp_v)

			if params.time == 0 then
				self._dof_override_transition_params = nil
			end
		end

		mvec_set(mvec, self._dof_override_near, self._dof_override_near + self._dof_override_near_pad, 0)
		self._material:set_variable(ids_dof_near_plane, mvec)
		mvec_set(mvec, self._dof_override_far - self._dof_override_far_pad, self._dof_override_far, 1)
		self._material:set_variable(ids_dof_far_plane, mvec)
	else
		local dof_settings = self._dof_tweaks[self._current_dof_setting]
		local no_weird_dof = HH.settings.toggle_noweirddof == true
		
		if dof_settings.use_no_dof == true then
			if no_weird_dof then
				mvec_set(mvec, 0, 0, 0)
				self._material:set_variable(ids_dof_near_plane, mvec)
				mvec_set(mvec, 0, 0, 0)
				self._material:set_variable(ids_dof_far_plane, mvec)
			else
				mvec_set(mvec, 0, 0, 0)
				self._material:set_variable(ids_dof_near_plane, mvec)
				mvec_set(mvec, 10000, 10000, 1)
				self._material:set_variable(ids_dof_far_plane, mvec)
			end
		elseif self._in_steelsight then
			dof_settings = dof_settings.steelsight
			local dof_plane_v = math.clamp(self._current_dof_distance / 5000, 0, 1)
			self._near_plane_x = math.lerp(500, dof_settings.near_plane_x, dof_plane_v)
			self._near_plane_y = math.lerp(20, dof_settings.near_plane_y, dof_plane_v)
			self._far_plane_x = math.lerp(100, dof_settings.far_plane_x, dof_plane_v)
			self._far_plane_y = math.lerp(500, dof_settings.far_plane_y, dof_plane_v)

			mvec_set(mvec, math.max(self._current_dof_distance - self._near_plane_x, 5), self._near_plane_y, 0)
			self._material:set_variable(ids_dof_near_plane, mvec)
			mvec_set(mvec, self._current_dof_distance + self._far_plane_x, self._far_plane_y, 1)
			self._material:set_variable(ids_dof_far_plane, mvec)
		elseif no_weird_dof then
			local dof_speed = math.min(10 * dt, 1)
			self._near_plane_x = math.lerp(self._near_plane_x, 0, dof_speed)
			self._near_plane_y = math.lerp(self._near_plane_y, 0, dof_speed)
			self._far_plane_x = math.lerp(self._far_plane_x, 0, dof_speed)
			self._far_plane_y = math.lerp(self._far_plane_y, 0, dof_speed)

			mvec_set(mvec, self._near_plane_x, self._near_plane_y, 0)
			self._material:set_variable(ids_dof_near_plane, mvec)
			mvec_set(mvec, self._far_plane_x, self._far_plane_y, 0)
			self._material:set_variable(ids_dof_far_plane, mvec)
		else
			dof_settings = dof_settings.other
			local dof_speed = math.min(10 * dt, 1)
			self._near_plane_x = math.lerp(self._near_plane_x, dof_settings.near_plane_x, dof_speed)
			self._near_plane_y = math.lerp(self._near_plane_y, dof_settings.near_plane_y, dof_speed)
			self._far_plane_x = math.lerp(self._far_plane_x, dof_settings.far_plane_x, dof_speed)
			self._far_plane_y = math.lerp(self._far_plane_y, dof_settings.far_plane_y, dof_speed)

			mvec_set(mvec, self._near_plane_x, self._near_plane_y, 0)
			self._material:set_variable(ids_dof_near_plane, mvec)
			mvec_set(mvec, self._far_plane_x, self._far_plane_y, 1)
			self._material:set_variable(ids_dof_far_plane, mvec)
		end
	end
end

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

function CoreEnvironmentControllerManager:set_chromatic_enabled(enabled)
	self._chromatic_enabled = enabled

	if self._material then
		if self._chromatic_enabled then
			self._material:set_variable(Idstring("chromatic_amount"), self._base_chromatic_amount)
		else
			self._material:set_variable(Idstring("chromatic_amount"), 0)
		end
	end
end

function CoreEnvironmentControllerManager:set_contrast_value_lerp(lerp_value)
	if not lerp_value then
		return
	end

	if self._material then
		local high_contrast = lerp_value >= 0.99 and math.lerp(0.5, 0.6, math.random()) or 0.5
		if self._chromatic_enabled then
			high_contrast = high_contrast * 0.5
		end
		local new_contrast_value = math.lerp(self._base_contrast, high_contrast, lerp_value)
		self._material:set_variable(Idstring("contrast"), new_contrast_value)
	end
end

function CoreEnvironmentControllerManager:set_chromatic_value_lerp(lerp_value)
	if not lerp_value then
		return
	end
	
	if not self._chromatic_enabled then
		return
	end

	if self._material then
		if self._chromatic_enabled then
			--log("nice")
			local high_chrom = lerp_value >= 0.99 and math.lerp(-0.85, -1.4, math.random()) or -0.85
			local new_chrom_value = math.lerp(self._base_chromatic_amount, high_chrom, lerp_value)
			self._material:set_variable(Idstring("chromatic_amount"), new_chrom_value)
		end
	end
end

if HH and HH:BlurzoneEnabled() then

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
				blurzone.opacity = 0.25
				blurzone.mode = 1
				blurzone.update = self.blurzone_flash_in_line_of_sight
			elseif mode == 3 then
				blurzone.opacity = 0.25
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
			blurzone.opacity = 0.25
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
	dt = dt / 2
	blurzone.opacity = blurzone.opacity + dt

	if blurzone.opacity > 0.25 then
		blurzone.opacity = 0.25
		blurzone.update = self.blurzone_fade_idle
	end

	return blurzone:check(blurzone, camera_pos)
end

end