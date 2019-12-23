local mvec3_set = mvector3.set
local mvec3_set_z = mvector3.set_z
local mvec3_sub = mvector3.subtract
local mvec3_norm = mvector3.normalize
local mvec3_dir = mvector3.direction
local mvec3_set_l = mvector3.set_length
local mvec3_add = mvector3.add
local mvec3_dot = mvector3.dot
local mvec3_cross = mvector3.cross
local mvec3_rot = mvector3.rotate_with
local mvec3_rand_orth = mvector3.random_orthogonal
local mvec3_lerp = mvector3.lerp
local mrot_axis_angle = mrotation.set_axis_angle
local temp_vec1 = Vector3()
local temp_vec2 = Vector3()
local temp_vec3 = Vector3()
local temp_rot1 = Rotation()
local bezier_curve = {
	0,
	0,
	1,
	1
}

function CopActionShoot:update(t)
	local vis_state = self._ext_base:lod_stage()
	vis_state = vis_state or 4
	local difficulty_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)
	local speed = 1

	if vis_state == 1 then
		-- Nothing
	elseif self._skipped_frames < vis_state * 3 then
		self._skipped_frames = self._skipped_frames + 1

		return
	else
		self._skipped_frames = 1
	end

	local shoot_from_pos = self._shoot_from_pos
	local ext_anim = self._ext_anim
	local target_vec, target_dis, autotarget, target_pos = nil

	if self._attention then
		target_pos, target_vec, target_dis, autotarget = self:_get_target_pos(shoot_from_pos, self._attention, t)
		local tar_vec_flat = temp_vec2

		mvec3_set(tar_vec_flat, target_vec)
		mvec3_set_z(tar_vec_flat, 0)
		mvec3_norm(tar_vec_flat)

		local fwd = self._common_data.fwd
		local fwd_dot = mvec3_dot(fwd, tar_vec_flat)
		
		if not self._unit:base():has_tag("tank") then
			if difficulty_index == 8 then
				speed = 1.75
			elseif difficulty_index == 6 or difficulty_index == 7 then
				speed = 1.5
			elseif difficulty_index <= 5 then
				speed = 1.25
			else
				speed = 1.25
			end
		end
		
		if self._turn_allowed then
			local active_actions = self._common_data.active_actions
			local queued_actions = self._common_data.queued_actions

			if (not active_actions[2] or active_actions[2]:type() == "idle") and (not queued_actions or not queued_actions[1] and not queued_actions[2]) and not self._ext_movement:chk_action_forbidden("walk") then
				local fwd_dot_flat = mvec3_dot(tar_vec_flat, fwd)

				if fwd_dot_flat < 0.96 then
					local spin = tar_vec_flat:to_polar_with_reference(fwd, math.UP).spin
					local new_action_data = {
						type = "turn",
						body_part = 2,
						speed = speed or 1,
						angle = error_spin
					}

					self._ext_movement:action_request(new_action_data)
				end
			end
		end

		target_vec = self:_upd_ik(target_vec, fwd_dot, t)
	end

	if not ext_anim.reload and not ext_anim.equip and not ext_anim.melee then
		if ext_anim.equip then
			-- Nothing
		elseif self._weapon_base:clip_empty() then
			if self._autofiring then
				self._weapon_base:stop_autofire()
				self._ext_movement:play_redirect("up_idle")

				self._autofiring = nil
				self._autoshots_fired = nil
			end

			local res = CopActionReload._play_reload(self)

			if res and not self._ext_anim.base_no_reload then
				self._machine:set_speed(res, self._reload_speed)
			end

			if Network:is_server() then
				managers.network:session():send_to_peers("reload_weapon_cop", self._unit)
			end
		elseif self._autofiring then
			if not target_vec or not self._common_data.allow_fire then
				self._weapon_base:stop_autofire()

				self._shoot_t = t + 0.6
				self._autofiring = nil
				self._autoshots_fired = nil

				self._ext_movement:play_redirect("up_idle")
			else
				local spread = self._spread
				local falloff, i_range = self:_get_shoot_falloff(target_dis, self._falloff)
				local dmg_buff = self._unit:base():get_total_buff("base_damage")
				local dmg_mul = (1 + dmg_buff) * falloff.dmg_mul
				local new_target_pos = self._shoot_history and self:_get_unit_shoot_pos(t, target_pos, target_dis, self._w_usage_tweak, falloff, i_range, autotarget)

				if new_target_pos then
					target_pos = new_target_pos
				else
					spread = math.min(20, spread)
				end

				local spread_pos = temp_vec2

				mvec3_rand_orth(spread_pos, target_vec)
				mvec3_set_l(spread_pos, spread)
				mvec3_add(spread_pos, target_pos)

				target_dis = mvec3_dir(target_vec, shoot_from_pos, spread_pos)
				local fired = self._weapon_base:trigger_held(shoot_from_pos, target_vec, dmg_mul, self._shooting_player, nil, nil, nil, self._attention.unit)

				if fired then
					if fired.hit_enemy and fired.hit_enemy.type == "death" and self._unit:unit_data().mission_element then
						self._unit:unit_data().mission_element:event("killshot", self._unit)
					end

					if not ext_anim.recoil and vis_state == 1 and not ext_anim.base_no_recoil and not ext_anim.move then
						self._ext_movement:play_redirect("recoil_auto")
					end

					if not self._autofiring or self._autoshots_fired >= self._autofiring - 1 then
						self._autofiring = nil
						self._autoshots_fired = nil

						self._weapon_base:stop_autofire()
						self._ext_movement:play_redirect("up_idle")

						if not Global.game_settings.one_down then
							self._shoot_t = t + (self._common_data.is_suppressed and 1.5 or 1) + (managers.groupai:state():chk_high_fed_density() and 1 or 0) * math.lerp(falloff.recoil[1], falloff.recoil[2], self:_pseudorandom())
						elseif Global.game_settings.one_down then
							self._shoot_t = t + 1 + (managers.groupai:state():chk_high_fed_density() and 1 or 0) * math.lerp(falloff.recoil[1], falloff.recoil[2], self:_pseudorandom()) --suppression does not affect recoil on shin mode
						else
							self._shoot_t = t + falloff.recoil[2]
						end
					else
						self._autoshots_fired = self._autoshots_fired + 1
					end
				end
			end
		elseif target_vec and self._common_data.allow_fire and self._shoot_t < t and self._mod_enable_t < t then
			local shoot = nil

			if autotarget or self._shooting_husk_player and self._next_vis_ray_t < t then
				if self._shooting_husk_player then
					self._next_vis_ray_t = t + 2
				end

				local fire_line = World:raycast("ray", shoot_from_pos, target_pos, "slot_mask", self._verif_slotmask, "ray_type", "ai_vision")

				if fire_line then
					if t - self._line_of_sight_t > 3 then
						local aim_delay_minmax = self._w_usage_tweak.aim_delay
						local lerp_dis = math.min(1, target_vec:length() / self._falloff[#self._falloff].r)
						local aim_delay = math.lerp(aim_delay_minmax[1], aim_delay_minmax[2], lerp_dis)
						aim_delay = aim_delay + self:_pseudorandom() * aim_delay
						
						if not Global.game_settings.one_down then
							if self._common_data.is_suppressed then --aim delay is not affected by suppression on shin mode
								aim_delay = aim_delay * 1.5
							end
						end
						
						if managers.groupai:state():chk_high_fed_density() then
							aim_delay = aim_delay * 2
						end
						
						self._shoot_t = t + aim_delay
					end
				else
					if t - self._line_of_sight_t > 0.35 and not self._last_vis_check_status then
						local shoot_hist = self._shoot_history
						local displacement = mvector3.distance(target_pos, shoot_hist.m_last_pos)
						local mult = displacement / self._w_usage_tweak.focus_dis
						local focus_delay = self._w_usage_tweak.focus_delay * mult
						shoot_hist.focus_start_t = t
						shoot_hist.focus_delay = focus_delay
						shoot_hist.m_last_pos = mvector3.copy(target_pos)
					end

					self._line_of_sight_t = t
					shoot = true
				end

				self._last_vis_check_status = shoot
			elseif self._shooting_husk_player then
				shoot = self._last_vis_check_status
			else
				shoot = true
			end

			if self._common_data.char_tweak.no_move_and_shoot and self._common_data.ext_anim and self._common_data.ext_anim.move then
				shoot = false
				self._shoot_t = t + (self._common_data.char_tweak.move_and_shoot_cooldown or 1)
			end

			if shoot then
				local melee = nil

				if autotarget and (not self._common_data.melee_countered_t or t - self._common_data.melee_countered_t > 15) and target_dis < 130 and self._w_usage_tweak.melee_speed and self._melee_timeout_t < t then
					melee = self:_chk_start_melee(target_vec, target_dis, autotarget, target_pos)
				end

				if not melee then
					local falloff, i_range = self:_get_shoot_falloff(target_dis, self._falloff)
					local dmg_buff = self._unit:base():get_total_buff("base_damage")
					local dmg_mul = (1 + dmg_buff) * falloff.dmg_mul
					local firemode = nil

					if self._automatic_weap then
						firemode = falloff.mode and falloff.mode[1] or 1
						local random_mode = self:_pseudorandom()

						for i_mode, mode_chance in ipairs(falloff.mode) do
							if random_mode <= mode_chance then
								firemode = i_mode

								break
							end
						end
					else
						firemode = 1
					end

					if firemode > 1 then
						self._weapon_base:start_autofire(firemode < 4 and firemode)

						if self._w_usage_tweak.autofire_rounds then
							if firemode < 4 then
								self._autofiring = firemode
							elseif falloff.autofire_rounds then
								local diff = falloff.autofire_rounds[2] - falloff.autofire_rounds[1]
								self._autofiring = math.round(falloff.autofire_rounds[1] + self:_pseudorandom() * diff)
							else
								local diff = self._w_usage_tweak.autofire_rounds[2] - self._w_usage_tweak.autofire_rounds[1]
								self._autofiring = math.round(self._w_usage_tweak.autofire_rounds[1] + self:_pseudorandom() * diff)
							end
						else
							Application:stack_dump_error("autofire_rounds is missing from weapon usage tweak data!", self._weap_tweak.usage)
						end

						self._autoshots_fired = 0

						if vis_state == 1 and not ext_anim.base_no_recoil and not ext_anim.move then
							self._ext_movement:play_redirect("recoil_auto")
						end
					else
						local spread = self._spread

						local new_target_pos = self._shoot_history and self:_get_unit_shoot_pos(t, target_pos, target_dis, self._w_usage_tweak, falloff, i_range, autotarget)

						if new_target_pos then
							target_pos = new_target_pos
						else
							spread = math.min(20, spread)
						end

						local spread_pos = temp_vec2

						mvec3_rand_orth(spread_pos, target_vec)
						mvec3_set_l(spread_pos, spread)
						mvec3_add(spread_pos, target_pos)

						target_dis = mvec3_dir(target_vec, shoot_from_pos, spread_pos)
						local fired = self._weapon_base:singleshot(shoot_from_pos, target_vec, dmg_mul, self._shooting_player, nil, nil, nil, self._attention.unit)

						if fired and fired.hit_enemy and fired.hit_enemy.type == "death" and self._unit:unit_data().mission_element then
							self._unit:unit_data().mission_element:event("killshot", self._unit)
						end

						if not Global.game_settings.one_down then
							if vis_state == 1 and not ext_anim.base_no_recoil and not ext_anim.move then
								self._ext_movement:play_redirect("recoil_single")
							end

							self._shoot_t = t + (self._common_data.is_suppressed and 1.5 or 1) + (managers.groupai:state():chk_high_fed_density() and 1 or 0) * math.lerp(falloff.recoil[1], falloff.recoil[2], self:_pseudorandom())
							
						elseif Global.game_settings.one_down then
							if vis_state == 1 and not ext_anim.base_no_recoil and not ext_anim.move then
								self._ext_movement:play_redirect("recoil_single")
							end

							self._shoot_t = t + 1 + (managers.groupai:state():chk_high_fed_density() and 1 or 0) * math.lerp(falloff.recoil[1], falloff.recoil[2], self:_pseudorandom()) --suppression does not affect recoil on shin mode
							
						else
							self._shoot_t = t + falloff.recoil[2]
						end
					end
				end
			end
		end
	end

	if self._ext_anim.base_need_upd then
		self._ext_movement:upd_m_head_pos()
	end
end

function CopActionShoot:_get_unit_shoot_pos(t, pos, dis, w_tweak, falloff, i_range, shooting_local_player)
	local shoot_hist = self._shoot_history
	local focus_delay, focus_prog = nil

	if shoot_hist.focus_delay then
		focus_delay = (shooting_local_player and self._attention.unit:character_damage():focus_delay_mul() or 1) * shoot_hist.focus_delay
		focus_prog = focus_delay > 0 and (t - shoot_hist.focus_start_t) / focus_delay

		if not focus_prog or focus_prog >= 1 then
			shoot_hist.focus_delay = nil
			focus_prog = 1
		end
	else
		focus_prog = 1
	end

	local dis_lerp = nil
	local hit_chances = falloff.acc
	local hit_chance = nil

	if i_range == 1 then
		dis_lerp = dis / falloff.r
		hit_chance = math.lerp(hit_chances[1], hit_chances[2], focus_prog)
	else
		local prev_falloff = w_tweak.FALLOFF[i_range - 1]
		dis_lerp = math.min(1, (dis - prev_falloff.r) / (falloff.r - prev_falloff.r))
		local prev_range_hit_chance = math.lerp(prev_falloff.acc[1], prev_falloff.acc[2], focus_prog)
		hit_chance = math.lerp(prev_range_hit_chance, math.lerp(hit_chances[1], hit_chances[2], focus_prog), dis_lerp)
	end
	
	if not Global.game_settings.one_down then
		if self._common_data.is_suppressed then --their accuracy is not affected by suppression on shin mode
			hit_chance = hit_chance * 0.5
		end
	end
	
	if managers.groupai:state():chk_high_fed_density() then
		hit_chance = hit_chance * 0.5
	end
	
	if not Global.game_settings.one_down then
		if self._common_data.ext_anim.move or self._common_data.ext_anim.run then
			hit_chance = hit_chance * 0.75
		end
	end
	
	if not Global.game_settings.one_down then
		if self._common_data.active_actions[2] and self._common_data.active_actions[2]:type() == "dodge" then --their accuracy is not affected while dodging on shin mode
			hit_chance = hit_chance * self._common_data.active_actions[2]:accuracy_multiplier()
		end
	end
	
	local gamemode_chk = game_state_machine:gamemode() 
	
	if gamemode_chk == "crime_spree" then
		if managers.crime_spree then
			local copaccmultcs = managers.crime_spree:get_acc_mult() or 1
			
			hit_chance = hitchance * getcopaccmultcs
		end
	end

	hit_chance = hit_chance * self._unit:character_damage():accuracy_multiplier()

	if self:_pseudorandom() < hit_chance then
		mvec3_set(shoot_hist.m_last_pos, pos)
	else
		local enemy_vec = temp_vec2

		mvec3_set(enemy_vec, pos)
		mvec3_sub(enemy_vec, self._common_data.pos)

		local error_vec = Vector3()

		mvec3_cross(error_vec, enemy_vec, math.UP)
		mrot_axis_angle(temp_rot1, enemy_vec, math.random(360))
		mvec3_rot(error_vec, temp_rot1)

		local miss_min_dis = shooting_local_player and 10 or 40
		local error_vec_len = nil
		
		if shooting_local_player then
			error_vec_len = w_tweak.spread + w_tweak.miss_dis
		else
			error_vec_len = w_tweak.spread + w_tweak.miss_dis * 2
		end

		mvec3_set_l(error_vec, error_vec_len)
		mvec3_add(error_vec, pos)
		mvec3_set(shoot_hist.m_last_pos, error_vec)

		return error_vec
	end
end