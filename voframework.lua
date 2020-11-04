if not _G.hhvoice then
	_G.hhvoice = {}
	_G.hhvoice.ModPath = ModPath
	blt.xaudio.setup()
    
	log("setting up hyper heisting voicework!")
	
	if _G.voiceline_framework then
		_G.voiceline_framework:register_unit("akuma")
		_G.voiceline_framework:register_line_type("akuma", "buddy_died")
		_G.voiceline_framework:register_line_type("akuma", "contact")
		_G.voiceline_framework:register_line_type("akuma", "kill")
		_G.voiceline_framework:register_line_type("akuma", "death")
		
		for i = 1, 21 do
			_G.voiceline_framework:register_voiceline("akuma", "buddy_died", ModPath .. "assets/voiceovers/true_lotus_master/passive/passive" .. i .. ".ogg")
		end
		
		for i = 1, 15 do
			_G.voiceline_framework:register_voiceline("akuma", "contact", ModPath .. "assets/voiceovers/true_lotus_master/aggro/aggro" .. i .. ".ogg")
		end
		
		for i = 1, 17 do
			_G.voiceline_framework:register_voiceline("akuma", "kill", ModPath .. "assets/voiceovers/true_lotus_master/kill/kill" .. i .. ".ogg")
		end
		
		for i = 1, 3 do
			_G.voiceline_framework:register_voiceline("akuma", "death", ModPath .. "assets/voiceovers/true_lotus_master/death/death" .. i .. ".ogg")
		end

	else
		log("NO VOICELINE FRAMEWORK FOR HYPER HEISTING!? DAMNIT!!!")
	end
end