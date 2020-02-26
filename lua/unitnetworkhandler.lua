function UnitNetworkHandler:action_spooc_start(unit, target_u_pos, flying_strike, action_id)
    if not self._verify_character(unit) or not self._verify_gamestate(self._gamestate_filter.any_ingame) then
        return
    end

    --[[local stand_action_data = {
        body_part = 4,
        type = "stand"
    }

    unit:movement():action_request(stand_action_data)]]

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