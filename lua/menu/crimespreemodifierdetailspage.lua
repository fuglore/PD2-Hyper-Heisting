local padding = 10

function CrimeSpreeModifierDetailsPage:upcoming_modifiers_text()
	local upcoming_modifiers_text = ""

	for i, category in ipairs({
		"forced",
		"loud"
	}) do
		local next_level = managers.crime_spree:next_modifier_level(category)

		if next_level then
			local text_id = "menu_cs_next_modifier_" .. category
			local padding = i > 1 and "  " or ""
			local localized = managers.localization:to_upper_text(text_id, {
				next = next_level - managers.crime_spree:server_spree_level()
			})
			upcoming_modifiers_text = upcoming_modifiers_text .. padding .. localized
		end
	end

	return upcoming_modifiers_text
end