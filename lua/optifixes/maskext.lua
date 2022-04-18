--Doing it through a dummy update function in order to not override the init itself for things that might be changed by other mods.

function MaskExt:update()
	--log("annoying.")
	self._unit:set_extension_update_enabled(Idstring("base"), false)
end