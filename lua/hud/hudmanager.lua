HUDManager = HUDManager or class()
HUDManager.WAITING_SAFERECT = Idstring("guis/waiting_saferect")
HUDManager.STATS_SCREEN_SAFERECT = Idstring("guis/stats_screen/stats_screen_saferect_pd2")
HUDManager.STATS_SCREEN_FULLSCREEN = Idstring("guis/stats_screen/stats_screen_fullscreen")
HUDManager.WAITING_FOR_PLAYERS_SAFERECT = Idstring("guis/waiting_saferect")
HUDManager.ASSAULT_DIALOGS = {
	"b01a",
	"b01b",
	"b02a",
	"b02b",
	"b02c",
	"b03x",
	"b04x",
	"b05x",
	"b10",
	"b11",
	"b12"
}
HUDManager.ASSAULTS_MAX = 1024

core:import("CoreEvent")

function HUDManager:setup_anticipation(total_t)
	local exists = self._anticipation_dialogs and true or false
	self._anticipation_dialogs = {}

	if not exists and total_t == 45 then
		table.insert(self._anticipation_dialogs, {
			time = 45,
			dialog = 1
		})
		table.insert(self._anticipation_dialogs, {
			time = 30,
			dialog = 2
		})
	elseif exists and total_t == 45 then
		table.insert(self._anticipation_dialogs, {
			time = 30,
			dialog = 6
		})
	end

	if total_t == 45 then
		table.insert(self._anticipation_dialogs, {
			time = 20,
			dialog = 3
		})
		table.insert(self._anticipation_dialogs, {
			time = 10,
			dialog = 4
		})
	end

	if total_t == 35 then
		table.insert(self._anticipation_dialogs, {
			time = 20,
			dialog = 7
		})
		table.insert(self._anticipation_dialogs, {
			time = 10,
			dialog = 4
		})
	end

	if total_t == 25 then
		table.insert(self._anticipation_dialogs, {
			time = 10,
			dialog = 8
		})
	end
end

function HUDManager:check_anticipation_voice(t)
	if not self._anticipation_dialogs or self._anticipation_dialogs and not self._anticipation_dialogs[1] then
		return
	end

	if self._anticipation_dialogs and t < self._anticipation_dialogs[1].time then
		local data = table.remove(self._anticipation_dialogs, 1)

		self:sync_assault_dialog(data.dialog)
		managers.network:session():send_to_peers_synched("sync_assault_dialog", data.dialog)
	end
end
