function BaseInteractionExt:can_interact(player)
	if self._host_only and not Network:is_server() then
		return false
	end
	
	if self.tweak_data == "corpse_dispose" and managers.groupai:state():whisper_mode() and Global.game_settings.one_down then
		return false
	end

	if self._disabled then
		return false
	end

	if not self:_has_required_upgrade(alive(player) and player:movement() and player:movement().current_state_name and player:movement():current_state_name()) then
		return false
	end

	if not self:_has_required_deployable() then
		return false
	end

	if not self:_is_in_required_state(alive(player) and player:movement() and player:movement().current_state_name and player:movement():current_state_name()) then
		return false
	end

	if self._tweak_data.special_equipment_block and managers.player:has_special_equipment(self._tweak_data.special_equipment_block) then
		return false
	end

	if not self._tweak_data.special_equipment or self._tweak_data.dont_need_equipment then
		return true
	end

	return managers.player:has_special_equipment(self._tweak_data.special_equipment)
end

function BaseInteractionExt:can_select(player)
	if not self:_has_required_upgrade(alive(player) and player:movement() and player:movement().current_state_name and player:movement():current_state_name()) then
		return false
	end

	if not self:_has_required_deployable() then
		return false
	end
	
	if self.tweak_data == "corpse_dispose" and managers.groupai:state():whisper_mode() and Global.game_settings.one_down then
		return false
	end
	
	if not self:_is_in_required_state(alive(player) and player:movement() and player:movement().current_state_name and player:movement():current_state_name()) then
		return false
	end

	local blockers = nil

	if type(self._tweak_data.special_equipment_block) == "string" then
		blockers = {
			self._tweak_data.special_equipment_block
		}
	else
		blockers = self._tweak_data.special_equipment_block
	end

	if blockers then
		for k, blocker in pairs(blockers) do
			if managers.player:has_special_equipment(blocker) then
				return false
			end
		end
	end

	if self._tweak_data.verify_owner and not self:is_owner() then
		return false
	end

	return true
end
