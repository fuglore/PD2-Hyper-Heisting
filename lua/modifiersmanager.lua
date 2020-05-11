--CREDIT: OFFYEROCKER
local level = Global.level_data and Global.level_data.level_id
local difficulty = Global.game_settings and Global.game_settings.difficulty or "normal"
local diff_index = tweak_data:difficulty_to_index(difficulty)
local replacement_table = {}

if level == "spa" or level == "glace" or level == "brb" or level == "red2" or level == "run" or level == "flat" or level == "dinner" then
	replacement_table = {
		["units/payday2/characters/ene_cop_3/ene_cop_3"] = "units/pd2_mod_beatpricks/characters/ene_cop_3/ene_cop_3",
		["units/payday2/characters/ene_cop_2/ene_cop_2"] = "units/pd2_mod_beatpricks/characters/ene_cop_2/ene_cop_2",
		["units/payday2/characters/ene_cop_4/ene_cop_4"] = "units/pd2_mod_beatpricks/characters/ene_cop_4/ene_cop_4",
		["units/payday2/characters/ene_cop_1/ene_cop_1"] = "units/pd2_mod_beatpricks/characters/ene_cop_1/ene_cop_1"
	}
elseif level == "rvd1" or level == "rvd2" or level == "jolly" then
	replacement_table = {
		["units/payday2/characters/ene_cop_3/ene_cop_3"] = "units/pd2_dlc_rvd/characters/ene_la_cop_3/ene_la_cop_3",
		["units/payday2/characters/ene_cop_2/ene_cop_2"] = "units/pd2_dlc_rvd/characters/ene_la_cop_2/ene_la_cop_2",
		["units/payday2/characters/ene_cop_4/ene_cop_4"] = "units/pd2_dlc_rvd/characters/ene_la_cop_4/ene_la_cop_4",
		["units/payday2/characters/ene_cop_1/ene_cop_1"] = "units/pd2_dlc_rvd/characters/ene_la_cop_1/ene_la_cop_1"
	}
elseif level == "vit" and diff_index == 8 then
	replacement_table = {
		["units/pd2_mod_psc/characters/ene_murky_punk_moss/ene_murky_punk_moss"] = "units/pd2_dlc_gitgud/characters/ene_zeal_punk_moss/ene_zeal_punk_moss",
		["units/pd2_mod_psc/characters/ene_murky_punk_mp5/ene_murky_punk_mp5"] = "units/pd2_dlc_gitgud/characters/ene_zeal_punk_mp5/ene_zeal_punk_mp5",
		["units/pd2_mod_psc/characters/ene_murky_punk_bronco/ene_murky_punk_bronco"] = "units/pd2_dlc_gitgud/characters/ene_zeal_punk_bronco/ene_zeal_punk_bronco"
	}
elseif _G.BB or FullSpeedSwarm or Iter or _G.SC or _G.deathvox then
	replacement_table = {
		["units/payday2/characters/ene_swat_1/ene_swat_1"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/payday2/characters/ene_swat_2/ene_swat_2"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",	
		["units/payday2/characters/ene_swat_3/ene_swat_3"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",	
		["units/payday2/characters/ene_fbi_swat_1/ene_fbi_swat_1"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/payday2/characters/ene_fbi_heavy_1/ene_fbi_heavy_1"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/pd2_dlc_mad/characters/ene_akan_fbi_swat_ak47_ass/ene_akan_fbi_swat_ak47_ass"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_g36/ene_akan_fbi_heavy_g36"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_1/ene_fbi_swat_hvh_1"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_1/ene_fbi_heavy_hvh_1"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/pd2_mod_psc/characters/ene_murky_heavy_scar/ene_murky_heavy_scar"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/pd2_dlc_bex/characters/ene_swat_policia_federale_fbi/ene_swat_policia_federale_fbi"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale_fbi_r870_hh/ene_swat_heavy_policia_federale_fbi_r870_hh"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy_r870/ene_zeal_swat_heavy_r870"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",    
		["units/payday2/characters/ene_fbi_swat_3/ene_fbi_swat_3"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/payday2/characters/ene_fbi_swat_2/ene_fbi_swat_2"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/payday2/characters/ene_city_swat_1/ene_city_swat_1"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/payday2/characters/ene_city_swat_2/ene_city_swat_2"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/payday2/characters/ene_city_swat_3/ene_city_swat_3"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/pd2_dlc_gitgud/characters/ene_zeal_city_1/ene_zeal_city_1"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/pd2_dlc_gitgud/characters/ene_zeal_city_2/ene_zeal_city_2"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/pd2_dlc_gitgud/characters/ene_zeal_city_3/ene_zeal_city_3"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy_hh/ene_zeal_swat_heavy_hh"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/pd2_dlc_bex/characters/ene_swat_policia_federale_r870_hh/ene_swat_policia_federale_r870_hh"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/pd2_dlc_bex/characters/ene_swat_policia_federale_r870_hh/ene_swat_policia_federale_r870_hh"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/pd2_mod_psc/characters/ene_murky_NH_rifle/ene_murky_NH_rifle"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/pd2_mod_psc/characters/ene_murky_NH_rifle/ene_murky_NH_rifle"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/pd2_dlc_mad/characters/ene_akan_cs_heavy_ak47_ass/ene_akan_cs_heavy_ak47_ass"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/pd2_dlc_hvh/characters/ene_swat_heavy_hvh_1/ene_swat_heavy_hvh_1"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/payday2/characters/ene_city_heavy_r870/ene_city_heavy_r870"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/pd2_dlc_hvh/characters/ene_swat_heavy_hvh_r870/ene_swat_heavy_hvh_r870"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/pd2_mod_psc/characters/ene_murky_NH_r870/ene_murky_NH_r870"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun"
	}		
elseif InFmenu then
	 if InFmenu.settings.rainbowassault == true or InFmenu.settings.sanehp == true or InFmenu.settings.copmiss == true or InFmenu.settings.copfalloff == true or InFmenu.settings.skulldozersahoy == 2 or InFmenu.settings.skulldozersahoy == 3 then
		replacement_table = {
		["units/payday2/characters/ene_swat_1/ene_swat_1"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/payday2/characters/ene_swat_2/ene_swat_2"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",	
		["units/payday2/characters/ene_swat_3/ene_swat_3"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",	
		["units/payday2/characters/ene_fbi_swat_1/ene_fbi_swat_1"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/payday2/characters/ene_fbi_heavy_1/ene_fbi_heavy_1"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/pd2_dlc_mad/characters/ene_akan_fbi_swat_ak47_ass/ene_akan_fbi_swat_ak47_ass"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/pd2_dlc_mad/characters/ene_akan_fbi_heavy_g36/ene_akan_fbi_heavy_g36"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/pd2_dlc_hvh/characters/ene_fbi_swat_hvh_1/ene_fbi_swat_hvh_1"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/pd2_dlc_hvh/characters/ene_fbi_heavy_hvh_1/ene_fbi_heavy_hvh_1"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/pd2_mod_psc/characters/ene_murky_light_rifle/ene_murky_light_rifle"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/pd2_mod_psc/characters/ene_murky_heavy_scar/ene_murky_heavy_scar"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/pd2_dlc_bex/characters/ene_swat_policia_federale_fbi/ene_swat_policia_federale_fbi"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/pd2_dlc_bex/characters/ene_swat_heavy_policia_federale_fbi_r870_hh/ene_swat_heavy_policia_federale_fbi_r870_hh"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy_r870/ene_zeal_swat_heavy_r870"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",    
		["units/payday2/characters/ene_fbi_swat_3/ene_fbi_swat_3"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/payday2/characters/ene_fbi_swat_2/ene_fbi_swat_2"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/payday2/characters/ene_city_swat_1/ene_city_swat_1"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/payday2/characters/ene_city_swat_2/ene_city_swat_2"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/payday2/characters/ene_city_swat_3/ene_city_swat_3"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/pd2_dlc_gitgud/characters/ene_zeal_city_1/ene_zeal_city_1"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/pd2_dlc_gitgud/characters/ene_zeal_city_2/ene_zeal_city_2"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/pd2_dlc_gitgud/characters/ene_zeal_city_3/ene_zeal_city_3"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/pd2_dlc_gitgud/characters/ene_zeal_swat_heavy_hh/ene_zeal_swat_heavy_hh"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/pd2_dlc_bex/characters/ene_swat_policia_federale_r870_hh/ene_swat_policia_federale_r870_hh"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/pd2_dlc_bex/characters/ene_swat_policia_federale_r870_hh/ene_swat_policia_federale_r870_hh"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/pd2_mod_psc/characters/ene_murky_NH_rifle/ene_murky_NH_rifle"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/pd2_mod_psc/characters/ene_murky_NH_rifle/ene_murky_NH_rifle"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/pd2_dlc_mad/characters/ene_akan_cs_heavy_ak47_ass/ene_akan_cs_heavy_ak47_ass"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/pd2_dlc_hvh/characters/ene_swat_heavy_hvh_1/ene_swat_heavy_hvh_1"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/payday2/characters/ene_city_heavy_r870/ene_city_heavy_r870"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/pd2_dlc_hvh/characters/ene_swat_heavy_hvh_r870/ene_swat_heavy_hvh_r870"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun",
		["units/pd2_mod_psc/characters/ene_murky_NH_r870/ene_murky_NH_r870"] = "units/pd2_mod_epictroll/characters/ene_trolliam_calhoun/ene_trolliam_calhoun"
		}		
	end
end

local unit_table = {}

for k,v in pairs(replacement_table) do 
	unit_table[tostring(Idstring(k))] = Idstring(v)
end
replacement_table = nil 

local orig_modify = ModifiersManager.modify_value
function ModifiersManager:modify_value(id, value, ...)
	local result = orig_modify(self,id,value,...)
	value = tostring(value)
	if id == "GroupAIStateBesiege:SpawningUnit" then 
		return unit_table[value] or result 
	end
	return result
end