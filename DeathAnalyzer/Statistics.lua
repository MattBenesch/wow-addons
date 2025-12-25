--[[
    Death Statistics
    Tracks long-term death patterns and statistics
]]

local ADDON_NAME, DA = ...

--------------------------------------------------------------------------------
-- Statistics Data Structure
--------------------------------------------------------------------------------

-- Default statistics structure
local DEFAULT_STATS = {
    totalDeaths = 0,
    preventableDeaths = 0,
    unavoidableDeaths = 0,
    totalAvoidableDamage = 0,
    totalDamageTaken = 0,
    
    -- Time-based tracking
    deathsByHour = {},      -- [hour] = count
    deathsByDay = {},       -- [dayOfWeek] = count
    
    -- Top killers
    killerSpells = {},      -- [spellID] = { name, count, totalDamage }
    killerSources = {},     -- [sourceName] = { count, totalDamage }
    
    -- Zone tracking
    deathsByZone = {},      -- [zoneName] = count
    
    -- Unused defensives tracking
    unusedDefensives = {},  -- [spellID] = { name, count }
    
    -- Avoidable damage by category
    avoidableByCategory = {},  -- [category] = { count, totalDamage }
    
    -- Score tracking
    totalScore = 0,
    scoreCount = 0,
    
    -- Session tracking
    sessionDeaths = 0,
    sessionStart = 0,
    
    -- First/last death timestamps
    firstDeath = nil,
    lastDeath = nil,
}

--------------------------------------------------------------------------------
-- Initialize Statistics
--------------------------------------------------------------------------------

function DA:InitializeStatistics()
    -- Load or create statistics data
    if not DeathAnalyzerDB.statistics then
        DeathAnalyzerDB.statistics = {}
        for k, v in pairs(DEFAULT_STATS) do
            if type(v) == "table" then
                DeathAnalyzerDB.statistics[k] = {}
            else
                DeathAnalyzerDB.statistics[k] = v
            end
        end
    end
    
    -- Start session tracking
    DeathAnalyzerDB.statistics.sessionDeaths = 0
    DeathAnalyzerDB.statistics.sessionStart = time()
    
    self.stats = DeathAnalyzerDB.statistics
    self:Debug("Statistics initialized")
end

--------------------------------------------------------------------------------
-- Record Death Statistics
--------------------------------------------------------------------------------

function DA:RecordDeathStatistics(snapshot)
    if not self.stats then
        self:InitializeStatistics()
    end
    
    local stats = self.stats
    local analysis = snapshot.analysis
    
    if not analysis then return end
    
    -- Basic counts
    stats.totalDeaths = stats.totalDeaths + 1
    stats.sessionDeaths = stats.sessionDeaths + 1
    
    -- Verdict tracking
    if analysis.verdict then
        if analysis.verdict.text == "PREVENTABLE" or analysis.verdict.text == "LIKELY PREVENTABLE" then
            stats.preventableDeaths = stats.preventableDeaths + 1
        elseif analysis.verdict.text == "UNAVOIDABLE" then
            stats.unavoidableDeaths = stats.unavoidableDeaths + 1
        end
    end
    
    -- Damage tracking
    stats.totalDamageTaken = stats.totalDamageTaken + (analysis.totalDamageTaken or 0)
    stats.totalAvoidableDamage = stats.totalAvoidableDamage + (analysis.avoidableDamage or 0)
    
    -- Score tracking
    if analysis.score then
        stats.totalScore = stats.totalScore + analysis.score
        stats.scoreCount = stats.scoreCount + 1
    end
    
    -- Time-based tracking
    local deathTime = snapshot.timestamp or time()
    local hour = tonumber(date("%H", deathTime))
    local dayOfWeek = date("%A", deathTime)
    
    stats.deathsByHour[hour] = (stats.deathsByHour[hour] or 0) + 1
    stats.deathsByDay[dayOfWeek] = (stats.deathsByDay[dayOfWeek] or 0) + 1
    
    -- First/last death
    if not stats.firstDeath then
        stats.firstDeath = deathTime
    end
    stats.lastDeath = deathTime
    
    -- Zone tracking
    local zone = snapshot.location or GetZoneText() or "Unknown"
    stats.deathsByZone[zone] = (stats.deathsByZone[zone] or 0) + 1
    
    -- Killer tracking
    if analysis.killingBlow then
        local kb = analysis.killingBlow
        local spellID = kb.spellID or 0
        local spellName = kb.spellName or "Unknown"
        local source = kb.source or "Unknown"
        local amount = kb.amount or 0
        
        -- Track by spell
        if not stats.killerSpells[spellID] then
            stats.killerSpells[spellID] = { name = spellName, count = 0, totalDamage = 0 }
        end
        stats.killerSpells[spellID].count = stats.killerSpells[spellID].count + 1
        stats.killerSpells[spellID].totalDamage = stats.killerSpells[spellID].totalDamage + amount
        
        -- Track by source
        if not stats.killerSources[source] then
            stats.killerSources[source] = { count = 0, totalDamage = 0 }
        end
        stats.killerSources[source].count = stats.killerSources[source].count + 1
        stats.killerSources[source].totalDamage = stats.killerSources[source].totalDamage + amount
    end
    
    -- Unused defensives tracking
    if analysis.unusedDefensives then
        for _, def in ipairs(analysis.unusedDefensives) do
            local spellID = def.spellID or 0
            if not stats.unusedDefensives[spellID] then
                stats.unusedDefensives[spellID] = { name = def.name, count = 0 }
            end
            stats.unusedDefensives[spellID].count = stats.unusedDefensives[spellID].count + 1
        end
    end
    
    -- Avoidable damage by category
    if analysis.avoidableEvents then
        for _, evt in ipairs(analysis.avoidableEvents) do
            local category = evt.category or "unknown"
            if not stats.avoidableByCategory[category] then
                stats.avoidableByCategory[category] = { count = 0, totalDamage = 0 }
            end
            stats.avoidableByCategory[category].count = stats.avoidableByCategory[category].count + 1
            stats.avoidableByCategory[category].totalDamage = stats.avoidableByCategory[category].totalDamage + (evt.amount or 0)
        end
    end
    
    self:Debug("Death statistics recorded")
end

--------------------------------------------------------------------------------
-- Get Statistics Summary
--------------------------------------------------------------------------------

function DA:GetStatisticsSummary()
    if not self.stats then
        self:InitializeStatistics()
    end
    
    local stats = self.stats
    local summary = {}
    
    -- Basic stats
    summary.totalDeaths = stats.totalDeaths
    summary.sessionDeaths = stats.sessionDeaths
    summary.preventableDeaths = stats.preventableDeaths
    summary.unavoidableDeaths = stats.unavoidableDeaths
    
    -- Percentages
    if stats.totalDeaths > 0 then
        summary.preventablePercent = (stats.preventableDeaths / stats.totalDeaths) * 100
        summary.unavoidablePercent = (stats.unavoidableDeaths / stats.totalDeaths) * 100
    else
        summary.preventablePercent = 0
        summary.unavoidablePercent = 0
    end
    
    -- Average score
    if stats.scoreCount > 0 then
        summary.averageScore = stats.totalScore / stats.scoreCount
    else
        summary.averageScore = 0
    end
    
    -- Avoidable damage percent
    if stats.totalDamageTaken > 0 then
        summary.avoidablePercent = (stats.totalAvoidableDamage / stats.totalDamageTaken) * 100
    else
        summary.avoidablePercent = 0
    end
    
    -- Top killers (sorted by count)
    summary.topKillers = {}
    for spellID, data in pairs(stats.killerSpells) do
        table.insert(summary.topKillers, {
            spellID = spellID,
            name = data.name,
            count = data.count,
            totalDamage = data.totalDamage
        })
    end
    table.sort(summary.topKillers, function(a, b) return a.count > b.count end)
    
    -- Top sources (sorted by count)
    summary.topSources = {}
    for source, data in pairs(stats.killerSources) do
        table.insert(summary.topSources, {
            name = source,
            count = data.count,
            totalDamage = data.totalDamage
        })
    end
    table.sort(summary.topSources, function(a, b) return a.count > b.count end)
    
    -- Top zones
    summary.topZones = {}
    for zone, count in pairs(stats.deathsByZone) do
        table.insert(summary.topZones, { name = zone, count = count })
    end
    table.sort(summary.topZones, function(a, b) return a.count > b.count end)
    
    -- Most unused defensives
    summary.mostUnusedDefensives = {}
    for spellID, data in pairs(stats.unusedDefensives) do
        table.insert(summary.mostUnusedDefensives, {
            spellID = spellID,
            name = data.name,
            count = data.count
        })
    end
    table.sort(summary.mostUnusedDefensives, function(a, b) return a.count > b.count end)
    
    -- Deadliest hour
    local maxHour, maxHourCount = 0, 0
    for hour, count in pairs(stats.deathsByHour) do
        if count > maxHourCount then
            maxHour, maxHourCount = hour, count
        end
    end
    summary.deadliestHour = maxHour
    summary.deadliestHourCount = maxHourCount
    
    -- Deadliest day
    local maxDay, maxDayCount = "", 0
    for day, count in pairs(stats.deathsByDay) do
        if count > maxDayCount then
            maxDay, maxDayCount = day, count
        end
    end
    summary.deadliestDay = maxDay
    summary.deadliestDayCount = maxDayCount
    
    return summary
end

--------------------------------------------------------------------------------
-- Reset Statistics
--------------------------------------------------------------------------------

function DA:ResetStatistics()
    DeathAnalyzerDB.statistics = nil
    self.stats = nil
    self:InitializeStatistics()
    self:Print("Statistics have been reset.")
end

--------------------------------------------------------------------------------
-- Statistics Window
--------------------------------------------------------------------------------

local STATS_WIDTH = 450
local STATS_HEIGHT = 500

function DA:CreateStatsWindow()
    if self.statsFrame then return end
    
    local frame = CreateFrame("Frame", "DeathAnalyzerStatsFrame", UIParent, "BackdropTemplate")
    frame:SetSize(STATS_WIDTH, STATS_HEIGHT)
    frame:SetPoint("CENTER", UIParent, "CENTER", 150, 0) -- Offset right of center
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetClampedToScreen(true)
    frame:SetFrameStrata("DIALOG")
    frame:SetFrameLevel(150)
    
    -- Backdrop
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    frame:SetBackdropColor(0.1, 0.1, 0.1, 0.95)
    frame:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)
    
    -- Make draggable
    frame:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            self:StartMoving()
        end
    end)
    frame:SetScript("OnMouseUp", function(self)
        self:StopMovingOrSizing()
    end)
    
    -- Header
    local header = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    header:SetHeight(24)
    header:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1)
    header:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -1, -1)
    header:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8" })
    header:SetBackdropColor(0.15, 0.15, 0.15, 1)
    
    -- Title
    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("LEFT", header, "LEFT", 8, 0)
    title:SetText("|cFF00FF00Death Analyzer|r - Statistics")
    
    -- Close button
    local closeBtn = CreateFrame("Button", nil, header)
    closeBtn:SetSize(16, 16)
    closeBtn:SetPoint("RIGHT", header, "RIGHT", -4, 0)
    closeBtn:SetNormalTexture("Interface\\Buttons\\UI-StopButton")
    closeBtn:SetHighlightTexture("Interface\\Buttons\\UI-StopButton", "ADD")
    closeBtn:SetScript("OnClick", function() frame:Hide() end)
    
    -- Scroll frame for content
    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 8, -8)
    scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -28, 8)
    
    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(STATS_WIDTH - 40, 800)
    scrollFrame:SetScrollChild(content)
    
    frame.content = content
    frame.scrollFrame = scrollFrame
    
    self.statsFrame = frame
    frame:Hide()
    
    return frame
end

function DA:RefreshStatsWindow()
    if not self.statsFrame then return end
    
    local content = self.statsFrame.content
    local summary = self:GetStatisticsSummary()
    
    -- Clear existing content
    for _, child in ipairs({content:GetChildren()}) do
        child:Hide()
        child:SetParent(nil)
    end
    for _, region in ipairs({content:GetRegions()}) do
        region:Hide()
    end
    
    local yOffset = 0
    
    -- Helper to create section header
    local function CreateHeader(text)
        local header = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        header:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOffset)
        header:SetText("|cFFFFCC00" .. text .. "|r")
        yOffset = yOffset - 20
        return header
    end
    
    -- Helper to create stat line
    local function CreateStatLine(label, value, valueColor)
        local line = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        line:SetPoint("TOPLEFT", content, "TOPLEFT", 10, yOffset)
        valueColor = valueColor or "FFFFFF"
        line:SetText(label .. ": |cFF" .. valueColor .. tostring(value) .. "|r")
        yOffset = yOffset - 16
        return line
    end
    
    --------------------------------------------------------------------------------
    -- Overview Section
    --------------------------------------------------------------------------------
    
    CreateHeader("Overview")
    CreateStatLine("Total Deaths", summary.totalDeaths)
    CreateStatLine("Session Deaths", summary.sessionDeaths, "FFFF00")
    CreateStatLine("Preventable", string.format("%d (%.0f%%)", summary.preventableDeaths, summary.preventablePercent), "FF6666")
    CreateStatLine("Unavoidable", string.format("%d (%.0f%%)", summary.unavoidableDeaths, summary.unavoidablePercent), "66FF66")
    CreateStatLine("Average Score", string.format("%.1f/10", summary.averageScore))
    CreateStatLine("Avoidable Damage", string.format("%.1f%%", summary.avoidablePercent), "FF8800")
    yOffset = yOffset - 10
    
    --------------------------------------------------------------------------------
    -- Top Killers Section
    --------------------------------------------------------------------------------
    
    CreateHeader("Top 5 Killing Abilities")
    local killerCount = math.min(5, #summary.topKillers)
    if killerCount == 0 then
        CreateStatLine("", "No data yet", "888888")
    else
        for i = 1, killerCount do
            local killer = summary.topKillers[i]
            CreateStatLine(killer.name, string.format("%d kills (%s damage)", 
                killer.count, self:FormatNumber(killer.totalDamage)), "FF6666")
        end
    end
    yOffset = yOffset - 10
    
    --------------------------------------------------------------------------------
    -- Top Sources Section
    --------------------------------------------------------------------------------
    
    CreateHeader("Top 5 Enemies")
    local sourceCount = math.min(5, #summary.topSources)
    if sourceCount == 0 then
        CreateStatLine("", "No data yet", "888888")
    else
        for i = 1, sourceCount do
            local source = summary.topSources[i]
            CreateStatLine(source.name, string.format("%d kills", source.count), "FF9999")
        end
    end
    yOffset = yOffset - 10
    
    --------------------------------------------------------------------------------
    -- Death Locations Section
    --------------------------------------------------------------------------------
    
    CreateHeader("Top 5 Death Locations")
    local zoneCount = math.min(5, #summary.topZones)
    if zoneCount == 0 then
        CreateStatLine("", "No data yet", "888888")
    else
        for i = 1, zoneCount do
            local zone = summary.topZones[i]
            CreateStatLine(zone.name, string.format("%d deaths", zone.count), "99CCFF")
        end
    end
    yOffset = yOffset - 10
    
    --------------------------------------------------------------------------------
    -- Unused Defensives Section
    --------------------------------------------------------------------------------
    
    CreateHeader("Most Unused Defensives")
    local defCount = math.min(5, #summary.mostUnusedDefensives)
    if defCount == 0 then
        CreateStatLine("", "No data yet", "888888")
    else
        for i = 1, defCount do
            local def = summary.mostUnusedDefensives[i]
            CreateStatLine(def.name, string.format("%d times", def.count), "FFCC00")
        end
    end
    yOffset = yOffset - 10
    
    --------------------------------------------------------------------------------
    -- Time Patterns Section
    --------------------------------------------------------------------------------
    
    CreateHeader("Time Patterns")
    if summary.deadliestHour and summary.deadliestHourCount > 0 then
        CreateStatLine("Deadliest Hour", string.format("%d:00 (%d deaths)", summary.deadliestHour, summary.deadliestHourCount))
    end
    if summary.deadliestDay and summary.deadliestDayCount > 0 then
        CreateStatLine("Deadliest Day", string.format("%s (%d deaths)", summary.deadliestDay, summary.deadliestDayCount))
    end
    
    -- Update content height
    content:SetHeight(math.abs(yOffset) + 20)
end

function DA:ToggleStatsWindow()
    if not self.statsFrame then
        self:CreateStatsWindow()
    end
    
    if self.statsFrame:IsShown() then
        self.statsFrame:Hide()
    else
        self:RefreshStatsWindow()
        self.statsFrame:Show()
    end
end

