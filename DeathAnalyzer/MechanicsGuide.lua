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

-- Helper function to open Adventure Guide to a specific boss and optionally scroll to a spell
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

    local foundSpell = false

    -- Use EncounterJournal_OpenJournal if available (the standard method)
    if EncounterJournal_OpenJournal then
        if encounter and encounter.encounterID then
            -- Open to specific boss
            EncounterJournal_OpenJournal(nil, instanceID, encounter.encounterID)

            -- Now try to navigate to the specific spell section
            if spellID and spellID > 0 then
                -- Need a small delay for the journal to fully populate
                C_Timer.After(0.15, function()
                    local sectionID = FindSpellSectionID(encounter.encounterID, spellID)
                    if sectionID then
                        -- Use the API to open to that specific section
                        if EncounterJournal_OpenSection then
                            EncounterJournal_OpenSection(sectionID)
                        elseif EncounterJournal.encounter and EncounterJournal.encounter.info then
                            -- Fallback: try to scroll to section
                            local scrollFrame = EncounterJournal.encounter.info.detailsScroll
                            if scrollFrame and scrollFrame.ScrollTarget then
                                -- Find the section button and scroll to it
                                for _, child in pairs({scrollFrame.ScrollTarget:GetChildren()}) do
                                    if child.spellID == spellID or (child.sectionID and child.sectionID == sectionID) then
                                        child:Click()
                                        break
                                    end
                                end
                            end
                        end
                        foundSpell = true
                    end
                end)
            end
        else
            -- Open to instance overview
            EncounterJournal_OpenJournal(nil, instanceID)
        end
        return true, foundSpell
    end

    -- Fallback: manually show and select
    ShowUIPanel(EncounterJournal)
    if EJ_SelectInstance then
        EJ_SelectInstance(instanceID)
    end
    if encounter and encounter.encounterID and EJ_SelectEncounter then
        EJ_SelectEncounter(encounter.encounterID)

        -- Try to find spell section with fallback
        if spellID and spellID > 0 then
            C_Timer.After(0.15, function()
                local sectionID = FindSpellSectionID(encounter.encounterID, spellID)
                if sectionID and EncounterJournal_OpenSection then
                    EncounterJournal_OpenSection(sectionID)
                end
            end)
        end
    end

    return true, foundSpell
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
    frame:SetPoint("CENTER", UIParent, "CENTER", 0, 20)
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:SetClampedToScreen(true)
    frame:SetFrameStrata("DIALOG")
    frame:SetFrameLevel(180)

    -- Backdrop - modern style
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

    --------------------------------------------------------------------------------
    -- Header Bar
    --------------------------------------------------------------------------------

    local header = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    header:SetHeight(36)
    header:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -2)
    header:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2)
    header:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8" })
    header:SetBackdropColor(0.12, 0.12, 0.12, 1)

    -- Title with book icon
    local titleIcon = header:CreateTexture(nil, "ARTWORK")
    titleIcon:SetSize(24, 24)
    titleIcon:SetPoint("LEFT", header, "LEFT", 10, 0)
    titleIcon:SetTexture("Interface\\Icons\\INV_Misc_Book_09")
    titleIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    local title = header:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    title:SetPoint("LEFT", titleIcon, "RIGHT", 8, 0)
    title:SetText("|cFF00FF00Death Analyzer|r - |cFFFFFFFFMechanics Guide|r")

    local subtitle = header:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    subtitle:SetPoint("LEFT", title, "RIGHT", 10, 0)
    subtitle:SetTextColor(0.5, 0.5, 0.5)
    subtitle:SetText("Learn how to avoid damage")

    -- Close button (styled)
    local closeBtn = CreateFrame("Button", nil, header, "BackdropTemplate")
    closeBtn:SetSize(20, 20)
    closeBtn:SetPoint("RIGHT", header, "RIGHT", -6, 0)
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

    -- Search box with styled container
    local searchContainer = CreateFrame("Frame", nil, header, "BackdropTemplate")
    searchContainer:SetSize(180, 22)
    searchContainer:SetPoint("RIGHT", closeBtn, "LEFT", -10, 0)
    searchContainer:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    searchContainer:SetBackdropColor(0.08, 0.08, 0.08, 1)
    searchContainer:SetBackdropBorderColor(0.3, 0.3, 0.3, 1)

    -- Search icon
    local searchIcon = searchContainer:CreateTexture(nil, "ARTWORK")
    searchIcon:SetSize(14, 14)
    searchIcon:SetPoint("LEFT", searchContainer, "LEFT", 5, 0)
    searchIcon:SetTexture("Interface\\Common\\UI-Searchbox-Icon")

    local searchBox = CreateFrame("EditBox", "DAGuideSearchBox", searchContainer)
    searchBox:SetSize(150, 18)
    searchBox:SetPoint("LEFT", searchIcon, "RIGHT", 4, 0)
    searchBox:SetFontObject("GameFontNormalSmall")
    searchBox:SetAutoFocus(false)
    searchBox:SetTextInsets(2, 2, 0, 0)
    searchBox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    searchBox:SetScript("OnTextChanged", function(self)
        DA:FilterMechanicsGuide(self:GetText())
    end)

    -- Placeholder text
    local placeholder = searchBox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    placeholder:SetPoint("LEFT", searchBox, "LEFT", 2, 0)
    placeholder:SetText("|cFF666666Search abilities...|r")
    searchBox.placeholder = placeholder

    searchBox:SetScript("OnEditFocusGained", function(self)
        self.placeholder:Hide()
    end)
    searchBox:SetScript("OnEditFocusLost", function(self)
        if self:GetText() == "" then
            self.placeholder:Show()
        end
    end)

    frame.searchBox = searchBox
    
    --------------------------------------------------------------------------------
    -- Sidebar (Categories)
    --------------------------------------------------------------------------------

    local sidebar = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    sidebar:SetWidth(SIDEBAR_WIDTH)
    sidebar:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 6, -6)
    sidebar:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 6, 6)
    sidebar:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    sidebar:SetBackdropColor(0.06, 0.06, 0.06, 1)
    sidebar:SetBackdropBorderColor(0.25, 0.25, 0.25, 1)

    -- Sidebar header
    local sidebarHeader = CreateFrame("Frame", nil, sidebar, "BackdropTemplate")
    sidebarHeader:SetHeight(24)
    sidebarHeader:SetPoint("TOPLEFT", sidebar, "TOPLEFT", 1, -1)
    sidebarHeader:SetPoint("TOPRIGHT", sidebar, "TOPRIGHT", -1, -1)
    sidebarHeader:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8" })
    sidebarHeader:SetBackdropColor(0.1, 0.1, 0.1, 1)

    local sidebarTitle = sidebarHeader:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    sidebarTitle:SetPoint("LEFT", sidebarHeader, "LEFT", 8, 0)
    sidebarTitle:SetText("|cFFFFD100Categories|r")

    -- Sidebar scroll frame
    local sidebarScroll = CreateFrame("ScrollFrame", nil, sidebar, "UIPanelScrollFrameTemplate")
    sidebarScroll:SetPoint("TOPLEFT", sidebarHeader, "BOTTOMLEFT", 4, -4)
    sidebarScroll:SetPoint("BOTTOMRIGHT", sidebar, "BOTTOMRIGHT", -24, 4)

    -- Style scrollbar
    local scrollBar = sidebarScroll.ScrollBar or _G[sidebarScroll:GetName().."ScrollBar"]
    if scrollBar then
        scrollBar:SetPoint("TOPLEFT", sidebarScroll, "TOPRIGHT", 2, -16)
        scrollBar:SetPoint("BOTTOMLEFT", sidebarScroll, "BOTTOMRIGHT", 2, 16)
    end

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
    content:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -6, 6)
    content:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    content:SetBackdropColor(0.1, 0.1, 0.1, 1)
    content:SetBackdropBorderColor(0.25, 0.25, 0.25, 1)

    -- Content header bar
    local contentHeaderBar = CreateFrame("Frame", nil, content, "BackdropTemplate")
    contentHeaderBar:SetHeight(28)
    contentHeaderBar:SetPoint("TOPLEFT", content, "TOPLEFT", 1, -1)
    contentHeaderBar:SetPoint("TOPRIGHT", content, "TOPRIGHT", -1, -1)
    contentHeaderBar:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8x8" })
    contentHeaderBar:SetBackdropColor(0.12, 0.12, 0.12, 1)

    local contentHeader = contentHeaderBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    contentHeader:SetPoint("LEFT", contentHeaderBar, "LEFT", 10, 0)
    contentHeader:SetText("|cFF888888Select a category from the sidebar|r")
    frame.contentHeader = contentHeader

    -- Mechanic count label (right side of header)
    local mechanicCount = contentHeaderBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    mechanicCount:SetPoint("RIGHT", contentHeaderBar, "RIGHT", -10, 0)
    mechanicCount:SetTextColor(0.5, 0.5, 0.5)
    frame.mechanicCount = mechanicCount

    -- Content scroll frame
    local contentScroll = CreateFrame("ScrollFrame", nil, content, "UIPanelScrollFrameTemplate")
    contentScroll:SetPoint("TOPLEFT", contentHeaderBar, "BOTTOMLEFT", 4, -4)
    contentScroll:SetPoint("BOTTOMRIGHT", content, "BOTTOMRIGHT", -24, 4)

    -- Style scrollbar
    local contentScrollBar = contentScroll.ScrollBar or _G[contentScroll:GetName().."ScrollBar"]
    if contentScrollBar then
        contentScrollBar:SetPoint("TOPLEFT", contentScroll, "TOPRIGHT", 2, -16)
        contentScrollBar:SetPoint("BOTTOMLEFT", contentScroll, "BOTTOMRIGHT", 2, 16)
    end

    local contentInner = CreateFrame("Frame", nil, contentScroll)
    contentInner:SetSize(content:GetWidth() - 35, 1)
    contentScroll:SetScrollChild(contentInner)

    frame.content = content
    frame.contentScroll = contentScroll
    frame.contentInner = contentInner
    frame.mechanicEntries = {}

    --------------------------------------------------------------------------------
    -- Help Footer
    --------------------------------------------------------------------------------

    local footer = CreateFrame("Frame", nil, frame)
    footer:SetHeight(20)
    footer:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 8, 3)
    footer:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", -8, 3)

    local footerText = footer:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    footerText:SetPoint("LEFT", footer, "LEFT", 0, 0)
    footerText:SetText("|cFF666666Tip: Click ability to link in chat | Shift-click to open Adventure Guide|r")

    self.guideFrame = frame
    frame:Hide()

    -- Make ESC close the window
    tinsert(UISpecialFrames, "DeathAnalyzerGuideFrame")

    return frame
end

--------------------------------------------------------------------------------
-- Populate Sidebar
--------------------------------------------------------------------------------

-- Helper to count mechanics in a data table
local function CountMechanics(data)
    if not data then return 0 end
    local count = 0
    for _ in pairs(data) do
        count = count + 1
    end
    return count
end

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
        -- Main category button with backdrop for better visuals
        local btn = CreateFrame("Button", nil, content, "BackdropTemplate")
        btn:SetSize(SIDEBAR_WIDTH - 35, 26)
        btn:SetPoint("TOPLEFT", content, "TOPLEFT", 0, yOffset)
        btn:SetBackdrop({
            bgFile = "Interface\\Buttons\\WHITE8x8",
        })

        -- Check if selected
        local isSelected = (selectedCategoryName == category.name)
        if isSelected then
            btn:SetBackdropColor(0.25, 0.35, 0.2, 0.8)
        else
            btn:SetBackdropColor(0, 0, 0, 0)
        end

        -- Icon
        local icon = btn:CreateTexture(nil, "ARTWORK")
        icon:SetSize(18, 18)
        icon:SetPoint("LEFT", btn, "LEFT", 4, 0)
        icon:SetTexture(category.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
        icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

        -- Label
        local label = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        label:SetPoint("LEFT", icon, "RIGHT", 5, 0)
        label:SetText("|cFFEEEEEE" .. category.name .. "|r")
        label:SetJustifyH("LEFT")

        -- Mechanic count badge (for non-parent categories)
        if category.data and not category.children then
            local count = CountMechanics(category.data)
            local countBadge = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            countBadge:SetPoint("RIGHT", btn, "RIGHT", -20, 0)
            countBadge:SetText("|cFF888888" .. count .. "|r")
        end

        -- Hover effect
        btn:SetScript("OnEnter", function(self)
            if selectedCategoryName ~= self.categoryData.name then
                self:SetBackdropColor(0.2, 0.2, 0.2, 0.5)
            end
        end)
        btn:SetScript("OnLeave", function(self)
            if selectedCategoryName ~= self.categoryData.name then
                self:SetBackdropColor(0, 0, 0, 0)
            end
        end)

        -- Store category data
        btn.categoryData = category

        btn:SetScript("OnClick", function(self)
            if self.categoryData.children then
                -- Toggle expansion
                expandedCategories[self.categoryData.name] = not expandedCategories[self.categoryData.name]
                DA:PopulateGuideSidebar()
            else
                -- Show mechanics
                selectedCategoryName = self.categoryData.name
                DA:ShowCategoryMechanics(self.categoryData)
                DA:PopulateGuideSidebar()
            end
        end)

        table.insert(frame.categoryButtons, btn)
        yOffset = yOffset - 28

        -- If has children, add expansion indicator
        if category.children then
            local isExpanded = expandedCategories[category.name]

            -- Expansion arrow
            local expandIcon = btn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
            expandIcon:SetPoint("RIGHT", btn, "RIGHT", -4, 0)
            if isExpanded then
                expandIcon:SetText("|cFFAAAAAA" .. string.char(0x76) .. "|r") -- v
            else
                expandIcon:SetText("|cFFAAAAAA>|r")
            end

            if isExpanded then
                for _, child in ipairs(category.children) do
                    local childBtn = CreateFrame("Button", nil, content, "BackdropTemplate")
                    childBtn:SetSize(SIDEBAR_WIDTH - 50, 22)
                    childBtn:SetPoint("TOPLEFT", content, "TOPLEFT", 18, yOffset)
                    childBtn:SetBackdrop({
                        bgFile = "Interface\\Buttons\\WHITE8x8",
                    })

                    -- Check if child selected
                    local childSelected = (selectedCategoryName == child.name)
                    if childSelected then
                        childBtn:SetBackdropColor(0.25, 0.35, 0.2, 0.8)
                    else
                        childBtn:SetBackdropColor(0, 0, 0, 0)
                    end

                    -- Indent marker
                    local indent = childBtn:CreateTexture(nil, "ARTWORK")
                    indent:SetSize(2, 16)
                    indent:SetPoint("LEFT", childBtn, "LEFT", 0, 0)
                    indent:SetColorTexture(0.3, 0.3, 0.3, 0.5)

                    local childLabel = childBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                    childLabel:SetPoint("LEFT", indent, "RIGHT", 4, 0)
                    if childSelected then
                        childLabel:SetText("|cFFFFFFFF" .. child.name .. "|r")
                    else
                        childLabel:SetText("|cFFBBBBBB" .. child.name .. "|r")
                    end

                    -- Count badge for child
                    if child.data then
                        local childCount = CountMechanics(child.data)
                        local childCountBadge = childBtn:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
                        childCountBadge:SetPoint("RIGHT", childBtn, "RIGHT", -4, 0)
                        childCountBadge:SetText("|cFF666666" .. childCount .. "|r")
                    end

                    -- Hover effect
                    childBtn:SetScript("OnEnter", function(self)
                        if selectedCategoryName ~= self.categoryData.name then
                            self:SetBackdropColor(0.15, 0.15, 0.15, 0.5)
                        end
                    end)
                    childBtn:SetScript("OnLeave", function(self)
                        if selectedCategoryName ~= self.categoryData.name then
                            self:SetBackdropColor(0, 0, 0, 0)
                        end
                    end)

                    childBtn.categoryData = child
                    childBtn:SetScript("OnClick", function(self)
                        selectedCategoryName = self.categoryData.name
                        DA:ShowCategoryMechanics(self.categoryData)
                        DA:PopulateGuideSidebar()
                    end)

                    table.insert(frame.categoryButtons, childBtn)
                    yOffset = yOffset - 24
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
    if not mechanics then
        -- Show empty state
        frame.mechanicCount:SetText("")
        local emptyText = content:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        emptyText:SetPoint("TOPLEFT", content, "TOPLEFT", 10, -20)
        emptyText:SetText("|cFF888888No mechanics data available for this category|r")
        table.insert(frame.mechanicEntries, emptyText)
        content:SetHeight(60)
        return
    end

    -- Count mechanics
    local mechanicCount = CountMechanics(mechanics)
    frame.mechanicCount:SetText(mechanicCount .. " abilities")
    
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
    frame.spellAvoidance = data.avoidance
    frame.bossName = data.boss
    frame.dungeonName = data.dungeon or data.raid

    -- Background
    frame:SetBackdrop({
        bgFile = "Interface\\Buttons\\WHITE8x8",
        edgeFile = "Interface\\Buttons\\WHITE8x8",
        edgeSize = 1,
    })
    frame:SetBackdropColor(0.12, 0.12, 0.12, 1)
    frame:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)

    -- Category icon (left side)
    local catIcon = frame:CreateTexture(nil, "ARTWORK")
    catIcon:SetSize(28, 28)
    catIcon:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -8)
    catIcon:SetTexture(CATEGORY_ICONS[data.category] or "Interface\\Icons\\INV_Misc_QuestionMark")
    catIcon:SetTexCoord(0.08, 0.92, 0.08, 0.92)

    -- Category label (below icon, small)
    local catInfo = self.AvoidanceCategories and self.AvoidanceCategories[data.category]
    local catLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    catLabel:SetPoint("TOP", catIcon, "BOTTOM", 0, -2)
    if catInfo then
        catLabel:SetText(catInfo.color .. catInfo.short .. "|r")
    else
        catLabel:SetText("|cFF888888" .. (data.category or "?") .. "|r")
    end

    -- Spell name
    local name = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    name:SetPoint("TOPLEFT", catIcon, "TOPRIGHT", 10, 2)
    name:SetText("|cFF66CCFF" .. data.name .. "|r")

    -- Category tag inline
    local catTag = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    catTag:SetPoint("LEFT", name, "RIGHT", 8, 0)
    if catInfo then
        catTag:SetText(catInfo.color .. "[" .. catInfo.name .. "]|r")
    end

    -- Difficulty badge
    if data.difficulty and data.difficulty ~= "all" then
        local diffBadge = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        diffBadge:SetPoint("LEFT", catTag, "RIGHT", 6, 0)

        local badgeText, r, g, b
        if data.difficulty == "heroic" then
            badgeText = "[H]"
            r, g, b = 1, 0.5, 0
        elseif data.difficulty == "heroic_change" then
            badgeText = "[H+]"
            r, g, b = 1, 0.7, 0.3
        elseif data.difficulty == "mythic" then
            badgeText = "[M]"
            r, g, b = 0.6, 0.2, 0.8
        elseif data.difficulty == "mythic_change" then
            badgeText = "[M+]"
            r, g, b = 0.8, 0.5, 1
        end

        if badgeText then
            diffBadge:SetText(badgeText)
            diffBadge:SetTextColor(r, g, b)
        end

        frame.difficultyInfo = data.difficulty
    end

    -- Avoidance text (with word wrap)
    local avoidance = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    avoidance:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -4)
    avoidance:SetPoint("RIGHT", frame, "RIGHT", -12, 0)
    avoidance:SetJustifyH("LEFT")
    avoidance:SetWordWrap(true)
    avoidance:SetMaxLines(2)
    avoidance:SetText("|cFF88FF88>|r " .. data.avoidance)

    -- Spell ID indicator (small, top right)
    local spellIdText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    spellIdText:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -8, -4)
    spellIdText:SetText("|cFF555555#" .. spellID .. "|r")

    -- Hover effect with spell tooltip
    frame:SetScript("OnEnter", function(self)
        self:SetBackdropColor(0.18, 0.18, 0.18, 1)
        self:SetBackdropBorderColor(0.3, 0.5, 0.3, 1)

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
        self:SetBackdropColor(0.12, 0.12, 0.12, 1)
        self:SetBackdropBorderColor(0.2, 0.2, 0.2, 1)
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

