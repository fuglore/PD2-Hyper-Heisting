core:module("UserManager")

Hooks:PostHook(GenericUserManager, "setup_setting_map", "hh_init", function(self)
	self:setup_setting(400, "hold_to_jump", false)
	self:setup_setting(401, "staticrecoil", false)
end)

Hooks:PostHook(GenericUserManager, "reset_controls_setting_map", "HH_reset_controls_setting_map", function(self)
	self:set_setting("hold_to_jump", self:get_default_setting("hold_to_jump"))
	self:set_setting("staticrecoil", self:get_default_setting("staticrecoil"))
end)

Hooks:PostHook(GenericUserManager, "sanitize_settings", "HH_sanitize_settings", function(self)
	local setting = self:get_setting("hold_to_jump")
	local setting_valid = setting == false or setting == true

	if not setting_valid then
		self:set_setting("hold_to_jump", false)
	end
	
	local setting = self:get_setting("staticrecoil")
	local setting_valid = setting == false or setting == true

	if not setting_valid then
		self:set_setting("staticrecoil", false)
	end
end)