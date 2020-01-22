PD2THHSHIN_Maps = PD2THHSHIN_Maps or class(MapFramework)
PD2THHSHIN_Maps._directory = ModPath .. "mapaifixing"
PD2THHSHIN_Maps.type_name = "PD2THHSHIN"
PD2THHSHIN_Maps:new()

_G.PD2THHSHIN = PD2THHSHIN or {}

PD2THHSHIN._mod_path = ModPath
PD2THHSHIN._options_path = ModPath .. "menu/options.txt"
PD2THHSHIN._save_path = SavePath .. "shin_settings.txt"
PD2THHSHIN.settings = {
	toggle_overhaul_player = true --default on
}
PD2THHSHIN.session_settings = {} --leave empty; generated on load

function PD2THHSHIN:ChangeSetting(setting_name,value,apply_immediately)
	self.settings[setting_name] = value
	if apply_immediately then 
		self.session_settings[setting_name] = value
	end
end

function PD2THHSHIN:IsOverhaulEnabled()
	return self:GetSessionSetting("toggle_overhaul_player")
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
	else
		self:SaveSettings(true)
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


--this file is the only time that settings should be loaded from the mod save file;
--any changes will not take place until Lua is reloaded (eg. load into new mission or on restart),
--UNLESS specifically requesting current setting:
--	PD2THHSHIN:GetSetting("setting_name_example")
--or if saving to apply immediately:
--	PD2THHSHIN:SaveSettings(true)
--	PD2THHSHIN:ChangeSetting("setting_name_example",12345,true)
--for anything that requires a restart, you should use 
--	PD2THHSHIN:GetSessionSetting("setting_name_example")