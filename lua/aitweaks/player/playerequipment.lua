--WIP


--[[function PlayerEquipment:use_doctor_bag()
	local ray = self:valid_shape_placement("doctor_bag")

	if ray then
		local pos = ray.position
		local rot = self:_m_deploy_rot()
		rot = Rotation(rot:yaw(), 0, 0)

		PlayerStandard.say_line(self, "s02x_plu")

		if managers.blackmarket:equipped_mask().mask_id == tweak_data.achievement.no_we_cant.mask then
			managers.achievment:award_progress(tweak_data.achievement.no_we_cant.stat)
		end

		managers.mission:call_global_event("player_deploy_doctorbag")
		managers.statistics:use_doctor_bag()
		
		local antilethal = managers.player:has_category_upgrade("player", "antilethal_meds") and 1 or 0
		local soldiers = 0
		
		if managers.player:has_category_upgrade("player", "soldiersyringe_basic") then
			soldiers = soldiers + 1
			
			if managers.player:has_category_upgrade("player", "soldiersyringe_aced") then
				soldiers = soldiers + 1
			end
		end
		
		local amount_upgrade_lvl = managers.player:upgrade_level("doctor_bag", "amount_increase")
		
		antilethal = math.clamp(antilethal, 0, 1)
		soldiers = math.clamp(soldiers, 0, 2)
		amount_upgrade_lvl = math.clamp(amount_upgrade_lvl, 0, 2)
		
		local bits = Bitwise:lshift(upgrade_lvl, DoctorBagBase.damage_reduce_lvl_shift) + Bitwise:lshift(amount_upgrade_lvl, DoctorBagBase.amount_upgrade_lvl_shift)

		if Network:is_client() then
			managers.network:session():send_to_host("place_deployable_bag", "DoctorBagBase", pos, rot, bits)
		else
			local unit = DoctorBagBase.spawn(pos, rot, bits, managers.network:session():local_peer():id())
		end

		return true
	end

	return false
end]]