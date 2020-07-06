local idstr_contour = Idstring("contour")
local idstr_material = Idstring("material")
local idstr_contour_color = Idstring("contour_color")
local idstr_contour_opacity = Idstring("contour_opacity")
ContourExt._types = {
	teammate = {
		persistence = 0.3,
		priority = 5,
		ray_check = true
	},
	teammate_downed = {
		priority = 4,
		color = tweak_data.contour.character.downed_color
	},
	teammate_downed_selected = {
		priority = 3,
		color = tweak_data.contour.character_interactable.selected_color
	},
	teammate_dead = {
		priority = 4,
		color = tweak_data.contour.character.dead_color
	},
	teammate_cuffed = {
		priority = 4,
		color = tweak_data.contour.character.downed_color
	},
	friendly = {
		priority = 3,
		material_swap_required = true,
		color = tweak_data.contour.character.friendly_color
	},
	drunk_pilot = {
		priority = 5
	},
	boris = {
		priority = 5
	},
	taxman = {
		priority = 5,
		color = tweak_data.contour.character_interactable.standard_color
	},
	mark_unit = {
		priority = 4,
		fadeout = 4.5,
		trigger_marked_event = true,
		color = tweak_data.contour.character.dangerous_color
	},
	mark_unit_dangerous = {
		priority = 4,
		fadeout = 9,
		trigger_marked_event = true,
		color = tweak_data.contour.character.dangerous_color
	},
	mark_unit_dangerous_damage_bonus = {
		priority = 4,
		damage_bonus = true,
		fadeout = 9,
		trigger_marked_event = true,
		color = tweak_data.contour.character.dangerous_color
	},
	mark_unit_dangerous_damage_bonus_distance = {
		priority = 4,
		damage_bonus = true,
		fadeout = 9,
		damage_bonus_distance = 1,
		trigger_marked_event = true,
		color = tweak_data.contour.character.dangerous_color
	},
	mark_unit_friendly = {
		priority = 3,
		color = tweak_data.contour.character.friendly_color
	},
	mark_enemy = {
		fadeout = 4.5,
		priority = 5,
		material_swap_required = true,
		fadeout_silent = 13.5,
		trigger_marked_event = true,
		color = tweak_data.contour.character.dangerous_color
	},
	mark_enemy_damage_bonus = {
		fadeout = 4.5,
		priority = 4,
		material_swap_required = true,
		damage_bonus = true,
		fadeout_silent = 13.5,
		trigger_marked_event = true,
		color = tweak_data.contour.character.more_dangerous_color
	},
	mark_enemy_damage_bonus_distance = {
		fadeout = 4.5,
		priority = 4,
		material_swap_required = true,
		damage_bonus = true,
		damage_bonus_distance = 1,
		fadeout_silent = 13.5,
		trigger_marked_event = true,
		color = tweak_data.contour.character.more_dangerous_color
	},
	highlight = {
		priority = 4,
		color = tweak_data.contour.interactable.standard_color
	},
	highlight_character = {
		priority = 6,
		material_swap_required = true,
		color = tweak_data.contour.interactable.standard_color
	},
	generic_interactable = {
		priority = 2,
		material_swap_required = true,
		color = tweak_data.contour.character_interactable.standard_color
	},
	generic_interactable_selected = {
		priority = 1,
		material_swap_required = true,
		color = tweak_data.contour.character_interactable.selected_color
	},
	hostage_trade = {
		priority = 1,
		material_swap_required = true,
		color = tweak_data.contour.character_interactable.standard_color
	},
	deployable_selected = {
		priority = 1,
		unique = true,
		color = tweak_data.contour.deployable.selected_color
	},
	deployable_disabled = {
		priority = 2,
		unique = true,
		color = tweak_data.contour.deployable.disabled_color
	},
	deployable_active = {
		priority = 3,
		unique = true,
		color = tweak_data.contour.deployable.active_color
	},
	deployable_interactable = {
		priority = 4,
		unique = true,
		color = tweak_data.contour.deployable.interact_color
	},
	medic_heal = {
		priority = 1,
		material_swap_required = true,
		fadeout = 3,
		color = tweak_data.contour.character.heal_color
	},
	medic_heal_shin = {
		priority = 1,
		material_swap_required = true,
		fadeout = 2,
		color = tweak_data.contour.character.heal_color
	},
	medic_heal_shin_complex = {
		priority = 1,
		material_swap_required = true,
		fadeout = 3,
		color = tweak_data.contour.character.heal_color
	},
	medic_heal_complex = {
		priority = 1,
		material_swap_required = true,
		fadeout = 4,
		color = tweak_data.contour.character.heal_color
	}
}
ContourExt.indexed_types = {}

for name, preset in pairs(ContourExt._types) do
	table.insert(ContourExt.indexed_types, name)
end

table.sort(ContourExt.indexed_types)

if #ContourExt.indexed_types > 32 then
	Application:error("[ContourExt] max # contour presets exceeded!")
end

ContourExt._MAX_ID = 100000
ContourExt._next_id = 1