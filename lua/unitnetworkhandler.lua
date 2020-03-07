function UnitNetworkHandler:sync_add_doted_enemy(enemy_unit, variant, weapon_unit, dot_length, dot_damage, user_unit, is_molotov_or_hurt_animation, rpc)
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

function UnitNetworkHandler:action_spooc_start(unit, target_u_pos, flying_strike, action_id)
    if not self._verify_character(unit) or not self._verify_gamestate(self._gamestate_filter.any_ingame) then
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
            act = -1,
            turn = -1,
            walk = -1
        }
    }

    if flying_strike then
        action_desc.blocks.idle = -1
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
