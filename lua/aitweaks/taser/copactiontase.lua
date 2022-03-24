local mvec3_set = mvector3.set
local mvec3_set_z = mvector3.set_z
local mvec3_dot = mvector3.dot
local mvec3_copy = mvector3.copy
local mvec3_norm = mvector3.normalize
local mvec3_dir = mvector3.direction
local mvec3_lerp = mvector3.lerp
local math_min = math.min
local math_lerp = math.lerp
local math_up = math.UP
local temp_vec1 = Vector3()
local temp_vec2 = Vector3()
local temp_vec3 = Vector3()
local bezier_curve = {
	0,
	0,
	1,
	1
}

CopActionTase._ik_presets = CopActionShoot._ik_presets
CopActionTase.set_ik_preset = CopActionShoot.set_ik_preset
CopActionTase._begin_ik_spine = CopActionShoot._begin_ik_spine
CopActionTase._get_blend_ik_spine = CopActionShoot._get_blend_ik_spine
CopActionTase._begin_ik_r_arm = CopActionShoot._begin_ik_r_arm
CopActionTase._stop_ik_r_arm = CopActionShoot._stop_ik_r_arm
CopActionTase._stop_ik_spine = CopActionShoot._stop_ik_spine
CopActionTase._get_blend_ik_r_arm = CopActionShoot._get_blend_ik_r_arm
CopActionTase._set_ik_updator = CopActionShoot._set_ik_updator

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
	self._is_server = Network:is_server()
	local attention = common_data.attention

	if not attention or not attention.unit then
		if self._is_server then
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
	self._falloff = weapon_usage_tweak.FALLOFF or {
		{
			dmg_mul = 1,
			r = 1500,
			acc = {
				0.2,
				0.6
			},
			recoil = {
				0.45,
				0.8
			},
			mode = {
				1,
				3,
				3,
				1
			}
		}
	}
	self._tase_distance = weapon_usage_tweak.tase_distance or 1500
	self._sphere_radius = 10
	self._line_of_fire_slotmask = managers.slot:get_mask("world_geometry", "vehicles", "enemy_shield_check")
	self._discharge_line_of_fire_slotmask = managers.slot:get_mask("world_geometry", "vehicles")
	self._weapon_obj_fire = weapon_unit:get_object(Idstring("fire"))
	self._shield = alive(self._ext_inventory._shield_unit) and self._ext_inventory._shield_unit or nil
	self._firing_at_husk = action_desc.firing_at_husk or nil

	local shoot_from_pos = self._ext_movement:m_head_pos()
	self._shoot_from_pos = shoot_from_pos

	if self._is_server then
		self._ext_movement:set_stance_by_code(3)
	else
		self._turn_allowed = true
	end

	if managers.modifiers and managers.modifiers:check_boolean("TotalAnarchy") or tweak_data:difficulty_to_index(Global.game_settings.difficulty) > 5 then
		self._shorter_tase_delay = true
	end

	local preset_name = self._ext_anim.base_aim_ik or "spine"
	local preset_data = self._ik_presets[preset_name]
	self._ik_preset = preset_data
	self[preset_data.start](self)

	self:on_attention(attention)

	CopActionAct._create_blocks_table(self, action_desc.block_desc)

	self._skipped_frames = 1

	return true
end

function CopActionTase:on_attention(attention)
	if self._expired then
		self._attention = attention

		return
	end

	local needs_to_expire = nil

	if self._is_server then
		if self._attention then
			needs_to_expire = true
		end
	elseif self._client_attention_set or not attention or not attention.unit then
		needs_to_expire = true
	end

	if needs_to_expire then
		self[self._ik_preset.stop](self)

		if self._aim_transition then
			self._aim_transition = nil
			self._get_target_pos = nil
		end

		if self._discharging then
			self._tasing_local_unit:movement():on_tase_ended()

			self._discharging = nil
		end

		if self._tasing_local_unit and self._tasing_player then
			self._tasing_local_unit:movement():on_targetted_for_attack(false, self._unit)
		end

		self._tasing_player = nil
		self._tasing_local_unit = nil
		self._discharging_on_husk = nil
		self._firing_at_husk = nil
		self.update = self._upd_empty
		self._attention = attention

		if self._is_server then
			self._expired = true
		end

		return
	end

	if not self._is_server then
		self._client_attention_set = true
	end

	local t = TimerManager:game():time()

	self[self._ik_preset.start](self)

	local vis_state = self._ext_base:lod_stage()

	if vis_state and vis_state < 3 and self[self._ik_preset.get_blend](self) > 0 then
		self._aim_transition = {
			duration = 0.333,
			start_t = t,
			start_vec = mvec3_copy(self._common_data.look_vec)
		}
		self._get_target_pos = self._get_transition_target_pos
	else
		self._aim_transition = nil
		self._get_target_pos = nil
	end

	self._mod_enable_t = t + 0.5

	self.update = nil
	self._attention = attention

	local shoot_delay = 0.8

	if self._shorter_tase_delay then
		shoot_delay = 0.4
	end
	
	self._num_shocks = 0

	self._tasing_local_unit = nil
	self._tasing_player = nil

	local attention_unit = attention.unit

	if self._is_server then
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

function CopActionTase:_get_target_pos(shoot_from_pos, attention)
	local target_pos, target_vec, target_dis, autotarget = nil
	
	if attention and attention.unit:base().is_local_player then
		target_pos = temp_vec1

		mvector3.set(target_pos, attention.unit:position() + math.UP * 140)

		if self._shooting_player then
			autotarget = true
		end
	elseif attention.handler then
		target_pos = temp_vec1

		mvector3.set(target_pos, attention.handler:get_attention_m_pos())

		if self._shooting_player then
			autotarget = true
		end
	elseif attention.unit then
		if self._shooting_player then
			autotarget = true
		end

		target_pos = temp_vec1

		attention.unit:character_damage():shoot_pos_mid(target_pos)
	else
		target_pos = attention.pos
	end

	target_vec = temp_vec3
	target_dis = mvec3_dir(target_vec, shoot_from_pos, target_pos)

	return target_pos, target_vec, target_dis, autotarget
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
	local target_pos, target_vec, target_dis, autotarget = nil

	if attention.unit and attention.unit:base().is_local_player then
		target_pos = temp_vec1

		mvector3.set(target_pos, attention.unit:position() + math.UP * 140)

		if self._shooting_player then
			autotarget = true
		end
	elseif attention.handler then
		target_pos = temp_vec1

		mvector3.set(target_pos, attention.handler:get_attention_m_pos())

		if self._shooting_player then
			autotarget = true
		end
	elseif attention.unit then
		if self._shooting_player then
			autotarget = true
		end

		target_pos = temp_vec1

		attention.unit:character_damage():shoot_pos_mid(target_pos)
	else
		target_pos = attention.pos
	end

	target_vec = temp_vec3
	target_dis = mvec3_dir(target_vec, shoot_from_pos, target_pos)

	mvec3_lerp(target_vec, transition.start_vec, target_vec, prog)

	return target_pos, target_vec, target_dis, autotarget
end

function CopActionTase:on_exit()
	if self._modifier_on then
		self[self._ik_preset.stop](self)
	end

	if self._tase_effect then
		World:effect_manager():fade_kill(self._tase_effect)
	end

	if self._discharging then
		self._tasing_local_unit:movement():on_tase_ended()
	end

	self._discharging_on_husk = nil
	self._firing_at_husk = nil

	if self._is_server then
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

	local vis_state = self._ext_base:lod_stage()
	vis_state = vis_state or 4

	if not self._discharging and vis_state ~= 1 then
		if self._skipped_frames < vis_state * 3 then
			self._skipped_frames = self._skipped_frames + 1

			return
		else
			self._skipped_frames = 1
		end
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

			if not active_actions[2] or active_actions[2]:type() == "idle" then
				local queued_actions = self._common_data.queued_actions

				if not queued_actions or not queued_actions[1] and not queued_actions[2] then
					if not self._ext_movement:chk_action_forbidden("turn") then
						local fwd_dot_flat = mvec3_dot(tar_vec_flat, fwd)

						if fwd_dot_flat < 0.96 then
							local spin = tar_vec_flat:to_polar_with_reference(fwd, math_up).spin
							local new_action_data = {
								body_part = 2,
								type = "turn",
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
		if self._firing_at_husk then
			if self._attention.unit:movement():tased() then
				
				if self._tase_effect then
					World:effect_manager():fade_kill(self._tase_effect)
				end

				self._tase_effect = World:effect_manager():spawn({
					force_synch = true,
					effect = Idstring("effects/pd2_mod_hh/particles/character/taser_hit"),
					parent = self._weapon_obj_fire
				})

				self._tasered_sound = self._unit:sound():play("tasered_3rd", nil)

				if vis_state == 1 then
					self._ext_movement:play_redirect("recoil_single")
				end

				self._discharging_on_husk = true
				self._firing_at_husk = nil
			end
		elseif self._discharging_on_husk then
			if not self._next_shock_t then
				self._next_shock_t = t + 0.75
			elseif self._next_shock_t < t then
				self._num_shocks = self._num_shocks + 1
				self._next_shock_t = t + 0.75
			end
		
			if not self._attention.unit:movement():tased() then
				self._discharging_on_husk = nil
				self._unit:character_damage()._tasing = nil
				
				if self._num_shocks >= 4 then
					if self._attention.unit:movement()._play_taser_boom then
						self._attention.unit:movement():_play_taser_boom()
					end
				end
				
				if self._is_server then
					self._expired = true
				else
					self.update = self._upd_empty
				end
			end
		elseif self._discharging then
			local cancel_tase = nil
			
			if self._tasing_player then
				if self._num_shocks >= 3 then
					if not self._played_warning_effect then
						local warning = World:effect_manager():spawn({
							effect = Idstring("effects/pd2_mod_hh/particles/character/taser_warning"),
							parent = self._weapon_obj_fire
						})
									
						if warning then
							self._played_warning_effect = true
						end
					end
				elseif not self._next_shock_t then
					self._num_shocks = self._num_shocks + 1
					self._next_shock_t = t + 0.75
				elseif self._next_shock_t < t then
					self._num_shocks = self._num_shocks + 1
					self._next_shock_t = t + 0.75
				end
			end

			if not self._tasing_local_unit:movement():tased() then
				cancel_tase = true
			else
				if self._shield then
					cancel_tase = self._unit:raycast("ray", self._shoot_from_pos, target_pos, "slot_mask", self._discharge_line_of_fire_slotmask, "sphere_cast_radius", self._sphere_radius, "ignore_unit", self._shield, "report")
				else
					cancel_tase = self._unit:raycast("ray", self._shoot_from_pos, target_pos, "slot_mask", self._discharge_line_of_fire_slotmask, "sphere_cast_radius", self._sphere_radius, "report")
				end
			end

			if cancel_tase then
				if self._is_server then
					self._expired = true
				else
					self._tasing_local_unit:movement():on_tase_ended()
					self._tasing_local_unit:movement():on_targetted_for_attack(false, self._unit)
					self._tasing_player = nil
					self._tasing_local_unit = nil

					self._discharging = nil
					self.update = self._upd_empty
				end
				
				self._unit:character_damage()._tasing = nil
			end
		elseif target_vec and self._common_data.allow_fire then
			if not self._played_sound_this_once then
				self._played_sound_this_once = true
				self._unit:sound():play("taser_charge", nil)
			end
			
			if PD2THHSHIN and PD2THHSHIN:GlintEnabled() then
				if self._tasing_player then
					if not self._played_glint then
						local ilovethisfuckingeffectlol = World:effect_manager():spawn({
							effect = Idstring("effects/pd2_mod_hh/particles/character/pretase_glint"),
							parent = self._unit:get_object(Idstring("Head"))
						})
						
						if ilovethisfuckingeffectlol then
							self._played_glint = true
						end
					end
				end
			end
			
			if self._shoot_t and self._shoot_t > t then				
			
				if self._tase_effect then
					World:effect_manager():fade_kill(self._tase_effect)
				end

				self._tase_effect = World:effect_manager():spawn({
					force_synch = true,
					effect = Idstring("effects/payday2/particles/character/taser_thread"),
					parent = self._weapon_obj_fire
				})
			elseif self._shoot_t and self._mod_enable_t < t and self._shoot_t < t then
				if self._tasing_local_unit and target_dis < self._tase_distance then
					local record = managers.groupai:state():criminal_record(self._tasing_local_unit:key())
					
					if not record or record.status or self._tasing_local_unit:movement():chk_action_forbidden("hurt") or self._tasing_local_unit:movement():zipline_unit() then
						if self._is_server then
							self._expired = true
						end
					else
						local is_obstructed = nil
		
						if self._shield then
							is_obstructed = self._unit:raycast("ray", self._shoot_from_pos, target_pos, "slot_mask", self._line_of_fire_slotmask, "sphere_cast_radius", self._sphere_radius, "ignore_unit", self._shield, "report")
						else
							is_obstructed = self._unit:raycast("ray", self._shoot_from_pos, target_pos, "slot_mask", self._line_of_fire_slotmask, "sphere_cast_radius", self._sphere_radius, "report")
						end

						if not is_obstructed then
							if self._tase_effect then
								World:effect_manager():fade_kill(self._tase_effect)
							end

							self._tase_effect = World:effect_manager():spawn({
								force_synch = true,
								effect = Idstring("effects/pd2_mod_hh/particles/character/taser_hit"),
								parent = self._weapon_obj_fire
							})

							self._common_data.ext_network:send("action_tase_event", 3)

							local attack_data = {
								attacker_unit = self._unit
							}
							
							self._unit:character_damage()._tasing = true
							self._tasing_local_unit:character_damage():damage_tase(attack_data)
							CopDamage._notify_listeners("on_criminal_tased", self._unit, self._tasing_local_unit)

							self._discharging = true

							if not self._tasing_local_unit:base().is_local_player then
								self._tasered_sound = self._unit:sound():play("tasered_3rd", nil)
							end

							if vis_state == 1 then
								self._ext_movement:play_redirect("recoil_single")
							end

							self._shoot_t = nil
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

function CopActionTase:fire_taser()
	self._firing_at_husk = true
end

function CopActionTase:get_husk_interrupt_desc()
	local action_desc = {
		block_type = "action",
		body_part = 3,
		type = "tase",
		firing_at_husk = self._firing_at_husk or self._discharging_on_husk
	}

	return action_desc
end

function CopActionTase:save(save_data)
	save_data.type = "tase"
	save_data.body_part = self._body_part
	save_data.firing_at_husk = self._discharging or self._firing_at_husk or self._discharging_on_husk
end

function CopActionTase:_upd_ik_spine(target_vec, fwd_dot, t)
	if fwd_dot > 0.7 then
		if not self._modifier_on then
			self._modifier_on = true

			self._machine:force_modifier(self._modifier_name)

			self._mod_enable_t = t + 0.5
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

function CopActionTase:_upd_ik_r_arm(target_vec, fwd_dot, t)
	if fwd_dot > 0.7 then
		if not self._modifier_on then
			self._modifier_on = true

			self._machine:force_modifier(self._head_modifier_name)
			self._machine:force_modifier(self._r_arm_modifier_name)

			self._mod_enable_t = t + 0.5
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

function CopActionTase:on_destroy()
	if self._tase_effect then
		World:effect_manager():fade_kill(self._tase_effect)
	end
	
	self._unit:character_damage()._tasing = nil

	if self._malfunction_clbk_id then
		managers.enemy:remove_delayed_clbk(self._malfunction_clbk_id)

		self._malfunction_clbk_id = nil
	end
end
