function FeedBackCameraShake:set_param(name, value)
	if name == "multiplier" then
		return
	end

	if name == "name" then
		return
	end

	if name == "amplitude" then
		local screenshake_mul = PD2THHSHIN.settings.screenshakemult
		value = value * screenshake_mul
	end

	if self._unit_camera then
		self._unit_camera:shaker():set_parameter(self._id, name, value)
	elseif alive(self._playing_camera) then
		self._playing_camera:set_parameter(self._id, name, value)
	end
end

function FeedBackCameraShake:play(extra_params)
	local params = managers.feedback:get_effect_table(self._name)[self._type]
	local name = extra_params.name or params.name
	self._multiplier = extra_params.multiplier or 1

	if self._unit_camera then
		self._id = self._unit_camera:play_shaker(name, params.amplitude or 1, params.frequency or 1, params.offset or 0)
	else
		local screenshake_mul = PD2THHSHIN.settings.screenshakemult
		params.amplitude = params.amplitude and params.amplitude * screenshake_mul or screenshake_mul
	
		self._playing_camera = alive(self._camera) and self._camera or managers.viewport:get_current_shaker()
		
		if self._playing_camera then
			self._id = self._playing_camera:play(name)

			if self._playing_camera:is_playing(self._id) then
				local t = {}

				mixin(t, params, self._params)

				t.name = nil

				for param, value in pairs(t) do
					self._playing_camera:set_parameter(self._id, param, value)
				end
			end
		end
	end
end