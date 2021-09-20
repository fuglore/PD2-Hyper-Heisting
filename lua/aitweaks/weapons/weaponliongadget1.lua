local mvec1 = Vector3()
local mvec2 = Vector3()
local mvec3 = Vector3()
local mvec_look_dir = Vector3()
local mvec_gun_down_dir = Vector3()
local mvec3_set = mvector3.set
local mvec3_rot_with = mvector3.rotate_with
local mvec3_mul = mvector3.multiply
local mvec3_add = mvector3.add

local y_offset_rays = Vector3(0, -100, 0)

local mrot_y = mrotation.y
local mrot_x = mrotation.x

function WeaponLionGadget1:init(unit)
	self._unit = unit
	self._is_npc = false
	self._deploy_slotmask = managers.slot:get_mask("world_geometry", "vehicles")

	local function on_cash_inspect_weapon()
		self:get_offsets()
	end

	managers.player:register_message(Message.OnCashInspectWeapon, self, on_cash_inspect_weapon)

	self._deployed = false
end

function WeaponLionGadget1:is_usable()
	if not self._center_ray_from or not self._center_ray_to then
		return nil
	end
	
	local ray_bipod_center = self._unit:raycast("ray", self._center_ray_from, self._center_ray_to, "slot_mask", self._deploy_slotmask)
	local ray_bipod_sides = self._unit:raycast("ray", self._left_ray_from, self._left_ray_to, "slot_mask", self._deploy_slotmask)

	if not ray_bipod_sides then
		ray_bipod_sides = self._unit:raycast("ray", self._right_ray_from, self._right_ray_to, "slot_mask", self._deploy_slotmask)
	end


	return ray_bipod_center and ray_bipod_sides
end

function WeaponLionGadget1:_shoot_bipod_rays(debug_draw)
	local from = mvec1
	local to = mvec2
	local from_offset = mvec3
	local bipod_max_length = WeaponLionGadget1.bipod_length or 90

	if not self._bipod_obj then
		return nil
	end

	if not self._bipod_offsets then
		self:get_offsets()
	end

	mrot_y(self:_get_bipod_alignment_obj():rotation(), mvec_look_dir)
	mrot_x(self:_get_bipod_alignment_obj():rotation(), mvec_gun_down_dir)

	local bipod_position = Vector3()

	mvec3_set(bipod_position, self._bipod_offsets.direction)
	mvec3_rot_with(bipod_position, self:_get_bipod_alignment_obj():rotation())
	mvec3_mul(bipod_position, (self._bipod_offsets.distance or bipod_max_length) * -1)
	mvec3_add(bipod_position, self:_get_bipod_alignment_obj():position())

	if mvec_look_dir:to_polar().pitch > 60 then
		return nil
	end

	mvec3_set(from, bipod_position)
	mvec3_set(to, mvec_gun_down_dir)
	mvec3_mul(to, bipod_max_length)
	mvec3_rot_with(to, Rotation(mvec_look_dir, 120))
	mvec3_add(to, from)

	local ray_bipod_left = self._unit:raycast("ray", from, to, "slot_mask", self._deploy_slotmask)

	self._left_ray_from = Vector3(from.x, from.y, from.z)
	self._left_ray_to = Vector3(to.x, to.y, to.z)
	
	mvec3_set(to, mvec_gun_down_dir)
	mvec3_mul(to, bipod_max_length)
	mvec3_rot_with(to, Rotation(mvec_look_dir, 60))
	mvec3_add(to, from)

	local ray_bipod_right = self._unit:raycast("ray", from, to, "slot_mask", self._deploy_slotmask)

	self._right_ray_from = Vector3(from.x, from.y, from.z)
	self._right_ray_to = Vector3(to.x, to.y, to.z)
	

	mvec3_set(to, mvec_gun_down_dir)
	mvec3_mul(to, bipod_max_length * math.cos(30))
	mvec3_rot_with(to, Rotation(mvec_look_dir, 90))
	mvec3_add(to, from)

	local ray_bipod_center = self._unit:raycast("ray", from, to, "slot_mask", self._deploy_slotmask)

	self._center_ray_from = Vector3(from.x, from.y, from.z)
	self._center_ray_to = Vector3(to.x, to.y, to.z)

	mvec3_set(from_offset, y_offset_rays)
	mvec3_rot_with(from_offset, self:_get_bipod_alignment_obj():rotation())
	mvec3_add(from, from_offset)
	mvec3_set(to, mvec_look_dir)
	mvec3_mul(to, bipod_max_length)
	mvec3_add(to, from)

	local ray_bipod_forward = self._unit:raycast("ray", from, to, "slot_mask", self._deploy_slotmask)

	return {
		left = ray_bipod_left,
		right = ray_bipod_right,
		center = ray_bipod_center,
		forward = ray_bipod_forward
	}
end