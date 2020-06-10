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
	CopBrain._logic_variants.tank.attack = CopLogicAttack
	CopBrain._logic_variants.tank_medic.attack = CopLogicAttack
	CopBrain._logic_variants.tank_mini.attack = CopLogicAttack
	CopBrain._logic_variants.spooc_heavy = clone(security_variant)
	CopBrain._logic_variants.spooc_heavy.idle = SpoocLogicIdle
	CopBrain._logic_variants.spooc_heavy.attack = SpoocLogicAttack
	-- CopBrain._logic_variants.spooc_heavy.travel = SpoocLogicTravel
	CopBrain._logic_variants.spooc = clone(security_variant)
	CopBrain._logic_variants.spooc.attack = SpoocLogicAttack
	CopBrain._logic_variants.spooc.idle = SpoocLogicIdle		
	-- CopBrain._logic_variants.spooc.travel = SpoocLogicTravel
	--CopBrain._logic_variants.taser.travel = TaserLogicTravel
	CopBrain._logic_variants.fbi_xc45 = clone(security_variant)
	CopBrain._logic_variants.fbi_pager = clone(security_variant)
	CopBrain._logic_variants.gangster_ninja = clone(security_variant)
	CopBrain._logic_variants.armored_swat = clone(security_variant)
	CopBrain._logic_variants.shield = clone(security_variant)
	CopBrain._logic_variants.shield.attack = CopLogicAttack
	CopBrain._logic_variants.akuma = clone(security_variant)
	CopBrain._logic_variants.akuma.attack = CopLogicAttack
	
	
	old_init(self)
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

function CopBrain:clbk_pathing_results(search_id, path)
    self:_add_pathing_result(search_id, path)
end

function CopBrain:search_for_path_to_unit(search_id, other_unit, access_neg)
	local enemy_tracker = other_unit:movement():nav_tracker()
	local pos_to = enemy_tracker:field_position()
	local params = {
		tracker_from = self._unit:movement():nav_tracker(),
		pos_to = pos_to,
		tracker_to = enemy_tracker,
		result_clbk = callback(self, self, "clbk_pathing_results", search_id),
		id = search_id,
		access_pos = self._SO_access,
		access_neg = access_neg
	}
	self._logic_data.active_searches[search_id] = true

	managers.navigation:search_pos_to_pos(params)

	return true
end

function CopBrain:search_for_path_to_cover(search_id, cover, offset_pos, access_neg)
	local params = {
		tracker_from = self._unit:movement():nav_tracker(),
		tracker_to = cover[3],
		result_clbk = callback(self, self, "clbk_pathing_results", search_id),
		id = search_id,
		access_pos = self._SO_access,
		access_neg = access_neg
	}
	self._logic_data.active_searches[search_id] = true

	managers.navigation:search_pos_to_pos(params)

	return true
end

function CopBrain:search_for_coarse_path(search_id, to_seg, verify_clbk, access_neg)
	local params = {
		from_tracker = self._unit:movement():nav_tracker(),
		to_seg = to_seg,
		access = {
			"walk"
		},
		id = search_id,
		results_clbk = callback(self, self, "clbk_coarse_pathing_results", search_id),
		verify_clbk = verify_clbk,
		access_pos = self._logic_data.char_tweak.access,
		access_neg = access_neg
	}
	self._logic_data.active_searches[search_id] = 2

	managers.navigation:search_coarse(params)

	return true
end

function CopBrain:on_alarm_pager_interaction(status, player)
	if not managers.groupai:state():whisper_mode() then
		return
	end

	local is_dead = self._unit:character_damage():dead()
	local pager_data = self._alarm_pager_data

	if not pager_data then
		return
	end

	if status == "started" then
		self._unit:sound():stop()
		self._unit:interaction():set_outline_flash_state(nil, true)

		if pager_data.pager_clbk_id then
			managers.enemy:remove_delayed_clbk(pager_data.pager_clbk_id)

			pager_data.pager_clbk_id = nil
		end
	elseif status == "complete" then
		local nr_previous_bluffs = managers.groupai:state():get_nr_successful_alarm_pager_bluffs()
		local has_upgrade = nil

		if player:base().is_local_player then
			has_upgrade = managers.player:has_category_upgrade("player", "corpse_alarm_pager_bluff")
		else
			has_upgrade = player:base():upgrade_value("player", "corpse_alarm_pager_bluff")
		end

		local chance_table = tweak_data.player.alarm_pager[has_upgrade and "bluff_success_chance_w_skill" or "bluff_success_chance"]
		local chance_index = math.min(nr_previous_bluffs + 1, #chance_table)
		local is_last = chance_table[math.min(chance_index + 1, #chance_table)] == 0
		local rand_nr = math.random()
		local success = true

		self._unit:sound():stop()

		if success then
			managers.groupai:state():on_successful_alarm_pager_bluff()

			local cue_index = is_last and 4 or 1

			if is_dead then
				self._unit:sound():corpse_play(self:_get_radio_id("dsp_radio_fooled_" .. tostring(cue_index)), nil, true)
			else
				self._unit:sound():play(self:_get_radio_id("dsp_radio_fooled_" .. tostring(cue_index)), nil, true)
			end

			if is_last then
				-- Nothing
			end
		else
			managers.groupai:state():on_police_called("alarm_pager_bluff_failed")
			self._unit:interaction():set_active(false, true)

			if is_dead then
				self._unit:sound():corpse_play(self:_get_radio_id("dsp_radio_alarm_1"), nil, true)
			else
				self._unit:sound():play(self:_get_radio_id("dsp_radio_alarm_1"), nil, true)
			end
		end

		self:end_alarm_pager()
		managers.mission:call_global_event("player_answer_pager")

		if not self:_chk_enable_bodybag_interaction() then
			self._unit:interaction():set_active(false, true)
		end
	elseif status == "interrupted" then
		managers.groupai:state():on_police_called("alarm_pager_hang_up")
		self._unit:interaction():set_active(false, true)
		self._unit:sound():stop()

		if is_dead then
			self._unit:sound():corpse_play(self:_get_radio_id("dsp_radio_alarm_1"), nil, true)
		else
			self._unit:sound():play(self:_get_radio_id("dsp_radio_alarm_1"), nil, true)
		end

		self:end_alarm_pager()
	end
end

function CopBrain:on_nav_link_unregistered(element_id)
	if self._logic_data.pathing_results then
		local failed_search_ids = nil

		for path_name, path in pairs(self._logic_data.pathing_results) do
			if type(path) == "table" and path[1] and type(path[1]) ~= "table" then
				for i, nav_point in ipairs(path) do
					if not nav_point.x and nav_point.script_data and nav_point:script_data().element._id == element_id then
						failed_search_ids = failed_search_ids or {}
						failed_search_ids[path_name] = true

						break
					end
				end
			end
		end

		if failed_search_ids then
			for search_id, _ in pairs(failed_search_ids) do
				self._logic_data.pathing_results[search_id] = "failed"
			end
		end
	end

	local paths = self._current_logic._get_all_paths and self._current_logic._get_all_paths(self._logic_data)

	if not paths then
		return
	end

	local verified_paths = {}

	for path_name, path in pairs(paths) do
		local path_is_ok = true

		for i, nav_point in ipairs(path) do
			if not nav_point.x and nav_point.script_data and nav_point:script_data().element._id == element_id then
				path_is_ok = false

				break
			end
		end

		if path_is_ok then
			verified_paths[path_name] = path
		end
	end

	self._current_logic._set_verified_paths(self._logic_data, verified_paths)
end

function CopBrain:_chk_enable_bodybag_interaction()
	if Global.game_settings.one_down then
		return
	end
	
	if self:is_pager_started() or Global.game_settings.one_down then
		return
	end

	if not self._unit:character_damage():dead() or Global.game_settings.one_down then
		return
	end

	if not self._alarm_pager_has_run and self._unit:unit_data().has_alarm_pager then
		return
	end
	
	if not Global.game_settings.one_down then
		self._unit:interaction():set_tweak_data("corpse_dispose")
		self._unit:interaction():set_active(true, true)
	end

	return true
end
