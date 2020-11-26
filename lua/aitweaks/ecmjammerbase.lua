local mvec3_cpy = mvector3.copy
local mvec3_norm = mvector3.normalize

local math_random = math.random

local world_g = World
local ipairs_g = ipairs

function ECMJammerBase._detect_and_give_dmg(from_pos, device_unit, user_unit, range)
	--[[local enemies_in_range = nil

	if device_unit then
		enemies_in_range = world_g:find_units_quick("sphere", from_pos, range, managers.slot:get_mask("enemies"))
	else
		enemies_in_range = world_g:find_units_quick("all", managers.slot:get_mask("enemies")) --affect enemies on the entire map, to match the Pocket ECM's ingame description for meme purposes
	end]]

	local enemies_in_range = world_g:find_units_quick("sphere", from_pos, range, managers.slot:get_mask("enemies"))

	for _, enemy in ipairs_g(enemies_in_range) do
		local dmg_ext = enemy:character_damage()

		if dmg_ext and dmg_ext.damage_explosion then
			local ecm_vuln = enemy:base() and enemy:base():char_tweak() and enemy:base():char_tweak().ecm_vulnerability

			if ecm_vuln then
				local stun = true
				local brain_ext = enemy:brain()

				if brain_ext then
					if brain_ext.is_hostage and brain_ext:is_hostage() or brain_ext.surrendered and brain_ext:surrendered() then
						stun = false
					end
				end

				if stun then
					if enemy:anim_data() and enemy:anim_data().act or ecm_vuln < math_random() then
						stun = false
					end
				end

				if stun then
					local hit_pos = mvec3_cpy(enemy:movement():m_head_pos())
					local attack_dir = hit_pos - from_pos
					mvec3_norm(attack_dir)

					local attack_data = {
						damage = 0,
						variant = "stun",
						attacker_unit = alive(user_unit) and user_unit,
						weapon_unit = alive(device_unit) and user_unit,
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