if PD2THHSHIN and PD2THHSHIN:IsOverhaulEnabled() then
	--i hate doing this so much but i couldn't figure out a proper way to posthook this. hopefully someone else can figure out how but for now i guess i'll just die
	function SawWeaponBase:fire(from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)
		if self:get_ammo_remaining_in_clip() == 0 then
			return
		end

		local user_unit = self._setup.user_unit
		local ray_res, hit_something = self:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)

		if hit_something then
			self:_start_sawing_effect()

			local ammo_usage = 5

			if ray_res.hit_enemy then
				ammo_usage = 15
			end

			ammo_usage = ammo_usage + math.ceil(math.random() * 10)

			if managers.player:has_category_upgrade("saw", "consume_no_ammo_chance") then
				local roll = math.rand(1)
				local chance = managers.player:upgrade_value("saw", "consume_no_ammo_chance", 0)

				if roll < chance then
					ammo_usage = 0
				end
			end

			if managers.player:has_active_temporary_property("bullet_storm") then
				ammo_usage = 0
			end
			
			if managers.player:has_category_upgrade("saw", "enemy_slicer") and ray_res.hit_enemy then
				ammo_usage = 0
			end

			ammo_usage = math.min(ammo_usage, self:get_ammo_remaining_in_clip())

			self:set_ammo_remaining_in_clip(math.max(self:get_ammo_remaining_in_clip() - ammo_usage, 0))
			self:set_ammo_total(math.max(self:get_ammo_total() - ammo_usage, 0))
			self:_check_ammo_total(user_unit)
		else
			self:_stop_sawing_effect()
		end

		if self._alert_events and ray_res.rays then
			if hit_something then
				self._alert_size = self._hit_alert_size
			else
				self._alert_size = self._no_hit_alert_size
			end

			self._current_stats.alert_size = self._alert_size

			self:_check_alert(ray_res.rays, from_pos, direction, user_unit)
		end

		return ray_res
	end
end