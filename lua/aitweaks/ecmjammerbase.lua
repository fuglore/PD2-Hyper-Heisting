local mvec3_cpy = mvector3.copy
local mvec3_norm = mvector3.normalize

local math_random = math.random

local world_g = World
local ipairs_g = ipairs

function ECMJammerBase._detect_and_give_dmg(from_pos, device_unit, user_unit, range)
	local enemies_in_range = world_g:find_units_quick("sphere", from_pos, range, managers.slot:get_mask("enemies"))
	local attacker = alive(user_unit) and user_unit or nil
	local weapon = alive(device_unit) and device_unit or nil

	for _, enemy in ipairs_g(enemies_in_range) do
		local dmg_ext = enemy:character_damage()

		if dmg_ext and dmg_ext.damage_explosion then
			local ecm_vuln = enemy:base() and enemy:base():char_tweak() and enemy:base():char_tweak().ecm_vulnerability

			if ecm_vuln and ecm_vuln ~= 0 then
				local can_stun = true
				local brain_ext = enemy:brain()

				if brain_ext then
					if brain_ext.is_hostage and brain_ext:is_hostage() or brain_ext.surrendered and brain_ext:surrendered() then
						can_stun = false
					end
				end

				if can_stun then
					if enemy:anim_data() and enemy:anim_data().act or enemy:movement():chk_action_forbidden("hurt") or ecm_vuln < math_random() then
						can_stun = false
					end
				end

				if can_stun then
					local hit_pos = mvec3_cpy(enemy:movement():m_head_pos())
					local attack_dir = hit_pos - from_pos
					mvec3_norm(attack_dir)

					local attack_data = {
						damage = 0,
						variant = "stun",
						attacker_unit = attacker,
						weapon_unit = weapon,
						col_ray = {
							position = hit_pos,
							ray = attack_dir
						}
					}

					dmg_ext:damage_explosion(attack_data)
				end
			end
		end
	end
end

local update_original = ECMJammerBase.update
function ECMJammerBase:update(...)
	--pain
	self._unit:m_position(self._position)
	self._unit:m_rotation(self._rotation)

	update_original(self, ...)
end

function ECMJammerBase:_set_feedback_active(state)
	state = state and true

	if state == self._feedback_active then
		return
	end

	if Network:is_server() then
		if state then
			self._unit:interaction():set_active(false, true)

			local t = TimerManager:game():time()
			self._feedback_clbk_id = "ecm_feedback" .. tostring(self._unit:key())
			self._feedback_interval = tweak_data.upgrades.ecm_feedback_interval or 1
			self._feedback_range = tweak_data.upgrades.ecm_jammer_base_range
			local duration_mul = 1

			if self._owner_id == 1 then
				duration_mul = duration_mul * managers.player:upgrade_value("ecm_jammer", "feedback_duration_boost", 1)
				duration_mul = duration_mul * managers.player:upgrade_value("ecm_jammer", "feedback_duration_boost_2", 1)
			else
				duration_mul = duration_mul * (self:owner():base():upgrade_value("ecm_jammer", "feedback_duration_boost") or 1)
				duration_mul = duration_mul * (self:owner():base():upgrade_value("ecm_jammer", "feedback_duration_boost_2") or 1)
			end

			self._feedback_duration = tweak_data.upgrades.ecm_feedback_min_duration * duration_mul --fuck rng
			self._feedback_expire_t = t + self._feedback_duration
			local first_impact_t = t + 1 --fuck rng

			managers.enemy:add_delayed_clbk(self._feedback_clbk_id, callback(self, self, "clbk_feedback"), first_impact_t)
			self:_send_net_event(self._NET_EVENTS.feedback_start)
		else
			if self._feedback_clbk_id then
				managers.enemy:remove_delayed_clbk(self._feedback_clbk_id)

				self._feedback_clbk_id = nil
			end

			self:_send_net_event(self._NET_EVENTS.feedback_stop)

			if alive(self._owner) then
				local retrigger = false

				if self._owner_id == 1 then
					retrigger = managers.player:has_category_upgrade("ecm_jammer", "can_retrigger")
				else
					retrigger = self:owner():base():upgrade_value("ecm_jammer", "can_retrigger")
				end

				if retrigger then
					self._chk_feedback_retrigger_t = tweak_data.upgrades.ecm_feedback_retrigger_interval or 60
				end
			end
		end
	end

	if state then
		--print("PUKE!")
		self._g_glow_feedback_green:set_visibility(true)
		self._g_glow_feedback_red:set_visibility(false)

		if not self._puke_sound_event then
			self._puke_sound_event = self._unit:sound_source():post_event("ecm_jammer_puke_signal")
		end

		self._unit:contour():remove("deployable_interactable")
		self._unit:contour():add("deployable_active")
	else
		self._g_glow_feedback_green:set_visibility(false)
		self._g_glow_feedback_red:set_visibility(false)

		if self._puke_sound_event then
			self._puke_sound_event:stop()

			self._puke_sound_event = nil

			self._unit:sound_source():post_event("ecm_jammer_puke_signal_stop")
		end

		if self._unit:contour() then
			self._unit:contour():remove("deployable_active")
		end
	end

	self._feedback_active = state
end

function ECMJammerBase:clbk_feedback()
	local t = TimerManager:game():time()
	self._feedback_clbk_id = "ecm_feedback" .. tostring(self._unit:key())

	if not managers.groupai:state():enemy_weapons_hot() then
		managers.groupai:state():propagate_alert({
			"vo_cbt",
			self._position,
			10000,
			self._alert_filter,
			self._unit
		})
	end

	--print("PUKING!!!!!")
	self._detect_and_give_dmg(self._position + self._unit:rotation():y() * 15, self._unit, self:owner(), self._feedback_range)

	if self._feedback_expire_t < t then
		self._feedback_clbk_id = nil

		self:_set_feedback_active(false)
	else
		if self._feedback_expire_t - t < self._feedback_duration * 0.1 then
			self._g_glow_feedback_red:set_visibility(true)
			self._g_glow_feedback_green:set_visibility(false)

			if not self._unit:contour():is_flashing() then
				self._unit:contour():flash("deployable_active", 0.15)

				if Network:is_server() then
					self:_send_net_event(self._NET_EVENTS.feedback_flash)
				end
			end
		end

		managers.enemy:add_delayed_clbk(self._feedback_clbk_id, callback(self, self, "clbk_feedback"), t + self._feedback_interval)
	end
end