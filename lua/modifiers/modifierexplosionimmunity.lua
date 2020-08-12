ModifierExplosionImmunity = ModifierExplosionImmunity or class(BaseModifier)
ModifierExplosionImmunity._type = "ModifierExplosionImmunity"
ModifierExplosionImmunity.name_id = "none"
ModifierExplosionImmunity.desc_id = "menu_cs_modifier_dozer_immune"

function ModifierExplosionImmunity:init(data)
	ModifierExplosionImmunity.super.init(self, data)
	
	local gamemode_chk = game_state_machine and game_state_machine:gamemode() 
	if Global.game_settings.incsmission then
		if not Global.game_settings.aggroAI then
			Global.game_settings.aggroAI = true
		end
	end
	
end

function ModifierExplosionImmunity:modify_value(id, value, unit_tweak)
	if dont then --dont
		if id == "CopDamage:DamageExplosion" and unit_tweak == "tank" then
			return 0
		end

		return value
	end
end
