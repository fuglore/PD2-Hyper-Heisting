local padding = 10

function StageEndScreenGui:init(saferect_ws, fullrect_ws, statistics_data)
	self._safe_workspace = saferect_ws
	self._full_workspace = fullrect_ws
	self._fullscreen_panel = self._full_workspace:panel():panel({
		layer = 1
	})
	local w = self._safe_workspace:panel():w() / 2 - padding

	if managers.crime_spree:is_active() then
		w = w - padding + 1
	end

	self._panel = self._safe_workspace:panel():panel({
		layer = 6,
		w = w,
		h = self._safe_workspace:panel():h() * 0.5 - padding
	})

	self._panel:set_right(self._safe_workspace:panel():w())

	if managers.crime_spree:is_active() then
		self._panel:set_bottom(self._safe_workspace:panel():h() - (CrimeSpreeMissionsMenuComponent.get_height() + padding))
	else
		self._panel:set_bottom(self._safe_workspace:panel():h())
	end

	local continue_button = managers.menu:is_pc_controller() and "[ENTER]" or nil
	local continue_text = utf8.to_upper(managers.localization:text("menu_es_calculating_experience", {
		CONTINUE = continue_button
	}))

	if managers.crime_spree:is_active() then
		continue_text = ""
	end

	self._continue_button = self._panel:text({
		name = "ready_button",
		vertical = "center",
		h = 32,
		align = "right",
		layer = 1,
		text = continue_text,
		font_size = tweak_data.menu.pd2_large_font_size,
		font = tweak_data.menu.pd2_large_font,
		color = tweak_data.screen_colors.button_stage_3
	})
	local _, _, w, h = self._continue_button:text_rect()

	self._continue_button:set_size(w, h)
	self._continue_button:set_bottom(self._panel:h())
	self._continue_button:set_right(self._panel:w())

	self._button_not_clickable = true

	self._continue_button:set_color(tweak_data.screen_colors.item_stage_1)

	self._scroll_panel = self._panel:panel({
		name = "scroll_panel"
	})
	self._tab_panel = self._scroll_panel:panel({
		name = "tab_panel"
	})
	local big_text = self._fullscreen_panel:text({
		name = "continue_big_text",
		vertical = "bottom",
		h = 90,
		alpha = 0.4,
		align = "right",
		text = continue_text,
		font_size = tweak_data.menu.pd2_massive_font_size,
		font = tweak_data.menu.pd2_massive_font,
		color = tweak_data.screen_colors.button_stage_3
	})
	local x, y = managers.gui_data:safe_to_full_16_9(self._continue_button:world_right(), self._continue_button:world_center_y())

	big_text:set_world_right(x)
	big_text:set_world_center_y(y)
	big_text:move(13, -9)

	if MenuBackdropGUI then
		MenuBackdropGUI.animate_bg_text(self, big_text)
	end

	local text = managers.menu:is_pc_controller() and "" or managers.localization:get_default_macro("BTN_BOTTOM_L")
	local color = managers.menu:is_pc_controller() and tweak_data.screen_colors.button_stage_3 or Color.white
	local prev_page = self._panel:text({
		w = 0,
		name = "prev_page",
		vertical = "top",
		y = 0,
		layer = 2,
		h = tweak_data.menu.pd2_medium_font_size,
		font_size = tweak_data.menu.pd2_medium_font_size,
		font = tweak_data.menu.pd2_medium_font,
		text = text,
		color = color
	})
	local _, _, w, h = prev_page:text_rect()

	prev_page:set_size(w, h + 10)
	prev_page:set_left(0)

	self._prev_page = prev_page

	self._scroll_panel:move(w, 0)

	self._items = {}
	local item = nil
	local tab_height = 0
	local show_summary = true

	if managers.crime_spree:is_active() then
		show_summary = false
		item = CrimeSpreeResultTabItem:new(self._panel, self._tab_panel, utf8.to_upper(managers.localization:text("menu_es_crime_spree_summary")), #self._items + 1)

		table.insert(self._items, item)
	end

	local moneythrower_spent = game_state_machine:current_state()._moneythrower_spendings or 0
	local should_show_moneythrower_spending = moneythrower_spent > 0

	if show_summary then
		local stats = {
			"stage_cash_summary"
		}

		if should_show_moneythrower_spending then
			stats[#stats + 1] = "moneythrower_spending"
		end

		item = StatsTabItem:new(self._panel, self._tab_panel, utf8.to_upper(managers.localization:text("menu_es_summary")), #self._items + 1)

		item:set_stats(stats)
		table.insert(self._items, item)
		self._items[1]._panel:set_alpha(0)
	elseif should_show_moneythrower_spending then
		item = StatsTabItem:new(self._panel, self._tab_panel, utf8.to_upper(managers.localization:text("menu_es_summary")), #self._items + 1)

		item:set_stats({
			"moneythrower_spending"
		})
		table.insert(self._items, item)
	end

	item = StatsTabItem:new(self._panel, self._tab_panel, utf8.to_upper(managers.localization:text("menu_es_stats_crew")), #self._items + 1)

	item:set_stats({
		"time_played",
		"most_downs",
		"best_accuracy",
		"best_killer",
		"best_special",
		"group_total_downed",
		"group_hit_accuracy",
		"criminals_finished"
	})
	table.insert(self._items, item)

	item = StatsTabItem:new(self._panel, self._tab_panel, utf8.to_upper(managers.localization:text("menu_es_stats_personal")), #self._items + 1)

	item:set_stats({
		"total_downed",
		"hit_accuracy",
		"total_kills",
		"total_specials_kills",
		"total_head_shots",
		"favourite_weapon",
		"civilians_killed_penalty"
	})
	table.insert(self._items, item)

	item = StatsTabItem:new(self._panel, self._tab_panel, utf8.to_upper(managers.localization:text("menu_es_stats_gage_assignment")), #self._items + 1)

	item:set_stats({
		"gage_assignment_summary"
	})
	table.insert(self._items, item)

	if managers.custom_safehouse:unlocked() then
		item = StatsTabItem:new(self._panel, self._tab_panel, utf8.to_upper(managers.localization:text("menu_es_safehouse_summary")), #self._items + 1)

		item:set_stats({
			"stage_safehouse_summary"
		})
		table.insert(self._items, item)
	end

	local scroll_w = self._panel:w() - self._scroll_panel:x()
	local text = managers.menu:is_pc_controller() and "" or managers.localization:get_default_macro("BTN_BOTTOM_R")
	local color = managers.menu:is_pc_controller() and tweak_data.screen_colors.button_stage_3 or Color.white
	local next_page = self._panel:text({
		w = 0,
		vertical = "top",
		y = 0,
		layer = 2,
		name = "tab_text_" .. tostring(#self._items + 1),
		h = tweak_data.menu.pd2_medium_font_size,
		font_size = tweak_data.menu.pd2_medium_font_size,
		font = tweak_data.menu.pd2_medium_font,
		text = text,
		color = color
	})
	local _, _, w, h = next_page:text_rect()

	next_page:set_size(w, h + 10)
	next_page:set_right(self._panel:w())

	self._next_page = next_page
	scroll_w = scroll_w - next_page:w() - 5
	local ix, iy, iw, ih = self._items[#self._items]:tab_text_shape()

	self._tab_panel:set_w(ix + iw + 5)
	self._tab_panel:set_h(ih)
	self._scroll_panel:set_w(scroll_w)
	self._scroll_panel:set_h(ih)

	if self._console_subtitle_string_id then
		self:console_subtitle_callback(self._console_subtitle_string_id)
	end

	self:select_tab(1, true)
	self._items[self._selected_item]:select()

	local box_panel = self._panel:panel()

	box_panel:set_shape(self._items[self._selected_item]._panel:shape())
	BoxGuiObject:new(box_panel, {
		sides = {
			1,
			1,
			2,
			1
		}
	})

	if statistics_data then
		self:feed_statistics(statistics_data)
	end

	self._enabled = true

	if managers.job:stage_success() then
		self._bain_debrief_t = TimerManager:main():time() + 1
	end

	self._reduced_to_small_font = managers.crime_spree:is_active()

	self:chk_reduce_to_small_font()
end

function StageEndScreenGui:play_bain_debrief()
	local variant = managers.groupai:state():endscreen_variant() or 0
	local level_data = Global.level_data.level_id and tweak_data.levels[Global.level_data.level_id]
	local outro_event = level_data and (variant == 0 and level_data.outro_event or level_data.outro_event[variant])

	Application:debug("StageEndScreenGui:play_bain_debrief()", outro_event)

	if outro_event then
		local snd_event = nil
		local tactic = managers.groupai:state():enemy_weapons_hot() and "loud" or "stealth"

		if type(outro_event) == "table" then
			if outro_event.loud or outro_event.stealth then
				snd_event = outro_event[tactic]
			else
				snd_event = outro_event[math.random(#outro_event)]
			end
		else
			snd_event = outro_event
		end

		if snd_event then
			print("[StageEndScreenGui] ", snd_event)
			managers.briefing:post_event(snd_event, {
				show_subtitle = false,
				listener = {
					end_of_event = true,
					clbk = callback(self, self, "bain_debrief_end_callback")
				}
			})
		else
			self:bain_debrief_end_callback(true)
		end

		if managers.menu:is_console() then
			managers.briefing:add_listener({
				marker = true,
				clbk = callback(self, self, "console_subtitle_callback")
			})
		end
	else
		self:bain_debrief_end_callback(true)
	end
end

function StageEndScreenGui:bain_debrief_end_callback(instant)
	if instant then
		if managers.job:on_last_stage() then
			local job_data = managers.job:current_job_data()

			if job_data and job_data.debrief_event then
				managers.briefing:post_event(job_data.debrief_event)

				if managers.menu:is_console() then
					managers.briefing:add_listener({
						marker = true,
						clbk = callback(self, self, "console_subtitle_callback")
					})
				end
			end
		end
	else
		self._contact_debrief_t = TimerManager:main():time() + 1.5
	end
end