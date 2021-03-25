function HUDHint:show(params)
	local text = params.text
	local clip_panel = self._hint_panel:child("clip_panel")

	clip_panel:child("hint_text"):set_text(utf8.to_upper(""))

	self._stop = false
	
	self._hint_panel:stop()
	
	local fucking_clbk = params.clbk or callback(self, self, "show_done")
	
	self._hint_panel:animate(callback(self, self, "_animate_show"), fucking_clbk, params.time or 3, utf8.to_upper(text))
end
