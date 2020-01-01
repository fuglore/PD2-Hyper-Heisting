Hooks:PostHook(HUDAssaultCorner, "_get_assault_strings", "post_FG", function(self)
	local cover_line_to_use = "hud_assault_cover"
	local FG_chance = math.random(1, 184)
	
	local versusline = "hud_assault_faction_swat"
	
	local faction = tweak_data.levels:get_ai_group_type()
	
	if faction then
		if faction == "russia" then
			versusline = "hud_assault_faction_mad"
		elseif faction == "murkywater" then
			versusline = "hud_assault_faction_psc"
		elseif faction == "america" then
			local diff_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)
				
			if diff_index == 4 or diff_index == 5 then
				versusline = "hud_assault_faction_fbi"
			elseif diff_index == 6 then
				versusline = "hud_assault_faction_fbitsu"
			elseif diff_index == 7 then
				versusline = "hud_assault_faction_ftsu"
			elseif diff_index == 8 then
				versusline = "hud_assault_faction_zeal"
			else
				versusline = "hud_assault_faction_swat"
			end
		end			
	end
	
	if FG_chance <= 24 then
		cover_line_to_use = "hud_assault_FG_cover" .. FG_chance
	else
		cover_line_to_use = "hud_assault_cover"
	end
	
	if self._assault_mode == "normal" then
		if managers.job:current_difficulty_stars() > 0 then
			local ids_risk = Idstring("risk")

			return {
				"hud_assault_assault",
				"hud_assault_end_line",
				cover_line_to_use,
				"hud_assault_end_line",
				versusline,
				"hud_assault_end_line",
				ids_risk,
				"hud_assault_end_line",
				"hud_assault_assault",
				"hud_assault_end_line",
				cover_line_to_use,
				"hud_assault_end_line",
				versusline,
				"hud_assault_end_line",
				ids_risk,
				"hud_assault_end_line",
			}
		else
			return {
				"hud_assault_assault",
				"hud_assault_end_line",
				cover_line_to_use,
				"hud_assault_end_line",
				versusline,
				"hud_assault_end_line",
				"hud_assault_assault",
				"hud_assault_end_line",
				cover_line_to_use,
				"hud_assault_end_line",
				versusline,
				"hud_assault_end_line",
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
end)
