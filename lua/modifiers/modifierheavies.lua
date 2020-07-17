ModifierHeavies = ModifierHeavies or class(BaseModifier)
ModifierHeavies._type = "ModifierHeavies"
ModifierHeavies.name_id = "none"
ModifierHeavies.desc_id = "menu_cs_modifier_heavies"
ModifierHeavies.unit_swaps = {
		
	["units/payday2/characters/ene_spook_1/ene_spook_1"] = "units/pd2_dlc_drm/characters/ene_spook_heavy/ene_spook_heavy",
	["units/pd2_dlc_bph/characters/ene_murkywater_cloaker/ene_murkywater_cloaker"] = "units/pd2_dlc_drm/characters/ene_spook_heavy/ene_spook_heavy",
	["units/pd2_mod_psc/characters/ene_murky_cloaker/ene_murky_cloaker"] = "units/pd2_dlc_drm/characters/ene_spook_heavy/ene_spook_heavy",
	
	["units/payday2/characters/ene_medic_m4/ene_medic_m4"] = "units/pd2_dlc_drm/characters/ene_medic_heavy_m4/ene_medic_heavy_m4",
	["units/payday2/characters/ene_medic_m4_hh/ene_medic_m4_hh"] = "units/pd2_dlc_drm/characters/ene_medic_heavy_m4/ene_medic_heavy_m4",
	["units/pd2_dlc_bph/characters/ene_murkywater_medic/ene_murkywater_medic"] = "units/pd2_dlc_drm/characters/ene_medic_heavy_m4/ene_medic_heavy_m4",
		
	["units/payday2/characters/ene_medic_r870/ene_medic_r870"] = "units/pd2_dlc_drm/characters/ene_medic_heavy_r870/ene_medic_heavy_r870",
	["units/pd2_dlc_bph/characters/ene_murkywater_medic_r870/ene_murkywater_medic_r870"] = "units/pd2_dlc_drm/characters/ene_medic_heavy_r870/ene_medic_heavy_r870",
	
	["units/payday2/characters/ene_tazer_1/ene_tazer_1"] = "units/pd2_dlc_drm/characters/ene_taser_heavy/ene_taser_heavy",
	["units/pd2_dlc_bph/characters/ene_murkywater_tazer/ene_murkywater_tazer"] = "units/pd2_dlc_drm/characters/ene_taser_heavy/ene_taser_heavy",
	
	["units/payday2/characters/ene_shield_1/ene_shield_1"] = "units/pd2_dlc_drm/characters/ene_shield_heavy/ene_shield_heavy",
	["units/pd2_dlc_bph/characters/ene_murkywater_shield/ene_murkywater_shield"] = "units/pd2_mod_psc/characters/ene_murky_DS_shield/ene_murky_DS_shield"
	
}

function ModifierHeavies:init(data)
	ModifierHeavies.super.init(self, data)
	
	--evening out chances of heavy umps
	table.insert(tweak_data.group_ai.unit_categories.FBI_heavy_G36.unit_types.america, Idstring("units/payday2/characters/ene_fbi_heavy_1/ene_fbi_heavy_1"))
	table.insert(tweak_data.group_ai.unit_categories.FBI_heavy_G36.unit_types.america, Idstring("units/pd2_dlc_drm/characters/ene_fbi_heavy_ump/ene_fbi_heavy_ump"))
	
	table.insert(tweak_data.group_ai.unit_categories.FBI_heavy_G36.unit_types.murkywater, Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_scar/ene_murky_heavy_scar"))
	table.insert(tweak_data.group_ai.unit_categories.FBI_heavy_G36.unit_types.murkywater, Idstring("units/pd2_dlc_drm/characters/ene_murky_heavy_ump/ene_murky_heavy_ump"))

	table.insert(tweak_data.group_ai.unit_categories.FBI_heavy_G36.unit_types.shared, Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_scar/ene_murky_heavy_scar")) 
	table.insert(tweak_data.group_ai.unit_categories.FBI_heavy_G36.unit_types.shared, Idstring("units/pd2_dlc_drm/characters/ene_murky_heavy_ump/ene_murky_heavy_ump"))	
	
	Global.game_settings.heavymutator = true --used to track various things related to unit distribution as to keep stuff consistent, not sure if i actually used this at all by now tbh
	
	for group, unit_group in pairs(tweak_data.group_ai.unit_categories) do
		if unit_group.unit_types then
			for continent, units in pairs(unit_group.unit_types) do
				for i, unit_id in ipairs(units) do
					for swap_id, new_id in pairs(ModifierHeavies.unit_swaps) do
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
