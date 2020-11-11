local old_init = CopBase.init

function CopBase:init(unit)
	local diff_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)
	local highdiff_c45_units = {
		Idstring("units/pd2_mod_psc/characters/ene_murky_fbigod_c45/ene_murky_fbigod_c45"),
		Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_fbigod_c45/ene_zeal_fbigod_c45"),		
		Idstring("units/pd2_dlc_bex/characters/ene_bex_ninja_c45/ene_bex_ninja_c45"),	
		Idstring("units/pd2_dlc_mad/characters/ene_akan_hyper_fbininja_c45/ene_akan_hyper_fbininja_c45"),
		Idstring("units/pd2_dlc_hvh/characters/ene_fbigod_hvh_c45/ene_fbigod_hvh_c45"),
		Idstring("units/pd2_dlc_hvh/characters/ene_fbi_hvh_1/ene_fbi_hvh_1"),	
		Idstring("units/payday2/characters/ene_fbi_1/ene_fbi_1"),
		Idstring("units/pd2_mod_ftsu/characters/ene_gensec_fbigod_c45/ene_gensec_fbigod_c45")	
		
	}
	
	if diff_index >= 6 then
		for _, pistoleer in ipairs(highdiff_c45_units) do
			if unit:name() == pistoleer then
                -- log(self._tweak_table)                			
				self._tweak_table = "fbi_xc45"
			end
		end
	end

	self._char_tweak = tweak_data.character[self._tweak_table]
	
	if unit:name() == Idstring("units/pd2_mod_psc/characters/ene_murky_punk_moss/ene_murky_punk_moss") then
		self._voidrage = true
	end

	self.my_voice = nil
	self.voice_length = 0
	self.voice_start_time = 0
	self:play_voiceline(nil, nil)
	
	old_init(self, unit)
end

function CopBase:pre_destroy(unit)
	if alive(self._headwear_unit) then
		self._headwear_unit:set_slot(0)
	end
	
	unit:character_damage():kill_punk_visual_effect()
	unit:brain():pre_destroy(unit)
	self._ext_movement:pre_destroy()
	self._unit:inventory():pre_destroy()
	UnitBase.pre_destroy(self, unit)
end

function CopBase:default_weapon_name()
	local default_weapon_id = self._default_weapon_id
	local weap_ids = tweak_data.character.weap_ids
	local diff_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)
	local faction = tweak_data.levels:get_ai_group_type()
	local level = Global.level_data and Global.level_data.level_id
	
	--available vanilla weapons, using their in-game names to avoid confusion since I'm planning to post this in the WIP thread regarding incorrect weapons in vanilla
	local suppressed_bernetti = Idstring("units/payday2/weapons/wpn_npc_beretta92/wpn_npc_beretta92")
	local crosskill_chimano = Idstring("units/payday2/weapons/wpn_npc_c45/wpn_npc_c45")
	local bronco = Idstring("units/payday2/weapons/wpn_npc_raging_bull/wpn_npc_raging_bull")
	local car4 = Idstring("units/payday2/weapons/wpn_npc_m4/wpn_npc_m4")
	local yellow_car4 = Idstring("units/payday2/weapons/wpn_npc_m4_yellow/wpn_npc_m4_yellow")
	local ak762 = Idstring("units/payday2/weapons/wpn_npc_ak47/wpn_npc_ak47")
	local reinfeld = Idstring("units/payday2/weapons/wpn_npc_r870/wpn_npc_r870")
	local sawn_off_mosconi = Idstring("units/payday2/weapons/wpn_npc_sawnoff_shotgun/wpn_npc_sawnoff_shotgun")
	local compact5 = Idstring("units/payday2/weapons/wpn_npc_mp5/wpn_npc_mp5")
	local suppressed_compact5 = Idstring("units/payday2/weapons/wpn_npc_mp5_tactical/wpn_npc_mp5_tactical")
	local cmp = Idstring("units/payday2/weapons/wpn_npc_smg_mp9/wpn_npc_smg_mp9")
	local mark10 = Idstring("units/payday2/weapons/wpn_npc_mac11/wpn_npc_mac11")
	local sniper_gewehr = Idstring("units/payday2/weapons/wpn_npc_sniper/wpn_npc_sniper")
	local izhma = Idstring("units/payday2/weapons/wpn_npc_saiga/wpn_npc_saiga")
	local ksp = Idstring("units/payday2/weapons/wpn_npc_lmg_m249/wpn_npc_lmg_m249")
	local m1014 = Idstring("units/payday2/weapons/wpn_npc_benelli/wpn_npc_benelli")
	local jp36 = Idstring("units/payday2/weapons/wpn_npc_g36/wpn_npc_g36")
	local jackal = Idstring("units/payday2/weapons/wpn_npc_ump/wpn_npc_ump")
	local eagle_heavy = Idstring("units/payday2/weapons/wpn_npc_scar_murkywater/wpn_npc_scar_murkywater")
	local rpk = Idstring("units/pd2_dlc_mad/weapons/wpn_npc_rpk/wpn_npc_rpk")
	local grom = Idstring("units/pd2_dlc_mad/weapons/wpn_npc_svd/wpn_npc_svd")
	local suppressed_krinkov = Idstring("units/pd2_dlc_mad/weapons/wpn_npc_akmsu/wpn_npc_akmsu")
	local valkyria = Idstring("units/pd2_dlc_mad/weapons/wpn_npc_asval/wpn_npc_asval")
	local heather = Idstring("units/pd2_dlc_mad/weapons/wpn_npc_sr2/wpn_npc_sr2")
	local ak762_akan = Idstring("units/pd2_dlc_mad/weapons/wpn_npc_ak47/wpn_npc_ak47")
	local crosskill_chimano_akimbo = Idstring("units/payday2/weapons/wpn_npc_c45/wpn_npc_x_c45")		
	local little_friend = Idstring("units/pd2_dlc_chico/weapons/wpn_npc_sg417/wpn_npc_sg417")
	local suppressed_grom = Idstring("units/pd2_dlc_spa/weapons/wpn_npc_svd_silenced/wpn_npc_svd_silenced")
	local vulcan_minigun = Idstring("units/pd2_dlc_drm/weapons/wpn_npc_mini/wpn_npc_mini")
	local zeal_gewehr = Idstring("units/pd2_dlc_drm/weapons/wpn_npc_heavy_zeal_sniper/wpn_npc_heavy_zeal_sniper")

	--HH npc custom weapons; this is by no means all of them, only the ones that were already here
	local commando_553 = Idstring("units/payday2/weapons/wpn_npc_s552/wpn_npc_s552")
	local kmtac = Idstring("units/pd2_dlc_gitgud/weapons/wpn_npc_kmtac/wpn_npc_kmtac")			
	local kmtac_akimbo = Idstring("units/pd2_dlc_gitgud/weapons/wpn_npc_kmtac/wpn_npc_x_kmtac")		
	local white_streak_akimbo = Idstring("units/pd2_dlc_mad/weapons/wpn_npc_pl14/wpn_npc_x_pl14")
	local crosskill_45_akimbo = Idstring("units/payday2/weapons/wpn_npc_xkill/wpn_npc_x_xkill")

	local unit_name = self._unit:name()
	
	local give_m4 = unit_name == Idstring("units/payday2/characters/ene_fbi_office_2/ene_fbi_office_2") 
	or unit_name == Idstring("units/payday2/characters/ene_fbi_female_2/ene_fbi_female_2")
	or unit_name == Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale/ene_swat_policia_federale")
	or unit_name == Idstring("units/payday2/characters/ene_swat_1/ene_swat_1")
	or unit_name == Idstring("units/pd2_dlc_hvh/characters/ene_swat_hvh_1/ene_swat_hvh_1")
	or unit_name == Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_medic/ene_bulldozer_medic")
	or unit_name == Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_medic_policia_federale/ene_swat_dozer_medic_policia_federale")
	
	local want_saiga = unit_name == Idstring("units/payday2/characters/ene_fbi_boss_1/ene_fbi_boss_1")

	local give_cc_x2 = unit_name == Idstring("units/payday2/characters/ene_fbi_female_4/ene_fbi_female_4")
		
	local give_m249 = unit_name == Idstring("units/payday2/characters/npc_old_hoxton_prisonsuit_2/npc_old_hoxton_prisonsuit_2")
	
	local give_beretta = unit_name == Idstring("units/payday2/characters/npc_old_hoxton_prisonsuit_1/npc_old_hoxton_prisonsuit_1")
	
	--groups of units to modify
	local mosconi_punks = unit_name == Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_r870/ene_akan_cs_cop_r870") 
    or unit_name == Idstring("units/payday2/characters/ene_security_3/ene_security_3") 
    or unit_name == Idstring("units/payday2/characters/ene_security_7/ene_security_7") 
    or unit_name == Idstring("units/pd2_dlc_bex/characters/ene_bex_security_02/ene_bex_security_02") 
    or unit_name == Idstring("units/pd2_dlc_bex/characters/ene_bex_security_suit_02/ene_bex_security_suit_02") 
    or unit_name == Idstring("units/payday2/characters/ene_gang_mexican_2/ene_gang_mexican_2")
    or unit_name == Idstring("units/payday2/characters/ene_gang_russian_3/ene_gang_russian_3")
    or unit_name == Idstring("units/payday2/characters/ene_gang_black_2/ene_gang_black_2")
    or unit_name == Idstring("units/pd2_dlc_friend/characters/ene_bolivian_thug_outdoor_01/ene_bolivian_thug_outdoor_01")
    or unit_name == Idstring("units/payday2/characters/ene_biker_2/ene_biker_2")
    or unit_name == Idstring("units/pd2_dlc_fex/characters/ene_guard_dog_mask/ene_guard_dog_mask")
	
	local mp5_punks = unit_name == Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_4/ene_cop_hvh_4")
    or unit_name == Idstring("units/payday2/characters/ene_security_6/ene_security_6") 
    or unit_name == Idstring("units/payday2/characters/ene_cop_4/ene_cop_4")
    or unit_name == Idstring("units/payday2/characters/ene_fbi_office_4/ene_fbi_office_4")
    or unit_name == Idstring("units/pd2_dlc_fex/characters/ene_guard_owl_mask/ene_guard_owl_mask")
	
	local bronco_punks = unit_name == Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_ak47_ass/ene_akan_cs_cop_ak47_ass")
    or unit_name == Idstring("units/payday2/characters/ene_security_1/ene_security_1") 
    or unit_name == Idstring("units/payday2/characters/ene_security_5/ene_security_5") 
    or unit_name == Idstring("units/pd2_dlc_bex/characters/ene_bex_security_01/ene_bex_security_01") 
    or unit_name == Idstring("units/pd2_dlc_bex/characters/ene_bex_security_suit_01/ene_bex_security_suit_01") 
    or unit_name == Idstring("units/payday2/characters/ene_gang_mexican_4/ene_gang_mexican_4") 
    or unit_name == Idstring("units/payday2/characters/ene_gang_russian_2/ene_gang_russian_2")
    or unit_name == Idstring("units/payday2/characters/ene_gang_black_4/ene_gang_black_4")
    or unit_name == Idstring("units/pd2_dlc_fex/characters/ene_guard_serpent_mask/ene_guard_serpent_mask")
	
	local give_r870 = unit_name == Idstring("units/payday2/characters/ene_security_8/ene_security_8") 
	or unit_name == Idstring("units/payday2/characters/ene_fbi_office_3/ene_fbi_office_3") 
	or unit_name == Idstring("units/payday2/characters/ene_fbi_female_3/ene_fbi_female_3")
	
	local zombie_taser = unit_name == Idstring("units/pd2_dlc_hvh/characters/ene_tazer_hvh_1/ene_tazer_hvh_1")
	
	local butcher_shit = unit_name == Idstring("units/pd2_dlc_wwh/characters/ene_male_crew_02/ene_male_crew_02")

	local give_jackal = unit_name == Idstring("units/pd2_dlc_wwh/characters/ene_captain/ene_captain")
	
	local give_benelli = unit_name == Idstring("units/pd2_dlc_wwh/characters/ene_female_crew/ene_female_crew") 
	or unit_name == Idstring("units/payday2/characters/ene_city_heavy_r870/ene_city_heavy_r870")  

	local secrit_servis = unit_name == Idstring("units/payday2/characters/ene_secret_service_1/ene_secret_service_1") 
	or unit_name == Idstring("units/payday2/characters/ene_secret_service_2/ene_secret_service_2") 
	
	local gang_mackas = unit_name == Idstring("units/payday2/characters/ene_gang_mexican_1/ene_gang_mexican_1") 
	or unit_name == Idstring("units/payday2/characters/ene_gang_black_1/ene_gang_black_1") 
	or unit_name == Idstring("units/payday2/characters/ene_biker_1/ene_biker_1") 
	or unit_name == Idstring("units/payday2/characters/ene_gang_russian_4/ene_gang_russian_4") 
	or unit_name == Idstring("units/pd2_dlc_friend/characters/ene_bolivian_thug_outdoor_02/ene_bolivian_thug_outdoor_02") 		
	
	local gang_aks = unit_name == Idstring("units/payday2/characters/ene_gang_mexican_3/ene_gang_mexican_3") 
	or unit_name == Idstring("units/payday2/characters/ene_gang_black_3/ene_gang_black_3")
	or unit_name == Idstring("units/payday2/characters/ene_gang_russian_1/ene_gang_russian_1")
	or unit_name == Idstring("units/pd2_dlc_wwh/characters/ene_male_crew_01/ene_male_crew_01")
	
	local highdiff_c45_units = unit_name == Idstring("units/pd2_dlc_bex/characters/ene_bex_ninja_c45/ene_bex_ninja_c45")
	or unit_name == Idstring("units/pd2_dlc_hvh/characters/ene_fbigod_hvh_c45/ene_fbigod_hvh_c45")
	or unit_name == Idstring("units/pd2_dlc_hvh/characters/ene_fbi_hvh_1/ene_fbi_hvh_1")
	or unit_name == Idstring("units/payday2/characters/ene_fbi_1/ene_fbi_1")	
	or unit_name == Idstring("units/pd2_mod_ftsu/characters/ene_gensec_fbigod_c45/ene_gensec_fbigod_c45")
	
	--ninja stuff. im not touching these amazing names as they're only used on one unit each
	local professor_miller = unit_name == Idstring("units/pd2_mod_psc/characters/ene_murky_fbigod_c45/ene_murky_fbigod_c45")
	local vagrant = unit_name == Idstring("units/pd2_dlc_mad/characters/ene_akan_hyper_fbininja_c45/ene_akan_hyper_fbininja_c45")
	local crank_dat_soulja = unit_name == Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_fbigod_c45/ene_zeal_fbigod_c45")
	
	if highdiff_c45_units and diff_index >= 6 then 
		return crosskill_chimano_akimbo
		
	elseif professor_miller and diff_index >= 6 then 
		return crosskill_45_akimbo
		
	elseif vagrant and diff_index >= 6 then 
		return white_streak_akimbo
		
	elseif secrit_servis then 
		return kmtac		
		
	elseif gang_mackas then 
		return mark10	
		
	elseif gang_aks then 
		return ak762		
		
	elseif crank_dat_soulja then 
		return kmtac_akimbo		
		
	elseif zombie_taser then
		return yellow_car4

	elseif give_m4 then
		return car4
		
	elseif want_saiga and not level == "tag" then
		return izhma
		
	elseif give_r870 then
		return reinfeld
		
	elseif give_cc_x2 then
		return crosskill_chimano_akimbo

	elseif give_m249 then
		return ksp
		
	elseif give_beretta then
		return suppressed_bernetti

	elseif butcher_shit then
		return suppressed_compact5

	elseif give_jackal then
		return jackal

	elseif mosconi_punks then
		return sawn_off_mosconi

	elseif bronco_punks then
		return bronco

	elseif mp5_punks then
		return compact5

	elseif give_benelli then
		return m1014
	else
		for i_weap_id, weap_id in ipairs(weap_ids) do
			if default_weapon_id == weap_id then
				return tweak_data.character.weap_unit_names[i_weap_id]
			end
		end
	end
end

function CopBase:play_voiceline(buffer, force)
	if buffer then
		if force and self.my_voice and not self.my_voice:is_closed() then
			self.my_voice:stop()
			self.my_voice:close()
			self.my_voice = nil
			self.voice_length = 0
		end
		local _time = math.floor(TimerManager:game():time())
		if self.voice_length == 0 or self.voice_start_time < _time then
			if self.my_voice and not self.my_voice:is_closed() then
				self.my_voice:stop()
				self.my_voice:close()
				self.my_voice = nil
			end
			self.my_voice = XAudio.UnitSource:new(self._unit, buffer)
			self.voice_length = buffer:get_length()
			self.voice_start_time = _time + buffer:get_length()
		end
	end
end