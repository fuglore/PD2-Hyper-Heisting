local mod_path = tostring(PD2THHSHIN._mod_path)

Hooks:Add("BeardLibCreateScriptDataMods", "CustomEnvCallBeardLibSequenceFuncs", function()
	local difficulty = Global.game_settings and Global.game_settings.difficulty or "normal"
	local diff_index = tweak_data:difficulty_to_index(difficulty)
	
	local sex = Global.level_data and Global.level_data.level_id
	
	BeardLib:ReplaceScriptData(mod_path .. "scriptdata/pd2_env_day_hh.custom_xml", "custom_xml", "environments/pd2_env_mid_day/pd2_env_mid_day", "environment")
	
	if diff_index == 8 and sex == "friend" then
		BeardLib:ReplaceScriptData(mod_path .. "scriptdata/shitfaceenvironment.custom_xml", "custom_xml", "environments/pd2_friend/pd2_friend", "environment")
	end
	--[[ if diff_index == 8 and sex == "flat_hh" or sex =="flat" then
		BeardLib:ReplaceScriptData(mod_path .. "scriptdata/greentwilight.custom_xml", "custom_xml", "environments/flat/flat", "environment")
	end	--]]
	if sex == "skm_watchdogs_stage2" then
		BeardLib:ReplaceScriptData(mod_path .. "scriptdata/purple_notrain.custom_xml", "custom_xml", "units/pd2_dlc_skm/environments/pd2_env_skm_watchdogs_2_exterior", "environment")
	end	
end)
