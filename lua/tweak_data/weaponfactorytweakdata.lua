Hooks:PostHook( WeaponFactoryTweakData, "init", "gwepmodsrebalance", function(self)


self.parts.wpn_fps_m4_upg_m_quick.stats.reload = 3
self.parts.wpn_fps_m4_upg_m_quick.stats.concealment = -2
self.parts.wpn_fps_upg_ak_m_quick.stats.reload = 3
self.parts.wpn_fps_upg_ak_m_quick.stats.concealment = -2
self.parts.wpn_fps_ass_g36_m_quick.stats.reload = 3
self.parts.wpn_fps_ass_g36_m_quick.stats.concealment = -2
self.parts.wpn_fps_smg_p90_m_strap.stats.reload = 3
self.parts.wpn_fps_smg_p90_m_strap.stats.concealment = -2
self.parts.wpn_fps_ass_aug_m_quick.stats.reload = 3
self.parts.wpn_fps_ass_aug_m_quick.stats.concealment = -2
self.parts.wpn_fps_smg_mac10_m_quick.stats.reload = 3
self.parts.wpn_fps_smg_mac10_m_quick.stats.concealment = -2
self.parts.wpn_fps_smg_sr2_m_quick.stats.reload = 3
self.parts.wpn_fps_smg_sr2_m_quick.stats.concealment = -2

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
	},
	wpn_fps_upg_a_custom = {
		desc_id = "bm_wp_upg_a_custom2_desc",
		custom_stats = {}
	},
	wpn_fps_upg_a_custom_free = {
		desc_id = "bm_wp_upg_a_custom2_desc",
		custom_stats = {}
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
	},
	wpn_fps_upg_a_custom = {
		desc_id = "bm_wp_upg_a_custom2_desc",
		custom_stats = {}
	},
	wpn_fps_upg_a_custom_free = {
		desc_id = "bm_wp_upg_a_custom2_desc",
		custom_stats = {}
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


end)