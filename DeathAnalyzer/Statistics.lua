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

local STATS_WIDTH = 500
local STATS_HEIGHT = 580

-- Static popup for reset confirmation
StaticPopupDialogs["DEATHANALYZER_RESET_STATS"] = {
    text = "Are you sure you want to reset all death statistics?\n\nThis cannot be undone.",
    button1 = "Reset",
    button2 = "Cancel",
    OnAccept = function()
        DA:ResetStatistics()
        if DA.statsFrame and DA.statsFrame:IsShown() then
            DA:RefreshStatsWindow()
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

function DA:CreateStatsWindow()
    if self.statsFrame then return end

    local frame = CreateFrame("Frame", "DeathAnalyzerStatsFrame", UIParent, "BackdropTemplate")
    frame:SetSize(STATS_WIDTH, STATS_HEIGHT)
    frame:SetPoint("CENTER", UIParent, "CENTER", 150, 0)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetClampedToScreen(true)
    frame:SetFrameStrata("DIALOG")
    frame:SetFrameLevel(150)

    -- Backdrop
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 2,
    })
    frame:SetBackdropColor(0.08, 0.08, 0.08, 0.97)
    frame:SetBackdropBorderColor(0.2, 0.5, 0.2, 1)

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
    header:SetHeight(28)
    header:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -2)
    header:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2)
    header:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8" })
    header:SetBackdropColor(0.12, 0.12, 0.12, 1)

    -- Title with icon
    local titleIcon = header:CreateTexture(nil, "ARTWORK")
    titleIcon:SetSize(20, 20)
    titleIcon:SetPoint("LEFT", header, "LEFT", 8, 0)
    titleIcon:SetTexture("Interface\\Icons\\INV_Misc_Note_05")

    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("LEFT", titleIcon, "RIGHT", 6, 0)
    title:SetText("|cFF00FF00Death Analyzer|r - |cFFFFFFFFStatistics|r")

    -- Close button
    local closeBtn = CreateFrame("Button", nil, header, "BackdropTemplate")
    closeBtn:SetSize(20, 20)
    closeBtn:SetPoint("RIGHT", header, "RIGHT", -4, 0)
    closeBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    closeBtn:SetBackdropColor(0.5, 0.1, 0.1, 0.8)
    closeBtn:SetBackdropBorderColor(0.6, 0.2, 0.2, 1)
    local closeBtnText = closeBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    closeBtnText:SetPoint("CENTER", 0, 1)
    closeBtnText:SetText("|cFFFFFFFFX|r")
    closeBtn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.7, 0.2, 0.2, 1)
    end)
    closeBtn:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0.5, 0.1, 0.1, 0.8)
    end)
    closeBtn:SetScript("OnClick", function() frame:Hide() end)

    -- Reset button
    local resetBtn = CreateFrame("Button", nil, header, "BackdropTemplate")
    resetBtn:SetSize(60, 18)
    resetBtn:SetPoint("RIGHT", closeBtn, "LEFT", -8, 0)
    resetBtn:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    resetBtn:SetBackdropColor(0.3, 0.3, 0.3, 0.8)
    resetBtn:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
    local resetBtnText = resetBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    resetBtnText:SetPoint("CENTER", 0, 0)
    resetBtnText:SetText("|cFFFFFFFFReset|r")
    resetBtn:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.5, 0.3, 0.3, 1)
        GameTooltip:SetOwner(self, "ANCHOR_TOP")
        GameTooltip:SetText("Reset Statistics", 1, 1, 1)
        GameTooltip:AddLine("Clear all recorded death statistics", 0.7, 0.7, 0.7)
        GameTooltip:Show()
    end)
    resetBtn:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0.3, 0.3, 0.3, 0.8)
        GameTooltip:Hide()
    end)
    resetBtn:SetScript("OnClick", function()
        StaticPopup_Show("DEATHANALYZER_RESET_STATS")
    end)

    -- Scroll frame for content
    local scrollFrame = CreateFrame("ScrollFrame", "DeathAnalyzerStatsScrollFrame", frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 8, -8)
    scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -28, 8)

    -- Style the scrollbar
    local scrollBar = scrollFrame.ScrollBar or _G["DeathAnalyzerStatsScrollFrameScrollBar"]
    if scrollBar then
        scrollBar:SetPoint("TOPLEFT", scrollFrame, "TOPRIGHT", 2, -16)
        scrollBar:SetPoint("BOTTOMLEFT", scrollFrame, "BOTTOMRIGHT", 2, 16)
    end

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(STATS_WIDTH - 45, 1000)
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
    local contentWidth = STATS_WIDTH - 45

    -- Clear existing content
    for _, child in ipairs({content:GetChildren()}) do
        child:Hide()
        child:SetParent(nil)
    end
    for _, region in ipairs({content:GetRegions()}) do
        region:Hide()
    end

    local yOffset = -5

    --------------------------------------------------------------------------------
    -- Helper Functions
    --------------------------------------------------------------------------------

    -- Create section header with divider lines
    local function CreateSectionHeader(text)
        local container = CreateFrame("Frame", nil, content)
        container:SetSize(contentWidth, 22)
        container:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOffset)

        -- Left divider line
        local leftLine = container:CreateTexture(nil, "ARTWORK")
        leftLine:SetHeight(1)
        leftLine:SetPoint("LEFT", container, "LEFT", 0, 0)
        leftLine:SetPoint("RIGHT", container, "CENTER", -50, 0)
        leftLine:SetColorTexture(0.4, 0.6, 0.4, 0.6)

        -- Section text
        local label = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("CENTER", container, "CENTER", 0, 0)
        label:SetText("|cFFFFD100" .. text .. "|r")

        -- Right divider line
        local rightLine = container:CreateTexture(nil, "ARTWORK")
        rightLine:SetHeight(1)
        rightLine:SetPoint("LEFT", container, "CENTER", 50, 0)
        rightLine:SetPoint("RIGHT", container, "RIGHT", 0, 0)
        rightLine:SetColorTexture(0.4, 0.6, 0.4, 0.6)

        yOffset = yOffset - 28
        return container
    end

    -- Create a stat card (colored box with value)
    local function CreateStatCard(xOffset, width, label, value, valueColor, bgColor)
        local card = CreateFrame("Frame", nil, content, "BackdropTemplate")
        card:SetSize(width, 52)
        card:SetPoint("TOPLEFT", content, "TOPLEFT", xOffset, yOffset)
        card:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        bgColor = bgColor or {0.15, 0.15, 0.15}
        card:SetBackdropColor(bgColor[1], bgColor[2], bgColor[3], 0.9)
        card:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)

        -- Value (large text)
        local valueText = card:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        valueText:SetPoint("CENTER", card, "CENTER", 0, 6)
        valueColor = valueColor or "FFFFFF"
        valueText:SetText("|cFF" .. valueColor .. tostring(value) .. "|r")

        -- Label (small text below)
        local labelText = card:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        labelText:SetPoint("BOTTOM", card, "BOTTOM", 0, 6)
        labelText:SetText("|cFF888888" .. label .. "|r")

        return card
    end

    -- Create a progress bar with label
    local function CreateProgressBar(label, percent, fillColor, showPercent)
        local container = CreateFrame("Frame", nil, content)
        container:SetSize(contentWidth, 26)
        container:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOffset)

        -- Label
        local labelText = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        labelText:SetPoint("LEFT", container, "LEFT", 5, 0)
        labelText:SetText(label)

        -- Bar background
        local barBg = CreateFrame("Frame", nil, container, "BackdropTemplate")
        barBg:SetSize(200, 14)
        barBg:SetPoint("LEFT", container, "LEFT", 150, 0)
        barBg:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 1,
        })
        barBg:SetBackdropColor(0.1, 0.1, 0.1, 1)
        barBg:SetBackdropBorderColor(0.25, 0.25, 0.25, 1)

        -- Bar fill
        if percent > 0 then
            local barFill = barBg:CreateTexture(nil, "ARTWORK")
            barFill:SetHeight(12)
            barFill:SetPoint("LEFT", barBg, "LEFT", 1, 0)
            barFill:SetWidth(math.max(1, (198 * math.min(100, percent) / 100)))
            barFill:SetColorTexture(fillColor[1], fillColor[2], fillColor[3], 0.9)
        end

        -- Percentage text
        if showPercent ~= false then
            local percentText = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            percentText:SetPoint("LEFT", barBg, "RIGHT", 8, 0)
            percentText:SetText(string.format("|cFFFFFFFF%.1f%%|r", percent))
        end

        yOffset = yOffset - 24
        return container
    end

    -- Create a stat line with optional icon
    local function CreateStatLine(label, value, valueColor, spellID, indent)
        local lineHeight = 20
        local container = CreateFrame("Frame", nil, content)
        container:SetSize(contentWidth, lineHeight)
        container:SetPoint("TOPLEFT", content, "TOPLEFT", indent or 0, yOffset)

        local xPos = 5

        -- Spell icon if provided
        if spellID and spellID > 0 then
            local icon = container:CreateTexture(nil, "ARTWORK")
            icon:SetSize(16, 16)
            icon:SetPoint("LEFT", container, "LEFT", xPos, 0)
            local iconTexture = select(3, GetSpellInfo(spellID))
            if iconTexture then
                icon:SetTexture(iconTexture)
                icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
            else
                icon:SetTexture("Interface\\Icons\\INV_Misc_QuestionMark")
            end
            xPos = xPos + 20
        end

        -- Label
        local labelText = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        labelText:SetPoint("LEFT", container, "LEFT", xPos, 0)
        labelText:SetText("|cFFCCCCCC" .. label .. "|r")

        -- Value (right-aligned)
        local valueText = container:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        valueText:SetPoint("RIGHT", container, "RIGHT", -5, 0)
        valueColor = valueColor or "FFFFFF"
        valueText:SetText("|cFF" .. valueColor .. tostring(value) .. "|r")

        yOffset = yOffset - lineHeight
        return container
    end

    -- Create empty state message
    local function CreateEmptyState(message)
        local text = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        text:SetPoint("TOPLEFT", content, "TOPLEFT", 15, yOffset)
        text:SetText("|cFF666666" .. message .. "|r")
        yOffset = yOffset - 20
        return text
    end

    --------------------------------------------------------------------------------
    -- Stat Cards (Overview)
    --------------------------------------------------------------------------------

    -- First row of cards
    local cardWidth = (contentWidth - 15) / 4
    CreateStatCard(0, cardWidth, "Total Deaths", summary.totalDeaths, "FFFFFF", {0.15, 0.15, 0.2})
    CreateStatCard(cardWidth + 5, cardWidth, "This Session", summary.sessionDeaths, "FFD100", {0.2, 0.18, 0.1})
    CreateStatCard((cardWidth + 5) * 2, cardWidth, "Avg Score", string.format("%.1f", summary.averageScore), "00FF00", {0.1, 0.2, 0.1})
    CreateStatCard((cardWidth + 5) * 3, cardWidth, "Avoidable", string.format("%.0f%%", summary.avoidablePercent), "FF8800", {0.2, 0.15, 0.1})
    yOffset = yOffset - 60

    --------------------------------------------------------------------------------
    -- Death Breakdown Section
    --------------------------------------------------------------------------------

    CreateSectionHeader("Death Breakdown")

    -- Preventable vs Unavoidable progress bars
    CreateProgressBar("Preventable Deaths", summary.preventablePercent, {0.9, 0.3, 0.3})
    CreateProgressBar("Unavoidable Deaths", summary.unavoidablePercent, {0.3, 0.9, 0.3})
    CreateProgressBar("Avoidable Damage", summary.avoidablePercent, {1.0, 0.6, 0.2})
    yOffset = yOffset - 10

    --------------------------------------------------------------------------------
    -- Top Killers Section
    --------------------------------------------------------------------------------

    CreateSectionHeader("Top Killing Abilities")
    local killerCount = math.min(5, #summary.topKillers)
    if killerCount == 0 then
        CreateEmptyState("No deaths recorded yet. Die in dungeons or raids to start tracking!")
    else
        for i = 1, killerCount do
            local killer = summary.topKillers[i]
            local displayName = killer.name
            if #displayName > 25 then
                displayName = displayName:sub(1, 22) .. "..."
            end
            CreateStatLine(displayName,
                string.format("%d kills (%s)", killer.count, self:FormatNumber(killer.totalDamage)),
                "FF6666", killer.spellID)
        end
    end
    yOffset = yOffset - 10

    --------------------------------------------------------------------------------
    -- Top Enemies Section
    --------------------------------------------------------------------------------

    CreateSectionHeader("Top Enemies")
    local sourceCount = math.min(5, #summary.topSources)
    if sourceCount == 0 then
        CreateEmptyState("No enemy data recorded yet")
    else
        for i = 1, sourceCount do
            local source = summary.topSources[i]
            local displayName = source.name
            if #displayName > 28 then
                displayName = displayName:sub(1, 25) .. "..."
            end
            CreateStatLine(displayName, string.format("%d kills", source.count), "FF9999")
        end
    end
    yOffset = yOffset - 10

    --------------------------------------------------------------------------------
    -- Death Locations Section
    --------------------------------------------------------------------------------

    CreateSectionHeader("Death Locations")
    local zoneCount = math.min(5, #summary.topZones)
    if zoneCount == 0 then
        CreateEmptyState("No location data recorded yet")
    else
        for i = 1, zoneCount do
            local zone = summary.topZones[i]
            local displayName = zone.name
            if #displayName > 28 then
                displayName = displayName:sub(1, 25) .. "..."
            end
            CreateStatLine(displayName, string.format("%d deaths", zone.count), "7799FF")
        end
    end
    yOffset = yOffset - 10

    --------------------------------------------------------------------------------
    -- Unused Defensives Section
    --------------------------------------------------------------------------------

    CreateSectionHeader("Most Unused Defensives")
    local defCount = math.min(5, #summary.mostUnusedDefensives)
    if defCount == 0 then
        CreateEmptyState("No defensive data recorded yet")
    else
        for i = 1, defCount do
            local def = summary.mostUnusedDefensives[i]
            CreateStatLine(def.name, string.format("%d times", def.count), "FFCC00", def.spellID)
        end
    end
    yOffset = yOffset - 10

    --------------------------------------------------------------------------------
    -- Time Patterns Section
    --------------------------------------------------------------------------------

    CreateSectionHeader("Time Patterns")

    -- Session duration
    if self.stats and self.stats.sessionStart then
        local sessionDuration = time() - self.stats.sessionStart
        local hours = math.floor(sessionDuration / 3600)
        local minutes = math.floor((sessionDuration % 3600) / 60)
        local sessionText
        if hours > 0 then
            sessionText = string.format("%dh %dm", hours, minutes)
        else
            sessionText = string.format("%dm", minutes)
        end
        CreateStatLine("Session Duration", sessionText, "AAAAAA")
    end

    if summary.deadliestHour and summary.deadliestHourCount > 0 then
        local hourStr = string.format("%d:00 - %d:59", summary.deadliestHour, summary.deadliestHour)
        CreateStatLine("Deadliest Hour", string.format("%s (%d deaths)", hourStr, summary.deadliestHourCount), "FF7777")
    end

    if summary.deadliestDay and summary.deadliestDayCount > 0 then
        CreateStatLine("Deadliest Day", string.format("%s (%d deaths)", summary.deadliestDay, summary.deadliestDayCount), "FF7777")
    end

    -- First and last death timestamps
    if self.stats then
        if self.stats.firstDeath then
            CreateStatLine("First Recorded Death", date("%b %d, %Y", self.stats.firstDeath), "888888")
        end
        if self.stats.lastDeath then
            CreateStatLine("Last Death", date("%b %d, %Y %H:%M", self.stats.lastDeath), "888888")
        end
    end

    yOffset = yOffset - 15

    --------------------------------------------------------------------------------
    -- Hour Distribution Bar Chart
    --------------------------------------------------------------------------------

    if self.stats and self.stats.deathsByHour then
        local hasHourData = false
        local maxHourDeaths = 0
        for hour, count in pairs(self.stats.deathsByHour) do
            if count > 0 then
                hasHourData = true
                maxHourDeaths = math.max(maxHourDeaths, count)
            end
        end

        if hasHourData then
            CreateSectionHeader("Deaths by Hour")

            -- Create a simple bar chart for 24 hours
            local chartContainer = CreateFrame("Frame", nil, content, "BackdropTemplate")
            chartContainer:SetSize(contentWidth, 50)
            chartContainer:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOffset)
            chartContainer:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
            })
            chartContainer:SetBackdropColor(0.12, 0.12, 0.12, 0.8)

            local barWidth = (contentWidth - 10) / 24
            for hour = 0, 23 do
                local count = self.stats.deathsByHour[hour] or 0
                local barHeight = maxHourDeaths > 0 and (count / maxHourDeaths * 35) or 0

                if barHeight > 0 then
                    local bar = chartContainer:CreateTexture(nil, "ARTWORK")
                    bar:SetSize(barWidth - 2, math.max(2, barHeight))
                    bar:SetPoint("BOTTOM", chartContainer, "BOTTOMLEFT", 5 + hour * barWidth + barWidth/2, 12)

                    -- Color based on time of day
                    if hour >= 6 and hour < 12 then
                        bar:SetColorTexture(0.4, 0.7, 0.9, 0.8)  -- Morning - blue
                    elseif hour >= 12 and hour < 18 then
                        bar:SetColorTexture(0.9, 0.8, 0.3, 0.8)  -- Afternoon - yellow
                    elseif hour >= 18 and hour < 22 then
                        bar:SetColorTexture(0.9, 0.5, 0.3, 0.8)  -- Evening - orange
                    else
                        bar:SetColorTexture(0.5, 0.3, 0.7, 0.8)  -- Night - purple
                    end
                end
            end

            -- Hour labels
            local labelHours = {0, 6, 12, 18, 23}
            for _, hour in ipairs(labelHours) do
                local label = chartContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                label:SetPoint("BOTTOM", chartContainer, "BOTTOMLEFT", 5 + hour * barWidth + barWidth/2, 0)
                label:SetText("|cFF666666" .. hour .. "|r")
            end

            yOffset = yOffset - 58
        end
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

