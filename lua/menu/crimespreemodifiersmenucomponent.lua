local padding = 10

function CrimeSpreeModifiersMenuComponent:_setup()
	local modifiers, modifiers_name = self:get_modifers()
	local parent = self._ws:panel()

	if alive(self._panel) then
		parent:remove(self._panel)
	end

	self._panel = self._ws:panel():panel({
		layer = 51
	})
	self._fullscreen_panel = self._fullscreen_ws:panel():panel({
		layer = 50
	})

	self._fullscreen_panel:rect({
		alpha = 0.75,
		layer = 0,
		color = Color.black
	})

	local blur = self._fullscreen_panel:bitmap({
		texture = "guis/textures/test_blur_df",
		render_template = "VertexColorTexturedBlur3D",
		w = self._fullscreen_ws:panel():w(),
		h = self._fullscreen_ws:panel():h()
	})

	local function func(o)
		local start_blur = 0

		over(0.6, function (p)
			o:set_alpha(math.lerp(start_blur, 1, p))
		end)
	end

	blur:animate(func)

	local modifier_h = CrimeSpreeModifierButton.size.h
	local btn_size = tweak_data.menu.pd2_large_font_size

	self._panel:set_w((CrimeSpreeModifierButton.size.w + padding) * 2 + padding)
	self._panel:set_h(modifier_h + btn_size + padding * 3)
	self._panel:set_center_x(parent:center_x())
	self._panel:set_center_y(parent:center_y())
	self._panel:rect({
		alpha = 0.4,
		layer = -1,
		color = Color.black
	})

	self._text_header = self._ws:panel():text({
		vertical = "top",
		align = "left",
		layer = 51,
		text = managers.localization:to_upper_text("menu_cs_modifiers_" .. tostring(modifiers_name)),
		font_size = tweak_data.menu.pd2_large_font_size,
		font = tweak_data.menu.pd2_large_font,
		color = tweak_data.screen_colors.text
	})
	local x, y, w, h = self._text_header:text_rect()

	self._text_header:set_size(self._panel:w(), h)
	self._text_header:set_left(self._panel:left())
	self._text_header:set_bottom(self._panel:top())

	self._current_num = 1
	self._num_to_select = self:modifiers_to_select()
	self._number_header = self._ws:panel():text({
		vertical = "top",
		align = "right",
		layer = 51,
		text = self._num_to_select > 1 and tostring(self._current_num) .. " / " .. managers.experience:cash_string(self._num_to_select, "") or "",
		font_size = tweak_data.menu.pd2_large_font_size,
		font = tweak_data.menu.pd2_large_font,
		color = tweak_data.screen_colors.text
	})
	local x, y, w, h = self._text_header:text_rect()

	self._number_header:set_size(self._panel:w(), h)
	self._number_header:set_left(self._panel:left())
	self._number_header:set_bottom(self._panel:top())

	self._modifiers_panel = self._panel:panel({
		x = padding,
		y = padding,
		w = self._panel:w() - padding * 2,
		h = modifier_h
	})
	self._button_panel = self._panel:panel({
		x = padding,
		y = self._modifiers_panel:bottom() + padding,
		w = self._panel:w() - padding * 2,
		h = btn_size
	})

	for i = 1, tweak_data.crime_spree.max_modifiers_displayed do
		local modifier = modifiers[i]
		local btn = CrimeSpreeModifierButton:new(self._modifiers_panel, modifier)

		btn:set_x((CrimeSpreeModifierButton.size.w + padding) * (1.5 - 1))
		btn:set_y(0)
		btn:set_callback(callback(self, self, "_on_select_modifier", btn))
		table.insert(self._buttons, btn)
	end

	if managers.menu:is_pc_controller() then
		local finalize_btn = CrimeSpreeButton:new(self._button_panel)

		finalize_btn:set_text(managers.localization:to_upper_text("menu_cs_select_modifier"))
		finalize_btn:set_callback(callback(self, self, "_on_finalize_modifier"))
		finalize_btn:shrink_wrap_button(0, 0)
		table.insert(self._buttons, finalize_btn)
		finalize_btn:panel():set_center_x(CrimeSpreeModifierButton.size.w + 10)

		for i, modifier in ipairs(modifiers) do
			local btn = self._buttons[i]

			if i > 1 then
				btn:set_link("left", self._buttons[i - 1])
			end

			if i < #modifiers then
				btn:set_link("right", self._buttons[i + 1])
			end

			btn:set_link("down", finalize_btn)
		end

		finalize_btn:set_link("up", self._buttons[1])
	else
		self._legend_text = self._button_panel:text({
			halign = "right",
			vertical = "bottom",
			layer = 1,
			blend_mode = "add",
			align = "right",
			text = "",
			y = 0,
			x = 0,
			valign = "bottom",
			color = tweak_data.screen_colors.text,
			font = tweak_data.menu.pd2_medium_font,
			font_size = tweak_data.menu.pd2_medium_font_size
		})
		local legend_string = managers.localization:get_default_macro("BTN_ACCEPT") .. " " .. managers.localization:to_upper_text("menu_cs_select_modifier") .. "  |  " .. managers.localization:to_upper_text("menu_legend_back")

		self._legend_text:set_text(legend_string)

		for i, modifier in ipairs(modifiers) do
			local btn = self._buttons[i]

			if i > 1 then
				btn:set_link("left", self._buttons[i - 1])
			end

			if i < #modifiers then
				btn:set_link("right", self._buttons[i + 1])
			end
		end

		self:_move_selection("up")
	end

	BoxGuiObject:new(self._panel, {
		sides = {
			1,
			1,
			1,
			1
		}
	})
end