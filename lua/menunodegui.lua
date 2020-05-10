--key is the global (_G) table value of the mod in question
--value is the localized name of that mod to display to the user
local warned_mods = {
    ["BB"] = "Better Bots",
    ["FullSpeedSwarm"] = "Full Speed Swarm",
    ["Iter"] = "Iter",
    ["SC"] = "Restoration",
    ["deathvox"] = "Crackdown"
}

Hooks:PostHook(MenuNodeGui,"_setup_item_rows","shin_mememode_safety_notif",function(self,node,...)
    local title = "HYPER HEISTING MEME MODE SAFETY FEATURE ACTIVATED"
    local desc = "Caution! You have the following AI-changing mods installed, which may conflict with Hyper Heisting:\n"
    local has_any
    for key,mod_name in pairs(warned_mods) do 
        if rawget(_G,key) then 
            has_any = true
            desc = desc .. "\n" .. mod_name
        end
    end
	
    if has_any then 
        QuickMenu:new(
            title,
            desc,
            {
                {
                    text = "ok fine mom GOD",
                    is_cancel_button = true
                }
            }
        ,true)
    end
end)