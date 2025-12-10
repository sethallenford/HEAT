--Events: PLAYER_TARGET_CHANGED, UNIT_AURA, NAME_PLATE_UNIT_ADDED, CHAT_MSG_ADDON, CLEU:SPELL_AURA_APPLIED, CLEU:SPELL_AURA_REMOVED, CLEU:SPELL_AURA_REFRESH, CLEU:SPELL_AURA_APPLIED_DOSE, CLEU:SPELL_AURA_REMOVED_DOSE, CLEU:SPELL_AURA_BROKEN, CLEU:SPELL_AURA_BROKEN_SPELL, CLEU:SPELL_DISPEL, CLEU:SPELL_STOLEN, CLEU:UNIT_DIED, CLEU:SPELL_CAST_SUCCESS

function(states, event, ...)
    if not HEAT or not HEAT.initialized then return end
    
    -- PRE-FILTER: STRICTLY ignore mouseover events in this specific aura
    if event == "UPDATE_MOUSEOVER_UNIT" then return false end
    
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, subEvent, _, sourceGUID, _, sourceFlags, _, _, _, _, _, spellID = CombatLogGetCurrentEventInfo()
        
        if subEvent == "SPELL_CAST_SUCCESS" and sourceGUID and HEAT:IsEnemy(sourceGUID, sourceFlags) then
            local now = GetTime()
            
            -- A. WARRIOR STANCE INFERENCE
            local newStance = nil
            if spellID == 100 or spellID == 6178 or spellID == 11578 then newStance = 2457 -- Charge -> Battle
            elseif spellID == 20252 or spellID == 20616 or spellID == 20617 then newStance = 2458 -- Intercept -> Berserker
            end
            
            if newStance then
                if not HEAT.storedBuffs[sourceGUID] then HEAT.storedBuffs[sourceGUID] = {} end
                local stances = { [2457]=true, [2458]=true, [71]=true }
                for sID in pairs(stances) do if sID ~= newStance then HEAT.storedBuffs[sourceGUID][sID] = nil end end
                local _, _, icon = GetSpellInfo(newStance)
                HEAT.storedBuffs[sourceGUID][newStance] = { destGUID = sourceGUID, spellID = newStance, icon = icon, duration = -1, expirationTime = nil, startTime = now }
                
                -- B. GENERIC STATIC BUFF INFERENCE (MOUNTS)
            elseif HEAT.spellData and HEAT.spellData[spellID] == -1 then
                if not HEAT.storedBuffs[sourceGUID] then HEAT.storedBuffs[sourceGUID] = {} end
                if not HEAT.storedBuffs[sourceGUID][spellID] then
                    local _, _, icon = GetSpellInfo(spellID)
                    HEAT.storedBuffs[sourceGUID][spellID] = { destGUID = sourceGUID, spellID = spellID, icon = icon, duration = -1, expirationTime = nil, startTime = now }
                end
            end
        end
    end
    
    -- 2. DISPLAY OPTIMIZATION (Prevent lag)
    local unit = "target"
    local targetGUID = UnitExists(unit) and UnitGUID(unit) or nil
    
    if not targetGUID then
        for k in pairs(states) do states[k] = nil end
        return true
    end
    
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
    local INFINITY = -1
    for k in pairs(states) do states[k] = nil end
    local unitBuffs = storedBuffs[targetGUID]
    
    if unitBuffs then
        for spellID, buffData in pairs(unitBuffs) do
            local isStatic = (not buffData.duration or buffData.duration == 0 or buffData.duration == INFINITY) 
            if isStatic then
                local key = buffData.destGUID .. buffData.spellID .. "static"
                states[key] = {
                    show = true, changed = true, autoHide = true,
                    icon = buffData.icon, destGUID = buffData.destGUID, unit = unit,
                    expirationTime = nil, duration = nil, spellID = buffData.spellID, progressType = "static"
                }
            end
        end
    end
    
    return true
end

