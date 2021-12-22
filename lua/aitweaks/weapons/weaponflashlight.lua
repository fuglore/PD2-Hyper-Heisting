WeaponFlashLight = WeaponFlashLight or class(WeaponGadgetBase)
WeaponFlashLight.GADGET_TYPE = "flashlight"

function WeaponFlashLight:init(unit)
	WeaponFlashLight.super.init(self, unit)

	self._on_event = "gadget_flashlight_on"
	self._off_event = "gadget_flashlight_off"
	self._a_flashlight_obj = self._unit:get_object(Idstring("a_flashlight"))
	local is_haunted = self:is_haunted()
	self._is_haunted = is_haunted
	
	local effect_path = nil
	local texture = nil
	
	if is_haunted then
		effect_path = "effects/particles/weapons/flashlight_spooky/fp_flashlight" 
		texture = "units/lights/spot_light_projection_textures/spotprojection_22_flashlight_df"
	else
		effect_path = "effects/particles/weapons/flashlight/fp_flashlight_multicolor"
		texture = "units/lights/spot_light_projection_textures/spotprojection_11_flashlight_df"
	end
	
	self._g_light = self._unit:get_object(Idstring("g_light"))
	self._light = World:create_light("spot|specular|plane_projection", texture)
	self._light_multiplier = is_haunted and 2 or 1
	self._current_light_multiplier = is_haunted and 2 or 1

	self._light:set_spot_angle_end(40)
	self._light:set_far_range(is_haunted and 10000 or 2000)
	self._light:set_multiplier(self._current_light_multiplier)
	self._light:link(self._a_flashlight_obj)
	self._light:set_rotation(Rotation(self._a_flashlight_obj:rotation():z(), -self._a_flashlight_obj:rotation():x(), -self._a_flashlight_obj:rotation():y()))
	self._light:set_enable(false)

	self._light_effect = World:effect_manager():spawn({
		force_synch = true,
		effect = Idstring(effect_path),
		parent = self._a_flashlight_obj
	})

	World:effect_manager():set_hidden(self._light_effect, true)
end

function WeaponFlashLight:is_haunted()
	local level_id = Global.level_data and Global.level_data.level_id

	if level_id and level_id == "haunted" then
		self._haunted_house = true
		return
	end
	
	local job_id = managers.job and managers.job:current_job_id()
	local tweak = job_id and tweak_data.narrative.jobs[job_id]

	return tweak and tweak.is_halloween_level
end

function WeaponFlashLight:update_flicker_safehouse_nightmare(t, dt)
	if managers.groupai:state()._hunt_mode or managers.groupai:state()._assault_mode then
		if self._flicker_off_t then
			if self._flicker_off_t < t then
				self._flicker_off_t = nil
				World:effect_manager():set_hidden(self._light_effect, false)
			end
		elseif math.random() > 0.9 then
			self._flicker_off_t = t + math.lerp(0.01, 0.05, math.random())
			self._current_light_multiplier = 0
			World:effect_manager():set_hidden(self._light_effect, true)
		else
			self._current_light_multiplier = math.clamp(self._light_multiplier + (math.rand(40) - 20) * dt, 0, 5)
		end
	elseif self._current_light_multiplier ~= self._light_multiplier then
		local lerp = math.clamp(1 - dt, 0, 1)
		self._current_light_multiplier = math.lerp(self._light_multiplier, self._current_light_multiplier, lerp)
	end
	
	self._light:set_multiplier(self._current_light_multiplier)
end

local mvec1 = Vector3()
local mrot1 = Rotation()
local mrot2 = Rotation()
WeaponFlashLight.HALLOWEEN_FLICKER = 1
WeaponFlashLight.HALLOWEEN_LAUGHTER = 2
WeaponFlashLight.HALLOWEEN_FROZEN = 3
WeaponFlashLight.HALLOWEEN_SPOOC = 4
WeaponFlashLight.HALLOWEEN_WARP = 5

function WeaponFlashLight:update(unit, t, dt)
	mrotation.set_xyz(mrot1, self._a_flashlight_obj:rotation():z(), -self._a_flashlight_obj:rotation():x(), -self._a_flashlight_obj:rotation():y())

	if not self._is_haunted then
		self._light:link(self._a_flashlight_obj)
		self._light:set_rotation(mrot1)
		
		if self._haunted_house then
			self:update_flicker_safehouse_nightmare(t, dt)
		end
		
		return
	end

	t = Application:time()

	self:update_flicker(t, dt)
	self:update_laughter(t, dt)
	self:update_frozen(t, dt)

	if not self._frozen_t then
		self._light_speed = self._light_speed or 1
		self._light_speed = math.step(self._light_speed, 1, dt * (math.random(4) + 2))
		self._light_rotation = (self._light_rotation or 0) + dt * -50 * self._light_speed

		mrotation.set_yaw_pitch_roll(mrot2, self._light_rotation, mrotation.pitch(mrot2), mrotation.roll(mrot2))
		mrotation.multiply(mrot1, mrot2)
		self._light:link(self._a_flashlight_obj)
		self._light:set_rotation(mrot1)
	end

	if not self._kittens_timer then
		self._kittens_timer = t + 10
	end

	if self._kittens_timer < t then
		if math.rand(1) < 0.75 then
			self:run_net_event(self.HALLOWEEN_FLICKER)

			self._kittens_timer = t + math.random(10) + 5
		elseif math.rand(1) < 0.35 then
			self:run_net_event(self.HALLOWEEN_WARP)

			self._kittens_timer = t + math.random(12) + 3
		elseif math.rand(1) < 0.3 then
			self:run_net_event(self.HALLOWEEN_FROZEN)

			self._kittens_timer = t + math.random(20) + 30
		elseif math.rand(1) < 0.25 then
			self:run_net_event(self.HALLOWEEN_LAUGHTER)

			self._kittens_timer = t + math.random(5) + 8
		elseif math.rand(1) < 0.15 then
			self:run_net_event(self.HALLOWEEN_SPOOC)

			self._kittens_timer = t + math.random(2) + 3
		else
			self._kittens_timer = t + math.random(5) + 3
		end
	end
end