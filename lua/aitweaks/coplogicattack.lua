local mvec3_set = mvector3.set
local mvec3_set_z = mvector3.set_z
local mvec3_sub = mvector3.subtract
local mvec3_dir = mvector3.direction
local mvec3_dot = mvector3.dot
local mvec3_dis = mvector3.distance
local mvec3_dis_sq = mvector3.distance_sq
local mvec3_lerp = mvector3.lerp
local mvec3_norm = mvector3.normalize
local temp_vec1 = Vector3()
local temp_vec2 = Vector3()
local temp_vec3 = Vector3()

function CopLogicAttack.enter(data, new_logic_name, enter_params)
	CopLogicBase.enter(data, new_logic_name, enter_params)
	data.unit:brain():cancel_all_pathing_searches()

	local old_internal_data = data.internal_data
	local my_data = {
		unit = data.unit
	}
	data.internal_data = my_data
	my_data.detection = data.char_tweak.detection.combat

	if old_internal_data then
		my_data.turning = old_internal_data.turning
		my_data.firing = old_internal_data.firing
		my_data.shooting = old_internal_data.shooting
		my_data.attention_unit = old_internal_data.attention_unit

		CopLogicAttack._set_best_cover(data, my_data, old_internal_data.best_cover)
	end

	my_data.cover_test_step = 1
	local key_str = tostring(data.key)
	my_data.detection_task_key = "CopLogicAttack._upd_enemy_detection" .. key_str

	CopLogicBase.queue_task(my_data, my_data.detection_task_key, CopLogicAttack._upd_enemy_detection, data, data.t)
	CopLogicIdle._chk_has_old_action(data, my_data)

	my_data.attitude = data.objective and data.objective.attitude or "avoid"
	
	local safety_range = nil
	
	safety_range = {
		optimal = 3500,
		far = 6000,
		close = 2000
	}
	
	if data.char_tweak.weapon[data.unit:inventory():equipped_unit():base():weapon_tweak_data().usage].range then
		my_data.weapon_range = data.char_tweak.weapon[data.unit:inventory():equipped_unit():base():weapon_tweak_data().usage].range
	else
		my_data.weapon_range = safety_range
	end

	data.unit:brain():set_update_enabled_state(true)

	if data.cool then
		data.unit:movement():set_cool(false)
	end

	if (not data.objective or not data.objective.stance) and data.unit:movement():stance_code() == 1 then
		data.unit:movement():set_stance("hos")
	end

	if my_data ~= data.internal_data then
		return
	end

	if data.objective and (data.objective.action_duration or data.objective.action_timeout_t and data.t < data.objective.action_timeout_t) then
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

			if not data.unit:in_slot(16) and data.char_tweak.chatter.aggressive then
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
						if not data.attack_sound_t or data.t - data.attack_sound_t > shield_knock_cooldown then
							data.unit:sound():say("shield_identification", true)
						end
					else
						managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "contact")
					end
				end
			end
		end
	elseif my_data.firing then
		data.unit:movement():set_allow_fire(false)

		my_data.firing = nil
	end
end

function CopLogicAttack._upd_aim(data, my_data)
	local shoot, aim, expected_pos, height_difference, outoffov = nil
	local focus_enemy = data.attention_obj
	local diff_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)
	
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
	
	if focus_enemy and AIAttentionObject.REACT_AIM <= focus_enemy.reaction then
		local last_sup_t = data.unit:character_damage():last_suppression_t()

		if focus_enemy.verified or focus_enemy.nearly_visible then
			
			if data.unit:anim_data().run and math.lerp(my_data.weapon_range.close, my_data.weapon_range.optimal, 0) < focus_enemy.dis then
				local walk_to_pos = data.unit:movement():get_walk_to_pos()

				if walk_to_pos then
					mvector3.direction(temp_vec1, data.m_pos, walk_to_pos)
					mvector3.direction(temp_vec2, data.m_pos, focus_enemy.m_pos)

					local dot = mvector3.dot(temp_vec1, temp_vec2)

					if dot < 0.6 then
						shoot = nil
						aim = nil
						outoffov = true
					end
				end
			end
			
			--harass: attempt to engage enemies who are leaving themselves open, with things like interactions, changing weapons or reloading 
	
			--this is important for harass.
			local pantsdownchk = nil
					
			if not data.unit:in_slot(16) and focus_enemy and focus_enemy.is_person and focus_enemy.verified and focus_enemy.dis <= 2000 then
				if focus_enemy.is_local_player then
					local e_movement_state = focus_enemy.unit:movement():current_state()
					if e_movement_state:_is_reloading() or e_movement_state:_interacting() or e_movement_state:is_equipping() then
						pantsdownchk = true
					end
				else
					local e_anim_data = focus_enemy.unit:anim_data()
					if not (e_anim_data.move or e_anim_data.idle) or e_anim_data.reload then
						pantsdownchk = true
					end
				end
			end
			
			if not shoot and focus_enemy and focus_enemy.verified and data.tactics and data.tactics.harass and pantsdownchk and not outoffov then 
				if managers.groupai:state():chk_high_fed_density() then
					--log("not firing due to FEDS")
				else
					shoot = true
				end
			end

			if aim == nil and AIAttentionObject.REACT_AIM <= focus_enemy.reaction then
				if AIAttentionObject.REACT_SHOOT <= focus_enemy.reaction then
					local running = my_data.advancing and not my_data.advancing:stopping() and my_data.advancing:haste() == "run"
					local firing_range = 1800

					if data.internal_data.weapon_range then
						firing_range = running and data.internal_data.weapon_range.close or data.internal_data.weapon_range.far
						maxrange = data.internal_data.weapon_range.far
					else
						debug_pause_unit(data.unit, "[CopLogicAttack]: Unit doesn't have data.internal_data.weapon_range")
					end
					
					if not managers.groupai:state():whisper_mode() then
						if focus_enemy.verified and focus_enemy.alert_t and data.t - focus_enemy.alert_t < 7 and managers.groupai:state():chk_assault_active_atm() then
							if dense_mook and managers.groupai:state():chk_high_fed_density() and not my_data.firing then
								--log("not firing due to FEDS")
							else
								shoot = true
							end
						elseif focus_enemy.verified and data.internal_data.weapon_range and focus_enemy.verified_dis < firing_range and managers.groupai:state():chk_assault_active_atm() then
							if dense_mook and managers.groupai:state():chk_high_fed_density() and not my_data.firing then
								--log("not firing due to FEDS")
							else
								shoot = true
							end
						elseif focus_enemy.verified and focus_enemy.criminal_record and focus_enemy.criminal_record.assault_t and data.t - focus_enemy.criminal_record.assault_t < 4 then
							if dense_mook and managers.groupai:state():chk_high_fed_density() and not my_data.firing then
								--log("not firing due to FEDS")
							else
								shoot = true
							end
						end
					end
					
					if managers.groupai:state():whisper_mode() then
						if focus_enemy.verified and focus_enemy.criminal_record and focus_enemy.criminal_record.assault_t and data.t - focus_enemy.criminal_record.assault_t < 4 then
							shoot = true
						end
					end

					if not shoot and not managers.groupai:state():whisper_mode() and my_data.attitude == "engage" and not managers.groupai:state():chk_active_assault_break() then
						if focus_enemy.verified_dis < firing_range * (height_difference and 0.75 or 1) or focus_enemy.reaction == AIAttentionObject.REACT_SHOOT then
							if dense_mook and managers.groupai:state():chk_high_fed_density() and not my_data.firing then
									--log("not firing due to FEDS")
							else
								shoot = true
							end
						else
							local time_since_verification = focus_enemy.verified_t and data.t - focus_enemy.verified_t

							if my_data.firing and time_since_verification and time_since_verification < 3 then
								shoot = true
								if dense_mook and managers.groupai:state():chk_high_fed_density() then
									--log("not hunting due to FEDS")
								else
									--they'll start pathing ahead of time to hunt
									if data.tactics and data.tactics.charge and focus_enemy.is_person then
										data.brain:search_for_path_to_unit("hunt" .. tostring(my_data.key), focus_enemy.unit)
									end
								end
							else
								if dense_mook and managers.groupai:state():chk_high_fed_density() then
									--log("not hunting due to FEDS")
								else
									--they'll start pathing ahead of time to hunt
									if not (data.tactics and data.tactics.obstacle) and focus_enemy.is_person then
										data.brain:search_for_path_to_unit("hunt" .. tostring(my_data.key), focus_enemy.unit)
									end
								end
							end
						end
					end

					aim = aim or shoot
					
					if diff_index > 5 and managers.groupai:state():whisper_mode() then
						if focus_enemy.verified and not shoot then
							shoot = true
						end
					end
					
				else
					aim = true
				end
			end
		elseif AIAttentionObject.REACT_AIM <= focus_enemy.reaction then
			local time_since_verification = focus_enemy.verified_t and data.t - focus_enemy.verified_t
			local running = my_data.advancing and not my_data.advancing:stopping() and my_data.advancing:haste() == "run"
			local same_z = math.abs(focus_enemy.verified_pos.z - data.m_pos.z) < 250

			if running then
				if time_since_verification and time_since_verification < 0.5 and same_z then
					aim = true
				end
			elseif time_since_verification and time_since_verification < 1 then
				aim = true
			end

			if aim and my_data.shooting and not managers.groupai:state():whisper_mode() and AIAttentionObject.REACT_SHOOT <= focus_enemy.reaction and time_since_verification and time_since_verification < (running and 1 or 2) then
				if dense_mook and managers.groupai:state():chk_high_fed_density() then
					--log("not firing due to FEDS")
				else
					shoot = true
				end
			end

			if not aim then
				expected_pos = CopLogicAttack._get_expected_attention_position(data, my_data)

				if expected_pos then
					if running then
						local watch_dir = temp_vec1

						mvec3_set(watch_dir, expected_pos)
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
							
							if focus_enemy and aim and focus_enemy.alert_t and data.t - focus_enemy.alert_t < 1 and focus_enemy.verified_t and data.t - focus_enemy.verified_t < 5 and data.tactics and data.tactics.harass then
								if dense_mook and managers.groupai:state():chk_high_fed_density() then
									--log("not firing due to FEDS")
								else
									shoot = true
								end
							end
						end
					else
						aim = true
						
						if focus_enemy and aim and focus_enemy.verified_t and data.t - focus_enemy.verified_t < 5 and data.tactics and data.tactics.harass then
							if dense_mook and managers.groupai:state():chk_high_fed_density() then
								--log("not firing due to FEDS")
							else
								shoot = true
							end
						end
					end
				end
			end
		else
			expected_pos = CopLogicAttack._get_expected_attention_position(data, my_data)

			if expected_pos then
				aim = true
				
				--cops will open fire on expected player positions if they hear player alerts and the player has been seen in the last 5 seconds, and they're harassers, for large bursts of suppressive fire.
				
				if focus_enemy and aim and focus_enemy.alert_t and data.t - focus_enemy.alert_t < 1 and focus_enemy.verified_t and data.t - focus_enemy.verified_t < 5 and data.tactics and data.tactics.harass then
					if dense_mook and managers.groupai:state():chk_high_fed_density() then
						--log("not firing due to FEDS")
					else
						shoot = true
					end
				end
			end
		end
	end
		
	--cops call out player reloads if they've seen the player in the last 2 seconds if they have the harass tactic
	if focus_enemy and focus_enemy.is_person and focus_enemy.reaction >= AIAttentionObject.REACT_COMBAT and not data.unit:in_slot(16) and data.tactics and data.tactics.harass then
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
	
	if not aim and data.char_tweak.always_face_enemy and focus_enemy and AIAttentionObject.REACT_COMBAT >= focus_enemy.reaction then
		aim = true
	end

	if data.logic.chk_should_turn(data, my_data) and (focus_enemy or expected_pos) then
		local enemy_pos = expected_pos or (focus_enemy.verified or focus_enemy.nearly_visible) and focus_enemy.m_pos or focus_enemy.verified_pos

		CopLogicAttack._chk_request_action_turn_to_enemy(data, my_data, data.m_pos, enemy_pos)
	end

	if aim or shoot then
		if expected_pos then
			if my_data.attention_unit ~= expected_pos then
				CopLogicBase._set_attention_on_pos(data, mvector3.copy(expected_pos))

				my_data.attention_unit = mvector3.copy(expected_pos)
			end
		elseif focus_enemy.verified or focus_enemy.nearly_visible then
			if my_data.attention_unit ~= focus_enemy.u_key then
				CopLogicBase._set_attention(data, focus_enemy)

				my_data.attention_unit = focus_enemy.u_key
			end
		else
			local look_pos = focus_enemy.last_verified_pos or focus_enemy.verified_pos

			if my_data.attention_unit ~= look_pos then
				CopLogicBase._set_attention_on_pos(data, mvector3.copy(look_pos))

				my_data.attention_unit = mvector3.copy(look_pos)
			end
		end

		if not my_data.shooting and not my_data.spooc_attack and not data.unit:anim_data().reload and not data.unit:movement():chk_action_forbidden("action") then
			local shoot_action = {
				body_part = 3,
				type = "shoot"
			}

			if data.unit:brain():action_request(shoot_action) then
				my_data.shooting = true
			end
		end
	else
		if my_data.shooting and not data.unit:anim_data().reload then
			local new_action = {
				body_part = 3,
				type = "idle"
			}

			data.unit:brain():action_request(new_action)
		end

		if my_data.attention_unit then
			CopLogicBase._reset_attention(data)

			my_data.attention_unit = nil
		end
	end
	
	if focus_enemy and focus_enemy.reaction >= AIAttentionObject.REACT_COMBAT then
		
		local reaction_comply = focus_enemy and focus_enemy.verified and focus_enemy.verified_t > 0.2
		
		local loud_react_comply = focus_enemy and focus_enemy.verified and focus_enemy.verified_t > 0.2
		
		if managers.groupai:state():whisper_mode() then
			if not reaction_comply then
				shoot = nil
			end
		else
			if not loud_react_comply and not data.unit:base()._tweak_table == "spooc" and not data.unit:base()._tweak_table == "taser" and not data.unit:base()._tweak_table == "spooc_heavy" and not data.unit:base()._tweak_table == "shadow_spooc" then
				shoot = nil
			end
		end
		
		if managers.groupai:state():chk_high_fed_density() and dense_mook then
			shoot = nil
			--log("not firing due to FEDS")
		end
	end
	
	if not my_data.weapon_range and focus_enemy and focus_enemy.dis > 6000 or my_data.weapon_range and focus_enemy and focus_enemy.dis > my_data.weapon_range.far then
		shoot = nil
	end

	CopLogicAttack.aim_allow_fire(shoot, aim, data, my_data)
end

function CopLogicAttack._chk_request_action_walk_to_cover(data, my_data)
	CopLogicAttack._correct_path_start_pos(data, my_data.cover_path)
	
	local haste = nil
	
	local can_perform_walking_action = not my_data.turning and not data.unit:movement():chk_action_forbidden("walk") and not my_data.has_old_action and not my_data.moving_to_cover and not my_data.walking_to_cover_shoot_pos
	local pose = nil
	
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
		"taser",
		"shield"
	}
	local is_mook = nil
	for _, name in ipairs(mook_units) do
		if data.unit:base()._tweak_table == name then
			is_mook = true
		end
	end
	
	if can_perform_walking_action then 
		
		--enemies at long distances makes cops run, enemies at shorter distances makes cops walk, keeps pacing in small maps consistent and manageable, while making the cops seem cooler
		local enemyseeninlast4secs = data.attention_obj and data.attention_obj.verified_t and data.t - data.attention_obj.verified_t < 4
		local enemy_seen_range_bonus = enemyseeninlast4secs and 500 or 0
		local enemy_has_height_difference = data.attention_obj and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction and data.attention_obj.dis >= 1200 and data.attention_obj.verified_t and data.t - data.attention_obj.verified_t < 4 and math.abs(data.m_pos.z - data.attention_obj.m_pos.z) > 250
		
		if data.unit:movement():cool() then
			haste = "walk"
		elseif data.attention_obj and data.attention_obj.dis > 10000 or data.unit:in_slot(16) or data.is_converted then
			haste = "run"
		elseif data.attention_obj and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction and data.attention_obj.dis > 1200 + enemy_seen_range_bonus and not data.unit:movement():cool() and not managers.groupai:state():whisper_mode() then
			haste = "run"
		elseif data.attention_obj and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction and data.attention_obj.dis <= 1200 + enemy_seen_range_bonus - (math.abs(data.m_pos.z - data.attention_obj.m_pos.z) < 250 and 400 or 0) and is_mook and data.tactics and not data.tactics.hitnrun then
			haste = "walk"
		else
			haste = "run"
		end
		
		if managers.groupai:state():chk_high_fed_density() and data.attention_obj and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction and data.attention_obj.dis < 3000 then
			local randomwalkchance = math.random(0.01, 1)
			if randomwalkchance > 0.1 then
				haste = "walk"
			else
				haste = haste
			end
		end

		local crouch_roll = math.random(0.01, 1)
		local stand_chance = nil
		local end_pose = nil
	
		if data.attention_obj and data.attention_obj.dis > 10000 or data.unit:in_slot(16) or data.is_converted then
			stand_chance = 1
			pose = "stand"
			end_pose = "stand"
		elseif data.attention_obj and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction and data.attention_obj.dis > 2000 then
			stand_chance = 0.75
		elseif enemy_has_height_difference and (not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.crouch) and is_mook then
			stand_chance = 0.25
		elseif data.attention_obj and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction and (data.attention_obj.verified and data.attention_obj.dis <= 1500 or data.attention_obj.dis <= 1000) and CopLogicTravel._chk_close_to_criminal(data, my_data) and data.tactics and data.tactics.flank and haste == "walk" and is_mook then
			stand_chance = 0.25
		elseif my_data.moving_to_cover and (not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.crouch) then
			stand_chance = 0.5
		else
			stand_chance = 1
			pose = "stand"
			end_pose = "stand"
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
		
		if managers.groupai:state():chk_high_fed_density() and data.attention_obj and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction and data.attention_obj.dis < 3000 then
			local randomwalkchance = math.random(0.01, 1)
			if randomwalkchance > 0.10 then
				haste = "walk"
			else
				haste = haste
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
	local can_perform_walking_action = not my_data.turning and not data.unit:movement():chk_action_forbidden("walk") and not my_data.has_old_action and not my_data.moving_to_cover and not my_data.walking_to_cover_shoot_pos
	
	local pose = nil
	
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
		"taser",
		"shield"
	}
	local is_mook = nil
	for _, name in ipairs(mook_units) do
		if data.unit:base()._tweak_table == name then
			is_mook = true
		end
	end
	
	if can_perform_walking_action then
		CopLogicAttack._cancel_cover_pathing(data, my_data)
		CopLogicAttack._cancel_charge(data, my_data)
		CopLogicAttack._correct_path_start_pos(data, path)
		
		--enemies at long distances makes cops run, enemies at shorter distances makes cops walk, keeps pacing in small maps consistent and manageable, while making the cops seem cooler
		local enemyseeninlast4secs = data.attention_obj and data.attention_obj.verified_t and data.t - data.attention_obj.verified_t < 4
		local enemy_seen_range_bonus = enemyseeninlast4secs and 500 or 0
		local enemy_has_height_difference = data.attention_obj and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction and data.attention_obj.dis >= 1200 and data.attention_obj.verified_t and data.t - data.attention_obj.verified_t < 4 and math.abs(data.m_pos.z - data.attention_obj.m_pos.z) > 250
		
		if data.unit:movement():cool() then
			haste = "walk"
		elseif data.is_converted or data.unit:in_slot(16) or data.attention_obj and data.attention_obj.dis > 10000 then 
			haste = "run"
		elseif data.attention_obj and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction and data.attention_obj.dis > 1200 + (enemyseeninlast4secs and 500 or 0) and not data.unit:movement():cool() and not managers.groupai:state():whisper_mode() then
			haste = "run"
		elseif data.attention_obj and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction and data.attention_obj.dis <= 1200 + enemy_seen_range_bonus - (math.abs(data.m_pos.z - data.attention_obj.m_pos.z) < 250 and 400 or 0) and is_mook and data.tactics and not data.tactics.hitnrun then
			haste = "walk"
		else
			haste = "run"
		end
		
		if managers.groupai:state():chk_high_fed_density() and data.attention_obj and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction and data.attention_obj.dis < 3000 then
			local randomwalkchance = math.random(0.01, 1)
			if randomwalkchance > 0.1 then
				haste = "walk"
			else
				haste = haste
			end
		end

		local crouch_roll = math.random(0.01, 1)
		local stand_chance = nil
		local end_pose = nil
	
		if data.attention_obj and data.attention_obj.dis > 10000 or data.is_converted or data.unit:in_slot(16) then
			stand_chance = 1
			pose = "stand"
			end_pose = "stand"
		elseif data.attention_obj and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction and data.attention_obj.dis > 2000 and is_mook then
			stand_chance = 0.75
		elseif enemy_has_height_difference and (not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.crouch) and is_mook then
			stand_chance = 0.25
		elseif data.attention_obj and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction and (data.attention_obj.verified and data.attention_obj.dis <= 1500 or data.attention_obj.dis <= 1000) and CopLogicTravel._chk_close_to_criminal(data, my_data) and data.tactics and data.tactics.flank and haste == "walk" and is_mook then
			stand_chance = 0.25
		elseif my_data.moving_to_cover and (not data.char_tweak.allowed_poses or data.char_tweak.allowed_poses.crouch) then
			stand_chance = 0.5
		else
			stand_chance = 1
			pose = "stand"
			end_pose = "stand"
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
		
		if managers.groupai:state():chk_high_fed_density() and data.attention_obj and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction and data.attention_obj.dis < 3000 then
			local randomwalkchance = math.random(0.01, 1)
			if randomwalkchance > 0.10 then
				haste = "walk"
			else
				haste = haste
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

function CopLogicAttack._upd_combat_movement(data)
	local my_data = data.internal_data
	local t = data.t
	local unit = data.unit
	local diff_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)
	local focus_enemy = data.attention_obj
	local in_cover = my_data.in_cover
	local best_cover = my_data.best_cover
	local enemy_visible = focus_enemy and focus_enemy.verified
	local enemy_visible_soft = nil
	
	if Global.game_settings.one_down or managers.skirmish.is_skirmish() then
		if data.tactics and data.tactics.ranged_fire or data.tactics and data.tactics.elite_ranged_fire then
			enemy_visible_soft = focus_enemy.verified_t and t - focus_enemy.verified_t < math.random(1, 2)
		else
			enemy_visible_soft = focus_enemy and focus_enemy.verified
		end
	else
		if diff_index <= 5 then
			if data.tactics and data.tactics.ranged_fire or data.tactics and data.tactics.elite_ranged_fire then
				enemy_visible_soft = focus_enemy.verified_t and t - focus_enemy.verified_t < math.random(3.1, 3.8)
			else
				enemy_visible_soft = focus_enemy.verified_t and t - focus_enemy.verified_t < math.random(1.05, 1.4)
			end
		else
			if data.tactics and data.tactics.ranged_fire or data.tactics and data.tactics.elite_ranged_fire then
				enemy_visible_soft = focus_enemy.verified_t and t - focus_enemy.verified_t < math.random(2, 3)
			else
				enemy_visible_soft = focus_enemy.verified_t and t - focus_enemy.verified_t < math.random(0.35, 1.05)
			end
		end
	end
	
	local enemy_visible_mild_soft = focus_enemy and focus_enemy.verified_t and t - focus_enemy.verified_t < 2
	local enemy_visible_softer = focus_enemy and focus_enemy.verified_t and t - focus_enemy.verified_t < 4
	local antipassivecheck = nil
	local flank_cover_charge_qualify = focus_enemy and focus_enemy.verified_t and t - focus_enemy.verified_t > 2 or focus_enemy.verified
	
	if Global.game_settings.one_down or managers.skirmish.is_skirmish() then
		if data.tactics and data.tactics.ranged_fire or data.tactics and data.tactics.elite_ranged_fire then
			antipassivecheck = focus_enemy and focus_enemy.verified and focus_enemy.verified_t > math.random(1, 2)
		else
			antipassivecheck = focus_enemy and focus_enemy.verified or my_data.shooting --fuck you <3
		end
	else
		if diff_index <= 5 then
			if data.tactics and data.tactics.ranged_fire or data.tactics and data.tactics.elite_ranged_fire then
				antipassivecheck = focus_enemy and focus_enemy.verified and focus_enemy.verified_t > math.random(3.1, 3.8)
			else
				antipassivecheck = focus_enemy and focus_enemy.verified and focus_enemy.verified_t > math.random(1.05, 1.4)
			end
		else
			if data.tactics and data.tactics.ranged_fire or data.tactics and data.tactics.elite_ranged_fire then
				antipassivecheck = focus_enemy and focus_enemy.verified and focus_enemy.verified_t > math.random(2, 3)
			else
				antipassivecheck = focus_enemy and focus_enemy.verified and focus_enemy.verified_t > math.random(0.35, 0.7)
			end
		end
	end
	
	if not managers.groupai:state():chk_active_assault_break() then
		my_data.has_retreated = nil
		my_data.in_retreat_pos = nil
	end
	
	local alert_soft = data.is_suppressed
	local action_taken = data.logic.action_taken(data, my_data)
	
	--hitnrun: approach enemies, back away once the enemy is visible, creating a variating degree of aggressiveness
	--eliterangedfire: open fire at enemies from longer distances, back away if the enemy gets too close for comfort
	--spoocavoidance: attempt to approach enemies, if aimed at/seen, retreat away into cover and disengage until ready to try again
	local hitnrunmovementqualify = data.tactics and data.tactics.hitnrun and focus_enemy and focus_enemy.verified and focus_enemy.verified_dis <= 1000 and math.abs(data.m_pos.z - data.attention_obj.m_pos.z) < 200
	local spoocavoidancemovementqualify = data.tactics and data.tactics.spoocavoidance and focus_enemy and focus_enemy.verified and focus_enemy.verified_dis <= 2000 and focus_enemy.aimed_at
	local eliterangedfiremovementqualify = data.tactics and data.tactics.elite_ranged_fire and focus_enemy and focus_enemy.verified and focus_enemy.verified_dis <= 1500
	
	--dangerawarenessGL: if i am aimed while the enemy is holding a grenade launcher within 30 meters, find nearby position to retreat to and disperse
	local antiexpmovementqualify = nil
	
	if data.tactics and data.tactics.dangerawarenessGL and focus_enemy and focus_enemy.verified and focus_enemy.verified_dis <= 3000 and focus_enemy.aimed_at and data.attention_obj.unit and data.attention_obj.is_person then
		local weapon_unit = data.attention_obj.unit:inventory():equipped_unit()
		if alive(weapon_unit) and weapon_unit:base().is_category and weapon_unit:base():is_category("grenade_launcher") then
			if data.attention_obj.aimed_at then
				antiexpmovementqualify = true
			end
		end
	end
	
	local ammo_max, ammo = data.unit:inventory():equipped_unit():base():ammo_info()
	local reloadingretreatmovementqualify = ammo / ammo_max < 0.2 and data.tactics and data.tactics.reloadingretreat and focus_enemy and focus_enemy.verified
	
	local want_to_take_cover = my_data.want_to_take_cover
	action_taken = action_taken or CopLogicAttack._upd_pose(data, my_data)
	local move_to_cover, want_flank_cover = nil
	local cover_test_step_chk = action_taken or want_to_take_cover or not in_cover --optimizations, yay
	
	if data.tactics and (data.tactics.hitnrun or data.tactics.murder) or data.unit:base():has_tag("takedown") or Global.game_settings.aggroAI then
		if my_data.cover_test_step ~= 1 and cover_test_step_chk then
			my_data.cover_test_step = 1
			--not many tactics need to be this aggressive, but hitnrun and murder are specifically for bulldozer and units which will want to get up to enemies' faces, and as such, require these.
		end
	else
		if my_data.cover_test_step ~= 1 and not enemy_visible_softer and cover_test_step_chk then
			my_data.cover_test_step = 1
		end
	end
	
	local stay_out_time_chk = enemy_visible_soft and not managers.groupai:state():chk_high_fed_density() or antipassivecheck and not managers.groupai:state():chk_high_fed_density() or not my_data.at_cover_shoot_pos or action_taken or want_to_take_cover
	
	local ranged_fire_sot_bonus = 2.5
	
	if my_data.stay_out_time and stay_out_time_chk then
		my_data.stay_out_time = nil
	elseif my_data.attitude == "engage" and not my_data.stay_out_time and not antipassivecheck and not enemy_visible_soft and my_data.at_cover_shoot_pos and not action_taken and not want_to_take_cover and not (data.tactics and data.tactics.obstacle) then
		if Global.game_settings.one_down or managers.skirmish.is_skirmish() then
			if data.tactics and data.tactics.ranged_fire or data.tactics and data.tactics.elite_ranged_fire then
				my_data.stay_out_time = t + 2
			else
				my_data.stay_out_time = t + 0.01
			end
			--log("interesting")
		else
			if diff_index <= 5 then
				if data.tactics and data.tactics.ranged_fire or data.tactics and data.tactics.elite_ranged_fire then
					my_data.stay_out_time = t + 5 + ranged_fire_sot_bonus
				else
					my_data.stay_out_time = t + 5
				end
			elseif diff_index == 6 or diff_index == 7 then
				if data.tactics and data.tactics.ranged_fire or data.tactics and data.tactics.elite_ranged_fire then
					my_data.stay_out_time = t + 2.5 + ranged_fire_sot_bonus
				else
					my_data.stay_out_time = t + 2.5
				end
			else
				if data.tactics and data.tactics.ranged_fire or data.tactics and data.tactics.elite_ranged_fire then
					my_data.stay_out_time = t + 1.5 + ranged_fire_sot_bonus
				else
					my_data.stay_out_time = t + 1.5
				end
			end
		end
	end
	
	if not action_taken and antiexpmovementqualify then
		action_taken = CopLogicAttack._chk_start_action_move_out_of_the_way(data, my_data)
	end
	
	--removed the need for being important, moved it up in priority
	if not action_taken and not my_data.turning and not data.unit:movement():chk_action_forbidden("walk") and not my_data.has_old_action and CopLogicAttack._can_move(data) and data.attention_obj.verified and not spoocavoidancemovementqualify then
		if data.is_suppressed and data.t - data.unit:character_damage():last_suppression_t() < 0.7 then
			action_taken = CopLogicBase.chk_start_action_dodge(data, "scared")
			if data.char_tweak.chatter.dodge then
				managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "dodge")
			end
			
			if data.char_tweak.chatter.cloakeravoidance then
				managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "cloakeravoidance")
			end
		end

		if not action_taken and focus_enemy.is_person then
			local dodge = nil

			if focus_enemy.is_local_player then
				local e_movement_state = focus_enemy.unit:movement():current_state()

				if not e_movement_state:_is_reloading() and not e_movement_state:_interacting() and not e_movement_state:is_equipping() then
					dodge = true
				end
			else
				local e_anim_data = focus_enemy.unit:anim_data()

				if (e_anim_data.move or e_anim_data.idle) and not e_anim_data.reload then
					dodge = true
				end
			end

			if dodge and focus_enemy.aimed_at then
				action_taken = CopLogicBase.chk_start_action_dodge(data, "preemptive")
				if data.char_tweak.chatter.dodge then
					managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "dodge")
				end
				if data.char_tweak.chatter.cloakeravoidance then
					managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "cloakeravoidance")
				end
			end
		end
	end
	
	if not action_taken and want_to_take_cover and not best_cover or not action_taken and hitnrunmovementqualify and not pantsdownchk or not action_taken and eliterangedfiremovementqualify and not pantsdownchk or not action_taken and spoocavoidancemovementqualify and not pantsdownchk or not action_taken and reloadingretreatmovementqualify or managers.groupai:state():chk_high_fed_density() and not action_taken then
		action_taken = CopLogicAttack._chk_start_action_move_back(data, my_data, focus_enemy, nil, nil)
		if data.char_tweak.chatter.cloakeravoidance then
			managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "cloakeravoidance")
		end
	end
	
	--added some extra stuff here to make sure other enemy groups get in on the fight, also added a new system so that once a flanking position is acquired for flanking teams, they'll charge, in order for flanking to actually happen instead of them just standing around in the flank cover
	if action_taken or my_data.stay_out_time and my_data.stay_out_time > t then
		-- Nothing		
	elseif my_data.walking_to_cover_shoot_pos then
		--nothing
	elseif managers.groupai:state():chk_active_assault_break() and not my_data.has_retreated then
		action_taken = CopLogicAttack._chk_start_action_move_back(data, my_data, focus_enemy, nil, true)
		my_data.has_retreated = true
	elseif managers.groupai:state():chk_active_assault_break() and my_data.has_retreated then
		if my_data.in_retreat_pos then
			if data.tactics and data.tactics.flank then
				want_flank_cover = true
			end
			move_to_cover = true
		end
	elseif want_to_take_cover then
		if data.tactics and data.tactics.flank and managers.groupai:state():chk_assault_active_atm() then
			want_flank_cover = true
		end
		move_to_cover = true
	elseif not enemy_visible_soft and not (data.tactics and data.tactics.obstacle) and not managers.groupai:state():chk_high_fed_density() and not managers.groupai:state():chk_active_assault_break() or antipassivecheck and not managers.groupai:state():chk_high_fed_density() and not managers.groupai:state():chk_active_assault_break() then 
		if not data.objective or data.objective and not data.objective.type == "follow" then
			if data.tactics and data.tactics.charge and data.objective and data.objective.grp_objective and data.objective.grp_objective.charge and (not my_data.charge_path_failed_t or data.t - my_data.charge_path_failed_t > 6) or data.tactics and data.tactics.flank and my_data.flank_cover and in_cover and focus_enemy and focus_enemy.dis <= 4000 and my_data.taken_flank_cover and flank_cover_charge_qualify and (not my_data.next_allowed_flank_charge_t or my_data.next_allowed_flank_charge_t and my_data.next_allowed_flank_charge_t < data.t) and (not my_data.charge_path_failed_t or data.t - my_data.charge_path_failed_t > 2) then
				if my_data.charge_path then
					if data.objective and not data.objective.type == "follow" then
						local path = my_data.charge_path
						action_taken = CopLogicAttack._chk_request_action_walk_to_cover_shoot_pos(data, my_data, path)
						my_data.charge_path = nil
						my_data.taken_flank_cover = nil
					end
				elseif not my_data.charge_path_search_id and data.attention_obj.nav_tracker then
					if data.objective and not data.objective.type == "follow" then
						my_data.charge_pos = CopLogicTravel._get_pos_on_wall(data.attention_obj.nav_tracker:field_position(), my_data.weapon_range.close, 45, nil)

						if my_data.charge_pos then
							my_data.charge_path_search_id = "charge" .. tostring(data.key)

							unit:brain():search_for_path(my_data.charge_path_search_id, my_data.charge_pos, nil, nil, nil)
							
							--my_data.taken_flank_cover = nil
						else
							debug_pause_unit(data.unit, "failed to find charge_pos", data.unit)

							my_data.charge_path_failed_t = TimerManager:game():time()
						end
					end
				end
			elseif in_cover then
				if my_data.cover_test_step <= 2 then
					local height = nil

					if in_cover[4] then
						height = 150
					else
						height = 80
					end

					local my_tracker = unit:movement():nav_tracker()
					local shoot_from_pos = CopLogicAttack._peek_for_pos_sideways(data, my_data, my_tracker, focus_enemy.m_head_pos, height)

					if shoot_from_pos then
						local path = {
							my_tracker:position(),
							shoot_from_pos
						}
						--ranged fire cops signal the start of their movement and positioning
						if data.tactics and data.tactics.ranged_fire or data.tactics and data.tactics.elite_ranged_fire then
							if not data.unit:in_slot(16) then
								if data.group and data.group.leader_key == data.key and data.char_tweak.chatter.ready then
									managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "ready")
								end
							end
						end
						action_taken = CopLogicAttack._chk_request_action_walk_to_cover_shoot_pos(data, my_data, path, math.random() < 0.5 and "run" or "walk")
					else
						my_data.cover_test_step = my_data.cover_test_step + 1
					end
				elseif not enemy_visible_softer and math.random() < 0.05 then
					move_to_cover = true
					want_flank_cover = true
				end
			elseif my_data.at_cover_shoot_pos then
				--ranged fire cops also signal the END of their movement and positioning
				if data.tactics and data.tactics.ranged_fire or data.tactics and data.tactics.elite_ranged_fire then
					if not data.unit:in_slot(16) and data.char_tweak.chatter.ready then
						managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "inpos")
					end
				end
				if my_data.stay_out_time and my_data.stay_out_time < t then
					if data.tactics and data.tactics.flank and managers.groupai:state():chk_assault_active_atm() then
						want_flank_cover = true 
						--i went ahead and included these to make sure flankers are always getting flanking positions instead of regular ones, it helps them stay predictable in regards to their choices of movement, you can tell a flank team by 1. smoke grenades being present 2. their chatter and 3. how they prefer to move around the map.
					end
					move_to_cover = true
				end				
			else
				if data.tactics and data.tactics.flank and managers.groupai:state():chk_assault_active_atm() then
					want_flank_cover = true
				end
				move_to_cover = true
			end
		end
	end

	if not my_data.processing_cover_path and not my_data.cover_path and not my_data.charge_path_search_id and not action_taken and best_cover and (not in_cover or best_cover[1] ~= in_cover[1]) and (not my_data.cover_path_failed_t or data.t - my_data.cover_path_failed_t > 5) then
		CopLogicAttack._cancel_cover_pathing(data, my_data)

		local search_id = tostring(unit:key()) .. "cover"

		if data.unit:brain():search_for_path_to_cover(search_id, best_cover[1], best_cover[5]) then
			my_data.cover_path_search_id = search_id
			my_data.processing_cover_path = best_cover
		end
	end

	if not action_taken and move_to_cover and my_data.cover_path then
		action_taken = CopLogicAttack._chk_request_action_walk_to_cover(data, my_data)
	end

	if want_flank_cover then
		if not my_data.flank_cover then
			local sign = math.random() < 0.5 and -1 or 1
			local step = 30
			my_data.flank_cover = {
				step = step,
				angle = step * sign,
				sign = sign
			}
			my_data.taken_flank_cover = true --this helps them qualify for charging behavior after acquiring a flank, which is not vanilla behavior btw
			my_data.next_allowed_flank_charge_t = data.t + 2
			want_flank_cover = nil
			if not data.unit:in_slot(16) then --flankers signal their presence whenever they move around
				if data.group and data.group.leader_key == data.key and data.char_tweak.chatter.look_for_angle then
					managers.groupai:state():chk_say_enemy_chatter(data.unit, data.m_pos, "look_for_angle")
				end
			end
		end
	else
		my_data.flank_cover = nil
		my_data.taken_flank_cover = nil
	end
	
	action_taken = action_taken or CopLogicAttack._chk_start_action_move_out_of_the_way(data, my_data)
end

function CopLogicAttack._chk_start_action_move_back(data, my_data, focus_enemy, engage, assault_break)

	local pantsdownchk = nil
	
	if not data.unit:in_slot(16) and focus_enemy and focus_enemy.is_person and focus_enemy.dis <= 2000 then
		if focus_enemy.is_local_player then
			local e_movement_state = focus_enemy.unit:movement():current_state()

			if e_movement_state:_is_reloading() or e_movement_state:_interacting() or e_movement_state:is_equipping() then
				pantsdownchk = true
			end
		else
			local e_anim_data = focus_enemy.unit:anim_data()

			if not (e_anim_data.move or e_anim_data.idle) or e_anim_data.reload then
				pantsdownchk = true
			end
		end
	end
	
	local can_perform_walking_action = not my_data.turning and not data.unit:movement():chk_action_forbidden("walk") and not my_data.has_old_action
	
	if can_perform_walking_action then
	--what the fuck is my code rn tbh
		if focus_enemy and focus_enemy.nav_tracker and focus_enemy.verified and focus_enemy.dis < 250 and CopLogicAttack._can_move(data) or focus_enemy and focus_enemy.nav_tracker and focus_enemy.dis < 700 and CopLogicAttack._can_move(data) and managers.groupai:state():chk_high_fed_density() or data.tactics and data.tactics.elite_ranged_fire and focus_enemy and focus_enemy.nav_tracker and focus_enemy.verified and focus_enemy.verified_dis <= 1500 and CopLogicAttack._can_move(data) or data.tactics and data.tactics.hitnrun and focus_enemy and focus_enemy.verified and focus_enemy.verified_dis <= 1000 and CopLogicAttack._can_move(data) or data.tactics and data.tactics.spoocavoidance and focus_enemy.verified and focus_enemy.aimed_at or data.tactics and data.tactics.reloadingretreat and focus_enemy and focus_enemy.verified then
			
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

	if action_type == "walk" then
		my_data.advancing = nil

		CopLogicAttack._cancel_cover_pathing(data, my_data)
		CopLogicAttack._cancel_charge(data, my_data)
		CopLogicIdle._update_haste(data, my_data)
		if my_data.has_retreated and managers.groupai:state():chk_active_assault_break() then
			my_data.in_retreat_pos = true
		elseif my_data.surprised then
			my_data.surprised = false
		elseif my_data.moving_to_cover then
			if action:expired() then
				my_data.in_cover = my_data.moving_to_cover
				my_data.cover_enter_t = data.t
			end

			my_data.moving_to_cover = nil
		elseif my_data.walking_to_cover_shoot_pos then
			my_data.walking_to_cover_shoot_pos = nil
			my_data.at_cover_shoot_pos = true
		end
	elseif action_type == "shoot" then
		my_data.shooting = nil
	elseif action_type == "turn" then
		my_data.turning = nil
	elseif action_type == "hurt" then
		CopLogicAttack._cancel_cover_pathing(data, my_data)
		
		--Removed the requirement for being important here.
		if action:expired() and not CopLogicBase.chk_start_action_dodge(data, "hit") then
			data.logic._upd_aim(data, my_data)
		end
	elseif action_type == "dodge" then
		local timeout = action:timeout()

		if timeout then
			data.dodge_timeout_t = TimerManager:game():time() + math.lerp(timeout[1], timeout[2], math.random())
		end

		CopLogicAttack._cancel_cover_pathing(data, my_data)

		if action:expired() then
			CopLogicAttack._upd_aim(data, my_data)
		end
	end
end

function CopLogicAttack.queue_update(data, my_data)
	local focus_enemy = data.attention_obj
	local is_close = focus_enemy and focus_enemy.dis <= 3000 and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction
	local too_far = focus_enemy and focus_enemy.dis > 5000 and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction
	local delay = nil
	if in_close then
		delay = 0
	elseif too_far then
		delay = 0.7
	else
		delay = 0.35
	end
	CopLogicBase.queue_task(my_data, my_data.update_queue_id, data.logic.queued_update, data, data.t + delay)
end

function CopLogicAttack.chk_should_turn(data, my_data)
	return not my_data.turning and not data.unit:movement():chk_action_forbidden("walk") and not my_data.has_old_action and not my_data.moving_to_cover and not my_data.walking_to_cover_shoot_pos
end

function CopLogicAttack._chk_start_action_move_out_of_the_way(data, my_data)
	local my_tracker = data.unit:movement():nav_tracker()
	local reservation = {
		radius = 30,
		position = data.m_pos,
		filter = data.pos_rsrv_id
	}
	local to_pos = nil
	local to_pos_range = nil
	
	if not managers.navigation:is_pos_free(reservation) then
		if data.attention_obj and data.attention_obj.unit and data.attention_obj.verified and data.attention_obj.reaction >= AIAttentionObject.REACT_COMBAT and data.attention_obj.is_person then
			local weapon_unit = data.attention_obj.unit:inventory():equipped_unit()

			if alive(weapon_unit) and weapon_unit:base().is_category and weapon_unit:base():is_category("grenade_launcher") and data.tactics and data.tactics.dangerawarenessGL then
				if data.attention_obj.aimed_at then
					to_pos_range = 1500
				end
			end
		end
		
		if to_pos_range then
			to_pos = CopLogicTravel._get_pos_on_wall(data.m_pos, to_pos_range)
		else
			to_pos = CopLogicTravel._get_pos_on_wall(data.m_pos, 500)
		end
		
		if to_pos then
			local path = {
				my_tracker:position(),
				to_pos
			}

			CopLogicAttack._chk_request_action_walk_to_cover_shoot_pos(data, my_data, path, "run")
		end
	end
end


local temp_vec4 = Vector3()
local temp_vec5 = Vector3()
local temp_vec6 = Vector3()
function CopLogicAttack._update_cover(data)
	local my_data = data.internal_data
	local cover_release_dis_sq = 10000
	local best_cover = my_data.best_cover
	local satisfied = true
	local my_pos = data.m_pos --my position
	
	if data.attention_obj and data.attention_obj.nav_tracker and AIAttentionObject.REACT_COMBAT >= data.attention_obj.reaction then
		local find_new = not my_data.moving_to_cover and not my_data.walking_to_cover_shoot_pos and not my_data.surprised
		local enemyseeninlast2secs = data.attention_obj and data.attention_obj.verified_t and data.t - data.attention_obj.verified_t < 5
		
		if find_new then
			local enemy_tracker = data.attention_obj.nav_tracker
			local threat_pos = enemy_tracker:field_position()
			local heister_pos = data.attention_obj.m_pos --the threat
			
			if data.objective and data.objective.type == "follow" then
				local near_pos = data.objective.follow_unit:movement():m_pos()

				if (not best_cover or not CopLogicAttack._verify_follow_cover(data, best_cover[1], near_pos, threat_pos, 200, 1000)) and not my_data.processing_cover_path and not my_data.charge_path_search_id then
					local follow_unit_area = managers.groupai:state():get_area_from_nav_seg_id(data.objective.follow_unit:movement():nav_tracker():nav_segment())
					local found_cover = managers.navigation:find_cover_in_nav_seg_3(follow_unit_area.nav_segs, data.objective.distance and data.objective.distance * 0.9 or nil, near_pos, threat_pos)

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
			elseif data.objective and data.objective.type == "follow" and data.tactics and data.tactics.shield_cover and not data.unit:base()._tweak_table == "shield" then
				local shield_pos = data.objective.follow_unit:movement():m_pos() --the pillar
				local shield_direction = mvector3.direction(temp_vec4, my_pos, shield_pos)
				local heister_direction = mvector3.direction(temp_vec5, my_pos, heister_pos)
				local following_direction = mvector3.direction(temp_vec6, shield_direction, heister_direction)
				local following_dis = following_direction * 120
				local near_pos = data.objective.follow_unit:movement():m_pos() + following_dis
				
				local notbestcovernotfollowcoverchk = not best_cover or not CopLogicAttack._verify_follow_cover(data, best_cover[1], near_pos, threat_pos, 60, 120)
				
				--unit would take the heister's angle to both the pillar, and the unit, the unit would attempt to line up the pillar and the heister together, since they're following the pillar, they should frequently position themselves behind the pillar, which would keep them in cover, its hacky, but it would work
				
				if notbestcovernotfollowcoverchk and not my_data.processing_cover_path and not my_data.charge_path_search_id then
					local follow_unit_area = managers.groupai:state():get_area_from_nav_seg_id(data.objective.follow_unit:movement():nav_tracker():nav_segment())
					local found_cover = managers.navigation:find_cover_in_nav_seg_3(follow_unit_area.nav_segs, data.objective.distance and data.objective.distance * 0.9 or nil, near_pos, threat_pos)

					if found_cover and data.unit:raycast("ray", data.unit:movement():m_head_pos(), data.attention_obj.m_head_pos, "slot_mask", managers.slot:get_mask("bullet_impact_targets_no_criminals"), "ignore_unit", data.attention_obj.unit, "report") then
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
			else
				local want_to_take_cover = my_data.want_to_take_cover
				local flank_cover = my_data.flank_cover
				local min_dis, max_dis = nil

				if want_to_take_cover or my_data.shooting then
					if data.tactics and not data.tactics.ranged_fire and not data.tactics.elite_ranged_fire or not enemyseeninlast2secs then
						min_dis = 250
					else
						min_dis = math.max(data.attention_obj.dis * 0.9, data.attention_obj.dis - 200)
					end
				end
				
				local notbc_or_fc_or_notvc_chk = not best_cover or flank_cover or not CopLogicAttack._verify_cover(data, best_cover[1], threat_pos, min_dis, max_dis)
				
				if not my_data.processing_cover_path and not my_data.charge_path_search_id and notbc_or_fc_or_notvc_chk then
					satisfied = false
					local my_vec = my_pos - threat_pos

					if flank_cover then
						mvector3.rotate_with(my_vec, Rotation(flank_cover.angle))
					end

					local optimal_dis = my_vec:length()
					local max_dis = nil

					if want_to_take_cover or my_data.shooting then
						if data.tactics and (data.tactics.ranged_fire or data.tactics.elite_ranged_fire) then
							if not enemyseeninlast2secs then
								optimal_dis = min_dis
							elseif optimal_dis < my_data.weapon_range.optimal then
								optimal_dis = optimal_dis

								mvector3.set_length(my_vec, optimal_dis)
							else
								optimal_dis = my_data.weapon_range.optimal

								mvector3.set_length(my_vec, optimal_dis)
							end
						else
							if not enemyseeninlast2secs then
								optimal_dis = min_dis
							elseif optimal_dis < my_data.weapon_range.close then
								optimal_dis = optimal_dis

								mvector3.set_length(my_vec, optimal_dis)
							else
								optimal_dis = my_data.weapon_range.close

								mvector3.set_length(my_vec, optimal_dis)
							end
						end
						
						if data.tactics and not data.tactics.ranged_fire and not data.tactics.elite_ranged_fire then
							max_dis = math.max(optimal_dis + 200, my_data.weapon_range.far * 0.5)
						else							
							max_dis = math.max(optimal_dis + 200, my_data.weapon_range.far)
						end
						
					elseif data.tactics and not data.tactics.ranged_fire and not data.tactics.elite_ranged_fire and optimal_dis > my_data.weapon_range.close then
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

					local min_threat_dis, cone_angle = nil

					if flank_cover then
						cone_angle = flank_cover.step
					else
						cone_angle = math.lerp(90, 60, math.min(1, optimal_dis / 3000))
					end

					local search_nav_seg = nil

					if data.objective and data.objective.type == "defend_area" then
						search_nav_seg = data.objective.area and data.objective.area.nav_segs or data.objective.nav_seg
					end

					local found_cover = managers.navigation:find_cover_in_cone_from_threat_pos_1(threat_pos, furthest_side_pos, my_side_pos, nil, cone_angle, min_threat_dis, search_nav_seg, optimal_dis, data.pos_rsrv_id)
					
					local notbcorvc_chk = nil
					
					if found_cover then
						notbcorvc_chk = not best_cover or CopLogicAttack._verify_cover(data, found_cover, threat_pos, min_dis, max_dis)
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

		if in_cover and enemyseeninlast2secs then
			local threat_pos = data.attention_obj.verified_pos
			in_cover[3], in_cover[4] = CopLogicAttack._chk_covered(data, my_pos, threat_pos, data.visibility_slotmask)
		end
	elseif best_cover and cover_release_dis_sq < mvector3.distance_sq(best_cover[1][1], my_pos) then
		CopLogicAttack._set_best_cover(data, my_data, nil)
	end
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
	
	if data.is_converted or data.unit:in_slot(16) or data.unit:base()._tweak_table == "sniper" then
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
	
	local gamemode_chk = game_state_machine:gamemode() 
	if gamemode_chk == "crime_spree" then
		if managers.crime_spree then
			local copturnspdadd = managers.crime_spree:get_turn_spd_add()
			speed = speed + copturnspdadd
		end
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
	local threat_dis = mvector3.direction(temp_vec1, cover[1], threat_pos)
	
	if max_dis and max_dis < threat_dis or min_dis and threat_dis < min_dis then
		return
	end

	local cover_dot = mvector3.dot(temp_vec1, cover[2])

	if cover_dot < 0.67 then
		return
	end

	return true
end

function CopLogicAttack._verify_follow_cover(data, cover, near_pos, threat_pos, min_dis, max_dis)
	if CopLogicAttack._verify_cover(data, cover, threat_pos, min_dis, max_dis) and mvector3.distance(near_pos, cover[1]) < 300 then
		return true
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

	if low_ray then
		mvector3.set_z(ray_from, ray_from.z + 60)
		mvector3.step(ray_to_pos, ray_from, threat_pos, 300)

		high_ray = World:raycast("ray", ray_from, ray_to_pos, "slot_mask", slotmask)
	end

	return low_ray, high_ray
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

	local att_obj = data.attention_obj

	if not att_obj or att_obj.reaction < AIAttentionObject.REACT_AIM then
		return true
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