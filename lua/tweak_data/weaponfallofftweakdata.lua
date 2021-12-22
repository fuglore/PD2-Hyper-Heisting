function WeaponFalloffTemplate.setup_weapon_falloff_templates()
	local weapon_falloff_templates = {
		ASSAULT_FALL_LOW = {}
	}
	weapon_falloff_templates.ASSAULT_FALL_LOW.optimal_distance = 0
	weapon_falloff_templates.ASSAULT_FALL_LOW.optimal_range = 2000
	weapon_falloff_templates.ASSAULT_FALL_LOW.near_falloff = 0
	weapon_falloff_templates.ASSAULT_FALL_LOW.far_falloff = 2000
	weapon_falloff_templates.ASSAULT_FALL_LOW.display_range = 2
	weapon_falloff_templates.ASSAULT_FALL_LOW.near_multiplier = 1
	weapon_falloff_templates.ASSAULT_FALL_LOW.far_multiplier = 0.5
	weapon_falloff_templates.ASSAULT_FALL_MEDIUM = {
		optimal_distance = 0,
		optimal_range = 2000,
		near_falloff = 0,
		far_falloff = 2000,
		display_range = 2,
		near_multiplier = 1,
		far_multiplier = 0.75
	}
	weapon_falloff_templates.ASSAULT_FALL_HIGH = {
		optimal_distance = 0,
		optimal_range = 3000,
		near_falloff = 0,
		far_falloff = 3000,
		display_range = 3,
		near_multiplier = 1,
		far_multiplier = 1
	}
	weapon_falloff_templates.SHOTGUN_FALL_PRIMARY_LOW = {
		optimal_distance = 200,
		optimal_range = 600,
		near_falloff = 0,
		display_range = 1,
		far_falloff = 400,
		near_multiplier = 1,
		far_multiplier = 0.5
	}
	weapon_falloff_templates.SHOTGUN_FALL_PRIMARY_MEDIUM = {
		optimal_distance = 700,
		optimal_range = 500,
		near_falloff = 0,
		display_range = 1,
		far_falloff = 300,
		near_multiplier = 1,
		far_multiplier = 0.6
	}
	weapon_falloff_templates.SHOTGUN_FALL_PRIMARY_HIGH = {
		optimal_distance = 700,
		optimal_range = 800,
		near_falloff = 0,
		display_range = 1,
		far_falloff = 400,
		near_multiplier = 1,
		far_multiplier = 0.7
	}
	weapon_falloff_templates.SNIPER_FALL_LOW = {
		optimal_distance = 400,
		optimal_range = 1600,
		display_range = 1,
		near_falloff = 0,
		far_falloff = 1000,
		near_multiplier = 1,
		far_multiplier = 1.25
	}
	weapon_falloff_templates.SNIPER_FALL_MEDIUM = {
		optimal_distance = 400,
		optimal_range = 1500,
		display_range = 2,
		far_falloff = 2000,
		near_multiplier = 1,
		far_multiplier = 1.5
	}
	weapon_falloff_templates.SNIPER_FALL_HIGH = {
		optimal_distance = 500,
		optimal_range = 1500,
		near_falloff = 0,
		display_range = 3,
		far_falloff = 3000,
		near_multiplier = 1,
		far_multiplier = 1.5
	}
	weapon_falloff_templates.SNIPER_FALL_VERYHIGH = {
		optimal_distance = 500,
		optimal_range = 1500,
		near_falloff = 0,
		display_range = 4,
		far_falloff = 3000,
		near_multiplier = 1,
		far_multiplier = 2
	}
	weapon_falloff_templates.LMG_FALL_MEDIUM = {
		optimal_distance = 0,
		optimal_range = 1700,
		near_falloff = 0,
		display_range = 1,
		far_falloff = 1500,
		near_multiplier = 1,
		far_multiplier = 0.7
	}
	weapon_falloff_templates.LMG_FALL_HIGH = {
		optimal_distance = 0,
		optimal_range = 1800,
		near_falloff = 0,
		display_range = 2,
		far_falloff = 2500,
		near_multiplier = 1,
		far_multiplier = 0.8
	}
	weapon_falloff_templates.AKI_PISTOL_FALL_AUTO = {
		optimal_distance = 300,
		optimal_range = 1000,
		near_falloff = 0,
		display_range = 1,
		far_falloff = 800,
		near_multiplier = 1,
		far_multiplier = 0.7
	}
	weapon_falloff_templates.AKI_PISTOL_FALL_LOW = {
		optimal_distance = 300,
		optimal_range = 1000,
		near_falloff = 0,
		display_range = 1,
		far_falloff = 1000,
		near_multiplier = 1,
		far_multiplier = 0.7
	}
	weapon_falloff_templates.AKI_PISTOL_FALL_MEDIUM = {
		optimal_distance = 300,
		optimal_range = 2000,
		near_falloff = 0,
		far_falloff = 2000,
		display_range = 2,
		near_multiplier = 1,
		far_multiplier = 0.8
	}
	weapon_falloff_templates.AKI_PISTOL_FALL_HIGH = {
		optimal_distance = 300,
		optimal_range = 2000,
		near_falloff = 0,
		far_falloff = 2000,
		display_range = 2,
		near_multiplier = 1,
		far_multiplier = 0.9
	}
	weapon_falloff_templates.AKI_PISTOL_FALL_VERYHIGH = {
		optimal_distance = 300,
		optimal_range = 3000,
		near_falloff = 0,
		far_falloff = 3000,
		display_range = 3,
		near_multiplier = 1,
		far_multiplier = 1
	}
	weapon_falloff_templates.AKI_SMG_FALL_LOW = {
		optimal_distance = 0,
		optimal_range = 1000,
		near_falloff = 0,
		far_falloff = 800,
		display_range = 1,
		near_multiplier = 1,
		far_multiplier = 0.5
	}
	weapon_falloff_templates.AKI_SMG_FALL_MEDIUM = {
		optimal_distance = 0,
		optimal_range = 2000,
		near_falloff = 0,
		far_falloff = 1400,
		display_range = 1,
		near_multiplier = 1,
		far_multiplier = 0.5
	}
	weapon_falloff_templates.AKI_SMG_FALL_HIGH = {
		optimal_distance = 0,
		optimal_range = 2000,
		near_falloff = 0,
		far_falloff = 1400,
		display_range = 1,
		near_multiplier = 1,
		far_multiplier = 0.75
	}
	weapon_falloff_templates.AKI_SHOTGUN_FALL_LOW = {
		optimal_distance = 500,
		optimal_range = 500,
		near_falloff = 0,
		display_range = 1,
		far_falloff = 200,
		near_multiplier = 1,
		far_multiplier = 0.5
	}
	weapon_falloff_templates.AKI_SHOTGUN_FALL_MEDIUM = {
		optimal_distance = 500,
		optimal_range = 500,
		near_falloff = 0,
		display_range = 1,
		far_falloff = 600,
		near_multiplier = 1,
		far_multiplier = 0.6
	}
	weapon_falloff_templates.AKI_SHOTGUN_FALL_HIGH = {
		optimal_distance = 500,
		optimal_range = 600,
		near_falloff = 0,
		display_range = 1,
		far_falloff = 500,
		near_multiplier = 1,
		far_multiplier = 0.7
	}
	weapon_falloff_templates.PISTOL_FALL_AUTO = {
		optimal_distance = 300,
		optimal_range = 1000,
		near_falloff = 0,
		display_range = 1,
		far_falloff = 800,
		near_multiplier = 1,
		far_multiplier = 0.5
	}
	weapon_falloff_templates.PISTOL_FALL_LOW = {
		optimal_distance = 500,
		optimal_range = 700,
		near_falloff = 0,
		display_range = 1,
		far_falloff = 1000,
		near_multiplier = 1,
		far_multiplier = 0.6
	}
	weapon_falloff_templates.PISTOL_FALL_MEDIUM = {
		optimal_distance = 0,
		optimal_range = 1000,
		near_falloff = 200,
		far_falloff = 1400,
		display_range = 1,
		near_multiplier = 1,
		far_multiplier = 0.7
	}
	weapon_falloff_templates.PISTOL_FALL_HIGH = {
		optimal_distance = 0,
		optimal_range = 2000,
		near_falloff = 0,
		display_range = 2,
		far_falloff = 1800,
		near_multiplier = 1,
		far_multiplier = 0.7
	}
	weapon_falloff_templates.PISTOL_FALL_VERYHIGH = {
		optimal_distance = 0,
		optimal_range = 2000,
		near_falloff = 0,
		display_range = 2,
		far_falloff = 2200,
		near_multiplier = 1,
		far_multiplier = 0.8
	}
	weapon_falloff_templates.PISTOL_FALL_SUPER = {
		optimal_distance = 0,
		optimal_range = 3000,
		near_falloff = 0,
		display_range = 3,
		far_falloff = 3000,
		near_multiplier = 1,
		far_multiplier = 0.8
	}
	weapon_falloff_templates.SMG_FALL_LOW = {
		optimal_distance = 0,
		optimal_range = 1000,
		near_falloff = 0,
		display_range = 1,
		far_falloff = 800,
		near_multiplier = 1,
		far_multiplier = 0.75
	}
	weapon_falloff_templates.SMG_FALL_MEDIUM = {
		optimal_distance = 0,
		optimal_range = 2000,
		near_falloff = 0,
		display_range = 1,
		far_falloff = 1400,
		near_multiplier = 1,
		far_multiplier = 0.75
	}
	weapon_falloff_templates.SMG_FALL_HIGH = {
		optimal_distance = 0,
		optimal_range = 3000,
		near_falloff = 0,
		display_range = 2,
		far_falloff = 2000,
		near_multiplier = 1,
		far_multiplier = 0.75
	}
	weapon_falloff_templates.SHOTGUN_FALL_SECONDARY_LOW = {
		optimal_distance = 500,
		optimal_range = 400,
		near_falloff = 0,
		far_falloff = 400,
		display_range = 1,
		near_multiplier = 1,
		far_multiplier = 0.5
	}
	weapon_falloff_templates.SHOTGUN_FALL_SECONDARY_MEDIUM = {
		optimal_distance = 500,
		optimal_range = 500,
		near_falloff = 0,
		far_falloff = 400,
		display_range = 1,
		near_multiplier = 1,
		far_multiplier = 0.5
	}
	weapon_falloff_templates.SHOTGUN_FALL_SECONDARY_HIGH = {
		optimal_distance = 500,
		optimal_range = 500,
		near_falloff = 400,
		far_falloff = 0,
		display_range = 1,
		near_multiplier = 1,
		far_multiplier = 0.6
	}
	weapon_falloff_templates.SHOTGUN_FALL_SECONDARY_VERYHIGH = {
		optimal_distance = 400,
		optimal_range = 600,
		near_falloff = 0,
		far_falloff = 200,
		display_range = 1,
		near_multiplier = 1,
		far_multiplier = 0.5
	}

	return weapon_falloff_templates
end
