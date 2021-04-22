_G.PD2THHSHIN = PD2THHSHIN or {}

PD2THHSHIN._mod_path = ModPath
PD2THHSHIN._options_path = ModPath .. "menu/options.txt"
PD2THHSHIN._save_path = SavePath .. "shin_settings.txt"
PD2THHSHIN.settings = {
	toggle_overhaul_player = true,
	enable_albanian_content = false,
	toggle_helmet = true,
	toggle_hhassault = false,
	toggle_hhskulldiff = false,
	toggle_highpriorityglint = true,
	toggle_suppression = true,
	toggle_health_effect = true,
	toggle_blurzonereduction = true,
	screenshakemult = 1,
	toggle_noweirddof = false,
	first_launch = true
}

PD2THHSHIN.session_settings = {} --leave empty; generated on load
PD2THHSHIN.show_popup = nil

function PD2THHSHIN:ChangeSetting(setting_name,value,apply_immediately)
	self.settings[setting_name] = value
	if apply_immediately then 
		self.session_settings[setting_name] = value
	end
end

function PD2THHSHIN:IsOverhaulEnabled()
	return true
end

function PD2THHSHIN:SkullDiffEnabled()
	return self:GetSessionSetting("toggle_hhskulldiff")
end

function PD2THHSHIN:DofEnabled()
	return self:GetSessionSetting("toggle_noweirddof")
end

function PD2THHSHIN:BlurzoneEnabled()
	return self:GetSessionSetting("toggle_blurzonereduction")
end

function PD2THHSHIN:GlintEnabled()
	return self:GetSessionSetting("toggle_highpriorityglint")
end

function PD2THHSHIN:SupEnabled()
	return self:GetSessionSetting("toggle_suppression")
end

function PD2THHSHIN:IsFlavorAssaultEnabled()
	return self:GetSessionSetting("toggle_hhassault")
end

function PD2THHSHIN:IsHelmetEnabled()
	return self:GetSessionSetting("toggle_helmet")
end

function PD2THHSHIN:IsAlbanianContentEnabled()
	return self:GetSessionSetting("enable_albanian_content") and PD2THHSHIN:LoadAlbAssets()
end

function PD2THHSHIN:LoadAlbAssets()
	PackageManager:load("packages/hhalbaniancontent")
	return true
end

function PD2THHSHIN:GetSessionSetting(setting_name,fallback_value)
	if self.session_settings[setting_name] == nil then 
		return fallback_value
	else
		return self.session_settings[setting_name]
	end
end

function PD2THHSHIN:GetSetting(setting_name,fallback_value)
	if self.settings[tostring(setting_name)] == nil then 
		return fallback_value
	else
		return self.settings[tostring(setting_name)]
	end
end

function PD2THHSHIN:LoadSettings()
	local file = io.open(self._save_path, "r")
	
	if (file) then
		for k, v in pairs(json.decode(file:read("*all"))) do
			self.settings[k] = v
			self.session_settings[k] = v
		end
	end
end

function PD2THHSHIN:SaveSettings(apply_immediately)
	local file = io.open(self._save_path,"w+")
	if file then
		file:write(json.encode(self.settings))
		file:close()
	end
	if apply_immediately then 
		for k,v in pairs(self.settings) do 
			self.session_settings[k] = v
		end
	end
end


PD2THHSHIN:LoadSettings()

if PD2THHSHIN.settings.first_launch then
	PD2THHSHIN.settings.first_launch = false
	PD2THHSHIN:SaveSettings(true)
end

PD2THHSHIN_Maps = PD2THHSHIN_Maps or class(MapFramework)
PD2THHSHIN_Maps._directory = ModPath .. "mapaifixing"
PD2THHSHIN_Maps.type_name = "PD2THHSHIN"
PD2THHSHIN_Maps:new()

--this file is the only time that settings should be loaded from the mod save file;
--any changes will not take place until Lua is reloaded (eg. load into new mission or on restart),
--UNLESS specifically requesting current setting:
--	PD2THHSHIN:GetSetting("setting_name_example")
--or if saving to apply immediately:
--	PD2THHSHIN:SaveSettings(true)
--	PD2THHSHIN:ChangeSetting("setting_name_example",12345,true)
--for anything that requires a restart, you should use 
--	PD2THHSHIN:GetSessionSetting("setting_name_example")

-- Voice Framework Setup
local C = blt_class()
VoicelineFramework = C
VoicelineFramework.BufferedSounds = {}

function C:register_unit(unit_name)
	--log("VF: Registering Unit, " .. unit_name)
	if _G.voiceline_framework then
		_G.voiceline_framework.BufferedSounds[unit_name] = {}
	end
end

function C:register_line_type(unit_name, line_type)
	if _G.voiceline_framework then
		if _G.voiceline_framework.BufferedSounds[unit_name] then
			--log("VF: Registering Type, " .. line_type .. " for Unit " .. unit_name)
			local fuck = _G.voiceline_framework.BufferedSounds[unit_name]
			fuck[line_type] = {}
		end
	end
end

function C:register_voiceline(unit_name, line_type, path)
	if _G.voiceline_framework then
		if _G.voiceline_framework.BufferedSounds[unit_name] then
			local fuck = _G.voiceline_framework.BufferedSounds[unit_name]
			if fuck[line_type] then
				--log("VF: Registering Path, " .. path .. " for Unit " .. unit_name)
				table.insert(fuck[line_type], XAudio.Buffer:new(path))
			end
		end
	end
end

if not _G.voiceline_framework then
	blt.xaudio.setup()
	_G.voiceline_framework = VoicelineFramework:new()
end

Hooks:Add("NetworkReceivedData", "shin_receive_network_data", function(sender, message, data)

	if message == "shin_sync_post_assault_replenish" then
		local pm = managers.player
						
		if pm then
			if pm:player_unit() and alive(pm:player_unit()) then
				local player = pm:player_unit()
				local dmg_ext = player:character_damage()
				
				if not dmg_ext:dead() then
					if not dmg_ext:need_revive() then --if your team didnt revive you in the first place, go eat a medic bag
						dmg_ext:replenish() 
					end
				end
			end
		end
	end

	if managers and managers.groupai then	
		if message == "shin_sync_hud_assault_color" then 
			if sender == 1 then
				if data == "true" then
					managers.groupai:state()._activeassaultbreak = true
					managers.groupai:state():play_heat_bonus_dialog()
					managers.hud:show_heat_bonus_hints()
					
					local pm = managers.player
						
					if pm then
						if pm:player_unit() and alive(pm:player_unit()) then
							local player = pm:player_unit()
							local dmg_ext = player:character_damage()
							
							if not dmg_ext:dead() then
								if not dmg_ext:need_revive() and not dmg_ext:is_berserker() then
									dmg_ext:restore_health(0.5) --50% health restored on heat bonus
								end
								
								local inventory = player:inventory()
							
								if inventory then
									local available_selections = {}

									for i, weapon in pairs(inventory:available_selections()) do
										available_selections[#available_selections] = weapon
									end
									
									for i = 1, #available_selections do
										local weapon = available_selections[i]
										weapon.unit:base():add_ammo_from_bag(0.5) --3 instead of 2 in case theres 
									end
								end
							end
						end
					end					
				elseif data == "nil" then 
				   managers.groupai:state()._activeassaultbreak = nil
				   managers.groupai:state()._said_heat_bonus_dialog = nil
				end
			end
		end
		
		if message == "shin_sync_speed_mul" then 
			if sender == 1 then
				if data then
					local number_data = tonumber(data)
					managers.groupai:state()._enemy_speed_mul = number_data
				end
			end
		end
	end
end)