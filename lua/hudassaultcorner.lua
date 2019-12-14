function HUDAssaultCorner:_get_assault_strings()
	local assault_line_to_use = "hud_assault_assault"
	
	local jokelines = {
		"hud_assault_FG_cover1",
		"hud_assault_FG_cover2",
		"hud_assault_FG_cover3",
		"hud_assault_FG_cover4",
		"hud_assault_FG_cover5",
		"hud_assault_FG_cover6",
		"hud_assault_FG_cover7",
		"hud_assault_FG_cover8",
		"hud_assault_FG_cover9",
		"hud_assault_FG_cover10",
		"hud_assault_FG_cover11",
		"hud_assault_FG_cover12",
		"hud_assault_FG_cover13",
		"hud_assault_FG_cover14"
	}
	
	if dont then
		assault_line_to_use = "hud_assault_assault"
	else
		assault_line_to_use = math.random(#jokelines)
	end
	
	if self._assault_mode == "normal" then
		if managers.job:current_difficulty_stars() > 0 then
			local ids_risk = Idstring("risk")

			return {
				assault_line_to_use,
				"hud_assault_end_line",
				ids_risk,
				"hud_assault_end_line",
				assault_line_to_use,
				"hud_assault_end_line",
				ids_risk,
				"hud_assault_end_line"
			}
		else
			return {
				assault_line_to_use,
				"hud_assault_end_line",
				assault_line_to_use,
				"hud_assault_end_line",
				assault_line_to_use,
				"hud_assault_end_line"
			}
		end
	end

	if self._assault_mode == "phalanx" then
		if managers.job:current_difficulty_stars() > 0 then
			local ids_risk = Idstring("risk")

			return {
				"hud_assault_vip",
				"hud_assault_padlock",
				ids_risk,
				"hud_assault_padlock",
				"hud_assault_vip",
				"hud_assault_padlock",
				ids_risk,
				"hud_assault_padlock"
			}
		else
			return {
				"hud_assault_vip",
				"hud_assault_padlock",
				"hud_assault_vip",
				"hud_assault_padlock",
				"hud_assault_vip",
				"hud_assault_padlock"
			}
		end
	end
end