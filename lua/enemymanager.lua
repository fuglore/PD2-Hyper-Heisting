function EnemyManager:get_magnet_storm_targets(unit)
	if self:is_civilian(unit) then
		return nil
	end
	
	--log("sexecuting")
	
	local targets_to_tase = {}

	local targets = World:find_units_quick(unit, "sphere", unit:position(), 400, managers.slot:get_mask("players"))

	for _, target in ipairs(targets) do
		--local vis_check_fail = World:raycast("ray", unit:movement():m_head_pos(), target:movement():m_head_pos(), "sphere_cast_radius", 15, "slot_mask", managers.slot:get_mask("world_geometry", "vehicles"), "report")
		if not vis_check_fail then
			table.insert(targets_to_tase, target)
		end
	end
	
	return targets_to_tase
end