local mvec3_set = mvector3.set
local mvec3_add = mvector3.add
local mvec3_dot = mvector3.dot
local mvec3_sub = mvector3.subtract
local mvec3_mul = mvector3.multiply
local mvec3_norm = mvector3.normalize
local mvec3_dir = mvector3.direction
local mvec3_set_l = mvector3.set_length
local mvec3_len = mvector3.length
local math_clamp = math.clamp
local math_lerp = math.lerp
local tmp_vec1 = Vector3()
local tmp_vec2 = Vector3()
local tmp_rot1 = Rotation()

PlayerDamage._UPPERS_COOLDOWN = 60

Hooks:PostHook(PlayerDamage, "init", "hhpost_lives", function(self, unit)
	self._lives_init = tweak_data.player.damage.LIVES_INIT

	if Global.game_settings.one_down then
		self._lives_init = tweak_data.player.damage.LIVES_INIT
	end

	self._lives_init = managers.modifiers:modify_value("PlayerDamage:GetMaximumLives", self._lives_init)
	
	if managers.player:has_category_upgrade("player", "criticalmode") then
		if self._lives_init ~= 1 then
			self._lives_init = self._lives_init - 1
		end
	end
	
	self._unit = unit
	self._max_health_reduction = managers.player:upgrade_value("player", "max_health_reduction", 1) * managers.player:upgrade_value("player", "perk_max_health_reduction", 1)
	self._healing_reduction = managers.player:upgrade_value("player", "healing_reduction", 1)
	self._revives = Application:digest_value(0, true)
	self._uppers_elapsed = 0

	self:replenish()

	local player_manager = managers.player
	self._bleed_out_health = Application:digest_value(tweak_data.player.damage.BLEED_OUT_HEALTH_INIT * player_manager:upgrade_value("player", "bleed_out_health_multiplier", 1), true)
	self._god_mode = Global.god_mode
	self._invulnerable = false
	self._mission_damage_blockers = {}
	self._gui = Overlay:newgui()
	self._ws = self._gui:create_screen_workspace()
	self._focus_delay_mul = 1
	self._dmg_interval = tweak_data.player.damage.MIN_DAMAGE_INTERVAL
	self._next_allowed_dmg_t = Application:digest_value(-100, true)
	self._last_received_dmg = 0
	self._next_allowed_sup_t = -100
	self._last_received_sup = 0
	self._supperssion_data = {}
	self._inflict_damage_body = self._unit:body("inflict_reciever")

	self._inflict_damage_body:set_extension(self._inflict_damage_body:extension() or {})

	local body_ext = PlayerBodyDamage:new(self._unit, self, self._inflict_damage_body)
	self._inflict_damage_body:extension().damage = body_ext

	managers.sequence:add_inflict_updator_body("fire", self._unit:key(), self._inflict_damage_body:key(), self._inflict_damage_body:extension().damage)

	self._doh_data = tweak_data.upgrades.damage_to_hot_data or {}
	self._damage_to_hot_stack = {}
	self._armor_stored_health = 0
	self._can_take_dmg_timer = 0
	self._regen_on_the_side_timer = 0
	self._regen_on_the_side = false
	self._interaction = managers.interaction
	self._armor_regen_mul = managers.player:upgrade_value("player", "armor_regen_time_mul", 1)
	self._dire_need = managers.player:has_category_upgrade("player", "armor_depleted_stagger_shot")
	self._has_damage_speed = managers.player:has_inactivate_temporary_upgrade("temporary", "damage_speed_multiplier")
	self._has_damage_speed_team = managers.player:upgrade_value("player", "team_damage_speed_multiplier_send", 0) ~= 0

	local function revive_player()
		self:revive(true)
	end

	managers.player:register_message(Message.RevivePlayer, self, revive_player)

	self._current_armor_fill = 0
	local has_swansong_skill = player_manager:has_category_upgrade("temporary", "berserker_damage_multiplier")
	self._current_state = nil
	self._listener_holder = unit:event_listener()

	if player_manager:has_category_upgrade("player", "damage_to_armor") then
		local damage_to_armor_data = player_manager:upgrade_value("player", "damage_to_armor", nil)
		local armor_data = tweak_data.blackmarket.armors[managers.blackmarket:equipped_armor(true, true)]

		if damage_to_armor_data and armor_data then
			local idx = armor_data.upgrade_level
			self._damage_to_armor = {
				armor_value = damage_to_armor_data[idx][1],
				target_tick = damage_to_armor_data[idx][2],
				elapsed = 0
			}

			local function on_damage(damage_info)
				local attacker_unit = damage_info and damage_info.attacker_unit

				if alive(attacker_unit) and attacker_unit:base() and attacker_unit:base().thrower_unit then
					attacker_unit = attacker_unit:base():thrower_unit()
				end

				if self._unit == attacker_unit then
					local time = Application:time()

					if self._damage_to_armor.target_tick < time - self._damage_to_armor.elapsed then
						self._damage_to_armor.elapsed = time

						self:restore_armor(self._damage_to_armor.armor_value, true)
					end
				end
			end

			CopDamage.register_listener("on_damage", {
				"on_damage"
			}, on_damage)
		end
	end

	self._listener_holder:add("on_use_armor_bag", {
		"on_use_armor_bag"
	}, callback(self, self, "_on_use_armor_bag_event"))

	if self:_init_armor_grinding_data() then
		function self._on_damage_callback_func()
			return callback(self, self, "_on_damage_armor_grinding")
		end

		self:_add_on_damage_event()
		self._listener_holder:add("on_enter_bleedout", {
			"on_enter_bleedout"
		}, callback(self, self, "_on_enter_bleedout_event"))

		if has_swansong_skill then
			self._listener_holder:add("on_enter_swansong", {
				"on_enter_swansong"
			}, callback(self, self, "_on_enter_swansong_event"))
			self._listener_holder:add("on_exit_swansong", {
				"on_enter_bleedout"
			}, callback(self, self, "_on_exit_swansong_event"))
		end

		self._listener_holder:add("on_revive", {
			"on_revive"
		}, callback(self, self, "_on_revive_event"))
	else
		self:_init_standard_listeners()
	end

	if player_manager:has_category_upgrade("temporary", "revive_damage_reduction") then
		self._listener_holder:add("combat_medic_damage_reduction", {
			"on_revive"
		}, callback(self, self, "_activate_combat_medic_damage_reduction"))
	end

	if player_manager:has_category_upgrade("player", "revive_damage_reduction") and player_manager:has_category_upgrade("player", "revive_damage_reduction") then
		local function on_revive_interaction_start()
			managers.player:set_property("revive_damage_reduction", player_manager:upgrade_value("player", "revive_damage_reduction"), 1)
		end

		local function on_exit_interaction()
			managers.player:remove_property("revive_damage_reduction")
		end

		local function on_revive_interaction_success()
			managers.player:activate_temporary_upgrade("temporary", "revive_damage_reduction")
		end

		self._listener_holder:add("on_revive_interaction_start", {
			"on_revive_interaction_start"
		}, on_revive_interaction_start)
		self._listener_holder:add("on_revive_interaction_interrupt", {
			"on_revive_interaction_interrupt"
		}, on_exit_interaction)
		self._listener_holder:add("on_revive_interaction_success", {
			"on_revive_interaction_success"
		}, on_revive_interaction_success)
	end

	managers.mission:add_global_event_listener("player_regenerate_armor", {
		"player_regenerate_armor"
	}, callback(self, self, "_regenerate_armor"))
	managers.mission:add_global_event_listener("player_force_bleedout", {
		"player_force_bleedout"
	}, callback(self, self, "force_into_bleedout", false))

	local level_tweak = tweak_data.levels[managers.job:current_level_id()]

	if level_tweak and level_tweak.is_safehouse and not level_tweak.is_safehouse_combat then
		self:set_mission_damage_blockers("damage_fall_disabled", true)
		self:set_mission_damage_blockers("invulnerable", true)
	end

	self._delayed_damage = {
		epsilon = 0.001,
		chunks = {}
	}

	self:clear_delayed_damage()
end)

function PlayerDamage:damage_melee(attack_data)
	if not self:_chk_can_take_dmg() then
		return
	end

	local pm = managers.player
	local can_counter_strike = pm:has_category_upgrade("player", "counter_strike_melee")

	if can_counter_strike and self._unit:movement():current_state().in_melee and self._unit:movement():current_state():in_melee() then
		if attack_data.attacker_unit and alive(attack_data.attacker_unit) and attack_data.attacker_unit:base() then
			local is_dozer = attack_data.attacker_unit:base().has_tag and attack_data.attacker_unit:base():has_tag("tank")

			--prevent the player from countering Dozers or other players through FF, for obvious reasons
			if not attack_data.attacker_unit:base().is_husk_player and not is_dozer then
				self._unit:movement():current_state():discharge_melee()

				return "countered"
			end
		end
	end

	local damage_info = {
		result = {
			variant = "melee",
			type = "hurt"
		},
		attacker_unit = attack_data.attacker_unit
	}

	if self:is_friendly_fire(attack_data.attacker_unit) then
		return
	elseif self._god_mode then
		if attack_data.damage > 0 then
			self:_send_damage_drama(attack_data, attack_data.damage)
		end

		self:_call_listeners(damage_info)

		return
	elseif self._invulnerable or self._mission_damage_blockers.invulnerable then
		self:_call_listeners(damage_info)

		return
	elseif self:incapacitated() then
		return
	elseif self._unit:movement():current_state().immortal then
		return
	elseif not attack_data.is_cloaker_kick and self:_chk_dmg_too_soon(attack_data.damage) then
		return
	end
	
	self:_hit_direction(attack_data.attacker_unit:position())

	self._last_received_dmg = attack_data.damage
	self._next_allowed_dmg_t = Application:digest_value(pm:player_timer():time() + self._dmg_interval, true)
	
	self:build_suppression(20)
	
	local allow_melee_dodge = true
	local sneakier_activated = nil
	if allow_melee_dodge and not attack_data.is_cloaker_kick and pm:current_state() ~= "bleed_out" and pm:current_state() ~= "bipod" and pm:current_state() ~= "tased" then --self._bleed_out and current_state() ~= "bleed_out" aren't the same thing
		local dodge_roll = math.random()
		local dodge_value = tweak_data.player.damage.DODGE_INIT or 0
		local armor_dodge_chance = pm:body_armor_value("dodge")
		local skill_dodge_chance = pm:skill_dodge_chance(self._unit:movement():running(), self._unit:movement():crouching(), self._unit:movement():zipline_unit())
		dodge_value = dodge_value + armor_dodge_chance + skill_dodge_chance

		if self._temporary_dodge_t and TimerManager:game():time() < self._temporary_dodge_t then
			dodge_value = dodge_value + self._temporary_dodge
		end

		local smoke_dodge = 0

		for _, smoke_screen in ipairs(pm._smoke_screen_effects or {}) do
			if smoke_screen:is_in_smoke(self._unit) then
				smoke_dodge = tweak_data.projectiles.smoke_screen_grenade.dodge_chance

				break
			end
		end

		dodge_value = 1 - (1 - dodge_value) * (1 - smoke_dodge)

		if dodge_roll <= dodge_value then
			--do a push to simulate the dodge + small camera shake + show an indicator (no hit sounds or a blood effect)
			self._unit:movement():push(attack_data.push_vel)
			self._unit:camera():play_shaker("melee_hit", 0.2)
			if pm:has_category_upgrade("player", "highvigour_aced") then
				self._unit:movement():add_stamina(5)
			end
			pm:send_message(Message.OnPlayerDodge)

			return
		else
			if pm:has_category_upgrade("player", "sneakier_aced") then
				local new_roll = math.random()
				if new_roll <= dodge_value then
					sneakier_activated = true
				end
			end
		end
	end
	
	if not attack_data.is_cloaker_kick then
		--log("damage was " .. tostring(attack_data.damage) .. "")
		local dmg_mul = pm:damage_reduction_skill_multiplier("melee", sneakier_activated) --the vanilla function has this line, but it also uses bullet damage reduction skills due to it redirecting to damage_bullet to get results
		
		attack_data.damage = attack_data.damage * dmg_mul
		
		attack_data.damage = pm:modify_value("damage_taken", attack_data.damage, attack_data) --apply damage resistances before checking for bleedout and other things
		
		--log("damage became " .. tostring(attack_data.damage) .. "")
	else
		local damage = self:_max_health() / 2
		if managers.modifiers and managers.modifiers:check_boolean("woahtheyjomp") then
			damage = damage * 1.5
		end
		damage = damage + self:get_real_armor()
		attack_data.damage = damage
	end

	local damage_absorption = pm:damage_absorption()

	if damage_absorption > 0 then
		attack_data.damage = math.max(0, attack_data.damage - damage_absorption)
	end
	
	local player_unit = managers.player:player_unit()
	local cur_state = self._unit:movement():current_state_name()
	
	if attack_data then
		local next_allowed_dmg_t = type(self._next_allowed_dmg_t) == "number" and self._next_allowed_dmg_t or Application:digest_value(self._next_allowed_dmg_t, false)
		local t = managers.player:player_timer():time()
		local dmg_is_allowed = next_allowed_dmg_t and next_allowed_dmg_t > t
		
		--enemies were meleeing players and taking their guns away during invincibility frames and thats no bueno
		if alive(attack_data.attacker_unit) and not self:is_downed() and not self._bleed_out and not self._dead and cur_state ~= "bipod" and cur_state ~= "fatal" and cur_state ~= "bleedout" and not self._invulnerable and not self._unit:character_damage().swansong and not self._unit:movement():tased() and not self._mission_damage_blockers.invulnerable and not self._god_mode and not self:incapacitated() and not self._unit:movement():current_state().immortal and dmg_is_allowed then
			-- log("balls")				
			if alive(player_unit) then
				local melee_stun_t = 0.4
				
				if tostring(attack_data.attacker_unit:base()._tweak_table) == "fbi" or tostring(attack_data.attacker_unit:base()._tweak_table) == "fbi_xc45" or tostring(attack_data.attacker_unit:base()._tweak_table) == "fbi_pager" then
					melee_stun_t = 0.8
				end
				
				if attack_data.is_cloaker_kick then
					melee_stun_t = 1
				end
				
				self._unit:movement():current_state():on_melee_stun(managers.player:player_timer():time(), melee_stun_t)
			end
		end
	end

	if attack_data.tase_player then
		if pm:current_state() == "standard" or pm:current_state() == "carry" or pm:current_state() == "bipod" then
			if pm:current_state() == "bipod" then
				self._unit:movement()._current_state:exit(nil, "tased")
			end

			self._unit:movement():on_non_lethal_electrocution()
			pm:set_player_state("tased")

			--no pushing and camera shaking for melee tase attacks
		end
	else
		if pm:current_state() == "bipod" then
			self._unit:movement()._current_state:exit(nil, "standard")
			pm:set_player_state("standard")
		end

		local vars = {
			"melee_hit",
			"melee_hit_var2"
		}
		
		self._unit:camera():play_shaker(vars[math.random(#vars)], attack_data.is_cloaker_kick and 1 or 0.5)

		--no pushing when in bleedout, looks silly in third-person
		if pm:current_state() ~= "bleed_out" then
			self._unit:movement():push(attack_data.push_vel)
		end
	end

	if self._bleed_out then
		self:_bleed_out_damage(attack_data)

		--bleed_out = always taking health damage, so use the appropiate sound and cause a blood effect if the weapon isn't tase capable
		local hit_sound = "hit_body"

		--unless damage is completely negated
		if attack_data.damage == 0 then
			hit_sound = "hit_gen"
		end

		self:play_melee_hit_sound_and_effects(attack_data, hit_sound, not attack_data.tase_player)

		return
	end

	self:_check_chico_heal(attack_data)

	local go_through_armor = false --manual toggle
	local health_subtracted = nil
	local armor_broken = false

	if go_through_armor or attack_data.is_cloaker_kick then
		health_subtracted = self:_calc_armor_damage(attack_data)

		attack_data.damage = attack_data.damage - health_subtracted

		health_subtracted = health_subtracted + self:_calc_health_damage(attack_data)

		armor_broken = self:_max_armor() == 0 or self:_max_armor() > 0 and self:get_real_armor() <= 0 --works when armor is broken and health damage is taken by the same hit
	else
		local armor_reduction_multiplier = 0

		if self:get_real_armor() <= 0 then --if armor is already broken, don't negate health damage
			armor_reduction_multiplier = 1
			armor_broken = true --checked before actually taking damage
		end

		health_subtracted = self:_calc_armor_damage(attack_data)

		if attack_data.melee_armor_piercing then --for specific cases, like say, making headless Dozers able to go through armor with melee when other enemies can't
			attack_data.damage = attack_data.damage - health_subtracted
		else
			attack_data.damage = attack_data.damage * armor_reduction_multiplier
		end

		health_subtracted = health_subtracted + self:_calc_health_damage(attack_data)
	end

	local hit_sound_type = "hit_gen"
	local blood_effect = false

	if armor_broken then
		hit_sound_type = "hit_body"
		blood_effect = not attack_data.tase_player
	end

	self:play_melee_hit_sound_and_effects(attack_data, hit_sound_type, blood_effect)

	if not self._bleed_out then
		if health_subtracted > 0 then
			self:_send_damage_drama(attack_data, health_subtracted)
		end
	else
		local attacker = attack_data.attacker_unit

		if attacker:character_damage() and attacker:character_damage().dead and not attacker:character_damage():dead() then
			if attacker:base().has_tag then
				if attacker:base():has_tag("tank") then
					attack_data.attacker_unit:sound():say("post_kill_taunt")
				elseif attacker:base():has_tag("taser") then
					attack_data.attacker_unit:sound():say("post_tasing_taunt")
				elseif attacker:base():has_tag("law") and not attacker:base():has_tag("special") then
					attack_data.attacker_unit:sound():say("i03")
				end
			end
		end
	end

	pm:send_message(Message.OnPlayerDamage, nil, attack_data)
	self:_call_listeners(damage_info)

	return
end

function PlayerDamage:_check_bleed_out(can_activate_berserker, ignore_movement_state, is_special_attack)
	if self:get_real_health() == 0 and not self._check_berserker_done then
		if self._unit:movement():zipline_unit() then
			self._bleed_out_blocked_by_zipline = true

			return
		end

		if not ignore_movement_state and self._unit:movement():current_state():bleed_out_blocked() then
			self._bleed_out_blocked_by_movement_state = true

			return
		end

		local time = Application:time()

		if not self._block_medkit_auto_revive and time > self._uppers_elapsed + self._UPPERS_COOLDOWN then
			local auto_recovery_kit = FirstAidKitBase.GetFirstAidKit(self._unit:position())

			if auto_recovery_kit then
				auto_recovery_kit:take(self._unit)
				self._unit:sound():play("pickup_fak_skill")

				self._uppers_elapsed = time

				return
			end
		end

		if can_activate_berserker and not self._check_berserker_done then
			local has_berserker_skill = managers.player:has_category_upgrade("temporary", "berserker_damage_multiplier")

			if has_berserker_skill and not self._disable_next_swansong then
				managers.hud:set_teammate_condition(HUDManager.PLAYER_PANEL, "mugshot_swansong", managers.localization:text("debug_mugshot_downed"))
				managers.player:activate_temporary_upgrade("temporary", "berserker_damage_multiplier")

				self._current_state = nil
				self._check_berserker_done = true

				if alive(self._interaction:active_unit()) and not self._interaction:active_unit():interaction():can_interact(self._unit) then
					self._unit:movement():interupt_interact()
				end

				self._listener_holder:call("on_enter_swansong")
			end

			self._disable_next_swansong = nil
		end

		self._hurt_value = 0.2
		self._damage_to_hot_stack = {}

		managers.environment_controller:set_downed_value(0)
		SoundDevice:set_rtpc("downed_state_progression", 0)

		if not self._check_berserker_done or not can_activate_berserker then
			self._revives = Application:digest_value(Application:digest_value(self._revives, false) - 1, true)
			self._check_berserker_done = nil

			managers.environment_controller:set_last_life(Application:digest_value(self._revives, false) <= 1)

			if Application:digest_value(self._revives, false) == 0 then
				self._down_time = 0
			end

			self._bleed_out = true
			self._current_state = nil
			
			if is_special_attack then
				managers.player:set_player_state("incapacitated")
			else
				managers.player:set_player_state("bleed_out")
			end

			self._critical_state_heart_loop_instance = self._unit:sound():play("critical_state_heart_loop")
			self._slomo_sound_instance = self._unit:sound():play("downed_slomo_fx")
			self._bleed_out_health = Application:digest_value(tweak_data.player.damage.BLEED_OUT_HEALTH_INIT * managers.player:upgrade_value("player", "bleed_out_health_multiplier", 1), true)

			self:_drop_blood_sample()
			self:on_downed()
		end
	elseif not self._said_hurt and self:get_real_health() / self:_max_health() < 0.2 then
		self._said_hurt = true

		PlayerStandard.say_line(self, "g80x_plu")
	end
end

local mvec1 = Vector3()

function PlayerDamage:play_melee_hit_sound_and_effects(attack_data, sound_type, play_blood_effect)
	if play_blood_effect then
		--make sure the weapon is supposed to cause a blood splatter
		local blood_effect = attack_data.melee_weapon and attack_data.melee_weapon == "weapon"
		blood_effect = blood_effect or attack_data.melee_weapon and tweak_data.weapon.npc_melee[attack_data.melee_weapon] and tweak_data.weapon.npc_melee[attack_data.melee_weapon].player_blood_effect or false

		if blood_effect then --spawn a blood splatter in front of the player
			local pos = mvec1

			mvector3.set(pos, self._unit:camera():forward())
			mvector3.multiply(pos, 20)
			mvector3.add(pos, self._unit:camera():position())

			local rot = self._unit:camera():rotation():z()

			World:effect_manager():spawn({
				effect = Idstring("effects/payday2/particles/impacts/blood/blood_impact_a"),
				position = pos,
				normal = rot
			})
		end
	end

	local melee_name_id = nil
	local attacker_unit = attack_data.attacker_unit
	local valid_attacker = attacker_unit and alive(attacker_unit) and attacker_unit:base()

	if valid_attacker then
		--get melee weapon id
		if attacker_unit:base().is_husk_player then
			local peer_id = managers.network:session():peer_by_unit(attacker_unit):id()
			local peer = managers.network:session():peer(peer_id)

			melee_name_id = peer:melee_id()
		else
			melee_name_id = attacker_unit:base().melee_weapon and attacker_unit:base():melee_weapon()
		end

		if melee_name_id then
			if melee_name_id == "knife_1" then --knife used by NPCs
				melee_name_id = "kabar"
			elseif melee_name_id == "helloween" then --titan staff used by headless Dozers
				melee_name_id = "brass_knuckles"
			elseif not attacker_unit:base().is_husk_player and melee_name_id == "baton" then --cop baton (otherwise the ballistic baton's sounds are used)
				melee_name_id = "weapon"
			end

			local tweak_data = tweak_data.blackmarket.melee_weapons[melee_name_id]

			if tweak_data and tweak_data.sounds and tweak_data.sounds[sound_type] then
				local post_event = tweak_data.sounds[sound_type]
				local anim_attack_vars = tweak_data.anim_attack_vars
				local variation = anim_attack_vars and math.random(#anim_attack_vars)

				if type(post_event) == "table" then
					if variation then
						post_event = post_event[variation]
					else
						post_event = post_event[1]
					end
				end

				--some sounds are too low to hear, playing them twice helps and or accentuates a hit even more)
				self._unit:sound():play(post_event, nil, false)
				self._unit:sound():play(post_event, nil, false)
			end
		end
	end
end

function PlayerDamage:damage_fire(attack_data)
	if not self:_chk_can_take_dmg() or self:incapacitated() then
		return
	end

	local attack_pos = attack_data.position or attack_data.col_ray.position or attack_data.attacker_unit and alive(attack_data.attacker_unit) and attack_data.attacker_unit:position()
	local distance = mvector3.distance(attack_pos, self._unit:position())

	if not attack_data.range then
		attack_data.range = distance
	end

	if attack_data.range < distance then
		return
	elseif self:is_friendly_fire(attack_data.attacker_unit) then
		return
	end

	local damage_info = {
		result = {
			variant = "fire",
			type = "hurt"
		}
	}

	local damage = attack_data.damage or 1
	attack_data.damage = damage

	if self._god_mode or self._invulnerable or self._mission_damage_blockers.invulnerable then
		self:_call_listeners(damage_info)

		return
	elseif self._unit:movement():current_state().immortal then
		return
	elseif self:_chk_dmg_too_soon(attack_data.damage) then
		return
	end

	if attack_data.attacker_unit and alive(attack_data.attacker_unit) then
		self:_hit_direction(attack_data.attacker_unit:position())
	end

	local pm = managers.player

	self._last_received_dmg = attack_data.damage
	self._next_allowed_dmg_t = Application:digest_value(pm:player_timer():time() + self._dmg_interval, true)

	local dmg_mul = pm:damage_reduction_skill_multiplier("fire")
	attack_data.damage = attack_data.damage * dmg_mul
	attack_data.damage = pm:modify_value("damage_taken", attack_data.damage, attack_data)

	local damage_absorption = pm:damage_absorption()

	if damage_absorption > 0 then
		attack_data.damage = math.max(0, attack_data.damage - damage_absorption)
	end

	if self._bleed_out then
		if attack_data.damage == 0 then
			self._unit:sound():play("player_hit")
		else
			self._unit:sound():play("player_hit_permadamage")
		end

		self:_bleed_out_damage(attack_data)

		return
	else
		if self:get_real_armor() > 0 or attack_data.damage == 0 then
			self._unit:sound():play("player_hit")
		else
			self._unit:sound():play("player_hit_permadamage")
		end
	end

	self:_check_chico_heal(attack_data)

	local armor_reduction_multiplier = 0

	if self:get_real_armor() <= 0 then
		armor_reduction_multiplier = 1
	end

	local health_subtracted = self:_calc_armor_damage(attack_data)

	attack_data.damage = attack_data.damage * armor_reduction_multiplier
	health_subtracted = health_subtracted + self:_calc_health_damage(attack_data)

	pm:send_message(Message.OnPlayerDamage, nil, attack_data)
	self:_call_listeners(damage_info)
end

function PlayerDamage:damage_explosion(attack_data)
	if not self:_chk_can_take_dmg() or self:incapacitated() then
		return
	end

	local attack_pos = attack_data.position or attack_data.col_ray.position or attack_data.attacker_unit and alive(attack_data.attacker_unit) and attack_data.attacker_unit:position()
	local distance = mvector3.distance(attack_pos, self._unit:position())

	if not attack_data.range then
		attack_data.range = distance
	end

	if attack_data.range < distance then
		return
	elseif self:is_friendly_fire(attack_data.attacker_unit) then
		return
	end

	local damage_info = {
		result = {
			variant = "explosion",
			type = "hurt"
		}
	}

	if self._god_mode or self._invulnerable or self._mission_damage_blockers.invulnerable then
		self:_call_listeners(damage_info)

		return
	elseif self._unit:movement():current_state().immortal then
		return
	end

	local pm = managers.player
	local damage = attack_data.damage or 1
	attack_data.damage = damage
	attack_data.damage = attack_data.damage * (1 - distance / attack_data.range)

	local dmg_mul = pm:damage_reduction_skill_multiplier("explosion")
	attack_data.damage = attack_data.damage * dmg_mul
	attack_data.damage = pm:modify_value("damage_taken", attack_data.damage, attack_data)
	attack_data.damage = managers.modifiers:modify_value("PlayerDamage:OnTakeExplosionDamage", attack_data.damage)

	local damage_absorption = pm:damage_absorption()

	if damage_absorption > 0 then
		attack_data.damage = math.max(0, attack_data.damage - damage_absorption)
	end

	if attack_data.attacker_unit and alive(attack_data.attacker_unit) then
		self:_hit_direction(attack_data.attacker_unit:position())
	end

	if self._bleed_out then
		if attack_data.damage == 0 then
			self._unit:sound():play("player_hit")
		else
			self._unit:sound():play("player_hit_permadamage")
		end

		self:_bleed_out_damage(attack_data)

		return
	else
		if self:get_real_armor() > 0 or attack_data.damage == 0 then
			self._unit:sound():play("player_hit")
		else
			self._unit:sound():play("player_hit_permadamage")
		end

		local allow_explosive_pushes = true

		--enjoy your rocket/grenade/trip mine jumps
		if allow_explosive_pushes and attack_data.damage ~= 0 then
			local push_vec = Vector3()
			mvector3.direction(push_vec, attack_pos, self._unit:movement():m_head_pos())
			local final_damage = attack_data.damage
			local max_damage = 60 --RPG player damage, aka maximum explosive damage that the player can normally take
			local dmg_lerp_value = math.clamp(final_damage, 1, max_damage) / max_damage
			local push_force = math.lerp(300, 1000, dmg_lerp_value)
			mvector3.set_z(push_vec, 0.25)

			self._unit:movement():push(push_vec * push_force)
		end
	end

	self:_check_chico_heal(attack_data)

	local health_subtracted = self:_calc_armor_damage(attack_data)

	attack_data.damage = attack_data.damage - health_subtracted
	health_subtracted = health_subtracted + self:_calc_health_damage(attack_data)

	pm:send_message(Message.OnPlayerDamage, nil, attack_data)
	self:_call_listeners(damage_info)
end

function PlayerDamage:clbk_kill_taunt(attack_data) -- just a nice little detail
	if attack_data.attacker_unit and attack_data.attacker_unit:alive() then
		if not attack_data.attacker_unit:base()._tweak_table then
			return
		end
		
		self._kill_taunt_clbk_id = nil
		if attack_data.attacker_unit:base():has_tag("tank") then
			attack_data.attacker_unit:sound():say("post_kill_taunt")
		elseif attack_data.attacker_unit:base():has_tag("law") and not attack_data.attacker_unit:base():has_tag("special") then	
			attack_data.attacker_unit:sound():say("i03")
		else
			--nothing
		end
	end
end

function PlayerDamage:damage_tase(attack_data)
	if self._god_mode then
		return
	end

	local cur_state = self._unit:movement():current_state_name()

	if cur_state ~= "tased" and cur_state ~= "fatal" then
		self:on_tased(false)

		self._tase_data = attack_data

		managers.player:set_player_state("tased")

		local damage_info = {
			result = {
				variant = "tase",
				type = "hurt"
			}
		}

		self:_call_listeners(damage_info)

		if attack_data.attacker_unit and attack_data.attacker_unit:alive() and attack_data.attacker_unit:base()._tweak_table == "taser" then
			--attack_data.attacker_unit:sound():say("post_tasing_taunt")

			if managers.blackmarket:equipped_mask().mask_id == tweak_data.achievement.its_alive_its_alive.mask then
				managers.achievment:award_progress(tweak_data.achievement.its_alive_its_alive.stat)
			end
		end
	end
end

function PlayerDamage:has_jackpot_token()
	return self._jackpot_token
end

function PlayerDamage:activate_jackpot_token()
	self._jackpot_token = true
	--log("this party's gettin crazy")
end

function PlayerDamage:activate_docbag_token()
	self._docbag_token = true
	--log("yes")
end

function PlayerDamage:_regenerated(no_messiah)
	self:set_health(self:_max_health())
	self:_send_set_health()
	self:_set_health_effect()
	self._jackpot_token = nil

	self._said_hurt = false
	self._revives = Application:digest_value(self._lives_init + managers.player:upgrade_value("player", "additional_lives", 0), true)
	self._revive_health_i = 1

	managers.environment_controller:set_last_life(false)

	self._down_time = tweak_data.player.damage.DOWNED_TIME

	if not no_messiah then
		self._messiah_charges = managers.player:upgrade_value("player", "pistol_revive_from_bleed_out", 0)
	end
end

function PlayerDamage:_chk_dmg_too_soon(damage, ...)
	local next_allowed_dmg_t = type(self._next_allowed_dmg_t) == "number" and self._next_allowed_dmg_t or Application:digest_value(self._next_allowed_dmg_t, false)
	local min_allowed_dmg_t = next_allowed_dmg_t - 0.1
	local t = managers.player:player_timer():time()
	
	if damage <= self._last_received_dmg + 0.01 and next_allowed_dmg_t > t then
		self._old_last_received_dmg = nil
		self._old_next_allowed_dmg_t = nil
		return true
	end
	
	if min_allowed_dmg_t > t then
		return true
	end
	
	if next_allowed_dmg_t > t then
		self._old_last_received_dmg = self._last_received_dmg
		self._old_next_allowed_dmg_t = next_allowed_dmg_t
	end
end

function PlayerDamage:damage_bullet(attack_data)
	if not self:_chk_can_take_dmg() then
		return
	end

	local damage_info = {
		result = {
			variant = "bullet",
			type = "hurt"
		},
		attacker_unit = attack_data.attacker_unit
	}

	if self:is_friendly_fire(attack_data.attacker_unit) then
		return
	elseif self._god_mode then
		if attack_data.damage > 0 then
			self:_send_damage_drama(attack_data, attack_data.damage)
		end

		self:_call_listeners(damage_info)

		return
	elseif self._invulnerable or self._mission_damage_blockers.invulnerable then
		self:_call_listeners(damage_info)

		return
	elseif self:incapacitated() then
		return
	elseif self._unit:movement():current_state().immortal then
		return
	elseif not attack_data.is_taser_shock and self._revive_miss and math.random() < self._revive_miss then
		self:play_whizby(attack_data.col_ray.position)

		return
	elseif attack_data.damage < 0.011 then
		self:play_whizby(attack_data.col_ray.position)
		
		return
	elseif not attack_data.is_taser_shock and self:_chk_dmg_too_soon(attack_data.damage) then
		self:play_whizby(attack_data.col_ray.position)
		
		return
	end
	
	local pm = managers.player
	
	if attack_data.is_taser_shock then
		local damage = self:_max_health() / 4
		if managers.modifiers and managers.modifiers:check_boolean("lightningbolt") then
			damage = damage * 2
		end
		damage = damage + self:get_real_armor()
		attack_data.damage = damage
		self:build_suppression(20)
		self._next_allowed_dmg_t = Application:digest_value(pm:player_timer():time() + self._dmg_interval, true)
		
		local from_pos = nil
		
		--probably unnecessary but you never know
		if attack_data.attacker_unit:movement() then
			if attack_data.attacker_unit:movement().m_head_pos then
				from_pos = attack_data.attacker_unit:movement():m_head_pos()
			elseif attack_data.attacker_unit:movement().m_pos then
				from_pos = attack_data.attacker_unit:movement():m_pos()
			else
				from_pos = attack_data.attacker_unit:position()
			end
		else
			from_pos = attack_data.attacker_unit:position()
		end
		
		local push_vec = Vector3()
		local distance = mvector3.direction(push_vec, from_pos, self._unit:movement():m_head_pos())
		mvector3.normalize(push_vec)
		
		self._unit:movement():push(push_vec * 1600)
	else
		self._next_allowed_dmg_t = Application:digest_value(pm:player_timer():time() + self._dmg_interval, true)
	end
	
	local armor_damage = self:_max_armor() > 0 and self:get_real_armor() < self:_max_armor()
	local cur_state = self._unit:movement():current_state_name()
	
	if self._bleed_out and self._akuma_effect then
		managers.groupai:state():chk_taunt()
	end
	
	if attack_data then
		if alive(attack_data.attacker_unit) and not self:is_downed() and not self._dead and cur_state ~= "fatal" and cur_state ~= "bleedout" and not self._invulnerable and not self._unit:character_damage().swansong and not self._unit:movement():tased() and not self._mission_damage_blockers.invulnerable and not self._god_mode and not self:incapacitated() and not self._unit:movement():current_state().immortal then
			if tostring(attack_data.attacker_unit:base()._tweak_table) == "akuma" then
				if alive(player_unit) then
					--self._akuma_effect = true
					self:build_suppression(99)
					return
				end
			end
		end
	end
	
	--local testing = true
	local state_chk = cur_state == "standard" or cur_state == "carry" or cur_state == "bipod"
	if Global.game_settings.bulletknock or testing then
		if alive(attack_data.attacker_unit) and state_chk then
			local from_pos = nil

			--probably unnecessary but you never know
			if attack_data.attacker_unit:movement() then
				if attack_data.attacker_unit:movement().m_head_pos then
					from_pos = attack_data.attacker_unit:movement():m_head_pos()
				elseif attack_data.attacker_unit:movement().m_pos then
					from_pos = attack_data.attacker_unit:movement():m_pos()
				else
					from_pos = attack_data.attacker_unit:position()
				end
			else
				from_pos = attack_data.attacker_unit:position()
			end

			local push_vec = Vector3()
			local distance = mvector3.direction(push_vec, from_pos, self._unit:movement():m_head_pos())
			mvector3.normalize(push_vec)

			local dis_lerp_value = math.clamp(distance, 0, 1000) / 1000
			local push_amount = math.lerp(1000, 0, dis_lerp_value)

			self._unit:movement():push(push_vec * push_amount)
		end
	end

	self:_hit_direction(attack_data.attacker_unit:position())
	
	if not attack_data.is_taser_shock then
		self._last_received_dmg = attack_data.damage

		local dodge_roll = math.random()
		local dodge_value = tweak_data.player.damage.DODGE_INIT or 0
		local armor_dodge_chance = pm:body_armor_value("dodge")
		local skill_dodge_chance = pm:skill_dodge_chance(self._unit:movement():running(), self._unit:movement():crouching(), self._unit:movement():zipline_unit())
		dodge_value = dodge_value + armor_dodge_chance + skill_dodge_chance

		if self._temporary_dodge_t and TimerManager:game():time() < self._temporary_dodge_t then
			dodge_value = dodge_value + self._temporary_dodge
		end

		local smoke_dodge = 0

		for _, smoke_screen in ipairs(pm._smoke_screen_effects or {}) do
			if smoke_screen:is_in_smoke(self._unit) then
				smoke_dodge = tweak_data.projectiles.smoke_screen_grenade.dodge_chance

				break
			end
		end

		dodge_value = 1 - (1 - dodge_value) * (1 - smoke_dodge)
		
		local sneakier_activated = nil
		
		if dodge_roll <= dodge_value then
			self:play_whizby(attack_data.col_ray.position)
			pm:send_message(Message.OnPlayerDodge)
			
			if pm:has_category_upgrade("player", "highvigour_aced") then
				self._unit:movement():add_stamina(5)
			end
			
			return
		else
			if pm:has_category_upgrade("player", "sneakier_aced") then
				local new_roll = math.random()
				if new_roll <= dodge_value then
					sneakier_activated = true
				end
			end
		end
		--log("damage was " .. tostring(attack_data.damage) .. "")
		local dmg_mul = pm:damage_reduction_skill_multiplier("bullet", sneakier_activated)
		attack_data.damage = attack_data.damage * dmg_mul
		attack_data.damage = pm:modify_value("damage_taken", attack_data.damage, attack_data)
		--log("damage became " .. tostring(attack_data.damage) .. "")
		attack_data.damage = managers.mutators:modify_value("PlayerDamage:TakeDamageBullet", attack_data.damage)
		attack_data.damage = managers.modifiers:modify_value("PlayerDamage:TakeDamageBullet", attack_data.damage)

		if _G.IS_VR then
			local distance = mvector3.distance(self._unit:position(), attack_data.attacker_unit:position())

			if tweak_data.vr.long_range_damage_reduction_distance[1] < distance then
				local step = math.clamp(distance / tweak_data.vr.long_range_damage_reduction_distance[2], 0, 1)
				local mul = 1 - math.step(tweak_data.vr.long_range_damage_reduction[1], tweak_data.vr.long_range_damage_reduction[2], step)
				attack_data.damage = attack_data.damage * mul
			end
		end

		local damage_absorption = pm:damage_absorption()

		if damage_absorption > 0 then
			attack_data.damage = math.max(0, attack_data.damage - damage_absorption)
		end
	end
	
	if not attack_data.is_taser_shock then

		local shake_armor_multiplier = pm:body_armor_value("damage_shake") * pm:upgrade_value("player", "damage_shake_multiplier", 1)
		local gui_shake_number = tweak_data.gui.armor_damage_shake_base / shake_armor_multiplier
		gui_shake_number = gui_shake_number + pm:upgrade_value("player", "damage_shake_addend", 0)
		shake_armor_multiplier = tweak_data.gui.armor_damage_shake_base / gui_shake_number
		local shake_multiplier = math.clamp(attack_data.damage, 0.2, 2) * shake_armor_multiplier
		
		self._unit:camera():play_shaker("player_bullet_damage", 1 * shake_multiplier)

		if not _G.IS_VR then
			managers.rumble:play("damage_bullet")
		end

		pm:check_damage_carry(attack_data)

		if self._bleed_out then
			if attack_data.damage == 0 then
				self._unit:sound():play("player_hit")
			else
				self._unit:sound():play("player_hit_permadamage")
			end

			self:_bleed_out_damage(attack_data)

			return
		else
			if self:get_real_armor() > 0 or attack_data.damage == 0 then
				self._unit:sound():play("player_hit")
			else
				self._unit:sound():play("player_hit_permadamage")
			end
		end
	else
		self._unit:sound():play("player_hit_permadamage")
	end

	self:_check_chico_heal(attack_data)

	local armor_reduction_multiplier = 0

	if self:get_real_armor() <= 0 then
		armor_reduction_multiplier = 1
	end

	local health_subtracted = self:_calc_armor_damage(attack_data)

	if attack_data.armor_piercing then
		attack_data.damage = attack_data.damage - health_subtracted
	else
		attack_data.damage = attack_data.damage * armor_reduction_multiplier
	end

	health_subtracted = health_subtracted + self:_calc_health_damage(attack_data)

	if not self._bleed_out then
		if health_subtracted > 0 then
			self:_send_damage_drama(attack_data, health_subtracted)
		end
	else
		local attacker = attack_data.attacker_unit

		if attacker:character_damage() and attacker:character_damage().dead and not attacker:character_damage():dead() then
			if attacker:base().has_tag then
				if attacker:base():has_tag("tank") then
					attack_data.attacker_unit:sound():say("post_kill_taunt")
				elseif attacker:base():has_tag("taser") then
					attack_data.attacker_unit:sound():say("post_tasing_taunt")
				elseif attacker:base():has_tag("law") and not attacker:base():has_tag("special") then
					attack_data.attacker_unit:sound():say("i03")
				end
			end
		end
	end

	pm:send_message(Message.OnPlayerDamage, nil, attack_data)
	self:_call_listeners(damage_info)

	return true
end

local _calc_armor_damage_original = PlayerDamage._calc_armor_damage
function PlayerDamage:_calc_armor_damage(attack_data, ...)
	attack_data.damage = attack_data.damage - (self._old_last_received_dmg or 0)
	self._next_allowed_dmg_t = self._old_next_allowed_dmg_t and Application:digest_value(self._old_next_allowed_dmg_t, true) or self._next_allowed_dmg_t
	self._old_last_received_dmg = nil
	self._old_next_allowed_dmg_t = nil
	return _calc_armor_damage_original(self, attack_data, ...)
end

function PlayerDamage:_calc_armor_damage(attack_data)
	local health_subtracted = 0
	
	attack_data.damage = attack_data.damage - (self._old_last_received_dmg or 0)
	
	self._next_allowed_dmg_t = self._old_next_allowed_dmg_t and Application:digest_value(self._old_next_allowed_dmg_t, true) or self._next_allowed_dmg_t
		
	self._old_last_received_dmg = nil
	self._old_next_allowed_dmg_t = nil
	
	if self:get_real_armor() > 0 then
		health_subtracted = self:get_real_armor()

		self:change_armor(-attack_data.damage)

		health_subtracted = health_subtracted - self:get_real_armor()
		
		self:_damage_screen()
		SoundDevice:set_rtpc("shield_status", self:armor_ratio() * 100)
		self:_send_set_armor()

		if self:get_real_armor() <= 0 then
			self._unit:sound():play("player_armor_gone_stinger")

			if attack_data.armor_piercing then
				self._unit:sound():play("player_sniper_hit_armor_gone")
			end

			local pm = managers.player
			
			if not self._unit:movement():tased() then
				self:_start_regen_on_the_side(pm:upgrade_value("player", "passive_always_regen_armor", 0))
				
				if pm:has_inactivate_temporary_upgrade("temporary", "armor_break_invulnerable") then
					pm:activate_temporary_upgrade("temporary", "armor_break_invulnerable")

					self._can_take_dmg_timer = pm:temporary_upgrade_value("temporary", "armor_break_invulnerable", 0)
				end
			end
		end
	end

	managers.hud:damage_taken()

	return health_subtracted
end

function PlayerDamage:_calc_health_damage(attack_data)

	attack_data.damage = attack_data.damage - (self._old_last_received_dmg or 0)
	if self._unit then
		local state = self._unit:movement():current_state_name()
		if state == "driving" or self._unit:movement():zipline_unit() then
			attack_data.damage = attack_data.damage * 0.5
		end
	end
	self._next_allowed_dmg_t = self._old_next_allowed_dmg_t and Application:digest_value(self._old_next_allowed_dmg_t, true) or self._next_allowed_dmg_t
	self._old_last_received_dmg = nil
	self._old_next_allowed_dmg_t = nil
	
	local health_subtracted = 0
	local death_prevented = nil
	health_subtracted = self:get_real_health()
	local revive_reasons = self._phoenix_down_t or self._docbag_token or self._jackpot_token
	
	if revive_reasons and self:get_real_health() - attack_data.damage <= 0 then
		death_prevented = true
	else
		self:change_health(-attack_data.damage)
	end

	health_subtracted = health_subtracted - self:get_real_health()
	local trigger_skills = table.contains({
		"bullet",
		"explosion",
		"melee",
		"delayed_tick"
	}, attack_data.variant)

	if self:get_real_health() == 0 and trigger_skills then
		self:_chk_cheat_death()
	end
	
	local incap_attack = attack_data.is_cloaker_kick or attack_data.is_taser_shock or nil
	
	self:_damage_screen()
	self:_check_bleed_out(trigger_skills, nil, incap_attack)
	managers.hud:set_player_health({
		current = self:get_real_health(),
		total = self:_max_health(),
		revives = Application:digest_value(self._revives, false)
	})
	self:_send_set_health()
	self:_set_health_effect()
	managers.statistics:health_subtracted(health_subtracted)
	
	if death_prevented then 
		if self._phoenix_down_t then
			self._unit:sound():play("pickup_fak_skill")
			return 0
		elseif self._docbag_token then
			self._docbag_token = nil
			self._unit:sound():play("pickup_fak_skill")
			--log("WOO")
			return 0
		elseif self._jackpot_token then
			self._jackpot_token = nil
			self._unit:sound():play("pickup_fak_skill")
			--log("Jackpot just saved you!")
			return 0
		end
	else
		return health_subtracted
	end
end

function PlayerDamage:is_friendly_fire(unit)
	if not unit or not unit:movement() or unit:base().is_grenade then
		return false
	end

	if unit:movement() and unit:movement():team() and unit:movement():team() ~= self._unit:movement():team() and unit:movement():friendly_fire() then
		return false
	end

	local friendly_fire = not unit:movement():team().foes[self._unit:movement():team().id]
	friendly_fire = managers.mutators:modify_value("PlayerDamage:FriendlyFire", friendly_fire)

	return friendly_fire
end

function PlayerDamage:build_suppression(amount)
	--if self:_chk_suppression_too_soon(amount) then
		--return
	--end

	local data = self._supperssion_data
	amount = amount * managers.player:upgrade_value("player", "suppressed_multiplier", 1)
	local armor_damage = self:_max_armor() > 0 and self:get_real_armor() < self:_max_armor()
	
	if amount >= 99 then
		self._akuma_effect = true
		self._akuma_dampen = 50
		SoundDevice:set_rtpc("downed_state_progression", self._akuma_dampen)
	end
		
	local morale_boost_bonus = self._unit:movement():morale_boost()

	if morale_boost_bonus then
		amount = amount * morale_boost_bonus.suppression_resistance
	end

	amount = amount * tweak_data.player.suppression.receive_mul
	data.value = math.min(tweak_data.player.suppression.max_value, (data.value or 0) + amount * tweak_data.player.suppression.receive_mul)
	
	if managers.player:has_category_upgrade("player", "strong_spirit") and self:health_ratio() <= 0.5 then
		amount = amount * 0.5
	end
	
	self._last_received_sup = amount
	self._next_allowed_sup_t = managers.player:player_timer():time() + self._dmg_interval
	
	local decay_t = 0.1 * math.min(amount, 15)
	
	if self._akuma_effect then
		decay_t = decay_t + 2
	end
	
	if not data.decay_start_t or data.decay_start_t < managers.player:player_timer():time() then
		if self._akuma_effect then
			data.decay_start_t = managers.player:player_timer():time() + decay_t
		else
			data.decay_start_t = managers.player:player_timer():time() + decay_t
		end
	else
		if self._akuma_effect then
			data.decay_start_t = managers.player:player_timer():time() + decay_t
		else
			local raw_decay_start_t = math.max(0, data.decay_start_t - managers.player:player_timer():time())
			
			--log("current regen t is " .. tostring(raw_decay_start_t) .. "")
			
			if raw_decay_start_t >= 0 and raw_decay_start_t < 1.5 then
				decay_t = math.min(1.5, decay_t)
				
				if decay_t + raw_decay_start_t > 1.5 then
					decay_t = decay_t - raw_decay_start_t
				end
				
				if decay_t > 0 then
					--log("decay t is " .. tostring(decay_t) .. "")	
					
					data.decay_start_t = data.decay_start_t + decay_t
				end
			end
		end
	end
end

function PlayerDamage:_upd_suppression(t, dt)
	local data = self._supperssion_data

	if data.value then
		if data.decay_start_t < t then
			local drain = dt * 30
			data.value = data.value - drain
			
			--log("ratio is " .. tostring(self:suppression_ratio()) .. "")
			
			--log("suppression is " .. tostring(data.value) .. "")

			if data.value <= 0 then
				data.value = nil
				data.decay_start_t = nil
				if PD2THHSHIN:SupEnabled() then
					managers.environment_controller:set_chromatic_value_lerp(0)
					managers.environment_controller:set_contrast_value_lerp(0)
				end
			end
		elseif data.value == tweak_data.player.suppression.max_value and self._regenerate_timer then
			self._listener_holder:call("suppression_max")
		end
		if PD2THHSHIN:SupEnabled() then
			if data.value then
				managers.environment_controller:set_chromatic_value_lerp(self:suppression_ratio())
				managers.environment_controller:set_contrast_value_lerp(self:suppression_ratio())
			end
		end
	end
end

function PlayerDamage:_begin_akuma_snddedampen()
	if self._akuma_dampen and self._akuma_dampen > 0 then
		self._akuma_dampen = 0
		SoundDevice:set_rtpc("downed_state_progression", self._akuma_dampen)		
	end
end

Hooks:PostHook(PlayerDamage, "_regenerate_armor", "hh_regenarmor", function(self, no_sound)
	self._akuma_effect = nil
	if self._akuma_dampen then
		--self._is_damping = true
		self:_begin_akuma_snddedampen()
	end
end)

function PlayerDamage:update(unit, t, dt)
	if _G.IS_VR and self._heartbeat_t and t < self._heartbeat_t then
		local intensity_mul = 1 - (t - self._heartbeat_start_t) / (self._heartbeat_t - self._heartbeat_start_t)
		local controller = self._unit:base():controller():get_controller("vr")

		for i = 0, 1, 1 do
			local intensity = get_heartbeat_value(t)
			intensity = intensity * (1 - math.clamp(self:health_ratio() / 0.3, 0, 1))
			intensity = intensity * intensity_mul

			controller:trigger_haptic_pulse(i, 0, intensity * 900)
		end
	end

	self:_check_update_max_health()
	self:_check_update_max_armor()
	self:_update_can_take_dmg_timer(dt)
	self:_update_regen_on_the_side(dt)
	
	if managers.player:has_category_upgrade("player", "melee_damage_health_ratio_multiplier") and self:health_ratio() <= 0.5 then
		if not self._unit:movement():next_reload_speed_multiplier() or self._unit:movement():next_reload_speed_multiplier() < 1.5 then
			self._unit:movement():set_next_reload_speed_multiplier(1.5)
		end
	end

	if not self._armor_stored_health_max_set then
		self._armor_stored_health_max_set = true

		self:update_armor_stored_health()
	end

	if managers.player:has_activate_temporary_upgrade("temporary", "chico_injector") then
		self._chico_injector_active = true
		local total_time = managers.player:upgrade_value("temporary", "chico_injector")[2]
		local current_time = managers.player:get_activate_temporary_expire_time("temporary", "chico_injector") - t

		managers.hud:set_player_ability_radial({
			current = current_time,
			total = total_time
		})
	elseif self._chico_injector_active then
		managers.hud:set_player_ability_radial({
			current = 0,
			total = 1
		})

		self._chico_injector_active = nil
	end

	local is_berserker_active = managers.player:has_activate_temporary_upgrade("temporary", "berserker_damage_multiplier")

	if self._check_berserker_done then
		if is_berserker_active then
			if self._unit:movement():tased() then
				self._tased_during_berserker = true
			else
				self._tased_during_berserker = false
			end
		end

		if not is_berserker_active then
			if self._unit:movement():tased() then
				self._bleed_out_blocked_by_tased = true
			else
				self._bleed_out_blocked_by_tased = false
				self._check_berserker_done = nil

				managers.hud:set_teammate_condition(HUDManager.PLAYER_PANEL, "mugshot_normal", "")
				managers.hud:set_player_custom_radial({
					current = 0,
					total = self:_max_health(),
					revives = Application:digest_value(self._revives, false)
				})
				self:force_into_bleedout()

				if not self._bleed_out then
					self._disable_next_swansong = true
				end
			end
		else
			local expire_time = managers.player:get_activate_temporary_expire_time("temporary", "berserker_damage_multiplier")
			local total_time = managers.player:upgrade_value("temporary", "berserker_damage_multiplier")
			total_time = total_time and total_time[2] or 0
			local delta = 0
			local max_health = self:_max_health()

			if total_time ~= 0 then
				delta = math.clamp((expire_time - Application:time()) / total_time, 0, 1)
			end

			managers.hud:set_player_custom_radial({
				current = delta * max_health,
				total = max_health,
				revives = Application:digest_value(self._revives, false)
			})
			managers.network:session():send_to_peers("sync_swansong_timer", self._unit, delta * max_health, max_health, Application:digest_value(self._revives, false), managers.network:session():local_peer():id())
		end
	end

	if self._bleed_out_blocked_by_zipline and not self._unit:movement():zipline_unit() then
		self:force_into_bleedout(true)

		self._bleed_out_blocked_by_zipline = nil
	end

	if self._bleed_out_blocked_by_movement_state and not self._unit:movement():current_state():bleed_out_blocked() then
		self:force_into_bleedout()

		self._bleed_out_blocked_by_movement_state = nil
	end

	if self._bleed_out_blocked_by_tased and not self._unit:movement():tased() then
		self:force_into_bleedout()

		self._bleed_out_blocked_by_tased = nil
	end

	if self._current_state then
		self:_current_state(t, dt)
	end

	self:_update_armor_hud(t, dt)

	if self._tinnitus_data then
		self._tinnitus_data.intensity = (self._tinnitus_data.end_t - t) / self._tinnitus_data.duration

		if self._tinnitus_data.intensity <= 0 then
			self:_stop_tinnitus()
		else
			SoundDevice:set_rtpc("downed_state_progression", math.max(self._downed_progression or 0, self._tinnitus_data.intensity * 100))
		end
	end

	if self._concussion_data then
		self._concussion_data.intensity = (self._concussion_data.end_t - t) / self._concussion_data.duration

		if self._concussion_data.intensity <= 0 then
			self:_stop_concussion()
		else
			SoundDevice:set_rtpc("concussion_effect", self._concussion_data.intensity * 100)
		end
	end

	if not self._downed_timer and self._downed_progression then
		self._downed_progression = math.max(0, self._downed_progression - dt * 50)
		local blur = self._downed_progression
		
		if PD2THHSHIN:BlurzoneEnabled() then
			blur = blur * 0.5
		end
		
		if not _G.IS_VR then
			managers.environment_controller:set_downed_value(blur)
		end

		SoundDevice:set_rtpc("downed_state_progression", self._downed_progression)

		if self._downed_progression == 0 then
			self._unit:sound():play("critical_state_heart_stop")

			self._downed_progression = nil
		end
	end

	if self._auto_revive_timer then
		if not managers.platform:presence() == "Playing" or not self._bleed_out or self._dead or self:incapacitated() or self:arrested() or self._check_berserker_done then
			self._auto_revive_timer = nil
		else
			self._auto_revive_timer = self._auto_revive_timer - dt

			if self._auto_revive_timer <= 0 then
				self:revive(true)
				self._unit:sound_source():post_event("nine_lives_skill")

				self._auto_revive_timer = nil
			end
		end
	end
	
	if self._start_phoenix_down_t then
		self._phoenix_down_t = t + 1.5
		self._start_phoenix_down_t = nil
	end
	
	if self._phoenix_down_t and self._phoenix_down_t < t then
		self._phoenix_down_t = nil
	end

	if self._revive_miss then
		self._revive_miss = self._revive_miss - dt

		if self._revive_miss <= 0 then
			self._revive_miss = nil
		end
	end
	
	if PD2THHSHIN.need_to_reset_visuals then
		managers.environment_controller:set_chromatic_value_lerp(0)
		managers.environment_controller:set_contrast_value_lerp(0)
		PD2THHSHIN.need_to_reset_visuals = nil
	end

	self:_upd_suppression(t, dt)

	if not self._dead and not self._bleed_out and not self._check_berserker_done then
		self:_upd_health_regen(t, dt)
	end

	if not self:is_downed() then
		self:_update_delayed_damage(t, dt)
	end
end

function PlayerDamage:revive(silent)
	if Application:digest_value(self._revives, false) == 0 then
		self._revive_health_multiplier = nil

		return
	end

	local arrested = self:arrested()

	managers.player:set_player_state("standard")

	if not silent then
		PlayerStandard.say_line(self, "s05x_sin")
	end

	self._bleed_out = false
	self._incapacitated = nil
	self._downed_timer = nil
	self._downed_start_time = nil

	if not arrested then
		self:set_health(self:_max_health() * tweak_data.player.damage.REVIVE_HEALTH_STEPS[self._revive_health_i] * (self._revive_health_multiplier or 1) * managers.player:upgrade_value("player", "revived_health_regain", 1))
		self:set_armor(self:_max_armor())

		self._revive_health_i = math.min(#tweak_data.player.damage.REVIVE_HEALTH_STEPS, self._revive_health_i + 1)
		self._revive_miss = 2
	end

	self:_regenerate_armor()
	managers.hud:set_player_health({
		current = self:get_real_health(),
		total = self:_max_health(),
		revives = Application:digest_value(self._revives, false)
	})
	self:_send_set_health()
	self:_set_health_effect()
	managers.hud:pd_stop_progress()

	self._revive_health_multiplier = nil

	self._listener_holder:call("on_revive")
	
	if not self._phoenix_down_t and managers.player:has_category_upgrade("player", "phoenix_down") then
		self._start_phoenix_down_t = true
	end
	
	if managers.player:has_category_upgrade("player", "comeback") then
		 managers.player:do_comeback_blast() --DON'T CALL IT A COMEBACK!!!
	end

	if managers.player:has_inactivate_temporary_upgrade("temporary", "revived_damage_resist") then
		managers.player:activate_temporary_upgrade("temporary", "revived_damage_resist")
	end

	if managers.player:has_inactivate_temporary_upgrade("temporary", "increased_movement_speed") then
		managers.player:activate_temporary_upgrade("temporary", "increased_movement_speed")
	end

	if managers.player:has_inactivate_temporary_upgrade("temporary", "swap_weapon_faster") then
		managers.player:activate_temporary_upgrade("temporary", "swap_weapon_faster")
	end

	if managers.player:has_inactivate_temporary_upgrade("temporary", "reload_weapon_faster") then
		managers.player:activate_temporary_upgrade("temporary", "reload_weapon_faster")
	end
end