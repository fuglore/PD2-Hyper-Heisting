ModifierTaserOvercharge = ModifierTaserOvercharge or class(BaseModifier)
ModifierTaserOvercharge._type = "ModifierTaserOvercharge"
ModifierTaserOvercharge.name_id = "none"
ModifierTaserOvercharge.desc_id = "menu_cs_modifier_taser_overcharge"
ModifierTaserOvercharge.default_value = "speed"

function ModifierTaserOvercharge:init(data)
	ModifierTaserOvercharge.super.init(self, data)
	
	local gamemode_chk = game_state_machine:gamemode() 
	if gamemode_chk == "crime_spree" or managers.skirmish and managers.skirmish:is_skirmish() then
		if not Global.mutators.tase_t_reduction then
			Global.mutators.tase_t_reduction = 0.5
		end
	end
	
end

function ModifierTaserOvercharge:modify_value(id, value)
	if id == "PlayerTased:TasedTime" then
		value = value / (self:value() * 0.01 + 1)
	end

	return value
end