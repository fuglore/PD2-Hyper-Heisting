
local testAllStrings = false

Hooks:PostHook(LocalizationManager, "text", "shin_text", function(self, string_id, ...)

return string_id == "menu_one_down" and "SHIN SHOOTOUT"
or string_id == "menu_toggle_one_down" and "SHIN SHOOTOUT"
or string_id == "menu_risk_pd" and      "Simple, but challenging. Stone cold."
or string_id == "menu_risk_swat" and    "SWAT team wants to arrest you. We are cool."
or string_id == "menu_risk_fbi" and     "You're up against the feds. A nice breeze."
or string_id == "menu_risk_special" and "The FBI wants you dead. A hot, summer day."
or string_id == "menu_risk_easy_wish" and "GENSEC are out to get you! Getting hot in here!"
or string_id == "menu_risk_elite" and   "More units rolling in! More heat around the corner!"
or string_id == "menu_risk_sm_wish" and "The ZEAL Squadrons are here! No escape from the inferno!"

or testAllStrings == true and string_id
end)

Hooks:Add("LocalizationManagerPostInit", "shin_assaultcornertext", function(loc)
	LocalizationManager:add_localized_strings({
		["hud_assault_FG_cover1"] = "KILL EACHOTHER, BUT IT'S GOOD INVERSES",
		["hud_assault_FG_cover2"] = "TRIUMPH OR DIE",
		["hud_assault_FG_cover3"] = "FACE IT STRAIGHT",
		["hud_assault_FG_cover4"] = "FIGHT ON",
		["hud_assault_FG_cover5"] = "THE WHEEL OF FATE IS TURNING",
		["hud_assault_FG_cover6"] = "THIS IS TUNA WITH BACON",
		["hud_assault_FG_cover7"] = "THIS IS TRUE LOVE WE MAKIN"
	})
end)
