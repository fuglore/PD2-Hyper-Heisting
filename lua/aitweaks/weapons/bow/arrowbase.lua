local mvec1 = Vector3()
local mvec2 = Vector3()
local ids_pickup = Idstring("pickup")

local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()

local world_g = World

local mvec3_dir = mvector3.direction
local mvec3_dot = mvector3.dot
local mvec3_dis = mvector3.distance
local mvec3_angle = mvector3.angle
local mvec3_dis_sq = mvector3.distance_sq
local mvec3_step = mvector3.step
local mvec3_set = mvector3.set
local mvec3_set_z = mvector3.set_z
local mvec3_norm = mvector3.normalize

local math_lerp = math.lerp

local anti_gravitate_idstr = Idstring("physic_effects/anti_gravitate")

function ArrowBase.throw_projectile(projectile_type, pos, dir, owner_peer_id, homing)
	if not ProjectileBase.check_time_cheat(projectile_type, owner_peer_id) then
		return
	end

	local tweak_entry = tweak_data.blackmarket.projectiles[projectile_type]
	local unit_name = Idstring(not Network:is_server() and tweak_entry.local_unit or tweak_entry.unit)
	local unit = World:spawn_unit(unit_name, pos, Rotation(dir, math.UP))
	
	if homing then
		unit:base()._should_home_in = world_g:play_physic_effect(anti_gravitate_idstr, unit)
		unit:base()._homing_physics = true
	end

	if owner_peer_id and managers.network:session() then
		local peer = managers.network:session():peer(owner_peer_id)
		local thrower_unit = peer and peer:unit()

		if alive(thrower_unit) then
			unit:base():set_thrower_unit(thrower_unit)

			if not tweak_entry.throwable and thrower_unit:movement() and thrower_unit:movement():current_state() then
				unit:base():set_weapon_unit(thrower_unit:movement():current_state()._equipped_unit)
			end
		end
	end

	unit:base():throw({
		dir = dir,
		projectile_entry = projectile_type,
		homing = homing
	})

	if unit:base().set_owner_peer_id then
		unit:base():set_owner_peer_id(owner_peer_id)
	end

	local projectile_type_index = tweak_data.blackmarket:get_index_from_projectile_id(projectile_type)

	managers.network:session():send_to_peers_synched("sync_throw_projectile", unit:id() ~= -1 and unit or nil, pos, dir, projectile_type_index, owner_peer_id or 0)

	if tweak_data.blackmarket.projectiles[projectile_type].impact_detonation then
		unit:damage():add_body_collision_callback(callback(unit:base(), unit:base(), "clbk_impact"))
		unit:base():create_sweep_data()
	end

	return unit
end

local homing_effect = "effects/payday2/particles/weapons/arrow_trail_homing"

function ArrowBase:add_trail_effect()
	local effect = self._should_home_in and homing_effect or nil

	managers.game_play_central:add_projectile_trail(self._unit, self._unit:orientation_object(), effect)
end

function ArrowBase:throw(params)
	self._owner = params.owner
	local velocity = params.dir
	local adjust_z = 50
	local launch_speed = 250
	local push_at_body_index = nil

	if params.projectile_entry and tweak_data.projectiles[params.projectile_entry] then
		adjust_z = tweak_data.projectiles[params.projectile_entry].adjust_z or adjust_z
		launch_speed = tweak_data.projectiles[params.projectile_entry].launch_speed or launch_speed
		push_at_body_index = tweak_data.projectiles[params.projectile_entry].push_at_body_index
	end
	
	velocity = velocity * launch_speed
	
	if self._should_home_in then
		velocity = Vector3(velocity.x, velocity.y, velocity.z - adjust_z)
	else
		velocity = Vector3(velocity.x, velocity.y, velocity.z + adjust_z)
	end
	
	local mass_look_up_modifier = self._mass_look_up_modifier or 1
	local mass = math.max(mass_look_up_modifier * (1 + math.min(0, params.dir.z)), 1)

	if self._simulated then
		if push_at_body_index then
			self._unit:push_at(mass, velocity, self._unit:body(push_at_body_index):center_of_mass())
		else
			self._unit:push_at(mass, velocity, self._unit:position())
		end
	else
		self._velocity = velocity
	end

	if params.projectile_entry and tweak_data.blackmarket.projectiles[params.projectile_entry] then
		local tweak_entry = tweak_data.blackmarket.projectiles[params.projectile_entry]

		if tweak_entry.add_trail_effect then
			self:add_trail_effect()
		end

		local unit_name = tweak_entry.sprint_unit

		if unit_name then
			local new_dir = Vector3(params.dir.y * -1, params.dir.x, params.dir.z)
			local sprint = world_g:spawn_unit(Idstring(unit_name), self._unit:position() + new_dir * 50, self._unit:rotation())
			local rot = Rotation(params.dir, math.UP)

			mrotation.x(rot, mvec1)
			mvector3.multiply(mvec1, 0.15)
			mvector3.add(mvec1, new_dir)
			mvector3.add(mvec1, math.UP / 2)
			mvector3.multiply(mvec1, 100)
			sprint:push_at(mass, mvec1, sprint:position())
		end

		self:set_projectile_entry(params.projectile_entry)
	end
end

local medic_tag = "medic"

function ArrowBase:_calculate_homing_dir()
	local m_unit = self._unit
	local pos = m_unit:position()
	local dir = m_unit:rotation():y()
	local closest_dis, closest_pos, homing_into, best_angle, has_medic = nil
	
	local enemies = world_g:find_units_quick(m_unit, "sphere", pos, 400, managers.slot:get_mask("enemies"))
	local obstruction_mask = managers.slot:get_mask("world_geometry", "vehicles", "enemy_shield_check")
		
	for i = 1, #enemies do
		local enemy = enemies[i]
		
		if not enemy:in_slot(16) then
			local valid = nil
			local com = enemy:movement():m_head_pos()
			local dis = mvec3_dis_sq(pos, com)
			
			if not has_medic then
				if dis <= 40000 then
					valid = true
				else
					com = enemy:movement():m_com()
					dis = mvec3_dis_sq(pos, com)
					if dis <= 40000 then
						valid = true
					end
				end
			
				if valid then		
					local obstructed = m_unit:raycast("ray", pos, com, "sphere_cast_radius", 5, "slot_mask", obstruction_mask, "report")
					
					if not obstructed then
						mvec3_dir(tmp_vec1, pos, com)

						local angle = mvec3_angle(dir, tmp_vec1)

						if angle <= 60 then
							if enemy:base():has_tag(medic_tag) then
								best_angle = angle
								closest_dis = dis
								closest_pos = com
								has_medic = true
							elseif not closest_dis or dis < closest_dis then
								if not best_angle or angle <= best_angle then
									best_angle = angle
									closest_dis = dis
									closest_pos = com
								end
							end
						end
					end
				end
			elseif enemy:base():has_tag(medic_tag) then
				if dis <= 40000 then
					valid = true
				else
					com = enemy:movement():m_com()
					dis = mvec3_dis_sq(pos, com)
					if dis <= 40000 then
						valid = true
					end
				end
			
				if valid then		
					local obstructed = m_unit:raycast("ray", pos, com, "sphere_cast_radius", 5, "slot_mask", obstruction_mask, "report")
					
					if not obstructed then
						mvec3_dir(tmp_vec1, pos, com)

						local angle = mvec3_angle(dir, tmp_vec1)

						if angle <= 60 then
							if not closest_dis or dis < closest_dis then
								if not best_angle or angle <= best_angle then
									best_angle = angle
									closest_dis = dis
									closest_pos = com
								end
							end
						end
					end
				end
			end
		end
	end

	if closest_pos then
		mvec3_dir(tmp_vec1, pos, closest_pos)

		return tmp_vec1, closest_dis
	end
end

function ArrowBase:_calculate_autohit_direction()
	local enemies = managers.enemy:all_enemies()
	local m_unit = self._unit
	local pos = m_unit:position()
	local dir = m_unit:rotation():y()
	local closest_ang, closest_pos = nil
	
	local obstruction_mask = managers.slot:get_mask("world_geometry", "vehicles", "enemy_shield_check")

	for u_key, enemy_data in pairs(enemies) do
		local enemy = enemy_data.unit
		
		if not enemy:in_slot(16) then
			local com = enemy:movement():m_head_pos()
			local obstructed = m_unit:raycast("ray", pos, com, "slot_mask", obstruction_mask, "report")
			
			if not obstructed then
				mvec3_dir(tmp_vec1, pos, com)
				mvec3_set_z(tmp_vec1, 0)

				local angle = mvec3_angle(dir, tmp_vec1)

				if angle < 30 then
					if not closest_ang or angle < closest_ang then
						closest_ang = angle
						closest_pos = com
					end
				end
			end
		end
	end

	if closest_pos then
		mvector3.direction(tmp_vec1, pos, closest_pos)

		return tmp_vec1
	end
end

local tmp_vel = Vector3()
function ArrowBase:update(unit, t, dt)
	if self._drop_in_sync_data then
		self._drop_in_sync_data.f = self._drop_in_sync_data.f - 1

		if self._drop_in_sync_data.f < 0 then
			local parent_unit = self._drop_in_sync_data.parent_unit

			if alive(parent_unit) then
				local state = self._drop_in_sync_data.state
				local parent_body = parent_unit:body(state.sync_attach_data.parent_body_index)
				local parent_obj = parent_body:root_object()

				self:sync_attach_to_unit(false, parent_unit, parent_body, parent_obj, state.sync_attach_data.local_pos, state.sync_attach_data.dir, true)
			end

			self._drop_in_sync_data = nil
		end
	end

	if not self._is_pickup then
		if self._should_home_in then
			if not self._homing_physics_t then
				self._homing_physics_t = t + 5
			end
		
			local autohit_dir, target_dis = self:_calculate_homing_dir()
			
			if autohit_dir then
				if not self._homing_physics then
					unit:base()._should_home_in = world_g:play_physic_effect(anti_gravitate_idstr, unit)
					self._homing_physics = true
				end
			
				local body = self._unit:body(0)

				mvec3_set(tmp_vel, body:velocity())
					
				local speed = mvec3_norm(tmp_vel)

				mvec3_step(tmp_vel, tmp_vel, autohit_dir, dt * 84)
				
				local rot = Rotation(tmp_vel, math.UP)
				
				body:set_rotation(rot)
				
				body:set_velocity(tmp_vel * speed)
			elseif self._homing_physics_t < t then
				world_g:stop_physic_effect(self._should_home_in)
				self._homing_physics = nil
			end
		else
			local autohit_dir = self:_calculate_autohit_direction()

			if autohit_dir then
				local body = self._unit:body(0)

				mvec3_set(tmp_vel, body:velocity())

				local speed = mvector3.normalize(tmp_vel)

				mvec3_step(tmp_vel, tmp_vel, autohit_dir, dt * 0.3)
				
				local rot = Rotation(tmp_vel, math.UP)
				
				body:set_rotation(rot)
				
				body:set_velocity(tmp_vel * speed)
			end
		end
	elseif self._should_home_in then
		world_g:stop_physic_effect(self._should_home_in)
		self._should_home_in = nil
	end

	ArrowBase.super.update(self, unit, t, dt)

	if self._draw_debug_cone then
		local tip = unit:position()
		local base = tip + unit:rotation():y() * -35

		Application:draw_cone(tip, base, 3, 0, 0, 1)
	end
end

function ArrowBase:_on_collision(col_ray)
	local damage_mult = self._weapon_damage_mult or 1
	local loose_shoot = self._weapon_charge_fail
	local result = nil
	
	if not loose_shoot and alive(col_ray.unit) then
		local client_damage = self._damage_class.is_explosive_bullet or alive(col_ray.unit) and col_ray.unit:id() ~= -1

		if Network:is_server() or client_damage then
			result = self._damage_class:on_collision(col_ray, self._weapon_unit or self._unit, self._thrower_unit, self._damage * damage_mult, false, false)
		end
	end

	if not loose_shoot and tweak_data.projectiles[self._tweak_projectile_entry].remove_on_impact then
		self._unit:set_slot(0)

		return
	end
	
	self._unit:body("dynamic_body"):set_deactivate_tag(Idstring())

	self._col_ray = col_ray
		
	if self._should_home_in then
		world_g:stop_physic_effect(self._should_home_in)
		self._should_home_in = nil
	end

	self:_attach_to_hit_unit(nil, loose_shoot)
end