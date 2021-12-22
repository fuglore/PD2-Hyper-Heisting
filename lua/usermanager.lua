core:module("UserManager")

Hooks:PostHook(GenericUserManager, "init", "hh_init", function(self)
	if not Global.user_manager.setting_data_map["hold_to_jump"] then
		self:setup_setting("hold_to_jump", "hold_to_jump", "off")
	end
end)

Hooks:PostHook(GenericUserManager, "reset_controls_setting_map", "HH_reset_controls_setting_map", function(self)
	self:set_setting("hold_to_jump", self:get_default_setting("hold_to_jump"))
end)

Hooks:PostHook(GenericUserManager, "sanitize_settings", "HH_sanitize_settings", function(self)
	local setting = self:get_setting("hold_to_jump")
	local setting_valid = setting == "off" or setting == "on"

	if not setting_valid then
		self:set_setting("hold_to_jump", "off")
	end
end)