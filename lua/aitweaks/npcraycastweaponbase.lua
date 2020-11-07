local trail_func = NPCRaycastWeaponBase.init
function NPCRaycastWeaponBase:init(...)
	trail_func(self, ...)
	self._bullet_slotmask = self._bullet_slotmask - World:make_slot_mask(22)
	
	local weapon_tweak = tweak_data.weapon[self._name_id]

	local trail = Idstring("effects/particles/weapons/weapon_trail")
		
	if weapon_tweak and weapon_tweak.r_trail then
		trail = Idstring("effects/pd2_mod_hh/particles/weapons/smstreaks/long_streak_r")
		self._hivis = true
	end
	
	if weapon_tweak and weapon_tweak.hivis then
		trail = Idstring("effects/pd2_mod_hh/particles/weapons/genstreaks/hivis_streak")
		self._hivis = true
	end
	
	if weapon_tweak and weapon_tweak.lotus_vis then
		trail = Idstring("effects/pd2_mod_hh/particles/weapons/genstreaks/lotus_streak")
	end
	
	if weapon_tweak and weapon_tweak.b_trail then
		trail = Idstring("effects/pd2_mod_hh/particles/weapons/smstreaks/long_streak_b")
	end
	
	if weapon_Tweak and weapon_tweak.no_vis then
		trail = Idstring("effects/pd2_mod_hh/particles/weapons/genstreaks/novis_streak")
	end
		
	self._trail_effect_table = {
		effect = trail,
		position = Vector3(),
		normal = Vector3()
	}

	--suppressor muzzleflash switch
	if self:weapon_tweak_data().has_suppressor and self:weapon_tweak_data().muzzleflash_silenced then
		self._muzzle_effect = Idstring(self:weapon_tweak_data().muzzleflash_silenced)
	else
		self._muzzle_effect = Idstring(self:weapon_tweak_data().muzzleflash or "effects/particles/test/muzzleflash_maingun")
	end

	--proper armor penetration to apply in copdamage (plus shield, enemy and cosmetic wall penetration)
	if self:weapon_tweak_data().armor_piercing then
		self._use_armor_piercing = true
	end
	
	if self._flashlight_data then
		self:set_flashlight_enabled(true)
	end
end

local setup_func = NPCRaycastWeaponBase.setup
function NPCRaycastWeaponBase:setup(setup_data, ...)
	setup_func(self, setup_data, ...)
	self._bullet_slotmask = self._bullet_slotmask - World:make_slot_mask(22) --removes a certain specific slotmask type related to bullet-impacts for enemies
	self._enemy_slotmask = managers.slot:get_mask("criminals")
	local user_unit = setup_data.user_unit
	if user_unit then
		if user_unit:in_slot(16) then
			self._bullet_slotmask = self._bullet_slotmask - World:make_slot_mask(16, 22) --removes criminals and certain kinds of bullet-impact related slotmasks
			self._enemy_slotmask = managers.slot:get_mask("enemies")
		end
	end

	if self._flashlight_data then
		self:set_flashlight_enabled(true)
	end
end

function NPCRaycastWeaponBase:flashlight_state_changed()
	if not self._flashlight_data then
		return
	end

	if not self._flashlight_data.enabled or self._flashlight_data.dropped then
		return
	end
	
	local enabled = true --always enabled

	if managers.game_play_central:flashlights_on() or enabled then
		self._flashlight_data.light:set_enable(self._flashlight_light_lod_enabled)
		self._flashlight_data.effect:activate()

		self._flashlight_data.on = true
	else
		self._flashlight_data.light:set_enable(false)
		self._flashlight_data.effect:kill_effect()

		self._flashlight_data.on = false
	end
end

function NPCRaycastWeaponBase:set_flashlight_enabled(enabled)
	if not self._flashlight_data then
		return
	end
	
	enabled = true --always enabled

	self._flashlight_data.enabled = enabled

	if managers.game_play_central:flashlights_on() or enabled then
		self._flashlight_data.light:set_enable(self._flashlight_light_lod_enabled)
		self._flashlight_data.effect:activate()

		self._flashlight_data.on = true
	else
		self._flashlight_data.light:set_enable(false)
		self._flashlight_data.effect:kill_effect()

		self._flashlight_data.on = false
	end
end

function NPCRaycastWeaponBase:_get_spread(user_unit)
	local weapon_tweak = tweak_data.weapon[self._name_id]

	if not weapon_tweak then
		return 3
	end
	
	if weapon_tweak.spread then
		return weapon_tweak.spread
	else
		return 1
	end
end

local mvec_to = Vector3()
local mvec_spread = Vector3()

function NPCRaycastWeaponBase:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)
	local char_hit = nil
	local result = {}
	local ray_distance = self._weapon_range or 20000
	local miss, extra_spread = self:_check_smoke_shot(user_unit, target_unit)

	if miss then
		result.guaranteed_miss = miss

		mvector3.spread(direction, math.rand(unpack(extra_spread)))
	else
		local true_spread = self:_get_spread(user_unit)

		if true_spread > 1 then
			mvector3.spread(direction, true_spread)
		end
	end

	mvector3.set(mvec_to, direction)
	mvector3.multiply(mvec_to, ray_distance)
	mvector3.add(mvec_to, from_pos)

	local damage = self._damage * (dmg_mul or 1)
	local ray_hits = nil
	local hit_enemy = false
	local enemy_mask = self._enemy_slotmask
	local wall_mask = managers.slot:get_mask("world_geometry", "vehicles")
	local shield_mask = managers.slot:get_mask("enemy_shield_check")
	local ai_vision_ids = Idstring("ai_vision")
	local bulletproof_ids = Idstring("bulletproof")

	if self._use_armor_piercing then
		ray_hits = World:raycast_wall("ray", from_pos, mvec_to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units, "thickness", 40, "thickness_mask", wall_mask)
	else
		ray_hits = World:raycast_all("ray", from_pos, mvec_to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units)
	end

	local units_hit = {}
	local unique_hits = {}

	for i, hit in ipairs(ray_hits) do
		if not units_hit[hit.unit:key()] then
			units_hit[hit.unit:key()] = true
			unique_hits[#unique_hits + 1] = hit
			hit.hit_position = hit.position
			hit_enemy = hit_enemy or hit.unit:in_slot(enemy_mask)
			local weak_body = hit.body:has_ray_type(ai_vision_ids)
			weak_body = weak_body or hit.body:has_ray_type(bulletproof_ids)

			if not self._use_armor_piercing then
				if hit_enemy or hit.unit:in_slot(wall_mask) and weak_body or hit.unit:in_slot(shield_mask) then
					break
				end
			end
		end
	end

	local furthest_hit = unique_hits[#unique_hits]
	local hit_player = nil
	local nc_or_nothit_chk = nil

	if #unique_hits > 0 then
		for _, hit in ipairs(unique_hits) do
			if not hit_player and shoot_player and self._hit_player then
				local player_hit, player_ray_data = self:damage_player(hit, from_pos, direction, result)

				if player_hit then
					hit_player = true
					InstantBulletBase:on_hit_player(hit or player_ray_data, self._unit, user_unit, damage)

					if not self._use_armor_piercing then
						hit.position = mvector3.copy(managers.player:player_unit():movement():m_head_pos())
						hit.distance = mvector3.direction(hit.ray, mvector3.copy(from_pos), mvector3.copy(managers.player:player_unit():movement():m_head_pos()))
						furthest_hit = hit

						break
					end
				end
			end

			if hit.unit ~= target_unit then
				nc_or_nothit_chk = true
			end

			char_hit = InstantBulletBase:on_collision(hit, self._unit, user_unit, damage)

			if char_hit and char_hit.type and char_hit.type == "death" then
				if self:is_category("shotgun") then
					managers.game_play_central:do_shotgun_push(hit.unit, hit.position, hit.ray, hit.distance, user_unit)
				end
			end
		end
	else
		nc_or_nothit_chk = true

		if shoot_player and self._hit_player then
			local player_hit, player_ray_data = self:damage_player(nil, from_pos, direction, result)

			if player_hit then
				hit_player = true
				InstantBulletBase:on_hit_player(player_ray_data, self._unit, user_unit, damage)
			end
		end
	end

	if target_unit and not hit_player and nc_or_nothit_chk and target_unit:character_damage() and target_unit:character_damage().build_suppression then
		local weaponname = tweak_data.weapon[self._name_id]

		if weaponname.suppression and weaponname.suppression >= 5 then
			target_unit:character_damage():build_suppression(math.max(tweak_data.weapon[self._name_id].suppression, 1))
			shouldnt_suppress_on_hit = true
		end
	end

	result.hit_enemy = char_hit
	local fhover600ornohitormiss = furthest_hit and furthest_hit.distance > 600 or not furthest_hit or result.guaranteed_miss
	if fhover600ornohitormiss and alive(self._obj_fire) then
		local num_rays = (tweak_data.weapon[self._name_id] or {}).rays or 1
		local trail_direction = furthest_hit and furthest_hit.ray or direction

		for i = 1, num_rays do
			mvector3.set(mvec_spread, trail_direction)

			if i > 1 then
				mvector3.spread(mvec_spread, self:_get_spread(user_unit))
			end

			self:_spawn_trail_effect(mvec_spread, furthest_hit)
		end
	end

	if self._alert_events then
		result.rays = unique_hits
	end

	self:_cleanup_smoke_shot()

	return result
end
