if PD2THHSHIN and PD2THHSHIN:IsOverhaulEnabled() then
	function FPCameraPlayerBase:recoil_kick(up, down, left, right)
		local v = math.lerp(up, down, math.random())
		self._recoil_kick.accumulated = ((self._recoil_kick.accumulated or 0) + v)
		local h = math.lerp(left, right, math.random())
		self._recoil_kick.h.accumulated = ((self._recoil_kick.h.accumulated or 0) + h)
	end
	function FPCameraPlayerBase:stop_shooting(wait)
		self._recoil_kick.to_reduce = 0
		self._recoil_kick.h.to_reduce = 0
		self._recoil_wait = nil
		self._recoil_kick.current = 0
		self._recoil_kick.h.current = 0
		self._recoil_kick.accumulated = 0
		self._recoil_kick.h.accumulated = 0
	end
end