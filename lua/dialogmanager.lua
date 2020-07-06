function DialogManager:queue_narrator_dialog_raw(id, params)
	self:queue_dialog(id, params)
end

local dialog_init = DialogManager.queue_dialog

function DialogManager:queue_dialog(id, ...)

	if id == "Play_loc_mex_18" or id == "Play_loc_mex_cook_01" or id == "Play_loc_mex_63" then
		managers.groupai:state()._in_mexico = true
	end
	
	return dialog_init(self, id, ...)
end