local mod_path = tostring(PD2THHSHIN._mod_path)

Hooks:Add("BeardLibPreProcessScriptData", "HHCreateEnvironment", function(PackManager, path, raw_data)
    if managers.dyn_resource then
        local skies = {
            "sky_1930_twillight",
			"sky_1930_sunset_heavy_clouds",
            "sky_1846_low_sun_nice_clouds",
            "sky_0902_overcast",
			"sky_1345_clear_sky",
			"sky_0200_night_moon_stars",
			"sky_2000_twilight_mad",
			"sky_2100_moon",
			"sky_1008_cloudy",
			"sky_0927_whispy_clouds",
			"sky_2335_night_moon",
			"sky_2100_moon",
			"sky_1313_cloudy_dark",
			"sky_2003_dusk_blue_high_color_scale",
			"sky_2335_night_moon"
			
        }
        for _, sky in ipairs(skies) do
            if not managers.dyn_resource:has_resource(Idstring("scene"), Idstring("core/environments/skies/" .. sky .. "/" .. sky), managers.dyn_resource.DYN_RESOURCES_PACKAGE) then
                managers.dyn_resource:load(Idstring("scene"), Idstring("core/environments/skies/" .. sky .. "/" .. sky), managers.dyn_resource.DYN_RESOURCES_PACKAGE, nil)
            end
        end
    end
end)
	

Hooks:Add("BeardLibCreateScriptDataMods", "CustomEnvCallBeardLibSequenceFuncs", function()
	local difficulty = Global.game_settings and Global.game_settings.difficulty or "normal"
	local diff_index = tweak_data:difficulty_to_index(difficulty)
	
	local sex = Global.level_data and Global.level_data.level_id
	
	BeardLib:ReplaceScriptData(mod_path .. "scriptdata/pd2_env_day_hh.custom_xml", "custom_xml", "environments/pd2_env_mid_day/pd2_env_mid_day", "environment")
	
	if diff_index == 8 then
		BeardLib:ReplaceScriptData(mod_path .. "scriptdata/serious_moonlight.custom_xml", "custom_xml", "environments/pd2_env_night/pd2_env_night", "environment")
		BeardLib:ReplaceScriptData(mod_path .. "scriptdata/serious_moonlight.custom_xml", "custom_xml", "environments/pd2_hlm1/pd2_hlm1", "environment")
		BeardLib:ReplaceScriptData(mod_path .. "scriptdata/serious_moonlight.custom_xml", "custom_xml", "environments/pd2_env_rat_night/pd2_env_rat_night", "environment")
		BeardLib:ReplaceScriptData(mod_path .. "scriptdata/serious_moonlight.custom_xml", "custom_xml", "environments/pd2_env_rat_night_stage_3/pd2_env_rat_night_stage_3", "environment")
		BeardLib:ReplaceScriptData(mod_path .. "scriptdata/serious_moonlight.custom_xml", "custom_xml", "environments/pd2_kosugi/pd2_kosugi", "environment")
	else
		BeardLib:ReplaceScriptData(mod_path .. "scriptdata/pd2_env_night_hh.custom_xml", "custom_xml", "environments/pd2_env_night/pd2_env_night", "environment")
		BeardLib:ReplaceScriptData(mod_path .. "scriptdata/pd2_env_night_hh.custom_xml", "custom_xml", "environments/pd2_hlm1/pd2_hlm1", "environment")
		BeardLib:ReplaceScriptData(mod_path .. "scriptdata/pd2_env_night_hh.custom_xml", "custom_xml", "environments/pd2_env_rat_night/pd2_env_rat_night", "environment")
		BeardLib:ReplaceScriptData(mod_path .. "scriptdata/pd2_env_night_hh.custom_xml", "custom_xml", "environments/pd2_env_rat_night_stage_3/pd2_env_rat_night_stage_3", "environment")
		BeardLib:ReplaceScriptData(mod_path .. "scriptdata/pd2_env_night_hh.custom_xml", "custom_xml", "environments/pd2_kosugi/pd2_kosugi", "environment")
	end
	
	if diff_index == 8 and sex == "friend" then
		BeardLib:ReplaceScriptData(mod_path .. "scriptdata/shitfaceenvironment.custom_xml", "custom_xml", "environments/pd2_friend/pd2_friend", "environment")
	end
	
	if diff_index == 8 and sex == "wwh_hh" then
		BeardLib:ReplaceScriptData(mod_path .. "scriptdata/albaniandeal.custom_xml", "custom_xml", "environments/pd2_wwh/pd2_wwh", "environment")
		BeardLib:ReplaceScriptData(mod_path .. "scriptdata/albaniandeal_indoor.custom_xml", "custom_xml", "environments/pd2_wwh/pd2_wwh_train", "environment")
	end

end)
