function CrimeSpreeManager:init()
	self:_setup()
	self._copaccmult = 1
	self._copturnadd = 0
	self._copdetmult = 0
	self._next_acc_turn_det_increase = 50
end

function CrimeSpreeManager:get_acc_mult()
	--log("fudge")
	return self._copaccmult
end

function CrimeSpreeManager:get_turn_spd_add()
	--log("fudge2")
	return self._copturnadd
end

function CrimeSpreeManager:get_cop_det_mult()
	--log("fudge3")
	return self._copdetmult
end

function CrimeSpreeManager:_setup_global_from_mission_id(mission_id)
	local mission_data = self:get_mission(mission_id)
	
	local score = 0
	
	if Network:is_server() or Global.game_settings.single_player then
		score = managers.crime_spree:spree_level()
	else
		score = managers.crime_spree:get_peer_spree_level(1)
	end
	
	if Network:is_server() or Global.game_settings.single_player then
		if self._next_acc_turn_det_increase <= score then
			repeat
				self._next_acc_turn_det_increase = self._next_acc_turn_det_increase + 50
				self._copaccmult = self._copaccmult + 0.1
				self._copturnadd = self._copturnadd + 0.05
				self._copdetmult = self._copdetmult + 0.05
			until score < self._next_acc_turn_det_increase	
		end
	else
		if score >= self._next_acc_turn_det_increase then
			repeat
				self._next_acc_turn_det_increase = self._next_acc_turn_det_increase + 50
				self._copaccmult = self._copaccmult + 0.1
				self._copturnadd = self._copturnadd + 0.05
				self._copdetmult = self._copdetmult + 0.05
			until score < self._next_acc_turn_det_increase
		end
	end
			
	local gamemode_chk = game_state_machine:gamemode() 
	if mission_data then
		Global.game_settings.difficulty = tweak_data.crime_spree.base_difficulty
		Global.game_settings.one_down = false
		Global.game_settings.level_id = mission_data.level.level_id
		Global.game_settings.mission = mission_data.mission or "none"
	end
end