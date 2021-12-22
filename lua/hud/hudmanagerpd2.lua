function HUDManager:show_heat_bonus_hints()
	local params = {text = "HEAT BONUS", time = 1}
	self:present_mid_text(params)
	local params = {text = "AMMO AND HEALTH PARTIALLY REPLENISHED", time = 1}
	self:present_mid_text(params)
end