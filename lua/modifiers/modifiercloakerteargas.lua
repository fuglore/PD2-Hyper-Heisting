ModifierCloakerTearGas = ModifierCloakerTearGas or class(BaseModifier)
ModifierCloakerTearGas._type = "ModifierCloakerTearGas"
ModifierCloakerTearGas.name_id = "none"
ModifierCloakerTearGas.desc_id = "menu_cs_modifier_cloaker_tear_gas"

function ModifierCloakerTearGas:init(data)
	ModifierCloakerTearGas.super.init(self, data)
end

function ModifierCloakerTearGas:OnEnemyDied(unit, damage_info)
	--nothing, gone
end

function ModifierCloakerTearGas:check_boolean()
	if id == "telespooc" and self:value("boolean") ~= nil then
		return true
	else
		return nil
	end
end
