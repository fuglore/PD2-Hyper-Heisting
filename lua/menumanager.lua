function MenuCallbackHandler:accept_skirmish_contract(item, node)
	managers.menu:active_menu().logic:navigate_back(true)
	managers.menu:active_menu().logic:navigate_back(true)

	local job_data = {
		difficulty = "overkill_145",
		one_down = true,
		job_id = managers.skirmish:random_skirmish_job_id()
	}

	if Global.game_settings.single_player then
		MenuCallbackHandler:start_single_player_job(job_data)
	else
		MenuCallbackHandler:start_job(job_data)
	end
end

function MenuCallbackHandler:accept_skirmish_weekly_contract(item, node)
	managers.menu:active_menu().logic:navigate_back(true)
	managers.menu:active_menu().logic:navigate_back(true)

	local weekly_skirmish = managers.skirmish:active_weekly()
	local job_data = {
		difficulty = "overkill_145",
		one_down = true,
		weekly_skirmish = true,
		job_id = weekly_skirmish.id,
	}

	if Global.game_settings.single_player then
		MenuCallbackHandler:start_single_player_job(job_data)
	else
		MenuCallbackHandler:start_job(job_data)
	end
end

Hooks:Add("MenuManagerInitialize", "shin_initmenu", function(menu_manager)

	MenuCallbackHandler.callback_shin_toggle_overhaul_player = function(self,item) --toggle
		PD2THHSHIN:ChangeSetting("toggle_overhaul_player",item:value() == "on")
	end
	
	--you can disable the "requires restart" popup if you want, just change show_popup to false
	local show_popup = true
	
	MenuCallbackHandler.callback_shin_close = function(self,item) --toggle
		if show_popup then 
			local has_change = false
			local settings_list = "\n"
			for setting_name,value in pairs(PD2THHSHIN.session_settings) do 
				local new_value = PD2THHSHIN.settings[setting_name]
				if (new_value ~= nil) and (new_value ~= value) then 
					has_change = true
					settings_list = settings_list .. managers.localization:text("shin_" .. tostring(setting_name) .. "_title") .. ": " .. tostring(value) .. "-->" .. tostring(new_value) .. "\n"
				end
			end
			if has_change then 
				QuickMenu:new(managers.localization:text("shin_requires_restart_title"),string.gsub(managers.localization:text("shin_requires_restart_desc"),"$SETTINGSLIST",settings_list),{
					{
						text = managers.localization:text("dialog_ok"),
						is_cancel_button = true
					}
				},true)
			PD2THHSHIN:SaveSettings(true)
			end
		end
	end
	
	MenuHelper:LoadFromJsonFile(PD2THHSHIN._options_path, PD2THHSHIN, PD2THHSHIN.settings)
end)
