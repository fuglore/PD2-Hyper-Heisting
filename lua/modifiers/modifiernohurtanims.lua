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
	if not Global.game_settings.one_down then
		Global.game_settings.one_down = true
	end
end

function ModifierNoHurtAnims:modify_value(id, value)
	--dont
	if dont and id == "CopMovement:HurtType" and table.contains(ModifierNoHurtAnims.IgnoredHurtTypes, value) then
		return value
	end
	
	return value
end