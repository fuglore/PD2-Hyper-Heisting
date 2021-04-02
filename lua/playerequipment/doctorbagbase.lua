DoctorBagBase.amount_upgrade_lvl_shift = 2
DoctorBagBase.damage_reduce_lvl_shift = 4

function DoctorBagBase.spawn(pos, rot, bits, peer_id)
	local unit_name = "units/payday2/equipment/gen_equipment_medicbag/gen_equipment_medicbag"
	local unit = World:spawn_unit(Idstring(unit_name), pos, rot)

	managers.network:session():send_to_peers_synched("sync_equipment_setup", unit, bits, peer_id or 0)
	
	unit:base():setup(bits, peer_id)

	return unit
end

function DoctorBagBase:sync_setup(bits, peer_id)
	if self._validate_clbk_id then
		managers.enemy:remove_delayed_clbk(self._validate_clbk_id)

		self._validate_clbk_id = nil
	end

	managers.player:verify_equipment(peer_id, "doctor_bag")
	self:setup(bits, peer_id)
end

function DoctorBagBase:setup(bits, peer_id)
	local amount_upgrade_lvl, dmg_reduction_lvl = self:_get_upgrade_levels(bits)
	self._damage_reduction_upgrade = dmg_reduction_lvl ~= 0
	self._amount = tweak_data.upgrades.doctor_bag_base + managers.player:upgrade_value_by_level("doctor_bag", "amount_increase", amount_upgrade_lvl)
	
	local peer = managers.network:session():peer(peer_id)
	
	if peer and alive(peer:unit()) then
		local unit = peer:unit()
		self._doctorbag_token = unit:base():upgrade_value("player", "antilethal_meds")
		self._syringe_basic = unit:base():upgrade_value("player", "soldiersyringe_basic")
		self._syringe_aced = unit:base():upgrade_value("player", "soldiersyringe_aced")
	end

	self:_set_visual_stage()

	if Network:is_server() and self._is_attachable then
		local from_pos = self._unit:position() + self._unit:rotation():z() * 10
		local to_pos = self._unit:position() + self._unit:rotation():z() * -10
		local ray = self._unit:raycast("ray", from_pos, to_pos, "slot_mask", managers.slot:get_mask("world_geometry"))

		if ray then
			self._attached_data = {
				body = ray.body,
				position = ray.body:position(),
				rotation = ray.body:rotation(),
				index = 1,
				max_index = 3
			}

			self._unit:set_extension_update_enabled(Idstring("base"), true)
		end
	end
end

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
	
	if managers.player:player_unit() and managers.player:player_unit() == unit then
		managers.player:activate_heal_upgrades(self._doctorbag_token, self._syringe_basic, self._syringe_aced)		
	end

	local rally_skill_data = unit:movement():rally_skill_data()

	if rally_skill_data then
		rally_skill_data.morale_boost_delay_t = (managers.player:has_category_upgrade("player", "morale_boost") or managers.player:has_enabled_cooldown_upgrade("cooldown", "long_dis_revive")) and 0 or nil
	end

	return taken
end