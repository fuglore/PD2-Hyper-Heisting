DoctorBagBase.amount_upgrade_lvl_shift = 2
DoctorBagBase.damage_reduce_lvl_shift = 4

function DoctorBagBase:init(unit)
	UnitBase.init(self, unit, false)

	self._unit = unit
	self._is_attachable = true

	self._unit:sound_source():post_event("ammo_bag_drop")

	self._max_amount = tweak_data.upgrades.doctor_bag_base + managers.player:upgrade_value_by_level("doctor_bag", "amount_increase", 0)

	if Network:is_client() then
		self._validate_clbk_id = "doctor_bag_validate" .. tostring(unit:key())

		managers.enemy:add_delayed_clbk(self._validate_clbk_id, callback(self, self, "_clbk_validate"), Application:time() + 60)
	end

	self._damage_reduction_upgrade = false
end

function DoctorBagBase:_set_visual_stage()
	local percentage = self._amount / 4

	if self._unit:damage() then
		local state = "state_" .. math.ceil(percentage * 4)

		if self._unit:damage():has_sequence(state) then
			self._unit:damage():run_sequence_simple(state)
		end
	end
end

function DoctorBagBase:_take(unit)
	local taken = 1
	self._amount = self._amount - taken

	unit:character_damage():recover_health()
	
	if managers.player:player_unit() and managers.player:player_unit() == unit and managers.player:has_category_upgrade("player", "antilethal_meds") then --temp, gonna make this depend on the medic bag owner
		unit:character_damage():activate_docbag_token()
	end

	local rally_skill_data = unit:movement():rally_skill_data()

	if rally_skill_data then
		rally_skill_data.morale_boost_delay_t = (managers.player:has_category_upgrade("player", "morale_boost") or managers.player:has_enabled_cooldown_upgrade("cooldown", "long_dis_revive")) and 0 or nil
	end

	return taken
end