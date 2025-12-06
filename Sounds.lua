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
    local GetTime = GetTime
    local tinsert = table.insert
    local wipe = table.wipe or wipe
    local bit_band = bit.band
    local string_sub = string.sub
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
        ["DEATHKNIGHT"] = "Trinketed DeathKnight",
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
    -- 0.5 CAST TIME COMPATIBILITY
    -- =========================================================================
    local function GetSpellCastTime(spellID)
        if not spellID then return 0 end
        if C_Spell and C_Spell.GetSpellInfo then
            local info = C_Spell.GetSpellInfo(spellID)
            if info then return info.castTime or 0 end
        else
            local _, _, _, castTime = GetSpellInfo(spellID)
            return castTime or 0
        end
        return 0
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
        
    elseif event == "PLAYER_LEAVING_WORLD" then
        wipe(HEAT.guidToUnit)
        return
    end
    
    -- =========================================================================
    -- 3. TRIGGER LOGIC: UNIT SPELLCAST
    -- =========================================================================
    if event == "UNIT_SPELLCAST_START" or event == "UNIT_SPELLCAST_CHANNEL_START" then
        local unit, _, spellID = ...
        local spellInfo = spellIDMap[event] and spellIDMap[event][spellID]
        if not spellInfo then return end
        
        if event == "UNIT_SPELLCAST_START" then
            local castTime = GetSpellCastTime(spellID)
            if not castTime or castTime == 0 then return end
        end
        
        if HEAT.UpdateUnitCache then HEAT:UpdateUnitCache(unit) end
        
        if unit and UnitExists(unit) then
            local guid = UnitGUID(unit)
            local isEnemy = false
            
            local node = cache.cache[guid]
            if node and node.isEnemy then
                isEnemy = true
                HEAT:MoveToHead(node)
            else
                local unitFlags = HEAT:BuildFlags(unit, guid)
                if HEAT:IsEnemy(guid, unitFlags) then isEnemy = true end
            end
            
            if isEnemy then
                local soundFile = GetSoundFile(spellID, spellInfo.soundFile, guid)
                
                if spellInfo.requireDst then
                    if UnitExists(unit) and UnitGUID(unit .. "target") == playerGUID then
                        HEAT:PlaySound(soundFile, CHANNEL)
                    end
                else
                    HEAT:PlaySound(soundFile, CHANNEL)
                end
            end
        end
        return
    end
    
    -- =========================================================================
    -- 4. TRIGGER LOGIC: COMBAT LOG
    -- =========================================================================
    if event == "COMBAT_LOG_EVENT_UNFILTERED" or (event and string_sub(event, 1, 5) == "CLEU:") then
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