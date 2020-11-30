local world_g = World
local temp_vec1 = Vector3()

function PlayerManager:_chk_fellow_crimin_proximity(unit)
	local players_nearby = 0
		
	local enemies = world_g:find_units_quick(unit, "sphere", unit:position(), 1500, managers.slot:get_mask("criminals_no_deployables"))

	for _, enemy in ipairs(enemies) do
		players_nearby = players_nearby + 1
	end
		
	if players_nearby <= 0 then
		--log("uhohstinky")
	end
		
	return players_nearby
end

function PlayerManager:skill_dodge_chance(running, crouching, on_zipline, override_armor, detection_risk)
	local chance = self:upgrade_value("player", "passive_dodge_chance", 0)
	local dodge_shot_gain = self:_dodge_shot_gain()
	local player_unit = self:player_unit()
	for _, smoke_screen in ipairs(self._smoke_screen_effects or {}) do
		if smoke_screen:is_in_smoke(self:player_unit()) then
			if smoke_screen:mine() then
				chance = chance * self:upgrade_value("player", "sicario_multiplier", 1)
				dodge_shot_gain = dodge_shot_gain * self:upgrade_value("player", "sicario_multiplier", 1)
			else
				chance = chance + smoke_screen:dodge_bonus()
			end
		end
	end
	
	if player_unit then
		local wavedash_active = player_unit:movement():current_state()._wave_dash_t
		
		if wavedash_active and player_unit:movement():is_above_stamina_threshold() then
			chance = chance + 0.05
		end
	end
	
	if self:has_category_upgrade("player", "highvigour_aced") then
		chance = chance + 0.1
	end

	chance = chance + dodge_shot_gain
	chance = chance + self:upgrade_value("player", "tier_dodge_chance", 0)

	if running and player_unit:movement():is_above_stamina_threshold() then
		chance = chance + self:upgrade_value("player", "run_dodge_chance", 0)
	end

	if crouching then
		chance = chance + self:upgrade_value("player", "crouch_dodge_chance", 0)
	end

	if on_zipline then
		chance = chance + self:upgrade_value("player", "on_zipline_dodge_chance", 0)
	end

	local detection_risk_add_dodge_chance = managers.player:upgrade_value("player", "detection_risk_add_dodge_chance")
	chance = chance + self:get_value_from_risk_upgrade(detection_risk_add_dodge_chance, detection_risk)
	chance = chance + self:upgrade_value("player", tostring(override_armor or managers.blackmarket:equipped_armor(true, true)) .. "_dodge_addend", 0)
	chance = chance + self:upgrade_value("team", "crew_add_dodge", 0)
	chance = chance + self:temporary_upgrade_value("temporary", "pocket_ecm_kill_dodge", 0)

	return chance
end

function PlayerManager:speak(message, arg1, arg2)
	if self:player_unit() and self:player_unit():sound() then
		self:player_unit():sound():say(message, arg1, arg2)
	end
end

function PlayerManager:get_health_ratio_easy()
	local player_unit = self:player_unit()
	local damage_ext = player_unit:character_damage()
	return damage_ext:health_ratio()
end

function PlayerManager:consume_bloodthirst_reload()	
	if self._melee_reload_speed_active then
		--log("*toilet flush noise*")
		self._enemies_killed_bloodthirst = nil
		self._melee_damage_mult = nil
		self._melee_reload_speed_active = nil
		self._reload_speed_bonus = nil
	end
end

function PlayerManager:damage_reduction_skill_multiplier(damage_type, sneakier_activated)
	local multiplier = 1
	multiplier = multiplier * self:temporary_upgrade_value("temporary", "dmg_dampener_outnumbered", 1)
	multiplier = multiplier * self:temporary_upgrade_value("temporary", "dmg_dampener_outnumbered_strong", 1)
	multiplier = multiplier * self:temporary_upgrade_value("temporary", "dmg_dampener_close_contact", 1)
	multiplier = multiplier * self:temporary_upgrade_value("temporary", "revived_damage_resist", 1)
	multiplier = multiplier * self:upgrade_value("player", "damage_dampener", 1)
	multiplier = multiplier * self:upgrade_value("player", "health_damage_reduction", 1)
	multiplier = multiplier * self:temporary_upgrade_value("temporary", "first_aid_damage_reduction", 1)
	multiplier = multiplier * self:temporary_upgrade_value("temporary", "revive_damage_reduction", 1)
	multiplier = multiplier * self:get_hostage_bonus_multiplier("damage_dampener")
	multiplier = multiplier * self._properties:get_property("revive_damage_reduction", 1)
	multiplier = multiplier * self._temporary_properties:get_property("revived_damage_reduction", 1)
	local dmg_red_mul = self:team_upgrade_value("damage_dampener", "team_damage_reduction", 1)
	
	if sneakier_activated then
		multiplier = multiplier * 0.75
	end

	if self:has_category_upgrade("player", "passive_damage_reduction") then
		local health_ratio = self:player_unit():character_damage():health_ratio()
		local min_ratio = self:upgrade_value("player", "passive_damage_reduction")

		if health_ratio < min_ratio then
			dmg_red_mul = dmg_red_mul - (1 - dmg_red_mul)
		end
	end

	multiplier = multiplier * dmg_red_mul

	if damage_type == "melee" then
		multiplier = multiplier * managers.player:upgrade_value("player", "melee_damage_dampener", 1)
	end

	local current_state = self:get_current_state()

	if current_state and current_state:_interacting() then
		multiplier = multiplier * managers.player:upgrade_value("player", "interacting_damage_multiplier", 1)
	end

	return multiplier
end

function PlayerManager:on_killshot(killed_unit, variant, headshot, weapon_id)
	local player_unit = self:player_unit()
	local effect_sync_index = nil

	if not player_unit then
		return
	end

	if CopDamage.is_civilian(killed_unit:base()._tweak_table) then
		return
	end

	local weapon_melee = weapon_id and tweak_data.blackmarket and tweak_data.blackmarket.melee_weapons and tweak_data.blackmarket.melee_weapons[weapon_id] and true

	if killed_unit:brain().surrendered and killed_unit:brain():surrendered() and (variant == "melee" or weapon_melee) then
		managers.custom_safehouse:award("daily_honorable")
	end

	managers.modifiers:run_func("OnPlayerManagerKillshot", player_unit, killed_unit:base()._tweak_table, variant)

	local equipped_unit = self:get_current_state()._equipped_unit
	self._num_kills = self._num_kills + 1

	if self._num_kills % self._SHOCK_AND_AWE_TARGET_KILLS == 0 and self:has_category_upgrade("player", "automatic_faster_reload") then
		self:_on_enter_shock_and_awe_event()
	end

	self._message_system:notify(Message.OnEnemyKilled, nil, equipped_unit, variant, killed_unit)
	
	if PD2THHSHIN and PD2THHSHIN:IsOverhaulEnabled() then
		local equipped_unit = self:get_current_state()._equipped_unit:base()
		
		if self:has_category_upgrade("player", "panic_suppression") then --let's make this fuckin' happen
			local suppression_amount = equipped_unit._suppression
			local pos = killed_unit:position()
			local enemies = world_g:find_units_quick(killed_unit, "sphere", pos, 600, 12, 21)
				
			for i, unit in ipairs(enemies) do
				if unit:character_damage() and unit:character_damage().build_suppression then
					unit:character_damage():build_suppression(suppression_amount, 50, nil)
				end
			end
		end
		
		if headshot and self:has_category_upgrade("player", "fineredmist_basic") and equipped_unit:fire_mode() == "single" then
			--THANK YOU FOR IMPROVING ALL OF THIS HOXI AAAAAAAAAAAAAAAAAAAA <33333333
			local pos = killed_unit:movement():m_head_pos()

			--hopefully ill get this working in a pretty way
			world_g:effect_manager():spawn({
				effect = Idstring("effects/pd2_mod_hh/particles/character/gore_explosion"),
				position = pos,
				normal = math.UP
			})

			--split_gen_body

			player_unit:sound():play("expl_gen_head", nil, nil)

			local damage = nil

			if self:has_category_upgrade("player", "fineredmist_aced") then
				damage = 40
				effect_sync_index = 2

				player_unit:sound():play("split_gen_body", nil, nil) --play both of these at once if aced for extra impact
			else
				damage = 0
				effect_sync_index = 1
			end

			local enemies = world_g:find_units_quick(killed_unit, "sphere", pos, 400, managers.slot:get_mask("enemies", "civilians"))
			local obstruction_slotmask = managers.slot:get_mask("world_geometry", "vehicles", "enemy_shield_check")
			local weap_unit = self:get_current_state()._equipped_unit

			for _, enemy in ipairs(enemies) do
				local dmg_ext = enemy:character_damage()

				if dmg_ext and dmg_ext.damage_simple then
					local center_of_mass = enemy:movement():m_com()
					local obstructed = enemy:raycast("ray", pos, center_of_mass, "slot_mask", obstruction_slotmask, "report")

					if not obstructed then
						local attack_dir = center_of_mass - pos
						local attack_data = {
							damage = damage,
							attacker_unit = player_unit,
							guaranteed_stagger = true,
							pos = center_of_mass,
							attack_dir = attack_dir,
							weapon_unit = weap_unit
						}

						dmg_ext:damage_simple(attack_data)
					end
				end
			end
		end
	end
	
	if self._saw_panic_when_kill and variant ~= "melee" then
		local equipped_unit = self:get_current_state()._equipped_unit:base()

		if equipped_unit:is_category("saw") then
			local pos = player_unit:position()
			local skill = self:upgrade_value("saw", "panic_when_kill")

			if skill and type(skill) ~= "number" then
				local area = skill.area
				local chance = skill.chance
				local amount = skill.amount
				local enemies = World:find_units_quick("sphere", pos, area, 12, 21)

				for i, unit in ipairs(enemies) do
					if unit:character_damage() and unit:character_damage().build_suppression then
						unit:character_damage():build_suppression(amount, chance, true)
					end
				end
			end
		end
	end
	
	if self:has_category_upgrade("player", "momentummaker_basic") then
		if variant == "melee" or weapon_melee then
			self._melee_damage_mult = nil
			if self._reload_speed_bonus then
				self._enemies_killed_bloodthirst = nil
				self._melee_reload_speed_active = true
				--log("gotcha")
			end
		elseif not self._melee_damage_mult or self._melee_damage_mult < 6 then
			if not self._enemies_killed_bloodthirst then
				self._enemies_killed_bloodthirst = 1
				--log("begin")
			else
				self._enemies_killed_bloodthirst = self._enemies_killed_bloodthirst + 1
				--log("number is: " .. self._enemies_killed_bloodthirst .. "")
			end
		
			if self._enemies_killed_bloodthirst > 1 then
				if not self._reload_speed_bonus or not self._melee_damage_mult then
					self._reload_speed_bonus = 0.05
					self._melee_damage_mult = 1
					--log("start")
				else
					self._reload_speed_bonus = self._reload_speed_bonus + 0.05
					self._melee_damage_mult = self._melee_damage_mult + 1
					--log("melee damage mult is: " .. self._melee_damage_mult .. "")
				end
				
				self._enemies_killed_bloodthirst = nil
			end
		end
	end

	local t = Application:time()
	local damage_ext = player_unit:character_damage()

	if self:has_category_upgrade("player", "kill_change_regenerate_speed") then
		local amount = self:body_armor_value("skill_kill_change_regenerate_speed", nil, 1)
		local multiplier = self:upgrade_value("player", "kill_change_regenerate_speed", 0)

		damage_ext:change_regenerate_speed(amount * multiplier, tweak_data.upgrades.kill_change_regenerate_speed_percentage)
	end

	local gain_throwable_per_kill = managers.player:upgrade_value("team", "crew_throwable_regen", 0)

	if gain_throwable_per_kill ~= 0 then
		self._throw_regen_kills = (self._throw_regen_kills or 0) + 1

		if gain_throwable_per_kill < self._throw_regen_kills then
			managers.player:add_grenade_amount(1, true)

			self._throw_regen_kills = 0
		end
	end
	
	if damage_ext then
		if self:has_category_upgrade("player", "dark_metamorphosis_aced") then
			damage_ext:restore_health(0.25, true)
		elseif self:has_category_upgrade("player", "dark_metamorphosis_basic") then
			damage_ext:restore_health(0.1, true)
		end
	end

	if self._on_killshot_t and t < self._on_killshot_t then
		return effect_sync_index
	end

	local regen_armor_bonus = self:upgrade_value("player", "killshot_regen_armor_bonus", 0)
	local dist_sq = mvector3.distance_sq(player_unit:movement():m_pos(), killed_unit:movement():m_pos())
	local close_combat_sq = tweak_data.upgrades.close_combat_distance * tweak_data.upgrades.close_combat_distance

	if dist_sq <= close_combat_sq then
		regen_armor_bonus = regen_armor_bonus + self:upgrade_value("player", "killshot_close_regen_armor_bonus", 0)
		local panic_chance = self:upgrade_value("player", "killshot_close_panic_chance", 0)
		panic_chance = managers.modifiers:modify_value("PlayerManager:GetKillshotPanicChance", panic_chance)

		if panic_chance > 0 or panic_chance == -1 then
			local slotmask = managers.slot:get_mask("enemies")
			local units = World:find_units_quick("sphere", player_unit:movement():m_pos(), tweak_data.upgrades.killshot_close_panic_range, slotmask)

			for e_key, unit in pairs(units) do
				if alive(unit) and unit:character_damage() and not unit:character_damage():dead() then
					unit:character_damage():build_suppression(0, panic_chance)
				end
			end
		end
	end

	if damage_ext and regen_armor_bonus > 0 then
		damage_ext:restore_armor(regen_armor_bonus)
	end

	local regen_health_bonus = 0

	if variant == "melee" then
		regen_health_bonus = regen_health_bonus + self:upgrade_value("player", "melee_kill_life_leech", 0)
	end

	if damage_ext and regen_health_bonus > 0 then
		damage_ext:restore_health(regen_health_bonus)
	end

	self._on_killshot_t = t + (tweak_data.upgrades.on_killshot_cooldown or 0)

	if _G.IS_VR then
		local steelsight_multiplier = equipped_unit:base():enter_steelsight_speed_multiplier()
		local stamina_percentage = (steelsight_multiplier - 1) * tweak_data.vr.steelsight_stamina_regen
		local stamina_regen = player_unit:movement():_max_stamina() * stamina_percentage

		player_unit:movement():add_stamina(stamina_regen)
	end
	
	return effect_sync_index
end

function PlayerManager:update(t, dt)
	self._message_system:update()
	self:_update_timers(t)

	if self._need_to_send_player_status then
		self._need_to_send_player_status = nil

		self:need_send_player_status()
	end

	self._sent_player_status_this_frame = nil
	local local_player = self:local_player()

	if self:has_category_upgrade("player", "close_to_hostage_boost") and (not self._hostage_close_to_local_t or self._hostage_close_to_local_t <= t) then
		self._is_local_close_to_hostage = alive(local_player) and managers.groupai and managers.groupai:state():is_a_hostage_within(local_player:movement():m_pos(), tweak_data.upgrades.hostage_near_player_radius)
		self._hostage_close_to_local_t = t + tweak_data.upgrades.hostage_near_player_check_t
	end

	self:_update_damage_dealt(t, dt)

	if #self._global.synced_cocaine_stacks >= 4 then
		local amount = 0

		for i, stack in pairs(self._global.synced_cocaine_stacks) do
			if stack.in_use then
				amount = amount + stack.amount
			end

			if PlayerManager.TARGET_COCAINE_AMOUNT <= amount then
				managers.achievment:award("mad_5")
			end
		end
	end

	self._coroutine_mgr:update(t, dt)
	self._action_mgr:update(t, dt)

	if self._unseen_strike and not self._coroutine_mgr:is_running(PlayerAction.UnseenStrike) then
		local data = self:upgrade_value("player", "unseen_increased_crit_chance", 0)

		if data ~= 0 then
			self._coroutine_mgr:add_coroutine(PlayerAction.UnseenStrike, PlayerAction.UnseenStrike, self, data.min_time, data.max_duration, data.crit_chance)
		end
	end
	
	if self:has_category_upgrade("player", "pop_pop") then
		self:upd_pop_pop(t)
	end
	
	if self._magic_bullet_aced_t and self._magic_bullet_aced_t < t then
		self._magic_bullet_aced_t = nil
	end
	
	if self._max_messiah_charges > 0 then
		if self._messiah_charges < self._max_messiah_charges then
			if not self._messiah_recharge_t then
				self._messiah_recharge_t = t + 120
			elseif self._messiah_recharge_t < t then
				self:_on_messiah_recharge_event()
			end
		end
	end

	self:update_smoke_screens(t, dt)
end

function PlayerManager:upd_pop_pop(t)
	--log("hmm")
	local player_unit = self:player_unit()

	if not player_unit then
		--log("how")
		self._pop_pop_mul = nil
		return
	end
	
	if not player_unit:movement():current_state()._shooting_t_pop then
		--log("hmm")
		self._pop_pop_mul = nil
		return
	end
	
	local weapon_unit = self:equipped_weapon_unit()
	
	if not weapon_unit or weapon_unit:base():fire_mode() == "single" then
		--log("nani")
		return
	end
	
	local state = player_unit:movement():current_state()
	
	if state._shooting_t_pop then
		local pop_t = state._shooting_t_pop - t
		pop_t = math.max(pop_t, 0)
		--log("pop_t is " .. tostring(pop_t) .. "")
		local lerp_value = math.clamp(pop_t, 0, 3) / 3
		local pop_mul = math.lerp(0.25, 0, lerp_value)
		
		self._pop_pop_mul = 0 - pop_mul
		
		--log("pop is " .. tostring(self._pop_pop_mul) .. "")
	else
		--log("aargh")
		self._pop_pop_mul = nil
	end
		
end

function PlayerManager:on_headshot_dealt()
	local player_unit = self:player_unit()

	if not player_unit then
		return
	end

	self._message_system:notify(Message.OnHeadShot, nil, nil)

	local t = Application:time()

	local damage_ext = player_unit:character_damage()
	local regen_armor_bonus = managers.player:upgrade_value("player", "headshot_regen_armor_bonus", 0)
	local regen_armor_t_chk = not self._on_headshot_dealt_t or self._on_headshot_dealt_t and self._on_headshot_dealt_t < t

	if damage_ext and regen_armor_bonus > 0 and regen_armor_t_chk then
		damage_ext:restore_armor(regen_armor_bonus)
		self._on_headshot_dealt_t = t + (tweak_data.upgrades.on_headshot_dealt_cooldown or 0)
	end
	
	if damage_ext and self:has_category_upgrade("player", "jackpot_safety") and not damage_ext:has_jackpot_token() and player_unit:movement() then	
		local cur_state = player_unit:movement():current_state_name()
		local state_chk = cur_state == "standard" or cur_state == "carry" or cur_state == "bipod"
		
		if state_chk then
			if not self._safety_headshot_t or self._safety_headshot_t and self._safety_headshot_t < t then
				damage_ext:activate_jackpot_token()
				self._safety_headshot_t = t + 5
			end
		end
	end
	
	local weapon_unit = self:equipped_weapon_unit()
	
	if self:has_category_upgrade("player", "magic_bullet_basic") then
		if weapon_unit and weapon_unit:base():is_category("pistol", "smg", "assault_rifle", "snp") then
			self:on_ammo_increase(1)
		end
	end
	
	if self:has_category_upgrade("player", "magic_bullet_aced") then
		if weapon_unit and weapon_unit:base():is_category("pistol", "smg", "assault_rifle", "snp") then
			self._magic_bullet_aced_t = t + 2
		end
	end
	
end

function PlayerManager:do_comeback_blast()
	local player_unit = self:player_unit()
	
	if not player_unit then
		return
	end
	
	local pos = player_unit:movement():m_head_pos()
	
	local enemies = world_g:find_units_quick(player_unit, "sphere", pos, 400, managers.slot:get_mask("enemies"))
	
	for _, enemy in ipairs(enemies) do
		local dmg_ext = enemy:character_damage()

		if dmg_ext and dmg_ext.damage_simple then
			local center_of_mass = enemy:movement():m_com()
			local obstructed = enemy:raycast("ray", pos, center_of_mass, "slot_mask", obstruction_slotmask, "report")

			if not obstructed then
				local attack_dir = center_of_mass - pos
				local attack_data = {
					damage = 0,
					attacker_unit = player_unit,
					guaranteed_knockdown = true,
					pos = center_of_mass,
					attack_dir = attack_dir
				}

				dmg_ext:damage_simple(attack_data)
			end
		end
	end
	
end