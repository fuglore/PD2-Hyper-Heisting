ModifierMagnetstorm = ModifierMagnetstorm or class(BaseModifier)
ModifierMagnetstorm._type = "ModifierMagnetstorm"
ModifierMagnetstorm.name_id = "none"
ModifierMagnetstorm.desc_id = "menu_cs_modifier_magnetstorm"

function ModifierMagnetstorm:init(data)
	ModifierMagnetstorm.super.init(self, data)
	
	if Global.game_settings.incsmission or managers.skirmish and managers.skirmish:is_skirmish() then
		Global.game_settings.magnetstorm = true
	else
		Global.game_settings.magnetstorm = nil
	end
	
end

ModifierBouncers = ModifierBouncers or class(BaseModifier)
ModifierBouncers._type = "ModifierBouncers"
ModifierBouncers.name_id = "none"
ModifierBouncers.desc_id = "menu_cs_modifier_bouncers"

function ModifierBouncers:OnEnemyDied(unit, damage_info)
	if Network:is_client() then
		return
	end

	if unit:base():has_tag("law") then
		local grenade = World:spawn_unit(Idstring("units/pd2_dlc_drm/weapons/wpn_frag_bouncer/wpn_frag_bouncer"), unit:position(), unit:rotation())

		--grenade:base():set_properties({
		--	radius = self:value("diameter") * 0.5 * 100,
		--	damage = self:value("damage") * 0.1,
		--	duration = self:value("duration")
		--})
		grenade:base():activate_immediately(unit:position(), tweak_data.group_ai.flash_grenade_lifetime)
	end
end

ModifierUnison = ModifierUnison or class(BaseModifier)
ModifierUnison._type = "ModifierUnison"
ModifierUnison.name_id = "none"
ModifierUnison.desc_id = "menu_cs_modifier_unison"

function ModifierUnison:init(data)
	ModifierUnison.super.init(self, data)
	
	if Global.game_settings.incsmission or managers.skirmish and managers.skirmish:is_skirmish() then
		Global.game_settings.thethreekings = true
	else
		Global.game_settings.thethreekings = nil
	end
	
end