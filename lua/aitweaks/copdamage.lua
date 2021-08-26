local mvec_1 = Vector3()
local mvec_2 = Vector3()
local table_size = table.size
local table_contains = table.contains
local math_min = math.min
local math_max = math.max
local world_g = World
local mvec3_norm = mvector3.normalize
local mvec3_set = mvector3.set
local mvec3_set_z = mvector3.set_z
local mvec3_sub = mvector3.subtract
local mvec3_add = mvector3.add
local mvec3_div = mvector3.divide
local mvec3_mul = mvector3.multiply
local mvec_spread = mvector3.spread
local mvec3_dot = mvector3.dot
local mvec3_copy = mvector3.copy
local mvec3_dis = mvector3.distance
local idstr_gore = Idstring("effects/pd2_mod_hh/particles/character/gore_explosion")
local idstr_deathresist = Idstring("effects/pd2_mod_hh/particles/iconograph/deathresist")
local idstr_shieldbreak = Idstring("effects/pd2_mod_hh/particles/character/shield_break")

function CopDamage:is_immune_to_shield_knockback()
	if self._immune_to_knockback then
		return true
	elseif self._unit:anim_data() and self._unit:anim_data().act then
		return true
	end

	return false
end

function CopDamage:_apply_damage_reduction(damage, attack_data)
	if self._health_ratio > 0.75 then
		if not attack_data.is_fire_dot_damage and attack_data.weapon_unit and not attack_data.weapon_unit:base().thrower_unit and alive(attack_data.weapon_unit) and attack_data.weapon_unit:base() and attack_data.weapon_unit:base().is_category and attack_data.weapon_unit:base():is_category("shotgun") then
			damage = damage * managers.player:upgrade_value("player", "shot_shoulders_crowbar", 1)
		end
	end

	local damage_reduction = self._unit:movement():team().damage_reduction or 0
	
	if damage_reduction > 0 then
		damage = damage * (1 - damage_reduction)
	end

	if self._damage_reduction_multiplier then
		damage = damage * self._damage_reduction_multiplier
	end
	
	if self._punk_effect then
		damage = damage * 0.25
	end
	
	if self._invulnerability_t and self._invulnerability_t > TimerManager:game():time()  then
		damage = damage * 0.1
	end

	return damage
end

function CopDamage:activate_punk_visual_effect()
	if not self._punk_effect then
		self._punk_effect_table = {
			effect = Idstring("effects/pd2_mod_hh/particles/character/punk_effect"),
			parent = self._spine2_obj
		}
		
		if self._unit:base()._voidrage then
			self._punk_effect_table.effect = Idstring("effects/pd2_mod_hh/particles/character/punk_effect_void")
		end
		
		self._punk_effect = World:effect_manager():spawn(self._punk_effect_table)
	end
end

function CopDamage:kill_punk_visual_effect()
	if self._punk_effect then
		World:effect_manager():fade_kill(self._punk_effect)
		self._punk_effect = nil
		self._punk_effect_table = nil
	end
end

function CopDamage:save(data)
	local save_health = self._health ~= self._HEALTH_INIT

	if managers.crime_spree:is_active() then
		save_health = save_health or managers.crime_spree:has_active_modifier_of_type("ModifierEnemyHealthAndDamage")
	end

	if save_health then
		data.char_dmg = data.char_dmg or {}
		data.char_dmg.health = self._health
		data.char_dmg.health_init = self._HEALTH_INIT
	end

	if self._invulnerable then
		data.char_dmg = data.char_dmg or {}
		data.char_dmg.invulnerable = self._invulnerable
	end

	if self._immortal then
		data.char_dmg = data.char_dmg or {}
		data.char_dmg.immortal = self._immortal
	end

	if self._unit:in_slot(16) then
		data.char_dmg = data.char_dmg or {}
		data.char_dmg.is_converted = true
	end

	if self._lower_health_percentage_limit then
		data.char_dmg = data.char_dmg or {}
		data.char_dmg.lower_health_percentage_limit = self._lower_health_percentage_limit
	end

	if self._dead then
		data.char_dmg = data.char_dmg or {}
		data.char_dmg.is_dead = true
	else
		data.char_dmg = data.char_dmg or {}
	
		if self._punk_effect then
			data._punk_effect = true
		end
		
		if self._hurt_level then
			data._hurt_level = self._hurt_level
		end
		
		if self._resisted_death then
			data._resisted_death = self._resisted_death
		end
	end
end

function CopDamage:load(data)
	if not data.char_dmg then
		return
	end

	if data.char_dmg.health then
		self._health = data.char_dmg.health
		self._HEALTH_INIT = data.char_dmg.health_init or self._HEALTH_INIT
		self._health_ratio = self._health / self._HEALTH_INIT
	end

	if data.char_dmg.invulnerable then
		self._invulnerable = data.char_dmg.invulnerable
	end

	self._immortal = data.char_dmg.immortal or self._immortal
	
	if data.char_dmg.is_converted then
		self._unit:set_slot(16)
		managers.groupai:state():sync_converted_enemy(self._unit)
		self:set_mover_collision_state(false)

		local add_contour = true
		local tweak_name = alive(self._unit) and self._unit:base() and self._unit:base()._tweak_table

		if tweak_name then
			local char_tweak_data = tweak_data.character[tweak_name]

			if char_tweak_data then
				add_contour = not char_tweak_data.ignores_contours
			end
		end

		if add_contour then
			self._unit:contour():add("friendly", false)
		end
	end

	if data.char_dmg.lower_health_percentage_limit then
		self:_set_lower_health_percentage_limit(data.char_dmg.lower_health_percentage_limit)
	end

	if data.char_dmg.is_dead then
		self._dead = true

		self:_remove_debug_gui()
		self._unit:base():set_slot(self._unit, 17)
		self._unit:inventory():drop_shield()
		self:set_mover_collision_state(false)

		if self._unit:base():has_tag("civilian") then
			managers.enemy:on_civilian_died(self._unit, {})
		else
			managers.enemy:on_enemy_died(self._unit, {})
		end
	else	
		if data._punk_effect then
			self:activate_punk_visual_effect()
		end
		
		if data._hurt_level then
			self._hurt_level = data._hurt_level
		end
		
		if data._resisted_death then
			self._resisted_death = data._resisted_death
		end
	end
end

function CopDamage:get_damage_type(damage_percent, category, attack_data)
	local hurt_table = self._char_tweak.damage.hurt_severity[category or "bullet"]
	local dmg = damage_percent / self._HEALTH_GRANULARITY
	
	--if self._tasing then shouldn't be needed but might uncomment this if people are STILL BITCHING
		--if math.random() < 0.1 then
			--return "hurt"
		--end
	--end
	
	if attack_data and self._char_tweak.damage.doom_hurt_type or self._char_tweak.damage.hurt_severity.doom_light then
		local result = self:determine_doom_hurt_type(attack_data)
		
		return result
	end
	
	if hurt_table.health_reference == "full" then
		-- Nothing
	elseif hurt_table.health_reference == "current" then
		dmg = math.min(1, self._HEALTH_INIT * dmg / self._health)
	else
		dmg = math.min(1, self._HEALTH_INIT * dmg / hurt_table.health_reference)
	end

	local zone = nil

	for i_zone, test_zone in ipairs(hurt_table.zones) do
		if i_zone == #hurt_table.zones or dmg < test_zone.health_limit then
			zone = test_zone

			break
		end
	end

	local rand_nr = math.random()
	local total_w = 0

	for sev_name, hurt_type in pairs(self._hurt_severities) do
		local weight = zone[sev_name]

		if weight and weight > 0 then
			total_w = total_w + weight

			if rand_nr <= total_w then
				return hurt_type or "dmg_rcv"
			end
		end
	end

	return "dmg_rcv"
end

function CopDamage:determine_doom_hurt_type(damage_info)
	local dmg_chk = not self._dead and self._health > 0
	
	local doomzer = self._char_tweak.damage.doom_hurt_type == "doomzer" or nil
	local superarmor = self._char_tweak.damage.doom_hurt_type == "superarmor" or nil
	local light = self._char_tweak.damage.doom_hurt_type == "light" or nil
	local light2 = self._char_tweak.damage.hurt_severity and self._char_tweak.damage.hurt_severity.doom_light or nil
	local heavy = self._char_tweak.damage.doom_hurt_type == "heavy" or nil
	
	local t = TimerManager:game():time()
	
	if dmg_chk and damage_info and damage_info.damage and damage_info.damage > 0.01 then
		local hurt_level_add = 0.5
		local time_mult = 1
		local damage = damage_info.damage
		local hurtlevel_mult = 0.75
		
		if self._punk_effect then
			hurtlevel_mult = 5
		elseif doomzer then
			hurtlevel_mult = 5
		elseif self._tasing then
			hurtlevel_mult = 0.5
			time_mult = time_mult + 0.5
		elseif superarmor then
			hurtlevel_mult = 1.75
			time_mult = 0.75
		elseif heavy then
			hurtlevel_mult = 0.5
			time_mult = time_mult + 0.5
		elseif light or light2 then
			hurtlevel_mult = 0.25
			time_mult = time_mult + 1
		end
		
		if self._unit:in_slot(16) then
			hurtlevel_mult = math_max(hurtlevel_mult * 2, 3)
			time_mult = math_min(time_mult / 2, 1)
		end
		
		if damage_info.variant == "melee" then
			hurtlevel_mult = hurtlevel_mult - 0.2
		end
		
		hurtlevel_mult = managers.modifiers:modify_value("HHHurtRes", hurtlevel_mult)
		
		if self._hurt_level then
			local mult_add = self._hurt_level * 0.1
			time_mult = time_mult + mult_add
		end
		
		local time_to_chk = 0.2 * time_mult	
		
		if damage >= 1600 then
			time_to_chk = 8 * time_mult
			hurt_level_add = 160
		elseif damage >= 800 then
			time_to_chk = 8 * time_mult
			hurt_level_add = 80
		elseif damage >= 120 then
			time_to_chk = 8 * time_mult
			hurt_level_add = 26
		elseif damage >= 110 then
			time_to_chk = 6 * time_mult
			hurt_level_add = 24
		elseif damage >= 100 then
			time_to_chk = 4 * time_mult
			hurt_level_add = 22
		elseif damage >= 90 then
			time_to_chk = 3.7 * time_mult
			hurt_level_add = 20
		elseif damage >= 80 then
			time_to_chk = 3.35 * time_mult
			hurt_level_add = 18
		elseif damage >= 70 then
			time_to_chk = 3 * time_mult
			hurt_level_add = 16
		elseif damage >= 60 then
			time_to_chk = 2.7 * time_mult
			hurt_level_add = 14
		elseif damage >= 50 then
			time_to_chk = 2.35 * time_mult
			hurt_level_add = 12
		elseif damage >= 40 then
			time_to_chk = 2 * time_mult
			hurt_level_add = 10
		elseif damage >= 30 then
			time_to_chk = 1.7 * time_mult
			hurt_level_add = 8
		elseif damage >= 20 then
			time_to_chk = 1.35 * time_mult
			hurt_level_add = 6
		elseif damage >= 12 then
			time_to_chk = 1.2 * time_mult
			hurt_level_add = 4
		elseif damage >= 8 then
			time_to_chk = 1 * time_mult
			hurt_level_add = 3
		elseif damage >= 6 then
			time_to_chk = 0.8 * time_mult
			hurt_level_add = 2
		elseif damage >= 4 then
			time_to_chk = 0.4 * time_mult
			hurt_level_add = 1
		end
		
		if not self._last_received_damage_t or self._last_received_damage_t and self._last_received_damage_t + time_to_chk > t then
			self._last_received_damage_t = t
			--log("hurt time was " .. t .. ".")
			--log("checked time was " .. self._last_received_damage_t + time_to_chk .. ".")
			if self._hurt_level then
				self._hurt_level = self._hurt_level + hurt_level_add
				--log("hurt level is " .. self._hurt_level .. ".")
			else
				self._hurt_level = hurt_level_add
				--log("hurt level is " .. self._hurt_level .. ".")
			end
		else
			local hurt_remove = hurt_level_add * 0.5
			self._last_received_damage_t = t
			--log("hurt time was " .. t .. ".")
			--log("checked time was " .. self._last_received_damage_t + time_to_chk .. ".")
			local checked_t = self._last_received_damage_t + time_to_chk
			if t - checked_t <= 0 then
				self._hurt_level = 0
				--log("reset!")
			elseif self._hurt_level and self._hurt_level > 0 then 
				self._hurt_level = math.max(0, self._hurt_level - hurt_remove)
				--log("hurt level is " .. self._hurt_level .. ".")
			else
				self._hurt_level = 0 + hurt_level_add
				--log("hurt level is " .. self._hurt_level .. ".")
			end
		end
	
		if self._hurt_level then
			if doomzer and self._hurt_level <= 16 * hurtlevel_mult then
				return "dmg_rcv"
			elseif damage_info.variant == "fire" or damage_info.is_fire_dot_damage then
				if doomzer then
					return "dmg_rcv"
				else
					if self._hurt_level >= 16 * hurtlevel_mult then
						return "fire_hurt"
					else
						return "dmg_rcv"
					end
				end
			elseif damage_info.variant == "poison" then
				if doomzer then
					return "dmg_rcv"
				else
					if self._hurt_level >= 16 * hurtlevel_mult then
						return "dmg_rcv"
					else
						return "poison_hurt"
					end
				end
			elseif damage_info.variant == "explosion" then
				if doomzer then
					if self._hurt_level >= 16 * hurtlevel_mult then
						return "light_hurt"
					else
						return "dmg_rcv"
					end
				else
					if self._hurt_level >= 16 * hurtlevel_mult then
						return "expl_hurt"
					else
						return "heavy_hurt"
					end
				end
			elseif self._hurt_level >= 32 * hurtlevel_mult then
				if doomzer then
					self._hurt_level = 0
				end
				
				return "expl_hurt"
			elseif self._hurt_level >= 24 * hurtlevel_mult then
				if doomzer then
					return "light_hurt"
				else
					return "expl_hurt"
				end
			elseif self._hurt_level >= 16 * hurtlevel_mult then
				if doomzer then
					return "light_hurt"
				else
					return "heavy_hurt"
				end
			elseif self._hurt_level >= 8 * hurtlevel_mult then
				return "hurt"
			else
				return "light_hurt"
			end
		end
	end
	
	return "dmg_rcv"
end

function CopDamage:die(attack_data)
	if self._immortal then
		debug_pause("Immortal character died!")
	end

	local variant = attack_data.variant

	self:_check_friend_4(attack_data)
	CopDamage.MAD_3_ACHIEVEMENT(attack_data)
	self:_remove_debug_gui()
	
	if self._punk_effect then
		self:kill_punk_visual_effect()
	end
	
	self._unit:base():set_slot(self._unit, 17)

	if alive(managers.interaction:active_unit()) then
		managers.interaction:active_unit():interaction():selected()
	end

	self:drop_pickup()
	self._unit:inventory():drop_shield()

	if self._unit:unit_data().mission_element then
		self._unit:unit_data().mission_element:event("death", self._unit)

		if not self._unit:unit_data().alerted_event_called then
			self._unit:unit_data().alerted_event_called = true

			self._unit:unit_data().mission_element:event("alerted", self._unit)
		end
	end

	if self._unit:movement() then
		self._unit:movement():remove_giveaway()
	end

	variant = variant or "bullet"
	self._health = 0
	self._health_ratio = 0
	self._dead = true

	self:set_mover_collision_state(false)
	
	if self._char_tweak.die_sound_event then
		if self._char_tweak.die_sound_event then
			self._unit:sound():play(self._char_tweak.die_sound_event, nil, nil)
		end
	end
	
	if not self._unit:movement():cool() then
		if self._unit:base():char_tweak()["custom_voicework"] then
			local voicelines = _G.voiceline_framework.BufferedSounds[self._unit:base():char_tweak().custom_voicework]
			if voicelines and voicelines["death"] then
				local line_to_use = voicelines.death[math.random(#voicelines.death)]
				self._unit:base():play_voiceline(line_to_use, true)
			end
		else
			self._unit:sound():say("x02a_any_3p", true, nil, true, nil)
		end
	end

	if self._unit:base().looping_voice then
		self._unit:base().looping_voice:set_looping(false)
		self._unit:base().looping_voice:stop()
		self._unit:base().looping_voice:close()
		self._unit:base().looping_voice = nil
	end
	
	if self._death_sequence then
		if self._unit:damage() and self._unit:damage():has_sequence(self._death_sequence) then
			self._unit:damage():run_sequence_simple(self._death_sequence)
		else
			debug_pause_unit(self._unit, "[CopDamage:die] does not have death sequence", self._death_sequence, self._unit)
		end
	end

	self:_on_death()
	managers.mutators:notify(Message.OnCopDamageDeath, self, attack_data)

	--report enemy deaths when not in stealth and when instantly killing enemies without alerting them
	if not managers.groupai:state():whisper_mode() and not CopDamage.is_civilian(self._unit:base()._tweak_table) then
		if attack_data.attacker_unit and alive(attack_data.attacker_unit) then
			if managers.groupai:state():all_criminals()[attack_data.attacker_unit:key()] then
				managers.groupai:state():report_aggression(attack_data.attacker_unit)
			end
		end
	end
end

function CopDamage:build_suppression(amount, panic_chance, was_saw)
	if self._dead or not self._char_tweak.suppression or self._punk_effect or self._unit:in_slot(16) then
		return
	end

	local t = TimerManager:game():time()
	local sup_tweak = self._char_tweak.suppression
	
	--local panic_chance_chk = panic_chance == -1 or panic_chance > 0 and sup_tweak.panic_chance_mul > 0 and math.random() < panic_chance * sup_tweak.panic_chance_mul

	if panic_chance then
		local panic_chance_chk = panic_chance == -1 or panic_chance > 0 and sup_tweak.panic_chance_mul > 0 and math.random() < panic_chance * sup_tweak.panic_chance_mul
		if panic_chance_chk then
			amount = "panic"
		end
	end

	local amount_val = nil

	if amount == "max" or amount == "panic" then
		amount_val = (sup_tweak.brown_point or sup_tweak.react_point)[2]
	elseif Network:is_server() and self._suppression_hardness_t and t < self._suppression_hardness_t then
		amount_val = amount * 0.5
	else
		amount_val = amount
	end

	if not Network:is_server() then
		local sync_amount = nil

		if amount == "panic" then
			sync_amount = 16
		elseif amount == "max" then
			sync_amount = 15
		else
			local sync_amount_ratio = nil

			if sup_tweak.brown_point then
				if sup_tweak.brown_point[2] <= 0 then
					sync_amount_ratio = 1
				else
					sync_amount_ratio = amount_val / sup_tweak.brown_point[2]
				end
			elseif sup_tweak.react_point[2] <= 0 then
				sync_amount_ratio = 1
			else
				sync_amount_ratio = amount_val / sup_tweak.react_point[2]
			end

			sync_amount = math.clamp(math.ceil(sync_amount_ratio * 15), 1, 15)
		end

		managers.network:session():send_to_host("suppression", self._unit, sync_amount)

		return
	end

	if self._suppression_data then
		self._suppression_data.value = math.min(self._suppression_data.brown_point or self._suppression_data.react_point, self._suppression_data.value + amount_val)
		self._suppression_data.last_build_t = t
		self._suppression_data.decay_t = t + self._suppression_data.duration

		managers.enemy:reschedule_delayed_clbk(self._suppression_data.decay_clbk_id, self._suppression_data.decay_t)
	else
		local duration = math.lerp(sup_tweak.duration[1], sup_tweak.duration[2], math.random())
		local decay_t = t + duration
		self._suppression_data = {
			value = amount_val,
			last_build_t = t,
			decay_t = decay_t,
			duration = duration,
			react_point = sup_tweak.react_point and math.lerp(sup_tweak.react_point[1], sup_tweak.react_point[2], math.random()),
			brown_point = sup_tweak.brown_point and math.lerp(sup_tweak.brown_point[1], sup_tweak.brown_point[2], math.random()),
			decay_clbk_id = "CopDamage_suppression" .. tostring(self._unit:key())
		}

		managers.enemy:add_delayed_clbk(self._suppression_data.decay_clbk_id, callback(self, self, "clbk_suppression_decay"), decay_t)
	end

	if not self._suppression_data.brown_zone and self._suppression_data.brown_point and self._suppression_data.brown_point <= self._suppression_data.value then
		self._suppression_data.brown_zone = true

		self._unit:brain():on_suppressed(amount == "panic" and "panic" or true)
		
		if amount == "panic" then
			if was_saw then
				self._unit:sound():say("ch4", true, nil, true, nil)
			else
				self._unit:sound():say("lk3b", true, nil, true, nil) 
			end
		else
			self._unit:sound():say("hlp", true, nil, true, nil)
		end
	elseif amount == "panic" then
		if was_saw then
			self._unit:sound():say("ch4", true, nil, true, nil)
		else
			self._unit:sound():say("lk3b", true, nil, true, nil) 
		end
	
		self._unit:brain():on_suppressed("panic")
	end

	if not self._suppression_data.react_zone and self._suppression_data.react_point and self._suppression_data.react_point <= self._suppression_data.value then
		self._suppression_data.react_zone = true

		self._unit:movement():on_suppressed(amount == "panic" and "panic" or true)
	elseif amount == "panic" then
		self._unit:movement():on_suppressed("panic")
	end
end

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
	
	local sup_build_amount = damage_info.damage * 0.25
	
	if sup_build_amount < 0.1 then
		sup_build_amount = 0.1
	end
	
	self:build_suppression(sup_build_amount, nil)

	if attacker_unit == managers.player:player_unit() and damage_info then
		managers.player:on_damage_dealt(self._unit, damage_info)
	end

	local dmg_chk = not self._dead and self._health > 0
	
	local t = TimerManager:game():time()
	
	local speech_allowed = not self._next_allowed_hurt_t or self._next_allowed_hurt_t and self._next_allowed_hurt_t < t	
	
	if dmg_chk and damage_info.damage and damage_info.damage > 0.01 and self._health > damage_info.damage then
		
		if not self._dead then
			if not damage_info.result_type or damage_info.result_type ~= "death"  then
				if self._unit:base():has_tag("punk_rage") then
					local diff_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)

					--punk rage buff will only apply on Death Sentence
					if diff_index == 8 or managers.modifiers and managers.modifiers:check_boolean("TotalAnarchy") then
						self._unit:base():add_buff("base_damage", 2)
						self:activate_punk_visual_effect()
					end
				end
			end
		end
	
		if speech_allowed then
			if not damage_info.result_type or damage_info.result_type ~= "healed" and damage_info.result_type ~= "death" then
				if self._unit:base():has_tag("takedown") and self._unit:base():has_tag("special") then
					if damage_info.is_fire_dot_damage or damage_info.variant == "fire" then
						local fire_variant = nil
						local money = nil
						
						if alive(damage_info.weapon_unit) then
							local weapon_tweak = tweak_data.weapon[damage_info.weapon_unit:base():get_name_id()] 
							fire_variant = weapon_tweak and weapon_tweak.fire_variant or "fire"
							money = fire_variant == "money"
						else
							fire_variant = "fire"
						end

						if self._next_allowed_burnhurt_t and self._next_allowed_burnhurt_t < t or not self._next_allowed_burnhurt_t then
							if money then
								self._unit:sound():say("moneythrower_hurt", nil, true, nil, nil)
							else
								self._unit:sound():say("burnhurt", nil, nil, nil, nil)
							end
							self._next_allowed_burnhurt_t = t + 3
							self._next_allowed_hurt_t = t + math.random(1, 2)
						end
					else
						self._next_allowed_hurt_t = t + math.random(2, 4)
						if self._unit:base():has_tag("tank") then
							--shut up. STOP PLAYING PDTH PAIN NOISES.
						else
							self._unit:sound():say("x01a_any_3p", nil, nil, nil, nil)
						end
					end
				else
					if damage_info.is_fire_dot_damage or damage_info.variant == "fire" then
						local fire_variant = nil
						local money = nil
						
						if alive(damage_info.weapon_unit) then
							local weapon_tweak = tweak_data.weapon[damage_info.weapon_unit:base():get_name_id()] 
							fire_variant = weapon_tweak and weapon_tweak.fire_variant or "fire"
							money = fire_variant == "money"
						else
							fire_variant = "fire"
						end
					
						if self._next_allowed_burnhurt_t and self._next_allowed_burnhurt_t < t or not self._next_allowed_burnhurt_t then
							if money then
								self._unit:sound():say("moneythrower_hurt", nil, true, nil, nil)
							else
								self._unit:sound():say("burnhurt", nil, nil, nil, nil)
							end
							
							self._next_allowed_burnhurt_t = t + 1
							self._next_allowed_hurt_t = t + math.random(1, 2)
						end
					else
						if self._unit:base():has_tag("tank") then
							--shut up. STOP PLAYING PDTH PAIN NOISES.
						else
							self._unit:sound():say("x01a_any_3p", nil, nil, nil, nil)
						end
					end
				end
			end
		end
		
		if damage_info.is_synced then
			local doomzer = self._char_tweak.damage.doom_hurt_type == "doomzer" or nil
			local light = self._char_tweak.damage.doom_hurt_type == "light" or nil
			local light2 = self._char_tweak.damage.hurt_severity and self._char_tweak.damage.hurt_severity.doom_light or nil
			local heavy = self._char_tweak.damage.doom_hurt_type == "heavy" or nil
			
			local hurt_level_add = 0.5
			local time_mult = 1
			local damage = damage_info.damage
			local hurtlevel_mult = 0.75
			
			if doomzer then
				hurtlevel_mult = 5
			elseif heavy then
				hurtlevel_mult = 0.5
				time_mult = time_mult + 0.5
			elseif light or light2 then
				hurtlevel_mult = 0.25
				time_mult = time_mult + 1
			end
			
			if damage_info.variant == "melee" then
				hurtlevel_mult = hurtlevel_mult - 0.25
			end
			
			if self._hurt_level then
				local mult_add = self._hurt_level * 0.1
				time_mult = time_mult + mult_add
			end
				
			local time_to_chk = 0.2 * time_mult	
		
			if damage >= 1600 then
				time_to_chk = 8 * time_mult
				hurt_level_add = 160
			elseif damage >= 800 then
				time_to_chk = 8 * time_mult
				hurt_level_add = 80
			elseif damage >= 120 then
				time_to_chk = 8 * time_mult
				hurt_level_add = 26
			elseif damage >= 110 then
				time_to_chk = 6 * time_mult
				hurt_level_add = 24
			elseif damage >= 100 then
				time_to_chk = 4 * time_mult
				hurt_level_add = 22
			elseif damage >= 90 then
				time_to_chk = 3.7 * time_mult
				hurt_level_add = 20
			elseif damage >= 80 then
				time_to_chk = 3.35 * time_mult
				hurt_level_add = 18
			elseif damage >= 70 then
				time_to_chk = 3 * time_mult
				hurt_level_add = 16
			elseif damage >= 60 then
				time_to_chk = 2.7 * time_mult
				hurt_level_add = 14
			elseif damage >= 50 then
				time_to_chk = 2.35 * time_mult
				hurt_level_add = 12
			elseif damage >= 40 then
				time_to_chk = 2 * time_mult
				hurt_level_add = 10
			elseif damage >= 30 then
				time_to_chk = 1.7 * time_mult
				hurt_level_add = 8
			elseif damage >= 20 then
				time_to_chk = 1.35 * time_mult
				hurt_level_add = 6
			elseif damage >= 12 then
				time_to_chk = 1.2 * time_mult
				hurt_level_add = 4
			elseif damage >= 8 then
				time_to_chk = 1 * time_mult
				hurt_level_add = 3
			elseif damage >= 6 then
				time_to_chk = 0.8 * time_mult
				hurt_level_add = 2
			elseif damage >= 4 then
				time_to_chk = 0.4 * time_mult
				hurt_level_add = 1
			end
			
			if not self._last_received_damage_t or self._last_received_damage_t and self._last_received_damage_t + time_to_chk > t then
				self._last_received_damage_t = t
				--log("hurt time was " .. t .. ".")
				--log("checked time was " .. self._last_received_damage_t + time_to_chk .. ".")
				if self._hurt_level then
					self._hurt_level = self._hurt_level + hurt_level_add
					--log("hurt level is " .. self._hurt_level .. ".")
				else
					self._hurt_level = hurt_level_add
					--log("hurt level is " .. self._hurt_level .. ".")
				end
			else
				local hurt_remove = hurt_level_add * 0.5
				self._last_received_damage_t = t
				--log("hurt time was " .. t .. ".")
				--log("checked time was " .. self._last_received_damage_t + time_to_chk .. ".")
				local checked_t = self._last_received_damage_t + time_to_chk
				if t - checked_t <= 0 then
					self._hurt_level = 0
					--log("reset!")
				elseif self._hurt_level and self._hurt_level > 0 then 
					self._hurt_level = math.max(0, self._hurt_level - hurt_remove)
					--log("hurt level is " .. self._hurt_level .. ".")
				else
					self._hurt_level = 0 + hurt_level_add
					--log("hurt level is " .. self._hurt_level .. ".")
				end
			end
			
		end
	
	end
	
	if not dmg_chk or damage_info.result_type and damage_info.result_type == "death" then
		if self._punk_effect then
			self:kill_punk_visual_effect()
		end
	end
	

	if damage_info.variant == "melee" then
		managers.statistics:register_melee_hit()
	end

	self:_update_debug_ws(damage_info)
end

local anims = {
    e_so_release_hostage_left = true,
    e_so_release_hostage_right = true,
    e_so_release_hostage_back = true
}

function CopDamage:check_medic_heal()
	if self._unit:base():has_tag("medic") then
		return false
	end

	local tweak_table_name = self._unit:base()._tweak_table

	if table_contains(tweak_data.medic.disabled_units, tweak_table_name) then
		return false
	end

	local mov_ext = self._unit:movement()
	local team = mov_ext.team and mov_ext:team()

	if team and team.id ~= "law1" then
		if not team.friends or not team.friends.law1 then
			return false
		end
	end

	local brain_ext = self._unit:brain()

	if brain_ext then
		if brain_ext.converted then
			if brain_ext:converted() then
				return false
			end
		elseif brain_ext._logic_data and brain_ext._logic_data.is_converted then
			return false
		end
	end
	
	local act_action, was_queued = mov_ext:_get_latest_act_action()

	if act_action then
		if was_queued or not act_action.host_expired then
			local variant = act_action.variant
			if anims[variant] then
				return false
			end
		end
	end

	local medic = managers.enemy:get_nearby_medic(self._unit)

	return medic and medic:character_damage():heal_unit(self._unit)
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
		self._suppression_hardness_t = TimerManager:game():time()
	else
		self._suppression_hardness_t = TimerManager:game():time() + 30
	end
	
end

if PD2THHSHIN and PD2THHSHIN:IsHelmetEnabled() then
	function CopDamage:_spawn_head_gadget(params)
		if not self._head_gear then
			return
		end

		if self._head_gear_object then
			if self._nr_head_gear_objects then
				for i = 1, self._nr_head_gear_objects, 1 do
					local head_gear_obj_name = self._head_gear_object .. tostring(i)

					self._unit:get_object(Idstring(head_gear_obj_name)):set_visibility(false)
				end
			else
				self._unit:get_object(Idstring(self._head_gear_object)):set_visibility(false)
			end

			if self._head_gear_decal_mesh then
				local mesh_name_idstr = Idstring(self._head_gear_decal_mesh)

				self._unit:decal_surface(mesh_name_idstr):set_mesh_material(mesh_name_idstr, Idstring("flesh"))
			end
		end

		local unit = World:spawn_unit(Idstring(self._head_gear), params.position, params.rotation)

		if not params.skip_push then
			local true_dir = params.dir
			local spread = math.random(6, 9)
			mvec_spread(true_dir, spread)
			local dir = math.UP + true_dir
			--dir = dir:spread(spread)
			local body = unit:body(0)

			body:push_at(body:mass(), dir * math.lerp(450, 650, math.random()), unit:position() + Vector3(math.rand(1), math.rand(1), math.rand(1)))
		end

		self._head_gear = false
		
		--log("hell yes!")
	end
end

function CopDamage:damage_melee(attack_data)
	if self._dead or self._invulnerable then
		return
	end

	if is_civilian or self._unit:base():has_tag("special") then
		if self:is_friendly_fire(attack_data.attacker_unit) then
			return "friendly_fire"
		end
	elseif self:is_friendly_fire(attack_data.attacker_unit) then
		if attack_data.attacker_unit:base().has_tag and attack_data.attacker_unit:base():has_tag("tank") and not self._unit:base():has_tag("tank") and not self._unit:base():has_tag("protected_reverse") then
			attack_data.damage = attack_data.damage * 9
		end
	end

	local result = nil
	local is_civlian = CopDamage.is_civilian(self._unit:base()._tweak_table)
	local is_gangster = CopDamage.is_gangster(self._unit:base()._tweak_table)
	local is_cop = not is_civlian and not is_gangster
	local head = self._head_body_name and not self._unit:in_slot(16) and not self._char_tweak.ignore_headshot and attack_data.col_ray.body and attack_data.col_ray.body:name() == self._ids_head_body_name
	local damage = attack_data.damage

	if attack_data.attacker_unit and attack_data.attacker_unit == managers.player:player_unit() then
		local critical_hit, crit_damage = self:roll_critical_hit(attack_data)

		if critical_hit then
			damage = crit_damage
			attack_data.critical_hit = true

			if damage > 0 then
				managers.hud:on_crit_confirmed()
			end
		else
			if damage > 0 then
				managers.hud:on_hit_confirmed()
			end
		end

		if tweak_data.achievement.cavity.melee_type == attack_data.name_id and not CopDamage.is_civilian(self._unit:base()._tweak_table) then
			managers.achievment:award(tweak_data.achievement.cavity.award)
		end
	end

	if self._marked_dmg_mul then
		damage = damage * self._marked_dmg_mul
	end

	damage = self:_apply_damage_reduction(damage, attack_data)

	if self._unit:movement():cool() then
		damage = self._HEALTH_INIT
	else
		if self._char_tweak.DAMAGE_CLAMP_MELEE then --adding it while I'm at it in case it's needed for some reason
			damage = math.min(damage, self._char_tweak.DAMAGE_CLAMP_MELEE)
		end
	end

	local damage_effect = attack_data.damage_effect
	local damage_effect_percent = nil
	damage = math.clamp(damage, self._HEALTH_INIT_PRECENT, self._HEALTH_INIT)
	local damage_percent = math.ceil(damage / self._HEALTH_INIT_PRECENT)
	damage = damage_percent * self._HEALTH_INIT_PRECENT
	damage, damage_percent = self:_apply_min_health_limit(damage, damage_percent)

	if self._immortal then
		damage = math.min(damage, self._health - 1)
	end

	if self._health <= damage then
		damage_effect_percent = 1
		attack_data.damage = self._health

		if self:check_medic_heal() then
			result = {
				type = "healed",
				variant = attack_data.variant
			}
		else
			if head then --cosmetic helmet/hat pop because it feels nice
				self:_spawn_head_gadget({
					position = attack_data.col_ray.body:position(),
					rotation = attack_data.col_ray.body:rotation(),
					dir = attack_data.col_ray.ray
				})
			end

			result = {
				type = "death",
				variant = attack_data.variant
			}

			self:die(attack_data)
			self:chk_killshot(attack_data.attacker_unit, "melee")
		end
	else
		attack_data.damage = damage
		damage_effect = math.clamp(damage_effect, self._HEALTH_INIT_PRECENT, self._HEALTH_INIT)
		damage_effect_percent = math.ceil(damage_effect / self._HEALTH_INIT_PRECENT)
		damage_effect_percent = math.clamp(damage_effect_percent, 1, self._HEALTH_GRANULARITY)

		local result_type = self:get_damage_type(damage_effect_percent, "melee", attack_data)
		local variant = attack_data.variant

		if attack_data.shield_knock and self._char_tweak.damage.shield_knocked and not self._unit:base().is_phalanx and not self:is_immune_to_shield_knockback() then
			result_type = "shield_knock"
		elseif attack_data.variant == "counter_tased" then
			result_type = "counter_tased"
		elseif attack_data.variant == "taser_tased" and self._char_tweak.can_be_tased == nil or attack_data.variant == "taser_tased" and self._char_tweak.can_be_tased then
			result_type = "taser_tased"
		elseif attack_data.variant == "counter_spooc" and not self._unit:base():has_tag("tank") or attack_data.variant == "counter_spooc" and not self._unit:base():has_tag("boss") then
			result_type = "expl_hurt"
		else
			result_type = self:get_damage_type(damage_effect_percent, "melee", attack_data)
		end

		if result_type == "taser_tased" and not self._unit:base():has_tag("shield") then --shields get tased as usual, other enemies get tased similarly to bots
			result_type = "hurt"
			variant = nil
			attack_data.variant = "tase"

			if attack_data.charge_lerp_value then
				local charge_power = math.lerp(0, 1, attack_data.charge_lerp_value)

				damage_effect_percent = charge_power
				self._tased_time = math.lerp(1, 5, charge_power)
				self._tased_down_time = self._tased_time * 2
			else
				damage_effect_percent = 0.4 --used for syncing purposes
				self._tased_time = 2
				self._tased_down_time = self._tased_time * 2
			end
		end

		result = {
			type = result_type,
			variant = variant
		}

		self:_apply_damage_to_health(damage)
	end

	attack_data.result = result
	attack_data.pos = attack_data.col_ray.position
	local snatch_pager = false

	if result.type == "death" then
		local data = {
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			head_shot = head,
			weapon_unit = attack_data.weapon_unit,
			name_id = attack_data.name_id,
			variant = attack_data.variant
		}

		managers.statistics:killed_by_anyone(data)

		if attack_data.attacker_unit == managers.player:player_unit() then
			local special_comment = self:_check_special_death_conditions(attack_data.variant, attack_data.col_ray.body, attack_data.attacker_unit, attack_data.name_id)

			self:_comment_death(attack_data.attacker_unit, self._unit, special_comment)
			self:_show_death_hint(self._unit:base()._tweak_table)
			managers.statistics:killed(data)

			if not is_civlian and managers.groupai:state():whisper_mode() and managers.blackmarket:equipped_mask().mask_id == tweak_data.achievement.cant_hear_you_scream.mask then
				managers.achievment:award_progress(tweak_data.achievement.cant_hear_you_scream.stat)
			end

			if is_cop and Global.game_settings.level_id == "nightclub" and attack_data.name_id and attack_data.name_id == "fists" then
				managers.achievment:award_progress(tweak_data.achievement.final_rule.stat)
			end

			if is_civlian then
				managers.money:civilian_killed()
			else
				mvec3_set(mvec_1, self._unit:position())
				mvec3_sub(mvec_1, attack_data.attacker_unit:position())
				mvec3_norm(mvec_1)
				mvec3_set(mvec_2, self._unit:rotation():y())

				local from_behind = mvec3_dot(mvec_1, mvec_2) >= 0

				if self._unit:movement():cool() and from_behind then
					snatch_pager = true
					self._unit:unit_data().has_alarm_pager = false
				end
			end
		elseif managers.groupai:state():is_unit_team_AI(attack_data.attacker_unit) then
			local special_comment = self:_check_special_death_conditions(attack_data.variant, attack_data.col_ray.body, attack_data.attacker_unit, attack_data.name_id)

			self:_AI_comment_death(attack_data.attacker_unit, self._unit, special_comment)
		end
	end

	if attack_data.attacker_unit == managers.player:player_unit() and tweak_data.blackmarket.melee_weapons[attack_data.name_id] then
		local achievements = tweak_data.achievement.enemy_melee_hit_achievements or {}
		local melee_type = tweak_data.blackmarket.melee_weapons[attack_data.name_id].type
		local enemy_base = self._unit:base()
		local enemy_movement = self._unit:movement()
		local enemy_type = enemy_base._tweak_table
		local unit_weapon = enemy_base._default_weapon_id
		local health_ratio = managers.player:player_unit():character_damage():health_ratio() * 100
		local melee_pass, melee_weapons_pass, type_pass, enemy_pass, enemy_weapon_pass, diff_pass, health_pass, level_pass, job_pass, jobs_pass, enemy_count_pass, tags_all_pass, tags_any_pass, all_pass, cop_pass, gangster_pass, civilian_pass, stealth_pass, on_fire_pass, behind_pass, result_pass, mutators_pass, critical_pass, action_pass, is_dropin_pass = nil

		for achievement, achievement_data in pairs(achievements) do
			melee_pass = not achievement_data.melee_id or achievement_data.melee_id == attack_data.name_id
			melee_weapons_pass = not achievement_data.melee_weapons or table.contains(achievement_data.melee_weapons, attack_data.name_id)
			type_pass = not achievement_data.melee_type or melee_type == achievement_data.melee_type
			result_pass = not achievement_data.result or attack_data.result.type == achievement_data.result
			enemy_pass = not achievement_data.enemy or enemy_type == achievement_data.enemy
			enemy_weapon_pass = not achievement_data.enemy_weapon or unit_weapon == achievement_data.enemy_weapon
			behind_pass = not achievement_data.from_behind or from_behind
			diff_pass = not achievement_data.difficulty or table.contains(achievement_data.difficulty, Global.game_settings.difficulty)
			health_pass = not achievement_data.health or health_ratio <= achievement_data.health
			level_pass = not achievement_data.level_id or (managers.job:current_level_id() or "") == achievement_data.level_id
			job_pass = not achievement_data.job or managers.job:current_real_job_id() == achievement_data.job
			jobs_pass = not achievement_data.jobs or table.contains(achievement_data.jobs, managers.job:current_real_job_id())
			enemy_count_pass = not achievement_data.enemy_kills or achievement_data.enemy_kills.count <= managers.statistics:session_enemy_killed_by_type(achievement_data.enemy_kills.enemy, "melee")
			tags_all_pass = not achievement_data.enemy_tags_all or enemy_base:has_all_tags(achievement_data.enemy_tags_all)
			tags_any_pass = not achievement_data.enemy_tags_any or enemy_base:has_any_tag(achievement_data.enemy_tags_any)
			cop_pass = not achievement_data.is_cop or is_cop
			gangster_pass = not achievement_data.is_gangster or is_gangster
			civilian_pass = not achievement_data.is_not_civilian or not is_civlian
			stealth_pass = not achievement_data.is_stealth or managers.groupai:state():whisper_mode()
			on_fire_pass = not achievement_data.is_on_fire or managers.fire:is_set_on_fire(self._unit)
			is_dropin_pass = achievement_data.is_dropin == nil or achievement_data.is_dropin == managers.statistics:is_dropin()

			if achievement_data.enemies then
				enemy_pass = false

				for _, enemy in pairs(achievement_data.enemies) do
					if enemy == enemy_type then
						enemy_pass = true

						break
					end
				end
			end

			mutators_pass = managers.mutators:check_achievements(achievement_data)
			critical_pass = not achievement_data.critical

			if achievement_data.critical then
				critical_pass = attack_data.critical_hit
			end

			action_pass = true

			if achievement_data.action then
				local action = enemy_movement:get_action(achievement_data.action.body_part)
				local action_type = action and action:type()
				action_pass = action_type == achievement_data.action.type
			end

			all_pass = melee_pass and melee_weapons_pass and type_pass and enemy_pass and enemy_weapon_pass and behind_pass and diff_pass and health_pass and level_pass and job_pass and jobs_pass and cop_pass and gangster_pass and civilian_pass and stealth_pass and on_fire_pass and enemy_count_pass and tags_all_pass and tags_any_pass and result_pass and mutators_pass and critical_pass and action_pass and is_dropin_pass

			if all_pass then
				if achievement_data.stat then
					managers.achievment:award_progress(achievement_data.stat)
				elseif achievement_data.award then
					managers.achievment:award(achievement_data.award)
				elseif achievement_data.challenge_stat then
					managers.challenge:award_progress(achievement_data.challenge_stat)
				elseif achievement_data.trophy_stat then
					managers.custom_safehouse:award(achievement_data.trophy_stat)
				elseif achievement_data.challenge_award then
					managers.challenge:award(achievement_data.challenge_award)
				end
			end
		end
	end

	local attacker = attack_data.attacker_unit

	if not attacker or attacker and alive(attacker) and attacker:id() == -1 then
		attack_data.attacker_unit = self._unit
	end

	local hit_offset_height = math.clamp(attack_data.col_ray.position.z - self._unit:movement():m_pos().z, 0, 300)
	local variant = nil

	--all variants added to properly sync them, this can even be used with players that don't have the proper sync_damage_melee code as the vanilla numbers remain unchanged
	if result.type == "shield_knock" then
		variant = 1
	elseif result.type == "counter_tased" then
		variant = 2
	elseif result.type == "expl_hurt" then
		variant = 4
	elseif snatch_pager then
		variant = 3
	elseif result.type == "taser_tased" then
		variant = 5
	--[[elseif dismember_victim then
		variant = 6]]
	elseif result.type == "hurt" then
		if attack_data.variant == "tase" then
			variant = 8
		else
			variant = 9
		end
	elseif result.type == "heavy_hurt" then
		variant = 10
	elseif result.type == "light_hurt" then
		variant = 11
	elseif result.type == "dmg_rcv" then --important, need to sync if there's no reaction
		variant = 12
	elseif result.type == "healed" then
		variant = 7
	else
		variant = 0
	end

	local body_index = self._unit:get_body_index(attack_data.col_ray.body:name())

	self:_send_melee_attack_result(attack_data, damage_percent, damage_effect_percent, hit_offset_height, variant, body_index)
	self:_on_damage_received(attack_data)

	return result
end

function CopDamage:sync_damage_melee(attacker_unit, damage_percent, damage_effect_percent, i_body, hit_offset_height, variant, death)
	if self._dead then
		return
	end

	local attack_data = {
		variant = "melee",
		attacker_unit = attacker_unit
	}
	local body = self._unit:body(i_body)
	local head = self._head_body_name and not self._unit:in_slot(16) and not self._char_tweak.ignore_headshot and body and body:name() == self._ids_head_body_name
	local damage = damage_percent * self._HEALTH_INIT_PRECENT
	local result = nil
	local attack_dir = nil

	if attacker_unit then
		attack_dir = self._unit:position() - attacker_unit:position()

		mvec3_norm(attack_dir)
	else
		attack_dir = -self._unit:rotation():y()
	end

	attack_data.attack_dir = attack_dir

	if death then
		if head then
			self:_spawn_head_gadget({
				position = body:position(),
				rotation = body:rotation(),
				dir = attack_dir
			})
		end

		local melee_name_id = nil
		local valid_attacker = attacker_unit and alive(attacker_unit) and attacker_unit:base()

		if valid_attacker then
			if attacker_unit:base().is_husk_player then
				local peer_id = managers.network:session():peer_by_unit(attacker_unit):id()
				local peer = managers.network:session():peer(peer_id)

				melee_name_id = peer:melee_id()
			else
				melee_name_id = attacker_unit:base().melee_weapon and attacker_unit:base():melee_weapon()
			end

			if melee_name_id then
				self:_check_special_death_conditions("melee", body, attacker_unit, melee_name_id)
			end
		end

		result = {
			variant = "melee",
			type = "death"
		}

		self:die(attack_data)
		self:chk_killshot(attacker_unit, "melee")

		local data = {
			variant = "melee",
			head_shot = false,
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name
		}

		managers.statistics:killed_by_anyone(data)
	else
		local result_type = nil

		if variant == 1 then
			result_type = "shield_knock"
		elseif variant == 2 then
			result_type = "counter_tased"
		elseif variant == 4 then
			result_type = "expl_hurt"
		elseif variant == 5 then
			result_type = "taser_tased"
		elseif variant == 8 or variant == 9 then
			result_type = "hurt"

			if variant == 8 then
				self._tased_time = math.lerp(1, 5, damage_effect_percent)
				self._tased_down_time = self._tased_time * 2
			end
		elseif variant == 10 then
			result_type = "heavy_hurt"
		elseif variant == 11 then
			result_type = "light_hurt"
		elseif variant == 12 then
			result_type = "dmg_rcv" --important, need to sync if there's no reaction
		else
			result_type = self:get_damage_type(damage_effect_percent, "melee") --to fall back in case other peers don't have the modified code
		end

		if variant == 7 then
			result_type = "healed"
		end

		result = {
			variant = variant ~= 8 and "melee",
			type = result_type
		}

		if result_type ~= "healed" then
			self:_apply_damage_to_health(damage)
		end

		attack_data.variant = variant == 8 and "tase" or result_type
	end

	attack_data.result = result
	attack_data.damage = damage
	attack_data.is_synced = true

	if variant == 3 then
		self._unit:unit_data().has_alarm_pager = false
	end

	attack_data.pos = self._unit:position()

	mvec3_set_z(attack_data.pos, attack_data.pos.z + math.random() * 180)

	if not self._no_blood and damage > 0 then
		managers.game_play_central:sync_play_impact_flesh(self._unit:movement():m_pos() + Vector3(0, 0, hit_offset_height), attack_dir)
	end

	self:_send_sync_melee_attack_result(attack_data, hit_offset_height)
	self:_on_damage_received(attack_data)
end

function CopDamage:chk_killshot(attacker_unit, variant, headshot, weapon_id)
	if attacker_unit and attacker_unit == managers.player:player_unit() then
		return managers.player:on_killshot(self._unit, variant, headshot, weapon_id)
	end
end

function CopDamage:damage_bullet(attack_data) --the bullshit i am required to do because of post-hooks not working right.
	if self._dead or self._invulnerable then
		return
	end

	local effect_to_sync = nil
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
		end

		if armor_pierce_value <= armor_pierce_roll then
			local damage = attack_data.damage
			local damage_percent = math.ceil(math.clamp(damage / self._HEALTH_INIT_PRECENT, 1, self._HEALTH_GRANULARITY))
			damage = damage_percent * self._HEALTH_INIT_PRECENT
			damage, damage_percent = self:_apply_min_health_limit(damage, damage_percent)

			local result_type = not self._char_tweak.immune_to_knock_down and (attack_data.knock_down and "knock_down" or attack_data.stagger and not self._has_been_staggered and "stagger") or self:get_damage_type(damage_percent, "bullet", attack_data)

			local result = {
				type = result_type,
				variant = attack_data.variant
			}

			local variant = nil

			if result.type == "knock_down" then
				variant = 1
			elseif result.type == "stagger" then
				variant = 2
				self._has_been_staggered = true
			elseif result.type == "healed" then
				variant = 3
			elseif result.type == "expl_hurt" then
				variant = 4
			elseif result.type == "hurt" then
				variant = 5
			elseif result.type == "heavy_hurt" then
				variant = 6
			elseif result.type == "light_hurt" then
				variant = 7
			elseif result.type == "dmg_rcv" then --important, need to sync if there's no reaction
				variant = 8
			else
				variant = 0
			end

			local body_index = self._unit:get_body_index(attack_data.col_ray.body:name())
			local hit_offset_height = math.clamp(attack_data.col_ray.position.z - self._unit:movement():m_pos().z, 0, 300)
			attack_data.result = result
			attack_data.pos = attack_data.col_ray.position
			attack_data.damage = 0
			damage = 0
			damage_percent = 0

			self:_send_bullet_attack_result(attack_data, attack_data.attacker_unit, damage_percent, body_index, hit_offset_height, variant)
			self:_on_damage_received(attack_data)

			return result
		end

		World:effect_manager():spawn({
			effect = Idstring("effects/payday2/particles/impacts/blood/blood_impact_a"),
			position = attack_data.col_ray.position,
			normal = attack_data.col_ray.ray
		})
	end
	
	local result = nil
	local body_index = self._unit:get_body_index(attack_data.col_ray.body:name())
	local head = self._head_body_name and not self._unit:in_slot(16) and not self._char_tweak.ignore_headshot and attack_data.col_ray.body and attack_data.col_ray.body:name() == self._ids_head_body_name

	--prevent headshots against these units unless shot from the front, used for bulldozers
	if head and self._unit:base():has_tag("protected") and not attack_data.weapon_unit:base().thrower_unit and not attack_data.weapon_unit:base()._can_shoot_through_wall then
		mvec3_set(mvec_1, attack_data.col_ray.body:position())
		mvec3_sub(mvec_1, attack_data.attacker_unit:position())
		mvec3_norm(mvec_1)
		mvec3_set(mvec_2, self._unit:rotation():y())

		local not_from_the_front = mvec3_dot(mvec_1, mvec_2) >= 0

		if not_from_the_front then
			head = false
		end
	end
	
	if head and self._unit:base():has_tag("protected_reverse") and not attack_data.weapon_unit:base().thrower_unit and not attack_data.weapon_unit:base()._can_shoot_through_wall then
		mvec3_set(mvec_1, attack_data.col_ray.body:position())
		mvec3_sub(mvec_1, attack_data.attacker_unit:position())
		mvec3_norm(mvec_1)
		mvec3_set(mvec_2, self._unit:rotation():y())

		local not_from_the_front = mvec3_dot(mvec_1, mvec_2) >= 0

		if not not_from_the_front then
			head = false
		end
	end

	local damage = attack_data.damage
	local headshot = false
	local headshot_multiplier = 1

	if attack_data.attacker_unit == managers.player:player_unit() then
		local critical_hit, crit_damage = self:roll_critical_hit(attack_data)

		if critical_hit then
			damage = crit_damage
			attack_data.critical_hit = true

			if damage > 0 then
				managers.hud:on_crit_confirmed()
			end
		else
			if damage > 0 then
				managers.hud:on_hit_confirmed()
			end
		end

		headshot_multiplier = managers.player:upgrade_value("weapon", "passive_headshot_damage_multiplier", 1)

		if self._char_tweak.priority_shout then
			damage = damage * managers.player:upgrade_value("weapon", "special_damage_taken_multiplier", 1)
		end

		if head then
			managers.player:on_headshot_dealt()

			headshot = true
		end
	end
	
	if is_civilian or self._unit:base():has_tag("special") or self._unit:base():has_tag("protected_reverse") then
		if self:is_friendly_fire(attack_data.attacker_unit) then
			return "friendly_fire"
		end
	elseif self:is_friendly_fire(attack_data.attacker_unit) then
		if attack_data.attacker_unit:base().has_tag and attack_data.attacker_unit:base():has_tag("tank") and not self._unit:base():has_tag("tank") and not self._unit:base():has_tag("protected_reverse") then
			attack_data.damage = attack_data.damage * 9
		end
	end

	if self._marked_dmg_mul and not self:is_friendly_fire(attack_data.attacker_unit) then --otherwise marked enemies take extra friendly fire damage
		damage = damage * self._marked_dmg_mul

		if self._marked_dmg_dist_mul then
			local dst = mvec3_dis(attack_data.origin, self._unit:position())
			local spott_dst = tweak_data.upgrades.values.player.marked_inc_dmg_distance[self._marked_dmg_dist_mul]

			if spott_dst[1] < dst then
				damage = damage * spott_dst[2]
			end
		end
	end

	if not self._damage_reduction_multiplier and head then
		if self._char_tweak.headshot_dmg_mul then
			damage = damage * self._char_tweak.headshot_dmg_mul * headshot_multiplier
		else
			damage = self._health * 10
		end
	end

	if not head and attack_data.weapon_unit:base().get_add_head_shot_mul then
		if self._char_tweak and not self._unit:base():has_tag("tank") and self._char_tweak.headshot_dmg_mul and not self._char_tweak.ignore_headshot then
			local add_head_shot_mul = attack_data.weapon_unit:base():get_add_head_shot_mul()

			if add_head_shot_mul then
				local tweak_headshot_mul = math.max(0, self._char_tweak.headshot_dmg_mul - 1)
				local mul = tweak_headshot_mul * add_head_shot_mul + 1
				damage = damage * mul
			end
		end
	end

	--moving damage reduction and clamping/insta-kill down here so that they work properly
	damage = self:_apply_damage_reduction(damage, attack_data)

	local diff_index = Global.game_settings and tweak_data:difficulty_to_index(Global.game_settings.difficulty)
	
	if head and diff_index <= 5 and self._unit:movement():cool() then
		damage = self._HEALTH_INIT
	else
		if self._char_tweak.DAMAGE_CLAMP_BULLET and not attack_data.weapon_unit:base()._can_shoot_through_wall then
			damage = math.min(damage, self._char_tweak.DAMAGE_CLAMP_BULLET)
		end
	end

	attack_data.raw_damage = damage
	attack_data.headshot = head
	local damage_percent = math.ceil(math.clamp(damage / self._HEALTH_INIT_PRECENT, 1, self._HEALTH_GRANULARITY))
	damage = damage_percent * self._HEALTH_INIT_PRECENT
	damage, damage_percent = self:_apply_min_health_limit(damage, damage_percent)
	
	if not self._resisted_death then 
		if self._char_tweak.resist_death and self._char_tweak.resist_death[attack_data.variant] then
			if damage >= self._health then
				if not attack_data.weapon_unit:base().thrower_unit and not attack_data.weapon_unit:base()._can_shoot_through_wall then 
					damage = self._health - 1
					self._resisted_death = true
						
						
					if head then
						self:_spawn_head_gadget({
							position = attack_data.col_ray.body:position(),
							rotation = attack_data.col_ray.body:rotation(),
							dir = attack_data.col_ray.ray
						})
					end
					
					world_g:effect_manager():spawn({
						effect = idstr_deathresist,
						position = attack_data.col_ray.position
					})
				end
				
				if attack_data.attacker_unit == managers.player:player_unit() then
					world_g:effect_manager():spawn({
						effect = idstr_shieldbreak,
						position = attack_data.col_ray.position,
						normal = math.UP
					})
				end
				
				self._unit:sound():play("bulldozer_visor_shatter")
				
				effect_to_sync = 3
			end
		end
	end
	
	if self._immortal then
		damage = math.min(damage, self._health - 1)
	end

	if self._health <= damage then
		attack_data.damage = self._health

		if self:check_medic_heal() then
			result = {
				type = "healed",
				variant = attack_data.variant
			}
		else
			if head then
				managers.player:on_lethal_headshot_dealt(attack_data.attacker_unit, attack_data)

				self:_spawn_head_gadget({
					position = attack_data.col_ray.body:position(),
					rotation = attack_data.col_ray.body:rotation(),
					dir = attack_data.col_ray.ray
				})
			end

			result = {
				type = "death",
				variant = attack_data.variant
			}

			self:die(attack_data)
			effect_to_sync = self:chk_killshot(attack_data.attacker_unit, "bullet", headshot)
		end
	else
		attack_data.damage = damage
		local result_type = not self._char_tweak.immune_to_knock_down and (attack_data.knock_down and "knock_down" or attack_data.stagger and not self._has_been_staggered and "stagger") or self:get_damage_type(damage_percent, "bullet", attack_data)
		result = {
			type = result_type,
			variant = attack_data.variant
		}
		
		self:_apply_damage_to_health(damage)
	end

	attack_data.result = result
	attack_data.pos = attack_data.col_ray.position

	local shotgun_push = nil
	local distance = nil

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
		else
			if managers.groupai:state():is_unit_team_AI(attack_data.attacker_unit) then
				local special_comment = self:_check_special_death_conditions(attack_data.variant, attack_data.col_ray.body, attack_data.attacker_unit, attack_data.weapon_unit)

				self:_AI_comment_death(attack_data.attacker_unit, self._unit, special_comment)
			end

			distance = mvec3_dis(attack_data.origin, attack_data.col_ray.position)

			if not attack_data.weapon_unit:base().thrower_unit and attack_data.weapon_unit:base():is_category("shotgun") and distance and distance < ((attack_data.attacker_unit:base() and attack_data.attacker_unit:base().is_husk_player or managers.groupai:state():is_unit_team_AI(attack_data.attacker_unit)) and managers.game_play_central:get_shotgun_push_range() or 500) then
				shotgun_push = true
			end
		end
	end
	
	local hit_offset_height = effect_to_sync or 0

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
	elseif result.type == "expl_hurt" then
		variant = 4
	elseif result.type == "hurt" then
		variant = 5
	elseif result.type == "heavy_hurt" then
		variant = 6
	elseif result.type == "light_hurt" then
		variant = 7
	elseif result.type == "dmg_rcv" then --important, need to sync if there's no reaction
		variant = 8
	else
		variant = 0
	end

	self:_send_bullet_attack_result(attack_data, attacker, damage_percent, body_index, hit_offset_height, variant)
	self:_on_damage_received(attack_data)

	if shotgun_push then
		managers.game_play_central:_do_shotgun_push(self._unit, attack_data.col_ray.position, attack_data.col_ray.ray, distance, attack_data.attacker_unit)
	end

	if not is_civilian then
		managers.player:send_message(Message.OnEnemyShot, nil, self._unit, attack_data)
	end

	result.attack_data = attack_data

	return result
end

function CopDamage:roll_critical_hit(attack_data)
	local damage = attack_data.damage

	if not self:can_be_critical(attack_data) then
		return false, damage
	end

	local critical_hits = self._char_tweak.critical_hits or {}
	local critical_hit = false
	local critical_value = (critical_hits.base_chance or 0) + managers.player:critical_hit_chance() * (critical_hits.player_chance_multiplier or 1)

	if critical_value > 0 then
		local critical_roll = math.rand(1)
		critical_hit = critical_roll < critical_value
	end
	
	--local testing = true
	
	if testing then
		critical_hit = true
	end
	
	local damage_multiplier = 1.5
	
	if managers.player:has_category_upgrade("player", "crit_damage_up") then
		damage_multiplier = damage_multiplier + 1.5
		--log("poggers")
	end
	
	if critical_hit then
		damage = damage * damage_multiplier
		--log("damage is " .. damage .. ".")
	end

	return critical_hit, damage
end

function CopDamage:offset_sync(index)
	--log("executed")
	local pos = pos or Vector3()
	
	if index == 1 then --fine red mist basic	
		--log("index 1")
		if self._dead then
			local obj = self._unit:get_object(Idstring("Head"))
			obj:m_position(pos)
		else
			mvec3_set(pos, self._unit:movement():m_head_pos())
		end
		
		world_g:effect_manager():spawn({
			effect = idstr_gore,
			position = pos,
			normal = math.UP
		})
		
		self._unit:sound():play("expl_gen_head", nil, nil)
	elseif index == 2 then --fine red mist aced
		--log("index 2")
		if self._dead then
			local obj = self._unit:get_object(Idstring("Head"))
			obj:m_position(pos)
		else
			mvec3_set(pos, self._unit:movement():m_head_pos())
		end
	
		world_g:effect_manager():spawn({
			effect = idstr_gore,
			position = pos,
			normal = math.UP
		})
		
		self._unit:sound():play("expl_gen_head", nil, nil)
		self._unit:sound():play("split_gen_body", nil, nil) --play both of these at once if aced for extra impact
	elseif index == 3 then
		self._resisted_death = true
		
		self._unit:sound():play("bulldozer_visor_shatter", nil, nil)
	end
end

function CopDamage:sync_damage_bullet(attacker_unit, damage_percent, i_body, hit_offset_height, variant, death)
	--log("it starts here")
	self:offset_sync(hit_offset_height)

	if self._dead then
		--log("it stops here")
		return
	end

	local body = self._unit:body(i_body)
	local head = self._head_body_name and not self._unit:in_slot(16) and not self._char_tweak.ignore_headshot and body and body:name() == self._ids_head_body_name
	local damage = damage_percent * self._HEALTH_INIT_PRECENT
	local attack_data = {}
	local hit_pos = mvec3_copy(body:center_of_mass())
	--local hit_pos = mvector3.copy(self._unit:movement():m_pos())

	--mvector3.set_z(hit_pos, hit_pos.z + hit_offset_height)

	attack_data.pos = hit_pos
	attack_data.attacker_unit = attacker_unit
	attack_data.variant = "bullet"
	local attack_dir, distance = nil
	
	--self:play_offset_effects(hit_offset_height)

	if attacker_unit then
		local from_pos = attacker_unit:movement().m_detect_pos and attacker_unit:movement():m_detect_pos() or attacker_unit:movement():m_head_pos()

		attack_dir = hit_pos - from_pos
		distance = mvec3_norm(attack_dir)
	else
		attack_dir = self._unit:rotation():y()
	end

	attack_data.attack_dir = attack_dir
	local shotgun_push, result = nil
	
	if hit_offset_height == 3 then
		if head then
			self:_spawn_head_gadget({
				position = body:position(),
				rotation = body:rotation(),
				dir = attack_dir
			})
		end

		world_g:effect_manager():spawn({
			effect = idstr_shieldbreak,
			position = hit_pos,
			normal = math.UP
		})
	end
	
	if death then
		if head then
			self:_spawn_head_gadget({
				position = body:position(),
				rotation = body:rotation(),
				dir = attack_dir
			})
		end

		result = {
			variant = "bullet",
			type = "death"
		}

		self:die(attack_data)
		self:chk_killshot(attacker_unit, "bullet")

		local data = {
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			head_shot = head,
			weapon_unit = attacker_unit and attacker_unit:inventory() and attacker_unit:inventory():equipped_unit(),
			variant = attack_data.variant
		}

		if data.weapon_unit then
			self:_check_special_death_conditions("bullet", body, attacker_unit, data.weapon_unit)
			managers.statistics:killed_by_anyone(data)

			if distance and managers.enemy:is_corpse_disposal_enabled() and not data.weapon_unit:base().thrower_unit and data.weapon_unit:base().is_category and data.weapon_unit:base():is_category("shotgun") then
				local negate_push = nil

				if data.weapon_unit:base()._parts then
					for part_id, part in pairs(data.weapon_unit:base()._parts) do
						if tweak_data.weapon.factory.parts[part_id].custom_stats and tweak_data.weapon.factory.parts[part_id].custom_stats.rays == 1 then
							negate_push = true

							break
						end
					end
				end

				if not negate_push then
					local max_distance = 500

					if attacker_unit:base() then
						if attacker_unit:base().is_husk_player or managers.groupai:state():is_unit_team_AI(attacker_unit) then
							max_distance = managers.game_play_central:get_shotgun_push_range()
						end
					end

					if distance < max_distance then
						shotgun_push = true
					end
				end
			end
		end
	else
		local result_type = nil

		if variant == 1 then
			result_type = "knock_down"
		elseif variant == 2 then
			result_type = "stagger"
		elseif variant == 4 then
			result_type = "expl_hurt"
		elseif variant == 5 then
			result_type = "hurt"
		elseif variant == 6 then
			result_type = "heavy_hurt"
		elseif variant == 7 then
			result_type = "light_hurt"
		elseif variant == 8 then
			result_type = "dmg_rcv" --important, need to sync if there's no reaction
		else
			result_type = self:get_damage_type(damage_percent, "bullet", attack_data) --to fall back in case other peers don't have the modified code
		end

		if variant == 3 then
			result_type = "healed"
		end

		result = {
			variant = "bullet",
			type = result_type
		}

		if result_type ~= "healed" then
			self:_apply_damage_to_health(damage)
		end
	end

	attack_data.variant = "bullet"
	attack_data.attacker_unit = attacker_unit
	attack_data.result = result
	attack_data.damage = damage
	attack_data.is_synced = true

	if not self._no_blood and damage > 0 then
		managers.game_play_central:sync_play_impact_flesh(hit_pos, attack_dir)
	end

	self:_send_sync_bullet_attack_result(attack_data, hit_offset_height)
	self:_on_damage_received(attack_data)

	if shotgun_push then
		local push_dir = attack_dir
		local push_hit_pos = hit_pos

		if attacker_unit and alive(attacker_unit) then
			if attacker_unit:movement() and attacker_unit:movement().detect_look_dir then
				push_dir = attacker_unit:movement():detect_look_dir()
			end

			local from_pos = attacker_unit:movement().m_detect_pos and attacker_unit:movement():m_detect_pos() or attacker_unit:movement():m_head_pos()
			local hit_ray = World:raycast("ray", from_pos, body:center_of_mass(), "target_body", body)

			if hit_ray then
				push_hit_pos = hit_ray.position
			end
		end

		managers.game_play_central:_do_shotgun_push(self._unit, push_hit_pos, push_dir, distance, attacker_unit)
	end
end

function CopDamage:damage_simple(attack_data)
	if self._dead or self._invulnerable then
		return
	end

	local is_civilian = CopDamage.is_civilian(self._unit:base()._tweak_table)
	local result = nil
	local damage = attack_data.damage

	damage = self:_apply_damage_reduction(damage, attack_data) --they also forgot to add this one
	
	--Graze damage is supposed to not benefit from any damage bonuses (as the damage is defined by the shot and skill upgrade you have), but it's not supposed to not be clamped like in vanilla, where everything can get nuked by it
	if self._unit:movement():cool() and damage > 0 then --allowing stealth insta-kill
		damage = self._HEALTH_INIT
	else
		if self._char_tweak.DAMAGE_CLAMP_SHOCK then --no unit has DAMAGE_CLAMP_SHOCK, which is why Winters and the Phalanx can all die instantly to one headshot-proced Graze attack in vanilla
			damage = math.min(damage, self._char_tweak.DAMAGE_CLAMP_SHOCK)
		elseif self._char_tweak.DAMAGE_CLAMP_BULLET then --I would just replace the shock check with the bullet one, but checking for it first allows a custom clamp specifically against Graze to be used
			damage = math.min(damage, self._char_tweak.DAMAGE_CLAMP_BULLET)
		end
	end

	damage = math.clamp(damage, 0, self._HEALTH_INIT)
	local damage_percent = math.ceil(damage / self._HEALTH_INIT_PRECENT)
	damage = damage_percent * self._HEALTH_INIT_PRECENT
	damage, damage_percent = self:_apply_min_health_limit(damage, damage_percent)

	if self._immortal then --but somehow didn't forget this one
		damage = math.min(damage, self._health - 1)
	end

	if self._health <= damage then
		attack_data.damage = self._health

		if self:check_medic_heal() then
			attack_data.variant = "healed"
			result = {
				type = "healed",
				variant = attack_data.variant
			}
		else
			result = {
				type = "death",
				variant = attack_data.variant
			}

			self:die(attack_data)
		end
	else
		attack_data.damage = damage

		--allowing knock_down and stagger, explanation at the end of the function
		local weapon_unit = attack_data.attacker_unit and attack_data.attacker_unit:inventory() and attack_data.attacker_unit:inventory():equipped_unit()
		local knock_down = weapon_unit and weapon_unit:base()._knock_down and weapon_unit:base()._knock_down > 0 and math.random() < weapon_unit:base()._knock_down or attack_data.guaranteed_knockdown
		local stagger = weapon_unit and weapon_unit:base()._stagger or attack_data.guaranteed_stagger
		local result_type = not self._char_tweak.immune_to_knock_down and (knock_down and "knock_down" or stagger and not self._has_been_staggered and "stagger") or self:get_damage_type(damage_percent, nil, attack_data)

		result = {
			type = result_type,
			variant = attack_data.variant
		}

		self:_apply_damage_to_health(damage)
	end

	attack_data.result = result
	local attacker = attack_data.attacker_unit

	if not attacker or attacker:id() == -1 then
		attacker = self._unit
	end

	if result.type == "death" then
		local data = {
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			owner = attack_data.owner,
			weapon_unit = attack_data.weapon_unit,
			variant = attack_data.variant
		}

		managers.statistics:killed_by_anyone(data)

		local attacker_unit = attack_data.attacker_unit

		if attacker_unit and attacker_unit:base() and attacker_unit:base().thrower_unit then
			attacker_unit = attacker_unit:base():thrower_unit()
			data.weapon_unit = attack_data.attacker_unit
		end

		if not is_civilian and managers.player:has_category_upgrade("temporary", "overkill_damage_multiplier") and attacker_unit == managers.player:player_unit() and attack_data.weapon_unit and attack_data.weapon_unit:base().weapon_tweak_data and not attack_data.weapon_unit:base().thrower_unit and attack_data.weapon_unit:base():is_category("shotgun", "saw") then
			managers.player:activate_temporary_upgrade("temporary", "overkill_damage_multiplier")
		end

		self:chk_killshot(attacker_unit, "shock")

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
			if attacker_unit and alive(attacker_unit) and managers.groupai:state():is_unit_team_AI(attacker_unit) then --no harm in doing it
				self:_AI_comment_death(attacker_unit, self._unit)
			end
		end
	end

	if not self._no_blood and damage > 0 then
		managers.game_play_central:sync_play_impact_flesh(attack_data.pos, attack_data.attack_dir)
	end

	local i_result = nil

	--proper variants (or i_results), whatever this section was supposed to work like in the original file, it's obvious that knock_down and stagger were intended to work with it. If not, somehow, at least syncing the other results should still be done
	if result.type == "knock_down" then
		i_result = 1
	elseif result.type == "stagger" then
		i_result = 2
		self._has_been_staggered = true
	elseif result.type == "healed" then
		i_result = 3
	elseif result.type == "expl_hurt" then
		i_result = 4
	elseif result.type == "hurt" then
		i_result = 5
	elseif result.type == "heavy_hurt" then
		i_result = 6
	elseif result.type == "light_hurt" then
		i_result = 7
	elseif result.type == "dmg_rcv" then --important, need to sync if there's no reaction
		i_result = 8
	else
		i_result = 0
	end

	self:_send_simple_attack_result(attacker, damage_percent, self:_get_attack_variant_index(attack_data.result.variant), i_result)
	self:_on_damage_received(attack_data)

	if not is_civilian and attack_data.attacker_unit and alive(attack_data.attacker_unit) then
		managers.player:send_message(Message.OnEnemyShot, nil, self._unit, attack_data)
	end

	return result
end

function CopDamage:sync_damage_simple(attacker_unit, damage_percent, i_attack_variant, i_result, death)
	if self._dead then
		return
	end

	local damage = damage_percent * self._HEALTH_INIT_PRECENT
	local attack_data = {}
	local hit_pos = mvec3_copy(self._unit:movement():m_pos())

	mvec3_set_z(hit_pos, hit_pos.z + 100)

	local variant = CopDamage._ATTACK_VARIANTS[i_attack_variant]
	attack_data.pos = hit_pos
	attack_data.attacker_unit = attacker_unit
	attack_data.variant = variant
	local attack_dir, distance = nil

	if attacker_unit then
		attack_dir = hit_pos - attacker_unit:movement():m_head_pos()
		distance = mvec3_norm(attack_dir)
	else
		attack_dir = self._unit:rotation():y()
	end

	attack_data.attack_dir = attack_dir
	local result = nil

	if death then
		result = {
			type = "death",
			variant = variant
		}

		self:die(attack_data)
		self:chk_killshot(attacker_unit, variant)

		local data = {
			head_shot = false,
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			weapon_unit = attacker_unit and attacker_unit:inventory() and attacker_unit:inventory():equipped_unit(),
			variant = attack_data.variant
		}

		if data.weapon_unit then
			managers.statistics:killed_by_anyone(data)
		end
	else
		local result_type = nil

		if i_result == 1 then
			result_type = "knock_down"
		elseif i_result == 2 then
			result_type = "stagger"
		elseif i_result == 4 then
			result_type = "expl_hurt"
		elseif i_result == 5 then
			result_type = "hurt"
		elseif i_result == 6 then
			result_type = "heavy_hurt"
		elseif i_result == 7 then
			result_type = "light_hurt"
		elseif i_result == 8 then
			result_type = "dmg_rcv" --important, need to sync if there's no reaction
		else
			result_type = self:get_damage_type(damage_percent, nil) --to fall back in case other peers don't have the modified code
		end

		if i_result == 3 then
			result_type = "healed"
		end

		result = {
			type = result_type,
			variant = variant
		}

		if result_type ~= "healed" then
			self:_apply_damage_to_health(damage)
		end
	end

	attack_data.result = result
	attack_data.damage = damage
	attack_data.is_synced = true

	if not self._no_blood and damage > 0 then
		managers.game_play_central:sync_play_impact_flesh(hit_pos, attack_dir)
	end

	self:_on_damage_received(attack_data)
end

function CopDamage:stun_hit(attack_data)
	local anim_data = self._unit:anim_data()

	if self._dead or self._invulnerable or (anim_data and (anim_data.act or anim_data.surrender or anim_data.hands_back or anim_data.hands_tied)) then --dead, invulnerable, is acting or is intimidated
		return
	end

	local is_civilian = CopDamage.is_civilian(self._unit:base()._tweak_table)
	local attacker = attack_data.attacker_unit
	local valid_attacker = attacker and alive(attacker) and attacker.base and attacker:base() and attacker.movement and attacker:movement() --with how user/owner assigning works with grenades, just gotta make sure

	if not is_civilian and valid_attacker and self:is_friendly_fire(attacker) then --do not stun teammates and affect civilians regardless so that they drop the ground (even if that's clunky, I might rewrite it)
		return "friendly_fire"
	end

	local result = {
		type = "concussion",
		variant = attack_data.variant
	}
	attack_data.result = result
	attack_data.pos = attack_data.col_ray.position
	local damage_percent = 0

	self:_send_stun_attack_result(attacker, damage_percent, self:_get_attack_variant_index(attack_data.result.variant), attack_data.col_ray.ray)
	self:_on_damage_received(attack_data)
	self:_create_stun_exit_clbk()

	if not is_civilian and valid_attacker then
		managers.player:send_message(Message.OnEnemyShot, nil, self._unit, attack_data)
	end

	return result
end

function CopDamage:sync_damage_stun(attacker_unit, damage_percent, i_attack_variant, death, direction)
	if self._dead then
		return
	end

	local variant = CopDamage._ATTACK_VARIANTS[i_attack_variant]
	local damage = damage_percent * self._HEALTH_INIT_PRECENT
	local attack_data = {
		variant = variant,
		attacker_unit = attacker_unit
	}
	local result = nil
	local result_type = "concussion"
	result = {
		type = result_type,
		variant = variant
	}
	attack_data.result = result
	attack_data.damage = damage
	attack_data.is_synced = true
	local attack_dir = nil

	if direction then
		attack_dir = direction
	elseif attacker_unit then
		attack_dir = self._unit:position() - attacker_unit:position()

		mvec3_norm(attack_dir)
	else
		attack_dir = self._unit:rotation():y()
	end

	attack_data.attack_dir = attack_dir

	if attack_data.attacker_unit and alive(attack_data.attacker_unit) and attack_data.attacker_unit == managers.player:player_unit() then
		if damage > 0 then
			managers.hud:on_hit_confirmed()
		end
	end

	attack_data.pos = self._unit:position()

	mvec3_set_z(attack_data.pos, attack_data.pos.z + math.random() * 180)
	self:_on_damage_received(attack_data)
	self:_create_stun_exit_clbk()
end

function CopDamage:damage_fire(attack_data)
	if self._dead or self._invulnerable then
		return
	end

	local valid_attacker = attack_data.attacker_unit and alive(attack_data.attacker_unit)

	if valid_attacker and self:is_friendly_fire(attack_data.attacker_unit) then
		return "friendly_fire"
	end

	local is_civilian = CopDamage.is_civilian(self._unit:base()._tweak_table)

	local result = nil
	
	local damage = attack_data.damage

	if attack_data.attacker_unit == managers.player:player_unit() then
		if attack_data.weapon_unit and attack_data.variant ~= "stun" and not attack_data.is_fire_dot_damage then
			if damage > 0 then
				managers.hud:on_hit_confirmed()
			end
		end

		if self._char_tweak.priority_shout then
			damage = damage * managers.player:upgrade_value("weapon", "special_damage_taken_multiplier", 1)
		end
	end

	if self._marked_dmg_mul then
		damage = damage * self._marked_dmg_mul

		if not attack_data.is_fire_dot_damage and self._marked_dmg_dist_mul then
			local attacking_unit = attack_data.attacker_unit

			if attacking_unit and attacking_unit:base() and attacking_unit:base().thrower_unit then
				attacking_unit = attacking_unit:base():thrower_unit()
			end

			if alive(attacking_unit) then
				local dst = mvec3_dis(attacking_unit:position(), self._unit:position())
				local spott_dst = tweak_data.upgrades.values.player.marked_inc_dmg_distance[self._marked_dmg_dist_mul]

				if spott_dst[1] < dst then
					damage = damage * spott_dst[2]
				end
			end
		end
	end
	
	if self._unit:base():char_tweak().fire_damage_mul and attack_data.use_damage_mul and not attack_data.is_fire_dot_damage then
		damage = damage * self._unit:base():char_tweak().fire_damage_mul
	end

	damage = self:_apply_damage_reduction(damage, attack_data)

	if self._unit:base():char_tweak().DAMAGE_CLAMP_FIRE and not attack_data.is_fire_dot_damage then
		damage = math.min(damage, self._unit:base():char_tweak().DAMAGE_CLAMP_FIRE)
	end
	
	if self._unit:base():char_tweak().DAMAGE_CLAMP_FIREDOT and attack_data and attack_data.is_fire_dot_damage then
		damage = math.min(damage, self._unit:base():char_tweak().DAMAGE_CLAMP_FIREDOT)
	end

	damage = math.clamp(damage, 0, self._HEALTH_INIT)
	local damage_percent = math.ceil(damage / self._HEALTH_INIT_PRECENT)
	damage = damage_percent * self._HEALTH_INIT_PRECENT
	damage, damage_percent = self:_apply_min_health_limit(damage, damage_percent)

	if self._immortal then
		damage = math.min(damage, self._health - 1)
	end

	if self._health <= damage then
		attack_data.damage = self._health

		if self:check_medic_heal() then
			result = {
				type = "healed",
				variant = attack_data.variant
			}
		else
			result = {
				type = "death",
				variant = attack_data.variant
			}

			self:die(attack_data)
			self:chk_killshot(attack_data.attacker_unit, "fire")
		end
	else
		attack_data.damage = damage
		local result_type = nil
		
		if self._char_tweak.damage.doom_hurt_type then
			result_type = self:determine_doom_hurt_type(attack_data)
		elseif attack_data.variant == "stun" then
			result_type = "hurt_sick"
		else
			result_type = self:get_damage_type(damage_percent, "fire", attack_data)
		end
		
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
		if self._head_body_name and attack_data.variant ~= "stun" then
			local body = self._unit:body(self._head_body_name)

			self:_spawn_head_gadget({
				skip_push = true,
				position = body:position(),
				rotation = body:rotation()
			})
		end

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
			distance = mvec3_dis(hit_loc, attacker_unit:position())
		end

		local fire_dot_max_distance = 3000
		local fire_dot_trigger_chance = 15
		local dot_damage = fire_dot_data and fire_dot_data.dot_damage or 25

		if fire_dot_data then
			fire_dot_max_distance = tonumber(fire_dot_data.dot_trigger_max_distance)
			fire_dot_trigger_chance = tonumber(fire_dot_data.dot_trigger_chance)
			
			if attack_data.attacker_unit and alive(attack_data.attacker_unit) and attack_data.attacker_unit:base()._grenade_entry == "molotov" or attack_data.is_molotov then
				--grenade, DoT unchanged
			elseif alive(attack_data.weapon_unit) and attack_data.weapon_unit:base()._name_id ~= nil and tweak_data.weapon[attack_data.weapon_unit:base()._name_id] ~= nil and tweak_data.weapon[attack_data.weapon_unit:base()._name_id].fire_dot_data ~= nil then
				dot_damage = (damage / dot_damage) * 200 --flamethrower, scale DoT damage depending on the total damage dealt through direct (impact) fire damage
				--usual dot_damage is 30
			elseif alive(attack_data.weapon_unit) and attack_data.weapon_unit:base()._parts then
				for part_id, part in pairs(attack_data.weapon_unit:base()._parts) do
					if tweak_data.weapon.factory.parts[part_id].custom_stats and tweak_data.weapon.factory.parts[part_id].custom_stats.fire_dot_data then
						dot_damage = dot_damage * damage * 0.01 --Dragon's Breath rounds, scale DoT damage depending on the total damage dealt through direct (impact) fire damage
						--usual dot_damage is 10
					end
				end
			end
		end

		local start_dot_damage_roll = math.random(1, 100)
		local start_dot_dance_antimation = false

		if flammable and not attack_data.is_fire_dot_damage and distance < fire_dot_max_distance and start_dot_damage_roll <= fire_dot_trigger_chance then
			managers.fire:add_doted_enemy(self._unit, TimerManager:game():time(), attack_data.weapon_unit, fire_dot_data.dot_length, dot_damage, attack_data.attacker_unit, attack_data.is_molotov)
			
			local can_do_fire_dance = char_tweak.use_animation_on_fire_damage ~= false
			
			if attack_data.result.type == "fire_hurt" and can_do_fire_dance then --i already calculate the result before this
				start_dot_dance_antimation = true
			end
		end

		if fire_dot_data then
			fire_dot_data.start_dot_dance_antimation = start_dot_dance_antimation
			attack_data.fire_dot_data = fire_dot_data
		end

		if attack_data.result.type == "fire_hurt" and not start_dot_dance_antimation then --prevent fire_hurt from micro-stunning enemies when the dance animation isn't proced
			attack_data.result.type = "dmg_rcv"
		end
	else	
		if attack_data.result.type == "fire_hurt" then --DoT never triggers an animation so it shouldn't constantly micro-stun enemies that are vulnerable to fire
			attack_data.result.type = "dmg_rcv"
		end
	end

	self:_send_fire_attack_result(attack_data, attacker, damage_percent, attack_data.is_fire_dot_damage, attack_data.col_ray.ray, attack_data.result.type == "healed")
	self:_on_damage_received(attack_data)

	if not attack_data.is_fire_dot_damage and not is_civilian and attack_data.attacker_unit and alive(attack_data.attacker_unit) then
		managers.player:send_message(Message.OnEnemyShot, nil, self._unit, attack_data)
	end

	return result
end

function CopDamage:sync_damage_fire(attacker_unit, damage_percent, start_dot_dance_antimation, death, direction, weapon_type, weapon_id, healed)
	if self._dead then
		return
	end

	local variant = "fire"
	local damage = damage_percent * self._HEALTH_INIT_PRECENT
	local is_fire_dot_damage = false
	local attack_data = {
		variant = variant,
		attacker_unit = attacker_unit,
		weapon_unit = attacker_unit and attacker_unit:inventory() and attacker_unit:inventory():equipped_unit()
	}
	local result = nil

	if weapon_type then
		local fire_dot = nil

		if weapon_type == CopDamage.WEAPON_TYPE_GRANADE then
			fire_dot = tweak_data.projectiles[weapon_id].fire_dot_data
		elseif weapon_type == CopDamage.WEAPON_TYPE_BULLET then
			if tweak_data.weapon.factory.parts[weapon_id].custom_stats then
				fire_dot = tweak_data.weapon.factory.parts[weapon_id].custom_stats.fire_dot_data
			end
		elseif weapon_type == CopDamage.WEAPON_TYPE_FLAMER and tweak_data.weapon[weapon_id].fire_dot_data then
			fire_dot = tweak_data.weapon[weapon_id].fire_dot_data
		end

		attack_data.fire_dot_data = fire_dot

		if attack_data.fire_dot_data then
			attack_data.fire_dot_data.start_dot_dance_antimation = start_dot_dance_antimation
		end
	end

	if death then
		result = {
			type = "death",
			variant = variant
		}

		self:die(attack_data)
		self:chk_killshot(attacker_unit, "fire")

		local data = {
			variant = "fire",
			head_shot = false,
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			weapon_unit = attacker_unit and attacker_unit:inventory() and attacker_unit:inventory():equipped_unit(),
			is_molotov = weapon_id == "molotov"
		}

		managers.statistics:killed_by_anyone(data)
	else
		local result_type = nil

		if start_dot_dance_antimation then
			result_type = "fire_hurt"
		else
			result_type = "dmg_rcv"
		end

		if healed then
			result_type = "healed"
		end

		result = {
			variant = "fire",
			type = result_type
		}

		if result_type ~= "healed" then
			self:_apply_damage_to_health(damage)
		end
	end

	attack_data.result = result
	attack_data.damage = damage
	attack_data.ignite_character = true
	attack_data.is_fire_dot_damage = is_fire_dot_damage
	attack_data.is_synced = true
	local attack_dir = nil

	if direction then
		attack_dir = direction
	elseif attacker_unit then
		attack_dir = self._unit:position() - attacker_unit:position()

		mvec3_norm(attack_dir)
	else
		attack_dir = self._unit:rotation():y()
	end

	attack_data.attack_dir = attack_dir

	if result.type == "death" then
		if self._head_body_name then --should be here to avoid popping helmets/hats on any synced fire damage
			local body = self._unit:body(self._head_body_name)

			self:_spawn_head_gadget({
				skip_push = true,
				position = body:position(),
				rotation = body:rotation()
			})
		end

		local data = {
			variant = "fire",
			head_shot = false,
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			weapon_unit = attacker_unit and attacker_unit:inventory() and attacker_unit:inventory():equipped_unit()
		}
		local attacker_unit = attack_data.attacker_unit

		if attacker_unit and attacker_unit:base() and attacker_unit:base().thrower_unit then
			attacker_unit = attacker_unit:base():thrower_unit()
			data.weapon_unit = attack_data.attacker_unit
		end

		if attacker_unit == managers.player:player_unit() then
			if alive(attacker_unit) then
				self:_comment_death(attacker_unit, self._unit)
			end

			self:_show_death_hint(self._unit:base()._tweak_table)
			managers.statistics:killed(data)

			if CopDamage.is_civilian(self._unit:base()._tweak_table) then
				managers.money:civilian_killed()
			end
		end
	end

	local weapon_unit = attack_data.weapon_unit

	if alive(weapon_unit) and weapon_unit:base() and weapon_unit:base().add_damage_result then
		weapon_unit:base():add_damage_result(self._unit, result.type == "death", attack_data.attacker_unit, damage_percent)
	end

	attack_data.pos = self._unit:position()

	mvec3_set_z(attack_data.pos, attack_data.pos.z + math.random() * 180)
	self:_send_sync_fire_attack_result(attack_data)
	self:_on_damage_received(attack_data)
end

function CopDamage:is_friendly_fire(unit)
	if not unit or not alive(unit) or not unit:movement() or not unit:movement().friendly_fire or not unit:movement().team or not self._unit:movement().team or unit:base() and unit:base().is_grenade and not unit:base().is_cop_grenade then
		return false
	end

	if unit:movement() and unit:movement():team() and unit:movement():team() ~= self._unit:movement():team() and unit:movement():friendly_fire() then
		return false
	end

	if unit:movement():team() and unit:movement():team().foes and self._unit:movement():team().id then
		return not unit:movement():team().foes[self._unit:movement():team().id]
	else
		return false
	end
end

function CopDamage:damage_explosion(attack_data)
	if self._dead or self._invulnerable or attack_data.attacker_unit and alive(attack_data.attacker_unit) and attack_data.attacker_unit:base().is_cop_grenade then
		return
	end
	

	local is_civilian = CopDamage.is_civilian(self._unit:base()._tweak_table)

	local result = nil
	
	local damage = attack_data.damage

	if attack_data.attacker_unit == managers.player:player_unit() then
		if attack_data.weapon_unit and attack_data.variant ~= "stun" then
			if damage > 0 then
				managers.hud:on_hit_confirmed()
			end
		end

		if self._char_tweak.priority_shout then
			damage = damage * managers.player:upgrade_value("weapon", "special_damage_taken_multiplier", 1)
		end
	end

	if self._char_tweak.damage.explosion_damage_mul then
		damage = damage * self._char_tweak.damage.explosion_damage_mul
	end

	if self._marked_dmg_mul then
		damage = damage * self._marked_dmg_mul

		if self._marked_dmg_dist_mul then
			local attacking_unit = attack_data.attacker_unit

			if attacking_unit and attacking_unit:base() and attacking_unit:base().thrower_unit then
				attacking_unit = attacking_unit:base():thrower_unit()
			end

			if alive(attacking_unit) then
				local dst = mvec3_dis(attacking_unit:position(), self._unit:position())
				local spott_dst = tweak_data.upgrades.values.player.marked_inc_dmg_distance[self._marked_dmg_dist_mul]

				if spott_dst[1] < dst then
					damage = damage * spott_dst[2]
				end
			end
		end
	end

	damage = managers.modifiers:modify_value("CopDamage:DamageExplosion", damage, self._unit:base()._tweak_table)
	damage = self:_apply_damage_reduction(damage, attack_data)

	if self._char_tweak.DAMAGE_CLAMP_EXPLOSION then
		damage = math.min(damage, self._char_tweak.DAMAGE_CLAMP_EXPLOSION)
	end

	damage = math.clamp(damage, 0, self._HEALTH_INIT)
	local damage_percent = math.ceil(damage / self._HEALTH_INIT_PRECENT)
	damage = damage_percent * self._HEALTH_INIT_PRECENT
	damage, damage_percent = self:_apply_min_health_limit(damage, damage_percent)

	if self._immortal then
		damage = math.min(damage, self._health - 1)
	end

	if self._health <= damage then
		attack_data.damage = self._health

		if self:check_medic_heal() then
			attack_data.variant = "healed"
			result = {
				type = "healed",
				variant = attack_data.variant
			}
		else
			result = {
				type = "death",
				variant = attack_data.variant
			}

			self:die(attack_data)
		end
	else
		attack_data.damage = damage
		local result_type = attack_data.variant == "stun" and "hurt_sick" or self:get_damage_type(damage_percent, "explosion", attack_data)
		result = {
			type = result_type,
			variant = attack_data.variant
		}

		self:_apply_damage_to_health(damage)
	end

	attack_data.result = result
	attack_data.pos = attack_data.col_ray.position
	result.ignite_character = attack_data.ignite_character

	if result.type == "death" then
		local data = {
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			owner = attack_data.owner,
			weapon_unit = attack_data.weapon_unit,
			variant = attack_data.variant,
			head_shot = false
		}

		managers.statistics:killed_by_anyone(data)

		if self._head_body_name and attack_data.variant ~= "stun" then
			local body = self._unit:body(self._head_body_name)

			self:_spawn_head_gadget({
				skip_push = true,
				position = body:position(),
				rotation = body:rotation()
			})
		end

		local attacker_unit = attack_data.attacker_unit

		if attacker_unit and attacker_unit:base() and attacker_unit:base().thrower_unit then
			attacker_unit = attacker_unit:base():thrower_unit()
			data.weapon_unit = attack_data.attacker_unit
		end

		if not is_civilian and managers.player:has_category_upgrade("temporary", "overkill_damage_multiplier") and attacker_unit == managers.player:player_unit() and attack_data.weapon_unit and attack_data.weapon_unit:base().weapon_tweak_data and not attack_data.weapon_unit:base().thrower_unit and attack_data.weapon_unit:base():is_category("shotgun", "saw") then
			managers.player:activate_temporary_upgrade("temporary", "overkill_damage_multiplier")
		end

		self:chk_killshot(attacker_unit, "explosion")

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

	local weapon_unit = attack_data.weapon_unit

	if alive(weapon_unit) and weapon_unit:base() and weapon_unit:base().add_damage_result then
		weapon_unit:base():add_damage_result(self._unit, result.type == "death", attacker, damage_percent)
	end

	if attack_data.variant ~= "stun" and not self._no_blood and damage > 0 then
		managers.game_play_central:sync_play_impact_flesh(attack_data.pos, attack_data.col_ray.ray)
	end

	local i_attack_variant = nil

	--will not work with peers that lack the updated sync_damage_explosion code (as it normally syncs stun, healed and explosion, simulating the hurt for the last one locally)
	--it might even cause the peer to crash since because of the new numbers, the actual attack variant can end up being fire/graze/nothing, and I don't know what would happen
	if attack_data.variant == "stun" then
		i_attack_variant = 1
	elseif attack_data.variant == "healed" then
		i_attack_variant = 2
	else
		if result.type == "expl_hurt" then
			i_attack_variant = 3
		elseif result.type == "light_hurt" then
			i_attack_variant = 4
		elseif result.type == "hurt" then
			i_attack_variant = 5
		elseif result.type == "heavy_hurt" then
			i_attack_variant = 6
		elseif result.type == "dmg_rcv" then --important, need to sync if there's no reaction
			i_attack_variant = 7
		else
			i_attack_variant = 0
		end
	end

	self:_send_explosion_attack_result(attack_data, attacker, damage_percent, i_attack_variant, attack_data.col_ray.ray)
	self:_on_damage_received(attack_data)

	return result
end

function CopDamage:sync_damage_explosion(attacker_unit, damage_percent, i_attack_variant, death, direction, weapon_unit)
	if self._dead then
		return
	end

	local variant = "explosion"

	if i_attack_variant == 1 then
		variant = "stun"
	elseif i_attack_variant == 2 then
		variant = "healed"
	end

	local damage = damage_percent * self._HEALTH_INIT_PRECENT
	local attack_data = {
		variant = variant,
		attacker_unit = attacker_unit
	}
	local result = nil

	if death then
		result = {
			type = "death",
			variant = variant
		}

		self:die(attack_data)

		local data = {
			variant = "explosion",
			head_shot = false,
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			weapon_unit = weapon_unit or attacker_unit and attacker_unit:inventory() and attacker_unit:inventory():equipped_unit()
		}

		managers.statistics:killed_by_anyone(data)
	else
		local result_type = nil

		--sending peer needs the updated local damage_explosion code for this to work correctly
		if variant == "stun" then
			result_type = "hurt_sick"
		elseif variant == "healed" then
			result_type = "healed"
		else
			if i_attack_variant == 3 then
				result_type = "expl_hurt"
			elseif i_attack_variant == 4 then
				result_type = "light_hurt"
			elseif i_attack_variant == 5 then
				result_type = "hurt"
			elseif i_attack_variant == 6 then
				result_type = "heavy_hurt"
			elseif i_attack_variant == 7 then --note to fug: 8 is still available for use if some weird shit reaction needs to happen
				result_type = "dmg_rcv"
			else
				result_type = self:get_damage_type(damage_percent, "explosion", attack_data)
			end
		end

		result = {
			type = result_type,
			variant = variant
		}

		if result_type ~= "healed" then
			self:_apply_damage_to_health(damage)
		end
	end

	attack_data.result = result
	attack_data.damage = damage
	attack_data.is_synced = true
	local attack_dir = nil

	if direction then
		attack_dir = direction
	elseif attacker_unit then
		attack_dir = self._unit:position() - attacker_unit:position()

		mvec3_norm(attack_dir)
	else
		attack_dir = self._unit:rotation():y()
	end

	attack_data.attack_dir = attack_dir

	if attack_data.attacker_unit and attack_data.attacker_unit == managers.player:player_unit() then
		if variant ~= "stun" and damage > 0 then
			managers.hud:on_hit_confirmed()
		end

		managers.statistics:shot_fired({
			hit = true,
			weapon_unit = attacker_unit and attacker_unit:inventory() and attacker_unit:inventory():equipped_unit()
		})
	end

	if result.type == "death" then
		if self._head_body_name and variant ~= "stun" then --should be here to avoid popping helmets/hats on any synced explosion damage
			local body = self._unit:body(self._head_body_name)

			self:_spawn_head_gadget({
				skip_push = true,
				position = body:position(),
				rotation = body:rotation()
			})
		end

		local data = {
			variant = "explosion",
			head_shot = false,
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			weapon_unit = attacker_unit and attacker_unit:inventory() and attacker_unit:inventory():equipped_unit()
		}
		local attacker_unit = attack_data.attacker_unit

		if attacker_unit and attacker_unit:base() and attacker_unit:base().thrower_unit then
			attacker_unit = attacker_unit:base():thrower_unit()
			data.weapon_unit = attack_data.attacker_unit
		end

		self:chk_killshot(attacker_unit, "explosion")

		if attacker_unit == managers.player:player_unit() then
			if alive(attacker_unit) then
				self:_comment_death(attacker_unit, self._unit)
			end

			self:_show_death_hint(self._unit:base()._tweak_table)
			managers.statistics:killed(data)

			if CopDamage.is_civilian(self._unit:base()._tweak_table) then
				managers.money:civilian_killed()
			end
		end
	end

	if alive(weapon_unit) and weapon_unit:base() and weapon_unit:base().add_damage_result then
		weapon_unit:base():add_damage_result(self._unit, result.type == "death", damage_percent)
	end

	if variant ~= "stun" and not self._no_blood and damage > 0 then
		local hit_pos = mvec3_copy(self._unit:movement():m_pos())

		mvec3_set_z(hit_pos, hit_pos.z + 100)
		managers.game_play_central:sync_play_impact_flesh(hit_pos, attack_dir)
	end

	attack_data.pos = self._unit:position()

	mvec3_set_z(attack_data.pos, attack_data.pos.z + math.random() * 180)
	self:_send_sync_explosion_attack_result(attack_data)
	self:_on_damage_received(attack_data)
end

function CopDamage:damage_dot(attack_data)
	if self._dead or self._invulnerable then
		return
	end

	local valid_attacker = attack_data.attacker_unit and alive(attack_data.attacker_unit)

	if valid_attacker and self:is_friendly_fire(attack_data.attacker_unit) then --you never know, maybe it can be useful later on
		return "friendly_fire"
	end

	local result = nil
	local damage = attack_data.damage

	if attack_data.attacker_unit == managers.player:player_unit() then
		if self._char_tweak.priority_shout then
			damage = damage * managers.player:upgrade_value("weapon", "special_damage_taken_multiplier", 1)
		end
	end

	if self._char_tweak.damage.dot_damage_mul then
		damage = damage * self._char_tweak.damage.dot_damage_mul
	end

	if self._marked_dmg_mul then
		damage = damage * self._marked_dmg_mul
	end

	damage = self:_apply_damage_reduction(damage, attack_data)

	if self._char_tweak.DAMAGE_CLAMP_DOT then --never hurts to add these additional clamps as they do nothing if you don't specifically add them in charactertweakdata
		damage = math.min(damage, self._char_tweak.DAMAGE_CLAMP_DOT)
	end

	damage = math.clamp(damage, 0, self._HEALTH_INIT)
	local damage_percent = math.ceil(damage / self._HEALTH_INIT_PRECENT)
	damage = damage_percent * self._HEALTH_INIT_PRECENT
	damage, damage_percent = self:_apply_min_health_limit(damage, damage_percent)

	if self._immortal then
		damage = math.min(damage, self._health - 1)
	end

	if self._health <= damage then
		attack_data.damage = self._health

		if self:check_medic_heal() then
			attack_data.variant = "healed"
			result = {
				type = "healed",
				variant = attack_data.variant
			}
		else
			result = {
				type = "death",
				variant = attack_data.variant
			}

			self:die(attack_data)
			self:chk_killshot(attack_data.attacker_unit, attack_data.variant or "dot", nil, attack_data.weapon_id)
		end
	else
		attack_data.damage = damage
		local result_type = attack_data.hurt_animation and self:get_damage_type(damage_percent, attack_data.variant, attack_data) or "dmg_rcv"
		result = {
			type = result_type,
			variant = attack_data.variant
		}

		self:_apply_damage_to_health(damage)
	end

	attack_data.result = result
	attack_data.pos = attack_data.col_ray.position
	local head = self._head_body_name and attack_data.col_ray.body and attack_data.col_ray.body:name() == self._ids_head_body_name
	local attacker = attack_data.attacker_unit

	if not attacker or attacker:id() == -1 then
		attacker = self._unit
	end

	local attacker_unit = attack_data.attacker_unit

	if result.type == "death" then
		local variant = attack_data.weapon_id and tweak_data.blackmarket and tweak_data.blackmarket.melee_weapons and tweak_data.blackmarket.melee_weapons[attack_data.weapon_id] and "melee" or attack_data.variant
		local data = {
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			owner = attack_data.owner,
			weapon_unit = attack_data.weapon_unit,
			variant = variant,
			head_shot = head,
			weapon_id = attack_data.weapon_id
		}

		managers.statistics:killed_by_anyone(data)

		if attacker_unit == managers.player:player_unit() then
			if alive(attacker_unit) then
				self:_comment_death(attacker_unit, self._unit)
			end

			self:_show_death_hint(self._unit:base()._tweak_table)
			managers.statistics:killed(data)

			if CopDamage.is_civilian(self._unit:base()._tweak_table) then
				managers.money:civilian_killed()
			end

			self:_check_damage_achievements(attack_data, false)
		end
	end

	if attack_data.hurt_animation and result.type ~= "poison_hurt" then --in case the hurt table value for poison is changed to something other than 1, sync if it procs or not instead of evaluating it locally in the sync function
		attack_data.hurt_animation = false
	end

	self:_send_dot_attack_result(attack_data, attacker, damage_percent, attack_data.variant, attack_data.col_ray.ray)
	self:_on_damage_received(attack_data)
end

function CopDamage:sync_damage_dot(attacker_unit, damage_percent, death, variant, hurt_animation, weapon_id)
	if self._dead then
		return
	end

	local damage = damage_percent * self._HEALTH_INIT_PRECENT
	local attack_data = {
		variant = variant,
		attacker_unit = attacker_unit
	}
	local result = nil

	if death then
		result = {
			type = "death",
			variant = variant
		}

		self:die(attack_data)
		self:chk_killshot(attacker_unit, variant or "dot", nil, weapon_id)

		local real_variant = weapon_id and tweak_data.blackmarket and tweak_data.blackmarket.melee_weapons and tweak_data.blackmarket.melee_weapons[weapon_id] and "melee" or attack_data.variant
		local data = {
			head_shot = false,
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			weapon_unit = not weapon_id and attacker_unit and attacker_unit:inventory() and attacker_unit:inventory():equipped_unit(),
			variant = real_variant,
			name_id = weapon_id
		}

		if data.weapon_unit or data.name_id then
			managers.statistics:killed_by_anyone(data)
		end
	else
		local result_type = nil
		local result_variant = nil

		if hurt_animation then
			result_type = "poison_hurt"
		else
			result_type = "dmg_rcv"
		end

		if variant == "healed" then
			result_type = "healed"
			result_variant = "bullet"
		else
			result_variant = variant
		end

		result = {
			variant = result_variant,
			type = result_type
		}

		if result_type ~= "healed" then
			self:_apply_damage_to_health(damage)
		end
	end

	attack_data.variant = result.variant
	attack_data.result = result
	attack_data.damage = damage
	attack_data.weapon_id = weapon_id
	attack_data.is_synced = true

	self:_on_damage_received(attack_data)
end

function CopDamage:damage_tase(attack_data)
	if self._dead or self._invulnerable then
		return
	end

	if PlayerDamage.is_friendly_fire(self, attack_data.attacker_unit) then
		return "friendly_fire"
	end

	local result = nil
	local damage = attack_data.damage
	--local head = self._head_body_name and not self._unit:in_slot(16) and not self._char_tweak.ignore_headshot and attack_data.col_ray.body and attack_data.col_ray.body:name() == self._ids_head_body_name

	damage = self:_apply_damage_reduction(damage, attack_data)
	damage = math.clamp(damage, 0, self._HEALTH_INIT)
	
	local damage_percent = math.ceil(damage / self._HEALTH_INIT_PRECENT)
	damage = damage_percent * self._HEALTH_INIT_PRECENT
	damage, damage_percent = self:_apply_min_health_limit(damage, damage_percent)

	if self._immortal then
		damage = math.min(damage, self._health - 1)
	end

	if self._health <= damage then
		attack_data.damage = self._health
		result = {
			variant = "bullet",
			type = "death"
		}

		self:die(attack_data)
		self:chk_killshot(attack_data.attacker_unit, "tase")

		--[[if head then
			local body = self._unit:body(self._head_body_name)

			self:_spawn_head_gadget({
				position = body:position(),
				rotation = body:rotation(),
				dir = -attack_data.col_ray.ray
			})
		end]]
	else
		attack_data.damage = damage
		result = {
			type = "none",
			variant = attack_data.variant
		}

		if self._char_tweak.damage.hurt_severity.tase == nil or self._char_tweak.damage.hurt_severity.tase then
			if attack_data.attacker_unit == managers.player:player_unit() then
				if attack_data.weapon_unit then
					managers.hud:on_hit_confirmed()
				end
			end

			if self._unit:base():has_tag("shield") then
				result.type = "taser_tased"
			else
				if self._char_tweak.damage and self._char_tweak.damage.tased_response then
					if attack_data.variant == "heavy" and self._char_tweak.damage.tased_response.heavy then
						self._tased_time = self._char_tweak.damage.tased_response.heavy.tased_time
						self._tased_down_time = self._char_tweak.damage.tased_response.heavy.down_time
						result.variant = "heavy"
					elseif self._char_tweak.damage.tased_response.light then
						self._tased_time = self._char_tweak.damage.tased_response.light.tased_time
						self._tased_down_time = self._char_tweak.damage.tased_response.light.down_time
						result.variant = "light"
					else
						self._tased_time = 1
						self._tased_down_time = 5
						result.variant = nil
					end
				end

				result.type = "hurt"
				attack_data.variant = "tase"
			end
		end

		self:_apply_damage_to_health(damage)
	end

	attack_data.result = result
	attack_data.pos = attack_data.col_ray.position

	if result.type == "death" then
		local data = {
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name,
			owner = attack_data.owner,
			weapon_unit = attack_data.weapon_unit,
			variant = attack_data.variant,
			head_shot = head
		}

		managers.statistics:killed_by_anyone(data)

		local attacker_unit = attack_data.attacker_unit

		if attacker_unit and attacker_unit:base() and attacker_unit:base().thrower_unit then
			attacker_unit = attacker_unit:base():thrower_unit()
			data.weapon_unit = attack_data.attacker_unit
		end

		if attacker_unit == managers.player:player_unit() then
			if alive(attacker_unit) then
				self:_comment_death(attacker_unit, self._unit)
			end

			self:_show_death_hint(self._unit:base()._tweak_table)
			managers.statistics:killed(data)

			if CopDamage.is_civilian(self._unit:base()._tweak_table) then
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
		attack_data.attacker_unit = self._unit
	end

	local weapon_unit = attack_data.weapon_unit

	if alive(weapon_unit) and weapon_unit:base() and weapon_unit:base().add_damage_result then
		weapon_unit:base():add_damage_result(self._unit, result.type == "death", damage_percent)
	end

	local variant = nil

	if result.type == "hurt" and attack_data.variant == "tase" then
		if result.variant == "heavy" then
			variant = 1
		elseif result.variant == "light" then
			variant = 2
		else
			variant = 3
		end
	elseif result.type == "taser_tased" then
		variant = 4
	else
		variant = 0
	end

	self:_send_tase_attack_result(attack_data, damage_percent, variant)
	self:_on_damage_received(attack_data)

	return result
end

function CopDamage:sync_damage_tase(attacker_unit, damage_percent, variant, death)
	if self._dead then
		return
	end

	local damage = damage_percent * self._HEALTH_INIT_PRECENT
	local attack_data = {
		attacker_unit = attacker_unit,
		variant = variant
	}
	local result = nil

	if death then
		result = {
			variant = "bullet",
			type = "death"
		}

		self:die(attack_data)
		self:chk_killshot(attacker_unit, "tase")

		local data = {
			variant = "bullet",
			head_shot = false,
			name = self._unit:base()._tweak_table,
			stats_name = self._unit:base()._stats_name
		}

		managers.statistics:killed_by_anyone(data)
	else
		local result_type = nil

		if variant == 1 then
			result_type = "hurt"
			attack_data.variant = "tase"
			self._tased_time = self._char_tweak.damage.tased_response.heavy.tased_time
			self._tased_down_time = self._char_tweak.damage.tased_response.heavy.down_time
		elseif variant == 2 then
			result_type = "hurt"
			attack_data.variant = "tase"
			self._tased_time = self._char_tweak.damage.tased_response.light.tased_time
			self._tased_down_time = self._char_tweak.damage.tased_response.light.down_time
		elseif variant == 3 then
			result_type = "hurt"
			attack_data.variant = "tase"
			self._tased_time = 1
			self._tased_down_time = 5
		elseif variant == 4 then
			result_type = "taser_tased"
		else
			result_type = "none"
		end

		result = {
			type = result_type
		}

		self:_apply_damage_to_health(damage)
	end

	attack_data.result = result
	attack_data.damage = damage
	attack_data.is_synced = true
	local attack_dir = nil

	if attacker_unit then
		attack_dir = self._unit:position() - attacker_unit:position()

		mvec3_norm(attack_dir)
	else
		attack_dir = -self._unit:rotation():y()
	end

	attack_data.attack_dir = attack_dir
	attack_data.pos = self._unit:position()

	mvec3_set_z(attack_data.pos, attack_data.pos.z + math.random() * 180)
	self:_send_sync_tase_attack_result(attack_data)
	self:_on_damage_received(attack_data)
end

function CopDamage:_check_special_death_conditions(variant, body, attacker_unit, weapon_unit)
	if not attacker_unit or not alive(attacker_unit) or not attacker_unit:base() then
		return
	end

	local special_deaths = self._char_tweak.special_deaths

	if not special_deaths or not special_deaths[variant] then
		return
	end

	local body_data = special_deaths[variant][body:name():key()]

	if not body_data then
		return
	end

	local required_character = body_data.character_name

	if required_character then
		local attacker_name = managers.criminals:character_name_by_unit(attacker_unit) or attacker_unit:base()._tweak_table or "error_no_name"

		if type(required_character) == "string" then
			if required_character ~= attacker_name then
				return
			end
		elseif type(required_character) == "table" and table_size(required_character) > 0 and not table_contains(required_character, attacker_name) then
			return
		end
	end

	if variant == "melee" then
		local required_melee = body_data.melee_weapon_id
		local melee_id = weapon_unit or "error_no_melee"

		if required_melee then
			if type(required_melee) == "string" then
				if required_melee ~= melee_id then
					return
				end
			elseif type(required_melee) == "table" and table_size(required_character) > 0 and not table_contains(required_melee, melee_id) then
				return
			end
		end
	elseif variant == "bullet" then
		local required_weapon = body_data.weapon_id

		if required_weapon then
			if not alive(weapon_unit) then
				return
			else
				local weapon_id = nil
				local factory_id = weapon_unit:base()._factory_id

				if factory_id then
					if weapon_unit:base():is_npc() then --uses newnpcraycastweaponbase (normally means bots and player husks)
						factory_id = utf8.sub(factory_id, 1, -5) --remove part of the factory id to be able to properly check it with a player variant
					end

					weapon_id = managers.weapon_factory:get_weapon_id_by_factory_id(factory_id)
				elseif weapon_unit:base().get_name_id then --needs testing
					weapon_id = weapon_unit:base():get_name_id()
					weapon_id = utf8.sub(weapon_id, 1, -4)
				end

				if not weapon_id then
					weapon_id = "error_no_id"
				end

				if type(required_weapon) == "string" then
					if required_weapon ~= weapon_id then
						return
					end
				elseif type(required_weapon) == "table" and table_size(required_character) > 0 and not table_contains(required_weapon, weapon_id) then
					return
				end
			end
		end
	end

	if body_data.sound_effect then
		self._unit:sound():play(body_data.sound_effect, nil, nil)
	end

	if body_data.sequence and self._unit:damage():has_sequence(body_data.sequence) then
		self._unit:damage():run_sequence_simple(body_data.sequence)
	end

	if body_data.special_comment then --local players or bots sync the voiceline, no need to do this for husks
		if attacker_unit == managers.player:player_unit() or Network:is_server() and managers.groupai:state():is_unit_team_AI(attacker_unit) then
			return body_data.special_comment
		end
	end
end

function CopDamage:_AI_comment_death(unit, killed_unit, special_comment)
	local victim_base = killed_unit:base()

	if special_comment then
		unit:sound():say(special_comment, true)
	elseif victim_base:has_tag("tank") then
		unit:sound():say("g30x_any", true)
	elseif victim_base:has_tag("spooc") then
		unit:sound():say("g33x_any", true)
	elseif victim_base:has_tag("taser") then
		unit:sound():say("g32x_any", true)
	elseif victim_base:has_tag("shield") then
		unit:sound():say("g31x_any", true)
	elseif victim_base:has_tag("sniper") then
		unit:sound():say("g35x_any", true)
	elseif victim_base:has_tag("medic") then
		unit:sound():say("g36x_any", true)
	end
end
