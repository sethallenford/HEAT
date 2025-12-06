--Events: NAME_PLATE_UNIT_ADDED, NAME_PLATE_UNIT_REMOVED, UNIT_AURA, CHAT_MSG_ADDON, CLEU:SPELL_AURA_APPLIED, CLEU:SPELL_AURA_REMOVED, CLEU:SPELL_AURA_REFRESH, CLEU:SPELL_AURA_APPLIED_DOSE, CLEU:SPELL_AURA_REMOVED_DOSE, CLEU:SPELL_AURA_BROKEN, CLEU:SPELL_AURA_BROKEN_SPELL, CLEU:SPELL_DISPEL, CLEU:SPELL_STOLEN, CLEU:UNIT_DIED
function(states, event, ...)
    if not HEAT or not HEAT.initialized then return end
    
    -- Sync incoming events to core
    if HEAT.ProcessHostilityEvent then
        HEAT:ProcessHostilityEvent(event, ...)
    end
    
    local storedBuffs = HEAT.storedBuffs
    local now = GetTime()
    local INFINITY = -1
    
    if not storedBuffs then return false end
    
    -- Config parsing
    if aura_env.aurasToShow == nil or aura_env.configChanged then
        aura_env.aurasToShow = {}
        local spellsTable = aura_env.config.spellsToTrack or {}
        for _, spellEntry in ipairs(spellsTable) do
            if spellEntry.spellID then
                aura_env.aurasToShow[tonumber(spellEntry.spellID)] = {
                    enabled = spellEntry.enabled == nil or spellEntry.enabled
                }
            end
        end
        aura_env.configChanged = false
    end
    
    local aurasToShow = aura_env.aurasToShow
    if not next(aurasToShow) then return false end
    
    -- Cleanup dead/removed units
    if event == "NAME_PLATE_UNIT_REMOVED" then
        local unit = ...
        local guid = UnitGUID(unit)
        if guid then
            for k, v in pairs(states) do
                if v.destGUID == guid then states[k] = nil end
            end
        end
        return true
    elseif event == "UNIT_DIED" or event == "UNIT_DESTROYED" then
        local _, _, _, _, _, _, _, destGUID = CombatLogGetCurrentEventInfo()
        if destGUID then
            for k, v in pairs(states) do
                if v.destGUID == destGUID then states[k] = nil end
            end
        end
        return true
    end
    
    -- Clear old states
    for k in pairs(states) do states[k] = nil end
    
    -- Rebuild states from HEAT Storage
    for i = 1, 40 do
        local unit = "nameplate" .. i
        if UnitExists(unit) then
            local guid = UnitGUID(unit)
            if guid and storedBuffs[guid] then
                
                for spellID, auraData in pairs(storedBuffs[guid]) do
                    -- Filter: Must be in config and enabled
                    local configEntry = aurasToShow[spellID]
                    
                    if configEntry and configEntry.enabled then
                        -- Check Expiration (Visual cleanup for things that fell off naturally)
                        local isExpired = false
                        if auraData.expirationTime and auraData.expirationTime > 0 and auraData.expirationTime < now then
                            isExpired = true
                        end
                        
                        if not isExpired then
                            local key = guid .. spellID
                            local remaining = (auraData.expirationTime and auraData.expirationTime > 0) and (auraData.expirationTime - now) or 0
                            
                            local durationText = ""
                            if remaining > 0 and remaining < 60 then
                                durationText = tostring(math.floor(remaining))
                            end
                            
                            states[key] = {
                                show = true,
                                changed = true,
                                icon = auraData.icon,
                                destGUID = guid,
                                unit = unit,
                                expirationTime = auraData.expirationTime,
                                duration = auraData.duration,
                                spellID = spellID,
                                progressType = "timed",
                                customDurationText = durationText
                            }
                        end
                    end
                end
            end
        end
    end
    
    return true
end

