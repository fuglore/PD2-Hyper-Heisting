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

	if Network:is_server() and state and not (self._tweak_data.allowed_poses or self._tweak_data.allowed_poses.crouch) and not (self._tweak_data.allowed_poses or self._tweak_data.allowed_poses.stand) and not self:chk_action_forbidden("walk") then
		if state == "panic" and not self:chk_action_forbidden("act") then
			if self._ext_anim.run and self._ext_anim.move_fwd then
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
					"e_so_sup_fumble_inplace_3"
				}
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
			local action_desc = {
				clamp_to_graph = true,
				type = "act",
				body_part = 1,
				variant = "suppressed_reaction",
				blocks = {
					walk = -1
				}
			}

			self:action_request(action_desc)
		end
	end

	self:enable_update()

	if Network:is_server() then
		managers.network:session():send_to_peers_synched("suppressed_state", self._unit, state and true or false)
	end
end