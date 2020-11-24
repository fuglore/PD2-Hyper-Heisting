function PlayerFatal:enter(state_data, enter_data)
	PlayerFatal.super.enter(self, state_data, enter_data)
	self:_interupt_action_steelsight()
	self:_interupt_action_melee(managers.player:player_timer():time())
	self:_interupt_action_ladder(managers.player:player_timer():time())

	local projectile_entry = managers.blackmarket:equipped_projectile()

	if tweak_data.blackmarket.projectiles[projectile_entry].is_a_grenade then
		self:_interupt_action_throw_grenade(managers.player:player_timer():time())
	else
		self:_interupt_action_throw_projectile(managers.player:player_timer():time())
	end

	self:_interupt_action_charging_weapon(managers.player:player_timer():time())
	self:_start_action_dead(managers.player:player_timer():time())
	self:_start_action_unequip_weapon(managers.player:player_timer():time(), {
		selection_wanted = 1
	})
	self._unit:base():set_slot(self._unit, 4)
	self._unit:camera():camera_unit():base():set_target_tilt(80)

	if self._ext_movement:nav_tracker() then
		managers.groupai:state():on_criminal_neutralized(self._unit)
	end

	self._unit:character_damage():on_fatal_state_enter()

	if Network:is_server() then
		if enter_data then
			if enter_data.revive_SO_data then
				self._revive_SO_data = enter_data.revive_SO_data
			else
				self._revive_SO_data = {
					unit = self._unit
				}
				
				PlayerBleedOut._register_revive_SO(self._revive_SO_data, "revive")
			end
			
			if enter_data.deathguard_SO_id then
				self._deathguard_SO_id = enter_data.deathguard_SO_id
			end
		else
			self._revive_SO_data = {
				unit = self._unit
			}
				
			PlayerBleedOut._register_revive_SO(self._revive_SO_data, "revive")
		end
	end

	self._reequip_weapon = enter_data and enter_data.equip_weapon

	managers.network:session():send_to_peers_synched("sync_contour_state", self._unit, -1, table.index_of(ContourExt.indexed_types, "teammate_downed"), true, 1)
end