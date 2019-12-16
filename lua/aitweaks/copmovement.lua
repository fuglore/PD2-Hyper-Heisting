local mvec3_set = mvector3.set
local mvec3_set_z = mvector3.set_z
local mvec3_lerp = mvector3.lerp
local mvec3_add = mvector3.add
local mvec3_sub = mvector3.subtract
local mvec3_mul = mvector3.multiply
local mvec3_norm = mvector3.normalize
local mvec3_len = mvector3.length
local mrot_set = mrotation.set_yaw_pitch_roll
local temp_vec1 = Vector3()
local temp_vec2 = Vector3()
local temp_vec3 = Vector3()

local old_init = CopMovement.init
local action_variants = {
	security = {
		idle = CopActionIdle,
		act = CopActionAct,
		walk = CopActionWalk,
		turn = CopActionTurn,
		hurt = CopActionHurt,
		stand = CopActionStand,
		crouch = CopActionCrouch,
		shoot = CopActionShoot,
		reload = CopActionReload,
		spooc = ActionSpooc,
		tase = CopActionTase,
		dodge = CopActionDodge,
		warp = CopActionWarp,
		healed = CopActionHealed
	}
}
local security_variant = action_variants.security

function CopMovement:init(unit)
	
	CopMovement._action_variants.tank_ftsu = clone(security_variant)
	CopMovement._action_variants.tank_ftsu.walk = TankCopActionWalk
	CopMovement._action_variants.spooc_heavy = security_variant
	CopMovement._action_variants.fbi_xc45 = security_variant
	
	old_init(self, unit)
end

function CopMovement:is_taser_attack_allowed() --lol
	return
end

function CopMovement:_change_stance(stance_code, instant)
	if self._tweak_data.allowed_stances then
		if stance_code == 1 and not self._tweak_data.allowed_stances.ntl then
			return
		elseif stance_code == 2 and not self._tweak_data.allowed_stances.hos then
			return
		elseif stance_code == 3 and not self._tweak_data.allowed_stances.cbt then
			return
		end
	end

	local stance = self._stance

	if instant then
		if stance.transition or stance.code ~= stance_code then
			stance.transition = nil
			stance.code = stance_code
			stance.name = CopMovement._stance.names[stance_code]

			for i = 1, 3, 1 do
				stance.values[i] = 0
			end

			stance.values[stance_code] = 1

			for i, v in ipairs(stance.values) do
				self._machine:set_global(CopMovement._stance.names[i], v)
			end
		end
	else
		local end_values = {}

		if stance_code == 4 then
			if stance.transition then
				end_values = stance.transition.end_values
			else
				for i, value in ipairs(stance.values) do
					end_values[i] = value
				end
			end
		elseif stance.transition then
			end_values = {
				0,
				0,
				0,
				stance.transition.end_values[4]
			}
		else
			end_values = {
				0,
				0,
				0,
				stance.values[4]
			}
		end

		end_values[stance_code] = 1

		if stance_code ~= 4 then
			stance.code = stance_code
			stance.name = CopMovement._stance.names[stance_code]
		end

		local delay = nil
		local vis_state = self._ext_base:lod_stage()

		if vis_state then
			delay = CopMovement._stance.blend[stance_code]

			if vis_state > 2 then
				delay = delay * 0.5
			end
		else
			stance.transition = nil

			if stance_code ~= 1 then
				self:_chk_play_equip_weapon()
			end

			local names = CopMovement._stance.names

			for i, v in ipairs(end_values) do
				if v ~= stance.values[i] then
					stance.values[i] = v

					self._machine:set_global(names[i], v)
				end
			end

			return
		end

		local start_values = {}

		for _, value in ipairs(stance.values) do
			table.insert(start_values, value)
		end

		local t = TimerManager:game():time()
		local transition = {
			end_values = end_values,
			start_values = start_values,
			duration = delay,
			start_t = t,
			next_upd_t = t + 0.066
		}
		stance.transition = transition
	end

	if stance_code ~= 1 then
		self:_chk_play_equip_weapon()
	end

	self:enable_update()
end

function CopMovement:on_suppressed(state)
	local suppression = self._suppression
	local end_value = state and 1 or 0
	
	if end_value ~= suppression.value then
		local t = TimerManager:game():time()
		local duration = 0.5 * math.abs(end_value - suppression.value)
		suppression.transition = {
			end_val = end_value,
			start_val = suppression.value,
			duration = duration,
			start_t = t,
			next_upd_t = t + 0.066
		}
	else
		suppression.transition = nil
		suppression.value = end_value

		self._machine:set_global("sup", end_value)
	end

	self._action_common_data.is_suppressed = state and true or nil
	
	local pose_chk = self._tweak_data.allowed_poses and self._tweak_data.allowed_poses.crouch or self._tweak_data.allowed_poses and self._tweak_data.allowed_poses.stand
	
	if Network:is_server() and state then
		if pose_chk or self:chk_action_forbidden("walk") or not self._unit:base():has_tag("law") then
			--nothing
		else
			local crumble_chance = self._tweak_data and self._tweak_data.crumble_chance or 0.25
			-- the fact i need to do this is why i hate everything about the panic effect
			if state == "panic" and not self:chk_action_forbidden("act") and math.random() < crumble_chance and not self._tweak_data.no_fumbling then
				if self._ext_anim.run and self._ext_anim.move_fwd then
					if Global.game_settings.one_down then
						local action_desc = {
							clamp_to_graph = true,
							type = "act",
							body_part = 1,
							variant = "e_nl_slide_fwd_4m",
							blocks = {
								action = -1,
								act = -1,
								tase = -1,
								bleedout = -1,
								dodge = -1,
								walk = -1,
								hurt = -1,
								heavy_hurt = -1
							}
						}
						
						--self._unit:sound():say("lk3b", true) 
						self:action_request(action_desc)
					else
						local action_desc = {
							clamp_to_graph = true,
							type = "act",
							body_part = 1,
							variant = "e_so_sup_fumble_run_fwd",
							blocks = {
								action = -1,
								walk = -1
							}
						}
						
						--self._unit:sound():say("hr01")
						self:action_request(action_desc)					
					end
				else
					local function debug_fumble(result, from, to)
					end
					
					local vec_from = temp_vec1
					local vec_to = temp_vec2
					local ray_params = {
						allow_entry = false,
						trace = true,
						tracker_from = self:nav_tracker(),
						pos_from = vec_from,
						pos_to = vec_to
					}
					local allowed_fumbles = {
						"e_so_sup_fumble_inplace_3",
					}
					
					if self._tweak_data.allow_pass_out and math.random() < 0.3 then
						table.insert(allowed_fumbles, "e_sp_dizzy_fall_get_up") --light swats and commons have a decent chance of doing this, heavies and up dont
					end
					
					local allow = nil
					mvec3_set(vec_from, self:m_pos())
					mvec3_set(vec_to, self:m_rot():y())
					mvec3_mul(vec_to, -100)
					mvec3_add(vec_to, self:m_pos())

					allow = not managers.navigation:raycast(ray_params)

					debug_fumble(allow, vec_from, vec_to)

					if allow then
						table.insert(allowed_fumbles, "e_so_sup_fumble_inplace_1")
					end

					mvec3_set(vec_from, self:m_pos())
					mvec3_set(vec_to, self:m_rot():x())
					mvec3_mul(vec_to, 200)
					mvec3_add(vec_to, self:m_pos())

					allow = not managers.navigation:raycast(ray_params)

					debug_fumble(allow, vec_from, vec_to)

					if allow then
						table.insert(allowed_fumbles, "e_so_sup_fumble_inplace_2")
					end

					mvec3_set(vec_from, self:m_pos())
					mvec3_set(vec_to, self:m_rot():x())
					mvec3_mul(vec_to, -200)
					mvec3_add(vec_to, self:m_pos())

					allow = not managers.navigation:raycast(ray_params)

					debug_fumble(allow, vec_from, vec_to)

					if allow then
						table.insert(allowed_fumbles, "e_so_sup_fumble_inplace_4")
					end

					if #allowed_fumbles > 0 then
						local action_desc = {
							body_part = 1,
							type = "act",
							variant = allowed_fumbles[math.random(#allowed_fumbles)],
							blocks = {
								action = -1,
								walk = -1
							}
						}

						self:action_request(action_desc)
						--self._unit:sound():say("hr01")
					end
				end
			elseif self._ext_anim.idle and (not self._active_actions[2] or self._active_actions[2]:type() == "idle") and not self:chk_action_forbidden("act") then
				if Global.game_settings.one_down and not self._ext_anim.crouch and not self:chk_action_forbidden("act") then
					local action_desc = {
						clamp_to_graph = true,
						type = "act",
						body_part = 1,
						variant = "suppressed_reaction", --they crouch into cover instead of freezing on shin shootout.
						blocks = {
							walk = -1
						}
					}
					
					self:action_request(action_desc)
				else
					local action_desc = {
						clamp_to_graph = true,
						type = "act",
						body_part = 1,
						variant = "surprised", --they freeze in their spot and play the "surprised" animation when out of shin shootout.
						blocks = {
							walk = -1
						}
					}
					
					self:action_request(action_desc)
				end
			elseif self._ext_anim.run and not self:chk_action_forbidden("act") and Global.game_settings.one_down then
				local action_desc = {
					clamp_to_graph = true,
					type = "act",
					body_part = 1,
					variant = "e_nl_slide_fwd_4m",
					blocks = {
						action = -1,
						act = -1,
						tase = -1,
						bleedout = -1,
						dodge = -1,
						walk = -1,
						hurt = -1,
						heavy_hurt = -1
					}
				}

				self:action_request(action_desc)
			end
		end
	end

	self:enable_update()

	if Network:is_server() then
		managers.network:session():send_to_peers_synched("suppressed_state", self._unit, state and true or false)
	end

end

function CopMovement:damage_clbk(my_unit, damage_info)
	local hurt_type = damage_info.result.type

	if damage_info.variant == "explosion" or damage_info.variant == "bullet" or damage_info.variant == "fire" or damage_info.variant == "poison" then
		hurt_type = managers.modifiers:modify_value("CopMovement:HurtType", hurt_type)
	end

	if hurt_type == "stagger" then
		hurt_type = "heavy_hurt"
	end

	if hurt_type == "hurt" or hurt_type == "heavy_hurt" or hurt_type == "knock_down" then
		if self._anim_global and self._anim_global == "shield" then
			hurt_type = "expl_hurt"
		end
	end

	local block_type = hurt_type

	if hurt_type == "knock_down" or hurt_type == "expl_hurt" or hurt_type == "fire_hurt" or hurt_type == "poison_hurt" or hurt_type == "taser_tased" then
		block_type = "heavy_hurt"
	end

	if hurt_type == "death" and self._queued_actions then
		self._queued_actions = {}
	end

	if not hurt_type or Network:is_server() and self:chk_action_forbidden(block_type) then
		if hurt_type == "death" then
			debug_pause_unit(self._unit, "[CopMovement:damage_clbk] Death action skipped!!!", self._unit)
			Application:draw_cylinder(self._m_pos, self._m_pos + math.UP * 5000, 30, 1, 0, 0)

			for body_part, action in ipairs(self._active_actions) do
				if action then
					--print(body_part, action:type(), inspect(action._blocks))
				end
			end
		end

		return
	end

	if damage_info.variant == "stun" and alive(self._ext_inventory and self._ext_inventory._shield_unit) then
		hurt_type = "shield_knock"
		block_type = "shield_knock"
		damage_info.variant = "melee"
		damage_info.result = {
			variant = "melee",
			type = "shield_knock"
		}
		damage_info.shield_knock = true
	end

	if hurt_type == "death" then
		if self._rope then
			self._rope:base():retract()

			self._rope = nil
			self._rope_death = true

			if self._unit:sound().anim_clbk_play_sound then
				self._unit:sound():anim_clbk_play_sound(self._unit, "repel_end")
			end
		end

		if Network:is_server() then
			self:set_attention()
		else
			self:synch_attention()
		end
	end

	local attack_dir = damage_info.col_ray and damage_info.col_ray.ray or damage_info.attack_dir
	local hit_pos = damage_info.col_ray and damage_info.col_ray.position or damage_info.pos
	local lgt_hurt = hurt_type == "light_hurt"
	local body_part = lgt_hurt and 4 or 1
	local blocks = nil

	if not lgt_hurt then
		blocks = {
			act = -1,
			aim = -1,
			action = -1,
			tase = -1,
			walk = -1,
			light_hurt = -1
		}

		if hurt_type == "bleedout" then
			blocks.bleedout = -1
			blocks.hurt = -1
			blocks.heavy_hurt = -1
			blocks.hurt_sick = -1
			blocks.concussion = -1
		end

		if hurt_type == "shield_knock" then
			blocks.light_hurt = -1
			blocks.concussion = -1
		end

		if hurt_type == "concussion" or hurt_type == "counter_tased" then
			blocks.hurt = -1
			blocks.light_hurt = -1
			blocks.heavy_hurt = -1
			blocks.stagger = -1
			blocks.knock_down = -1
			blocks.counter_tased = -1
			blocks.hurt_sick = -1
			blocks.expl_hurt = -1
			blocks.counter_spooc = -1
			blocks.fire_hurt = -1
			blocks.taser_tased = -1
			blocks.poison_hurt = -1
			blocks.shield_knock = -1
			blocks.concussion = -1
		end
	end

	if damage_info.variant == "tase" then
		block_type = "bleedout"
	elseif hurt_type == "expl_hurt" or hurt_type == "fire_hurt" or hurt_type == "poison_hurt" or hurt_type == "taser_tased" then
		block_type = "heavy_hurt"
	else
		block_type = hurt_type
	end

	local client_interrupt = nil
	
	local horribly_long_hurt_chk = hurt_type == "light_hurt" or hurt_type == "hurt" and damage_info.variant ~= "tase" or hurt_type == "heavy_hurt" or hurt_type == "expl_hurt" or hurt_type == "shield_knock" or hurt_type == "counter_tased" or hurt_type == "taser_tased" or hurt_type == "counter_spooc" or hurt_type == "death" or hurt_type == "hurt_sick" or hurt_type == "fire_hurt" or hurt_type == "poison_hurt" or hurt_type == "concussion"

	if Network:is_client() and horribly_long_hurt_chk then
		client_interrupt = true
	end

	local tweak = self._tweak_data
	local action_data = nil

	if hurt_type == "healed" then
		if Network:is_client() then
			client_interrupt = true
		end

		action_data = {
			body_part = 3,
			type = "healed",
			client_interrupt = client_interrupt
		}
	else
		local death_severity_chk = tweak.damage.death_severity and tweak.damage.death_severity < damage_info.damage / tweak.HEALTH_INIT and "heavy" or "normal"
		action_data = {
			type = "hurt",
			block_type = block_type,
			hurt_type = hurt_type,
			variant = damage_info.variant,
			direction_vec = attack_dir,
			hit_pos = hit_pos,
			body_part = body_part,
			blocks = blocks,
			client_interrupt = client_interrupt,
			attacker_unit = damage_info.attacker_unit,
			death_type = death_severity_chk or "normal",
			ignite_character = damage_info.ignite_character,
			start_dot_damage_roll = damage_info.start_dot_damage_roll,
			is_fire_dot_damage = damage_info.is_fire_dot_damage,
			fire_dot_data = damage_info.fire_dot_data,
			is_synced = damage_info.is_synced --to check in copactionhurt and avoid syncing back to sender
		}
	end

	local request_action = Network:is_server() or not self:chk_action_forbidden(action_data)

	if damage_info.is_synced and (hurt_type == "knock_down" or hurt_type == "heavy_hurt") then
		request_action = false
	end

	if request_action then
		self:action_request(action_data)

		if hurt_type == "death" and self._queued_actions then
			self._queued_actions = {}
		end
	end
end
