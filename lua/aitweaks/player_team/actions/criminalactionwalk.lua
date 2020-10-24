function CriminalActionWalk:init(action_desc, common_data)
	return CriminalActionWalk.super.init(self, action_desc, common_data)
end

function CriminalActionWalk:_get_max_walk_speed()
	local speed = deep_clone(CriminalActionWalk.super._get_max_walk_speed(self))

	if self._ext_movement:carrying_bag() then
		local speed_modifier = tweak_data.carry.types[tweak_data.carry[self._ext_movement:carry_id()].type].move_speed_modifier * 1.25

		for k, v in pairs(speed) do
			speed[k] = v * speed_modifier
		end
	end

	return speed
end