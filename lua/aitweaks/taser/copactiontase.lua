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
local bezier_curve = {
	0,
	0,
	1,
	1
}

CopActionTase._ik_presets = {
	spine = {
		update = "_update_ik_spine",
		start = "_begin_ik_spine",
		get_blend = "_get_blend_ik_spine",
		stop = "_stop_ik_spine"
	},
	r_arm = {
		update = "_update_ik_r_arm",
		start = "_begin_ik_r_arm",
		get_blend = "_get_blend_ik_r_arm",
		stop = "_stop_ik_r_arm"
	}
}

function CopActionTase:init(action_desc, common_data)
	self._common_data = common_data
	self._unit = common_data.unit
	self._ext_base = common_data.ext_base
	self._ext_movement = common_data.ext_movement
	self._ext_anim = common_data.ext_anim
	self._ext_brain = common_data.ext_brain
	self._ext_inventory = common_data.ext_inventory
	self._body_part = action_desc.body_part
	self._machine = common_data.machine
	local attention = common_data.attention

	if not attention or not attention.unit then
		if Network:is_server() then
			--debug_pause("[CopActionTase:init] no attention", inspect(action_desc))

			return
		end
	end

	local weapon_unit = self._ext_inventory:equipped_unit()

	if not weapon_unit then
		return
	end

	self._weapon_unit = weapon_unit
	self._weapon_base = weapon_unit:base()

	local weap_tweak = weapon_unit:base():weapon_tweak_data()
	local weapon_usage_tweak = common_data.char_tweak.weapon[weap_tweak.usage]
	self._weap_tweak = weap_tweak
	self._w_usage_tweak = weapon_usage_tweak
	self._falloff = weapon_usage_tweak.FALLOFF
	self._tase_distance = weapon_usage_tweak.tase_distance
	self._aim_delay = weapon_usage_tweak.aim_delay_tase or weapon_usage_tweak.aim_delay or {1, 1}
	self._sphere_radius = weapon_usage_tweak.tase_sphere_cast_radius or 30
	self._line_of_fire_slotmask = managers.slot:get_mask("world_geometry", "vehicles", "enemy_shield_check")
	self._weapon_obj_fire = weapon_unit:get_object(Idstring("fire"))

	local shoot_from_pos = self._ext_movement:m_head_pos()
	self._shoot_from_pos = shoot_from_pos
	self._turn_allowed = Network:is_client()

	local preset_name = self._ext_anim.base_aim_ik or "spine"
	local preset_data = self._ik_presets[preset_name]
	self._ik_preset = preset_data

	self[preset_data.start](self)

	self._skipped_frames = 1

	self:on_attention(attention)

	if Network:is_server() then
		self._ext_movement:set_stance_by_code(3)
	end

	CopActionAct._create_blocks_table(self, action_desc.block_desc)

	return true
end

function CopActionTase:on_attention(attention)
	if self._expired then
		self._attention = attention
	else
		local has_expired = nil

		if Network:is_server() then
			if self._attention then
				has_expired = true
			end
		elseif self._client_attention_set or not attention or not attention.unit then
			has_expired = true
		end

		if has_expired then
			self[self._ik_preset.stop](self)

			if self._aim_transition then
				self._aim_transition = nil
				self._get_target_pos = nil
			end

			if self._discharging then
				if self._tasing_local_unit then
					self._tasing_local_unit:movement():on_tase_ended()
				end

				self._discharging = nil
			end

			if self._tasing_local_unit and self._tasing_player then
				self._tasing_local_unit:movement():on_targetted_for_attack(false, self._unit)
			end

			self._tasing_player = nil
			self._tasing_local_unit = nil
			self.update = self._upd_empty
			self._attention = attention

			if Network:is_server() then
				self._expired = true
			end

			return
		end

		if Network:is_client() then
			self._client_attention_set = true
		end
	end

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

	self._mod_enable_t = TimerManager:game():time() + 0.5

	self.update = nil
	self._attention = attention

	local _, __, target_dis = self:_get_target_pos(self._shoot_from_pos, self._attention, t)
	local lerp_dis = math.min(1, target_dis / self._falloff[#self._falloff].r)
	local difficulty_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)
	local shoot_delay = difficulty_index > 5 and 0.5 or 1
	self._tasing_local_unit = nil
	self._tasing_player = nil

	local attention_unit = attention.unit

	if Network:is_server() then
		self._common_data.ext_network:send("action_tase_event", 1)

		if not attention_unit:base().is_husk_player then
			self._shoot_t = self._mod_enable_t + shoot_delay
			self._tasing_local_unit = attention_unit
			self._tasing_player = attention_unit:base().is_local_player and true or nil
		end
	elseif attention_unit:base().is_local_player then
		self._shoot_t = self._mod_enable_t + shoot_delay
		self._tasing_local_unit = attention_unit
		self._tasing_player = true
	end

	if self._tasing_local_unit and self._tasing_player then
		self._tasing_local_unit:movement():on_targetted_for_attack(true, self._unit)
	end
end

function CopActionTase:on_exit()
	if self._modifier_on then
		self[self._ik_preset.stop](self)
	end

	if self._tase_effect then
		World:effect_manager():fade_kill(self._tase_effect)
	end

	if self._discharging and self._tasing_local_unit then
		self._tasing_local_unit:movement():on_tase_ended()
	end

	if Network:is_server() then
		self._ext_movement:set_stance_by_code(2)
		self._unit:network():send("action_tase_event", 2)

		if self._expired then
			self._ext_movement:action_request({
				body_part = 3,
				type = "idle"
			})
		end
	end

	if self._tasered_sound then
		self._tasered_sound:stop()
		self._unit:sound():play("tasered_3rd_stop", nil)
	end

	if self._tasing_local_unit and self._tasing_player then
		self._tasing_local_unit:movement():on_targetted_for_attack(false, self._unit)
	end

	if self._malfunction_clbk_id then
		managers.enemy:remove_delayed_clbk(self._malfunction_clbk_id)

		self._malfunction_clbk_id = nil
	end
end

function CopActionTase:update(t)
	if self._expired then
		return
	end

	if Network:is_client() and self._ext_anim.act then --temporary fix for husks shooting local clients while doing animations like climbing
		return
	end

	local vis_state = self._ext_base:lod_stage()
	vis_state = vis_state or 4

	if vis_state == 1 then
		-- Nothing
	elseif self._skipped_frames < vis_state * 3 then
		self._skipped_frames = self._skipped_frames + 1

		return
	else
		self._skipped_frames = 1
	end

	local target_pos, target_vec, target_dis = nil

	if self._attention then
		target_pos, target_vec, target_dis = self:_get_target_pos(self._shoot_from_pos, self._attention, t)
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

	if not self._ext_anim.reload and not self._ext_anim.equip and not self._ext_anim.melee then
		if self._discharging then
			if self._tasing_local_unit then
				local cancel_tase = not self._tasing_local_unit:movement():tased() or self._unit:raycast("ray", self._shoot_from_pos, target_pos, "slot_mask", self._line_of_fire_slotmask, "sphere_cast_radius", 5, "report")

				if cancel_tase then
					if Network:is_server() then
						self._expired = true
					else
						self._tasing_local_unit:movement():on_tase_ended()
						self._tasing_local_unit:movement():on_targetted_for_attack(false, self._unit)
						self._tasing_player = nil
						self._tasing_local_unit = nil

						self._discharging = nil
						self.update = self._upd_empty
					end
				end
			elseif not self._attention.unit:movement():tased() then
				if Network:is_server() then
					self._expired = true
				else
					self.update = self._upd_empty
				end

				self._discharging = nil
			end
		elseif not self._tasing_local_unit and self._attention and self._attention.unit:movement():tased() then
			self._discharging = true
			self._tasered_sound = self._unit:sound():play("tasered_3rd", nil)
			self._ext_movement:play_redirect("recoil")
		elseif target_vec and self._mod_enable_t < t then
			if self._tase_effect then
				World:effect_manager():fade_kill(self._tase_effect)
			end

			self._tase_effect = World:effect_manager():spawn({
				force_synch = true,
				effect = Idstring("effects/payday2/particles/character/taser_thread"),
				parent = self._weapon_obj_fire
			})

			if not self._played_sound_this_once then
				if not self._ext_brain._last_charge_snd_play_t or self._ext_brain._last_charge_snd_play_t + 0.7 < t then
					self._played_sound_this_once = true
					self._ext_brain._last_charge_snd_play_t = t
					self._unit:sound():play("taser_charge", nil)
				end
			end

			if self._common_data.allow_fire and self._shoot_t and self._shoot_t < t then
				if self._tasing_local_unit and target_dis < self._tase_distance then
					local record = managers.groupai:state():criminal_record(self._tasing_local_unit:key())

					if not record or record.status or self._tasing_local_unit:movement():chk_action_forbidden("hurt") or self._tasing_local_unit:movement():zipline_unit() then
						if Network:is_server() then
							self._expired = true
						end
					else
						local is_obstructed = self._unit:raycast("ray", self._shoot_from_pos, target_pos, "slot_mask", self._line_of_fire_slotmask, "sphere_cast_radius", self._sphere_radius, "report")

						if not is_obstructed then
							self._common_data.ext_network:send("action_tase_event", 3)

							local attack_data = {
								attacker_unit = self._unit
							}

							self._tasing_local_unit:character_damage():damage_tase(attack_data)
							CopDamage._notify_listeners("on_criminal_tased", self._unit, self._tasing_local_unit)

							self._discharging = true

							if not self._tasing_local_unit:base().is_local_player then
								self._tasered_sound = self._unit:sound():play("tasered_3rd", nil)
							end

							self._ext_movement:play_redirect("recoil")

							self._shoot_t = nil
						end
					end
				elseif not self._tasing_local_unit then
					self._shoot_t = nil
				end
			end
		end
	end

	if self._ext_anim.base_need_upd then
		self._ext_movement:upd_m_head_pos()
	end
end

function CopActionTase:clbk_malfunction()
	self._malfunction_clbk_id = nil

	if self._expired then
		return
	end

	World:effect_manager():spawn({
		effect = Idstring("effects/payday2/particles/character/taser_stop"),
		position = self._ext_movement:m_com(),
		normal = math.UP
	})

	local attacker_pos = managers.player:player_unit() and managers.player:player_unit():movement():m_head_pos() or self._ext_movement:m_com() + self._ext_movement:m_rot():y() * 100
	local counter_ray = World:raycast("ray", attacker_pos, self._ext_movement:m_com(), "sphere_cast_radius", 20, "target_unit", self._unit)
	local action_data = {
		damage_effect = 1,
		damage = 0,
		variant = "counter_spooc",
		attacker_unit = managers.player:player_unit() or self._unit,
		col_ray = counter_ray,
		attack_dir = counter_ray.ray,
	}

	self._unit:character_damage():damage_melee(action_data)
end

function CopActionTase:_get_transition_target_pos(shoot_from_pos, attention, t)
	local transition = self._aim_transition
	local prog = (t - transition.start_t) / transition.duration

	if prog > 1 then
		self._aim_transition = nil
		self._get_target_pos = nil

		return self:_get_target_pos(shoot_from_pos, attention)
	end

	prog = math.bezier(bezier_curve, prog)
	local target_pos, target_vec, target_dis = nil

	if attention.handler then
		target_pos = temp_vec1

		mvector3.set(target_pos, attention.handler:get_attention_m_pos())
	elseif attention.unit then
		target_pos = temp_vec1

		attention.unit:character_damage():shoot_pos_mid(target_pos)
	else
		target_pos = attention.pos
	end

	target_vec = temp_vec3
	target_dis = mvec3_dir(target_vec, shoot_from_pos, target_pos)

	mvec3_lerp(target_vec, transition.start_vec, target_vec, prog)

	return target_pos, target_vec, target_dis
end

function CopActionTase:_get_target_pos(shoot_from_pos, attention)
	local target_pos, target_vec, target_dis = nil

	if attention.handler then
		target_pos = temp_vec1

		mvector3.set(target_pos, attention.handler:get_attention_m_pos())
	elseif attention.unit then
		target_pos = temp_vec1

		attention.unit:character_damage():shoot_pos_mid(target_pos)
	else
		target_pos = attention.pos
	end

	target_vec = temp_vec3
	target_dis = mvec3_dir(target_vec, shoot_from_pos, target_pos)

	return target_pos, target_vec, target_dis
end

function CopActionTase:set_ik_preset(preset_name)
	self[self._ik_preset.stop](self)

	local preset_data = self._ik_presets[preset_name]
	self._ik_preset = preset_data

	self[preset_data.start](self)
end

function CopActionTase:_begin_ik_spine()
	if self._modifier then
		return
	end

	self._modifier_name = Idstring("action_upper_body")
	self._modifier = self._machine:get_modifier(self._modifier_name)

	self:_set_ik_updator("_upd_ik_spine")

	self._modifier_on = nil
	self._mod_enable_t = nil
end

function CopActionTase:_stop_ik_spine()
	if not self._modifier then
		return
	end

	self._machine:allow_modifier(self._modifier_name)

	self._modifier_name = nil
	self._modifier = nil
	self._modifier_on = nil
end

function CopActionTase:_upd_ik_spine(target_vec, fwd_dot, t)
	if fwd_dot > 0.7 then
		if not self._modifier_on then
			self._modifier_on = true

			self._machine:force_modifier(self._modifier_name)

			self._mod_enable_t = t + 0.35
		end

		self._modifier:set_target_y(target_vec)
		mvec3_set(self._common_data.look_vec, target_vec)

		return target_vec
	else
		if self._modifier_on then
			self._modifier_on = nil

			self._machine:allow_modifier(self._modifier_name)
		end

		return nil
	end
end

function CopActionTase:_get_blend_ik_spine()
	return self._modifier:blend()
end

function CopActionTase:_begin_ik_r_arm()
	if self._head_modifier then
		return
	end

	self._head_modifier_name = Idstring("look_head")
	self._head_modifier = self._machine:get_modifier(self._head_modifier_name)
	self._r_arm_modifier_name = Idstring("aim_r_arm")
	self._r_arm_modifier = self._machine:get_modifier(self._r_arm_modifier_name)
	self._modifier_on = nil
	self._mod_enable_t = false

	self:_set_ik_updator("_upd_ik_r_arm")
end

function CopActionTase:_stop_ik_r_arm()
	if not self._head_modifier then
		return
	end

	self._machine:allow_modifier(self._head_modifier_name)
	self._machine:allow_modifier(self._r_arm_modifier_name)

	self._head_modifier_name = nil
	self._head_modifier = nil
	self._r_arm_modifier_name = nil
	self._r_arm_modifier = nil
	self._modifier_on = nil
end

function CopActionTase:_upd_ik_r_arm(target_vec, fwd_dot, t)
	if fwd_dot > 0.7 then
		if not self._modifier_on then
			self._modifier_on = true

			self._machine:force_modifier(self._head_modifier_name)
			self._machine:force_modifier(self._r_arm_modifier_name)

			self._mod_enable_t = t + 0.35
		end

		self._head_modifier:set_target_z(target_vec)
		self._r_arm_modifier:set_target_y(target_vec)
		mvec3_set(self._common_data.look_vec, target_vec)

		return target_vec
	else
		if self._modifier_on then
			self._modifier_on = nil

			self._machine:allow_modifier(self._head_modifier_name)
			self._machine:allow_modifier(self._r_arm_modifier_name)
		end

		return nil
	end
end

function CopActionTase:_get_blend_ik_r_arm()
	return self._r_arm_modifier:blend()
end

function CopActionTase:_set_ik_updator(name)
	self._upd_ik = self[name]
end

function CopActionTase:check_joker_counter()
	local taser_unit = self._unit
	local max_dis = 500
	local closest_minion_data, closest_dis = nil
	local record = managers.groupai:state():criminal_record(self._attention.unit:key())

	if record and record.minions then
		local minions = clone(record.minions)

		for _, minion_u_data in pairs(minions) do
			local dis = mvector3.distance(minion_u_data.m_pos, taser_unit:position())

			if (not closest_dis or dis < closest_dis) and (not max_dis or dis < max_dis) then --select the nearest owned Joker
				local obstructed = World:raycast("ray", minion_u_data.unit:movement():m_head_pos(), taser_unit:movement():m_head_pos(), "slot_mask", managers.slot:get_mask("AI_visibility"), "ray_type", "ai_vision")

				if not obstructed then
					closest_minion_data = minion_u_data
					closest_dis = dis
				end
			end
		end
	end

	if closest_minion_data then --if valid Joker was found, execute counter attack
		local tackle_dir = Vector3()
		mvector3.set(tackle_dir, taser_unit:position())
		mvector3.subtract(tackle_dir, closest_minion_data.m_pos)
		mvector3.set_z(tackle_dir, 0)
		mvector3.normalize(tackle_dir)

		self:execute_tackle_counter(closest_minion_data.unit, mvector3.copy(tackle_dir))
	end
end

function CopActionTase:execute_tackle_counter(minion_unit, direction)
	if not minion_unit:movement():chk_action_forbidden("act") then
		local action_data = {
			type = "dodge",
			body_part = 1,
			variation = "dive",
			side = "fwd",
			direction = direction,
			timeout = {0, 0},
			speed = 2,
			blocks = {
				act = -1,
				tase = -1,
				bleedout = -1,
				dodge = -1,
				walk = -1,
				action = -1,
				aim = -1,
				hurt = -1,
				heavy_hurt = -1
			}
		}

		local action = minion_unit:movement():action_request(action_data)

		if action then
			local taser_unit = self._unit

			if taser_unit then
				local action_data = {
					damage_effect = 1,
					damage = 0,
					variant = "counter_spooc",
					attacker_unit = minion_unit,
					col_ray = {
						body = taser_unit:body("body"),
						position = taser_unit:position() + math.UP * 100
					},
					attack_dir = direction
				}

				taser_unit:character_damage():damage_melee(action_data)
			end
		end
	end
end
