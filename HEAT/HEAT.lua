-- Shared functions and client data are loaded first by HEAT.toc.

-- Global frame for event handling
local HeatFrame = CreateFrame("Frame")
HEAT.frame = HeatFrame

-- Register all necessary events once at load time
HeatFrame:RegisterEvent("ADDON_LOADED")
HeatFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
HeatFrame:RegisterEvent("ARENA_OPPONENT_UPDATE")
HeatFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
HeatFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
HeatFrame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
HeatFrame:RegisterEvent("NAME_PLATE_UNIT_ADDED")
HeatFrame:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
HeatFrame:RegisterEvent("PLAYER_FOCUS_CHANGED")
HeatFrame:RegisterEvent("UNIT_FLAGS")
HeatFrame:RegisterEvent("UNIT_FACTION")
HeatFrame:RegisterEvent("UNIT_AURA")
HeatFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
HeatFrame:RegisterEvent("CHAT_MSG_ADDON")

-- Main event handler
HeatFrame:SetScript("OnEvent", function(self, event, ...)
    local arg1 = ...

    -- 1. Handle Initialization
    if event == "ADDON_LOADED" and arg1 == "HEAT" then
        HEAT:Init()
    elseif event == "PLAYER_ENTERING_WORLD" then
        HEAT:Init()
        if HEAT.ProcessHostilityEvent then
            HEAT:ProcessHostilityEvent(event, ...)
        end

    -- 2. Pass Events to the Hostility Processor
    elseif HEAT.ProcessHostilityEvent then
        HEAT:ProcessHostilityEvent(event, ...)
    end
end)

HEAT:Init()
