--[[
    Minimap Button
    Creates a minimap icon for quick access to Death Analyzer
]]

local ADDON_NAME, DA = ...

--------------------------------------------------------------------------------
-- Minimap Button Setup
--------------------------------------------------------------------------------

local LDB = LibStub("LibDataBroker-1.1", true)
local LDBIcon = LibStub("LibDBIcon-1.0", true)

if not LDB or not LDBIcon then
    DA:Debug("LibDataBroker or LibDBIcon not found, minimap button disabled")
    return
end

-- Create the data object
local dataObject = LDB:NewDataObject("DeathAnalyzer", {
    type = "launcher",
    icon = "Interface\\Icons\\Ability_Rogue_FeignDeath",
    label = "Death Analyzer",
    text = "Death Analyzer",
    
    OnClick = function(self, button)
        if IsShiftKeyDown() and button == "LeftButton" then
            -- Open mechanics guide
            if DA.ToggleMechanicsGuide then
                DA:ToggleMechanicsGuide()
            end
        elseif button == "LeftButton" then
            -- Toggle main window
            DA:ToggleMainWindow()
        elseif button == "RightButton" then
            -- Open settings
            if DA.OpenSettings then
                DA:OpenSettings()
            else
                DA:Print("Right-click settings coming soon! Use /da help for commands.")
            end
        elseif button == "MiddleButton" then
            -- Quick show last death
            DA:ShowLastDeath()
        end
    end,
    
    OnTooltipShow = function(tooltip)
        tooltip:AddLine("|cFF00FF00Death Analyzer|r", 1, 1, 1)
        tooltip:AddLine(" ")
        
        -- Show death count
        local deathCount = #DA.deathSnapshots
        tooltip:AddDoubleLine("Deaths Recorded:", tostring(deathCount), 1, 1, 1, 1, 0.82, 0)
        
        -- Show last death info if available
        if deathCount > 0 then
            local lastDeath = DA.deathSnapshots[deathCount]
            if lastDeath then
                tooltip:AddLine(" ")
                tooltip:AddLine("|cFFFFFF00Last Death:|r", 1, 1, 1)
                
                -- Killing blow
                if lastDeath.killingBlow then
                    tooltip:AddDoubleLine("Killed by:", lastDeath.killingBlow, 0.7, 0.7, 0.7, 1, 0.3, 0.3)
                end
                
                -- Verdict
                if lastDeath.verdict then
                    local verdictColor = {1, 1, 1}
                    if lastDeath.verdict == "PREVENTABLE" then
                        verdictColor = {1, 0, 0}
                    elseif lastDeath.verdict == "LIKELY PREVENTABLE" then
                        verdictColor = {1, 0.5, 0}
                    elseif lastDeath.verdict == "DIFFICULT TO PREVENT" then
                        verdictColor = {1, 1, 0}
                    elseif lastDeath.verdict == "UNAVOIDABLE" then
                        verdictColor = {0, 1, 0}
                    end
                    tooltip:AddDoubleLine("Verdict:", lastDeath.verdict, 0.7, 0.7, 0.7, unpack(verdictColor))
                end
                
                -- Score
                if lastDeath.score then
                    local scoreColor = lastDeath.score >= 7 and {0, 1, 0} or 
                                       lastDeath.score >= 4 and {1, 1, 0} or {1, 0, 0}
                    tooltip:AddDoubleLine("Score:", lastDeath.score .. "/10", 0.7, 0.7, 0.7, unpack(scoreColor))
                end
                
                -- Location and time
                if lastDeath.location then
                    tooltip:AddDoubleLine("Location:", lastDeath.location, 0.7, 0.7, 0.7, 0.5, 0.5, 0.5)
                end
                if lastDeath.timestamp then
                    tooltip:AddDoubleLine("Time:", date("%m/%d %H:%M", lastDeath.timestamp), 0.7, 0.7, 0.7, 0.5, 0.5, 0.5)
                end
            end
        else
            tooltip:AddLine("|cFF888888No deaths recorded yet|r")
        end
        
        tooltip:AddLine(" ")
        tooltip:AddLine("|cFF00FF00Left-Click:|r Open Death Analyzer", 0.7, 0.7, 0.7)
        tooltip:AddLine("|cFF00FF00Right-Click:|r Open Settings", 0.7, 0.7, 0.7)
        tooltip:AddLine("|cFF00FF00Middle-Click:|r Show Last Death", 0.7, 0.7, 0.7)
        tooltip:AddLine("|cFF00FF00Shift+Click:|r Open Mechanics Guide", 0.7, 0.7, 0.7)
    end,
})

--------------------------------------------------------------------------------
-- Initialization
--------------------------------------------------------------------------------

function DA:InitializeMinimapButton()
    -- Initialize saved position data
    if not DeathAnalyzerDB.minimap then
        DeathAnalyzerDB.minimap = {
            hide = not DeathAnalyzerDB.minimapIcon,
            minimapPos = 225,
        }
    end
    
    -- Register with LibDBIcon
    LDBIcon:Register("DeathAnalyzer", dataObject, DeathAnalyzerDB.minimap)
    
    self:Debug("Minimap button initialized")
end

--------------------------------------------------------------------------------
-- Show/Hide functions
--------------------------------------------------------------------------------

function DA:ShowMinimapButton()
    LDBIcon:Show("DeathAnalyzer")
    DeathAnalyzerDB.minimapIcon = true
    if DeathAnalyzerDB.minimap then
        DeathAnalyzerDB.minimap.hide = false
    end
end

function DA:HideMinimapButton()
    LDBIcon:Hide("DeathAnalyzer")
    DeathAnalyzerDB.minimapIcon = false
    if DeathAnalyzerDB.minimap then
        DeathAnalyzerDB.minimap.hide = true
    end
end

function DA:ToggleMinimapButton()
    if DeathAnalyzerDB.minimapIcon then
        self:HideMinimapButton()
        self:Print("Minimap button hidden. Use /da minimap to show it again.")
    else
        self:ShowMinimapButton()
        self:Print("Minimap button shown.")
    end
end

function DA:IsMinimapButtonShown()
    return DeathAnalyzerDB.minimapIcon
end

--------------------------------------------------------------------------------
-- Update tooltip text dynamically
--------------------------------------------------------------------------------

function DA:UpdateMinimapButtonText()
    local deathCount = #self.deathSnapshots
    if deathCount > 0 then
        dataObject.text = "Deaths: " .. deathCount
    else
        dataObject.text = "Death Analyzer"
    end
end

