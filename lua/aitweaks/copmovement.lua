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
	
	old_init(self, unit)
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
			next_upd_t = t + 0.033
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
			next_upd_t = t + 0.033
		}
	else
		suppression.transition = nil
		suppression.value = end_value

		self._machine:set_global("sup", end_value)
	end

	self._action_common_data.is_suppressed = state and true or nil

	if Network:is_server() and state then
		if self._tweak_data.allowed_poses and (self._tweak_data.allowed_poses.crouch or self._tweak_data.allowed_poses.stand) or self:chk_action_forbidden("walk") then
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
								walk = -1
							}
						}

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
					end
				end
			elseif self._ext_anim.idle and (not self._active_actions[2] or self._active_actions[2]:type() == "idle") and not self:chk_action_forbidden("act") then
				if Global.game_settings.one_down then
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
						walk = -1
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
