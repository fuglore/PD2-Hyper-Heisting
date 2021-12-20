function StageEndScreenGui:bain_debrief_end_callback()
	self._contact_debrief_t = TimerManager:main():time() + 1
end