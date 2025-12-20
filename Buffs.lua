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
        
        -- Helper to add valid Names to the whitelist
        local function enableTracking(name)
            if name and type(name) == "string" then
                aura_env.aurasToShow[name] = { enabled = true }
            end
        end
        
        -- Iterate the user config
        -- Expects Spell Names (strings) instead of IDs
        for _, spellName in pairs(spellsTable) do
            enableTracking(spellName)
        end
        
        aura_env.configChanged = false
    end
    
    -- Helper to get live stacks
    local function GetLiveStacks(unit, spellID)
        for i = 1, 40 do
            local _, _, count, _, _, _, _, _, _, id = UnitAura(unit, i, "HELPFUL")
            if not id then break end
            if id == spellID then
                return count
            end
        end
        return 0
    end
    
    -- Pre-calculate active units map (Performance Fix + Replaces missing HEAT function)
    -- This maps GUID -> UnitID (e.g., "Player-123..." -> "nameplate1")
    local activeUnits = {}
    
    -- check target/focus/mouseover first
    if UnitExists("target") then activeUnits[UnitGUID("target")] = "target" end
    if UnitExists("focus") then activeUnits[UnitGUID("focus")] = "focus" end
    if UnitExists("mouseover") then activeUnits[UnitGUID("mouseover")] = "mouseover" end
    
    -- scan nameplates (Optimized)
    local nameplates = C_NamePlate.GetNamePlates()
    if nameplates then
        for _, frame in pairs(nameplates) do
            local unit = frame.namePlateUnitToken
            if unit and UnitExists(unit) then
                activeUnits[UnitGUID(unit)] = unit
            end
        end
    end
    
    -- Iterate all stored buffs to see if they match our tracked names
    for guid, unitBuffs in pairs(storedBuffs) do
        -- Only process if we have a valid unit for this GUID (optimally nameplates)
        -- FIXED: Replaced HEAT:GetUnitIdByGUID call with local map lookup to prevent nil error
        local unit = activeUnits[guid]
        
        if unit then
            for spellID, auraData in pairs(unitBuffs) do
                -- Get the Spell Name from the ID to check against config
                local spellName = GetSpellInfo(spellID)
                
                -- Check against Name instead of ID
                if spellName and aura_env.aurasToShow[spellName] then
                    local remaining = (auraData.expirationTime or 0) - now
                    local duration = auraData.duration or 0
                    
                    -- Filter out expired (unless static/infinite)
                    if (duration == 0) or (remaining > 0) then
                        local key = guid .. spellID .. "buff"
                        
                        -- Update Stacks if unit is available
                        local currentStacks = auraData.stacks
                        if unit then
                            currentStacks = GetLiveStacks(unit, spellID)
                        end
                        
                        -- Generate Custom Text
                        -- 1. If Stacks > 0 (e.g. Thrash 1-3), show Stacks
                        -- 2. Else if Duration is short (< 60s), show Timer
                        local durationText = ""
                        if currentStacks and currentStacks > 0 then
                            durationText = tostring(currentStacks)
                        elseif remaining > 0 and remaining < 60 then
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
                            stacks = currentStacks, -- Passed to %s
                            progressType = "timed",
                            customDurationText = durationText -- Passed to %customDurationText
                        }
                    end
                end
            end
        end
    end
    
    return true
end

