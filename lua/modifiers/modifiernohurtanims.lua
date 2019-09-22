ModifierNoHurtAnims = ModifierNoHurtAnims or class(BaseModifier)
ModifierNoHurtAnims._type = "ModifierNoHurtAnims"
ModifierNoHurtAnims.name_id = "none"
ModifierNoHurtAnims.desc_id = "menu_cs_modifier_no_hurt"
ModifierNoHurtAnims.IgnoredHurtTypes = {
	"expl_hurt",
	"heavy_hurt"
}

function ModifierNoHurtAnims:init(data)
	ModifierNoHurtAnims.super.init(self, data)
	if managers and managers.skirmish and managers.skirmish:is_skirmish() then
		--nothing
	elseif not Global.game_settings.one_down then
		Global.game_settings.one_down = true
	end
end

function ModifierNoHurtAnims:modify_value(id, value)
	if id == "CopMovement:HurtType" and table.contains(ModifierNoHurtAnims.IgnoredHurtTypes, value) then
		if managers and managers.skirmish and managers.skirmish:is_skirmish() then
			return nil, true
		else
			return value
		end
	end
	
	return value
end