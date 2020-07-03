ModifierCloakerTearGas = ModifierCloakerTearGas or class(BaseModifier)
ModifierCloakerTearGas._type = "ModifierCloakerTearGas"
ModifierCloakerTearGas.name_id = "none"
ModifierCloakerTearGas.desc_id = "menu_cs_modifier_cloaker_tear_gas"

function ModifierCloakerTearGas:init(data)
	ModifierCloakerTearGas.super.init(self, data)
	
	local gamemode_chk = game_state_machine and game_state_machine:gamemode() 
	
	if Global.game_settings.incsmission or managers.skirmish and managers.skirmish:is_skirmish() then
		if not Global.game_settings.telespooc then
			Global.game_settings.telespooc = true
		end
	else
		Global.game_settings.telespooc = nil
	end
end

function ModifierCloakerTearGas:OnEnemyDied(unit, damage_info)
	if Network:is_client() then
		return
	end
	
	local gamemode_chk = game_state_machine:gamemode() 
	if Global.game_settings.incsmission or managers.skirmish and managers.skirmish:is_skirmish() then
		if not Global.game_settings.telespooc then
			Global.game_settings.telespooc = true
		end
	else
		Global.game_settings.telespooc = nil
	end

	if dont and unit:base()._tweak_table == "spooc" then
		local grenade = World:spawn_unit(Idstring("units/pd2_dlc_drm/weapons/smoke_grenade_tear_gas/smoke_grenade_tear_gas"), unit:position(), unit:rotation())

		grenade:base():set_properties({
			radius = self:value("diameter") * 0.5 * 100,
			damage = self:value("damage") * 0.1,
			duration = self:value("duration")
		})
		grenade:base():detonate()
	end
end