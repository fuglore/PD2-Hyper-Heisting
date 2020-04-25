
if restoration and restoration:all_enabled("HUD/MainHUD", "HUD/AssaultPanel") then
	return
end

Hooks:PostHook(HUDAssaultCorner, "_get_assault_strings", "post_FG", function(self)
	local level = Global.level_data and Global.level_data.level_id
	local cover_line_to_use = "hud_assault_cover"
	local FG_chance = math.random(1, 233)
	
	local versusline = "hud_assault_faction_swat"
	
	local faction = tweak_data.levels:get_ai_group_type()
	
	local assaultline = "hud_assault_assault"
	
	if faction then
		local diff_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)				
		if faction == "russia" then
			versusline = "hud_assault_faction_mad"
			assaultline = "hud_assault_assaultrepers"			
		elseif faction == "federales" then
			versusline = "hud_assault_faction_federales"
			assaultline = "hud_assault_assault_mexcross"
		elseif level == "red 2" then
			versusline = "hud_assault_assault_blma"
			versusline = "hud_assault_faction_federales"			
		elseif faction == "murkywater" then
			if managers.groupai and managers.groupai:state()._in_mexico or level == "mex_cooking" then
				versusline = "hud_assault_faction_mexcross"
				assaultline = "hud_assault_assault_mexcross"
			else
				versusline = "hud_assault_faction_psc"
			end
		elseif faction == "shared" then
			if diff_index == 4 or diff_index == 5 then
				versusline = "hud_assault_faction_sharedfbi"		
			elseif diff_index == 6 or diff_index == 7 then
				versusline = "hud_assault_faction_sharedgensec"		
			elseif diff_index == 8 then
				versusline = "hud_assault_faction_sharedzeal"
			else
				versusline = "hud_assault_faction_sharedswat"					
			end			
		elseif faction == "zombie" then
			versusline = "hud_assault_faction_hvh"
			assaultline = "hud_assault_assaulthvh"
		elseif faction == "america" then
			local diff_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)
			
			if managers.skirmish and managers.skirmish:is_skirmish() or Global.game_settings.incsmission then	
				versusline = "hud_assault_faction_generic"
			elseif diff_index == 4 or diff_index == 5 then
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
	
	if FG_chance <= 33 then
		cover_line_to_use = "hud_assault_FG_cover" .. FG_chance
	else
		if managers.groupai and managers.groupai:state()._in_mexico or level == "mex_cooking" or faction == "federales" then
			cover_line_to_use = "hud_assault_cover_mexcross"
		elseif faction == "zombie" then
			cover_line_to_use = "hud_assault_coverhvh"
		elseif level == "red 2" then
			cover_line_to_use = "hud_assault_cover_blma"			
		elseif faction == "russia" then
			cover_line_to_use = "hud_assault_cover_repers"			
		else
			cover_line_to_use = "hud_assault_cover"
		end
	end
	
	if self._assault_mode == "normal" then
		if managers.job:current_difficulty_stars() > 0 then
			local ids_risk = Idstring("risk")

			return {
				assaultline,
				"hud_assault_end_line",
				cover_line_to_use,
				"hud_assault_end_line",
				versusline,
				"hud_assault_end_line",
				ids_risk,
				"hud_assault_end_line",
				assaultline,
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
				assaultline,
				"hud_assault_end_line",
				cover_line_to_use,
				"hud_assault_end_line",
				versusline,
				"hud_assault_end_line",
				assaultline,
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