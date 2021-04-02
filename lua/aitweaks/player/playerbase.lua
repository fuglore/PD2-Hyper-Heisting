function PlayerBase:init(unit)
	UnitBase.init(self, unit, false)

	self._unit = unit

	self:_setup_suspicion_and_detection_data()
	self:_setup_hud()

	self._id = managers.player:player_id(self._unit)
	self._rumble_pos_callback = callback(self, self, "get_rumble_position")

	self:_setup_controller()
	self._unit:set_extension_update_enabled(Idstring("base"), false)

	self._stats_screen_visible = false

	managers.game_play_central:restart_portal_effects()

	self:sync_unit_upgrades()

	managers.job:set_memory("mad_3", true)
end

function PlayerBase:set_suspicion_multiplier(reason, multiplier)
	self._suspicion_settings.multipliers[reason] = multiplier
	local buildup_mul = self._suspicion_settings.init_buildup_mul
	local range_mul = self._suspicion_settings.init_range_mul

	for reason, mul in pairs(self._suspicion_settings.multipliers) do
		buildup_mul = buildup_mul * mul

		if mul > 1 then
			range_mul = range_mul * math.sqrt(mul)
		end
	end

	self._suspicion_settings.buildup_mul = buildup_mul * (managers.groupai:state():chk_guard_detection_mul() or 1)
	self._suspicion_settings.range_mul = range_mul
end

function PlayerBase:set_detection_multiplier(reason, multiplier)
	self._detection_settings.multipliers[reason] = multiplier
	local delay_mul = self._detection_settings.init_delay_mul
	local range_mul = self._detection_settings.init_range_mul

	for reason, mul in pairs(self._detection_settings.multipliers) do
		delay_mul = delay_mul * 1 / mul
		range_mul = range_mul * math.sqrt(mul)
	end

	self._detection_settings.delay_mul = delay_mul - (managers.groupai:state():chk_guard_delay_deduction() or 0)
	self._detection_settings.range_mul = range_mul 
end

function PlayerBase:_setup_suspicion_and_detection_data()
	local difficulty_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)
	self._suspicion_settings = deep_clone(tweak_data.player.suspicion)
	self._suspicion_settings.multipliers = {}
	local gamemode_chk = game_state_machine:gamemode() 
	self._suspicion_settings.init_buildup_mul = self._suspicion_settings.buildup_mul
	self._suspicion_settings.init_range_mul = self._suspicion_settings.range_mul
	if Global.game_settings.incsmission then
		if managers.crime_spree then
			local copdetmult = managers.crime_spree:get_cop_det_mult()
			self._suspicion_settings.init_buildup_mul = self._suspicion_settings.init_buildup_mul + copdetmult
			--log("uhuh")
		end
	end

	self:setup_hud_offset()
	
	if difficulty_index <= 3 then
		self._detection_settings = {
			multipliers = {},
			init_delay_mul = 1,
			init_range_mul = 0.5
		}
	elseif difficulty_index == 4 or difficulty_index == 5 then
		self._detection_settings = {
			multipliers = {},
			init_delay_mul = 0.75,
			init_range_mul = 0.75
		}
	elseif difficulty_index == 6 or difficulty_index == 7 then
		self._detection_settings = {
			multipliers = {},
			init_delay_mul = 0.5,
			init_range_mul = 1
		}
	else 
		self._detection_settings = {
			multipliers = {},
			init_delay_mul = 0.25,
			init_range_mul = 1
		}
	end
	
end