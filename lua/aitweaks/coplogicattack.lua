local mvec3_x = mvector3.x
local mvec3_y = mvector3.y
local mvec3_z = mvector3.z
local mvec3_set = mvector3.set
local mvec3_set_z = mvector3.set_z
local mvec3_sub = mvector3.subtract
local mvec3_dir = mvector3.direction
local mvec3_dot = mvector3.dot
local mvec3_dis = mvector3.distance
local mvec3_dis_sq = mvector3.distance_sq
local mvec3_lerp = mvector3.lerp
local mvec3_norm = mvector3.normalize
local mvec3_add = mvector3.add
local mvec3_mul = mvector3.multiply
local mvec3_cross = mvector3.cross
local mvec3_rand_ortho = mvector3.random_orthogonal
local mvec3_negate = mvector3.negate
local mvec3_len = mvector3.length
local mvec3_len_sq = mvector3.length_sq
local mvec3_cpy = mvector3.copy
local mvec3_set_stat = mvector3.set_static
local mvec3_set_length = mvector3.set_length
local mvec3_angle = mvector3.angle
local mvec3_step = mvector3.step
local math_lerp = math.lerp
local math_random = math.random
local math_up = math.UP
local math_abs = math.abs
local math_clamp = math.clamp
local math_min = math.min
local m_rot_x = mrotation.x
local m_rot_y = mrotation.y
local m_rot_z = mrotation.z
local table_insert = table.insert
local table_contains = table.contains
local temp_vec1 = Vector3()
local temp_vec2 = Vector3()
local temp_vec3 = Vector3()

function CopLogicAttack.enter(data, new_logic_name, enter_params)
	CopLogicBase.enter(data, new_logic_name, enter_params)
	data.unit:brain():cancel_all_pathing_searches()
	local prefix = data.unit:sound():chk_voice_prefix() or "empty"
	local is_radio_cop = prefix == "l1d_" or prefix == "l2d_" or prefix == "l3d_" or prefix == "l4d_" or prefix == "l5d_"

	local old_internal_data = data.internal_data
	local my_data = {
		unit = data.unit
	}
	data.internal_data = my_data
	my_data.detection = data.char_tweak.detection.combat
	
	--if Global.game_settings.thethreekings then
	--	log("oh worm")
	--end
	--New times are coming, ngl.
	
	if old_internal_data then
		my_data.turning = old_internal_data.turning
		my_data.firing = old_internal_data.firing
		my_data.shooting = old_internal_data.shooting
		my_data.attention_unit = old_internal_data.attention_unit

		CopLogicAttack._set_best_cover(data, my_data, old_internal_data.best_cover)
	end
	
	if prefix ~= "empty" and is_radio_cop then
		my_data.radio_voice = true
	end

	my_data.cover_test_step = 1
	local key_str = tostring(data.key)
	my_data.detection_task_key = "CopLogicAttack._upd_enemy_detection" .. key_str

	CopLogicBase.queue_task(my_data, my_data.detection_task_key, CopLogicAttack._upd_enemy_detection, data, data.t)
	CopLogicIdle._chk_has_old_action(data, my_data)

	my_data.attitude = data.objective and data.objective.attitude or "avoid"
	
	if data.char_tweak.weapon[data.unit:inventory():equipped_unit():base():weapon_tweak_data().usage].range then
		my_data.weapon_range = data.char_tweak.weapon[data.unit:inventory():equipped_unit():base():weapon_tweak_data().usage].range
	else
		local safety_range = {
			optimal = 3500,
			far = 6000,
			close = 2000
		}
		
		my_data.weapon_range = safety_range
	end

	data.unit:brain():set_update_enabled_state(true)

	if data.cool then
		data.unit:movement():set_cool(false)
	end
	
	local stance_chk = not data.objective or not data.objective.stance
	
	if stance_chk and data.unit:movement():stance_code() == 1 then
		data.unit:movement():set_stance("hos")
	end

	if my_data ~= data.internal_data then
		return
	end
	
	local objective_duration_chk = data.objective and data.objective.action_duration or data.objective and data.objective.action_timeout_t and data.t < data.objective.action_timeout_t
	
	if data.objective and objective_duration_chk then
		my_data.action_timeout_clbk_id = "CopLogicIdle_action_timeout" .. tostring(data.key)
		local action_timeout_t = data.objective.action_timeout_t or data.t + data.objective.action_duration
		data.objective.action_timeout_t = action_timeout_t

		CopLogicBase.add_delayed_clbk(my_data, my_data.action_timeout_clbk_id, callback(CopLogicIdle, CopLogicIdle, "clbk_action_timeout", data), action_timeout_t)
	end

	data.unit:brain():set_attention_settings({
		cbt = true
	})
end

function CopLogicAttack.aim_allow_fire(shoot, aim, data, my_data)
	local focus_enemy = data.attention_obj

	if shoot then
		if not my_data.firing then
			data.unit:movement():set_allow_fire(true)

			my_data.firing = true

			if not data.unit:in_slot(16) and not data.is_converted and data.char_tweak and data.char_tweak.chatter and data.char_tweak.chatter.aggressive then
				if not data.unit:base():has_tag("special") and data.unit:base():has_tag("law") and not data.unit:base()._tweak_table == "gensec" and not data.unit:base()._tweak_table == "security" then
					if focus_enemy.verified and focus_enemy.verified_dis <= 500 then
						if managers.groupai:state():chk_assault_active_atm() then
							local roll = math.random(1, 100)
						
							if roll < 33 then
								managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "aggressivecontrolsurprised1")
							elseif roll < 66 and roll > 33 then
								managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "aggressivecontrolsurprised2")
							else
								managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "open_fire")
							end
						else
							local roll = math.random(1, 100)
						
							if roll <= chance_heeeeelpp then
								managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "aggressivecontrolsurprised1")
							else --hopefully some variety here now
								managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "aggressivecontrolsurprised2")
							end	
						end
					else
						if managers.groupai:state():chk_assault_active_atm() then
							managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "open_fire")
						else
							managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "aggressivecontrol")
						end
					end
				elseif data.unit:base():has_tag("special") then
					if not data.unit:base():has_tag("tank") and data.unit:base():has_tag("medic") then
						managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "aggressive")
					elseif data.unit:base():has_tag("shield") then
						local shield_knock_cooldown = math.random(3, 6)
						if not my_data.shield_knock_cooldown or my_data.shield_knock_cooldown < data.t then
							local diff_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)	
							my_data.shield_knock_cooldown = data.t + shield_knock_cooldown
									
							if diff_index < 8 then
								data.unit:sound():play("shield_identification", nil, true)
							else
								data.unit:sound():play("hos_shield_indication_sound_terminator_style", nil, true)
							end
						end
					else
						managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "contact")
					end
				elseif data.unit:base()._tweak_table == "akuma" then
					managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "contact")
				else
					managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "contact")
				end
			end
		end
	elseif my_data.firing then
		data.unit:movement():set_allow_fire(false)

		my_data.firing = nil
	end
end

function CopLogicAttack.update(data)
	local my_data = data.internal_data

	if my_data.has_old_action then
		CopLogicAttack._upd_stop_old_action(data, my_data)

		if not my_data.update_queue_id then
			data.unit:brain():set_update_enabled_state(false)

			my_data.update_queue_id = "CopLogicAttack.queued_update" .. tostring(data.key)

			CopLogicAttack.queue_update(data, my_data)
		end

		return
	end
	
	local action_taken = data.logic.action_taken(data, my_data)
	
	if not data.is_converted and data.unit:base():has_tag("law") and data.tactics or Global.game_settings.one_down and data.unit:base():has_tag("law") then
		if objective then --currently trying to get rawed by 9 lonewolves at the burger king drive-in in front of 81 other cops
			if Global.game_settings.one_down or data.tactics.lonewolf then
				if objective.follow_unit then
					if objective.follow_unit:brain() and objective.follow_unit:brain().objective and objective.follow_unit:brain():objective() ~= nil then
						local new_objective = objective.follow_unit:brain():objective() --ignore following the "follow_unit", copy their objective and become standalone instead in order to execute pinches and flanking manuevers freely
						--log("ay caramba
						
						if new_objective.type ~= "surrender" then
							data.unit:brain():set_objective(new_objective, nil)
						end
						
						return
					end
				end
			end
		end
	end
	
	if my_data.tasing then
		action_taken = action_taken or CopLogicAttack._chk_request_action_turn_to_enemy(data, my_data, data.m_pos, focus_enemy.m_pos)
		
		if data.internal_data == my_data then
			CopLogicBase._report_detections(data.detected_attention_objects)
			CopLogicAttack.queue_update(data, my_data)
		end

		return
	end
	
	if my_data.spooc_attack then
		
		if data.internal_data == my_data then
			CopLogicBase._report_detections(data.detected_attention_objects)
			CopLogicAttack.queue_update(data, my_data)
		end

		return
	end
	
	if data.unit:base()._tweak_table == "spooc" or data.unit:base()._tweak_table == "heavy_spooc" or data.unit:base()._tweak_table == "shadow_spooc" or data.unit:base()._tweak_table == "spooc_titan" then
		SpoocLogicAttack._upd_spooc_attack(data, my_data)
	end

	if my_data.spooc_attack then
		if data.internal_data == my_data then
			CopLogicAttack.queue_update(data, data.internal_data, delay)
		end

		return
	end
	
	local hostage_count = managers.groupai:state():get_hostage_count_for_chatter() --check current hostage count
	local chosen_panic_chatter = "controlpanic" --set default generic assault break chatter
	
	if hostage_count > 0 then --make sure the hostage count is actually above zero before replacing any of the lines
		if hostage_count > 3 then  -- hostage count needs to be above 3
			if math_random() < 0.4 then --40% chance for regular panic if hostages are present
				chosen_panic_chatter = "controlpanic"
			else
				chosen_panic_chatter = "hostagepanic2" --more panicky "GET THOSE HOSTAGES OUT RIGHT NOW!!!" line for when theres too many hostages on the map
			end
		else
			if math_random() < 0.4 then
				chosen_panic_chatter = "controlpanic"
			else
				chosen_panic_chatter = "hostagepanic1" --less panicky "Delay the assault until those hostages are out." line
			end
		end
			
		if managers.groupai:state():chk_has_civilian_hostages() then
			--log("they got sausages!")
			if math_random() < 0.5 then
				chosen_panic_chatter = chosen_panic_chatter
			else
				chosen_panic_chatter = "civilianpanic"
			end
		end
			
	elseif managers.groupai:state():chk_had_hostages() then
		if math_random() < 0.4 then
			chosen_panic_chatter = "controlpanic"
		else
			chosen_panic_chatter = "hostagepanic3" -- no more hostages!!! full force!!!
		end
	end
	
	local chosen_sabotage_chatter = "sabotagegeneric" --set default sabotage chatter for variety's sake
	local skirmish_map = managers.skirmish:is_skirmish()--these shouldnt play on holdout
	local ignore_radio_rules = nil
	
	if objective and objective.bagjob then
		--log("oh, worm")
		chosen_sabotage_chatter = "sabotagebags"
		ignore_radio_rules = true
	elseif objective and objective.hostagejob then
		--log("sausage removal squadron")
		chosen_sabotage_chatter = "sabotagehostages"
		ignore_radio_rules = true 
	else
		chosen_sabotage_chatter = "sabotagegeneric" --if none of these levels are the current one, use a generic "Break their gear!" line
	end
		
	local clear_t_chk = not data.attention_obj or not data.attention_obj.verified_t or data.attention_obj.verified_t - data.t > math_random(2.5, 5)	
		
	local cant_say_clear = not data.attention_obj or AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and clear_t_chk
		
	if not data.unit:base():has_tag("special") and not cant_say_clear and not data.is_converted then
		if data.unit:movement():cool() and data.char_tweak.chatter and data.char_tweak.chatter.clear_whisper then
			managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "clear_whisper" )
		elseif not data.unit:movement():cool() then
			if not managers.groupai:state():chk_assault_active_atm() then
				if data.char_tweak.chatter and data.char_tweak.chatter.controlpanic then
					local clearchk = math_random(0, 90)
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
				elseif data.char_tweak.chatter and data.char_tweak.chatter.clear then
					managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "clear" )
				end
			end
		end
	end
	
	if data.unit:base():has_tag("special") and not cant_say_clear then
		if data.unit:base():has_tag("tank") or data.unit:base():has_tag("taser") then
			managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "approachingspecial" )
		elseif data.unit:base()._tweak_table == "shield" then
			--fuck off
		elseif data.unit:base()._tweak_table == "akuma" then
			managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "lotusapproach" )
		end
	end
		
	--mid-assault panic for cops based on alerts instead of opening fire, since its supposed to be generic action lines instead of for opening fire and such
	--I'm adding some randomness to these since the delays in groupaitweakdata went a bit overboard but also arent able to really discern things proper
				
	if data.char_tweak and data.char_tweak.chatter and data.char_tweak.chatter.enemyidlepanic and not data.is_converted then
		if not data.unit:base():has_tag("special") and data.unit:base():has_tag("law") then
			if managers.groupai:state():chk_assault_active_atm() then
				if managers.groupai:state():_check_assault_panic_chatter() then
					if data.attention_obj and data.attention_obj.verified and data.attention_obj.dis <= 500 or data.is_suppressed and data.attention_obj and data.attention_obj.verified then
						local roll = math_random(1, 100)
						local chance_suppanic = 50
						
						if roll <= chance_suppanic then
							local nroll = math_random(1, 100)
							local chance_help = 50
							if roll <= chance_suppanic then
								managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "assaultpanicsuppressed1" )
							else
								managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "assaultpanicsuppressed2" )
							end
						else
							managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "assaultpanic" )
						end
					else
						if math_random() < 0.2 then
							managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, chosen_sabotage_chatter )
						else
							managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "assaultpanic" )
						end
					end
				else
					local clearchk = math_random(0, 90)
						
					if clearchk > 60 then
						if not skirmish_map and my_data.radio_voice or not skirmish_map and ignore_radio_rules then
							managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, chosen_sabotage_chatter )
						end
					elseif chosen_panic_chatter == "civilianpanic" then
						managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, chosen_panic_chatter )
					end
				end
			end
		elseif not data.unit:base():has_tag("special") and data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.verified_t or not data.unit:base():has_tag("special") and data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.alert_t then
		
			if data.attention_obj.verified and data.attention_obj.dis <= 500 or data.is_suppressed and data.attention_obj.verified then
				local roll = math_random(1, 100)
				local chance_suppanic = 50
						
				if roll <= chance_suppanic then
					local nroll = math_random(1, 100)
					local chance_help = 50
					if roll <= chance_suppanic then
						managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "assaultpanicsuppressed1" )
					else
						managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "assaultpanicsuppressed2" )
					end
				else
					managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "assaultpanic" )
				end
			else
				managers.groupai:state():chk_say_enemy_chatter( data.unit, data.m_pos, "assaultpanic" )
			end
		end
	end

	if CopLogicIdle._chk_relocate(data) then
		return
	end

	if CopLogicAttack._chk_exit_non_walkable_area(data) then
		return
	end

	CopLogicAttack._process_pathing_results(data, my_data)

	if not data.attention_obj or data.attention_obj.reaction < AIAttentionObject.REACT_AIM then
		CopLogicAttack._upd_enemy_detection(data, true)

		if my_data ~= data.internal_data or not data.attention_obj then
			return
		end
	end
	
	CopLogicAttack._chk_start_action_move_out_of_the_way(data, my_data)

	if AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction then
		my_data.want_to_take_cover = CopLogicAttack._chk_wants_to_take_cover(data, my_data)

		CopLogicAttack._update_cover(data)
		CopLogicTravel._upd_combat_movement(data)
	end

	if data.team.id == "criminal1" and (not data.objective or data.objective.type == "free") and (not data.path_fail_t or data.t - data.path_fail_t > 6) then
		managers.groupai:state():on_criminal_jobless(data.unit)

		if my_data ~= data.internal_data then
			return
		end
	end

	if not my_data.update_queue_id then
		data.unit:brain():set_update_enabled_state(false)

		my_data.update_queue_id = "CopLogicAttack.queued_update" .. tostring(data.key)

		CopLogicAttack.queue_update(data, my_data)
	end
end

function CopLogicAttack._upd_aim(data, my_data)
	
	if my_data.spooc_attack then
		if my_data.attention_unit ~= my_data.spooc_attack.target_u_data.u_key then
			CopLogicBase._set_attention(data, my_data.spooc_attack.target_u_data)

			my_data.attention_unit = my_data.spooc_attack.target_u_data.u_key
		end
		
		return
	end
	
	local shoot, aim, expected_pos = nil
	local focus_enemy = data.attention_obj
	local running = data.unit:movement()._active_actions[2] and data.unit:movement()._active_actions[2]:type() == "walk" and data.unit:movement()._active_actions[2]:haste() == "run"
	local tase = focus_enemy and focus_enemy.reaction >= AIAttentionObject.REACT_SPECIAL_ATTACK

	if focus_enemy then
		if tase and data.unit:base():has_tag("taser") then
			shoot = true
		elseif AIAttentionObject.REACT_AIM <= focus_enemy.reaction then
			if focus_enemy.verified or focus_enemy.nearly_visible then
				local firing_range = 500

				if my_data.weapon_range then
					firing_range = running and my_data.weapon_range.close or my_data.weapon_range.far
				elseif not running then
					firing_range = 1000
				end

				if running and firing_range < focus_enemy.dis then
					local walk_to_pos = data.unit:movement():get_walk_to_pos()

					if walk_to_pos then
						mvec3_dir(temp_vec1, data.m_pos, walk_to_pos)
						mvec3_dir(temp_vec2, data.m_pos, focus_enemy.m_pos)

						local dot = mvec3_dot(temp_vec1, temp_vec2)

						if dot < 0.6 then
							shoot = false
							aim = false
						end
					end
				end

				if aim == nil then
					if AIAttentionObject.REACT_SHOOT <= focus_enemy.reaction then
						local last_sup_t = data.unit:character_damage():last_suppression_t()

						if last_sup_t then
							local sup_t_ver = 7 

							if running then
								sup_t_ver = sup_t_ver * 0.3
							end

							if not focus_enemy.verified then
								if focus_enemy.vis_ray and firing_range < focus_enemy.vis_ray.distance then
									sup_t_ver = sup_t_ver * 0.5
								else
									sup_t_ver = sup_t_ver * 0.2
								end
							end

							if data.t - last_sup_t < sup_t_ver then
								shoot = true
							end
						end

						if not managers.groupai:state():whisper_mode() then
							if data.internal_data.weapon_range and focus_enemy.verified_dis < firing_range and managers.groupai:state():chk_assault_active_atm() then
								shoot = true
							elseif focus_enemy.criminal_record and focus_enemy.criminal_record.assault_t and data.t - focus_enemy.criminal_record.assault_t < 2 then
								shoot = true
							elseif not data.unit:base():has_tag("law") and focus_enemy.verified_dis < firing_range or data.unit:base():has_tag("law") and focus_enemy.aimed_at and focus_enemy.verified_dis <= 1500 then
								shoot = true
							end
						end
						
						if managers.groupai:state():whisper_mode() then
							if not shoot then
								shoot = true
							end
						end
						
						if not shoot and not managers.groupai:state():whisper_mode() and my_data.attitude == "engage" then
							local height_difference = math.abs(data.m_pos.z - data.attention_obj.m_pos.z) > 250
							local z_check = height_difference and 0.75 or 1
							
							if focus_enemy.verified_dis < firing_range * z_check or focus_enemy.reaction == AIAttentionObject.REACT_SHOOT then
								if dense_mook and not my_data.firing then
										--log("not firing due to FEDS")
								else
									shoot = true
								end
							else
								local time_since_verification = focus_enemy.verified_t and data.t - focus_enemy.verified_t
								local suppressingfire_t = 0.75
								
								if data.tactics and data.tactics.harass then
									suppressingfire_t = 2
								end

								if my_data.firing and time_since_verification and time_since_verification < suppressingfire_t then
									shoot = true
								end
							end
						end
						
						if not aim and focus_enemy.verified_dis < firing_range and not running then
							aim = true
						end

						aim = aim or shoot
					else
						aim = true
					end
				end
			else
				local time_since_verification = focus_enemy.verified_t and data.t - focus_enemy.verified_t

				if time_since_verification then
					if running then
						local dis_lerp = math_clamp((focus_enemy.verified_dis - 500) / 600, 0, 1)

						if time_since_verification < math_lerp(5, 1, dis_lerp) then
							aim = true
						end
					elseif time_since_verification < 5 then
						aim = true
					end

					if aim and my_data.shooting and AIAttentionObject.REACT_SHOOT <= focus_enemy.reaction then
						if running then
							local look_pos = focus_enemy.last_verified_pos or focus_enemy.verified_pos
							local same_height = math_abs(look_pos.z - data.m_pos.z) < 250

							if same_height and time_since_verification < 2 then
								shoot = true
							end
						elseif time_since_verification < 3 then
							shoot = true
						end
					end
				end

				if not shoot then
					if not focus_enemy.last_verified_pos or time_since_verification and time_since_verification > 5 then
						my_data.expected_pos = CopLogicAttack._get_expected_attention_position(data, my_data)

						if my_data.expected_pos then
							if running then
								my_data.expected_pos = mvec3_cpy(my_data.expected_pos)
								local watch_dir = temp_vec1

								mvec3_set(watch_dir, my_data.expected_pos)
								mvec3_sub(watch_dir, data.m_pos)
								mvec3_set_z(watch_dir, 0)

								local watch_pos_dis = mvec3_norm(watch_dir)
								local walk_to_pos = data.unit:movement():get_walk_to_pos()
								local walk_vec = temp_vec2

								mvec3_set(walk_vec, walk_to_pos)
								mvec3_sub(walk_vec, data.m_pos)
								mvec3_set_z(walk_vec, 0)
								mvec3_norm(walk_vec)

								local watch_walk_dot = mvec3_dot(watch_dir, walk_vec)

								if watch_pos_dis < 500 or watch_pos_dis < 1000 and watch_walk_dot > 0.85 then
									aim = true
								end
							else
								aim = true
							end
						end
					end
				end
			end
		end
		
		
		if focus_enemy.is_person and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and not data.unit:in_slot(16) and not data.is_converted and data.tactics and data.tactics.harass then
			if focus_enemy.is_local_player then
				local time_since_verify = data.attention_obj.verified_t and data.t - data.attention_obj.verified_t
				local e_movement_state = focus_enemy.unit:movement():current_state()
				
				if e_movement_state:_is_reloading() and time_since_verify and time_since_verify < 2 then
					if not data.unit:in_slot(16) and data.char_tweak.chatter.reload then
						managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "reload")
					end
				end
			else
				local e_anim_data = focus_enemy.unit:anim_data()
				local time_since_verify = data.attention_obj.verified_t and data.t - data.attention_obj.verified_t

				if e_anim_data.reload and time_since_verify and time_since_verify < 2 then
					if not data.unit:in_slot(16) and data.char_tweak.chatter.reload then
						managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "reload")
					end			
				end
			end
		end

		if not aim and data.char_tweak.always_face_enemy and AIAttentionObject.REACT_COMBAT <= focus_enemy.reaction then
			aim = true
		end

		if data.logic.chk_should_turn(data, my_data) then
			local enemy_pos = nil

			if focus_enemy.verified or focus_enemy.nearly_visible then
				enemy_pos = focus_enemy.m_pos
			else
				enemy_pos = my_data.expected_pos or focus_enemy.last_verified_pos or focus_enemy.verified_pos
			end

			CopLogicAttack._chk_request_action_turn_to_enemy(data, my_data, data.m_pos, enemy_pos)
		end
	end
	
	local is_moving = my_data.walking_to_cover_shoot_pos or my_data.moving_to_cover or data.unit:anim_data().run or data.unit:anim_data().move
	if tase and is_moving and not data.unit:movement():chk_action_forbidden("walk") then
		local new_action = {
			body_part = 2,
			type = "idle"
		}

		data.unit:brain():action_request(new_action)
	end

	if aim or shoot then
		if focus_enemy.verified or focus_enemy.nearly_visible then
			if my_data.attention_unit ~= focus_enemy.u_key then
				CopLogicBase._set_attention(data, focus_enemy)

				my_data.attention_unit = focus_enemy.u_key
			end
		else
			local look_pos = my_data.expected_pos or focus_enemy.last_verified_pos or focus_enemy.verified_pos

			--[[if look_pos then
				local line = Draw:brush(Color.blue:with_alpha(0.5), 0.1)
				line:cylinder(data.unit:movement():m_head_pos(), look_pos, 5)
			end]]

			if my_data.attention_unit ~= look_pos then
				CopLogicBase._set_attention_on_pos(data, mvec3_cpy(look_pos))

				my_data.attention_unit = mvec3_cpy(look_pos)
			end
		end
		
		local nottasingortargetwrong = not my_data.tasing or my_data.tasing.target_u_data ~= focus_enemy
		
		if tase then
			if nottasingortargetwrong and not data.unit:movement():chk_action_forbidden("walk") and not focus_enemy.unit:movement():zipline_unit() then
				if my_data.attention_unit ~= focus_enemy.u_key then
					CopLogicBase._set_attention(data, focus_enemy)

					my_data.attention_unit = focus_enemy.u_key
				end

				local tase_action = {
					body_part = 3,
					type = "tase"
				}

				if data.unit:brain():action_request(tase_action) then
					my_data.tasing = {
						target_u_data = focus_enemy,
						target_u_key = focus_enemy.u_key,
						start_t = data.t
					}

					TaserLogicAttack._cancel_charge(data, my_data)
					managers.groupai:state():on_tase_start(data.key, focus_enemy.u_key)
				end
			end
		elseif not my_data.shooting and not my_data.spooc_attack and not data.unit:anim_data().reload and not data.unit:movement():chk_action_forbidden("action") then
			local shoot_action = {
				body_part = 3,
				type = "shoot"
			}

			if data.brain:action_request(shoot_action) then
				my_data.shooting = true
			end
		end
	else
		if my_data.shooting and not data.unit:anim_data().reload or my_data.tasing then
			local new_action = {
				body_part = 3,
				type = "idle"
			}

			data.brain:action_request(new_action)
		end

		if my_data.attention_unit then
			CopLogicBase._reset_attention(data)

			my_data.attention_unit = nil
		end
	end

	CopLogicAttack.aim_allow_fire(shoot, aim, data, my_data)
end

function CopLogicAttack._get_expected_attention_position(data, my_data)
	local main_enemy = data.attention_obj
	local e_nav_tracker = main_enemy.nav_tracker

	if not e_nav_tracker then
		return
	end

	local my_nav_seg = data.unit:movement():nav_tracker():nav_segment()
	local e_pos = main_enemy.m_pos
	local e_nav_seg = e_nav_tracker:nav_segment()

	if e_nav_seg == my_nav_seg then
		mvec3_set(temp_vec1, e_pos)
		mvec3_set_z(temp_vec1, temp_vec1.z + 140)

		return temp_vec1
	end

	local expected_path = my_data.expected_pos_path
	local from_nav_seg, to_nav_seg = nil

	if expected_path then
		local i_from_seg = nil

		for i, k in ipairs(expected_path) do
			if k[1] == my_nav_seg then
				i_from_seg = i

				break
			end
		end

		if i_from_seg then
			local function _find_aim_pos(from_nav_seg, to_nav_seg)
				local closest_dis = 1000000000
				local closest_door = nil
				local min_point_dis_sq = 10000
				local found_doors = managers.navigation:find_segment_doors(from_nav_seg, callback(CopLogicAttack, CopLogicAttack, "_chk_is_right_segment", to_nav_seg))

				for _, door in pairs(found_doors) do
					mvec3_set(temp_vec1, door.center)

					local dis = mvec3_dis_sq(e_pos, temp_vec1)

					if dis < closest_dis then
						closest_dis = dis
						closest_door = door
					end
				end

				if closest_door then
					mvec3_set(temp_vec1, closest_door.center)
					mvec3_sub(temp_vec1, data.m_pos)
					mvec3_set_z(temp_vec1, 0)

					if min_point_dis_sq < mvector3.length_sq(temp_vec1) then
						mvec3_set(temp_vec1, closest_door.center)
						mvec3_set_z(temp_vec1, temp_vec1.z + 140)

						return temp_vec1
					else
						return false, true
					end
				end
			end

			local i = #expected_path

			while i > 0 do
				if expected_path[i][1] == e_nav_seg then
					to_nav_seg = expected_path[math.clamp(i, i_from_seg - 1, i_from_seg + 1)][1]
					local aim_pos, too_close = _find_aim_pos(my_nav_seg, to_nav_seg)

					if aim_pos then
						return aim_pos

						-- break
					end

					if too_close then
						local next_nav_seg = expected_path[math.clamp(i, i_from_seg - 2, i_from_seg + 2)][1]

						if next_nav_seg ~= to_nav_seg then
							local from_nav_seg = to_nav_seg
							to_nav_seg = next_nav_seg
							aim_pos = _find_aim_pos(from_nav_seg, to_nav_seg)
						end

						return aim_pos
					end

					break
				end

				i = i - 1
			end
		end

		if not i_from_seg or not to_nav_seg then
			expected_path = nil
			my_data.expected_pos_path = nil
		end
	end

	if not expected_path and not my_data.expected_pos_path_search_id then
		my_data.expected_pos_path_search_id = "ExpectedPos" .. tostring(data.key)

		data.unit:brain():search_for_coarse_path(my_data.expected_pos_path_search_id, e_nav_seg)
	end
end

function CopLogicAttack._chk_request_action_walk_to_cover(data, my_data)
	CopLogicAttack._correct_path_start_pos(data, my_data.cover_path)
	
	local haste = nil
	
	local can_perform_walking_action = not data.unit:movement():chk_action_forbidden("walk") and not my_data.turning or data.unit:anim_data().act_idle
	local pose = nil
	
	local mook_units = {
		"security",
		"security_undominatable",
		"cop",
		"cop_scared",
		"cop_female",
		"gensec",
		"fbi",
		"fbi_xc45",
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
		"taser",
		"spooc",
		"shadow_spooc",
		"spooc_heavy",
		"tank_ftsu",
		"tank_mini",
		"tank",
		"tank_medic"
	}
	local is_mook = nil
	for _, name in ipairs(mook_units) do
		if data.unit:base()._tweak_table == name then
			is_mook = true
		end
	end
	
	if can_perform_walking_action then 
		
		--enemies at long distances makes cops run, enemies at shorter distances makes cops walk, keeps pacing in small maps consistent and manageable, while making the cops seem cooler
		local pose_chk = not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.crouch
		local enemyseeninlast4secs = data.attention_obj and data.attention_obj.verified_t and data.t - data.attention_obj.verified_t < 4
		local enemy_seen_range_bonus = enemyseeninlast4secs and 500 or 0
		local enemy_has_height_difference = data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.dis >= 1200 and data.attention_obj.verified_t and data.t - data.attention_obj.verified_t < 4 and math.abs(data.m_pos.z - data.attention_obj.m_pos.z) > 250
		local height_difference_penalty = math.abs(data.m_pos.z - data.attention_obj.m_pos.z) < 250 and 400 or 0
		--local testing = true
		
		if data.unit:movement():cool() then
			haste = "walk"
		elseif data.attention_obj and data.attention_obj.dis > 10000 or data.team and data.team.id == tweak_data.levels:get_default_team_ID("player") or data.is_converted or data.unit:in_slot(16) or data.unit:in_slot(managers.slot:get_mask("criminals")) then
			haste = "run"
		elseif data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.dis > 800 + enemy_seen_range_bonus and not data.unit:movement():cool() and not managers.groupai:state():whisper_mode() then
			haste = "run"
		elseif data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.dis <= 800 + enemy_seen_range_bonus - height_difference_penalty and is_mook and data.tactics and not data.tactics.hitnrun then
			haste = "walk"
		else
			haste = "run"
		end
		
		local crouch_roll = math.random(0.01, 1)
		local stand_chance = nil
		local end_pose = nil
		local enemy_visible15m_or_10m_chk = data.attention_obj.verified and data.attention_obj.dis <= 1500 or data.attention_obj.dis <= 1000
	
		if data.attention_obj and data.attention_obj.dis > 10000 or data.team and data.team.id == tweak_data.levels:get_default_team_ID("player") or data.is_converted or data.unit:in_slot(16) or data.unit:in_slot(managers.slot:get_mask("criminals")) then
			stand_chance = 1
			pose = "stand"
			end_pose = "stand"
		elseif data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.dis > 2000 then
			stand_chance = 0.75
		elseif enemy_has_height_difference and pose_chk and is_mook then
			stand_chance = 0.25
		elseif data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and enemy_visible15m_or_10m_chk and CopLogicTravel._chk_close_to_criminal(data, my_data) and data.tactics and data.tactics.flank and haste == "walk" and is_mook then
			stand_chance = 0.25
		elseif my_data.moving_to_cover and pose_chk then
			stand_chance = 0.5
		else
			stand_chance = 1
			pose = "stand"
			end_pose = "stand"
		end
	
		--randomize enemy crouching to make enemies feel less easy to aim at, the fact they're always crouching all over the place always bugged me, plus, they shouldn't need to crouch so often when you're at long distances from them
		
		if not data.unit:movement():cool() and not managers.groupai:state():whisper_mode() then
			if stand_chance ~= 1 and crouch_roll > stand_chance and pose_chk or data.char_tweak.allowed_poses and data.char_tweak.allowed_poses.crouch then
				end_pose = "crouch"
				pose = "crouch"
			else
				end_pose = "stand"
				pose = "stand"
			end
		end
				
		if not pose then
			pose = not data.char_tweak.crouch_move and "stand" or data.char_tweak.allowed_poses and not data.char_tweak.allowed_poses.stand and "crouch" or "stand"
			end_pose = pose
		end
		
		if not data.unit:anim_data()[pose] then
			CopLogicAttack["_chk_request_action_" .. pose](data)
		end
		
		local new_action_data = {
			type = "walk",
			body_part = 2,
			pose = pose,
			nav_path = my_data.cover_path,
			variant = haste,
			end_pose = end_pose
		}
		my_data.cover_path = nil
		my_data.advancing = data.unit:brain():action_request(new_action_data)

		if my_data.advancing then
			my_data.moving_to_cover = my_data.best_cover
			my_data.at_cover_shoot_pos = nil
			my_data.in_cover = nil

			data.brain:rem_pos_rsrv("path")
		end
	end
end

function CopLogicAttack._chk_request_action_walk_to_cover_shoot_pos(data, my_data, path, speed)
	local can_perform_walking_action = not data.unit:movement():chk_action_forbidden("walk") and not my_data.turning or data.unit:anim_data().act_idle
	
	local pose = nil
	
	local mook_units = {
		"security",
		"security_undominatable",
		"cop",
		"cop_scared",
		"cop_female",
		"gensec",
		"fbi",
		"fbi_xc45",
		"fbi_pager",
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
		"taser",
		"spooc",
		"trolliam_epicson",
		"gangster_ninja",						
		"shadow_spooc",
		"spooc_heavy",
		"tank_ftsu",
		"tank_mini",
		"tank",
		"tank_medic"
	}
	local is_mook = nil
	for _, name in ipairs(mook_units) do
		if data.unit:base()._tweak_table == name then
			is_mook = true
		end
	end
	
	local haste = nil
	
	--this is a mess, but it should keep enemy movement tacticool overall, by having them prefer slower apporoaches at close ranges
	if can_perform_walking_action then
		local pose_chk = not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.crouch
		local enemyseeninlast4secs = data.attention_obj and data.attention_obj.verified_t and data.t - data.attention_obj.verified_t < 4
		local enemy_seen_range_bonus = enemyseeninlast4secs and 500 or 0
		local enemy_has_height_difference = data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.dis >= 1200 and data.attention_obj.verified_t and data.t - data.attention_obj.verified_t < 4 and math_abs(data.m_pos.z - data.attention_obj.m_pos.z) > 250
		local height_difference_penalty = data.attention_obj and math_abs(data.m_pos.z - data.attention_obj.m_pos.z) < 250 and 400 or 0
		--local testing = true
		
		if data.unit:movement():cool() then
			haste = "walk"
		elseif data.team and data.team.id == tweak_data.levels:get_default_team_ID("player") or data.is_converted or data.unit:in_slot(16) or data.unit:in_slot(managers.slot:get_mask("criminals")) or data.attention_obj and data.attention_obj.dis > 10000 then
			haste = "run"
		elseif data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.dis > 800 + enemy_seen_range_bonus and not data.unit:movement():cool() and not managers.groupai:state():whisper_mode() then
			haste = "run"
		elseif data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.dis <= 800 + enemy_seen_range_bonus - height_difference_penalty and is_mook and data.tactics and not data.tactics.hitnrun then
			haste = "walk"
		else
			haste = "run"
		end

		local should_crouch = nil

		local end_rot = nil

		if my_data.coarse_path and my_data.coarse_path_index >= #my_data.coarse_path - 1 then
			end_rot = objective and objective.rot
		end

		local no_strafe, end_pose = nil
		
		local crouch_roll = math_random(0.01, 1)
		local stand_chance = nil
		local enemy_visible15m_or_10m_chk = data.attention_obj and data.attention_obj.verified and data.attention_obj.dis <= 1500 or data.attention_obj and data.attention_obj.dis <= 1000
		
		if data.attention_obj and data.attention_obj.dis > 10000 or data.unit:in_slot(16) or data.is_converted then
			stand_chance = 1
		elseif data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and data.attention_obj.dis > 2000 and is_mook then
			stand_chance = 0.75
		elseif enemy_has_height_difference and enemy_visible15m_or_10m_chk and is_mook then
			stand_chance = 0.25
		elseif data.attention_obj and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction and enemy_visible15m_or_10m_chk and CopLogicTravel._chk_close_to_criminal(data, my_data) and data.tactics and data.tactics.flank and haste == "walk" and is_mook then
			stand_chance = 0.25
		elseif my_data.moving_to_cover and pose_chk then
			stand_chance = 0.5
		else
			stand_chance = 0.5
		end
		
		--randomize enemy crouching to make enemies feel less easy to aim at, the fact they're always crouching all over the place always bugged me, plus, they shouldn't need to crouch so often when you're at long distances from them
		
		if not data.unit:movement():cool() and not managers.groupai:state():whisper_mode() then
			if data.char_tweak.allowed_poses and data.char_tweak.allowed_poses.crouch then
				end_pose = "crouch"
				pose = "crouch"
			elseif data.char_tweak.allowed_poses and data.char_tweak.allowed_poses.stand then
				end_pose = "stand"
				pose = "stand"
			elseif stand_chance ~= 1 and crouch_roll > stand_chance then
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
		
		local new_action_data = {
			body_part = 2,
			type = "walk",
			nav_path = path,
			pose = pose,
			end_pose = end_pose,
			variant = haste or "walk"
		}
		my_data.cover_path = nil
		my_data.advancing = data.unit:brain():action_request(new_action_data)

		if my_data.advancing then
			my_data.walking_to_cover_shoot_pos = my_data.advancing
			my_data.at_cover_shoot_pos = nil
			my_data.in_cover = nil

			data.brain:rem_pos_rsrv("path")
		end
	end
end

function CopLogicAttack._chk_start_action_move_back(data, my_data, focus_enemy, engage, assault_break)

	local pantsdownchk = nil
	
	
	if focus_enemy.is_person and focus_enemy.is_husk_player or focus_enemy.is_person and focus_enemy.is_local_player then
		if focus_enemy.is_local_player then
			local e_movement_state = focus_enemy.unit:movement():current_state()
			if e_movement_state:_is_reloading() or e_movement_state:_interacting() or e_movement_state:is_equipping() then
				pantsdownchk = true
			end
		else
			local e_anim_data = focus_enemy.unit:anim_data()
			local movingoridle = e_anim_data.move or e_anim_data.idle
			if not movingoridle or e_anim_data.reload then
				pantsdownchk = true
			end
		end
	end
	
	local can_perform_walking_action = not my_data.turning and not data.unit:movement():chk_action_forbidden("walk") and not my_data.has_old_action
	
	if can_perform_walking_action then
	--what the fuck is my code rn tbh
		if focus_enemy and focus_enemy.nav_tracker and focus_enemy.verified and focus_enemy.dis < 250 and CopLogicAttack._can_move(data) or data.tactics and data.tactics.elite_ranged_fire and focus_enemy and focus_enemy.nav_tracker and focus_enemy.verified and focus_enemy.verified_dis <= 1500 and CopLogicAttack._can_move(data) or data.tactics and data.tactics.hitnrun and focus_enemy and focus_enemy.verified and focus_enemy.verified_dis <= 1000 and CopLogicAttack._can_move(data) or data.tactics and data.tactics.spoocavoidance and focus_enemy.verified and focus_enemy.aimed_at or data.tactics and data.tactics.reloadingretreat and focus_enemy and focus_enemy.verified then
			
			local from_pos = mvector3.copy(data.m_pos)
			local threat_tracker = focus_enemy.nav_tracker
			local threat_head_pos = focus_enemy.m_head_pos
			local max_walk_dis = nil
			local vis_required = engage
			
			if assault_break then 	
				max_walk_dis = 5000
				vis_required = nil
			elseif data.tactics and data.tactics.hitnrun then
				max_walk_dis = 800
			elseif data.tactics and data.tactics.elite_ranged_fire then
				max_walk_dis = 2000
				vis_required = true
			elseif data.tactics and data.tactics.spoocavoidance then
				max_walk_dis = 1500
			elseif data.tactics and data.tactics.reloadingretreat then
				max_walk_dis = 1500
			else
				max_walk_dis = 400
			end
				
			local retreat_to = CopLogicAttack._find_retreat_position(from_pos, focus_enemy.m_pos, threat_head_pos, threat_tracker, max_walk_dis, vis_required)

			if retreat_to then
				CopLogicAttack._cancel_cover_pathing(data, my_data)
				
				if data.unit:anim_data().move or data.unit:anim_data().run then
					local new_action = {
						body_part = 2,
						type = "idle"
					}
					data.unit:brain():action_request(new_action)
				end
					
				--if data.tactics and data.tactics.hitnrun or data.tactics and data.tactics.elite_ranged_fire then
					--log("hitnrun or eliteranged just backed up properly")
				--end
					
				if data.tactics and data.tactics.elite_ranged_fire then
					if not data.unit:in_slot(16) and data.char_tweak.chatter.dodge then
						managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "dodge")
					end
				end

				local new_action_data = {
					variant = "run",
					body_part = 2,
					type = "walk",
					nav_path = {
						from_pos,
						retreat_to
					}
				}
				my_data.advancing = data.unit:brain():action_request(new_action_data)
					
				if my_data.advancing then
					my_data.surprised = true

					return true
				end
			end
		end
	end
end

function CopLogicAttack.action_complete_clbk(data, action)
	local my_data = data.internal_data
	local action_type = action:type()
	
	if action_type == "act" then
		if not data.unit:in_slot(managers.slot:get_mask("criminals")) then
			if not data.unit:character_damage():dead() and action:expired() then
				if data.unit:base()._tweak_table == "spooc" or data.unit:base()._tweak_table == "heavy_spooc" or data.unit:base()._tweak_table == "shadow_spooc" or data.unit:base()._tweak_table == "spooc_titan" then
					SpoocLogicAttack._upd_spooc_attack(data, my_data)
				end
				CopLogicAttack._upd_aim(data, my_data)
				data.logic._upd_stance_and_pose(data, data.internal_data)
				CopLogicTravel._upd_combat_movement(data)
			end
		end
	elseif action_type == "healed" then
		CopLogicAttack._cancel_cover_pathing(data, my_data)
		CopLogicAttack._cancel_charge(data, my_data)
	
		if not data.unit:character_damage():dead() and action:expired() then
			if data.unit:base()._tweak_table == "spooc" or data.unit:base()._tweak_table == "heavy_spooc" or data.unit:base()._tweak_table == "shadow_spooc" or data.unit:base()._tweak_table == "spooc_titan" then
				SpoocLogicAttack._upd_spooc_attack(data, my_data)
			end
			CopLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
			CopLogicTravel._upd_combat_movement(data)
		end
	elseif action_type == "heal" then
		CopLogicAttack._cancel_cover_pathing(data, my_data)
		CopLogicAttack._cancel_charge(data, my_data)
	
		if not data.unit:character_damage():dead() and action:expired() then
			if data.unit:base()._tweak_table == "spooc" or data.unit:base()._tweak_table == "heavy_spooc" or data.unit:base()._tweak_table == "shadow_spooc" or data.unit:base()._tweak_table == "spooc_titan" then
				SpoocLogicAttack._upd_spooc_attack(data, my_data)
			end
			CopLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
			CopLogicTravel._upd_combat_movement(data)
		end
	elseif action_type == "walk" then
		my_data.advancing = nil

		CopLogicAttack._cancel_cover_pathing(data, my_data)
		CopLogicAttack._cancel_charge(data, my_data)

		if my_data.walking_to_optimal_pos then
			if action:expired() then
				my_data.walking_to_optimal_pos = nil
				
				if data.unit:base()._tweak_table == "spooc" or data.unit:base()._tweak_table == "heavy_spooc" or data.unit:base()._tweak_table == "shadow_spooc" or data.unit:base()._tweak_table == "spooc_titan" then
					SpoocLogicAttack._upd_spooc_attack(data, my_data)
				end
				
				CopLogicAttack._upd_aim(data, my_data)
				data.logic._upd_stance_and_pose(data, data.internal_data)
				CopLogicTravel._upd_combat_movement(data, true)
			end
		elseif my_data.walking_to_cover_shoot_pos then
			if action:expired() then
				my_data.walking_to_cover_shoot_pos = nil
				my_data.at_cover_shoot_pos = true
				
				if data.unit:base()._tweak_table == "spooc" or data.unit:base()._tweak_table == "heavy_spooc" or data.unit:base()._tweak_table == "shadow_spooc" or data.unit:base()._tweak_table == "spooc_titan" then
					SpoocLogicAttack._upd_spooc_attack(data, my_data)
				end
				
				CopLogicAttack._upd_aim(data, my_data)
				data.logic._upd_stance_and_pose(data, data.internal_data)
				CopLogicTravel._upd_combat_movement(data, true)
			end
		elseif my_data.moving_to_cover then
			if action:expired() then
				my_data.in_cover = my_data.moving_to_cover
				my_data.cover_enter_t = data.t
				my_data.moving_to_cover = nil
				
				if data.unit:base()._tweak_table == "spooc" or data.unit:base()._tweak_table == "heavy_spooc" or data.unit:base()._tweak_table == "shadow_spooc" or data.unit:base()._tweak_table == "spooc_titan" then
					SpoocLogicAttack._upd_spooc_attack(data, my_data)
				end
				
				CopLogicAttack._upd_aim(data, my_data)
				data.logic._upd_stance_and_pose(data, data.internal_data)
				CopLogicTravel._upd_combat_movement(data, true)
			end
		end
	elseif action_type == "shoot" then
		my_data.shooting = nil
	elseif action_type == "tase" then
		if not data.unit:character_damage():dead() and action:expired() and my_data.tasing then
			local record = managers.groupai:state():criminal_record(my_data.tasing.target_u_key)

			if record and record.status then
				data.tase_delay_t = TimerManager:game():time() + 45
			end
			CopLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
			CopLogicTravel._upd_combat_movement(data)
		end
		
		if my_data.tasing then
			managers.groupai:state():on_tase_end(my_data.tasing.target_u_key)
		end

		my_data.tasing = nil
	elseif action_type == "spooc" then
		data.spooc_attack_timeout_t = TimerManager:game():time() + math_lerp(data.char_tweak.spooc_attack_timeout[1], data.char_tweak.spooc_attack_timeout[2], math_random())

		if action:complete() and data.char_tweak.spooc_attack_use_smoke_chance > 0 and math_random() <= data.char_tweak.spooc_attack_use_smoke_chance and not managers.groupai:state():is_smoke_grenade_active() then
			managers.groupai:state():detonate_smoke_grenade(data.m_pos + math_UP * 10, data.unit:movement():m_head_pos(), math_lerp(15, 30, math_random()), false)
		end
		
		if not data.unit:character_damage():dead() and action:expired() then
			CopLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
			CopLogicTravel._upd_combat_movement(data)
		end

		my_data.spooc_attack = nil
	elseif action_type == "reload" then
		--Removed the requirement for being important here.
		if not data.unit:character_damage():dead() and action:expired() then
			if data.unit:base()._tweak_table == "spooc" or data.unit:base()._tweak_table == "heavy_spooc" or data.unit:base()._tweak_table == "shadow_spooc" or data.unit:base()._tweak_table == "spooc_titan" then
				SpoocLogicAttack._upd_spooc_attack(data, my_data)
			end
			CopLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
			CopLogicTravel._upd_combat_movement(data)
		end
	elseif action_type == "turn" then
		if not data.unit:character_damage():dead() and action:expired() then
			if data.unit:base()._tweak_table == "spooc" or data.unit:base()._tweak_table == "heavy_spooc" or data.unit:base()._tweak_table == "shadow_spooc" or data.unit:base()._tweak_table == "spooc_titan" then
				SpoocLogicAttack._upd_spooc_attack(data, my_data)
			end
			CopLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
			CopLogicTravel._upd_combat_movement(data)
		end
		
		my_data.turning = nil
		
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
	elseif action_type == "hurt" then
		CopLogicAttack._cancel_cover_pathing(data, my_data)
		CopLogicAttack._cancel_charge(data, my_data)
		
		--Removed the requirement for being important here.
		if not data.unit:character_damage():dead() and action:expired() and not CopLogicBase.chk_start_action_dodge(data, "hit") then
			if data.unit:base()._tweak_table == "spooc" or data.unit:base()._tweak_table == "heavy_spooc" or data.unit:base()._tweak_table == "shadow_spooc" or data.unit:base()._tweak_table == "spooc_titan" then
				SpoocLogicAttack._upd_spooc_attack(data, my_data)
			end
			CopLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
			CopLogicTravel._upd_combat_movement(data)
		end
		
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
		
	elseif action_type == "dodge" then
		local timeout = action:timeout()

		if timeout then
			data.dodge_timeout_t = TimerManager:game():time() + math_lerp(timeout[1], timeout[2], math_random())
		end

		CopLogicAttack._cancel_cover_pathing(data, my_data)
		CopLogicAttack._cancel_charge(data, my_data)
		
		if not data.unit:character_damage():dead() and action:expired() then
			if data.unit:base()._tweak_table == "spooc" or data.unit:base()._tweak_table == "heavy_spooc" or data.unit:base()._tweak_table == "shadow_spooc" or data.unit:base()._tweak_table == "spooc_titan" then
				SpoocLogicAttack._upd_spooc_attack(data, my_data)
			end
			CopLogicAttack._upd_aim(data, my_data)
			data.logic._upd_stance_and_pose(data, data.internal_data)
			CopLogicTravel._upd_combat_movement(data)
		end
		
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

local temp_vec4 = Vector3()
local temp_vec5 = Vector3()
local temp_vec6 = Vector3()
local fuckingvector = Vector3()
function CopLogicAttack._update_cover(data)
	local my_data = data.internal_data
	local cover_release_dis_sq = 10000
	local best_cover = my_data.best_cover
	local satisfied = true
	local my_pos = data.m_pos --my position
	
	if data.attention_obj and data.attention_obj.nav_tracker and AIAttentionObject.REACT_COMBAT <= data.attention_obj.reaction then
		local find_new = not my_data.moving_to_cover and not my_data.walking_to_cover_shoot_pos and not my_data.surprised
		
		if find_new then
			local enemy_tracker = data.attention_obj.nav_tracker
			local threat_pos = enemy_tracker:field_position()
			local enemyseeninlast2secs = data.attention_obj and data.attention_obj.verified_t and data.t - data.attention_obj.verified_t < math.random(0.35, 2)
			
			if data.objective and data.objective.type == "follow" and data.tactics and data.tactics.shield_cover and not data.unit:base()._tweak_table == "shield" then
				local heister_pos = data.attention_obj.m_pos --the threat
				local shield_pos = data.objective.follow_unit:movement():m_pos() --the pillar
				local shield_direction = mvector3.direction(temp_vec4, my_pos, shield_pos)
				local heister_direction = mvector3.direction(temp_vec5, my_pos, heister_pos)
				local following_direction = mvector3.direction(temp_vec6, shield_direction, heister_direction)
				mvector3.set(temp_vec4, my_pos)
				mvector3.direction(temp_vec5, temp_vec4, shield_pos)
				mvec3_norm(temp_vec5)
				mvector3.direction(fuckingvector, temp_vec5, heister_direction)
				mvec3_norm(fuckingvector)
				local following_dis = fuckingvector
				local near_pos = data.objective.follow_unit:movement():m_pos() + following_dis
				
				local notbestcovernotfollowcoverchk = not best_cover or CopLogicAttack._verify_follow_cover(data, best_cover[1], near_pos, threat_pos, 60, 120)
				
				--unit would take the heister's angle to both the pillar, and the unit, the unit would attempt to line up the pillar and the heister together, since they're following the pillar, they should frequently position themselves behind the pillar, which would keep them in cover, its hacky, but it would work
				
				if notbestcovernotfollowcoverchk and not my_data.processing_cover_path and not my_data.charge_path_search_id then
					local follow_unit_area = managers.groupai:state():get_area_from_nav_seg_id(data.objective.follow_unit:movement():nav_tracker():nav_segment())
					local found_cover = managers.navigation:find_cover_in_nav_seg_3(follow_unit_area.nav_segs, data.objective.distance or nil, near_pos, threat_pos)

					if found_cover then
						if not follow_unit_area.nav_segs[found_cover[3]:nav_segment()] then
							debug_pause_unit(data.unit, "cover in wrong area")
						end

						satisfied = true
						local better_cover = {
							found_cover
						}

						CopLogicAttack._set_best_cover(data, my_data, better_cover)

						local offset_pos, yaw = CopLogicAttack._get_cover_offset_pos(data, better_cover, threat_pos)

						if offset_pos then
							better_cover[5] = offset_pos
							better_cover[6] = yaw
						end
					end
				end
			elseif data.objective and data.objective.type == "follow" then
				local near_pos = data.objective.follow_unit:movement():m_pos()
				local notbc_ornotvc_chk = not best_cover or CopLogicAttack._verify_follow_cover(data, best_cover[1], near_pos, threat_pos, 200, 1000)
				if notbc_ornotvc_chk and not my_data.processing_cover_path and not my_data.charge_path_search_id then
					local follow_unit_area = managers.groupai:state():get_area_from_nav_seg_id(data.objective.follow_unit:movement():nav_tracker():nav_segment())
					local found_cover = managers.navigation:find_cover_in_nav_seg_3(follow_unit_area.nav_segs, data.objective.distance and data.objective.distance * 0.9 or nil, near_pos, threat_pos)

					if found_cover then
						if not follow_unit_area.nav_segs[found_cover[3]:nav_segment()] then
							--debug_pause_unit(data.unit, "cover in wrong area")
						end

						satisfied = true
						local better_cover = {
							found_cover
						}

						CopLogicAttack._set_best_cover(data, my_data, better_cover)

						local offset_pos, yaw = CopLogicAttack._get_cover_offset_pos(data, better_cover, threat_pos)

						if offset_pos then
							better_cover[5] = offset_pos
							better_cover[6] = yaw
						end
					end
				end
			else
				local want_to_take_cover = my_data.want_to_take_cover
				local flank_cover = my_data.flank_cover
				local min_dis, max_dis = nil

				if want_to_take_cover then
					if not enemyseeninlast2secs then
						min_dis = 30
						max_dis = data.attention_obj.dis
					else
						min_dis = math.max(data.attention_obj.dis * 1.2, data.attention_obj.dis + 200)
						
						if min_dis > data.attention_obj.dis + 1000 then
							min_dis = data.attention_obj.dis + 500
						end
						
						max_dis = math.min(min_dis + 500, data.attention_obj.dis + 1000)
						
						if min_dis > max_dis then
							min_dis = min_dis - max_dis
						end
					end
				end
				
				local notbc_or_fc_or_notvc_chk = not best_cover or flank_cover or CopLogicAttack._verify_cover(data, best_cover[1], threat_pos, min_dis, max_dis)
				
				if not my_data.processing_cover_path and not my_data.charge_path_search_id and notbc_or_fc_or_notvc_chk then
					satisfied = false
					local my_vec = my_pos - threat_pos

					if flank_cover then
						mvector3.rotate_with(my_vec, Rotation(flank_cover.angle))
					end

					local optimal_dis = my_vec:length()
					local max_dis = nil
					local not_ranged_fire_group_chk = not data.tactics or not data.tactics.ranged_fire and not data.tactics.elite_ranged_fire

					if want_to_take_cover and enemyseeninlast2secs then
						if data.tactics and data.tactics.ranged_fire or data.tactics and data.tactics.elite_ranged_fire then
							if optimal_dis < my_data.weapon_range.optimal then
								optimal_dis = optimal_dis

								mvector3.set_length(my_vec, optimal_dis)
							else
								optimal_dis = my_data.weapon_range.optimal

								mvector3.set_length(my_vec, optimal_dis)
							end
						else
							if optimal_dis < my_data.weapon_range.close then
								optimal_dis = optimal_dis

								mvector3.set_length(my_vec, optimal_dis)
							else
								optimal_dis = my_data.weapon_range.close

								mvector3.set_length(my_vec, optimal_dis)
							end
						end
						
						if not_ranged_fire_group_chk then
							max_dis = math.max(optimal_dis + 200, my_data.weapon_range.far * 0.5)
						else							
							max_dis = math.max(optimal_dis + 200, my_data.weapon_range.far)
						end
						
					elseif not_ranged_fire_group_chk and optimal_dis > my_data.weapon_range.close or not enemyseeninlast2secs then
						optimal_dis = my_data.weapon_range.close

						mvector3.set_length(my_vec, optimal_dis)

						max_dis = my_data.weapon_range.optimal
					elseif optimal_dis > my_data.weapon_range.optimal then
						optimal_dis = my_data.weapon_range.optimal

						mvector3.set_length(my_vec, optimal_dis)

						max_dis = my_data.weapon_range.far
					end

					local my_side_pos = threat_pos + my_vec

					mvector3.set_length(my_vec, max_dis)

					local furthest_side_pos = threat_pos + my_vec

					if flank_cover then
						local angle = flank_cover.angle
						local sign = flank_cover.sign

						if math.sign(angle) ~= sign then
							angle = -angle + flank_cover.step * sign

							if math.abs(angle) > 90 then
								flank_cover.failed = true
							else
								flank_cover.angle = angle
							end
						else
							flank_cover.angle = -angle
						end
					end

					local cone_angle = nil

					if flank_cover and not flank_cover.failed then
						cone_angle = flank_cover.step
					else
						cone_angle = math.lerp(90, 60, math.min(1, optimal_dis / 3000))
					end

					local search_nav_seg = nil

					if data.objective and data.objective.type == "defend_area" then
						search_nav_seg = data.objective.area and data.objective.area.nav_segs or data.objective.nav_seg
					end

					local found_cover = managers.navigation:find_cover_in_cone_from_threat_pos_1(threat_pos, furthest_side_pos, my_side_pos, my_pos, cone_angle, min_dis, search_nav_seg, optimal_dis, data.pos_rsrv_id)
					
					local notbcorvc_chk = nil
					
					if found_cover then
						notbcorvc_chk = not best_cover or flank_cover or CopLogicAttack._verify_cover(data, found_cover, threat_pos, min_dis, max_dis)
					end
					
					if found_cover and notbcorvc_chk then
						satisfied = true
						local better_cover = {
							found_cover
						}

						CopLogicAttack._set_best_cover(data, my_data, better_cover)

						local offset_pos, yaw = CopLogicAttack._get_cover_offset_pos(data, better_cover, threat_pos)

						if offset_pos then
							better_cover[5] = offset_pos
							better_cover[6] = yaw
						end
					end
				end
			end
		end

		local in_cover = my_data.in_cover

		if in_cover then
			local threat_pos = data.attention_obj.m_pos
			in_cover[3], in_cover[4] = CopLogicAttack._chk_covered(data, my_pos, threat_pos, data.visibility_slotmask)
		end
	elseif best_cover and cover_release_dis_sq < mvector3.distance_sq(best_cover[1][1], my_pos) then
		CopLogicAttack._set_best_cover(data, my_data, nil)
	end
end	

function CopLogicAttack._chk_covered(data, cover_pos, threat_pos, slotmask)
	local ray_from = temp_vec1

	mvec3_set(ray_from, math.UP)
	mvector3.multiply(ray_from, 80)
	mvector3.add(ray_from, cover_pos)

	local ray_to_pos = temp_vec2

	mvector3.step(ray_to_pos, ray_from, threat_pos, 300)

	local low_ray = World:raycast("ray", ray_from, ray_to_pos, "slot_mask", slotmask)
	local high_ray = nil

	if not low_ray then
		--log("unexposed")
		mvector3.set_z(ray_from, ray_from.z + 60)
		mvector3.step(ray_to_pos, ray_from, threat_pos, 300)

		high_ray = World:raycast("ray", ray_from, ray_to_pos, "slot_mask", slotmask)
	end

	return low_ray, high_ray
end

function CopLogicAttack._chk_request_action_turn_to_enemy(data, my_data, my_pos, enemy_pos)
	local fwd = data.unit:movement():m_rot():y()
	local target_vec = enemy_pos - my_pos
	local error_spin = target_vec:to_polar_with_reference(fwd, math.UP).spin
	local diff_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)
	local mook_units = {
		"security",
		"security_undominatable",
		"cop",
		"cop_scared",
		"cop_female",
		"gensec",
		"fbi",
		"fbi_xc45",
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
		"taser",
		"shield",
		"spooc",
		"spooc_heavy",
		"shadow_spooc"
	}
	local is_mook = nil
	for _, name in ipairs(mook_units) do
		if data.unit:base()._tweak_table == name then
			is_mook = true
		end
	end
	
	local speed = nil
	
	if data.team and data.team.id == tweak_data.levels:get_default_team_ID("player") or data.is_converted or data.unit:in_slot(16) or data.unit:in_slot(managers.slot:get_mask("criminals")) or data.unit:base()._tweak_table == "sniper" then
		speed = 2.5
	elseif diff_index == 8 and is_mook then
		speed = 1.75
	elseif diff_index == 6 and is_mook or diff_index == 7 and is_mook then
		speed = 1.5
	elseif diff_index <= 5 and is_mook then
		speed = 1.25
	else
		speed = 1
	end
	
	if math.abs(error_spin) > 27 then
		local new_action_data = {
			type = "turn",
			body_part = 2,
			speed = speed or 1,
			angle = error_spin
		}

		if data.unit:brain():action_request(new_action_data) then
			my_data.turning = new_action_data.angle

			return true
		end
	end
end

function CopLogicAttack._verify_cover(data, cover, threat_pos, min_dis, max_dis)
	local threat_dis = mvector3.distance(temp_vec1, cover[1], threat_pos)
	
	if not data.attention_obj and data.attention_obj.verified_t and data.t - data.attention_obj.verified_t < math.random(0.35, 2) then
		return true
	end
	
	
	if min_dis and threat_dis < min_dis or max_dis and threat_dis > max_dis then
		--log("damnit!")
		return
	end
	
	--log("acceptable!")

	return true
end

function CopLogicAttack._verify_follow_cover(data, cover, near_pos, threat_pos, min_dis, max_dis)
	if data.tactics and data.tactics.shield_cover and mvector3.distance(near_pos, cover[1]) < 120 then
		return true
	end
	
	if not data.tactics or not data.tactics.shield_cover and mvector3.distance(near_pos, cover[1]) < 240 then
		return true
	end
end

function CopLogicAttack._process_pathing_results(data, my_data)
	if not data.pathing_results then
		return
	end

	local pathing_results = data.pathing_results
	local path = pathing_results[my_data.optimal_path_search_id]
		
	if path then
		--log("ghsanh")
		if path ~= "failed" then
		--log("hgh")
			my_data.optimal_path = path
		else
			--log("aruugugh")
			print("[CopLogicAttack._process_pathing_results] optimal path failed")
		end

		my_data.pathing_to_optimal_pos = nil
		my_data.optimal_path_search_id = nil
	end
	
	local path = pathing_results[my_data.cover_path_search_id]

	if path then
		if path ~= "failed" then
			my_data.cover_path = path
		else
			print(data.unit, "[CopLogicAttack._process_pathing_results] cover path failed", data.unit)
			CopLogicAttack._set_best_cover(data, my_data, nil)

			my_data.cover_path_failed_t = TimerManager:game():time()
		end

		my_data.processing_cover_path = nil
		my_data.cover_path_search_id = nil
	end

	path = pathing_results[my_data.charge_path_search_id]

	if path then
		if path ~= "failed" then
			--log("charge/flank found")
			my_data.charge_path = path
		else
			--print("[CopLogicAttack._process_pathing_results] charge path failed", data.unit)
		end

		my_data.charge_path_search_id = nil
		my_data.charge_path_failed_t = TimerManager:game():time()
	end

	path = pathing_results[my_data.expected_pos_path_search_id]

	if path then
		if path ~= "failed" then
			my_data.expected_pos_path = path
		end

		my_data.expected_pos_path_search_id = nil
	end
	
	data.pathing_results = nil
end

function CopLogicAttack._get_all_paths(data)
	return {
		optimal_path = data.internal_data.optimal_path,
		cover_path = data.internal_data.cover_path,
		flank_path = data.internal_data.flank_path,
		expected_pos_path = data.internal_data.expected_pos_path,
		charge_path = data.internal_data.charge_path
	}
end

function CopLogicAttack._set_verified_paths(data, verified_paths)
	data.internal_data.optimal_path = verified_paths.optimal_path
	data.internal_data.cover_path = verified_paths.cover_path
	data.internal_data.flank_path = verified_paths.flank_path
	data.internal_data.expected_pos_path = verified_paths.expected_pos_path
	data.internal_data.charge_path = verified_paths.charge_path
end

function CopLogicAttack.is_available_for_assignment(data, new_objective)
	local my_data = data.internal_data
	
	if my_data.exiting then
		return
	end
	
	if new_objective and new_objective.forced then
		return true
	end

	if data.unit:movement():chk_action_forbidden("walk") then
		return
	end

	if data.path_fail_t and data.t < data.path_fail_t + 6 then
		return
	end

	if data.is_suppressed and not Global.game_settings.one_down and not managers.skirmish:is_skirmish() then
		return
	end

	if not new_objective or new_objective.type == "free" then
		return true
	end

	if new_objective then
		local allow_trans, obj_fail = CopLogicBase.is_obstructed(data, new_objective, 0.2)

		if obj_fail then
			return
		end
	end

	return true
end

function CopLogicAttack._upd_enemy_detection(data, is_synchronous)
	managers.groupai:state():on_unit_detection_updated(data.unit)

	local my_data = data.internal_data
	local min_reaction = nil
	if data.unit:base():has_tag("special") then
		min_reaction = AIAttentionObject.REACT_AIM
	end
	local delay = CopLogicBase._upd_attention_obj_detection(data, min_reaction, nil)
	local detected_enemies = data.detected_attention_objects
	local tasing = my_data.tasing
	local tased_u_key = tasing and tasing.target_u_key
	local tase_in_effect = nil
	local get_new_target = true

	if tasing then
		if data.unit:movement()._active_actions[3] and data.unit:movement()._active_actions[3]:type() == "tase" then
			local tase_action = data.unit:movement()._active_actions[3]

			if tase_action._discharging or tase_action._firing_at_husk or tase_action._discharging_on_husk then
				tase_in_effect = true
			end
		end
	end

	if tase_in_effect then
		return
	end
	
	local reaction_func = nil
	
	if data.unit:base()._tweak_table == "taser" then
		reaction_func = TaserLogicAttack._chk_reaction_to_attention_object
	end
	
	if alive(data.unit:inventory() and data.unit:inventory()._shield_unit) then
		local focus_enemy, focus_enemy_angle, focus_enemy_reaction = nil
		local enemies = {}
		local enemies_cpy = {}
		local passive_enemies = {}
		local threat_epicenter, threats = nil
		local nr_threats = 0
		local verified_chk_t = data.t - 8
		for key, enemy_data in pairs(detected_enemies) do
			if AIAttentionObject.REACT_COMBAT <= enemy_data.reaction and enemy_data.identified and enemy_data.verified_t and verified_chk_t < enemy_data.verified_t then
				enemies[key] = enemy_data
				enemies_cpy[key] = enemy_data
			end
		end

		for key, enemy_data in pairs(enemies) do
			threat_epicenter = threat_epicenter or Vector3()

			mvector3.add(threat_epicenter, enemy_data.m_pos)

			nr_threats = nr_threats + 1
			enemy_data.aimed_at = CopLogicIdle.chk_am_i_aimed_at(data, enemy_data, enemy_data.aimed_at and 0.95 or 0.985)
		end

		if threat_epicenter then
			mvector3.divide(threat_epicenter, nr_threats)

			local from_threat = mvector3.copy(threat_epicenter)

			mvector3.subtract(from_threat, data.m_pos)
			mvector3.normalize(from_threat)

			local furthest_pt_dist = 0
			local furthest_line = nil

			if not my_data.threat_epicenter or mvector3.distance(threat_epicenter, my_data.threat_epicenter) > 100 then
				my_data.threat_epicenter = mvector3.copy(threat_epicenter)

				for key1, enemy_data1 in pairs(enemies) do
					enemies_cpy[key1] = nil

					for key2, enemy_data2 in pairs(enemies_cpy) do
						if nr_threats == 2 then
							local AB = mvector3.copy(enemy_data1.m_pos)

							mvector3.subtract(AB, enemy_data2.m_pos)
							mvector3.normalize(AB)

							local PA = mvector3.copy(data.m_pos)

							mvector3.subtract(PA, enemy_data1.m_pos)
							mvector3.normalize(PA)

							local PB = mvector3.copy(data.m_pos)

							mvector3.subtract(PB, enemy_data2.m_pos)
							mvector3.normalize(PB)

							local dot1 = mvector3.dot(AB, PA)
							local dot2 = mvector3.dot(AB, PB)

							if dot1 < 0 and dot2 < 0 or dot1 > 0 and dot2 > 0 then
								break
							else
								furthest_line = {
									enemy_data1.m_pos,
									enemy_data2.m_pos
								}

								break
							end
						end

						local pt = math.line_intersection(enemy_data1.m_pos, enemy_data2.m_pos, threat_epicenter, data.m_pos)
						local to_pt = mvector3.copy(threat_epicenter)

						mvector3.subtract(to_pt, pt)
						mvector3.normalize(to_pt)

						if mvector3.dot(from_threat, to_pt) > 0 then
							local line = mvector3.copy(enemy_data2.m_pos)

							mvector3.subtract(line, enemy_data1.m_pos)

							local line_len = mvector3.normalize(line)
							local pt_line = mvector3.copy(pt)

							mvector3.subtract(pt_line, enemy_data1.m_pos)

							local dot = mvector3.dot(line, pt_line)

							if dot < line_len and dot > 0 then
								local dist = mvector3.distance(pt, threat_epicenter)

								if furthest_pt_dist < dist then
									furthest_pt_dist = dist
									furthest_line = {
										enemy_data1.m_pos,
										enemy_data2.m_pos
									}
								end
							end
						end
					end
				end
			end

			local optimal_direction = nil

			if furthest_line then
				local BA = mvector3.copy(furthest_line[2])

				mvector3.subtract(BA, furthest_line[1])

				local PA = mvector3.copy(furthest_line[1])

				mvector3.subtract(PA, data.m_pos)

				local out = nil

				if nr_threats == 2 then
					mvector3.normalize(BA)

					local len = mvector3.dot(BA, PA)
					local x = mvector3.copy(furthest_line[1])

					mvector3.multiply(BA, len)
					mvector3.subtract(x, BA)

					out = mvector3.copy(data.m_pos)

					mvector3.subtract(out, x)
				else
					local EA = mvector3.copy(threat_epicenter)

					mvector3.subtract(EA, furthest_line[1])

					local rot_axis = Vector3()

					mvector3.cross(rot_axis, BA, EA)
					mvector3.set_static(rot_axis, 0, 0, rot_axis.z)

					out = Vector3()

					mvector3.cross(out, BA, rot_axis)
				end

				mvector3.normalize(out)

				optimal_direction = mvector3.copy(out)

				mvector3.multiply(optimal_direction, -1)
				mvector3.multiply(out, mvector3.dot(out, PA) + 600)

				my_data.optimal_pos = mvector3.copy(data.m_pos)

				mvector3.add(my_data.optimal_pos, out)
			else
				optimal_direction = mvector3.copy(threat_epicenter)

				mvector3.subtract(optimal_direction, data.m_pos)
				mvector3.normalize(optimal_direction)

				local optimal_length = 0

				for _, enemy in pairs(enemies) do
					local enemy_dir = mvector3.copy(threat_epicenter)

					mvector3.subtract(enemy_dir, enemy.m_pos)

					local len = mvector3.dot(enemy_dir, optimal_direction)
					optimal_length = math.max(len, optimal_length)
				end

				local optimal_pos = mvector3.copy(optimal_direction)

				mvector3.multiply(optimal_pos, -(optimal_length + 600))
				mvector3.add(optimal_pos, threat_epicenter)

				my_data.optimal_pos = optimal_pos
			end

			for key, enemy_data in pairs(enemies) do
				local reaction = CopLogicSniper._chk_reaction_to_attention_object(data, enemy_data, true)

				if not focus_enemy_reaction or focus_enemy_reaction <= reaction then
					local enemy_dir = Vector3()

					mvector3.direction(enemy_dir, data.m_pos, enemy_data.m_pos)

					local angle = mvector3.dot(optimal_direction, enemy_dir)

					if data.attention_obj and key == data.attention_obj.u_key then
						angle = angle + 0.15
					end

					if not focus_enemy or enemy_data.verified and not focus_enemy.verified or (enemy_data.verified or not focus_enemy.verified) and focus_enemy_angle < angle then
						focus_enemy = enemy_data
						focus_enemy_angle = angle
						focus_enemy_reaction = reaction
					end
				end
			end

			CopLogicBase._set_attention_obj(data, focus_enemy, focus_enemy_reaction)
			get_new_target = nil
		end
	end
		
	if get_new_target then
		local new_attention, new_prio_slot, new_reaction = CopLogicIdle._get_priority_attention(data, detected_enemies, reaction_func)
		local old_att_obj = data.attention_obj

		CopLogicBase._set_attention_obj(data, new_attention, new_reaction)
		
		if new_attention and new_reaction then 
			if AIAttentionObject.REACT_COMBAT <= new_reaction and new_attention.nav_tracker then
				if alive(data.unit:inventory() and data.unit:inventory()._shield_unit) then
					my_data.optimal_pos = CopLogicAttack._find_flank_pos(data, my_data, new_attention.nav_tracker)
				elseif data.tactics and data.tactics.flank then
					my_data.optimal_pos = CopLogicAttack._find_flank_pos(data, my_data, new_attention.nav_tracker)
				elseif data.tactics and data.tactics.charge then
					my_data.optimal_pos = CopLogicTravel._get_pos_on_wall(new_attention.nav_tracker:field_position(), my_data.weapon_range.close, 45, nil)
				end
			end
		end
		
		if new_attention then
			if old_att_obj and old_att_obj.u_key ~= new_attention.u_key then
				CopLogicAttack._cancel_charge(data, my_data)

				my_data.flank_cover = nil

				if not data.unit:movement():chk_action_forbidden("walk") then
					CopLogicAttack._cancel_walking_to_cover(data, my_data)
				end

				CopLogicAttack._set_best_cover(data, my_data, nil)
			end
		elseif old_att_obj then
			CopLogicAttack._cancel_charge(data, my_data)

			my_data.flank_cover = nil
		end
		
		if alive(data.unit:inventory() and data.unit:inventory()._shield_unit) then
			if new_attention then
				if old_att_obj and old_att_obj.u_key ~= new_attention.u_key then
					CopLogicAttack._cancel_charge(data, my_data)

					if not data.unit:movement():chk_action_forbidden("walk") then
						ShieldLogicAttack._cancel_optimal_attempt(data, my_data)
					end
				end
			elseif old_att_obj and not data.unit:movement():chk_action_forbidden("walk") then
				ShieldLogicAttack._cancel_optimal_attempt(data, my_data)
			end
		end
	end
	
	CopLogicAttack._chk_exit_attack_logic(data, new_reaction)

	if my_data ~= data.internal_data then
		return
	end
	
	local objective = data.objective
	local allow_trans, obj_failed = CopLogicBase.is_obstructed(data, objective, nil, new_attention)

	if allow_trans and (obj_failed or not objective or objective.type ~= "follow") then
		local wanted_state = CopLogicBase._get_logic_state_from_reaction(data)

		if wanted_state and wanted_state ~= data.name then
			if obj_failed then
				data.objective_failed_clbk(data.unit, data.objective)
			end

			if my_data == data.internal_data and not objective.is_default then
				debug_pause_unit(data.unit, "[CopLogicAttack._upd_enemy_detection] exiting without discarding objective", data.unit, inspect(objective))
				
				CopLogicBase._exit(data.unit, wanted_state)
			end

			CopLogicBase._report_detections(detected_enemies)

			return delay
		end
	end

	CopLogicBase._chk_call_the_police(data)

	if my_data ~= data.internal_data then
		return
	end

	CopLogicAttack._upd_aim(data, my_data)

	if not is_synchronous then
		CopLogicBase.queue_task(my_data, my_data.detection_task_key, CopLogicAttack._upd_enemy_detection, data, delay and data.t + delay, data.important and true)
	end

	CopLogicBase._report_detections(data.detected_attention_objects)
end