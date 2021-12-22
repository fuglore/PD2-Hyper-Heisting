FirstAidKitBase.upgrade_lvl_shift = 2
FirstAidKitBase.auto_recovery_shift = 4

function FirstAidKitBase.spawn(pos, rot, bits, peer_id)
	local unit_name = "units/pd2_dlc_old_hoxton/equipment/gen_equipment_first_aid_kit/gen_equipment_first_aid_kit"
	local unit = World:spawn_unit(Idstring(unit_name), pos, rot)

	managers.network:session():send_to_peers_synched("sync_equipment_setup", unit, bits, peer_id or 0)
	unit:base():setup(bits, peer_id)

	return unit
end

function FirstAidKitBase:sync_setup(bits, peer_id)
	if self._validate_clbk_id then
		managers.enemy:remove_delayed_clbk(self._validate_clbk_id)

		self._validate_clbk_id = nil
	end

	managers.player:verify_equipment(peer_id, "first_aid_kit")
	self:setup(bits, peer_id)
end

function FirstAidKitBase:setup(bits, peer_id)
	local upgrade_lvl, auto_recovery = self:_get_upgrade_levels(bits)
	self._damage_reduction_upgrade = upgrade_lvl == 1
	
	local peer = managers.network:session():peer(peer_id)
	
	if peer and alive(peer:unit()) then
		local unit = peer:unit()
		self._syringe_basic = unit:base():upgrade_value("player", "soldiersyringe_basic")
		self._syringe_aced = unit:base():upgrade_value("player", "soldiersyringe_aced")
	end
	
	if Network:is_server() then
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

	if auto_recovery == 1 then
		self._min_distance = tweak_data.upgrades.values.first_aid_kit.first_aid_kit_auto_recovery[1]

		print("min distance ", self._min_distance)
		FirstAidKitBase.Add(self, self._unit:position(), self._min_distance)
	end
end

function FirstAidKitBase:take(unit)
	if self._empty then
		return
	end
	
	if managers.player:player_unit() and managers.player:player_unit() == unit then
		managers.player:activate_heal_upgrades(nil, self._syringe_basic, self._syringe_aced)		
	end

	unit:character_damage():band_aid_health()

	if self._damage_reduction_upgrade then
		managers.player:activate_temporary_upgrade("temporary", "first_aid_damage_reduction")
	end

	if managers.network:session() then
		managers.network:session():send_to_peers_synched("sync_unit_event_id_16", self._unit, "base", 2)
	end

	self:_set_empty()
end