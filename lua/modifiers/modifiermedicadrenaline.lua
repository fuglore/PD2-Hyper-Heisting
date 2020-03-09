ModifierMedicAdrenaline = ModifierMedicAdrenaline or class(BaseModifier)
ModifierMedicAdrenaline._type = "ModifierMedicAdrenaline"
ModifierMedicAdrenaline.name_id = "none"
ModifierMedicAdrenaline.desc_id = "menu_cs_modifier_medic_adrenaline"

function ModifierMedicAdrenaline:init(data)
	ModifierMedicAdrenaline.super.init(self, data)
	local unit_types = tweak_data.group_ai.unit_categories.punk_group.unit_types
	local unit_name = Idstring("units/pd2_dlc_drm/characters/ene_zeal_armored_light/ene_zeal_armored_light")
	
	if managers.skirmish and managers.skirmish:is_skirmish() then
		unit_types = tweak_data.group_ai.unit_categories.FBI_heavy_G36.unit_types
	end
		
	
	table.insert(unit_types.america, unit_name)
	table.insert(unit_types.russia, unit_name)
	table.insert(unit_types.murkywater, unit_name)
end

function ModifierMedicAdrenaline:OnEnemyHealed(medic, target)
	if dont then -- dont
		target:base():add_buff("base_damage", self:value("damage") * 0.01)
	end
end
