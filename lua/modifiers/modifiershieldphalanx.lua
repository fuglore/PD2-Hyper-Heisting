ModifierShieldPhalanx = ModifierShieldPhalanx or class(BaseModifier)
ModifierShieldPhalanx._type = "ModifierShieldPhalanx"
ModifierShieldPhalanx.name_id = "none"
ModifierShieldPhalanx.desc_id = "menu_cs_modifier_shield_phalanx"

function ModifierShieldPhalanx:init(data)
	ModifierShieldPhalanx.super.init(data)
	
	table.insert(tweak_data.group_ai.unit_categories.FBI_swat_R870.unit_types.america, Idstring("units/payday2/characters/ene_fbi_swat_2/ene_fbi_swat_2"))
	table.insert(tweak_data.group_ai.unit_categories.FBI_swat_M4.unit_types.america, Idstring("units/pd2_dlc_drm/characters/ene_city_swat_saiga/ene_city_swat_saiga"))
	
	table.insert(tweak_data.group_ai.unit_categories.FBI_swat_R870.unit_types.murkywater, Idstring("units/pd2_mod_psc/characters/ene_murky_light_r870/ene_murky_light_r870"))
	table.insert(tweak_data.group_ai.unit_categories.FBI_swat_M4.unit_types.murkywater, Idstring("units/pd2_dlc_drm/characters/ene_city_swat_saiga/ene_city_swat_saiga"))
	
	if Global.game_settings.heavymutator then
		table.insert(tweak_data.group_ai.unit_categories.FBI_heavy_R870.unit_types.america, Idstring("units/payday2/characters/units/payday2/characters/ene_fbi_heavy_r870/ene_fbi_heavy_r870"))
		table.insert(tweak_data.group_ai.unit_categories.FBI_heavy_R870.unit_types.murkywater, Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_r870/ene_murky_heavy_r870"))
		
		table.insert(tweak_data.group_ai.unit_categories.FBI_heavy_R870.unit_types.america, Idstring("units/pd2_dlc_drm/characters/ene_city_swat_saiga/ene_city_swat_saiga"))
		table.insert(tweak_data.group_ai.unit_categories.FBI_heavy_R870.unit_types.murkywater, Idstring("units/pd2_dlc_drm/characters/ene_city_swat_saiga/ene_city_swat_saiga"))
	end
	
	--tweak_data.group_ai.unit_categories.CS_shield = tweak_data.group_ai.unit_categories.Phalanx_minion
	--tweak_data.group_ai.unit_categories.FBI_shield = tweak_data.group_ai.unit_categories.Phalanx_minion
end

function ModifierShieldPhalanx:modify_value(id, value, unit)
	if dont then --dont
		if id ~= "PlayerStandart:_start_action_intimidate" then
			return value
		end

		local unit_tweak = unit:base()._tweak_table

		if unit_tweak ~= "phalanx_minion" then
			return value
		end

		if unit:base().is_phalanx then
			return
		end

		return "f31x_any"
	end
end
