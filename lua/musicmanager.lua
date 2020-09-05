-- CREDIT: TEST1
Hooks:PostHook(MusicManager, "jukebox_heist_specific", "HH_MusicManagerJukeBoxHeistSpecific", function(self)
	
    if not Global.music_manager.track_attachment.flat_hh then
        Global.music_manager.track_attachment.flat_hh = "track_47_gen"
    end
	
    if not Global.music_manager.track_attachment.wwh_hh then
        Global.music_manager.track_attachment.wwh_hh = "track_54"
    end
	
    if not Global.music_manager.track_attachment.nmh_hyper then
        Global.music_manager.track_attachment.nmh_hyper = "track_63"
    end
    
    -- local job_data = Global.job_manager.current_job
	
    if managers.job:current_level_id() == "flat_hh" then
        return self:track_attachment("flat_hh") or "all"
    end

    if managers.job:current_level_id() == "wwh_hh" then
        return self:track_attachment("wwh_hh") or "all"
    end	
	
    if managers.job:current_level_id() == "nmh_hyper" then
        return self:track_attachment("nmh_hyper") or "all"
    end
end)
