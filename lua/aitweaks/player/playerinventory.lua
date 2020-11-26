function PlayerInventory:sync_net_event(event_id, peer)
	local net_events = self._NET_EVENTS

	if event_id == net_events.jammer_start then
		self:_start_jammer_effect()
	elseif event_id == net_events.jammer_stop then
		self:_stop_jammer_effect()
	elseif event_id == net_events.feedback_start then
		self:_start_feedback_effect()
	elseif event_id == net_events.feedback_stop then
		self:_stop_feedback_effect()
	end
end

function PlayerInventory:get_jammer_time()
	return tweak_data.upgrades.values.player.pocket_ecm_jammer_base and tweak_data.upgrades.values.player.pocket_ecm_jammer_base.duration or 6
end

function PlayerInventory:_send_net_event_to_host(event_id)
	managers.network:session():send_to_peer_synched(managers.network:session():peer(1), "sync_unit_event_id_16", self._unit, "inventory", event_id)
end

function PlayerInventory:_start_jammer_effect(end_time)
	end_time = end_time or self:get_jammer_time() + TimerManager:game():time()
	self._jammer_data = {
		effect = "jamming",
		t = end_time,
		sound = self._unit:sound_source():post_event("ecm_jammer_jam_signal"),
		stop_jamming_callback_key = "jammer" .. tostring(self._unit:key())
	}

	if Network:is_server() then
		managers.groupai:state():register_ecm_jammer(self._unit, {
			pager = true,
			call = true,
			camera = true
		})
	end

	managers.enemy:add_delayed_clbk(self._jammer_data.stop_jamming_callback_key, callback(self, self, "_stop_jammer_effect"), self._jammer_data.t)

	local is_local_player = managers.player:player_unit() == self._unit
	local dodge = is_local_player and self._unit:base():upgrade_value("temporary", "pocket_ecm_kill_dodge")

	if dodge then
		self._jammer_data.dodge_kills = dodge[3]
		self._jammer_data.dodge_listener_key = "jamming_dodge" .. tostring(self._unit:key())

		managers.player:register_message(Message.OnEnemyKilled, self._jammer_data.dodge_listener_key, callback(self, self, "_jamming_kill_dodge"))
	end
end

function PlayerInventory:stop_jammer_effect()
	self:_stop_jammer_effect()

	if managers.player:player_unit() == self._unit then
		self:_send_net_event(self._NET_EVENTS.jammer_stop)
	end
end

function PlayerInventory:_stop_jammer_effect()
	if not self._jammer_data or self._jammer_data.effect ~= "jamming" then
		return
	end

	self._jammer_data.effect = nil

	if self._jammer_data.sound then
		self._jammer_data.sound:stop()
		self._unit:sound_source():post_event("ecm_jammer_jam_signal_stop")
	end

	if Network:is_server() then
		managers.groupai:state():register_ecm_jammer(self._unit, false)
	end

	managers.enemy:remove_delayed_clbk(self._jammer_data.stop_jamming_callback_key, true)

	if self._jammer_data.dodge_listener_key then
		managers.player:unregister_message(Message.OnEnemyKilled, self._jammer_data.dodge_listener_key, true)
	end
end

function PlayerInventory:start_feedback_effect(...)
	self:_start_feedback_effect(...)
	self:_send_net_event(self._NET_EVENTS.feedback_start)
end

function PlayerInventory:_start_feedback_effect(end_time, interval, range)
	end_time = end_time or self:get_jammer_time() + TimerManager:game():time()
	self._jammer_data = {
		effect = "feedback",
		t = end_time,
		interval = interval or 1,
		range = range or 2500,
		sound = self._unit:sound_source():post_event("ecm_jammer_puke_signal"),
		feedback_callback_key = "feedback" .. tostring(self._unit:key())
	}

	local is_local_player = managers.player:player_unit() == self._unit
	local dodge = is_local_player and self._unit:base():upgrade_value("temporary", "pocket_ecm_kill_dodge")
	local heal = is_local_player and self._unit:base():upgrade_value("player", "pocket_ecm_heal_on_kill") or self._unit:base():upgrade_value("team", "pocket_ecm_heal_on_kill")

	if heal then
		self._jammer_data.heal = heal
		self._jammer_data.heal_listener_key = "feedback_heal" .. tostring(self._unit:key())

		managers.player:register_message(Message.OnEnemyKilled, self._jammer_data.heal_listener_key, callback(self, self, "_feedback_heal_on_kill"))
	end

	if dodge then
		self._jammer_data.dodge_kills = dodge[3]
		self._jammer_data.dodge_listener_key = "jamming_dodge" .. tostring(self._unit:key())

		managers.player:register_message(Message.OnEnemyKilled, self._jammer_data.dodge_listener_key, callback(self, self, "_jamming_kill_dodge"))
	end

	if Network:is_server() then
		ECMJammerBase._detect_and_give_dmg(self._unit:movement():m_head_pos(), nil, self._unit, 2500)

		managers.enemy:add_delayed_clbk(self._jammer_data.feedback_callback_key, callback(self, self, "_do_feedback"), TimerManager:game():time() + self._jammer_data.interval)
	else
		managers.enemy:add_delayed_clbk(self._jammer_data.feedback_callback_key, callback(self, self, "_stop_feedback_effect"), self._jammer_data.t)
	end
end

function PlayerInventory:stop_feedback_effect()
	self:_stop_feedback_effect()

	if managers.player:player_unit() == self._unit then
		self:_send_net_event(self._NET_EVENTS.feedback_stop)
	end
end

function PlayerInventory:_stop_feedback_effect()
	if not self._jammer_data or self._jammer_data.effect ~= "feedback" then
		return
	end

	self._jammer_data.effect = nil

	if self._jammer_data.sound then
		self._jammer_data.sound:stop()
		self._unit:sound_source():post_event("ecm_jammer_puke_signal_stop")
	end

	if self._jammer_data.heal_listener_key then
		managers.player:unregister_message(Message.OnEnemyKilled, self._jammer_data.heal_listener_key, true)
	end

	if self._jammer_data.dodge_listener_key then
		managers.player:unregister_message(Message.OnEnemyKilled, self._jammer_data.dodge_listener_key, true)
	end

	managers.enemy:remove_delayed_clbk(self._jammer_data.feedback_callback_key, true)
end

function PlayerInventory:_feedback_heal_on_kill()
	if not self._jammer_data or not alive(self._unit) then
		return
	end

	local local_player = managers.player:player_unit()

	if not local_player then
		return
	end

	local damage_ext = local_player:character_damage()

	if not damage_ext or damage_ext:dead() or damage_ext:need_revive() or damage_ext:is_berserker() then
		return
	end

	damage_ext:restore_health(self._jammer_data.heal, true, self._unit ~= local_player and true)
end

function PlayerInventory:_jamming_kill_dodge()
	local data = self._jammer_data

	if not data or not alive(self._unit) then
		return
	end

	local local_player = managers.player:player_unit()

	if not local_player then
		return
	end

	if data.dodge_kills then
		data.dodge_kills = data.dodge_kills - 1

		if data.dodge_kills == 0 then
			managers.player:activate_temporary_upgrade("temporary", "pocket_ecm_kill_dodge")
			managers.player:unregister_message(Message.OnEnemyKilled, data.dodge_listener_key, true)
		end
	end
end

function PlayerInventory:_do_feedback()
	local data = self._jammer_data

	if not data or not alive(self._unit) then
		self:_stop_feedback_effect()

		return
	end

	ECMJammerBase._detect_and_give_dmg(self._unit:movement():m_head_pos(), nil, self._unit, 2500)

	local t = TimerManager:game():time()

	if t >= data.t then
		self:_stop_feedback_effect()
	else
		local next_feedback_t = t + data.interval

		if next_feedback_t > data.t then
			managers.enemy:add_delayed_clbk(data.feedback_callback_key, callback(self, self, "_stop_feedback_effect"), data.t)
		else
			managers.enemy:add_delayed_clbk(data.feedback_callback_key, callback(self, self, "_do_feedback"), next_feedback_t)
		end
	end
end
