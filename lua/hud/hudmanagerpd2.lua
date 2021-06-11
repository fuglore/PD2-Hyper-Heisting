function HUDManager:show_heat_bonus_hints()
	local params = {text = "HEAT BONUS", time = 1}
	self._hud_hint:show(params)
	local params = {text = "AMMO AND HEALTH PARTIALLY REPLENISHED", time = 1}
	managers.enemy:add_delayed_clbk("HHEATTIP2", callback(self._hud_hint, self._hud_hint, "show", params), TimerManager:game():time() + 1.01)
end