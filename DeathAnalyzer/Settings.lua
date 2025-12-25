--[[
    Settings Panel
    Custom settings window for Death Analyzer
]]

local ADDON_NAME, DA = ...

--------------------------------------------------------------------------------
-- Settings Window
--------------------------------------------------------------------------------

local SETTINGS_WIDTH = 400
local SETTINGS_HEIGHT = 520

function DA:CreateSettingsWindow()
    if self.settingsFrame then return end
    
    local frame = CreateFrame("Frame", "DeathAnalyzerSettingsFrame", UIParent, "BackdropTemplate")
    frame:SetSize(SETTINGS_WIDTH, SETTINGS_HEIGHT)
    frame:SetPoint("CENTER", UIParent, "CENTER", -150, 0) -- Offset left of center
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetClampedToScreen(true)
    frame:SetFrameStrata("DIALOG")
    frame:SetFrameLevel(200)
    
    -- Backdrop
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 2,
    })
    frame:SetBackdropColor(0.1, 0.1, 0.1, 0.95)
    frame:SetBackdropBorderColor(0.3, 0.6, 0.3, 1)
    
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
    header:SetBackdropColor(0.2, 0.4, 0.2, 1)
    
    -- Title
    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("LEFT", header, "LEFT", 10, 0)
    title:SetText("|cFF00FF00Death Analyzer|r Settings")
    
    -- Version
    local version = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    version:SetPoint("LEFT", title, "RIGHT", 10, 0)
    version:SetText("v" .. DA.VERSION)
    version:SetTextColor(0.6, 0.6, 0.6)
    
    -- Close button
    local closeBtn = CreateFrame("Button", nil, header, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", header, "TOPRIGHT", 4, 4)
    closeBtn:SetScript("OnClick", function() frame:Hide() end)
    
    -- Content area
    local content = CreateFrame("Frame", nil, frame)
    content:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 10, -10)
    content:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 10)
    
    local yOffset = 0
    
    --------------------------------------------------------------------------------
    -- General Settings Section
    --------------------------------------------------------------------------------
    
    local generalHeader = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    generalHeader:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOffset)
    generalHeader:SetText("|cFFFFCC00General Settings|r")
    yOffset = yOffset - 30
    
    -- Buffer Duration Slider
    local bufferLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    bufferLabel:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOffset)
    bufferLabel:SetText("Event Buffer Duration:")
    
    local bufferValue = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    bufferValue:SetPoint("LEFT", bufferLabel, "RIGHT", 5, 0)
    frame.bufferValue = bufferValue
    yOffset = yOffset - 20
    
    local bufferSlider = CreateFrame("Slider", "DASettingsBufferSlider", content, "OptionsSliderTemplate")
    bufferSlider:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOffset)
    bufferSlider:SetWidth(250)
    bufferSlider:SetMinMaxValues(5, 30)
    bufferSlider:SetValueStep(1)
    bufferSlider:SetObeyStepOnDrag(true)
    bufferSlider.Low:SetText("5s")
    bufferSlider.High:SetText("30s")
    bufferSlider.Text:SetText("")
    bufferSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value)
        DeathAnalyzerDB.bufferDuration = value
        bufferValue:SetText(value .. " seconds")
    end)
    frame.bufferSlider = bufferSlider
    
    local bufferTip = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    bufferTip:SetPoint("TOPLEFT", bufferSlider, "BOTTOMLEFT", 0, -2)
    bufferTip:SetText("How many seconds of combat to track before death")
    bufferTip:SetTextColor(0.5, 0.5, 0.5)
    yOffset = yOffset - 50
    
    -- Max Snapshots Slider
    local snapshotsLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    snapshotsLabel:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOffset)
    snapshotsLabel:SetText("Maximum Deaths Stored:")
    
    local snapshotsValue = content:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    snapshotsValue:SetPoint("LEFT", snapshotsLabel, "RIGHT", 5, 0)
    frame.snapshotsValue = snapshotsValue
    yOffset = yOffset - 20
    
    local snapshotsSlider = CreateFrame("Slider", "DASettingsSnapshotsSlider", content, "OptionsSliderTemplate")
    snapshotsSlider:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOffset)
    snapshotsSlider:SetWidth(250)
    snapshotsSlider:SetMinMaxValues(10, 100)
    snapshotsSlider:SetValueStep(10)
    snapshotsSlider:SetObeyStepOnDrag(true)
    snapshotsSlider.Low:SetText("10")
    snapshotsSlider.High:SetText("100")
    snapshotsSlider.Text:SetText("")
    snapshotsSlider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value)
        DeathAnalyzerDB.maxSnapshots = value
        snapshotsValue:SetText(value .. " deaths")
    end)
    frame.snapshotsSlider = snapshotsSlider
    
    local snapshotsTip = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    snapshotsTip:SetPoint("TOPLEFT", snapshotsSlider, "BOTTOMLEFT", 0, -2)
    snapshotsTip:SetText("Older deaths are removed when limit is reached")
    snapshotsTip:SetTextColor(0.5, 0.5, 0.5)
    yOffset = yOffset - 60
    
    --------------------------------------------------------------------------------
    -- Display Settings Section
    --------------------------------------------------------------------------------
    
    local displayHeader = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    displayHeader:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOffset)
    displayHeader:SetText("|cFFFFCC00Display Settings|r")
    yOffset = yOffset - 30
    
    -- Show Popup on Death
    local popupCheck = CreateFrame("CheckButton", "DASettingsPopupCheck", content, "UICheckButtonTemplate")
    popupCheck:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOffset)
    popupCheck.text:SetText("  Show analysis popup when you die")
    popupCheck.text:SetFontObject("GameFontNormal")
    popupCheck:SetScript("OnClick", function(self)
        DeathAnalyzerDB.showPopupOnDeath = self:GetChecked()
    end)
    frame.popupCheck = popupCheck
    yOffset = yOffset - 28
    
    -- Announce to Chat
    local chatCheck = CreateFrame("CheckButton", "DASettingsChatCheck", content, "UICheckButtonTemplate")
    chatCheck:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOffset)
    chatCheck.text:SetText("  Announce death summary to chat")
    chatCheck.text:SetFontObject("GameFontNormal")
    chatCheck:SetScript("OnClick", function(self)
        DeathAnalyzerDB.announceToChat = self:GetChecked()
    end)
    frame.chatCheck = chatCheck
    yOffset = yOffset - 28
    
    -- Minimap Button
    local minimapCheck = CreateFrame("CheckButton", "DASettingsMinimapCheck", content, "UICheckButtonTemplate")
    minimapCheck:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOffset)
    minimapCheck.text:SetText("  Show minimap button")
    minimapCheck.text:SetFontObject("GameFontNormal")
    minimapCheck:SetScript("OnClick", function(self)
        if self:GetChecked() then
            if DA.ShowMinimapButton then DA:ShowMinimapButton() end
        else
            if DA.HideMinimapButton then DA:HideMinimapButton() end
        end
    end)
    frame.minimapCheck = minimapCheck
    yOffset = yOffset - 40
    
    --------------------------------------------------------------------------------
    -- Analysis Settings Section
    --------------------------------------------------------------------------------
    
    local analysisHeader = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    analysisHeader:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOffset)
    analysisHeader:SetText("|cFFFFCC00Analysis Settings|r")
    yOffset = yOffset - 30
    
    -- Include consumables in analysis
    local consumablesCheck = CreateFrame("CheckButton", "DASettingsConsumablesCheck", content, "UICheckButtonTemplate")
    consumablesCheck:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOffset)
    consumablesCheck.text:SetText("  Include Healthstones & Potions in analysis")
    consumablesCheck.text:SetFontObject("GameFontNormal")
    consumablesCheck:SetScript("OnClick", function(self)
        DeathAnalyzerDB.includeConsumables = self:GetChecked()
        -- Reinitialize defensives to update the list
        if DA.InitializeDefensives then
            DA:InitializeDefensives()
        end
    end)
    frame.consumablesCheck = consumablesCheck
    
    local consumablesTip = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    consumablesTip:SetPoint("TOPLEFT", consumablesCheck.text, "BOTTOMLEFT", 0, -2)
    consumablesTip:SetText("Only suggests items actually in your bags")
    consumablesTip:SetTextColor(0.5, 0.5, 0.5)
    yOffset = yOffset - 50
    
    --------------------------------------------------------------------------------
    -- Data Management Section
    --------------------------------------------------------------------------------
    
    local dataHeader = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    dataHeader:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOffset)
    dataHeader:SetText("|cFFFFCC00Data Management|r")
    yOffset = yOffset - 30
    
    -- Death count
    local deathCountLabel = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    deathCountLabel:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOffset)
    frame.deathCountLabel = deathCountLabel
    yOffset = yOffset - 30
    
    -- Reset Deaths button
    local resetBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    resetBtn:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOffset)
    resetBtn:SetSize(130, 26)
    resetBtn:SetText("Reset Deaths")
    resetBtn:SetScript("OnClick", function()
        StaticPopup_Show("DEATHANALYZER_RESET_CONFIRM")
    end)
    
    -- Reset Stats button
    local resetStatsBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    resetStatsBtn:SetPoint("LEFT", resetBtn, "RIGHT", 10, 0)
    resetStatsBtn:SetSize(130, 26)
    resetStatsBtn:SetText("Reset Statistics")
    resetStatsBtn:SetScript("OnClick", function()
        StaticPopup_Show("DEATHANALYZER_RESET_STATS_CONFIRM")
    end)
    
    --------------------------------------------------------------------------------
    -- OnShow refresh
    --------------------------------------------------------------------------------
    
    frame:SetScript("OnShow", function(self)
        -- Refresh all values
        local db = DeathAnalyzerDB
        
        self.bufferSlider:SetValue(db.bufferDuration or 15)
        self.bufferValue:SetText((db.bufferDuration or 15) .. " seconds")
        
        self.snapshotsSlider:SetValue(db.maxSnapshots or 50)
        self.snapshotsValue:SetText((db.maxSnapshots or 50) .. " deaths")
        
        self.popupCheck:SetChecked(db.showPopupOnDeath)
        self.chatCheck:SetChecked(db.announceToChat)
        self.minimapCheck:SetChecked(db.minimapIcon)
        self.consumablesCheck:SetChecked(db.includeConsumables ~= false) -- default true
        
        self.deathCountLabel:SetText("Deaths recorded: |cFFFFFFFF" .. #DA.deathSnapshots .. "|r")
    end)
    
    self.settingsFrame = frame
    frame:Hide()
    
    -- Make ESC close the window
    tinsert(UISpecialFrames, "DeathAnalyzerSettingsFrame")
    
    return frame
end

--------------------------------------------------------------------------------
-- Confirmation Dialogs
--------------------------------------------------------------------------------

StaticPopupDialogs["DEATHANALYZER_RESET_CONFIRM"] = {
    text = "Are you sure you want to delete all death records?\n\nThis cannot be undone.",
    button1 = "Yes, Delete",
    button2 = "Cancel",
    OnAccept = function()
        DA:ResetData()
        if DA.settingsFrame and DA.settingsFrame:IsShown() then
            DA.settingsFrame.deathCountLabel:SetText("Deaths recorded: |cFFFFFFFF0|r")
        end
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

StaticPopupDialogs["DEATHANALYZER_RESET_STATS_CONFIRM"] = {
    text = "Are you sure you want to reset all statistics?\n\nThis cannot be undone.",
    button1 = "Yes, Reset",
    button2 = "Cancel",
    OnAccept = function()
        if DA.ResetStatistics then
            DA:ResetStatistics()
        end
        DA:Print("Statistics reset.")
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

--------------------------------------------------------------------------------
-- Open/Toggle Settings
--------------------------------------------------------------------------------

function DA:OpenSettings()
    if not self.settingsFrame then
        self:CreateSettingsWindow()
    end
    self.settingsFrame:Show()
end

function DA:ToggleSettings()
    if not self.settingsFrame then
        self:CreateSettingsWindow()
    end
    
    if self.settingsFrame:IsShown() then
        self.settingsFrame:Hide()
    else
        self.settingsFrame:Show()
    end
end

--------------------------------------------------------------------------------
-- Initialize
--------------------------------------------------------------------------------

function DA:InitializeSettings()
    -- Pre-create the settings window
    self:CreateSettingsWindow()
    self:Debug("Settings window initialized")
end
