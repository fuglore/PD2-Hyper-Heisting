function CopSound:chk_voice_prefix()
	if self._prefix then
		return self._prefix
	end
end

function CopSound:init(unit)
	self._unit = unit
	self._speak_expire_t = 0
	local char_tweak = tweak_data.character[unit:base()._tweak_table]

	self:set_voice_prefix(nil)

	local nr_variations = char_tweak.speech_prefix_count
	self._prefix = (char_tweak.speech_prefix_p1 or "") .. (nr_variations and tostring(math.random(nr_variations)) or "") .. (char_tweak.speech_prefix_p2 or "") .. "_"
	
	if self._unit:name() == Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_scar/ene_murky_heavy_scar") or self._unit:name() == Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_city_3/ene_zeal_city_3") then
		self._prefix = ("l1d") .. "_"
	end
	
	if self._unit:name() == Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_r870/ene_murky_heavy_r870") then
		self._prefix = ("l3d") .. "_"
	end
	
	if char_tweak.speech_prefix_p1 and char_tweak.speech_prefix_p1 == "r" then
		self._russian = true
	end
	
	if self._prefix == "f11n_" or char_tweak.speech_prefix_p1 and char_tweak.speech_prefix_p1 == "f" then
		self._fem = true
	end
		
	if self._unit:base():char_tweak().speech_prefix_count ~= nil then
		self._randomizedvcset = true
	end
		
	if self._prefix == "l1d_" or self._prefix == "l2d_" or self._prefix == "l3d_" or self._prefix == "l4d_" or self._prefix == "l5d_" or char_tweak.speech_prefix_p2 and char_tweak.speech_prefix_p2 == "d" then
		self._radiovc = true
	end

	if self._unit:base():char_tweak().spawn_sound_event then
		self._unit:sound():play(self._unit:base():char_tweak().spawn_sound_event, nil, nil)
	end

	unit:base():post_init()
end

function CopSound:destroy(unit)
	if alive(unit) and unit:base() then
		unit:base():pre_destroy(unit)
	end
end

function CopSound:set_voice_prefix(index)
	local char_tweak = tweak_data.character[self._unit:base()._tweak_table]
	local nr_variations = char_tweak.speech_prefix_count

	if index and (index < 1 or nr_variations < index) then
		debug_pause_unit(self._unit, "[CopSound:set_voice_prefix] Invalid prefix index:", index, ". nr_variations:", nr_variations)
	end

	self._prefix = (char_tweak.speech_prefix_p1 or "") .. (nr_variations and tostring(index or math.random(nr_variations)) or "") .. (char_tweak.speech_prefix_p2 or "") .. "_"
	
	if char_tweak.speech_prefix_p1 and char_tweak.speech_prefix_p1 == "r" then
		self._russian = true
	end
	
	if char_tweak.speech_prefix_p1 and char_tweak.speech_prefix_p1 == "f" then
		self._fem = true
	end
	
	if self._unit:base():char_tweak().speech_prefix_count ~= nil then
		self._randomizedvcset = true
	end
	
	if char_tweak.speech_prefix_p2 and char_tweak.speech_prefix_p2 == "d" then
		self._radiovc = true
	end
	
end

Hooks:PostHook(CopSound, "say", "shit_say", function(self, sound_name, sync, skip_prefix, important, callback)

	if sound_name == "hos_shield_identification" or sound_name == "shield_identification" then
		skip_prefix = true
	end
	
	local full_sound = nil
	
	if self._prefix == "l5d_" then
		if sound_name == "c01" or sound_name == "att" then
			sound_name = "g90"
		elseif sound_name == "rrl" then
			sound_name = "pus"
		elseif sound_name == "t01" then
			sound_name = "prm"
		elseif sound_name == "h01" then
			sound_name = "h10"
		end
	end
	
	if self._prefix == "l3d_" then
		if sound_name == "burnhurt" then
			full_sound = "l1d_burnhurt"
		end
		if sound_name == "burndeath" then
			full_sound = "l1d_burndeath"
		end
	end
	
	local fixed_sound = nil
	
	if self._prefix == "l1n_" or self._prefix == "l2n_" or self._prefix == "l3n_" or self._prefix == "l4n_" or not self._radiovc and self._randomizedvcset then
		if sound_name == "x02a_any_3p" then
			sound_name = "x01a_any_3p"
			--log("help")
			fixed_sound = true
		elseif sound_name == "x01a_any_3p" and not fixed_sound and not self._prefix == "l4n_" then
			sound_name = "x02a_any_3p"
			--log("fuckinghell")
		end
	end
		
	
	if self._last_speech then
		self._last_speech:stop()
	end
	
	local faction = tweak_data.levels:get_ai_group_type()
	
	if self._unit:base():has_tag("special") then
		if sound_name == "x02a_any_3p" then
			if self._unit:base():has_tag("spooc") then
				if faction == "russia" then
					full_sound = "rclk_x02a_any_3p"
				else
					full_sound = "clk_x02a_any_3p"
				end
			end
			
			if self._unit:base():has_tag("taser") then
				if faction == "russia" then
					full_sound = "rtsr_x02a_any_3p"
				else
					full_sound = "tsr_x02a_any_3p"
				end
			end
			
			if self._unit:base():has_tag("tank") then
				full_sound = "bdz_x02a_any_3p"
			end
			
			if self._unit:base():has_tag("medic") then
				full_sound = "mdc_x02a_any_3p"
			end
		end
		
		if sound_name == "x01a_any_3p" then
			if self._unit:base():has_tag("spooc") then
				if faction == "russia" then
					full_sound = "rclk_x01a_any_3p" --weird he has hurt noises but the regular cloaker doesnt
				else
					full_sound = full_sound
				end
			end
			if self._unit:base():has_tag("taser") then
				if faction == "russia" then
					full_sound = "rtsr_x01a_any_3p"
				else
					full_sound = "tsr_x01a_any_3p"
				end
			end
			if self._unit:base():has_tag("tank") then
				full_sound = "bdz_x01a_any_3p"
			end
			if self._unit:base():has_tag("medic") then
				full_sound = "mdc_x01a_any_3p"
			end
		end
	end
	
	if self._prefix == "l1d_" or self._prefix == "l2d_" or self._prefix == "l3d_" or self._prefix == "l4d_" or self._prefix == "l5d_" or self._radiovc and self._randomizedvcset then
		if sound_name == "x02a_any_3p" then
			full_sound = "shd_x02a_any_3p_01"
		end
	end
	
	if self._prefix == "fl1n_" or self._fem then
        if sound_name == "x02a_any_3p" then
            full_sound = "fl1n_x01a_any_3p_01"
        end
    end
        
    if self._prefix == "r1n_" or self._prefix == "r2n_" or self._prefix == "r3n_" or self._prefix == "r4n_" or self._russian then
        if sound_name == "x02a_any_3p" then
            full_sound = "l2n_x01a_any_3p"
        elseif sound_name == "x01a_any_3p" then
			full_sound = "l2n_x02a_any_3p"
        end
    end   
	
	if not full_sound then
		if skip_prefix then
			full_sound = sound_name
		else
			full_sound = self._prefix .. sound_name
		end
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
end)
