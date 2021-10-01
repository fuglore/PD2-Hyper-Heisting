function BlackMarketGui:damage_falloff_to_string(damage_falloff)

	if damage_falloff then
		local bonuses = nil
		local display_range = damage_falloff.display_range
		if damage_falloff.far_multiplier > 1 then
			bonuses = true
		end

		local range_empty = managers.localization:get_default_macro("BTN_RANGE_EMPTY")
		local range_filled = managers.localization:get_default_macro("BTN_RANGE_FILLED")
		local range_bonus = managers.localization:get_default_macro("BTN_RANGE_BONUS")
		
		if display_range < 1 then
			if damage_falloff.far_multiplier > 1 then
				return range_bonus .. range_empty .. range_empty
			end
			
			return range_empty .. range_empty .. range_empty
		elseif display_range < 2 then
			if damage_falloff.far_multiplier > 1 then
				return range_filled .. range_bonus .. range_bonus
			end
			
			return range_filled .. range_empty .. range_empty
		elseif display_range < 3 then
			if damage_falloff.far_multiplier > 1 then
				return range_filled .. range_filled .. range_bonus
			end
			
			return range_filled .. range_filled .. range_empty
		elseif display_range == 3 then
			if damage_falloff.far_multiplier > 1 then
				return range_filled .. range_filled .. range_filled .. range_bonus
			end
			
			return range_filled .. range_filled .. range_filled
		elseif display_range > 3 then
			local chance = math.random(1, 42)
			
			if chance == 25 then
				return range_bonus .. range_bonus .. range_bonus .. range_bonus .. range_bonus
			end
			
			local FG_chance = tostring(chance)
			
			local the_string = "bm_menu_damage_falloff_lol_" .. FG_chance
			return managers.localization:to_upper_text(the_string)
		end
	end

	return managers.localization:to_upper_text("bm_menu_damage_falloff_no_data")
end

function BlackMarketGui:_get_armor_stats(name)
	local base_stats = {}
	local mods_stats = {}
	local skill_stats = {}
	local detection_risk = managers.blackmarket:get_suspicion_offset_from_custom_data({
		armors = name
	}, tweak_data.player.SUSPICION_OFFSET_LERP or 0.75)
	detection_risk = math.round(detection_risk * 100)
	local bm_armor_tweak = tweak_data.blackmarket.armors[name]
	local upgrade_level = bm_armor_tweak.upgrade_level

	for i, stat in ipairs(self._armor_stats_shown) do
		base_stats[stat.name] = {
			value = 0
		}
		mods_stats[stat.name] = {
			value = 0
		}
		skill_stats[stat.name] = {
			value = 0
		}

		if stat.name == "armor" then
			local base = tweak_data.player.damage.ARMOR_INIT
			local mod = managers.player:body_armor_value("armor", upgrade_level)
			base_stats[stat.name] = {
				value = (base + mod) * tweak_data.gui.stats_present_multiplier
			}
			skill_stats[stat.name] = {
				value = (base_stats[stat.name].value + managers.player:body_armor_skill_addend(name) * tweak_data.gui.stats_present_multiplier) * managers.player:body_armor_skill_multiplier(name) - base_stats[stat.name].value
			}
		elseif stat.name == "health" then
			local base = tweak_data.player.damage.HEALTH_INIT
			local mod = managers.player:max_health()
			mod = mod - base
			base_stats[stat.name] = {
				value = (base) * tweak_data.gui.stats_present_multiplier
			}
			skill_stats[stat.name] = {
				value = mod * tweak_data.gui.stats_present_multiplier
			}
		elseif stat.name == "concealment" then
			base_stats[stat.name] = {
				value = managers.player:body_armor_value("concealment", upgrade_level)
			}
			skill_stats[stat.name] = {
				value = managers.blackmarket:concealment_modifier("armors", upgrade_level)
			}
		elseif stat.name == "movement" then
			local base = tweak_data.player.movement_state.standard.movement.speed.RUNNING_MAX * 1.1
			base = base / 100
			local movement_penalty = managers.player:body_armor_value("movement", upgrade_level)
			local base_value = movement_penalty * base
			base_stats[stat.name] = {
				value = base_value
			}
			local skill_mod = managers.player:movement_speed_multiplier("run", false, upgrade_level, 1)
			local val = base * skill_mod
			val = Utl.round(val, 2)
			base_value = Utl.round(base_value, 2)
			local skill_value = val - base_value
			skill_stats[stat.name] = {
				value = skill_value,
				skill_in_effect = skill_value > 0
			}
		elseif stat.name == "dodge" then
			local base = 0
			local mod = managers.player:body_armor_value("dodge", upgrade_level)
			base_stats[stat.name] = {
				value = (base + mod) * 100
			}
			skill_stats[stat.name] = {
				value = managers.player:skill_dodge_chance(false, false, false, name, detection_risk) * 100
			}
		elseif stat.name == "damage_shake" then
			local base = tweak_data.gui.armor_damage_shake_base
			local mod = math.max(managers.player:body_armor_value("damage_shake", upgrade_level, nil, 1), 0.01)
			local skill = math.max(managers.player:upgrade_value("player", "damage_shake_multiplier", 1), 0.01)
			local base_value = base
			local mod_value = base / mod - base_value
			local skill_value = base / mod / skill - base_value - mod_value + managers.player:upgrade_value("player", "damage_shake_addend", 0)
			base_stats[stat.name] = {
				value = (base_value + mod_value) * tweak_data.gui.stats_present_multiplier
			}
			skill_stats[stat.name] = {
				value = skill_value * tweak_data.gui.stats_present_multiplier
			}
		elseif stat.name == "stamina" then
			local stamina_data = tweak_data.player.movement_state.stamina
			local base = stamina_data.STAMINA_INIT
			local mod = managers.player:body_armor_value("stamina", upgrade_level)
			local skill = managers.player:stamina_multiplier()
			local base_value = base
			local mod_value = base * mod - base_value
			local skill_value = base * mod * skill - base_value - mod_value
			base_stats[stat.name] = {
				value = base_value + mod_value
			}
			skill_stats[stat.name] = {
				value = skill_value
			}
		end

		skill_stats[stat.name].skill_in_effect = skill_stats[stat.name].skill_in_effect or skill_stats[stat.name].value ~= 0
	end

	if managers.player:has_category_upgrade("player", "armor_to_health_conversion") then
		local conversion_ratio = managers.player:upgrade_value("player", "armor_to_health_conversion") * 0.01
		local converted_armor = (base_stats.armor.value + skill_stats.armor.value) * conversion_ratio
		local skill_in_effect = converted_armor ~= 0
		skill_stats.armor.value = skill_stats.armor.value - converted_armor
		skill_stats.health.value = skill_stats.health.value + converted_armor
		skill_stats.armor.skill_in_effect = skill_in_effect
		skill_stats.health.skill_in_effect = skill_in_effect
	end

	return base_stats, mods_stats, skill_stats
end