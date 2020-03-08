require("lib/units/enemies/cop/actions/lower_body/CopActionIdle")
require("lib/units/enemies/cop/actions/lower_body/CopActionWalk")
require("lib/units/enemies/cop/actions/full_body/CopActionAct")
require("lib/units/enemies/cop/actions/lower_body/CopActionTurn")
require("lib/units/enemies/cop/actions/full_body/CopActionHurt")
require("lib/units/enemies/cop/actions/lower_body/CopActionStand")
require("lib/units/enemies/cop/actions/lower_body/CopActionCrouch")
require("lib/units/enemies/cop/actions/upper_body/CopActionShoot")
require("lib/units/enemies/cop/actions/upper_body/CopActionReload")
require("lib/units/enemies/cop/actions/upper_body/CopActionTase")
require("lib/units/enemies/cop/actions/full_body/CopActionDodge")
require("lib/units/enemies/cop/actions/full_body/CopActionWarp")
require("lib/units/enemies/spooc/actions/lower_body/ActionSpooc")
require("lib/units/civilians/actions/lower_body/CivilianActionWalk")
require("lib/units/civilians/actions/lower_body/EscortWithSuitcaseActionWalk")
require("lib/units/enemies/tank/actions/lower_body/TankCopActionWalk")
require("lib/units/enemies/shield/actions/lower_body/ShieldCopActionWalk")
require("lib/units/player_team/actions/lower_body/CriminalActionWalk")
require("lib/units/enemies/cop/actions/upper_body/CopActionHealed")
require("lib/units/enemies/medic/actions/upper_body/MedicActionHeal")

local mvec3_set = mvector3.set
local mvec3_set_z = mvector3.set_z
local mvec3_lerp = mvector3.lerp
local mvec3_add = mvector3.add
local mvec3_sub = mvector3.subtract
local mvec3_mul = mvector3.multiply
local mvec3_norm = mvector3.normalize
local mvec3_len = mvector3.length
local mrot_set = mrotation.set_yaw_pitch_roll
local temp_vec1 = Vector3()
local temp_vec2 = Vector3()
local temp_vec3 = Vector3()
local stance_ctl_pts = {
	0,
	0.34,
	0.67,
	1
}

local old_init = CopMovement.init
local action_variants = {
	security = {
		idle = CopActionIdle,
		act = CopActionAct,
		walk = CopActionWalk,
		turn = CopActionTurn,
		hurt = CopActionHurt,
		stand = CopActionStand,
		crouch = CopActionCrouch,
		shoot = CopActionShoot,
		reload = CopActionReload,
		spooc = ActionSpooc,
		tase = CopActionTase,
		dodge = CopActionDodge,
		warp = CopActionWarp,
		healed = CopActionHealed
	}
}
local security_variant = action_variants.security

function CopMovement:init(unit)
	
	CopMovement._action_variants.tank_ftsu = clone(security_variant)
	CopMovement._action_variants.tank_ftsu.walk = TankCopActionWalk
	CopMovement._action_variants.spooc_heavy = security_variant
	CopMovement._action_variants.fbi_xc45 = security_variant
	CopMovement._action_variants.armored_swat = security_variant
	CopMovement._action_variants.akuma = clone(security_variant)
	CopMovement._action_variants.akuma.hurt = ShieldActionHurt
	CopMovement._action_variants.akuma.walk = ShieldCopActionWalk
	
	old_init(self, unit)
end

function CopMovement:post_init()
	local diff_index = tweak_data:difficulty_to_index(Global.game_settings.difficulty)
	local unit = self._unit
	self._ext_brain = unit:brain()
	self._ext_network = unit:network()
	self._ext_anim = unit:anim_data()
	self._ext_base = unit:base()
	self._ext_damage = unit:character_damage()
	self._ext_inventory = unit:inventory()
	self._tweak_data = tweak_data.character[self._ext_base._tweak_table]

	tweak_data:add_reload_callback(self, self.tweak_data_clbk_reload)
	self._machine:set_callback_object(self)

	self._stance = {
		name = "ntl",
		code = 1,
		values = {
			1,
			0,
			0,
			0
		}
	}

	if managers.navigation:is_data_ready() then
		self._nav_tracker = managers.navigation:create_nav_tracker(self._m_pos)
		self._pos_rsrv_id = managers.navigation:get_pos_reservation_id()
	else
		Application:error("[CopMovement:post_init] Spawned AI unit with incomplete navigation data.")
		self._unit:set_extension_update(ids_movement, false)
	end

	self._unit:kill_mover()
	self._unit:set_driving("script")
	
	if diff_index == 8 then
		self._unit:unit_data().has_alarm_pager = self._tweak_data.has_alarm_pager
	else
		self._unit:unit_data().has_alarm_pager = nil
	end
	
	local event_list = {
		"bleedout",
		"light_hurt",
		"heavy_hurt",
		"expl_hurt",
		"hurt",
		"hurt_sick",
		"shield_knock",
		"knock_down",
		"stagger",
		"counter_tased",
		"taser_tased",
		"death",
		"fatal",
		"fire_hurt",
		"poison_hurt",
		"concussion"
	}

	table.insert(event_list, "healed")
	self._unit:character_damage():add_listener("movement", event_list, callback(self, self, "damage_clbk"))
	self._unit:inventory():add_listener("movement", {
		"equip",
		"unequip"
	}, callback(self, self, "clbk_inventory"))
	self:add_weapons()

	if self._unit:inventory():is_selection_available(2) then
		if managers.groupai:state():whisper_mode() or not self._unit:inventory():is_selection_available(1) then
			self._unit:inventory():equip_selection(2, true)
		else
			self._unit:inventory():equip_selection(1, true)
		end
	elseif self._unit:inventory():is_selection_available(1) then
		self._unit:inventory():equip_selection(1, true)
	end

	if self._ext_inventory:equipped_selection() == 2 and managers.groupai:state():whisper_mode() then
		self._ext_inventory:set_weapon_enabled(false)
	end

	local weap_name = self._ext_base:default_weapon_name(managers.groupai:state():enemy_weapons_hot() and "primary" or "secondary")
	local fwd = self._m_rot:y()
	self._action_common_data = {
		stance = self._stance,
		pos = self._m_pos,
		rot = self._m_rot,
		fwd = fwd,
		right = self._m_rot:x(),
		unit = unit,
		machine = self._machine,
		ext_movement = self,
		ext_brain = self._ext_brain,
		ext_anim = self._ext_anim,
		ext_inventory = self._ext_inventory,
		ext_base = self._ext_base,
		ext_network = self._ext_network,
		ext_damage = self._ext_damage,
		char_tweak = self._tweak_data,
		nav_tracker = self._nav_tracker,
		active_actions = self._active_actions,
		queued_actions = self._queued_actions,
		look_vec = mvector3.copy(fwd)
	}

	self:upd_ground_ray()

	if self._gnd_ray then
		self:set_position(self._gnd_ray.position)
	end

	self:_post_init()
end

function CopMovement:is_taser_attack_allowed() --lol
	return
end

function CopMovement:_upd_actions(t)
	local a_actions = self._active_actions
	local has_no_action = true

	for i_action, action in ipairs(a_actions) do
		if action then
			if action.update then
				action:update(t)
			end

			if not self._need_upd and action.need_upd then
				self._need_upd = action:need_upd()
			end

			if action.expired and action:expired() then
				a_actions[i_action] = false

				if action.on_exit then
					action:on_exit()
				end

				self._ext_brain:action_complete_clbk(action)
				self._ext_base:chk_freeze_anims()

				for _, action in ipairs(a_actions) do
					if action then
						has_no_action = nil

						break
					end
				end
			else
				has_no_action = nil
			end
		end
	end

	if has_no_action and (not self._queued_actions or not next(self._queued_actions)) then
		self:action_request({
			body_part = 1,
			type = "idle"
		})
	end

	if not a_actions[1] and not a_actions[2] and (not self._queued_actions or not next(self._queued_actions)) and not self:chk_action_forbidden("action") then
		if a_actions[3] then
			self:action_request({
				body_part = 2,
				type = "idle"
			})
		else
			self:action_request({
				body_part = 1,
				type = "idle"
			})
		end
	end

	self:_upd_stance(t)

	self._need_upd = true
end

function CopMovement:_change_stance(stance_code, instant)
	if self._tweak_data.allowed_stances then
		if stance_code == 1 and not self._tweak_data.allowed_stances.ntl then
			return
		elseif stance_code == 2 and not self._tweak_data.allowed_stances.hos then
			return
		elseif stance_code == 3 and not self._tweak_data.allowed_stances.cbt then
			return
		end
	end

	local stance = self._stance

	if instant then
		if stance.transition or stance.code ~= stance_code then
			stance.transition = nil
			stance.code = stance_code
			stance.name = CopMovement._stance.names[stance_code]

			for i = 1, 3, 1 do
				stance.values[i] = 0
			end

			stance.values[stance_code] = 1

			for i, v in ipairs(stance.values) do
				self._machine:set_global(CopMovement._stance.names[i], v)
			end
		end
	else
		local end_values = {}

		if stance_code == 4 then
			if stance.transition then
				end_values = stance.transition.end_values
			else
				for i, value in ipairs(stance.values) do
					end_values[i] = value
				end
			end
		elseif stance.transition then
			end_values = {
				0,
				0,
				0,
				stance.transition.end_values[4]
			}
		else
			end_values = {
				0,
				0,
				0,
				stance.values[4]
			}
		end

		end_values[stance_code] = 1

		if stance_code ~= 4 then
			stance.code = stance_code
			stance.name = CopMovement._stance.names[stance_code]
		end

		local delay = nil
		local vis_state = self._ext_base:lod_stage()

		if vis_state then
			delay = CopMovement._stance.blend[stance_code]

			if vis_state > 2 then
				delay = delay * 0.5
			end
		else
			stance.transition = nil

			if stance_code ~= 1 then
				self:_chk_play_equip_weapon()
			end

			local names = CopMovement._stance.names

			for i, v in ipairs(end_values) do
				if v ~= stance.values[i] then
					stance.values[i] = v

					self._machine:set_global(names[i], v)
				end
			end

			return
		end

		local start_values = {}

		for _, value in ipairs(stance.values) do
			table.insert(start_values, value)
		end

		local t = TimerManager:game():time()
		local transition = {
			end_values = end_values,
			start_values = start_values,
			duration = delay,
			start_t = t,
			next_upd_t = t + 0.07
		}
		stance.transition = transition
	end

	if stance_code ~= 1 then
		self:_chk_play_equip_weapon()
	end

	self:enable_update()
end

function CopMovement:_upd_stance(t)
	if self._stance.transition then
		local stance = self._stance
		local transition = stance.transition

		if transition.next_upd_t < t then
			local values = stance.values
			local progtransition_t = t - transition.start_t
			local prog = progtransition_t / transition.duration

			if prog < 1 then
				local prog_smooth = math.clamp(math.bezier(stance_ctl_pts, prog), 0, 1)
				local v_start = transition.start_values
				local v_end = transition.end_values
				local mlerp = math.lerp

				for i, v in ipairs(v_start) do
					values[i] = mlerp(v, v_end[i], prog_smooth)
				end

				transition.next_upd_t = t + 0.033
			else
				for i, v in ipairs(transition.end_values) do
					values[i] = v
				end

				stance.transition = nil
			end

			local names = CopMovement._stance.names

			for i, v in ipairs(values) do
				self._machine:set_global(names[i], v)
			end
		end
	end

	if self._suppression.transition then
		local suppression = self._suppression
		local transition = suppression.transition

		if transition.next_upd_t < t then
			local progtransition_t = t - transition.start_t
			local prog = progtransition_t / transition.duration

			if prog < 1 then
				local prog_smooth = math.clamp(math.bezier(stance_ctl_pts, prog), 0, 1)
				local val = math.lerp(transition.start_val, transition.end_val, prog_smooth)
				suppression.value = val

				self._machine:set_global("sup", val)

				transition.next_upd_t = t + 0.033
			else
				self._machine:set_global("sup", transition.end_val)

				suppression.value = transition.end_val
				suppression.transition = nil
			end
		end
	end
end

function CopMovement:anim_clbk_enemy_spawn_melee_item()
    if alive(self._melee_item_unit) then
        return
    end

    local melee_weapon = self._unit:base().melee_weapon and self._unit:base():melee_weapon()
    local unit_name = melee_weapon and melee_weapon ~= "weapon" and tweak_data.weapon.npc_melee[melee_weapon] and tweak_data.weapon.npc_melee[melee_weapon].unit_name or nil

    if unit_name then
        local align_obj_l_name = CopMovement._gadgets.aligns.hand_l
        local align_obj_l = self._unit:get_object(align_obj_l_name)

        self._melee_item_unit = World:spawn_unit(unit_name, align_obj_l:position(), align_obj_l:rotation())
        self._unit:link(align_obj_l:name(), self._melee_item_unit, self._melee_item_unit:orientation_object():name())
    end
end

function CopMovement:on_suppressed(state)
	local suppression = self._suppression
	local end_value = state and 1 or 0
	local vis_state = self._ext_base:lod_stage()

	if vis_state and end_value ~= suppression.value then
		local t = TimerManager:game():time()
		local duration = 0.5 * math.abs(end_value - suppression.value)
		suppression.transition = {
			end_val = end_value,
			start_val = suppression.value,
			duration = duration,
			start_t = t,
			next_upd_t = t + 0.07
		}
	else
		suppression.transition = nil
		suppression.value = end_value

		self._machine:set_global("sup", end_value)
	end

	self._action_common_data.is_suppressed = state and true or nil

	if Network:is_server() then
		if state and self._unit:base():has_tag("law") then
			local pose_chk = self._tweak_data.allowed_poses and self._tweak_data.allowed_poses.crouch or self._tweak_data.allowed_poses and self._tweak_data.allowed_poses.stand

			if not pose_chk and not self:chk_action_forbidden("walk") then
				local is_shin_shootout = Global.game_settings.one_down
				local try_something_else = true

				-- the fact i need to do this is why i hate everything about the panic effect
				if state == "panic" and not self._tweak_data.no_fumbling and not self:chk_action_forbidden("act") then
					local crumble_chance = self._tweak_data and self._tweak_data.crumble_chance or 0.25

					if PD2THHSHIN and PD2THHSHIN:IsOverhaulEnabled() then
						crumble_chance = 1000
					end

					if math.random() < crumble_chance then
						if self._ext_anim.run and self._ext_anim.move_fwd then
							if is_shin_shootout then
								local vec_from = temp_vec1
								local vec_to = temp_vec2
								local ray_params = {
									allow_entry = false,
									trace = true,
									tracker_from = self:nav_tracker(),
									pos_from = vec_from,
									pos_to = vec_to
								}

								mvec3_set(ray_params.pos_from, self:m_pos())
								mvec3_set(ray_params.pos_to, self:m_rot():y())
								mvec3_mul(ray_params.pos_to, 380) --small offset from 4m
								mvec3_add(ray_params.pos_to, self:m_pos())

								if not managers.navigation:raycast(ray_params) then
									local action_desc = {
										clamp_to_graph = true,
										type = "act",
										body_part = 1,
										variant = "e_nl_slide_fwd_4m",
										blocks = {
											action = -1,
											act = -1,
											tase = -1,
											bleedout = -1,
											dodge = -1,
											walk = -1,
											hurt = -1,
											heavy_hurt = -1
										}
									}

									if self:action_request(action_desc) then
										--self._unit:sound():say("lk3b", true) 
										try_something_else = false
									end
								end
							else
								local action_desc = {
									clamp_to_graph = true,
									type = "act",
									body_part = 1,
									variant = "e_so_sup_fumble_run_fwd",
									blocks = {
										action = -1,
										walk = -1
									}
								}

								if self:action_request(action_desc) then
									--self._unit:sound():say("hr01")
									try_something_else = false
								end
							end
						else
							local allow = nil
							local vec_from = temp_vec1
							local vec_to = temp_vec2
							local ray_params = {
								allow_entry = false,
								trace = true,
								tracker_from = self:nav_tracker(),
								pos_from = vec_from,
								pos_to = vec_to
							}
							local allowed_fumbles = {
								"e_so_sup_fumble_inplace_3",
							}

							if self._tweak_data.allow_pass_out and math.random() < 0.3 then
								table.insert(allowed_fumbles, "e_sp_dizzy_fall_get_up") --light swats and commons have a decent chance of doing this, heavies and up dont
							end

							mvec3_set(ray_params.pos_from, self:m_pos())
							mvec3_set(ray_params.pos_to, self:m_rot():y())
							mvec3_mul(ray_params.pos_to, -100)
							mvec3_add(ray_params.pos_to, self:m_pos())

							allow = not managers.navigation:raycast(ray_params)

							if allow then
								table.insert(allowed_fumbles, "e_so_sup_fumble_inplace_1")
							end

							mvec3_set(ray_params.pos_from, self:m_pos())
							mvec3_set(ray_params.pos_to, self:m_rot():x())
							mvec3_mul(ray_params.pos_to, 200)
							mvec3_add(ray_params.pos_to, self:m_pos())

							allow = not managers.navigation:raycast(ray_params)

							if allow then
								table.insert(allowed_fumbles, "e_so_sup_fumble_inplace_2")
							end

							mvec3_set(ray_params.pos_from, self:m_pos())
							mvec3_set(ray_params.pos_to, self:m_rot():x())
							mvec3_mul(ray_params.pos_to, -200)
							mvec3_add(ray_params.pos_to, self:m_pos())

							allow = not managers.navigation:raycast(ray_params)

							if allow then
								table.insert(allowed_fumbles, "e_so_sup_fumble_inplace_4")
							end

							if #allowed_fumbles > 0 then
								local action_desc = {
									body_part = 1,
									type = "act",
									variant = allowed_fumbles[math.random(#allowed_fumbles)],
									blocks = {
										action = -1,
										walk = -1
									}
								}

								if self:action_request(action_desc) then
									--self._unit:sound():say("hr01")
									try_something_else = false
								end
							end
						end
					end
				end

				if try_something_else and is_shin_shootout and self._ext_anim.run and self._ext_anim.move_fwd and not self:chk_action_forbidden("act") then
					local vec_from = temp_vec1
					local vec_to = temp_vec2
					local ray_params = {
						allow_entry = false,
						trace = true,
						tracker_from = self:nav_tracker(),
						pos_from = vec_from,
						pos_to = vec_to
					}

					mvec3_set(ray_params.pos_from, self:m_pos())
					mvec3_set(ray_params.pos_to, self:m_rot():y())
					mvec3_mul(ray_params.pos_to, 380) --small offset from 4m
					mvec3_add(ray_params.pos_to, self:m_pos())

					if not managers.navigation:raycast(ray_params) then
						local action_desc = {
							clamp_to_graph = true,
							type = "act",
							body_part = 1,
							variant = "e_nl_slide_fwd_4m",
							blocks = {
								action = -1,
								act = -1,
								tase = -1,
								bleedout = -1,
								dodge = -1,
								walk = -1,
								hurt = -1,
								heavy_hurt = -1
							}
						}

						if self:action_request(action_desc) then
							try_something_else = false
						end
					end
				end

				if try_something_else and not self._tweak_data.no_suppression_reaction then
					if self._ext_anim.idle then
						if not self._active_actions[2] or self._active_actions[2]:type() == "idle" then
							if not self:chk_action_forbidden("act") then
								if is_shin_shootout then
									if not self._ext_anim.crouch then
										local action_desc = {
											clamp_to_graph = true,
											type = "act",
											body_part = 2,
											variant = "suppressed_reaction", --they do an unique crouching animation instead of freezing on shin shootout.
											blocks = {
												walk = -1
											}
										}

										self:action_request(action_desc)
									end
								else
									local action_desc = {
										clamp_to_graph = true,
										type = "act",
										body_part = 1,
										variant = "surprised", --they freeze in their spot and play the "surprised" animation when out of shin shootout.
										blocks = {
											walk = -1,
											action = -1
										}
									}

									self:action_request(action_desc)
								end
							end
						end
					end
				end
			end
		end

		managers.network:session():send_to_peers_synched("suppressed_state", self._unit, state and true or false)
	end

	self:enable_update()
end

function CopMovement:damage_clbk(my_unit, damage_info)
	local hurt_type = damage_info.result.type

	if not hurt_type then
		return
	end

	if damage_info.variant == "bullet" or damage_info.variant == "explosion" or damage_info.variant == "fire" or damage_info.variant == "poison" or damage_info.variant == "graze" then
		hurt_type = managers.modifiers:modify_value("CopMovement:HurtType", hurt_type)

		if not hurt_type then
			return
		end
	end

	if damage_info.variant == "stun" and self._anim_global == "shield" then
		hurt_type = "expl_hurt"
		damage_info.result = {
			variant = damage_info.variant,
			type = "expl_hurt"
		}
	elseif hurt_type == "stagger" or hurt_type == "knock_down" then
		if self._anim_global == "shield" then
			hurt_type = "expl_hurt"
		else
			hurt_type = "hurt"
		end
	elseif hurt_type == "hurt" or hurt_type == "heavy_hurt" then
		if self._anim_global == "shield" then
			hurt_type = "expl_hurt"
		end
	end

	local block_type = hurt_type

	if hurt_type == "expl_hurt" or hurt_type == "fire_hurt" or hurt_type == "poison_hurt" or hurt_type == "taser_tased" then
		block_type = "heavy_hurt"
	end

	if hurt_type == "death" and self._queued_actions then
		self._queued_actions = {}
	end

	if Network:is_server() and self:chk_action_forbidden(block_type) then
		--[[if hurt_type == "death" then
			debug_pause_unit(self._unit, "[CopMovement:damage_clbk] Death action skipped!!!", self._unit)
			Application:draw_cylinder(self._m_pos, self._m_pos + math.UP * 5000, 30, 1, 0, 0)

			for body_part, action in ipairs(self._active_actions) do
				if action then
					print(body_part, action:type(), inspect(action._blocks))
				end
			end
		end]]

		return
	end

	if hurt_type == "death" then
		if self._rope then
			self._rope:base():retract()

			self._rope = nil
			self._rope_death = true

			if self._unit:sound().anim_clbk_play_sound then
				self._unit:sound():anim_clbk_play_sound(self._unit, "repel_end")
			end
		end

		if Network:is_server() then
			self:set_attention()
		else
			self:synch_attention()
		end
	end

	local attack_dir = damage_info.col_ray and damage_info.col_ray.ray or damage_info.attack_dir
	local hit_pos = damage_info.col_ray and damage_info.col_ray.position or damage_info.pos
	local lgt_hurt = hurt_type == "light_hurt"
	local body_part = lgt_hurt and 4 or 1
	local blocks = nil

	if not lgt_hurt then
		blocks = {
			act = -1,
			aim = -1,
			action = -1,
			tase = -1,
			walk = -1,
			light_hurt = -1
		}

		if hurt_type == "bleedout" then
			blocks.bleedout = -1
			blocks.hurt = -1
			blocks.heavy_hurt = -1
			blocks.stagger = -1
			blocks.knock_down = -1
			blocks.counter_tased = -1
			blocks.hurt_sick = -1
			blocks.expl_hurt = -1
			blocks.fire_hurt = -1
			blocks.taser_tased = -1
			blocks.poison_hurt = -1
			blocks.shield_knock = -1
			blocks.concussion = -1
		elseif hurt_type == "shield_knock" or hurt_type == "concussion" or hurt_type == "counter_tased" then
			blocks.hurt = -1
			blocks.heavy_hurt = -1
			blocks.stagger = -1
			blocks.knock_down = -1
			blocks.counter_tased = -1
			blocks.hurt_sick = -1
			blocks.expl_hurt = -1
			blocks.fire_hurt = -1
			blocks.taser_tased = -1
			blocks.poison_hurt = -1
			blocks.shield_knock = -1
			blocks.concussion = -1
		end
	end

	local client_interrupt = nil

	if damage_info.variant == "tase" then
		block_type = "bleedout"
	else
		if Network:is_client() then
			client_interrupt = true
		end

		block_type = hurt_type
	end

	local tweak = self._tweak_data
	local action_data = nil

	if hurt_type == "healed" then
		if self._unit:contour() then
			self._unit:contour():add("medic_heal")
			self._unit:contour():flash("medic_heal", 0.2)
		end

		if tweak.ignore_medic_revive_animation then
			return
		end

		action_data = {
			body_part = 1,
			type = "healed",
			client_interrupt = client_interrupt
		}
	else
		local death_type = "normal"

		if tweak.damage.death_severity then
			if tweak.damage.death_severity < damage_info.damage / tweak.HEALTH_INIT then
				death_type = "heavy"
			end
		end

		action_data = {
			type = "hurt",
			block_type = block_type,
			hurt_type = hurt_type,
			variant = damage_info.variant,
			direction_vec = attack_dir,
			hit_pos = hit_pos,
			body_part = body_part,
			blocks = blocks,
			client_interrupt = client_interrupt,
			attacker_unit = damage_info.attacker_unit,
			death_type = death_type,
			ignite_character = damage_info.ignite_character,
			start_dot_damage_roll = damage_info.start_dot_damage_roll,
			is_fire_dot_damage = damage_info.is_fire_dot_damage,
			fire_dot_data = damage_info.fire_dot_data,
			is_synced = damage_info.is_synced
		}
	end

	if Network:is_server() or not self:chk_action_forbidden(action_data) then
		self:action_request(action_data)
	end
end

function CopMovement:synch_attention(attention)
	if attention and self._unit:character_damage():dead() then
		--debug_pause_unit(self._unit, "[CopMovement:synch_attention] dead AI", self._unit, inspect(attention))
	end

	self:_remove_attention_destroy_listener(self._attention)
	self:_add_attention_destroy_listener(attention)

	if attention and attention.unit and not attention.destroy_listener_key then
		--debug_pause_unit(attention.unit, "[CopMovement:synch_attention] problematic attention unit", attention.unit)
		self:synch_attention(nil)

		return
	end

	local old_attention = self._attention
	self._attention = attention
	self._action_common_data.attention = attention

	for _, action in ipairs(self._active_actions) do
		if action and action.on_attention then
			action:on_attention(attention, old_attention)
		end
	end
end

function CopMovement:drop_held_items()
	self._spawneditems = {}

	if not self._droppable_gadgets then
		return
	end

	for _, drop_item_unit in ipairs(self._droppable_gadgets) do
		local wanted_item_key = drop_item_unit:key()

		if alive(drop_item_unit) then
			for align_place, item_list in pairs(self._equipped_gadgets) do
				if wanted_item_key then
					for i_item, item_unit in ipairs(item_list) do
						if item_unit:key() == wanted_item_key then
							table.remove(item_list, i_item)

							wanted_item_key = nil

							break
						end
					end
				else
					break
				end
			end

			drop_item_unit:unlink()
			drop_item_unit:set_slot(0)
		else
			for align_place, item_list in pairs(self._equipped_gadgets) do
				if wanted_item_key then
					for i_item, item_unit in ipairs(item_list) do
						if not alive(item_unit) then
							table.remove(item_list, i_item)
						end
					end
				end
			end
		end
	end

	self._droppable_gadgets = nil
end

function CopMovement:_equip_item(item_type, align_place, droppable)
	if item_type == "needle" then
		align_place = "hand_l"
	end

	local align_name = self._gadgets.aligns[align_place]

	if not align_name then
		--print("[CopMovement:anim_clbk_equip_item] non existent align place:", align_place)

		return
	end

	local align_obj = self._unit:get_object(align_name)
	local available_items = self._gadgets[item_type]

	if not available_items then
		--print("[CopMovement:anim_clbk_equip_item] non existent item_type:", item_type)

		return
	end

	local item_name = available_items[math.random(available_items)]

	if self._spawneditems[item_type] ~= nil then
		return
	end

	self._spawneditems[item_type] = true

	if item_type == "needle" then
		align_place = "hand_l"
	end

	--print("[CopMovement]Spawning: " .. item_type)

	local item_unit = World:spawn_unit(item_name, align_obj:position(), align_obj:rotation())

	self._unit:link(align_name, item_unit, item_unit:orientation_object():name())

	self._equipped_gadgets = self._equipped_gadgets or {}
	self._equipped_gadgets[align_place] = self._equipped_gadgets[align_place] or {}

	table.insert(self._equipped_gadgets[align_place], item_unit)

	if droppable then
		self._droppable_gadgets = self._droppable_gadgets or {}

		table.insert(self._droppable_gadgets, item_unit)
	end
end

function CopMovement:_get_latest_tase_action()
	if self._queued_actions then
		for i = #self._queued_actions, 1, -1 do
			local action = self._queued_actions[i]

			if action.type == "tase" then
				return self._queued_actions[i], true
			end
		end
	end

	if self._active_actions[3] and self._active_actions[3]:type() == "tase" and not self._active_actions[3]:expired() then
		return self._active_actions[3]
	end
end

function CopMovement:sync_taser_fire()
	local tase_action, is_queued = self:_get_latest_tase_action()

	if is_queued then
		tase_action.firing_at_husk = true
	elseif tase_action then
		tase_action:fire_taser()
	end
end

function CopMovement:sync_action_spooc_nav_point(pos, action_id)
	local spooc_action, is_queued = self:_get_latest_spooc_action(action_id)

	if is_queued then
		if spooc_action.stop_pos and not spooc_action.nr_expected_nav_points then
			return
		end

		table.insert(spooc_action.nav_path, pos)

		if spooc_action.nr_expected_nav_points then
			if spooc_action.nr_expected_nav_points == 1 then
				spooc_action.nr_expected_nav_points = nil

				table.insert(spooc_action.nav_path, spooc_action.stop_pos)
			else
				spooc_action.nr_expected_nav_points = spooc_action.nr_expected_nav_points - 1
			end
		end
	elseif spooc_action then
		spooc_action:sync_append_nav_point(pos)
	end
end

function CopMovement:sync_action_spooc_stop(pos, nav_index, action_id)
	local spooc_action, is_queued = self:_get_latest_spooc_action(action_id)

	if is_queued then
		if spooc_action.host_stop_pos_inserted then
			nav_index = nav_index + spooc_action.host_stop_pos_inserted
		end

		local nav_path = spooc_action.nav_path

		while nav_index < #nav_path do
			table.remove(nav_path)
		end

		spooc_action.stop_pos = pos

		if #nav_path < nav_index - 1 then
			spooc_action.nr_expected_nav_points = nav_index - #nav_path + 1
		else
			table.insert(nav_path, pos)
		end

		spooc_action.path_index = math.max(1, math.min(spooc_action.path_index, #nav_path - 1))
	elseif spooc_action then
		if Network:is_server() then
			self:action_request({
				sync = true,
				body_part = 1,
				type = "idle"
			})
		else
			spooc_action:sync_stop(pos, nav_index)
		end
	end
end

function CopMovement:sync_action_spooc_strike(pos, action_id)
	local spooc_action, is_queued = self:_get_latest_spooc_action(action_id)

	if is_queued then
		if spooc_action.stop_pos and not spooc_action.nr_expected_nav_points then
			return
		end

		table.insert(spooc_action.nav_path, pos)

		spooc_action.strike_nav_index = #spooc_action.nav_path
		spooc_action.strike = true
	elseif spooc_action then
		spooc_action:sync_strike(pos)
	end
end
