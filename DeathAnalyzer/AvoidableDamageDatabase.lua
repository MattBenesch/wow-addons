--[[
    Avoidable Damage Database
    Contains all avoidable M+ dungeon mechanics and affixes
    
    Each entry has:
    - spellID: The spell ID (verify in-game if uncertain)
    - name: Display name of the ability
    - avoidance: How to avoid the damage
    - category: "frontal", "ground", "interrupt", "soak", "dodge", "positioning", "add"
    - dungeon: Which dungeon this is from (for filtering)
    
    To add new entries or correct spell IDs:
    1. Use /da debug in-game to see spell IDs in combat
    2. Check Wowhead for correct spell IDs
    3. Add entries following the format below
]]

local ADDON_NAME, DA = ...

--------------------------------------------------------------------------------
-- Avoidance Categories
--------------------------------------------------------------------------------

DA.AvoidanceCategories = {
    frontal = { name = "Frontal", short = "FRONT", icon = "F", color = "|cFFFF6600", tip = "Don't stand in front of the enemy" },
    ground = { name = "Ground Effect", short = "GROUND", icon = "G", color = "|cFFFF0000", tip = "Move out of the ground effect" },
    interrupt = { name = "Interruptible", short = "KICK", icon = "I", color = "|cFFFFFF00", tip = "Interrupt this cast" },
    soak = { name = "Soak/Stack", short = "SOAK", icon = "S", color = "|cFF00FFFF", tip = "Spread or stack as needed" },
    dodge = { name = "Dodge", short = "DODGE", icon = "D", color = "|cFFFF8800", tip = "Sidestep or move away" },
    positioning = { name = "Positioning", short = "POS", icon = "P", color = "|cFF8800FF", tip = "Adjust your position" },
    add = { name = "Add Damage", short = "ADD", icon = "A", color = "|cFFFF00FF", tip = "Kill or kite the add" },
    environmental = { name = "Environment", short = "ENV", icon = "E", color = "|cFF888888", tip = "Watch your surroundings" },
}

--------------------------------------------------------------------------------
-- Category Weights for Scoring
-- Higher weight = more blame on player for taking this damage
-- Lower weight = less preventable or shared responsibility
--------------------------------------------------------------------------------

DA.CategoryWeights = {
    frontal = 1.0,       -- Predictable, clearly telegraphed, should always avoid
    ground = 1.0,        -- Visible effects, should move out quickly
    interrupt = 0.8,     -- May have interrupt on CD or multiple casters
    dodge = 0.9,         -- Requires good reaction time
    soak = 0.7,          -- Often unavoidable (tank soaking, raid mechanics)
    positioning = 0.8,   -- Complex mechanics, harder to optimize
    add = 0.6,           -- Often group responsibility, not just individual
    environmental = 1.2, -- Purely player error (falling, standing in lava)
}

-- Get weight for a category (defaults to 1.0 if unknown)
function DA:GetCategoryWeight(category)
    return self.CategoryWeights[category] or 1.0
end

--------------------------------------------------------------------------------
-- M+ Affix Mechanics (Common across all dungeons)
--------------------------------------------------------------------------------

DA.AffixMechanics = {
    -- Volcanic
    [209862] = { 
        name = "Volcanic Plume", 
        avoidance = "Move away from the volcanic plume spawning under you",
        category = "ground",
        dungeon = "Affix"
    },
    
    -- Sanguine
    [226512] = { 
        name = "Sanguine Ichor", 
        avoidance = "Don't stand in the blood pool - it heals enemies",
        category = "ground",
        dungeon = "Affix"
    },
    
    -- Storming
    [343520] = { 
        name = "Storming", 
        avoidance = "Avoid the moving tornado",
        category = "dodge",
        dungeon = "Affix"
    },
    
    -- Spiteful
    [350163] = { 
        name = "Spiteful Shade", 
        avoidance = "Kite the Spiteful Shade - it fixates on you",
        category = "add",
        dungeon = "Affix"
    },
    
    -- Quaking
    [240447] = { 
        name = "Quake", 
        avoidance = "Spread out to avoid overlapping with teammates",
        category = "soak",
        dungeon = "Affix"
    },
    
    -- Bursting
    [243237] = { 
        name = "Burst", 
        avoidance = "Don't kill too many mobs at once - stagger kills",
        category = "positioning",
        dungeon = "Affix"
    },
    
    -- Necrotic (if it returns)
    [209858] = { 
        name = "Necrotic Wound", 
        avoidance = "Tank needs to kite to drop stacks",
        category = "positioning",
        dungeon = "Affix"
    },
    
    -- Explosive
    [240446] = { 
        name = "Explosive Orb", 
        avoidance = "Kill the Explosive Orb before it detonates",
        category = "add",
        dungeon = "Affix"
    },
    
    -- Grievous
    [240559] = { 
        name = "Grievous Wound", 
        avoidance = "Healers must top players off to remove the bleed",
        category = "soak",
        dungeon = "Affix"
    },
}

--------------------------------------------------------------------------------
-- THE STONEVAULT
--------------------------------------------------------------------------------

DA.StonevaultMechanics = {
    -- E.D.N.A.
    [423572] = {
        name = "Refracting Beam",
        avoidance = "Position behind a spike to break line of sight",
        category = "positioning",
        dungeon = "The Stonevault"
    },
    [423327] = {
        name = "Volatile Spike",
        avoidance = "Destroy spikes with the beam before they explode",
        category = "ground",
        dungeon = "The Stonevault"
    },
    [423246] = {
        name = "Earth Shatterer",
        avoidance = "Use defensives - this is heavy group-wide damage",
        category = "soak",
        dungeon = "The Stonevault"
    },
    
    -- Skarmorak
    [423313] = {
        name = "Crystalline Smash",
        avoidance = "Don't stand in front of the boss",
        category = "frontal",
        dungeon = "The Stonevault"
    },
    [423228] = {
        name = "Void Discharge",
        avoidance = "Collect Unstable Fragments to break the shield and prevent this",
        category = "soak",
        dungeon = "The Stonevault"
    },
    [423393] = {
        name = "Unstable Crash",
        avoidance = "Move away from impact zones",
        category = "ground",
        dungeon = "The Stonevault"
    },
    
    -- Master Machinists (Brokk and Dorlita)
    [428202] = {
        name = "Scrap Song",
        avoidance = "Dodge the giant metal cube moving across the arena",
        category = "dodge",
        dungeon = "The Stonevault"
    },
    [428711] = {
        name = "Lava Cannon",
        avoidance = "Targeted player should move away from the group",
        category = "soak",
        dungeon = "The Stonevault"
    },
    [428535] = {
        name = "Blazing Crescendo",
        avoidance = "Move to the edges of the arena - center will explode",
        category = "ground",
        dungeon = "The Stonevault"
    },
    [428820] = {
        name = "Molten Metal",
        avoidance = "Interrupt this cast to prevent the slow debuff",
        category = "interrupt",
        dungeon = "The Stonevault"
    },
    
    -- Void Speaker Eirich
    [427329] = {
        name = "Void Rift",
        avoidance = "Stay away from the rift to avoid being pulled in",
        category = "positioning",
        dungeon = "The Stonevault"
    },
    [427854] = {
        name = "Entropic Reckoning",
        avoidance = "Move out of the shadow zones",
        category = "ground",
        dungeon = "The Stonevault"
    },
    [427382] = {
        name = "Void Corruption",
        avoidance = "Clear debuff by approaching void portals without touching them",
        category = "positioning",
        dungeon = "The Stonevault"
    },
    
    -- Trash
    [426308] = {
        name = "Seismic Wave",
        avoidance = "Sidestep the wave or use movement ability",
        category = "dodge",
        dungeon = "The Stonevault"
    },
    [426283] = {
        name = "Ground Pound",
        avoidance = "Move away from the impact zone",
        category = "ground",
        dungeon = "The Stonevault"
    },
}

--------------------------------------------------------------------------------
-- THE DAWNBREAKER
--------------------------------------------------------------------------------

DA.DawnbreakerMechanics = {
    -- Speaker Shadowcrown
    [431309] = {
        name = "Obsidian Beam",
        avoidance = "Move out of the beam's path",
        category = "dodge",
        dungeon = "The Dawnbreaker"
    },
    [431494] = {
        name = "Collapsing Darkness",
        avoidance = "Move away from the portals before they explode",
        category = "ground",
        dungeon = "The Dawnbreaker"
    },
    [431333] = {
        name = "Burning Shadows",
        avoidance = "Interrupt this cast to prevent major damage",
        category = "interrupt",
        dungeon = "The Dawnbreaker"
    },
    
    -- Anub'ikkaj
    [432520] = {
        name = "Dark Orb",
        avoidance = "Stay away from the orb's path - damage decreases with distance",
        category = "dodge",
        dungeon = "The Dawnbreaker"
    },
    [432565] = {
        name = "Shadowy Decay",
        avoidance = "Spread out and use defensives for heavy group damage",
        category = "soak",
        dungeon = "The Dawnbreaker"
    },
    [432031] = {
        name = "Terrifying Slam",
        avoidance = "Tank should face boss away from group - causes knockback/fear",
        category = "frontal",
        dungeon = "The Dawnbreaker"
    },
    
    -- Rasha'nan
    [434089] = {
        name = "Rolling Acid",
        avoidance = "Dodge the acid waves by moving perpendicular",
        category = "dodge",
        dungeon = "The Dawnbreaker"
    },
    [434137] = {
        name = "Sticky Webs",
        avoidance = "Break free from webs immediately to avoid being trapped",
        category = "ground",
        dungeon = "The Dawnbreaker"
    },
    [434213] = {
        name = "Acidic Eruption",
        avoidance = "Interrupt this cast to prevent massive AoE damage",
        category = "interrupt",
        dungeon = "The Dawnbreaker"
    },
    
    -- Trash
    [430086] = {
        name = "Shadow Bolt Volley",
        avoidance = "Interrupt to reduce group damage",
        category = "interrupt",
        dungeon = "The Dawnbreaker"
    },
    [430172] = {
        name = "Dark Pulse",
        avoidance = "Move away from the caster",
        category = "ground",
        dungeon = "The Dawnbreaker"
    },
}

--------------------------------------------------------------------------------
-- ARA-KARA, CITY OF ECHOES
--------------------------------------------------------------------------------

DA.AraKaraMechanics = {
    -- Avanoxx
    [438476] = {
        name = "Gossamer Onslaught",
        avoidance = "Sidestep the indicators and avoid standing in webbing",
        category = "dodge",
        dungeon = "Ara-Kara"
    },
    [438531] = {
        name = "Web Spray",
        avoidance = "Spread out to avoid overlapping webs",
        category = "soak",
        dungeon = "Ara-Kara"
    },
    [438592] = {
        name = "Alerting Shrill",
        avoidance = "Kite and kill the Starved Crawlers quickly",
        category = "add",
        dungeon = "Ara-Kara"
    },
    
    -- Anub'zekt
    [439341] = {
        name = "Burrow Charge",
        avoidance = "Move away from the charge path",
        category = "dodge",
        dungeon = "Ara-Kara"
    },
    [439269] = {
        name = "Impale",
        avoidance = "Don't stand in front of the boss",
        category = "frontal",
        dungeon = "Ara-Kara"
    },
    [439508] = {
        name = "Ceaseless Swarm",
        avoidance = "Kill adds before they overwhelm the group",
        category = "add",
        dungeon = "Ara-Kara"
    },
    
    -- Ki'katal the Harvester
    [440246] = {
        name = "Grasping Blood",
        avoidance = "Move out of the blood pools",
        category = "ground",
        dungeon = "Ara-Kara"
    },
    [440313] = {
        name = "Venom Strike",
        avoidance = "Tank should use active mitigation for this hit",
        category = "frontal",
        dungeon = "Ara-Kara"
    },
    
    -- Trash
    [437533] = {
        name = "Poison Bolt",
        avoidance = "Interrupt this cast",
        category = "interrupt",
        dungeon = "Ara-Kara"
    },
    [437708] = {
        name = "Venomous Spray",
        avoidance = "Don't stand in the cone",
        category = "frontal",
        dungeon = "Ara-Kara"
    },
}

--------------------------------------------------------------------------------
-- CITY OF THREADS
--------------------------------------------------------------------------------

DA.CityOfThreadsMechanics = {
    -- Orator Krix'vizk
    [442863] = {
        name = "Terrorize",
        avoidance = "Interrupt this cast to prevent fear",
        category = "interrupt",
        dungeon = "City of Threads"
    },
    [442536] = {
        name = "Vociferous Indoctrination",
        avoidance = "Stack together to split the damage",
        category = "soak",
        dungeon = "City of Threads"
    },
    [442707] = {
        name = "Silk Binding",
        avoidance = "Break players out of the webbing quickly",
        category = "ground",
        dungeon = "City of Threads"
    },
    
    -- Fangs of the Queen
    [443427] = {
        name = "Ice Sickles",
        avoidance = "Dodge the sickles as they fly across the room",
        category = "dodge",
        dungeon = "City of Threads"
    },
    [443430] = {
        name = "Shade Slash",
        avoidance = "Don't stand between the two bosses",
        category = "positioning",
        dungeon = "City of Threads"
    },
    [443612] = {
        name = "Knife Throw",
        avoidance = "Avoid the knife trajectory",
        category = "dodge",
        dungeon = "City of Threads"
    },
    
    -- The Coaglamation
    [444123] = {
        name = "Dark Pulse",
        avoidance = "Move away from impact zones",
        category = "ground",
        dungeon = "City of Threads"
    },
    [444364] = {
        name = "Viscous Darkness",
        avoidance = "Don't stand in the void zones",
        category = "ground",
        dungeon = "City of Threads"
    },
    [444205] = {
        name = "Blood Surge",
        avoidance = "Spread out to minimize splash damage",
        category = "soak",
        dungeon = "City of Threads"
    },
    
    -- Izo, the Grand Splicer
    [445518] = {
        name = "Splice",
        avoidance = "Move away from the targeted area",
        category = "ground",
        dungeon = "City of Threads"
    },
    [445642] = {
        name = "Shifting Anomalies",
        avoidance = "Avoid the moving void zones",
        category = "dodge",
        dungeon = "City of Threads"
    },
    [445824] = {
        name = "Process of Elimination",
        avoidance = "Use defensives and healing cooldowns",
        category = "soak",
        dungeon = "City of Threads"
    },
    
    -- Trash
    [441216] = {
        name = "Poison Cloud",
        avoidance = "Move out of the poison cloud",
        category = "ground",
        dungeon = "City of Threads"
    },
    [441375] = {
        name = "Earthshatter",
        avoidance = "Don't stand in front of the Royal Swarmguard",
        category = "frontal",
        dungeon = "City of Threads"
    },
    [441522] = {
        name = "Twist Thoughts",
        avoidance = "Interrupt this to prevent the DoT",
        category = "interrupt",
        dungeon = "City of Threads"
    },
}

--------------------------------------------------------------------------------
-- GRIM BATOL
--------------------------------------------------------------------------------

DA.GrimBatolMechanics = {
    -- General Umbriss
    [451871] = {
        name = "Ground Siege",
        avoidance = "Move out of the impact zone",
        category = "ground",
        dungeon = "Grim Batol"
    },
    [451224] = {
        name = "Blitz",
        avoidance = "Don't stand in the charge path",
        category = "dodge",
        dungeon = "Grim Batol"
    },
    [451378] = {
        name = "Bleeding Wound",
        avoidance = "Use defensive cooldowns, heavy tank damage",
        category = "frontal",
        dungeon = "Grim Batol"
    },
    
    -- Forgemaster Throngus
    [74976] = {
        name = "Disorienting Roar",
        avoidance = "Expect reduced movement after the roar",
        category = "soak",
        dungeon = "Grim Batol"
    },
    [90756] = {
        name = "Impaling Slam",
        avoidance = "Don't stand in front during Mace phase",
        category = "frontal",
        dungeon = "Grim Batol"
    },
    [74981] = {
        name = "Dual Blades",
        avoidance = "Tank should kite during this phase",
        category = "positioning",
        dungeon = "Grim Batol"
    },
    [74986] = {
        name = "Personal Phalanx",
        avoidance = "Attack from behind - frontal damage is reflected",
        category = "positioning",
        dungeon = "Grim Batol"
    },
    
    -- Drahga Shadowburner
    [75238] = {
        name = "Invocation of Shadowflame",
        avoidance = "Kite and kill the Shadowflame Spirits",
        category = "add",
        dungeon = "Grim Batol"
    },
    [90950] = {
        name = "Devouring Flames",
        avoidance = "Move behind Valiona to avoid the breath",
        category = "frontal",
        dungeon = "Grim Batol"
    },
    [448040] = {
        name = "Shadowflame Bolt",
        avoidance = "Interrupt to reduce incoming damage",
        category = "interrupt",
        dungeon = "Grim Batol"
    },
    [448057] = {
        name = "Curse of Entropy",
        avoidance = "Dispel this curse on affected players",
        category = "soak",
        dungeon = "Grim Batol"
    },
    
    -- Erudax
    [75664] = {
        name = "Shadow Gale",
        avoidance = "Stand in the eye of the storm to avoid damage",
        category = "positioning",
        dungeon = "Grim Batol"
    },
    [75520] = {
        name = "Binding Shadows",
        avoidance = "Dispel this immediately on affected players",
        category = "soak",
        dungeon = "Grim Batol"
    },
    [91079] = {
        name = "Shadow Wounds",
        avoidance = "Avoid stacking too many debuffs",
        category = "soak",
        dungeon = "Grim Batol"
    },
    
    -- Trash
    [448016] = {
        name = "Shadowflame Slash",
        avoidance = "Don't stand in front of the caster",
        category = "frontal",
        dungeon = "Grim Batol"
    },
    [448058] = {
        name = "Twilight Flame",
        avoidance = "Move out of the fire",
        category = "ground",
        dungeon = "Grim Batol"
    },
}

--------------------------------------------------------------------------------
-- MISTS OF TIRNA SCITHE
--------------------------------------------------------------------------------

DA.MistsMechanics = {
    -- Ingra Maloch
    [323177] = {
        name = "Spirit Bolt",
        avoidance = "Interrupt to reduce incoming damage",
        category = "interrupt",
        dungeon = "Mists of Tirna Scithe"
    },
    [323057] = {
        name = "Spirit Thorns",
        avoidance = "Don't attack the boss while this buff is active",
        category = "positioning",
        dungeon = "Mists of Tirna Scithe"
    },
    [322614] = {
        name = "Mind Link",
        avoidance = "Move away from linked player to break the link",
        category = "soak",
        dungeon = "Mists of Tirna Scithe"
    },
    
    -- Mistcaller
    [321834] = {
        name = "Patty Cake",
        avoidance = "Tank should interrupt or avoid this",
        category = "interrupt",
        dungeon = "Mists of Tirna Scithe"
    },
    [321828] = {
        name = "Freeze Tag",
        avoidance = "Targeted player must run from the Illusionary Fox",
        category = "dodge",
        dungeon = "Mists of Tirna Scithe"
    },
    [336759] = {
        name = "Dodge Ball",
        avoidance = "Dodge the bouncing ball",
        category = "dodge",
        dungeon = "Mists of Tirna Scithe"
    },
    
    -- Tred'ova
    [322450] = {
        name = "Consumption",
        avoidance = "Kill the Gorged Parasites before they reach the boss",
        category = "add",
        dungeon = "Mists of Tirna Scithe"
    },
    [326281] = {
        name = "Parasitic Pacification",
        avoidance = "Interrupt this to prevent incapacitation",
        category = "interrupt",
        dungeon = "Mists of Tirna Scithe"
    },
    [322527] = {
        name = "Acid Expulsion",
        avoidance = "Move out of the acid pools",
        category = "ground",
        dungeon = "Mists of Tirna Scithe"
    },
    
    -- Trash
    [321968] = {
        name = "Mistveil Tear",
        avoidance = "Don't stand in the tear effect",
        category = "ground",
        dungeon = "Mists of Tirna Scithe"
    },
    [322938] = {
        name = "Harvest Essence",
        avoidance = "Interrupt to prevent healing",
        category = "interrupt",
        dungeon = "Mists of Tirna Scithe"
    },
    [322557] = {
        name = "Soul Split",
        avoidance = "Kill the Shattered Soul add quickly",
        category = "add",
        dungeon = "Mists of Tirna Scithe"
    },
}

--------------------------------------------------------------------------------
-- THE NECROTIC WAKE
--------------------------------------------------------------------------------

DA.NecroticWakeMechanics = {
    -- Blightbone
    [320637] = {
        name = "Fetid Gas",
        avoidance = "Move out of the gas cloud",
        category = "ground",
        dungeon = "The Necrotic Wake"
    },
    [320596] = {
        name = "Heaving Retch",
        avoidance = "Don't stand in front of the boss",
        category = "frontal",
        dungeon = "The Necrotic Wake"
    },
    [320655] = {
        name = "Carrion Worms",
        avoidance = "Kill the worms quickly before they spread",
        category = "add",
        dungeon = "The Necrotic Wake"
    },
    
    -- Amarth
    [320012] = {
        name = "Necrotic Bolt",
        avoidance = "Interrupt to reduce incoming damage",
        category = "interrupt",
        dungeon = "The Necrotic Wake"
    },
    [320170] = {
        name = "Necrotic Breath",
        avoidance = "Don't stand in front of the boss",
        category = "frontal",
        dungeon = "The Necrotic Wake"
    },
    [321247] = {
        name = "Final Harvest",
        avoidance = "Kill all adds before this casts - damage scales with living adds",
        category = "add",
        dungeon = "The Necrotic Wake"
    },
    [320171] = {
        name = "Land of the Dead",
        avoidance = "Kill the Reanimated adds quickly",
        category = "add",
        dungeon = "The Necrotic Wake"
    },
    
    -- Surgeon Stitchflesh
    [320358] = {
        name = "Stitchneedle",
        avoidance = "Avoid this to prevent the bleed effect",
        category = "dodge",
        dungeon = "The Necrotic Wake"
    },
    [327664] = {
        name = "Embalming Ichor",
        avoidance = "Move out of the ichor puddles",
        category = "ground",
        dungeon = "The Necrotic Wake"
    },
    [334476] = {
        name = "Morbid Fixation",
        avoidance = "Kite the add or use CC",
        category = "add",
        dungeon = "The Necrotic Wake"
    },
    [320366] = {
        name = "Meat Hook",
        avoidance = "Position yourself to pull the boss off the platform",
        category = "positioning",
        dungeon = "The Necrotic Wake"
    },
    
    -- Nalthor the Rimebinder
    [320772] = {
        name = "Comet Storm",
        avoidance = "Move out of the impact zones",
        category = "ground",
        dungeon = "The Necrotic Wake"
    },
    [320788] = {
        name = "Frozen Binds",
        avoidance = "Break the ice on frozen players quickly",
        category = "soak",
        dungeon = "The Necrotic Wake"
    },
    [321754] = {
        name = "Icebound Aegis",
        avoidance = "Kill the Brittlebone Warrior to break the shield",
        category = "add",
        dungeon = "The Necrotic Wake"
    },
    [323730] = {
        name = "Dark Exile",
        avoidance = "Kill the Zolramus Siphoner in the exile realm quickly",
        category = "add",
        dungeon = "The Necrotic Wake"
    },
    
    -- Trash
    [324372] = {
        name = "Throw Cleaver",
        avoidance = "Dodge the thrown cleaver",
        category = "dodge",
        dungeon = "The Necrotic Wake"
    },
    [323471] = {
        name = "Spine Crush",
        avoidance = "Move away from the impact zone",
        category = "ground",
        dungeon = "The Necrotic Wake"
    },
    [334748] = {
        name = "Drain Fluids",
        avoidance = "Interrupt this channel",
        category = "interrupt",
        dungeon = "The Necrotic Wake"
    },
    [338357] = {
        name = "Goresplatter",
        avoidance = "Move out of the gore",
        category = "ground",
        dungeon = "The Necrotic Wake"
    },
}

--------------------------------------------------------------------------------
-- SIEGE OF BORALUS
--------------------------------------------------------------------------------

DA.SiegeMechanics = {
    -- Chopper Redhook
    [257459] = {
        name = "On The Hook",
        avoidance = "Move away from hooked players - don't chain",
        category = "soak",
        dungeon = "Siege of Boralus"
    },
    [257326] = {
        name = "Meat Hook",
        avoidance = "Dodge the hook or move behind cover",
        category = "dodge",
        dungeon = "Siege of Boralus"
    },
    [257292] = {
        name = "Heavy Slash",
        avoidance = "Tank should sidestep this frontal",
        category = "frontal",
        dungeon = "Siege of Boralus"
    },
    
    -- Dread Captain Lockwood
    [268260] = {
        name = "Broadside",
        avoidance = "Move out of the cannon impact zones",
        category = "ground",
        dungeon = "Siege of Boralus"
    },
    [268230] = {
        name = "Crimson Swipe",
        avoidance = "Don't stand in front of the boss",
        category = "frontal",
        dungeon = "Siege of Boralus"
    },
    [268752] = {
        name = "Barrel Smash",
        avoidance = "Move away from the barrel explosions",
        category = "ground",
        dungeon = "Siege of Boralus"
    },
    
    -- Hadal Darkfathom
    [261563] = {
        name = "Tidal Surge",
        avoidance = "Get behind cover to avoid the wave",
        category = "positioning",
        dungeon = "Siege of Boralus"
    },
    [257862] = {
        name = "Crashing Tide",
        avoidance = "Move out of the wave path",
        category = "dodge",
        dungeon = "Siege of Boralus"
    },
    [276068] = {
        name = "Break Water",
        avoidance = "Spread out to minimize splash damage",
        category = "soak",
        dungeon = "Siege of Boralus"
    },
    
    -- Viq'Goth
    [270590] = {
        name = "Evasive",
        avoidance = "Focus tentacles in sequence",
        category = "positioning",
        dungeon = "Siege of Boralus"
    },
    [270185] = {
        name = "Slam",
        avoidance = "Move away from the tentacle slam zone",
        category = "ground",
        dungeon = "Siege of Boralus"
    },
    [274991] = {
        name = "Putrid Waters",
        avoidance = "Don't stand in the corrupted water",
        category = "ground",
        dungeon = "Siege of Boralus"
    },
    
    -- Trash
    [274942] = {
        name = "Banana Rampage",
        avoidance = "Dodge the bananas or interrupt",
        category = "dodge",
        dungeon = "Siege of Boralus"
    },
    [257169] = {
        name = "Terrifying Roar",
        avoidance = "Interrupt to prevent the fear",
        category = "interrupt",
        dungeon = "Siege of Boralus"
    },
    [272874] = {
        name = "Trample",
        avoidance = "Don't stand in the charge path",
        category = "dodge",
        dungeon = "Siege of Boralus"
    },
}

--------------------------------------------------------------------------------
-- ENVIRONMENTAL DAMAGE
-- Note: Environmental damage in WoW uses type names (Falling, Fire, Lava, etc.)
-- NOT spell IDs. We handle these separately since spell ID 0 = melee attacks.
--------------------------------------------------------------------------------

-- Environmental damage types (matched by name, not spell ID)
DA.EnvironmentalTypes = {
    ["Falling"] = {
        name = "Fall Damage",
        avoidance = "Use a slow-fall ability or avoid falling",
        category = "environmental",
    },
    ["Fire"] = {
        name = "Fire",
        avoidance = "Move out of the fire",
        category = "environmental",
    },
    ["Lava"] = {
        name = "Lava",
        avoidance = "Don't stand in lava",
        category = "environmental",
    },
    ["Drowning"] = {
        name = "Drowning",
        avoidance = "Return to the surface for air",
        category = "environmental",
    },
    ["Fatigue"] = {
        name = "Fatigue",
        avoidance = "Return to a valid area",
        category = "environmental",
    },
    ["Slime"] = {
        name = "Slime",
        avoidance = "Move out of the slime",
        category = "environmental",
    },
}

-- Removed: EnvironmentalMechanics with spell IDs 0-3
-- These were incorrectly triggering on melee attacks (spell ID 0)

--------------------------------------------------------------------------------
-- Merge all mechanics into the main database
--------------------------------------------------------------------------------

function DA:BuildAvoidableDamageDB()
    -- Start fresh
    self.AvoidableDamageDB = {}
    
    -- Helper function to merge tables
    local function MergeTable(source)
        for spellID, data in pairs(source) do
            self.AvoidableDamageDB[spellID] = data
        end
    end
    
    -- Merge all dungeon mechanics
    MergeTable(self.AffixMechanics)
    MergeTable(self.StonevaultMechanics)
    MergeTable(self.DawnbreakerMechanics)
    MergeTable(self.AraKaraMechanics)
    MergeTable(self.CityOfThreadsMechanics)
    MergeTable(self.GrimBatolMechanics)
    MergeTable(self.MistsMechanics)
    MergeTable(self.NecroticWakeMechanics)
    MergeTable(self.SiegeMechanics)
    -- Note: EnvironmentalMechanics removed - environmental damage detected by type name, not spell ID
    
    -- Merge raid mechanics
    if self.BuildRaidDatabase then
        self:BuildRaidDatabase()
    end
    
    -- Count entries
    local count = 0
    for _ in pairs(self.AvoidableDamageDB) do
        count = count + 1
    end
    
    self:Debug("Loaded " .. count .. " avoidable damage mechanics (dungeons + raids)")
end

--------------------------------------------------------------------------------
-- Helper: Get mechanic info with category
--------------------------------------------------------------------------------

function DA:GetAvoidableInfo(spellID)
    local info = self.AvoidableDamageDB[spellID]
    if info then
        local category = self.AvoidanceCategories[info.category]
        return {
            name = info.name,
            avoidance = info.avoidance,
            category = info.category,
            categoryInfo = category,
            dungeon = info.dungeon,
        }
    end
    return nil
end

--------------------------------------------------------------------------------
-- Helper: Get category display info
--------------------------------------------------------------------------------

function DA:GetCategoryDisplay(category)
    return self.AvoidanceCategories[category] or self.AvoidanceCategories.ground
end

