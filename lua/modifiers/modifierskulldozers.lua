ModifierSkulldozers = ModifierSkulldozers or class(BaseModifier)
ModifierSkulldozers._type = "ModifierSkulldozers"
ModifierSkulldozers.name_id = "none"
ModifierSkulldozers.desc_id = "menu_cs_modifier_dozer_lmg"
ModifierSkulldozers.unit_swaps = { --replace jerome with cool jerome when everything is horrible
	["units/payday2/characters/ene_fbi_2/ene_fbi_2"] = "units/pd2_dlc_gitgud/characters/ene_zeal_fbigod_m4/ene_zeal_fbigod_m4",
	["units/payday2/characters/ene_fbi_1/ene_fbi_1"] = "units/pd2_dlc_gitgud/characters/ene_zeal_fbigod_c45/ene_zeal_fbigod_c45",
}


function ModifierSkulldozers:init(data)
	ModifierSkulldozers.super.init(self, data)
	
	local gamemode_chk = game_state_machine and game_state_machine:gamemode() 
	if Global.game_settings.incsmission or managers.skirmish and managers.skirmish:is_skirmish() then
		local current_wave = managers.skirmish:current_wave_number()
		if Global.game_settings.incsmission or current_wave and current_wave ~= nil and current_wave >= 3 then
			Global.game_settings.use_intense_AI = true
			--log("itson")
		end
	else
		Global.game_settings.use_intense_AI = nil
	end
	
	if managers.skirmish then
		local current_wave = managers.skirmish:current_wave_number()
		if current_wave and current_wave ~= nil and current_wave < 3 then
			Global.game_settings.use_intense_AI = nil
		end
	end
	
	table.insert(tweak_data.group_ai.unit_categories.FBI_tank.unit_types.america, Idstring("units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3"))
	table.insert(tweak_data.group_ai.unit_categories.FBI_tank.unit_types.federales, Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_m249/ene_swat_dozer_policia_federale_m249"))
	table.insert(tweak_data.group_ai.unit_categories.FBI_tank.unit_types.shared, Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_4/ene_murkywater_bulldozer_4"))
	table.insert(tweak_data.group_ai.unit_categories.FBI_tank.unit_types.shared, Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_4/ene_murkywater_bulldozer_4"))	
	table.insert(tweak_data.group_ai.unit_categories.FBI_tank.unit_types.russia, Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_rpk_lmg/ene_akan_fbi_tank_rpk_lmg"))
	table.insert(tweak_data.group_ai.unit_categories.FBI_tank.unit_types.murkywater, Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_4/ene_murkywater_bulldozer_4"))

	Global.game_settings.lmgmodifier = true --literally only for zeal sniper
	
	for group, unit_group in pairs(tweak_data.group_ai.unit_categories) do
		if unit_group.unit_types then
			for continent, units in pairs(unit_group.unit_types) do
				for i, unit_id in ipairs(units) do
					for swap_id, new_id in pairs(ModifierSkulldozers.unit_swaps) do
						if unit_id == Idstring(swap_id) then
							units[i] = Idstring(new_id)

							break
						end
					end
				end
			end
		end
	end
	
end
