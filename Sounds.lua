--Event: CHAT_MSG_ADDON, NAME_PLATE_UNIT_ADDED, NAME_PLATE_UNIT_REMOVED, PLAYER_TARGET_CHANGED, PLAYER_FOCUS_CHANGED, UPDATE_MOUSEOVER_UNIT, UNIT_TARGET, GROUP_ROSTER_UPDATE, PLAYER_ENTERING_WORLD, PLAYER_LEAVING_WORLD, UNIT_SPELLCAST_START, UNIT_SPELLCAST_CHANNEL_START, ARENA_OPPONENT_UPDATE, CLEU:SPELL_CAST_START, CLEU:SPELL_CAST_SUCCESS, CLEU:SPELL_SUMMON, CLEU:SPELL_AURA_APPLIED, CLEU:SPELL_AURA_REFRESH, CLEU:SPELL_AURA_APPLIED_DOSE, CLEU:SPELL_ABSORBED, CLEU:SPELL_AURA_REMOVED, CLEU:SPELL_AURA_BROKEN, CLEU:SPELL_AURA_BROKEN_SPELL, CLEU:SPELL_AURA_REMOVED_DOSE, CLEU:SPELL_DISPEL, CLEU:SPELL_STOLEN

function(event, ...)
    if not HEAT or not HEAT.initialized then return end
    
    local spellIDMap = HEAT.spellIDMap
    local cache = HEAT.hostilityCache
    if not cache or not spellIDMap or next(spellIDMap) == nil then return end
    
    -- Local upvalues for maximum performance (LuaJIT)
    local CHANNEL = HEAT.CHANNEL
    local playerGUID = HEAT.playerGUID
    local unitCastDelayed = HEAT.unitCastDelayed
    local UnitGUID = UnitGUID
    local UnitExists = UnitExists
    --local wipe = table.wipe or wipe
    local GetPlayerInfoByGUID = GetPlayerInfoByGUID
    
    -- =========================================================================
    -- 0. DYNAMIC SOUND LOGIC (STRATEGY PATTERN)
    -- =========================================================================
    
    -- 1. Define explicit Class -> Sound File mappings (Safety against typos)
    local CLASS_SOUNDS = {
        ["WARRIOR"] = "Trinketed Warrior",
        ["HUNTER"]  = "Trinketed Hunter",
        ["SHAMAN"]  = "Trinketed Shaman",
        ["ROGUE"]   = "Trinketed Rogue",
        ["MAGE"]    = "Trinketed Mage",
        ["PRIEST"]  = "Trinketed Priest",
        ["WARLOCK"] = "Trinketed Warlock",
        ["PALADIN"] = "Trinketed Paladin",
        ["DRUID"]   = "Trinketed Druid",
    }
    
    -- 2. Define specific logic for Shared Spell IDs
    local SPECIAL_HANDLERS = {}
    
    -- Helper for class lookup
    local function GetClassSound(sourceGUID)
        if not sourceGUID then return nil end
        local _, classFilename = GetPlayerInfoByGUID(sourceGUID)
        return classFilename and CLASS_SOUNDS[classFilename]
    end
    
    -- [5579] Insignia of the Horde/Alliance (Warrior, Hunter, Shaman)
    SPECIAL_HANDLERS[5579] = GetClassSound
    
    -- [23273] Insignia of the Horde/Alliance (Rogue, Warlock)
    SPECIAL_HANDLERS[23273] = GetClassSound
    
    -- [23276] Insignia of the Horde/Alliance (Paladin, Priest)
    SPECIAL_HANDLERS[23276] = GetClassSound
    
    -- [NOTE] Druid (23277) and Mage (18850) usually have unique IDs, 
    -- but we can map them here too just to be safe if you want uniform logic.
    SPECIAL_HANDLERS[23277] = GetClassSound
    SPECIAL_HANDLERS[18850] = GetClassSound
    
    -- 3. Resolver Function
    local function GetSoundFile(spellID, defaultSound, sourceGUID)
        local handler = SPECIAL_HANDLERS[spellID]
        if handler then
            local specificSound = handler(sourceGUID)
            if specificSound then return specificSound end
        end
        return defaultSound
    end
    
    -- =========================================================================
    -- 1. INITIALIZATION & HELPERS
    -- =========================================================================
    if not HEAT.cacheInitialized then
        HEAT.cacheInitialized = true
        if HEAT.BuildUnitTokens then
            HEAT:BuildUnitTokens()
        end
    end
    
    -- =========================================================================
    -- 2. CACHE MANAGEMENT EVENTS
    -- =========================================================================
    if event == "NAME_PLATE_UNIT_ADDED" then
        local unit = ...
        if HEAT.UpdateUnitCache then HEAT:UpdateUnitCache(unit) end
        local target = unit .. "target"
        if UnitExists(target) and HEAT.UpdateUnitCache then
            C_Timer.After(0, function() HEAT:UpdateUnitCache(target) end)
        end
        return
        
    elseif event == "NAME_PLATE_UNIT_REMOVED" then
        local unit = ...
        if unit and HEAT.ClearUnitCache then HEAT:ClearUnitCache(unit) end
        return
        
    elseif event == "ARENA_OPPONENT_UPDATE" then
        local unit, updateType = ...
        if updateType == "seen" or updateType == "updated" then
            if HEAT.UpdateUnitCache then HEAT:UpdateUnitCache(unit) end
        elseif updateType == "destroyed" or updateType == "cleared" then
            if HEAT.ClearUnitCache then HEAT:ClearUnitCache(unit) end
        end
        return
        
    elseif event == "PLAYER_TARGET_CHANGED" then
        if HEAT.UpdateUnitCache then HEAT:UpdateUnitCache("target") end
        return
        
    elseif event == "PLAYER_FOCUS_CHANGED" then
        if HEAT.UpdateUnitCache then HEAT:UpdateUnitCache("focus") end
        return
        
    elseif event == "UPDATE_MOUSEOVER_UNIT" then
        if HEAT.UpdateUnitCache then HEAT:UpdateUnitCache("mouseover") end
        return
        
    elseif event == "UNIT_TARGET" then
        local unit = ...
        if HEAT.UpdateUnitCache then HEAT:UpdateUnitCache(unit) end
        return
        
    elseif event == "GROUP_ROSTER_UPDATE" then
        if HEAT.BuildUnitTokens then HEAT:BuildUnitTokens() end
        return
        
    elseif event == "PLAYER_ENTERING_WORLD" then
        local _, instanceType = IsInInstance()
        if instanceType == "arena" then
            for i = 1, 3 do
                C_Timer.After(0, function() 
                        if HEAT.UpdateUnitCache then
                            HEAT:UpdateUnitCache("arena" .. i) 
                            HEAT:UpdateUnitCache("arenapet" .. i) 
                        end
                end)
            end
        end
        if HEAT.BuildUnitTokens then HEAT:BuildUnitTokens() end
        return
        
        --elseif event == "PLAYER_LEAVING_WORLD" then
        --wipe(HEAT.guidToUnit)
        --return
    end
    
    -- =========================================================================
    -- 3. TRIGGER LOGIC: UNIT SPELLCAST
    -- =========================================================================
    if
    event == "UNIT_SPELLCAST_START" or
    event == "UNIT_SPELLCAST_CHANNEL_START" then
        local unit, _, spellID = ...
        if unit and UnitExists(unit) then
            local sourceGUID = UnitGUID(unit)
            if sourceGUID and sourceGUID ~= playerGUID then
                local spellInfo = (spellIDMap[event] and spellIDMap[event][spellID]) 
                local sourceFlags = HEAT:BuildFlags(unit)
                
                if spellInfo and HEAT:IsEnemy(sourceGUID, sourceFlags) then
                    -- Only apply delay logic if the spell requires a destination check
                    if spellInfo.requireDst then
                        -- Check if we've already delayed for this unit's cast start
                        if unitCastDelayed[sourceGUID] then
                            -- Already handled the delay once for this unit, check target immediately
                            -- Re-verify UnitExists
                            --if UnitExists(unit) then
                            if UnitIsUnit(unit .. "target", "player") then
                                HEAT:PlaySound(spellInfo.soundFile, CHANNEL)
                            end
                            --end
                        else
                            -- First time for this unit, use the delay
                            C_Timer.After(0, function()
                                    -- Re-verify UnitExists in case it disappeared during the delay
                                    --if UnitExists(unit) then
                                    -- Check the target *after* the short delay
                                    if UnitIsUnit(unit .. "target", "player") then
                                        HEAT:PlaySound(spellInfo.soundFile, CHANNEL)
                                    end
                                    -- Mark that we've run the delayed check for this unit
                                    unitCastDelayed[sourceGUID] = true
                                    --end
                            end)
                        end
                    else
                        -- Spell does not require destination check, play sound immediately
                        HEAT:PlaySound(spellInfo.soundFile, CHANNEL)
                    end
                end
            end
        end
        return
    end
    
    if event == "UNIT_AURA" then
        local unitID, _, _, _, spellID = ...
        if unitID and UnitExists(unitID) then
            local sourceGUID = UnitGUID(unitID)
            local sourceFlags = HEAT:BuildFlags(unitID)
            -- Check if DESTINATION is enemy
            if sourceGUID and sourceFlags and HEAT:IsEnemy(sourceGUID, sourceFlags) then 
                local spellInfo = (spellIDMap[event] and spellIDMap[event][spellID])
                if spellInfo then HEAT:PlaySound(spellInfo.soundFile, CHANNEL) end
            end
        end
        return
    end
    
    -- =========================================================================
    -- 4. TRIGGER LOGIC: COMBAT LOG
    -- =========================================================================
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local _, subEvent, _, sourceGUID, _, sourceFlags, _, destGUID, _, destFlags, _, spellID, _, _, auraType, extraSpellID = CombatLogGetCurrentEventInfo()
        
        local spellInfo = spellIDMap[subEvent] and spellIDMap[subEvent][spellID]
        
        if subEvent == "SPELL_CAST_START" then
            if not spellID then return end 
            
            if spellInfo and sourceFlags and HEAT:IsEnemy(sourceGUID, sourceFlags) then
                local playSound = true
                
                if spellInfo.requireDst then
                    local unit = HEAT.guidToUnit[sourceGUID]
                    if unit and UnitExists(unit) then
                        if UnitGUID(unit .. "target") ~= playerGUID then playSound = false end
                    else
                        if not destGUID or destGUID ~= playerGUID then playSound = false end
                    end
                end
                
                if playSound then 
                    local soundFile = GetSoundFile(spellID, spellInfo.soundFile, sourceGUID)
                    HEAT:PlaySound(soundFile, CHANNEL) 
                end
            end
            
        elseif
        subEvent == "SPELL_CAST_SUCCESS" or 
        subEvent == "SPELL_SUMMON" then
            
            if spellInfo and sourceFlags and HEAT:IsEnemy(sourceGUID, sourceFlags) then
                if spellInfo.requireDst and destGUID ~= playerGUID then return end
                
                local soundFile = GetSoundFile(spellID, spellInfo.soundFile, sourceGUID)
                HEAT:PlaySound(soundFile, CHANNEL) 
            end
            
        elseif
        subEvent == "SPELL_AURA_APPLIED" or
        subEvent == "SPELL_AURA_REFRESH" or
        subEvent == "SPELL_AURA_APPLIED_DOSE" or
        subEvent == "SPELL_ABSORBED" then
            
            if spellInfo then
                if sourceFlags and HEAT:IsEnemy(sourceGUID, sourceFlags) then
                    if spellInfo.requireDst and destGUID ~= playerGUID then return end
                    
                    local soundFile = GetSoundFile(spellID, spellInfo.soundFile, sourceGUID)
                    HEAT:PlaySound(soundFile, CHANNEL)
                    
                elseif destFlags and HEAT:IsEnemy(destGUID, destFlags) then
                    if sourceFlags and HEAT:IsEnemy(sourceGUID, sourceFlags) then
                        local soundFile = GetSoundFile(spellID, spellInfo.soundFile, sourceGUID)
                        HEAT:PlaySound(soundFile, CHANNEL)
                    end
                end
            end
            
        elseif
        subEvent == "SPELL_AURA_REMOVED" or
        subEvent == "SPELL_AURA_BROKEN" or
        subEvent == "SPELL_AURA_BROKEN_SPELL" or
        subEvent == "SPELL_AURA_REMOVED_DOSE" or
        subEvent == "SPELL_DISPEL" or 
        subEvent == "SPELL_STOLEN" then
            
            local id = spellID
            if (subEvent == "SPELL_DISPEL" or subEvent == "SPELL_STOLEN") and extraSpellID then
                id = extraSpellID
                spellInfo = spellIDMap["SPELL_AURA_REMOVED"] and spellIDMap["SPELL_AURA_REMOVED"][id]
            end
            
            if spellInfo and destFlags and HEAT:IsEnemy(destGUID, destFlags) then
                if sourceFlags and HEAT:IsEnemy(sourceGUID, sourceFlags) then
                    local soundFile = GetSoundFile(id, spellInfo.soundFile, sourceGUID)
                    HEAT:PlaySound(soundFile, CHANNEL)
                end
            end
        end
    end
end

