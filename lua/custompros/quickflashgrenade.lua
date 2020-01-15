BouncerNade = BouncerNade or class(QuickFlashGrenade)

BouncerNade.States = {
	{
		"_state_launched",
		1
	},
	{
		"_state_bounced"
	},
	{
		"_state_detonated",
		3
	},
	{
		"_state_destroy",
		0
	}
}
BouncerNade.Events = {
	DestroyedByPlayer = 1,
	[1.0] = "on_flashbang_destroyed"
}

function BouncerNade:init(unit)
	self._unit = unit
	self._state = 0
	self._armed = false
	self._player_damage = 5
	self._effect_name = "effects/payday2/particles/explosions/grenade_explosion"
	self._custom_params = {
		camera_shake_max_mul = 4,
		sound_muffle_effect = true,
		effect = self._effect_name,
		sound_event = sound_event,
		feedback_range = 500 * 2
	}
	
	
	for i, state in ipairs(BouncerNade.States) do
		if state[2] == nil then
			BouncerNade.States[i][2] = tweak_data.group_ai.flash_grenade.timer
		end
	end

	if Network:is_client() then
		self:activate(self._unit:position(), tweak_data.group_ai.flash_grenade_lifetime)
	end
end

function BouncerNade:is_grenade()
	return true
end

function BouncerNade:is_cop_grenade()
	return true
end

function BouncerNade:update(unit, t, dt)
	if self._destroyed_t then
		self._destroyed_t = self._destroyed_t - dt

		if self._destroyed_t <= 0 then
			self:destroy_unit()
		end
	end

	if self._destroyed or not self._armed then
		return
	end

	if self._timer then
		self._timer = self._timer - dt

		if self._timer <= 0 then
			self._state = self._state + 1
			local state = BouncerNade.States[self._state]

			if state then
				self[state[1]](self)

				self._timer = state[2]
			else
				self._timer = nil
			end
		end
	end

	if self._state == 2 then
		if self._beep_t then
			self._beep_t = self._beep_t - dt

			if self._beep_t < 0 then
				self:_beep()
			end
		else
			self:_beep()
		end
	end

	if alive(self._light) then
		self._light_multiplier = math.clamp(self._light_multiplier - dt * tweak_data.group_ai.flash_grenade.beep_fade_speed, 0, 1)

		self._light:set_multiplier(self._light_multiplier)
		self._light:set_far_range(600 * self._light_multiplier)
	end
end

function BouncerNade:_beep()
	self._unit:sound_source():post_event("ecm_jammer_ready")

	self._beep_t = self:_get_next_beep_time()
	self._light_multiplier = tweak_data.group_ai.flash_grenade.beep_multi
end

function BouncerNade:timer(new)
	if not self._timer then
		self._timer = 3
	end

	self._timer = new or self._timer

	return self._timer
end

function BouncerNade:_get_next_beep_time()
	local beep_speed = tweak_data.group_ai.flash_grenade.beep_speed

	return self:timer() / beep_speed[1] * beep_speed[2]
end

-- Lines 110-112
function BouncerNade:activate(position, duration)
	self:_activate(0, 0, position, duration)
end

function BouncerNade:activate_immediately(position, duration)
	self:_activate(2, 0, position, duration)
end

function BouncerNade:_activate(state, timer, position, duration)
	self._armed = true
	self._timer = timer
	self._shoot_position = position
	self._duration = duration
end

function BouncerNade:_state_launched()
	self._unit:damage():run_sequence_simple("insert")
	
	local sound_source = SoundDevice:create_source("grenade_fire_source")

	sound_source:set_position(self._unit:position())
	sound_source:post_event("grenade_gas_npc_fire")
end

function BouncerNade:_state_bounced()
	self._unit:damage():run_sequence_simple("activate")

	local bounce_point = Vector3()

	mvector3.lerp(bounce_point, self._shoot_position, self._unit:position(), 0.65)

	local sound_source = SoundDevice:create_source("grenade_bounce_source")

	sound_source:set_position(bounce_point)
	sound_source:post_event("flashbang_bounce", callback(self, self, "sound_playback_complete_clbk"), sound_source, "end_of_event")

	local light = World:create_light("omni|specular")

	light:set_far_range(600)
	light:set_color(tweak_data.group_ai.flash_grenade.light_color)
	light:set_position(self._unit:position())
	light:set_specular_multiplier(tweak_data.group_ai.flash_grenade.light_specular)
	light:set_enable(true)
	light:set_multiplier(0)
	light:set_falloff_exponent(0.5)

	self._light = light
	self._light_multiplier = 0
end

function BouncerNade:_state_detonated()
	local detonate_pos = self._unit:position()
	if Network:is_server() then
		self:make_flash(detonate_pos, tweak_data.group_ai.flash_grenade.range, nil)
		managers.groupai:state():propagate_alert({
			"aggression",
			detonate_pos,
			10000,
			managers.groupai:state():get_unit_type_filter("civilians_enemies")
		})
		self._unit:damage():run_sequence_simple("detonate")
	else
		self:make_flash_client(detonate_pos, tweak_data.group_ai.flash_grenade.range, nil)
		self._unit:damage():run_sequence_simple("detonate")
	end
end

function BouncerNade:_state_destroy()
	self:destroy_unit()
end

function BouncerNade:make_flash(detonate_pos, range, ignore_units)
	local pos = self._unit:position()
	local normal = math.UP
	local range = 500
	local slot_mask = managers.slot:get_mask("explosion_targets")

	managers.explosion:give_local_player_dmg(pos, range, self._player_damage)
	managers.explosion:play_sound_and_effects(pos, normal, range, self._custom_params)

	local hit_units, splinters = managers.explosion:detect_and_give_dmg({
		player_damage = 5,
		hit_pos = pos,
		range = range,
		collision_slotmask = slot_mask,
		curve_pow = 3,
		damage = 5,
		ignore_unit = self._unit,
		alert_radius = 10000,
		user = self._unit,
		owner = self._unit
	})
end

function BouncerNade:make_flash_client(detonate_pos, range, ignore_units)
	local normal = math.UP
	local range = 500
	local slot_mask = managers.slot:get_mask("explosion_targets")

	local pos = self._unit:position()

	managers.explosion:give_local_player_dmg(pos, range, 5)
	managers.explosion:explode_on_client(pos, math.UP, nil, 5, range, 3, self._custom_params)
end


function BouncerNade:_chk_dazzle_local_player(detonate_pos, range, ignore_units)
	local player = managers.player:player_unit()

	if not alive(player) then
		return
	end

	local detonate_pos = detonate_pos or self._unit:position() + math.UP * 150
	local m_pl_head_pos = player:movement():m_head_pos()
	local linear_dis = mvector3.distance(detonate_pos, m_pl_head_pos)

	if range < linear_dis then
		return
	end

	local slotmask = managers.slot:get_mask("bullet_impact_targets")


	local function _vis_ray_func(from, to, boolean)
		if ignore_units then
			return World:raycast("ray", from, to, "ignore_unit", ignore_units, "slot_mask", slotmask, boolean and "report" or nil)
		else
			return World:raycast("ray", from, to, "slot_mask", slotmask, boolean and "report" or nil)
		end
	end

	if not _vis_ray_func(m_pl_head_pos, detonate_pos, true) then
		return true, true, nil, linear_dis
	end

	local random_rotation = Rotation(360 * math.random(), 360 * math.random(), 360 * math.random())
	local raycast_dir = Vector3()
	local bounce_pos = Vector3()

	for _, axis in ipairs({
		"x",
		"y",
		"z"
	}) do
		for _, polarity in ipairs({
			1,
			-1
		}) do
			mvector3.set_zero(raycast_dir)
			mvector3["set_" .. axis](raycast_dir, polarity)
			mvector3.rotate_with(raycast_dir, random_rotation)
			mvector3.set(bounce_pos, raycast_dir)
			mvector3.multiply(bounce_pos, range)
			mvector3.add(bounce_pos, detonate_pos)

			local bounce_ray = _vis_ray_func(detonate_pos, bounce_pos)

			if bounce_ray then
				mvector3.set(bounce_pos, raycast_dir)
				mvector3.multiply(bounce_pos, -1 * math.min(bounce_ray.distance, 10))
				mvector3.add(bounce_pos, bounce_ray.position)

				local return_ray = _vis_ray_func(m_pl_head_pos, bounce_pos, true)

				if not return_ray then
					local travel_dis = bounce_ray.distance + mvector3.distance(m_pl_head_pos, bounce_pos)

					if range > travel_dis then
						return true, false, travel_dis, linear_dis
					end
				end
			end
		end
	end
end

function BouncerNade:sound_playback_complete_clbk(event_instance, sound_source, event_type, sound_source_again)
end

function BouncerNade:preemptive_kill()
	self:destroy_unit()
end

function BouncerNade:destroy_unit()
	self._unit:set_slot(0)
end

function BouncerNade:remove_light()
	if alive(self._light) then
		World:delete_light(self._light)

		self._light = nil
	end
end

function BouncerNade:destroy()
	self:remove_light()
end
