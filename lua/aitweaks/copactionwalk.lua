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
	self._action_desc = action_desc
	self._action_desc.path_simplified = true
	local action_desc = action_desc
	action_desc.path_simplified = true
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
	
	if self._unit:base():has_tag("spooc") and self._haste == "run" and not Global.mutators.telespooc then
		self._unit:damage():run_sequence_simple("kill_spook_lights")
		self._unit:sound():play("cloaker_presence_stop")
	end

	self._ext_movement:enable_update()

	self._is_civilian = CopDamage.is_civilian(self._unit:base()._tweak_table)

	return true
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
	
	
	if self._unit:base():has_tag("spooc") then
		if not self._unit:character_damage():dead() then
			self._unit:sound():play(self._unit:base():char_tweak().spawn_sound_event)
			self._unit:damage():run_sequence_simple("turn_on_spook_lights")
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
