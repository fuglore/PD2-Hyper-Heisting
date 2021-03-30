function PlayerCamera:play_shaker(effect, amplitude, frequency, offset)
	if _G.IS_VR then
		return
	end
	
	local screenshake_mul = PD2THHSHIN.settings.screenshakemult
	
	amplitude = amplitude and amplitude * screenshake_mul or screenshake_mul

	return self._shaker:play(effect, amplitude or 1, frequency or 1, offset or 0)
end

function PlayerCamera:set_shaker_parameter(effect, parameter, value)
	if not self._shakers then
		return
	end

	if self._shakers[effect] then
		if parameter == "amplitude" then
			local screenshake_mul = PD2THHSHIN.settings.screenshakemult
			value = value * screenshake_mul
		end
		
		self._shaker:set_parameter(self._shakers[effect], parameter, value)
	end
end