ModifierDozerMedic = ModifierDozerMedic or class(BaseModifier)
ModifierDozerMedic._type = "ModifierDozerMedic"
ModifierDozerMedic.name_id = "none"
ModifierDozerMedic.desc_id = "menu_cs_modifier_dozer_medic"

function ModifierDozerMedic:init(data)
	ModifierDozerMedic.super.init(self, data)

	local unit_types = tweak_data.group_ai.unit_categories.FBI_shield.unit_types
	local unit_name = Idstring("units/pd2_dlc_drm/characters/ene_true_lotus_master/ene_true_lotus_master")

	table.insert(unit_types.america, unit_name)
	table.insert(unit_types.murkywater, unit_name)
	table.insert(unit_types.shared, unit_name)
end
