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

function MenuCallbackHandler:choice_crimenet_one_down(item)
	local value = item:value() == "on" and item:value() or managers.mutators:get_enabled_active_mutator_category() == "event" and true
	
	managers.menu_component:set_crimenet_contract_one_down(value)
end

function MenuCallbackHandler:start_job(job_data)
	if not managers.job:activate_job(job_data.job_id) then
		return
	end

	Global.game_settings.level_id = managers.job:current_level_id()
	Global.game_settings.mission = managers.job:current_mission()
	Global.game_settings.world_setting = managers.job:current_world_setting()
	Global.game_settings.difficulty = job_data.difficulty
	Global.game_settings.one_down = managers.mutators:get_enabled_active_mutator_category() == "event" and true or job_data.one_down
	Global.game_settings.weekly_skirmish = job_data.weekly_skirmish

	if managers.platform then
		managers.platform:update_discord_heist()
	end

	local matchmake_attributes = self:get_matchmake_attributes()

	if Network:is_server() then
		local job_id_index = tweak_data.narrative:get_index_from_job_id(managers.job:current_job_id())
		local level_id_index = tweak_data.levels:get_index_from_level_id(Global.game_settings.level_id)
		local difficulty_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)
		local one_down = Global.game_settings.one_down
		local weekly_skirmish = Global.game_settings.weekly_skirmish

		managers.network:session():send_to_peers("sync_game_settings", job_id_index, level_id_index, difficulty_index, one_down, weekly_skirmish)
		managers.network.matchmake:set_server_attributes(matchmake_attributes)
		managers.mutators:update_lobby_info()
		managers.menu_component:on_job_updated()
		managers.menu:open_node("lobby")
		managers.menu:active_menu().logic:refresh_node("lobby", true)
	else
		managers.network.matchmake:create_lobby(matchmake_attributes)
	end

	managers.platform:refresh_rich_presence()
end


function MenuCrimeNetContractInitiator:modify_node(original_node, data)
	local node = deep_clone(original_node)

	if Global.game_settings.single_player then
		node:item("toggle_ai"):set_value(Global.game_settings.team_ai and Global.game_settings.team_ai_option or 0)
	elseif data.smart_matchmaking then
		-- Nothing
	elseif not data.server then
		node:item("lobby_job_plan"):set_value(Global.game_settings.job_plan)
		node:item("lobby_kicking_option"):set_value(Global.game_settings.kick_option)
		node:item("lobby_permission"):set_value(Global.game_settings.permission)
		node:item("lobby_reputation_permission"):set_value(Global.game_settings.reputation_permission)
		node:item("lobby_drop_in_option"):set_value(Global.game_settings.drop_in_option)
		node:item("toggle_ai"):set_value(Global.game_settings.team_ai and Global.game_settings.team_ai_option or 0)
		node:item("toggle_auto_kick"):set_value(Global.game_settings.auto_kick and "on" or "off")
		node:item("toggle_allow_modded_players"):set_value(Global.game_settings.allow_modded_players and "on" or "off")

		if tweak_data.quickplay.stealth_levels[data.job_id] then
			local job_plan_item = node:item("lobby_job_plan")
			local stealth_option = nil

			for _, option in ipairs(job_plan_item:options()) do
				if option:value() == 2 then
					stealth_option = option

					break
				end
			end

			job_plan_item:clear_options()
			job_plan_item:add_option(stealth_option)
		end
	end

	if data.customize_contract then
		node:set_default_item_name("buy_contract")

		local job_data = data

		if job_data and job_data.job_id then
			local buy_contract_item = node:item("buy_contract")

			if buy_contract_item then
				local can_afford = managers.money:can_afford_buy_premium_contract(job_data.job_id, job_data.difficulty_id or 3)
				buy_contract_item:parameters().text_id = can_afford and "menu_cn_premium_buy_accept" or "menu_cn_premium_cannot_buy"
				buy_contract_item:parameters().disabled_color = Color(1, 0.6, 0.2, 0.2)

				buy_contract_item:set_enabled(can_afford)
			end
		end
		
		local value = managers.mutators:get_enabled_active_mutator_category() == "event"
		
		if not value then
			node:item("toggle_one_down"):set_value("off")
		else
			node:item("toggle_one_down"):set_value("on")
			node:item("toggle_one_down"):set_enabled(false)
		end
	end

	if tweak_data.narrative:is_job_locked(data.job_id) then
		node:item("accept_contract"):set_enabled(false)
	end

	if data and data.back_callback then
		table.insert(node:parameters().back_callback, data.back_callback)
	end

	node:parameters().menu_component_data = data

	return node
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
	
	MenuCallbackHandler.callback_shin_toggle_screenFX = function(self,item) --toggle
		PD2THHSHIN:ChangeSetting("toggle_screenFX",item:value() == "on")
		PD2THHSHIN.need_to_reset_visuals = true
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
	local hold = item:value() == "on" or false

	managers.user:set_setting("hold_to_jump", hold)
end

function MenuCallbackHandler:staticrecoil_clbk(item)
	local on = item:value() == "on" or false

	managers.user:set_setting("staticrecoil", on)
end

function MenuCallbackHandler:holdtofire_clbk(item)
	local on = item:value() == "on" or false

	managers.user:set_setting("holdtofire", on)
end

Hooks:Add("MenuManagerBuildCustomMenus", "HH_CONTROLS", function(menu_manager, nodes)
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
	
	local params = {
		name = "staticrecoil",
		text_id = "hhmenu_staticrecoil",
		help_id = "hhmenu_staticrecoil_help",
		callback = "staticrecoil_clbk",
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
	
	local recoil_item = controls_node:create_item(data_node, params)
	
	local position = 0
	
	for index, item in pairs(controls_node._items) do
		if item:name() == "hold_to_jump" then
			position = index + 1
			break
		end
	end
	
	controls_node:insert_item(recoil_item, position)
	
	local params = {
		name = "holdtofire",
		text_id = "hhmenu_holdtofire",
		help_id = "hhmenu_holdtofire_help",
		callback = "holdtofire_clbk",
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
	
	local fire_item = controls_node:create_item(data_node, params)
	
	local position = 0
	
	for index, item in pairs(controls_node._items) do
		if item:name() == "staticrecoil" then
			position = index + 1
			break
		end
	end
	
	controls_node:insert_item(fire_item, position)
end)

Hooks:PostHook(MenuOptionInitiator, "modify_controls", "HH_modify_controls", function(self, node)
	local option_value = "off"
	local jump_item = node:item("hold_to_jump")
	local recoil_item = node:item("staticrecoil")
	local holdtofire_item = node:item("holdtofire")
	
	if jump_item then
		if managers.user:get_setting("hold_to_jump") then
			option_value = "on"
		end

		jump_item:set_value(option_value)
	end
	
	option_value = "off"
	
	if recoil_item then
		if managers.user:get_setting("staticrecoil") then
			option_value = "on"
		end
		
		recoil_item:set_value(option_value)
	end
	
	option_value = "off"
	
	if holdtofire_item then
		if managers.user:get_setting("holdtofire") then
			option_value = "on"
		end
		
		holdtofire_item:set_value(option_value)
	end
end)