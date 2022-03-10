--Added a bunch of chatter stuff with permission from Rino, along with a few tweaks to keep things consistent

local mvec3_set = mvector3.set
local mvec3_set_z = mvector3.set_z
local mvec3_set_zero = mvector3.set_zero
local mvec3_step = mvector3.step
local mvec3_lerp = mvector3.lerp
local mvec3_add = mvector3.add
local mvec3_divide = mvector3.divide
local mvec3_dis_sq = mvector3.distance_sq
local mvec3_cpy = mvector3.copy
local mvec3_sub = mvector3.subtract
local mvec3_dir = mvector3.direction
local mvec3_dot = mvector3.dot
local mvec3_norm = mvector3.normalize
local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()
local tmp_vec3 = Vector3()

local math_up = math.UP
local math_lerp = math.lerp
local math_random = math.random
local math_clamp = math.clamp
local math_max = math.max

local pairs_g = pairs
local next_g = next

local table_insert = table.insert
local table_remove = table.remove

function GroupAIStateBesiege:init(group_ai_state)
	GroupAIStateBesiege.super.init(self)

	--self:set_debug_draw_state(true)
	--self:set_drama_draw_state(true)
	
	self._tweak_data = tweak_data.group_ai[group_ai_state]

	local level = Global.level_data and Global.level_data.level_id
	local level_data = tweak_data.levels[level]
	self._small_map = level_data.meatgrinder
	self._street = level_data.street
	self._too_drama = level_data.too_drama
	
	--log(tostring(self._small_map))
	
	self._spawn_group_timers = {}
	self._graph_distance_cache = {}
	self._enemy_speed_mul = 1
	self._had_hostages = nil
	self._downs_during_assault = 0
	self._feddensityhigh = nil	
	self._feddensityhighfrequency = 1
	self._downleniency = 1
	self._enemies_killed_sustain = 0
	self._enemies_killed_sustain_guaranteed_break = nil
	self._downcountleniency = 0
	self._feddensity_active_t = nil
	self._next_allowed_hunter_upd_t = nil
	self._activeassaultbreak = nil
	self._activeassaultnextbreak_t = nil
	self._stopassaultbreak_t = nil
	self._MAX_SIMULTANEOUS_SPAWNS = 3
	
	if Network:is_server() and managers.navigation:is_data_ready() then
		self:_queue_police_upd_task()
	end
end

function GroupAIStateBesiege:_draw_enemy_activity_client(t)
	local camera = managers.viewport:get_current_camera()

	if not camera then
		return
	end

	local draw_data = self._AI_draw_data
	local logic_name_texts = draw_data.logic_name_texts --not really logics since client
	local panel = draw_data.panel
	local ws = draw_data.workspace
	local mid_pos1 = tmp_vec1
	local mid_pos2 = tmp_vec2
	local focus_enemy_pen = draw_data.pen_focus_enemy
	local focus_player_brush = draw_data.brush_focus_player
	local suppr_period = 0.4
	local suppr_t = t % suppr_period

	if suppr_t > suppr_period * 0.5 then
		suppr_t = suppr_period - suppr_t
	end

	draw_data.brush_suppressed:set_color(Color(math_lerp(0.2, 0.5, suppr_t), 0.85, 0.9, 0.2))

	local groups = {
		{
			group = self._police,
			color = Color(1, 1, 0, 0)
		},
		{
			group = managers.enemy:all_civilians(),
			color = Color(1, 0.75, 0.75, 0.75)
		},
		{
			group = self._ai_criminals,
			color = Color(1, 0, 1, 0)
		}
	}

	local res_x = RenderSettings.resolution.x
	local res_y = RenderSettings.resolution.y

	for i = 1, #groups do
		local group_data = groups[i]

		for u_key, u_data in pairs_g(group_data.group) do
			local logic_name_text = logic_name_texts[u_key]
			local unit = u_data.unit
			local ext_mov = unit:movement()
			local team = ext_mov:team()
			local text_str = team and team.id or "no_team"

			local anim_machine = unit:anim_state_machine()

			if anim_machine then
				local base_seg_state = anim_machine:segment_state(Idstring("base"))

				if base_seg_state then
					local idx = anim_machine:state_name_to_index(base_seg_state)
					text_str = text_str .. ":base_anim_idx( " .. tostring(idx) .. " )"
				end

				local upper_body_seg_state = anim_machine:segment_state(Idstring("upper_body"))

				if upper_body_seg_state then
					local idx = anim_machine:state_name_to_index(upper_body_seg_state)
					text_str = text_str .. ":upp_bdy_anim_idx( " .. tostring(idx) .. " )"
				end
			end

			local active_actions = ext_mov._active_actions

			if active_actions then
				local full_body = active_actions[1]

				if full_body then
					text_str = text_str .. ":action[1]( " .. full_body:type() .. " )"
				end

				local lower_body = active_actions[2]

				if lower_body then
					text_str = text_str .. ":action[2]( " .. lower_body:type() .. " )"
				end

				local upper_body = active_actions[3]

				if upper_body then
					text_str = text_str .. ":action[3]( " .. upper_body:type() .. " )"
				end

				local superficial = active_actions[4]

				if superficial then
					text_str = text_str .. ":action[4]( " .. superficial:type() .. " )"
				end
			end

			local queued_actions = ext_mov._queued_actions

			if queued_actions then
				for idx = 1, #queued_actions do
					local q_action = queued_actions[idx]

					if q_action then
						local action_type = q_action.type or "unknown"

						text_str = text_str .. ":queued_action[1]( " .. action_type .. " )"
					end
				end
			end

			if logic_name_text then
				logic_name_text:set_text(text_str)
			else
				logic_name_text = panel:text({
					name = "text",
					font_size = 20,
					layer = 1,
					text = text_str,
					font = tweak_data.hud.medium_font,
					color = group_data.color
				})
				logic_name_texts[u_key] = logic_name_text
			end

			local my_head_pos = mid_pos1
			local m_head_pos = ext_mov:m_head_pos()

			mvec3_set(my_head_pos, m_head_pos)
			mvec3_set_z(my_head_pos, my_head_pos.z + 30)

			local my_head_pos_screen = camera:world_to_screen(my_head_pos)

			if my_head_pos_screen.z > 0 then
				local screen_x = (my_head_pos_screen.x + 1) * 0.5 * res_x
				local screen_y = (my_head_pos_screen.y + 1) * 0.5 * res_y

				logic_name_text:set_x(screen_x)
				logic_name_text:set_y(screen_y)

				if not logic_name_text:visible() then
					logic_name_text:show()
				end
			elseif logic_name_text:visible() then
				logic_name_text:hide()
			end

			local mov_common_data = ext_mov._common_data

			if mov_common_data and mov_common_data.is_suppressed then
				mvec3_set(mid_pos1, ext_mov:m_pos())
				mvec3_set_z(mid_pos1, mid_pos1.z + 220)
				draw_data.brush_suppressed:cylinder(ext_mov:m_pos(), mid_pos1, 35)
			end

			local attention = ext_mov:attention()

			if attention then
				mvec3_set(my_head_pos, m_head_pos)

				local att_unit, e_pos = nil
				local att_handler = attention.handler

				if att_handler then
					e_pos = att_handler:get_attention_m_pos()
				else
					att_unit = attention.unit

					if att_unit then
						local att_ext_mov = att_unit:movement()

						e_pos = att_ext_mov and att_ext_mov:m_head_pos() or att_unit:position()
					else
						e_pos = attention.pos
					end
				end

				mvec3_step(mid_pos2, my_head_pos, e_pos, 300)
				mvec3_lerp(mid_pos1, my_head_pos, mid_pos2, t % 0.5)
				mvec3_step(mid_pos2, mid_pos1, e_pos, 50)
				focus_enemy_pen:line(mid_pos1, mid_pos2)

				att_unit = att_unit or attention.unit

				if att_unit then
					local att_base = att_unit:base()

					if att_base and att_base.is_local_player then
						focus_player_brush:sphere(my_head_pos, 20)
					end
				end
			end
		end
	end

	for u_key, gui_text in pairs_g(logic_name_texts) do
		local keep = nil

		for i = 1, #groups do
			local group_data = groups[i]

			if group_data.group[u_key] then
				keep = true

				break
			end
		end

		if not keep then
			panel:remove(gui_text)

			logic_name_texts[u_key] = nil
		end
	end
end

function GroupAIStateBesiege:_draw_enemy_activity(t)
	local camera = managers.viewport:get_current_camera()

	if not camera then
		return
	end

	local draw_data = self._AI_draw_data
	local brush_area = draw_data.brush_area
	local area_normal = -math_up
	local logic_name_texts = draw_data.logic_name_texts
	local group_id_texts = draw_data.group_id_texts
	local panel = draw_data.panel
	local ws = draw_data.workspace
	local mid_pos1 = tmp_vec1
	local mid_pos2 = tmp_vec2
	local focus_enemy_pen = draw_data.pen_focus_enemy
	local focus_player_brush = draw_data.brush_focus_player
	local suppr_period = 0.4
	local suppr_t = t % suppr_period

	if suppr_t > suppr_period * 0.5 then
		suppr_t = suppr_period - suppr_t
	end

	draw_data.brush_suppressed:set_color(Color(math_lerp(0.2, 0.5, suppr_t), 0.85, 0.9, 0.2))

	for area_id, area in pairs_g(self._area_data) do
		if next_g(area.police.units) then
			brush_area:half_sphere(area.pos, 22, area_normal)
		end
	end

	local res_x = RenderSettings.resolution.x
	local res_y = RenderSettings.resolution.y

	local function _f_draw_logic_name(u_key, l_data, draw_color)
		local logic_name_text = logic_name_texts[u_key]
		local text_str = l_data.name

		if l_data.objective then
			text_str = text_str .. ":" .. l_data.objective.type
		end

		if not l_data.group and l_data.team then
			text_str = l_data.team.id .. ":" .. text_str
		end

		if l_data.spawned_in_phase then
			text_str = text_str .. ":" .. l_data.spawned_in_phase
		end

		local unit = l_data.unit
		local anim_machine = unit:anim_state_machine()

		if anim_machine then
			local base_seg_state = anim_machine:segment_state(Idstring("base"))

			if base_seg_state then
				local idx = anim_machine:state_name_to_index(base_seg_state)
				text_str = text_str .. ":base_anim_idx( " .. tostring(idx) .. " )"
			end

			local upper_body_seg_state = anim_machine:segment_state(Idstring("upper_body"))

			if upper_body_seg_state then
				local idx = anim_machine:state_name_to_index(upper_body_seg_state)
				text_str = text_str .. ":upp_bdy_anim_idx( " .. tostring(idx) .. " )"
			end
		end

		local ext_mov = unit:movement()
		local active_actions = ext_mov._active_actions

		if active_actions then
			local full_body = active_actions[1]

			if full_body then
				text_str = text_str .. ":action[1]( " .. full_body:type() .. " )"
			end

			local lower_body = active_actions[2]

			if lower_body then
				text_str = text_str .. ":action[2]( " .. lower_body:type() .. " )"
			end

			local upper_body = active_actions[3]

			if upper_body then
				text_str = text_str .. ":action[3]( " .. upper_body:type() .. " )"
			end

			local superficial = active_actions[4]

			if superficial then
				text_str = text_str .. ":action[4]( " .. superficial:type() .. " )"
			end
		end

		if logic_name_text then
			logic_name_text:set_text(text_str)
		else
			logic_name_text = panel:text({
				name = "text",
				font_size = 12,
				layer = 1,
				text = text_str,
				font = tweak_data.hud.medium_font,
				color = draw_color
			})
			logic_name_texts[u_key] = logic_name_text
		end

		local my_head_pos = mid_pos1

		mvec3_set(my_head_pos, ext_mov:m_head_pos())
		mvec3_set_z(my_head_pos, my_head_pos.z + 30)

		local my_head_pos_screen = camera:world_to_screen(my_head_pos)

		if my_head_pos_screen.z > 0 then
			local screen_x = (my_head_pos_screen.x + 1) * 0.5 * res_x
			local screen_y = (my_head_pos_screen.y + 1) * 0.5 * res_y

			logic_name_text:set_x(screen_x)
			logic_name_text:set_y(screen_y)

			if not logic_name_text:visible() then
				logic_name_text:show()
			end
		elseif logic_name_text:visible() then
			logic_name_text:hide()
		end
	end

	local brush_to_use = {
		guard = "brush_guard",
		defend_area = "brush_defend",
		free = "brush_free",
		follow = "brush_free",
		surrender = "brush_free",
		act = "brush_act",
		revive = "brush_act"
	}

	local function _f_draw_obj_pos(unit)
		local ext_brain = unit:brain()
		local objective = ext_brain:objective()
		local objective_type = objective and objective.type
		local brush = brush_to_use[objective_type]
		brush = brush and draw_data[brush] or draw_data.brush_misc

		local obj_pos = nil

		if objective then
			if objective.pos then
				obj_pos = objective.pos
			else
				local follow_unit = objective.follow_unit

				if follow_unit then
					obj_pos = follow_unit:movement():m_head_pos()

					if follow_unit:base().is_local_player then
						obj_pos = obj_pos + math_up * -30
					end
				elseif objective.nav_seg then
					obj_pos = managers.navigation._nav_segments[objective.nav_seg].pos
				elseif objective.area then
					obj_pos = objective.area.pos
				end
			end
		end

		local ext_mov = nil

		if obj_pos then
			ext_mov = unit:movement()

			local u_pos = ext_mov:m_com()

			brush:cylinder(u_pos, obj_pos, 4, 3)
			brush:sphere(u_pos, 24)
		end

		if ext_brain._logic_data.is_suppressed then
			ext_mov = ext_mov or unit:movement()

			mvec3_set(mid_pos1, ext_mov:m_pos())
			mvec3_set_z(mid_pos1, mid_pos1.z + 220)
			draw_data.brush_suppressed:cylinder(ext_mov:m_pos(), mid_pos1, 35)
		end
	end

	local my_groups = self._groups
	local group_center = tmp_vec3

	for group_id, group in pairs_g(my_groups) do
		local units_com = {}

		for u_key, u_data in pairs_g(group.units) do
			local m_com = u_data.unit:movement():m_com()

			units_com[#units_com + 1] = m_com

			mvec3_add(group_center, m_com)
		end

		local nr_units = #units_com

		if nr_units > 0 then
			mvec3_divide(group_center, nr_units)

			local gui_text = group_id_texts[group_id]
			local group_pos_screen = camera:world_to_screen(group_center)

			if group_pos_screen.z > 0 then
				local move_type = ":" .. "none"
				local group_objective = group.objective

				if group_objective then
					if group_objective.tactic then
						move_type = ":" .. group_objective.tactic
					elseif group.is_chasing then
						move_type = ":" .. "chasing"
					elseif group_objective.moving_in then
						move_type = ":" .. "moving_in"
					elseif group_objective.moving_out then
						move_type = ":" .. "moving_out"
					elseif group_objective.open_fire then
						move_type = ":" .. "open_fire"
					end
				end
				
				local phase = ""
				
				local task_data = self._task_data.assault
				
				if task_data and task_data.active then
					phase = ":" .. task_data.phase
				end

				if not gui_text then
					gui_text = panel:text({
						name = "text",
						font_size = 12,
						layer = 2,
						text = group.team.id .. ":" .. group_id .. ":" .. group.objective.type .. move_type .. phase,
						font = tweak_data.hud.medium_font,
						color = draw_data.group_id_color
					})
					group_id_texts[group_id] = gui_text
				else
					gui_text:set_text(group.team.id .. ":" .. group_id .. ":" .. group.objective.type .. move_type .. phase)
				end

				local screen_x = (group_pos_screen.x + 1) * 0.5 * res_x
				local screen_y = (group_pos_screen.y + 1) * 0.5 * res_y

				gui_text:set_x(screen_x)
				gui_text:set_y(screen_y)

				if not gui_text:visible() then
					gui_text:show()
				end
			elseif gui_text and gui_text:visible() then
				gui_text:hide()
			end

			for i = 1, #units_com do
				local m_com = units_com[i]

				draw_data.pen_group:line(group_center, m_com)
			end
		end

		mvec3_set_zero(group_center)
	end

	local function _f_draw_attention(l_data)
		local current_focus = l_data.attention_obj

		if not current_focus then
			return
		end

		local my_head_pos = l_data.unit:movement():m_head_pos()
		local e_pos = l_data.attention_obj.m_head_pos

		mvec3_step(mid_pos2, my_head_pos, e_pos, 300)
		mvec3_lerp(mid_pos1, my_head_pos, mid_pos2, t % 0.5)
		mvec3_step(mid_pos2, mid_pos1, e_pos, 50)
		focus_enemy_pen:line(mid_pos1, mid_pos2)

		local focus_base_ext = current_focus.unit:base()

		if focus_base_ext and focus_base_ext.is_local_player then
			focus_player_brush:sphere(my_head_pos, 20)
		end
	end

	local groups = {
		{
			group = self._police,
			color = Color(1, 1, 0, 0)
		},
		{
			group = managers.enemy:all_civilians(),
			color = Color(1, 0.75, 0.75, 0.75)
		},
		{
			group = self._ai_criminals,
			color = Color(1, 0, 1, 0)
		}
	}

	for i = 1, #groups do
		local group_data = groups[i]

		for u_key, u_data in pairs_g(group_data.group) do
			_f_draw_obj_pos(u_data.unit)

			if camera then
				local l_data = u_data.unit:brain()._logic_data

				_f_draw_logic_name(u_key, l_data, group_data.color)
				_f_draw_attention(l_data)
			end
		end
	end

	for u_key, gui_text in pairs_g(logic_name_texts) do
		local keep = nil

		for i = 1, #groups do
			local group_data = groups[i]

			if group_data.group[u_key] then
				keep = true

				break
			end
		end

		if not keep then
			panel:remove(gui_text)

			logic_name_texts[u_key] = nil
		end
	end

	for group_id, gui_text in pairs_g(group_id_texts) do
		if not my_groups[group_id] then
			panel:remove(gui_text)

			group_id_texts[group_id] = nil
		end
	end
end

function GroupAIStateBesiege:_upd_police_activity()
	self._police_upd_task_queued = false

	if self._police_activity_blocked then
		return
	end

	if self._ai_enabled then
		self:_upd_SO()
		self:_upd_grp_SO()
		self:_check_spawn_phalanx()
		self:_check_phalanx_group_has_spawned()
		self:_check_phalanx_damage_reduction_increase()
		self:_upd_hostage_task()

		if self._enemy_weapons_hot then
			--self:_claculate_drama_value()
			self:_upd_regroup_task()
			self:_upd_reenforce_tasks()
			self:_upd_recon_tasks()
			self:_upd_assault_task()
			self:_begin_new_tasks()
			if not self._activeassaultbreak and not self._feddensityhigh then
				self:_upd_group_spawning()
			end
			self:_upd_groups()
		end
	end
	
	self:_queue_police_upd_task()
end

function GroupAIStateBesiege:_chk_group_area_presence(group, area_to_chk)
	if not area_to_chk then
		return
	end
	
	local id = area_to_chk.id
	
	for u_key, u_data in pairs(group.units) do
		local nav_seg = u_data.tracker:nav_segment()
		local my_area = self:get_area_from_nav_seg_id(nav_seg)

		if my_area.id == id then
			--log("bingus")
			return my_area
		end
	end
end

function GroupAIStateBesiege:_set_objective_to_enemy_group(group, grp_objective)
	group.objective = grp_objective

	if grp_objective.area then
		if grp_objective.type == "retire" or not self:_chk_group_area_presence(group, grp_objective.area) then
			grp_objective.moving_out = true
		else
			group.in_place = true
			grp_objective.moving_out = nil
		end

		if not grp_objective.nav_seg and grp_objective.coarse_path then
			grp_objective.nav_seg = grp_objective.coarse_path[#grp_objective.coarse_path][1]
		end
	end

	grp_objective.assigned_t = self._t

	if self._AI_draw_data and self._AI_draw_data.group_id_texts[group.id] then
		self._AI_draw_data.panel:remove(self._AI_draw_data.group_id_texts[group.id])

		self._AI_draw_data.group_id_texts[group.id] = nil
	end
end

function GroupAIStateBesiege:_assign_enemy_groups_to_assault(phase)
	for group_id, group in pairs_g(self._groups) do
		local grp_objective = group.objective
		if group.has_spawned and grp_objective.type == "assault_area" then
			if grp_objective.area and grp_objective.moving_out then
				local done_moving = nil
				
				for u_key, u_data in pairs(group.units) do
					local objective = u_data.unit:brain():objective()

					if objective then
						if objective.grp_objective ~= group.objective then
							-- Nothing
						elseif objective.in_place then
							done_moving = true
							
							break
						end
					end
				end

				if done_moving then
					group.objective.moving_out = nil
					group.in_place_t = self._t
					group.in_place = true
					
					if not grp_objective.moving_in then
						self:_voice_move_complete(group)
					end
					
					group.objective.moving_in = nil
				else
					group.in_place_t = nil
					group.in_place = nil
				end
			elseif grp_objective.area and not group.in_place_t then
				group.in_place_t = self._t
				group.in_place = true
			end

			self:_set_assault_objective_to_group(group, phase)
		end
	end
end

function GroupAIStateBesiege:_queue_police_upd_task()
	if not self._police_upd_task_queued then
		self._police_upd_task_queued = true
		
		managers.enemy:add_delayed_clbk("GroupAIStateBesiege._upd_police_activity", callback(self, self, "_upd_police_activity"), self._t + (next(self._spawning_groups) and 0.4 or 2))
	end
end

function GroupAIStateBesiege:add_to_surrendered(unit, update)
	local hos_data = self._hostage_data
	local nr_entries = #hos_data
	local entry = {
		u_key = unit:key(),
		clbk = update
	}

	table.insert(hos_data, entry)
end

function GroupAIStateBesiege:_upd_hostage_task()
	if #self._hostage_data > 0 then
		local hos_data = self._hostage_data
		local first_entry = hos_data[1]

		table.remove(hos_data, 1)
		first_entry.clbk()
	end
end

function GroupAIStateBesiege:remove_from_surrendered(unit)
	local hos_data = self._hostage_data
	local u_key = unit:key()

	for i, entry in ipairs(hos_data) do
		if u_key == entry.u_key then
			table.remove(hos_data, i)

			break
		end
	end
end

function GroupAIStateBesiege:force_end_assault_phase(force_regroup)
	local task_data = self._task_data.assault

	if task_data.active then
		print("GroupAIStateBesiege:force_end_assault_phase()")

		task_data.phase = "fade"
		task_data.force_end = true

		if force_regroup then
			task_data.force_regroup = true

			managers.enemy:reschedule_delayed_clbk(GroupAIStateBesiege._upd_police_activity, self._t)
		end
	end

	self:set_assault_endless(false)
end

function GroupAIStateBesiege:update(t, dt)
	GroupAIStateBesiege.super.update(self, t, dt)
	self:get_assault_hud_state()
	
	if managers.hud._hud_assault_corner._assault then
		if managers.hud.needs_to_restart_assault_banner then
			managers.hud._hud_assault_corner:_start_assault(managers.hud._hud_assault_corner:_get_assault_strings())
			managers.hud.needs_to_restart_assault_banner = nil
		end
		
		if PD2THHSHIN and PD2THHSHIN:IsFlavorAssaultEnabled() then			
			if managers.hud._hud_assault_corner.set_color_state and managers.hud._hud_assault_corner._assault_state ~= self._current_assault_state then
				managers.hud._hud_assault_corner:set_color_state(self._current_assault_state)
			end
		end
	end
	
	if Network:is_server() then
		self:_queue_police_upd_task()
		
		if self._task_data then			
			--self:_claculate_drama_value()
			
			if Global.game_settings and Global.game_settings.one_down then
				--nothing
			elseif self._danger_state then
				if not self._reset_heat_bonus then
					self:reset_heat_bonus()
					self._reset_heat_bonus = true
				end
			else
				if self._reset_heat_bonus then
					self._reset_heat_bonus = nil
				end
					
				local level = Global.level_data and Global.level_data.level_id
			
				local small_map = self._small_map
				
				if self._force_pool and not self._enemies_killed_sustain_guaranteed_break then
					local value = nil
							
					if self._force_pool then
						if small_map then
							value = self._force_pool / 3
						else
							value = self._force_pool / 4
						end
						
						value = value
					end
							
					if small_map then
						self._enemies_killed_sustain_guaranteed_break = value
					else
						self._enemies_killed_sustain_guaranteed_break = value
					end
				end

				local task_data = self._task_data.assault
				local diff_index = managers.modifiers and managers.modifiers:check_boolean("TotalAnarchy") and 8 or tweak_data:difficulty_to_index(Global.game_settings.difficulty)
				
				if self._activeassaultbreak and self._stopassaultbreak_t and self._stopassaultbreak_t < self._t then
					self._stopassaultbreak_t = nil
					self._activeassaultbreak = nil
					
					if small_map then
						self._activeassaultnextbreak_t = self._t + 30
					else
						self._activeassaultnextbreak_t = self._t + 30
					end
							
					if diff_index > 6 or managers.modifiers and managers.modifiers:check_boolean("TotalAnarchy") then
						self._activeassaultnextbreak_t = self._activeassaultnextbreak_t + 30
						--log("breaksetforDW")
					end
					
					self._said_heat_bonus_dialog = nil
					if not Global.game_settings.single_player then
						LuaNetworking:SendToPeers("shin_sync_hud_assault_color",tostring(self._activeassaultbreak))
					end
					--log("assaultbreakreset")
				end
				
				if not self._activeassaultnextbreak_t then
					if self._hunt_mode then
						self._activeassaultnextbreak_t = self._t + 30
						
						if diff_index > 6 or managers.modifiers and managers.modifiers:check_boolean("TotalAnarchy") then
							self._activeassaultnextbreak_t = self._activeassaultnextbreak_t + 30
							--log("breaksetforDW")
						end
					else
						self._activeassaultnextbreak_t = self._t
					end
				end
				
				if task_data and task_data.phase == "sustain" or self._hunt_mode then
					if not self._activeassaultbreak and self._current_assault_state ~= "heat" and self._activeassaultnextbreak_t and self._enemies_killed_sustain_guaranteed_break then
						if self._enemies_killed_sustain_guaranteed_break <= self._enemies_killed_sustain and self._activeassaultnextbreak_t < self._t and not self._stopassaultbreak_t then
							self._heat_bonus_count = self._heat_bonus_count + 1
							self._stopassaultbreak_t = self._t + 20
							self._activeassaultbreak = true
							--self._task_data.assault.phase_end_t = self._task_data.assault.phase_end_t + 20
							local value = 32
							
							if self._force_pool then
								if small_map then
									value = self._force_pool / 3
								else
									value = self._force_pool / 4
								end
								
								value = value 
							end
							
							if small_map then
								self._enemies_killed_sustain_guaranteed_break = self._enemies_killed_sustain + value
							else
								self._enemies_killed_sustain_guaranteed_break = self._enemies_killed_sustain + value
							end
							
							if not self._said_heat_bonus_dialog then
								self:play_heat_bonus_dialog()
								
								managers.hud:show_heat_bonus_hints()
								
								for key, data in pairs_g(self._police) do
									local dmg_ext = data.unit:character_damage()

									if dmg_ext and dmg_ext.build_suppression then
										dmg_ext:build_suppression(nil, -1)
									end
								end
								
								local pm = managers.player
						
								if pm then
									if pm:player_unit() and alive(pm:player_unit()) then
										local player = pm:player_unit()
										local dmg_ext = player:character_damage()
										
										if not dmg_ext:dead() then			
											if not dmg_ext:need_revive() then
												if self._heat_bonus_count >= 3 then
													dmg_ext:replenish() 
													self._heat_bonus_count = 0
												end
												
												if not dmg_ext:is_berserker() then
													dmg_ext:restore_health(0.5, nil, nil, true) --50% health restored on heat bonus
												end
											end
											
											local inventory = player:inventory()
										
											if inventory then						
												for i, weapon in pairs(inventory:available_selections()) do
													weapon.unit:base():add_ratio_plus_ammo(0.5)
												end
											end
										end
									end
								end
							end
							
							if not Global.game_settings.single_player then
								LuaNetworking:SendToPeers("shin_sync_hud_assault_color",tostring(self._activeassaultbreak))
							end
							--log("assaultbreakon")
						end
					end
				else
					self._heat_bonus_count = 0
					
					if self._activeassaultbreak then
						self._activeassaultbreak = nil
						self._activeassaultnextbreak_t = nil
						self._stopassaultbreak_t = nil
						if not Global.game_settings.single_player then
							LuaNetworking:SendToPeers("shin_sync_hud_assault_color",tostring(self._activeassaultbreak))
						end
					end
				end
			end
		end
		

		if managers.navigation:is_data_ready() and self._draw_enabled then
			self:_draw_enemy_activity(t)
			self:_draw_spawn_points()
		end
	end
end

-- Fix for the bug when there is too many dozers/specials thank you andole im sorry
local fixed = false
local origfunc2 = GroupAIStateBesiege._get_special_unit_type_count
function GroupAIStateBesiege:_get_special_unit_type_count(special_type, ...)
	
	if special_type == 'tank' then
		local res1 = origfunc2(self, 'tank', ...) or 0
		res1 = res1 + (origfunc2(self, 'tank_mini', ...) or 0)
		res1 = res1 + (origfunc2(self, 'tank_medic', ...) or 0)
		res1 = res1 + (origfunc2(self, 'tank_ftsu', ...) or 0)
		res1 = res1 + (origfunc2(self, 'tank_hw', ...) or 0)
		return res1
	end
	
	if special_type == 'spooc' then
		local res2 = origfunc2(self, 'spooc', ...) or 0
		res2 = res2 + (origfunc2(self, 'spooc_heavy', ...) or 0)
		return res2
	end
	
	if special_type == 'shield' then 
		local res3 = origfunc2(self, 'shield', ...) or 0
		res3 = res3 + (origfunc2(self, 'phalanx_minion', ...) or 0)
		res3 = res3 + (origfunc2(self, 'akuma', ...) or 0)
		return res3
	end
	
	if special_type == 'ninja' then
		local res4 = origfunc2(self, 'fbi', ...) or 0
		res4 = res4 + (origfunc2(self, 'fbi_xc45', ...) or 0)
		return res4
	end
	
	if special_type == 'medic' then
		local res5 = origfunc2(self, 'medic', ...) or 0
		res5 = res5 + (origfunc2(self, 'tank_medic', ...) or 0)
		return res5
	end
	
	return origfunc2(self, special_type, ...)
end

function GroupAIStateBesiege:chk_assault_number()
	if not self._assault_number then
		return 1
	end
	
	return self._assault_number
end

function GroupAIStateBesiege:chk_has_civilian_hostages()
	if self._police_hostage_headcount and self._hostage_headcount > 0 then
		if self._hostage_headcount - self._police_hostage_headcount > 0 then
			return true
		end
	end
end

function GroupAIStateBesiege:chk_no_fighting_atm()

	if self._drama_data.amount > tweak_data.drama.consistentcombat then
		return
	end
	
	return true
end

function GroupAIStateBesiege:chk_had_hostages()
	return self._had_hostages
end

function GroupAIStateBesiege:chk_anticipation()
	local assault_task = self._task_data.assault
	
	if assault_task and assault_task.phase == "anticipation" and assault_task.phase_end_t and assault_task.phase_end_t > self._t then
		return true
	end
	
	return
end

function GroupAIStateBesiege:chk_assault_active_atm()
	if self._fake_assault_mode then
		return true
	end

	local assault_task = self._task_data.assault
	
	if assault_task and assault_task.phase and assault_task.phase ~= "anticipation" then
		return true
	end
	
	return
end

function GroupAIStateBesiege:is_detection_persistent()
	return self._enemy_weapons_hot
end

function GroupAIStateBesiege:get_hostage_count_for_chatter()
	
	if self._hostage_headcount > 0 then
		return self._hostage_headcount
	end
	
	return 0
end

function GroupAIStateBesiege:chk_heat_bonus_retreat()
	return self._activeassaultbreak
end

function GroupAIStateBesiege:_upd_assault_areas(current_area)
	local all_areas = self._area_data
	local nav_manager = managers.navigation
	local all_nav_segs = nav_manager._nav_segments
	local task_data = self._task_data
	local t = self._t
	
	local assault_candidates = {}
	local assault_data = task_data.assault

	local found_areas = {}
	local to_search_areas = {}

	for area_id, area in pairs_g(all_areas) do
		if area.spawn_points then
			for _, sp_data in pairs_g(area.spawn_points) do
				if sp_data.delay_t <= t and not all_nav_segs[sp_data.nav_seg].disabled then
					table_insert(to_search_areas, area)

					found_areas[area_id] = true

					break
				end
			end
		end

		if not found_areas[area_id] and area.spawn_groups then
			for _, sp_data in pairs_g(area.spawn_groups) do
				if sp_data.delay_t <= t and not all_nav_segs[sp_data.nav_seg].disabled then
					table_insert(to_search_areas, area)

					found_areas[area_id] = true

					break
				end
			end
		end
	end

	if #to_search_areas == 0 then
		return current_area
	end

	if assault_candidates and self._char_criminals then
		for criminal_key, criminal_data in pairs_g(self._char_criminals) do
			if criminal_key and not criminal_data.status then
				local nav_seg = criminal_data.tracker:nav_segment()
				local area = self:get_area_from_nav_seg_id(nav_seg)
				found_areas[area] = true
				
				for _, nbr in pairs_g(area.neighbours) do
					found_areas[nbr] = true
				end

				table_insert(assault_candidates, area)
			end
		end
	end

	local i = 1

	repeat
		local area = to_search_areas[i]
		local force_factor = area.factors.force
		local demand = force_factor and force_factor.force
		local nr_police = table.size(area.police.units)
		local nr_criminals = table.size(area.criminal.units)

		if assault_candidates and self._player_criminals then
			for criminal_key, _ in pairs_g(area.criminal.units) do
				if criminal_key and self._player_criminals[criminal_key] then
					if not self._player_criminals[criminal_key].is_deployable then
						table_insert(assault_candidates, area)

						break
					end
				end
			end
		end

		if nr_criminals == 0 then
			for neighbour_area_id, neighbour_area in pairs_g(area.neighbours) do
				if not found_areas[neighbour_area_id] then
					table_insert(to_search_areas, neighbour_area)

					found_areas[neighbour_area_id] = true
				end
			end
		end

		i = i + 1
	until i > #to_search_areas

	if assault_candidates and #assault_candidates > 0 then
		return assault_candidates
	end	
end

function GroupAIStateBesiege:_upd_reenforce_tasks()
	local reenforce_tasks = self._task_data.reenforce.tasks
	local t = self._t
	local i = #reenforce_tasks

	while i > 0 do
		local task_data = reenforce_tasks[i]
		local going_after_objective_area = self._current_objective_area and task_data.target_area.id == self._current_objective_area.id
		local force_settings = task_data.target_area.factors.force
		local force_required = going_after_objective_area and 12 or force_settings and force_settings.force

		if force_required or going_after_objective_area then
			local force_occupied = 0

			for group_id, group in pairs(self._groups) do
				if (group.objective.target_area or group.objective.area) == task_data.target_area and group.objective.type == "reenforce_area" then
					force_occupied = force_occupied + (group.has_spawned and group.size or group.initial_size)
				end
			end

			local undershot = force_required - force_occupied

			if undershot > 0 and not self._task_data.regroup.active and self._task_data.assault.phase ~= "fade" and self._task_data.reenforce.next_dispatch_t < t and self:is_area_safe(task_data.target_area) then
				self:_try_use_task_spawn_event(t, task_data.target_area, "reenforce")

				local used_group, spawning_groups = nil

				if not used_event then
					if next(self._spawning_groups) then
						spawning_groups = true
					else
						local spawn_group, spawn_group_type = self:_find_spawn_group_near_area(task_data.target_area, self._tweak_data.reenforce.groups, nil, 6000, nil)

						if spawn_group then
							local grp_objective = {
								attitude = "avoid",
								scan = true,
								pose = "stand",
								type = "reenforce_area",
								stance = "hos",
								area = spawn_group.area,
								target_area = task_data.target_area
							}

							self:_spawn_in_group(spawn_group, spawn_group_type, grp_objective)

							used_group = true
						end
					end
				end

				if used_event or used_group then
					self._task_data.reenforce.next_dispatch_t = t + self:_get_difficulty_dependent_value(self._tweak_data.reenforce.interval)
				end
			elseif undershot < 0 then
				local force_defending = 0

				for group_id, group in pairs(self._groups) do
					if group.objective.area == task_data.target_area and group.objective.type == "reenforce_area" then
						force_defending = force_defending + (group.has_spawned and group.size or group.initial_size)
					end
				end

				local overshot = force_defending - force_required

				if overshot > 0 then
					local closest_group, closest_group_size = nil

					for group_id, group in pairs(self._groups) do
						if group.has_spawned and (group.objective.target_area or group.objective.area) == task_data.target_area and group.objective.type == "reenforce_area" and (not closest_group_size or closest_group_size < group.size) and group.size <= overshot then
							closest_group = group
							closest_group_size = group.size
						end
					end

					if closest_group then
						self:_assign_group_to_retire(closest_group)
					end
				end
			end
		else
			for group_id, group in pairs(self._groups) do
				if group.has_spawned and (group.objective.target_area or group.objective.area) == task_data.target_area and group.objective.type == "reenforce_area" then
					self:_assign_group_to_retire(group)
				end
			end

			reenforce_tasks[i] = reenforce_tasks[#reenforce_tasks]

			table.remove(reenforce_tasks)
		end

		i = i - 1
	end

	self:_assign_enemy_groups_to_reenforce()
end

function GroupAIStateBesiege:_begin_new_tasks()
	local all_areas = self._area_data
	local nav_manager = managers.navigation
	local all_nav_segs = nav_manager._nav_segments
	local task_data = self._task_data
	local t = self._t
	local reenforce_candidates = nil
	local reenforce_data = task_data.reenforce

	if reenforce_data.next_dispatch_t and reenforce_data.next_dispatch_t < t then
		reenforce_candidates = {}
	end

	local recon_candidates, are_recon_candidates_safe = nil
	local recon_data = task_data.recon

	if recon_data.next_dispatch_t and recon_data.next_dispatch_t < t and not task_data.assault.active and not task_data.regroup.active then
		recon_candidates = {}
	end

	local assault_candidates = nil
	local assault_data = task_data.assault

	if self._difficulty_value > 0 and assault_data.next_dispatch_t and assault_data.next_dispatch_t < t and not task_data.regroup.active then
		assault_candidates = {}
	end

	if not reenforce_candidates and not recon_candidates and not assault_candidates then
		return
	end

	local found_areas = {}
	local to_search_areas = {}

	for area_id, area in pairs_g(all_areas) do
		if area.spawn_points then
			for _, sp_data in pairs_g(area.spawn_points) do
				if sp_data.delay_t <= t and not all_nav_segs[sp_data.nav_seg].disabled then
					table_insert(to_search_areas, area)

					found_areas[area_id] = true

					break
				end
			end
		end

		if not found_areas[area_id] and area.spawn_groups then
			for _, sp_data in pairs_g(area.spawn_groups) do
				if sp_data.delay_t <= t and not all_nav_segs[sp_data.nav_seg].disabled then
					table_insert(to_search_areas, area)

					found_areas[area_id] = true

					break
				end
			end
		end
	end

	if #to_search_areas == 0 then
		return
	end

	if assault_candidates and self._char_criminals then
		for criminal_key, criminal_data in pairs_g(self._char_criminals) do
			if criminal_key and not criminal_data.status then
				local nav_seg = criminal_data.tracker:nav_segment()
				local area = self:get_area_from_nav_seg_id(nav_seg)
				found_areas[area] = true

				table_insert(assault_candidates, area)
			end
		end
	end
	

	local i = 1

	repeat
		local area = to_search_areas[i]
		local force_factor = area.factors.force
		local demand = force_factor and force_factor.force
		local nr_police = table.size(area.police.units)
		local nr_criminals = nil
		
		if area.criminal and area.criminal.units then
			nr_criminals = table.size(area.criminal.units)
		end

		if reenforce_candidates and demand and demand > 0 and nr_criminals and nr_criminals == 0 then
			local area_free = true

			for i_task, reenforce_task_data in ipairs(reenforce_data.tasks) do
				if reenforce_task_data.target_area == area then
					area_free = false

					break
				end
			end

			if area_free then
				table_insert(reenforce_candidates, area)
			end
		end

		if recon_candidates then
			if area.loot or area.hostages then
				local occupied = nil

				for group_id, group in pairs(self._groups) do
					if group.objective.target_area == area or group.objective.area == area then
						occupied = true

						break
					end
				end

				if not occupied then
					local is_area_safe = nr_criminals == 0

					if is_area_safe then
						if are_recon_candidates_safe then
							table_insert(recon_candidates, area)
						else
							are_recon_candidates_safe = true
							recon_candidates = {
								area
							}
						end
					elseif not are_recon_candidates_safe then
						table_insert(recon_candidates, area)
					end
				end
			else
				if nr_criminals and nr_criminals > 0 then
					table_insert(recon_candidates, area)
				end
			end
		end

		if recon_candidates or reenforce_candidates then
			for neighbour_area_id, neighbour_area in pairs(area.neighbours) do
				if not found_areas[neighbour_area_id] then
					table_insert(to_search_areas, neighbour_area)

					found_areas[neighbour_area_id] = true
				end
			end
		end

		i = i + 1
	until i > #to_search_areas

	if assault_candidates and #assault_candidates > 0 then
		self:_begin_assault_task(assault_candidates)

		recon_candidates = nil
	end

	if recon_candidates and #recon_candidates > 0 then
		local recon_area = nil
		
		for i = 1, #recon_candidates do
			local area = recon_candidates[i]
			recon_area = area
			
			if area.loot or area.hostages then
				break
			end
		end

		self:_begin_recon_task(recon_area)
	end
	
	if reenforce_candidates then
		if #self._registered_escorts > 0 then
			--local harass_escort = true
		end
		
		if self._current_objective_area then
			local guard_current_objective_area = 3
			local reenforce_tasks = reenforce_data.tasks
			
			for i = 1, #reenforce_tasks do
				if guard_current_objective_area <= 0 then
					guard_current_objective_area = nil
					
					break
				end
				
				reenforce_task_data = reenforce_tasks[i]
				
				if reenforce_task_data.target_area == self._current_objective_area then
					guard_current_objective_area = guard_current_objective_area - 1
				end
			end
			
			if guard_current_objective_area then
				table_insert(reenforce_candidates, self._current_objective_area)
			end
		end
	end

	if reenforce_candidates and #reenforce_candidates > 0 then
		local lucky_i_candidate = math_random(#reenforce_candidates)
		local reenforce_area = reenforce_candidates[lucky_i_candidate]

		self:_begin_reenforce_task(reenforce_area)

		recon_candidates = nil
	end
end

function GroupAIStateBesiege:_assign_enemy_groups_to_reenforce()
	for group_id, group in pairs(self._groups) do
		local grp_objective = group.objective
		
		if group.has_spawned and grp_objective.type == "reenforce_area" then
			local locked_up_in_area = nil
			
			if grp_objective.area and grp_objective.moving_out then
				local done_moving = nil
				
				for u_key, u_data in pairs(group.units) do
					local objective = u_data.unit:brain():objective()

					if objective then
						if objective.grp_objective ~= group.objective then
							-- Nothing
						elseif objective.in_place then
							done_moving = true
							
							break
						end
					end
				end

				if done_moving then
					group.objective.moving_out = nil
					group.in_place_t = self._t
					group.in_place = true
					
					if not grp_objective.moving_in then
						self:_voice_move_complete(group)
					end
					
					group.objective.moving_in = nil
				else
					group.in_place_t = nil
					group.in_place = nil
				end
			elseif grp_objective.area and not group.in_place_t then
				group.in_place_t = self._t
				group.in_place = true
			end

			if not group.objective.moving_in then
				if not group.objective.moving_out then
					self:_set_reenforce_objective_to_group(group)
				end
			end
		end
	end
end

function GroupAIStateBesiege:_set_reenforce_objective_to_group(group)
	if not group.has_spawned then
		return
	end

	local current_objective = group.objective

	if current_objective.target_area then
		if not group.in_place and not current_objective.moving_in then
			local forwardmost_i_nav_point = self:_get_group_forwardmost_coarse_path_index(group)

			if forwardmost_i_nav_point then
				for i = forwardmost_i_nav_point + 1, #current_objective.coarse_path do
					local nav_point = current_objective.coarse_path[forwardmost_i_nav_point]

					if not self:is_nav_seg_safe(nav_point[1]) then
						for i = 0, #current_objective.coarse_path - forwardmost_i_nav_point do
							table.remove(current_objective.coarse_path)
						end

						local grp_objective = {
							attitude = "avoid",
							scan = true,
							pose = "stand",
							type = "reenforce_area",
							stance = "hos",
							area = self:get_area_from_nav_seg_id(current_objective.coarse_path[#current_objective.coarse_path][1]),
							target_area = current_objective.target_area
						}

						self:_set_objective_to_enemy_group(group, grp_objective)

						return
					end
				end
			end
		end

		if group.in_place and not current_objective.area.neighbours[current_objective.target_area.id] then
			local search_params = {
				id = "GroupAI_reenforce",
				from_seg = current_objective.area.pos_nav_seg,
				to_seg = current_objective.target_area.pos_nav_seg,
				access_pos = self._get_group_acces_mask(group),
				verify_clbk = callback(self, self, "is_nav_seg_safe")
			}
			local coarse_path = managers.navigation:search_coarse(search_params)

			if coarse_path then
				self:_merge_coarse_path_by_area(coarse_path)
				table.remove(coarse_path)

				local grp_objective = {
					scan = true,
					pose = "stand",
					type = "reenforce_area",
					stance = "hos",
					attitude = "avoid",
					area = self:get_area_from_nav_seg_id(coarse_path[#coarse_path][1]),
					target_area = current_objective.target_area,
					coarse_path = coarse_path
				}

				self:_set_objective_to_enemy_group(group, grp_objective)
			end
		end

		if group.in_place and current_objective.area.neighbours[current_objective.target_area.id] and not next(current_objective.target_area.criminal.units) then
			local grp_objective = {
				stance = "hos",
				scan = true,
				pose = "crouch",
				type = "reenforce_area",
				attitude = "engage",
				area = current_objective.target_area
			}

			self:_set_objective_to_enemy_group(group, grp_objective)

			group.objective.moving_in = true
		end
	end
end

function GroupAIStateBesiege:_begin_assault_task(assault_areas)
	local assault_task = self._task_data.assault
	self._skip_phase = nil
	assault_task.active = true
	assault_task.next_dispatch_t = nil
	assault_task.target_areas = assault_areas or self:_upd_assault_areas(nil)
	self._current_target_area = self._task_data.assault.target_areas[1]
	
	if self._street then 
		if self._current_objective_pos then
			local area_pos = self._current_objective_pos:with_z(0)
			local primary_target_area_pos = self._task_data.assault.target_areas[1].pos:with_z(0)
			mvec3_dir(area_pos, primary_target_area_pos, area_pos)
			self._current_objective_dis = mvec3_dis_sq(primary_target_area_pos, area_pos)
			self._current_objective_dir = area_pos
		else
			self._current_objective_dis = nil
			self._current_objective_dir = nil
		end
	end
	
	self._used_assault_area_i = 0
	local anticipation_duration = self:_get_anticipation_duration(self._tweak_data.assault.anticipation_duration, assault_task.is_first)
	
	if self._hunt_mode then
		anticipation_duration = 0
	end

	assault_task.phase = "anticipation"
	assault_task.phase_end_t = self._t + anticipation_duration
	
	managers.hud:setup_anticipation(anticipation_duration)
	managers.hud:start_anticipation()
	
	assault_task.start_t = self._t
	
	assault_task.force_anticipation = 16
	assault_task.is_first = nil
	self._force_pool = nil
	self._enemies_killed_sustain = 0
	--self._enemies_killed_sustain_guaranteed_break = nil
	
	if not self._downleniency or self._downleniency < 1 then
		self._downleniency = 1
		--log("resetting down leniency")
	end
	
	if self._assault_was_hell then
		--log("resetting break from hell")
		self._assault_was_hell = nil
	end
	
	self:_check_drama_low_p()
	
	if managers.skirmish:is_skirmish() then
		local force_table = {
			40,
			48,
			64,
			64,
			64,
			64,
			64,
			68,
			72,
			84
		}
		local wave = math_clamp(managers.skirmish:current_wave_number(), 1, #force_table)
		local force_to_use = force_table[wave]
		assault_task.force = force_to_use * self:_get_balancing_multiplier(self._tweak_data.assault.force_balance_mul)
	else
		assault_task.force = math.ceil(self:_get_difficulty_dependent_value(self._tweak_data.assault.force) * self:_get_balancing_multiplier(self._tweak_data.assault.force_balance_mul))
	end
	
	local nr_players = 0
	
	for u_key, u_data in pairs(self:all_player_criminals()) do
		if not u_data.status then
			nr_players = nr_players + 1
		end
	end
	
	if assault_task.force and nr_players > 4 then
		assault_task.force = assault_task.force * 1.25
	end
	
	--assault_task.use_smoke = true
	--assault_task.use_smoke_timer = 0
	assault_task.use_spawn_event = true
	assault_task.force_spawned = 0

	self._downs_during_assault = 0

	if self._draw_drama then
		table_insert(self._draw_drama.assault_hist, {
			self._t
		})
	end
	
	self:_assign_recon_groups_to_retire()

	self._task_data.recon.tasks = {}
end

function GroupAIStateBesiege:assault_phase_end_time()
	local task_data = self._task_data.assault
	local end_t = task_data and task_data.phase_end_t
	
	local assault_number_sustain_t_mul = nil
	
	if task_data.is_first or self._assault_number and self._assault_number <= 2 or not self._assault_number then
		assault_number_sustain_t_mul = 0.75
	elseif self._assault_number >= 3 then
		assault_number_sustain_t_mul = 1
	end

	if end_t and task_data.phase == "sustain" then
		end_t = managers.modifiers:modify_value("GroupAIStateBesiege:SustainEndTime", end_t) * assault_number_sustain_t_mul
	end

	return end_t
end

function GroupAIStateBesiege:set_wave_mode(flag)
	local old_wave_mode = self._wave_mode
	self._wave_mode = flag
	self._hunt_mode = nil

	if flag == "hunt" then
		self:get_assault_hud_state()
		self._hunt_mode = true
		self._wave_mode = "besiege"

		managers.hud:start_assault(self._assault_number)
		--self:_set_rescue_state(true)
		self:set_assault_mode(true)
		managers.trade:set_trade_countdown(false)
		self:_end_regroup_task()
		
		
		if self._task_data.assault.active then
			self._task_data.assault.phase = "sustain"
			--self._task_data.use_smoke = true
			--self._task_data.use_smoke_timer = 0
		else
			self._task_data.assault.next_dispatch_t = self._t
		end
	elseif flag == "besiege" then
		self:get_assault_hud_state()
		
		if self._task_data.regroup.active then
			self._task_data.assault.next_dispatch_t = self._task_data.regroup.end_t
		elseif not self._task_data.assault.active then
			self._task_data.assault.next_dispatch_t = self._t
		end
	elseif flag == "quiet" then
		self._hunt_mode = nil
	else
		self._wave_mode = old_wave_mode

		debug_pause("[GroupAIStateBesiege:set_wave_mode] flag", flag, " does not apply to the current Group AI state.")
	end
end
		
function GroupAIStateBesiege:_upd_assault_task() 
	local task_data = self._task_data.assault
	local assault_number_sustain_t_mul = nil

	
	if task_data.is_first or not self._assault_number then
		assault_number_sustain_t_mul = 0.75
	elseif self._assault_number >= 3 then
		assault_number_sustain_t_mul = 1
	else
		assault_number_sustain_t_mul = 0.75
	end
	
	if not task_data.active then
		self._skip_phase = nil
		return
	end

	local t = self._t
	
	local diff_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)

	local force_pool = nil 
	
	if managers.skirmish:is_skirmish() then
		local force_pool_table = {
			64,
			64,
			96,
			128,
			144,
			160,
			176,
			240,
			304,
			400
		}
		local wave = math_clamp(managers.skirmish:current_wave_number(), 1, #force_pool_table)
		local force_pool_to_use = force_pool_table[wave]
		force_pool = force_pool_to_use * self:_get_balancing_multiplier(self._tweak_data.assault.force_pool_balance_mul)
	elseif task_data.is_first or self._assault_number and self._assault_number <= 1 or not self._assault_number then
		force_pool = self:_get_difficulty_dependent_value(self._tweak_data.assault.force_pool) * 0.75
		force_pool = force_pool * self:_get_balancing_multiplier(self._tweak_data.assault.force_pool_balance_mul)
	elseif self._assault_number == 2 then
		force_pool = self:_get_difficulty_dependent_value(self._tweak_data.assault.force_pool) * 0.8
		force_pool = force_pool * self:_get_balancing_multiplier(self._tweak_data.assault.force_pool_balance_mul)
	elseif self._assault_number >= 3 then
		force_pool = self:_get_difficulty_dependent_value(self._tweak_data.assault.force_pool) * self:_get_balancing_multiplier(self._tweak_data.assault.force_pool_balance_mul)
	end
	
	local enemies_spawned = task_data.force_spawned
	
	if self._hunt_mode or task_data.phase == "anticipation" or task_data.phase == "build" then
		enemies_spawned = 0
	end
	
	local enemykillcountchk = force_pool * 0.75
	
	if not self._force_pool then
		self._force_pool = force_pool
		self._enemies_killed_sustain_guaranteed_break = nil
	end
	
	local task_spawn_allowance = force_pool - enemies_spawned
	
	if task_data.phase == "anticipation" then
		if task_spawn_allowance <= 0 and self._enemies_killed_sustain >= enemykillcountchk then
			--fade
			task_data.phase = "fade"
			task_data.phase_end_t = t + self._tweak_data.assault.fade_duration
		elseif task_data.phase_end_t < t and self._drama_data.amount >= tweak_data.drama.assaultstart or self._hunt_mode or self._skip_phase then --if drama is high and there are 5 or more enemies engaging all players, start the assault and drop the bass
			self._assault_number = self._assault_number + 1
			
			self._skip_phase = nil

			managers.mission:call_global_event("start_assault")
			managers.hud:start_assault(self._assault_number)
			managers.groupai:dispatch_event("start_assault", self._assault_number)
			--self:_set_rescue_state(true)
			
			for group_id, group in pairs(self._groups) do
				for u_key, u_data in pairs(group.units) do
					u_data.unit:sound():say("att", true)
				end
			end
			
			if Network:is_server() then
				if managers.modifiers:check_boolean("itmightrain") then
					self._enemy_speed_mul = self._enemy_speed_mul + 0.1
				end
				
				if not Global.game_settings.single_player then
					LuaNetworking:SendToPeers("shin_sync_speed_mul",tostring(self._enemy_speed_mul))
				end
			end

			task_data.phase = "build"
			task_data.phase_end_t = self._t + self._tweak_data.assault.build_duration
			self._had_hostages = nil
			task_data.is_hesitating = nil

			self:set_assault_mode(true)
			managers.trade:set_trade_countdown(false)
		else
			managers.hud:check_anticipation_voice(task_data.phase_end_t - t)
			managers.hud:check_start_anticipation_music(task_data.phase_end_t - t)
		end
	elseif task_data.phase == "build" then
		if task_spawn_allowance <= 0 and self._enemies_killed_sustain >= enemykillcountchk then
			task_data.phase = "fade"
			task_data.phase_end_t = t + self._tweak_data.assault.fade_duration
			local time = self._t
			for group_id, group in pairs(self._groups) do
				for u_key, u_data in pairs(group.units) do
					local nav_seg_id = u_data.tracker:nav_segment()
					local current_objective = group.objective
					if current_objective.coarse_path then
						if not u_data.unit:sound():speaking(time) then
							u_data.unit:sound():say("m01", true)
						end	
					end					   
				end	
			end
		elseif task_data.phase_end_t < t or self._skip_phase then
			local sustain_duration = math_lerp(self:_get_difficulty_dependent_value(self._tweak_data.assault.sustain_duration_min), self:_get_difficulty_dependent_value(self._tweak_data.assault.sustain_duration_max), math_random()) * self:_get_balancing_multiplier(self._tweak_data.assault.sustain_duration_balance_mul) * assault_number_sustain_t_mul
			
			self._skip_phase = nil
			
			managers.modifiers:run_func("OnEnterSustainPhase", sustain_duration)
		
			self._task_data.assault.phase = "sustain"
			self._task_data.assault.phase_end_t = t
		end
	elseif task_data.phase == "sustain" then
		task_spawn_allowance = managers.modifiers:modify_value("GroupAIStateBesiege:SustainSpawnAllowance", task_spawn_allowance, force_pool)

		if task_spawn_allowance <= 0 and self._enemies_killed_sustain >= enemykillcountchk then
			task_data.phase = "fade"
			task_data.phase_end_t = t + self._tweak_data.assault.fade_duration
			
			local time = self._t
				for group_id, group in pairs(self._groups) do
					for u_key, u_data in pairs(group.units) do
						local nav_seg_id = u_data.tracker:nav_segment()
						local current_objective = group.objective
						if current_objective.coarse_path then
							if not u_data.unit:sound():speaking(time) then
								u_data.unit:sound():say("m01", true)
							end	
						end					   
					end	
				end	
		elseif self._task_data.assault.phase_end_t < t and self._enemies_killed_sustain >= enemykillcountchk and not self._hunt_mode or self._skip_phase and not self._hunt_mode then
			self._skip_phase = nil
			task_data.phase = "fade"
			task_data.phase_end_t = t + self._tweak_data.assault.fade_duration
		end
	else
		local end_assault = false
		local enemies_left = self:_count_police_force("assault")

		if not self._hunt_mode then
			local enemies_defeated_time_limit = 60
			local drama_engagement_time_limit = 60
			local min_enemies_left = 256 * 0.1

			if managers.skirmish:is_skirmish() then	
				min_enemies_left = 15
				enemies_defeated_time_limit = 0
				drama_engagement_time_limit = 0
			end
			
			 --enemies remaining before considering all enemies defeated
			local enemies_defeated = enemies_left <= min_enemies_left
			local taking_too_long = t > task_data.phase_end_t + enemies_defeated_time_limit
			local fade_time_over = t > task_data.phase_end_t 
			--self:_assign_assault_groups_to_retire()
			if enemies_defeated or taking_too_long or self._skip_phase then
				if not task_data.said_retreat then
					self._task_data.assault.said_retreat = true

					self:_police_announce_retreat()
					self:_assign_assault_groups_to_retire()
					local time = self._t
					for group_id, group in pairs(self._groups) do
						for u_key, u_data in pairs(group.units) do
							local nav_seg_id = u_data.tracker:nav_segment()
							local current_objective = group.objective
							if current_objective.coarse_path then
								if not u_data.unit:sound():speaking(time) then
									u_data.unit:sound():say("m01", true)
								end	
							end					   
						end	
					end
					
					self._skip_phase = nil
				elseif self._skip_phase or fade_time_over and not self._activeassaultbreak then
					local drama_pass = self._drama_data.amount < tweak_data.drama.assault_fade_end --if there is no active fighting going on
					local taking_too_long = t > task_data.phase_end_t + drama_engagement_time_limit
					
					--if engagement_pass then
						--log("engagement check")
					--end
					
					--if drama_pass then
						--log("drama check")
					--end
					
					--if taking_too_long then 
						--log("i cant believe they kited cops fuglore would never do this im literally shaking and crying right now")
					--end
					
					if self._skip_phase or drama_pass and fade_time_over or taking_too_long then
						self._skip_phase = nil
						end_assault = true
					end
				end
			end

			if task_data.force_end or end_assault then
				--print("assault task clear")

				task_data.active = nil
				task_data.phase = nil
				task_data.said_retreat = nil
				task_data.force_end = nil
				local force_regroup = task_data.force_regroup
				task_data.force_regroup = nil

				if self._draw_drama then
					self._draw_drama.assault_hist[#self._draw_drama.assault_hist][2] = t
				end

				managers.mission:call_global_event("end_assault")
				self:_begin_regroup_task(force_regroup)
				
				return
			end
		end
	end
	
	local primary_target_area = task_data.target_areas[1]

	if self:is_area_safe_assault(primary_target_area) then
		local target_pos = primary_target_area.pos
		local nearest_area, nearest_dis = nil

		for criminal_key, criminal_data in pairs_g(self._player_criminals) do
			if not criminal_data.status then
				local dis = mvec3_dis_sq(target_pos, criminal_data.m_pos)

				if not nearest_dis or dis < nearest_dis then
					nearest_dis = dis
					nearest_area = self:get_area_from_nav_seg_id(criminal_data.tracker:nav_segment())
				end
			end
		end

		if nearest_area then
			primary_target_area = nearest_area
			task_data.target_areas[1] = nearest_area
		end
		
		if self._street then 
			if self._current_objective_pos then
				local area_pos = self._current_objective_pos:with_z(0)
				local primary_target_area_pos = self._task_data.assault.target_areas[1].pos:with_z(0)
				mvec3_dir(area_pos, primary_target_area_pos, area_pos)
				self._current_objective_dis = mvec3_dis_sq(primary_target_area_pos, area_pos)
				self._current_objective_dir = area_pos
			else
				self._current_objective_dis = nil
				self._current_objective_dir = nil
			end
		end
	end
	
	if task_data.phase ~= "fade" then
		if not task_data.use_smoke_timer or task_data.use_smoke_timer < t then
			task_data.use_smoke = true
		end
	end

	self:detonate_queued_smoke_grenades()
	
	local enemies_wanted = next(self._bosses) and 16 or task_data.force
	local enemy_count = self:_count_police_force("assault")	
	
	local nr_wanted = enemies_wanted - enemy_count
	--local enemies_wanted = task_data.force * 0.25
	
	local low_carnage = self:_count_criminals_engaged_force(4) <= 8
	
	if primary_target_area and nr_wanted > 0 and not self._activeassaultbreak then
		if task_data.phase ~= "fade" or self._hunt_mode then 
			local used_event = next(self._spawning_groups)
			local phase = task_data.phase
			local anticipation = self._activeassaultbreak or self:chk_anticipation()

			if not used_event then
				if not anticipation or self._hunt_mode then
					used_event = self:_try_use_task_spawn_event(t, primary_target_area, "assault")
				end
				
				if not used_event and not self._activeassaultbreak then
					--local max_dis = self._street and 6000 or 12000
					local spawn_group, spawn_group_type = self:_find_spawn_group_near_area(primary_target_area, self._tweak_data.assault.groups, primary_target_area.pos, 12000, anticipation and callback(self, self, "_verify_anticipation_spawn_point") or nil)

					if spawn_group then
						local grp_objective = {
							attitude = self._street and "avoid" or anticipation and "avoid" or "engage",
							stance = "hos",
							pose = anticipation and "crouch" or "stand",
							type = "assault_area",
							area = self:get_area_from_nav_seg_id(spawn_group.nav_seg)
						}

						self:_spawn_in_group(spawn_group, spawn_group_type, grp_objective, task_data)
					end
				end
			end
		end
	end
	
	self:_assign_enemy_groups_to_assault(task_data.phase)
end

function GroupAIStateBesiege:_upd_recon_tasks()
	local task_data = self._task_data.recon.tasks[1]

	self:_assign_enemy_groups_to_recon()

	if not task_data then
		return
	end

	local t = self._t

	self:_assign_assault_groups_to_retire()

	local target_pos = task_data.target_area.pos
	local nr_wanted = self:_get_difficulty_dependent_value(self._tweak_data.recon.force) - self:_count_police_force("recon")

	if nr_wanted <= 0 then
		return
	end

	local used_event, used_spawn_points, reassigned = nil

	if task_data.use_spawn_event then
		if self:_try_use_task_spawn_event(t, task_data.target_area, "recon") then
			used_event = true
		end
	end

	local used_group = nil

	if next(self._spawning_groups) then
		used_group = true
	else
		local spawn_group, spawn_group_type = self:_find_spawn_group_near_area(task_data.target_area, self._tweak_data.recon.groups, nil, nil, nil)

		if spawn_group then
			local grp_objective = {
				attitude = "avoid",
				scan = true,
				stance = "hos",
				type = "recon_area",
				area = task_data.target_area,
				target_area = task_data.target_area
			}

			self:_spawn_in_group(spawn_group, spawn_group_type, grp_objective)

			used_group = true
		end
	end

	if used_event or used_spawn_points or reassigned then
		table.remove(self._task_data.recon.tasks, 1)

		self._task_data.recon.next_dispatch_t = t + 10 * math.random()
	end
end

function GroupAIStateBesiege:_assign_enemy_groups_to_recon()
	for group_id, group in pairs(self._groups) do
		if group.has_spawned and group.objective.type == "recon_area" then
			if group.objective.moving_out then
				local done_moving = nil
				
				for u_key, u_data in pairs(group.units) do
					local objective = u_data.unit:brain():objective()

					if objective then
						if objective.grp_objective ~= group.objective then
							-- Nothing
						elseif objective.in_place then
							done_moving = true
							
							break
						end
					end
				end
				
				if done_moving then
					if group.objective.moved_in then
						group.visited_areas = group.visited_areas or {}
						group.visited_areas[group.objective.area] = true
					end

					group.objective.moving_out = nil
					group.in_place_t = self._t
					group.in_place = true
					group.objective.moving_in = nil

					self:_voice_move_complete(group)
				end
			end

			if not group.objective.moving_in then
				self:_set_recon_objective_to_group(group)
			end
		end
	end
end

function GroupAIStateBesiege:_set_recon_objective_to_group(group)
	local current_objective = group.objective
	local target_area = current_objective.target_area or current_objective.area

	if not target_area.loot and not target_area.hostages or not group.in_place and current_objective.moved_in and group.in_place_t and self._t - group.in_place_t > 15 then
		local recon_area = nil
		local to_search_areas = {
			current_objective.area
		}
		local found_areas = {
			[current_objective.area] = "init"
		}

		repeat
			local search_area = table.remove(to_search_areas, 1)

			if search_area.loot or search_area.hostages then
				local occupied = nil

				for test_group_id, test_group in pairs(self._groups) do
					if test_group ~= group and (test_group.objective.target_area == search_area or test_group.objective.area == search_area) then
						occupied = true

						break
					end
				end

				if not occupied and group.visited_areas and group.visited_areas[search_area] then
					occupied = true
				end

				if not occupied then
					local is_area_safe = not next(search_area.criminal.units)

					if is_area_safe then
						recon_area = search_area

						break
					else
						recon_area = recon_area or search_area
					end
				end
			end

			if not next(search_area.criminal.units) then
				for other_area_id, other_area in pairs(search_area.neighbours) do
					if not found_areas[other_area] then
						table.insert(to_search_areas, other_area)

						found_areas[other_area] = search_area
					end
				end
			end
		until #to_search_areas == 0

		if recon_area then
			local coarse_path = {
				{
					recon_area.pos_nav_seg,
					recon_area.pos
				}
			}
			local last_added_area = recon_area

			while found_areas[last_added_area] ~= "init" do
				last_added_area = found_areas[last_added_area]

				table.insert(coarse_path, 1, {
					last_added_area.pos_nav_seg,
					last_added_area.pos
				})
			end

			local grp_objective = {
				scan = true,
				pose = "stand",
				type = "recon_area",
				stance = "hos",
				attitude = "avoid",
				area = current_objective.area,
				target_area = recon_area,
				coarse_path = coarse_path
			}

			self:_set_objective_to_enemy_group(group, grp_objective)

			current_objective = group.objective
		end
	end

	if current_objective.target_area then
		if not group.in_place and not current_objective.moving_in and current_objective.coarse_path then
			local forwardmost_i_nav_point = self:_get_group_forwardmost_coarse_path_index(group)

			if forwardmost_i_nav_point and forwardmost_i_nav_point > 1 then
				for i = forwardmost_i_nav_point + 1, #current_objective.coarse_path do
					local nav_point = current_objective.coarse_path[forwardmost_i_nav_point]

					if not self:is_nav_seg_safe(nav_point[1]) then
						for i = 0, #current_objective.coarse_path - forwardmost_i_nav_point do
							table.remove(current_objective.coarse_path)
						end

						local grp_objective = {
							attitude = "avoid",
							scan = true,
							pose = "stand",
							type = "recon_area",
							stance = "hos",
							area = self:get_area_from_nav_seg_id(current_objective.coarse_path[#current_objective.coarse_path][1]),
							target_area = current_objective.target_area
						}

						self:_set_objective_to_enemy_group(group, grp_objective)

						return
					end
				end
			end
		end

		if group.in_place and not current_objective.area.neighbours[current_objective.target_area.id] then
			local search_params = {
				id = "GroupAI_recon",
				from_seg = current_objective.area.pos_nav_seg,
				to_seg = current_objective.target_area.pos_nav_seg,
				access_pos = self._get_group_acces_mask(group),
				verify_clbk = callback(self, self, "is_nav_seg_safe")
			}
			local coarse_path = managers.navigation:search_coarse(search_params)

			if coarse_path then
				self:_merge_coarse_path_by_area(coarse_path)
				table.remove(coarse_path)

				local grp_objective = {
					scan = true,
					pose = "stand",
					type = "recon_area",
					stance = "hos",
					attitude = "avoid",
					area = self:get_area_from_nav_seg_id(coarse_path[#coarse_path][1]),
					target_area = current_objective.target_area,
					coarse_path = coarse_path
				}

				self:_set_objective_to_enemy_group(group, grp_objective)
			end
		end

		if group.in_place and current_objective.area.neighbours[current_objective.target_area.id] then
			local grp_objective = {
				stance = "hos",
				scan = true,
				pose = "crouch",
				type = "recon_area",
				attitude = "avoid",
				area = current_objective.target_area
			}

			self:_set_objective_to_enemy_group(group, grp_objective)

			group.objective.moving_in = true
			group.objective.moved_in = true

			if next(current_objective.target_area.criminal.units) then
				self:_chk_group_use_smoke_grenade(group, {
					use_smoke = true,
					target_areas = {
						grp_objective.area
					}
				})
			end
		end
	end
end

function GroupAIStateBesiege:_assign_group_to_retire(group)
	local retire_area, retire_pos = nil
	local start_area = group.objective.area
	
	if not start_area then
		local group_leader_u_key, group_leader_u_data = self._determine_group_leader(group.units)
		if group_leader_u_data then
			start_area = group_leader_u_data and self:get_area_from_nav_seg_id(group_leader_u_data.tracker:nav_segment())
		else
			for u_key, u_data in pairs_g(group.units) do
				start_area = self:get_area_from_nav_seg_id(u_data.tracker:nav_segment())
				
				if start_area then
					break
				end
			end
		end
	end
	
	local to_search_areas = {
		start_area
	}
	local found_areas = {
		[start_area] = true
	}

	repeat
		local search_area = table.remove(to_search_areas, 1)

		if search_area.flee_points and next(search_area.flee_points) then
			retire_area = search_area
			local flee_point_id, flee_point = next(search_area.flee_points)
			retire_pos = flee_point.pos

			break
		else
			for other_area_id, other_area in pairs(search_area.neighbours) do
				if not found_areas[other_area] then
					table.insert(to_search_areas, other_area)

					found_areas[other_area] = true
				end
			end
		end
	until #to_search_areas == 0

	if not retire_area then
		Application:error("[GroupAIStateBesiege:_assign_group_to_retire] flee point not found. from area:", inspect(group.objective.area), "group ID:", group.id)

		return
	end

	local grp_objective = {
		type = "retire",
		area = retire_area or group.objective.area,
		coarse_path = {
			{
				retire_area.pos_nav_seg,
				retire_area.pos
			}
		},
		pos = retire_pos
	}

	self:_set_objective_to_enemy_group(group, grp_objective)
end

function GroupAIStateBesiege:_get_special_unit_type_count(special_type)
	if not self._special_units[special_type] then
		return 0
	end

	return table.size(self._special_units[special_type])
end

function GroupAIStateBesiege:_spawn_in_group(spawn_group, spawn_group_type, grp_objective, ai_task)
	local spawn_group_desc = tweak_data.group_ai.enemy_spawn_groups[spawn_group_type]
	local wanted_nr_units = nil

	if type(spawn_group_desc.amount) == "number" then
		wanted_nr_units = spawn_group_desc.amount
	else
		wanted_nr_units = math_random(spawn_group_desc.amount[1], spawn_group_desc.amount[2])
	end

	local valid_unit_types = {}

	self._extract_group_desc_structure(spawn_group_desc.spawn, valid_unit_types)

	local unit_categories = tweak_data.group_ai.unit_categories
	local total_wgt = 0
	local i = 1

	while i <= #valid_unit_types do
		local spawn_entry = valid_unit_types[i]
		local cat_data = unit_categories[spawn_entry.unit]

		if not cat_data then
			debug_pause("[GroupAIStateBesiege:_spawn_in_group] unit category doesn't exist:", spawn_entry.unit)

			return
		end

		if cat_data.special_type and not cat_data.is_captain then
			local spawn_limit = managers.job:current_spawn_limit(cat_data.special_type)
		
			if self._spawned_megatank_t and cat_data.special_type == "tank" and self._spawned_megatank_t > self._t then
				--log("dick")
				spawn_group.delay_t = self._t + 2
				
				return
			elseif spawn_limit > self:_get_special_unit_type_count(cat_data.special_type) + (spawn_entry.amount_min or 0) then
				total_wgt = total_wgt + spawn_entry.freq
				i = i + 1
			else
				spawn_group.delay_t = self._t + 2
				return
			end
		else
			total_wgt = total_wgt + spawn_entry.freq
			i = i + 1
		end
	end

	for i = 1, #spawn_group.spawn_pts do
		local sp_data = spawn_group.spawn_pts[i]
		sp_data.delay_t = self._t + math.random()
	end

	local spawn_task = {
		objective = not grp_objective.element and self._create_objective_from_group_objective(grp_objective),
		units_remaining = {},
		spawn_group = spawn_group,
		spawn_group_type = spawn_group_type,
		ai_task = ai_task
	}

	table.insert(self._spawning_groups, spawn_task)

	local function _add_unit_type_to_spawn_task(i, spawn_entry)
		local spawn_amount_mine = 1 + (spawn_task.units_remaining[spawn_entry.unit] and spawn_task.units_remaining[spawn_entry.unit].amount or 0)
		spawn_task.units_remaining[spawn_entry.unit] = {
			amount = spawn_amount_mine,
			spawn_entry = spawn_entry
		}
		wanted_nr_units = wanted_nr_units - 1

		if spawn_entry.amount_min then
			spawn_entry.amount_min = spawn_entry.amount_min - 1
		end

		if spawn_entry.amount_max then
			spawn_entry.amount_max = spawn_entry.amount_max - 1
			
			local cat_data = unit_categories[spawn_entry.unit]

			if not cat_data then
				debug_pause("[GroupAIStateBesiege:_spawn_in_group] unit category doesn't exist:", spawn_entry.unit)

				return
			end
			
			if cat_data.special_type then
				local spawn_limit = managers.job:current_spawn_limit(cat_data.special_type)
				
				if spawn_limit > self:_get_special_unit_type_count(cat_data.special_type) + spawn_amount_mine then
					table.remove(valid_unit_types, i)

					total_wgt = total_wgt - spawn_entry.freq

					return true
				end
			end
			
			if spawn_entry.amount_max == 0 then
				table.remove(valid_unit_types, i)

				total_wgt = total_wgt - spawn_entry.freq

				return true
			end
		else
			local cat_data = unit_categories[spawn_entry.unit]

			if not cat_data then
				debug_pause("[GroupAIStateBesiege:_spawn_in_group] unit category doesn't exist:", spawn_entry.unit)

				return
			end
			
			if cat_data.special_type then
				local spawn_limit = managers.job:current_spawn_limit(cat_data.special_type)
				
				if spawn_limit > self:_get_special_unit_type_count(cat_data.special_type) + spawn_amount_mine then
					table.remove(valid_unit_types, i)

					total_wgt = total_wgt - spawn_entry.freq

					return true
				end
			end
		end
	end

	local i = 1

	while i <= #valid_unit_types do
		local spawn_entry = valid_unit_types[i]

		if i <= #valid_unit_types and wanted_nr_units > 0 and spawn_entry.amount_min and spawn_entry.amount_min > 0 and (not spawn_entry.amount_max or spawn_entry.amount_max > 0) then
			if not _add_unit_type_to_spawn_task(i, spawn_entry) then
				i = i + 1
			end
		else
			i = i + 1
		end
	end

	while wanted_nr_units > 0 and #valid_unit_types ~= 0 do
		local rand_wght = math_random() * total_wgt
		local rand_i = 1
		local rand_entry = nil

		repeat
			rand_entry = valid_unit_types[rand_i]
			rand_wght = rand_wght - rand_entry.freq

			if rand_wght <= 0 then
				break
			else
				rand_i = rand_i + 1
			end
		until false

		local cat_data = unit_categories[rand_entry.unit]
		local spawn_limit = managers.job:current_spawn_limit(cat_data.special_type)

		if cat_data.special_type and not cat_data.is_captain and spawn_limit <= self:_get_special_unit_type_count(cat_data.special_type) then
			table.remove(valid_unit_types, rand_i)

			total_wgt = total_wgt - rand_entry.freq
		else
			_add_unit_type_to_spawn_task(rand_i, rand_entry)
		end
	end

	local group_desc = {
		size = 0,
		type = spawn_group_type
	}

	for u_name, spawn_info in pairs(spawn_task.units_remaining) do
		group_desc.size = group_desc.size + spawn_info.amount
	end

	local group = self:_create_group(group_desc)
	
	self:_set_objective_to_enemy_group(group, grp_objective)
	group.team = self._teams[spawn_group.team_id or tweak_data.levels:get_default_team_ID("combatant")]
	spawn_task.group = group

	return group
end

function GroupAIStateBesiege:is_smoke_grenade_active() --this functions differently, check for if use_smoke IS a thing instead
	if not self._task_data.assault.use_smoke then
		return
	end
	
	return self._task_data.assault.use_smoke
end

function GroupAIStateBesiege:_set_reenforce_objective_to_group(group)
	if not group.has_spawned then
		return
	end

	local current_objective = group.objective

	if current_objective.target_area then
		if not group.in_place and not current_objective.moving_in then
			local forwardmost_i_nav_point = self:_get_group_forwardmost_coarse_path_index(group)

			if forwardmost_i_nav_point then
				for i = forwardmost_i_nav_point + 1, #current_objective.coarse_path do
					local nav_point = current_objective.coarse_path[forwardmost_i_nav_point]

					if not self:is_nav_seg_safe(nav_point[1]) then
						for i = 0, #current_objective.coarse_path - forwardmost_i_nav_point do
							table_remove(current_objective.coarse_path)
						end

						local grp_objective = {
							attitude = "engage",
							scan = true,
							pose = "stand",
							type = "reenforce_area",
							stance = "hos",
							area = self:get_area_from_nav_seg_id(current_objective.coarse_path[#current_objective.coarse_path][1]),
							target_area = current_objective.target_area
						}

						self:_set_objective_to_enemy_group(group, grp_objective)

						return
					end
				end
			end
		end

		if group.in_place and not current_objective.area.neighbours[current_objective.target_area.id] then
			local search_params = {
				id = "GroupAI_reenforce",
				from_seg = current_objective.area.pos_nav_seg,
				to_seg = current_objective.target_area.pos_nav_seg,
				access_pos = self._get_group_acces_mask(group),
				verify_clbk = callback(self, self, "is_nav_seg_safe")
			}
			local coarse_path = managers.navigation:search_coarse(search_params)

			if coarse_path then
				self:_merge_coarse_path_by_area(coarse_path)
				
				local grp_objective = {
					scan = true,
					pose = "stand",
					type = "reenforce_area",
					stance = "hos",
					attitude = "engage",
					area = self:get_area_from_nav_seg_id(coarse_path[#coarse_path][1]),
					target_area = current_objective.target_area,
					coarse_path = coarse_path
				}

				self:_set_objective_to_enemy_group(group, grp_objective)
				--table_remove(coarse_path)
			end
		end

		if group.in_place and current_objective.area.neighbours[current_objective.target_area.id] then
			local grp_objective = {
				stance = "cbt",
				scan = true,
				pose = "stand",
				type = "reenforce_area",
				attitude = "engage",
				area = current_objective.target_area
			}

			self:_set_objective_to_enemy_group(group, grp_objective)

			group.objective.moving_in = true
		end
	end
end

function GroupAIStateBesiege:_verify_group_objective(group)
	local is_objective_broken = nil
	local grp_objective = group.objective
	local coarse_path = grp_objective.coarse_path
	local nav_segments = managers.navigation._nav_segments

	if coarse_path then
		for i = 1, #coarse_path do
			node = coarse_path[i]
			local nav_seg_id = node[1]

			if nav_segments[nav_seg_id].disabled then
				is_objective_broken = true

				break
			end
		end
	end

	if not is_objective_broken then
		return
	end

	local new_area = nil
	local tested_nav_seg_ids = {}

	for u_key, u_data in pairs(group.units) do
		u_data.tracker:move(u_data.m_pos)

		local nav_seg_id = u_data.tracker:nav_segment()

		if not tested_nav_seg_ids[nav_seg_id] then
			tested_nav_seg_ids[nav_seg_id] = true
			local areas = self:get_areas_from_nav_seg_id(nav_seg_id)

			for _, test_area in pairs(areas) do
				for test_nav_seg, _ in pairs(test_area.nav_segs) do
					if not nav_segments[test_nav_seg].disabled then
						new_area = test_area

						break
					end
				end

				if new_area then
					break
				end
			end
		end

		if new_area then
			break
		end
	end

	if not new_area then
		print("[GroupAIStateBesiege:_verify_group_objective] could not find replacement area to", grp_objective.area)

		return
	end
	
	group.objective = {
		moving_out = nil,
		type = grp_objective.type,
		area = new_area
	}
end

function GroupAIStateBesiege:is_area_populated(area)
	for u_key, u_data in pairs(self._police) do
		if not u_data.is_deployable and u_data.tactics_map and not u_data.tactics_map.flank and area.nav_segs[u_data.tracker:nav_segment()] then
			--log("violator")
			return
		end
	end
	
	--log("we got it")

	return true
end

function GroupAIStateBesiege:is_area_populated_and_safe(area)
	for u_key, u_data in pairs(self._police) do
		if not u_data.is_deployable and u_data.tactics_map and not u_data.tactics_map.flank and area.nav_segs[u_data.tracker:nav_segment()] then
			return
		end
	end
	
	for u_key, u_data in pairs(self._criminals) do
		if area.nav_segs[u_data.tracker:nav_segment()] then
			return
		end
	end

	return true
end

function GroupAIStateBase:is_nav_seg_populated(nav_seg)
	local area = self:get_area_from_nav_seg_id(nav_seg)

	return self:is_area_populated(area)
end

function GroupAIStateBase:is_nav_seg_populated_and_safe(nav_seg)
	local area = self:get_area_from_nav_seg_id(nav_seg)

	return self:is_area_populated_and_safe(area)
end

function GroupAIStateBase:is_area_flank_route(area)	
	for u_key, u_data in pairs(self._police) do
		if not u_data.is_deployable and u_data.tactics_map and u_data.tactics_map.flank and area.nav_segs[u_data.tracker:nav_segment()] then
			return
		end
	end

	return true
end

function GroupAIStateBase:is_area_safe_charge(area)
	for u_key, u_data in pairs(self._criminals) do
		if not u_data.is_deployable and area.nav_segs[u_data.tracker:nav_segment()] then
			return
		end
	end
	
	for u_key, u_data in pairs(self._police) do
		if not u_data.is_deployable and u_data.tactics_map and u_data.tactics_map.flank and area.nav_segs[u_data.tracker:nav_segment()] then
			return
		end
	end

	return true
end

function GroupAIStateBesiege:on_objective_complete(unit, objective)
	local new_objective, so_element = nil

	if objective.followup_objective then
		if not objective.followup_objective.trigger_on then
			new_objective = objective.followup_objective
		else
			new_objective = {
				type = "free",
				followup_objective = objective.followup_objective,
				interrupt_dis = objective.interrupt_dis,
				interrupt_health = objective.interrupt_health
			}
		end
	elseif objective.followup_SO then
		local current_SO_element = objective.followup_SO
		so_element = current_SO_element:choose_followup_SO(unit)
		new_objective = so_element and so_element:get_objective(unit)
	end

	if new_objective then
		if new_objective.nav_seg then
			local u_key = unit:key()
			local u_data = self._police[u_key]

			if u_data and u_data.assigned_area then
				self:set_enemy_assigned(self._area_data[new_objective.nav_seg], u_key)
			end
		end
	else
		local seg = unit:movement():nav_tracker():nav_segment()
		local area_data = self:get_area_from_nav_seg_id(seg)

		if tweak_data.character[unit:base()._tweak_table].rescue_hostages then
			for u_key, u_data in pairs(managers.enemy:all_civilians()) do
				if seg == u_data.tracker:nav_segment() then
					local so_id = u_data.unit:brain():wants_rescue()

					if so_id then
						local so = self._special_objectives[so_id]
						local so_data = so.data
						local so_objective = so_data.objective
						new_objective = self.clone_objective(so_objective)

						if so_data.admin_clbk then
							so_data.admin_clbk(unit)
						end

						self:remove_special_objective(so_id)

						break
					end
				end
			end
		end

		if not new_objective and objective.type == "free" then
			new_objective = {
				is_default = true,
				type = "free",
				attitude = objective.attitude
			}
		end
	end

	objective.fail_clbk = nil

	unit:brain():set_objective(new_objective)

	if objective.complete_clbk then
		objective.complete_clbk(unit)
	end

	if so_element then
		so_element:clbk_objective_administered(unit)
	end
end

function GroupAIStateBase:is_nav_seg_flank_route(nav_seg)
	local area = self:get_area_from_nav_seg_id(nav_seg)

	return self:is_area_flank_route(area)
end

function GroupAIStateBase:is_nav_seg_safe_charge(nav_seg)
	local area = self:get_area_from_nav_seg_id(nav_seg)

	return self:is_area_safe_charge(area)
end

function GroupAIStateBesiege:_set_assault_objective_to_group(group, phase)
	if not group.has_spawned then
		return
	end

	local phase_is_anticipation = nil
	
	if not self._fake_assault_mode then
		phase_is_anticipation = self._activeassaultbreak or self:chk_anticipation()
	end
	
	local phase_is_sustain = nil
	
	if not phase_is_anticipation then
		phase_is_sustain = phase == "sustain" or self._drama_data.amount > self._drama_data.high_p or self._danger_state
	end
	
	local current_objective = group.objective
	
	local approach, open_fire, push, pull_back, charge, has_found_position = nil
	local obstructed_area = self:_chk_group_areas_tresspassed(group)
	local group_leader_u_key, group_leader_u_data = self._determine_group_leader(group.units)
	local tactics_map = nil
	
	if not obstructed_area then
		if not phase_is_anticipation and self._current_assault_state == "lastcrimstanding" then
			local crim_data = nil
			
			for u_key, u_data in pairs_g(self._char_criminals) do
				if u_data.unit then
					if not u_data.status or u_data.status == "electrified" then
						crim_data = u_data
						break
					end
				end
			end
			
			if crim_data then
				local end_nav_seg = managers.navigation:get_nav_seg_from_pos(crim_data.m_pos, true)
				local grp_objective = {
					distance = 1500,
					type = "assault_area",
					attitude = "engage",
					moving_in = true,
					open_fire = true,
					follow_unit = crim_data.unit,
					nav_seg = end_nav_seg
				}
				group.is_chasing = true
				
				--log("you're a cuck")
				
				self:_set_objective_to_enemy_group(group, grp_objective)
				
				return
			end
		end
	end

	if group_leader_u_data and group_leader_u_data.tactics then
		tactics_map = {}
		
		--group_leader_u_data.tactics[#group_leader_u_data.tactics + 1] = "hunter"
		
		for i = 1, #group_leader_u_data.tactics do
			tactic_name = group_leader_u_data.tactics[i]
			tactics_map[tactic_name] = true
		end

		if current_objective.tactic and not tactics_map[current_objective.tactic] then
			current_objective.tactic = nil
			--group._last_updated_tactics_t = nil
		end
		
		if not phase_is_anticipation then			
			if current_objective.tactic then
				local follow_unit = current_objective.follow_unit
				
				if alive(follow_unit) then
					local crim_key = follow_unit:key()
					local crim_record = self._char_criminals[crim_key] 
					
					if crim_record then
						if current_objective.tactic == "hunter" then
							if crim_record.status and crim_record.status ~= "electrified" then
								current_objective.tactic = nil
							else
								local players_nearby = managers.player:_chk_fellow_crimin_proximity(follow_unit) 
								
								if players_nearby > 0 then
									current_objective.tactic = nil
								end
							end
						elseif current_objective.tactic == "deathguard" then
							if not crim_record.status or crim_record.status == "electrified" then
								current_objective.tactic = nil
							end
						end
					else
						current_objective.tactic = nil
					end
				else
					current_objective.tactic = nil
				end
			else
				for i = 1, #group_leader_u_data.tactics do
					tactic_name = group_leader_u_data.tactics[i]
					
					if tactic_name == "chase_test" then
						for u_key, u_data in pairs_g(self._player_criminals) do
							if u_data.unit then
								if not u_data.status or u_data.status == "electrified" then
									local closest_u_id, closest_u_data, closest_u_dis_sq = self._get_closest_group_unit_to_pos(u_data.m_pos, group.units)
									if closest_u_dis_sq then
										closest_crim_u_data = u_data
										closest_crim_dis_sq = closest_u_dis_sq
									end
								end
							end
						end
						
						if closest_crim_u_data then
							local end_nav_seg = managers.navigation:get_nav_seg_from_pos(closest_crim_u_data.m_pos, true)
							local grp_objective = {
								distance = 1500,
								type = "assault_area",
								attitude = "engage",
								tactic = "chase_test",
								moving_in = true,
								open_fire = true,
								follow_unit = closest_crim_u_data.unit,
								nav_seg = end_nav_seg
							}
							group.is_chasing = true
							
							--log("you're a cuck")
							
							self:_set_objective_to_enemy_group(group, grp_objective)

							return
						end
					elseif tactic_name == "hunter" then
						local closest_crim_u_data, closest_crim_dis_sq = nil
						local crim_dis_sq_chk = not closest_crim_dis_sq or closest_crim_dis_sq > closest_u_dis_sq
						
						for u_key, u_data in pairs_g(self._char_criminals) do
							if u_data.unit then
								if not u_data.status or u_data.status == "electrified" then
									local players_nearby = managers.player:_chk_fellow_crimin_proximity(u_data.unit)
									local closest_u_id, closest_u_data, closest_u_dis_sq = self._get_closest_group_unit_to_pos(u_data.m_pos, group.units)
									if players_nearby and players_nearby <= 0 then
										if closest_u_dis_sq and crim_dis_sq_chk then
											closest_crim_u_data = u_data
											closest_crim_dis_sq = closest_u_dis_sq
										end
									end
								end
							end
						end
						
						if closest_crim_u_data then
							local end_nav_seg = managers.navigation:get_nav_seg_from_pos(closest_crim_u_data.m_pos, true)
							local grp_objective = {
								distance = 1500,
								type = "assault_area",
								attitude = "engage",
								tactic = "hunter",
								moving_in = true,
								open_fire = true,
								follow_unit = closest_crim_u_data.unit,
								nav_seg = end_nav_seg
							}
							group.is_chasing = true

							self:_set_objective_to_enemy_group(group, grp_objective)

							return
						end
					elseif tactic_name == "deathguard" then
						if current_objective.tactic == tactic_name then
							for u_key, u_data in pairs_g(self._char_criminals) do
								if u_data.status and current_objective.follow_unit == u_data.unit then
									local crim_nav_seg = u_data.tracker:nav_segment()

									if current_objective.area.nav_segs[crim_nav_seg] then
										return
									end
								end
							end
						end

						local closest_crim_u_data, closest_crim_dis_sq = nil

						for u_key, u_data in pairs_g(self._char_criminals) do
							if u_data.status and u_data.status ~= "electrified" then
								local closest_u_id, closest_u_data, closest_u_dis_sq = self._get_closest_group_unit_to_pos(u_data.m_pos, group.units)

								if closest_u_dis_sq and closest_u_dis_sq < 1440000 and (not closest_crim_dis_sq or closest_u_dis_sq < closest_crim_dis_sq) then
									closest_crim_u_data = u_data
									closest_crim_dis_sq = closest_u_dis_sq
								end
							end
						end

						if closest_crim_u_data then
							local end_nav_seg = managers.navigation:get_nav_seg_from_pos(closest_crim_u_data.m_pos, true)
							local grp_objective = {
								distance = 800,
								type = "assault_area",
								attitude = "engage",
								tactic = "deathguard",
								open_fire = true,
								moving_in = true,
								follow_unit = closest_crim_u_data.unit,
								nav_seg = end_nav_seg
							}
							group.is_chasing = true

							self:_set_objective_to_enemy_group(group, grp_objective)
							self:_voice_deathguard_start(group)

							return
						end
					end
				end
			end
		else
			current_objective.tactic = nil
		end
	end
	
	if current_objective.tactic then
		return
	end

	local objective_area = nil
	
	if obstructed_area then
		--if one of the group members walk into a criminal then, if the phase is anticipation, they'll retreat backwards, otherwise, stand their ground and start shooting.
		--this will most likely always instantly kick in if the group has finished charging into an area.
	
		if phase_is_anticipation then 
			pull_back = true
		else
			if group.in_place and self._t - group.in_place_t > 2 then
				for criminal_key, criminal_data in pairs(self._player_criminals) do
					self:criminal_spotted(criminal_data.unit)

					for u_key, u_data in pairs(group.units) do
						u_data.unit:brain():clbk_group_member_attention_identified(nil, criminal_key)
					end
				end
				
				push = true
			else
				open_fire = true
			end
		
			objective_area = obstructed_area
		end
	elseif current_objective.moving_in then
		if phase_is_anticipation then
			pull_back = true
		elseif not current_objective.area or not next(current_objective.area.criminal.units) then --if theres suddenly no criminals in the area, start approaching instead
			if self._street then
				pull_back = true
			else
				push = true
			end
		end
	elseif group.in_place_t or not current_objective.area then
		local obstructed_path_index = nil
		local forwardmost_i_nav_point = nil
		local area_to_chk = nil
		
		if current_objective.coarse_path then --if they were previously moving in, use their current coarse path for reference as that means they transitioned
			forwardmost_i_nav_point = self:_get_group_forwardmost_coarse_path_index(group)
		elseif current_objective.area then --otherwise, use their current objective area, as it means they were in place
			area_to_chk = current_objective.area
		end

		if forwardmost_i_nav_point then
			area_to_chk = self:get_area_from_nav_seg_id(current_objective.coarse_path[forwardmost_i_nav_point][1])
		end
	
		local has_criminals_closer = nil
		local has_criminals_close = nil
		
		--check up to two nav areas away, but first check the current area in case obstructed_area didn't proc
		if area_to_chk then
			if next(area_to_chk.criminal.units) then
				has_criminals_close = true
				has_criminals_closer = true
			else
				for area_id, neighbour_area in pairs_g(area_to_chk.neighbours) do
					if next(neighbour_area.criminal.units) then					
						has_criminals_close = neighbour_area
						break
					else
						for alt_area_id, alt_area in pairs_g(neighbour_area.neighbours) do
							if next(alt_area.criminal.units) then
								has_criminals_close = alt_area
								break
							end
						end
					end
				end
			end
		end

		if has_criminals_closer then --open fire when enemies are in the current area we are in
			if phase_is_anticipation then
				pull_back = true
			else
				if group.in_place and self._t - group.in_place_t > 2 then
					for criminal_key, criminal_data in pairs(self._player_criminals) do
						self:criminal_spotted(criminal_data.unit)

						for u_key, u_data in pairs(group.units) do
							u_data.unit:brain():clbk_group_member_attention_identified(nil, criminal_key)
						end
					end
					
					push = true
				elseif current_objective.moving_in then
					open_fire = true
				end
			end
		elseif phase_is_anticipation and current_objective.open_fire then --if we were aggressive one update ago, start backing up away from the current objective area
			pull_back = true
		elseif has_criminals_close then
			if not phase_is_anticipation then
				if group.in_place and self._t - group.in_place_t > 2 then
					for criminal_key, criminal_data in pairs(self._player_criminals) do
						self:criminal_spotted(criminal_data.unit)

						for u_key, u_data in pairs(group.units) do
							u_data.unit:brain():clbk_group_member_attention_identified(nil, criminal_key)
						end
					end
				end
			
				if self._street then --street behavior, stay in place a bit before pushes 
					if group.in_place_t and self._t - group.in_place_t > 8 then 
						objective_area = has_criminals_close
						push = true
					elseif not current_objective.open_fire then
						open_fire = true
						objective_area = area_to_chk
					end
				else
					objective_area = has_criminals_close
					push = true
				end
			end
		elseif group.in_place or not current_objective.area then
			if phase_is_anticipation then
				approach = true
			else
				push = true
			end
		end
	end
	
	objective_area = objective_area or self._task_data.assault.target_areas[1]
	
	if not objective_area then
		return
	end
	
	if not current_objective.area then
		current_objective.area = group_leader_u_data and self:get_area_from_nav_seg_id(group_leader_u_data.tracker:nav_segment())
	end

	if open_fire then
		local grp_objective = {
			attitude = "engage",
			pose = "stand",
			type = "assault_area",
			stance = "hos",
			open_fire = true,
			tactic = current_objective.tactic,
			area = obstructed_area or objective_area
		}

		group.is_chasing = nil
		
		if not current_objective.open_fire then
			self:_voice_open_fire_start(group)
		end
		
		self:_set_objective_to_enemy_group(group, grp_objective)
		
	elseif approach or push then
		local assault_area, alternate_assault_area, alternate_assault_area_from, assault_path, alternate_assault_path = nil
		
		if tactics_map and tactics_map.flank then
			local all_nav_segs = managers.navigation._nav_segments
			local assault_to_seg = all_nav_segs[objective_area.pos_nav_seg]
			
			local neighbour_list = {}
			
			for neighbour_nav_seg_id, door_list in pairs(assault_to_seg.neighbours) do
				neighbour_list[#neighbour_list + 1] = neighbour_nav_seg_id
			end
			
			local assault_to_seg = neighbour_list[math_random(#neighbour_list)]
		
			local search_params = {
				id = "GroupAI_assault",
				from_seg = current_objective.area.pos_nav_seg,
				to_seg = assault_to_seg,
				access_pos = self._get_group_acces_mask(group),
				long_path = math_random() < 0.5 and true,
				verify_clbk = approach and callback(self, self, "is_nav_seg_safe") or nil
			}
			assault_path = managers.navigation:search_coarse(search_params)
			
			if assault_path then
				assault_path[#assault_path + 1] = {objective_area.pos_nav_seg, all_nav_segs[objective_area.pos_nav_seg].pos}
			end
		else
			local search_params = {
				id = "GroupAI_assault",
				from_seg = current_objective.area.pos_nav_seg,
				to_seg = objective_area.pos_nav_seg,
				access_pos = self._get_group_acces_mask(group),
				long_path = math_random() < 0.5 and true,
				verify_clbk = approach and callback(self, self, "is_nav_seg_safe") or nil
			}
			assault_path = managers.navigation:search_coarse(search_params)
		end

		if assault_path then
			--log("YOOOOOOOOOOOOOOOOOOOOOOOOO")
			assault_area = objective_area
			
			self:_merge_coarse_path_by_area(assault_path)
		end

		if assault_area and assault_path then	
			local used_grenade = nil
			local objective_pos = nil
			
			if push then
				if current_objective.area.id == assault_area.id or current_objective.area.neighbours[assault_area] then
					if math_random() < 0.5 then
						used_grenade = self:_chk_group_use_flash_grenade(group, self._task_data.assault, detonate_pos, assault_area)
						
						if not used_grenade then
							used_grenade = self:_chk_group_use_smoke_grenade(group, self._task_data.assault, detonate_pos, assault_area)
						end
					else
						used_grenade = self:_chk_group_use_smoke_grenade(group, self._task_data.assault, detonate_pos, assault_area)
						
						if not used_grenade then
							used_grenade = self:_chk_group_use_flash_grenade(group, self._task_data.assault, detonate_pos, assault_area)
						end
					end
				end
				
				
				local best_dis, best_pos
				local assault_area_pos = assault_area.pos
				
				for criminal_key, criminal_data in pairs(self._char_criminals) do
					if alive(criminal_data.unit) then
						local c_nav_tracker = criminal_data.tracker
						local crim_nav_seg = c_nav_tracker:nav_segment()

						if assault_area.nav_segs[crim_nav_seg] then
							local c_pos = c_nav_tracker:field_position()
							local c_dis = mvec3_dis_sq(c_pos, assault_area_pos)
							
							if not best_dis or best_dis > c_dis then
								best_dis = c_dis
								best_pos = c_pos
							end
						end
					end
				end
				
				if best_pos then
					objective_pos = best_pos
				end
			end
			
			if not push and assault_path and #assault_path > 2 then
				table_remove(assault_path, #assault_path)
				objective_area = self:get_area_from_nav_seg_id(assault_path[#assault_path][1])
			end

			local grp_objective = {
				type = "assault_area",
				stance = "hos",
				area = assault_area,
				coarse_path = assault_path or nil,
				pose = "stand",
				attitude = push and "engage" or "avoid",
				moving_in = push,
				open_fire = push,
				pushed = push,
				charge = push,
				pos = objective_pos,
				pos_optional = true,
				distance = 400,
				interrupt_dis = nil
			}
			--group.is_chasing = group.is_chasing or push
			
			if push and not current_objective.moving_in then
				self:_voice_push_in(group)
			elseif approach then
				if tactics_map and tactics_map.flank then
					self:_voice_looking_for_angle(group)
				else
					self:_voice_move_in_start(group)
				end
			end
			
			self:_set_objective_to_enemy_group(group, grp_objective)
		end
	elseif pull_back then
		local retreat_area = nil

		if not next(objective_area.criminal.units) then
			retreat_area = objective_area
		else
			for u_key, u_data in pairs_g(group.units) do
				local nav_seg_id = u_data.tracker:nav_segment()

				if self:is_nav_seg_safe(nav_seg_id) then
					retreat_area = self:get_area_from_nav_seg_id(nav_seg_id)

					break
				end
			end
		end

		if not retreat_area and current_objective.coarse_path then
			local forwardmost_i_nav_point = self:_get_group_forwardmost_coarse_path_index(group)

			if forwardmost_i_nav_point then
				local safe_i = 2
				local nearest_safe_area = self:get_area_from_nav_seg_id(current_objective.coarse_path[math.max(forwardmost_i_nav_point - safe_i, 1)][1])
				retreat_area = nearest_safe_area
			end
		end

		if retreat_area then
			local search_params = nil
			local retreat_path = nil
			
			if group_leader_u_data then
				search_params = {
					id = "GroupAI_pullback",
					from_tracker = group_leader_u_data.unit:movement():nav_tracker(),
					to_seg = retreat_area.pos_nav_seg,
					access_pos = self._get_group_acces_mask(group)
				}
				
				retreat_path = managers.navigation:search_coarse(search_params)
			end

			local new_grp_objective = {
				attitude = "avoid",
				stance = "hos",
				pose = "crouch",
				type = "assault_area",
				area = retreat_area,
				running = true,
				coarse_path = retreat_path or nil
			}
			group.is_chasing = nil
			
			if current_objective.moving_in and tactics_map and tactics_map.flank then
				self:_voice_looking_for_angle(group)
			end
			
			self:_set_objective_to_enemy_group(group, new_grp_objective)

			return
		end
	end
end

function GroupAIStateBesiege:_chk_group_use_smoke_grenade(group, task_data, detonate_pos, target_area)
	if task_data.use_smoke then
		local shooter_pos, shooter_u_data = nil
		local duration = tweak_data.group_ai.smoke_grenade_lifetime

		for u_key, u_data in pairs(group.units) do
			if u_data.tactics_map and u_data.tactics_map.smoke_grenade then
				if not detonate_pos then
					local nav_seg_id = u_data.tracker:nav_segment()
					local nav_seg = managers.navigation._nav_segments[nav_seg_id]
					
					if not target_area then
						target_area = task_data.target_areas[1]
					end
					
					for neighbour_nav_seg_id, door_list in pairs(nav_seg.neighbours) do
						local area = self:get_area_from_nav_seg_id(neighbour_nav_seg_id)

						if target_area.nav_segs[neighbour_nav_seg_id] or next(area.criminal.units) then
							local random_door_id = door_list[math_random(#door_list)]

							if type(random_door_id) == "number" then
								detonate_pos = managers.navigation._room_doors[random_door_id].center
							else
								detonate_pos = random_door_id:script_data().element:nav_link_end_pos()
							end

							shooter_pos = mvector3.copy(u_data.m_pos)
							shooter_u_data = u_data

							break
						end
					end
				end

				if detonate_pos and shooter_u_data then
					self:detonate_smoke_grenade(detonate_pos, shooter_pos, duration, false)
					self:apply_grenade_cooldown(nil)

					if shooter_u_data.char_tweak.chatter.smoke and not shooter_u_data.unit:sound():speaking(self._t) then
						self:chk_say_enemy_chatter(shooter_u_data.unit, shooter_u_data.m_pos, "smoke")
					end

					return true
				end
			end
		end
	end
end

function GroupAIStateBesiege:_chk_group_use_flash_grenade(group, task_data, detonate_pos, target_area)
	if task_data.use_smoke then
		local shooter_pos, shooter_u_data = nil
		local duration = tweak_data.group_ai.flash_grenade_lifetime

		for u_key, u_data in pairs(group.units) do
			if u_data.tactics_map and u_data.tactics_map.flash_grenade then
				if not detonate_pos then
					local nav_seg_id = u_data.tracker:nav_segment()
					local nav_seg = managers.navigation._nav_segments[nav_seg_id]
					
					if not target_area then
						target_area = task_data.target_areas[1]
					end
					
					for neighbour_nav_seg_id, door_list in pairs(nav_seg.neighbours) do
						if target_area.nav_segs[neighbour_nav_seg_id] then
							local random_door_id = door_list[math_random(#door_list)]

							if type(random_door_id) == "number" then
								detonate_pos = managers.navigation._room_doors[random_door_id].center
							else
								detonate_pos = random_door_id:script_data().element:nav_link_end_pos()
							end

							shooter_pos = mvector3.copy(u_data.m_pos)
							shooter_u_data = u_data

							break
						end
					end
				end

				if detonate_pos and shooter_u_data then
					self:detonate_smoke_grenade(detonate_pos, shooter_pos, duration, true)
					self:apply_grenade_cooldown(true)

					if shooter_u_data.char_tweak.chatter.flash_grenade and not shooter_u_data.unit:sound():speaking(self._t) then
						self:chk_say_enemy_chatter(shooter_u_data.unit, shooter_u_data.m_pos, "flash_grenade")
					end

					return true
				end
			end
		end
	end
end

function GroupAIStateBesiege._create_objective_from_group_objective(grp_objective, receiving_unit)
	local objective = {
		grp_objective = grp_objective
	}

	if grp_objective.element then
		objective = grp_objective.element:get_random_SO(receiving_unit)

		if not objective then
			return
		end

		objective.grp_objective = grp_objective

		return
	elseif grp_objective.type == "defend_area" or grp_objective.type == "recon_area" or grp_objective.type == "reenforce_area" then
		objective.type = "defend_area"
		objective.stance = "hos"
		objective.pose = "stand"
		objective.scan = true
		objective.interrupt_dis = 200
		objective.interrupt_suppression = nil
	elseif grp_objective.type == "retire" then
		objective.type = "defend_area"
		objective.running = true
		objective.stance = "hos"
		objective.pose = "stand"
		objective.scan = true
		objective.no_arrest = true
	elseif grp_objective.type == "assault_area" then
		objective.type = "defend_area"

		if grp_objective.follow_unit then
			objective.type = "follow"
			objective.follow_unit = grp_objective.follow_unit
		end
		
		objective.distance = grp_objective.distance
		objective.no_arrest = true
		objective.stance = "hos"
		objective.pose = "stand"
		objective.scan = true
		objective.interrupt_dis = nil
		objective.interrupt_suppression = nil
	elseif grp_objective.type == "create_phalanx" then
		objective.type = "phalanx"
		objective.stance = "hos"
		objective.interrupt_dis = nil
		objective.interrupt_health = nil
		objective.interrupt_suppression = nil
		objective.attitude = "avoid"
		objective.path_ahead = true
	elseif grp_objective.type == "hunt" then
		objective.type = "hunt"
		objective.stance = "hos"
		objective.scan = true
		objective.interrupt_dis = 200
	end

	objective.stance = grp_objective.stance or objective.stance
	objective.pose = grp_objective.pose or objective.pose
	objective.area = grp_objective.area
	
	if grp_objective.type == "recon_area" and objective.area then
		if objective.area.loot then
			objective.bagjob = true
		end
		
		if objective.area.hostages then
			objective.hostagejob = true
		end
	end
	
	objective.nav_seg = grp_objective.nav_seg or objective.area.pos_nav_seg
	objective.attitude = grp_objective.attitude or objective.attitude
	
	if not objective.no_arrest then
		objective.no_arrest = not objective.attitude or objective.attitude == "avoid"
	end
	
	objective.interrupt_dis = grp_objective.interrupt_dis or objective.interrupt_dis
	objective.interrupt_health = grp_objective.interrupt_health or objective.interrupt_health
	objective.interrupt_suppression = nil
	objective.pos = grp_objective.pos
	
	if not objective.running then
		objective.interrupt_dis = nil
		objective.running = grp_objective.running or nil
	end

	if grp_objective.scan ~= nil then
		objective.scan = grp_objective.scan
	end

	if grp_objective.coarse_path then
		objective.path_style = "coarse_complete"
		objective.path_data = grp_objective.coarse_path
	end

	return objective
end

function GroupAIStateBesiege:_voice_groupentry(group)
	local group_leader_u_key, group_leader_u_data = self._determine_group_leader(group.units)
	if group_leader_u_data and group_leader_u_data.tactics and group_leader_u_data.char_tweak.chatter.entry then
		for i_tactic, tactic_name in ipairs(group_leader_u_data.tactics) do
			local randomgroupcallout = math_lerp(1, 100, math_random())
			if tactic_name == "groupcs1" then
				self:chk_say_enemy_chatter(group_leader_u_data.unit, group_leader_u_data.m_pos, "csalpha")
			elseif tactic_name == "groupcs2" then
				self:chk_say_enemy_chatter(group_leader_u_data.unit, group_leader_u_data.m_pos, "csbravo")
			elseif tactic_name == "groupcs3" then
				self:chk_say_enemy_chatter(group_leader_u_data.unit, group_leader_u_data.m_pos, "cscharlie")
			elseif tactic_name == "groupcs4" then
				self:chk_say_enemy_chatter(group_leader_u_data.unit, group_leader_u_data.m_pos, "csdelta")
			elseif tactic_name == "grouphrt1" then
				self:chk_say_enemy_chatter(group_leader_u_data.unit, group_leader_u_data.m_pos, "hrtalpha")
			elseif tactic_name == "grouphrt2" then
				self:chk_say_enemy_chatter(group_leader_u_data.unit, group_leader_u_data.m_pos, "hrtbravo")
			elseif tactic_name == "grouphrt3" then
				self:chk_say_enemy_chatter(group_leader_u_data.unit, group_leader_u_data.m_pos, "hrtcharlie")
			elseif tactic_name == "grouphrt4" then
				self:chk_say_enemy_chatter(group_leader_u_data.unit, group_leader_u_data.m_pos, "hrtdelta")
			elseif tactic_name == "groupcsr" then
				if randomgroupcallout < 25 then
					self:chk_say_enemy_chatter(group_leader_u_data.unit, group_leader_u_data.m_pos, "csalpha")
				elseif randomgroupcallout > 25 and randomgroupcallout < 50 then
					self:chk_say_enemy_chatter(group_leader_u_data.unit, group_leader_u_data.m_pos, "csbravo")
				elseif randomgroupcallout < 74 and randomgroupcallout > 50 then
					self:chk_say_enemy_chatter(group_leader_u_data.unit, group_leader_u_data.m_pos, "cscharlie")
				else
					self:chk_say_enemy_chatter(group_leader_u_data.unit, group_leader_u_data.m_pos, "csdelta")
				end
			elseif tactic_name == "grouphrtr" then
				if randomgroupcallout < 25 then
					self:chk_say_enemy_chatter(group_leader_u_data.unit, group_leader_u_data.m_pos, "hrtalpha")
				elseif randomgroupcallout > 25 and randomgroupcallout < 50 then
					self:chk_say_enemy_chatter(group_leader_u_data.unit, group_leader_u_data.m_pos, "hrtbravo")
				elseif randomgroupcallout < 74 and randomgroupcallout > 50 then
					self:chk_say_enemy_chatter(group_leader_u_data.unit, group_leader_u_data.m_pos, "hrtcharlie")
				else
					self:chk_say_enemy_chatter(group_leader_u_data.unit, group_leader_u_data.m_pos, "hrtdelta")
				end
			elseif tactic_name == "groupany" then
				if self._task_data.assault.active then
					if randomgroupcallout < 25 then
						self:chk_say_enemy_chatter(group_leader_u_data.unit, group_leader_u_data.m_pos, "csalpha")
					elseif randomgroupcallout > 25 and randomgroupcallout < 50 then
						self:chk_say_enemy_chatter(group_leader_u_data.unit, group_leader_u_data.m_pos, "csbravo")
					elseif randomgroupcallout < 74 and randomgroupcallout > 50 then
						self:chk_say_enemy_chatter(group_leader_u_data.unit, group_leader_u_data.m_pos, "cscharlie")
					else
						self:chk_say_enemy_chatter(group_leader_u_data.unit, group_leader_u_data.m_pos, "csdelta")
					end
				else
					if randomgroupcallout < 25 then
						self:chk_say_enemy_chatter(group_leader_u_data.unit, group_leader_u_data.m_pos, "hrtalpha")
					elseif randomgroupcallout > 25 and randomgroupcallout < 50 then
						self:chk_say_enemy_chatter(group_leader_u_data.unit, group_leader_u_data.m_pos, "hrtbravo")
					elseif randomgroupcallout < 74 and randomgroupcallout > 50 then
						self:chk_say_enemy_chatter(group_leader_u_data.unit, group_leader_u_data.m_pos, "hrtcharlie")
					else
						self:chk_say_enemy_chatter(group_leader_u_data.unit, group_leader_u_data.m_pos, "hrtdelta")
					end
				end
			end
		end
	end
end

function GroupAIStateBesiege:_voice_looking_for_angle(group)
	for u_key, unit_data in pairs(group.units) do
		if unit_data.char_tweak.chatter.ready and self:chk_say_enemy_chatter(unit_data.unit, unit_data.m_pos, "look_for_angle") then
			else
		end
	end
end

function GroupAIStateBesiege:_voice_friend_dead(group)
	for u_key, unit_data in pairs(group.units) do
		if unit_data.char_tweak.chatter.enemyidlepanic and self:chk_say_enemy_chatter(unit_data.unit, unit_data.m_pos, "assaultpanic") then
			else
		end
	end
end

function GroupAIStateBesiege:_voice_saw()
	for group_id, group in pairs(self._groups) do
		for u_key, u_data in pairs(group.units) do
			if u_data.char_tweak.chatter.saw then
				self:chk_say_enemy_chatter(u_data.unit, u_data.m_pos, "saw")
			else
				
			end
		end
	end
end

function GroupAIStateBesiege:_voice_sentry()
	for group_id, group in pairs(self._groups) do
		for u_key, u_data in pairs(group.units) do
			if u_data.char_tweak.chatter.sentry then
				self:chk_say_enemy_chatter(u_data.unit, u_data.m_pos, "sentry")
			else
				
			end
		end
	end
end	

function GroupAIStateBesiege:_voice_affirmative(group)
	for u_key, unit_data in pairs(group.units) do
		if unit_data.char_tweak.chatter.affirmative and self:chk_say_enemy_chatter(unit_data.unit, unit_data.m_pos, "affirmative") then
			else
		end
	end
end	
	
function GroupAIStateBesiege:_voice_open_fire_start(group)
	for u_key, unit_data in pairs(group.units) do
		if unit_data.char_tweak.chatter.ready and self:chk_say_enemy_chatter(unit_data.unit, unit_data.m_pos, "open_fire") then
			else
		end
	end
end

function GroupAIStateBesiege:_voice_push_in(group)
	for u_key, unit_data in pairs(group.units) do
		if unit_data.char_tweak.chatter.ready and self:chk_say_enemy_chatter(unit_data.unit, unit_data.m_pos, "push") then
			else
		end
	end
end

function GroupAIStateBesiege:_voice_gtfo(group)
	for u_key, unit_data in pairs(group.units) do
		if unit_data.char_tweak.chatter.ready and self:chk_say_enemy_chatter(unit_data.unit, unit_data.m_pos, "retreat") then
			else
		end
	end
end
	
function GroupAIStateBesiege:_voice_deathguard_start(group)
	for u_key, unit_data in pairs(group.units) do
		if unit_data.char_tweak.chatter.ready and self:chk_say_enemy_chatter(unit_data.unit, unit_data.m_pos, "deathguard") then
			else
		end
	end
end	
	
function GroupAIStateBesiege:_voice_smoke(group)
	for u_key, unit_data in pairs(group.units) do
		if unit_data.char_tweak.chatter.ready and self:chk_say_enemy_chatter(unit_data.unit, unit_data.m_pos, "smoke") then
			else
		end
	end
end	
	
function GroupAIStateBesiege:_voice_flash(group)
	for u_key, unit_data in pairs(group.units) do
		if unit_data.char_tweak.chatter.ready and self:chk_say_enemy_chatter(unit_data.unit, unit_data.m_pos, "flash_grenade") then
		else
		end
	end
end

function GroupAIStateBesiege:_voice_dont_delay_assault(group)
	local time = self._t
	for u_key, unit_data in pairs(group.units) do
		if not unit_data.unit:sound():speaking(time) then
			unit_data.unit:sound():say("p01", true, nil)
			return true
		end
	end
	return false
end

function GroupAIStateBesiege:apply_grenade_cooldown(flash)

	if not self._task_data.assault then
		return
	end
	
	local task_data = self._task_data.assault
	local duration = tweak_data.group_ai.smoke_grenade_lifetime
	local cooldown = math_lerp(tweak_data.group_ai.smoke_and_flash_grenade_timeout[1], tweak_data.group_ai.smoke_and_flash_grenade_timeout[2], math_random())
	
	if flash then
		duration = 4
		cooldown = cooldown * 0.5
	end

	cooldown = cooldown + duration
	
	task_data.use_smoke_timer = self._t + cooldown
	task_data.use_smoke = nil
	
end

function GroupAIStateBesiege:_end_regroup_task()
	if self._task_data.regroup.active then
		self._task_data.regroup.active = nil

		managers.trade:set_trade_countdown(true)
		self:set_assault_mode(false)

		if not self._smoke_grenade_ignore_control then
			managers.network:session():send_to_peers_synched("sync_smoke_grenade_kill")
			self:sync_smoke_grenade_kill()
		end

		local dmg = self._downs_during_assault
		local limits = tweak_data.group_ai.bain_assault_praise_limits
		local result = dmg < limits[1] and 0 or dmg < limits[2] and 1 or 2
		
		if self._downs_during_assault > 5 then
			self._assault_was_hell = true
		end
		
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
		
		if not Global.game_settings.single_player then
			LuaNetworking:SendToPeers("shin_sync_post_assault_replenish", "")
		end
		
		self._current_objective_dir = nil

		managers.mission:call_global_event("end_assault_late")
		managers.groupai:dispatch_event("end_assault_late", self._assault_number)
		managers.hud:end_assault(result)
		self:_mark_hostage_areas_as_unsafe()
		self._heat_bonus_count = 0
		
		--self:_set_rescue_state(true)

		if not self._task_data.assault.next_dispatch_t then
			local assault_delay = self._tweak_data.assault.delay
			local breaktime = self._assault_was_hell and 15 or 0
			self._task_data.assault.next_dispatch_t = self._t + self:_get_difficulty_dependent_value(assault_delay) + breaktime
			
			if self._hostage_headcount > 3 then
				self._task_data.assault.next_dispatch_t = self._task_data.assault.next_dispatch_t + 25
				self._had_hostages = true
			elseif self._hostage_headcount > 0 then
				self._task_data.assault.next_dispatch_t = self._task_data.assault.next_dispatch_t + self:_get_difficulty_dependent_value(self._tweak_data.assault.hostage_hesitation_delay)
			else
				self._had_hostages = nil
			end
		end

		if self._draw_drama then
			self._draw_drama.regroup_hist[#self._draw_drama.regroup_hist][2] = self._t
		end

		self._task_data.recon.next_dispatch_t = self._t
	end
end

function GroupAIStateBesiege:_upd_regroup_task()
	local regroup_task = self._task_data.regroup
	
	if regroup_task.active then
		self:_assign_assault_groups_to_retire()

		if regroup_task.end_t < self._t and self._drama_data.amount < tweak_data.drama.assault_fade_end then
			self:_end_regroup_task()
		end
	end
end

local function make_dis_id(from, to)
	local f = from < to and from or to
	local t = to < from and from or to

	return tostring(f) .. "-" .. tostring(t)
end

local function spawn_group_id(spawn_group)
	return spawn_group.mission_element:id()
end

function GroupAIStateBesiege:_find_spawn_group_near_area(target_area, allowed_groups, target_pos, max_dis, verify_clbk)
	local all_areas = self._area_data
	
	max_dis = max_dis and max_dis * max_dis
	local min_dis = nil
	local t = self._t
	local valid_spawn_groups = {}
	local valid_spawn_group_distances = {}
	local total_dis = 0
	target_pos = target_pos or target_area.pos
	local to_search_areas = {
		target_area
	}
	local found_areas = {
		[target_area.id] = true
	}

	repeat
		local search_area = table.remove(to_search_areas, 1)
		local spawn_groups = search_area.spawn_groups

		if spawn_groups then
			for i = 1, #spawn_groups do
				local spawn_group = spawn_groups[i]
				if spawn_group.delay_t <= t and (not verify_clbk or verify_clbk(spawn_group)) then
					local dis_id = make_dis_id(spawn_group.nav_seg, target_area.pos_nav_seg)

					if not self._graph_distance_cache[dis_id] then
						local coarse_params = {
							access_pos = "swat",
							from_seg = spawn_group.nav_seg,
							to_seg = target_area.pos_nav_seg,
							id = dis_id
						}
						local path = managers.navigation:search_coarse(coarse_params)

						if path and #path >= 2 then
							local dis = 0
							local current = spawn_group.pos

							for i = 2, #path do
								local nxt = path[i][2]

								if current and nxt then
									dis = dis + mvec3_dis_sq(current, nxt)
								end

								current = nxt
							end

							self._graph_distance_cache[dis_id] = dis
						end
					end

					if self._graph_distance_cache[dis_id] then
						local my_dis = self._graph_distance_cache[dis_id]
						
						local should_add_spawngroup = true
						--log(tostring(my_dis))
						--log(tostring(min_dis))
						if min_dis and min_dis > my_dis then
							should_add_spawngroup = nil
							--log("piss")
						end
						
						if max_dis and my_dis > max_dis then
							should_add_spawngroup = nil
							--log("piss2")
						end
						
						if self._current_objective_dir then
							local spawn_group_dir = spawn_group.pos:with_z(0)
							mvec3_sub(spawn_group_dir, target_pos:with_z(0))
							mvec3_norm(spawn_group_dir)
							
							if mvec3_dot(self._current_objective_dir, spawn_group_dir) < 0.2 then
								should_add_spawngroup = nil
							end
						end
						
						if should_add_spawngroup then
							--log("confusion")
							total_dis = total_dis + my_dis
							valid_spawn_groups[spawn_group_id(spawn_group)] = spawn_group
							valid_spawn_group_distances[spawn_group_id(spawn_group)] = my_dis
						end	
					end
				end
			end
		end

		for other_area_id, other_area in pairs(all_areas) do
			if not found_areas[other_area_id] and other_area.neighbours[search_area.id] then
				table_insert(to_search_areas, other_area)

				found_areas[other_area_id] = true
			end
		end
	until #to_search_areas == 0

	local time = TimerManager:game():time()
	local spawn_group_number = #valid_spawn_groups
	
	if spawn_group_number and spawn_group_number > 1 then
		for id in pairs(valid_spawn_groups) do
			if self._spawn_group_timers[id] and time < self._spawn_group_timers[id] then
				valid_spawn_groups[id] = nil
				valid_spawn_group_distances[id] = nil
				spawn_group_number = spawn_group_number - 1
			end
		end
	end
	
	local delays = {10, 15}
	
	if spawn_group_number > 3 and spawn_group_number < 6 then
		delays = {7.5, 12.5}
	elseif spawn_group_number < 3 then
		delays = {5, 7.5}
	end
	
	if Global.game_settings.one_down then --LET'S GIVE INTO PAAAAAAIN
		delays[1] = delays[1] * 0.25
		delays[2] = delays[2] * 0.25
	end

	if total_dis == 0 then
		total_dis = 1
	end

	local total_weight = 0
	local candidate_groups = {}
	self._debug_weights = {} 
	
	for i, dis in pairs(valid_spawn_group_distances) do
		local my_spawn_group = valid_spawn_groups[i]
		local my_group_types = my_spawn_group.mission_element:spawn_groups()
		my_spawn_group.distance = dis
		total_weight = total_weight + self:_choose_best_groups(candidate_groups, my_spawn_group, my_group_types, allowed_groups)
	end

	if total_weight == 0 then
		return
	end

	--[[for _, group in ipairs(candidate_groups) do
		table_insert(self._debug_weights, clone(group))
	end]]

	return self:_choose_best_group(candidate_groups, total_weight, delays)
end

function GroupAIStateBesiege:_choose_best_groups(best_groups, group, group_types, allowed_groups)
	local total_weight = 0

	for _, group_type in ipairs(group_types) do
		if tweak_data.group_ai.enemy_spawn_groups[group_type] then
			local group_tweak = tweak_data.group_ai.enemy_spawn_groups[group_type]
			local special_type, spawn_limit, current_count = nil
			local cat_weights = allowed_groups[group_type]

			if cat_weights then
				if group_tweak.special then
					special_type = group_tweak.special
					current_count = self:_get_special_unit_type_count(special_type)
					spawn_limit = managers.job:current_spawn_limit(special_type)
				end
			
				if not special_type or spawn_limit >= current_count + 1 then
					local cat_weight = cat_weights[1]

					table.insert(best_groups, {
						group = group,
						group_type = group_type,
						wght = cat_weight,
						cat_weight = cat_weight,
						dis_weight = cat_weight
					})

					total_weight = total_weight + cat_weight
				end
			end
		end
	end

	return total_weight
end

function GroupAIStateBesiege:_choose_best_group(best_groups, total_weight, delays)
	local rand_wgt = total_weight * math_random()
	local best_grp, best_grp_type = nil
	
	--log("group choosing time: ")
	
	for i = 1, #best_groups do
		local candidate = best_groups[i]
		
		--log("candidate name: " .. tostring(candidate.group_type) .. "#" .. tostring(i))
		
		--log("candidate weight: " .. tostring(candidate.wght) .. "")
		
		--log("rand_wgt: " .. tostring(rand_wgt))
		
		rand_wgt = rand_wgt - candidate.wght
		
		if rand_wgt <= 0 then
			--log("CANDIDATE CHOSEN!")
		
			if delays then
				self._spawn_group_timers[spawn_group_id(candidate.group)] = TimerManager:game():time() + math_lerp(delays[1], delays[2], math_random())
			end
			
			best_grp = candidate.group
			best_grp_type = candidate.group_type
			best_grp.delay_t = self._t + best_grp.interval

			break
		end
	end

	return best_grp, best_grp_type
end

local bo_hh = "bo_hh"
local shield = "shield"
local winters = Idstring("units/pd2_dlc_drm/characters/ene_true_lotus_master/ene_true_lotus_master")

function GroupAIStateBesiege:_perform_group_spawning(spawn_task, force, use_last)
	local nr_units_spawned = 0
	local produce_data = {
		name = true,
		spawn_ai = {}
	}
	local group_ai_tweak = tweak_data.group_ai
	local spawn_points = spawn_task.spawn_group.spawn_pts

	local function _try_spawn_unit(u_type_name, spawn_entry)
		if GroupAIStateBesiege._MAX_SIMULTANEOUS_SPAWNS <= nr_units_spawned and not force then
			return
		end

		local hopeless = true
		local current_unit_type = tweak_data.levels:get_ai_group_type()
		local try_hh = current_unit_type == "bo"
		
		for i = 1, #spawn_points do
			local sp_data = spawn_points[i]
			local category = group_ai_tweak.unit_categories[u_type_name]
			local access_check = sp_data.accessibility == "any" or category.access[sp_data.accessibility]
			local amount_check = not sp_data.amount or sp_data.amount > 0

			if access_check and amount_check and sp_data.mission_element:enabled() then
				hopeless = false

				if sp_data.delay_t < self._t then
					local cat_unit_types = category.unit_types
					local units = cat_unit_types[current_unit_type]
					
					if try_hh then
						if cat_unit_types[bo_hh] then
							units = cat_unit_types[bo_hh]
						end
					end
					
					if try_hh and category.special_type == shield and self._downs_during_assault <= 0 and math.random() <= 0.2 then
						produce_data.name = winters
					else
						produce_data.name = units[math.random(#units)]
					end
					
					produce_data.name = managers.modifiers:modify_value("GroupAIStateBesiege:SpawningUnit", produce_data.name)
					local spawned_unit = sp_data.mission_element:produce(produce_data)
					local u_key = spawned_unit:key()
					local objective = nil

					if spawn_task.objective then
						objective = self.clone_objective(spawn_task.objective)
					else
						objective = spawn_task.group.objective.element:get_random_SO(spawned_unit)

						if not objective then
							spawned_unit:set_slot(0)

							return true
						end

						objective.grp_objective = spawn_task.group.objective
					end

					local u_data = self._police[u_key]

					self:set_enemy_assigned(objective.area, u_key)

					if spawn_entry.tactics then
						u_data.tactics = spawn_entry.tactics
						u_data.tactics_map = {}

						for _, tactic_name in ipairs(u_data.tactics) do
							u_data.tactics_map[tactic_name] = true
						end
					end
					
					if spawned_unit:base()._tweak_table == "tank_mini" or spawned_unit:base()._tweak_table == "tank_medic" then
						self._spawned_megatank_t = self._t + 15
					end
					
					spawned_unit:brain():set_spawn_entry(spawn_entry, u_data.tactics_map)

					u_data.rank = spawn_entry.rank

					self:_add_group_member(spawn_task.group, u_key)

					if spawned_unit:brain():is_available_for_assignment(objective) then
						if objective.element then
							objective.element:clbk_objective_administered(spawned_unit)
						end

						spawned_unit:brain():set_objective(objective)
					else
						spawned_unit:brain():set_followup_objective(objective)
					end

					nr_units_spawned = nr_units_spawned + 1

					if spawn_task.ai_task then
						spawn_task.ai_task.force_spawned = spawn_task.ai_task.force_spawned + 1
						spawned_unit:brain()._logic_data.spawned_in_phase = spawn_task.ai_task.phase
					end
					
					sp_data.delay_t = self._t + sp_data.interval

					if sp_data.amount then
						sp_data.amount = sp_data.amount - 1
					end

					return true
				end
			end
		end

		if hopeless then
			debug_pause("[GroupAIStateBesiege:_upd_group_spawning] spawn group", spawn_task.spawn_group.id, "failed to spawn unit", u_type_name)

			return true
		end
	end

	for u_type_name, spawn_info in pairs(spawn_task.units_remaining) do
		if not group_ai_tweak.unit_categories[u_type_name].access.acrobatic then
			for i = spawn_info.amount, 1, -1 do
				local success = _try_spawn_unit(u_type_name, spawn_info.spawn_entry)

				if success then
					spawn_info.amount = spawn_info.amount - 1
				end

				break
			end
		end
	end

	for u_type_name, spawn_info in pairs(spawn_task.units_remaining) do
		for i = spawn_info.amount, 1, -1 do
			local success = _try_spawn_unit(u_type_name, spawn_info.spawn_entry)

			if success then
				spawn_info.amount = spawn_info.amount - 1
			end

			break
		end
	end

	local complete = true

	for u_type_name, spawn_info in pairs(spawn_task.units_remaining) do
		if spawn_info.amount > 0 then
			complete = false

			break
		end
	end

	if complete then
		spawn_task.group.has_spawned = true

		table.remove(self._spawning_groups, use_last and #self._spawning_groups or 1)

		if spawn_task.group.size <= 0 then
			self._groups[spawn_task.group.id] = nil
		end
	end
end
