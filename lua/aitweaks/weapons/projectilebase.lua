function ProjectileBase:destroy(...)
	ProjectileBase.super.destroy(self, ...)

	if self._ignore_units then
		local destroy_key = self._ignore_destroy_listener_key

		for _, ig_unit in pairs(self._ignore_units) do
			if alive(ig_unit) then
				local has_destroy_listener = nil
				local listener_class = ig_unit:base()

				if listener_class and listener_class.add_destroy_listener then
					has_destroy_listener = true
				else
					listener_class = ig_unit:unit_data()

					if listener_class and listener_class.add_destroy_listener then
						has_destroy_listener = true
					end
				end

				if has_destroy_listener then
					listener_class:remove_destroy_listener(destroy_key)
				end
			end
		end

		self._ignore_units = nil
	end

	if alive(self._thrower_unit) then
		local has_destroy_listener = nil
		local listener_class = self._thrower_unit:base()

		if listener_class and listener_class.add_destroy_listener then
			has_destroy_listener = true
		else
			listener_class = self._thrower_unit:unit_data()

			if listener_class and listener_class.add_destroy_listener then
				has_destroy_listener = true
			end
		end

		if has_destroy_listener then
			listener_class:remove_destroy_listener(self._ignore_destroy_listener_key)
		end

		self._thrower_unit = nil
	end

	self:remove_trail_effect()
end