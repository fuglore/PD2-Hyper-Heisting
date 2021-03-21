local massive_font = tweak_data.menu.pd2_massive_font
local large_font = tweak_data.menu.pd2_large_font
local medium_font = tweak_data.menu.pd2_medium_font
local small_font = tweak_data.menu.pd2_small_font
local massive_font_size = tweak_data.menu.pd2_massive_font_size
local large_font_size = tweak_data.menu.pd2_large_font_size
local medium_font_size = tweak_data.menu.pd2_medium_font_size
local small_font_size = tweak_data.menu.pd2_small_font_size
local PANEL_PADDING = 10
MutatorsCategoryPage = MutatorsCategoryPage or class(MenuGuiTabPage)
MutatorsCategoryPage.category = "all"

function MutatorsCategoryPage:refresh()
	MutatorsCategoryPage.super.refresh(self)

	local compatible, incompatible_mutator = nil

	if self._selected_item then
		local longdesc = self._selected_item:mutator():longdesc()

		self._mutator_longdesc:set_text(longdesc and longdesc ~= "" and longdesc or "")

		local _, _, _, h = self._mutator_longdesc:text_rect()

		self._mutator_longdesc:set_h(h)

		compatible, incompatible_mutator = managers.mutators:can_enable_mutator(self._selected_item:mutator())

		if not compatible and incompatible_mutator then
			self._incompatibilities_text:set_text(managers.localization:text("menu_mutators_incompatibilities", {
				mutators = incompatible_mutator:name()
			}))
			self._incompatibilities_text:set_visible(true)

			local _, _, _, h = self._incompatibilities_text:text_rect()

			self._incompatibilities_text:set_h(h)
			self._incompatibilities_text:set_top(self._mutator_longdesc:bottom() + PANEL_PADDING)
		elseif not compatible then
			self._incompatibilities_text:set_text(managers.localization:text("menu_hh_mutator_incomp"))
			self._incompatibilities_text:set_visible(true)

			local _, _, _, h = self._incompatibilities_text:text_rect()

			self._incompatibilities_text:set_h(h)
			self._incompatibilities_text:set_top(self._mutator_longdesc:bottom() + PANEL_PADDING)
		else
			self._incompatibilities_text:set_text("")
			self._incompatibilities_text:set_h(0)
			self._incompatibilities_text:set_visible(false)
		end
	end

	if self._achievements_text then
		self._achievements_text:set_visible(managers.mutators:are_mutators_enabled())
		self._achievements_text:set_top((not compatible and self._incompatibilities_text or self._mutator_longdesc):bottom() + PANEL_PADDING)
	end

	if self._reduction_text then
		self._reduction_text:set_visible(managers.mutators:are_mutators_enabled() and (managers.mutators:get_cash_multiplier() < 1 or managers.mutators:get_experience_multiplier() < 1))

		if managers.mutators:are_mutators_enabled() then
			self._reduction_text:set_text(managers.localization:text("menu_mutators_reduction", self:_get_reduction_macros()))
		end

		self._reduction_text:set_top(self._achievements_text:bottom() + PANEL_PADDING)
	end

	if self._items then
		for _, item in ipairs(self._items) do
			item:refresh()
		end
	end
end
