ModifierTaserOvercharge = ModifierTaserOvercharge or class(BaseModifier)
ModifierTaserOvercharge._type = "ModifierTaserOvercharge"
ModifierTaserOvercharge.name_id = "none"
ModifierTaserOvercharge.desc_id = "menu_cs_modifier_taser_overcharge"
ModifierTaserOvercharge.default_value = "speed"

function ModifierTaserOvercharge:init(data)
	ModifierTaserOvercharge.super.init(self, data)
end

function ModifierTaserOvercharge:check_boolean(id)
	if id == "lightningbolt" and self:value("boolean") ~= nil then
		return true
	else
		return nil
	end
end

function ModifierTaserOvercharge:modify_value(id, value)
	--if id == "PlayerTased:TasedTime" then
	--	value = value / (self:value() * 0.01 + 1)
	--end

	--return value
end