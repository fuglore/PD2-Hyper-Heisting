local ids_upper_body = Idstring("upper_body")
local mvec3_set = mvector3.set
local mvec3_set_z = mvector3.set_z
local mvec3_norm = mvector3.normalize
local mvec3_dist_sq = mvector3.distance_sq
local mvec3_dir = mvector3.direction
local mvec3_dot = mvector3.dot
local mvec3_lerp = mvector3.lerp
local mvec3_copy = mvector3.copy
local temp_vec1 = Vector3()
local temp_vec2 = Vector3()
local temp_vec3 = Vector3()
local math_up = math.UP
local math_bezier = math.bezier
local bezier_curve = {
	0,
	0,
	1,
	1
}

CopActionReload._ik_presets = CopActionShoot._ik_presets
CopActionReload._upd_ik_spine = CopActionShoot._upd_ik_spine
CopActionReload._upd_ik_r_arm = CopActionShoot._upd_ik_r_arm
CopActionReload.set_ik_preset = CopActionShoot.set_ik_preset
CopActionReload._begin_ik_spine = CopActionShoot._begin_ik_spine
CopActionReload._get_blend_ik_spine = CopActionShoot._get_blend_ik_spine
CopActionReload._begin_ik_r_arm = CopActionShoot._begin_ik_r_arm
CopActionReload._stop_ik_r_arm = CopActionShoot._stop_ik_r_arm
CopActionReload._stop_ik_spine = CopActionShoot._stop_ik_spine
CopActionReload._get_blend_ik_r_arm = CopActionShoot._get_blend_ik_r_arm
CopActionReload._set_ik_updator = CopActionShoot._set_ik_updator

function CopActionReload:init(action_desc, common_data)
	self._common_data = common_data
	self._ext_base = common_data.ext_base
	self._ext_movement = common_data.ext_movement
	self._ext_anim = common_data.ext_anim
	self._ext_inventory = common_data.ext_inventory
	self._body_part = action_desc.body_part
	self._machine = common_data.machine
	self._unit = common_data.unit

	self._blocks = action_desc.blocks or {}
	self._blocks.light_hurt = -1

	local weapon_unit = self._ext_inventory:equipped_unit()

	if not weapon_unit then
		return false
	end

	self._weapon_unit = weapon_unit
	self._weapon_base = self._weapon_unit:base()

	local weap_tweak = self._weapon_unit:base():weapon_tweak_data()
	local weapon_usage_tweak = common_data.char_tweak.weapon[weap_tweak.usage]
	self._weap_tweak = weap_tweak
	self._w_usage_tweak = weapon_usage_tweak
	self._is_looped = weap_tweak.reload == "looped" and true or nil
	self._reload_speed = weapon_usage_tweak.RELOAD_SPEED or 1
	
	if self._weap_tweak.reload_speed_mul then
		local reload_mul = self._weap_tweak.reload_speed_mul
		self._reload_speed = self._reload_speed * reload_mul		
	end

	self._is_server = Network:is_server()

	local t = TimerManager:game():time()
	local anim_multiplier = self._reload_speed
	local reload_type = 0

	if self._is_looped then
		if self._weap_tweak.looped_reload_speed then
			anim_multiplier = anim_multiplier * self._weap_tweak.looped_reload_speed
		end

		local sound_prefix = self._weap_tweak.sounds and self._weap_tweak.sounds.prefix
		local single_reload = sound_prefix == "nagant_npc" or sound_prefix == "ching_npc" or sound_prefix == "ecp_npc" --using sounds because it's vanilla weapontweakdata friendly
		local magazine_size, current_ammo_in_mag = self._weapon_base:ammo_info()

		if action_desc.idle_reload then
			if not self._is_server and action_desc.idle_reload ~= 0 then
				magazine_size = action_desc.idle_reload
			else
				magazine_size = magazine_size - current_ammo_in_mag
				reload_type = 1
			end
		end

		local loop_amount = single_reload and 1 or magazine_size

		self._loop_stop_t = t + (1 * ((0.45 * loop_amount) / anim_multiplier))
	end

	self._speed_mul = anim_multiplier

	local shoot_from_pos = self._ext_movement:m_head_pos()
	self._shoot_from_pos = shoot_from_pos

	if self._is_server then
		common_data.ext_network:send("reload_weapon", reload_type, 1)
	else
		self._turn_allowed = true
		self._turn_speed = nil

		local difficulty_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)

		if not self._ext_movement._anim_global == "tank" then
			if difficulty_index == 8 then
				self._turn_speed = 1.75
			elseif difficulty_index == 6 or difficulty_index == 7 then
				self._turn_speed = 1.5
			else
				self._turn_speed = 1.25
			end
		end
	end

	self._converted_chk = self._unit:brain().is_converted_chk and self._unit:brain():is_converted_chk() and true or nil

	if self._ext_anim.reload or self:_play_reload() then
		local preset_name = self._ext_anim.base_aim_ik or "spine"
		local preset_data = self._ik_presets[preset_name]
		self._ik_preset = preset_data
		self[preset_data.start](self)

		--local testing = true
		if managers.modifiers and managers.modifiers:check_boolean("Magnetstorm")  then
			if self._ext_base:has_tag("law") and not self._execute_storm_t then
				self._execute_storm_t = t + 0.75
				local tase_effect_table = self._unit:character_damage() ~= nil and self._unit:character_damage()._tase_effect_table

				if tase_effect_table and not self._storm_effect then
					self._storm_effect = World:effect_manager():spawn(tase_effect_table)
				end
			end
		end

		self:on_attention(common_data.attention)

		CopActionAct._create_blocks_table(self, self._blocks)

		self._skipped_frames = 1

		return true
	else
		--cat_print("george", "[CopActionReload:init] failed in", self._machine:segment_state(Idstring("base")))
	end
end

function CopActionReload:update(t)
	if Global.game_settings.incsmission then
		if self._execute_storm_t and not self._executed_storm and not self._converted_chk and self._ext_anim.reload and self._execute_storm_t < t then
			self:execute_magnet_storm(t)
		end
	end

	if self._is_looped then
		if self._loop_stop_t and self._loop_stop_t < t then
			self._weapon_base:on_reload()

			self._expired = true
			self._ext_movement:play_redirect("reload_looped_exit")
		end
	elseif not self._ext_anim.reload then
		self._weapon_base:on_reload()

		self._expired = true
	end

	local vis_state = self._ext_base:lod_stage()
	vis_state = vis_state or 4

	if vis_state ~= 1 then
		if self._skipped_frames < vis_state * 3 then
			self._skipped_frames = self._skipped_frames + 1

			return
		else
			self._skipped_frames = 1
		end
	end

	local target_pos, target_vec = nil

	if self._attention then
		local shoot_from_pos = self._shoot_from_pos
		target_pos, target_vec = self:_get_target_pos(shoot_from_pos, self._attention, t)

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
								speed = self._turn_speed,
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

	if self._ext_anim.base_need_upd then
		self._ext_movement:upd_m_head_pos()
	end
end

function CopActionReload:execute_magnet_storm(t)
	--log("cuuunt")

	World:effect_manager():spawn({
		effect = Idstring("effects/pd2_mod_hh/particles/weapons/explosion/electric_explosion"),
		position = self._ext_movement:m_com()
	})

	self._unit:sound():play("c4_explode_metal")

	local player = managers.player:player_unit()

	if alive(player) then
		local pl_movement = player:movement()
		local sq_dist_range = 90000
		local sq_dist = mvec3_dist_sq(mvec3_copy(self._ext_movement:m_com()), mvec3_copy(pl_movement:m_head_pos()))

		if sq_dist <= sq_dist_range then
			if pl_movement:is_taser_attack_allowed() then
				local player_movement_chk = not pl_movement:tased() and pl_movement:current_state_name() == "standard" or pl_movement:current_state_name() == "carry" or pl_movement:current_state_name() == "bipod"

				if player_movement_chk and not self._unit:raycast("ray", self._ext_movement:m_com(), pl_movement:m_head_pos(), "slot_mask", managers.slot:get_mask("world_geometry", "vehicles"), "sphere_cast_radius", 10, "report") then
					if pl_movement:current_state_name() == "bipod" then
						pl_movement._current_state:exit(nil, "tased")
					end

					if pl_movement.on_non_lethal_electrocution then
						pl_movement:on_non_lethal_electrocution()
					end

					managers.player:set_player_state("tased")
				end
			end
		end
	end

	self._executed_storm = true
	self._execute_storm_t = nil

	if self._storm_effect then
		World:effect_manager():fade_kill(self._storm_effect)
		self._storm_effect = nil
	end
end

function CopActionReload:_play_reload()
	local redir_name = self._is_looped and "reload_looped" or "reload"
	local redir_res = self._ext_movement:play_redirect(redir_name)

	if redir_res then
		if self._speed_mul then
			self._machine:set_speed(redir_res, self._speed_mul)
		end
	else
		cat_print("george", "[CopActionReload:_play_reload] redirect failed in", self._machine:segment_state(Idstring("base")))

		return
	end

	return redir_res
end

function CopActionReload:on_attention(attention)
	if attention then
		self[self._ik_preset.start](self)

		local vis_state = self._ext_base:lod_stage()

		if vis_state and vis_state < 3 and self[self._ik_preset.get_blend](self) > 0 then
			local t = TimerManager:game():time()
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

		self._mod_enable_t = TimerManager:game():time() + 0.5
	else
		self[self._ik_preset.stop](self)

		if self._aim_transition then
			self._aim_transition = nil
			self._get_target_pos = nil
		end
	end

	self._attention = attention
end

function CopActionReload:on_exit()
	if self._modifier_on then
		self[self._ik_preset.stop](self)
	end

	if self._expired then
		if self._is_server then
			if self._attention and self._attention.reaction and self._attention.reaction >= AIAttentionObject.REACT_AIM then
				self._ext_movement:set_stance_by_code(3)
			else
				self._ext_movement:set_stance_by_code(2)
			end
		end
	else
		self._expired = true
		self._weapon_base:on_reload()

		if self._is_looped then
			self._ext_movement:play_redirect("up_idle")
		end
	end
end

function CopActionReload:_get_transition_target_pos(shoot_from_pos, attention, t)
	local transition = self._aim_transition
	local prog = (t - transition.start_t) / transition.duration

	if prog > 1 then
		self._aim_transition = nil
		self._get_target_pos = nil

		return self:_get_target_pos(shoot_from_pos, attention)
	end

	prog = math_bezier(bezier_curve, prog)
	local target_pos, target_vec = nil

	if attention.handler then
		target_pos = temp_vec1

		mvec3_set(target_pos, attention.handler:get_attention_m_pos())
	elseif attention.unit then
		target_pos = temp_vec1

		attention.unit:character_damage():shoot_pos_mid(target_pos)
	else
		target_pos = attention.pos
	end

	target_vec = temp_vec3
	mvec3_dir(target_vec, shoot_from_pos, target_pos)
	mvec3_lerp(target_vec, transition.start_vec, target_vec, prog)

	return target_pos, target_vec
end

function CopActionReload:_get_target_pos(shoot_from_pos, attention)
	local target_pos, target_vec = nil

	if attention.handler then
		target_pos = temp_vec1

		mvec3_set(target_pos, attention.handler:get_attention_m_pos())
	elseif attention.unit then
		target_pos = temp_vec1

		attention.unit:character_damage():shoot_pos_mid(target_pos)
	else
		target_pos = attention.pos
	end

	target_vec = temp_vec3
	mvec3_dir(target_vec, shoot_from_pos, target_pos)

	return target_pos, target_vec
end

function CopActionReload:save(save_data)
	if not self._ext_anim.reload then
		return
	end

	save_data.type = "reload"
	save_data.body_part = 3

	local start_data = {
		anim_interrupt_t = self._machine:segment_real_time(ids_upper_body)
	}

	if self._is_looped then
		start_data.rounds_left = self._loop_stop_t - TimerManager:game():time()
	end

	save_data.start_data = start_data
end

function CopActionReload:on_inventory_event(event)
	local new_weapon_unit = self._ext_inventory:equipped_unit()

	if new_weapon_unit then
		self._weapon_unit = new_weapon_unit
		self._weapon_base = new_weapon_unit:base()
		self._weap_tweak = self._weapon_base:weapon_tweak_data()
	else
		self._ext_movement:play_redirect("up_idle")

		self._weapon_unit = nil
		self._weapon_base = nil
		self._weap_tweak = nil

		self.update = self._upd_empty

		self._expired = true
	end
end

