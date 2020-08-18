--List of Modifiers using booleans:
--Magnetstorm
--Bulletknock
--ModifierSkulldozers
--ModifierTaserovercharge
--ModifierHeavies

ModifierMagnetstorm = ModifierMagnetstorm or class(BaseModifier)
ModifierMagnetstorm._type = "ModifierMagnetstorm"
ModifierMagnetstorm.name_id = "none"
ModifierMagnetstorm.desc_id = "menu_cs_modifier_magnetstorm"

function ModifierMagnetstorm:init(data)
	ModifierMagnetstorm.super.init(self, data)	
end

function ModifierMagnetstorm:check_boolean(id)
	if id == "Magnetstorm" and self:value("boolean") ~= nil then
		return self:value("boolean")
	else
		return nil
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

ModifierVolter = ModifierVolter or class(BaseModifier)
ModifierVolter._type = "ModifierVolter"
ModifierVolter.name_id = "none"
ModifierVolter.desc_id = "menu_cs_modifier_voltergas"

function ModifierVolter:check_boolean(id)
	if id == "HHLetsTryGas" and self:value("boolean") ~= nil then
		return true
	else
		return nil
	end
end

ModifierHurtResist = ModifierHurtResist or class(BaseModifier)
ModifierHurtResist._type = "ModifierHurtResist"
ModifierHurtResist.name_id = "none"
ModifierHurtResist.desc_id = "menu_cs_modifier_no_hurt"
ModifierHurtResist.default_value = 0

function ModifierHurtResist:modify_value(id, value)
	if id == "HHHurtRes" then
		return value + self:value("multiplier")
	end
	
	return value
end

ModifierBulletknock = ModifierBulletknock or class(BaseModifier)
ModifierBulletknock._type = "ModifierBulletknock"
ModifierBulletknock.name_id = "none"
ModifierBulletknock.desc_id = "menu_cs_modifier_bulletknock"

function ModifierBulletknock:init(data)
	ModifierBulletknock.super.init(self, data)
end

function ModifierBulletknock:check_boolean()
	if id == "Bullethell" and self:value("boolean") ~= nil then
		return self:value("boolean")
	else
		return nil
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
	
	if Global.game_settings.incsmission then
		Global.game_settings.thethreerulers = true
	else
		Global.game_settings.thethreerulers = nil
	end
	
end