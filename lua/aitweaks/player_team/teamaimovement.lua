local world_g = World

function TeamAIMovement:on_SPOOCed(enemy_unit)
	local push_vec = Vector3()
	local distance = mvector3.direction(push_vec, enemy_unit:movement():m_head_pos(), self._unit:movement():m_pos())
	mvector3.normalize(push_vec)
	mvector3.set_z(push_vec, 200)
	local attack_data = {
		attacker_unit = enemy_unit,
		is_cloaker_kick = true,
		melee_armor_piercing = true,
		damage = 12.5, --die
		pos = self._unit:movement():m_pos(),
		push_vel = push_vec * 2000
	}
	self._unit:character_damage():damage_melee(attack_data)
	
	return true
end

function TeamAIMovement:play_taser_boom()
	world_g:effect_manager():spawn({
		effect = Idstring("effects/pd2_mod_hh/particles/weapons/explosion/electric_explosion"),
		position = self._unit:movement():m_pos(),
		normal = math.UP
	})
	
	self._unit:sound():play("c4_explode_metal")
end

function TeamAIMovement:pre_destroy()
	TeamAIMovement.super.pre_destroy(self)

	if self._heat_listener_clbk then
		managers.groupai:state():remove_listener(self._heat_listener_clbk)

		self._heat_listener_clbk = nil
	end

	if self._switch_to_not_cool_clbk_id then
		managers.enemy:remove_delayed_clbk(self._switch_to_not_cool_clbk_id)

		self._switch_to_not_cool_clbk_id = nil
	end
end

function TeamAIMovement:carrying_bag(...)
	return TeamAIMovement.super.carrying_bag(self, ...)
end

function TeamAIMovement:set_carrying_bag(...)
	TeamAIMovement.super.set_carrying_bag(self, ...)
end

function TeamAIMovement:carry_id(...)
	return TeamAIMovement.super.carry_id(self, ...)
end

function TeamAIMovement:carry_data(...)
	return TeamAIMovement.super.carry_data(self)
end

function TeamAIMovement:carry_tweak(...)
	return TeamAIMovement.super.carry_tweak(self)
end

function TeamAIMovement:throw_bag(...)
	TeamAIMovement.super.throw_bag(self, ...)
end

function TeamAIMovement:was_carrying_bag(...)
	return TeamAIMovement.super.was_carrying_bag(self, ...)
end

function TeamAIMovement:sync_throw_bag(...)
	TeamAIMovement.super.sync_throw_bag(self, ...)
end

function TeamAIMovement:save(save_data)
	TeamAIMovement.super.save(self, save_data)

	local should_stay = self._should_stay

	if should_stay ~= nil then
		save_data.movement = save_data.movement or {}
		save_data.movement.should_stay = should_stay
	end
end

function TeamAIMovement:load(load_data)
	TeamAIMovement.super.load(self, load_data)

	local mov_load_data = load_data.movement

	if not mov_load_data then
		return
	end

	local should_stay = mov_load_data.should_stay

	if should_stay ~= nil then
		self:set_should_stay(should_stay)
	end
end

function TeamAIMovement:set_should_stay(should_stay)
	if self._should_stay == should_stay then
		return
	end

	self._should_stay = should_stay

	if Network:is_server() then
		managers.network:session():send_to_peers_synched("sync_team_ai_stopped", self._unit, should_stay)
	end

	local panel = managers.criminals:character_data_by_unit(self._unit)

	if panel then
		managers.hud:set_ai_stopped(panel.panel_id, should_stay)
	end
end

function TeamAIMovement:chk_action_forbidden(action_type)
	--stay put orders are not supposed to affect clients
	if action_type == "walk" and self._should_stay and Network:is_server() then
		local objective = self._unit:brain():objective()

		if objective then
			if objective.forced or objective.type == "revive" then
				return false
			end
		end

		return true
	end

	return TeamAIMovement.super.chk_action_forbidden(self, action_type)
end

--used by clients
function TeamAIMovement:sync_reload_weapon(empty_reload, reload_speed_multiplier)
	local reload_action = {
		body_part = 3,
		type = "reload",
		idle_reload = empty_reload ~= 0 and empty_reload or nil
	}

	self:action_request(reload_action)
end

function TeamAIMovement:is_taser_attack_allowed()
	if not self._unit:character_damage():is_downed() and not self._unit:character_damage():_cannot_take_damage() and not self:cool() and not self:chk_action_forbidden("hurt") then
		return true
	end
	
	return
end