local mvec3_set = mvector3.set
local mvec3_z = mvector3.z
local mvec3_set_z = mvector3.set_z
local mvec3_sub = mvector3.subtract
local mvec3_norm = mvector3.normalize
local mvec3_add = mvector3.add
local mvec3_mul = mvector3.multiply
local mvec3_lerp = mvector3.lerp
local mvec3_cpy = mvector3.copy
local mvec3_set_l = mvector3.set_length
local mvec3_dot = mvector3.dot
local mvec3_cross = mvector3.cross
local mvec3_dis = mvector3.distance
local mvec3_dis_sq = mvector3.distance_sq
local mvec3_len = mvector3.length
local mvec3_rot = mvector3.rotate_with
local mrot_lookat = mrotation.set_look_at
local mrot_slerp = mrotation.slerp
local math_abs = math.abs
local math_max = math.max
local math_min = math.min
local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()
local tmp_vec3 = Vector3()
local tmp_vec4 = Vector3()
local temp_rot1 = Rotation()
local idstr_base = Idstring("base")
CopActionWalk = CopActionWalk or class()

CopActionWalk._walk_anim_velocities = {
	stand = {
		ntl = {
			walk = {
				bwd = 111.4,
				l = 124.5,
				fwd = 110,
				r = 124.5
			},
			run = {
				bwd = 416.77,
				l = 416.35,
				fwd = 457.98,
				r = 411.9
			}
		},
		cbt = {
			walk = {
				bwd = 187.5,
				l = 186.589,
				fwd = 194.2,
				r = 191.379
			},
			run = {
				bwd = 333.33,
				l = 333.33,
				fwd = 348.3,
				r = 340.62
			},
			sprint = {
				bwd = 434.1,
				l = 368.116,
				fwd = 546,
				r = 470.636
			}
		}
	},
	crouch = {
		cbt = {
			walk = {
				bwd = 184.38,
				l = 150.65,
				fwd = 164.87,
				r = 163.31
			},
			run = {
				bwd = 266.66,
				l = 282.35,
				fwd = 292.5,
				r = 266.66
			}
		}
	},
	wounded = {
		cbt = {
			walk = {
				bwd = 184.38,
				l = 150.65,
				fwd = 164.87,
				r = 163.31
			},
			run = {
				bwd = 266.66,
				l = 282.35,
				fwd = 292.5,
				r = 266.66
			}
		}
	}
}

CopActionWalk._walk_anim_velocities.stand.hos = CopActionWalk._walk_anim_velocities.stand.cbt
CopActionWalk._walk_anim_velocities.crouch.ntl = CopActionWalk._walk_anim_velocities.crouch.cbt
CopActionWalk._walk_anim_velocities.crouch.hos = CopActionWalk._walk_anim_velocities.crouch.cbt
CopActionWalk._walk_anim_velocities.wounded.hos = CopActionWalk._walk_anim_velocities.wounded.cbt

CopActionWalk._walk_anim_lengths = {
	stand = {
		ntl = {
			walk = {
				bwd = 42,
				l = 34,
				fwd = 42,
				r = 34
			},
			run = {
				bwd = 18,
				l = 18,
				fwd = 22,
				r = 20
			}
		},
		cbt = {
			walk = {
				bwd = 27,
				l = 29,
				fwd = 29,
				r = 29
			},
			run = {
				bwd = 18,
				l = 18,
				fwd = 22,
				r = 20
			},
			sprint = {
				bwd = 15,
				l = 18,
				fwd = 18,
				r = 19
			},
			run_start = {
				bwd = 26,
				l = 27,
				fwd = 31,
				r = 29
			},
			run_start_turn = {
				bwd = 26,
				l = 37,
				r = 26
			},
			run_stop = {
				bwd = 29,
				l = 34,
				fwd = 28,
				r = 30
			}
		}
	},
	crouch = {
		cbt = {
			walk = {
				bwd = 27,
				l = 28,
				fwd = 32,
				r = 30
			},
			run = {
				bwd = 18,
				l = 17,
				fwd = 20,
				r = 18
			},
			run_start = {
				bwd = 20,
				l = 29,
				fwd = 30,
				r = 22
			},
			run_start_turn = {
				bwd = 28,
				l = 21,
				r = 21
			},
			run_stop = {
				bwd = 30,
				l = 31,
				fwd = 27,
				r = 32
			}
		}
	},
	wounded = {
		cbt = {
			walk = {
				bwd = 27,
				l = 28,
				fwd = 32,
				r = 30
			},
			run = {
				bwd = 18,
				l = 17,
				fwd = 20,
				r = 18
			}
		}
	},
	panic = {
		ntl = {
			run = {
				bwd = 15,
				l = 15,
				fwd = 15,
				r = 16
			}
		}
	}
}

for pose, stances in pairs(CopActionWalk._walk_anim_lengths) do
	for stance, speeds in pairs(stances) do
		for speed, sides in pairs(speeds) do
			for side, speed in pairs(sides) do
				sides[side] = speed * 0.03333
			end
		end
	end
end

CopActionWalk._walk_anim_lengths.stand.hos = CopActionWalk._walk_anim_lengths.stand.cbt
CopActionWalk._walk_anim_lengths.crouch.ntl = CopActionWalk._walk_anim_lengths.crouch.cbt
CopActionWalk._walk_anim_lengths.crouch.hos = CopActionWalk._walk_anim_lengths.crouch.cbt
CopActionWalk._walk_anim_lengths.wounded.hos = CopActionWalk._walk_anim_lengths.wounded.cbt

CopActionWalk._matching_walk_anims = {
	fwd = {
		bwd = true
	},
	bwd = {
		fwd = true
	},
	l = {
		r = true
	},
	r = {
		l = true
	}
}

CopActionWalk._walk_side_rot = {
	fwd = Rotation(),
	bwd = Rotation(180),
	l = Rotation(-90),
	r = Rotation(90)
}

CopActionWalk._anim_movement = {
	stand = {
		run_stop_l = 141.21,
		run_stop_r = 141.41,
		run_stop_fwd = 162.78,
		run_stop_bwd = 115.59,
		run_start_turn_bwd = {
			ds = Vector3(19, -173, 0)
		},
		run_start_turn_l = {
			ds = Vector3(-287, 23, 0)
		},
		run_start_turn_r = {
			ds = Vector3(133, 16, 0)
		}
	},
	crouch = {
		run_stop_l = 98,
		run_stop_r = 120,
		run_stop_fwd = 108,
		run_stop_bwd = 75,
		run_start_turn_bwd = {
			ds = Vector3(0, -123, 0)
		},
		run_start_turn_l = {
			ds = Vector3(-66, 0, 0)
		},
		run_start_turn_r = {
			ds = Vector3(103, 0, 0)
		}
	}
}

CopActionWalk._anim_block_presets = {
	block_all = {
		light_hurt = -1,
		shoot = -1,
		turn = -1,
		stand = -1,
		action = -1,
		dodge = -1,
		crouch = -1,
		walk = -1,
		act = -1,
		hurt = -1,
		heavy_hurt = -1,
		idle = -1
	},
	block_lower = {
		light_hurt = -1,
		turn = -1,
		crouch = -1,
		stand = -1,
		idle = -1,
		dodge = -1,
		heavy_hurt = -1,
		walk = -1,
		act = -1,
		hurt = -1
	},
	block_upper = {
		crouch = -1,
		shoot = -1,
		action = -1,
		stand = -1
	},
	block_none = {
		crouch = -1,
		stand = -1
	}
}

function CopActionWalk:init(action_desc, common_data)
	self._common_data = common_data
	local action_desc = action_desc
	self._action_desc = action_desc
	self._unit = common_data.unit
	self._ext_movement = common_data.ext_movement
	self._ext_anim = common_data.ext_anim
	self._ext_base = common_data.ext_base
	self._ext_network = common_data.ext_network
	self._body_part = action_desc.body_part

	self:_init_ik()

	self._machine = common_data.machine

	self:on_attention(common_data.attention)

	self._stance = common_data.stance
	self._last_vel_z = 0
	self._cur_vel = 0
	self._end_rot = action_desc.end_rot

	CopActionAct._create_blocks_table(self, action_desc.blocks)

	self._persistent = action_desc.persistent
	self._haste = action_desc.variant
	self._start_t = TimerManager:game():time()
	self._no_walk = action_desc.no_walk
	self._no_strafe = action_desc.no_strafe
	self._last_pos = mvec3_cpy(common_data.pos)
	self._nav_path = action_desc.nav_path
	self._last_upd_t = self._start_t - 0.001
	self._sync = Network:is_server()
	self._skipped_frames = 1
	
	if not action_desc then
		log("huh?")
		return
	end
	
	if not action_desc.nav_path then
		log("what?")
		return
	end
	
	if self._ext_anim.needs_idle then
		self._waiting_full_blend = true

		self:_set_updator("_upd_wait_for_full_blend")

		if Network:is_server() then
			self._unit:brain():add_pos_rsrv("move_dest", {
				radius = 30,
				position = mvector3.copy(self._nav_point_pos(self._nav_path[#self._nav_path]))
			})
		end
	elseif not self:_init() then
		debug_pause_unit(self._unit, "[CopActionWalk:init] failed _init", self._unit)

		return
	end
	
	if self._unit:base():has_tag("spooc") then
		if not self._unit:character_damage():dead() and self._haste ~= "walk" then
			self._unit:sound():play(self._unit:base():char_tweak().spawn_sound_event)
			self._unit:damage():run_sequence_simple("turn_on_spook_lights")
		end
	end

	self._ext_movement:enable_update()

	self._is_civilian = CopDamage.is_civilian(self._unit:base()._tweak_table)

	return true
end

function CopActionWalk:_init()
	if not self:_sanitize() then
		return
	end

	self._init_called = true
	self._walk_velocity = self:_get_max_walk_speed()
	local action_desc = self._action_desc
	local common_data = self._common_data

	if self._is_civilian then
		print("common_data ", inspect(common_data))
	end

	if self._sync then
		if managers.groupai:state():all_AI_criminals()[common_data.unit:key()] then
			self._nav_link_invul = true
		end

		local nav_path = {}

		for i, nav_point in ipairs(self._nav_path) do
			if nav_point.x then
				table.insert(nav_path, nav_point)
			elseif alive(nav_point) then
				table.insert(nav_path, {
					element = nav_point:script_data().element,
					c_class = nav_point
				})
			else
				debug_pause_unit(self._unit, "dead nav_link", self._unit)

				return false
			end
		end

		self._nav_path = nav_path
	else
		if not action_desc.interrupted or not self._nav_path[1].x then
			table.insert(self._nav_path, 1, mvec3_cpy(common_data.pos))
		else
			self._nav_path[1] = mvec3_cpy(common_data.pos)
		end

		for i, nav_point in ipairs(self._nav_path) do
			if not nav_point.x then
				-- Lines 337-337
				function nav_point.element.value(element, name)
					return element[name]
				end

				-- Lines 338-338
				function nav_point.element.nav_link_wants_align_pos(element)
					return element.from_idle
				end
			end
		end

		if not action_desc.host_stop_pos_ahead and self._nav_path[2] then
			local ray_params = {
				tracker_from = common_data.nav_tracker,
				pos_to = self._nav_point_pos(self._nav_path[2])
			}

			if managers.navigation:raycast(ray_params) then
				table.insert(self._nav_path, 2, mvec3_cpy(self._ext_movement:m_host_stop_pos()))

				self._host_stop_pos_ahead = true
			end
		end
	end

	if action_desc.path_simplified and action_desc.persistent then
		if self._sync then
			local t_ins = table.insert
			local original_path = self._nav_path
			local new_nav_points = self._simplified_path
			local s_path = {}

			for _, nav_point in ipairs(original_path) do
				t_ins(s_path, nav_point.x and mvec3_cpy(nav_point) or nav_point)
			end

			if new_nav_points then
				for _, nav_point in ipairs(new_nav_points) do
					t_ins(s_path, nav_point.x and mvec3_cpy(nav_point) or nav_point)
				end
			end

			self._simplified_path = s_path
		else
			self._simplified_path = self._nav_path
		end
	elseif not managers.groupai:state():enemy_weapons_hot() then
		self._simplified_path = self._nav_path
	else
		local good_pos = mvector3.copy(common_data.pos)
		self._simplified_path = self._calculate_simplified_path(good_pos, self._nav_path, (not self._sync or self._common_data.stance.name == "ntl") and 2 or 1, self._sync, true)
	end

	if not self._simplified_path[2].x then
		self._next_is_nav_link = self._simplified_path[2]
	end

	self._curve_path_index = 1

	self:_chk_start_anim(CopActionWalk._nav_point_pos(self._simplified_path[2]))

	if self._start_run then
		self:_set_updator("_upd_start_anim_first_frame")
	end

	if not self._start_run_turn and mvec3_dis(self._nav_point_pos(self._simplified_path[2]), self._simplified_path[1]) > 400 and self._ext_base:lod_stage() then
		self._curve_path = self:_calculate_curved_path(self._simplified_path, 1, 1)
	else
		self._curve_path = {
			self._simplified_path[1],
			mvec3_cpy(self._nav_point_pos(self._simplified_path[2]))
		}
	end

	if #self._simplified_path == 2 and not self._NO_RUN_STOP and not self._no_walk and self._haste ~= "walk" and mvec3_dis(self._curve_path[2], self._curve_path[1]) >= 120 then
		self._chk_stop_dis = 210
	end

	if Network:is_server() then
		local sync_yaw = 0

		if self._end_rot then
			local yaw = self._end_rot:yaw()

			if yaw < 0 then
				yaw = 360 + yaw
			end

			sync_yaw = 1 + math.ceil(yaw * 254 / 360)
		end

		local sync_haste = self._haste == "walk" and 1 or 2
		local nav_link_act_index, nav_link_act_yaw = nil
		local next_nav_point = self._simplified_path[2]
		local nav_link_from_idle = false

		if next_nav_point.x then
			nav_link_act_index = 0
			nav_link_act_yaw = 1
		else
			nav_link_act_index = CopActionAct._get_act_index(CopActionAct, next_nav_point.element:value("so_action"))
			nav_link_act_yaw = next_nav_point.element:value("rotation")

			if nav_link_act_yaw < 0 then
				nav_link_act_yaw = 360 + nav_link_act_yaw
			end

			nav_link_act_yaw = math.ceil(255 * nav_link_act_yaw / 360)

			if nav_link_act_yaw == 0 then
				nav_link_act_yaw = 255
			end

			if next_nav_point.element:nav_link_wants_align_pos() then
				nav_link_from_idle = true
			else
				nav_link_from_idle = false
			end

			self._nav_link_synched_with_start = true
		end

		local pose_code = nil

		if not action_desc.pose then
			pose_code = 0
		elseif action_desc.pose == "stand" then
			pose_code = 1
		else
			pose_code = 2
		end

		local end_pose_code = nil

		if not action_desc.end_pose then
			end_pose_code = 0
		elseif action_desc.end_pose == "stand" then
			end_pose_code = 1
		else
			end_pose_code = 2
		end

		self._ext_network:send("action_walk_start", self._nav_point_pos(next_nav_point), nav_link_act_yaw, nav_link_act_index, nav_link_from_idle, sync_haste, sync_yaw, self._no_walk and true or false, self._no_strafe and true or false, pose_code, end_pose_code)
	else
		local pose = action_desc.pose

		if pose and not self._unit:anim_data()[pose] then
			if pose == "stand" then
				local action, success = CopActionStand:new(action_desc, self._common_data)
			else
				local action, success = CopActionCrouch:new(action_desc, self._common_data)
			end
		end
	end

	if Network:is_server() then
		self._unit:brain():rem_pos_rsrv("stand")
		self._unit:brain():add_pos_rsrv("move_dest", {
			radius = 30,
			position = mvector3.copy(self._simplified_path[#self._simplified_path])
		})
	end

	return true
end

function CopActionWalk:_nav_chk_walk(t, dt, vis_state)
	local s_path = self._simplified_path
	local c_path = self._curve_path
	local c_index = self._curve_path_index
	local vel = nil

	if self._ext_anim.act and self._ext_anim.walk then
		local new_anim_pos = self._unit:get_animation_delta_position()
		local anim_displacement = mvector3.length(new_anim_pos)
		vel = anim_displacement / dt

		if vel == 0 then
			return
		end
	else
		vel = self:_get_current_max_walk_speed(self._ext_anim.move_side or "fwd")

		if not self._sync and not self._start_run and self:_husk_needs_speedup() then
			vel = 1.25 * vel
		end
	end

	local walk_dis = vel * dt
	local footstep_length = 200
	local nav_advanced = nil
	local cur_pos = self._common_data.pos
	local new_pos, new_c_index, complete, upd_footstep, reservation_failed = nil

	while not self._end_of_curved_path do
		new_pos, new_c_index, complete = self._walk_spline(c_path, self._last_pos, c_index, walk_dis + footstep_length)
		upd_footstep = true

		if complete then
			if #s_path == 2 then
				self._end_of_curved_path = true

				if self._end_rot and not self._persistent then
					self._curve_path_end_rot = Rotation(mrotation.yaw(self._common_data.rot), 0, 0)
				end

				nav_advanced = true

				break
			elseif self._next_is_nav_link then
				self._end_of_curved_path = true
				self._nav_link_rot = Rotation(self._next_is_nav_link.element:value("rotation"), 0, 0)
				self._curve_path_end_rot = Rotation(mrotation.yaw(self._common_data.rot), 0, 0)

				break
			else
				self:_advance_simplified_path()

				local next_pos = self._nav_point_pos(s_path[2])

				if self._sync and not self._action_desc.path_simplified and not self._next_is_nav_link and s_path[3] and not self:_reserve_nav_pos(next_pos, self._nav_point_pos(s_path[3]), self._nav_point_pos(c_path[#c_path]), vel) then
					-- Nothing
				end

				if not s_path[1].x then
					debug_pause_unit(self._unit, "[CopActionWalk:_nav_chk_walk] missed nav_link", self._unit, inspect(s_path))

					s_path[1] = self._nav_point_pos(s_path[1])
				end

				local dis_sq = mvec3_dis_sq(s_path[1], next_pos)
				local new_c_path = nil

				if dis_sq > 490000 and not self._action_desc.path_simplified and self._ext_base:lod_stage() then
					new_c_path = self:_calculate_curved_path(s_path, 1, 1)
				else
					new_c_path = {
						s_path[1],
						next_pos
					}
				end

				local i = #c_path - 1

				while c_index <= i do
					table.insert(new_c_path, 1, c_path[i])

					i = i - 1
				end

				self._curve_path = new_c_path
				self._curve_path_index = 1
				c_path = self._curve_path
				c_index = 1

				if self._sync then
					self:_send_nav_point(next_pos)
				end

				nav_advanced = true
			end
		else
			break
		end
	end

	if upd_footstep then
		self._footstep_pos = new_pos:with_z(cur_pos.z)
	end

	local wants_walk_turn = nil

	if not reservation_failed then
		local wanted_vel = nil

		if self._turn_vel and vis_state == 1 then
			mvec3_set(tmp_vec1, c_path[c_index + 1])
			mvec3_set_z(tmp_vec1, mvec3_z(cur_pos))

			local dis = mvec3_dis_sq(tmp_vec1, cur_pos)

			if dis < 4900 then
				wanted_vel = math.lerp(self._turn_vel, vel, dis / 4900)
			end
		end

		wanted_vel = wanted_vel or vel

		if self._start_run then
			local delta_pos = self._common_data.unit:get_animation_delta_position()
			walk_dis = mvec3_len(delta_pos)
			self._cur_vel = walk_dis / dt
			self._cur_vel = math_min(self:_get_current_max_walk_speed(self._ext_anim.move_side or "fwd"), math_max(walk_dis / dt, self._start_max_vel))

			if self._cur_vel < self._start_max_vel then
				self._cur_vel = self._start_max_vel
				walk_dis = self._cur_vel * dt
			else
				self._start_max_vel = self._cur_vel
			end
		else
			local c_vel = self._cur_vel

			if c_vel ~= wanted_vel then
				local adj = vel * (c_vel < wanted_vel and 1.5 or 4) * dt
				c_vel = math.step(c_vel, wanted_vel, adj)
				self._cur_vel = c_vel
			end

			walk_dis = c_vel * dt
		end

		new_pos, new_c_index, complete = self._walk_spline(c_path, self._last_pos, c_index, walk_dis)

		if complete then
			if self._next_is_nav_link then
				self._end_of_path = true

				if self._sync then
					if alive(self._next_is_nav_link.c_class) and self._next_is_nav_link.element:nav_link_delay() then
						self._next_is_nav_link.c_class:set_delay_time(t + self._next_is_nav_link.element:nav_link_delay())
					else
						debug_pause_unit(self._unit, "dead nav_link", self._unit)
					end
				end
			elseif #s_path == 2 then
				self._end_of_path = true
			end
		elseif new_c_index ~= self._curve_path_index or nav_advanced then
			local future_pos = c_path[new_c_index + 2]
			local next_pos = c_path[new_c_index + 1]
			local back_pos = c_path[new_c_index]
			local cur_vec = tmp_vec2

			mvec3_set(cur_vec, next_pos)
			mvec3_sub(cur_vec, back_pos)
			mvec3_set_z(cur_vec, 0)

			if future_pos then
				mvec3_norm(cur_vec)

				local next_vec = tmp_vec1

				mvec3_set(next_vec, future_pos)
				mvec3_sub(next_vec, next_pos)
				mvec3_set_z(next_vec, 0)

				local future_dis_flat = mvec3_norm(next_vec)
				local turn_dot = mvec3_dot(cur_vec, next_vec)

				if self._haste ~= "run" and turn_dot > -0.7 and turn_dot < 0.7 and not self._attention_pos and future_dis_flat > 80 and self._common_data.stance.name == "ntl" and mvec3_dot(self._common_data.fwd, cur_vec) > 0.97 then
					self._walk_turn = true
				else
					turn_dot = turn_dot * turn_dot
					local dot_lerp = math_max(0, turn_dot)
					local turn_vel = math.lerp(math.min(vel, 100), self:_get_current_max_walk_speed(self._ext_anim.move_side or "fwd"), dot_lerp)
					self._turn_vel = turn_vel
					self._walk_turn = nil
				end
			else
				if vis_state < 3 and self._end_of_curved_path and self._ext_anim.run and not self._NO_RUN_STOP and not self._no_walk and mvec3_dis(c_path[new_c_index + 1], new_pos) >= 120 then
					self._chk_stop_dis = 210
				elseif self._chk_stop_dis then
					self._chk_stop_dis = nil
				end

				self._walk_turn = nil
			end
		end

		self._curve_path_index = new_c_index
		self._last_pos = mvec3_cpy(new_pos)
	end
end

function CopActionWalk:_upd_nav_link(t)
	if self._ext_anim.act and not self._ext_anim.walk then
		self._last_pos = self._unit:position()

		self._ext_movement:set_m_pos(self._last_pos)
		self._ext_movement:set_m_rot(self._unit:rotation())
	elseif self._simplified_path[2] then
		self._common_data.unit:set_driving("script")

		self._changed_driving = nil
		self._simplified_path[1] = mvec3_cpy(self._common_data.pos)

		if self._sync then
			local ray_params = {
				tracker_from = self._common_data.nav_tracker,
				pos_to = self._nav_point_pos(self._simplified_path[2])
			}
			local res = managers.navigation:raycast(ray_params)

			if res then
				local end_pos = self._nav_link.c_class:end_position()

				table.insert(self._simplified_path, 2, end_pos)

				self._next_is_nav_link = nil
			end

			self:_send_nav_point(self._simplified_path[2])
		end

		if mvec3_dis(self._simplified_path[1], self._nav_point_pos(self._simplified_path[2])) > 400 and self._ext_base:lod_stage() then
			self._curve_path = self:_calculate_curved_path(self._simplified_path, 1, 1, self._common_data.fwd)
		else
			self._curve_path = {
				mvec3_cpy(self._simplified_path[1]),
				self._nav_point_pos(self._simplified_path[2])
			}
		end

		self._curve_path_index = 1

		if self._nav_link_invul_on then
			self._nav_link_invul_on = nil

			self._common_data.ext_damage:set_invulnerable(false)
		end

		self._nav_link = nil
		self._cur_vel = 0
		self._last_vel_z = 0

		self:_set_blocks(self._old_blocks)

		self._old_blocks = nil

		self:_set_updator(nil)
		self:_chk_correct_pose()
		self:update(t)
	elseif not self._persistent then
		self._simplified_path[1] = mvec3_cpy(self._common_data.pos)

		self._common_data.unit:set_driving("script")

		self._changed_driving = nil
		self._end_of_curved_path = true

		if self._nav_link_invul_on then
			self._nav_link_invul_on = nil

			self._common_data.ext_damage:set_invulnerable(false)
		end

		self._nav_link = nil
		self._cur_vel = 0
		self._last_vel_z = 0

		self:_set_blocks(self._old_blocks)

		self._old_blocks = nil

		self:_chk_correct_pose()

		self._expired = true

		if self._end_rot then
			self._ext_movement:set_rotation(self._end_rot)
		end
	end
end

function CopActionWalk:on_exit()
	if self._expired and self._end_rot then
		self._ext_movement:set_rotation(self._end_rot)
	end

	if self._root_blend_disabled then
		self._ext_movement:set_root_blend(true)
	end

	if self._changed_driving then
		self._common_data.unit:set_driving("script")

		self._changed_driving = nil
	end
	
	
	if self._unit:base():has_tag("spooc") and not Global.mutators.telespooc then
		if not self._unit:character_damage():dead() then
			self._unit:damage():run_sequence_simple("kill_spook_lights")
			self._unit:sound():play("cloaker_presence_stop")
		end
	end
	
	if self._expired and self._common_data.ext_anim.move then
		self:_stop_walk()
	end

	self._ext_movement:drop_held_items()

	if self._sync then
		if not self._expired then
			self._ext_network:send("action_walk_nav_point", mvec3_cpy(self._ext_movement:m_pos()))
		end

		self._ext_network:send("action_walk_stop")
	else
		self._ext_movement:set_m_host_stop_pos(self._ext_movement:m_pos())
	end

	if self._nav_link_invul_on then
		self._nav_link_invul_on = nil

		self._common_data.ext_damage:set_invulnerable(false)
	end

	if self._ext_anim.act and not self._ext_anim.walk and not self._unit:character_damage():dead() and self._unit:movement():chk_action_forbidden("walk") then
		debug_pause("[CopActionWalk:on_exit] possible illegal exit!", self._unit, self._machine:segment_state(idstr_base))
		Application:draw_cylinder(self._common_data.pos, self._common_data.pos + math.UP * 5000, 30, 1, 0, 0)
	end

	if Network:is_server() then
		self._unit:brain():rem_pos_rsrv("move_dest")
	end
end

function CopActionWalk:_get_current_max_walk_speed(move_dir)
	if move_dir == "l" or move_dir == "r" then
		move_dir = "strafe"
	end

	local multiplier = self._unit:brain().is_hostage and self._unit:brain():is_hostage() and self._common_data.char_tweak.hostage_move_speed or 1
	local speed = self._common_data.char_tweak.move_speed[self._ext_anim.pose][self._haste][self._stance.name][move_dir] * multiplier
	local is_host = Network:is_server() or Global.game_settings.single_player

	if not is_host then
		self._host_peer = self._host_peer or managers.network:session():peer(1)
		local ping_multiplier = 1

		if self._host_peer then
			ping_multiplier = ping_multiplier + Network:qos(self._host_peer:rpc()).ping / 1000
		end

		local lod = self._ext_base:lod_stage()
		--local lod_multiplier = 1

		if managers.groupai:state():enemy_weapons_hot() then
			speed = speed * ping_multiplier
		else
			speed = speed * tweak_data.network.stealth_speed_boost
		end
	end

	return speed
end
