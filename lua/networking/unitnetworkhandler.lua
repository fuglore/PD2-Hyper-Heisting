function UnitNetworkHandler:sync_add_doted_enemy(enemy_unit, variant, weapon_unit, dot_length, dot_damage, user_unit, is_molotov_or_hurt_animation, rpc)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	if variant == 0 then
		managers.fire:sync_add_fire_dot(enemy_unit, nil, weapon_unit, dot_length, dot_damage, user_unit, is_molotov_or_hurt_animation)
	else
		if variant == 1 then
			variant = "poison"
		elseif variant == 2 then
			variant = "dot"
		else
			variant = nil
		end

		if weapon_unit and alive(weapon_unit) and weapon_unit:base() then
			if weapon_unit:base().is_husk_player then
				local peer_id = managers.network:session():peer_by_unit(weapon_unit):id()
				local peer = managers.network:session():peer(peer_id)

				weapon_unit = peer:melee_id()
			else
				weapon_unit = weapon_unit:base().melee_weapon and weapon_unit:base():melee_weapon() or weapon_unit

				if weapon_unit == "weapon" then
					weapon_unit = nil
				end
			end
		end

		managers.dot:sync_add_dot_damage(enemy_unit, variant, weapon_unit, dot_length, dot_damage, user_unit, is_molotov_or_hurt_animation, variant, weapon_id)
	end
end

function UnitNetworkHandler:request_throw_projectile(projectile_type_index, position, dir, sender)
	local peer = self._verify_sender(sender)

	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not peer then
		return
	end

	local peer_id = peer:id()
	local projectile_type = tweak_data.blackmarket:get_projectile_name_from_index(projectile_type_index)
	local no_cheat_count = true

	if not no_cheat_count and not managers.player:verify_grenade(peer_id) then
		return
	end

	ProjectileBase.throw_projectile(projectile_type, position, dir, peer_id)
end

function UnitNetworkHandler:action_spooc_start(unit, target_u_pos, flying_strike, action_id, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(sender) or not self._verify_character(unit) then
		return
	end

	local action_desc = {
		block_type = "walk",
		type = "spooc",
		path_index = 1,
		body_part = 1,
		nav_path = {
			unit:position()
		},
		target_u_pos = target_u_pos,
		flying_strike = flying_strike,
		action_id = action_id,
		blocks = {
			idle = -1,
			act = -1,
			turn = -1,
			walk = -1
		}
	}

	if flying_strike then
		action_desc.blocks.light_hurt = -1
		action_desc.blocks.heavy_hurt = -1
		action_desc.blocks.fire_hurt = -1
		action_desc.blocks.hurt = -1
		action_desc.blocks.expl_hurt = -1
		action_desc.blocks.taser_tased = -1
	end

	unit:movement():action_request(action_desc)
end

function UnitNetworkHandler:action_aim_state(unit, state)
    if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_character(unit) then
        return
    end

    if state then
        local shoot_action = {
            block_type = "action",
            body_part = 3,
            type = "shoot"
        }

        unit:movement():action_request(shoot_action)
    else
        unit:movement():sync_action_aim_end()
    end
end

function UnitNetworkHandler:m79grenade_explode_on_client(position, normal, user, damage, range, curve_pow, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	if not self._verify_character_and_sender(user, sender) then
		if alive(user) and user:movement() and user:movement()._active_actions then --this instance was actually a shotgun push ragdoll pos sync
			local death_action = user:movement()._active_actions[1]

			if death_action and death_action:type() == "hurt" and death_action._hips_obj then
				local u_body = user:body(damage)

				if u_body:enabled() and u_body:dynamic() then
					u_body:set_position(position)
				end
			end
		end

		return
	end

	ProjectileBase._explode_on_client(position, normal, user, damage, range, curve_pow)
end

function UnitNetworkHandler:action_hurt_start(unit, hurt_type_idx, body_part, death_type_idx, type_idx, variant_idx, direction_vec, hit_pos)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) then
		return
	end

	local hurt_type = CopActionHurt.idx_to_hurt_type(hurt_type_idx)

	if hurt_type == "death" then
		if alive(unit) then
			local action_type = CopActionHurt.idx_to_type(type_idx)
			local variant = CopActionHurt.idx_to_variant(variant_idx)
			local block_type = hurt_type
			local mov_ext = unit:movement()
			local client_interrupt = nil

			if mov_ext._queued_actions then
				mov_ext._queued_actions = {}
			end

			if mov_ext._rope then
				mov_ext._rope:base():retract()

				mov_ext._rope = nil
				mov_ext._rope_death = true

				if unit:sound().anim_clbk_play_sound then
					unit:sound():anim_clbk_play_sound(unit, "repel_end")
				end
			end

			if Network:is_server() then
				mov_ext:set_attention()
			else
				client_interrupt = true
				mov_ext:synch_attention()
			end

			local blocks = {
				act = -1,
				aim = -1,
				action = -1,
				tase = -1,
				walk = -1,
				light_hurt = -1,
				death = -1
			}

			local action_data = {
				allow_network = false,
				client_interrupt = client_interrupt,
				hurt_type = hurt_type,
				block_type = block_type,
				blocks = blocks,
				body_part = body_part,
				death_type = CopActionHurt.idx_to_death_type(death_type_idx),
				type = action_type,
				variant = variant,
				direction_vec = direction_vec,
				hit_pos = hit_pos
			}

			unit:movement():action_request(action_data)
		end
	else
		if not self._verify_character(unit) then
			return
		end

		local action_data = nil
		local action_type = CopActionHurt.idx_to_type(type_idx)

		if action_type == "healed" then
			if unit:anim_data() and unit:anim_data().act then
				return
			end

			action_data = {
				body_part = body_part,
				type = "healed",
				client_interrupt = Network:is_client()
			}
		else
			local block_type = hurt_type

			if hurt_type == "expl_hurt" or hurt_type == "fire_hurt" or hurt_type == "poison_hurt" or hurt_type == "taser_tased" then
				block_type = "heavy_hurt"
			end

			if Network:is_server() and unit:movement():chk_action_forbidden(block_type) then
				return
			end

			local variant = CopActionHurt.idx_to_variant(variant_idx)
			local client_interrupt, blocks = nil

			if variant == "tase" then
				block_type = "bleedout"
			elseif hurt_type == "expl_hurt" or hurt_type == "fire_hurt" or hurt_type == "poison_hurt" or hurt_type == "taser_tased" then
				block_type = "heavy_hurt"

				client_interrupt = Network:is_client()
			else
				block_type = hurt_type

				if hurt_type ~= "bleedout" and hurt_type ~= "fatal" then
					client_interrupt = Network:is_client()
				end
			end

			if hurt_type ~= "light_hurt" then
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
					blocks.hurt_sick = -1
					blocks.concussion = -1
				end
			end

			action_data = {
				allow_network = false,
				client_interrupt = client_interrupt,
				hurt_type = hurt_type,
				block_type = block_type,
				blocks = blocks,
				body_part = body_part,
				death_type = CopActionHurt.idx_to_death_type(death_type_idx),
				type = action_type,
				variant = variant,
				direction_vec = direction_vec,
				hit_pos = hit_pos
			}
		end

		unit:movement():action_request(action_data)
	end
end

function UnitNetworkHandler:sync_medic_heal(unit, sender)
	if not self._verify_gamestate(self._gamestate_filter.any_ingame) or not self._verify_sender(sender) then
		return
	end

	MedicActionHeal:check_achievements()

	if self._verify_character(unit) then
		unit:character_damage()._heal_cooldown_t = Application:time()

		if unit:anim_data() and unit:anim_data().act then --do not try to play the anim redirect if acting, just play the voiceline
			unit:sound():say("heal")
		else
			local redir_res = unit:movement():play_redirect("cmd_get_up")

			if redir_res then
				unit:sound():say("heal")
				unit:anim_state_machine():set_speed(redir_res, 0.5)
			end
		end
	end
end
