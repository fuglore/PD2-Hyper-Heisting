Hooks:PostHook(ZipLine, "init", "lore_init", function(self, unit)
	if self._speed and self._speed < 1200 then
		self._speed = 1200
	end
end)

function ZipLine:set_speed(speed)
	if not speed then
		return
	end

	self._speed = speed > 1200 and speed or 1200

	self:_update_total_time()
end