--[[
    Defensive Database
    Contains all class/spec defensive cooldowns with their properties
    
    Each defensive has:
    - spellID: The spell ID
    - name: Display name
    - cooldown: Base cooldown in seconds
    - duration: Buff duration (if applicable)
    - reduction: Damage reduction percentage (approximate)
    - type: "personal", "external", "immunity", "cheat_death"
    - notes: Additional info
]]

local ADDON_NAME, DA = ...

--------------------------------------------------------------------------------
-- Defensive Spell Database
--------------------------------------------------------------------------------

DA.DefensiveDB = {
    -- DEATH KNIGHT
    DEATHKNIGHT = {
        -- All specs
        SHARED = {
            { spellID = 48707, name = "Anti-Magic Shell", cooldown = 60, duration = 5, reduction = 0, type = "personal", notes = "Magic damage absorb" },
            { spellID = 48792, name = "Icebound Fortitude", cooldown = 180, duration = 8, reduction = 30, type = "personal" },
            { spellID = 49039, name = "Lichborne", cooldown = 120, duration = 10, reduction = 0, type = "personal", notes = "Immune to Charm/Fear/Sleep" },
        },
        -- Blood (spec ID: 250)
        [250] = {
            { spellID = 55233, name = "Vampiric Blood", cooldown = 90, duration = 10, reduction = 0, type = "personal", notes = "+30% health and healing" },
            { spellID = 49028, name = "Dancing Rune Weapon", cooldown = 120, duration = 8, reduction = 0, type = "personal", notes = "+40% parry" },
            { spellID = 219809, name = "Tombstone", cooldown = 60, duration = 8, reduction = 0, type = "personal", notes = "Bone Shield absorb" },
        },
        -- Frost (spec ID: 251)
        [251] = {},
        -- Unholy (spec ID: 252)
        [252] = {},
    },
    
    -- DEMON HUNTER
    DEMONHUNTER = {
        SHARED = {
            { spellID = 198589, name = "Blur", cooldown = 60, duration = 10, reduction = 20, type = "personal", notes = "+50% dodge" },
            { spellID = 196555, name = "Netherwalk", cooldown = 180, duration = 6, reduction = 100, type = "immunity", notes = "Immune but can't attack" },
        },
        -- Havoc (spec ID: 577)
        [577] = {
            { spellID = 212800, name = "Darkness", cooldown = 300, duration = 8, reduction = 0, type = "personal", notes = "20% avoid all damage" },
        },
        -- Vengeance (spec ID: 581)
        [581] = {
            { spellID = 187827, name = "Metamorphosis", cooldown = 180, duration = 15, reduction = 0, type = "personal", notes = "+50% armor, +20% health" },
            { spellID = 204021, name = "Fiery Brand", cooldown = 60, duration = 8, reduction = 40, type = "personal" },
            { spellID = 263648, name = "Soul Barrier", cooldown = 30, duration = 12, reduction = 0, type = "personal", notes = "Absorb shield" },
        },
    },
    
    -- DRUID
    DRUID = {
        SHARED = {
            { spellID = 22812, name = "Barkskin", cooldown = 60, duration = 8, reduction = 20, type = "personal" },
            { spellID = 108238, name = "Renewal", cooldown = 90, duration = 0, reduction = 0, type = "personal", notes = "30% instant heal" },
        },
        -- Balance (spec ID: 102)
        [102] = {},
        -- Feral (spec ID: 103)
        [103] = {
            { spellID = 61336, name = "Survival Instincts", cooldown = 180, duration = 6, reduction = 50, type = "personal" },
        },
        -- Guardian (spec ID: 104)
        [104] = {
            { spellID = 61336, name = "Survival Instincts", cooldown = 180, duration = 6, reduction = 50, type = "personal" },
            { spellID = 22842, name = "Frenzied Regeneration", cooldown = 36, duration = 3, reduction = 0, type = "personal", notes = "24% heal over time" },
            { spellID = 102558, name = "Incarnation: Guardian", cooldown = 180, duration = 30, reduction = 0, type = "personal", notes = "+15% health" },
        },
        -- Restoration (spec ID: 105)
        [105] = {
            { spellID = 102342, name = "Ironbark", cooldown = 90, duration = 12, reduction = 20, type = "external" },
        },
    },
    
    -- EVOKER
    EVOKER = {
        SHARED = {
            { spellID = 363916, name = "Obsidian Scales", cooldown = 90, duration = 12, reduction = 30, type = "personal" },
            { spellID = 374348, name = "Renewing Blaze", cooldown = 90, duration = 8, reduction = 0, type = "personal", notes = "Heal over time" },
        },
        -- Devastation (spec ID: 1467)
        [1467] = {},
        -- Preservation (spec ID: 1468)
        [1468] = {},
        -- Augmentation (spec ID: 1473)
        [1473] = {},
    },
    
    -- HUNTER
    HUNTER = {
        SHARED = {
            { spellID = 186265, name = "Aspect of the Turtle", cooldown = 180, duration = 8, reduction = 100, type = "immunity", notes = "Immune but can't attack" },
            { spellID = 109304, name = "Exhilaration", cooldown = 120, duration = 0, reduction = 0, type = "personal", notes = "30% instant heal" },
            { spellID = 264735, name = "Survival of the Fittest", cooldown = 180, duration = 6, reduction = 20, type = "personal" },
        },
        -- Beast Mastery (spec ID: 253)
        [253] = {},
        -- Marksmanship (spec ID: 254)
        [254] = {},
        -- Survival (spec ID: 255)
        [255] = {},
    },
    
    -- MAGE
    MAGE = {
        SHARED = {
            { spellID = 45438, name = "Ice Block", cooldown = 240, duration = 10, reduction = 100, type = "immunity" },
            { spellID = 55342, name = "Mirror Image", cooldown = 120, duration = 40, reduction = 0, type = "personal", notes = "Threat drop" },
            { spellID = 342245, name = "Alter Time", cooldown = 60, duration = 10, reduction = 0, type = "personal", notes = "Reset health/position" },
        },
        -- Arcane (spec ID: 62)
        [62] = {
            { spellID = 235450, name = "Prismatic Barrier", cooldown = 25, duration = 60, reduction = 0, type = "personal", notes = "Absorb shield" },
        },
        -- Fire (spec ID: 63)
        [63] = {
            { spellID = 235313, name = "Blazing Barrier", cooldown = 25, duration = 60, reduction = 0, type = "personal", notes = "Absorb shield" },
        },
        -- Frost (spec ID: 64)
        [64] = {
            { spellID = 235219, name = "Cold Snap", cooldown = 270, duration = 0, reduction = 0, type = "personal", notes = "Reset Ice Block CD" },
            { spellID = 11426, name = "Ice Barrier", cooldown = 25, duration = 60, reduction = 0, type = "personal", notes = "Absorb shield" },
        },
    },
    
    -- MONK
    MONK = {
        SHARED = {
            { spellID = 122278, name = "Dampen Harm", cooldown = 120, duration = 10, reduction = 20, type = "personal", notes = "Up to 50% on big hits" },
            { spellID = 122783, name = "Diffuse Magic", cooldown = 90, duration = 6, reduction = 60, type = "personal", notes = "Magic only" },
            { spellID = 243435, name = "Fortifying Brew", cooldown = 180, duration = 15, reduction = 20, type = "personal", notes = "+20% health" },
        },
        -- Brewmaster (spec ID: 268)
        [268] = {
            { spellID = 115176, name = "Zen Meditation", cooldown = 300, duration = 8, reduction = 60, type = "personal", notes = "Channeled" },
            { spellID = 322507, name = "Celestial Brew", cooldown = 60, duration = 8, reduction = 0, type = "personal", notes = "Absorb shield" },
        },
        -- Mistweaver (spec ID: 270)
        [270] = {
            { spellID = 116849, name = "Life Cocoon", cooldown = 120, duration = 12, reduction = 0, type = "external", notes = "Absorb + healing boost" },
        },
        -- Windwalker (spec ID: 269)
        [269] = {
            { spellID = 122470, name = "Touch of Karma", cooldown = 90, duration = 10, reduction = 0, type = "personal", notes = "Redirects damage" },
        },
    },
    
    -- PALADIN
    PALADIN = {
        SHARED = {
            { spellID = 642, name = "Divine Shield", cooldown = 300, duration = 8, reduction = 100, type = "immunity" },
            { spellID = 633, name = "Lay on Hands", cooldown = 600, duration = 0, reduction = 0, type = "personal", notes = "Full heal" },
            { spellID = 184662, name = "Shield of Vengeance", cooldown = 90, duration = 15, reduction = 0, type = "personal", notes = "Absorb shield" },
        },
        -- Holy (spec ID: 65)
        [65] = {
            { spellID = 498, name = "Divine Protection", cooldown = 60, duration = 8, reduction = 20, type = "personal" },
            { spellID = 6940, name = "Blessing of Sacrifice", cooldown = 120, duration = 12, reduction = 0, type = "external", notes = "Transfer 30% damage" },
            { spellID = 1022, name = "Blessing of Protection", cooldown = 300, duration = 10, reduction = 100, type = "external", notes = "Physical immunity" },
        },
        -- Protection (spec ID: 66)
        [66] = {
            { spellID = 31850, name = "Ardent Defender", cooldown = 120, duration = 8, reduction = 20, type = "personal", notes = "Cheat death" },
            { spellID = 86659, name = "Guardian of Ancient Kings", cooldown = 300, duration = 8, reduction = 50, type = "personal" },
            { spellID = 6940, name = "Blessing of Sacrifice", cooldown = 120, duration = 12, reduction = 0, type = "external" },
            { spellID = 1022, name = "Blessing of Protection", cooldown = 300, duration = 10, reduction = 100, type = "external" },
        },
        -- Retribution (spec ID: 70)
        [70] = {
            { spellID = 184662, name = "Shield of Vengeance", cooldown = 90, duration = 15, reduction = 0, type = "personal" },
            { spellID = 6940, name = "Blessing of Sacrifice", cooldown = 120, duration = 12, reduction = 0, type = "external" },
            { spellID = 1022, name = "Blessing of Protection", cooldown = 300, duration = 10, reduction = 100, type = "external" },
        },
    },
    
    -- PRIEST
    PRIEST = {
        SHARED = {
            { spellID = 586, name = "Fade", cooldown = 30, duration = 10, reduction = 0, type = "personal", notes = "Threat drop" },
            { spellID = 19236, name = "Desperate Prayer", cooldown = 90, duration = 10, reduction = 0, type = "personal", notes = "25% heal + 25% max health" },
        },
        -- Discipline (spec ID: 256)
        [256] = {
            { spellID = 33206, name = "Pain Suppression", cooldown = 180, duration = 8, reduction = 40, type = "external" },
            { spellID = 271466, name = "Luminous Barrier", cooldown = 180, duration = 10, reduction = 0, type = "external", notes = "Raid absorb" },
        },
        -- Holy (spec ID: 257)
        [257] = {
            { spellID = 47788, name = "Guardian Spirit", cooldown = 180, duration = 10, reduction = 0, type = "external", notes = "Cheat death + 60% healing" },
        },
        -- Shadow (spec ID: 258)
        [258] = {
            { spellID = 47585, name = "Dispersion", cooldown = 120, duration = 6, reduction = 75, type = "personal" },
            { spellID = 108968, name = "Void Shift", cooldown = 300, duration = 0, reduction = 0, type = "personal", notes = "Swap health %" },
        },
    },
    
    -- ROGUE
    ROGUE = {
        SHARED = {
            { spellID = 5277, name = "Evasion", cooldown = 120, duration = 10, reduction = 0, type = "personal", notes = "+100% dodge" },
            { spellID = 1856, name = "Vanish", cooldown = 120, duration = 3, reduction = 0, type = "personal", notes = "Drop combat" },
            { spellID = 31224, name = "Cloak of Shadows", cooldown = 120, duration = 5, reduction = 100, type = "personal", notes = "Magic immunity" },
            { spellID = 185311, name = "Crimson Vial", cooldown = 30, duration = 4, reduction = 0, type = "personal", notes = "20% heal" },
        },
        -- Assassination (spec ID: 259)
        [259] = {},
        -- Outlaw (spec ID: 260)
        [260] = {
            { spellID = 199754, name = "Riposte", cooldown = 120, duration = 10, reduction = 0, type = "personal", notes = "100% parry" },
        },
        -- Subtlety (spec ID: 261)
        [261] = {},
    },
    
    -- SHAMAN
    SHAMAN = {
        SHARED = {
            { spellID = 108271, name = "Astral Shift", cooldown = 90, duration = 12, reduction = 40, type = "personal" },
        },
        -- Elemental (spec ID: 262)
        [262] = {},
        -- Enhancement (spec ID: 263)
        [263] = {},
        -- Restoration (spec ID: 264)
        [264] = {
            { spellID = 98008, name = "Spirit Link Totem", cooldown = 180, duration = 6, reduction = 10, type = "external", notes = "Redistributes health" },
            { spellID = 207399, name = "Ancestral Protection Totem", cooldown = 300, duration = 30, reduction = 0, type = "external", notes = "Cheat death" },
        },
    },
    
    -- WARLOCK
    WARLOCK = {
        SHARED = {
            { spellID = 104773, name = "Unending Resolve", cooldown = 180, duration = 8, reduction = 40, type = "personal" },
            { spellID = 108416, name = "Dark Pact", cooldown = 60, duration = 20, reduction = 0, type = "personal", notes = "Absorb shield" },
            { spellID = 6789, name = "Mortal Coil", cooldown = 45, duration = 0, reduction = 0, type = "personal", notes = "20% heal" },
        },
        -- Affliction (spec ID: 265)
        [265] = {},
        -- Demonology (spec ID: 266)
        [266] = {},
        -- Destruction (spec ID: 267)
        [267] = {},
    },
    
    -- WARRIOR
    WARRIOR = {
        SHARED = {
            { spellID = 184364, name = "Enraged Regeneration", cooldown = 120, duration = 8, reduction = 0, type = "personal", notes = "30% heal" },
            { spellID = 97462, name = "Rallying Cry", cooldown = 180, duration = 10, reduction = 0, type = "personal", notes = "+15% max health raid-wide" },
        },
        -- Arms (spec ID: 71)
        [71] = {
            { spellID = 118038, name = "Die by the Sword", cooldown = 120, duration = 8, reduction = 30, type = "personal", notes = "+100% parry" },
        },
        -- Fury (spec ID: 72)
        [72] = {
            { spellID = 184364, name = "Enraged Regeneration", cooldown = 120, duration = 8, reduction = 0, type = "personal", notes = "30% heal" },
        },
        -- Protection (spec ID: 73)
        [73] = {
            { spellID = 871, name = "Shield Wall", cooldown = 210, duration = 8, reduction = 40, type = "personal" },
            { spellID = 12975, name = "Last Stand", cooldown = 180, duration = 15, reduction = 0, type = "personal", notes = "+30% health" },
            { spellID = 23920, name = "Spell Reflection", cooldown = 25, duration = 5, reduction = 0, type = "personal", notes = "Reflect spells" },
        },
    },
}

--------------------------------------------------------------------------------
-- Healthstone / Potions / Racials
--------------------------------------------------------------------------------

DA.ConsumablesDB = {
    { spellID = 6262, name = "Healthstone", cooldown = 60, reduction = 0, type = "consumable", notes = "25% heal", itemID = 5512 },
    { spellID = 370511, name = "Refreshing Healing Potion", cooldown = 300, reduction = 0, type = "consumable", notes = "Potion", itemID = 191380 },
    { spellID = 431416, name = "Algari Healing Potion", cooldown = 300, reduction = 0, type = "consumable", notes = "Potion", itemID = 211880 },
}

--------------------------------------------------------------------------------
-- Bag Check for Consumables
--------------------------------------------------------------------------------

function DA:HasItemInBags(itemID)
    if not itemID then return false end
    
    -- Check all bag slots
    for bag = 0, 4 do
        for slot = 1, C_Container.GetContainerNumSlots(bag) do
            local info = C_Container.GetContainerItemInfo(bag, slot)
            if info and info.itemID == itemID then
                return true, info.stackCount
            end
        end
    end
    return false, 0
end

function DA:GetAvailableConsumables()
    local available = {}
    
    -- Only include consumables if the setting allows
    if not DeathAnalyzerDB.includeConsumables then
        return available
    end
    
    for _, consumable in ipairs(self.ConsumablesDB) do
        if consumable.itemID then
            local hasItem, count = self:HasItemInBags(consumable.itemID)
            if hasItem then
                local entry = {}
                for k, v in pairs(consumable) do
                    entry[k] = v
                end
                entry.stackCount = count
                table.insert(available, entry)
            end
        end
    end
    
    return available
end

DA.RacialsDB = {
    { spellID = 59752, name = "Will to Survive", race = "Human", cooldown = 180, type = "racial" },
    { spellID = 20594, name = "Stoneform", race = "Dwarf", cooldown = 120, duration = 8, reduction = 10, type = "racial" },
    { spellID = 58984, name = "Shadowmeld", race = "NightElf", cooldown = 120, type = "racial" },
    { spellID = 265221, name = "Fireblood", race = "DarkIronDwarf", cooldown = 120, type = "racial" },
}

--------------------------------------------------------------------------------
-- Helper Functions
--------------------------------------------------------------------------------

-- Get all defensives for current class/spec
function DA:GetPlayerDefensives()
    local playerInfo = self:GetPlayerInfo()
    local class = playerInfo.class
    local specID = playerInfo.specID
    
    local defensives = {}
    
    -- Get class data
    local classData = self.DefensiveDB[class]
    if not classData then
        self:Debug("No defensive data for class: " .. tostring(class))
        return defensives
    end
    
    -- Add shared class defensives
    if classData.SHARED then
        for _, def in ipairs(classData.SHARED) do
            table.insert(defensives, def)
        end
    end
    
    -- Add spec-specific defensives
    if specID and classData[specID] then
        for _, def in ipairs(classData[specID]) do
            table.insert(defensives, def)
        end
    end
    
    -- Add consumables only if setting enabled and items are in bags
    if DeathAnalyzerDB.includeConsumables then
        local availableConsumables = self:GetAvailableConsumables()
        for _, def in ipairs(availableConsumables) do
            table.insert(defensives, def)
        end
    end
    
    return defensives
end

-- Initialize defensive state tracking
function DA:InitializeDefensives()
    local defensives = self:GetPlayerDefensives()
    
    self.defensiveState = {}
    
    for _, def in ipairs(defensives) do
        if def.spellID then
            self.defensiveState[def.spellID] = {
                info = def,
                lastUsed = 0,
                isReady = true,
            }
        else
            self:Debug("Skipping defensive with no spellID: " .. (def.name or "unknown"))
        end
    end
    
    self:Debug("Initialized " .. #defensives .. " defensives for tracking")
end

-- Check if a defensive was ready at a specific time
function DA:WasDefensiveReady(spellID, atTime)
    local state = self.defensiveState[spellID]
    if not state then return false end
    
    local lastUsed = state.lastUsed or 0
    local cooldown = state.info.cooldown or 0
    
    return (atTime - lastUsed) >= cooldown
end

-- Get all defensives that were ready at death
function DA:GetReadyDefensivesAtDeath(deathTime)
    local ready = {}
    
    for spellID, state in pairs(self.defensiveState) do
        if self:WasDefensiveReady(spellID, deathTime) then
            local readyFor = deathTime - (state.lastUsed + state.info.cooldown)
            if state.lastUsed == 0 then
                readyFor = 999 -- Never used
            end
            
            table.insert(ready, {
                spellID = spellID,
                info = state.info,
                readyFor = readyFor,
            })
        end
    end
    
    -- Sort by damage reduction potential (highest first)
    table.sort(ready, function(a, b)
        return (a.info.reduction or 0) > (b.info.reduction or 0)
    end)
    
    return ready
end

-- Update defensive usage tracking
function DA:OnDefensiveUsed(spellID, timestamp)
    if self.defensiveState[spellID] then
        self.defensiveState[spellID].lastUsed = timestamp
        self.defensiveState[spellID].isReady = false
        self:Debug("Defensive used: " .. (self.defensiveState[spellID].info.name or spellID))
    end
end

--------------------------------------------------------------------------------
-- Talent Cooldown Reduction Database
-- Format: [talentSpellID] = { affects = {spellID, ...}, reduction = seconds OR reductionPercent = 0.XX }
--------------------------------------------------------------------------------

DA.TalentCDRDB = {
    -- DEATH KNIGHT
    -- Icy Talons (Frost): reduces Icebound Fortitude CD
    [194878] = { affects = {48792}, reduction = 15 },
    -- Osmosis: reduces Anti-Magic Shell CD
    [454835] = { affects = {48707}, reduction = 15 },
    
    -- DEMON HUNTER  
    -- Desperate Instincts: Blur CD reduction (talent node)
    [205411] = { affects = {198589}, reduction = 15 },
    -- Darkness talent improvements
    [196419] = { affects = {196555}, reduction = 30 }, -- Netherwalk CD reduction
    
    -- DRUID
    -- Innate Resolve: Barkskin CD reduction
    [377811] = { affects = {22812}, reduction = 12 },
    -- Survival Instincts CD reduction (Guardian)
    [61336] = { affects = {61336}, reductionPercent = 0.33 }, -- Placeholder for talent node
    
    -- EVOKER
    -- Obsidian Bulwark: Obsidian Scales CD reduction
    [375406] = { affects = {363916}, reduction = 30 },
    
    -- HUNTER
    -- Born To Be Wild: reduces Aspect of the Turtle CD
    [266921] = { affects = {186265, 264735}, reductionPercent = 0.20 },
    
    -- MAGE
    -- Cryo-Freeze: Ice Block healing (not CD reduction but useful)
    [382292] = { affects = {45438}, reduction = 0 }, -- placeholder
    -- Ice Cold: Ice Block CD reduction
    [414659] = { affects = {45438}, reduction = 30 },
    
    -- MONK
    -- Expeditious Fortification: Fortifying Brew CD reduction
    [388814] = { affects = {243435}, reduction = 60 },
    -- Fundamental Observation: Zen Meditation CD reduction
    [387184] = { affects = {115176}, reduction = 60 },
    
    -- PALADIN
    -- Unbreakable Spirit: Divine Shield, Divine Protection, Lay on Hands CD reduction
    [114154] = { affects = {642, 498, 633}, reductionPercent = 0.30 },
    -- Divine Purpose (can reset CD on proc - not tracked)
    
    -- PRIEST
    -- Angel's Mercy: reduces Desperate Prayer CD
    [238100] = { affects = {19236}, reduction = 20 },
    -- Inspiration: Guardian Spirit CD reduction on save
    [390676] = { affects = {47788}, reduction = 60 },
    
    -- ROGUE
    -- Elusiveness: Evasion/Cloak CD reduction
    [79008] = { affects = {5277, 31224}, reduction = 30 },
    -- Graceful Guile: Feint CD reduction (utility)
    [423647] = { affects = {1966}, reduction = 0 }, -- placeholder
    
    -- SHAMAN
    -- Ancestral Defense: Astral Shift CD reduction
    [382947] = { affects = {108271}, reduction = 30 },
    -- Planes Traveler: Astral Shift CD when Spirit Wolf form active
    [381647] = { affects = {108271}, reduction = 3 }, -- per second in Ghost Wolf
    
    -- WARLOCK
    -- Frequent Donor: Dark Pact CD reduction
    [386686] = { affects = {108416}, reduction = 15 },
    -- Demonic Durability: Unending Resolve CD reduction
    [389055] = { affects = {104773}, reduction = 30 },
    
    -- WARRIOR
    -- Bolster: Last Stand/Shield Wall improvements
    [280001] = { affects = {12975, 871}, reduction = 0 }, -- shared charges mechanic
    -- Overwhelming Rage: extends Enraged Regeneration
    [382767] = { affects = {184364}, reduction = 0 }, -- extends duration, not CD
    -- Defensive Stance: Die by the Sword CD reduction (Arms)
    [386208] = { affects = {118038}, reduction = 30 },
}

--------------------------------------------------------------------------------
-- Talent Detection and Effective Cooldown Calculation
--------------------------------------------------------------------------------

-- Cache for active talents
DA.activeTalentCDRs = {}

-- Refresh talent cache
function DA:RefreshTalentCDR()
    self.activeTalentCDRs = {}
    
    -- Build a list of CDR effects from active talents
    for talentSpellID, cdrInfo in pairs(self.TalentCDRDB) do
        -- Check if the player knows this talent
        if IsPlayerSpell(talentSpellID) or IsSpellKnown(talentSpellID) then
            for _, affectedSpellID in ipairs(cdrInfo.affects) do
                if not self.activeTalentCDRs[affectedSpellID] then
                    self.activeTalentCDRs[affectedSpellID] = {
                        flatReduction = 0,
                        percentReduction = 0,
                    }
                end
                
                if cdrInfo.reduction then
                    self.activeTalentCDRs[affectedSpellID].flatReduction = 
                        self.activeTalentCDRs[affectedSpellID].flatReduction + cdrInfo.reduction
                end
                
                if cdrInfo.reductionPercent then
                    -- Multiplicative stacking for percent reductions
                    local current = self.activeTalentCDRs[affectedSpellID].percentReduction
                    local newReduction = 1 - ((1 - current) * (1 - cdrInfo.reductionPercent))
                    self.activeTalentCDRs[affectedSpellID].percentReduction = newReduction
                end
            end
            self:Debug("Active talent CDR detected: " .. talentSpellID)
        end
    end
end

-- Get effective cooldown for a defensive ability
function DA:GetEffectiveCooldown(spellID, baseCooldown)
    local cdr = self.activeTalentCDRs[spellID]
    
    if not cdr then
        return baseCooldown
    end
    
    local effectiveCD = baseCooldown
    
    -- Apply percent reduction first (multiplicative)
    if cdr.percentReduction > 0 then
        effectiveCD = effectiveCD * (1 - cdr.percentReduction)
    end
    
    -- Apply flat reduction
    if cdr.flatReduction > 0 then
        effectiveCD = effectiveCD - cdr.flatReduction
    end
    
    -- Minimum 1 second cooldown
    return math.max(1, effectiveCD)
end

-- Updated defensive ready check using effective cooldowns
function DA:WasDefensiveReadyWithCDR(spellID, atTime)
    local state = self.defensiveState[spellID]
    if not state then return false end
    
    local lastUsed = state.lastUsed or 0
    local baseCooldown = state.info.cooldown or 0
    local effectiveCooldown = self:GetEffectiveCooldown(spellID, baseCooldown)
    
    return (atTime - lastUsed) >= effectiveCooldown
end

-- Get all ready defensives with CDR-aware calculation
function DA:GetReadyDefensivesAtDeathWithCDR(deathTime)
    local ready = {}
    
    for spellID, state in pairs(self.defensiveState) do
        local baseCooldown = state.info.cooldown or 0
        local effectiveCooldown = self:GetEffectiveCooldown(spellID, baseCooldown)
        local lastUsed = state.lastUsed or 0
        
        if (deathTime - lastUsed) >= effectiveCooldown then
            local readyFor = deathTime - (lastUsed + effectiveCooldown)
            if lastUsed == 0 then
                readyFor = 999 -- Never used
            end
            
            table.insert(ready, {
                spellID = spellID,
                info = state.info,
                readyFor = readyFor,
                baseCooldown = baseCooldown,
                effectiveCooldown = effectiveCooldown,
                hasCDR = (baseCooldown ~= effectiveCooldown),
            })
        end
    end
    
    -- Sort by damage reduction potential (highest first)
    table.sort(ready, function(a, b)
        return (a.info.reduction or 0) > (b.info.reduction or 0)
    end)
    
    return ready
end
