Hooks:PostHook( WeaponFactoryTweakData, "init", "gwepmodsrebalance", function(self)

self.parts.wpn_fps_m4_upg_m_quick.name_id = "bm_GEN_speed_strap"
self.parts.wpn_fps_m4_upg_m_quick.has_description = true
self.parts.wpn_fps_m4_upg_m_quick.desc_id = "bm_GEN_decorative_strap"
self.parts.wpn_fps_m4_upg_m_quick.stats.reload = nil
self.parts.wpn_fps_m4_upg_m_quick.stats.concealment = nil

self.parts.wpn_fps_upg_ak_m_quick.name_id = "bm_GEN_speed_strap"
self.parts.wpn_fps_upg_ak_m_quick.has_description = true
self.parts.wpn_fps_upg_ak_m_quick.desc_id = "bm_GEN_decorative_strap"
self.parts.wpn_fps_upg_ak_m_quick.stats.reload = nil
self.parts.wpn_fps_upg_ak_m_quick.stats.concealment = nil

self.parts.wpn_fps_ass_g36_m_quick.name_id = "bm_GEN_speed_strap"
self.parts.wpn_fps_ass_g36_m_quick.has_description = true
self.parts.wpn_fps_ass_g36_m_quick.desc_id = "bm_GEN_decorative_strap"
self.parts.wpn_fps_ass_g36_m_quick.stats.reload = nil
self.parts.wpn_fps_ass_g36_m_quick.stats.concealment = nil

self.parts.wpn_fps_smg_p90_m_strap.name_id = "bm_GEN_speed_strap"
self.parts.wpn_fps_smg_p90_m_strap.has_description = true
self.parts.wpn_fps_smg_p90_m_strap.desc_id = "bm_GEN_decorative_strap"
self.parts.wpn_fps_smg_p90_m_strap.stats.reload = nil
self.parts.wpn_fps_smg_p90_m_strap.stats.concealment = nil

self.parts.wpn_fps_ass_aug_m_quick.name_id = "bm_GEN_speed_strap"
self.parts.wpn_fps_ass_aug_m_quick.has_description = true
self.parts.wpn_fps_ass_aug_m_quick.desc_id = "bm_GEN_decorative_strap"
self.parts.wpn_fps_ass_aug_m_quick.stats.reload = nil
self.parts.wpn_fps_ass_aug_m_quick.stats.concealment = nil

self.parts.wpn_fps_smg_mac10_m_quick.name_id = "bm_GEN_speed_strap"
self.parts.wpn_fps_smg_mac10_m_quick.has_description = true
self.parts.wpn_fps_smg_mac10_m_quick.desc_id = "bm_GEN_decorative_strap"
self.parts.wpn_fps_smg_mac10_m_quick.stats.extra_ammo = nil
self.parts.wpn_fps_smg_mac10_m_quick.stats.reload = nil
self.parts.wpn_fps_smg_mac10_m_quick.stats.concealment = nil

self.parts.wpn_fps_smg_fmg9_m_speed.name_id = "bm_GEN_fmg9_speed_strap"
self.parts.wpn_fps_smg_fmg9_m_speed.has_description = true
self.parts.wpn_fps_smg_fmg9_m_speed.desc_id = "bm_GEN_fmg9_speed_strap_desc"
self.parts.wpn_fps_smg_fmg9_m_speed.stats = {
	value = 1
}

self.wpn_fps_smg_x_mac10.override.wpn_fps_smg_mac10_m_quick = nil

self.parts.wpn_fps_smg_sr2_m_quick.name_id = "bm_GEN_speed_strap"
self.parts.wpn_fps_smg_sr2_m_quick.has_description = true
self.parts.wpn_fps_smg_sr2_m_quick.desc_id = "bm_GEN_decorative_strap"
self.parts.wpn_fps_smg_sr2_m_quick.stats.reload = nil
self.parts.wpn_fps_smg_sr2_m_quick.stats.concealment = nil

self.parts.wpn_fps_smg_p90_m_strap.name_id = "bm_GEN_speed_strap"
self.parts.wpn_fps_smg_p90_m_strap.has_description = true
self.parts.wpn_fps_smg_p90_m_strap.desc_id = "bm_GEN_decorative_strap"
self.parts.wpn_fps_smg_p90_m_strap.stats.reload = nil
self.parts.wpn_fps_smg_p90_m_strap.stats.concealment = nil

self.parts.wpn_fps_smg_pm9_m_quick.name_id = "bm_GEN_speed_strap"
self.parts.wpn_fps_smg_pm9_m_quick.has_description = true
self.parts.wpn_fps_smg_pm9_m_quick.desc_id = "bm_GEN_decorative_strap"
self.parts.wpn_fps_smg_pm9_m_quick.stats.reload = nil
self.parts.wpn_fps_smg_pm9_m_quick.stats.concealment= nil

--peacemaker
self.parts.wpn_fps_pis_peacemaker_b_long = {
		texture_bundle_folder = "west",
		dlc = "west",
		type = "slide",
		name_id = "bm_wp_peacemaker_barrel_long",
		a_obj = "a_b",
		unit = "units/pd2_dlc_west/weapons/wpn_fps_pis_peacemaker_pts/wpn_fps_pis_peacemaker_b_long",
		pcs = {
			10,
			20,
			30,
			40
		},
		stats = {
			spread = 1,
			spread_moving = 1,
			value = 1,
			concealment = -2
		}
	}
self.parts.wpn_fps_pis_peacemaker_b_short = {
	texture_bundle_folder = "west",
	dlc = "west",
	type = "slide",
	name_id = "bm_wp_peacemaker_barrel_short",
	a_obj = "a_b",
	unit = "units/pd2_dlc_west/weapons/wpn_fps_pis_peacemaker_pts/wpn_fps_pis_peacemaker_b_short",
	pcs = {
		10,
		20,
		30,
		40
	},
	stats = {
		spread = -1,
		spread_moving = -1,
		value = 1,
		recoil = 4,
		concealment = 2
	}
}

self.parts.wpn_fps_pis_c96_b_long.stats = { value = 2, damage = 0, total_ammo_mod = 0, extra_ammo= 0, spread = 1}
self.parts.wpn_fps_pis_c96_b_long.custom_stats = nil
self.parts.wpn_fps_smg_shepheard_mag_extended.stats = { value = 2, extra_ammo= 5}
self.parts.wpn_fps_ass_ching_s_pouch.stats = { value = 2, damage = 0, total_ammo_mod = 0, extra_ammo= 0, recoil = 1}
self.parts.wpn_fps_ass_m14_body_jae.stats = { value = 2, damage = 0, total_ammo_mod = 0, extra_ammo= 0, recoil = 1}
self.parts.wpn_fps_ass_m14_body_ebr.stats = { value = 2, damage = 0, total_ammo_mod = 0, extra_ammo= 0, recoil = 1}
self.parts.wpn_fps_ass_g3_b_short.custom_stats = {
	ammo_pickup_max_mul = 2.2,
	ammo_pickup_min_mul = 6
}
self.parts.wpn_fps_ass_g3_b_short.stats = { value = 2, damage = 0, total_ammo_mod = 0, extra_ammo= 0, spread = -1, concealment = 1}
self.parts.wpn_fps_ass_g3_b_short.custom_stats = nil
self.parts.wpn_fps_ass_g3_b_sniper.stats = { value = 2, damage = 0, total_ammo_mod = 0, extra_ammo= 0, spread = 1, concealment = -1}
self.parts.wpn_fps_ass_g3_b_sniper.custom_stats = nil
self.parts.wpn_fps_ass_g3_b_sniper.override = nil
self.parts.wpn_fps_upg_a_slug.custom_stats = {
	armor_piercing_add = 1,
	can_shoot_through_shield = true,
	can_shoot_through_wall = true,
	damage_far_mul = 6,
	damage_near_mul = 6,
	can_shoot_through_enemy = true,
	rays = 1
}
self.parts.wpn_fps_upg_a_slug.stats.total_ammo_mod = -5

self.parts.wpn_fps_upg_a_slug.stats.spread = 6

self.parts.wpn_fps_upg_a_custom.stats = {value = 2}
self.parts.wpn_fps_upg_a_custom.custom_stats = {use_tracers = true}
self.parts.wpn_fps_upg_a_custom_free.stats = {value = 2}
self.parts.wpn_fps_upg_a_custom_free.custom_stats = {use_tracers = true}

self.parts.wpn_fps_upg_a_dragons_breath.custom_stats.can_shoot_through_shield = nil
self.parts.wpn_fps_upg_a_dragons_breath.custom_stats.fire_dot_data = {
	dot_trigger_chance = "60",
	dot_damage = "2",
	dot_length = "6.1",
	dot_trigger_max_distance = "2000",
	dot_tick_period = "0.5"
}
	
self.parts.wpn_fps_upg_a_piercing.custom_stats = {
	damage_near_mul = 1,
	armor_piercing_add = 1,
	can_shoot_through_enemy = true,
	can_shoot_through_shield = false,
	can_shoot_through_wall = false,
	damage_far_mul = 1
}
self.parts.wpn_fps_upg_a_piercing.stats.total_ammo_mod = -5
self.parts.wpn_fps_upg_a_piercing.stats.damage = -50

self.parts.wpn_fps_upg_ns_duck.stats = {
	value = 1,
	spread = 2,
	recoil = 1,
	damage = 2,
	concealment = -2,
	spread_multi = {
		2.25,
		0.5
	}
}


self.wpn_fps_shot_serbu.override = {
	wpn_fps_upg_a_slug = {
		desc_id = "bm_wp_upg_a_slug2_desc",
		custom_stats = {
			armor_piercing_add = 1,
			can_shoot_through_shield = true,
			can_shoot_through_wall = true,
			damage_far_mul = 1,
			damage_near_mul = 1,
			can_shoot_through_enemy = true,
			rays = 1
		}
	}
}

self.wpn_fps_sho_striker.override = {
	wpn_upg_o_marksmansight_rear_vanilla = {a_obj = "a_o_r"},
	wpn_upg_o_marksmansight_front = {a_obj = "a_o_f"},
	wpn_fps_upg_a_slug = {
		desc_id = "bm_wp_upg_a_slug2_desc",
		custom_stats = {
			armor_piercing_add = 1,
			can_shoot_through_shield = true,
			can_shoot_through_wall = true,
			damage_far_mul = 1,
			damage_near_mul = 1,
			can_shoot_through_enemy = true,
			rays = 1
		}
	}
}
	
self.wpn_fps_pis_judge.override = {
	wpn_fps_upg_ns_shot_shark = {parent = "slide"},
	wpn_fps_upg_ns_shot_thick = {parent = "slide"},
	wpn_fps_upg_shot_ns_king = {parent = "slide"},
	wpn_fps_upg_ns_sho_salvo_large = {parent = "slide"},
	wpn_fps_upg_ns_duck = {parent = "slide"},
	wpn_fps_upg_a_piercing = {custom_stats = {
		damage_near_mul = 1,
		armor_piercing_add = 1,
		damage_far_mul = 1
	}},
	wpn_fps_upg_a_explosive = {custom_stats = {
		ignore_statistic = true,
		damage_far_mul = 2.5,
		damage_near_mul = 2,
		bullet_class = "InstantExplosiveBulletBase",
		rays = 1
	}}
}

self.wpn_fps_pis_x_judge.override = {
	wpn_fps_upg_ns_shot_shark = {parent = "slide"},
	wpn_fps_upg_ns_shot_thick = {parent = "slide"},
	wpn_fps_upg_shot_ns_king = {parent = "slide"},
	wpn_fps_upg_ns_sho_salvo_large = {parent = "slide"},
	wpn_fps_upg_ns_duck = {parent = "slide"},
	wpn_fps_upg_a_piercing = {custom_stats = {
		damage_near_mul = 1,
		armor_piercing_add = 1,
		damage_far_mul = 1
	}},
	wpn_fps_upg_a_explosive = {custom_stats = {
		ignore_statistic = true,
		damage_far_mul = 2.5,
		damage_near_mul = 2,
		bullet_class = "InstantExplosiveBulletBase",
		rays = 1
	}}
}

if self.wpn_fps_ass_sg416 then
	self.parts.wpn_fps_ass_komodo_body_tactical.stats = { value = 0, damage = 0, total_ammo_mod = 0, extra_ammo= 0, recoil = 1, spread = 0}
	self.parts.wpn_fps_ass_s552_m_ak.stats = { value = 2, damage = 2, total_ammo_mod = 0, extra_ammo= 0, recoil = -2, spread = 1}
	self.parts.wpn_fps_ass_m4_m_stick.pcs = nil
	self.parts.wpn_fps_ass_m4_m_stick_heavy.pcs = nil
	self.parts.wpn_fps_ass_m4_m_stick_sg.pcs = nil
	self.parts.wpn_fps_ass_m4_m_stick_amcar.pcs = nil
	self.parts.wpn_fps_ass_ak_m_proto.stats.concealment = -2
	self.parts.wpn_fps_ass_ak_m_proto.stats.reload = 3
end

if self.parts.wpn_fps_fla_mk2_body_long then --WAR! Nozzle
	self.parts.wpn_fps_fla_mk2_body_long.desc_id = "bm_wpn_fps_fla_mk2_body_long_desc"
	self.parts.wpn_fps_fla_mk2_body_long.has_description = true
	self.parts.wpn_fps_fla_mk2_body_long.stats = {damage = -6, concealment = -2, recoil = 2}
	self.parts.wpn_fps_fla_mk2_body_long.custom_stats = {range_mul = 3}
end

self.parts.wpn_fps_fla_system_b_wtf.desc_id = "bm_wpn_fps_fla_system_b_wtf_desc"
self.parts.wpn_fps_fla_system_b_wtf.has_description = true
self.parts.wpn_fps_fla_system_b_wtf.stats = {
	damage = 6,
	recoil = -2,
	concealment = 5
}
self.parts.wpn_fps_fla_system_b_wtf.custom_stats = {range_mul = 0.5}

--M4 DMRs
self.parts.wpn_fps_upg_ass_m4_b_beowulf.desc_id = "bm_GEN_light_DMR_desc"
self.parts.wpn_fps_upg_ass_m4_b_beowulf.has_description = true
self.parts.wpn_fps_upg_ass_m4_b_beowulf.stats = {
	spread = 0,
	total_ammo_mod = -12,
	damage = 44,
	concealment = -4,
	value = 1,
	recoil = -10
}
self.parts.wpn_fps_upg_ass_m4_b_beowulf.custom_stats = {
	armor_piercing_add = 1,
	can_shoot_through_enemy = true,
	rof_mul = 0.7,
	ammo_pickup_max_mul = 0.6,
	ammo_pickup_min_mul = 0.6
}

self.wpn_fps_ass_m16.override = {
	wpn_fps_upg_ass_m4_b_beowulf = {
		desc_id = "bm_GEN_heavy_DMR_desc",
		has_description = true,
		stats = {
			spread = 4,
			total_ammo_mod = -8,
			damage = 22,
			concealment = -4,
			recoil = -8,
			value = 1
		},
		custom_stats = {
			armor_piercing_add = 1,
			can_shoot_through_enemy = true,
			can_shoot_through_shield = true,
			rof_mul = 0.5,
			ammo_pickup_max_mul = 0.8,
			ammo_pickup_min_mul = 0.8
		}
	}
}

--AK DMRs
self.parts.wpn_fps_upg_ass_ak_b_zastava.desc_id = "bm_GEN_sniperkit_desc"
self.parts.wpn_fps_upg_ass_ak_b_zastava.has_description = true
self.parts.wpn_fps_upg_ass_ak_b_zastava.stats = {
	spread = 3,
	total_ammo_mod = -12,
	damage = 97,
	concealment = -4,
	value = 1,
	recoil = -17
}
self.parts.wpn_fps_upg_ass_ak_b_zastava.custom_stats = {
	armor_piercing_add = 1,
	can_shoot_through_wall = true,
	can_shoot_through_enemy = true,
	can_shoot_through_shield = true,
	rof_mul = 0.4,
	ammo_pickup_max_mul = 0.4,
	ammo_pickup_min_mul = 0.5
}
self.wpn_fps_ass_74.override = {
	wpn_fps_upg_ass_ak_b_zastava = {
		stats = {
			spread = 2,
			total_ammo_mod = -6,
			damage = 24,
			concealment = -4,
			value = 1,
			recoil = -8
		},
		desc_id = "bm_GEN_heavy_DMR_desc",
		custom_stats = {
			armor_piercing_add = 1,
			can_shoot_through_enemy = true,
			can_shoot_through_shield = true,
			rof_mul = 0.5,
			ammo_pickup_max_mul = 0.5,
			ammo_pickup_min_mul = 0.5
		}
	}
}


end)