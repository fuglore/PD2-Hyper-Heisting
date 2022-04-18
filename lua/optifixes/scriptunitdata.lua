--There's an issue in vanilla that causes the engine to waste time checking for updates if the extension does not forcibly disable updating itself on the init, even if an update function doesn't exist.

--With script data extensions being used by architecture and such, this means that the engine is constantly trying to update objects that *can't* be updated, which isn't good for performance. This can be fixed by doing what I'm doing here.

--I'm giving it a week before most of this ends up in some other mod, somewhere, without my permission. Made by some very specific fucking people.

function ScriptUnitData:init(unit)
	CoreScriptUnitData.init(self)

	if managers.occlusion and self.skip_occlusion then
		managers.occlusion:remove_occlusion(unit)
	end
	
	self._unit = unit
	self._unit:set_extension_update_enabled(Idstring("unit_data"), false)
end
