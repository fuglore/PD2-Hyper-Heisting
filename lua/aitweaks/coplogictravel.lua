local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()

function CopLogicTravel.chk_slide_conditions(data)
	local my_data = data.internal_data
	local running = data.unit:anim_data().move
	local next_allowed_slide_t = nil
	local can_perform_walking_action = not data.unit:movement():chk_action_forbidden("walk")
	local next_allowed_slide_t = my_data.next_allowed_slide_t
	
	if running then
		local c_dis, bc_dis, mtc_dis, csp_dis, c_pos, bc_pos, mtc_pos, csp_pos  = nil
			
		if my_data.moving_to_cover then
			mtc_dis = mvector3.distance(my_data.moving_to_cover[1][1], data.unit:movement():m_pos())
			mtc_pos = my_data.moving_to_cover[1][1]
		elseif my_data.best_cover then
			bc_dis = mvector3.distance(my_data.best_cover[1][1], data.unit:movement():m_pos())
			bc_pos = my_data.best_cover[1][1]
		elseif my_data.nearest_cover then
			c_dis = mvector3.distance(my_data.nearest_cover[1][1], data.unit:movement():m_pos())
			c_pos = my_data.nearest_cover[1][1]
		end
			
		local dis =	nil
		local cover_pos = nil
		dis = mtc_dis
		cover_pos = mtc_pos or c_pos or bc_pos
		
		if not my_data.next_allowed_slide_t then
			my_data.next_allowed_slide_t = data.t + 0.5
		end
			
		if data.unit:base()._tweak_table == "fbi_swat" or data.unit:base()._tweak_table == "fbi_heavy_swat" then
			if running then
				--if my_data.next_allowed_slide_t and my_data.next_allowed_slide_t < data.t then
					log("my dad abandoned me")
					CopLogicAttack._cancel_cover_pathing(data, my_data)
					CopLogicAttack._cancel_charge(data, my_data)
					CopLogicAttack._cancel_expected_pos_path(data, my_data)
					CopLogicAttack._cancel_walking_to_cover(data, my_data, true)
					--data.unit:movement():play_redirect("e_nl_slide_fwd_4m")
					return true
				--end
			end
		end
	else
		return
	end
end

function CopLogicTravel.enter(data, new_logic_name, enter_params)
	CopLogicBase.enter(data, new_logic_name, enter_params)
	data.unit:brain():cancel_all_pathing_searches()
	
	local old_internal_data = data.internal_data
	local my_data = {
		unit = data.unit
	}
	data.internal_data = my_data
	local is_cool = data.unit:movement():cool()
	
	if is_cool then
		my_data.detection = data.char_tweak.detection.ntl
	else
		my_data.detection = data.char_tweak.detection.recon
	end

	if old_internal_data then
		my_data.turning = old_internal_data.turning
		my_data.firing = old_internal_data.firing
		my_data.shooting = old_internal_data.shooting
		my_data.attention_unit = old_internal_data.attention_unit

		if old_internal_data.nearest_cover then
			my_data.nearest_cover = old_internal_data.nearest_cover

			managers.navigation:reserve_cover(my_data.nearest_cover[1], data.pos_rsrv_id)
		end

		if old_internal_data.best_cover then
			my_data.best_cover = old_internal_data.best_cover

			managers.navigation:reserve_cover(my_data.best_cover[1], data.pos_rsrv_id)
		end
	end

	if data.char_tweak.announce_incomming then
		my_data.announce_t = data.t + 2
	end
	
	local prefix = data.unit:sound():chk_voice_prefix() or "empty"
	local is_radio_cop = prefix == "l1d_" or prefix == "l2d_" or prefix == "l3d_" or prefix == "l4d_" or prefix == "l5d_"
	
	if prefix ~= "empty" and is_radio_cop then
		my_data.radio_voice = true
	end
	
	local key_str = tostring(data.key)
	my_data.upd_task_key = "CopLogicTravel.queued_update" .. key_str

	CopLogicTravel.queue_update(data, my_data)

	my_data.cover_update_task_key = "CopLogicTravel._update_cover" .. key_str

	if my_data.nearest_cover or my_data.best_cover then
		CopLogicBase.add_delayed_clbk(my_data, my_data.cover_update_task_key, callback(CopLogicTravel, CopLogicTravel, "_update_cover", data), data.t)
	end

	my_data.advance_path_search_id = "CopLogicTravel_detailed" .. tostring(data.key)
	my_data.coarse_path_search_id = "CopLogicTravel_coarse" .. tostring(data.key)

	CopLogicIdle._chk_has_old_action(data, my_data)

	local objective = data.objective
	local path_data = objective.path_data

	if objective.path_style == "warp" then
		my_data.warp_pos = objective.pos
	elseif path_data then
		local path_style = objective.path_style

		if path_style == "precise" then
			local path = {
				mvector3.copy(data.m_pos)
			}

			for _, point in ipairs(path_data.points) do
				table.insert(path, mvector3.copy(point.position))
			end

			my_data.advance_path = path
			my_data.coarse_path_index = 1
			local start_seg = data.unit:movement():nav_tracker():nav_segment()
			local end_pos = mvector3.copy(path[#path])
			local end_seg = managers.navigation:get_nav_seg_from_pos(end_pos)
			my_data.coarse_path = {
				{
					start_seg
				},
				{
					end_seg,
					end_pos
				}
			}
			my_data.path_is_precise = true
			my_data.path_ahead = true
		elseif path_style == "coarse" then
			my_data.path_ahead = true
			local nav_manager = managers.navigation
			local f_get_nav_seg = nav_manager.get_nav_seg_from_pos
			local start_seg = data.unit:movement():nav_tracker():nav_segment()
			local path = {
				{
					start_seg
				}
			}

			for _, point in ipairs(path_data.points) do
				local pos = mvector3.copy(point.position)
				local nav_seg = f_get_nav_seg(nav_manager, pos)

				table.insert(path, {
					nav_seg,
					pos
				})
			end

			my_data.coarse_path = path
			my_data.coarse_path_index = CopLogicTravel.complete_coarse_path(data, my_data, path)
		elseif path_style == "coarse_complete" then
			my_data.path_safely = nil
			my_data.path_ahead = true
			my_data.coarse_path_index = 1
			my_data.coarse_path = deep_clone(objective.path_data)
			my_data.coarse_path_index = CopLogicTravel.complete_coarse_path(data, my_data, my_data.coarse_path)
		end
	end

	if objective.stance then
		local upper_body_action = data.unit:movement()._active_actions[3]

		if not upper_body_action or upper_body_action:type() ~= "shoot" then
			data.unit:movement():set_stance(objective.stance)
		end
	end

	if data.attention_obj and AIAttentionObject.REACT_AIM < data.attention_obj.reaction then
		data.unit:movement():set_cool(false, managers.groupai:state().analyse_giveaway(data.unit:base()._tweak_table, data.attention_obj.unit))
	end

	if is_cool then
		data.unit:brain():set_attention_settings({
			peaceful = true
		})
	else
		data.unit:brain():set_attention_settings({
			cbt = true
		})
	end

	my_data.attitude = data.objective.attitude or "avoid"
	my_data.weapon_range = data.char_tweak.weapon[data.unit:inventory():equipped_unit():base():weapon_tweak_data().usage].range
	my_data.path_safely = nil
	my_data.path_ahead = true

	data.unit:brain():set_update_enabled_state(false)
end

function CopLogicTravel.queued_update(data)
    local my_data = data.internal_data
    data.t = TimerManager:game():time()
    my_data.close_to_criminal = nil
    local delay = CopLogicTravel._upd_enemy_detection(data)
    
    if data.internal_data ~= my_data then
    	return
    end
    
    CopLogicTravel.upd_advance(data)
	CopLogicIdle._update_haste(data, my_data)
    
    if data.internal_data ~= my_data then
    	return
    end
    
    if not delay then
    	debug_pause_unit(data.unit, "crap!!!", inspect(data))	
    
    	delay = 0.35
    end
	
	local level = Global.level_data and Global.level_data.level_id
	local hostage_count = managers.groupai:state():get_hostage_count_for_chatter() --check current hostage count
	local chosen_panic_chatter = "controlpanic" --set default generic assault break chatter
	
	if hostage_count > 0 and not managers.groupai:state():chk_assault_active_atm() then --make sure the hostage count is actually above zero before replacing any of the lines
		if hostage_count > 3 then  -- hostage count needs to be above 3
			if math.random() < 0.4 then --40% chance
				chosen_panic_chatter = "controlpanic"
			else
				chosen_panic_chatter = "hostagepanic2" --more panicky "GET THOSE HOSTAGES OUT RIGHT NOW!!!" line for when theres too many hostages on the map
			end
		else
			if math.random() < 0.4 then
				chosen_panic_chatter = "controlpanic"
			else
				chosen_panic_chatter = "hostagepanic1" --less panicky "Delay the assault until those hostages are out." line
			end
		end
	end
	
	local chosen_sabotage_chatter = "sabotagegeneric" --set default sabotage chatter for variety's sake
	local skirmish_map = level == "skm_mus" or level == "skm_red2" or level == "skm_run" or level == "skm_watchdogs_stage2" --these shouldnt play on holdout
	local ignore_radio_rules = nil
	
	if level == "branchbank" then --bank heist
		chosen_sabotage_chatter = "sabotagedrill"
	elseif level == "nmh" or level == "man" or level == "framing_frame_3" or level == "rat" or level == "election_day_1" then --various heists where turning off the power is a frequent occurence
		chosen_sabotage_chatter = "sabotagepower"
	elseif level == "chill_combat" or level == "watchdogs_1" or level == "watchdogs_1_night" or level == "watchdogs_2" or level == "watchdogs_2_day" or level == "cane" then
		chosen_sabotage_chatter = "sabotagebags"
		ignore_radio_rules = true
	else
		chosen_sabotage_chatter = "sabotagegeneric" --if none of these levels are the current one, use a generic "Break their gear!" line
	end
	
	local cant_say_clear = data.attention_obj and data.attention_obj.reaction >= AIAttentionObject.REACT_COMBAT and data.attention_obj.verified_t and data.attention_obj.verified_t - data.t < 5
	
    if not data.unit:base():has_tag("special") then
    	if data.char_tweak.chatter.clear and not cant_say_clear and not data.is_converted then
			if data.unit:movement():cool() then
				managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "clear_whisper" )
			else
				local clearchk = math.random(0, 90)
				local say_clear = 30
				if clearchk > 60 then
					managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "clear" )
				elseif clearchk > 30 then
					if not skirmish_map and my_data.radio_voice or not skirmish_map and ignore_radio_rules then
						managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, chosen_sabotage_chatter )
					else
						managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, chosen_panic_chatter )
					end
				else
					managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, chosen_panic_chatter )
				end
			end
		end
    end
	
	if data.unit:base():has_tag("tank") or data.unit:base():has_tag("taser") then
    	if not cant_say_clear then
			managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "approachingspecial" )
		end
    end
	
	data.logic._update_haste(data, data.internal_data)
	
	--mid-assault panic for cops based on alerts instead of opening fire, since its supposed to be generic action lines instead of for opening fire and such
	--I'm adding some randomness to these since the delays in groupaitweakdata went a bit overboard but also arent able to really discern things proper
	
	if data.char_tweak and data.char_tweak.chatter and data.char_tweak.chatter.enemyidlepanic and not data.is_converted then
		if managers.groupai:state():chk_assault_active_atm() or not data.unit:base():has_tag("law") then
			if data.attention_obj and data.attention_obj.reaction >= AIAttentionObject.REACT_COMBAT and data.attention_obj.alert_t and data.t - data.attention_obj.alert_t < 1 and data.attention_obj.dis <= 3000 then
				if data.attention_obj.verified and data.attention_obj.dis <= 500 or data.is_suppressed and data.attention_obj.verified then
					local roll = math.random(1, 100)
					local chance_suppanic = 30
					
					if roll <= chance_suppanic then
						local nroll = math.random(1, 100)
						local chance_help = 50
						if roll <= chance_suppanic or not data.unit:base():has_tag("law") then
							managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "assaultpanicsuppressed1" )
						else
							managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "assaultpanicsuppressed2" )
						end
					else
						managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "assaultpanic" )
					end
				else
					if math.random() < 0.1 and data.unit:base():has_tag("law") then
						managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, chosen_sabotage_chatter )
					else
						managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "assaultpanic" )
					end
				end
			end
		end
	end
      
    CopLogicTravel.queue_update(data, data.internal_data, delay)
end

function CopLogicTravel.upd_advance(data)
	local unit = data.unit
	local my_data = data.internal_data
	local objective = data.objective
	local t = TimerManager:game():time()
	data.t = t
	
	if my_data.has_old_action then
		CopLogicAttack._upd_stop_old_action(data, my_data)
	elseif my_data.warp_pos then
		local action_desc = {
			body_part = 1,
			type = "warp",
			position = mvector3.copy(objective.pos),
			rotation = objective.rot
		}

		if unit:movement():action_request(action_desc) then
			CopLogicTravel._on_destination_reached(data)
		end
	elseif my_data.advancing then
		if my_data.coarse_path then
			if my_data.announce_t and my_data.announce_t < t then
				CopLogicTravel._try_anounce(data, my_data)
			end
			
			--CopLogicTravel._chk_stop_for_follow_unit(data, my_data)

			if my_data ~= data.internal_data then
				return
			end
		end
	elseif my_data.advance_path then
		CopLogicTravel._chk_begin_advance(data, my_data)

		if my_data.advancing and my_data.path_ahead then
			CopLogicTravel._check_start_path_ahead(data)
		end
	elseif my_data.processing_advance_path or my_data.processing_coarse_path then
		CopLogicTravel._upd_pathing(data, my_data)
		
		if my_data ~= data.internal_data then
			return
		end
	elseif my_data.cover_leave_t then
		if not my_data.turning and not unit:movement():chk_action_forbidden("walk") and not data.unit:anim_data().reload then
			if my_data.cover_leave_t < t then
				my_data.cover_leave_t = nil
			end
		end
	elseif objective and objective.nav_seg or objective and objective.type == "follow" then
		if my_data.coarse_path then
			if my_data.coarse_path_index == #my_data.coarse_path then
				CopLogicTravel._on_destination_reached(data)

				return
			else
				CopLogicTravel._chk_start_pathing_to_next_nav_point(data, my_data)
			end
		else
			CopLogicTravel._begin_coarse_pathing(data, my_data)
		end
	else
		CopLogicBase._exit(data.unit, "idle")

		return
	end
end

function CopLogicTravel.chk_group_ready_to_move(data, my_data)
	local my_objective = data.objective
	
	if data.is_converted or data.unit:in_slot(16) or data.unit:in_slot(managers.slot:get_mask("criminals")) then
		return true
	end
	
	local dense_units = {
		"security",
		"security_undominatable",
		"cop",
		"cop_scared",
		"cop_female",
		"gensec",
		"fbi",
		"swat",
		"heavy_swat",
		"fbi_swat",
		"fbi_heavy_swat",
		"city_swat",
		"gangster",
		"biker",
		"mobster",
		"bolivian",
		"bolivian_indoors",
		"medic"
	}
	local dense_mook = nil
	for _, name in ipairs(dense_units) do
		if data.unit:base()._tweak_table == name then
			dense_mook = true
		end
	end
	
	--check that the people in my group who have a similar objective to mine have caught up with me
	if not my_objective.grp_objective then
		return true
	end
	
	if data.tactics and data.tactics.obstacle and CopLogicTravel._chk_close_to_criminal(data, my_data) then
		return 
	end
	
	if CopLogicTravel._chk_close_to_criminal(data, my_data) and managers.groupai:state():chk_high_fed_density() and dense_mook then
		return
	end
	
	if CopLogicTravel._chk_close_to_criminal(data, my_data) and managers.groupai:state():chk_active_assault_break() and dense_mook then
		return
	end
	
	local my_dis = mvector3.distance_sq(my_objective.area.pos, data.m_pos)

	if my_dis > 2000 * 2000 and not managers.groupai:state():chk_high_fed_density() then
		return true
	end

	return true
end

local temp_vec4 = Vector3()
local temp_vec5 = Vector3()
local temp_vec6 = Vector3()
function CopLogicTravel._find_cover(data, search_nav_seg, near_pos)
	local cover = nil
	local search_area = nil
	local diff_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)
	
	if data.objective and data.objective.type == "follow" and data.tactics and data.tactics.shield_cover and not data.unit:base()._tweak_table == "shield" and data.attention_obj and data.attention_obj.nav_tracker and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction then
		 local enemy_tracker = data.attention_obj.nav_tracker
		 local threat_pos = enemy_tracker:field_position()
		 local heister_pos = data.attention_obj.m_pos --the threat
		 local shield_pos = data.objective.follow_unit:movement():m_pos() --the pillar
		 local shield_direction = mvector3.direction(temp_vec4, my_pos, shield_pos)
		 local heister_direction = mvector3.direction(temp_vec5, my_pos, heister_pos)
		 local following_direction = mvector3.direction(temp_vec6, shield_direction, heister_direction)
		 local following_dis = following_direction * 120
		 local near_pos = data.objective.follow_unit:movement():m_pos() + following_dis
		 local follow_unit_area = managers.groupai:state():get_area_from_nav_seg_id(data.objective.follow_unit:movement():nav_tracker():nav_segment())
		 
		 local cover = managers.navigation:find_cover_in_nav_seg_3(follow_unit_area.nav_segs, data.objective.distance and data.objective.distance * 0.9 or nil, near_pos, threat_pos)
		 
	elseif data.objective and data.objective.type == "follow" then
		search_area = managers.groupai:state():get_area_from_nav_seg_id(data.objective.follow_unit:movement():nav_tracker():nav_segment())
	else
		search_area = managers.groupai:state():get_area_from_nav_seg_id(search_nav_seg)
	end
	
	if data.unit:movement():cool() then
		cover = managers.navigation:find_cover_in_nav_seg_1(search_area.nav_segs)
	else
		local optimal_threat_dis, threat_pos = nil
		
		if data.unit:base()._tweak_table == "spooc" or data.unit:base()._tweak_table == "taser" then --make sure these two boys are getting appropriate ranges
			if diff_index <= 5 and data.unit:base()._tweak_table == "spooc" and not Global.game_settings.use_intense_AI then
				optimal_threat_dis = 900
			else
				optimal_threat_dis = 1400
			end
		elseif data.tactics and data.tactics.charge and data.objective.attitude == "engage" then --charge is an aggressive tactic, so i want it actually being aggressive as possible
			optimal_threat_dis = data.internal_data.weapon_range.close * 0.5
		elseif data.objective.attitude == "engage" and data.tactics and not data.tactics.charge then --everything else is not required to find it.
			if diff_index <= 5 and not Global.game_settings.use_intense_AI then
				optimal_threat_dis = data.internal_data.weapon_range.optimal
			else
				optimal_threat_dis = data.internal_data.weapon_range.close
			end
		else
			optimal_threat_dis = data.internal_data.weapon_range.optimal
		end

		near_pos = near_pos or search_area.pos
		
		if data.attention_obj and data.attention_obj.reaction <= AIAttentionObject.REACT_COMBAT then
			threat_pos = data.attention_obj.m_pos
		else
			local all_criminals = managers.groupai:state():all_char_criminals()
			local closest_crim_u_data, closest_crim_dis = nil

			for u_key, u_data in pairs(all_criminals) do
				local crim_area = managers.groupai:state():get_area_from_nav_seg_id(u_data.tracker:nav_segment()) --this checks for the area any criminal units are standing in, this includes players and bots, keep in mind, this is nav-segment to nav-segment, so its map-dependant

				if crim_area == search_area then
					threat_pos = u_data.m_pos

					break
				else
					local crim_dis = mvector3.distance_sq(near_pos, u_data.m_pos)

					if not closest_crim_dis or crim_dis < closest_crim_dis then
						threat_pos = u_data.m_pos
						closest_crim_dis = crim_dis
					end
				end
			end
		end
		
		if not cover then
			cover = managers.navigation:find_cover_from_threat(search_area.nav_segs, optimal_threat_dis, near_pos, threat_pos)
		end
	end

	return cover
end

function CopLogicTravel.apply_wall_offset_to_cover(data, my_data, cover, wall_fwd_offset)
	local to_pos_fwd = tmp_vec1

	mvector3.set(to_pos_fwd, cover[2])
	mvector3.multiply(to_pos_fwd, wall_fwd_offset)
	mvector3.add(to_pos_fwd, cover[1])

	local ray_params = {
		trace = true,
		tracker_from = cover[3],
		pos_to = to_pos_fwd
	}
	local collision = managers.navigation:raycast(ray_params)

	if not collision then
		return cover[1]
	end

	local col_pos_fwd = ray_params.trace[1]
	local space_needed = mvector3.distance(col_pos_fwd, to_pos_fwd) + wall_fwd_offset * 1.15 --15% extra space for no clippy clip
	local to_pos_bwd = tmp_vec2

	mvector3.set(to_pos_bwd, cover[2])
	mvector3.multiply(to_pos_bwd, -space_needed)
	mvector3.add(to_pos_bwd, cover[1])

	local ray_params = {
		trace = true,
		tracker_from = cover[3],
		pos_to = to_pos_bwd
	}
	local collision = managers.navigation:raycast(ray_params)

	return collision and ray_params.trace[1] or mvector3.copy(to_pos_bwd)
end

function CopLogicTravel.action_complete_clbk(data, action)
	local my_data = data.internal_data
	local action_type = action:type()
	local no_cover_wait = my_data.additional_unit_configs and my_data.additional_unit_configs.no_cover_wait
	local no_height_cover_wait = my_data.additional_unit_configs and my_data.additional_unit_configs.no_tacticool_cover_check
	local no_cover_search_dis_change = my_data.additional_unit_configs and my_data.additional_unit_configs.no_cover_dis_change
	
	local mook_units = {
		"security",
		"security_undominatable",
		"cop",
		"cop_scared",
		"cop_female",
		"gensec",
		"fbi",
		"swat",
		"heavy_swat",
		"fbi_swat",
		"fbi_heavy_swat",
		"city_swat",
		"gangster",
		"biker",
		"mobster",
		"bolivian",
		"bolivian_indoors",
		"medic",
		"taser"
	}
	local is_mook = nil
	for _, name in ipairs(mook_units) do
		if data.unit:base()._tweak_table == name then
			is_mook = true
		end
	end
	
	
	--if is_mook then
		--log("AHAHAHAHAH FUCK YEAH IS_MOOK")
	--end

	if action_type == "walk" then
		--if CopLogicTravel.chk_slide_conditions(data) then 
			--data.unit:movement():play_redirect("e_nl_slide_fwd_4m")
		--end
		if action:expired() and not my_data.starting_advance_action and my_data.coarse_path_index and not my_data.has_old_action and my_data.advancing then
			my_data.coarse_path_index = my_data.coarse_path_index + 1

			if my_data.coarse_path_index > #my_data.coarse_path then
				debug_pause_unit(data.unit, "[CopLogicTravel.action_complete_clbk] invalid coarse path index increment", data.unit, inspect(my_data.coarse_path), my_data.coarse_path_index)

				my_data.coarse_path_index = my_data.coarse_path_index - 1
			end
		end

		my_data.advancing = nil

		if my_data.moving_to_cover then
			if action:expired() then
				if my_data.best_cover then
					managers.navigation:release_cover(my_data.best_cover[1])
				end

				my_data.best_cover = my_data.moving_to_cover

				CopLogicBase.chk_cancel_delayed_clbk(my_data, my_data.cover_update_task_key)

				local high_ray = CopLogicTravel._chk_cover_height(data, my_data.best_cover[1], data.visibility_slotmask)
				my_data.best_cover[4] = high_ray
				my_data.in_cover = true
				
				local cover_wait_time = nil
				
				local should_tacticool_wait = data.attention_obj and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction and data.attention_obj.dis >= 1200 and data.attention_obj.verified_t and data.t - data.attention_obj.verified_t < math.random(2, 4) and math.abs(data.m_pos.z - data.attention_obj.m_pos.z) > 250 or managers.groupai:state():chk_high_fed_density() --if an enemy is not at semi equal height, and further than 12 meters, and we've seen him at least two to four seconds ago, do a slower, more tacticool approach
				
				if should_tacticool_wait then
					cover_wait_time = math.random(0.4, 0.64) --If there is a height advantage/disadvantage, act tacticool and approach slower.
					--log("HH: cop waiting due to height difference")
				else
					cover_wait_time = math.random(0.35, 0.5) --Keep enemies aggressive and active while still preserving some semblance of what used to be the original pacing while not in Shin Shootout mode
				end
				
				if not is_mook or Global.game_settings.one_down and not managers.groupai:state():chk_high_fed_density() or managers.skirmish:is_skirmish() and not managers.groupai:state():chk_high_fed_density() or data.unit:base():has_tag("takedown") or data.is_converted or data.unit:in_slot(16) or data.unit:in_slot(managers.slot:get_mask("criminals")) then
					my_data.cover_leave_t = data.t + 0
				else
					my_data.cover_leave_t = data.t + cover_wait_time
				end
				
			else
				managers.navigation:release_cover(my_data.moving_to_cover[1])

				if my_data.best_cover then
					local facing_cover = nil
					local dis = mvector3.distance(my_data.best_cover[1][1], data.unit:movement():m_pos())
					local cover_search_dis = nil
					
					if no_cover_search_dis_change or not is_mook then
						cover_search_dis = 100
					else
						cover_search_dis = 100
					end
					
					--if cover_search_dis == 200 then
						--log("thats hot")
					--end

					if dis > cover_search_dis then
						managers.navigation:release_cover(my_data.best_cover[1])

						my_data.best_cover = nil
					end
				end
			end

			my_data.moving_to_cover = nil
		elseif my_data.best_cover then
			local dis = mvector3.distance(my_data.best_cover[1][1], data.unit:movement():m_pos())
			local cover_search_dis = nil
					
			if no_cover_search_dis_change or not is_mook then
				cover_search_dis = 100
			else
				cover_search_dis = 100
			end
			
			if dis > cover_search_dis then
				managers.navigation:release_cover(my_data.best_cover[1])

				my_data.best_cover = nil
			end
		end

		if not action:expired() then
			if my_data.processing_advance_path then
				local pathing_results = data.pathing_results

				if pathing_results and pathing_results[my_data.advance_path_search_id] then
					data.pathing_results[my_data.advance_path_search_id] = nil
					my_data.processing_advance_path = nil
				end
			elseif my_data.advance_path then
				my_data.advance_path = nil
			end

			data.unit:brain():abort_detailed_pathing(my_data.advance_path_search_id)
		end
	elseif action_type == "turn" then
		data.internal_data.turning = nil
	elseif action_type == "shoot" then
		data.internal_data.shooting = nil
	elseif action_type == "dodge" then
		local objective = data.objective
		local allow_trans, obj_failed = CopLogicBase.is_obstructed(data, objective, nil, nil)

		if allow_trans then
			local wanted_state = data.logic._get_logic_state_from_reaction(data)

			if wanted_state and wanted_state ~= data.name and obj_failed then
				if data.unit:in_slot(managers.slot:get_mask("enemies")) or data.unit:in_slot(17) then
					data.objective_failed_clbk(data.unit, data.objective)
				elseif data.unit:in_slot(managers.slot:get_mask("criminals")) then
					managers.groupai:state():on_criminal_objective_failed(data.unit, data.objective, false)
				end

				if my_data == data.internal_data then
					debug_pause_unit(data.unit, "[CopLogicTravel.action_complete_clbk] exiting without discarding objective", data.unit, inspect(data.objective))
					CopLogicBase._exit(data.unit, wanted_state)
				end
			end
		end
	end
end

function CopLogicTravel._update_cover(ignore_this, data)
	local my_data = data.internal_data
	
	local mook_units = {
		"security",
		"security_undominatable",
		"cop",
		"cop_scared",
		"cop_female",
		"gensec",
		"fbi",
		"swat",
		"heavy_swat",
		"fbi_swat",
		"fbi_heavy_swat",
		"city_swat",
		"gangster",
		"biker",
		"mobster",
		"bolivian",
		"bolivian_indoors",
		"medic",
		"taser"
	}
	local is_mook = nil
	for _, name in ipairs(mook_units) do
		if data.unit:base()._tweak_table == name then
			is_mook = true
		end
	end

	CopLogicBase.on_delayed_clbk(my_data, my_data.cover_update_task_key)

	local cover_release_dis = nil
	
	if not is_mook then
		cover_release_dis = 100
	else
		if data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.dis > 10000 then
			cover_release_dis = 500
		else
			cover_release_dis = 75
		end
	end
	
	local nearest_cover = my_data.nearest_cover
	local best_cover = my_data.best_cover
	local m_pos = data.m_pos
	local facing_cover = nil

	if not my_data.in_cover and nearest_cover and cover_release_dis < mvector3.distance(nearest_cover[1][1], m_pos) then
		managers.navigation:release_cover(nearest_cover[1])

		my_data.nearest_cover = nil
		nearest_cover = nil
	end

	if best_cover and cover_release_dis < mvector3.distance(best_cover[1][1], m_pos) then
		managers.navigation:release_cover(best_cover[1])

		my_data.best_cover = nil
		best_cover = nil
	end

	if nearest_cover or best_cover then
		CopLogicBase.add_delayed_clbk(my_data, my_data.cover_update_task_key, callback(CopLogicTravel, CopLogicTravel, "_update_cover", data), data.t + 0.066)
	end
end

function CopLogicTravel._chk_request_action_walk_to_advance_pos(data, my_data, speed, end_rot, no_strafe, pose, end_pose)
	if not data.unit:movement():chk_action_forbidden("walk") and not my_data.turning or data.unit:anim_data().act_idle then
		CopLogicAttack._correct_path_start_pos(data, my_data.advance_path)

		local path = my_data.advance_path
		local new_action_data = {
			type = "walk",
			body_part = 2,
			nav_path = path,
			variant = speed or "run",
			end_rot = end_rot,
			path_simplified = my_data.path_is_precise,
			no_strafe = no_strafe,
			pose = pose,
			end_pose = end_pose
		}
		my_data.advance_path = nil
		my_data.starting_advance_action = true
		my_data.advancing = data.unit:brain():action_request(new_action_data)
		my_data.starting_advance_action = false

		if my_data.advancing then
			data.brain:rem_pos_rsrv("path")
			
			local notdelayclbksornotdlclbks_chk = not my_data.delayed_clbks or not my_data.delayed_clbks[my_data.cover_update_task_key]
			if my_data.nearest_cover and notdelayclbksornotdlclbks_chk then
				CopLogicBase.add_delayed_clbk(my_data, my_data.cover_update_task_key, callback(CopLogicTravel, CopLogicTravel, "_update_cover", data), data.t + 0.066)
			end
		end
	end
end

function CopLogicTravel._chk_begin_advance(data, my_data)
	if my_data.turning or data.unit:movement():chk_action_forbidden("walk") then
		return
	end

	local objective = data.objective
	local haste = nil
	local pose = nil
	
	local mook_units = {
		"security",
		"security_undominatable",
		"cop",
		"cop_scared",
		"cop_female",
		"heavy_swat_sniper",
		"gensec",
		"shield",
		"fbi",
		"swat",
		"heavy_swat",
		"fbi_swat",
		"fbi_heavy_swat",
		"city_swat",
		"gangster",
		"biker",
		"mobster",
		"bolivian",
		"bolivian_indoors",
		"medic",
		"taser"
	}
	local is_mook = nil
	for _, name in ipairs(mook_units) do
		if data.unit:base()._tweak_table == name then
			is_mook = true
		end
	end
	
	--this is a mess, but it should keep enemy movement tacticool overall, by having them prefer slower apporoaches at close ranges
	
	local pose_chk = not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.crouch
	local enemyseeninlast4secs = data.attention_obj and data.attention_obj.verified_t and data.t - data.attention_obj.verified_t < 4
	local enemy_seen_range_bonus = enemyseeninlast4secs and 500 or 0
	local enemy_has_height_difference = data.attention_obj and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction and data.attention_obj.dis >= 1200 and data.attention_obj.verified_t and data.t - data.attention_obj.verified_t < 4 and math.abs(data.m_pos.z - data.attention_obj.m_pos.z) > 250
	local height_difference_penalty = data.attention_obj and math.abs(data.m_pos.z - data.attention_obj.m_pos.z) < 250 and 400 or 0
	
	if data.unit:movement():cool() then
			haste = "walk"
	elseif data.is_converted or data.unit:in_slot(16) or data.attention_obj and data.attention_obj.dis > 10000 then
		haste = "run"
	elseif data.attention_obj and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction and data.attention_obj.dis > 1200 + enemy_seen_range_bonus and not data.unit:movement():cool() and not managers.groupai:state():whisper_mode() then
		haste = "run"
	elseif data.attention_obj and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction and data.attention_obj.dis <= 1200 + enemy_seen_range_bonus - height_difference_penalty and is_mook and data.tactics and not data.tactics.hitnrun then
		haste = "walk"
	else
		haste = "run"
	end

	local should_crouch = nil

	local end_rot = nil

	if my_data.coarse_path_index >= #my_data.coarse_path - 1 then
		end_rot = objective and objective.rot
	end

	local no_strafe, end_pose = nil
	
	local crouch_roll = math.random(0.01, 1)
	local stand_chance = nil
	local enemy_visible15m_or_10m_chk = data.attention_obj and data.attention_obj.verified and data.attention_obj.dis <= 1500 or data.attention_obj and data.attention_obj.dis <= 1000
	
	if data.attention_obj and data.attention_obj.dis > 10000 or data.unit:in_slot(16) or data.is_converted then
		stand_chance = 1
	elseif data.attention_obj and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction and data.attention_obj.dis > 2000 and is_mook then
		stand_chance = 0.75
	elseif enemy_has_height_difference and enemy_visible15m_or_10m_chk and is_mook then
		stand_chance = 0.25
	elseif data.attention_obj and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction and enemy_visible15m_or_10m_chk and CopLogicTravel._chk_close_to_criminal(data, my_data) and data.tactics and data.tactics.flank and haste == "walk" and is_mook then
		stand_chance = 0.25
	elseif my_data.moving_to_cover and pose_chk then
		stand_chance = 0.5
	else
		stand_chance = 0.5
	end
	
	--randomize enemy crouching to make enemies feel less easy to aim at, the fact they're always crouching all over the place always bugged me, plus, they shouldn't need to crouch so often when you're at long distances from them
	
	if not data.unit:movement():cool() and not managers.groupai:state():whisper_mode() then
		if stand_chance ~= 1 and crouch_roll > stand_chance and (not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.crouch) or data.char_tweak.allowed_poses and data.char_tweak.allowed_poses.crouch then
			end_pose = "crouch"
			pose = "crouch"
		else
			end_pose = "stand"
			pose = "stand"
		end
	end
	
	if not pose then
		pose = not data.char_tweak.crouch_move and "stand" or data.char_tweak.allowed_poses and not data.char_tweak.allowed_poses.stand and "crouch" or "stand"
	end
	
	if not data.unit:anim_data()[pose] then
		CopLogicAttack["_chk_request_action_" .. pose](data)
	end
	
	if managers.groupai:state():chk_high_fed_density() and data.attention_obj and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction and data.attention_obj.dis < 3000 then
		local randomwalkchance = math.random(0.01, 1)
		if randomwalkchance > 0.10 then
			haste = "walk"
		else
			haste = haste
		end
	end

	CopLogicTravel._chk_request_action_walk_to_advance_pos(data, my_data, haste, end_rot, no_strafe, pose, end_pose)
end

function CopLogicTravel._get_exact_move_pos(data, nav_index)
	local my_data = data.internal_data
	local objective = data.objective
	local to_pos = nil
	local coarse_path = my_data.coarse_path
	local total_nav_points = #coarse_path
	local reservation, wants_reservation = nil
	local should_wall_offset = data.attention_obj and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction and not data.attention_obj.verified and data.attention_obj.dis <= 3000

	if total_nav_points <= nav_index then
		local new_occupation = data.logic._determine_destination_occupation(data, objective)

		if new_occupation then
			if new_occupation.type == "guard" then
				local guard_door = new_occupation.door
				local guard_pos = CopLogicTravel._get_pos_accross_door(guard_door, objective.nav_seg)

				if guard_pos then
					reservation = CopLogicTravel._reserve_pos_along_vec(guard_door.center, guard_pos)

					if reservation then
						local guard_object = {
							type = "door",
							door = guard_door,
							from_seg = new_occupation.from_seg
						}
						objective.guard_obj = guard_object
						to_pos = reservation.pos
					end
				end
			elseif new_occupation.type == "defend" then
				if new_occupation.cover then
					to_pos = new_occupation.cover[1][1]

					if should_wall_offset or data.char_tweak.wall_fwd_offset then
						local wall_fwd_offset = data.char_tweak.wall_fwd_offset or 40
						to_pos = CopLogicTravel.apply_wall_offset_to_cover(data, my_data, new_occupation.cover[1], wall_fwd_offset)
					end

					local new_cover = new_occupation.cover

					managers.navigation:reserve_cover(new_cover[1], data.pos_rsrv_id)

					my_data.moving_to_cover = new_cover
				elseif new_occupation.pos then
					to_pos = new_occupation.pos
				end

				wants_reservation = true
			elseif new_occupation.type == "act" then
				to_pos = new_occupation.pos
				wants_reservation = true
			elseif new_occupation.type == "revive" then
				to_pos = new_occupation.pos
				objective.rot = new_occupation.rot
				wants_reservation = true
			else
				to_pos = new_occupation.pos
				wants_reservation = true
			end
		end

		if not to_pos then
			to_pos = managers.navigation:find_random_position_in_segment(objective.nav_seg)
			to_pos = CopLogicTravel._get_pos_on_wall(to_pos)
			wants_reservation = true
		end
	else
		local nav_seg = coarse_path[nav_index][1]
		local area = managers.groupai:state():get_area_from_nav_seg_id(nav_seg)
		local cover = managers.navigation:find_cover_in_nav_seg_1(area.nav_segs)

		if my_data.moving_to_cover then
			managers.navigation:release_cover(my_data.moving_to_cover[1])

			my_data.moving_to_cover = nil
		end

		if cover then
			managers.navigation:reserve_cover(cover, data.pos_rsrv_id)

			my_data.moving_to_cover = {
				cover
			}
			to_pos = cover[1]
		else
			to_pos = coarse_path[nav_index][2]
		end
	end

	if not reservation and wants_reservation then
		data.brain:add_pos_rsrv("path", {
			radius = 30,
			position = mvector3.copy(to_pos)
		})
	end

	return to_pos
end

function CopLogicTravel.get_pathing_prio(data)
	local prio = nil
	local objective = data.objective
	local focus_enemy = data.attention_obj
	
	if objective then
		prio = 4
		
		if (objective.follow_unit or objective.type == "phalanx") then
			prio = prio + 1
			
			if focus_enemy and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction and focus_enemy.dis < 4000 then
				prio = prio + 2
			end
		end
		
		if data.team.id == tweak_data.levels:get_default_team_ID("player") or data.is_converted or data.unit:in_slot(16) or data.unit:in_slot(managers.slot:get_mask("criminals")) then
			prio = prio + 2
		end	
	end

	return prio
end