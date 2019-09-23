ModifierExplosionImmunity = ModifierExplosionImmunity or class(BaseModifier)
ModifierExplosionImmunity._type = "ModifierExplosionImmunity"
ModifierExplosionImmunity.name_id = "none"
ModifierExplosionImmunity.desc_id = "menu_cs_modifier_dozer_immune"

function ModifierExplosionImmunity:init(data)
	ModifierExplosionImmunity.super.init(self, data)
	
	if managers and managers.skirmish and managers.skirmish:is_skirmish() then
		--nothing
	elseif not Global.game_settings.aggroAI then
		Global.game_settings.aggroAI = true
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
