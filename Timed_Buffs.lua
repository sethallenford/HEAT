--Events: PLAYER_TARGET_CHANGED, UNIT_AURA, NAME_PLATE_UNIT_ADDED, CHAT_MSG_ADDON, CLEU:SPELL_AURA_APPLIED, CLEU:SPELL_AURA_REMOVED, CLEU:SPELL_AURA_REFRESH, CLEU:SPELL_AURA_APPLIED_DOSE, CLEU:SPELL_AURA_REMOVED_DOSE, CLEU:SPELL_AURA_BROKEN, CLEU:SPELL_AURA_BROKEN_SPELL, CLEU:SPELL_DISPEL, CLEU:SPELL_STOLEN, CLEU:UNIT_DIED, CLEU:SPELL_CAST_SUCCESS

function(states, event, ...)
    if not HEAT or not HEAT.initialized then return end
    
    -- PRE-FILTER: STRICTLY ignore mouseover events in this specific aura
    if event == "UPDATE_MOUSEOVER_UNIT" then return false end
    
    -- 1. DATA PROCESSING
    local unit = "target"
    local targetGUID = UnitExists(unit) and UnitGUID(unit) or nil
    
    if not targetGUID then
        for k in pairs(states) do states[k] = nil end
        return true
    end
    
    -- 2. DISPLAY OPTIMIZATION (Target Relevance Check)
    local isRelevant = false
    
    if event == "PLAYER_TARGET_CHANGED" then
        isRelevant = true
        if HEAT.ProcessHostilityEvent then HEAT:ProcessHostilityEvent(event, ...) end
        
    elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, _, _, sourceGUID, _, _, _, destGUID = CombatLogGetCurrentEventInfo()
        if sourceGUID == targetGUID or destGUID == targetGUID then
            isRelevant = true
            if HEAT.ProcessHostilityEvent then HEAT:ProcessHostilityEvent(event, ...) end
        end
        
    elseif event == "UNIT_AURA" then
        local unitId = ...
        if unitId == "target" then 
            isRelevant = true 
            if HEAT.ProcessHostilityEvent then HEAT:ProcessHostilityEvent(event, ...) end
        end
        
    elseif event == "CHAT_MSG_ADDON" then
        local _, msg = ...
        if msg and string.find(msg, targetGUID, 1, true) then 
            isRelevant = true
            if HEAT.ProcessHostilityEvent then HEAT:ProcessHostilityEvent(event, ...) end
        end
        
    elseif event == "NAME_PLATE_UNIT_ADDED" then
        local unitId = ...
        if UnitGUID(unitId) == targetGUID then 
            isRelevant = true 
            if HEAT.ProcessHostilityEvent then HEAT:ProcessHostilityEvent(event, ...) end
        end
    else
        isRelevant = true
    end
    
    if not isRelevant then return false end
    
    -- 3. BUILD DISPLAY
    local storedBuffs = HEAT.storedBuffs
    local now = GetTime()
    local INFINITY = -1
    
    -- Clear old states
    for k in pairs(states) do states[k] = nil end
    
    local unitBuffs = storedBuffs[targetGUID]
    
    if unitBuffs then
        -- Iterate Key/Value pairs (SpellID / Data)
        for spellID, buffData in pairs(unitBuffs) do
            
            -- Determine if buff is timed (has finite duration and expiration)
            local isTimed = buffData.duration and buffData.duration > 0 and buffData.duration ~= INFINITY and buffData.expirationTime and buffData.expirationTime > 0
            
            if isTimed then
                -- Check for expiration (cleanup fallback)
                if buffData.expirationTime > now then
                    -- Create unique key
                    local key = buffData.destGUID .. buffData.spellID .. "timed"
                    
                    -- Create WA state object
                    local state = {
                        show = true,
                        changed = true,
                        autoHide = true,
                        icon = buffData.icon,
                        destGUID = buffData.destGUID,
                        unit = unit,
                        expirationTime = buffData.expirationTime,
                        duration = buffData.duration,
                        spellID = buffData.spellID,
                        progressType = "timed"
                    }
                    
                    states[key] = state
                end
            end
        end
    end
    
    return true
end

