ModifierDozerRage = ModifierDozerRage or class(BaseModifier)
ModifierDozerRage._type = "ModifierDozerRage"
ModifierDozerRage.name_id = "none"
ModifierDozerRage.desc_id = "menu_cs_modifier_dozer_rage"

function ModifierDozerRage:init(data)
	ModifierDozerRage.super.init(self, data)
	
	table.insert(tweak_data.group_ai.unit_categories.FBI_suit_M4_MP5.unit_types.america, Idstring("units/pd2_dlc_drm/characters/ene_swat_bronco/ene_swat_bronco"))
	table.insert(tweak_data.group_ai.unit_categories.FBI_suit_M4_MP5.unit_types.russia, Idstring("units/pd2_dlc_drm/characters/ene_swat_bronco/ene_swat_bronco"))
	table.insert(tweak_data.group_ai.unit_categories.FBI_suit_M4_MP5.unit_types.murkywater, Idstring("units/pd2_dlc_drm/characters/ene_swat_bronco/ene_swat_bronco"))
end

function ModifierDozerRage:OnTankVisorShatter(unit, damage_info)
	if dont then
		unit:base():add_buff("base_damage", self:value("damage") * 0.01)
	end
end
