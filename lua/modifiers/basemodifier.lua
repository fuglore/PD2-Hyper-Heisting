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