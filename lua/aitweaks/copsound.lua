function CopSound:chk_voice_prefix()
	if self._prefix then
		return self._prefix
	end
end

function CopSound:init(unit)
	self._unit = unit
	self._speak_expire_t = 0
	local char_tweak = tweak_data.character[unit:base()._tweak_table]
	
	local tasers = {
		Idstring("units/pd2_dlc_bph/characters/ene_murkywater_tazer/ene_murkywater_tazer"),
		Idstring("units/pd2_dlc_hvh/characters/ene_tazer_hvh_1/ene_tazer_hvh_1"),
		Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_tazer_ak47_ass/ene_akan_cs_tazer_ak47_ass"),
		Idstring("units/payday2/characters/ene_tazer_1/ene_tazer_1"),
		Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_tazer_hh/ene_zeal_tazer_hh"),
		Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_tazer/ene_zeal_tazer")
	}
	local is_taser = nil
	
	for _, taser_name in ipairs(tasers) do
		if self._unit:name() == taser_name then
			is_taser = true
		end
	end
	
	local tanks = {
		Idstring("units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1"),
		Idstring("units/payday2/characters/ene_bulldozer_2/ene_bulldozer_2"),
		Idstring("units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3"),
		Idstring("units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1"),
		Idstring("units/payday2/characters/ene_bulldozer_2/ene_bulldozer_2"),
		Idstring("units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3"),
		Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_minigun_classic/ene_bulldozer_minigun_classic"),
		Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer/ene_zeal_bulldozer"),
		Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer_2/ene_zeal_bulldozer_2"),
		Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer_3/ene_zeal_bulldozer_3"),
		Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer/ene_zeal_bulldozer"),
		Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer_2/ene_zeal_bulldozer_2"),
		Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer_3/ene_zeal_bulldozer_3"),
		Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_medic/ene_bulldozer_medic"),
		Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_minigun/ene_bulldozer_minigun"),
		Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_r870/ene_akan_fbi_tank_r870"),
		Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_saiga/ene_akan_fbi_tank_saiga"),
		Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_rpk_lmg/ene_akan_fbi_tank_rpk_lmg"),
		Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_r870/ene_akan_fbi_tank_r870"),
		Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_saiga/ene_akan_fbi_tank_saiga"),
		Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_rpk_lmg/ene_akan_fbi_tank_rpk_lmg"),
		Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_1/ene_bulldozer_hvh_1"),
		Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_2/ene_bulldozer_hvh_2"),
		Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_3/ene_bulldozer_hvh_3"),
		Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_1/ene_bulldozer_hvh_1"),
		Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_2/ene_bulldozer_hvh_2"),
		Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_3/ene_bulldozer_hvh_3"),
		Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_2/ene_murkywater_bulldozer_2"),
		Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_3/ene_murkywater_bulldozer_3"),
		Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_4/ene_murkywater_bulldozer_4"),
		Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_2/ene_murkywater_bulldozer_2"),
		Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_3/ene_murkywater_bulldozer_3"),
		Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_4/ene_murkywater_bulldozer_4"),
		Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_1/ene_murkywater_bulldozer_1"),
		Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_medic/ene_murkywater_bulldozer_medic")
	}
	local is_tank = nil
	for _, tank_name in ipairs(tanks) do
		if self._unit:name() == tank_name then
			is_tank = true
		end
	end
	
	local l1d_units = {
		Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_city_3/ene_zeal_city_3"),
		Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_city_3/ene_zeal_city_3_husk"),
		Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_scar/ene_murky_heavy_scar"),
		Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_scar/ene_murky_heavy_scar_husk")
	}
	local is_l1d = nil
	for _, l1d_name in ipairs(l1d_units) do
		if self._unit:name() == l1d_name then
			is_l1d = true
		end
	end
	
	local l3d_units = {
		Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_r870/ene_murky_heavy_r870"),
		Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_r870/ene_murky_heavy_r870_husk")
	}
	local is_l3d = nil
	for _, l3d_name in ipairs(l3d_units) do
		if self._unit:name() == l3d_name then
			is_l3d = true
		end
	end

	self:set_voice_prefix(nil)

	local nr_variations = char_tweak.speech_prefix_count
	self._prefix = (char_tweak.speech_prefix_p1 or "") .. (nr_variations and tostring(math.random(nr_variations)) or "") .. (char_tweak.speech_prefix_p2 or "") .. "_"
	
	if self._unit:name() == Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_scar/ene_murky_heavy_scar") or self._unit:name() == Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_city_3/ene_zeal_city_3") or is_l1d then
		self._prefix = ("l1d") .. "_"
	end
	
	if self._unit:name() == Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_r870/ene_murky_heavy_r870") or is_l3d then
		self._prefix = ("l3d") .. "_"
	end
	
	local faction = tweak_data.levels:get_ai_group_type()
	
	if self._unit:name() == Idstring("units/payday2/characters/ene_medic_m4/ene_medic_m4") or self._unit:name() == Idstring("units/pd2_dlc_bph/characters/ene_murkywater_medic/ene_murkywater_medic") or self._unit:name() == Idstring("units/pd2_dlc_hvh/characters/ene_medic_hvh_m4/ene_medic_hvh_m4") or self._unit:name() == Idstring("units/pd2_dlc_drm/characters/ene_medic_heavy_m4/ene_medic_heavy_m4") or self._unit:name() == Idstring("units/payday2/characters/ene_medic_m4/ene_medic_m4_husk") or self._unit:name() == Idstring("units/pd2_dlc_bph/characters/ene_murkywater_medic/ene_murkywater_medic_husk") or self._unit:name() == Idstring("units/pd2_dlc_hvh/characters/ene_medic_hvh_m4/ene_medic_hvh_m4_husk") or self._unit:name() == Idstring("units/pd2_dlc_drm/characters/ene_medic_heavy_m4/ene_medic_heavy_m4_husk")then
		self._prefix = ("mdc") .. "_"
	end
	
	if self._unit:name() == Idstring("units/payday2/characters/ene_medic_r870/ene_medic_r870") or self._unit:name() == Idstring("units/pd2_dlc_bph/characters/ene_murkywater_medic/ene_murkywater_medic_r870") or self._unit:name() == Idstring("units/pd2_dlc_hvh/characters/ene_medic_hvh_r870/ene_medic_hvh_r870") or self._unit:name() == Idstring("units/pd2_dlc_drm/characters/ene_medic_heavy_r870/ene_medic_heavy_r870") or self._unit:name() == Idstring("units/payday2/characters/ene_medic_r870/ene_medic_r870_husk") or self._unit:name() == Idstring("units/pd2_dlc_bph/characters/ene_murkywater_medic/ene_murkywater_medic_r870_husk") or self._unit:name() == Idstring("units/pd2_dlc_hvh/characters/ene_medic_hvh_r870/ene_medic_hvh_r870_husk") or self._unit:name() == Idstring("units/pd2_dlc_drm/characters/ene_medic_heavy_r870/ene_medic_heavy_r870_husk") then
		self._prefix = ("mdc") .. "_"
	end
	
	if self._unit:name() == Idstring("units/pd2_dlc_mad/characters/ene_akan_medic_ak47_ass/ene_akan_medic_ak47_ass") or self._unit:name() == Idstring("units/pd2_dlc_mad/characters/ene_akan_medic_r870/ene_akan_medic_r870") or self._unit:name() == Idstring("units/pd2_dlc_mad/characters/ene_akan_medic_ak47_ass/ene_akan_medic_ak47_ass_husk") or self._unit:name() == Idstring("units/pd2_dlc_mad/characters/ene_akan_medic_r870/ene_akan_medic_r870_husk") then
		self._prefix = ("rmdc") .. "_"
	end
	
	if self._unit:base()._tweak_table == "tank" or self._unit:base()._tweak_table == "tank_mini" or self._unit:base()._tweak_table == "tank_medic" or self._unit:base()._tweak_table == "tank_ftsu" or is_tank then
		if faction == "russia" then
			self._prefix = ("rbdz") .. "_"
		else
			self._prefix = ("bdz") .. "_"
		end
	end
	
	if self._unit:base()._tweak_table == "taser" or is_taser then
		if faction == "russia" then
			self._prefix = ("rtsr") .. "_"
		else
			self._prefix = ("tsr") .. "_"
		end
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
	
	if self._unit:base():char_tweak().spawn_scream then
		self._unit:sound():say(self._unit:base():char_tweak().spawn_scream, true, nil, nil, nil)
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

	local tasers = {
		Idstring("units/pd2_dlc_bph/characters/ene_murkywater_tazer/ene_murkywater_tazer"),
		Idstring("units/pd2_dlc_hvh/characters/ene_tazer_hvh_1/ene_tazer_hvh_1"),
		Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_tazer_ak47_ass/ene_akan_cs_tazer_ak47_ass"),
		Idstring("units/payday2/characters/ene_tazer_1/ene_tazer_1"),
		Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_tazer_hh/ene_zeal_tazer_hh"),
		Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_tazer/ene_zeal_tazer")
	}
	local is_taser = nil
	
	for _, taser_name in ipairs(tasers) do
		if self._unit:name() == taser_name then
			is_taser = true
		end
	end
	
	local tanks = {
		Idstring("units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1"),
		Idstring("units/payday2/characters/ene_bulldozer_2/ene_bulldozer_2"),
		Idstring("units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3"),
		Idstring("units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1"),
		Idstring("units/payday2/characters/ene_bulldozer_2/ene_bulldozer_2"),
		Idstring("units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3"),
		Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_minigun_classic/ene_bulldozer_minigun_classic"),
		Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer/ene_zeal_bulldozer"),
		Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer_2/ene_zeal_bulldozer_2"),
		Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer_3/ene_zeal_bulldozer_3"),
		Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer/ene_zeal_bulldozer"),
		Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer_2/ene_zeal_bulldozer_2"),
		Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer_3/ene_zeal_bulldozer_3"),
		Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_medic/ene_bulldozer_medic"),
		Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_minigun/ene_bulldozer_minigun"),
		Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_r870/ene_akan_fbi_tank_r870"),
		Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_saiga/ene_akan_fbi_tank_saiga"),
		Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_rpk_lmg/ene_akan_fbi_tank_rpk_lmg"),
		Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_r870/ene_akan_fbi_tank_r870"),
		Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_saiga/ene_akan_fbi_tank_saiga"),
		Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_rpk_lmg/ene_akan_fbi_tank_rpk_lmg"),
		Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_1/ene_bulldozer_hvh_1"),
		Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_2/ene_bulldozer_hvh_2"),
		Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_3/ene_bulldozer_hvh_3"),
		Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_1/ene_bulldozer_hvh_1"),
		Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_2/ene_bulldozer_hvh_2"),
		Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_3/ene_bulldozer_hvh_3"),
		Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_2/ene_murkywater_bulldozer_2"),
		Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_3/ene_murkywater_bulldozer_3"),
		Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_4/ene_murkywater_bulldozer_4"),
		Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_2/ene_murkywater_bulldozer_2"),
		Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_3/ene_murkywater_bulldozer_3"),
		Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_4/ene_murkywater_bulldozer_4"),
		Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_1/ene_murkywater_bulldozer_1"),
		Idstring("units/pd2_dlc_bph/characters/ene_murkywater_bulldozer_medic/ene_murkywater_bulldozer_medic")
	}
	local is_tank = nil
	for _, tank_name in ipairs(tanks) do
		if self._unit:name() == tank_name then
			is_tank = true
		end
	end
	
	local l1d_units = {
		Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_city_3/ene_zeal_city_3"),
		Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_city_3/ene_zeal_city_3_husk"),
		Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_scar/ene_murky_heavy_scar"),
		Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_scar/ene_murky_heavy_scar_husk")
	}
	local is_l1d = nil
	for _, l1d_name in ipairs(l1d_units) do
		if self._unit:name() == l1d_name then
			is_l1d = true
		end
	end
	
	local l3d_units = {
		Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_r870/ene_murky_heavy_r870"),
		Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_r870/ene_murky_heavy_r870_husk")
	}
	local is_l3d = nil
	for _, l3d_name in ipairs(l3d_units) do
		if self._unit:name() == l3d_name then
			is_l3d = true
		end
	end
	
	local nr_variations = char_tweak.speech_prefix_count
	self._prefix = (char_tweak.speech_prefix_p1 or "") .. (nr_variations and tostring(math.random(nr_variations)) or "") .. (char_tweak.speech_prefix_p2 or "") .. "_"
	
	if self._unit:name() == Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_scar/ene_murky_heavy_scar") or self._unit:name() == Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_city_3/ene_zeal_city_3") or is_l1d then
		self._prefix = ("l1d") .. "_"
	end
	
	if self._unit:name() == Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_r870/ene_murky_heavy_r870") or is_l3d then
		self._prefix = ("l3d") .. "_"
	end
	
	local faction = tweak_data.levels:get_ai_group_type()
	
	if self._unit:name() == Idstring("units/payday2/characters/ene_medic_m4/ene_medic_m4") or self._unit:name() == Idstring("units/pd2_dlc_bph/characters/ene_murkywater_medic/ene_murkywater_medic") or self._unit:name() == Idstring("units/pd2_dlc_hvh/characters/ene_medic_hvh_m4/ene_medic_hvh_m4") or self._unit:name() == Idstring("units/pd2_dlc_drm/characters/ene_medic_heavy_m4/ene_medic_heavy_m4") or self._unit:name() == Idstring("units/payday2/characters/ene_medic_m4/ene_medic_m4_husk") or self._unit:name() == Idstring("units/pd2_dlc_bph/characters/ene_murkywater_medic/ene_murkywater_medic_husk") or self._unit:name() == Idstring("units/pd2_dlc_hvh/characters/ene_medic_hvh_m4/ene_medic_hvh_m4_husk") or self._unit:name() == Idstring("units/pd2_dlc_drm/characters/ene_medic_heavy_m4/ene_medic_heavy_m4_husk")then
		self._prefix = ("mdc") .. "_"
	end
	
	if self._unit:name() == Idstring("units/payday2/characters/ene_medic_r870/ene_medic_r870") or self._unit:name() == Idstring("units/pd2_dlc_bph/characters/ene_murkywater_medic/ene_murkywater_medic_r870") or self._unit:name() == Idstring("units/pd2_dlc_hvh/characters/ene_medic_hvh_r870/ene_medic_hvh_r870") or self._unit:name() == Idstring("units/pd2_dlc_drm/characters/ene_medic_heavy_r870/ene_medic_heavy_r870") or self._unit:name() == Idstring("units/payday2/characters/ene_medic_r870/ene_medic_r870_husk") or self._unit:name() == Idstring("units/pd2_dlc_bph/characters/ene_murkywater_medic/ene_murkywater_medic_r870_husk") or self._unit:name() == Idstring("units/pd2_dlc_hvh/characters/ene_medic_hvh_r870/ene_medic_hvh_r870_husk") or self._unit:name() == Idstring("units/pd2_dlc_drm/characters/ene_medic_heavy_r870/ene_medic_heavy_r870_husk") then
		self._prefix = ("mdc") .. "_"
	end
	
	if self._unit:name() == Idstring("units/pd2_dlc_mad/characters/ene_akan_medic_ak47_ass/ene_akan_medic_ak47_ass") or self._unit:name() == Idstring("units/pd2_dlc_mad/characters/ene_akan_medic_r870/ene_akan_medic_r870") or self._unit:name() == Idstring("units/pd2_dlc_mad/characters/ene_akan_medic_ak47_ass/ene_akan_medic_ak47_ass_husk") or self._unit:name() == Idstring("units/pd2_dlc_mad/characters/ene_akan_medic_r870/ene_akan_medic_r870_husk") then
		self._prefix = ("rmdc") .. "_"
	end
	
	if self._unit:base()._tweak_table == "tank" or self._unit:base()._tweak_table == "tank_mini" or self._unit:base()._tweak_table == "tank_medic" or self._unit:base()._tweak_table == "tank_ftsu" or is_tank then
		if faction == "russia" then
			self._prefix = ("rbdz") .. "_"
		else
			self._prefix = ("bdz") .. "_"
		end
	end
	
	if self._unit:base()._tweak_table == "taser" or is_taser then
		if faction == "russia" then
			self._prefix = ("rtsr") .. "_"
		else
			self._prefix = ("tsr") .. "_"
		end
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
	
end

Hooks:PostHook(CopSound, "say", "hh_say", function(self, sound_name, sync, skip_prefix, important, callback)

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
	
	local fixed_sound = nil
	
	if self._prefix == "l1n_" or self._prefix == "l2n_" or self._prefix == "l3n_" or self._prefix == "l4n_" then
		if sound_name == "x02a_any_3p" then
			sound_name = "x01a_any_3p"
			--log("help")
			fixed_sound = true
		elseif sound_name == "x01a_any_3p" and not fixed_sound and not self._prefix == "l4n_" then
			sound_name = "x02a_any_3p"
			--log("fuckinghell")
		end
	end
	
	local faction = tweak_data.levels:get_ai_group_type()
	
	if self._prefix == "z1n_" or self._prefix == "z2n_" or self._prefix == "z3n_" or self._prefix == "z4n_" then
		if sound_name == "x02a_any_3p" then
			full_sound = "shd_x02a_any_3p_01"
		end
		
		if sound_name == "x01a_any_3p" then
			full_sound = "bdz_x01a_any_3p"
		end
		
		if sound_name ~= "x01a_any_3p" and sound_name ~= "x02a_any_3p" and not full_sound then
			sound_name = "g90"
		end
	end
	
	if self._unit:base():has_tag("special") and not sound_name == "g90" and not sound_name == "c01" then
	
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
	
	if self._prefix == "l3d_" then
		if sound_name == "burnhurt" then
			full_sound = "l1d_burnhurt"
		end
		if sound_name == "burndeath" then
			full_sound = "l1d_burndeath"
		end
	end
	
	--if self._prefix == "l1d_" or self._prefix == "l2d_" or self._prefix == "l3d_" or self._prefix == "l4d_" or self._prefix == "l5d_" then
		--if sound_name == "x02a_any_3p" then
			--full_sound = "shd_x02a_any_3p_01"
		--end
	--end
	
	if self._prefix == "fl1n_" then
        if sound_name == "x02a_any_3p" then
            full_sound = "fl1n_x01a_any_3p_01"
        end
    end
        
    if self._prefix == "r1n_" or self._prefix == "r2n_" or self._prefix == "r3n_" or self._prefix == "r4n_" then
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

end)