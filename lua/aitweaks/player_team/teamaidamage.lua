TeamAIDamage = TeamAIDamage or class()
TeamAIDamage._all_event_types = {
	"bleedout",
	"death",
	"hurt",
	"light_hurt",
	"heavy_hurt",
	"fatal",
	"none"
}
TeamAIDamage._RESULT_INDEX_TABLE = {
	light_hurt = 4,
	hurt = 1,
	bleedout = 2,
	heavy_hurt = 5,
	death = 3,
	fatal = 6
}
TeamAIDamage._HEALTH_GRANULARITY = CopDamage._HEALTH_GRANULARITY
TeamAIDamage.set_invulnerable = CopDamage.set_invulnerable
TeamAIDamage._hurt_severities = CopDamage._hurt_severities
TeamAIDamage.get_damage_type = CopDamage.get_damage_type
local alive_g = alive


function TeamAIDamage:on_recon()
	self:_regenerated()
end

function TeamAIDamage:is_friendly_fire(unit)
	return PlayerDamage.is_friendly_fire(self, unit)
end

function TeamAIDamage:damage_tase(attack_data)	
	if not attack_data or not alive_g(attack_data.attacker_unit) then
        return
    end

    if PlayerDamage.is_friendly_fire(self, attack_data.attacker_unit) then
        self:friendly_fire_hit()

        return
    end

	if self:_cannot_take_damage() then
		return
	end

	self._regenerate_t = nil
	local damage_info = {
		variant = "tase",
		result = {
			type = "hurt"
		}
	}

	if self._tase_effect then
		World:effect_manager():fade_kill(self._tase_effect)
	end

	self._tase_effect = World:effect_manager():spawn(self._tase_effect_table)

	if Network:is_server() then
		if math.random() < 0.25 then
			self._unit:sound():say("s07x_sin", true)
		end

		if not self._to_incapacitated_clbk_id then
			self._to_incapacitated_clbk_id = "TeamAIDamage_to_incapacitated" .. tostring(self._unit:key())

			managers.enemy:add_delayed_clbk(self._to_incapacitated_clbk_id, callback(self, self, "clbk_exit_to_incapacitated"), TimerManager:game():time() + 9999)
		end
	end
	
	self._taser_unit = attack_data.attacker_unit

	self:_call_listeners(damage_info)

	if Network:is_server() then
		self:_send_tase_attack_result()
	end

	return damage_info
end

function TeamAIDamage:damage_bullet(attack_data)
	local result = {
		type = "none",
		variant = "bullet"
	}
	attack_data.result = result

	if self:_cannot_take_damage() then
		self:_call_listeners(attack_data)

		return
	elseif PlayerDamage._chk_dmg_too_soon(self, attack_data.damage) and not attack_data.is_taser_shock then
		self:_call_listeners(attack_data)

		return
	elseif PlayerDamage.is_friendly_fire(self, attack_data.attacker_unit) then
		self:friendly_fire_hit()

		return
	end
	
	if attack_data.is_taser_shock then
		local damage = self._HEALTH_INIT / 4
		if managers.modifiers and managers.modifiers:check_boolean("lightningbolt") then
			damage = damage * 2
		end
		
		attack_data.damage = damage
	end

	local damage_percent, health_subtracted = self:_apply_damage(attack_data, result)
	local t = TimerManager:game():time()
	self._next_allowed_dmg_t = t + self._dmg_interval
	self._last_received_dmg_t = t
	self._last_received_dmg = health_subtracted

	if health_subtracted > 0 then
		self:_send_damage_drama(attack_data, health_subtracted)
	end

	if self._dead then
		self:_unregister_unit()
	end

	self:_call_listeners(attack_data)
	self:_send_bullet_attack_result(attack_data, 0)

	return result
end

function TeamAIDamage:_send_damage_drama(attack_data, health_subtracted)
	if not Network:is_server() then
		return
	end

	local dmg_percent = health_subtracted / self._HEALTH_INIT
	local attacker = attack_data.attacker_unit

	if not attacker or attack_data.attacker_unit:id() == -1 then
		attacker = self._unit
	end
	
	if attacker and attack_data.attacker_unit:movement() then
		local group_ai = managers.groupai:state()
		self._unit:network():send("criminal_hurt", attacker, math.clamp(math.ceil(dmg_percent * 100), 1, 100), nil)
		
		if group_ai._drama_data.amount < 0.2 then
			managers.groupai:state():criminal_hurt_drama(self._unit, attacker, dmg_percent, true)
		end
	end
end

function TeamAIDamage:update(unit, t, dt)
	if self._regenerate_t then
		if self._regenerate_t < t then
			self:_regenerated()
		end
	elseif self._arrested_timer and self._arrested_paused_counter == 0 then
		self._arrested_timer = self._arrested_timer - dt

		if self._arrested_timer <= 0 then
			self._arrested_timer = nil
			local action_data = {
				variant = "stand",
				body_part = 1,
				type = "act",
				blocks = {
					heavy_hurt = -1,
					hurt = -1,
					action = -1,
					aim = -1,
					walk = -1
				}
			}
			local res = self._unit:movement():action_request(action_data)

			self._unit:brain():on_recovered(self._unit)
			self._unit:network():send("from_server_unit_recovered")
			managers.groupai:state():on_criminal_recovered(self._unit)
			managers.hud:set_mugshot_normal(self._unit:unit_data().mugshot_id)
		end
	end

	if self._revive_reminder_line_t and self._revive_reminder_line_t < t then
		self._unit:sound():say("f11e_plu", true)

		self._revive_reminder_line_t = nil
	end
	
	if self._unit:movement():tased() then
		if not self._num_shocks then
			self._num_shocks = 0
			self._next_shock_t = t + 0.75
		else
			if self._num_shocks >= 4 then
				if not alive_g(self._taser_unit) then					
					if Network:is_server() then
						self._num_shocks = nil
						self._next_shock_t = nil
						self._unit:movement():on_tase_ended()
					end
				else
					self._unit:movement():play_taser_boom()
					if Network:is_server() then
						local attack_data = {
							attacker_unit = self._taser_unit,
							pos = self._unit:movement():m_pos(),
							is_taser_shock = true,
							armor_piercing = true,
							damage = 1
						}
						self._num_shocks = nil
						self._next_shock_t = nil
						self._unit:movement():on_tase_ended()
						self._unit:character_damage():damage_bullet(attack_data)
					end
				end
				
				self._taser_unit = nil
			elseif self._next_shock_t < t then
				self._num_shocks = self._num_shocks + 1
				self._next_shock_t = t + 0.75
			end
		end
	else
		self._num_shocks = nil
		self._next_shock_t = nil
	end
	
end

function TeamAIDamage:damage_melee(attack_data)
	if self._invulnerable or self._dead or self._fatal or self._arrested_timer then
		return
	end

	if PlayerDamage.is_friendly_fire(self, attack_data.attacker_unit) then
		return
	end

	local result = {
		variant = "melee"
	}
	local damage_percent, health_subtracted = self:_apply_damage(attack_data, result)
	local t = TimerManager:game():time()
	self._next_allowed_dmg_t = t + self._dmg_interval
	self._last_received_dmg_t = t

	if health_subtracted > 0 then
		self:_send_damage_drama(attack_data, health_subtracted)
	end

	if self._dead then
		self:_unregister_unit()
	end

	self:_call_listeners(attack_data)
	self:_send_melee_attack_result(attack_data)

	return result
end

function TeamAIDamage:_send_melee_attack_result(attack_data, hit_offset_height)
	local pos = attack_data.pos or attack_data.col_ray.position
	hit_offset_height = hit_offset_height or math.clamp(pos.z - self._unit:movement():m_pos().z, 0, 300)
	local attacker = attack_data.attacker_unit

	if not attacker or attacker:id() == -1 then
		attacker = self._unit
	end

	local result_index = self._RESULT_INDEX_TABLE[attack_data.result.type] or 0

	self._unit:network():send("from_server_damage_melee", attacker, hit_offset_height, result_index)
end

function TeamAIDamage:_apply_damage(attack_data, result)
	local damage = attack_data.damage
	damage = math.clamp(damage, self._HEALTH_TOTAL_PERCENT, self._HEALTH_TOTAL)
	local damage_percent = math.ceil(damage / self._HEALTH_TOTAL_PERCENT)
	damage = damage_percent * self._HEALTH_TOTAL_PERCENT
	attack_data.damage = damage
	local dodged = self:inc_dodge_count(damage_percent / 2)
	attack_data.pos = attack_data.pos or attack_data.col_ray.position
	attack_data.result = result

	if dodged or self._unit:anim_data().dodge then
		attack_data.result.type = "none"

		return 0, 0
	end

	local health_subtracted = nil

	if self._bleed_out then
		health_subtracted = self._bleed_out_health
		self._bleed_out_health = self._bleed_out_health - damage

		self:_check_fatal()

		if self._fatal then
			attack_data.result.type = "fatal"
			self._health_ratio = 0
		else
			health_subtracted = damage
			attack_data.result.type = "hurt"
			self._health_ratio = self._bleed_out_health / self._HEALTH_BLEEDOUT_INIT
		end
	else
		health_subtracted = self._health
		self._health = self._health - damage

		self:_check_bleed_out()

		if self._bleed_out then
			attack_data.result.type = "bleedout"
			self._health_ratio = 1
		else
			health_subtracted = damage
			attack_data.result.type = self:get_damage_type(damage_percent, "bullet") or "none"

			self:_on_hurt()

			self._health_ratio = self._health / self._HEALTH_INIT
		end
	end

	managers.hud:set_mugshot_damage_taken(self._unit:unit_data().mugshot_id)

	return damage_percent, health_subtracted
end