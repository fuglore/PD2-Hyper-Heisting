function SkirmishManager:on_start_assault()
	local wave_number = managers.groupai:state():get_assault_number()
	
	self:_apply_modifiers_for_wave(wave_number)
	
	if wave_number == 3 then
		tweak_data:set_difficulty(Global.game_settings.difficulty)
	end
	
	self:update_matchmake_attributes()
end