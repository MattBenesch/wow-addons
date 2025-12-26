--[[
    Death Analyzer
    Analyzes your deaths and tells you what could have saved you
    
    Phase 1 Features:
    - Damage/healing timeline before death
    - Unused defensive cooldown detection
    - "Would have survived" calculator
]]

-- Create addon namespace
local ADDON_NAME, DA = ...
DeathAnalyzer = DA

-- Version info
DA.VERSION = "1.5.0"
DA.DEBUG = false

-- Core data structures
DA.eventBuffer = {}           -- Rolling buffer of combat events
DA.deathSnapshots = {}        -- Saved death analyses
DA.defensiveState = {}        -- Current state of defensive cooldowns
DA.currentSpec = nil          -- Player's current spec

-- Configuration defaults
DA.defaults = {
    bufferDuration = 15,      -- Seconds of events to keep before death
    maxSnapshots = 50,        -- Max deaths to store
    showPopupOnDeath = true,
    announceToChat = false,
    minimapIcon = true,
    includeConsumables = true, -- Include healthstones/potions in survival analysis
}

-- Saved variables (will be overwritten on load)
DeathAnalyzerDB = DeathAnalyzerDB or {}

--------------------------------------------------------------------------------
-- Utility Functions
--------------------------------------------------------------------------------

function DA:Print(msg)
    print("|cFF00FF00[DeathAnalyzer]|r " .. tostring(msg))
end

function DA:Debug(msg)
    if self.DEBUG then
        print("|cFFFFFF00[DA Debug]|r " .. tostring(msg))
    end
end

function DA:FormatNumber(num)
    if num >= 1000000 then
        return string.format("%.1fM", num / 1000000)
    elseif num >= 1000 then
        return string.format("%.1fK", num / 1000)
    else
        return tostring(math.floor(num))
    end
end

function DA:FormatTime(seconds)
    if seconds < 0 then
        return string.format("-%.1fs", math.abs(seconds))
    else
        return string.format("+%.1fs", seconds)
    end
end

function DA:GetPlayerInfo()
    local _, class = UnitClass("player")
    local specIndex = GetSpecialization()
    local specID = specIndex and GetSpecializationInfo(specIndex) or nil
    
    return {
        class = class,
        specIndex = specIndex,
        specID = specID,
        maxHealth = UnitHealthMax("player"),
        name = UnitName("player"),
    }
end

--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------

local frame = CreateFrame("Frame", "DeathAnalyzerFrame")

frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" and ... == ADDON_NAME then
        DA:Initialize()
    elseif event == "PLAYER_LOGIN" then
        DA:OnLogin()
    elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
        DA:OnSpecChange()
    end
end)

function DA:Initialize()
    -- Merge saved variables with defaults
    for k, v in pairs(self.defaults) do
        if DeathAnalyzerDB[k] == nil then
            DeathAnalyzerDB[k] = v
        end
    end
    
    -- Load saved death snapshots
    if DeathAnalyzerDB.deathSnapshots then
        self.deathSnapshots = DeathAnalyzerDB.deathSnapshots
    end
    
    self:Debug("Addon initialized")
end

function DA:OnLogin()
    -- Get initial player info
    local playerInfo = self:GetPlayerInfo()
    self.currentSpec = playerInfo.specID
    
    -- Build avoidable damage database
    if self.BuildAvoidableDamageDB then
        self:BuildAvoidableDamageDB()
    end
    
    -- Initialize defensive tracking for current spec
    if self.InitializeDefensives then
        self:InitializeDefensives()
    end
    
    -- Refresh talent CDR cache
    if self.RefreshTalentCDR then
        self:RefreshTalentCDR()
    end
    
    -- Start combat tracking
    if self.StartTracking then
        self:StartTracking()
    end
    
    -- Initialize statistics
    if self.InitializeStatistics then
        self:InitializeStatistics()
    end
    
    -- Initialize minimap button
    if self.InitializeMinimapButton then
        self:InitializeMinimapButton()
    end
    
    -- Initialize settings panel
    if self.InitializeSettings then
        self:InitializeSettings()
    end
    
    self:Print("Loaded. Type /da to open, /da help for commands.")
end

function DA:OnSpecChange()
    local playerInfo = self:GetPlayerInfo()
    self.currentSpec = playerInfo.specID
    
    -- Reinitialize defensives for new spec
    if self.InitializeDefensives then
        self:InitializeDefensives()
    end
    
    -- Refresh talent CDR cache for new spec
    if self.RefreshTalentCDR then
        self:RefreshTalentCDR()
    end
    
    self:Debug("Spec changed to: " .. tostring(self.currentSpec))
end

--------------------------------------------------------------------------------
-- Slash Commands
--------------------------------------------------------------------------------

SLASH_DEATHANALYZER1 = "/da"
SLASH_DEATHANALYZER2 = "/deathanalyzer"

SlashCmdList["DEATHANALYZER"] = function(msg)
    local cmd = msg:lower():trim()
    
    if cmd == "" or cmd == "show" then
        DA:ToggleMainWindow()
    elseif cmd == "last" then
        DA:ShowLastDeath()
    elseif cmd == "history" then
        DA:ShowDeathHistory()
    elseif cmd == "reset" then
        DA:ResetData()
    elseif cmd == "minimap" then
        if DA.ToggleMinimapButton then
            DA:ToggleMinimapButton()
        end
    elseif cmd == "config" or cmd == "options" or cmd == "settings" then
        if DA.OpenSettings then
            DA:OpenSettings()
        else
            DA:Print("Settings panel coming soon!")
        end
    elseif cmd == "stats" or cmd == "statistics" then
        if DA.ToggleStatsWindow then
            DA:ToggleStatsWindow()
        else
            DA:Print("Statistics panel coming soon!")
        end
    elseif cmd == "guide" or cmd == "mechanics" or cmd == "book" then
        if DA.ToggleMechanicsGuide then
            DA:ToggleMechanicsGuide()
        else
            DA:Print("Mechanics guide coming soon!")
        end
    elseif cmd == "export" or cmd == "share" then
        if DA.ExportCurrentDeath then
            DA:ExportCurrentDeath()
        else
            DA:Print("Export feature not available")
        end
    elseif cmd == "debug" then
        DA.DEBUG = not DA.DEBUG
        DA:Print("Debug mode: " .. (DA.DEBUG and "ON" or "OFF"))
    elseif cmd == "test" then
        DA:SimulateTestDeath()
    elseif cmd == "help" then
        DA:Print("Commands:")
        print("  /da - Toggle main window")
        print("  /da last - Show last death analysis")
        print("  /da history - Show death history")
        print("  /da stats - Show death statistics")
        print("  /da guide - Open mechanics guide (adventure book)")
        print("  /da export - Export current death to clipboard")
        print("  /da config - Open settings")
        print("  /da minimap - Toggle minimap button")
        print("  /da reset - Clear all death data")
        print("  /da debug - Toggle debug mode")
        print("  /da test - Simulate a test death")
    else
        DA:Print("Unknown command. Type /da help for options.")
    end
end

function DA:ResetData()
    self.deathSnapshots = {}
    DeathAnalyzerDB.deathSnapshots = {}
    self:Print("All death data cleared.")
end

-- Placeholder functions (implemented in other files)
function DA:ToggleMainWindow()
    if self.mainFrame then
        if self.mainFrame:IsShown() then
            self.mainFrame:Hide()
        else
            self.mainFrame:Show()
            self:RefreshUI()
        end
    else
        self:CreateMainWindow()
    end
end

function DA:ShowLastDeath()
    if #self.deathSnapshots > 0 then
        self:ToggleMainWindow()
        self:DisplayDeath(self.deathSnapshots[#self.deathSnapshots])
    else
        self:Print("No deaths recorded yet.")
    end
end

function DA:ShowDeathHistory()
    self:Print("Deaths recorded: " .. #self.deathSnapshots)
    for i = math.max(1, #self.deathSnapshots - 4), #self.deathSnapshots do
        local death = self.deathSnapshots[i]
        if death then
            print(string.format("  #%d: %s - %s (%s)", 
                i, 
                death.killingBlow or "Unknown",
                death.verdict or "?",
                date("%m/%d %H:%M", death.timestamp)
            ))
        end
    end
end
