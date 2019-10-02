function CopDamage:_on_damage_received(damage_info)
	self:_call_listeners(damage_info)
	CopDamage._notify_listeners("on_damage", damage_info)

	if damage_info.result.type == "death" then
		managers.enemy:on_enemy_died(self._unit, damage_info)

		for c_key, c_data in pairs(managers.groupai:state():all_char_criminals()) do
			if c_data.engaged[self._unit:key()] then
				debug_pause_unit(self._unit:key(), "dead AI engaging player", self._unit, c_data.unit)
			end
		end
	end

	if self._dead and self._unit:movement():attention() then
		debug_pause_unit(self._unit, "[CopDamage:_on_damage_received] dead AI", self._unit, inspect(self._unit:movement():attention()))
	end

	local attacker_unit = damage_info and damage_info.attacker_unit

	if alive(attacker_unit) and attacker_unit:base() then
		if attacker_unit:base().thrower_unit then
			attacker_unit = attacker_unit:base():thrower_unit()
		elseif attacker_unit:base().sentry_gun then
			attacker_unit = attacker_unit:base():get_owner()
		end
	end
	
	local sup_build_amount = math.ceil(1, damage_info.damage / 0.25)
	
	self:build_suppression(sup_build_amount, nil)

	if attacker_unit == managers.player:player_unit() and damage_info then
		managers.player:on_damage_dealt(self._unit, damage_info)
	end

	if damage_info.variant == "melee" then
		managers.statistics:register_melee_hit()
	end

	self:_update_debug_ws(damage_info)
end

function CopDamage:check_medic_heal()
	if not self._unit:base():has_tag("medic") then
		if self._unit:anim_data() and self._unit:anim_data().act then
			return false
		end

		local medic = managers.enemy:get_nearby_medic(self._unit)

		return medic and medic:character_damage():heal_unit(self._unit)
	end
end

function CopDamage:clbk_suppression_decay()
	local sup_data = self._suppression_data
	self._suppression_data = nil

	if not alive(self._unit) or self._dead then
		return
	end

	if sup_data.react_zone then
		self._unit:movement():on_suppressed(false)
	end

	if sup_data.brown_zone then
		self._unit:brain():on_suppressed(false)
	end
	
	if Global.game_settings.one_down then --The effect is self-explanatory, but the reasons for it are in copactionshoot.
		self._suppression_hardness_t = TimerManager:game():time() + 0.35
	else
		self._suppression_hardness_t = TimerManager:game():time() + 30
	end
	
end

function CopDamage:damage_bullet(attack_data) --the bullshit i am required to do because of post-hooks not working right.
	local diff_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)
	if self._dead or self._invulnerable then
		return
	end

	local is_civilian = CopDamage.is_civilian(self._unit:base()._tweak_table)

	if self._has_plate and attack_data.col_ray.body and attack_data.col_ray.body:name() == self._ids_plate_name and not attack_data.armor_piercing then
		local armor_pierce_roll = math.rand(1)
		local armor_pierce_value = 0

		if attack_data.attacker_unit == managers.player:player_unit() and not attack_data.weapon_unit:base().thrower_unit then
			armor_pierce_value = armor_pierce_value + attack_data.weapon_unit:base():armor_piercing_chance()
			armor_pierce_value = armor_pierce_value + managers.player:upgrade_value("player", "armor_piercing_chance", 0)
			armor_pierce_value = armor_pierce_value + managers.player:upgrade_value("weapon", "armor_piercing_chance", 0)
			armor_pierce_value = armor_pierce_value + managers.player:upgrade_value("weapon", "armor_piercing_chance_2", 0)

			if attack_data.weapon_unit:base():got_silencer() then
				armor_pierce_value = armor_pierce_value + managers.player:upgrade_value("weapon", "armor_piercing_chance_silencer", 0)
			end

			if attack_data.weapon_unit:base():is_category("saw") then
				armor_pierce_value = armor_pierce_value + managers.player:upgrade_value("saw", "armor_piercing_chance", 0)
			end
		elseif attack_data.attacker_unit:base() and attack_data.attacker_unit:base().sentry_gun then
			local owner = attack_data.attacker_unit:base():get_owner()

			if alive(owner) then
				if owner == managers.player:player_unit() then
					armor_pierce_value = armor_pierce_value + managers.player:upgrade_value("sentry_gun", "armor_piercing_chance", 0)
					armor_pierce_value = armor_pierce_value + managers.player:upgrade_value("sentry_gun", "armor_piercing_chance_2", 0)
				else
					armor_pierce_value = armor_pierce_value + (owner:base():upgrade_value("sentry_gun", "armor_piercing_chance") or 0)
					armor_pierce_value = armor_pierce_value + (owner:base():upgrade_value("sentry_gun", "armor_piercing_chance_2") or 0)
				end
			end
		end

		if armor_pierce_roll >= armor_pierce_value then
			return
		end
	end

	local result = nil
	local body_index = self._unit:get_body_index(attack_data.col_ray.body:name())
	local head = self._head_body_name and attack_data.col_ray.body and attack_data.col_ray.body:name() == self._ids_head_body_name
	local damage = attack_data.damage
	
	if is_civilian or self._unit:base():has_tag("special") and attack_data and not attack_data.attacker_unit:base()._tweak_table == "tank_mini" and not attack_data.attacker_unit:base()._tweak_table == "tank" and not attack_data.attacker_unit:base()._tweak_table == "tank_medic" then
		if self:is_friendly_fire(attack_data.attacker_unit) then
			return "friendly_fire"
		end
	elseif self:is_friendly_fire(attack_data.attacker_unit) and not is_civilian then
		if attack_data.attacker_unit:base()._tweak_table == "tank_mini" or attack_data.attacker_unit:base()._tweak_table == "tank" or attack_data.attacker_unit:base()._tweak_table == "tank_medic" then
			damage = damage * 9
		else
			damage = damage * 0.25
		end
	end
	
	if self._unit:base():char_tweak().DAMAGE_CLAMP_BULLET then
		damage = math.min(damage, self._unit:base():char_tweak().DAMAGE_CLAMP_BULLET)
	end

	damage = damage * (self._marked_dmg_mul or 1)

	if self._marked_dmg_mul and self._marked_dmg_dist_mul then
		local dst = mvector3.distance(attack_data.origin, self._unit:position())
		local spott_dst = tweak_data.upgrades.values.player.marked_inc_dmg_distance[self._marked_dmg_dist_mul]

		if spott_dst[1] < dst then
			damage = damage * spott_dst[2]
		end
	end

	if self._unit:movement():cool() and diff_index <= 5 then
		damage = self._HEALTH_INIT
	end

	local headshot = false
	local headshot_multiplier = 1

	if attack_data.attacker_unit == managers.player:player_unit() then
		local critical_hit, crit_damage = self:roll_critical_hit(attack_data)

		if critical_hit then
			managers.hud:on_crit_confirmed()

			damage = crit_damage
			attack_data.critical_hit = true
		else
			managers.hud:on_hit_confirmed()
		end

		headshot_multiplier = managers.player:upgrade_value("weapon", "passive_headshot_damage_multiplier", 1)

		if tweak_data.character[self._unit:base()._tweak_table].priority_shout then
			damage = damage * managers.player:upgrade_value("weapon", "special_damage_taken_multiplier", 1)
		end

		if head then
			managers.player:on_headshot_dealt()

			headshot = true
		end
	end

	if not self._char_tweak.ignore_headshot and not self._damage_reduction_multiplier and head then
		if self._char_tweak.headshot_dmg_mul then
			damage = damage * self._char_tweak.headshot_dmg_mul * headshot_multiplier
		else
			damage = self._health * 10
		end
	end

	if attack_data.weapon_unit:base().get_add_head_shot_mul then
		local add_head_shot_mul = attack_data.weapon_unit:base():get_add_head_shot_mul()

		if not head and add_head_shot_mul and self._char_tweak and self._char_tweak.access ~= "tank" then
			local tweak_headshot_mul = math.max(0, self._char_tweak.headshot_dmg_mul - 1)
			local mul = tweak_headshot_mul * add_head_shot_mul + 1
			damage = damage * mul
		end
	end

	damage = self:_apply_damage_reduction(damage)
	attack_data.raw_damage = damage
	attack_data.headshot = head
	local damage_percent = math.ceil(math.clamp(damage / self._HEALTH_INIT_PRECENT, 1, self._HEALTH_GRANULARITY))
	damage = damage_percent * self._HEALTH_INIT_PRECENT
	damage, damage_percent = self:_apply_min_health_limit(damage, damage_percent)

	if self._immortal then
		damage = math.min(damage, self._health - 1)
	end

	if self._health <= damage then
		if self:check_medic_heal() then
			result = {
				type = "healed",
				variant = attack_data.variant
			}
		else
			if head then
				managers.player:on_lethal_headshot_dealt(attack_data.attacker_unit, attack_data)

				if math.random(10) < damage then
					self:_spawn_head_gadget({
						position = attack_data.col_ray.body:position(),
						rotation = attack_data.col_ray.body:rotation(),
						dir = attack_data.col_ray.ray
					})
				end
			end

			attack_data.damage = self._health
			result = {
				type = "death",
				variant = attack_data.variant
			}

			self:die(attack_data)
			self:chk_killshot(attack_data.attacker_unit, "bullet", headshot)
		end
	else
		attack_data.damage = damage
		local result_type = not self._char_tweak.immune_to_knock_down and (attack_data.knock_down and "knock_down" or attack_data.stagger and not self._has_been_staggered and "stagger") or self:get_damage_type(damage_percent, "bullet")
		result = {
			type = result_type,
			variant = attack_data.variant
		}

		self:_apply_damage_to_health(damage)
	end

	attack_data.result = result
	attack_data.pos = attack_data.col_ray.position

	if result.type == "death" then
		local data = {
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			head_shot = head,
			weapon_unit = attack_data.weapon_unit,
			variant = attack_data.variant
		}

		if managers.groupai:state():all_criminals()[attack_data.attacker_unit:key()] then
			managers.statistics:killed_by_anyone(data)
		end
		
		if attack_data.attacker_unit == managers.player:player_unit() then
			local special_comment = self:_check_special_death_conditions(attack_data.variant, attack_data.col_ray.body, attack_data.attacker_unit, attack_data.weapon_unit)

			self:_comment_death(attack_data.attacker_unit, self._unit, special_comment)
			self:_show_death_hint(self._unit:base()._tweak_table)

			local attacker_state = managers.player:current_state()
			data.attacker_state = attacker_state

			managers.statistics:killed(data)
			self:_check_damage_achievements(attack_data, head)

			if not is_civilian and managers.player:has_category_upgrade("temporary", "overkill_damage_multiplier") and not attack_data.weapon_unit:base().thrower_unit and attack_data.weapon_unit:base():is_category("shotgun", "saw") then
				managers.player:activate_temporary_upgrade("temporary", "overkill_damage_multiplier")
			end

			if is_civilian then
				managers.money:civilian_killed()
			end
		elseif attack_data.attacker_unit:in_slot(managers.slot:get_mask("criminals_no_deployables")) then
			self:_AI_comment_death(attack_data.attacker_unit, self._unit)
		elseif attack_data.attacker_unit:base().sentry_gun then
			if Network:is_server() then
				local server_info = attack_data.weapon_unit:base():server_information()

				if server_info and server_info.owner_peer_id ~= managers.network:session():local_peer():id() then
					local owner_peer = managers.network:session():peer(server_info.owner_peer_id)

					if owner_peer then
						owner_peer:send_queued_sync("sync_player_kill_statistic", data.name, data.head_shot and true or false, data.weapon_unit, data.variant, data.stats_name)
					end
				else
					data.attacker_state = managers.player:current_state()

					managers.statistics:killed(data)
				end
			end

			local sentry_attack_data = deep_clone(attack_data)
			sentry_attack_data.attacker_unit = attack_data.attacker_unit:base():get_owner()

			if sentry_attack_data.attacker_unit == managers.player:player_unit() then
				self:_check_damage_achievements(sentry_attack_data, head)
			else
				self._unit:network():send("sync_damage_achievements", sentry_attack_data.weapon_unit, sentry_attack_data.attacker_unit, sentry_attack_data.damage, sentry_attack_data.col_ray and sentry_attack_data.col_ray.distance, head)
			end
		end
	end

	local hit_offset_height = math.clamp(attack_data.col_ray.position.z - self._unit:movement():m_pos().z, 0, 300)
	local attacker = attack_data.attacker_unit
	
	if attacker:id() == -1 then
		attacker = self._unit
	end

	local weapon_unit = attack_data.weapon_unit

	if alive(weapon_unit) and weapon_unit:base() and weapon_unit:base().add_damage_result then
		weapon_unit:base():add_damage_result(self._unit, result.type == "death", attacker, damage_percent)
	end

	local variant = nil

	if result.type == "knock_down" then
		variant = 1
	elseif result.type == "stagger" then
		variant = 2
		self._has_been_staggered = true
	elseif result.type == "healed" then
		variant = 3
	else
		variant = 0
	end

	self:_send_bullet_attack_result(attack_data, attacker, damage_percent, body_index, hit_offset_height, variant)
	self:_on_damage_received(attack_data)

	if not is_civilian then
		managers.player:send_message(Message.OnEnemyShot, nil, self._unit, attack_data)
	end

	result.attack_data = attack_data

	return result
end

function CopDamage:damage_fire(attack_data)
	local is_civilian = CopDamage.is_civilian(self._unit:base()._tweak_table)
	local valid_attacker = attack_data.attacker_unit and alive(attack_data.attacker_unit)

	if self._dead or self._invulnerable then
		if self._invulnerable and not is_civilian and valid_attacker and not self:is_friendly_fire(attack_data.attacker_unit) then
			managers.player:send_message(Message.OnEnemyShot, nil, attack_data.attacker_unit, self._unit, "fire")
		end

		return
	end

	if valid_attacker and self:is_friendly_fire(attack_data.attacker_unit) then
		return "friendly_fire"
	end

	if not is_civilian and valid_attacker then
		managers.player:send_message(Message.OnEnemyShot, nil, attack_data.attacker_unit, self._unit, "fire")
	end

	local result = nil
	local damage = attack_data.damage

	if attack_data.attacker_unit == managers.player:player_unit() then
		if attack_data.weapon_unit and attack_data.variant ~= "stun" and not attack_data.is_fire_dot_damage then
			if damage > 0 then
				managers.hud:on_hit_confirmed()
			end
		end

		if tweak_data.character[self._unit:base()._tweak_table].priority_shout then
			damage = damage * managers.player:upgrade_value("weapon", "special_damage_taken_multiplier", 1)
		end
	end

	damage = damage * (self._char_tweak.damage.fire_damage_mul or 1)
	damage = damage * (self._marked_dmg_mul or 1)

	if not attack_data.is_fire_dot_damage and self._marked_dmg_mul and self._marked_dmg_dist_mul then
		local attacking_unit = attack_data.attacker_unit

		if attacking_unit and attacking_unit:base() and attacking_unit:base().thrower_unit then
			attacking_unit = attacking_unit:base():thrower_unit()
		end

		if alive(attacking_unit) then
			local dst = mvector3.distance(attacking_unit:position(), self._unit:position())
			local spott_dst = tweak_data.upgrades.values.player.marked_inc_dmg_distance[self._marked_dmg_dist_mul]

			if spott_dst[1] < dst then
				damage = damage * spott_dst[2]
			end
		end
	end

	if self._unit:base():char_tweak().DAMAGE_CLAMP_FIRE and not attack_data.is_fire_dot_damage then
		damage = math.min(damage, self._unit:base():char_tweak().DAMAGE_CLAMP_FIRE)
	end
	
	if self._unit:base():char_tweak().DAMAGE_CLAMP_FIREDOT and attack_data and attack_data.is_fire_dot_damage then
		damage = math.min(damage, self._unit:base():char_tweak().DAMAGE_CLAMP_FIREDOT)
	end
	
	
	if self._unit:base():char_tweak().fire_dmg_mul then
		damage = damage * self._unit:base():char_tweak().fire_dmg_mul
	end
	
	damage = self:_apply_damage_reduction(damage)
	damage = math.clamp(damage, 0, self._HEALTH_INIT)
	local damage_percent = math.ceil(damage / self._HEALTH_INIT_PRECENT)
	damage = damage_percent * self._HEALTH_INIT_PRECENT
	damage, damage_percent = self:_apply_min_health_limit(damage, damage_percent)

	if self._immortal then
		damage = math.min(damage, self._health - 1)
	end

	if self._health <= damage then
		if self:check_medic_heal() then
			result = {
				type = "healed",
				variant = attack_data.variant
			}
		else
			attack_data.damage = self._health
			result = {
				type = "death",
				variant = attack_data.variant
			}

			self:die(attack_data)
			self:chk_killshot(attack_data.attacker_unit, "fire")
		end
	else
		attack_data.damage = damage
		local result_type = attack_data.variant == "stun" and "hurt_sick" or self:get_damage_type(damage_percent, "fire")
		result = {
			type = result_type,
			variant = attack_data.variant
		}

		self:_apply_damage_to_health(damage)
	end

	attack_data.result = result
	attack_data.pos = attack_data.col_ray.position

	local attacker_unit = attack_data.attacker_unit

	if result.type == "death" then
		local data = {
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			owner = attack_data.owner,
			weapon_unit = attack_data.weapon_unit,
			variant = attack_data.variant,
			head_shot = false,
			is_molotov = attack_data.is_molotov
		}

		managers.statistics:killed_by_anyone(data)

		if not is_civilian and managers.player:has_category_upgrade("temporary", "overkill_damage_multiplier") and attacker_unit == managers.player:player_unit() and alive(attack_data.weapon_unit) and not attack_data.weapon_unit:base().thrower_unit and attack_data.weapon_unit:base().is_category and attack_data.weapon_unit:base():is_category("shotgun", "saw") then
			managers.player:activate_temporary_upgrade("temporary", "overkill_damage_multiplier")
		end

		if attacker_unit and alive(attacker_unit) and attacker_unit:base() and attacker_unit:base().thrower_unit then
			attacker_unit = attacker_unit:base():thrower_unit()
			data.weapon_unit = attack_data.attacker_unit
		end

		if attacker_unit == managers.player:player_unit() then
			if alive(attacker_unit) then
				self:_comment_death(attacker_unit, self._unit)
			end

			self:_show_death_hint(self._unit:base()._tweak_table)
			managers.statistics:killed(data)

			if is_civilian then
				managers.money:civilian_killed()
			end

			self:_check_damage_achievements(attack_data, false)
		else
			if attacker_unit and alive(attacker_unit) and managers.groupai:state():is_unit_team_AI(attacker_unit) then
				self:_AI_comment_death(attacker_unit, self._unit)
			end
		end
	end

	local attacker = attack_data.attacker_unit

	if not attacker or attacker and alive(attacker) and attacker:id() == -1 then
		attacker = self._unit
	end

	local weapon_unit = attack_data.weapon_unit or attacker

	if alive(weapon_unit) and weapon_unit:base() and weapon_unit:base().add_damage_result then
		weapon_unit:base():add_damage_result(self._unit, result.type == "death", attacker, damage_percent)
	end

	if not attack_data.is_fire_dot_damage then
		local fire_dot_data = attack_data.fire_dot_data
		local flammable = nil
		local char_tweak = tweak_data.character[self._unit:base()._tweak_table]

		if char_tweak.flammable == nil then
			flammable = true
		else
			flammable = char_tweak.flammable
		end

		local distance = 1000
		local hit_loc = attack_data.col_ray.hit_position

		if hit_loc and attacker_unit and attacker_unit.position then
			distance = mvector3.distance(hit_loc, attacker_unit:position())
		end

		local fire_dot_max_distance = 3000
		local fire_dot_trigger_chance = 30
		local dot_damage = fire_dot_data and fire_dot_data.dot_damage or 25

		if fire_dot_data then
			fire_dot_max_distance = tonumber(fire_dot_data.dot_trigger_max_distance)
			fire_dot_trigger_chance = tonumber(fire_dot_data.dot_trigger_chance)
			
			if attack_data.attacker_unit and alive(attack_data.attacker_unit) and attack_data.attacker_unit:base()._grenade_entry == "molotov" or attack_data.is_molotov then
				--grenade, DoT unchanged
			elseif alive(attack_data.weapon_unit) and attack_data.weapon_unit:base()._name_id ~= nil and tweak_data.weapon[attack_data.weapon_unit:base()._name_id] ~= nil and tweak_data.weapon[attack_data.weapon_unit:base()._name_id].fire_dot_data ~= nil then
				dot_damage = (damage / dot_damage) * 100 --flamethrower, scale DoT damage depending on the total damage dealt through direct (impact) fire damage
				--usual dot_damage is 30
			elseif alive(attack_data.weapon_unit) and attack_data.weapon_unit:base()._parts then
				for part_id, part in pairs(attack_data.weapon_unit:base()._parts) do
					if tweak_data.weapon.factory.parts[part_id].custom_stats and tweak_data.weapon.factory.parts[part_id].custom_stats.fire_dot_data then
						dot_damage = dot_damage * damage * 0.1 --Dragon's Breath rounds, scale DoT damage depending on the total damage dealt through direct (impact) fire damage
						--usual dot_damage is 10
					end
				end
			end
		end

		local start_dot_damage_roll = math.random(1, 100)
		local start_dot_dance_antimation = false

		if flammable and not attack_data.is_fire_dot_damage and distance < fire_dot_max_distance and start_dot_damage_roll <= fire_dot_trigger_chance then
			managers.fire:add_doted_enemy(self._unit, TimerManager:game():time(), attack_data.weapon_unit, fire_dot_data.dot_length, dot_damage, attack_data.attacker_unit, attack_data.is_molotov)

			start_dot_dance_antimation = true
		end

		if fire_dot_data then
			fire_dot_data.start_dot_dance_antimation = start_dot_dance_antimation
			attack_data.fire_dot_data = fire_dot_data
		end
	end

	self:_send_fire_attack_result(attack_data, attacker, damage_percent, attack_data.is_fire_dot_damage, attack_data.col_ray.ray, attack_data.result.type == "healed")
	self:_on_damage_received(attack_data)
end

Hooks:PostHook(CopDamage, "damage_bullet", "shin_damagebullet", function(self, attack_data)
	
	if attack_data.weapon_unit and attack_data.weapon_unit:base().is_category and attack_data.weapon_unit:base():is_category("saw") then
		managers.groupai:state():_voice_saw() --THAT MADMAN HAS A FUCKIN' SAW
	end
		
	if attack_data.attacker_unit:base().sentry_gun and not self:is_friendly_fire(attack_data.attacker_unit) then
		managers.groupai:state():_voice_sentry() --FUCKING SCI-FI ROBOT GUNS
	end

end)