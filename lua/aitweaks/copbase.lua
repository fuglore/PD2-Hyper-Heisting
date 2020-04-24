local old_init = CopBase.init

function CopBase:init(unit)
	local diff_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)
	local DS_c45_units = {
		Idstring("units/pd2_mod_psc/characters/ene_murky_fbigod_c45/ene_murky_fbigod_c45"),
		Idstring("units/pd2_mod_psc/characters/ene_murky_fbigod_c45/ene_murky_fbigod_c45_husk"),
		Idstring("units/pd2_dlc_mad/characters/ene_akan_hyper_fbininja_c45/ene_akan_hyper_fbininja_c45"),
		Idstring("units/pd2_dlc_mad/characters/ene_akan_hyper_fbininja_c45/ene_akan_hyper_fbininja_c45_husk")
	}
	
	if diff_index == 8 then
		for _, pistoleer in ipairs(DS_c45_units) do
			if unit_name == pistoleer then
				self._tweak_table = "fbi_xc45"
			end
		end
	end

	self._char_tweak = tweak_data.character[self._tweak_table]
	
	if unit_name == Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_scar/ene_murky_heavy_scar") or unit_name == Idstring("units/pd2_mod_psc/characters/ene_murky_heavy_scar/ene_murky_heavy_scar_husk") then
		local tags = self:char_tweak().tags
		table.insert(tags, "twitchy")
	end
	
	if unit_name ~= Idstring("units/pd2_mod_psc/characters/ene_murky_punk_moss/ene_murky_punk_moss") and unit_name ~= Idstring("units/pd2_mod_psc/characters/ene_murky_punk_moss/ene_murky_punk_moss_husk") then
		if self._tweak_table == "cop" then
			local tags = self:char_tweak().tags
			table.insert(tags, "panicked")
		end
	end
	
	old_init(self, unit)
end


function CopBase:default_weapon_name()
	local default_weapon_id = self._default_weapon_id
	local weap_ids = tweak_data.character.weap_ids
	local diff_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)
	
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

	local commando_553 = Idstring("units/payday2/weapons/wpn_npc_s552/wpn_npc_s552")

	local unit_name = self._unit:name()
	
	local hoxout_m4s = unit_name == Idstring("units/payday2/characters/ene_fbi_office_2/ene_fbi_office_2") or unit_name == Idstring("units/payday2/characters/ene_fbi_office_2/ene_fbi_office_2_husk") or unit_name == Idstring("units/payday2/characters/ene_fbi_female_2/ene_fbi_female_2") or unit_name == Idstring("units/payday2/characters/ene_fbi_female_2/ene_fbi_female_2_husk")
	
	--groups of units to modify
	local mosconi_punks = unit_name == Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_r870/ene_akan_cs_cop_r870") or unit_name == Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_r870/ene_akan_cs_cop_r870_husk")
	
	local mp5_punks = unit_name == Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_4/ene_cop_hvh_4") or unit_name == Idstring("units/pd2_dlc_hvh/characters/ene_cop_hvh_4/ene_cop_hvh_4_husk")
	
	local bronco_punks = unit_name == Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_ak47_ass/ene_akan_cs_cop_ak47_ass") or unit_name == Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_cop_ak47_ass/ene_akan_cs_cop_ak47_ass_husk")
	
	local zombie_taser = unit_name == Idstring("units/pd2_dlc_hvh/characters/ene_tazer_hvh_1/ene_tazer_hvh_1") or unit_name == Idstring("units/pd2_dlc_hvh/characters/ene_tazer_hvh_1/ene_tazer_hvh_1_husk")
	
	local missing_r870_husk_case = unit_name == Idstring("units/payday2/characters/ene_swat_heavy_r870/ene_swat_heavy_r870_husk")
	
	local bex_swat = unit_name == Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale/ene_swat_policia_federale") or unit_name == Idstring("units/pd2_dlc_bex/characters/ene_swat_policia_federale/ene_swat_policia_federale_husk")
	
	local DS_c45_units = unit_name == Idstring("units/pd2_mod_psc/characters/ene_murky_fbigod_c45/ene_murky_fbigod_c45") or unit_name == Idstring("units/pd2_mod_psc/characters/ene_murky_fbigod_c45/ene_murky_fbigod_c45_husk") or unit_name == Idstring("units/pd2_dlc_mad/characters/ene_akan_hyper_fbininja_c45/ene_akan_hyper_fbininja_c45") or unit_name == Idstring("units/pd2_dlc_mad/characters/ene_akan_hyper_fbininja_c45/ene_akan_hyper_fbininja_c45_husk")
	
	if DS_c45_units then 
		return crosskill_chimano_akimbo
	elseif bex_swat then
		return car4
	elseif zombie_taser then
		return yellow_car4
	elseif hoxout_m4s then
		return car4
	elseif mosconi_punks then
		return sawn_off_mosconi
	elseif bronco_punks then
		return bronco
	elseif mp5_punks then
		return compact5
	elseif missing_r870_husk_case then
		return reinfeld
	else
		for i_weap_id, weap_id in ipairs(weap_ids) do
			if default_weapon_id == weap_id then
				return tweak_data.character.weap_unit_names[i_weap_id]
			end
		end
	end
end
