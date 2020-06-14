ModifierDozerMinigun = ModifierDozerMinigun or class(BaseModifier)
ModifierDozerMinigun._type = "ModifierDozerMinigun"
ModifierDozerMinigun.name_id = "none"
ModifierDozerMinigun.desc_id = "menu_cs_modifier_dozer_minigun"

function ModifierDozerMinigun:init(data)
	ModifierDozerMinigun.super.init(self, data)

	local unit_types = tweak_data.group_ai.unit_categories.FBI_tank.unit_types
	local unit_name = Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_minigun_classic/ene_bulldozer_minigun_classic")
	local unit_name_murker = Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_1/ene_murkywater_bulldozer_1")
	local unit_name_jjgatlingman = Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_minigun/ene_swat_dozer_policia_federale_minigun")
	
	local unit_name_medic = Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_medic/ene_bulldozer_medic")
	local unit_name_murkmedic = Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_medic/ene_murkywater_bulldozer_medic")
	local unit_name_federalesmed = Idstring("units/pd2_dlc_mad/characters/ene_akan_dozer_medic/ene_akan_dozer_medic")
	
	table.insert(unit_types.america, unit_name)
	table.insert(unit_types.russia, unit_name)
	table.insert(unit_types.america, unit_name_medic)
	table.insert(unit_types.russia, unit_name_medic)
	table.insert(unit_types.murkywater, unit_name_murker)
	table.insert(unit_types.murkywater, unit_name_murkmedic)
	table.insert(unit_types.federales, unit_name_jjgatlingman)
	table.insert(unit_types.federales, unit_name_federalesmed)
	table.insert(unit_types.shared, unit_name_murker)
	table.insert(unit_types.shared, unit_name_murkmedic)	
	table.insert(unit_types.shared, unit_name_murker)
	table.insert(unit_types.shared, unit_name_murkmedic)		
end