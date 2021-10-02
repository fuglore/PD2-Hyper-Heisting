function PlayerParachuting:_update_foley(t, input)
	if self._gnd_ray then
		self._state_data.in_air = false
		self._state_data.in_air_enter_t = nil
		self._jump_t = nil
		self._jump_vel_xy = nil
		self._unit:set_driving("script")
		
		self._camera_unit:base():set_target_tilt(0)
		self._ext_camera:play_shaker("player_land", 1.5)
		managers.rumble:play("hard_land")
		managers.player:set_player_state("standard")
	elseif not self._gnd_ray and not self._state_data.on_ladder then
		if not self._state_data.in_air then
			self._state_data.in_air = true
			self._state_data.in_air_enter_t = t
			self._state_data.enter_air_pos_z = self._pos.z

			self._unit:set_driving("orientation_object")
		end
	end
end