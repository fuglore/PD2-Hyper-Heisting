function CopSound:chk_voice_prefix()
	if self._prefix then
		return self._prefix
	end
end

function CopSound:say(sound_name, sync, skip_prefix, important, callback)
	local has_fixed_sound = nil
	
	if self._prefix == "l5d" then
		if sound_name == "c01" or sound_name == "att" then
			sound_name = "g90"
		elseif sound_name == "rrl" then
			sound_name = "pus"
		elseif sound_name == "t01" then
			sound_name = "prm"
		elseif sound_name == "h01" then
			sound_name = "h10"
		end
	elseif self._prefix == "l3d" then
		if sound_name == "burnhurt" or "burndeath" then
			sound_name = "x02a_any_3p"
		end
	elseif self._prefix == "l1n" or self._prefix == "l2n" or self._prefix == "l3n" then
		if sound_name == "x02a_any_3p" then
			sound_name = "x01a_any_3p"
			has_fixed_sound = true
			--log("help")
		elseif sound_name == "x01a_any_3p" and not has_fixed_sound then
			sound_name = "x02a_any_3p"
			--log("fuckinghell")
		end
	end
		
	
	if self._last_speech then
		self._last_speech:stop()
	end

	local full_sound = nil
	
	if skip_prefix then
		full_sound = sound_name
	else
		full_sound = self._prefix .. sound_name
	end

	local event_id = nil

	if type(full_sound) == "number" then
		event_id = full_sound
		full_sound = nil
	end

	if sync then
		event_id = event_id or SoundDevice:string_to_id(full_sound)

		self._unit:network():send("say", event_id)
	end

	self._last_speech = self:_play(full_sound or event_id)

	if not self._last_speech then
		return
	end

	self._speak_expire_t = TimerManager:game():time() + 2
end