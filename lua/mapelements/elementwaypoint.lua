local level_objectives_table = {
	run = {
		[103203] = true,
		[103204] = true,
		[102136] = true,
		[102008] = true,
		[101290] = true,
		[101356] = true,
		[103210] = true,
		[101611] = true,
		[100372] = true
	},
	glace = { 
		[100067] = true,
		[102367] = true,
		[100437] = true,
		[101621] = true
	},
	gallery = {
		[100995] = true,
	},
}

function ElementWaypoint:on_executed(instigator)
	if not self._values.enabled then
		return
	end

	if self._values.only_on_instigator and instigator ~= managers.player:player_unit() then
		ElementWaypoint.super.on_executed(self, instigator)

		return
	end
	
	local level = Global.level_data and Global.level_data.level_id
	local ids = level_objectives_table[level]

	if not self._values.only_in_civilian or managers.player:current_state() == "civilian" then
		--log(tostring(self._id))
		if ids then
			if ids[self._id] then
				managers.groupai:state():set_current_objective_area(self._values.position)
			end
		end
		
		local text = managers.localization:text(self._values.text_id)

		managers.hud:add_waypoint(self._id, {
			distance = true,
			state = "sneak_present",
			present_timer = 0,
			text = text,
			icon = self._values.icon,
			position = self._values.position
		})
	elseif managers.hud:get_waypoint_data(self._id) then
		managers.hud:remove_waypoint(self._id)
		
		if ids then
			if ids[self._id] then
				managers.groupai:state():set_current_objective_area(nil)
			end
		end
	end

	ElementWaypoint.super.on_executed(self, instigator)
end