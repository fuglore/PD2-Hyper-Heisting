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

	if unit:base():has_tag("law") and math.random() < 0.75 then
		local grenade = World:spawn_unit(Idstring("units/pd2_dlc_drm/weapons/wpn_frag_bouncer/wpn_frag_bouncer"), unit:position(), unit:rotation())

		--grenade:base():set_properties({
		--	radius = self:value("diameter") * 0.5 * 100,
		--	damage = self:value("damage") * 0.1,
		--	duration = self:value("duration")
		--})
		grenade:base():activate_immediately(unit:position(), tweak_data.group_ai.flash_grenade_lifetime)
	end
end

ModifierBulletknock = ModifierBulletknock or class(BaseModifier)
ModifierBulletknock._type = "ModifierBulletknock"
ModifierBulletknock.name_id = "none"
ModifierBulletknock.desc_id = "menu_cs_modifier_bulletknock"

function ModifierBulletknock:init(data)
	ModifierBulletknock.super.init(self, data)
	
	if Global.game_settings.incsmission or managers.skirmish and managers.skirmish:is_skirmish() then
		Global.game_settings.bulletknock = true
	else
		Global.game_settings.bulletknock = nil
	end
	
end

ModifierShin = ModifierShin or class(BaseModifier)
ModifierShin._type = "ModifierShin"
ModifierShin.name_id = "none"
ModifierShin.desc_id = "menu_cs_modifier_shin"

function ModifierShin:init(data)
	ModifierShin.super.init(self, data)
	
	Global.game_settings.one_down = true
end

ModifierUnison = ModifierUnison or class(BaseModifier)
ModifierUnison._type = "ModifierUnison"
ModifierUnison.name_id = "none"
ModifierUnison.desc_id = "menu_cs_modifier_unison"

function ModifierUnison:init(data)
	ModifierUnison.super.init(self, data)
	
	if Global.game_settings.incsmission or managers.skirmish and managers.skirmish:is_skirmish() then
		Global.game_settings.thethreerulers = true
	else
		Global.game_settings.thethreerulers = nil
	end
	
end