

function UnitBase:init(unit, update_enabled)
	self._unit = unit
	
	if not update_enabled then
		--log("is this ever set?")
		unit:set_extension_update_enabled(Idstring("base"), false)
	end
	
	if not self.update and update_enabled then --if there is no update function either, disable the updating.
		unit:set_extension_update_enabled(Idstring("base"), false)
	end

	self._destroy_listener_holder = ListenerHolder:new()
end