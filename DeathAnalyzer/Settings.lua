--[[
    Settings Panel
    Modern settings window for Death Analyzer
]]

local ADDON_NAME, DA = ...

--------------------------------------------------------------------------------
-- Settings Window
--------------------------------------------------------------------------------

local SETTINGS_WIDTH = 440
local SETTINGS_HEIGHT = 580

-- Helper to create a styled section header with divider
local function CreateSectionHeader(parent, text, yOffset)
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(parent:GetWidth() - 20, 30)
    container:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, yOffset)

    -- Left divider line
    local leftLine = container:CreateTexture(nil, "ARTWORK")
    leftLine:SetSize(30, 1)
    leftLine:SetPoint("LEFT", container, "LEFT", 0, 0)
    leftLine:SetColorTexture(0.4, 0.6, 0.4, 0.6)

    -- Section text
    local label = container:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("LEFT", leftLine, "RIGHT", 8, 0)
    label:SetText("|cFFFFD100" .. text .. "|r")

    -- Right divider line
    local rightLine = container:CreateTexture(nil, "ARTWORK")
    rightLine:SetHeight(1)
    rightLine:SetPoint("LEFT", label, "RIGHT", 8, 0)
    rightLine:SetPoint("RIGHT", container, "RIGHT", 0, 0)
    rightLine:SetColorTexture(0.4, 0.6, 0.4, 0.6)

    return container, yOffset - 35
end

-- Helper to create a styled checkbox
local function CreateStyledCheckbox(parent, text, tooltip, yOffset, onClick)
    local check = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    check:SetSize(26, 26)
    check:SetPoint("TOPLEFT", parent, "TOPLEFT", 5, yOffset)

    local label = check:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetPoint("LEFT", check, "RIGHT", 4, 0)
    label:SetText(text)

    if tooltip then
        check.tooltipText = tooltip
        check:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(self.tooltipText, 1, 1, 1, 1, true)
            GameTooltip:Show()
        end)
        check:SetScript("OnLeave", function() GameTooltip:Hide() end)
    end

    check:SetScript("OnClick", onClick)

    return check, yOffset - 30
end

-- Helper to create a styled slider
local function CreateStyledSlider(parent, label, tooltip, min, max, step, yOffset, onValueChanged)
    -- Label row
    local labelText = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    labelText:SetPoint("TOPLEFT", parent, "TOPLEFT", 5, yOffset)
    labelText:SetText(label)

    -- Value display (right-aligned)
    local valueText = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    valueText:SetPoint("LEFT", labelText, "RIGHT", 8, 0)

    yOffset = yOffset - 22

    -- Slider background
    local sliderBg = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    sliderBg:SetSize(340, 20)
    sliderBg:SetPoint("TOPLEFT", parent, "TOPLEFT", 5, yOffset)
    sliderBg:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    sliderBg:SetBackdropColor(0.15, 0.15, 0.15, 0.8)
    sliderBg:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)

    -- Actual slider
    local slider = CreateFrame("Slider", nil, sliderBg, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", sliderBg, "TOPLEFT", 5, -3)
    slider:SetPoint("BOTTOMRIGHT", sliderBg, "BOTTOMRIGHT", -5, 3)
    slider:SetMinMaxValues(min, max)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)
    slider.Low:SetText(tostring(min))
    slider.High:SetText(tostring(max))
    slider.Text:SetText("")

    slider.valueText = valueText
    slider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value)
        onValueChanged(self, value, valueText)
    end)

    if tooltip then
        local tip = parent:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        tip:SetPoint("TOPLEFT", sliderBg, "BOTTOMLEFT", 0, -2)
        tip:SetText("|cFF888888" .. tooltip .. "|r")
        yOffset = yOffset - 38
    else
        yOffset = yOffset - 28
    end

    return slider, valueText, yOffset
end

function DA:CreateSettingsWindow()
    if self.settingsFrame then return end

    local frame = CreateFrame("Frame", "DeathAnalyzerSettingsFrame", UIParent, "BackdropTemplate")
    frame:SetSize(SETTINGS_WIDTH, SETTINGS_HEIGHT)
    frame:SetPoint("CENTER", UIParent, "CENTER", -150, 0)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetClampedToScreen(true)
    frame:SetFrameStrata("DIALOG")
    frame:SetFrameLevel(200)

    -- Modern backdrop
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 2,
    })
    frame:SetBackdropColor(0.08, 0.08, 0.08, 0.97)
    frame:SetBackdropBorderColor(0.3, 0.5, 0.3, 1)

    -- Make draggable
    frame:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then self:StartMoving() end
    end)
    frame:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() end)

    --------------------------------------------------------------------------------
    -- Header
    --------------------------------------------------------------------------------

    local header = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    header:SetHeight(36)
    header:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -2)
    header:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2)
    header:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8" })
    header:SetBackdropColor(0.15, 0.25, 0.15, 1)

    -- Icon
    local icon = header:CreateTexture(nil, "ARTWORK")
    icon:SetSize(24, 24)
    icon:SetPoint("LEFT", header, "LEFT", 10, 0)
    icon:SetTexture("Interface\\Icons\\Spell_Shadow_DeathCoil")
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    -- Title
    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("LEFT", icon, "RIGHT", 10, 0)
    title:SetText("|cFF00FF00Death Analyzer|r Settings")

    -- Version badge
    local versionBg = CreateFrame("Frame", nil, header, "BackdropTemplate")
    versionBg:SetSize(50, 18)
    versionBg:SetPoint("LEFT", title, "RIGHT", 10, 0)
    versionBg:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    versionBg:SetBackdropColor(0.2, 0.2, 0.2, 0.8)
    versionBg:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)

    local version = versionBg:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    version:SetPoint("CENTER", versionBg, "CENTER", 0, 0)
    version:SetText("v" .. DA.VERSION)
    version:SetTextColor(0.7, 0.7, 0.7)

    -- Close button
    local closeBtn = CreateFrame("Button", nil, header, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", header, "TOPRIGHT", 4, 4)
    closeBtn:SetScript("OnClick", function() frame:Hide() end)

    --------------------------------------------------------------------------------
    -- Scrollable Content Area
    --------------------------------------------------------------------------------

    local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 8, -8)
    scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -28, 50)

    local content = CreateFrame("Frame", nil, scrollFrame)
    content:SetSize(SETTINGS_WIDTH - 50, 600)
    scrollFrame:SetScrollChild(content)

    local yOffset = 0

    --------------------------------------------------------------------------------
    -- Recording Settings
    --------------------------------------------------------------------------------

    local _, newY = CreateSectionHeader(content, "Recording", yOffset)
    yOffset = newY

    -- Buffer Duration Slider
    local bufferSlider, bufferValue
    bufferSlider, bufferValue, yOffset = CreateStyledSlider(
        content,
        "Event Buffer Duration:",
        "How many seconds of combat events to record before death",
        5, 30, 1, yOffset,
        function(self, value, valueText)
            DeathAnalyzerDB.bufferDuration = value
            valueText:SetText("|cFFFFFFFF" .. value .. "s|r")
        end
    )
    frame.bufferSlider = bufferSlider
    frame.bufferValue = bufferValue

    yOffset = yOffset - 5

    -- Max Snapshots Slider
    local snapshotsSlider, snapshotsValue
    snapshotsSlider, snapshotsValue, yOffset = CreateStyledSlider(
        content,
        "Maximum Deaths Stored:",
        "Older deaths are automatically removed when limit is reached",
        10, 100, 10, yOffset,
        function(self, value, valueText)
            DeathAnalyzerDB.maxSnapshots = value
            valueText:SetText("|cFFFFFFFF" .. value .. "|r")
        end
    )
    frame.snapshotsSlider = snapshotsSlider
    frame.snapshotsValue = snapshotsValue

    --------------------------------------------------------------------------------
    -- Display Settings
    --------------------------------------------------------------------------------

    yOffset = yOffset - 10
    local _, newY2 = CreateSectionHeader(content, "Display", yOffset)
    yOffset = newY2

    -- Show Popup on Death
    local popupCheck
    popupCheck, yOffset = CreateStyledCheckbox(
        content,
        "Show analysis popup when you die",
        "Automatically display the death analysis window after each death",
        yOffset,
        function(self) DeathAnalyzerDB.showPopupOnDeath = self:GetChecked() end
    )
    frame.popupCheck = popupCheck

    -- Minimap Button
    local minimapCheck
    minimapCheck, yOffset = CreateStyledCheckbox(
        content,
        "Show minimap button",
        "Display a button on the minimap for quick access",
        yOffset,
        function(self)
            if self:GetChecked() then
                if DA.ShowMinimapButton then DA:ShowMinimapButton() end
            else
                if DA.HideMinimapButton then DA:HideMinimapButton() end
            end
        end
    )
    frame.minimapCheck = minimapCheck

    -- Announce to Chat
    local chatCheck
    chatCheck, yOffset = CreateStyledCheckbox(
        content,
        "Announce death summary to party/raid chat",
        "Share a brief death summary with your group (may be annoying - use sparingly!)",
        yOffset,
        function(self) DeathAnalyzerDB.announceToChat = self:GetChecked() end
    )
    frame.chatCheck = chatCheck

    --------------------------------------------------------------------------------
    -- Analysis Settings
    --------------------------------------------------------------------------------

    yOffset = yOffset - 10
    local _, newY3 = CreateSectionHeader(content, "Analysis", yOffset)
    yOffset = newY3

    -- Include consumables in analysis
    local consumablesCheck
    consumablesCheck, yOffset = CreateStyledCheckbox(
        content,
        "Include Healthstones & Potions in survival analysis",
        "Suggest healthstones and healing potions that could have saved you (only if you have them in bags)",
        yOffset,
        function(self)
            DeathAnalyzerDB.includeConsumables = self:GetChecked()
            if DA.InitializeDefensives then DA:InitializeDefensives() end
        end
    )
    frame.consumablesCheck = consumablesCheck

    -- Track external cooldowns
    local externalsCheck
    externalsCheck, yOffset = CreateStyledCheckbox(
        content,
        "Track healer external cooldowns",
        "Analyze external defensives (Pain Suppression, Guardian Spirit, etc.) that were active or available",
        yOffset,
        function(self) DeathAnalyzerDB.trackExternals = self:GetChecked() end
    )
    frame.externalsCheck = externalsCheck

    --------------------------------------------------------------------------------
    -- Keyboard Shortcuts
    --------------------------------------------------------------------------------

    yOffset = yOffset - 10
    local _, newY4 = CreateSectionHeader(content, "Keyboard Shortcuts", yOffset)
    yOffset = newY4

    -- Keybind info text
    local keybindInfo = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    keybindInfo:SetPoint("TOPLEFT", content, "TOPLEFT", 5, yOffset)
    keybindInfo:SetText("|cFF888888Set keybindings in the WoW Keybindings menu under 'AddOns'|r")
    yOffset = yOffset - 20

    -- Current keybinds display
    local keybindFrame = CreateFrame("Frame", nil, content, "BackdropTemplate")
    keybindFrame:SetSize(340, 50)
    keybindFrame:SetPoint("TOPLEFT", content, "TOPLEFT", 5, yOffset)
    keybindFrame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    keybindFrame:SetBackdropColor(0.12, 0.12, 0.12, 0.8)
    keybindFrame:SetBackdropBorderColor(0.25, 0.25, 0.25, 1)

    local keybindText = keybindFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    keybindText:SetPoint("TOPLEFT", keybindFrame, "TOPLEFT", 8, -8)
    keybindText:SetText("|cFFCCCCCCToggle Window:|r  Not Set\n|cFFCCCCCCOpen Last Death:|r  Not Set")
    frame.keybindText = keybindText

    yOffset = yOffset - 60

    --------------------------------------------------------------------------------
    -- Data Management
    --------------------------------------------------------------------------------

    yOffset = yOffset - 10
    local _, newY5 = CreateSectionHeader(content, "Data Management", yOffset)
    yOffset = newY5

    -- Stats display
    local statsFrame = CreateFrame("Frame", nil, content, "BackdropTemplate")
    statsFrame:SetSize(340, 45)
    statsFrame:SetPoint("TOPLEFT", content, "TOPLEFT", 5, yOffset)
    statsFrame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    statsFrame:SetBackdropColor(0.12, 0.12, 0.12, 0.8)
    statsFrame:SetBackdropBorderColor(0.25, 0.25, 0.25, 1)

    local deathCountLabel = statsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    deathCountLabel:SetPoint("LEFT", statsFrame, "LEFT", 10, 0)
    frame.deathCountLabel = deathCountLabel

    yOffset = yOffset - 55

    -- Action buttons row
    local resetBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    resetBtn:SetPoint("TOPLEFT", content, "TOPLEFT", 5, yOffset)
    resetBtn:SetSize(105, 26)
    resetBtn:SetText("Reset Deaths")
    resetBtn:SetScript("OnClick", function()
        StaticPopup_Show("DEATHANALYZER_RESET_CONFIRM")
    end)

    local resetStatsBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    resetStatsBtn:SetPoint("LEFT", resetBtn, "RIGHT", 8, 0)
    resetStatsBtn:SetSize(105, 26)
    resetStatsBtn:SetText("Reset Statistics")
    resetStatsBtn:SetScript("OnClick", function()
        StaticPopup_Show("DEATHANALYZER_RESET_STATS_CONFIRM")
    end)

    local defaultsBtn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    defaultsBtn:SetPoint("LEFT", resetStatsBtn, "RIGHT", 8, 0)
    defaultsBtn:SetSize(105, 26)
    defaultsBtn:SetText("Reset Settings")
    defaultsBtn:SetScript("OnClick", function()
        StaticPopup_Show("DEATHANALYZER_RESET_SETTINGS_CONFIRM")
    end)

    --------------------------------------------------------------------------------
    -- Footer
    --------------------------------------------------------------------------------

    local footer = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    footer:SetHeight(40)
    footer:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 2, 2)
    footer:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 2)
    footer:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8" })
    footer:SetBackdropColor(0.1, 0.1, 0.1, 0.9)

    -- Help text
    local helpText = footer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    helpText:SetPoint("LEFT", footer, "LEFT", 10, 0)
    helpText:SetText("|cFF888888Type |cFFFFFFFF/da help|r|cFF888888 for commands  |  |cFFFFFFFF/da stats|r|cFF888888 for statistics  |  |cFFFFFFFF/da guide|r|cFF888888 for mechanics|r")

    --------------------------------------------------------------------------------
    -- OnShow refresh
    --------------------------------------------------------------------------------

    frame:SetScript("OnShow", function(self)
        local db = DeathAnalyzerDB

        self.bufferSlider:SetValue(db.bufferDuration or 15)
        self.bufferValue:SetText("|cFFFFFFFF" .. (db.bufferDuration or 15) .. "s|r")

        self.snapshotsSlider:SetValue(db.maxSnapshots or 50)
        self.snapshotsValue:SetText("|cFFFFFFFF" .. (db.maxSnapshots or 50) .. "|r")

        self.popupCheck:SetChecked(db.showPopupOnDeath)
        self.chatCheck:SetChecked(db.announceToChat)
        self.minimapCheck:SetChecked(db.minimapIcon)
        self.consumablesCheck:SetChecked(db.includeConsumables ~= false)
        self.externalsCheck:SetChecked(db.trackExternals ~= false)

        -- Update death count display
        local deaths = #DA.deathSnapshots
        local stats = DA.stats or {}
        self.deathCountLabel:SetText(string.format(
            "|cFFCCCCCCRecorded:|r |cFFFFFFFF%d|r deaths    |cFFCCCCCCSession:|r |cFFFFFF00%d|r",
            deaths,
            stats.sessionDeaths or 0
        ))

        -- Update keybind display
        local toggleBind = GetBindingKey("DEATHANALYZER_TOGGLE") or "Not Set"
        local lastBind = GetBindingKey("DEATHANALYZER_LAST") or "Not Set"
        self.keybindText:SetText(string.format(
            "|cFFCCCCCCToggle Window:|r  |cFFFFFFFF%s|r\n|cFFCCCCCCShow Last Death:|r  |cFFFFFFFF%s|r",
            toggleBind, lastBind
        ))
    end)

    self.settingsFrame = frame
    frame:Hide()

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
            DA.settingsFrame.deathCountLabel:SetText("|cFFCCCCCCRecorded:|r |cFFFFFFFF0|r deaths    |cFFCCCCCCSession:|r |cFFFFFF000|r")
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
        if DA.ResetStatistics then DA:ResetStatistics() end
        DA:Print("Statistics reset.")
    end,
    timeout = 0,
    whileDead = true,
    hideOnEscape = true,
    preferredIndex = 3,
}

StaticPopupDialogs["DEATHANALYZER_RESET_SETTINGS_CONFIRM"] = {
    text = "Reset all settings to default values?\n\nThis will not delete your death records.",
    button1 = "Yes, Reset",
    button2 = "Cancel",
    OnAccept = function()
        -- Reset to defaults
        for k, v in pairs(DA.defaults) do
            DeathAnalyzerDB[k] = v
        end
        DA:Print("Settings reset to defaults.")
        -- Refresh the settings window
        if DA.settingsFrame and DA.settingsFrame:IsShown() then
            DA.settingsFrame:Hide()
            DA.settingsFrame:Show()
        end
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
    self:CreateSettingsWindow()
    self:Debug("Settings window initialized")
end
