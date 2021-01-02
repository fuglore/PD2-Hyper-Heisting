function Drill:_register_sabotage_SO()
	if self._sabotage_SO_id or not managers.navigation:is_data_ready() or not self._unit:timer_gui() or not self._unit:timer_gui()._can_jam or not self._sabotage_align_obj_name then
		return
	end

	local field_pos = self._nav_tracker:field_position()
	local field_z = self._nav_tracker:field_z() - 25
	local height = self._pos.z - field_z
	local act_anim = "sabotage_device_" .. (height > 100 and "high" or height > 60 and "mid" or "low")
	local align_obj = self._unit:get_object(Idstring(self._sabotage_align_obj_name))
	local objective_rot = align_obj:rotation()
	local objective_pos = align_obj:position()
	self._SO_area = managers.groupai:state():get_area_from_nav_seg_id(self._nav_tracker:nav_segment())
	local followup_objective = {
		attitude = "avoid",
		scan = true,
		stance = "hos",
		type = "defend_area",
		interrupt_health = 1,
		interrupt_dis = 500,
		nav_seg = self._nav_tracker:nav_segment(),
		area = self._SO_area
	}
	local objective = {
		type = "act",
		stance = "hos",
		haste = "run",
		scan = true,
		nav_seg = self._nav_tracker:nav_segment(),
		area = self._SO_area,
		pos = objective_pos,
		rot = objective_rot,
		fail_clbk = callback(self, self, "on_sabotage_SO_failed"),
		complete_clbk = callback(self, self, "on_sabotage_SO_completed"),
		action_start_clbk = callback(self, self, "on_sabotage_SO_started"),
		followup_objective = followup_objective,
		action = {
			align_sync = true,
			type = "act",
			body_part = 1,
			variant = act_anim,
			blocks = {
				light_hurt = -1,
				action = -1,
				aim = -1
			}
		}
	}
	local search_dis_sq = nil
	
	if Global.game_settings.one_down then
		search_dis_sq = 16000000 --people dont deserve to have fun if they play this.
	else
		search_dis_sq = 4000000
	end
	
	local so_descriptor = {
		interval = 0,
		search_dis_sq = search_dis_sq,
		AI_group = "enemies",
		base_chance = 1,
		chance_inc = 0,
		usage_amount = 1,
		objective = objective,
		search_pos = field_pos,
		verification_clbk = callback(self, self, "clbk_sabotage_SO_verification"),
		access = managers.navigation:convert_access_filter_to_number({
			"gangster",
			"cop",
			"fbi",
			"swat",
			"murky",
			"sniper",
			"spooc",
			"tank",
			"taser"
		}),
		admin_clbk = callback(self, self, "on_sabotage_SO_administered")
	}
	self._sabotage_SO_id = "drill_sabotage" .. tostring(self._unit:key())

	managers.groupai:state():add_special_objective(self._sabotage_SO_id, so_descriptor)
end

function Drill:on_sabotage_SO_administered(receiver_unit)
	if self._saboteur then
		debug_pause("[Drill:on_sabotage_SO_administered] Already had a saboteur", receiver_unit, self._saboteur)
	end

	self._saboteur = receiver_unit
	self._sabotage_SO_id = nil
	
	if math.random() < 0.20 then
		managers.dialog:queue_narrator_dialog("dd_01", {})
	end
end
