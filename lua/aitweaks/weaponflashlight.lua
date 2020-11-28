WeaponFlashLight = WeaponFlashLight or class(WeaponGadgetBase)
WeaponFlashLight.GADGET_TYPE = "flashlight"

function WeaponFlashLight:init(unit)
	WeaponFlashLight.super.init(self, unit)

	self._on_event = "gadget_flashlight_on"
	self._off_event = "gadget_flashlight_off"
	self._a_flashlight_obj = self._unit:get_object(Idstring("a_flashlight"))
	local is_haunted = self:is_haunted()
	self._g_light = self._unit:get_object(Idstring("g_light"))
	local texture = is_haunted and "units/lights/spot_light_projection_textures/spotprojection_22_flashlight_df" or "units/lights/pd2_hh_flashlight_proj/flashlight_player"
	self._light = World:create_light("spot|specular|plane_projection", texture)
	self._light_multiplier = is_haunted and 2 or 1
	self._current_light_multiplier = self._light_multiplier

	self._light:set_spot_angle_end(40)
	self._light:set_far_range(is_haunted and 10000 or 2000)
	self._light:set_multiplier(self._current_light_multiplier)
	self._light:link(self._a_flashlight_obj)
	self._light:set_rotation(Rotation(self._a_flashlight_obj:rotation():z(), -self._a_flashlight_obj:rotation():x(), -self._a_flashlight_obj:rotation():y()))
	self._light:set_enable(false)

	local effect_path = is_haunted and "effects/particles/weapons/flashlight_spooky/fp_flashlight" or "effects/particles/weapons/flashlight/fp_flashlight_multicolor"
	self._light_effect = World:effect_manager():spawn({
		force_synch = true,
		effect = Idstring(effect_path),
		parent = self._a_flashlight_obj
	})

	World:effect_manager():set_hidden(self._light_effect, true)
end