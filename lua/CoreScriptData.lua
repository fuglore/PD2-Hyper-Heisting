local mod_path = tostring(PD2THHSHIN._mod_path)
local diff_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)				
local sex = Global.level_data and Global.level_data.level_id

Hooks:Add("BeardLibCreateScriptDataMods", "CustomEnvCallBeardLibSequenceFuncs", function()
	if diff_index == 8 and sex == "friend" then
		BeardLib:ReplaceScriptData(mod_path .. "scriptdata/shitfaceenvironment.custom_xml", "custom_xml", "environments/pd2_friend/pd2_friend", "environment")
	end
end)
