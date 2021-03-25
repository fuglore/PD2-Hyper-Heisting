function HUDManager:show_heat_bonus_hints()
	local params = {text = "HEAT BONUS", time = 1}
	local clbk_params = {text = "AMMO AND HEALTH PARTIALLY REPLENISHED", time = 1}
	params.clbk = callback(self._hud_hint, self._hud_hint, "show", clbk_params)
	self._hud_hint:show(params)
end