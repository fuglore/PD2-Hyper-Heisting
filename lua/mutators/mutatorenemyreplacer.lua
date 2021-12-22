local access_type_walk_only = {
	walk = true
}
local access_type_all = {
	acrobatic = true,
	walk = true
}
local ignored_groups = {
	"Phalanx_minion",
	"Phalanx_vip"
}
MutatorEnemyReplacer = MutatorEnemyReplacer or class(BaseMutator)
MutatorEnemyReplacer._type = "MutatorEnemyReplacer"
MutatorEnemyReplacer.name_id = "mutator_specials_override"
MutatorEnemyReplacer.desc_id = "mutator_specials_override_desc"
MutatorEnemyReplacer.has_options = true
MutatorEnemyReplacer.reductions = {
	money = 0.35,
	exp = 0.35
}
MutatorEnemyReplacer.disables_achievements = true
MutatorEnemyReplacer.categories = {
	"enemies"
}
MutatorEnemyReplacer.incompatibility_tags = {
	"replaces_units"
}
MutatorEnemyReplacer.icon_coords = {
	6,
	1
}

function MutatorEnemyReplacer:register_values(mutator_manager)
	self:register_value("override_enemy", self:default_override_enemy(), "oe")
end

function MutatorEnemyReplacer:setup()
	self._groups = self._groups or {}
	local difficulty = Global.game_settings and Global.game_settings.difficulty or "normal"
	local difficulty_index = tweak_data:difficulty_to_index(difficulty)

	self:modify_unit_categories(tweak_data.group_ai, difficulty_index)
end

function MutatorEnemyReplacer:name(lobby_data)
	local name = MutatorEnemyReplacer.super.name(self)

	if self:_mutate_name("override_enemy") then
		return string.format("%s - %s", name, managers.localization:text("mutator_specials_override_" .. tostring(self:value("override_enemy"))))
	else
		return name
	end
end

function MutatorEnemyReplacer:get_override_enemy()
	return self:value("override_enemy")
end

function MutatorEnemyReplacer:default_override_enemy()
	return "tank"
end

function MutatorEnemyReplacer:setup_options_gui(node)
	local params = {
		callback = "_update_mutator_value",
		name = "enemy_selector_choice",
		text_id = "mutator_specials_override_select",
		filter = true,
		update_callback = callback(self, self, "_update_selected_enemy")
	}
	local data_node = {
		{
			value = "tank",
			text_id = "mutator_specials_override_tank",
			_meta = "option"
		},
		{
			value = "taser",
			text_id = "mutator_specials_override_taser",
			_meta = "option"
		},
		{
			value = "shield",
			text_id = "mutator_specials_override_shield",
			_meta = "option"
		},
		{
			value = "spooc",
			text_id = "mutator_specials_override_spooc",
			_meta = "option"
		},
		{
			value = "medic",
			text_id = "mutator_specials_override_medic",
			_meta = "option"
		},
		type = "MenuItemMultiChoice"
	}
	local new_item = node:create_item(data_node, params)

	new_item:set_value(self:get_override_enemy())
	node:add_item(new_item)

	self._node = node

	return new_item
end

function MutatorEnemyReplacer:_update_selected_enemy(item)
	self:set_value("override_enemy", item:value())
end

function MutatorEnemyReplacer:reset_to_default()
	self:clear_values()

	if self._node then
		local slider = self._node:item("enemy_selector_choice")

		if slider then
			slider:set_value(self:default_override_enemy())
		end
	end
end

function MutatorEnemyReplacer:modify_unit_categories(group_ai_tweak, difficulty_index)
	for key, value in pairs(group_ai_tweak.special_unit_spawn_limits) do
		if key == self:get_override_enemy() then
			group_ai_tweak.special_unit_spawn_limits[key] = math.huge
		end
	end

	local unit_group = self["_get_unit_group_" .. self:get_override_enemy()](self, difficulty_index)

	for group, units in pairs(group_ai_tweak.unit_categories) do
		if not table.contains(ignored_groups, group) then
			print("[Mutators] Replacing unit group:", group)

			group_ai_tweak.unit_categories[group] = unit_group
		else
			print("[Mutators] Ignoring unit group:", group)
		end
	end
end

function MutatorEnemyReplacer:_get_unit_group_tank(difficulty_index)
	if not self._groups.tank then
		if difficulty_index <= 4 then
			self._groups.tank = {
				special_type = "tank",
				unit_types = {
					america = {
						Idstring("units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1")
					},
					russia = {
						Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_r870/ene_akan_fbi_tank_r870")
					},
					zombie = {
						Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_1/ene_bulldozer_hvh_1")
					},
					murkywater = {
						Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_2/ene_murkywater_bulldozer_2")
					},
					federales = {
						Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_r870/ene_swat_dozer_policia_federale_r870")
					},
					shared = { 
						Idstring("units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1"),
						Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_2/ene_murkywater_bulldozer_2")
					}
				},
				access = access_type_all
			}
		elseif difficulty_index == 5 then
			self._groups.tank = {
				special_type = "tank",
				unit_types = {
					america = {
						Idstring("units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1"),
						Idstring("units/payday2/characters/ene_bulldozer_2/ene_bulldozer_2")
					},
					russia = {
						Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_saiga/ene_akan_fbi_tank_saiga"),
						Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_r870/ene_akan_fbi_tank_r870")
					},
					zombie = {
						Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_1/ene_bulldozer_hvh_1"),
						Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_2/ene_bulldozer_hvh_2")
					},
					murkywater = {
						Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_2/ene_murkywater_bulldozer_2"),
						Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_3/ene_murkywater_bulldozer_3")
					},
					federales = {
						Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_saiga/ene_swat_dozer_policia_federale_saiga"),
						Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_r870/ene_swat_dozer_policia_federale_r870")
					},
					shared = { 
						Idstring("units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1"),
						Idstring("units/payday2/characters/ene_bulldozer_2/ene_bulldozer_2"),
						Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_2/ene_murkywater_bulldozer_2"),
						Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_3/ene_murkywater_bulldozer_3")
					}
				},
				access = access_type_all
			}
		elseif difficulty_index == 6 then
			self._groups.tank = {
				special_type = "tank",
				unit_types = {
					america = {
						Idstring("units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1"),
						Idstring("units/payday2/characters/ene_bulldozer_2/ene_bulldozer_2"),
						Idstring("units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3")
					},
					russia = {
						Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_saiga/ene_akan_fbi_tank_saiga"),
						Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_r870/ene_akan_fbi_tank_r870"),
						Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_rpk_lmg/ene_akan_fbi_tank_rpk_lmg")
					},
					zombie = {
						Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_1/ene_bulldozer_hvh_1"),
						Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_2/ene_bulldozer_hvh_2"),
						Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_3/ene_bulldozer_hvh_3")
					},
					murkywater = {
						Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_4/ene_murkywater_bulldozer_4"),
						Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_2/ene_murkywater_bulldozer_2"),
						Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_3/ene_murkywater_bulldozer_3")
					},
					federales = {
						Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_r870/ene_swat_dozer_policia_federale_r870"),
						Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_saiga/ene_swat_dozer_policia_federale_saiga"),
						Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_m249/ene_swat_dozer_policia_federale_m249")
					},
					shared = {
						Idstring("units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1"),
						Idstring("units/payday2/characters/ene_bulldozer_2/ene_bulldozer_2"),
						Idstring("units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3"),
						Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_4/ene_murkywater_bulldozer_4"),
						Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_2/ene_murkywater_bulldozer_2"),
						Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_3/ene_murkywater_bulldozer_3")					
					}
				},
				access = access_type_all
			}
		elseif difficulty_index == 7 then
			self._groups.tank = {
				special_type = "tank",
				unit_types = {
					america = {
						Idstring("units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1"),
						Idstring("units/payday2/characters/ene_bulldozer_2/ene_bulldozer_2"),
						Idstring("units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3"),
						Idstring("units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1"),
						Idstring("units/payday2/characters/ene_bulldozer_2/ene_bulldozer_2"),
						Idstring("units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3"),
						Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_minigun_classic/ene_bulldozer_minigun_classic")
					},
					russia = {
						Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_r870/ene_akan_fbi_tank_r870"),
						Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_saiga/ene_akan_fbi_tank_saiga"),
						Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_rpk_lmg/ene_akan_fbi_tank_rpk_lmg"),
						Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_r870/ene_akan_fbi_tank_r870"),
						Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_saiga/ene_akan_fbi_tank_saiga"),
						Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_rpk_lmg/ene_akan_fbi_tank_rpk_lmg"),
						Idstring("units/pd2_dlc_mad/characters/ene_akan_dozer_mini/ene_akan_dozer_mini")
					},
					zombie = {
						Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_1/ene_bulldozer_hvh_1"),
						Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_2/ene_bulldozer_hvh_2"),
						Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_3/ene_bulldozer_hvh_3"),
						Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_1/ene_bulldozer_hvh_1"),
						Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_2/ene_bulldozer_hvh_2"),
						Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_3/ene_bulldozer_hvh_3"),
						Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_minigun_classic/ene_bulldozer_minigun_classic")
					},
					murkywater = {
						Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_2/ene_murkywater_bulldozer_2"),
						Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_3/ene_murkywater_bulldozer_3"),
						Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_4/ene_murkywater_bulldozer_4"),
						Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_2/ene_murkywater_bulldozer_2"),
						Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_3/ene_murkywater_bulldozer_3"),
						Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_4/ene_murkywater_bulldozer_4"),
						Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_1/ene_murkywater_bulldozer_1"),
					},
					federales = {
						Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_r870/ene_swat_dozer_policia_federale_r870"),
						Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_saiga/ene_swat_dozer_policia_federale_saiga"),
						Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_m249/ene_swat_dozer_policia_federale_m249"),
						Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_r870/ene_swat_dozer_policia_federale_r870"),
						Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_saiga/ene_swat_dozer_policia_federale_saiga"),
						Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_m249/ene_swat_dozer_policia_federale_m249"),
						Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_minigun/ene_swat_dozer_policia_federale_minigun")
					},
					--Lord, I hate everything about how this physically and visually presents itself.
					shared = {
						Idstring("units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1"),
						Idstring("units/payday2/characters/ene_bulldozer_2/ene_bulldozer_2"),
						Idstring("units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3"),
						Idstring("units/payday2/characters/ene_bulldozer_1/ene_bulldozer_1"),
						Idstring("units/payday2/characters/ene_bulldozer_2/ene_bulldozer_2"),
						Idstring("units/payday2/characters/ene_bulldozer_3/ene_bulldozer_3"),
						Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_2/ene_murkywater_bulldozer_2"),
						Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_3/ene_murkywater_bulldozer_3"),
						Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_4/ene_murkywater_bulldozer_4"),
						Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_2/ene_murkywater_bulldozer_2"),
						Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_3/ene_murkywater_bulldozer_3"),
						Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_4/ene_murkywater_bulldozer_4"),
						Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_1/ene_murkywater_bulldozer_1"),					
						Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_minigun_classic/ene_bulldozer_minigun_classic")
					}
				},
				access = access_type_all
			}
		else
			self._groups.tank = {
				special_type = "tank",
				unit_types = {
					america = {
						Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer/ene_zeal_bulldozer"),
						Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer_2/ene_zeal_bulldozer_2"),
						Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer_3/ene_zeal_bulldozer_3"),
						Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer/ene_zeal_bulldozer"),
						Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer_2/ene_zeal_bulldozer_2"),
						Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer_3/ene_zeal_bulldozer_3"),
						Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_medic/ene_bulldozer_medic"),
						Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_minigun/ene_bulldozer_minigun")
					},
					russia = {
						Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_r870/ene_akan_fbi_tank_r870"),
						Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_saiga/ene_akan_fbi_tank_saiga"),
						Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_rpk_lmg/ene_akan_fbi_tank_rpk_lmg"),
						Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_r870/ene_akan_fbi_tank_r870"),
						Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_saiga/ene_akan_fbi_tank_saiga"),
						Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_tank_rpk_lmg/ene_akan_fbi_tank_rpk_lmg"),
						Idstring("units/pd2_dlc_mad/characters/ene_akan_dozer_medic/ene_akan_dozer_medic"),
						Idstring("units/pd2_dlc_mad/characters/ene_akan_dozer_mini/ene_akan_dozer_mini")
					},
					zombie = {
						Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_1/ene_bulldozer_hvh_1"),
						Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_2/ene_bulldozer_hvh_2"),
						Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_3/ene_bulldozer_hvh_3"),
						Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_1/ene_bulldozer_hvh_1"),
						Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_2/ene_bulldozer_hvh_2"),
						Idstring("units/pd2_dlc_hvh/characters/ene_bulldozer_hvh_3/ene_bulldozer_hvh_3"),
						Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_medic/ene_bulldozer_medic"),
						Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_minigun/ene_bulldozer_minigun")
					},
					murkywater = {
						Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_2/ene_murkywater_bulldozer_2"),
						Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_3/ene_murkywater_bulldozer_3"),
						Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_4/ene_murkywater_bulldozer_4"),
						Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_2/ene_murkywater_bulldozer_2"),
						Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_3/ene_murkywater_bulldozer_3"),
						Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_4/ene_murkywater_bulldozer_4"),
						Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_1/ene_murkywater_bulldozer_1"),
						Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_medic/ene_murkywater_bulldozer_medic")
					},
					federales = {
						Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_r870/ene_swat_dozer_policia_federale_r870"),
						Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_saiga/ene_swat_dozer_policia_federale_saiga"),
						Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_m249/ene_swat_dozer_policia_federale_m249"),
						Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_r870/ene_swat_dozer_policia_federale_r870"),
						Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_saiga/ene_swat_dozer_policia_federale_saiga"),
						Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_m249/ene_swat_dozer_policia_federale_m249"),
						Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_policia_federale_minigun/ene_swat_dozer_policia_federale_minigun"),
						Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_medic_policia_federale/ene_swat_dozer_medic_policia_federale")
					},
					shared = {
						Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer/ene_zeal_bulldozer"),
						Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer_2/ene_zeal_bulldozer_2"),
						Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer_3/ene_zeal_bulldozer_3"),
						Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer/ene_zeal_bulldozer"),
						Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer_2/ene_zeal_bulldozer_2"),
						Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_bulldozer_3/ene_zeal_bulldozer_3"),
						Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_medic/ene_bulldozer_medic"),
						Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_minigun/ene_bulldozer_minigun"),
						Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_2/ene_murkywater_bulldozer_2"),
						Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_3/ene_murkywater_bulldozer_3"),
						Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_4/ene_murkywater_bulldozer_4"),
						Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_2/ene_murkywater_bulldozer_2"),
						Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_3/ene_murkywater_bulldozer_3"),
						Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_4/ene_murkywater_bulldozer_4"),
						Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_1/ene_murkywater_bulldozer_1"),
						Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_medic/ene_murkywater_bulldozer_medic")					
					}
				},
				access = access_type_all
			}
		end		
	end

	return self._groups.tank
end

function MutatorEnemyReplacer:_get_unit_group_shield(difficulty_index)
	if not self._groups.shield then
		if difficulty_index < 3 then
			self._groups.shield = {
				special_type = "shield",
				unit_types = {
					america = {
						Idstring("units/payday2/characters/ene_shield_2/ene_shield_2")
					},
					russia = {
						Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_shield_c45/ene_akan_cs_shield_c45")
					},
					zombie = {
						Idstring("units/pd2_dlc_hvh/characters/ene_shield_hvh_2/ene_shield_hvh_2")
					},
					murkywater = {
						Idstring("units/pd2_mod_psc/characters/ene_murky_shield_ld/ene_murky_shield_ld")
					},
					federales = {
						Idstring("units/pd2_dlc_bex/characters/ene_swat_shield_policia_federale_c45/ene_swat_shield_policia_federale_c45")
					},
					shared = {
						Idstring("units/payday2/characters/ene_shield_2/ene_shield_2"),
						Idstring("units/pd2_mod_psc/characters/ene_murky_shield_ld/ene_murky_shield_ld")
					}
				},
				access = access_type_all
			}
		elseif difficulty_index < 4 then
			self._groups.shield = {
				special_type = "shield",
				unit_types = {
					america = {
						Idstring("units/payday2/characters/ene_shield_2/ene_shield_2"),
						Idstring("units/payday2/characters/ene_shield_2/ene_shield_2"),
						Idstring("units/payday2/characters/ene_shield_1/ene_shield_1")
					},
					russia = {
						Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_shield_c45/ene_akan_cs_shield_c45"),
						Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_shield_c45/ene_akan_cs_shield_c45"),
						Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_shield_sr2_smg/ene_akan_fbi_shield_sr2_smg")
					},
					zombie = {
						Idstring("units/pd2_dlc_hvh/characters/ene_shield_hvh_2/ene_shield_hvh_2"),
						Idstring("units/pd2_dlc_hvh/characters/ene_shield_hvh_2/ene_shield_hvh_2"),
						Idstring("units/pd2_dlc_hvh/characters/ene_shield_hvh_1/ene_shield_hvh_1")
					},
					murkywater = {
						Idstring("units/pd2_mod_psc/characters/ene_murky_shield_ld/ene_murky_shield_ld"),
						Idstring("units/pd2_mod_psc/characters/ene_murky_shield_ld/ene_murky_shield_ld"),
						Idstring("units/pd2_mod_psc/characters/ene_murky_shield/ene_murky_shield")
					},
					federales = {
						Idstring("units/pd2_dlc_bex/characters/ene_swat_shield_policia_federale_c45/ene_swat_shield_policia_federale_c45"),
						Idstring("units/pd2_dlc_bex/characters/ene_swat_shield_policia_federale_c45/ene_swat_shield_policia_federale_c45"),
						Idstring("units/pd2_dlc_bex/characters/ene_swat_shield_policia_federale_mp9/ene_swat_shield_policia_federale_mp9")
					},
					shared = {
						Idstring("units/payday2/characters/ene_shield_2/ene_shield_2"),
						Idstring("units/payday2/characters/ene_shield_2/ene_shield_2"),
						Idstring("units/pd2_mod_psc/characters/ene_murky_shield_ld/ene_murky_shield_ld"),
						Idstring("units/pd2_mod_psc/characters/ene_murky_shield_ld/ene_murky_shield_ld"),
						Idstring("units/payday2/characters/ene_shield_1/ene_shield_1"),
						Idstring("units/pd2_mod_psc/characters/ene_murky_shield/ene_murky_shield")
					}
				},
				access = access_type_all
			}
		elseif difficulty_index < 6 then
			self._groups.shield = {
				special_type = "shield",
				unit_types = {
					america = {
						Idstring("units/payday2/characters/ene_shield_1/ene_shield_1"),
						Idstring("units/payday2/characters/ene_shield_1/ene_shield_1"),
						Idstring("units/payday2/characters/ene_shield_1/ene_shield_1"),
						Idstring("units/payday2/characters/ene_shield_1/ene_shield_1")
					},
					russia = {
						Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_shield_sr2_smg/ene_akan_fbi_shield_sr2_smg")
					},
					zombie = {
						Idstring("units/pd2_dlc_hvh/characters/ene_shield_hvh_1/ene_shield_hvh_1")
					},
					murkywater = {
						Idstring("units/pd2_mod_psc/characters/ene_murky_shield/ene_murky_shield"),
						Idstring("units/pd2_mod_psc/characters/ene_murky_shield/ene_murky_shield"),
						Idstring("units/pd2_mod_psc/characters/ene_murky_shield/ene_murky_shield"),
						Idstring("units/pd2_mod_psc/characters/ene_murky_shield/ene_murky_shield")
					},
					federales = {
						Idstring("units/pd2_dlc_bex/characters/ene_swat_shield_policia_federale_mp9/ene_swat_shield_policia_federale_mp9"),
						Idstring("units/pd2_dlc_bex/characters/ene_swat_shield_policia_federale_mp9/ene_swat_shield_policia_federale_mp9"),
						Idstring("units/pd2_dlc_bex/characters/ene_swat_shield_policia_federale_mp9/ene_swat_shield_policia_federale_mp9"),
						Idstring("units/pd2_dlc_bex/characters/ene_swat_shield_policia_federale_mp9/ene_swat_shield_policia_federale_mp9")
					},
					shared = {
						Idstring("units/payday2/characters/ene_shield_1/ene_shield_1"),
						Idstring("units/payday2/characters/ene_shield_1/ene_shield_1"),
						Idstring("units/pd2_mod_psc/characters/ene_murky_shield/ene_murky_shield"),
						Idstring("units/pd2_mod_psc/characters/ene_murky_shield/ene_murky_shield")
					}
				},
				access = access_type_all
			}
		elseif difficulty_index < 8 then
			self._groups.shield = {
				special_type = "shield",
				unit_types = {
					america = {
						Idstring("units/payday2/characters/ene_city_shield/ene_city_shield")
					},
					russia = {
						Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_shield_sr2_smg/ene_akan_fbi_shield_sr2_smg")
					},
					zombie = {
						Idstring("units/pd2_dlc_hvh/characters/ene_shield_hvh_1/ene_shield_hvh_1")
					},
					murkywater = {
						Idstring("units/pd2_mod_psc/characters/ene_murky_shield/ene_murky_shield")
					},
					federales = {
						Idstring("units/pd2_dlc_bex/characters/ene_swat_shield_policia_federale_mp9/ene_swat_shield_policia_federale_mp9")
					},
					shared = {
						Idstring("units/payday2/characters/ene_city_shield/ene_city_shield"),
						Idstring("units/pd2_mod_psc/characters/ene_murky_shield/ene_murky_shield")
					}
				},
				access = access_type_all
			}
		else
			self._groups.shield = {
				special_type = "shield",
				unit_types = {
					america = {
						Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_swat_shield_hh/ene_zeal_swat_shield_hh")
					},
					russia = {
						Idstring("units/pd2_dlc_mad/characters/ene_akan_hyper_DS_shield/ene_akan_hyper_DS_shield")
					},
					zombie = {
						Idstring("units/pd2_dlc_hvh/characters/ene_fbi_swat_shield_ds/ene_fbi_swat_shield_ds")
					},
					murkywater = {
						Idstring("units/pd2_mod_psc/characters/ene_murky_DS_shield/ene_murky_DS_shield")
					},
					federales = {
						Idstring("units/pd2_dlc_bex/characters/ene_heavy_swat_shield_federale_ds/ene_heavy_swat_shield_federale_ds")
					},
					shared = {
						Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_swat_shield_hh/ene_zeal_swat_shield_hh"),
						Idstring("units/pd2_mod_psc/characters/ene_murky_DS_shield/ene_murky_DS_shield")
					}
				},
				access = access_type_all
			}
		end
	
	end

	return self._groups.shield
end

function MutatorEnemyReplacer:_get_unit_group_taser(difficulty_index)
	if not self._groups.taser then
		if difficulty_index == 8 then
			self._groups.taser = {
				special_type = "taser",
				unit_types = {
					america = {
						Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_tazer_hh/ene_zeal_tazer_hh")
					},
					russia = {
						Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_tazer_ak47_ass/ene_akan_cs_tazer_ak47_ass")
					},
					zombie = {
						Idstring("units/pd2_dlc_hvh/characters/ene_tazer_hvh_1/ene_tazer_hvh_1")
					},
					murkywater = {
						Idstring("units/pd2_mod_psc/characters/ene_murkywater_tazer/ene_murkywater_tazer")
					},
					federales = {
						Idstring("units/pd2_dlc_bex/characters/ene_swat_tazer_policia_federale/ene_swat_tazer_policia_federale")
					},
					shared = {
						Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_tazer_hh/ene_zeal_tazer_hh"),
						Idstring("units/pd2_mod_psc/characters/ene_murkywater_tazer/ene_murkywater_tazer")
					}
				},
				access = access_type_all
			}
		else
			self._groups.taser = {
				special_type = "taser",
				unit_types = {
					america = {
						Idstring("units/payday2/characters/ene_tazer_1/ene_tazer_1")
					},
					russia = {
						Idstring("units/pd2_dlc_mad/characters/ene_akan_cs_tazer_ak47_ass/ene_akan_cs_tazer_ak47_ass")
					},
					zombie = {
						Idstring("units/pd2_dlc_hvh/characters/ene_tazer_hvh_1/ene_tazer_hvh_1")
					},
					murkywater = {
						Idstring("units/pd2_mod_psc/characters/ene_murkywater_tazer/ene_murkywater_tazer")
					},
					federales = {
						Idstring("units/pd2_dlc_bex/characters/ene_swat_tazer_policia_federale/ene_swat_tazer_policia_federale")
					},
					shared = {
						Idstring("units/payday2/characters/ene_tazer_1/ene_tazer_1"),
						Idstring("units/pd2_mod_psc/characters/ene_murkywater_tazer/ene_murkywater_tazer")
					}
				},
				access = access_type_all
			}
		end
	end

	return self._groups.taser
end

function MutatorEnemyReplacer:_get_unit_group_spooc(difficulty_index)
	if not self._groups.spooc then
		if difficulty_index == 8 then
			self._groups.spooc = {
				special_type = "spooc",
				unit_types = {
					america = {
						Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_cloaker/ene_zeal_cloaker")
					},
					russia = {
						Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_spooc_asval_smg/ene_akan_fbi_spooc_asval_smg")
					},
					zombie = {
						Idstring("units/pd2_dlc_hvh/characters/ene_spook_hvh_1/ene_spook_hvh_1")
					},
					murkywater = {
						Idstring("units/pd2_mod_psc/characters/ene_murky_cloaker/ene_murky_cloaker")
					},
					federales = {
						Idstring("units/pd2_dlc_bex/characters/ene_swat_cloaker_policia_federale/ene_swat_cloaker_policia_federale")
					},
					shared = {
						Idstring("units/pd2_mod_psc/characters/ene_murky_cloaker/ene_murky_cloaker"),
						Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_cloaker/ene_zeal_cloaker")
					}
				},
				access = access_type_all
			}
		else
			self._groups.spooc = {
				special_type = "spooc",
				unit_types = {
					america = {
						Idstring("units/payday2/characters/ene_spook_1/ene_spook_1")
					},
					russia = {
						Idstring("units/pd2_dlc_mad/characters/ene_akan_fbi_spooc_asval_smg/ene_akan_fbi_spooc_asval_smg")
					},
					zombie = {
						Idstring("units/pd2_dlc_hvh/characters/ene_spook_hvh_1/ene_spook_hvh_1")
					},
					murkywater = {
						Idstring("units/pd2_mod_psc/characters/ene_murky_cloaker/ene_murky_cloaker")
					},
					federales = {
						Idstring("units/pd2_dlc_bex/characters/ene_swat_cloaker_policia_federale/ene_swat_cloaker_policia_federale")
					},
					shared = {
						Idstring("units/pd2_mod_psc/characters/ene_murky_cloaker/ene_murky_cloaker"),
						Idstring("units/payday2/characters/ene_spook_1/ene_spook_1")
					}
				},
				access = access_type_all
			}
		end

	end

	return self._groups.spooc
end

function MutatorEnemyReplacer:_get_unit_group_medic(difficulty_index)
	if not self._groups.medic then
		if difficulty_index <= 7 then
			self._groups.medic = {
				special_type = "medic",
				unit_types = {
					america = {
						Idstring("units/payday2/characters/ene_medic_m4_hh/ene_medic_m4_hh"),
						Idstring("units/payday2/characters/ene_medic_r870/ene_medic_r870")
					},
					russia = {
						Idstring("units/pd2_dlc_mad/characters/ene_akan_medic_ak47_ass_hh/ene_akan_medic_ak47_ass_hh"),
						Idstring("units/pd2_dlc_mad/characters/ene_akan_medic_r870/ene_akan_medic_r870")
					},
					zombie = {
						Idstring("units/pd2_dlc_hvh/characters/ene_medic_hvh_m4/ene_medic_hvh_m4"),
						Idstring("units/pd2_dlc_hvh/characters/ene_medic_hvh_r870/ene_medic_hvh_r870")
					},
					murkywater = {
						Idstring("units/pd2_mod_psc/characters/ene_murkywater_medic/ene_murkywater_medic"),
						Idstring("units/pd2_mod_psc/characters/ene_murkywater_medic_r870/ene_murkywater_medic_r870")
					},
					federales = {
						Idstring("units/pd2_dlc_bex/characters/ene_medic_federale_rifle_hh/ene_medic_federale_rifle_hh"),
						Idstring("units/pd2_dlc_bex/characters/ene_medic_federale_r870_hh/ene_medic_federale_r870_hh")
					},
					shared = {
						Idstring("units/payday2/characters/ene_medic_m4/ene_medic_m4"),				
						Idstring("units/pd2_mod_psc/characters/ene_murkywater_medic/ene_murkywater_medic"),
						Idstring("units/payday2/characters/ene_medic_r870/ene_medic_r870"),
						Idstring("units/pd2_mod_psc/characters/ene_murkywater_medic_r870/ene_murkywater_medic_r870")	
					}
				},
				access = access_type_all
			}
		else
			self._groups.medic = {
				special_type = "medic",
				unit_types = {
					america = {
						Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_medic/ene_zeal_medic"),
						Idstring("units/pd2_dlc_gitgud/characters/ene_zeal_medic_r870/ene_zeal_medic_r870"),
					},
					russia = {
						Idstring("units/pd2_dlc_mad/characters/ene_akan_medic_ak47_ass_hh/ene_akan_medic_ak47_ass_hh"),
						Idstring("units/pd2_dlc_mad/characters/ene_akan_medic_r870/ene_akan_medic_r870")
					},
					zombie = {
						Idstring("units/pd2_dlc_hvh/characters/ene_medic_hvh_m4/ene_medic_hvh_m4"),
						Idstring("units/pd2_dlc_hvh/characters/ene_medic_hvh_r870/ene_medic_hvh_r870")
					},
					murkywater = {
						Idstring("units/pd2_mod_psc/characters/ene_murkywater_medic/ene_murkywater_medic"),
						Idstring("units/pd2_mod_psc/characters/ene_murkywater_medic_r870/ene_murkywater_medic_r870")
					},
					federales = {
						Idstring("units/pd2_dlc_bex/characters/ene_medic_federale_rifle_hh/ene_medic_federale_rifle_hh"),
						Idstring("units/pd2_dlc_bex/characters/ene_medic_federale_r870_hh/ene_medic_federale_r870_hh")
					},
					shared = {
						Idstring("units/payday2/characters/ene_medic_m4/ene_medic_m4"),				
						Idstring("units/pd2_mod_psc/characters/ene_murkywater_medic/ene_murkywater_medic"),
						Idstring("units/payday2/characters/ene_medic_r870/ene_medic_r870"),
						Idstring("units/pd2_mod_psc/characters/ene_murkywater_medic_r870/ene_murkywater_medic_r870")
					}
				},
				access = access_type_all
			}
		end
		
	end

	return self._groups.medic
end

MutatorMediDozer = MutatorMediDozer or class(BaseMutator)
MutatorMediDozer._type = "MutatorMediDozer"
MutatorMediDozer.name_id = "mutator_medidozer"
MutatorMediDozer.desc_id = "mutator_medidozer_desc"
MutatorMediDozer.reductions = {
	money = 0,
	exp = 0
}
MutatorMediDozer.disables_achievements = true
MutatorMediDozer.categories = {
	"enemies"
}
MutatorMediDozer.incompatibility_tags = {
	"replaces_units"
}
MutatorMediDozer.icon_coords = {
	8,
	1
}

function MutatorMediDozer:setup()
	self._groups = self._groups or {}
	local difficulty = Global.game_settings and Global.game_settings.difficulty or "normal"
	local difficulty_index = tweak_data:difficulty_to_index(difficulty)

	self:modify_unit_categories(tweak_data.group_ai, difficulty_index)
end

function MutatorMediDozer:modify_unit_categories(group_ai_tweak, difficulty_index)
	if difficulty_index < 8 then
		if group_ai_tweak.unit_categories.FBI_tank then
			table.insert(group_ai_tweak.unit_categories.FBI_tank.unit_types.america, Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_medic/ene_bulldozer_medic"))
			table.insert(group_ai_tweak.unit_categories.FBI_tank.unit_types.russia, Idstring("units/pd2_dlc_mad/characters/ene_akan_dozer_medic/ene_akan_dozer_medic"))
			table.insert(group_ai_tweak.unit_categories.FBI_tank.unit_types.zombie, Idstring("units/pd2_dlc_drm/characters/ene_bulldozer_medic/ene_bulldozer_medic"))
			table.insert(group_ai_tweak.unit_categories.FBI_tank.unit_types.murkywater, Idstring("units/pd2_mod_psc/characters/ene_murkywater_bulldozer_medic/ene_murkywater_bulldozer_medic"))
			table.insert(group_ai_tweak.unit_categories.FBI_tank.unit_types.federales, Idstring("units/pd2_dlc_bex/characters/ene_swat_dozer_medic_policia_federale/ene_swat_dozer_medic_policia_federale"))
		end
	end
end

MutatorTitandozers = MutatorTitandozers or class(BaseMutator)
MutatorTitandozers._type = "MutatorTitandozers"
MutatorTitandozers.name_id = "mutator_titandozers"
MutatorTitandozers.desc_id = "mutator_titandozers_desc"
MutatorTitandozers.reductions = {
	money = 0,
	exp = 0
}
MutatorTitandozers.disables_achievements = true
MutatorTitandozers.categories = {
	"enemies"
}
MutatorTitandozers.incompatibility_tags = {}
MutatorTitandozers.icon_coords = {
	1,
	3
}
MutatorTitandozers.load_priority = -10

function MutatorTitandozers:setup()
	self._groups = self._groups or {}
	local difficulty = Global.game_settings and Global.game_settings.difficulty or "normal"
	local difficulty_index = tweak_data:difficulty_to_index(difficulty)

	self:modify_unit_categories(tweak_data.group_ai, difficulty_index)
end

function MutatorTitandozers:modify_unit_categories(group_ai_tweak, difficulty_index)
	if difficulty_index < 8 then
		if group_ai_tweak.unit_categories.FBI_tank then
			table.insert(group_ai_tweak.unit_categories.FBI_tank.unit_types.america, Idstring("units/payday2/characters/ene_bulldozer_4/ene_bulldozer_4"))
			table.insert(group_ai_tweak.unit_categories.FBI_tank.unit_types.russia, Idstring("units/payday2/characters/ene_bulldozer_4/ene_bulldozer_4"))
			table.insert(group_ai_tweak.unit_categories.FBI_tank.unit_types.zombie, Idstring("units/payday2/characters/ene_bulldozer_4/ene_bulldozer_4"))
			table.insert(group_ai_tweak.unit_categories.FBI_tank.unit_types.murkywater, Idstring("units/payday2/characters/ene_bulldozer_4/ene_bulldozer_4"))
			table.insert(group_ai_tweak.unit_categories.FBI_tank.unit_types.federales, Idstring("units/payday2/characters/ene_bulldozer_4/ene_bulldozer_4"))
		end
	else
		if group_ai_tweak.unit_categories.FBI_tank then
			table.insert(group_ai_tweak.unit_categories.FBI_tank.unit_types.america, Idstring("units/pd2_dlc_help/characters/ene_zeal_bulldozer_halloween/ene_zeal_bulldozer_halloween"))
			table.insert(group_ai_tweak.unit_categories.FBI_tank.unit_types.russia, Idstring("units/pd2_dlc_help/characters/ene_zeal_bulldozer_halloween/ene_zeal_bulldozer_halloween"))
			table.insert(group_ai_tweak.unit_categories.FBI_tank.unit_types.zombie, Idstring("units/pd2_dlc_help/characters/ene_zeal_bulldozer_halloween/ene_zeal_bulldozer_halloween"))
			table.insert(group_ai_tweak.unit_categories.FBI_tank.unit_types.murkywater, Idstring("units/pd2_dlc_help/characters/ene_zeal_bulldozer_halloween/ene_zeal_bulldozer_halloween"))
			table.insert(group_ai_tweak.unit_categories.FBI_tank.unit_types.federales, Idstring("units/pd2_dlc_help/characters/ene_zeal_bulldozer_halloween/ene_zeal_bulldozer_halloween"))
		end
	end
end