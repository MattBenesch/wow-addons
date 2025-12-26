--[[
    Combat Tracker
    Handles combat log event tracking and rolling buffer system
]]

local ADDON_NAME, DA = ...

--------------------------------------------------------------------------------
-- Combat Log Event Types to Track
--------------------------------------------------------------------------------

local DAMAGE_EVENTS = {
    ["SWING_DAMAGE"] = true,
    ["RANGE_DAMAGE"] = true,
    ["SPELL_DAMAGE"] = true,
    ["SPELL_PERIODIC_DAMAGE"] = true,
    ["ENVIRONMENTAL_DAMAGE"] = true,
}

local HEALING_EVENTS = {
    ["SPELL_HEAL"] = true,
    ["SPELL_PERIODIC_HEAL"] = true,
}

local AURA_EVENTS = {
    ["SPELL_AURA_APPLIED"] = true,
    ["SPELL_AURA_REMOVED"] = true,
    ["SPELL_AURA_REFRESH"] = true,
}

local CAST_EVENTS = {
    ["SPELL_CAST_SUCCESS"] = true,
}

local DEATH_EVENTS = {
    ["UNIT_DIED"] = true,
    ["PARTY_KILL"] = true,
}

--------------------------------------------------------------------------------
-- Tracking Frame
--------------------------------------------------------------------------------

local trackerFrame = CreateFrame("Frame", "DeathAnalyzerTracker")
local isTracking = false
local playerGUID = nil

--------------------------------------------------------------------------------
-- Start/Stop Tracking
--------------------------------------------------------------------------------

function DA:StartTracking()
    if isTracking then return end
    
    playerGUID = UnitGUID("player")
    
    trackerFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    trackerFrame:RegisterEvent("PLAYER_DEAD")
    trackerFrame:RegisterEvent("PLAYER_UNGHOST")
    trackerFrame:RegisterEvent("PLAYER_ALIVE")
    
    isTracking = true
    self:Debug("Combat tracking started for: " .. tostring(playerGUID))
end

function DA:StopTracking()
    trackerFrame:UnregisterAllEvents()
    isTracking = false
    self:Debug("Combat tracking stopped")
end

--------------------------------------------------------------------------------
-- Event Handler
--------------------------------------------------------------------------------

trackerFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "COMBAT_LOG_EVENT_UNFILTERED" then
        DA:ProcessCombatLogEvent(CombatLogGetCurrentEventInfo())
    elseif event == "PLAYER_DEAD" then
        DA:OnPlayerDeath()
    elseif event == "PLAYER_UNGHOST" or event == "PLAYER_ALIVE" then
        -- Clear buffer after resurrection
        C_Timer.After(1, function()
            DA:PruneBuffer(GetTime())
        end)
    end
end)

--------------------------------------------------------------------------------
-- Combat Log Processing
--------------------------------------------------------------------------------

function DA:ProcessCombatLogEvent(...)
    local timestamp, subevent, hideCaster, sourceGUID, sourceName, sourceFlags, 
          sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = ...
    
    -- Get additional params starting at index 12
    local params = {...}
    
    -- We only care about events that affect the player
    local affectsPlayer = (destGUID == playerGUID) or (sourceGUID == playerGUID)
    
    if not affectsPlayer then return end
    
    -- Process damage events
    if DAMAGE_EVENTS[subevent] and destGUID == playerGUID then
        self:ProcessDamageEvent(timestamp, subevent, sourceName, sourceGUID, params)
    
    -- Process healing events
    elseif HEALING_EVENTS[subevent] and destGUID == playerGUID then
        self:ProcessHealingEvent(timestamp, subevent, sourceName, sourceGUID, params)
    
    -- Process aura events (for buff/defensive tracking)
    elseif AURA_EVENTS[subevent] then
        self:ProcessAuraEvent(timestamp, subevent, sourceGUID, destGUID, params)
    
    -- Process cast events (for defensive cooldown tracking)
    elseif CAST_EVENTS[subevent] and sourceGUID == playerGUID then
        self:ProcessCastEvent(timestamp, subevent, params)
    
    -- Process death events
    elseif DEATH_EVENTS[subevent] and destGUID == playerGUID then
        -- Death is handled via PLAYER_DEAD event for reliability
    end
end

--------------------------------------------------------------------------------
-- Damage Event Processing
--------------------------------------------------------------------------------

function DA:ProcessDamageEvent(timestamp, subevent, sourceName, sourceGUID, params)
    local event = {
        type = "DAMAGE",
        timestamp = GetTime(),
        rawTimestamp = timestamp,
        source = sourceName or "Unknown",
        sourceGUID = sourceGUID,
    }
    
    -- Parse based on event type
    if subevent == "SWING_DAMAGE" then
        -- Swing: amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing
        event.spellID = 0
        event.spellName = "Melee"
        event.amount = params[12] or 0
        event.overkill = params[13] or 0
        event.school = params[14] or 1
        event.absorbed = params[17] or 0
        event.critical = params[18]
        
    elseif subevent == "ENVIRONMENTAL_DAMAGE" then
        -- Environmental: environmentalType, amount, overkill, school, resisted, blocked, absorbed
        event.spellID = 0
        event.spellName = params[12] or "Environment"
        event.amount = params[13] or 0
        event.overkill = params[14] or 0
        event.school = params[15] or 1
        event.absorbed = params[18] or 0
        
    else
        -- Spell damage: spellId, spellName, spellSchool, amount, overkill, school, resisted, blocked, absorbed, critical
        event.spellID = params[12] or 0
        event.spellName = params[13] or "Unknown Spell"
        event.spellSchool = params[14] or 1
        event.amount = params[15] or 0
        event.overkill = params[16] or 0
        event.absorbed = params[20] or 0
        event.critical = params[21]
    end
    
    -- Record current health
    event.healthRemaining = UnitHealth("player")
    event.healthMax = UnitHealthMax("player")
    event.healthPercent = (event.healthRemaining / event.healthMax) * 100
    
    self:AddToBuffer(event)
end

--------------------------------------------------------------------------------
-- Healing Event Processing
--------------------------------------------------------------------------------

function DA:ProcessHealingEvent(timestamp, subevent, sourceName, sourceGUID, params)
    -- Healing: spellId, spellName, spellSchool, amount, overhealing, absorbed, critical
    local event = {
        type = "HEALING",
        timestamp = GetTime(),
        rawTimestamp = timestamp,
        source = sourceName or "Unknown",
        sourceGUID = sourceGUID,
        spellID = params[12] or 0,
        spellName = params[13] or "Unknown Heal",
        amount = params[15] or 0,
        overhealing = params[16] or 0,
        absorbed = params[17] or 0,
        critical = params[18],
    }
    
    -- Record current health
    event.healthRemaining = UnitHealth("player")
    event.healthMax = UnitHealthMax("player")
    event.healthPercent = (event.healthRemaining / event.healthMax) * 100
    
    self:AddToBuffer(event)
end

--------------------------------------------------------------------------------
-- Aura Event Processing
--------------------------------------------------------------------------------

function DA:ProcessAuraEvent(timestamp, subevent, sourceGUID, destGUID, params)
    -- Track defensive buff applications/removals
    local spellID = params[12]
    local spellName = params[13]
    local auraType = params[15] -- BUFF or DEBUFF
    local sourceName = params[5] -- Source name from original params

    -- Only track buffs applied to player
    if destGUID ~= playerGUID or auraType ~= "BUFF" then return end

    local currentTime = GetTime()
    local isApplied = (subevent == "SPELL_AURA_APPLIED" or subevent == "SPELL_AURA_REFRESH")

    -- Check if this is a tracked personal defensive
    if self.defensiveState[spellID] then
        local event = {
            type = subevent == "SPELL_AURA_APPLIED" and "BUFF_GAIN" or
                   subevent == "SPELL_AURA_REMOVED" and "BUFF_FADE" or "BUFF_REFRESH",
            timestamp = currentTime,
            spellID = spellID,
            spellName = spellName,
        }

        self:AddToBuffer(event)
    end

    -- Check if this is an external defensive (healer cooldown)
    if self.ExternalDefensiveLookup and self.ExternalDefensiveLookup[spellID] then
        -- Track external defensive application/removal
        if self.TrackExternalDefensive then
            self:TrackExternalDefensive(spellID, sourceName, sourceGUID, currentTime, isApplied)
        end

        -- Add to event buffer for timeline
        local event = {
            type = isApplied and "EXTERNAL_GAIN" or "EXTERNAL_FADE",
            timestamp = currentTime,
            spellID = spellID,
            spellName = spellName,
            source = sourceName,
            sourceGUID = sourceGUID,
            externalInfo = self.ExternalDefensiveLookup[spellID],
        }

        self:AddToBuffer(event)
    end
end

--------------------------------------------------------------------------------
-- Cast Event Processing
--------------------------------------------------------------------------------

function DA:ProcessCastEvent(timestamp, subevent, params)
    local spellID = params[12]
    local spellName = params[13]
    
    -- Check if this is a defensive cooldown
    if self.defensiveState[spellID] then
        self:OnDefensiveUsed(spellID, GetTime())
        
        local event = {
            type = "DEFENSIVE_USED",
            timestamp = GetTime(),
            spellID = spellID,
            spellName = spellName,
        }
        
        self:AddToBuffer(event)
    end
end

--------------------------------------------------------------------------------
-- Buffer Management
--------------------------------------------------------------------------------

function DA:AddToBuffer(event)
    table.insert(self.eventBuffer, event)
    
    -- Prune old events
    local now = GetTime()
    local cutoff = now - (DeathAnalyzerDB.bufferDuration or 15)
    self:PruneBuffer(cutoff)
end

function DA:PruneBuffer(cutoff)
    local newBuffer = {}
    for _, event in ipairs(self.eventBuffer) do
        if event.timestamp >= cutoff then
            table.insert(newBuffer, event)
        end
    end
    self.eventBuffer = newBuffer
end

function DA:GetBufferSnapshot()
    -- Return a copy of the current buffer
    local snapshot = {}
    for _, event in ipairs(self.eventBuffer) do
        table.insert(snapshot, event)
    end
    return snapshot
end

--------------------------------------------------------------------------------
-- Death Processing
--------------------------------------------------------------------------------

local lastDeathTime = 0
local DEATH_DEBOUNCE = 2.0 -- Ignore deaths within 2 seconds of each other

function DA:OnPlayerDeath()
    local deathTime = GetTime()
    
    -- Debounce: Prevent double-recording deaths
    if (deathTime - lastDeathTime) < DEATH_DEBOUNCE then
        self:Debug("Death ignored (debounce) - last death was " .. string.format("%.1f", deathTime - lastDeathTime) .. "s ago")
        return
    end
    lastDeathTime = deathTime
    
    -- Capture buffer snapshot
    local events = self:GetBufferSnapshot()
    
    if #events == 0 then
        self:Debug("No events captured before death")
        return
    end
    
    -- Get ready defensives at time of death (using CDR-aware calculation if available)
    local readyDefensives
    if self.GetReadyDefensivesAtDeathWithCDR then
        readyDefensives = self:GetReadyDefensivesAtDeathWithCDR(deathTime)
    else
        readyDefensives = self:GetReadyDefensivesAtDeath(deathTime)
    end
    
    -- Capture M+ context if in a M+ dungeon
    local mplusInfo = self:GetMythicPlusContext()

    -- Capture encounter context
    local encounterInfo = self:GetEncounterContext()

    -- Capture active external defensives at death
    local activeExternals = nil
    if self.GetActiveExternalsAtDeath then
        activeExternals = self:GetActiveExternalsAtDeath(deathTime)
    end

    -- Create death snapshot
    local snapshot = {
        timestamp = deathTime,
        dateString = date("%Y-%m-%d %H:%M:%S"),
        events = events,
        readyDefensives = readyDefensives,
        activeExternals = activeExternals,  -- External CDs that were active at death
        playerInfo = self:GetPlayerInfo(),
        location = GetZoneText(),
        subzone = GetSubZoneText(),
        -- M+ Context
        mythicPlus = mplusInfo,
        -- Encounter Context (boss fights)
        encounter = encounterInfo,
        -- Instance info
        instanceType = select(2, IsInInstance()),
        difficultyID = select(3, GetInstanceInfo()),
        difficultyName = select(4, GetInstanceInfo()),
    }
    
    -- Analyze the death
    self:AnalyzeDeath(snapshot)
    
    -- Record statistics (skip for test deaths)
    if self.RecordDeathStatistics and not self.isTestDeath then
        self:RecordDeathStatistics(snapshot)
    end
    
    -- Update minimap button text
    if self.UpdateMinimapButtonText then
        self:UpdateMinimapButtonText()
    end
    
    -- Save snapshot
    table.insert(self.deathSnapshots, snapshot)
    
    -- Trim old snapshots
    while #self.deathSnapshots > (DeathAnalyzerDB.maxSnapshots or 50) do
        table.remove(self.deathSnapshots, 1)
    end
    
    -- Save to DB
    DeathAnalyzerDB.deathSnapshots = self.deathSnapshots
    
    -- Show notification
    if DeathAnalyzerDB.showPopupOnDeath then
        self:ShowDeathPopup(snapshot)
    end
    
    self:Debug("Death recorded. Total deaths: " .. #self.deathSnapshots)
end

--------------------------------------------------------------------------------
-- Test Function
--------------------------------------------------------------------------------

function DA:SimulateTestDeath()
    -- Mark this as a test death so it doesn't get recorded in statistics
    self.isTestDeath = true
    
    -- Create fake events for testing
    local now = GetTime()
    local maxHealth = UnitHealthMax("player")
    
    -- Use real spell IDs from the avoidable damage database for testing
    -- 209862 = Volcanic Plume (M+ Affix)
    -- 320637 = Fetid Gas (Necrotic Wake - Blightbone)
    
    self.eventBuffer = {
        {
            type = "DAMAGE",
            timestamp = now - 10,
            source = "Test Boss",
            spellID = 12345,
            spellName = "Big Hit",
            amount = math.floor(maxHealth * 0.25),
            healthPercent = 85,
            healthRemaining = math.floor(maxHealth * 0.85),
            healthMax = maxHealth,
        },
        {
            type = "HEALING",
            timestamp = now - 8,
            source = "Test Healer",
            spellID = 54321,
            spellName = "Flash Heal",
            amount = math.floor(maxHealth * 0.15),
            healthPercent = 80,
            healthRemaining = math.floor(maxHealth * 0.80),
            healthMax = maxHealth,
        },
        {
            type = "DAMAGE",
            timestamp = now - 6,
            source = "Volcanic Plume",
            spellID = 209862,  -- Real Volcanic spell ID
            spellName = "Volcanic Plume",
            amount = math.floor(maxHealth * 0.35),
            healthPercent = 50,
            healthRemaining = math.floor(maxHealth * 0.50),
            healthMax = maxHealth,
        },
        {
            type = "DAMAGE",
            timestamp = now - 4,
            source = "Blightbone",
            spellID = 320637,  -- Real Fetid Gas spell ID from Necrotic Wake
            spellName = "Fetid Gas",
            amount = math.floor(maxHealth * 0.20),
            healthPercent = 35,
            healthRemaining = math.floor(maxHealth * 0.35),
            healthMax = maxHealth,
        },
        {
            type = "DAMAGE",
            timestamp = now - 2,
            source = "Test Boss",
            spellID = 12345,
            spellName = "Big Hit",
            amount = math.floor(maxHealth * 0.25),
            healthPercent = 15,
            healthRemaining = math.floor(maxHealth * 0.15),
            healthMax = maxHealth,
        },
        {
            type = "DAMAGE",
            timestamp = now,
            source = "Test Boss",
            spellID = 12345,
            spellName = "Big Hit",
            amount = math.floor(maxHealth * 0.20),
            overkill = math.floor(maxHealth * 0.05),
            healthPercent = 0,
            healthRemaining = 0,
            healthMax = maxHealth,
        },
    }
    
    -- Trigger death analysis
    self:OnPlayerDeath()
    
    -- Clear test flag
    self.isTestDeath = false
    
    self:Print("Test death simulated (not recorded in statistics). Use /da to view.")
end

--------------------------------------------------------------------------------
-- Context Gathering Functions
--------------------------------------------------------------------------------

-- Get Mythic+ dungeon context
function DA:GetMythicPlusContext()
    -- Check if we're in a M+ dungeon
    local _, instanceType = IsInInstance()
    if instanceType ~= "party" then
        return nil
    end

    -- Try to get M+ info from C_ChallengeMode
    local activeKeystoneLevel = C_ChallengeMode.GetActiveKeystoneInfo and C_ChallengeMode.GetActiveKeystoneInfo()
    if not activeKeystoneLevel or activeKeystoneLevel == 0 then
        return nil
    end

    local mapID = C_ChallengeMode.GetActiveChallengeMapID and C_ChallengeMode.GetActiveChallengeMapID()
    local dungeonName = mapID and C_ChallengeMode.GetMapUIInfo(mapID) or GetZoneText()

    -- Get active affixes
    local affixes = {}
    local affixIDs = C_ChallengeMode.GetActiveKeystoneInfo and select(2, C_ChallengeMode.GetActiveKeystoneInfo()) or {}
    if affixIDs then
        for _, affixID in ipairs(affixIDs) do
            local affixName, affixDesc = C_ChallengeMode.GetAffixInfo(affixID)
            if affixName then
                table.insert(affixes, {
                    id = affixID,
                    name = affixName,
                    description = affixDesc,
                })
            end
        end
    end

    -- Get timer info
    local elapsedTime = select(2, C_ChallengeMode.GetCompletionInfo and C_ChallengeMode.GetCompletionInfo()) or 0
    local timeLimit = select(3, C_ChallengeMode.GetMapUIInfo(mapID or 0)) or 0

    -- Get death count
    local deathCount = C_ChallengeMode.GetDeathCount and C_ChallengeMode.GetDeathCount() or 0

    return {
        keyLevel = activeKeystoneLevel,
        dungeonName = dungeonName,
        mapID = mapID,
        affixes = affixes,
        elapsedTime = elapsedTime,
        timeLimit = timeLimit,
        deathCount = deathCount,
        inProgress = true,
    }
end

-- Get encounter (boss fight) context
function DA:GetEncounterContext()
    -- Check if we're in a boss encounter
    if not self.currentEncounter then
        return nil
    end

    return {
        encounterID = self.currentEncounter.encounterID,
        encounterName = self.currentEncounter.encounterName,
        difficultyID = self.currentEncounter.difficultyID,
        groupSize = self.currentEncounter.groupSize,
        startTime = self.currentEncounter.startTime,
        duration = GetTime() - (self.currentEncounter.startTime or GetTime()),
    }
end

-- Track encounter start/end
local encounterFrame = CreateFrame("Frame")
encounterFrame:RegisterEvent("ENCOUNTER_START")
encounterFrame:RegisterEvent("ENCOUNTER_END")

encounterFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ENCOUNTER_START" then
        local encounterID, encounterName, difficultyID, groupSize = ...
        DA.currentEncounter = {
            encounterID = encounterID,
            encounterName = encounterName,
            difficultyID = difficultyID,
            groupSize = groupSize,
            startTime = GetTime(),
        }
        DA:Debug("Encounter started: " .. (encounterName or "Unknown"))
    elseif event == "ENCOUNTER_END" then
        local encounterID, encounterName, difficultyID, groupSize, success = ...
        DA.currentEncounter = nil
        DA:Debug("Encounter ended: " .. (encounterName or "Unknown") .. " - " .. (success == 1 and "Success" or "Wipe"))
    end
end)
