Hooks:PostHook( WeaponFactoryTweakData, "init", "gwepmodsrebalance", function(self)
	if PD2THHSHIN and PD2THHSHIN:IsOverhaulEnabled() then
		self.parts.wpn_fps_m4_upg_m_quick.stats.reload = 5
		self.parts.wpn_fps_m4_upg_m_quick.stats.concealment = -1
		self.parts.wpn_fps_upg_ak_m_quick.stats.reload = 5
		self.parts.wpn_fps_upg_ak_m_quick.stats.concealment = -1
		self.parts.wpn_fps_ass_g36_m_quick.stats.reload = 5
		self.parts.wpn_fps_ass_g36_m_quick.stats.concealment = -1
		self.parts.wpn_fps_smg_p90_m_strap.stats.reload = 5
		self.parts.wpn_fps_smg_p90_m_strap.stats.concealment = -1
		self.parts.wpn_fps_ass_aug_m_quick.stats.reload = 5
		self.parts.wpn_fps_ass_aug_m_quick.stats.concealment = -1
		self.parts.wpn_fps_smg_mac10_m_quick.stats.reload = 5
		self.parts.wpn_fps_smg_mac10_m_quick.stats.concealment = -1
		self.parts.wpn_fps_smg_sr2_m_quick.stats.reload = 5
		self.parts.wpn_fps_smg_sr2_m_quick.stats.concealment = -1

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
							damage_far_mul = 5,
							damage_near_mul = 5,
							can_shoot_through_enemy = true,
							rays = 1
			}
			
		self.parts.wpn_fps_upg_a_piercing.custom_stats = {
							damage_near_mul = 3,
							armor_piercing_add = 1,
							damage_far_mul = 3
			}

		self.wpn_fps_shot_serbu.override = {
					wpn_fps_upg_a_slug = {
						desc_id = "bm_wp_upg_a_slug2_desc",
						custom_stats = {
							armor_piercing_add = 1,
							can_shoot_through_shield = true,
							can_shoot_through_wall = true,
							damage_far_mul = 5,
							damage_near_mul = 5,
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
							damage_far_mul = 5,
							damage_near_mul = 5,
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
						damage_near_mul = 3,
						armor_piercing_add = 1,
						damage_far_mul = 3
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
						damage_near_mul = 3,
						armor_piercing_add = 1,
						damage_far_mul = 3
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

		-- PX4
		if self.wpn_fps_pis_px4 then
				self.parts.wpn_fps_upg_px4_ammo_45acp.pcs = nil											
				self.parts.wpn_fps_upg_px4_ammo_9mm.pcs = nil
		end	

		-- M&P 40
		if self.wpn_fps_pis_swmp40 then
				self.parts.wpn_fps_upg_swmp40_ammo_9mm.pcs = nil											
		end	

		-- P99
		if self.wpn_fps_pis_p99 then
				self.parts.wpn_fps_upg_p99_ammo_40sw.pcs = nil											
		end	

		-- SW659
		if self.wpn_fps_pis_sw659 then
				self.parts.wpn_fps_pis_sw659_a_c45.pcs = nil		
				self.parts.wpn_fps_pis_sw659_a_gen.pcs = nil				
		end	

		-- TT33
		if self.wpn_fps_pis_gtt33 then
				self.parts.wpn_fps_pis_gtt33_a_c45.pcs = nil					
		end	

		-- G19
		if self.wpn_fps_pis_g19 then
				self.parts.wpn_fps_upg_g19_ammo_9mm_p.pcs = nil					
		end	

		-- Max9
		if self.wpn_fps_pis_max9 then
				self.parts.wpn_fps_pis_max9_b_short.pcs = nil	
				self.parts.wpn_fps_pis_max9_b_nosup.pcs = nil					
		end	

		-- P22-whatever who cares
		if self.wpn_fps_pis_noodle then
				self.parts.wpn_fps_pis_noodle_a1_10mm.pcs = nil					
		end	

		-- Brown Bricks -browning hp-
		if self.wpn_fps_pis_hpb then
				self.parts.wpn_fps_pis_hpb_a_c45.pcs = nil					
		end	

		-- A glock
		if self.wpn_fps_pis_glawk then
				self.parts.wpn_fps_pis_glawk_a1_22lr.pcs = nil		
				self.parts.wpn_fps_pis_glawk_a1_40sw.pcs = nil	
				self.parts.wpn_fps_pis_glawk_a2_10mm.pcs = nil	
				self.parts.wpn_fps_pis_glawk_a3_357sig.pcs = nil
				self.parts.wpn_fps_pis_glawk_a4_45acp.pcs = nil		
				self.parts.wpn_fps_pis_glawk_a5_45gap.pcs = nil				
		end	

		-- AMT
		if self.wpn_fps_pis_amt then
				self.parts.wpn_fps_pis_amt_a_357.pcs = nil		
				self.parts.wpn_fps_pis_amt_a_44.pcs = nil			
		end	

		-- Doom Shotgun
		if self.wpn_fps_shot_super then
				self.parts.wpn_fps_upg_super_ammo_piercing.pcs = nil			
		end	

		-- GITS M4
		if self.wpn_fps_ass_cinnamonroll then
				self.parts.wpn_fps_ass_cinnamonroll_bc_a.pcs = nil
				self.parts.wpn_fps_ass_cinnamonroll_bc_b.pcs = nil		
				self.parts.wpn_fps_ass_cinnamonroll_bc_c.pcs = nil				
		end	

		-- GITS munmu
		if self.wpn_fps_ass_munmu then
				self.parts.wpn_fps_ass_munmu_bc_dam.pcs = nil
				self.parts.wpn_fps_ass_munmu_bc_acc.pcs = nil		
				self.parts.wpn_fps_ass_munmu_bc_sta.pcs = nil				
		end	

		-- Tar21
		if self.wpn_fps_ass_tar21 then
				self.parts.wpn_fps_ass_tar21_a_sniper.pcs = nil	
		end	

		-- an hk rifle
		if self.wpn_fps_ass_raifu then
				self.parts.wpn_fps_upg_raifu_am_blackhills.pcs = nil	
		end	

		-- m14e2131241
		if self.wpn_fps_ass_m14e2 then
				self.parts.wpn_fps_ass_m14e2_m_extended.pcs = nil	
		end	

		-- Howa
		if self.wpn_fps_ass_howa then
				self.parts.wpn_fps_ass_howa_t64_body.pcs = nil	
		end	

		-- an92
		if self.wpn_fps_ass_tilt then
				self.parts.wpn_fps_ass_tilt_a_fuerte.pcs = nil	
		end	

		-- mk18s
		if self.wpn_fps_ass_mk18s then
				self.parts.wpn_fps_ass_mk18s_a_dmr.pcs = nil	
				self.parts.wpn_fps_ass_mk18s_a_weak.pcs = nil	
				self.parts.wpn_fps_ass_mk18s_a_strong.pcs = nil	
				self.parts.wpn_fps_ass_mk18s_a_classic.pcs = nil	
		end	

		-- mikon
		if self.wpn_fps_ass_mikon then
				self.parts.wpn_fps_upg_mikon_am_spc.pcs = nil	
				self.parts.wpn_fps_upg_mikon_am_parp.pcs = nil	
		end	

		-- lkrifle
		if self.wpn_fps_ass_lkrifle then
				self.parts.wpn_fps_ass_lkrifle_a_fuerte.pcs = nil	
		end	

		-- evo
		if self.wpn_fps_smg_czevo then
				self.parts.wpn_fps_smg_czevo_a_strong.pcs = nil	
				self.parts.wpn_fps_smg_czevo_a_classic.pcs = nil	
		end	
	end

end)
