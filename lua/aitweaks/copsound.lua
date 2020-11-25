function CopSound:init(unit)
	self._unit = unit
	self._chatter = {}
	self._speak_expire_t = 0
	unit:base():post_init()
	self._prefix = self:get_appropriate_unit_sound_prefix()
end

function CopSound:get_appropriate_unit_sound_prefix()
	local char_tweak = tweak_data.character[self._unit:base()._tweak_table]
	local speech_prefix1 = char_tweak.speech_prefix_p1 or ""
	local speech_prefix2 = char_tweak.speech_prefix_p2 or ""
	
	local l1d_units = {
		Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_city_3/ene_zeal_city_3"),
		Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_city_3/ene_zeal_city_3_husk")
	}	
	
	for _, name in ipairs(l1d_units) do
		if self._unit:name() == name then
			return "l1d_"
		end
	end

	local l4n_units = {
		Idstring("units/pd2_mod_psc/characters/ene_murky_light_ump/ene_murky_light_ump"),
		Idstring("units/pd2_mod_psc/characters/ene_murky_light_ump/ene_murky_light_ump_husk")
	}	
	
	for _, name in ipairs(l4n_units) do
		if self._unit:name() == name then
			return "l4n_"
		end
	end
	
	local l1n_units = {
		Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"),
		Idstring("units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle_husk")
	}	
	
	for _, name in ipairs(l1n_units) do
		if self._unit:name() == name then
			return "l1n_"
		end
	end	
	
	local l5d_units = {
		Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_scar/ene_murky_heavy_scar"),
		Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_scar/ene_murky_heavy_scar_husk")
	}	
	
	for _, name in ipairs(l5d_units) do
		if self._unit:name() == name then
			return "l5d_"
		end
	end	
	
	local l3n_units = {
		Idstring("units/pd2_mod_psc/characters/ene_murky_light_r870/ene_murky_light_r870"),
		Idstring("units/pd2_mod_psc/characters/ene_murky_light_r870/ene_murky_light_r870_husk")
	}	
	
	for _, name in ipairs(l3n_units) do
		if self._unit:name() == name then
			return "l3n_"
		end
	end		
	
	local l3d_units = {
		Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_r870/ene_murky_heavy_r870"),
		Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_r870/ene_murky_heavy_r870_husk")
	}	
	
	for _, name in ipairs(l3d_units) do
		if self._unit:name() == name then
			return "l3d_"
		end
	end	
	
	local low_diff_units = {
		Idstring("units/payday2/characters/ene_swat_1/ene_swat_1"),
		Idstring("units/payday2/characters/ene_swat_1/ene_swat_1_husk"),
		Idstring("units/payday2/characters/ene_swat_2/ene_swat_2"),
		Idstring("units/payday2/characters/ene_swat_2/ene_swat_2_husk"),
		Idstring("units/payday2/characters/ene_swat_3/ene_swat_3"),
		Idstring("units/payday2/characters/ene_swat_3/ene_swat_3_husk"),
		Idstring("units/payday2/characters/ene_swat_heavy_1/ene_swat_heavy_1"),
		Idstring("units/payday2/characters/ene_swat_heavy_1/ene_swat_heavy_1_husk"),
		Idstring("units/payday2/characters/ene_swat_heavy_r870/ene_swat_heavy_r870"),
		Idstring("units/payday2/characters/ene_swat_heavy_r870/ene_swat_heavy_r870_husk"),
		Idstring("units/payday2/characters/ene_fbi_heavy_1/ene_fbi_heavy_1"),
		Idstring("units/payday2/characters/ene_fbi_heavy_1/ene_fbi_heavy_1_husk"),
		Idstring("units/payday2/characters/ene_fbi_heavy_r870/ene_fbi_heavy_r870"),
		Idstring("units/payday2/characters/ene_fbi_heavy_r870/ene_fbi_heavy_r870_husk")
	}
	
	local nr_variations = char_tweak.speech_prefix_count or nil
	
	for _, name in ipairs(low_diff_units) do
		if self._unit:name() == name then
			nr_variations = 4
			speech_prefix2 = "n"
		end
	end
	
	local variation = ""
	
	if nr_variations then
		variation = tostring(math.random(nr_variations))
	end
	
	local prefix = speech_prefix1 .. variation .. speech_prefix2 .. "_"
	
	--log("prefix is " .. tostring(prefix) .. "!")
	
	return prefix
end

function CopSound:set_voice_prefix(index) -- this function can go punch a cactus
	self._prefix = self:get_appropriate_unit_sound_prefix()
end

function CopSound:chk_voice_prefix()
	if self._prefix then
		return self._prefix
	end
end	

function CopSound:say(sound_name, sync, skip_prefix, important, callback)
	local line_array = { c01 = "contact",
		c01x = "contact",
		burnhurt = "burnhurt",
		burndeath = "burndeath",
		rrl = "reload",
		gr1a = "spawn",
		gr1b = "spawn",
		gr1c = "spawn",
		gr1d = "spawn",
		gr2a = "spawn",
		gr2b = "spawn",
		gr2c = "spawn",
		gr2d = "spawn",
		a05 = "clear_stelf",
		a06 = "clear_stelf",
		e01 = "disabled_gear", --look into restoring this chatter in general
		e02 = "disabled_gear",
		e03 = "disabled_gear",
		e04 = "disabled_gear",
		e05 = "disabled_gear",
		e06 = "disabled_gear",
		i01 = "contact",
		i02 = "gogo",
		i03 = "kill",
		lk3a = "buddy_died",  
		lk3b = "cover_me",  --could use this to add calmer panic between assaults
		mov = "gogo",
		med = "buddy_died",
		amm = "buddy_died",
		ch1 = "trip_mines",--
		ch2 = "sentry",--
		ch3 = "ecm", --
		ch4 = "saw", -- could add these lines to our units
		t01 = "flank",
		pus = "gogo",
		g90 = "contact",
		civ = "hostage",
		bak = "ready",
		p01 = "hostage",
		p02 = "hostage",
		p03 = "gogo",
		m01 = "retreat",
		h01 = "rescue_civ",
		cr1 = "rescue_civ",
		rdy = "ready",
		r01 = "ready",
		clr = "clear",
		att = "gogo",
		a08 = "gogo",
		prm = "ready",
		pos = "ready",
		d01 = "ready",
		d02 = "ready",
		x01a_any_3p = "pain",
		x01a_any_3p_01 = "pain",
		x01a_any_3p_02 = "pain",
		x02a_any_3p = "death",
		x02a_any_3p_01 = "death",
		x02a_any_3p_02 = "death",
		hlp = "buddy_died",
		buddy_died = "buddy_died",
		s01x = "surrender",
		use_gas = "use_gas",
		spawn = "spawn",
		tasing = "tasing",
		heal = "heal",
		tsr_x02a_any_3p = "death",
		tsr_x01a_any_3p = "pain",
		tsr_post_tasing_taunt = "tasing",
		tsr_g90 = "contact",
		tsr_entrance = "gogo",
		tsr_c01 = "contact",
		bdz_c01 = "contact",
		bdz_entrance = "spawn",
		bdz_entrance_elite = "spawn",
		bdz_g90 = "gogo",
		bdz_post_kill_taunt = "gogo",
		bdz_visor_lost = "gogo",
		cloaker_taunt_after_assault = "kill",
		cloaker_taunt_during_assault = "kill",
		cpa_taunt_after_assault = "kill",
		cpa_taunt_during_assault = "kill",
		police_radio = "radio", -- doesnt work :<
		clk_x02a_any_3p = "death"
	}
	
	local line_to_check = line_array[sound_name]
	if self._unit:base():char_tweak()["custom_voicework"] then
		if line_to_check then
			local voicelines = _G.voiceline_framework.BufferedSounds[self._unit:base():char_tweak().custom_voicework]
			if voicelines and voicelines[line_to_check] then
				local line_to_use = voicelines[line_to_check][math.random(#voicelines[line_to_check])]
				self._unit:base():play_voiceline(line_to_use, important)
				return
			end
		end
	end

	if self._last_speech then
		self._last_speech:stop()
	end

	local full_sound = nil

	if not self._unit:base():char_tweak()["custom_voicework"] then
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

		local fixed_sound = nil
		
		if self._prefix == "l1n_" or self._prefix == "l2n_" or self._prefix == "l3n_" then
			if sound_name == "x02a_any_3p" then
				sound_name = "x01a_any_3p"
				fixed_sound = true
				--log("IM FUCKIN DEAD BRO")
			elseif sound_name == "x01a_any_3p" then
				sound_name = "x02a_any_3p"
				--log("OW MY BONES")
			end
		end
		
		if self._prefix == "l4n_" then
			if sound_name == "x02a_any_3p" then
				sound_name = "x01a_any_3p"
				fixed_sound = true
				--log("l4N IS FUCKIGN DEAD WTF NOOOO")
			elseif sound_name == "x01a_any_3p" then
				sound_name = "l1n_x02a_any_3p"
				--log("l4N BONE HURTY JUICE")
			end
		end
		
		if self._prefix == "l1d_" or self._prefix == "l2d_" or self._prefix == "l3d_" or self._prefix == "l4d_" or self._prefix == "l5d_" then
			if sound_name == "a05" or sound_name == "a06" then
				sound_name = "clr"
				--log("CLEAR!!!")
			end
		end

		local faction = tweak_data.levels:get_ai_group_type()

		if self._unit:base():has_tag("special") and not sound_name == "g90" and not sound_name == "c01" then --just making sure

			if sound_name == "x02a_any_3p" then
				if self._unit:base():has_tag("spooc") then
					if faction == "russia" then
						full_sound = "rclk_x02a_any_3p"
					elseif faction == "federales" then
						full_sound = "Mclk_x02a_any_3p"					
					else
						full_sound = "clk_x02a_any_3p"
					end
				end

				if self._unit:base():has_tag("taser") then
					if faction == "russia" then
						full_sound = "rtsr_x02a_any_3p"
					elseif faction == "federales" then
						full_sound = "mtsr_x02a_any_3p"						
					else
						full_sound = "tsr_x02a_any_3p"
					end
				end

				if self._unit:base():has_tag("tank") then
					full_sound = "bdz_x02a_any_3p"
				end

				if self._unit:base():has_tag("medic") then
					if faction == "federales" then
						full_sound = "mmdc_x02a_any_3p"
					else
						full_sound = "mdc_x02a_any_3p"
					end
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
					elseif faction == "federales" then
						full_sound = "mtsr_x01a_any_3p"
					else
						full_sound = "tsr_x01a_any_3p"
					end
				end
				if self._unit:base():has_tag("tank") then
					full_sound = "bdz_x01a_any_3p"
				end
				if self._unit:base():has_tag("medic") and not self._unit:base():has_tag("tank") then
					full_sound = "mdc_x01a_any_3p"
				end
			end
		end

		if self._prefix == "l2d_" then
			if sound_name == "x02a_any_3p" then
				full_sound = "l1d_x02a_any_3p"
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

		if self._prefix == "z1n_" or self._prefix == "z2n_" or self._prefix == "z3n_" or self._prefix == "z4n_" then
			if sound_name == "x02a_any_3p" then
				full_sound = "shd_x02a_any_3p_01"
			end

			if sound_name == "x01a_any_3p" then
				full_sound = "bdz_x01a_any_3p"
			end

			if sound_name ~= "x01a_any_3p" and sound_name ~= "x02a_any_3p" then
				sound_name = "g90"
			end
		end
			
		if self._prefix == "f1n_" then
			if sound_name == "x02a_any_3p" then
				full_sound = "f1n_x01a_any_3p_01"
			end
		end

		if self._prefix == "r1n_" or self._prefix == "r2n_" or self._prefix == "r3n_" or self._prefix == "r4n_" then
			if sound_name == "x02a_any_3p" then
				full_sound = "l2n_x01a_any_3p"
			elseif sound_name == "x01a_any_3p" then
				full_sound = "l2n_x02a_any_3p"
			end
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
end
