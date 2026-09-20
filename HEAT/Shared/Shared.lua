HEAT = HEAT or { initialized = false }

local UnitGUID = UnitGUID
local UnitName = UnitName
local UnitExists = UnitExists
local UnitCanAttack = UnitCanAttack
local UnitIsEnemy = UnitIsEnemy
local UnitIsFriend = UnitIsFriend
local UnitIsUnit = UnitIsUnit
local UnitPlayerControlled = UnitPlayerControlled
local UnitInParty = UnitInParty
local UnitInRaid = UnitInRaid
local UnitIsPlayer = UnitIsPlayer
local UnitAura = UnitAura
local GetTime = GetTime
local PlaySoundFile = PlaySoundFile
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local IsInGroup = IsInGroup
local IsInRaid = IsInRaid
local IsInInstance = IsInInstance
local pairs, ipairs, next, type, tonumber, select, string, table = pairs, ipairs, next, type, tonumber, select, string, table
local wipe = wipe
local bit_band, bit_bor = bit.band, bit.bor

local nodePool = {}

local WARRIOR_STANCE_TRIGGERS = {
    [100] = 2457,    -- Charge (Rank 1) -> Battle Stance
    [6178] = 2457,   -- Charge (Rank 2) -> Battle Stance
    [11578] = 2457,  -- Charge (Rank 3) -> Battle Stance
    [20252] = 2458,  -- Intercept (Rank 1) -> Berserker Stance
    [20616] = 2458,  -- Intercept (Rank 2) -> Berserker Stance
    [20617] = 2458,  -- Intercept (Rank 3) -> Berserker Stance
    [7384] = 2457,   -- Overpower (Rank 1) -> Battle Stance
    [7887] = 2457,   -- Overpower (Rank 2) -> Battle Stance
    [11584] = 2457,  -- Overpower (Rank 3) -> Battle Stance
    [11585] = 2457,  -- Overpower (Rank 4) -> Battle Stance
    [6552] = 2458,   -- Pummel (Rank 1) -> Berserker Stance
    [6554] = 2458,   -- Pummel (Rank 2) -> Berserker Stance
    [1680] = 2458,   -- Whirlwind -> Berserker Stance
    [18499] = 2458,  -- Berserker Rage -> Berserker Stance
    [355] = 71,      -- Taunt -> Defensive Stance
    [676] = 71,      -- Disarm -> Defensive Stance
    [6572] = 71,     -- Revenge -> Defensive Stance
    [2565] = 71,     -- Shield Block -> Defensive Stance
    [871] = 71,      -- Shield Wall -> Defensive Stance
}

if not wipe then
    wipe = function(t)
        for k in pairs(t) do
            t[k] = nil
        end
        return t
    end
end

local function BuildBuffLookup(buffTable)
    if not buffTable then return nil, "" end

    local lookup = {}
    local signature = {}
    for k, v in pairs(buffTable) do
        if type(k) == "string" or type(k) == "number" then
            lookup[k] = true
            signature[#signature + 1] = type(k) .. ":" .. tostring(k)
        end
        if type(v) == "string" or type(v) == "number" then
            lookup[v] = true
            signature[#signature + 1] = type(v) .. ":" .. tostring(v)
        end
    end

    table.sort(signature)
    return next(lookup) and lookup or nil, table.concat(signature, "\001")
end

local function TrackBuffLookup(buffLookup)
    if not (buffLookup and HEAT and HEAT.AuraInfo and HEAT.trackedAuraIDs) then return end

    for id, auraInfo in pairs(HEAT.AuraInfo) do
        if buffLookup[id] or (auraInfo.name and buffLookup[auraInfo.name]) then
            HEAT.trackedAuraIDs[id] = true
        end
    end
end

function HEAT:Init()
    if HEAT.initialized then return end

    local MAXSIZE = 100

    HEAT = HEAT or {}

    HEAT.debug = false

    -- Always reset these (Runtime Caches)
    HEAT.spellData = {}
    HEAT.storedBuffs = {}
    HEAT.spellIDMap = {}
    HEAT.trackedAuraIDs = {}
    HEAT.AuraInfo = {}
    HEAT.unitCastDelayed = {}
    HEAT.guidToUnit = {}
    HEAT.unitToGuid = {}
    HEAT.unitTokens = {}
    HEAT.scanUnitTokens = {}
    HEAT.scanFoundSpells = {}
    HEAT.soundPathCache = {}
    HEAT.hostilityCache = { cache = {}, head = nil, tail = nil, size = 0, maxSize = MAXSIZE }

    -- Setup Constants
    HEAT.playerGUID = UnitGUID("player")
    HEAT.SOUND_PREFIX = "Interface\\AddOns\\HEAT\\Sounds\\"
    HEAT.CHANNEL = "Master"
    HEAT.fileExtension = ".ogg"
    HEAT.prefix = "HEAT"

    -- Register Prefix safely
    if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then
        C_ChatInfo.RegisterAddonMessagePrefix(HEAT.prefix)
    else
        RegisterAddonMessagePrefix(HEAT.prefix)
    end

    HEAT.unitTokens = { "playerpet", "target", "focus", "mouseover" }
    for i = 1, 5 do table.insert(HEAT.unitTokens, "boss"..i) end
    for i = 1, 5 do table.insert(HEAT.unitTokens, "arena"..i) end
    for i = 1, 5 do table.insert(HEAT.unitTokens, "arenapet"..i) end
    for i = 1, 40 do table.insert(HEAT.unitTokens, "nameplate"..i) end
    for i = 1, 4 do table.insert(HEAT.unitTokens, "party"..i) end
    for i = 1, 4 do table.insert(HEAT.unitTokens, "partypet"..i) end
    for i = 1, 40 do table.insert(HEAT.unitTokens, "raid"..i) end
    for i = 1, 40 do table.insert(HEAT.unitTokens, "raidpet"..i) end

    HEAT.scanUnitTokens = { "target", "focus", "mouseover" }
    for i = 1, 5 do table.insert(HEAT.scanUnitTokens, "boss"..i) end
    for i = 1, 5 do table.insert(HEAT.scanUnitTokens, "arena"..i) end
    for i = 1, 5 do table.insert(HEAT.scanUnitTokens, "arenapet"..i) end
    for i = 1, 40 do table.insert(HEAT.scanUnitTokens, "nameplate"..i) end

    HEAT.FLAGS = {
        PLAYER = COMBATLOG_OBJECT_TYPE_PLAYER or 0x00000400,
        NPC = COMBATLOG_OBJECT_TYPE_NPC or 0x00000800,
        PET = COMBATLOG_OBJECT_TYPE_PET or 0x00002000,
        GUARDIAN = COMBATLOG_OBJECT_TYPE_GUARDIAN or 0x00004000,
        CONTROL_PLAYER = COMBATLOG_OBJECT_CONTROL_PLAYER or 0x00000100,
        REACTION_FRIENDLY = COMBATLOG_OBJECT_REACTION_FRIENDLY or 0x00000010,
        REACTION_NEUTRAL  = COMBATLOG_OBJECT_REACTION_NEUTRAL  or 0x00000020,
        REACTION_HOSTILE  = COMBATLOG_OBJECT_REACTION_HOSTILE  or 0x00000040,
        AFFILIATION_OUTSIDER = COMBATLOG_OBJECT_AFFILIATION_OUTSIDER or 0x00000008
    };

    local rawSpellData, defaultBuffs, defaultSounds = HEAT:LoadStaticData()

    if not HEAT.soundTable or not next(HEAT.soundTable) then
        HEAT.soundTable = defaultSounds or {}
    end

    -- Process Sound Tables
    if HEAT.soundTable["SPELL_AURA_APPLIED"] and not HEAT.soundTable["UNIT_AURA"] then
        --HEAT.soundTable["SPELL_AURA_REFRESH"] = HEAT.soundTable["SPELL_AURA_APPLIED"]
        HEAT.soundTable["UNIT_AURA"] = HEAT.soundTable["SPELL_AURA_APPLIED"]
    end

    if HEAT.soundTable["SPELL_CAST_START"] then
        HEAT.soundTable["UNIT_SPELLCAST_START"] = HEAT.soundTable["SPELL_CAST_START"]
        HEAT.soundTable["UNIT_SPELLCAST_CHANNEL_START"] = HEAT.soundTable["SPELL_CAST_START"]
        --HEAT.soundTable["UNIT_SPELLCAST_CHANNEL_STOP"] = HEAT.soundTable["SPELL_CAST_START"]
    end

    if HEAT.soundTable["SPELL_CAST_SUCCESS"] then
        HEAT.soundTable["UNIT_SPELLCAST_SUCCEEDED"] = HEAT.soundTable["SPELL_CAST_SUCCESS"]
    end

    if not HEAT.nameplateBuffs or not next(HEAT.nameplateBuffs) then
        HEAT.nameplateBuffs = {}
        if defaultBuffs then
            for _, name in ipairs(defaultBuffs) do
                HEAT.nameplateBuffs[name] = true
            end
        end
    end

    if rawSpellData and rawSpellData ~= "" then
        local spellCount = 0
        local chunk = rawSpellData .. "^"

        for name, info in chunk:gmatch("(.-)~([^^]+)^") do
            name = name:gsub("[\n\r]", "")
            if name and name ~= "" then
                HEAT.spellData[name] = info

                for entry in string.gmatch(info, "([^,]+)") do
                    local sID, sIcon, sDur = string.match(entry, "(%d+)=(%d+)=([%d%-]+)")
                    if sID then
                        local id = tonumber(sID)
                        local icon = tonumber(sIcon)
                        local dur = tonumber(sDur)

                        HEAT.AuraInfo[id] = {
                            spellID = id,
                            icon = icon,
                            name = name,
                            duration = dur
                        }
                        spellCount = spellCount + 1
                    end
                end
            end
        end

        rawSpellData = nil -- clear memory
        if HEAT.RefreshTrackedBuffs then
            HEAT:RefreshTrackedBuffs(true)
        end
        print(string.format("|cFFFFD700H|r |cFFFF8C00E|r |cFFFF4500A|r |cFFFF0000T|r Successfully built and cached |cFF00FF00%d|r spells.", spellCount))
    end

    if HEAT.soundTable then
        for eventType, eventSpells in pairs(HEAT.soundTable) do
            HEAT.spellIDMap[eventType] = {}
            for key, data in pairs(eventSpells) do
                -- We now support using the Key as the sound filename (e.g. ["Feign Death"] = {...})
                -- Or finding it at index 1 (legacy support)
                if type(data) == "table" then
                    local soundFile
                    if type(data[1]) == "string" then
                        soundFile = data[1]
                    elseif type(key) == "string" then
                        soundFile = key
                    end
                    if soundFile then
                        local soundPath = HEAT.SOUND_PREFIX .. soundFile .. HEAT.fileExtension
                        HEAT.soundPathCache[soundFile] = soundPath
                        for id, requireDst in pairs(data) do
                            if type(id) == "number" and id ~= 1 then
                                HEAT.spellIDMap[eventType][id] = { soundFile = soundFile, soundPath = soundPath, requireDst = requireDst }
                                if eventType == "UNIT_AURA"
                                    or eventType == "SPELL_AURA_APPLIED"
                                    or eventType == "SPELL_AURA_REFRESH"
                                    or eventType == "SPELL_AURA_APPLIED_DOSE"
                                    or eventType == "SPELL_AURA_REMOVED"
                                    or eventType == "SPELL_AURA_BROKEN"
                                    or eventType == "SPELL_AURA_BROKEN_SPELL"
                                    or eventType == "SPELL_AURA_REMOVED_DOSE" then
                                    HEAT.trackedAuraIDs[id] = true
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    HEAT.trackedAuraIDs[71] = true
    HEAT.trackedAuraIDs[2457] = true
    HEAT.trackedAuraIDs[2458] = true

    HEAT.initialized = true
    print("HEAT Initialized.")
end

----------------------------------------------------------------------------
-- FUNCTION DEFINITIONS
----------------------------------------------------------------------------
function HEAT:SendMessage(message)
    if IsInGroup() then
        local msg = ("%s#"):format(message)
        local channel = "PARTY"
        if IsInGroup(LE_PARTY_CATEGORY_INSTANCE) and IsInInstance() then
            channel = "INSTANCE_CHAT"
        elseif IsInRaid() then
            channel = "RAID"
        end

        if channel and msg then
            if C_ChatInfo and C_ChatInfo.SendAddonMessage then
                C_ChatInfo.SendAddonMessage(HEAT.prefix, msg, channel)
            elseif SendAddonMessage then
                SendAddonMessage(HEAT.prefix, msg, channel)
            end
        end
    end
end

function HEAT:PlaySound(file, channel)
    if not file then return end
    local soundPath = self.soundPathCache and self.soundPathCache[file]
    if not soundPath then
        soundPath = self.SOUND_PREFIX .. file .. self.fileExtension
        if self.soundPathCache then
            self.soundPathCache[file] = soundPath
        end
    end
    local soundChannel = channel or self.CHANNEL
    if soundChannel then PlaySoundFile(soundPath, soundChannel) end
end

function HEAT:RemoveNode(node)
    if not node or not self.hostilityCache then return end

    if node.prev then
        node.prev.next = node.next
    else
        self.hostilityCache.head = node.next
    end

    if node.next then
        node.next.prev = node.prev
    else
        self.hostilityCache.tail = node.prev
    end

    -- Cleanup Data associated with this GUID to prevent leaks
    if node.guid then
        if self.debug then
            print(string.format("|cFF00FFFFHEAT Debug:|r Evicting node %s. Cache Size: %d", node.guid, self.hostilityCache.size - 1))
        end

        self.hostilityCache.cache[node.guid] = nil
        self.storedBuffs[node.guid] = nil
        self.unitCastDelayed[node.guid] = nil
    end

    -- Safety: Ensure node links are broken and recycle to nodePool (zero GC allocations)
    node.guid = nil
    node.next = nil
    node.prev = nil

    if self.hostilityCache.size > 0 then
        self.hostilityCache.size = self.hostilityCache.size - 1
    end

    nodePool[#nodePool + 1] = node
end

function HEAT:MoveToHead(node)
    if not node or not self.hostilityCache or node == self.hostilityCache.head then return end

    if node.prev then node.prev.next = node.next end
    if node.next then node.next.prev = node.prev end

    if self.hostilityCache.tail == node then
        self.hostilityCache.tail = node.prev
    end

    node.prev = nil
    node.next = self.hostilityCache.head

    if self.hostilityCache.head then
        self.hostilityCache.head.prev = node
    end
    self.hostilityCache.head = node
end

function HEAT:AddNode(guid)
    if not guid or not self.hostilityCache then return end

    local limit = self.hostilityCache.maxSize or 100

    -- Enforce LRU Limit
    if limit ~= math.huge and self.hostilityCache.size >= limit then
        local tail = self.hostilityCache.tail
        if tail then
            if self.debug then
                print("|cFF00FFFFHEAT Debug:|r Cache Limit Reached. Evicting Tail.")
            end
            self:RemoveNode(tail)
        end
    end

    -- Reuse existing node from pool or allocate only if empty
    local node = table.remove(nodePool)
    if node then
        node.guid = guid
        node.isEnemy = true
        node.prev = nil
        node.next = self.hostilityCache.head
    else
        node = { guid = guid, isEnemy = true, prev = nil, next = self.hostilityCache.head }
    end

    if self.hostilityCache.head then
        self.hostilityCache.head.prev = node
    end
    self.hostilityCache.head = node

    if not self.hostilityCache.tail then
        self.hostilityCache.tail = node
    end

    self.hostilityCache.cache[guid] = node
    self.hostilityCache.size = self.hostilityCache.size + 1

    if self.debug then
        print(string.format("|cFF00FFFFHEAT Debug:|r Added node %s. New Size: %d", guid, self.hostilityCache.size))
    end
end

function HEAT:IsEnemy(guid, unitFlags)
    if guid == self.playerGUID then return false end
    if not guid or not unitFlags then return false end

    -- Check hostility bitmask
    local isHostile = (bit_band(unitFlags, self.FLAGS.REACTION_HOSTILE) > 0)

    -- Only interact with the cache if the unit is hostile
    if isHostile then
        local node = self.hostilityCache.cache[guid]
        if node then
            self:MoveToHead(node)
        else
            self:AddNode(guid)
        end
    end

    return isHostile
end

function HEAT:BuildFlags(unit, guid)
    if not unit or not UnitExists(unit) then return 0 end
    local unitGUID = guid or UnitGUID(unit)
    if not unitGUID then return 0 end

    local flags = 0

    if (UnitCanAttack and UnitCanAttack("player", unit)) or UnitIsEnemy("player", unit) then
        flags = self.FLAGS.REACTION_HOSTILE
    elseif UnitIsFriend("player", unit) then
        flags = self.FLAGS.REACTION_FRIENDLY
    else
        flags = self.FLAGS.REACTION_NEUTRAL
    end

    if UnitIsPlayer(unit) then
        flags = bit_bor(flags, self.FLAGS.PLAYER)
    elseif UnitPlayerControlled(unit) then
        flags = bit_bor(flags, self.FLAGS.PET)
    else
        flags = bit_bor(flags, self.FLAGS.NPC)
    end

    if UnitPlayerControlled(unit) then flags = bit_bor(flags, self.FLAGS.CONTROL_PLAYER) end

    local isMine = UnitIsUnit(unit, "player") or UnitIsUnit(unit, "pet") or UnitIsUnit(unit, "vehicle")
    local isInGroup = UnitInParty(unit) or UnitInRaid(unit)

    if not isMine and not isInGroup then
        flags = bit_bor(flags, self.FLAGS.AFFILIATION_OUTSIDER)
    end
    return flags
end

function HEAT:UpdateUnitHostility(unit, guid)
    if not UnitExists(unit) then return 0, false end
    local unitGUID = guid or UnitGUID(unit)
    if not unitGUID then return 0, false end

    local flags = self:BuildFlags(unit, unitGUID)
    local isHostile = self:IsEnemy(unitGUID, flags)
    return flags, isHostile
end

function HEAT:UpdateUnitCache(unit)
    if not unit then return end
    local guid = UnitGUID(unit)

    if guid then
        -- Ensure tables exist
        if not self.guidToUnit then self.guidToUnit = {} end
        if not self.unitToGuid then self.unitToGuid = {} end

        -- Safe Cleanup:
        -- Only remove the reverse mapping if it currently points to the unit we are updating.
        -- This prevents 'target' update from wiping 'mouseover' if they are different units.
        local oldGuid = self.unitToGuid[unit]
        if oldGuid and oldGuid ~= guid then
            if self.guidToUnit[oldGuid] == unit then
                self.guidToUnit[oldGuid] = nil
            end

            -- Remove old GUID from hostility cache if it's no longer tracked by any unit token?
            -- (Optional: Keeping it in cache is usually safer for LRU history, so we skip explicit removal here)
        end

        self.guidToUnit[guid] = unit
        self.unitToGuid[unit] = guid
    end
end

-- Cleans up the cache when a unit is removed (e.g. nameplate hidden)
function HEAT:ClearUnitCache(unit)
    if not unit then return end

    if self.unitToGuid and self.unitToGuid[unit] then
        local guid = self.unitToGuid[unit]

        -- Only clear the forward lookup if it matches the unit
        if self.guidToUnit[guid] == unit then
            self.guidToUnit[guid] = nil
        end

        self.unitToGuid[unit] = nil
    elseif self.guidToUnit and next(self.guidToUnit) then
        -- Fallback scan: Safe pairs usage
        for guid, cachedUnit in pairs(self.guidToUnit) do
            if cachedUnit == unit then
                self.guidToUnit[guid] = nil
            end
        end
    end
end

function HEAT:StoreBuff(guid, spellID, data)
    if not guid or not spellID then return end
    if not data then
        if self.storedBuffs[guid] then
            self.storedBuffs[guid][spellID] = nil
            if not next(self.storedBuffs[guid]) then self.storedBuffs[guid] = nil end
        end
        return
    end

    if not self.storedBuffs[guid] then self.storedBuffs[guid] = {} end
    local record = self.storedBuffs[guid][spellID]
    if not record then
        record = {}
        self.storedBuffs[guid][spellID] = record
    elseif record == data then
        return
    else
        wipe(record)
    end
    for key, value in pairs(data) do
        record[key] = value
    end
end

function HEAT:SetStoredBuff(guid, spellID, name, icon, duration, expirationTime, startTime, stacks, isScanned)
    if not guid or not spellID then return end
    if not self.storedBuffs[guid] then self.storedBuffs[guid] = {} end

    local record = self.storedBuffs[guid][spellID]
    if not record then
        record = {}
        self.storedBuffs[guid][spellID] = record
    end

    record.destGUID = guid
    record.spellID = spellID
    record.name = name
    record.icon = icon
    record.duration = duration
    record.expirationTime = expirationTime
    record.startTime = startTime
    record.stacks = stacks
    record.isScanned = isScanned or nil
end

function HEAT:RemoveBuff(guid, spellID)
    if not guid or not spellID then return end
    if self.storedBuffs[guid] then
        self.storedBuffs[guid][spellID] = nil
        if not next(self.storedBuffs[guid]) then self.storedBuffs[guid] = nil end
    end
end

function HEAT:RefreshTrackedBuffs(force)
    local nameplateBuffLookup, nameplateSignature = BuildBuffLookup(self.nameplateBuffs)
    local targetBuffLookup, targetSignature = BuildBuffLookup(self.targetBuffs)
    local signature = (nameplateSignature or "") .. "|" .. (targetSignature or "")

    if not force and self.configuredBuffSignature == signature then return end

    self.configuredBuffSignature = signature
    TrackBuffLookup(nameplateBuffLookup)
    TrackBuffLookup(targetBuffLookup)
end

function HEAT:ScanUnitBuffs(unit, providedFlags, providedIsEnemy, providedGUID)
    local guid = providedGUID or UnitGUID(unit)
    if not guid then return end

    local isEnemy = providedIsEnemy
    if isEnemy == nil then
        local flags = providedFlags or self:BuildFlags(unit, guid)
        isEnemy = self.IsEnemy and self:IsEnemy(guid, flags)
    end

    if not isEnemy then return end
    if not self.trackedAuraIDs or not next(self.trackedAuraIDs) then return end

    local now = GetTime()
    local foundSpells = self.scanFoundSpells
    if not foundSpells then
        foundSpells = {}
        self.scanFoundSpells = foundSpells
    else
        wipe(foundSpells)
    end

    for i = 1, 40 do
        local name, icon, count, _, duration, expirationTime, source, _, _, spellID = UnitAura(unit, i, "HELPFUL")
        if not name then break end

        if spellID and self.trackedAuraIDs[spellID] then
            foundSpells[spellID] = true

            local calculatedDuration = duration
            if not calculatedDuration or calculatedDuration == 0 then calculatedDuration = -1 end

            local stackCount = count or 0
            if stackCount == 0 then stackCount = 1 end

            local start = now
            if expirationTime and expirationTime > 0 and duration and duration > 0 then
                start = expirationTime - duration
            end

            self:SetStoredBuff(guid, spellID, name, icon, calculatedDuration, expirationTime, start, stackCount, true)
        end
    end

    -- Cleanup Logic
    -- Removes spells that were previously scanned but are no longer found on the unit.
    -- Does NOT remove spells that were added via COMBAT_LOG (isScanned == nil/false)
    -- as they might be invisible to UnitAura due to range.
    if self.storedBuffs[guid] and next(self.storedBuffs[guid]) then
        for spellID, data in pairs(self.storedBuffs[guid]) do
            local shouldRemove = false
            if not foundSpells[spellID] then
                shouldRemove = true
            end

            if shouldRemove then
                if data.isScanned then
                    self.storedBuffs[guid][spellID] = nil
                end
            end
        end
        if not next(self.storedBuffs[guid]) then self.storedBuffs[guid] = nil end
    end

    wipe(foundSpells)
end

function HEAT:ScanAllUnits()
    local unitTokens = self.scanUnitTokens or self.unitTokens
    if not unitTokens then return end
    for _, unit in ipairs(unitTokens) do
        if UnitExists(unit) then
            local guid = UnitGUID(unit)
            if guid then
                self:UpdateUnitCache(unit)
                local flags, isHostile = self:UpdateUnitHostility(unit, guid)
                self:ScanUnitBuffs(unit, flags, isHostile, guid)
            end
        end
    end
end

function HEAT:ProcessDataEvents(event, ...)
    local INFINITY = -1

    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        local now = GetTime()
        -- args 1-11 are standard. args 12-18 vary by subEvent.
        --       1          2         3           4           5           6                7             8         9         10          11         12     13     14     15     16     17     18
        local timestamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, arg12, arg13, arg14, arg15, arg16, arg17, arg18 = CombatLogGetCurrentEventInfo()

        -- Cleanup on Death
        if subEvent == "UNIT_DIED" or subEvent == "UNIT_DESTROYED" then
            if destGUID then
                self.storedBuffs[destGUID] = nil
                self.unitCastDelayed[destGUID] = nil
                if self.hostilityCache and self.hostilityCache.cache[destGUID] then
                    self:RemoveNode(self.hostilityCache.cache[destGUID])
                end
            end
            return
        end

        -- Warrior Stance Inference via instant O(1) hash map
        if subEvent == "SPELL_CAST_SUCCESS" then
            local spellID = arg12
            if sourceGUID and sourceFlags and self:IsEnemy(sourceGUID, sourceFlags) then
                local newStance = spellID and WARRIOR_STANCE_TRIGGERS[spellID]
                if newStance then
                    local stanceInfo = self.AuraInfo[newStance]

                    self:RemoveBuff(sourceGUID, 2457) -- Battle
                    self:RemoveBuff(sourceGUID, 2458) -- Berserker
                    self:RemoveBuff(sourceGUID, 71)   -- Defensive

                    self:SetStoredBuff(sourceGUID, newStance, stanceInfo and stanceInfo.name, stanceInfo and stanceInfo.icon, INFINITY, nil, now, 0, nil)
                end
            end
        end

        local isApplication = subEvent == "SPELL_AURA_APPLIED" or subEvent == "SPELL_AURA_REFRESH" or subEvent == "SPELL_AURA_APPLIED_DOSE"
        local isRemoval = subEvent == "SPELL_AURA_REMOVED" or subEvent == "SPELL_AURA_BROKEN" or subEvent == "SPELL_AURA_BROKEN_SPELL" or subEvent == "SPELL_AURA_REMOVED_DOSE"
        local isDispel = subEvent == "SPELL_DISPEL" or subEvent == "SPELL_STOLEN"

        local spellID, spellName, auraType, amount

        if isApplication or isRemoval then
            -- Standard Aura Args: 12=ID, 13=Name, 14=School, 15=Type, 16=Amount
            spellID = arg12
            spellName = arg13
            auraType = arg15
            amount = arg16
        elseif isDispel then
            -- Dispel Args: 12=CasterID ... 15=ExtraSpellID (Removed ID), 16=ExtraName, 17=ExtraSchool, 18=ExtraType
            spellID = arg15
            auraType = arg18
        end

        local isTrackedAura = spellID and self.trackedAuraIDs and self.trackedAuraIDs[spellID]

        if (isApplication or isRemoval or isDispel) and isTrackedAura then

            -- Only track logic if the destination is an enemy
            if self.IsEnemy and destGUID and destFlags and auraType == "BUFF" and self:IsEnemy(destGUID, destFlags) then
                local spellDataForLookup = self.AuraInfo[spellID]

                if isApplication then
                    local buffDuration = INFINITY
                    if spellDataForLookup and spellDataForLookup.duration and spellDataForLookup.duration ~= -1 then
                        buffDuration = tonumber(spellDataForLookup.duration)
                    end

                    local expirationTime = (buffDuration == INFINITY) and nil or ((buffDuration > 0) and (now + buffDuration) or nil)

                    local currentStacks = 1
                    if (subEvent == "SPELL_AURA_APPLIED_DOSE" --[[or subEvent == "SPELL_AURA_REFRESH"]]) then
                        if amount then
                            currentStacks = amount
                        elseif self.storedBuffs[destGUID] and self.storedBuffs[destGUID][spellID] then
                            currentStacks = self.storedBuffs[destGUID][spellID].stacks or currentStacks
                        end
                    end

                    self:SetStoredBuff(
                        destGUID,
                        spellID,
                        spellName or (spellDataForLookup and spellDataForLookup.name),
                        spellDataForLookup and spellDataForLookup.icon,
                        buffDuration,
                        expirationTime,
                        now,
                        currentStacks,
                        nil
                    )
                elseif (isRemoval or isDispel) then
                    self:RemoveBuff(destGUID, spellID)
                end
            end
        end
    elseif event == "CHAT_MSG_ADDON" then
        local now = GetTime()
        local messagePrefix, msg, _, sender = ...
        if messagePrefix == self.prefix and sender ~= UnitName("player") and msg then
            local eventType, data = msg:match("([^#]+)#(.*)")
            if not (eventType and data) then return end

            local guid = data:match("([^#]+)")
            -- If we are targeting the unit, assume our local scan is more accurate than the sync
            if guid and guid == UnitGUID("target") then return end

            if eventType == "APPLIED" then
                local _, spellID, expiration = data:match("([^#]+)#([^#]+)#([^#]+)")
                spellID = tonumber(spellID)
                expiration = tonumber(expiration)
                if not (guid and spellID and expiration) then return end

                local spell = self.AuraInfo[spellID]
                if not spell then return end
                local expirationTime = (expiration == 0) and nil or expiration
                local duration = INFINITY
                if expirationTime then duration = expirationTime - now; if duration < 0 then duration = 0 end
                elseif spell and spell.duration ~= INFINITY then duration = spell.duration end

                self:SetStoredBuff(guid, spellID, spell.name, spell.icon, duration, expirationTime, now, nil, nil)

            elseif eventType == "REMOVED" then
                local _, spellID = data:match("([^#]+)#([^#]+)")
                spellID = tonumber(spellID)
                if guid and spellID then self:RemoveBuff(guid, spellID) end
            end
        end
    end
end

function HEAT:ProcessHostilityEvent(event, ...)
        if not self.hostilityCache then return end

        -- Process raw data (Combat Log / Chat Sync)
        if event == "COMBAT_LOG_EVENT_UNFILTERED" or event == "CHAT_MSG_ADDON" then
            self:ProcessDataEvents(event, ...)
            return
        end

        -- Handle Zone Changes / Roster updates
        if event == "PLAYER_ENTERING_WORLD" or event == "ARENA_OPPONENT_UPDATE" or event == "GROUP_ROSTER_UPDATE" then
            if event == "PLAYER_ENTERING_WORLD" then
                self.playerGUID = UnitGUID("player") or self.playerGUID
            end
            self:ScanAllUnits()
            -- Arena Update Specifics: Check for removal
            if event == "ARENA_OPPONENT_UPDATE" then
                local unit, type = ...
                if type == "cleared" or type == "destroyed" then
                    self:ClearUnitCache(unit)
                elseif type == "seen" then
                    self:UpdateUnitCache(unit)
                end
            end
            return
        end

        -- Determine if a specific unit needs scanning based on the event
        local unitToUpdate = nil
        if event == "PLAYER_TARGET_CHANGED" then unitToUpdate = "target"
        elseif event == "PLAYER_FOCUS_CHANGED" then unitToUpdate = "focus"
        elseif event == "UPDATE_MOUSEOVER_UNIT" then unitToUpdate = "mouseover"
        elseif event == "NAME_PLATE_UNIT_ADDED" or event == "UNIT_FLAGS" or event == "UNIT_FACTION" or event == "UNIT_AURA" then
            local unitId = ...
            if unitId and UnitExists(unitId) then
                unitToUpdate = unitId
                -- IMPORTANT: Keep cache updated here
                self:UpdateUnitCache(unitId)
            end

        -- Handle Nameplate Removal to clean cache
        elseif event == "NAME_PLATE_UNIT_REMOVED" then
            local unitId = ...
            if unitId then self:ClearUnitCache(unitId) end
        end

        -- Perform the scan if a unit was identified
        if unitToUpdate then
            local guid = UnitGUID(unitToUpdate)
            if guid then
                local flags, isHostile = self:UpdateUnitHostility(unitToUpdate, guid)
                self:ScanUnitBuffs(unitToUpdate, flags, isHostile, guid)
            end
        end
end

----------------------------------------------------------------------------
-- STATIC DATA LOADER
----------------------------------------------------------------------------
-- Clients without a data file retain the original empty defaults.
function HEAT:LoadStaticData()
    return "", {}, {}
end
