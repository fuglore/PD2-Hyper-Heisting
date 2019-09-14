local trail_func = NPCRaycastWeaponBase.init
function NPCRaycastWeaponBase:init(...)
	trail_func(self, ...)
	self._bullet_slotmask = self._bullet_slotmask - World:make_slot_mask(22)
	
	local weapon_tweak = tweak_data.weapon[self._name_id]

	local trail = Idstring("effects/particles/weapons/weapon_trail")
		
	if weapon_tweak and weapon_tweak.r_trail then
		trail = Idstring("effects/pd2_mod_hh/particles/weapons/smstreaks/long_streak_r")
	end
	
	if weapon_tweak and weapon_tweak.hivis then
		trail = Idstring("effects/pd2_mod_hh/particles/weapons/genstreaks/hivis_streak")
	end
	
	if weapon_tweak and weapon_tweak.b_trail then
		trail = Idstring("effects/pd2_mod_hh/particles/weapons/smstreaks/long_streak_b")
	end
		
	self._trail_effect_table = {
		effect = trail,
		position = Vector3(),
		normal = Vector3()
	}
end

local setup_func = NPCRaycastWeaponBase.setup
function NPCRaycastWeaponBase:setup(setup_data, ...)
	setup_func(self, setup_data, ...)
	self._bullet_slotmask = self._bullet_slotmask - World:make_slot_mask(22) --removes a certain specific slotmask type related to bullet-impacts for enemies
	local user_unit = setup_data.user_unit
	if user_unit then
		if user_unit:in_slot(16) then
			self._bullet_slotmask = self._bullet_slotmask - World:make_slot_mask(16, 22) --removes criminals and certain kinds of bullet-impact related slotmasks
		end
	end		
end

function NPCRaycastWeaponBase:_spawn_trail_effect(direction, col_ray)
	self._obj_fire:m_position(self._trail_effect_table.position)
	mvector3.set(self._trail_effect_table.normal, direction)

	local trail = World:effect_manager():spawn(self._trail_effect_table)

	if col_ray then
		World:effect_manager():set_remaining_lifetime(trail, math.clamp((col_ray.distance - 600) / 10000, 0, col_ray.distance))
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
		return 3
	end
end

local mvec_true_spread = Vector3()
local mvec_to = Vector3()
local mvec_spread = Vector3()
function NPCRaycastWeaponBase:_fire_raycast(user_unit, from_pos, direction, dmg_mul, shoot_player, spread_mul, autohit_mul, suppr_mul, target_unit)
	local result = {}
	local hit_unit = nil
	local miss, extra_spread = self:_check_smoke_shot(user_unit, target_unit)
	local true_spread = self:_get_spread(user_unit)
	local spreadtweak = self:_get_spread(user_unit)
	spreadtweak = spreadtweak * 0.25
	spreadtweak = math.min(spreadtweak, 5)
	spreadtweak = math.max(1, spreadtweak)
	
	if miss then
		result.guaranteed_miss = miss

		mvector3.spread(direction, math.rand(unpack(extra_spread)))
	end

	mvector3.set(mvec_to, direction)
	mvector3.multiply(mvec_to, 20000)
	
	if true_spread > 1 then
		mvector3.spread(mvec_to, self:_get_spread(user_unit))
	end
	
	mvector3.add(mvec_to, from_pos)

	local damage = self._damage * (dmg_mul or 1)
	local col_ray = World:raycast("ray", from_pos, mvec_to, "slot_mask", self._bullet_slotmask, "ignore_unit", self._setup.ignore_units)
	local player_hit, player_ray_data = nil
	local shouldnt_suppress_on_hit = nil
	
	if (not col_ray or col_ray.unit ~= target_unit) and target_unit and target_unit:character_damage() and target_unit:character_damage().build_suppression then
		local weaponname = tweak_data.weapon[self._name_id]
		if weaponname.suppression and weaponname.suppression >= 5 then
			target_unit:character_damage():build_suppression(tweak_data.weapon[self._name_id].suppression)
			shouldnt_suppress_on_hit = true
		end
	end


	if shoot_player and self._hit_player then
		player_hit, player_ray_data = self:damage_player(col_ray, from_pos, direction, result)

		if player_hit then
			if target_unit and target_unit:character_damage() and target_unit:character_damage().build_suppression and not should_suppress_on_hit then
				target_unit:character_damage():build_suppression(tweak_data.weapon[self._name_id].suppression)
			end
			InstantBulletBase:on_hit_player(col_ray or player_ray_data, self._unit, user_unit, damage)
		end
	end
	
	local char_hit = nil

	if not player_hit and col_ray then
		char_hit = InstantBulletBase:on_collision(col_ray, self._unit, user_unit, damage)
	end

	if not col_ray or col_ray.distance > 600 or result.guaranteed_miss then
		local weaponname = tweak_data.weapon[self._name_id]
		local num_rays = weaponname.rays or 1
			
		for i = 1, num_rays, 1 do
			mvector3.set(mvec_spread, direction)
			
			if i > 1 then
				mvector3.spread(mvec_spread, spreadtweak)
			end

			self:_spawn_trail_effect(mvec_spread, col_ray)
		end
	end

	result.hit_enemy = char_hit

	if self._alert_events then
		result.rays = {
			col_ray
		}
	end

	self:_cleanup_smoke_shot()

	return result
end
