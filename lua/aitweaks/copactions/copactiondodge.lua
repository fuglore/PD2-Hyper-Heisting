CopActionDodge = CopActionDodge or class()
CopActionDodge._apply_freefall = CopActionWalk._apply_freefall
CopActionDodge._VARIATIONS = {
	"side_step",
	"dive",
	"roll",
	"wheel"
}
CopActionDodge._SIDES = {
	"fwd",
	"bwd",
	"l",
	"r"
}

function CopActionDodge:init(action_desc, common_data)
	self._common_data = common_data
	self._ext_base = common_data.ext_base
	self._ext_movement = common_data.ext_movement
	self._ext_anim = common_data.ext_anim
	self._body_part = action_desc.body_part
	self._unit = common_data.unit
	self._timeout = action_desc.timeout
	self._machine = common_data.machine
	self._ids_base = Idstring("base")
	local redir_name = "dodge"
	local redir_res = self._ext_movement:play_redirect(redir_name)

	if redir_res then
		self._descriptor = action_desc
		self._last_vel_z = 0

		self:_determine_rotation_transition()
		self._ext_movement:set_root_blend(false)
		self._machine:set_parameter(redir_res, action_desc.variation, 1)

		if action_desc.speed then
			self._machine:set_speed_soft(redir_res, action_desc.speed, 0.75)
		end

		self._machine:set_parameter(redir_res, action_desc.side, 1)

		if Network:is_server() then
			local accuracy = math.clamp(math.floor((action_desc.shoot_accuracy or 1) * 10) / 10, 0, 10)

			common_data.ext_network:send("action_dodge_start", self._body_part, CopActionDodge._get_variation_index(action_desc.variation), CopActionDodge._get_side_index(action_desc.side), Rotation(action_desc.direction, math.UP):yaw(), action_desc.speed or 1, accuracy)
		end

		self._ext_movement:enable_update()

		return true
	else
		debug_pause_unit(self._unit, "[CopActionDodge:init] redirect", redir_name, "failed in", self._machine:segment_state(Idstring("base")), common_data.unit)

		return
	end
end