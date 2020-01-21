Hooks:PostHook( WeaponFactoryTweakData, "init", "gwepmodsrebalance", function(self)
if PD2THHSHIN and PD2THHSHIN:IsOverhaulEnabled() then
self.parts.wpn_fps_pis_c96_b_long.stats = { value = 2, damage = 0, total_ammo_mod = 0, extra_ammo= 0, spread = 1}
self.parts.wpn_fps_pis_c96_b_long.custom_stats = nil
self.parts.wpn_fps_smg_shepheard_mag_extended.stats = { value = 2, extra_ammo= 5}
self.parts.wpn_fps_ass_ching_s_pouch.stats = { value = 2, damage = 0, total_ammo_mod = 0, extra_ammo= 0, recoil = 1}
self.parts.wpn_fps_ass_m14_body_jae.stats = { value = 2, damage = 0, total_ammo_mod = 0, extra_ammo= 0, recoil = 1}
self.parts.wpn_fps_ass_m14_body_ebr.stats = { value = 2, damage = 0, total_ammo_mod = 0, extra_ammo= 0, recoil = 1}
self.parts.wpn_fps_smg_p90_m_strap.stats.reload = 3
self.parts.wpn_fps_ass_aug_m_quick.stats.reload = 3
self.parts.wpn_fps_ass_vhs_body.stats.reload = 7
self.parts.wpn_fps_m4_upg_m_quick.stats.reload = 3
self.parts.wpn_fps_smg_cobray_m_standard.stats.reload = 5
self.parts.wpn_fps_upg_ak_m_quick.stats.reload = 3
self.parts.wpn_fps_ass_g36_m_quick.stats.reload = 3
self.parts.wpn_fps_smg_mac10_m_quick.stats.reload = 3
self.parts.wpn_fps_pis_2006m_body_standard.stats.reload = 7
self.parts.wpn_fps_pis_chinchilla_body.stats.reload = 4
self.parts.wpn_fps_smg_sr2_m_quick.stats.reload = 3
self.parts.wpn_fps_gre_m32_upper_reciever.stats.reload = 11
self.parts.wpn_fps_pis_peacemaker_body_standard.stats.reload = 10
self.parts.wpn_fps_ass_galil_m_standard.stats.reload = 5
self.parts.wpn_fps_ass_famas_m_standard.stats.reload = 3
self.parts.wpn_fps_snp_wa2000_m_standard.stats.reload = 10
self.parts.wpn_fps_ass_asval_body_standard.stats.reload = 5
self.parts.wpn_fps_ass_g3_b_short.custom_stats = {
			ammo_pickup_max_mul = 2.2,
			ammo_pickup_min_mul = 6
	}
self.parts.wpn_fps_ass_g3_b_short.stats.total_ammo_mod = 10
self.parts.wpn_fps_ass_g3_b_sniper.stats.total_ammo_mod = -10

if SystemFS:exists("assets/mod_overrides/Vanilla Styled Mod Pack/main.xml") then
self.parts.wpn_fps_ass_komodo_body_tactical.stats = { value = 0, damage = 0, total_ammo_mod = 0, extra_ammo= 0, recoil = 1, spread = 0}
self.parts.wpn_fps_ass_s552_m_ak.pcs = nil
self.parts.wpn_fps_ass_m4_m_stick.pcs = nil
self.parts.wpn_fps_ass_m4_m_stick_heavy.pcs = nil
self.parts.wpn_fps_ass_m4_m_stick_sg.pcs = nil
self.parts.wpn_fps_ass_m4_m_stick_amcar.pcs = nil
end

end


end)