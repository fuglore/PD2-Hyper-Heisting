function DialogManager:queue_narrator_dialog(id, params)
	--this is normally missing a return statement
	return self:queue_dialog(self._narrator_prefix .. id, params)
end

function DialogManager:queue_narrator_dialog_raw(id, params)
	params = params or {}

	return self:queue_dialog(id, params)
end

local in_mex_lines = {
	Play_loc_mex_18 = true,
	Play_loc_mex_63 = true,
	Play_loc_mex_cook_01 = true
}

local dialog_init = DialogManager.queue_dialog
function DialogManager:queue_dialog(id, ...)
	if in_mex_lines[id] then
		managers.groupai:state()._in_mexico = true
	end

	return dialog_init(self, id, ...)
end
