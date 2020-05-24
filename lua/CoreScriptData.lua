local mod_path = tostring(PD2THHSHIN._mod_path)

Hooks:Add("BeardLibCreateScriptDataMods", "CustomEnvCallBeardLibSequenceFuncs", function()
	local difficulty = Global.game_settings and Global.game_settings.difficulty or "normal"
	local diff_index = tweak_data:difficulty_to_index(difficulty)
	local level = Global.level_data and Global.level_data.level_id
	if diff_index == 8 and level == "friend" then
		BeardLib:ReplaceScriptData(mod_path .. "scriptdata/shitfaceenvironment.custom_xml", "custom_xml", "environments/pd2_friend/pd2_friend", "environment")
	end
end)
