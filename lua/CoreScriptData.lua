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
			"sky_2003_dusk_blue",
			"sky_2003_dusk_blue_high_color_scale",
			"sky_2335_night_moon"
			
        }
        for i = 1, #skies do
			sky = skies[i]
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
	
	if diff_index == 8 or managers.modifiers and managers.modifiers:check_boolean("TotalAnarchy") then
		BeardLib:ReplaceScriptData(mod_path .. "scriptdata/sunset_hell.custom_xml", "custom_xml", "environments/pd2_env_mid_day/pd2_env_mid_day", "environment")
	else
		BeardLib:ReplaceScriptData(mod_path .. "scriptdata/pd2_env_day_hh.custom_xml", "custom_xml", "environments/pd2_env_mid_day/pd2_env_mid_day", "environment")
	end
	
	if sex == "haunted" then
		BeardLib:ReplaceScriptData(mod_path .. "scriptdata/hellvoid.custom_xml", "custom_xml", "environments/pd2_env_framing_frame_stage_2/pd2_env_framing_frame_stage_2", "environment")
	elseif diff_index == 8 or managers.modifiers and managers.modifiers:check_boolean("TotalAnarchy") then
		BeardLib:ReplaceScriptData(mod_path .. "scriptdata/heated_confrontation.custom_xml", "custom_xml", "environments/pd2_env_hox1_01/pd2_env_hox1_01", "environment")
		BeardLib:ReplaceScriptData(mod_path .. "scriptdata/heated_confrontation_garage.custom_xml", "custom_xml", "environments/pd2_env_hox1_02/pd2_env_hox1_02", "environment")
		BeardLib:ReplaceScriptData(mod_path .. "scriptdata/serious_moonlight.custom_xml", "custom_xml", "environments/pd2_env_ed2/pd2_env_ed2", "environment")
		BeardLib:ReplaceScriptData(mod_path .. "scriptdata/calmbeforethestorm.custom_xml", "custom_xml", "environments/pd2_env_ed1/pd2_env_ed1", "environment")
		BeardLib:ReplaceScriptData(mod_path .. "scriptdata/serious_moonlight.custom_xml", "custom_xml", "environments/pd2_env_ed2/pd2_env_ed2", "environment")
		BeardLib:ReplaceScriptData(mod_path .. "scriptdata/serious_moonlight.custom_xml", "custom_xml", "environments/pd2_env_night/pd2_env_night", "environment")
		BeardLib:ReplaceScriptData(mod_path .. "scriptdata/serious_moonlight.custom_xml", "custom_xml", "environments/pd2_hlm1/pd2_hlm1", "environment")
		BeardLib:ReplaceScriptData(mod_path .. "scriptdata/serious_moonlight.custom_xml", "custom_xml", "environments/pd2_env_rat_night/pd2_env_rat_night", "environment")
		BeardLib:ReplaceScriptData(mod_path .. "scriptdata/serious_moonlight.custom_xml", "custom_xml", "environments/pd2_env_rat_night_stage_3/pd2_env_rat_night_stage_3", "environment")
		BeardLib:ReplaceScriptData(mod_path .. "scriptdata/serious_moonlight.custom_xml", "custom_xml", "environments/pd2_kosugi/pd2_kosugi", "environment")
		BeardLib:ReplaceScriptData(mod_path .. "scriptdata/no_mercy_default.custom_xml", "custom_xml", "units/pd2_dlc_nmh/enviroments/nmh_enviroment_01", "environment")
		BeardLib:ReplaceScriptData(mod_path .. "scriptdata/serious_moonlight.custom_xml", "custom_xml", "environments/pd2_env_framing_frame_stage_2/pd2_env_framing_frame_stage_2", "environment")
	else
		BeardLib:ReplaceScriptData(mod_path .. "scriptdata/maybe_some_mercy.custom_xml", "custom_xml", "units/pd2_dlc_nmh/enviroments/nmh_enviroment_01", "environment")
		BeardLib:ReplaceScriptData(mod_path .. "scriptdata/pd2_env_night_hh.custom_xml", "custom_xml", "environments/pd2_env_night/pd2_env_night", "environment")
		BeardLib:ReplaceScriptData(mod_path .. "scriptdata/pd2_env_night_hh.custom_xml", "custom_xml", "environments/pd2_hlm1/pd2_hlm1", "environment")
		BeardLib:ReplaceScriptData(mod_path .. "scriptdata/pd2_env_night_hh.custom_xml", "custom_xml", "environments/pd2_env_rat_night/pd2_env_rat_night", "environment")
		BeardLib:ReplaceScriptData(mod_path .. "scriptdata/pd2_env_night_hh.custom_xml", "custom_xml", "environments/pd2_env_rat_night_stage_3/pd2_env_rat_night_stage_3", "environment")
		BeardLib:ReplaceScriptData(mod_path .. "scriptdata/pd2_env_night_hh.custom_xml", "custom_xml", "environments/pd2_kosugi/pd2_kosugi", "environment")
		BeardLib:ReplaceScriptData(mod_path .. "scriptdata/pd2_env_night_hh.custom_xml", "custom_xml", "environments/pd2_env_framing_frame_stage_2/pd2_env_framing_frame_stage_2", "environment")
	end
	
	if diff_index == 8 or managers.modifiers and managers.modifiers:check_boolean("TotalAnarchy") then
		BeardLib:ReplaceScriptData(mod_path .. "scriptdata/btmountain/finalsectionpbr.custom_xml", "custom_xml", "environments/pd2_berry_outdoor_night/pd2_berry_outdoor_night", "environment")
		BeardLib:ReplaceScriptData(mod_path .. "scriptdata/btmountain/pbrconnectionanarchy.custom_xml", "custom_xml", "environments/pd2_berry_connection/pd2_berry_connection", "environment")
		BeardLib:ReplaceScriptData(mod_path .. "scriptdata/btmountain/pbrundergroundanarchy.custom_xml", "custom_xml", "environments/pd2_berry_underground/pd2_berry_underground", "environment")
		
		BeardLib:ReplaceScriptData(mod_path .. "scriptdata/pd2_env_night_hh.custom_xml", "custom_xml", "environments/pd2_berry_outdoor_final_top_part/pd2_berry_outdoor_final_top_part", "environment")	
	else
		BeardLib:ReplaceScriptData(mod_path .. "scriptdata/pd2_env_night_hh.custom_xml", "custom_xml", "environments/pd2_berry_outdoor_night/pd2_berry_outdoor_night", "environment")
		BeardLib:ReplaceScriptData(mod_path .. "scriptdata/btmountain/pbrconnectionhh.custom_xml", "custom_xml", "environments/pd2_berry_connection/pd2_berry_connection", "environment")
		BeardLib:ReplaceScriptData(mod_path .. "scriptdata/btmountain/pbrundergroundhh.custom_xml", "custom_xml", "environments/pd2_berry_underground/pd2_berry_underground", "environment")
		
		BeardLib:ReplaceScriptData(mod_path .. "scriptdata/btmountain/finalsectionpbr.custom_xml", "custom_xml", "environments/pd2_berry_outdoor_final_top_part/pd2_berry_outdoor_final_top_part", "environment")
		
	end
	
	
	if diff_index == 8 or managers.modifiers and managers.modifiers:check_boolean("TotalAnarchy") then
		if sex == "friend" then
			BeardLib:ReplaceScriptData(mod_path .. "scriptdata/shitfaceenvironment.custom_xml", "custom_xml", "environments/pd2_friend/pd2_friend", "environment")
		end
	end
	
	if diff_index == 8 or managers.modifiers and managers.modifiers:check_boolean("TotalAnarchy") then
		if sex == "wwh_hh" then
			BeardLib:ReplaceScriptData(mod_path .. "scriptdata/albaniandeal.custom_xml", "custom_xml", "environments/pd2_wwh/pd2_wwh", "environment")
			BeardLib:ReplaceScriptData(mod_path .. "scriptdata/albaniandeal_indoor.custom_xml", "custom_xml", "environments/pd2_wwh/pd2_wwh_train", "environment")
		end
	end

end)
