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
	old_init(self, unit)
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
			next_upd_t = t + 0.07
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
			elseif self._ext_anim.run and self._ext_anim.move_fwd and not self:chk_action_forbidden("act") and Global.game_settings.one_down then
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
