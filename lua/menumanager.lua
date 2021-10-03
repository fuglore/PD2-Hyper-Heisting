function MenuCallbackHandler:accept_skirmish_contract(item)
	local node = item:parameters().gui_node.node

	managers.menu:active_menu().logic:navigate_back(true)
	managers.menu:active_menu().logic:navigate_back(true)

	local job_id = (node:parameters().menu_component_data or {}).job_id
	local job_data = {
		difficulty = "overkill_145",
		one_down = false,		
		customize_contract = true,
		job_id = job_id or managers.skirmish:random_skirmish_job_id(),
		difficulty_id = tweak_data:difficulty_to_index("overkill_145")
	}

	managers.job:on_buy_job(job_data.job_id, job_data.difficulty_id or 3)

	if Global.game_settings.single_player then
		MenuCallbackHandler:start_single_player_job(job_data)
	else
		MenuCallbackHandler:start_job(job_data)
	end
end

function MenuCallbackHandler:accept_skirmish_weekly_contract(item)
	managers.menu:active_menu().logic:navigate_back(true)
	managers.menu:active_menu().logic:navigate_back(true)

	local weekly_skirmish = managers.skirmish:active_weekly()
	local job_data = {
		difficulty = "overkill_145",
		weekly_skirmish = true,
		one_down = false,				
		job_id = weekly_skirmish.id
	}

	if Global.game_settings.single_player then
		MenuCallbackHandler:start_single_player_job(job_data)
	else
		MenuCallbackHandler:start_job(job_data)
	end
end

Hooks:Add("MenuManagerInitialize", "shin_initmenu", function(menu_manager)
	local show_popup = nil
	MenuCallbackHandler.callback_shin_toggle_overhaul_player = function(self,item) --toggle
		PD2THHSHIN:ChangeSetting("toggle_overhaul_player",item:value() == "on")
		PD2THHSHIN.show_popup = true
	end
	
	MenuCallbackHandler.callback_shin_toggle_helmet = function(self,item) --toggle
		PD2THHSHIN:ChangeSetting("toggle_helmet",item:value() == "on")
	end
	
	MenuCallbackHandler.callback_shin_toggle_hhskulldiff = function(self,item) --toggle
		PD2THHSHIN:ChangeSetting("toggle_hhskulldiff",item:value() == "on")
	end
	
	MenuCallbackHandler.callback_shin_toggle_health_effect = function(self,item) --toggle
		PD2THHSHIN:ChangeSetting("toggle_health_effect",item:value() == "on")
	end
	
	MenuCallbackHandler.callback_shin_toggle_noweirddof = function(self,item) --toggle
		PD2THHSHIN:ChangeSetting("toggle_noweirddof",item:value() == "on")
	end
	
	MenuCallbackHandler.callback_shin_toggle_blurzonereduction = function(self,item) --toggle
		PD2THHSHIN:ChangeSetting("toggle_blurzonereduction",item:value() == "on")
	end
	
	MenuCallbackHandler.callback_shin_toggle_highpriorityglint = function(self,item) --toggle
		PD2THHSHIN:ChangeSetting("toggle_highpriorityglint",item:value() == "on")
	end
	
	MenuCallbackHandler.callback_shin_toggle_suppression = function(self,item) --toggle
		PD2THHSHIN:ChangeSetting("toggle_suppression",item:value() == "on")
		PD2THHSHIN.need_to_reset_visuals = true
	end
	
	MenuCallbackHandler.callback_shin_toggle_hhassault = function(self,item) --toggle
		PD2THHSHIN:ChangeSetting("toggle_hhassault",item:value() == "on")
		if managers.hud then
			managers.hud.needs_to_restart_assault_banner = true
		end
	end
	
	MenuCallbackHandler.callback_shin_screenshakemult = function(self,item)
		PD2THHSHIN.settings.screenshakemult = tonumber(item:value())
	end
	
	MenuCallbackHandler.callback_shin_albanian_content_enable = function(self,item) --toggle
		PD2THHSHIN:ChangeSetting("enable_albanian_content",item:value() == "on")
		PD2THHSHIN.show_popup = true		
	end
			
	--you can disable the "requires restart" popup if you want, just change show_popup to false

	MenuCallbackHandler.callback_shin_close = function(self,item) --toggle
		if PD2THHSHIN and PD2THHSHIN.show_popup then 
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
			end
			PD2THHSHIN.show_popup = nil
		end
		PD2THHSHIN:SaveSettings(true)
	end
	
	MenuHelper:LoadFromJsonFile(PD2THHSHIN._options_path, PD2THHSHIN, PD2THHSHIN.settings)
end)

function MenuCallbackHandler:hold_to_jump_clbk(item)
	local hold = item:value() == "on"

	managers.user:set_setting("hold_to_jump", hold)
end

Hooks:Add("MenuManagerBuildCustomMenus", "HH_HTJ", function(menu_manager, nodes)
	local controls_node = nodes.controls

	local params = {
		name = "hold_to_jump",
		text_id = "hhmenu_hold_to_jump",
		help_id = "hhmenu_hold_to_jump_help",
		callback = "hold_to_jump_clbk",
		filter = true,
		enabled = false,
		localize = true,
		localize_help = true
	}
	local data_node = {
		{
			w = "24",
			y = "0",
			h = "24",
			s_y = "24",
			value = "on",
			s_w = "24",
			s_h = "24",
			s_x = "24",
			_meta = "option",
			icon = "guis/textures/menu_tickbox",
			x = "24",
			s_icon = "guis/textures/menu_tickbox"
		},
		{
			w = "24",
			y = "0",
			h = "24",
			s_y = "24",
			value = "off",
			s_w = "24",
			s_h = "24",
			s_x = "0",
			_meta = "option",
			icon = "guis/textures/menu_tickbox",
			x = "0",
			s_icon = "guis/textures/menu_tickbox"
		},
		type = "CoreMenuItemToggle.ItemToggle"
	}
	
	local jump_item = controls_node:create_item(data_node, params)
	
	local position = 0
	
	for index, item in pairs(controls_node._items) do
		if item:name() == "toggle_hold_to_duck" then
			position = index + 1
			break
		end
	end
	
	controls_node:insert_item(jump_item, position)
end)

Hooks:PostHook(MenuOptionInitiator, "modify_controls", "HH_modify_controls", function(self, node)
	local option_value = "off"
	local jump_item = node:item("hold_to_jump")
	
	if jump_item then
		if managers.user:get_setting("hold_to_jump") then
			option_value = "on"
		end

		jump_item:set_value(option_value)
	end
end)