core:import("CoreElementArea")
local ElementAreaReportTrigger = CoreElementArea.ElementAreaReportTrigger

local tmp_vec1 = Vector3()

local t_cont = table.contains
local t_del = table.delete

local fall_dmg_event_names = {
	trigger_area_report_001 = true,
	trigger_area_report_002 = true,
	trigger_area_report_003 = true
}

function ElementAreaReportTrigger:init(...)
	ElementAreaReportTrigger.super.init(self, ...)

	--log("fuck")
	if Network:is_client() and Global.game_settings.level_id == "nail" and fall_dmg_event_names[self._editor_name] then
		self._toggle_fall_dmg_on_local_player = true
	end
end

function ElementAreaReportTrigger:_client_check_state(unit)
	local rule_ok = self:_check_instigator_rules(unit)
	local session = managers.network:session()
	local inside, synced_while_inside = nil
	local mov_ext = unit:movement()
	local element_id = self._id

	if mov_ext then
		inside = self:_is_inside(mov_ext:m_pos())
	else
		unit:m_position(tmp_vec1)

		inside = self:_is_inside(tmp_vec1)
	end

	if inside and not rule_ok then
		if self:_has_on_executed_alternative("rule_failed") then
			session:send_to_host("to_server_area_event", 4, element_id, unit)
		end
	end

	local units_inside = self._inside

	if t_cont(units_inside, unit) then
		if inside and rule_ok then
			if self:_has_on_executed_alternative("while_inside") then
				session:send_to_host("to_server_area_event", 3, element_id, unit)
			end
		else
			t_del(units_inside, unit)
			self._inside = units_inside

			session:send_to_host("to_server_area_event", 2, element_id, unit)

			if self._toggle_fall_dmg_on_local_player then
				local base_ext = unit:base()

				if base_ext and base_ext.is_local_player then
					unit:character_damage():set_mission_damage_blockers("damage_fall_disabled", false)
				end
			end
		end
	elseif inside and rule_ok then
		units_inside[#units_inside + 1] = unit
		self._inside = units_inside

		session:send_to_host("to_server_area_event", 1, element_id, unit)

		if self._toggle_fall_dmg_on_local_player then
			local base_ext = unit:base()

			if base_ext and base_ext.is_local_player then
				unit:character_damage():set_mission_damage_blockers("damage_fall_disabled", true)
			end
		end
	end
end
