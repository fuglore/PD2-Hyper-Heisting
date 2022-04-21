
if restoration and restoration:all_enabled("HUD/MainHUD", "HUD/AssaultPanel") then
	return
end

if PD2THHSHIN and PD2THHSHIN:IsFlavorAssaultEnabled() then

function HUDAssaultCorner:init(hud, full_hud, tweak_hud)
	self._hud_panel = hud.panel
	self._full_hud_panel = full_hud.panel

	if self._hud_panel:child("assault_panel") then
		self._hud_panel:remove(self._hud_panel:child("assault_panel"))
	end

	local size = 200

	if _G.IS_VR then
		size = 150
	end

	local assault_panel = self._hud_panel:panel({
		name = "assault_panel",
		h = 100,
		visible = false,
		w = size * 2
	})

	assault_panel:set_top(0)
	assault_panel:set_right(self._hud_panel:w())

	self._assault_mode = "normal"
	self._assault_state = "normal"
	
	self._regular_assault_color = Color(1, 1, 1, 0)
	self._danger_color = tweak_data.screen_colors.skirmish_color
	self._clutch_color = Color(1, 1, 0.1, 0)
	self._vip_assault_color = Color(1, 1, 0.5019607843137255, 0)

	if managers.mutators:are_mutators_active() then
		self._assault_color = Color(255, 211, 133, 255) / 255
		self._vip_assault_color = Color(255, 255, 133, 225) / 255
	end

	self._assault_survived_color = Color(1, 0.12549019607843137, 0.9019607843137255, 0.12549019607843137)
	self._current_assault_color = self._regular_assault_color
	self._assault_color = self._current_assault_color
	local icon_assaultbox = assault_panel:bitmap({
		texture = "guis/textures/pd2/hud_icon_assaultbox",
		name = "icon_assaultbox",
		h = 24,
		layer = 0,
		w = 24,
		y = 0,
		visible = true,
		blend_mode = "add",
		halign = "right",
		x = 0,
		valign = "top",
		color = self._assault_color
	})

	icon_assaultbox:set_right(icon_assaultbox:parent():w())

	self._bg_box_size = size * 1.5 - 58
	self._bg_box = HUDBGBox_create(assault_panel, {
		x = 0,
		h = 38,
		y = 0,
		w = self._bg_box_size
	}, {
		blend_mode = "add",
		color = self._assault_color
	})

	self._bg_box:set_right(icon_assaultbox:left() - 3)

	local yellow_tape = assault_panel:rect({
		name = "yellow_tape",
		visible = false,
		layer = 1,
		h = tweak_data.hud.location_font_size * 1.5,
		w = size * 3,
		color = Color(1, 0.8, 0)
	})

	yellow_tape:set_center(10, 10)
	yellow_tape:set_rotation(30)
	yellow_tape:set_blend_mode("add")
	assault_panel:panel({
		name = "text_panel",
		layer = 1,
		w = yellow_tape:w()
	}):set_center(yellow_tape:center())

	if self._hud_panel:child("hostages_panel") then
		self._hud_panel:remove(self._hud_panel:child("hostages_panel"))
	end

	local hostage_w = 70
	local hostage_h = 38
	local hostage_box = 38
	local hostages_panel = self._hud_panel:panel({
		name = "hostages_panel",
		w = hostage_w,
		h = hostage_h,
		x = self._hud_panel:w() - hostage_w
	})
	local hostages_icon = hostages_panel:bitmap({
		texture = "guis/textures/pd2/hud_icon_hostage",
		name = "hostages_icon",
		layer = 1,
		y = 0,
		x = 0,
		valign = "top"
	})
	self._hostages_bg_box = HUDBGBox_create(hostages_panel, {
		x = 0,
		y = 0,
		w = hostage_box,
		h = hostage_box
	}, {})

	hostages_icon:set_right(hostages_panel:w() + 5)
	hostages_icon:set_center_y(self._hostages_bg_box:h() / 2)
	self._hostages_bg_box:set_right(hostages_icon:left())

	local num_hostages = self._hostages_bg_box:text({
		layer = 1,
		vertical = "center",
		name = "num_hostages",
		align = "center",
		text = "0",
		y = 0,
		x = 0,
		valign = "center",
		w = self._hostages_bg_box:w(),
		h = self._hostages_bg_box:h(),
		color = Color.white,
		font = tweak_data.hud_corner.assault_font,
		font_size = tweak_data.hud_corner.numhostages_size
	})

	if tweak_hud.no_hostages then
		hostages_panel:hide()
	end

	self:setup_wave_display(0, hostages_panel:left() - 3)

	if self._hud_panel:child("point_of_no_return_panel") then
		self._hud_panel:remove(self._hud_panel:child("point_of_no_return_panel"))
	end

	local size = 300
	local point_of_no_return_panel = self._hud_panel:panel({
		name = "point_of_no_return_panel",
		h = 40,
		visible = false,
		w = size,
		x = self._hud_panel:w() - size
	})
	self._noreturn_data = self:_get_noreturn_data()
	local icon_noreturnbox = point_of_no_return_panel:bitmap({
		texture = "guis/textures/pd2/hud_icon_noreturnbox",
		name = "icon_noreturnbox",
		h = 24,
		layer = 0,
		w = 24,
		y = 0,
		visible = true,
		blend_mode = "add",
		halign = "right",
		x = 0,
		valign = "top",
		color = self._noreturn_data.color,
		texture = self._noreturn_data.icon_texture,
		texture_rect = self._noreturn_data.icon_texture_rect
	})

	icon_noreturnbox:set_right(icon_noreturnbox:parent():w())

	self._noreturn_bg_box = HUDBGBox_create(point_of_no_return_panel, {
		x = 0,
		h = 38,
		y = 0,
		w = self._bg_box_size
	}, {
		blend_mode = "add",
		color = self._noreturn_data.color
	})

	self._noreturn_bg_box:set_right(icon_noreturnbox:left() - 3)

	local w = point_of_no_return_panel:w()
	local size = 200 - tweak_data.hud.location_font_size
	local point_of_no_return_text = self._noreturn_bg_box:text({
		valign = "center",
		vertical = "center",
		name = "point_of_no_return_text",
		blend_mode = "add",
		align = "right",
		text = "",
		y = 0,
		x = 0,
		layer = 1,
		color = self._noreturn_data.color,
		font_size = tweak_data.hud_corner.noreturn_size,
		font = tweak_data.hud_corner.assault_font
	})

	point_of_no_return_text:set_text(utf8.to_upper(managers.localization:text(self._noreturn_data.text_id, {
		time = ""
	})))
	point_of_no_return_text:set_size(self._noreturn_bg_box:w(), self._noreturn_bg_box:h())

	local point_of_no_return_timer = self._noreturn_bg_box:text({
		valign = "center",
		vertical = "center",
		name = "point_of_no_return_timer",
		blend_mode = "add",
		align = "center",
		text = "",
		y = 0,
		x = 0,
		layer = 1,
		color = self._noreturn_data.color,
		font_size = tweak_data.hud_corner.noreturn_size,
		font = tweak_data.hud_corner.assault_font
	})
	local _, _, w, h = point_of_no_return_timer:text_rect()

	point_of_no_return_timer:set_size(46, self._noreturn_bg_box:h())
	point_of_no_return_timer:set_right(point_of_no_return_timer:parent():w())
	point_of_no_return_text:set_right(math.round(point_of_no_return_timer:left()))
	self:_update_noreturn()

	if self._hud_panel:child("casing_panel") then
		self._hud_panel:remove(self._hud_panel:child("casing_panel"))
	end

	local size = 300
	local casing_panel = self._hud_panel:panel({
		name = "casing_panel",
		h = 40,
		visible = false,
		w = size,
		x = self._hud_panel:w() - size
	})
	self._casing_color = Color.white
	local icon_casingbox = casing_panel:bitmap({
		texture = "guis/textures/pd2/hud_icon_stealthbox",
		name = "icon_casingbox",
		h = 24,
		layer = 0,
		w = 24,
		y = 0,
		visible = true,
		blend_mode = "add",
		halign = "right",
		x = 0,
		valign = "top",
		color = self._casing_color
	})

	icon_casingbox:set_right(icon_casingbox:parent():w())

	self._casing_bg_box = HUDBGBox_create(casing_panel, {
		x = 0,
		h = 38,
		y = 0,
		w = self._bg_box_size
	}, {
		blend_mode = "add",
		color = self._casing_color
	})

	self._casing_bg_box:set_right(icon_casingbox:left() - 3)

	local w = casing_panel:w()
	local size = 200 - tweak_data.hud.location_font_size

	casing_panel:panel({
		name = "text_panel",
		layer = 1,
		w = yellow_tape:w()
	}):set_center(yellow_tape:center())

	if self._hud_panel:child("buffs_panel") then
		self._hud_panel:remove(self._hud_panel:child("buffs_panel"))
	end

	local width = 200
	local x = assault_panel:left() + self._bg_box:left() - 3 - width
	local buffs_panel = self._hud_panel:panel({
		name = "buffs_panel",
		h = 38,
		visible = false,
		w = width,
		x = x
	})
	self._vip_bg_box_bg_color = Color(1, 0, 0.6666666666666666, 1)
	self._vip_bg_box = HUDBGBox_create(buffs_panel, {
		w = 38,
		h = 38,
		y = 0,
		x = width - 38
	}, {
		color = Color.white,
		bg_color = self._vip_bg_box_bg_color
	})
	local vip_icon = self._vip_bg_box:bitmap({
		texture = "guis/textures/pd2/hud_buff_shield",
		name = "vip_icon",
		h = 38,
		layer = 0,
		w = 38,
		y = 0,
		visible = true,
		blend_mode = "add",
		halign = "center",
		x = 0,
		valign = "center",
		color = Color.white
	})

	vip_icon:set_center(self._vip_bg_box:w() / 2, self._vip_bg_box:h() / 2)
end

Hooks:PostHook(HUDAssaultCorner, "_get_assault_strings", "post_FG", function(self)
	local level = Global.level_data and Global.level_data.level_id
	local cover_line_to_use = "hud_assault_cover"
	local danger_line_to_use = "hud_assault_danger"
	local FG_chance = math.random(1, 331)
	local danger_chance = math.random(1, 64)
	local heat_chance = math.random(1, 57)
	local versusline = "hud_assault_faction_swat"
	
	local faction = tweak_data.levels:get_ai_group_type()
	
	local assaultline = "hud_assault_assault"
	local heatbonus_line_to_use = "hud_heat_common"
	
	if level == "haunted" then
		assaultline = "hud_assault_assault_nightmare"
		cover_line_to_use = "hud_assault_cover_nightmare"
		versusline = "hud_assault_faction_nightmare"
		
		if self._assault_mode == "normal" then
			local ids_risk = Idstring("risk")
			
			if self._assault_state == "danger" or self._assault_state == "lastcrimstanding" then
				if managers.job:current_difficulty_stars() > 0 then
					return {
						assaultline,
						"hud_assault_end_line",
						danger_line_to_use,
						"hud_assault_end_line",
						versusline,
						"hud_assault_end_line",
						ids_risk,
						"hud_assault_end_line",
						assaultline,
						"hud_assault_end_line",
						danger_line_to_use,
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
						danger_line_to_use,
						"hud_assault_end_line",
						versusline,
						"hud_assault_end_line",
						assaultline,
						"hud_assault_end_line",
						danger_line_to_use,
						"hud_assault_end_line",
						versusline,
						"hud_assault_end_line",
					}
				end
			else		
				if managers.job:current_difficulty_stars() > 0 then
					if self._assault_state == "heat" then
						return {
							"hud_assault_heat",
							"hud_assault_end_line",
							heatbonus_line_to_use,
							"hud_assault_end_line",
							"hud_heat_gameplay",
							"hud_assault_end_line",
							ids_risk,
							"hud_assault_end_line",
							"hud_assault_heat",
							"hud_assault_end_line",
							heatbonus_line_to_use,
							"hud_assault_end_line",
							"hud_heat_gameplay",
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
					end
				else
					if self._assault_state == "heat" then
						return {
							"hud_assault_heat",
							"hud_assault_end_line",
							heatbonus_line_to_use,
							"hud_assault_end_line",
							"hud_heat_gameplay",
							"hud_assault_end_line",
							assaultline,
							"hud_assault_end_line",
							heatbonus_line_to_use,
							"hud_assault_end_line",
							"hud_heat_gameplay",
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
			end
		end
	elseif faction then
		local diff_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)
		if faction == "bo" then
			if diff_index < 4 then
				versusline = "hud_assault_faction_sbz"
			elseif diff_index < 6 then
				versusline = "hud_assault_faction_ovk"
			elseif diff_index == 6 then
				versusline = "hud_assault_faction_bofadeez"
			elseif diff_index == 7 then
				versusline = "hud_assault_faction_bofa"
			else
				versusline = "hud_assault_faction_zeal"
			end
		elseif faction == "russia" then
			versusline = "hud_assault_faction_mad"
			assaultline = "hud_assault_assaultrepers"			
		elseif faction == "federales" then
			versusline = "hud_assault_faction_federales"
			assaultline = "hud_assault_assault_mexcross"
		elseif level == "red 2" then
			versusline = "hud_assault_assault_blma"
			assaultline = "hud_assault_faction_federales"			
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
	
	if FG_chance <= 130 then
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
	
	if danger_chance <= 63 then
		danger_line_to_use = "hud_assault_FG_danger" .. danger_chance
	else
		if managers.groupai and managers.groupai:state()._in_mexico or level == "mex_cooking" or faction == "federales" then
			danger_line_to_use = "hud_assault_dangermex"
		end
	end
	
	if heat_chance <= 57 then
		heatbonus_line_to_use = "hud_heat_" .. heat_chance
	end
	
	if self._assault_mode == "normal" then
		local ids_risk = Idstring("risk")
		
		if self._bosses and self._bosses > 0 then
			local boss_line = "hud_assault_boss"
			
			if self._bosses > 1 then
				boss_line = boss_line .. "es"
			end
		
			if managers.job:current_difficulty_stars() > 0 then
				return {
					boss_line,
					"hud_assault_end_line",
					cover_line_to_use,
					"hud_assault_end_line",
					ids_risk,
					"hud_assault_end_line",
					boss_line,
					"hud_assault_end_line",
					cover_line_to_use,
					"hud_assault_end_line",
					ids_risk,
					"hud_assault_end_line",
				}
			else
				return {
					boss_line,
					"hud_assault_end_line",
					cover_line_to_use,
					"hud_assault_end_line",
					boss_line,
					"hud_assault_end_line",
					cover_line_to_use,
					"hud_assault_end_line"
				}
			end
		elseif self._assault_state == "danger" or self._assault_state == "lastcrimstanding" then
			if managers.job:current_difficulty_stars() > 0 then
				return {
					assaultline,
					"hud_assault_end_line",
					danger_line_to_use,
					"hud_assault_end_line",
					versusline,
					"hud_assault_end_line",
					ids_risk,
					"hud_assault_end_line",
					assaultline,
					"hud_assault_end_line",
					danger_line_to_use,
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
					danger_line_to_use,
					"hud_assault_end_line",
					versusline,
					"hud_assault_end_line",
					assaultline,
					"hud_assault_end_line",
					danger_line_to_use,
					"hud_assault_end_line",
					versusline,
					"hud_assault_end_line",
				}
			end
		else		
			if managers.job:current_difficulty_stars() > 0 then
				if self._assault_state == "heat" then
					return {
						"hud_assault_heat",
						"hud_assault_end_line",
						heatbonus_line_to_use,
						"hud_assault_end_line",
						"hud_heat_gameplay",
						"hud_assault_end_line",
						ids_risk,
						"hud_assault_end_line",
						"hud_assault_heat",
						"hud_assault_end_line",
						heatbonus_line_to_use,
						"hud_assault_end_line",
						"hud_heat_gameplay",
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
				end
			else
				if self._assault_state == "heat" then
					return {
						"hud_assault_heat",
						"hud_assault_end_line",
						heatbonus_line_to_use,
						"hud_assault_end_line",
						"hud_heat_gameplay",
						"hud_assault_end_line",
						assaultline,
						"hud_assault_end_line",
						heatbonus_line_to_use,
						"hud_assault_end_line",
						"hud_heat_gameplay",
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

function HUDAssaultCorner:_start_assault(text_list)
	text_list = text_list or {
		""
	}
	local assault_panel = self._hud_panel:child("assault_panel")
	local text_panel = assault_panel:child("text_panel")

	self:_set_text_list(text_list)

	local started_now = not self._assault
	self._assault = true

	if self._bg_box:child("text_panel") then
		self._bg_box:child("text_panel"):stop()
		self._bg_box:child("text_panel"):clear()
	else
		self._bg_box:panel({
			name = "text_panel"
		})
	end

	self._bg_box:child("bg"):stop()
	assault_panel:set_visible(true)

	local icon_assaultbox = assault_panel:child("icon_assaultbox")

	icon_assaultbox:stop()
	icon_assaultbox:animate(callback(self, self, "_show_icon_assaultbox"))

	local config = {
		attention_forever = true,
		attention_color = self._current_assault_color ~= nil and self._current_assault_color or self._regular_assault_color,
		attention_color_function = callback(self, self, "assault_attention_color_function")
	}

	self._bg_box:stop()
	self._bg_box:animate(callback(nil, _G, "HUDBGBox_animate_open_left"), 0.75, self._bg_box_size, function ()
	end, config)

	local box_text_panel = self._bg_box:child("text_panel")

	box_text_panel:stop()
	box_text_panel:animate(callback(self, self, "_animate_text"), nil, nil, callback(self, self, "assault_attention_color_function"))
	self:_set_feedback_color(config.color)

	if alive(self._wave_bg_box) then
		self._wave_bg_box:stop()
		self._wave_bg_box:animate(callback(self, self, "_animate_wave_started"), self)
	end

	if managers.skirmish:is_skirmish() and started_now then
		self:_popup_wave_started()
	end
end

function HUDAssaultCorner:_popup_boss_incoming()
	local boss_string = managers.localization:to_upper_text("hud_assault_boss_incoming")
	self:_popup_wave(boss_string, self._clutch_color)
end

function HUDAssaultCorner:sync_set_assault_mode(mode)
	if self._assault_mode == mode then
		return
	end

	self._assault_mode = mode
	local color = self._current_assault_color ~= nil and self._current_assault_color or self._regular_assault_color

	if mode == "phalanx" then
		color = self._vip_assault_color
	end

	self:_update_assault_hud_color(color)
	self:_set_text_list(self:_get_assault_strings())

	local assault_panel = self._hud_panel:child("assault_panel")
	local icon_assaultbox = assault_panel:child("icon_assaultbox")
	local image = mode == "phalanx" and "guis/textures/pd2/hud_icon_padlockbox" or "guis/textures/pd2/hud_icon_assaultbox"

	icon_assaultbox:set_image(image)
end

function HUDAssaultCorner:sync_start_assault(assault_number)
	if self._point_of_no_return or self._casing then
		return
	end

	local color = self._current_assault_color ~= nil and self._current_assault_color or self._regular_assault_color

	if self._assault_mode == "phalanx" then
		color = self._vip_assault_color
	end

	self:_update_assault_hud_color(color)
	self:set_assault_wave_number(assault_number)

	self._start_assault_after_hostage_offset = true

	self:_set_hostage_offseted(true)
end

function HUDAssaultCorner:set_color_state(state, dont_refresh_hud)
	if not state then
		return
	end
	
	if state == "danger" then
		self._assault_state = "danger"
		if self._current_assault_color ~= self._danger_color then
			self:_update_assault_hud_color(self._danger_color)
		end
	elseif state == "normal" then
		self._assault_state = "normal"
		if self._current_assault_color ~= self._regular_assault_color then
			self:_update_assault_hud_color(self._regular_assault_color)
		end
	elseif state == "lastcrimstanding" then
		self._assault_state = "lastcrimstanding"
		if self._current_assault_color ~= self._clutch_color then
			self:_update_assault_hud_color(self._clutch_color)
		end
	elseif state == "heat" then
		self._assault_state = "heat"
		if self._current_assault_color ~= self._assault_survived_color then
			self:_update_assault_hud_color(self._assault_survived_color)
		end
	else
		log("HUDASSAULTCORNER: STATE DOES NOT MATCH ANY COLOR!!!")
		self._assault_state = "normal"
		self:_update_assault_hud_color(self._regular_assault_color)
	end
	
	if not dont_refresh_hud then
		self:_start_assault(self:_get_assault_strings())
	end
end

function HUDAssaultCorner:_update_assault_hud_color(color)
	self._current_assault_color = color
	self._assault_color = self._current_assault_color

	self._bg_box:child("left_top"):set_color(color)
	self._bg_box:child("left_bottom"):set_color(color)
	self._bg_box:child("right_top"):set_color(color)
	self._bg_box:child("right_bottom"):set_color(color)

	local assault_panel = self._hud_panel:child("assault_panel")
	local icon_assaultbox = assault_panel:child("icon_assaultbox")

	icon_assaultbox:set_color(color)
end

function HUDAssaultCorner:_close_assault_box()
	local icon_assaultbox = self._hud_panel:child("assault_panel"):child("icon_assaultbox")

	icon_assaultbox:stop()

	local function close_done()
		self._bg_box:set_visible(false)
		icon_assaultbox:stop()
		icon_assaultbox:animate(callback(self, self, "_hide_icon_assaultbox"))
		self:sync_set_assault_mode("normal")
		self:set_color_state(self._assault_state, true)
	end

	self._bg_box:stop()
	self._bg_box:animate(callback(nil, _G, "HUDBGBox_animate_close_left"), close_done)
end

end
