--[[
    Death Analyzer UI
    Main window and death analysis display

    UI/UX Overhaul - Modern, polished interface with animations and visual hierarchy
]]

local ADDON_NAME, DA = ...

--------------------------------------------------------------------------------
-- Theme System - Centralized colors for consistency across all UI
--------------------------------------------------------------------------------

DA.Theme = {
    -- Primary backgrounds
    background = { 0.06, 0.06, 0.08, 0.97 },
    backgroundLight = { 0.10, 0.10, 0.12, 0.95 },
    backgroundDark = { 0.04, 0.04, 0.05, 0.98 },

    -- Panel backgrounds
    panelBg = { 0.08, 0.08, 0.10, 0.95 },
    panelBgHover = { 0.12, 0.12, 0.14, 0.95 },

    -- Accent colors (Green - addon identity)
    accent = { 0.35, 0.75, 0.35, 1 },
    accentBright = { 0.45, 0.85, 0.45, 1 },
    accentDim = { 0.25, 0.55, 0.25, 1 },
    accentGlow = { 0.35, 0.75, 0.35, 0.3 },

    -- Secondary accents
    gold = { 1, 0.82, 0, 1 },
    goldDim = { 0.8, 0.65, 0, 1 },

    -- Borders
    border = { 0.22, 0.22, 0.25, 1 },
    borderLight = { 0.35, 0.35, 0.38, 1 },
    borderAccent = { 0.35, 0.75, 0.35, 0.8 },

    -- Severity scale (for verdicts and damage)
    critical = { 1, 0.25, 0.25, 1 },      -- Bright red
    warning = { 1, 0.55, 0.15, 1 },       -- Orange
    caution = { 1, 0.85, 0.25, 1 },       -- Yellow
    good = { 0.25, 0.9, 0.4, 1 },         -- Green

    -- Event type colors
    damage = { 1, 0.35, 0.35, 1 },
    healing = { 0.35, 1, 0.45, 1 },
    avoidable = { 1, 0.55, 0.15, 1 },
    defensive = { 1, 0.8, 0.2, 1 },
    buff = { 0.4, 0.75, 1, 1 },

    -- Text colors
    textPrimary = { 1, 1, 1, 1 },
    textSecondary = { 0.75, 0.75, 0.78, 1 },
    textMuted = { 0.5, 0.5, 0.52, 1 },
    textHighlight = { 0.35, 0.75, 0.35, 1 },

    -- Score meter gradient points
    scoreLow = { 1, 0.25, 0.25, 1 },      -- 0-3: Red
    scoreMid = { 1, 0.75, 0.15, 1 },      -- 4-6: Orange/Yellow
    scoreHigh = { 0.35, 0.9, 0.35, 1 },   -- 7-10: Green
}

-- Legacy color mapping for backwards compatibility
local COLORS = {
    DAMAGE = DA.Theme.damage,
    HEALING = DA.Theme.healing,
    BUFF_GAIN = DA.Theme.buff,
    BUFF_FADE = DA.Theme.textMuted,
    DEFENSIVE_USED = DA.Theme.defensive,
    AVOIDABLE = DA.Theme.avoidable,
    BACKGROUND = DA.Theme.background,
    BORDER = DA.Theme.border,
    HEADER = DA.Theme.backgroundLight,
}

--------------------------------------------------------------------------------
-- Layout Constants
--------------------------------------------------------------------------------

local FRAME_WIDTH = 520
local FRAME_HEIGHT = 480
local HEADER_HEIGHT = 32          -- Increased from 24 for larger touch targets
local PANEL_HEADER_HEIGHT = 24
local TIMELINE_ENTRY_HEIGHT = 28  -- Increased from 18 for better readability
local DEFENSIVE_ENTRY_HEIGHT = 32 -- Increased from 22
local BUTTON_SIZE = 24            -- Increased from 16
local PADDING = 8
local PANEL_SPACING = 6
local TIMELINE_HEIGHT = 180       -- Height for timeline panel
local HEALTH_GRAPH_HEIGHT = 70    -- Height for health graph

--------------------------------------------------------------------------------
-- Animation Helpers
--------------------------------------------------------------------------------

function DA:FadeIn(frame, duration, callback)
    if not frame then return end
    duration = duration or 0.2
    frame:SetAlpha(0)
    frame:Show()

    local elapsed = 0
    frame:SetScript("OnUpdate", function(self, dt)
        elapsed = elapsed + dt
        local progress = math.min(elapsed / duration, 1)
        self:SetAlpha(progress)
        if progress >= 1 then
            self:SetScript("OnUpdate", nil)
            if callback then callback() end
        end
    end)
end

function DA:FadeOut(frame, duration, callback)
    if not frame then return end
    duration = duration or 0.2

    local startAlpha = frame:GetAlpha()
    local elapsed = 0
    frame:SetScript("OnUpdate", function(self, dt)
        elapsed = elapsed + dt
        local progress = math.min(elapsed / duration, 1)
        self:SetAlpha(startAlpha * (1 - progress))
        if progress >= 1 then
            self:SetScript("OnUpdate", nil)
            self:Hide()
            self:SetAlpha(1)
            if callback then callback() end
        end
    end)
end

-- Get score color based on value (0-10)
function DA:GetScoreColor(score)
    if score <= 3 then
        return unpack(DA.Theme.scoreLow)
    elseif score <= 6 then
        -- Interpolate between low and mid
        local t = (score - 3) / 3
        return
            DA.Theme.scoreLow[1] + (DA.Theme.scoreMid[1] - DA.Theme.scoreLow[1]) * t,
            DA.Theme.scoreLow[2] + (DA.Theme.scoreMid[2] - DA.Theme.scoreLow[2]) * t,
            DA.Theme.scoreLow[3] + (DA.Theme.scoreMid[3] - DA.Theme.scoreLow[3]) * t,
            1
    else
        -- Interpolate between mid and high
        local t = (score - 6) / 4
        return
            DA.Theme.scoreMid[1] + (DA.Theme.scoreHigh[1] - DA.Theme.scoreMid[1]) * t,
            DA.Theme.scoreMid[2] + (DA.Theme.scoreHigh[2] - DA.Theme.scoreMid[2]) * t,
            DA.Theme.scoreMid[3] + (DA.Theme.scoreHigh[3] - DA.Theme.scoreMid[3]) * t,
            1
    end
end

--------------------------------------------------------------------------------
-- UI Helper Functions
--------------------------------------------------------------------------------

-- Create a styled button with hover effects
local function CreateStyledButton(parent, size, icon, tooltip)
    local btn = CreateFrame("Button", nil, parent)
    btn:SetSize(size, size)

    -- Icon texture
    local iconTex = btn:CreateTexture(nil, "ARTWORK")
    iconTex:SetSize(size - 4, size - 4)
    iconTex:SetPoint("CENTER")
    iconTex:SetTexture(icon)
    iconTex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    btn.icon = iconTex

    -- Hover glow
    local glow = btn:CreateTexture(nil, "BACKGROUND")
    glow:SetPoint("TOPLEFT", -2, 2)
    glow:SetPoint("BOTTOMRIGHT", 2, -2)
    glow:SetTexture("Interface\\Buttons\\WHITE8x8")
    glow:SetVertexColor(unpack(DA.Theme.accentGlow))
    glow:SetAlpha(0)
    btn.glow = glow

    -- Hover effects
    btn:SetScript("OnEnter", function(self)
        self.glow:SetAlpha(1)
        self.icon:SetVertexColor(1.2, 1.2, 1.2)
        if tooltip then
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText(tooltip)
            GameTooltip:Show()
        end
    end)

    btn:SetScript("OnLeave", function(self)
        self.glow:SetAlpha(0)
        self.icon:SetVertexColor(1, 1, 1)
        GameTooltip:Hide()
    end)

    return btn
end

-- Create a panel header with accent bar
local function CreatePanelHeader(parent, title, collapsible)
    local header = CreateFrame("Frame", nil, parent)
    header:SetHeight(PANEL_HEADER_HEIGHT)

    -- Left accent bar
    local accent = header:CreateTexture(nil, "ARTWORK")
    accent:SetSize(3, 16)
    accent:SetPoint("LEFT", header, "LEFT", 0, 0)
    accent:SetColorTexture(unpack(DA.Theme.accent))
    header.accent = accent

    -- Title text
    local titleText = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    titleText:SetPoint("LEFT", accent, "RIGHT", 8, 0)
    titleText:SetTextColor(unpack(DA.Theme.textPrimary))
    titleText:SetText(title)
    header.title = titleText

    -- Collapse button (if collapsible)
    if collapsible then
        local collapseBtn = CreateFrame("Button", nil, header)
        collapseBtn:SetSize(16, 16)
        collapseBtn:SetPoint("RIGHT", header, "RIGHT", -4, 0)

        local collapseTex = collapseBtn:CreateTexture(nil, "ARTWORK")
        collapseTex:SetAllPoints()
        collapseTex:SetTexture("Interface\\Buttons\\UI-MinusButton-UP")
        collapseBtn.texture = collapseTex
        collapseBtn.collapsed = false

        collapseBtn:SetScript("OnEnter", function(self)
            self.texture:SetVertexColor(1.3, 1.3, 1.3)
        end)
        collapseBtn:SetScript("OnLeave", function(self)
            self.texture:SetVertexColor(1, 1, 1)
        end)

        header.collapseBtn = collapseBtn
    end

    return header
end

-- Create a prominent score display (larger, more visible)
local function CreateScoreMeter(parent, width)
    local meter = CreateFrame("Frame", nil, parent)
    meter:SetSize(width, 36)

    -- Container for score + /10 (right-aligned within meter)
    local scoreContainer = CreateFrame("Frame", nil, meter)
    scoreContainer:SetSize(80, 30)
    scoreContainer:SetPoint("RIGHT", meter, "RIGHT", 0, 2)

    -- Large score number (prominent display)
    local scoreText = scoreContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    scoreText:SetPoint("RIGHT", scoreContainer, "RIGHT", -25, 0)
    scoreText:SetFont(scoreText:GetFont(), 24, "OUTLINE")
    meter.scoreText = scoreText

    -- "/10" suffix (fixed position relative to container)
    local maxText = scoreContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    maxText:SetPoint("BOTTOMRIGHT", scoreContainer, "BOTTOMRIGHT", 0, 4)
    maxText:SetText("/10")
    maxText:SetTextColor(0.5, 0.5, 0.5, 1)
    meter.maxText = maxText

    -- Bar background (below the number)
    local barBg = meter:CreateTexture(nil, "BACKGROUND")
    barBg:SetPoint("BOTTOMLEFT", meter, "BOTTOMLEFT", 0, 0)
    barBg:SetPoint("BOTTOMRIGHT", meter, "BOTTOMRIGHT", 0, 0)
    barBg:SetHeight(6)
    barBg:SetColorTexture(0.15, 0.15, 0.15, 0.8)
    meter.barBg = barBg

    -- Fill bar
    local fill = meter:CreateTexture(nil, "ARTWORK")
    fill:SetPoint("LEFT", barBg, "LEFT", 0, 0)
    fill:SetHeight(6)
    meter.fill = fill

    -- Score label above
    local label = meter:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("TOPLEFT", meter, "TOPLEFT", 0, 0)
    label:SetText("SCORE")
    label:SetTextColor(0.6, 0.6, 0.6, 1)
    meter.label = label

    -- Update function
    function meter:SetScore(score)
        local barWidth = self.barBg:GetWidth() or width
        local fillWidth = math.max(2, (score / 10) * barWidth)
        self.fill:SetWidth(fillWidth)

        local r, g, b = DA:GetScoreColor(score)
        self.fill:SetColorTexture(r, g, b, 1)
        self.scoreText:SetText(string.format("%.1f", score))
        self.scoreText:SetTextColor(r, g, b, 1)
    end

    return meter
end

--------------------------------------------------------------------------------
-- Main Window Creation
--------------------------------------------------------------------------------

function DA:CreateMainWindow()
    if self.mainFrame then return end
    
    -- Main frame
    local frame = CreateFrame("Frame", "DeathAnalyzerMainFrame", UIParent, "BackdropTemplate")
    frame:SetSize(FRAME_WIDTH, FRAME_HEIGHT)
    frame:SetPoint("CENTER")
    frame:SetMovable(true)
    frame:SetResizable(true)
    frame:SetResizeBounds(400, 350, 800, 700)
    frame:EnableMouse(true)
    frame:SetClampedToScreen(true)
    frame:SetFrameStrata("HIGH")
    
    -- Backdrop
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    frame:SetBackdropColor(unpack(COLORS.BACKGROUND))
    frame:SetBackdropBorderColor(unpack(COLORS.BORDER))
    
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
    header:SetHeight(HEADER_HEIGHT)
    header:SetPoint("TOPLEFT", frame, "TOPLEFT", 1, -1)
    header:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -1, -1)
    header:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
    })
    header:SetBackdropColor(unpack(DA.Theme.backgroundLight))

    -- Left accent bar (addon identity)
    local headerAccent = header:CreateTexture(nil, "ARTWORK")
    headerAccent:SetSize(3, HEADER_HEIGHT - 8)
    headerAccent:SetPoint("LEFT", header, "LEFT", 4, 0)
    headerAccent:SetColorTexture(unpack(DA.Theme.accent))

    -- Title
    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("LEFT", headerAccent, "RIGHT", 8, 0)
    title:SetTextColor(unpack(DA.Theme.accent))
    title:SetText("Death Analyzer")
    frame.title = title

    -- Close button (far right) - larger with hover effect
    local closeBtn = CreateStyledButton(header, BUTTON_SIZE, "Interface\\Buttons\\UI-StopButton", "Close")
    closeBtn:SetPoint("RIGHT", header, "RIGHT", -6, 0)
    closeBtn:SetScript("OnClick", function()
        DA:FadeOut(frame, 0.15)
    end)

    -- Separator before close button
    local closeSep = header:CreateTexture(nil, "ARTWORK")
    closeSep:SetSize(1, HEADER_HEIGHT - 12)
    closeSep:SetPoint("RIGHT", closeBtn, "LEFT", -8, 0)
    closeSep:SetColorTexture(unpack(DA.Theme.border))

    -- Tool buttons (right side, before separator)
    local settingsBtn = CreateStyledButton(header, BUTTON_SIZE, "Interface\\Buttons\\UI-OptionsButton", "Settings")
    settingsBtn:SetPoint("RIGHT", closeSep, "LEFT", -8, 0)
    settingsBtn:SetScript("OnClick", function()
        if DA.OpenSettings then
            DA:OpenSettings()
        end
    end)

    local statsBtn = CreateStyledButton(header, BUTTON_SIZE, "Interface\\Buttons\\UI-GuildButton-PublicNote-Up", "Statistics")
    statsBtn:SetPoint("RIGHT", settingsBtn, "LEFT", -4, 0)
    statsBtn:SetScript("OnClick", function()
        if DA.ToggleStatsWindow then
            DA:ToggleStatsWindow()
        else
            DA:Print("Statistics panel coming soon!")
        end
    end)

    local guideBtn = CreateStyledButton(header, BUTTON_SIZE, "Interface\\Icons\\INV_Misc_Book_09", "Mechanics Guide")
    guideBtn:SetPoint("RIGHT", statsBtn, "LEFT", -4, 0)
    guideBtn:SetScript("OnClick", function()
        if DA.ToggleMechanicsGuide then
            DA:ToggleMechanicsGuide()
        else
            DA:Print("Mechanics guide coming soon!")
        end
    end)

    -- Death navigation (centered in header with visual container)
    local navContainer = CreateFrame("Frame", nil, header, "BackdropTemplate")
    navContainer:SetSize(100, 24)
    navContainer:SetPoint("CENTER", header, "CENTER", 0, 0)
    navContainer:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    navContainer:SetBackdropColor(unpack(DA.Theme.backgroundDark))
    navContainer:SetBackdropBorderColor(unpack(DA.Theme.border))

    -- Previous button
    local prevBtn = CreateFrame("Button", nil, navContainer)
    prevBtn:SetSize(22, 20)
    prevBtn:SetPoint("LEFT", navContainer, "LEFT", 2, 0)
    local prevIcon = prevBtn:CreateTexture(nil, "ARTWORK")
    prevIcon:SetSize(12, 12)
    prevIcon:SetPoint("CENTER")
    prevIcon:SetTexture("Interface\\Buttons\\UI-SpellbookIcon-PrevPage-Up")
    prevBtn.icon = prevIcon
    prevBtn:SetScript("OnEnter", function(self)
        self.icon:SetVertexColor(unpack(DA.Theme.accentBright))
    end)
    prevBtn:SetScript("OnLeave", function(self)
        self.icon:SetVertexColor(1, 1, 1)
    end)
    prevBtn:SetScript("OnClick", function() DA:ShowPreviousDeath() end)
    frame.prevBtn = prevBtn

    -- Death counter (center)
    local deathCounter = navContainer:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    deathCounter:SetPoint("CENTER", navContainer, "CENTER", 0, 0)
    deathCounter:SetTextColor(unpack(DA.Theme.textPrimary))
    deathCounter:SetText("0/0")
    frame.deathCounter = deathCounter

    -- Next button
    local nextBtn = CreateFrame("Button", nil, navContainer)
    nextBtn:SetSize(22, 20)
    nextBtn:SetPoint("RIGHT", navContainer, "RIGHT", -2, 0)
    local nextIcon = nextBtn:CreateTexture(nil, "ARTWORK")
    nextIcon:SetSize(12, 12)
    nextIcon:SetPoint("CENTER")
    nextIcon:SetTexture("Interface\\Buttons\\UI-SpellbookIcon-NextPage-Up")
    nextBtn.icon = nextIcon
    nextBtn:SetScript("OnEnter", function(self)
        self.icon:SetVertexColor(unpack(DA.Theme.accentBright))
    end)
    nextBtn:SetScript("OnLeave", function(self)
        self.icon:SetVertexColor(1, 1, 1)
    end)
    nextBtn:SetScript("OnClick", function() DA:ShowNextDeath() end)
    frame.nextBtn = nextBtn

    -- Keyboard hint (subtle indicator next to nav)
    local keyHint = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    keyHint:SetPoint("LEFT", navContainer, "RIGHT", 6, 0)
    keyHint:SetTextColor(unpack(DA.Theme.textMuted))
    keyHint:SetText("[</>]")
    keyHint:SetAlpha(0.5)

    -- Keyboard navigation support
    frame:EnableKeyboard(true)
    frame:SetPropagateKeyboardInput(true)
    frame:SetScript("OnKeyDown", function(self, key)
        if key == "LEFT" then
            DA:ShowPreviousDeath()
            self:SetPropagateKeyboardInput(false)
        elseif key == "RIGHT" then
            DA:ShowNextDeath()
            self:SetPropagateKeyboardInput(false)
        elseif key == "ESCAPE" then
            DA:FadeOut(self, 0.15)
            self:SetPropagateKeyboardInput(false)
        else
            self:SetPropagateKeyboardInput(true)
        end
    end)
    
    -- Content area
    local content = CreateFrame("Frame", nil, frame)
    content:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 8, -8)
    content:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -8, 8)
    frame.content = content
    
    -- Verdict panel (increased height for larger score display)
    local verdictPanel = self:CreateVerdictPanel(content)
    verdictPanel:SetPoint("TOPLEFT", content, "TOPLEFT")
    verdictPanel:SetPoint("TOPRIGHT", content, "TOPRIGHT")
    verdictPanel:SetHeight(90)
    frame.verdictPanel = verdictPanel

    -- Health Graph panel (visual health timeline)
    local healthGraphPanel = self:CreateHealthGraphPanel(content)
    healthGraphPanel:SetPoint("TOPLEFT", verdictPanel, "BOTTOMLEFT", 0, -8)
    healthGraphPanel:SetPoint("TOPRIGHT", verdictPanel, "BOTTOMRIGHT", 0, -8)
    healthGraphPanel:SetHeight(HEALTH_GRAPH_HEIGHT)
    frame.healthGraphPanel = healthGraphPanel

    -- Timeline panel
    local timelinePanel = self:CreateTimelinePanel(content)
    timelinePanel:SetPoint("TOPLEFT", healthGraphPanel, "BOTTOMLEFT", 0, -8)
    timelinePanel:SetPoint("TOPRIGHT", healthGraphPanel, "BOTTOMRIGHT", 0, -8)
    timelinePanel:SetHeight(TIMELINE_HEIGHT)
    frame.timelinePanel = timelinePanel
    
    -- Defensives panel
    local defensivesPanel = self:CreateDefensivesPanel(content)
    defensivesPanel:SetPoint("TOPLEFT", timelinePanel, "BOTTOMLEFT", 0, -8)
    defensivesPanel:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT")
    frame.defensivesPanel = defensivesPanel
    
    -- Resize handle
    local resizer = CreateFrame("Button", nil, frame)
    resizer:SetSize(16, 16)
    resizer:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
    resizer:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    resizer:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
    resizer:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    resizer:SetScript("OnMouseDown", function() frame:StartSizing("BOTTOMRIGHT") end)
    resizer:SetScript("OnMouseUp", function() frame:StopMovingOrSizing() end)
    
    self.mainFrame = frame
    self.currentDeathIndex = #self.deathSnapshots
    
    -- Initial hide
    frame:Hide()
    
    return frame
end

--------------------------------------------------------------------------------
-- Verdict Panel
--------------------------------------------------------------------------------

function DA:CreateVerdictPanel(parent)
    local panel = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    panel:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    panel:SetBackdropColor(unpack(DA.Theme.panelBg))
    panel:SetBackdropBorderColor(unpack(DA.Theme.border))

    -- Score meter (RIGHT side, prominent display)
    local scoreMeter = CreateScoreMeter(panel, 120)
    scoreMeter:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -10, -6)
    panel.scoreMeter = scoreMeter

    -- Verdict text (left side, below score level)
    local verdict = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    verdict:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, -8)
    verdict:SetPoint("RIGHT", scoreMeter, "LEFT", -15, 0)
    verdict:SetJustifyH("LEFT")
    panel.verdict = verdict

    -- M+ Context display (below verdict, left side)
    local mplusContext = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    mplusContext:SetPoint("TOPLEFT", verdict, "BOTTOMLEFT", 0, -2)
    mplusContext:SetJustifyH("LEFT")
    mplusContext:SetTextColor(0.4, 0.8, 1.0)
    mplusContext:Hide()
    panel.mplusContext = mplusContext

    -- Killing blow (middle row)
    local killingBlow = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    killingBlow:SetPoint("TOPLEFT", panel, "TOPLEFT", 10, -38)
    killingBlow:SetPoint("RIGHT", panel, "RIGHT", -10, 0)
    killingBlow:SetJustifyH("LEFT")
    killingBlow:SetTextColor(unpack(DA.Theme.textSecondary))
    killingBlow:SetWordWrap(false)
    panel.killingBlow = killingBlow

    -- Overkill indicator (after killing blow, same line)
    local overkillText = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    overkillText:SetPoint("TOPLEFT", killingBlow, "BOTTOMLEFT", 0, -2)
    overkillText:SetJustifyH("LEFT")
    overkillText:Hide()
    panel.overkillText = overkillText

    -- Suggestion (bottom)
    local suggestion = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    suggestion:SetPoint("BOTTOMLEFT", panel, "BOTTOMLEFT", 10, 6)
    suggestion:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -10, 6)
    suggestion:SetJustifyH("LEFT")
    suggestion:SetTextColor(unpack(DA.Theme.accent))
    panel.suggestion = suggestion

    -- Keep legacy score text for compatibility (hidden)
    local score = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    score:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -10, -8)
    score:SetAlpha(0)
    panel.score = score

    return panel
end

--------------------------------------------------------------------------------
-- Health Graph Panel (Visual Health Timeline)
--------------------------------------------------------------------------------

function DA:CreateHealthGraphPanel(parent)
    local panel = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    panel:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    panel:SetBackdropColor(unpack(DA.Theme.panelBg))
    panel:SetBackdropBorderColor(unpack(DA.Theme.border))

    -- Graph area (inset from panel edges)
    local graphFrame = CreateFrame("Frame", nil, panel)
    graphFrame:SetPoint("TOPLEFT", panel, "TOPLEFT", 40, -8)
    graphFrame:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -10, 16)
    panel.graphFrame = graphFrame

    -- Y-axis labels
    local label100 = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label100:SetPoint("RIGHT", graphFrame, "TOPLEFT", -4, 0)
    label100:SetText("100%")
    label100:SetTextColor(unpack(DA.Theme.textMuted))

    local label50 = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label50:SetPoint("RIGHT", graphFrame, "LEFT", -4, 0)
    label50:SetText("50%")
    label50:SetTextColor(unpack(DA.Theme.textMuted))

    local label0 = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label0:SetPoint("RIGHT", graphFrame, "BOTTOMLEFT", -4, 0)
    label0:SetText("0%")
    label0:SetTextColor(unpack(DA.Theme.textMuted))

    -- Time labels (will be updated dynamically)
    local timeStart = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    timeStart:SetPoint("TOPLEFT", graphFrame, "BOTTOMLEFT", 0, -2)
    timeStart:SetTextColor(unpack(DA.Theme.textMuted))
    panel.timeStart = timeStart

    local timeEnd = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    timeEnd:SetPoint("TOPRIGHT", graphFrame, "BOTTOMRIGHT", 0, -2)
    timeEnd:SetText("Death")
    timeEnd:SetTextColor(1, 0.3, 0.3)
    panel.timeEnd = timeEnd

    -- Grid lines (horizontal)
    for i = 1, 3 do
        local line = graphFrame:CreateTexture(nil, "BACKGROUND")
        line:SetColorTexture(0.3, 0.3, 0.3, 0.3)
        line:SetHeight(1)
        line:SetPoint("LEFT", graphFrame, "LEFT", 0, 0)
        line:SetPoint("RIGHT", graphFrame, "RIGHT", 0, 0)
        local yOffset = (i / 4) * graphFrame:GetHeight()
        line:SetPoint("TOP", graphFrame, "BOTTOM", 0, yOffset)
    end

    -- Store line segments for the graph
    panel.lineSegments = {}
    panel.eventMarkers = {}

    return panel
end

-- Update health graph with death data
function DA:UpdateHealthGraph(panel, snapshot)
    if not panel or not snapshot or not snapshot.events then return end

    local graphFrame = panel.graphFrame
    if not graphFrame then return end

    -- Clear existing lines and markers
    for _, line in ipairs(panel.lineSegments or {}) do
        line:Hide()
    end
    for _, marker in ipairs(panel.eventMarkers or {}) do
        marker:Hide()
    end
    panel.lineSegments = {}
    panel.eventMarkers = {}

    local events = snapshot.events
    if #events == 0 then return end

    -- Calculate time range
    local deathTime = snapshot.timestamp
    local startTime = events[1].timestamp
    local timeRange = deathTime - startTime
    if timeRange <= 0 then timeRange = 1 end

    -- Update time label
    panel.timeStart:SetText(string.format("-%.1fs", timeRange))

    -- Get graph dimensions
    local graphWidth = graphFrame:GetWidth()
    local graphHeight = graphFrame:GetHeight()

    if graphWidth <= 0 or graphHeight <= 0 then
        -- Frame not sized yet, try again later
        C_Timer.After(0.1, function()
            self:UpdateHealthGraph(panel, snapshot)
        end)
        return
    end

    -- Build health data points
    local dataPoints = {}
    local lastHealth = 100

    for _, event in ipairs(events) do
        if event.healthPercent and event.healthPercent > 0 then
            local x = ((event.timestamp - startTime) / timeRange) * graphWidth
            local y = (event.healthPercent / 100) * graphHeight
            table.insert(dataPoints, {
                x = x,
                y = y,
                health = event.healthPercent,
                event = event,
            })
            lastHealth = event.healthPercent
        end
    end

    -- Add death point
    table.insert(dataPoints, {
        x = graphWidth,
        y = 0,
        health = 0,
        isDeath = true,
    })

    -- Draw line segments
    for i = 2, #dataPoints do
        local prev = dataPoints[i - 1]
        local curr = dataPoints[i]

        local line = graphFrame:CreateTexture(nil, "ARTWORK")

        -- Color based on health level
        local healthAvg = (prev.health + curr.health) / 2
        if healthAvg > 60 then
            line:SetColorTexture(0.3, 1.0, 0.3, 0.9)  -- Green
        elseif healthAvg > 30 then
            line:SetColorTexture(1.0, 0.8, 0.2, 0.9)  -- Yellow
        else
            line:SetColorTexture(1.0, 0.3, 0.3, 0.9)  -- Red
        end

        -- Calculate line dimensions
        local dx = curr.x - prev.x
        local dy = curr.y - prev.y
        local length = math.sqrt(dx * dx + dy * dy)
        local angle = math.atan2(dy, dx)

        line:SetSize(length, 2)
        line:SetPoint("CENTER", graphFrame, "BOTTOMLEFT", (prev.x + curr.x) / 2, (prev.y + curr.y) / 2)

        -- WoW doesn't support rotation, so we'll use a simpler approach - horizontal lines with vertical steps
        line:ClearAllPoints()
        line:SetHeight(2)
        line:SetPoint("LEFT", graphFrame, "BOTTOMLEFT", prev.x, prev.y)
        line:SetPoint("RIGHT", graphFrame, "BOTTOMLEFT", curr.x, curr.y)

        table.insert(panel.lineSegments, line)
    end

    -- Draw event markers for damage/healing
    for i, point in ipairs(dataPoints) do
        if point.event and (point.event.type == "DAMAGE" or point.event.type == "HEALING") then
            local marker = graphFrame:CreateTexture(nil, "OVERLAY")
            marker:SetSize(6, 6)
            marker:SetPoint("CENTER", graphFrame, "BOTTOMLEFT", point.x, point.y)

            if point.event.type == "DAMAGE" then
                marker:SetColorTexture(1.0, 0.2, 0.2, 1.0)
                -- Check if avoidable
                if self:IsDamageAvoidable(point.event.spellID) then
                    marker:SetColorTexture(1.0, 0.5, 0.0, 1.0)  -- Orange for avoidable
                end
            else
                marker:SetColorTexture(0.2, 1.0, 0.2, 1.0)
            end

            table.insert(panel.eventMarkers, marker)
        end
    end

    -- Death marker (skull-like indicator)
    local deathMarker = graphFrame:CreateTexture(nil, "OVERLAY")
    deathMarker:SetSize(12, 12)
    deathMarker:SetPoint("CENTER", graphFrame, "BOTTOMRIGHT", 0, 0)
    deathMarker:SetColorTexture(1.0, 0.0, 0.0, 1.0)
    table.insert(panel.eventMarkers, deathMarker)
end

--------------------------------------------------------------------------------
-- Timeline Panel
--------------------------------------------------------------------------------

function DA:CreateTimelinePanel(parent)
    local panel = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    panel:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    panel:SetBackdropColor(unpack(DA.Theme.panelBg))
    panel:SetBackdropBorderColor(unpack(DA.Theme.border))

    -- Panel header with accent bar
    local header = CreatePanelHeader(panel, "TIMELINE", true)  -- collapsible
    header:SetPoint("TOPLEFT", panel, "TOPLEFT", 6, -4)
    header:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -6, -4)
    panel.header = header

    -- Time range hint
    local timeHint = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    timeHint:SetPoint("LEFT", header.title, "RIGHT", 8, 0)
    timeHint:SetTextColor(unpack(DA.Theme.textMuted))
    timeHint:SetText("(last 15 seconds)")

    -- Scroll frame for timeline entries
    local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", panel, "TOPLEFT", 4, -24)
    scrollFrame:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -24, 4)

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(1, 1)
    scrollFrame:SetScrollChild(scrollChild)

    panel.scrollFrame = scrollFrame
    panel.scrollChild = scrollChild
    panel.entries = {}

    -- Collapse functionality
    if header.collapseBtn then
        panel.content = scrollFrame
        panel.originalHeight = nil  -- Will be set dynamically
        header.collapseBtn:SetScript("OnClick", function()
            header.collapseBtn.collapsed = not header.collapseBtn.collapsed
            if header.collapseBtn.collapsed then
                scrollFrame:Hide()
                panel.originalHeight = panel:GetHeight()
                panel:SetHeight(PANEL_HEADER_HEIGHT + 8)
                header.collapseBtn.texture:SetTexture("Interface\\Buttons\\UI-PlusButton-UP")
            else
                scrollFrame:Show()
                if panel.originalHeight then
                    panel:SetHeight(panel.originalHeight)
                end
                header.collapseBtn.texture:SetTexture("Interface\\Buttons\\UI-MinusButton-UP")
            end
        end)
    end

    return panel
end

--------------------------------------------------------------------------------
-- Defensives Panel
--------------------------------------------------------------------------------

function DA:CreateDefensivesPanel(parent)
    local panel = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    panel:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    panel:SetBackdropColor(unpack(DA.Theme.panelBg))
    panel:SetBackdropBorderColor(unpack(DA.Theme.border))

    -- Panel header with accent bar (using defensive color)
    local header = CreatePanelHeader(panel, "UNUSED DEFENSIVES", true)
    header:SetPoint("TOPLEFT", panel, "TOPLEFT", 6, -4)
    header:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -6, -4)
    -- Change accent bar to defensive gold color
    header.accent:SetColorTexture(unpack(DA.Theme.defensive))
    panel.header = header

    -- Scroll frame
    local scrollFrame = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", panel, "TOPLEFT", 4, -24)
    scrollFrame:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -24, 4)

    local scrollChild = CreateFrame("Frame", nil, scrollFrame)
    scrollChild:SetSize(1, 1)
    scrollFrame:SetScrollChild(scrollChild)

    panel.scrollFrame = scrollFrame
    panel.scrollChild = scrollChild
    panel.entries = {}

    -- Collapse functionality
    if header.collapseBtn then
        panel.content = scrollFrame
        panel.originalHeight = nil
        header.collapseBtn:SetScript("OnClick", function()
            header.collapseBtn.collapsed = not header.collapseBtn.collapsed
            if header.collapseBtn.collapsed then
                scrollFrame:Hide()
                panel.originalHeight = panel:GetHeight()
                panel:SetHeight(PANEL_HEADER_HEIGHT + 8)
                header.collapseBtn.texture:SetTexture("Interface\\Buttons\\UI-PlusButton-UP")
            else
                scrollFrame:Show()
                if panel.originalHeight then
                    panel:SetHeight(panel.originalHeight)
                end
                header.collapseBtn.texture:SetTexture("Interface\\Buttons\\UI-MinusButton-UP")
            end
        end)
    end

    return panel
end

--------------------------------------------------------------------------------
-- Display Functions
--------------------------------------------------------------------------------

function DA:RefreshUI()
    if not self.mainFrame then return end
    if #self.deathSnapshots == 0 then
        self:ClearDisplay()
        return
    end
    
    self.currentDeathIndex = math.max(1, math.min(self.currentDeathIndex, #self.deathSnapshots))
    local snapshot = self.deathSnapshots[self.currentDeathIndex]
    
    if snapshot then
        self:DisplayDeath(snapshot)
    end
end

function DA:DisplayDeath(snapshot)
    if not self.mainFrame or not snapshot then return end

    -- Update counter
    self.mainFrame.deathCounter:SetText(self.currentDeathIndex .. "/" .. #self.deathSnapshots)

    -- Ensure analysis exists
    if not snapshot.analysis then
        self:AnalyzeDeath(snapshot)
    end

    local analysis = snapshot.analysis
    if not analysis then return end

    -- Update verdict panel
    self:UpdateVerdictPanel(snapshot, analysis)

    -- Update health graph
    if self.mainFrame.healthGraphPanel then
        self:UpdateHealthGraph(self.mainFrame.healthGraphPanel, snapshot)
    end

    -- Update timeline
    self:UpdateTimelinePanel(snapshot, analysis)

    -- Update defensives
    self:UpdateDefensivesPanel(snapshot, analysis)
end

function DA:UpdateVerdictPanel(snapshot, analysis)
    local panel = self.mainFrame.verdictPanel

    -- Verdict
    local verdictText = analysis.verdict and (analysis.verdict.color .. analysis.verdict.text .. "|r") or "Unknown"
    panel.verdict:SetText(verdictText)

    -- Visual score meter
    if panel.scoreMeter and panel.scoreMeter.SetScore then
        panel.scoreMeter:SetScore(analysis.score or 0)
    end

    -- Legacy score (hidden but kept for compatibility)
    local scoreColor = analysis.score >= 7 and "|cFF00FF00" or
                       analysis.score >= 4 and "|cFFFFFF00" or "|cFFFF0000"
    panel.score:SetText(scoreColor .. "Score: " .. analysis.score .. "/10|r")

    -- M+ Context display
    if panel.mplusContext then
        if snapshot.mythicPlus and snapshot.mythicPlus.keyLevel then
            local mp = snapshot.mythicPlus
            local affixText = ""
            if mp.affixes and #mp.affixes > 0 then
                local affixNames = {}
                for i, affix in ipairs(mp.affixes) do
                    if i <= 3 then  -- Show up to 3 affixes
                        table.insert(affixNames, affix.name)
                    end
                end
                affixText = " (" .. table.concat(affixNames, "/") .. ")"
            end
            panel.mplusContext:SetText(string.format("|cFF00CCFF+%d|r %s%s",
                mp.keyLevel,
                mp.dungeonName or "",
                affixText
            ))
            panel.mplusContext:Show()
        elseif snapshot.encounter then
            -- Show boss encounter info instead
            panel.mplusContext:SetText(string.format("|cFFFFCC00%s|r %s",
                snapshot.encounter.encounterName or "Boss",
                snapshot.difficultyName or ""
            ))
            panel.mplusContext:Show()
        else
            panel.mplusContext:Hide()
        end
    end

    -- Killing blow with overkill indicator
    if analysis.killingBlow then
        local kb = analysis.killingBlow
        -- Check if killing blow was avoidable
        local kbAvoidable = ""
        local kbInfo = self:GetAvoidanceInfo(kb.spellID)
        if kbInfo then
            local catInfo = kbInfo.categoryInfo
            if catInfo then
                kbAvoidable = " " .. catInfo.color .. "[" .. catInfo.name:sub(1,6):upper() .. "]|r"
            end
        end
        -- Truncate spell and source names to prevent overflow
        local spellName = kb.spellName or "Unknown"
        local sourceName = kb.source or "Unknown"
        if #spellName > 25 then spellName = spellName:sub(1,23) .. ".." end
        if #sourceName > 18 then sourceName = sourceName:sub(1,16) .. ".." end

        panel.killingBlow:SetText(string.format("Killed by: |cFFFF6666%s|r from %s (%s)%s",
            spellName,
            sourceName,
            self:FormatNumber(kb.amount or 0),
            kbAvoidable
        ))

        -- Overkill indicator
        if panel.overkillText then
            local overkill = kb.overkill or 0
            if overkill > 0 then
                local playerInfo = snapshot.playerInfo or self:GetPlayerInfo()
                local maxHealth = playerInfo.maxHealth or 1
                local overkillPercent = (overkill / maxHealth) * 100

                if overkillPercent > 50 then
                    panel.overkillText:SetText(string.format("|cFFFF0000OVERKILL +%s (%.0f%%)|r",
                        self:FormatNumber(overkill), overkillPercent))
                elseif overkillPercent > 20 then
                    panel.overkillText:SetText(string.format("|cFFFF6600Overkill +%s|r",
                        self:FormatNumber(overkill)))
                else
                    panel.overkillText:SetText(string.format("|cFFFFCC00Barely died (-%s HP)|r",
                        self:FormatNumber(overkill)))
                end
                panel.overkillText:Show()
            else
                -- Check if we can calculate how close they were
                local lastDamage = kb.amount or 0
                if lastDamage > 0 then
                    panel.overkillText:SetText("|cFF00FF00Exact lethal hit|r")
                    panel.overkillText:Show()
                else
                    panel.overkillText:Hide()
                end
            end
        end
    else
        panel.killingBlow:SetText("Killing blow unknown")
        if panel.overkillText then
            panel.overkillText:Hide()
        end
    end

    -- Suggestion - show primary suggestion
    local suggestionText = ""
    if analysis.avoidablePercent and analysis.avoidablePercent > 0 then
        suggestionText = string.format("|cFFFF8800%.0f%% avoidable damage|r - ", analysis.avoidablePercent)
    end

    if analysis.suggestions and #analysis.suggestions > 0 then
        suggestionText = suggestionText .. analysis.suggestions[1]
    end
    panel.suggestion:SetText(suggestionText)
end

function DA:UpdateTimelinePanel(snapshot, analysis)
    local panel = self.mainFrame.timelinePanel
    local scrollChild = panel.scrollChild
    local scrollFrame = panel.scrollFrame

    -- Clear old entries properly (release textures/fontstrings)
    for _, entry in ipairs(panel.entries) do
        entry:Hide()
        entry:ClearAllPoints()
        entry:SetParent(nil)
    end
    wipe(panel.entries)

    -- Reset scroll position to top for new death
    scrollFrame:SetVerticalScroll(0)

    -- Create new entries with dynamic height
    local timeline = analysis.timeline or {}
    local yOffset = 0

    -- Calculate available width for entries
    local entryWidth = scrollFrame:GetWidth() - 4

    for i, event in ipairs(timeline) do
        -- Avoidable damage gets two-line layout (taller)
        local entryHeight = (event.isAvoidable and event.avoidanceInfo) and TIMELINE_ENTRY_HEIGHT + 14 or TIMELINE_ENTRY_HEIGHT
        local entry = self:CreateTimelineEntry(scrollChild, event, entryHeight, entryWidth)
        entry:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, -yOffset)
        entry:SetWidth(entryWidth)
        table.insert(panel.entries, entry)
        yOffset = yOffset + entryHeight + 2  -- 2px spacing between entries
    end

    -- Set scroll child size for THIS death's timeline
    local totalHeight = math.max(1, yOffset)
    scrollChild:SetHeight(totalHeight)
    scrollChild:SetWidth(entryWidth)
end

function DA:CreateTimelineEntry(parent, event, height, entryWidth)
    height = height or TIMELINE_ENTRY_HEIGHT
    entryWidth = entryWidth or 400
    local isAvoidable = event.isAvoidable and event.avoidanceInfo
    local isTwoLine = isAvoidable and height > TIMELINE_ENTRY_HEIGHT

    local entry = CreateFrame("Frame", nil, parent)
    entry:SetHeight(height)
    entry:SetWidth(entryWidth)
    entry:EnableMouse(true)

    -- Left border color based on event type
    local leftBorder = entry:CreateTexture(nil, "ARTWORK")
    leftBorder:SetSize(2, height - 4)
    leftBorder:SetPoint("LEFT", entry, "LEFT", 2, 0)

    if event.type == "DAMAGE" then
        if isAvoidable then
            leftBorder:SetColorTexture(unpack(DA.Theme.avoidable))
        else
            leftBorder:SetColorTexture(unpack(DA.Theme.damage))
        end
    elseif event.type == "HEALING" then
        leftBorder:SetColorTexture(unpack(DA.Theme.healing))
    elseif event.type == "DEFENSIVE_USED" then
        leftBorder:SetColorTexture(unpack(DA.Theme.defensive))
    else
        leftBorder:SetColorTexture(unpack(DA.Theme.textMuted))
    end

    -- Time (positioned for first line)
    local timeText = entry:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    local timeYOffset = isTwoLine and 6 or 0
    timeText:SetPoint("LEFT", entry, "LEFT", 8, timeYOffset)
    timeText:SetWidth(40)
    timeText:SetJustifyH("LEFT")
    timeText:SetTextColor(unpack(DA.Theme.textSecondary))
    timeText:SetText(self:FormatTime(event.relativeTime))

    -- Health bar background
    local healthBg = entry:CreateTexture(nil, "BACKGROUND")
    healthBg:SetPoint("LEFT", timeText, "RIGHT", 4, 0)
    healthBg:SetSize(50, 10)
    healthBg:SetColorTexture(0.15, 0.15, 0.15, 0.8)

    -- Health bar fill
    local healthBar = entry:CreateTexture(nil, "ARTWORK")
    healthBar:SetPoint("LEFT", healthBg, "LEFT", 1, 0)
    local healthWidth = math.max(1, 44 * (event.healthPercent / 100))
    healthBar:SetSize(healthWidth, 8)

    -- Health color gradient
    local r, g, b = 0.3, 1, 0.3
    if event.healthPercent < 25 then
        r, g, b = 1, 0.2, 0.2
    elseif event.healthPercent < 50 then
        r, g, b = 1, 0.6, 0.2
    elseif event.healthPercent < 75 then
        r, g, b = 0.9, 0.9, 0.3
    end
    healthBar:SetColorTexture(r, g, b, 0.9)

    -- Icon (type indicator) - using text icons
    local icon = entry:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    icon:SetPoint("LEFT", healthBg, "RIGHT", 4, 0)
    icon:SetWidth(16)

    if event.type == "DAMAGE" then
        if isAvoidable and event.avoidanceInfo.categoryInfo then
            local catInfo = event.avoidanceInfo.categoryInfo
            icon:SetText(catInfo.color .. catInfo.icon .. "|r")
        else
            icon:SetText("|cFFFF5555-|r")
        end
    elseif event.type == "HEALING" then
        icon:SetText("|cFF55FF55+|r")
    elseif event.type == "DEFENSIVE_USED" then
        icon:SetText("|cFFFFCC00*|r")
    else
        icon:SetText("")
    end

    -- Calculate remaining width for description
    local descWidth = entryWidth - 8 - 40 - 4 - 50 - 4 - 16 - 4 - 6  -- ~entryWidth - 132

    -- Main description line
    local desc = entry:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    desc:SetPoint("LEFT", icon, "RIGHT", 4, 0)
    desc:SetWidth(descWidth)
    desc:SetJustifyH("LEFT")
    desc:SetTextColor(unpack(DA.Theme.textPrimary))
    desc:SetWordWrap(false)

    -- Helper to truncate text
    local function truncate(text, maxLen)
        if not text then return "?" end
        if #text > maxLen then
            return text:sub(1, maxLen - 2) .. ".."
        end
        return text
    end

    local descText = ""
    if event.type == "DAMAGE" then
        local avoidableTag = ""
        if isAvoidable then
            local catInfo = event.avoidanceInfo.categoryInfo
            if catInfo then
                avoidableTag = " " .. catInfo.color .. "[" .. catInfo.name:sub(1,5):upper() .. "]|r"
            else
                avoidableTag = " |cFFFF8800[!]|r"
            end
        end
        -- Truncate spell name and source to prevent overflow
        local spellName = truncate(event.spellName or "Unknown", 20)
        local sourceName = truncate(event.source or "?", 12)
        descText = string.format("|cFFFF6666-%s|r %s (%s)%s",
            self:FormatNumber(event.amount),
            spellName,
            sourceName,
            avoidableTag
        )
    elseif event.type == "HEALING" then
        local spellName = truncate(event.spellName or "Unknown", 20)
        local sourceName = truncate(event.source or "?", 12)
        descText = string.format("|cFF66FF66+%s|r %s (%s)",
            self:FormatNumber(event.amount),
            spellName,
            sourceName
        )
    elseif event.type == "DEFENSIVE_USED" then
        descText = string.format("|cFFFFCC00%s|r activated",
            truncate(event.spellName or "Unknown", 25)
        )
    end

    desc:SetText(descText)

    -- Second line for avoidable damage (avoidance tip)
    if isTwoLine then
        local tipLine = entry:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        tipLine:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -2)
        tipLine:SetPoint("RIGHT", entry, "RIGHT", -6, 0)
        tipLine:SetJustifyH("LEFT")
        tipLine:SetTextColor(unpack(DA.Theme.accent))

        -- Truncate long avoidance tips
        local tip = event.avoidanceInfo.avoidance or "Dodge this ability"
        if #tip > 60 then
            tip = tip:sub(1, 57) .. "..."
        end
        tipLine:SetText("-> " .. tip)
    end

    -- Add tooltip and click handlers for avoidable damage
    if event.isAvoidable and event.avoidanceInfo then
        -- Enable clicking
        entry:RegisterForClicks("LeftButtonUp")

        -- Store data for click handler
        entry.spellID = event.spellID
        entry.spellName = event.spellName
        entry.bossName = event.avoidanceInfo.boss
        entry.dungeonName = event.avoidanceInfo.dungeon

        -- Click handler
        entry:SetScript("OnClick", function(self, button)
            if button == "LeftButton" then
                if IsShiftKeyDown() then
                    -- Shift+click: Open in-game Adventure Guide
                    if DA.OpenAdventureGuide then
                        DA:OpenAdventureGuide(self.bossName, self.dungeonName, self.spellID)
                    end
                else
                    -- Normal click: Open our Mechanics Guide
                    if DA.OpenMechanicsGuideToSpell then
                        DA:OpenMechanicsGuideToSpell(self.spellID, self.spellName, self.dungeonName)
                    end
                end
            end
        end)

        entry:SetScript("OnEnter", function(self)
            -- Show hand cursor to indicate clickable
            SetCursor("Interface\\CURSOR\\openhand")

            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:ClearLines()

            local info = event.avoidanceInfo
            local catInfo = info.categoryInfo

            -- Title with category color
            if catInfo then
                GameTooltip:AddLine(catInfo.color .. event.spellName .. "|r", 1, 1, 1)
                GameTooltip:AddLine(catInfo.name .. " - " .. (info.dungeon or "Unknown"), 0.7, 0.7, 0.7)
            else
                GameTooltip:AddLine(event.spellName, 1, 0.5, 0)
            end

            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("How to avoid:", 1, 0.82, 0)
            GameTooltip:AddLine(info.avoidance, 0, 1, 0, true)

            -- Damage amount
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("Damage taken: " .. DA:FormatNumber(event.amount), 1, 0.3, 0.3)

            -- Click hints
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine("|cFF00FF00Click|r to open Mechanics Guide", 0.7, 0.7, 0.7)
            GameTooltip:AddLine("|cFF00FF00Shift+Click|r to open Adventure Guide", 0.7, 0.7, 0.7)

            GameTooltip:Show()
        end)
        entry:SetScript("OnLeave", function(self)
            ResetCursor()
            GameTooltip:Hide()
        end)

        -- Highlight on hover
        local highlight = entry:CreateTexture(nil, "HIGHLIGHT")
        highlight:SetAllPoints()
        highlight:SetColorTexture(1, 0.5, 0, 0.2)
    end
    
    entry:Show()
    return entry
end

function DA:UpdateDefensivesPanel(snapshot, analysis)
    local panel = self.mainFrame.defensivesPanel
    local scrollChild = panel.scrollChild

    -- Clear old entries
    for _, entry in ipairs(panel.entries) do
        entry:Hide()
        entry:SetParent(nil)
    end
    panel.entries = {}

    -- Create new entries
    local defensives = analysis.unusedDefensives or {}
    local yOffset = 0

    if #defensives == 0 then
        local noDefFrame = CreateFrame("Frame", nil, scrollChild)
        noDefFrame:SetHeight(24)
        noDefFrame:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, 0)
        noDefFrame:SetPoint("RIGHT", scrollChild, "RIGHT", 0, 0)

        local noDefText = noDefFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        noDefText:SetPoint("LEFT", noDefFrame, "LEFT", 8, 0)
        noDefText:SetTextColor(unpack(DA.Theme.textMuted))
        noDefText:SetText("All defensives were on cooldown")
        panel.entries[1] = noDefFrame
        yOffset = 24
    else
        for i, def in ipairs(defensives) do
            local entry = self:CreateDefensiveEntry(scrollChild, def, analysis)
            entry:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 0, -yOffset)
            entry:SetPoint("RIGHT", scrollChild, "RIGHT", 0, 0)
            table.insert(panel.entries, entry)
            yOffset = yOffset + DEFENSIVE_ENTRY_HEIGHT + 2
        end
    end

    scrollChild:SetHeight(math.max(1, yOffset))
    scrollChild:SetWidth(panel.scrollFrame:GetWidth())
end

function DA:CreateDefensiveEntry(parent, def, analysis)
    local entry = CreateFrame("Frame", nil, parent)
    entry:SetHeight(DEFENSIVE_ENTRY_HEIGHT)
    entry:EnableMouse(true)

    -- Calculate survival chance
    local survivalChance = 0
    local wouldSurvive = false
    local survivePercent = 0

    if def.potentialReduction and def.potentialReduction > 0 then
        local playerInfo = analysis.playerInfo or DA:GetPlayerInfo()
        local maxHealth = playerInfo.maxHealth or UnitHealthMax("player")
        local overkill = (analysis.killingBlow and analysis.killingBlow.overkill) or 0

        if def.potentialReduction > overkill then
            wouldSurvive = true
            local surviving = def.potentialReduction - overkill
            survivePercent = (surviving / maxHealth) * 100
            survivalChance = math.min(100, 50 + survivePercent)
        else
            survivalChance = math.max(10, 40 * (def.potentialReduction / math.max(1, overkill)))
        end
    end

    -- Left accent bar
    local leftBorder = entry:CreateTexture(nil, "ARTWORK")
    leftBorder:SetSize(2, DEFENSIVE_ENTRY_HEIGHT - 4)
    leftBorder:SetPoint("LEFT", entry, "LEFT", 2, 0)
    if wouldSurvive then
        leftBorder:SetColorTexture(unpack(DA.Theme.good))
    else
        leftBorder:SetColorTexture(unpack(DA.Theme.defensive))
    end

    -- Spell icon (actual icon from spellID)
    local icon = entry:CreateTexture(nil, "ARTWORK")
    icon:SetSize(22, 22)
    icon:SetPoint("LEFT", entry, "LEFT", 8, 0)
    icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    -- Try to get spell icon
    if def.spellID then
        local spellInfo = C_Spell.GetSpellInfo(def.spellID)
        if spellInfo and spellInfo.iconID then
            icon:SetTexture(spellInfo.iconID)
        else
            icon:SetTexture("Interface\\Icons\\Spell_Holy_DevineAegis")
        end
    else
        icon:SetTexture("Interface\\Icons\\Spell_Holy_DevineAegis")
    end

    -- Name
    local name = entry:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    name:SetPoint("LEFT", icon, "RIGHT", 6, 0)
    name:SetTextColor(unpack(DA.Theme.defensive))
    name:SetText(def.name)

    -- Reduction info inline
    local infoText = entry:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    infoText:SetPoint("LEFT", name, "RIGHT", 6, 0)
    infoText:SetTextColor(unpack(DA.Theme.textMuted))

    if def.reduction and def.reduction > 0 then
        infoText:SetText(string.format("(%d%% DR)", def.reduction))
    elseif def.notes then
        infoText:SetText("(" .. def.notes .. ")")
    end

    -- Right side: Survival text
    local survivalText = entry:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    survivalText:SetPoint("RIGHT", entry, "RIGHT", -6, 0)

    if wouldSurvive then
        survivalText:SetText(string.format("|cFF55FF55Would survive at %d%% HP|r", survivePercent))
    elseif survivalChance > 30 then
        survivalText:SetText("|cFFFFAA00Might have helped|r")
    else
        survivalText:SetText("|cFF888888Limited impact|r")
    end

    -- Hover highlight
    local highlight = entry:CreateTexture(nil, "HIGHLIGHT")
    highlight:SetAllPoints()
    highlight:SetColorTexture(1, 0.8, 0.2, 0.1)

    -- Tooltip showing spell info
    entry.spellID = def.spellID
    entry.defName = def.name
    entry.reduction = def.reduction
    entry.wouldSurvive = wouldSurvive
    entry.survivePercent = survivePercent

    entry:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")

        -- Show spell tooltip if we have spellID
        if self.spellID then
            GameTooltip:SetSpellByID(self.spellID)
            GameTooltip:AddLine(" ")
        else
            GameTooltip:AddLine(self.defName, 1, 0.82, 0)
        end

        -- Add survival info
        if self.wouldSurvive then
            GameTooltip:AddLine(string.format("Would have survived at %d%% HP", self.survivePercent), 0.3, 1, 0.3)
        else
            GameTooltip:AddLine("Might have reduced incoming damage", 1, 0.7, 0.2)
        end

        if self.reduction and self.reduction > 0 then
            GameTooltip:AddLine(string.format("Provides %d%% damage reduction", self.reduction), 0.7, 0.7, 0.7)
        end

        GameTooltip:Show()
    end)

    entry:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
    end)

    entry:Show()
    return entry
end

function DA:ClearDisplay()
    if not self.mainFrame then return end
    
    self.mainFrame.deathCounter:SetText("0/0")
    self.mainFrame.verdictPanel.verdict:SetText("No deaths recorded")
    self.mainFrame.verdictPanel.score:SetText("")
    self.mainFrame.verdictPanel.killingBlow:SetText("")
    self.mainFrame.verdictPanel.suggestion:SetText("Go get killed and come back!")
end

--------------------------------------------------------------------------------
-- Navigation
--------------------------------------------------------------------------------

function DA:ShowPreviousDeath()
    if self.currentDeathIndex > 1 then
        self.currentDeathIndex = self.currentDeathIndex - 1
        self:RefreshUI()
    end
end

function DA:ShowNextDeath()
    if self.currentDeathIndex < #self.deathSnapshots then
        self.currentDeathIndex = self.currentDeathIndex + 1
        self:RefreshUI()
    end
end

--------------------------------------------------------------------------------
-- Death Popup
--------------------------------------------------------------------------------

function DA:ShowDeathPopup(snapshot)
    -- Simple popup on death
    if not snapshot.analysis then
        self:AnalyzeDeath(snapshot)
    end
    
    local analysis = snapshot.analysis
    if not analysis then return end
    
    -- Print summary to chat
    self:Print("--- Death Analysis ---")
    
    local summary = self:GetAnalysisSummary(snapshot)
    for line in summary:gmatch("[^\n]+") do
        print("  " .. line)
    end
    
    print("  |cFF888888Type /da to view full analysis|r")
end

--------------------------------------------------------------------------------
-- Death Export/Share Functionality
--------------------------------------------------------------------------------

-- Generate a shareable text summary of a death
function DA:GenerateExportText(snapshot)
    if not snapshot then return "No death data" end

    if not snapshot.analysis then
        self:AnalyzeDeath(snapshot)
    end

    local analysis = snapshot.analysis
    if not analysis then return "Analysis unavailable" end

    local lines = {}

    -- Header
    table.insert(lines, "=== Death Analyzer Report ===")
    table.insert(lines, "")

    -- Context
    table.insert(lines, "Date: " .. (snapshot.dateString or "Unknown"))
    table.insert(lines, "Location: " .. (snapshot.location or "Unknown") .. " - " .. (snapshot.subzone or ""))

    -- M+ Context
    if snapshot.mythicPlus and snapshot.mythicPlus.keyLevel then
        local mp = snapshot.mythicPlus
        local affixNames = {}
        if mp.affixes then
            for _, affix in ipairs(mp.affixes) do
                table.insert(affixNames, affix.name)
            end
        end
        table.insert(lines, "M+ Key: +" .. mp.keyLevel .. " " .. (mp.dungeonName or ""))
        if #affixNames > 0 then
            table.insert(lines, "Affixes: " .. table.concat(affixNames, ", "))
        end
    end

    -- Boss context
    if snapshot.encounter then
        table.insert(lines, "Encounter: " .. (snapshot.encounter.encounterName or "Boss") ..
            " (" .. (snapshot.difficultyName or "Unknown") .. ")")
    end

    table.insert(lines, "")

    -- Verdict
    table.insert(lines, "VERDICT: " .. (analysis.verdict and analysis.verdict.text or "Unknown"))
    table.insert(lines, "Score: " .. (analysis.score or "?") .. "/10")
    table.insert(lines, "")

    -- Killing Blow
    if analysis.killingBlow then
        local kb = analysis.killingBlow
        local overkillText = ""
        if kb.overkill and kb.overkill > 0 then
            overkillText = " (Overkill: " .. self:FormatNumber(kb.overkill) .. ")"
        end
        table.insert(lines, "Killing Blow: " .. (kb.spellName or "Unknown") ..
            " from " .. (kb.source or "Unknown") ..
            " for " .. self:FormatNumber(kb.amount or 0) .. overkillText)
    end

    table.insert(lines, "")

    -- Damage summary
    table.insert(lines, "Total Damage: " .. self:FormatNumber(analysis.totalDamageTaken or 0))
    table.insert(lines, "Total Healing: " .. self:FormatNumber(analysis.totalHealingReceived or 0))

    if analysis.avoidableDamage and analysis.avoidableDamage > 0 then
        table.insert(lines, "Avoidable Damage: " .. self:FormatNumber(analysis.avoidableDamage) ..
            " (" .. string.format("%.0f%%", analysis.avoidablePercent or 0) .. ")")
    end

    table.insert(lines, "")

    -- Avoidable damage breakdown
    if analysis.avoidableEvents and #analysis.avoidableEvents > 0 then
        table.insert(lines, "-- Avoidable Damage Sources --")
        for i, evt in ipairs(analysis.avoidableEvents) do
            if i <= 5 then
                table.insert(lines, "  - " .. (evt.spellName or "Unknown") ..
                    ": " .. self:FormatNumber(evt.amount or 0) ..
                    " [" .. (evt.category and evt.category:upper() or "AVOIDABLE") .. "]")
            end
        end
        if #analysis.avoidableEvents > 5 then
            table.insert(lines, "  ... and " .. (#analysis.avoidableEvents - 5) .. " more")
        end
        table.insert(lines, "")
    end

    -- Unused defensives
    if analysis.unusedDefensives and #analysis.unusedDefensives > 0 then
        table.insert(lines, "-- Unused Defensive Cooldowns --")
        for i, def in ipairs(analysis.unusedDefensives) do
            if i <= 5 then
                local survivalNote = ""
                if def.potentialReduction then
                    local playerInfo = snapshot.playerInfo or {}
                    local maxHealth = playerInfo.maxHealth or 1
                    local overkill = (analysis.killingBlow and analysis.killingBlow.overkill) or 0
                    if def.potentialReduction > overkill then
                        survivalNote = " - Would have survived!"
                    end
                end
                table.insert(lines, "  - " .. def.name ..
                    (def.reduction and (" (" .. def.reduction .. "% DR)") or "") ..
                    survivalNote)
            end
        end
        table.insert(lines, "")
    end

    -- Suggestions
    if analysis.suggestions and #analysis.suggestions > 0 then
        table.insert(lines, "-- Suggestions --")
        for i, suggestion in ipairs(analysis.suggestions) do
            if i <= 3 then
                -- Strip color codes for export
                local cleanSuggestion = suggestion:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
                table.insert(lines, "  > " .. cleanSuggestion)
            end
        end
        table.insert(lines, "")
    end

    -- Footer
    table.insert(lines, "Generated by Death Analyzer v" .. (self.VERSION or "?"))

    return table.concat(lines, "\n")
end

-- Create export popup window
function DA:ShowExportWindow(snapshot)
    if not snapshot then
        self:Print("No death selected to export")
        return
    end

    -- Create or show export frame
    if not self.exportFrame then
        local frame = CreateFrame("Frame", "DeathAnalyzerExportFrame", UIParent, "BackdropTemplate")
        frame:SetSize(450, 350)
        frame:SetPoint("CENTER")
        frame:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
            edgeFile = "Interface\\Buttons\\WHITE8x8",
            edgeSize = 2,
        })
        frame:SetBackdropColor(0.1, 0.1, 0.1, 0.95)
        frame:SetBackdropBorderColor(0.4, 0.8, 0.4, 1)
        frame:SetMovable(true)
        frame:EnableMouse(true)
        frame:RegisterForDrag("LeftButton")
        frame:SetScript("OnDragStart", frame.StartMoving)
        frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
        frame:SetFrameStrata("DIALOG")
        frame:SetClampedToScreen(true)

        -- Title
        local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        title:SetPoint("TOP", frame, "TOP", 0, -10)
        title:SetText("|cFF00FF00Export Death Analysis|r")

        -- Close button
        local closeBtn = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
        closeBtn:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2)

        -- Scroll frame for text
        local scrollFrame = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
        scrollFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -40)
        scrollFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 40)

        -- Edit box
        local editBox = CreateFrame("EditBox", nil, scrollFrame)
        editBox:SetMultiLine(true)
        editBox:SetAutoFocus(false)
        editBox:SetFontObject(GameFontHighlightSmall)
        editBox:SetWidth(400)
        editBox:SetScript("OnEscapePressed", function() frame:Hide() end)
        scrollFrame:SetScrollChild(editBox)

        frame.editBox = editBox

        -- Instructions
        local instructions = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        instructions:SetPoint("BOTTOM", frame, "BOTTOM", 0, 15)
        instructions:SetText("|cFFAAAAAA Ctrl+A to select all, Ctrl+C to copy |r")

        self.exportFrame = frame
    end

    -- Populate with export text
    local exportText = self:GenerateExportText(snapshot)
    self.exportFrame.editBox:SetText(exportText)
    self.exportFrame.editBox:HighlightText()
    self.exportFrame.editBox:SetFocus()

    self.exportFrame:Show()
end

-- Add export button click handler (called from header setup)
function DA:ExportCurrentDeath()
    if #self.deathSnapshots == 0 then
        self:Print("No deaths to export")
        return
    end

    local snapshot = self.deathSnapshots[self.currentDeathIndex]
    if snapshot then
        self:ShowExportWindow(snapshot)
    end
end
