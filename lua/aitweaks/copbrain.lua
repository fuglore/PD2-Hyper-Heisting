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
	
	CopBrain._logic_variants.tank_ftsu = clone(security_variant)
	CopBrain._logic_variants.tank_ftsu.attack = TankCopLogicAttack

	old_init(self)
end


function CopBrain:on_suppressed(state)
    self._logic_data.is_suppressed = state or nil

    if self._current_logic.on_suppressed_state then
        self._current_logic.on_suppressed_state(self._logic_data)

        if self._logic_data.char_tweak.chatter.suppress then
		    local roll = math.random(1, 100)
			local chance_heeeeelpp = 50
			
			if roll <= chance_heeeeelpp then
                self._unit:sound():say("hlp", true)
			else --hopefully some variety here now
                self._unit:sound():say("lk3b", true) 
			end		
        end
    end
end

function CopBrain:begin_alarm_pager(reset)
	local diff_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)
	if diff_index == 8 then
			if not reset and self._alarm_pager_has_run then
				return
			end

		self._alarm_pager_has_run = true
		self._alarm_pager_data = {
			total_nr_calls = math.random(tweak_data.player.alarm_pager.nr_of_calls[1], tweak_data.player.alarm_pager.nr_of_calls[2]),
			nr_calls_made = 0
		}
		local call_delay = math.lerp(tweak_data.player.alarm_pager.first_call_delay[1], tweak_data.player.alarm_pager.first_call_delay[2], math.random())
		self._alarm_pager_data.pager_clbk_id = "pager" .. tostring(self._unit:key())

		managers.enemy:add_delayed_clbk(self._alarm_pager_data.pager_clbk_id, callback(self, self, "clbk_alarm_pager"), TimerManager:game():time() + 1.05)
	end
end

function CopBrain:on_alarm_pager_interaction(status, player)
	local diff_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)
	if not managers.groupai:state():whisper_mode() or diff_index <= 7 then
		return
	end

	local is_dead = self._unit:character_damage():dead()
	local pager_data = self._alarm_pager_data

	if not pager_data then
		return
	end
	
	if diff_index == 8 then
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

				local cue_index = 1

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
end

function CopBrain:clbk_alarm_pager(ignore_this, data)
	local diff_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)
	local pager_data = self._alarm_pager_data
	local clbk_id = pager_data.pager_clbk_id
	pager_data.pager_clbk_id = nil

	if not managers.groupai:state():whisper_mode() or diff_index <= 7 then
		self:end_alarm_pager()

		return
	end
	
	if diff_index == 8 then
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
			managers.groupai:state():on_police_called("alarm_pager_not_answered")
			self._unit:sound():stop()

			if self._unit:character_damage():dead() then
				self._unit:sound():corpse_play("pln_alm_any_any", nil, true)
			else
				self._unit:sound():play("pln_alm_any_any", nil, true)
			end

			self:end_alarm_pager()
		end

		if pager_data.nr_calls_made == pager_data.total_nr_calls - 1 then
			self._unit:interaction():set_outline_flash_state(true, true)
		end

		pager_data.nr_calls_made = pager_data.nr_calls_made + 1

		if pager_data.nr_calls_made <= pager_data.total_nr_calls then
			local duration_settings = tweak_data.player.alarm_pager.call_duration[math.min(#tweak_data.player.alarm_pager.call_duration, pager_data.nr_calls_made)]
			local call_delay = math.lerp(duration_settings[1], duration_settings[2], math.random())
			self._alarm_pager_data.pager_clbk_id = clbk_id

			managers.enemy:add_delayed_clbk(self._alarm_pager_data.pager_clbk_id, callback(self, self, "clbk_alarm_pager"), TimerManager:game():time() + call_delay)
		end
	end
end

function CopBrain:_chk_enable_bodybag_interaction()
	if self:is_pager_started() or Global.game_settings.one_down then
		return
	end

	if not self._unit:character_damage():dead() or Global.game_settings.one_down then
		return
	end

	if not self._alarm_pager_has_run and self._unit:unit_data().has_alarm_pager and Global.game_settings.one_down then
		return
	end

	self._unit:interaction():set_tweak_data("corpse_dispose")
	self._unit:interaction():set_active(true, true)

	return true
end
