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

function CopActionShoot:init(action_desc, common_data)
	self._common_data = common_data
	self._ext_movement = common_data.ext_movement
	self._ext_anim = common_data.ext_anim
	self._ext_brain = common_data.ext_brain
	self._ext_inventory = common_data.ext_inventory
	self._ext_base = common_data.ext_base
	self._body_part = action_desc.body_part
	self._machine = common_data.machine
	self._unit = common_data.unit
	local preset_name = self._ext_anim.base_aim_ik or "spine"
	local preset_data = self._ik_presets[preset_name]
	self._ik_preset = preset_data

	self[preset_data.start](self)

	local weapon_unit = self._ext_inventory:equipped_unit()

	if not weapon_unit then
		return false
	end

	local weap_tweak = weapon_unit:base():weapon_tweak_data()
	local weapon_usage_tweak = common_data.char_tweak.weapon[weap_tweak.usage]
	self._weapon_unit = weapon_unit
	self._weapon_base = weapon_unit:base()
	local suppressive = self._weapon_base.suppression and self._weapon_base.suppression >= 5
	self.fireline_t = suppressive and 2 or 0.7
	self._weap_tweak = weap_tweak
	self._w_usage_tweak = weapon_usage_tweak
	self._reload_speed = weapon_usage_tweak.RELOAD_SPEED
	self._spread = weapon_usage_tweak.spread
	self._falloff = weapon_usage_tweak.FALLOFF
	self._variant = action_desc.variant
	self._body_part = action_desc.body_part
	self._turn_allowed = Network:is_client()
	self._automatic_weap = weap_tweak.auto and weapon_usage_tweak.autofire_rounds and true
	self._shoot_t = 0
	local t = TimerManager:game():time()
	self._melee_timeout_t = t + 1
	local shoot_from_pos = self._ext_movement:m_head_pos()
	self._shoot_from_pos = shoot_from_pos
	self._shield = alive(self._ext_inventory and self._ext_inventory._shield_unit) and self._ext_inventory._shield_unit

	self:on_attention(common_data.attention)

	if Network:is_server() then
		self._ext_movement:set_stance_by_code(3)
		common_data.ext_network:send("action_aim_state", true)
	end

	CopActionAct._create_blocks_table(self, action_desc.blocks)

	self._skipped_frames = 1

	return true
end

function CopActionShoot:on_attention(attention, old_attention)
	if self._shooting_player and old_attention and alive(old_attention.unit) then
		old_attention.unit:movement():on_targetted_for_attack(false, self._common_data.unit)
	end

	self._shooting_player = nil
	self._shooting_husk_player = nil
	self._next_vis_ray_t = nil

	if attention then
		local t = TimerManager:game():time()

		self[self._ik_preset.start](self)

		local vis_state = self._ext_base:lod_stage()

		if vis_state and vis_state < 3 and self[self._ik_preset.get_blend](self) > 0 then
			self._aim_transition = {
				duration = 0.333,
				start_t = t,
				start_vec = mvector3.copy(self._common_data.look_vec)
			}
			self._get_target_pos = self._get_transition_target_pos
		else
			self._aim_transition = nil
			self._get_target_pos = nil
		end

		self._mod_enable_t = t + 0.5

		if attention.unit then
			self._shooting_player = attention.unit:base() and attention.unit:base().is_local_player

			if Network:is_client() then
				self._shooting_husk_player = attention.unit:base() and attention.unit:base().is_husk_player

				if self._shooting_husk_player then
					self._next_vis_ray_t = t
				end
			end

			if self._shooting_player or self._shooting_husk_player then
				self._line_of_sight_t = t - 2

				if self._shooting_player then
					attention.unit:movement():on_targetted_for_attack(true, self._common_data.unit)
				end
			end

			local target_pos, _, target_dis = self:_get_target_pos(self._shoot_from_pos, attention, t)
			local usage_tweak = self._w_usage_tweak
			local shoot_hist = self._shoot_history

			if shoot_hist then
				local displacement = mvector3.distance(target_pos, shoot_hist.m_last_pos)

				shoot_hist.focus_start_t = t
				shoot_hist.m_last_pos = mvector3.copy(target_pos)

				if displacement > usage_tweak.focus_dis then
					local aim_delay_minmax = usage_tweak.aim_delay
					local lerp_dis = math.min(1, usage_tweak.focus_dis / displacement)
					local aim_delay = math.lerp(aim_delay_minmax[2], aim_delay_minmax[1], lerp_dis)

					if self._common_data.is_suppressed then
						aim_delay = aim_delay * 1.5
					end

					self._shoot_t = t + aim_delay
				end
			else
				local aim_delay_minmax = usage_tweak.aim_delay
				local lerp_dis = math.min(1, target_dis / self._falloff[#self._falloff].r)
				local aim_delay = math.lerp(aim_delay_minmax[1], aim_delay_minmax[2], lerp_dis)

				if self._common_data.is_suppressed then
					aim_delay = aim_delay * 1.5
				end

				self._shoot_t = t + aim_delay

				shoot_hist = {
					focus_start_t = t,
					focus_delay = usage_tweak.focus_delay,
					m_last_pos = mvector3.copy(target_pos)
				}
				self._shoot_history = shoot_hist
			end
		end
	else
		self[self._ik_preset.stop](self)

		if self._aim_transition then
			self._aim_transition = nil
			self._get_target_pos = nil
		end
	end

	self._attention = attention
end

function CopActionShoot:update(t)
	if Network:is_client() and self._ext_anim.act then --temporary fix for husks shooting local clients while doing animations like climbing
		return
	end

	local vis_state = self._ext_base:lod_stage()
	vis_state = vis_state or 4

	if not self._autofiring and vis_state ~= 1 then
		if self._skipped_frames < vis_state * 3 then
			self._skipped_frames = self._skipped_frames + 1

			return
		else
			self._skipped_frames = 1
		end
	end

	local shoot_from_pos = self._shoot_from_pos
	local ext_anim = self._ext_anim
	local target_pos, target_vec, target_dis, autotarget = nil

	if self._attention then
		target_pos, target_vec, target_dis, autotarget = self:_get_target_pos(shoot_from_pos, self._attention, t)
		local tar_vec_flat = temp_vec2

		mvec3_set(tar_vec_flat, target_vec)
		mvec3_set_z(tar_vec_flat, 0)
		mvec3_norm(tar_vec_flat)

		local fwd = self._common_data.fwd
		local fwd_dot = mvec3_dot(fwd, tar_vec_flat)

		if self._turn_allowed then
			local active_actions = self._common_data.active_actions
			local queued_actions = self._common_data.queued_actions

			if not active_actions[2] or active_actions[2]:type() == "idle" then
				if not queued_actions or not queued_actions[1] and not queued_actions[2] then
					if not self._ext_movement:chk_action_forbidden("turn") then
						local fwd_dot_flat = mvec3_dot(tar_vec_flat, fwd)

						if fwd_dot_flat < 0.96 then
							local difficulty_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)
			
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
							
							local spin = tar_vec_flat:to_polar_with_reference(fwd, math.UP).spin
							local new_action_data = {
								body_part = 2,
								type = "turn",
								speed = speed or 1,
								angle = spin
							}

							self._ext_movement:action_request(new_action_data)
						end
					end
				end
			end
		end

		target_vec = self:_upd_ik(target_vec, fwd_dot, t)
	end

	if not ext_anim.reload and not ext_anim.equip and not ext_anim.melee then
		local can_melee = not self._shield and target_vec and self._common_data.allow_fire and true

		if can_melee then
			if Network:is_server() or autotarget then
				local melee_range = autotarget and 130 or 180

				if target_dis > melee_range then
					can_melee = false
				end
			else
				can_melee = false
			end
		end

		local do_melee = can_melee and self:check_melee_start(t, self._attention, target_dis, autotarget, shoot_from_pos, target_pos) and self:_chk_start_melee(target_vec, target_dis, autotarget, target_pos)

		if do_melee then
			if self._autofiring then
				self._weapon_base:stop_autofire()

				self._autofiring = nil
				self._autoshots_fired = nil
			end

			self._shoot_t = t + 1
		elseif self._weapon_base:clip_empty() then
			if self._autofiring then
				self._weapon_base:stop_autofire()
				self._ext_movement:play_redirect("up_idle")

				self._autofiring = nil
				self._autoshots_fired = nil
			end

			local reload_action = {
				body_part = 3,
				type = "reload"
			}

			self._ext_movement:action_request(reload_action)

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
				mvec3_dir(target_vec, shoot_from_pos, spread_pos)

				local fired = self._weapon_base:trigger_held(shoot_from_pos, target_vec, dmg_mul, autotarget, nil, nil, nil, self._attention.unit)

				if fired then
					if vis_state == 1 and not ext_anim.recoil and not ext_anim.base_no_recoil and not ext_anim.move then
						if self._ext_movement._anim_global == "tank" then
							self._ext_movement:play_redirect("recoil_single")
						else
							self._ext_movement:play_redirect("recoil_auto")
						end
					end

					if not self._autofiring or self._autofiring - 1 <= self._autoshots_fired then
						self._autofiring = nil
						self._autoshots_fired = nil

						self._weapon_base:stop_autofire()
						self._ext_movement:play_redirect("up_idle")

						local lerp_dis = math.min(1, target_dis / self._falloff[#self._falloff].r)
						local shoot_delay = math.lerp(falloff.recoil[1], falloff.recoil[2], lerp_dis)

						if self._common_data.is_suppressed and not Global.game_settings.one_down then
							shoot_delay = shoot_delay * 1.5
						end

						self._shoot_t = t + shoot_delay
					else
						self._autoshots_fired = self._autoshots_fired + 1
					end
				end
			end
		elseif self._common_data.allow_fire and target_vec and self._mod_enable_t < t then
			local shoot = nil

			if self._common_data.char_tweak.no_move_and_shoot and self._common_data.active_actions[2] and self._common_data.active_actions[2]:type() == "walk" then
				local moving_cooldown = self._common_data.char_tweak.move_and_shoot_cooldown or 1

				self._shoot_t = t + moving_cooldown
			elseif autotarget or self._shooting_husk_player and self._next_vis_ray_t < t then
				if self._shooting_husk_player then
					self._next_vis_ray_t = t + 2
				end

				local fire_line_is_obstructed = self._unit:raycast("ray", shoot_from_pos, target_pos, "slot_mask", managers.slot:get_mask("AI_visibility"), "ray_type", "ai_vision")

				if fire_line_is_obstructed then
					if self._line_of_sight_t and fire_line_is_obstructed.distance > 300 and t - self._line_of_sight_t < self.fireline_t then
						shoot = true
					end
				else
					local shield_in_the_way = nil
					local has_ap_rounds = self._weapon_base._use_armor_piercing

					if not has_ap_rounds then
						if self._shield then
							shield_in_the_way = self._unit:raycast("ray", shoot_from_pos, target_pos, "slot_mask", managers.slot:get_mask("enemy_shield_check"), "ignore_unit", self._shield, "report")
						else
							shield_in_the_way = self._unit:raycast("ray", shoot_from_pos, target_pos, "slot_mask", managers.slot:get_mask("enemy_shield_check"), "report")
						end
					end

					if not shield_in_the_way then
					
						if not self._last_vis_check_status and t - self._line_of_sight_t > 1 then
							self._shoot_history.focus_start_t = t
							self._shoot_history.m_last_pos = mvector3.copy(target_pos)
						end

						self._line_of_sight_t = t
						shoot = true
					end
				end

				self._last_vis_check_status = shoot
			elseif self._shooting_husk_player then
				shoot = self._last_vis_check_status
			else
				local fire_line_is_obstructed = self._unit:raycast("ray", shoot_from_pos, target_pos, "slot_mask", managers.slot:get_mask("AI_visibility"), "ray_type", "ai_vision")

				if fire_line_is_obstructed then
					if self._line_of_sight_t and fire_line_is_obstructed.distance > 300 and t - self._line_of_sight_t < self.fireline_t then
						shoot = true
					end
				else
					local shield_in_the_way = nil
					local has_ap_rounds = self._weapon_base._use_armor_piercing

					if not has_ap_rounds then
						if self._shield then
							shield_in_the_way = self._unit:raycast("ray", shoot_from_pos, target_pos, "slot_mask", managers.slot:get_mask("enemy_shield_check"), "ignore_unit", self._shield, "report")
						else
							shield_in_the_way = self._unit:raycast("ray", shoot_from_pos, target_pos, "slot_mask", managers.slot:get_mask("enemy_shield_check"), "report")
						end
					end

					if not shield_in_the_way then
						
						if self._line_of_sight_t and not self._last_vis_check_status and t - self._line_of_sight_t > 1 then
							self._shoot_history.focus_start_t = t
							self._shoot_history.m_last_pos = mvector3.copy(target_pos)
						end
						
						self._line_of_sight_t = t
						shoot = true
					end
				end
			end

			if shoot and self._shoot_t < t then
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
					--[[else
						Application:stack_dump_error("autofire_rounds is missing from weapon usage tweak data!", self._weap_tweak.usage)]]
					end

					self._autoshots_fired = 0

					if vis_state == 1 and not ext_anim.recoil and not ext_anim.base_no_recoil and not ext_anim.move then
						if self._ext_movement._anim_global == "tank" then
							self._ext_movement:play_redirect("recoil_single")
						else
							self._ext_movement:play_redirect("recoil_auto")
						end
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
					mvec3_dir(target_vec, shoot_from_pos, spread_pos)

					local fired = self._weapon_base:singleshot(shoot_from_pos, target_vec, dmg_mul, autotarget, nil, nil, nil, self._attention.unit)

					if fired then
						if vis_state == 1 and not ext_anim.base_no_recoil and not ext_anim.move then
							self._ext_movement:play_redirect("recoil_single")
						end

						local recoil_1 = self._weap_tweak.custom_single_fire_rate or falloff.recoil[1]
						local recoil_2 = self._weap_tweak.custom_single_fire_rate and self._weap_tweak.custom_single_fire_rate * #self._falloff or falloff.recoil[2]
						local lerp_dis = math.min(1, target_dis / self._falloff[#self._falloff].r)
						local shoot_delay = math.lerp(recoil_1, recoil_2, lerp_dis)

						if self._common_data.is_suppressed and not Global.game_settings.one_down then
							shoot_delay = shoot_delay * 1.5
						end

						self._shoot_t = t + shoot_delay
					end
				end
			end
		end
	end

	if self._ext_anim.base_need_upd then
		self._ext_movement:upd_m_head_pos()
	end
end

function CopActionShoot:check_melee_start(t, attention, target_dis, autotarget, shoot_from_pos)
	if (not self._common_data.melee_countered_t or t - self._common_data.melee_countered_t > 15) and self._melee_timeout_t < t then
		--das' a lot of sanity checks
		if not attention then
			return false
		end

		if not attention.unit then
			return false
		end

		if not alive(attention.unit) then
			return false
		end

		if not attention.unit.base then
			return false
		end

		if not attention.unit:base() then
			return false
		end

		if attention.unit:base().is_husk_player then --does not affect clients locally
			return false
		end

		if not attention.unit.character_damage then
			return false
		end

		if not attention.unit:character_damage() then
			return false
		end

		if not attention.unit:base().sentry_gun and not attention.unit:character_damage().damage_melee then --sentries take bullet damage, but check for damage_melee for anything else
			return false
		end

		if not autotarget and attention.unit:character_damage().dead and attention.unit:character_damage():dead() then --target is dead
			return false
		end

		local melee_weapon = self._unit:base():melee_weapon()
		local is_weapon = melee_weapon == "weapon"
		--[[local melee_weapon_data = nil

		if tweak_data.weapon.npc_melee[melee_weapon] then
			melee_weapon_data = tweak_data.weapon.npc_melee[melee_weapon]
		end]]

		local melee_range = nil
		--[[melee_range = melee_weapon_data and melee_weapon_data.stats and melee_weapon_data.stats.range

		if melee_range then
			melee_range = melee_range - 20
		else]]
			melee_range = autotarget and 130 or 180 --higher for NPC vs NPC so that they can hit each other more often and easily
		--end

		if target_dis <= melee_range then
			local my_fwd = mvector3.copy(self._ext_movement:m_head_rot():z())
			local target_pos = Vector3()

			mvector3.set(target_pos, my_fwd)
			mvector3.multiply(target_pos, melee_range)
			mvector3.add(target_pos, shoot_from_pos)

			local obstructed_by_geometry = self._unit:raycast("ray", shoot_from_pos, target_pos, "sphere_cast_radius", 20, "slot_mask", managers.slot:get_mask("world_geometry", "vehicles"), "ray_type", "body melee", "report")

			if not obstructed_by_geometry then
				local electrical_melee = not is_weapon and tweak_data.weapon.npc_melee[melee_weapon] and tweak_data.weapon.npc_melee[melee_weapon].electrical
				local target_has_shield = alive(attention.unit:inventory() and attention.unit:inventory()._shield_unit)
				local target_is_covered_by_shield = self._unit:raycast("ray", shoot_from_pos, target_pos, "sphere_cast_radius", 20, "slot_mask", managers.slot:get_mask("enemy_shield_check"), "ray_type", "body melee", "report")

				if autotarget then
					if not target_is_covered_by_shield then
						return true
					end
				elseif attention.unit:base().sentry_gun then
					if not electrical_melee then --since it'll probably be worse most of the time rather than just shooting at it
						if not target_is_covered_by_shield then
							return true
						end
					end
				else
					if target_has_shield then
						if target_is_covered_by_shield then
							local can_be_knocked = attention.unit:base():char_tweak().damage.shield_knocked and not attention.unit:base().is_phalanx and not attention.unit:character_damage():is_immune_to_shield_knockback()

							if can_be_knocked then
								return true
							end
						else
							if electrical_melee then
								local can_be_tased = attention.unit:base():char_tweak().can_be_tased == nil or attention.unit:base():char_tweak().can_be_tased

								if can_be_tased then
									local anim_data = attention.unit:anim_data()

									if anim_data then
										if anim_data.act or anim_data.tase or anim_data.hurt or anim_data.bleedout then
											return false
										end
									end

									return true
								end
							else
								return true
							end
						end
					else
						if not target_is_covered_by_shield then
							if electrical_melee then
								local can_be_tased = attention.unit:base():char_tweak().can_be_tased == nil or attention.unit:base():char_tweak().can_be_tased

								if can_be_tased then
									local anim_data = attention.unit:anim_data()

									if anim_data then
										if anim_data.act or anim_data.tase or anim_data.hurt or anim_data.bleedout then
											return false
										end
									end

									return true
								end
							else
								return true
							end
						end
					end
				end
			end
		end
	end

	return false
end

function CopActionShoot:_get_unit_shoot_pos(t, pos, dis, w_tweak, falloff, i_range, shooting_local_player)
	local shoot_hist = self._shoot_history
	local focus_delay, focus_prog = nil

	if shoot_hist.focus_delay then
		focus_delay = 1 * shoot_hist.focus_delay
		local focus_t = t - shoot_hist.focus_start_t
		focus_prog = focus_delay > 0 and focus_t / focus_delay

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
		local falloff_range_dis1 = dis - prev_falloff.r
		local falloff_range_dis2 = falloff.r - prev_falloff.r
		dis_lerp = math.min(1, falloff_range_dis1 / falloff_range_dis2)
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
	
	if Global.game_settings.incsmission then
		if managers.crime_spree then
			local copaccmultcs = managers.crime_spree:get_acc_mult() or 1
			
			hit_chance = hit_chance * copaccmultcs
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

function CopActionShoot:_chk_start_melee(target_vec, target_dis, autotarget, target_pos)
	local melee_weapon = self._unit:base():melee_weapon()
	local is_weapon = melee_weapon == "weapon"
	local redir_name = is_weapon and "melee" or "melee_item"
	local tank_melee = nil

	if self._unit:base():has_tag("tank") and melee_weapon == "fists" then
		redir_name = "melee" --use tank_melee unique punching animation as originally intended
		tank_melee = true
	end

	if is_weapon and self._weap_tweak.usage == "mini" then
		redir_name = "melee_bayonet" --bash with the front of the minigun's barrel like in first person
		tank_melee = nil
	end

	local state = self._ext_movement:play_redirect(redir_name)

	if state then
		if not is_weapon and not tank_melee then
			local anim_attack_vars = self._common_data.char_tweak.melee_anims or {
				"var1",
				"var2"
			}

			local melee_var = self:_pseudorandom(#anim_attack_vars)

			self._common_data.machine:set_parameter(state, anim_attack_vars[melee_var], 1)

			local param = tweak_data.weapon.npc_melee[melee_weapon].animation_param

			self._common_data.machine:set_parameter(state, param, 1)
		end

		if is_weapon then
			local anim_speed = self._w_usage_tweak.melee_speed or 1

			self._common_data.machine:set_speed(state, anim_speed)
		else
			local anim_speed = self._common_data.char_tweak.melee_weapon_speed or 1

			self._common_data.machine:set_speed(state, anim_speed)
		end

		--let other players see when NPCs attempt a melee attack instead of nothing (not actually cosmetic as melee attacks are tied to the animation, but the necessary checks are there)
		managers.network:session():send_to_peers_synched("play_distance_interact_redirect", self._unit, redir_name)

		self._melee_timeout_t = TimerManager:game():time() + (self._w_usage_tweak.melee_retry_delay and math.lerp(self._w_usage_tweak.melee_retry_delay[1], self._w_usage_tweak.melee_retry_delay[2], self:_pseudorandom()) or 1)

		--CopActionShoot.play_melee_sound(melee_weapon, "equip", self._unit)
		--CopActionShoot.play_melee_sound(melee_weapon, "hit_air", self._unit)
	else
		debug_pause_unit(self._common_data.unit, "[CopActionShoot:_chk_start_melee] redirect failed in state", self._common_data.machine:segment_state(Idstring("base")), self._common_data.unit)
	end

	return state and true
end

function CopActionShoot:anim_clbk_melee_strike()
	local shoot_from_pos = self._shoot_from_pos
	local my_fwd = mvector3.copy(self._ext_movement:m_head_rot():z())
	local target_pos = Vector3()

	--[[if self._attention then
		local att_char_dmg = self._attention.unit and self._attention.unit:character_damage()

		if att_char_dmg and att_char_dmg.shoot_pos_mid then
			local fwd_vec = Vector3()
			local att_shoot_pos = Vector3()
			att_char_dmg:shoot_pos_mid(att_shoot_pos)

			mvector3.direction(fwd_vec, mvector3.copy(shoot_from_pos), att_shoot_pos)
			my_fwd = fwd_vec
		end
	end]]

	mvector3.set(target_pos, my_fwd)
	mvector3.multiply(target_pos, 180)
	mvector3.add(target_pos, shoot_from_pos)

	local hit_local_player = true
	local melee_slot_mask = managers.slot:get_mask("bullet_impact_targets_no_police") --ignore teammates of the attacking unit
	melee_slot_mask = melee_slot_mask + 3 --just consider player husks as obstructions for enemies, they won't take damage

	if managers.groupai:state():is_unit_team_AI(self._unit) or managers.groupai:state():is_enemy_converted_to_criminal(self._unit) then --override for Jokers and team AI
		melee_slot_mask = managers.slot:get_mask("bullet_impact_targets_no_criminals")
		hit_local_player = false
	end

	--similar to player melee attacks, use a sphere ray instead of just a normal plain ray
	local col_ray = self._unit:raycast("ray", shoot_from_pos, target_pos, "sphere_cast_radius", 20, "slot_mask", melee_slot_mask, "ray_type", "body melee")
	local draw_debug_spheres = false

	if draw_debug_spheres then
		local draw_duration = 3
		local new_brush = col_ray and Draw:brush(Color.red:with_alpha(0.5), draw_duration) or Draw:brush(Color.white:with_alpha(0.5), draw_duration)
		local sphere_draw_pos = col_ray and col_ray.position or target_pos
		local sphere_draw_size = col_ray and 5 or 20
		new_brush:sphere(sphere_draw_pos, sphere_draw_size)
	end

	local local_player = managers.player:player_unit()

	--a more clean method of determining if the local player should get hit or not, without cancelling the attack if the player can't get hit, like it did before
	--sadly, no raycasts I tried so far (even with target_unit/target_body) seem to be able to hit the local player
	if hit_local_player and alive(local_player) and not self._unit:character_damage():is_friendly_fire(local_player) then
		local range_against_player = 165
		local player_head_pos = local_player:movement():m_head_pos()
		local player_vec = Vector3()
		local player_distance = mvector3.direction(player_vec, mvector3.copy(shoot_from_pos), mvector3.copy(player_head_pos))

		if player_distance <= range_against_player then
			if not col_ray or col_ray.distance > player_distance or not self._unit:raycast("ray", shoot_from_pos, player_head_pos, "sphere_cast_radius", 5, "slot_mask", melee_slot_mask, "ray_type", "body melee", "report") then
				local flat_vec = Vector3()

				mvector3.set(flat_vec, player_vec)
				mvector3.set_z(flat_vec, 0)
				mvector3.normalize(flat_vec)

				local min_dot = math.lerp(0, 0.4, player_distance / range_against_player)
				local fwd_dot = mvector3.dot(my_fwd, flat_vec)

				if fwd_dot >= min_dot then
					col_ray = {
						unit = local_player,
						position = player_head_pos,
						ray = mvector3.copy(player_vec:normalized())
					}

					if draw_debug_spheres then
						local draw_duration = 3
						local new_brush = Draw:brush(Color.yellow:with_alpha(0.5), draw_duration)
						local sphere_draw_pos = player_head_pos
						local sphere_draw_size = 5
						new_brush:sphere(sphere_draw_pos, sphere_draw_size)
					end
				end
			end
		end
	end

	if col_ray and alive(col_ray.unit) then
		local melee_weapon = self._unit:base():melee_weapon()
		local is_weapon = melee_weapon == "weapon"
		local electrical_melee = not is_weapon and tweak_data.weapon.npc_melee[melee_weapon] and tweak_data.weapon.npc_melee[melee_weapon].electrical
		local damage = self._w_usage_tweak.melee_dmg

		if is_weapon or managers.groupai:state():is_unit_team_AI(self._unit) then
			--nothing
		elseif tweak_data.weapon.npc_melee[melee_weapon] and tweak_data.weapon.npc_melee[melee_weapon].damage then
			damage = tweak_data.weapon.npc_melee[melee_weapon].damage
		end

		local dmg_mul = is_weapon and 1 or self._common_data.char_tweak.melee_weapon_dmg_multiplier or 1
		dmg_mul = dmg_mul * (1 + self._unit:base():get_total_buff("base_damage"))
		damage = damage * dmg_mul

		managers.game_play_central:physics_push(col_ray) --the function already has sanity checks so it's fine to just use it like this

		local hit_unit = col_ray.unit
		local character_unit, shield_knock = nil
		local defense_data = nil

		if Network:is_server() and hit_unit:in_slot(managers.slot:get_mask("enemy_shield_check")) and alive(hit_unit:parent()) then
			local can_be_knocked = not hit_unit:parent():base().is_phalanx and hit_unit:parent():base():char_tweak().damage.shield_knocked and not hit_unit:parent():character_damage():is_immune_to_shield_knockback()

			if can_be_knocked then
				shield_knock = true
				character_unit = hit_unit:parent()
			end
		end

		character_unit = character_unit or hit_unit

		if character_unit == local_player then
			local action_data = {
				variant = "melee",
				damage = damage,
				weapon_unit = self._weapon_unit,
				attacker_unit = self._unit,
				melee_weapon = melee_weapon,
				push_vel = mvector3.copy(col_ray.ray:with_z(0.1)) * 600,
				tase_player = electrical_melee,
				col_ray = col_ray
			}

			defense_data = character_unit:character_damage():damage_melee(action_data)
		else
			if Network:is_server() then --only allow melee damage against NPCs for the host (used in case an enemy targets a client locally but hits something else instead)
				if character_unit:character_damage() then
					if character_unit:base().sentry_gun then
						local action_data = {
							variant = "bullet",
							damage = damage,
							weapon_unit = self._weapon_unit,
							attacker_unit = self._unit,
							origin = shoot_from_pos,
							col_ray = col_ray
						}

						defense_data = character_unit:character_damage():damage_bullet(action_data) --sentries/turrets lack a melee damage function
					else
						if character_unit:character_damage().damage_melee and not character_unit:base().is_husk_player then --ignore player husks as the damage CAN be synced and dealt to them
							local variant = shield_knock and "melee" or electrical_melee and "taser_tased" or "melee"
							local action_data = {
								variant = variant,
								damage = shield_knock and 0 or damage,
								damage_effect = damage * 2,
								weapon_unit = is_weapon and self._weapon_unit or nil,
								attacker_unit = self._unit,
								name_id = melee_weapon,
								shield_knock = shield_knock,
								col_ray = col_ray
							}

							defense_data = character_unit:character_damage():damage_melee(action_data)
						end
					end
				end

				if character_unit:damage() and col_ray.body:extension() and col_ray.body:extension().damage then --damage objects with body extensions (like glass), just like players are able to
					damage = math.clamp(damage, 0, 63)

					col_ray.body:extension().damage:damage_melee(self._unit, col_ray.normal, col_ray.position, col_ray.ray, damage)
					managers.network:session():send_to_peers_synched("sync_body_damage_melee", col_ray.body, self._unit, col_ray.normal, col_ray.position, col_ray.ray, damage)
				end
			end
		end

		if defense_data and defense_data ~= "friendly_fire" then
			if defense_data == "countered" then
				self._common_data.melee_countered_t = TimerManager:game():time()

				--use a sphere ray to properly attack the countered unit by getting a proper direction, position of the hit, etc
				local counter_ray = World:raycast("ray", character_unit:movement():m_head_pos(), self._unit:movement():m_com(), "sphere_cast_radius", 20, "target_unit", self._unit)
				local action_data = {
					damage_effect = 1,
					damage = 0,
					variant = "counter_spooc",
					attacker_unit = character_unit,
					col_ray = counter_ray,
					attack_dir = counter_ray.ray,
					name_id = character_unit == local_player and managers.blackmarket:equipped_melee_weapon() or character_unit:base():melee_weapon()
				}

				self._unit:character_damage():damage_melee(action_data)
			else
				if not shield_knock and character_unit ~= local_player and character_unit:character_damage() and not character_unit:character_damage()._no_blood then
					if character_unit:base().sentry_gun then
						managers.game_play_central:play_impact_sound_and_effects({
							no_decal = true,
							col_ray = col_ray
						})
					else
						managers.game_play_central:sync_play_impact_flesh(col_ray.position, col_ray.ray)
					end
				end
			end
		end
	end
end