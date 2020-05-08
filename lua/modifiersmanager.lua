--CREDIT: OFFYEROCKER
local level = Global.level_data and Global.level_data.level_id
local diff_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)				

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
else
	replacement_table = {}	--bullshitting this 
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