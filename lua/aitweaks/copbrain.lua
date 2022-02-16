require("lib/units/enemies/cop/logics/CopLogicBase")
require("lib/units/enemies/cop/logics/CopLogicInactive")
require("lib/units/enemies/cop/logics/CopLogicIdle")
require("lib/units/enemies/cop/logics/CopLogicAttack")
require("lib/units/enemies/cop/logics/CopLogicIntimidated")
require("lib/units/enemies/cop/logics/CopLogicTravel")
require("lib/units/enemies/cop/logics/CopLogicArrest")
require("lib/units/enemies/cop/logics/CopLogicGuard")
require("lib/units/enemies/cop/logics/CopLogicFlee")
require("lib/units/enemies/cop/logics/CopLogicSniper")
require("lib/units/enemies/cop/logics/CopLogicTrade")
require("lib/units/enemies/cop/logics/CopLogicPhalanxMinion")
require("lib/units/enemies/cop/logics/CopLogicPhalanxVip")
require("lib/units/enemies/tank/logics/TankCopLogicAttack")
require("lib/units/enemies/shield/logics/ShieldLogicAttack")
require("lib/units/enemies/spooc/logics/SpoocLogicIdle")
require("lib/units/enemies/spooc/logics/SpoocLogicAttack")
require("lib/units/enemies/taser/logics/TaserLogicAttack")
local old_init = CopBrain.post_init
local logic_variants = {
	security = {
		idle = CopLogicIdle,
		attack = CopLogicAttack,
		travel = CopLogicTravel,
		inactive = CopLogicInactive,
		intimidated = CopLogicIntimidated,
		arrest = CopLogicArrest,
		guard = CopLogicGuard,
		flee = CopLogicFlee,
		sniper = CopLogicSniper,
		trade = CopLogicTrade,
		phalanx = CopLogicPhalanxMinion
	}
}
local security_variant = logic_variants.security
function CopBrain:post_init()
	CopBrain._logic_variants.trolliam_epicson = clone(security_variant)	
	CopBrain._logic_variants.trolliam_epicson.idle = SpoocLogicIdle	
	CopBrain._logic_variants.trolliam_epicson.attack = SpoocLogicAttack
	CopBrain._logic_variants.tank_ftsu = clone(security_variant)
	CopBrain._logic_variants.tank_ftsu.attack = TankCopLogicAttack	
	CopBrain._logic_variants.spooc_heavy = clone(security_variant)
	CopBrain._logic_variants.spooc_heavy.idle = SpoocLogicIdle
	CopBrain._logic_variants.spooc_heavy.attack = SpoocLogicAttack
	-- CopBrain._logic_variants.spooc_heavy.travel = SpoocLogicTravel
	CopBrain._logic_variants.taser = clone(security_variant)
	CopBrain._logic_variants.shadow_taser = clone(security_variant)
	CopBrain._logic_variants.spooc = clone(security_variant)
	CopBrain._logic_variants.spooc.attack = SpoocLogicAttack
	CopBrain._logic_variants.spooc.idle = SpoocLogicIdle
	CopBrain._logic_variants.medic = clone(security_variant)
	CopBrain._logic_variants.medic.attack = MedicLogicAttack
	CopBrain._logic_variants.shadow_swat = clone(security_variant)
	CopBrain._logic_variants.fbi_xc45 = clone(security_variant)
	CopBrain._logic_variants.fbi_pager = clone(security_variant)
	CopBrain._logic_variants.gangster_ninja = clone(security_variant)
	CopBrain._logic_variants.armored_swat = clone(security_variant)
	CopBrain._logic_variants.cop_moss = clone(security_variant)
	CopBrain._logic_variants.armored_sniper = clone(security_variant)	
	CopBrain._logic_variants.shield = clone(security_variant)
	CopBrain._logic_variants.shield.attack = ShieldLogicAttack
	CopBrain._logic_variants.akuma = clone(security_variant)
	CopBrain._logic_variants.akuma.attack = CopLogicAttack
	
	
	old_init(self)
end

CopBrain._NET_EVENTS = {
	stopped_seeing_client_peaceful = 11,
	detected_client_peaceful_verified = 10,
	detected_client_peaceful = 9,
	client_no_longer_verified = 8,
	detected_suspected_client = 7,
	stopped_suspecting_client = 6,
	suspecting_client_verified = 5,
	suspecting_client = 4,
	detected_client = 3,
	stopped_seeing_client = 2,
	seeing_client = 1
}

local mvec3_set = mvector3.set

function CopBrain:sync_net_event(event_id, peer)
	local peer_id = peer:id()
	local peer_unit = managers.criminals:character_unit_by_peer_id(peer_id)

	if not peer_unit then
		return
	end

	if event_id == self._NET_EVENTS.seeing_client then
		managers.groupai:state():on_criminal_suspicion_progress(peer_unit, self._unit, 1, peer_id)
	elseif event_id == self._NET_EVENTS.stopped_seeing_client then
		managers.groupai:state():on_criminal_suspicion_progress(peer_unit, self._unit, false, peer_id)
	elseif event_id == self._NET_EVENTS.detected_client then
		managers.groupai:state():on_criminal_suspicion_progress(peer_unit, self._unit, true, peer_id)

		self._unit:movement():set_cool(false, managers.groupai:state().analyse_giveaway(self._unit:base()._tweak_table, peer_unit))

		local att_obj_data = CopLogicBase.identify_attention_obj_instant(self._logic_data, peer_unit:key())

		if att_obj_data and att_obj_data.criminal_record then
			managers.groupai:state():criminal_spotted(peer_unit)
		end
	elseif event_id == self._NET_EVENTS.detected_client_peaceful or event_id == self._NET_EVENTS.detected_client_peaceful_verified then
		local t = self._logic_data.t
		local att_u_key = peer_unit:key()
		local att_obj_data = self._logic_data.detected_attention_objects[att_u_key]

		if att_obj_data then
			if not att_obj_data.client_peaceful_detection then
				mvec3_set(att_obj_data.verified_pos, att_obj_data.m_head_pos)

				att_obj_data.verified_dis = mvector3.distance(self._unit:movement():m_head_pos(), att_obj_data.m_head_pos)

				if not att_obj_data.identified then
					att_obj_data.identified = true
					att_obj_data.identified_t = t
					att_obj_data.notice_progress = nil
					att_obj_data.prev_notice_chk_t = nil
				elseif att_obj_data.uncover_progress then
					att_obj_data.uncover_progress = nil
				end
			end
		else
			local attention_info = managers.groupai:state():get_AI_attention_objects_by_filter(self._logic_data.SO_access_str)[att_u_key]

			if attention_info then
				local settings = attention_info.handler:get_attention(self._logic_data.SO_access, nil, nil, self._logic_data.team)

				if settings then
					att_obj_data = CopLogicBase._create_detected_attention_object_data(t, self._unit, att_u_key, attention_info, settings)
					att_obj_data.identified = true
					att_obj_data.identified_t = t
					att_obj_data.notice_progress = nil
					att_obj_data.prev_notice_chk_t = nil

					self._logic_data.detected_attention_objects[att_u_key] = att_obj_data
				end
			end
		end

		if att_obj_data then
			att_obj_data.client_peaceful_detection = true

			if event_id == self._NET_EVENTS.detected_client_peaceful_verified then
				att_obj_data.verified = true
			end
		end
	elseif event_id == self._NET_EVENTS.suspecting_client or event_id == self._NET_EVENTS.suspecting_client_verified then
		local t = self._logic_data.t
		local att_u_key = peer_unit:key()
		local att_obj_data = self._logic_data.detected_attention_objects[att_u_key]

		if att_obj_data then
			if not att_obj_data.client_casing_suspicion then
				mvec3_set(att_obj_data.verified_pos, att_obj_data.m_head_pos)

				att_obj_data.verified_dis = mvector3.distance(self._unit:movement():m_head_pos(), att_obj_data.m_head_pos)

				if not att_obj_data.identified then
					att_obj_data.identified = true
					att_obj_data.identified_t = t
					att_obj_data.notice_progress = nil
					att_obj_data.prev_notice_chk_t = nil
				elseif att_obj_data.uncover_progress then
					att_obj_data.uncover_progress = nil
				end
			end
		else
			local attention_info = managers.groupai:state():get_AI_attention_objects_by_filter(self._logic_data.SO_access_str)[att_u_key]

			if attention_info then
				local settings = attention_info.handler:get_attention(self._logic_data.SO_access, nil, nil, self._logic_data.team)

				if settings then
					att_obj_data = CopLogicBase._create_detected_attention_object_data(t, self._unit, att_u_key, attention_info, settings)
					att_obj_data.identified = true
					att_obj_data.identified_t = t
					att_obj_data.notice_progress = nil
					att_obj_data.prev_notice_chk_t = nil

					self._logic_data.detected_attention_objects[att_u_key] = att_obj_data
				end
			end
		end

		if att_obj_data then
			if not att_obj_data.client_casing_suspicion then
				att_obj_data.client_casing_suspicion = true

				managers.groupai:state():on_criminal_suspicion_progress(peer_unit, self._unit, 1, peer_id)
			end

			if event_id == self._NET_EVENTS.suspecting_client_verified then
				att_obj_data.verified = true
			end
		end
	elseif event_id == self._NET_EVENTS.client_no_longer_verified then
		local att_obj_data = self._logic_data.detected_attention_objects[peer_unit:key()]

		if att_obj_data then
			att_obj_data.verified = nil
		end
	elseif event_id == self._NET_EVENTS.stopped_suspecting_client or event_id == self._NET_EVENTS.stopped_seeing_client_peaceful then
		if event_id == self._NET_EVENTS.stopped_suspecting_client then
			managers.groupai:state():on_criminal_suspicion_progress(peer_unit, self._unit, false, peer_id)
		end

		local att_obj_data = self._logic_data.detected_attention_objects[peer_unit:key()]

		if att_obj_data then
			att_obj_data.handler:remove_listener("detect_" .. tostring(self._logic_data.key))

			self._logic_data.detected_attention_objects[peer_unit:key()] = nil
		end
	elseif event_id == self._NET_EVENTS.detected_suspected_client then
		managers.groupai:state():on_criminal_suspicion_progress(peer_unit, self._unit, true, peer_id)

		local att_obj_data = self._logic_data.detected_attention_objects[peer_unit:key()]

		if att_obj_data then
			att_obj_data.client_casing_suspicion = nil
			att_obj_data.client_casing_detected = true
		end
	end
end

function CopBrain:on_suppressed(state)
    self._logic_data.is_suppressed = state or nil
	
	--local supp_complain_t_chk = not self._next_supyell_t or self._next_supyell_t < TimerManager:game():time()
	
    if self._current_logic.on_suppressed_state and not self._logic_data.is_converted then
        self._current_logic.on_suppressed_state(self._logic_data)

        --if self._logic_data.char_tweak.chatter.suppress and supp_complain_t_chk then
		--    local roll = math.random(1, 100)
		--	local chance_heeeeelpp = 60
			
		--	if roll < chance_heeeeelpp then
        --        self._unit:sound():say("hlp", true)
		--	else --hopefully some variety here now
        --         self._unit:sound():say("lk3b", true) 
		--	end
		--	self._next_supyell_t = TimerManager:game():time() + 4  
	end
end

function CopBrain:is_converted_chk()
	if self._logic_data.is_converted then
		return true
	end
end

function CopBrain:is_available_for_assignment(objective)
	return self._current_logic.is_available_for_assignment(self._logic_data, objective)
end

function CopBrain:_reset_logic_data()
	self._logic_data = {
		unit = self._unit,
		brain = self,
		brain_updating = false,
		active_searches = {},
		m_pos = self._unit:movement():m_pos(),
		char_tweak = tweak_data.character[self._unit:base()._tweak_table],
		key = self._unit:key(),
		pos_rsrv = {},
		pos_rsrv_id = self._unit:movement():pos_rsrv_id(),
		SO_access = self._SO_access,
		SO_access_str = tweak_data.character[self._unit:base()._tweak_table].access,
		detected_attention_objects = {},
		attention_handler = self._attention_handler,
		visibility_slotmask = managers.slot:get_mask("AI_visibility"),
		enemy_slotmask = self._slotmask_enemies,
		cool = self._unit:movement():cool(),
		objective_complete_clbk = callback(managers.groupai:state(), managers.groupai:state(), "on_objective_complete"),
		objective_failed_clbk = callback(managers.groupai:state(), managers.groupai:state(), "on_objective_failed")
	}
	
	if self._logic_data.char_tweak.buddy then
		self._logic_data.buddypalchum = true
		
		local level = Global.level_data and Global.level_data.level_id
		
		if tweak_data.levels[level].trigger_follower_behavior_element == nil then
			--log("uuuh")
			self._logic_data.check_crim_jobless = true
		end
	end
end

function CopBrain:set_update_enabled_state(state)
	self._unit:set_extension_update_enabled(Idstring("brain"), state)
	
	if self._logic_data then
		self._logic_data.brain_updating = state
	end
end

function CopBrain:set_objective(new_objective, params)
	local old_objective = self._logic_data.objective
	
	if new_objective and self._logic_data.buddypalchum then
		local level = Global.level_data and Global.level_data.level_id

		if new_objective.element then
			if tweak_data.levels[level] and tweak_data.levels[level].ignored_so_elements and tweak_data.levels[level].ignored_so_elements[new_objective.element._id] then
				if new_objective.complete_clbk then
					new_objective.complete_clbk(self._unit, self._logic_data)
				end
				
				if new_objective.action_start_clbk then
					new_objective.action_start_clbk(self._unit)
				end
				
				return
			end
		end
		
		if tweak_data.levels[level].trigger_follower_behavior_element and new_objective.element and tweak_data.levels[level].trigger_follower_behavior_element[new_objective.element._id] then
			self._logic_data.check_crim_jobless = true
		end
		
		--managers.groupai:state():print_objective(new_objective)

		if new_objective.stance == "ntl" then
			new_objective.stance = nil
		end
	end
	
	self._logic_data.objective = new_objective

	if new_objective and new_objective.followup_objective and new_objective.followup_objective.interaction_voice then
		self._unit:network():send("set_interaction_voice", new_objective.followup_objective.interaction_voice)
	elseif old_objective and old_objective.followup_objective and old_objective.followup_objective.interaction_voice then
		self._unit:network():send("set_interaction_voice", "")
	end

	self._current_logic.on_new_objective(self._logic_data, old_objective, params)
end

function CopBrain:convert_to_criminal(mastermind_criminal)
	if self._alert_listen_key then
		managers.groupai:state():remove_alert_listener(self._alert_listen_key)
	else
		self._alert_listen_key = "CopBrain" .. tostring(self._unit:key())
	end

	local alert_listen_filter = managers.groupai:state():get_unit_type_filter("combatant")
	local alert_types = {
		explosion = true,
		fire = true,
		aggression = true,
		bullet = true
	}

	managers.groupai:state():add_alert_listener(self._alert_listen_key, callback(self, self, "on_alert"), alert_listen_filter, alert_types, self._unit:movement():m_head_pos())

	self._logic_data.is_converted = true
	self._logic_data.group = nil

	if self._logic_data.internal_data and self._logic_data.internal_data.coarse_path then
		self._logic_data.internal_data.coarse_path = nil
	end

	local mover_col_body = self._unit:body("mover_blocker")

	mover_col_body:set_enabled(false)

	local attention_preset = PlayerMovement._create_attention_setting_from_descriptor(self, tweak_data.attention.settings.team_enemy_cbt, "team_enemy_cbt")

	self._attention_handler:override_attention("enemy_team_cbt", attention_preset)

	local health_multiplier = 1
	local damage_multiplier = 1

	if alive(mastermind_criminal) then
		local base_ext = mastermind_criminal:base()

		health_multiplier = health_multiplier * (base_ext:upgrade_value("player", "convert_enemies_health_multiplier") or 1)
		health_multiplier = health_multiplier * (base_ext:upgrade_value("player", "passive_convert_enemies_health_multiplier") or 1)
		damage_multiplier = damage_multiplier * (base_ext:upgrade_value("player", "convert_enemies_damage_multiplier") or 1)
		damage_multiplier = damage_multiplier * (base_ext:upgrade_value("player", "passive_convert_enemies_damage_multiplier") or 1)
	else
		local player_manager = managers.player

		health_multiplier = health_multiplier * player_manager:upgrade_value("player", "convert_enemies_health_multiplier", 1)
		health_multiplier = health_multiplier * player_manager:upgrade_value("player", "passive_convert_enemies_health_multiplier", 1)
		damage_multiplier = damage_multiplier * player_manager:upgrade_value("player", "convert_enemies_damage_multiplier", 1)
		damage_multiplier = damage_multiplier * player_manager:upgrade_value("player", "passive_convert_enemies_damage_multiplier", 1)
	end

	self._unit:character_damage():convert_to_criminal(health_multiplier)

	self._logic_data.attention_obj = nil

	CopLogicBase._destroy_all_detected_attention_object_data(self._logic_data)

	local team_ai_so_access = tweak_data.character.russian.access

	self._SO_access = managers.navigation:convert_access_flag(team_ai_so_access)
	self._logic_data.SO_access = self._SO_access
	self._logic_data.SO_access_str = team_ai_so_access
	self._slotmask_enemies = managers.slot:get_mask("enemies")
	self._logic_data.enemy_slotmask = self._slotmask_enemies

	local char_tweaks = deep_clone(self._unit:base()._char_tweak)
	
	if self._unit:base():has_tag("fbi") then
		char_tweaks.weapon = tweak_data.character.presets.weapon.fbigod
	else
		char_tweaks.weapon = tweak_data.character.presets.weapon.anarchy
	end
	
	char_tweaks.suppression = nil
	char_tweaks.crouch_move = false
	char_tweaks.allowed_poses = {stand = true}
	char_tweaks.move_speed = tweak_data.character.presets.move_speed.teamai
	char_tweaks.access = team_ai_so_access
	char_tweaks.no_run_start = true
	char_tweaks.no_run_stop = true

	self._logic_data.char_tweak = char_tweaks
	self._unit:base()._char_tweak = char_tweaks
	self._unit:character_damage()._char_tweak = char_tweaks
	self._unit:movement()._tweak_data = char_tweaks
	self._unit:movement()._action_common_data.char_tweak = char_tweaks

	local equipped_w_selection = self._unit:inventory():equipped_selection()

	if equipped_w_selection then
		self._unit:inventory():remove_selection(equipped_w_selection, true)
	end

	local weap_name = self._unit:base():default_weapon_name()

	TeamAIInventory.add_unit_by_name(self._unit:inventory(), weap_name, true)

	local weapon_unit = self._unit:inventory():equipped_unit()

	weapon_unit:base():add_damage_multiplier(damage_multiplier)
	self._logic_data.objective_complete_clbk = callback(managers.groupai:state(), managers.groupai:state(), "on_criminal_objective_complete")
	self._logic_data.objective_failed_clbk = callback(managers.groupai:state(), managers.groupai:state(), "on_criminal_objective_failed")
	local objective = managers.groupai:state():_determine_objective_for_criminal_AI(self._unit)
	self:set_objective(objective)
	self:set_logic("idle", nil)
	
	self._unit:base():set_slot(self._unit, 16)
	self._unit:movement():set_stance("hos")

	local action_data = {
		variant = "stand",
		body_part = 1,
		type = "act"
	}

	self._unit:brain():action_request(action_data)
	--self._unit:sound():say("cn1", true, nil)
	managers.network:session():send_to_peers_synched("sync_unit_converted", self._unit)
end

function CopBrain:begin_alarm_pager(reset)
	if not reset and self._alarm_pager_has_run then
		return
	end

	self._alarm_pager_has_run = true
	self._alarm_pager_data = {
		total_nr_calls = math.random(tweak_data.player.alarm_pager.nr_of_calls[1], tweak_data.player.alarm_pager.nr_of_calls[2]),
		nr_calls_made = 0
	}
	self._alarm_pager_data.pager_clbk_id = "pager" .. tostring(self._unit:key())

	managers.enemy:add_delayed_clbk(self._alarm_pager_data.pager_clbk_id, callback(self, self, "clbk_alarm_pager"), TimerManager:game():time() + 5)
end

function CopBrain:end_alarm_pager()
	if not self._alarm_pager_data then
		return
	end

	if self._alarm_pager_data.pager_clbk_id then
		self._unit:interaction():set_outline_flash_state(nil, true)
		managers.enemy:remove_delayed_clbk(self._alarm_pager_data.pager_clbk_id)
	end

	self._alarm_pager_data = nil
	
	if not self:_chk_enable_bodybag_interaction() then
		self._unit:interaction():set_active(false, true)
	end
end

function CopBrain:set_can_do_alarm_pager(state)
	if managers.groupai:state():whisper_mode() then
		self._can_do_alarm_pager = state
		
		if not managers.groupai:state()._stealth_has_begun then
			managers.groupai:state():begin_HH_stealth()
		end
	end
end

local next_g = next
local pairs_g = pairs
local type_g = type

local on_nav_link_unregistered_original = CopBrain.on_nav_link_unregistered
function CopBrain:on_nav_link_unregistered(element_id)
	on_nav_link_unregistered_original(self, element_id)

	if next_g(self._logic_data.active_searches) then
		for search_id, search_type in pairs_g(self._logic_data.active_searches) do
			if search_type ~= 2 then
				self._nav_links_to_check = self._nav_links_to_check or {}
				self._nav_links_to_check[search_id] = element_id
			end
		end
	end
end

function CopBrain:clbk_pathing_results(search_id, path)
	local dead_nav_links = self._nav_links_to_check

	if dead_nav_links then
		if path then
			local element_id = dead_nav_links[search_id]

			if element_id then
				for i = 1, #path do
					local nav_point = path[i]

					if not nav_point.x and nav_point:script_data().element._id == element_id then
						path = nil

						break
					end
				end
			end

			dead_nav_links[search_id] = nil

			if not next_g(dead_nav_links) then
				dead_nav_links = nil
			end
		elseif dead_nav_links[search_id] then
			dead_nav_links[search_id] = nil

			if not next_g(dead_nav_links) then
				dead_nav_links = nil
			end
		end

		self._nav_links_to_check = dead_nav_links
	end

	self:_add_pathing_result(search_id, path)
end

function CopBrain:abort_detailed_pathing(search_id)
	if not self._logic_data.active_searches[search_id] then
		return
	end

	self._logic_data.active_searches[search_id] = nil

	managers.navigation:cancel_pathing_search(search_id)

	local dead_nav_links = self._nav_links_to_check

	if dead_nav_links and dead_nav_links[search_id] then
		dead_nav_links[search_id] = nil

		if not next_g(dead_nav_links) then
			dead_nav_links = nil
		end

		self._nav_links_to_check = dead_nav_links
	end
end

function CopBrain:cancel_all_pathing_searches()
	local dead_nav_links = self._nav_links_to_check
	local contains_dead_nav_link = {}

	for search_id, search_type in pairs_g(self._logic_data.active_searches) do
		if search_type == 2 then
			managers.navigation:cancel_coarse_search(search_id)
		else
			managers.navigation:cancel_pathing_search(search_id)

			if dead_nav_links and dead_nav_links[search_id] then
				contains_dead_nav_link[search_id] = true
				dead_nav_links[search_id] = nil
			end
		end
	end

	if dead_nav_links and not next_g(dead_nav_links) then
		self._nav_links_to_check = nil
	end
	
	local path_results = self._logic_data.pathing_results

	if path_results and next_g(path_results) then
		for search_id, path in pairs_g(path_results) do
			if path ~= "failed" and not contains_dead_nav_link[search_id] and type_g(path[1]) ~= "table" then
				for i = 1, #path do
					local nav_point = path[i]

					if not nav_point.x and nav_point:script_data().element:nav_link_delay() then
						nav_point:set_delay_time(0)
					end
				end
			end
		end
	end
	
	self._logic_data.active_searches = {}
	self._logic_data.pathing_results = nil
end

function CopBrain:search_for_coarse_path(search_id, to_seg, verify_clbk, access_neg)
	local params = {
		from_tracker = self._unit:movement():nav_tracker(),
		to_seg = to_seg,
		access = {
			"walk"
		},
		id = search_id,
		long_path = not self._logic_data.is_converted and self._logic_data.tactics and self._logic_data.tactics.flank,
		results_clbk = callback(self, self, "clbk_coarse_pathing_results", search_id),
		verify_clbk = verify_clbk,
		access_pos = self._logic_data.char_tweak.access,
		access_neg = access_neg
	}
	self._logic_data.active_searches[search_id] = 2

	managers.navigation:search_coarse(params)

	return true
end

--Stealth stuff.

function CopBrain:_chk_enable_bodybag_interaction()
	if self:is_pager_started() then
		return
	end

	if not self._unit:character_damage():dead() then
		return
	end

	self._unit:interaction():set_tweak_data("corpse_dispose")
	self._unit:interaction():set_active(true, true)

	return true
end

function CopBrain:clbk_alarm_pager(ignore_this, data)
	local pager_data = self._alarm_pager_data
	local clbk_id = pager_data.pager_clbk_id
	pager_data.pager_clbk_id = nil

	if not managers.groupai:state():whisper_mode() then
		self:end_alarm_pager()

		return
	end

	if pager_data.nr_calls_made == 0 then
		if managers.groupai:state():is_ecm_jammer_active("pager") then
			self:end_alarm_pager()
			self:begin_alarm_pager(true)

			return
		end

		self._unit:sound():stop()

		if self._unit:character_damage():dead() then
			self._unit:sound():corpse_play(self:_get_radio_id("dsp_radio_query_1"), nil, true)
		else
			self._unit:sound():play(self:_get_radio_id("dsp_radio_query_1"), nil, true)
		end

		self._unit:interaction():set_tweak_data("corpse_alarm_pager")
		self._unit:interaction():set_active(true, true)
	elseif pager_data.nr_calls_made < pager_data.total_nr_calls then
		self._unit:sound():stop()

		if self._unit:character_damage():dead() then
			self._unit:sound():corpse_play(self:_get_radio_id("dsp_radio_reminder_1"), nil, true)
		else
			self._unit:sound():play(self:_get_radio_id("dsp_radio_reminder_1"), nil, true)
		end
	elseif pager_data.nr_calls_made == pager_data.total_nr_calls then
		self._unit:interaction():set_active(false, true)
		managers.groupai:state():register_strike("unanswered")
		self._unit:sound():stop()

		self:end_alarm_pager()
	end

	if pager_data.nr_calls_made == pager_data.total_nr_calls - 1 then
		self._unit:interaction():set_outline_flash_state(true, true)
	end

	pager_data.nr_calls_made = pager_data.nr_calls_made + 1

	if pager_data.nr_calls_made <= pager_data.total_nr_calls then
		self._alarm_pager_data.pager_clbk_id = clbk_id

		managers.enemy:add_delayed_clbk(self._alarm_pager_data.pager_clbk_id, callback(self, self, "clbk_alarm_pager"), TimerManager:game():time() + 10)
	end
end

function CopBrain:on_alarm_pager_interaction(status, player)
	if not managers.groupai:state():whisper_mode() then
		return
	end

	local is_dead = self._unit:character_damage():dead()
	local pager_data = self._alarm_pager_data

	if not pager_data then
		--log("penis")
		return
	end
	
	--log(tostring(status))

	if status == "started" then
		self._unit:sound():stop()
		self._unit:interaction():set_outline_flash_state(nil, true)

		if pager_data.pager_clbk_id then
			managers.enemy:remove_delayed_clbk(pager_data.pager_clbk_id)

			pager_data.pager_clbk_id = nil
		end
	elseif status == "complete" then
		local nr_previous_bluffs = 1
		
		self._unit:sound():stop()
		managers.groupai:state():on_successful_alarm_pager_bluff()

		if is_dead then
			self._unit:sound():corpse_play(self:_get_radio_id("dsp_radio_fooled_" .. tostring(nr_previous_bluffs)), nil, true)
		else
			self._unit:sound():play(self:_get_radio_id("dsp_radio_fooled_" .. tostring(nr_previous_bluffs)), nil, true)
		end

		self:end_alarm_pager()
		managers.mission:call_global_event("player_answer_pager")
	elseif status == "interrupted" then
		managers.groupai:state():register_strike("hung_up")
		self._unit:sound():stop()

		if is_dead then
			self._unit:sound():corpse_play(self:_get_radio_id("dsp_radio_reminder_1"), nil, true)
		else
			self._unit:sound():play(self:_get_radio_id("dsp_radio_reminder_1"), nil, true)
		end
		
		self:end_alarm_pager()
	end
end

function CopBrain:on_intimidated(amount, aggressor_unit)
	local interaction_voice = self:interaction_voice()

	if interaction_voice then
		self:set_objective(self._logic_data.objective.followup_objective)

		return interaction_voice
	else
		local diff_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)
		
		
		if diff_index < 6 then
			amount = amount * 80
		elseif diff_index < 8 then
			amount = amount * 70
		else
			amount = amount * 50
		end
	
		self._current_logic.on_intimidated(self._logic_data, amount, aggressor_unit)
	end
end
