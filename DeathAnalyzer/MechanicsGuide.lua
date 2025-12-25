--[[
    Mechanics Guide - Adventure Book Style UI
    Browse all avoidable damage mechanics organized by dungeon/raid
]]

local ADDON_NAME, DA = ...

--------------------------------------------------------------------------------
-- Constants
--------------------------------------------------------------------------------

local GUIDE_WIDTH = 750
local GUIDE_HEIGHT = 580
local SIDEBAR_WIDTH = 200
local ENTRY_HEIGHT = 65

-- Category icons for visual flair
local CATEGORY_ICONS = {
    frontal = "Interface\\Icons\\Ability_Warrior_Cleave",
    ground = "Interface\\Icons\\Spell_Fire_MoltenBlood",
    interrupt = "Interface\\Icons\\Ability_Kick",
    soak = "Interface\\Icons\\Spell_Holy_DivineProtection",
    dodge = "Interface\\Icons\\Ability_Rogue_Sprint",
    positioning = "Interface\\Icons\\Ability_Hunter_Pathfinding",
    add = "Interface\\Icons\\Ability_Hunter_BeastCall",
    environmental = "Interface\\Icons\\Spell_Nature_EarthBind",
}

-- Persistent state for sidebar
local expandedCategories = {}  -- { ["M+ Dungeons"] = true, ... }
local selectedCategoryName = nil  -- Track currently selected category for highlighting

--------------------------------------------------------------------------------
-- Adventure Guide (Encounter Journal) Mappings
-- Instance IDs and Encounter IDs for linking to the in-game dungeon journal
-- These IDs can be verified in-game using: /dump EJ_GetCurrentInstance()
-- or by iterating EJ_GetInstanceByIndex() and EJ_GetEncounterInfoByIndex()
--------------------------------------------------------------------------------

-- Helper function to check if addon is loaded (compatible with all WoW versions)
local function IsAddonLoadedHelper(addonName)
    if C_AddOns and C_AddOns.IsAddOnLoaded then
        return C_AddOns.IsAddOnLoaded(addonName)
    elseif IsAddOnLoaded then
        return IsAddOnLoaded(addonName)
    end
    return false
end

-- Helper function to load addon (compatible with all WoW versions)
local function LoadAddonHelper(addonName)
    if C_AddOns and C_AddOns.LoadAddOn then
        C_AddOns.LoadAddOn(addonName)
    elseif LoadAddOn then
        LoadAddOn(addonName)
    end
end

-- Instance IDs (journalInstanceID) for dungeons and raids
local INSTANCE_IDS = {
    -- The War Within Dungeons
    ["The Stonevault"] = 1269,
    ["The Dawnbreaker"] = 1270,
    ["Ara-Kara"] = 1271,
    ["City of Threads"] = 1274,
    -- The War Within Raids
    ["Nerub-ar Palace"] = 1273,
    ["Liberation of Undermine"] = 1296,
    ["Manaforge Omega"] = 1302,
    -- Legacy Dungeons (M+ Season 1)
    ["Grim Batol"] = 71,
    ["Mists of Tirna Scithe"] = 1184,
    ["The Necrotic Wake"] = 1182,
    ["Siege of Boralus"] = 1023,
}

-- Encounter IDs (journalEncounterID) for bosses
-- Format: ["Boss Name"] = { encounterID = X, instanceID = Y }
local ENCOUNTER_IDS = {
    -- Nerub-ar Palace (Instance 1273)
    ["Ulgrax the Devourer"] = { encounterID = 2902, instanceID = 1273 },
    ["The Bloodbound Horror"] = { encounterID = 2917, instanceID = 1273 },
    ["Sikran"] = { encounterID = 2898, instanceID = 1273 },
    ["Rasha'nan"] = { encounterID = 2918, instanceID = 1273 },
    ["Broodtwister Ovi'nax"] = { encounterID = 2919, instanceID = 1273 },
    ["Nexus-Princess Ky'veza"] = { encounterID = 2920, instanceID = 1273 },
    ["The Silken Court"] = { encounterID = 2921, instanceID = 1273 },
    ["Queen Ansurek"] = { encounterID = 2922, instanceID = 1273 },
    -- Liberation of Undermine (Instance 1296)
    ["Vexie and the Geargrinders"] = { encounterID = 3009, instanceID = 1296 },
    ["Cauldron of Carnage"] = { encounterID = 3010, instanceID = 1296 },
    ["Rik Reverb"] = { encounterID = 3011, instanceID = 1296 },
    ["Stix Bunkjunker"] = { encounterID = 3012, instanceID = 1296 },
    ["Sprocketmonger Lockenstock"] = { encounterID = 3013, instanceID = 1296 },
    ["The One-Armed Bandit"] = { encounterID = 3014, instanceID = 1296 },
    ["Mug'Zee, Heads of Security"] = { encounterID = 3015, instanceID = 1296 },
    ["Chrome King Gallywix"] = { encounterID = 3016, instanceID = 1296 },
    -- Manaforge Omega (Instance 1302)
    ["Plexus Sentinel"] = { encounterID = 3129, instanceID = 1302 },
    ["Loom'ithar"] = { encounterID = 3131, instanceID = 1302 },
    ["Soulbinder Naazindhri"] = { encounterID = 3130, instanceID = 1302 },
    ["Forgeweaver Araz"] = { encounterID = 3132, instanceID = 1302 },
    ["The Soul Hunters"] = { encounterID = 3122, instanceID = 1302 },
    ["Fractillus"] = { encounterID = 3133, instanceID = 1302 },
    ["Nexus-King Salhadaar"] = { encounterID = 3134, instanceID = 1302 },
    ["Dimensius the All-Devouring"] = { encounterID = 3135, instanceID = 1302 },
    ["Dimensius, the All-Devouring"] = { encounterID = 3135, instanceID = 1302 }, -- Alternate name
    -- The Stonevault (Instance 1269)
    ["E.D.N.A."] = { encounterID = 2854, instanceID = 1269 },
    ["Skarmorak"] = { encounterID = 2880, instanceID = 1269 },
    ["Master Machinists"] = { encounterID = 2888, instanceID = 1269 },
    ["Void Speaker Eirich"] = { encounterID = 2883, instanceID = 1269 },
    -- The Dawnbreaker (Instance 1270)
    ["Speaker Shadowcrown"] = { encounterID = 2837, instanceID = 1270 },
    ["Anub'ikkaj"] = { encounterID = 2838, instanceID = 1270 },
    -- Ara-Kara (Instance 1271)
    ["Avanoxx"] = { encounterID = 2926, instanceID = 1271 },
    ["Anub'zekt"] = { encounterID = 2906, instanceID = 1271 },
    ["Ki'katal the Harvester"] = { encounterID = 2929, instanceID = 1271 },
    -- City of Threads (Instance 1274)
    ["Orator Krix'vizk"] = { encounterID = 2907, instanceID = 1274 },
    ["Fangs of the Queen"] = { encounterID = 2908, instanceID = 1274 },
    ["The Coaglamation"] = { encounterID = 2905, instanceID = 1274 },
    ["Izo, the Grand Splicer"] = { encounterID = 2909, instanceID = 1274 },
    -- Grim Batol (Instance 71)
    ["General Umbriss"] = { encounterID = 131, instanceID = 71 },
    ["Forgemaster Throngus"] = { encounterID = 132, instanceID = 71 },
    ["Drahga Shadowburner"] = { encounterID = 133, instanceID = 71 },
    ["Erudax"] = { encounterID = 134, instanceID = 71 },
    -- Mists of Tirna Scithe (Instance 1184)
    ["Ingra Maloch"] = { encounterID = 2400, instanceID = 1184 },
    ["Mistcaller"] = { encounterID = 2402, instanceID = 1184 },
    ["Tred'ova"] = { encounterID = 2405, instanceID = 1184 },
    -- The Necrotic Wake (Instance 1182)
    ["Blightbone"] = { encounterID = 2387, instanceID = 1182 },
    ["Amarth"] = { encounterID = 2388, instanceID = 1182 },
    ["Surgeon Stitchflesh"] = { encounterID = 2389, instanceID = 1182 },
    ["Nalthor the Rimebinder"] = { encounterID = 2390, instanceID = 1182 },
    -- Siege of Boralus (Instance 1023)
    ["Chopper Redhook"] = { encounterID = 2133, instanceID = 1023 },
    ["Dread Captain Lockwood"] = { encounterID = 2173, instanceID = 1023 },
    ["Hadal Darkfathom"] = { encounterID = 2134, instanceID = 1023 },
    ["Viq'Goth"] = { encounterID = 2140, instanceID = 1023 },
}

-- Boss encounter order for sorting (matches in-game Adventure Guide order)
-- Each raid/dungeon lists bosses in the order they appear in the encounter journal
local BOSS_ORDER = {
    -- Nerub-ar Palace (in Adventure Guide order)
    ["Ulgrax the Devourer"] = 1,
    ["The Bloodbound Horror"] = 2,
    ["Sikran"] = 3,
    ["Sikran, Captain of the Sureki"] = 3,
    ["Rasha'nan"] = 4,
    ["Broodtwister Ovi'nax"] = 5,
    ["Nexus-Princess Ky'veza"] = 6,
    ["The Silken Court"] = 7,
    ["Queen Ansurek"] = 8,

    -- Liberation of Undermine (in Adventure Guide order)
    ["Vexie and the Geargrinders"] = 1,
    ["Cauldron of Carnage"] = 2,
    ["Rik Reverb"] = 3,
    ["Stix Bunkjunker"] = 4,
    ["Sprocketmonger Lockenstock"] = 5,
    ["The One-Armed Bandit"] = 6,
    ["Mug'Zee, Heads of Security"] = 7,
    ["Chrome King Gallywix"] = 8,

    -- Manaforge Omega (in Adventure Guide order)
    ["Plexus Sentinel"] = 1,
    ["Loom'ithar"] = 2,
    ["Soulbinder Naazindhri"] = 3,
    ["Forgeweaver Araz"] = 4,
    ["The Soul Hunters"] = 5,
    ["Fractillus"] = 6,
    ["Nexus-King Salhadaar"] = 7,
    ["Dimensius the All-Devouring"] = 8,
    ["Dimensius, the All-Devouring"] = 8,
}

-- Helper function to find a spell's section ID within an encounter
-- This searches through the encounter's ability sections to find the matching spell
local function FindSpellSectionID(encounterID, spellID)
    if not encounterID or not spellID or spellID <= 0 then
        return nil
    end

    -- Get encounter info to find the root section ID
    local name, description, journalEncounterID, rootSectionID = EJ_GetEncounterInfo(encounterID)
    if not rootSectionID then
        return nil
    end

    -- Recursive function to search through sections
    local function SearchSection(sectionID, depth)
        if not sectionID or depth > 20 then -- Prevent infinite loops
            return nil
        end

        local sectionInfo = C_EncounterJournal.GetSectionInfo(sectionID)
        if not sectionInfo then
            return nil
        end

        -- Check if this section's spell matches
        if sectionInfo.spellID and sectionInfo.spellID == spellID then
            return sectionID
        end

        -- Search child sections (firstChildSectionID)
        if sectionInfo.firstChildSectionID then
            local found = SearchSection(sectionInfo.firstChildSectionID, depth + 1)
            if found then return found end
        end

        -- Search sibling sections (nextSectionID)
        if sectionInfo.nextSectionID then
            local found = SearchSection(sectionInfo.nextSectionID, depth + 1)
            if found then return found end
        end

        return nil
    end

    return SearchSection(rootSectionID, 0)
end

-- Helper function to open Adventure Guide to a specific boss
-- Exposed as DA method so it can be called from other files (e.g., UI.lua death timeline)
function DA:OpenAdventureGuide(bossName, dungeonName, spellID)
    -- Load the encounter journal addon if not loaded
    if not IsAddonLoadedHelper("Blizzard_EncounterJournal") then
        LoadAddonHelper("Blizzard_EncounterJournal")
    end

    -- Wait a frame for addon to fully load if needed
    if not EncounterJournal then
        C_Timer.After(0.1, function()
            DA:OpenAdventureGuide(bossName, dungeonName, spellID)
        end)
        return true, false
    end

    -- Try to find encounter by boss name first
    local encounter = ENCOUNTER_IDS[bossName]
    local instanceID = encounter and encounter.instanceID or INSTANCE_IDS[dungeonName]

    if not instanceID then
        self:Print("No Adventure Guide entry found for: " .. tostring(bossName or dungeonName))
        return false, false
    end

    -- Use EncounterJournal_OpenJournal if available (the standard method)
    if EncounterJournal_OpenJournal then
        if encounter and encounter.encounterID then
            -- Open to specific boss
            EncounterJournal_OpenJournal(nil, instanceID, encounter.encounterID)
        else
            -- Open to instance overview
            EncounterJournal_OpenJournal(nil, instanceID)
        end
        return true, false
    end

    -- Fallback: manually show and select
    ShowUIPanel(EncounterJournal)
    if EJ_SelectInstance then
        EJ_SelectInstance(instanceID)
    end
    if encounter and encounter.encounterID and EJ_SelectEncounter then
        EJ_SelectEncounter(encounter.encounterID)
    end

    return true, false
end

-- Open the Mechanics Guide and navigate to a specific spell
-- Called from death timeline when clicking on avoidable damage
function DA:OpenMechanicsGuideToSpell(spellID, spellName, dungeonName)
    -- Ensure guide is created and shown
    if not self.guideFrame then
        self:CreateMechanicsGuide()
    end

    if not self.guideFrame:IsShown() then
        self.guideFrame:Show()
    end

    -- Search for the spell by name (or ID as fallback)
    local searchTerm = spellName or tostring(spellID)
    if searchTerm and searchTerm ~= "" then
        -- Set search box text and trigger filter
        if self.guideFrame.searchBox then
            self.guideFrame.searchBox:SetText(searchTerm)
        end
        self:FilterMechanicsGuide(searchTerm)
    end
end

--------------------------------------------------------------------------------
-- Build Content Structure
--------------------------------------------------------------------------------

local function BuildContentStructure()
    -- Build dungeon children list, filtering out nil data
    local dungeonChildren = {}
    local dungeonList = {
        { name = "The Stonevault", data = DA.StonevaultMechanics },
        { name = "The Dawnbreaker", data = DA.DawnbreakerMechanics },
        { name = "Ara-Kara", data = DA.AraKaraMechanics },
        { name = "City of Threads", data = DA.CityOfThreadsMechanics },
        { name = "Grim Batol", data = DA.GrimBatolMechanics },
        { name = "Mists of Tirna Scithe", data = DA.MistsMechanics },
        { name = "The Necrotic Wake", data = DA.NecroticWakeMechanics },
        { name = "Siege of Boralus", data = DA.SiegeMechanics },
    }
    for _, dungeon in ipairs(dungeonList) do
        if dungeon.data then
            table.insert(dungeonChildren, dungeon)
        end
    end

    local structure = {}

    -- M+ Dungeons (only add if there are valid dungeons)
    if #dungeonChildren > 0 then
        table.insert(structure, {
            name = "M+ Dungeons",
            icon = "Interface\\Icons\\INV_Misc_Key_10",
            children = dungeonChildren
        })
    end

    -- M+ Affixes
    if DA.AffixMechanics then
        table.insert(structure, {
            name = "M+ Affixes",
            icon = "Interface\\Icons\\INV_Relics_HourgassSand",
            data = DA.AffixMechanics,
        })
    end

    -- Raids (only add if data exists)
    if DA.NerubArPalaceMechanics then
        table.insert(structure, {
            name = "Nerub-ar Palace",
            icon = "Interface\\Icons\\Achievement_Boss_Anubarak",
            data = DA.NerubArPalaceMechanics,
            groupByBoss = true,
        })
    end

    if DA.LiberationOfUndermineMechanics then
        table.insert(structure, {
            name = "Liberation of Undermine",
            icon = "Interface\\Icons\\INV_Misc_Coin_01",
            data = DA.LiberationOfUndermineMechanics,
            groupByBoss = true,
        })
    end

    if DA.ManaforgeOmegaMechanics then
        table.insert(structure, {
            name = "Manaforge Omega",
            icon = "Interface\\Icons\\Spell_Arcane_Arcane04",
            data = DA.ManaforgeOmegaMechanics,
            groupByBoss = true,
        })
    end

    return structure
end

--------------------------------------------------------------------------------
-- Create Guide Window
--------------------------------------------------------------------------------

function DA:CreateMechanicsGuide()
    if self.guideFrame then return end
    
    local frame = CreateFrame("Frame", "DeathAnalyzerGuideFrame", UIParent, "BackdropTemplate")
    frame:SetSize(GUIDE_WIDTH, GUIDE_HEIGHT)
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 20) -- Slightly above center
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetClampedToScreen(true)
    frame:SetFrameStrata("DIALOG")
    frame:SetFrameLevel(180)
    
    -- Backdrop - modern style matching main UI
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 2,
        insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    frame:SetBackdropColor(unpack(DA.Theme.background))
    frame:SetBackdropBorderColor(unpack(DA.Theme.accent))
    
    -- Make draggable
    frame:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            self:StartMoving()
        end
    end)
    frame:SetScript("OnMouseUp", function(self)
        self:StopMovingOrSizing()
    end)
    
    --------------------------------------------------------------------------------
    -- Header
    --------------------------------------------------------------------------------
    
    local header = CreateFrame("Frame", nil, frame)
    header:SetHeight(40)
    header:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -8)
    header:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -8, -8)
    
    -- Header accent bar
    local headerAccent = header:CreateTexture(nil, "ARTWORK")
    headerAccent:SetSize(3, 28)
    headerAccent:SetPoint("LEFT", header, "LEFT", 4, 0)
    headerAccent:SetColorTexture(unpack(DA.Theme.accent))

    -- Title with book icon
    local titleIcon = header:CreateTexture(nil, "ARTWORK")
    titleIcon:SetSize(28, 28)
    titleIcon:SetPoint("LEFT", headerAccent, "RIGHT", 8, 0)
    titleIcon:SetTexture("Interface\\Icons\\INV_Misc_Book_09")
    titleIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("LEFT", titleIcon, "RIGHT", 10, 0)
    title:SetTextColor(unpack(DA.Theme.accent))
    title:SetText("Mechanics Guide")

    local subtitle = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    subtitle:SetPoint("LEFT", title, "RIGHT", 10, 0)
    subtitle:SetTextColor(unpack(DA.Theme.textMuted))
    subtitle:SetText("Learn how to avoid damage")
    
    -- Close button
    local closeBtn = CreateFrame("Button", nil, header, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", header, "TOPRIGHT", 0, 5)
    closeBtn:SetScript("OnClick", function() frame:Hide() end)
    
    -- Search box
    local searchBox = CreateFrame("EditBox", "DAGuideSearchBox", header, "SearchBoxTemplate")
    searchBox:SetSize(150, 20)
    searchBox:SetPoint("RIGHT", closeBtn, "LEFT", -10, 0)
    searchBox:SetScript("OnTextChanged", function(self)
        SearchBoxTemplate_OnTextChanged(self)
        DA:FilterMechanicsGuide(self:GetText())
    end)
    frame.searchBox = searchBox
    
    --------------------------------------------------------------------------------
    -- Sidebar (Categories)
    --------------------------------------------------------------------------------
    
    local sidebar = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    sidebar:SetWidth(SIDEBAR_WIDTH)
    sidebar:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -5)
    sidebar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 8, 8)
    sidebar:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    sidebar:SetBackdropColor(unpack(DA.Theme.backgroundDark))
    sidebar:SetBackdropBorderColor(unpack(DA.Theme.border))
    
    -- Sidebar scroll frame
    local sidebarScroll = CreateFrame("ScrollFrame", nil, sidebar, "UIPanelScrollFrameTemplate")
    sidebarScroll:SetPoint("TOPLEFT", sidebar, "TOPLEFT", 4, -4)
    sidebarScroll:SetPoint("BOTTOMRIGHT", sidebar, "BOTTOMRIGHT", -24, 4)
    
    local sidebarContent = CreateFrame("Frame", nil, sidebarScroll)
    sidebarContent:SetSize(SIDEBAR_WIDTH - 30, 1)
    sidebarScroll:SetScrollChild(sidebarContent)
    
    frame.sidebar = sidebar
    frame.sidebarScroll = sidebarScroll
    frame.sidebarContent = sidebarContent
    frame.categoryButtons = {}
    
    --------------------------------------------------------------------------------
    -- Content Area
    --------------------------------------------------------------------------------
    
    local content = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    content:SetPoint("TOPLEFT", sidebar, "TOPRIGHT", 5, 0)
    content:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -8, 8)
    content:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    content:SetBackdropColor(unpack(DA.Theme.panelBg))
    content:SetBackdropBorderColor(unpack(DA.Theme.border))
    
    -- Content header
    local contentHeader = content:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    contentHeader:SetPoint("TOPLEFT", content, "TOPLEFT", 10, -10)
    contentHeader:SetText("Select a category")
    frame.contentHeader = contentHeader
    
    -- Content scroll frame
    local contentScroll = CreateFrame("ScrollFrame", nil, content, "UIPanelScrollFrameTemplate")
    contentScroll:SetPoint("TOPLEFT", content, "TOPLEFT", 4, -35)
    contentScroll:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", -24, 4)
    
    local contentInner = CreateFrame("Frame", nil, contentScroll)
    contentInner:SetSize(content:GetWidth() - 30, 1)
    contentScroll:SetScrollChild(contentInner)
    
    frame.content = content
    frame.contentScroll = contentScroll
    frame.contentInner = contentInner
    frame.mechanicEntries = {}
    
    self.guideFrame = frame
    frame:Hide()
    
    -- Make ESC close the window
    tinsert(UISpecialFrames, "DeathAnalyzerGuideFrame")
    
    return frame
end

--------------------------------------------------------------------------------
-- Populate Sidebar
--------------------------------------------------------------------------------

function DA:PopulateGuideSidebar()
    local frame = self.guideFrame
    if not frame then return end
    
    local content = frame.sidebarContent
    local structure = BuildContentStructure()
    
    -- Clear existing buttons
    for _, btn in ipairs(frame.categoryButtons) do
        btn:Hide()
        btn:SetParent(nil)
    end
    frame.categoryButtons = {}
    
    local yOffset = 0
    
    for _, category in ipairs(structure) do
        -- Main category button
        local btn = CreateFrame("Button", nil, content)
        btn:SetSize(SIDEBAR_WIDTH - 35, 28)
        btn:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOffset)
        
        -- Icon
        local icon = btn:CreateTexture(nil, "ARTWORK")
        icon:SetSize(20, 20)
        icon:SetPoint("LEFT", btn, "LEFT", 4, 0)
        icon:SetTexture(category.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
        
        -- Label
        local label = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("LEFT", icon, "RIGHT", 6, 0)
        label:SetText(category.name)
        label:SetJustifyH("LEFT")
        
        -- Highlight
        local highlight = btn:CreateTexture(nil, "HIGHLIGHT")
        highlight:SetAllPoints()
        highlight:SetColorTexture(0.4, 0.35, 0.2, 0.3)
        
        -- Store category data
        btn.categoryData = category

        -- Check if this category is currently selected (for highlighting)
        local isSelected = (selectedCategoryName == category.name)
        if isSelected then
            local selectBg = btn:CreateTexture(nil, "BACKGROUND")
            selectBg:SetAllPoints()
            selectBg:SetColorTexture(0.3, 0.25, 0.15, 0.6)
        end

        btn:SetScript("OnClick", function(self)
            if self.categoryData.children then
                -- Toggle expansion using persistent state
                expandedCategories[self.categoryData.name] = not expandedCategories[self.categoryData.name]
                DA:PopulateGuideSidebar() -- Refresh
            else
                -- Show mechanics for this category
                selectedCategoryName = self.categoryData.name
                DA:ShowCategoryMechanics(self.categoryData)
                DA:PopulateGuideSidebar() -- Refresh to update selection highlight
            end
        end)

        table.insert(frame.categoryButtons, btn)
        yOffset = yOffset - 30

        -- If has children, add expansion indicator and optionally show children
        if category.children then
            local isExpanded = expandedCategories[category.name]

            -- Add expansion indicator (using ASCII to avoid rendering issues)
            local expandIcon = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            expandIcon:SetPoint("RIGHT", btn, "RIGHT", -4, 0)
            expandIcon:SetText(isExpanded and "v" or ">")

            if isExpanded then
                for _, child in ipairs(category.children) do
                    local childBtn = CreateFrame("Button", nil, content)
                    childBtn:SetSize(SIDEBAR_WIDTH - 45, 24)
                    childBtn:SetPoint("TOPLEFT", content, "TOPLEFT", 15, yOffset)

                    -- Check if this child is selected
                    local childSelected = (selectedCategoryName == child.name)
                    if childSelected then
                        local childSelectBg = childBtn:CreateTexture(nil, "BACKGROUND")
                        childSelectBg:SetAllPoints()
                        childSelectBg:SetColorTexture(0.3, 0.25, 0.15, 0.6)
                    end

                    local childLabel = childBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                    childLabel:SetPoint("LEFT", childBtn, "LEFT", 4, 0)
                    childLabel:SetText(child.name)

                    local childHighlight = childBtn:CreateTexture(nil, "HIGHLIGHT")
                    childHighlight:SetAllPoints()
                    childHighlight:SetColorTexture(0.3, 0.3, 0.2, 0.3)

                    childBtn.categoryData = child
                    childBtn:SetScript("OnClick", function(self)
                        selectedCategoryName = self.categoryData.name
                        DA:ShowCategoryMechanics(self.categoryData)
                        DA:PopulateGuideSidebar() -- Refresh to update selection highlight
                    end)

                    table.insert(frame.categoryButtons, childBtn)
                    yOffset = yOffset - 26
                end
            end
        end
    end
    
    content:SetHeight(math.abs(yOffset) + 10)
end

--------------------------------------------------------------------------------
-- Show Category Mechanics
--------------------------------------------------------------------------------

function DA:ShowCategoryMechanics(category)
    local frame = self.guideFrame
    if not frame or not category then return end
    
    frame.contentHeader:SetText("|cFFFFD700" .. category.name .. "|r")
    frame.currentCategory = category
    
    local content = frame.contentInner
    
    -- Clear existing entries
    for _, entry in ipairs(frame.mechanicEntries) do
        entry:Hide()
        entry:SetParent(nil)
    end
    frame.mechanicEntries = {}
    
    local mechanics = category.data
    if not mechanics then return end
    
    -- Group by boss if applicable
    local grouped = {}
    if category.groupByBoss then
        for spellID, data in pairs(mechanics) do
            local boss = data.boss or "Unknown"
            if not grouped[boss] then
                grouped[boss] = {}
            end
            table.insert(grouped[boss], { spellID = spellID, data = data })
        end
    else
        grouped[""] = {}
        for spellID, data in pairs(mechanics) do
            table.insert(grouped[""], { spellID = spellID, data = data })
        end
    end
    
    local yOffset = 0
    local entryWidth = content:GetParent():GetWidth() - 35
    
    -- Sort boss names by encounter order (Adventure Guide order)
    local bosses = {}
    for boss in pairs(grouped) do
        table.insert(bosses, boss)
    end
    table.sort(bosses, function(a, b)
        local orderA = BOSS_ORDER[a] or 999
        local orderB = BOSS_ORDER[b] or 999
        if orderA == orderB then
            return a < b  -- Fallback to alphabetical if same order
        end
        return orderA < orderB
    end)
    
    for _, boss in ipairs(bosses) do
        local entries = grouped[boss]
        
        -- Boss header (if grouping)
        if boss ~= "" then
            local bossHeader = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            bossHeader:SetPoint("TOPLEFT", content, "TOPLEFT", 5, yOffset)
            bossHeader:SetText("|cFFFF8800" .. boss .. "|r")
            table.insert(frame.mechanicEntries, bossHeader)
            yOffset = yOffset - 22
        end
        
        -- Sort by category then name
        table.sort(entries, function(a, b)
            if a.data.category == b.data.category then
                return a.data.name < b.data.name
            end
            return (a.data.category or "") < (b.data.category or "")
        end)
        
        for _, entry in ipairs(entries) do
            local mechFrame = self:CreateMechanicEntry(content, entry.spellID, entry.data, entryWidth)
            mechFrame:SetPoint("TOPLEFT", content, "TOPLEFT", 5, yOffset)
            table.insert(frame.mechanicEntries, mechFrame)
            yOffset = yOffset - (ENTRY_HEIGHT + 5)
        end
        
        yOffset = yOffset - 10 -- Extra space between bosses
    end
    
    content:SetHeight(math.abs(yOffset) + 20)
end

--------------------------------------------------------------------------------
-- Create Mechanic Entry
--------------------------------------------------------------------------------

function DA:CreateMechanicEntry(parent, spellID, data, width)
    local frame = CreateFrame("Button", nil, parent, "BackdropTemplate")
    frame:SetSize(width, ENTRY_HEIGHT)
    frame:EnableMouse(true)
    frame:RegisterForClicks("LeftButtonUp", "RightButtonUp")

    -- Store spell info for interactions
    frame.spellID = spellID
    frame.spellName = data.name
    frame.spellAvoidance = data.avoidance  -- Store avoidance text for click handler
    frame.bossName = data.boss  -- For Adventure Guide lookup
    frame.dungeonName = data.dungeon or data.raid  -- For Adventure Guide fallback
    
    -- Background - using theme colors
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    frame:SetBackdropColor(unpack(DA.Theme.panelBg))
    frame:SetBackdropBorderColor(unpack(DA.Theme.border))
    
    -- Category icon (left side)
    local catIcon = frame:CreateTexture(nil, "ARTWORK")
    catIcon:SetSize(32, 32)
    catIcon:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -8)
    catIcon:SetTexture(CATEGORY_ICONS[data.category] or "Interface\\Icons\\INV_Misc_QuestionMark")
    
    -- Category label (below icon, small)
    local catInfo = self.AvoidanceCategories and self.AvoidanceCategories[data.category]
    local catLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    catLabel:SetPoint("TOP", catIcon, "BOTTOM", 0, -1)
    if catInfo then
        catLabel:SetText(catInfo.color .. catInfo.short .. "|r")
    else
        catLabel:SetText("|cFF888888" .. (data.category or "?") .. "|r")
    end
    
    -- Spell name (clickable feel - using accent color)
    local name = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    name:SetPoint("TOPLEFT", catIcon, "TOPRIGHT", 10, 0)
    local r, g, b = unpack(DA.Theme.accentBright)
    name:SetText(string.format("|cFF%02X%02X%02X%s|r", r*255, g*255, b*255, data.name))
    
    -- Category tag inline
    local catTag = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    catTag:SetPoint("LEFT", name, "RIGHT", 8, 0)
    if catInfo then
        catTag:SetText(catInfo.color .. "[" .. catInfo.name .. "]|r")
    end

    -- Difficulty badge (if specified)
    -- Follows mythictrap.com pattern: [H] = Heroic Only, [H+] = Heroic Changes, [M] = Mythic Only, [M+] = Mythic Changes
    if data.difficulty and data.difficulty ~= "all" then
        local diffBadge = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        diffBadge:SetPoint("LEFT", catTag, "RIGHT", 6, 0)

        local badgeText, r, g, b
        if data.difficulty == "heroic" then
            badgeText = "[H]"
            r, g, b = 1, 0.5, 0  -- Orange
        elseif data.difficulty == "heroic_change" then
            badgeText = "[H+]"
            r, g, b = 1, 0.7, 0.3  -- Light orange
        elseif data.difficulty == "mythic" then
            badgeText = "[M]"
            r, g, b = 0.6, 0.2, 0.8  -- Purple
        elseif data.difficulty == "mythic_change" then
            badgeText = "[M+]"
            r, g, b = 0.8, 0.5, 1  -- Light purple
        end

        if badgeText then
            diffBadge:SetText(badgeText)
            diffBadge:SetTextColor(r, g, b)
        end

        frame.difficultyInfo = data.difficulty  -- Store for tooltip
    end

    -- Avoidance text (with word wrap)
    local avoidance = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    avoidance:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -4)
    avoidance:SetPoint("RIGHT", frame, "RIGHT", -12, 0)
    avoidance:SetJustifyH("LEFT")
    avoidance:SetWordWrap(true)
    avoidance:SetMaxLines(2)
    avoidance:SetText("|cFF88FF88>|r " .. data.avoidance)
    
    -- Click hint (small, right side)
    local clickHint = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    clickHint:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -8, -4)
    clickHint:SetTextColor(unpack(DA.Theme.textMuted))
    clickHint:SetText("Shift: Guide")

    -- Hover effect with spell tooltip
    frame:SetScript("OnEnter", function(self)
        self:SetBackdropColor(unpack(DA.Theme.panelBgHover))
        self:SetBackdropBorderColor(unpack(DA.Theme.borderAccent))

        -- Show spell tooltip
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:SetSpellByID(self.spellID)
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("|cFF00FF00How to Avoid:|r", 1, 1, 1)
        GameTooltip:AddLine(self.spellAvoidance or "", 0.7, 1, 0.7, true)

        -- Show difficulty info if present
        if self.difficultyInfo then
            GameTooltip:AddLine(" ")
            local diffText = {
                heroic = "|cFFFF8000Heroic Only|r - This ability only appears on Heroic+",
                heroic_change = "|cFFFFB366Changed on Heroic|r - This ability is modified on Heroic+",
                mythic = "|cFF9933FFMythic Only|r - This ability only appears on Mythic",
                mythic_change = "|cFFCC80FFChanged on Mythic|r - This ability is modified on Mythic",
            }
            GameTooltip:AddLine(diffText[self.difficultyInfo] or "", 1, 1, 1, true)
        end

        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("|cFFFFFF00Click|r to link spell in chat", 0.5, 0.5, 0.5)
        GameTooltip:AddLine("|cFF00CCFFShift-Click|r to open Adventure Guide", 0.5, 0.5, 0.5)
        GameTooltip:Show()
    end)
    frame:SetScript("OnLeave", function(self)
        self:SetBackdropColor(unpack(DA.Theme.panelBg))
        self:SetBackdropBorderColor(unpack(DA.Theme.border))
        GameTooltip:Hide()
    end)
    
    -- Click to link spell or open Adventure Guide
    frame:SetScript("OnClick", function(self, button)
        if button == "LeftButton" then
            if IsShiftKeyDown() then
                -- Shift-click: Open Adventure Guide to boss and spell
                local opened, foundSpell = DA:OpenAdventureGuide(self.bossName, self.dungeonName, self.spellID)
                if opened then
                    if foundSpell then
                        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[Death Analyzer]|r Opened to " .. (self.spellName or "ability") .. " in Adventure Guide")
                    else
                        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[Death Analyzer]|r Opened to " .. (self.bossName or self.dungeonName or "encounter") .. " in Adventure Guide")
                    end
                else
                    -- Fallback message if no encounter mapping exists
                    DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[Death Analyzer]|r Adventure Guide not available for this mechanic (trash mob or affix)")
                end
            else
                -- Normal click: Insert spell link into chat
                -- Use C_Spell.GetSpellLink for modern WoW, fallback to GetSpellLink for older versions
                local spellLink
                if C_Spell and C_Spell.GetSpellLink then
                    spellLink = C_Spell.GetSpellLink(self.spellID)
                elseif GetSpellLink then
                    spellLink = GetSpellLink(self.spellID)
                end

                if spellLink then
                    if ChatFrame1EditBox and ChatFrame1EditBox:IsShown() then
                        ChatFrame1EditBox:Insert(spellLink)
                    else
                        -- Print to chat
                        DEFAULT_CHAT_FRAME:AddMessage("|cFF00FF00[Death Analyzer]|r " .. spellLink .. " - " .. (self.spellAvoidance or ""))
                    end
                else
                    -- Fallback: spell ID might be invalid, show warning
                    DEFAULT_CHAT_FRAME:AddMessage("|cFFFF6600[Death Analyzer]|r Spell not found (ID: " .. tostring(self.spellID) .. ") - " .. (self.spellName or "Unknown"))
                    DEFAULT_CHAT_FRAME:AddMessage("|cFF888888This spell ID may need verification. Use /da debug in combat to find correct IDs.|r")
                end
            end
        end
    end)
    
    frame:Show()
    return frame
end

--------------------------------------------------------------------------------
-- Filter/Search (Global Search)
--------------------------------------------------------------------------------

-- Store previous category for restoring after search clear
local previousCategory = nil

function DA:FilterMechanicsGuide(searchText)
    if not self.guideFrame then return end

    searchText = (searchText or ""):lower():gsub("^%s*(.-)%s*$", "%1") -- trim whitespace

    -- If search is empty, restore previous category view
    if searchText == "" then
        if previousCategory then
            self:ShowCategoryMechanics(previousCategory)
            previousCategory = nil
        end
        return
    end

    -- Save current category before searching (only once)
    if not previousCategory and self.guideFrame.currentCategory then
        previousCategory = self.guideFrame.currentCategory
    end

    -- Search across all mechanics databases
    local results = {}
    local structure = BuildContentStructure()

    for _, category in ipairs(structure) do
        if category.children then
            -- Category with children (e.g., M+ Dungeons)
            for _, child in ipairs(category.children) do
                if child.data then
                    self:SearchMechanicsTable(child.data, child.name, searchText, results)
                end
            end
        elseif category.data then
            -- Direct category (e.g., M+ Affixes, Raids)
            self:SearchMechanicsTable(category.data, category.name, searchText, results)
        end
    end

    -- Display search results
    self:ShowSearchResults(results, searchText)
end

function DA:SearchMechanicsTable(mechanics, sourceName, searchText, results)
    if not mechanics then return end

    for spellID, data in pairs(mechanics) do
        local nameMatch = data.name and data.name:lower():find(searchText, 1, true)
        local avoidMatch = data.avoidance and data.avoidance:lower():find(searchText, 1, true)
        local catMatch = data.category and data.category:lower():find(searchText, 1, true)
        local bossMatch = data.boss and data.boss:lower():find(searchText, 1, true)

        if nameMatch or avoidMatch or catMatch or bossMatch then
            table.insert(results, {
                spellID = spellID,
                data = data,
                source = sourceName
            })
        end
    end
end

function DA:ShowSearchResults(results, searchText)
    local frame = self.guideFrame
    if not frame then return end

    frame.contentHeader:SetText("|cFFFFD700Search: |r|cFFFFFFFF\"" .. searchText .. "\"|r |cFF888888(" .. #results .. " results)|r")

    local content = frame.contentInner

    -- Clear existing entries
    for _, entry in ipairs(frame.mechanicEntries) do
        entry:Hide()
        entry:SetParent(nil)
    end
    frame.mechanicEntries = {}

    local yOffset = 0
    local entryWidth = content:GetParent():GetWidth() - 35

    if #results == 0 then
        -- Show "no results" message
        local noResults = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        noResults:SetPoint("TOPLEFT", content, "TOPLEFT", 10, -20)
        noResults:SetText("|cFF888888No mechanics found matching \"|r|cFFFFFFFF" .. searchText .. "|r|cFF888888\"|r")
        table.insert(frame.mechanicEntries, noResults)

        local hint = content:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        hint:SetPoint("TOPLEFT", noResults, "BOTTOMLEFT", 0, -10)
        hint:SetText("|cFF666666Try searching for spell names, avoidance keywords, or boss names.|r")
        table.insert(frame.mechanicEntries, hint)

        content:SetHeight(80)
        return
    end

    -- Sort results by source, then by name
    table.sort(results, function(a, b)
        if a.source == b.source then
            return a.data.name < b.data.name
        end
        return a.source < b.source
    end)

    -- Group by source
    local currentSource = nil
    for _, result in ipairs(results) do
        -- Add source header when it changes
        if result.source ~= currentSource then
            currentSource = result.source
            local sourceHeader = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
            sourceHeader:SetPoint("TOPLEFT", content, "TOPLEFT", 5, yOffset)
            sourceHeader:SetText("|cFF00CCFF" .. currentSource .. "|r")
            table.insert(frame.mechanicEntries, sourceHeader)
            yOffset = yOffset - 22
        end

        local mechFrame = self:CreateMechanicEntry(content, result.spellID, result.data, entryWidth)
        mechFrame:SetPoint("TOPLEFT", content, "TOPLEFT", 5, yOffset)
        table.insert(frame.mechanicEntries, mechFrame)
        yOffset = yOffset - (ENTRY_HEIGHT + 5)
    end

    content:SetHeight(math.abs(yOffset) + 20)
end

--------------------------------------------------------------------------------
-- Toggle Guide
--------------------------------------------------------------------------------

function DA:ToggleMechanicsGuide()
    if not self.guideFrame then
        self:CreateMechanicsGuide()
        -- Set default expansion state: M+ Dungeons expanded by default
        expandedCategories["M+ Dungeons"] = true
        self:PopulateGuideSidebar()
    end

    if self.guideFrame:IsShown() then
        self.guideFrame:Hide()
    else
        self.guideFrame:Show()
        -- Default to first dungeon category if nothing selected yet
        if not selectedCategoryName and self.StonevaultMechanics then
            selectedCategoryName = "The Stonevault"
            self:ShowCategoryMechanics({ name = "The Stonevault", data = self.StonevaultMechanics })
            self:PopulateGuideSidebar() -- Refresh to show selection
        end
    end
end

