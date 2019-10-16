
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
		["hud_assault_FG_cover7"] = "THIS IS TRUE LOVE WE MAKIN",
		["menu_toggle_one_down"] = "SHIN SHOOTOUT",
		["menu_one_down"] = "SHIN SHOOTOUT",
		["menu_cs_modifier_heavies"] = "All enemies except Bulldozers and FBIs now have body armor.",
		["menu_cs_modifier_heavy_sniper"] = "Adds a chance for Sniperdozers to spawn.",
		["menu_cs_modifier_dozer_lmg"] = "EVERYTHING IS HORRIBLE!",
		["menu_cs_modifier_dozer_immune"] = "Enemies are much more aggressive.",
		["menu_cs_modifier_shield_phalanx"] = "Shotgunners have a chance to be replaced by a Gensec Saiga SWAT.",
		["menu_cs_modifier_no_hurt"] = "SHIN SHOOTOUT is now enabled."
	})
end)
