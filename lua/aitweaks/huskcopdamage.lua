local old_death = HuskCopDamage.die
function HuskCopDamage:die(variant)
    old_death(self, variant)

    if self._unit:base():char_tweak().die_sound_event then
        self._unit:sound():play(self._unit:base():char_tweak().die_sound_event, nil, nil)
    else
        if self._unit:base():char_tweak()["custom_voicework"] then
            local voicelines = _G.voiceline_framework.BufferedSounds[self._unit:base():char_tweak().custom_voicework]
            if voicelines and voicelines["death"] then
                local line_to_use = voicelines.death[math.random(#voicelines.death)]
                self._unit:base():play_voiceline(line_to_use, true)
            end
        end
    end
end