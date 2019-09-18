ModifierHeavies = ModifierHeavies or class(BaseModifier)
ModifierHeavies._type = "ModifierHeavies"
ModifierHeavies.name_id = "none"
ModifierHeavies.desc_id = "menu_cs_modifier_heavies"
ModifierHeavies.unit_swaps = {

	["units/payday2/characters/ene_fbi_swat_1/ene_fbi_swat_1"] = "units/payday2/characters/ene_fbi_heavy_1/ene_fbi_heavy_1",
	["units/payday2/characters/ene_fbi_3/ene_fbi_3"] = "units/payday2/characters/ene_fbi_heavy_1/ene_fbi_heavy_1",
	
	["units/pd2_dlc_mad/characters/ene_akan_fbi_swat_ak47_ass/ene_akan_fbi_swat_ak47_ass"] = "units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_g36/ene_akan_fbi_heavy_g36",
	
	["units/pd2_dlc_mad/characters/ene_akan_hyper_fbi_akmsu_smg/ene_akan_hyper_fbi_akmsu_smg"] = "units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_g36/ene_akan_fbi_heavy_g36",
	
	["units/pd2_mod_psc/characters/ene_murky_light_ump/ene_murky_light_ump"] = "units/pd2_mod_psc/characters/ene_murky_heavy_scar/ene_murky_heavy_scar",
	
	["units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"] = "units/pd2_mod_psc/characters/ene_murky_heavy_scar/ene_murky_heavy_scar",
	
	
	
	["units/payday2/characters/ene_fbi_swat_2/ene_fbi_swat_2"] = "units/payday2/characters/ene_fbi_heavy_r870/ene_fbi_heavy_r870",
	
	["units/pd2_dlc_mad/characters/ene_akan_fbi_swat_r870/ene_akan_fbi_swat_r870"] = "units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_r870/ene_akan_fbi_heavy_r870",
	
	["units/pd2_mod_psc/characters/ene_murky_light_r870/ene_murky_light_r870"] = "units/pd2_mod_psc/characters/ene_murky_heavy_r870/ene_murky_heavy_r870"
	
	
}

function ModifierHeavies:init(data)
	ModifierHeavies.super.init(self, data)

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
