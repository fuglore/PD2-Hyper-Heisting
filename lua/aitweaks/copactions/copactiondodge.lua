CopActionDodge._DODGE_VAR_DISTANCES = {
	side_step = 130,
	dive = 300,
	roll = 250,
	wheel = 300
}

CopActionDodge._DODGE_ANIM_T_CLAMP = {
	side_step = 0.5,
	dive = 0.77,
	roll = 0.6,
	wheel = 0.5
}

local mvec3_cpy = mvector3.copy

local mrot_lookat = mrotation.set_look_at
local tmp_rot = Rotation()

local math_floor = math.floor
local math_clamp = math.clamp
local math_up = math.UP
local math_lerp = math.lerp

local ids_base = Idstring("base")

function CopActionDodge:init(action_desc, common_data)
	local ext_mov = common_data.ext_movement
	local redir_res = ext_mov:play_redirect("dodge")

	if not redir_res then
		return
	end

	self._common_data = common_data
	self._action_desc = action_desc
	self._ext_movement = ext_mov
	self._ext_base = common_data.ext_base
	self._ext_anim = common_data.ext_anim
	self._unit = common_data.unit

	local body_part = action_desc.body_part
	self._body_part = body_part

	local variation = "dive" or action_desc.variation
	local speed = action_desc.speed
	speed = speed > 1.6 and 1.6 or speed --hard clamp as otherwise the animations just completely break, thanks OVK lmao
	if variation == "dive" then
		speed = speed + 0.4
	end
	self._speed = speed
	self._t_clamp = self._DODGE_ANIM_T_CLAMP[variation] / speed

	local side = action_desc.side
	local direction = action_desc.direction

	self._timeout = action_desc.timeout

	local machine = common_data.machine
	self._machine = machine

	machine:set_parameter(redir_res, variation, 1)
	machine:set_parameter(redir_res, side, 1)

	if speed ~= 1 then
		machine:set_speed(redir_res, speed)
	end

	CopActionAct._create_blocks_table(self, action_desc.blocks)

	self:_determine_rotation_transition(side, direction, variation)

	local shoot_accuracy = action_desc.shoot_accuracy

	if Network:is_server() then
		self._is_server = true

		if shoot_accuracy then --clamp accuracy between 0 and 1, and round down to one decimal if needed
			if shoot_accuracy < 0 then
				shoot_accuracy = 0
			elseif shoot_accuracy ~= 1 then
				shoot_accuracy = shoot_accuracy > 1 and 1 or math_floor(shoot_accuracy * 10) / 10
			end
		else
			shoot_accuracy = 1
		end

		local var_index = self._get_variation_index(variation)
		local side_index = self._get_side_index(side)
		local sync_yaw = self._end_rot:yaw()
		local sync_acc = shoot_accuracy * 10 --accuracy multiplier is synced to clients as an integer clamped between 0 and 10

		common_data.ext_network:send("action_dodge_start", body_part, var_index, side_index, sync_yaw, speed, sync_acc)
	end

	self._shoot_accuracy = shoot_accuracy

	self._last_vel_z = 0

	ext_mov:enable_update()

	self:on_attention(common_data.attention)

	--self:_create_debug_ws()

	return true
end

function CopActionDodge:on_attention(attention)
	if attention then
		local att_handler = attention.handler

		if att_handler then
			self._attention_pos = att_handler:get_ground_m_pos()
		else
			local att_unit = attention.unit

			if att_unit then
				local att_mov_ext = att_unit:movement()

				self._attention_pos = att_mov_ext and att_mov_ext:m_pos() or att_unit:position()
			else
				self._attention_pos = attention.pos or nil
			end
		end
	else
		self._attention_pos = nil
	end

	self._attention = attention
end

function CopActionDodge:on_exit()
	local ext_mov = self._ext_movement
	local expired = self._expired

	if not self._is_server then
		ext_mov:set_m_host_stop_pos(self._common_data.pos)
	elseif not expired then
		self._common_data.ext_network:send("action_dodge_end")
	end

	if expired then
		CopActionWalk._chk_correct_pose(self)
	end

	self:_remove_debug_gui()
end

function CopActionDodge:update(t)
	local ext_anim = self._ext_anim
	local dt = TimerManager:game():delta_time()

	if not ext_anim.dodge then
		self._expired = true

		self._last_pos = self._end_pos

		CopActionWalk._set_new_pos(self, dt)

		return
	end

	local ext_mov = self._ext_movement
	local seg_rel_t = self._machine:segment_relative_time(ids_base)
	local seg_rel_t_clamp = math_clamp((seg_rel_t - self._anim_start_t) / self._t_clamp, 0, 1)
	self._last_pos = math_lerp(self._start_pos, self._end_pos, seg_rel_t_clamp)

	CopActionWalk._set_new_pos(self, dt)

	--self:_update_debug_ws(seg_rel_t, seg_rel_t_clamp)

	if seg_rel_t_clamp < 0.3 or seg_rel_t_clamp > 0.8 then
		local att_pos = self._attention_pos

		if att_pos then
			local common_data = self._common_data
			local delta_lerp = dt * 2
			delta_lerp = delta_lerp > 1 and 1 or delta_lerp

			local face_fwd = att_pos - common_data.pos
			face_fwd = face_fwd:with_z(0):normalized()

			local new_rot = tmp_rot
			mrot_lookat(new_rot, face_fwd, math_up)

			new_rot = common_data.rot:slerp(new_rot, delta_lerp)

			ext_mov:set_rotation(new_rot)
		end
	end

	if ext_anim.base_need_upd then
		ext_mov:upd_m_head_pos()
	end
end

local cannot_block_list = {
	death = true,
	bleedout = true,
	fatal = true
}

local default_block_list = {
	turn = true,
	idle = true,
	stand = true,
	crouch = true,
	walk = true
}

function CopActionDodge:chk_block(action_type, t)
	if cannot_block_list[action_type] then
		return false
	elseif default_block_list[action_type] or CopActionAct.chk_block(self, action_type, t) then
		return true
	end
end

function CopActionDodge._get_variation_index(var_name)
	local vars = CopActionDodge._VARIATIONS

	for i = 1, #vars do
		local test_var_name = vars[i]

		if var_name == test_var_name then
			return i
		end
	end
end

function CopActionDodge._get_side_index(side_name)
	local vars = CopActionDodge._SIDES

	for i = 1, #vars do
		local test_side_name = vars[i]

		if side_name == test_side_name then
			return i
		end
	end
end

function CopActionDodge:_determine_rotation_transition(wanted_side, direction, variation)
	local common_data = self._common_data
	local cur_pos = common_data.pos
	local end_rot = Rotation(direction, math_up)
	self._end_rot = end_rot

	local needed_dis = CopActionDodge._determine_needed_distance(variation)
	local ray_params = {
		allow_entry = false,
		trace = true,
		pos_to = cur_pos + direction * needed_dis
	}

	local my_tracker = common_data.nav_tracker

	if my_tracker:lost() then
		ray_params.pos_from = my_tracker:field_position()
	else
		ray_params.tracker_from = my_tracker
	end

	local nav_ray = managers.navigation:raycast(ray_params)

	self._start_pos = mvec3_cpy(cur_pos)
	self._end_pos = ray_params.trace[1]
	self._anim_start_t = self._machine:segment_relative_time(ids_base)
end

function CopActionDodge:accuracy_multiplier()
	return self._shoot_accuracy
end

function CopActionDodge._determine_needed_distance(var)
	return CopActionDodge._DODGE_VAR_DISTANCES[var]
end

function CopActionDodge:_create_debug_ws()
	self._gui = World:newgui()
	local obj = self._unit:get_object(Idstring("Head"))
	self._ws = self._gui:create_linked_workspace(100, 100, obj, obj:position() + obj:rotation():y() * 25, obj:rotation():x() * 50, obj:rotation():y() * 50)

	self._ws:set_billboard(self._ws.BILLBOARD_BOTH)
	self._ws:panel():text({
		name = "seg_t",
		vertical = "top",
		visible = true,
		font_size = 30,
		align = "left",
		font = "fonts/font_medium_shadow_mf",
		y = 0,
		render_template = "OverlayVertexColorTextured",
		layer = 1,
		text = "nil",
		color = Color.white
	})
	self._ws:panel():text({
		name = "clamp_seg_t",
		vertical = "top",
		visible = true,
		font_size = 30,
		align = "left",
		font = "fonts/font_medium_shadow_mf",
		y = 30,
		render_template = "OverlayVertexColorTextured",
		layer = 1,
		text = "nil",
		color = Color.green
	})
end

function CopActionDodge:_update_debug_ws(t, clamp_t)
	if alive(self._ws) then
		self._ws:panel():child("seg_t"):set_text(tostring(t))
		self._ws:panel():child("clamp_seg_t"):set_text(tostring(clamp_t))
	end

	if t then
		local line1 = Draw:brush(Color.blue:with_alpha(t), 0.1)
		line1:cylinder(self._start_pos, self._end_pos, 15)

		local line2 = Draw:brush(Color.red:with_alpha(t), 0.1)
		line2:cylinder(self._ext_movement:m_head_pos(), self._end_pos, 15)
	end
end

function CopActionDodge:_remove_debug_gui()
	if alive(self._gui) and alive(self._ws) then
		self._gui:destroy_workspace(self._ws)

		self._ws = nil
		self._gui = nil
	end
end

function CopActionDodge:on_destroy()
	self:_remove_debug_gui()
end
