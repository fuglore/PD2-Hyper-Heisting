local math_random = math.random

function MedicDamage:heal_unit(unit, no_cooldown)
	if not no_cooldown then
		local t = Application:time()

		self._heal_cooldown_t = t
	end

	if not self._unit:character_damage():dead() then
		self._unit:sound():say("heal")

		local contour_ext = self._unit:contour()

		if contour_ext then
			contour_ext:add("mark_enemy")
		end

		local base_ext = self._unit:base()
		local custom_vo = base_ext:char_tweak()["custom_voicework"]

		if custom_vo then
			local voicelines = _G.voiceline_framework.BufferedSounds[custom_vo]

			if voicelines and voicelines["heal"] then
				local line_to_use = voicelines.heal[math_random(#voicelines.heal)]

				base_ext:play_voiceline(line_to_use)
			end
		end

		local anim_data = self._unit:anim_data()
		local acting = anim_data and anim_data.act

		if not acting then
			local redir_res = self._unit:movement():play_redirect("cmd_get_up")

			if redir_res then
				self._unit:anim_state_machine():set_speed(redir_res, 0.5)
			end
		end
	end

	managers.network:session():send_to_peers_synched("sync_medic_heal", self._unit)
	MedicActionHeal:check_achievements()

	return true
end
