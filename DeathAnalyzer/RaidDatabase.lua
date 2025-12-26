--[[
    Raid Avoidable Damage Database
    Contains avoidable mechanics for The War Within raids

    Raids covered:
    - Nerub-ar Palace (8 bosses)
    - Liberation of Undermine (8 bosses)
    - Manaforge Omega (8 bosses)

    Each entry has:
    - spellID: The spell ID (verified from Wowhead encounter journal)
    - name: Display name of the ability
    - avoidance: How to avoid the damage
    - category: "frontal", "ground", "interrupt", "soak", "dodge", "positioning", "add"
    - boss: Which boss this is from
    - raid: Which raid this is from
    - difficulty: (optional) "heroic", "heroic_change", "mythic", "mythic_change"

    Last verified: December 2025
]]

local ADDON_NAME, DA = ...

--------------------------------------------------------------------------------
-- NERUB-AR PALACE (8 bosses)
-- Spell IDs verified from Wowhead encounter journal
--------------------------------------------------------------------------------

DA.NerubArPalaceMechanics = {
    --------------------------------------------------------------------------------
    -- Ulgrax the Devourer
    --------------------------------------------------------------------------------
    [435136] = {
        name = "Venomous Lash",
        avoidance = "Don't stand in front of the boss",
        category = "frontal",
        boss = "Ulgrax the Devourer",
        raid = "Nerub-ar Palace"
    },
    [434776] = {
        name = "Carnivorous Contest",
        avoidance = "Stay grouped with your team, don't get isolated",
        category = "positioning",
        boss = "Ulgrax the Devourer",
        raid = "Nerub-ar Palace"
    },
    [435138] = {
        name = "Digestive Acid",
        avoidance = "Move out of the acid pools",
        category = "ground",
        boss = "Ulgrax the Devourer",
        raid = "Nerub-ar Palace"
    },
    [435341] = {
        name = "Hulking Crash",
        avoidance = "Move away from the impact zone",
        category = "ground",
        boss = "Ulgrax the Devourer",
        raid = "Nerub-ar Palace"
    },
    [439502] = {
        name = "Stalker's Webbing",
        avoidance = "Break out of webs quickly or avoid getting wrapped",
        category = "dodge",
        boss = "Ulgrax the Devourer",
        raid = "Nerub-ar Palace"
    },
    [438012] = {
        name = "Hungering Bellows",
        avoidance = "Move away from boss during feeding frenzy phase",
        category = "positioning",
        boss = "Ulgrax the Devourer",
        raid = "Nerub-ar Palace"
    },
    [434697] = {
        name = "Brutal Crush",
        avoidance = "Tank swap after stacks, move away if not tanking",
        category = "frontal",
        boss = "Ulgrax the Devourer",
        raid = "Nerub-ar Palace"
    },
    [436255] = {
        name = "Juggernaut Charge",
        avoidance = "Move out of the charge path",
        category = "dodge",
        boss = "Ulgrax the Devourer",
        raid = "Nerub-ar Palace"
    },
    [438657] = {
        name = "Chunky Viscera",
        avoidance = "Avoid the viscera pools on the ground",
        category = "ground",
        boss = "Ulgrax the Devourer",
        raid = "Nerub-ar Palace"
    },

    --------------------------------------------------------------------------------
    -- The Bloodbound Horror
    --------------------------------------------------------------------------------
    [444363] = {
        name = "Gruesome Disgorge",
        avoidance = "Don't stand in front of the boss during cast",
        category = "frontal",
        boss = "The Bloodbound Horror",
        raid = "Nerub-ar Palace"
    },
    [442530] = {
        name = "Goresplatter",
        avoidance = "Move out of the blood pools",
        category = "ground",
        boss = "The Bloodbound Horror",
        raid = "Nerub-ar Palace"
    },
    [443305] = {
        name = "Crimson Rain",
        avoidance = "Avoid the falling blood drops",
        category = "dodge",
        boss = "The Bloodbound Horror",
        raid = "Nerub-ar Palace"
    },
    [451288] = {
        name = "Black Bulwark",
        avoidance = "Stack behind the tank to split damage",
        category = "soak",
        boss = "The Bloodbound Horror",
        raid = "Nerub-ar Palace"
    },
    [443042] = {
        name = "Grasp From Beyond",
        avoidance = "Move away from the tentacle spawn locations",
        category = "ground",
        boss = "The Bloodbound Horror",
        raid = "Nerub-ar Palace"
    },
    [445936] = {
        name = "Spewing Hemorrhage",
        avoidance = "Dodge the blood spray projectiles",
        category = "dodge",
        boss = "The Bloodbound Horror",
        raid = "Nerub-ar Palace"
    },
    [445016] = {
        name = "Spectral Slam",
        avoidance = "Move away from impact zones",
        category = "ground",
        boss = "The Bloodbound Horror",
        raid = "Nerub-ar Palace"
    },
    [438696] = {
        name = "Black Sepsis",
        avoidance = "Heal through the damage over time, dispel if possible",
        category = "soak",
        boss = "The Bloodbound Horror",
        raid = "Nerub-ar Palace"
    },
    [452237] = {
        name = "Bloodcurdle",
        avoidance = "Use defensives during this heavy damage phase",
        category = "soak",
        boss = "The Bloodbound Horror",
        raid = "Nerub-ar Palace",
        difficulty = "mythic"
    },

    --------------------------------------------------------------------------------
    -- Sikran, Captain of the Sureki
    --------------------------------------------------------------------------------
    [432969] = {
        name = "Phase Lunge",
        avoidance = "Move out of the lunge path",
        category = "frontal",
        boss = "Sikran",
        raid = "Nerub-ar Palace"
    },
    [433475] = {
        name = "Phase Blades",
        avoidance = "Dodge the blade charge path",
        category = "dodge",
        boss = "Sikran",
        raid = "Nerub-ar Palace"
    },
    [442428] = {
        name = "Decimate",
        avoidance = "Dodge the beams, avoid ghost collisions",
        category = "dodge",
        boss = "Sikran",
        raid = "Nerub-ar Palace"
    },
    [456420] = {
        name = "Shattering Sweep",
        avoidance = "Move out of the sweep arc",
        category = "frontal",
        boss = "Sikran",
        raid = "Nerub-ar Palace"
    },
    [439559] = {
        name = "Rain of Arrows",
        avoidance = "Avoid the arrow impact zones",
        category = "ground",
        boss = "Sikran",
        raid = "Nerub-ar Palace"
    },
    [459785] = {
        name = "Cosmic Residue",
        avoidance = "Don't stand in the cosmic puddles",
        category = "ground",
        boss = "Sikran",
        raid = "Nerub-ar Palace"
    },
    [458272] = {
        name = "Cosmic Simulacrum",
        avoidance = "Dodge the ghost copies of Sikran's attacks",
        category = "dodge",
        boss = "Sikran",
        raid = "Nerub-ar Palace"
    },
    [459273] = {
        name = "Cosmic Shards",
        avoidance = "Avoid the projectile shards",
        category = "dodge",
        boss = "Sikran",
        raid = "Nerub-ar Palace"
    },
    [461401] = {
        name = "Collapsing Nova",
        avoidance = "Move away from the nova explosion point",
        category = "ground",
        boss = "Sikran",
        raid = "Nerub-ar Palace"
    },

    --------------------------------------------------------------------------------
    -- Rasha'nan
    --------------------------------------------------------------------------------
    [439789] = {
        name = "Rolling Acid",
        avoidance = "Dodge the acid waves, avoid getting stunned",
        category = "dodge",
        boss = "Rasha'nan",
        raid = "Nerub-ar Palace"
    },
    [439776] = {
        name = "Acid Pools",
        avoidance = "Don't stand in acid pools on the ground",
        category = "ground",
        boss = "Rasha'nan",
        raid = "Nerub-ar Palace"
    },
    [439784] = {
        name = "Spinneret's Strands",
        avoidance = "Break webbing quickly or avoid getting caught",
        category = "ground",
        boss = "Rasha'nan",
        raid = "Nerub-ar Palace"
    },
    [452806] = {
        name = "Acidic Eruption",
        avoidance = "Move out of the eruption zones",
        category = "ground",
        boss = "Rasha'nan",
        raid = "Nerub-ar Palace"
    },
    [439815] = {
        name = "Infested Spawn",
        avoidance = "Kill adds quickly, avoid their melee",
        category = "add",
        boss = "Rasha'nan",
        raid = "Nerub-ar Palace"
    },
    [439794] = {
        name = "Web Reave",
        avoidance = "Don't stand between boss and webbed players",
        category = "positioning",
        boss = "Rasha'nan",
        raid = "Nerub-ar Palace"
    },
    [439811] = {
        name = "Erosive Spray",
        avoidance = "Avoid the spray cone direction",
        category = "frontal",
        boss = "Rasha'nan",
        raid = "Nerub-ar Palace"
    },

    --------------------------------------------------------------------------------
    -- Broodtwister Ovi'nax
    --------------------------------------------------------------------------------
    [441362] = {
        name = "Volatile Concoction",
        avoidance = "Spread out to avoid splash damage",
        category = "soak",
        boss = "Broodtwister Ovi'nax",
        raid = "Nerub-ar Palace"
    },
    [442430] = {
        name = "Ingest Black Blood",
        avoidance = "Break the egg before the cast finishes",
        category = "interrupt",
        boss = "Broodtwister Ovi'nax",
        raid = "Nerub-ar Palace"
    },
    [442526] = {
        name = "Experimental Dosage",
        avoidance = "Move away from targeted players",
        category = "positioning",
        boss = "Broodtwister Ovi'nax",
        raid = "Nerub-ar Palace"
    },
    [446349] = {
        name = "Sticky Web",
        avoidance = "Don't stand in web patches, avoid root",
        category = "ground",
        boss = "Broodtwister Ovi'nax",
        raid = "Nerub-ar Palace"
    },
    [446700] = {
        name = "Poison Burst",
        avoidance = "Spread for the poison explosion from mutated parasites",
        category = "soak",
        boss = "Broodtwister Ovi'nax",
        raid = "Nerub-ar Palace"
    },
    [442257] = {
        name = "Infest",
        avoidance = "Handle parasites before they mutate",
        category = "add",
        boss = "Broodtwister Ovi'nax",
        raid = "Nerub-ar Palace"
    },

    --------------------------------------------------------------------------------
    -- Nexus-Princess Ky'veza
    --------------------------------------------------------------------------------
    [436867] = {
        name = "Assassination",
        avoidance = "Watch for ghost spawn, avoid the attack",
        category = "dodge",
        boss = "Nexus-Princess Ky'veza",
        raid = "Nerub-ar Palace"
    },
    [437620] = {
        name = "Nether Rift",
        avoidance = "Move away from the rift before it kills you",
        category = "ground",
        boss = "Nexus-Princess Ky'veza",
        raid = "Nerub-ar Palace"
    },
    [438245] = {
        name = "Twilight Massacre",
        avoidance = "Move to safe zones between the slashes",
        category = "dodge",
        boss = "Nexus-Princess Ky'veza",
        raid = "Nerub-ar Palace"
    },
    [435405] = {
        name = "Starless Night",
        avoidance = "Dodge rotating cones, stay in safe zones",
        category = "dodge",
        boss = "Nexus-Princess Ky'veza",
        raid = "Nerub-ar Palace"
    },
    [436749] = {
        name = "Reaper",
        avoidance = "Move away from the Reaper's path during Starless Night",
        category = "dodge",
        boss = "Nexus-Princess Ky'veza",
        raid = "Nerub-ar Palace"
    },
    [436950] = {
        name = "Stalking Shadows",
        avoidance = "Watch for and dodge the shadow attacks",
        category = "dodge",
        boss = "Nexus-Princess Ky'veza",
        raid = "Nerub-ar Palace"
    },
    [437343] = {
        name = "Queensbane",
        avoidance = "Dispel or heal through the debuff quickly",
        category = "soak",
        boss = "Nexus-Princess Ky'veza",
        raid = "Nerub-ar Palace"
    },
    [440377] = {
        name = "Void Shredders",
        avoidance = "Don't stand in the line of the shredder attack",
        category = "frontal",
        boss = "Nexus-Princess Ky'veza",
        raid = "Nerub-ar Palace"
    },
    [439576] = {
        name = "Nexus Daggers",
        avoidance = "Dodge the dagger projectiles",
        category = "dodge",
        boss = "Nexus-Princess Ky'veza",
        raid = "Nerub-ar Palace"
    },

    --------------------------------------------------------------------------------
    -- The Silken Court
    --------------------------------------------------------------------------------
    [438218] = {
        name = "Piercing Strikes",
        avoidance = "Tank-swap mechanic, avoid if not tanking",
        category = "frontal",
        boss = "The Silken Court",
        raid = "Nerub-ar Palace"
    },
    [438677] = {
        name = "Stinging Swarm",
        avoidance = "Stun/interrupt the swarm, avoid getting hit",
        category = "add",
        boss = "The Silken Court",
        raid = "Nerub-ar Palace"
    },
    [440504] = {
        name = "Impaling Eruption",
        avoidance = "Move away from eruption locations",
        category = "ground",
        boss = "The Silken Court",
        raid = "Nerub-ar Palace"
    },
    [440246] = {
        name = "Reckless Charge",
        avoidance = "Move out of Anub'arash's charge path",
        category = "dodge",
        boss = "The Silken Court",
        raid = "Nerub-ar Palace"
    },
    [451277] = {
        name = "Spike Storm",
        avoidance = "Avoid the spike projectiles from Anub'arash",
        category = "dodge",
        boss = "The Silken Court",
        raid = "Nerub-ar Palace"
    },
    [443068] = {
        name = "Spike Eruption",
        avoidance = "Move away from the eruption zones",
        category = "ground",
        boss = "The Silken Court",
        raid = "Nerub-ar Palace"
    },
    [441782] = {
        name = "Strands of Reality",
        avoidance = "Move to safe zones during the cast",
        category = "ground",
        boss = "The Silken Court",
        raid = "Nerub-ar Palace"
    },
    [441634] = {
        name = "Web Vortex",
        avoidance = "Don't get pulled into the center",
        category = "positioning",
        boss = "The Silken Court",
        raid = "Nerub-ar Palace"
    },
    [438355] = {
        name = "Cataclysmic Entropy",
        avoidance = "Use defensives for the heavy damage",
        category = "soak",
        boss = "The Silken Court",
        raid = "Nerub-ar Palace"
    },
    --------------------------------------------------------------------------------
    -- Queen Ansurek
    --------------------------------------------------------------------------------
    [437592] = {
        name = "Reactive Toxin",
        avoidance = "Spread out when debuffed to avoid splash",
        category = "soak",
        boss = "Queen Ansurek",
        raid = "Nerub-ar Palace"
    },
    [439814] = {
        name = "Silken Tomb",
        avoidance = "Break out of the cocoon quickly",
        category = "ground",
        boss = "Queen Ansurek",
        raid = "Nerub-ar Palace"
    },
    [438976] = {
        name = "Royal Condemnation",
        avoidance = "Move away from marked players, dodge spikes",
        category = "positioning",
        boss = "Queen Ansurek",
        raid = "Nerub-ar Palace"
    },
    [443336] = {
        name = "Gorge",
        avoidance = "Don't stand in front during cast",
        category = "frontal",
        boss = "Queen Ansurek",
        raid = "Nerub-ar Palace"
    },
    [440899] = {
        name = "Liquefy",
        avoidance = "Use movement abilities to escape the pull",
        category = "positioning",
        boss = "Queen Ansurek",
        raid = "Nerub-ar Palace"
    },
    [447411] = {
        name = "Wrest",
        avoidance = "Stack with other players to split damage",
        category = "soak",
        boss = "Queen Ansurek",
        raid = "Nerub-ar Palace"
    },
    [438481] = {
        name = "Toxic Waves",
        avoidance = "Dodge the expanding toxic waves",
        category = "dodge",
        boss = "Queen Ansurek",
        raid = "Nerub-ar Palace"
    },
    [448176] = {
        name = "Gloom Orbs",
        avoidance = "Dodge the orb projectiles",
        category = "dodge",
        boss = "Queen Ansurek",
        raid = "Nerub-ar Palace"
    },
    [448046] = {
        name = "Gloom Eruption",
        avoidance = "Move away from eruption zones",
        category = "ground",
        boss = "Queen Ansurek",
        raid = "Nerub-ar Palace"
    },
    [437417] = {
        name = "Venom Nova",
        avoidance = "Use defensives for the raid-wide damage",
        category = "soak",
        boss = "Queen Ansurek",
        raid = "Nerub-ar Palace"
    },
    [438846] = {
        name = "Reactive Froth",
        avoidance = "Spread to avoid chain damage from Reactive Toxin",
        category = "positioning",
        boss = "Queen Ansurek",
        raid = "Nerub-ar Palace"
    },
    [447076] = {
        name = "Predation",
        avoidance = "Avoid the Queen's hunting phase attacks",
        category = "dodge",
        boss = "Queen Ansurek",
        raid = "Nerub-ar Palace"
    },
    [439299] = {
        name = "Web Blades",
        avoidance = "Dodge the blade projectiles",
        category = "dodge",
        boss = "Queen Ansurek",
        raid = "Nerub-ar Palace"
    },
    [443888] = {
        name = "Abyssal Infusion",
        avoidance = "Handle the debuff before it kills you",
        category = "soak",
        boss = "Queen Ansurek",
        raid = "Nerub-ar Palace"
    },
}

--------------------------------------------------------------------------------
-- LIBERATION OF UNDERMINE (8 bosses)
-- Spell IDs verified from Wowhead encounter journal
--------------------------------------------------------------------------------

DA.LiberationOfUndermineMechanics = {
    --------------------------------------------------------------------------------
    -- Vexie and the Geargrinders
    --------------------------------------------------------------------------------
    [459994] = {
        name = "Hot Wheels",
        avoidance = "Stay close to boss to bait bikers, dodge straight-line charge paths",
        category = "dodge",
        boss = "Vexie and the Geargrinders",
        raid = "Liberation of Undermine"
    },
    [460625] = {
        name = "Burning Shrapnel",
        avoidance = "Dodge fire circles when bikes hit walls or boss",
        category = "ground",
        boss = "Vexie and the Geargrinders",
        raid = "Liberation of Undermine"
    },
    [459666] = {
        name = "Spew Oil",
        avoidance = "Move away from targeted area, position oil slicks carefully",
        category = "ground",
        boss = "Vexie and the Geargrinders",
        raid = "Liberation of Undermine"
    },
    [468207] = {
        name = "Incendiary Fire",
        avoidance = "Move away from other players when dropping fire circles",
        category = "positioning",
        boss = "Vexie and the Geargrinders",
        raid = "Liberation of Undermine"
    },
    [460603] = {
        name = "Mechanical Breakdown",
        avoidance = "Dodge fire swirlies during intermission phase",
        category = "dodge",
        boss = "Vexie and the Geargrinders",
        raid = "Liberation of Undermine"
    },
    [459679] = {
        name = "Oil Slicks",
        avoidance = "Don't stand in oil puddles - they ignite",
        category = "ground",
        boss = "Vexie and the Geargrinders",
        raid = "Liberation of Undermine"
    },
    [459943] = {
        name = "Call Bikers",
        avoidance = "Prepare to dodge incoming biker charge paths",
        category = "dodge",
        boss = "Vexie and the Geargrinders",
        raid = "Liberation of Undermine"
    },
    [459453] = {
        name = "Blaze of Glory",
        avoidance = "Move away from the burning motorcycle",
        category = "ground",
        boss = "Vexie and the Geargrinders",
        raid = "Liberation of Undermine"
    },
    [459974] = {
        name = "Bomb Voyage!",
        avoidance = "Dodge the bomb explosions across the arena",
        category = "dodge",
        boss = "Vexie and the Geargrinders",
        raid = "Liberation of Undermine"
    },

    --------------------------------------------------------------------------------
    -- Cauldron of Carnage
    --------------------------------------------------------------------------------
    [472231] = {
        name = "Blastburn Roarcannon",
        avoidance = "Move out at last second when beam fixates, aim toward walls",
        category = "frontal",
        boss = "Cauldron of Carnage",
        raid = "Liberation of Undermine"
    },
    [463840] = {
        name = "Thunderdrum Salvo",
        avoidance = "Slowly shuffle out of marked circles, minimize movement",
        category = "ground",
        boss = "Cauldron of Carnage",
        raid = "Liberation of Undermine"
    },
    [465446] = {
        name = "Fiery Waves",
        avoidance = "Position away from wave patterns after bomb explosions",
        category = "ground",
        boss = "Cauldron of Carnage",
        raid = "Liberation of Undermine"
    },
    [473650] = {
        name = "Scrapbomb",
        avoidance = "Bait location near walls, gather group to split damage",
        category = "soak",
        boss = "Cauldron of Carnage",
        raid = "Liberation of Undermine"
    },
    [473951] = {
        name = "Static Charge",
        avoidance = "Minimize movement when near Torq to avoid 6-second stun",
        category = "positioning",
        boss = "Cauldron of Carnage",
        raid = "Liberation of Undermine"
    },
    [1213688] = {
        name = "Molten Phlegm",
        avoidance = "Spread away from teammates when marked with pulsing fire circles",
        category = "positioning",
        boss = "Cauldron of Carnage",
        raid = "Liberation of Undermine",
        difficulty = "heroic"
    },
    [1213994] = {
        name = "Voltaic Image",
        avoidance = "CC fixating adds, move away - they drop silencing pools",
        category = "add",
        boss = "Cauldron of Carnage",
        raid = "Liberation of Undermine"
    },
    [465833] = {
        name = "Colossal Clash",
        avoidance = "Dodge ground AoE and waves, swap sides to reset debuff stacks",
        category = "dodge",
        boss = "Cauldron of Carnage",
        raid = "Liberation of Undermine"
    },

    --------------------------------------------------------------------------------
    -- Stix Bunkjunker
    --------------------------------------------------------------------------------
    [464865] = {
        name = "Discarded Doomsplosive",
        avoidance = "Roll trash ball into bombs to destroy them before wipe",
        category = "positioning",
        boss = "Stix Bunkjunker",
        raid = "Liberation of Undermine"
    },
    [472893] = {
        name = "Incinerator",
        avoidance = "Spread out, maintain distance from trash piles while affected",
        category = "positioning",
        boss = "Stix Bunkjunker",
        raid = "Liberation of Undermine"
    },
    [466742] = {
        name = "Dumpster Dive",
        avoidance = "Move away from green marked zone before Scrapmaster slams down",
        category = "ground",
        boss = "Stix Bunkjunker",
        raid = "Liberation of Undermine"
    },
    [467117] = {
        name = "Overdrive",
        avoidance = "Dodge electric bolt circles during intermission",
        category = "dodge",
        boss = "Stix Bunkjunker",
        raid = "Liberation of Undermine"
    },
    [464399] = {
        name = "Electromagnetic Sorting",
        avoidance = "Move away from spawning trash pile locations",
        category = "ground",
        boss = "Stix Bunkjunker",
        raid = "Liberation of Undermine"
    },
    [461536] = {
        name = "Rolling Rubbish",
        avoidance = "Don't get hit by the rolling trash ball",
        category = "dodge",
        boss = "Stix Bunkjunker",
        raid = "Liberation of Undermine"
    },
    [1219384] = {
        name = "Scrap Rockets",
        avoidance = "Dodge the rocket impact zones",
        category = "dodge",
        boss = "Stix Bunkjunker",
        raid = "Liberation of Undermine"
    },

    --------------------------------------------------------------------------------
    -- Sprocketmonger Lockenstock
    --------------------------------------------------------------------------------
    [1216414] = {
        name = "Blazing Beam",
        avoidance = "Dodge the incoming fire beam projectile",
        category = "dodge",
        boss = "Sprocketmonger Lockenstock",
        raid = "Liberation of Undermine"
    },
    [1216525] = {
        name = "Rocket Barrage",
        avoidance = "Move out of rocket trajectory paths",
        category = "dodge",
        boss = "Sprocketmonger Lockenstock",
        raid = "Liberation of Undermine"
    },
    [1216674] = {
        name = "Jumbo Void Beam",
        avoidance = "Dodge the enlarged void beam after Intermission 1",
        category = "dodge",
        boss = "Sprocketmonger Lockenstock",
        raid = "Liberation of Undermine"
    },
    [1216699] = {
        name = "Void Barrage",
        avoidance = "Avoid all projectiles - any hit causes raid-wide damage",
        category = "dodge",
        boss = "Sprocketmonger Lockenstock",
        raid = "Liberation of Undermine"
    },
    [466235] = {
        name = "Wire Transfer",
        avoidance = "Move away from electrified room segments",
        category = "ground",
        boss = "Sprocketmonger Lockenstock",
        raid = "Liberation of Undermine"
    },
    [1215858] = {
        name = "Mega Magnetize",
        avoidance = "Maintain distance from magnet invention - contact causes 6s stun",
        category = "positioning",
        boss = "Sprocketmonger Lockenstock",
        raid = "Liberation of Undermine"
    },
    [1216508] = {
        name = "Screw Up",
        avoidance = "Keep moving when marked to avoid drill spawn locations",
        category = "positioning",
        boss = "Sprocketmonger Lockenstock",
        raid = "Liberation of Undermine"
    },
    [471308] = {
        name = "Blisterizer Mk. II",
        avoidance = "Dodge moving traps on conveyor belts",
        category = "dodge",
        boss = "Sprocketmonger Lockenstock",
        raid = "Liberation of Undermine"
    },
    [1217083] = {
        name = "Foot-Blasters",
        avoidance = "Step on correct color only (Mythic), time detonations carefully",
        category = "positioning",
        boss = "Sprocketmonger Lockenstock",
        raid = "Liberation of Undermine"
    },

    --------------------------------------------------------------------------------
    -- The One-Armed Bandit
    --------------------------------------------------------------------------------
    [460181] = {
        name = "Pay-Line",
        avoidance = "Stand near rolling chips and click to re-roll and destroy them",
        category = "positioning",
        boss = "The One-Armed Bandit",
        raid = "Liberation of Undermine"
    },
    [460472] = {
        name = "The Big Hit",
        avoidance = "Move out of lightning pool after tank hit, tank swap",
        category = "ground",
        boss = "The One-Armed Bandit",
        raid = "Liberation of Undermine"
    },
    [474731] = {
        name = "Fire Tornadoes",
        avoidance = "Move away from dispelled players - tornadoes spawn after dispel",
        category = "positioning",
        boss = "The One-Armed Bandit",
        raid = "Liberation of Undermine"
    },
    [465432] = {
        name = "Linked Machines",
        avoidance = "Avoid electric beams connecting boss to Hyper Coils",
        category = "dodge",
        boss = "The One-Armed Bandit",
        raid = "Liberation of Undermine"
    },
    [465322] = {
        name = "Hot Hot Heat",
        avoidance = "Move away from marked positions immediately when targeted",
        category = "dodge",
        boss = "The One-Armed Bandit",
        raid = "Liberation of Undermine"
    },
    [461060] = {
        name = "Spin To Win",
        avoidance = "Deposit tokens correctly to avoid 500% damage buff on boss",
        category = "positioning",
        boss = "The One-Armed Bandit",
        raid = "Liberation of Undermine"
    },
    [460474] = {
        name = "Shocking Field",
        avoidance = "Move out of the electric field after tank hit",
        category = "ground",
        boss = "The One-Armed Bandit",
        raid = "Liberation of Undermine"
    },
    [461068] = {
        name = "Fraud Detected!",
        avoidance = "Avoid triggering the fraud detection mechanic",
        category = "positioning",
        boss = "The One-Armed Bandit",
        raid = "Liberation of Undermine"
    },
    [465580] = {
        name = "Scattered Payout",
        avoidance = "Dodge the scattered gold during Stage 2",
        category = "dodge",
        boss = "The One-Armed Bandit",
        raid = "Liberation of Undermine"
    },
    [465587] = {
        name = "Explosive Jackpot",
        avoidance = "Move away from the explosive coins",
        category = "ground",
        boss = "The One-Armed Bandit",
        raid = "Liberation of Undermine"
    },

    --------------------------------------------------------------------------------
    -- Mug'Zee, Heads of Security
    --------------------------------------------------------------------------------
    [466509] = {
        name = "Stormfury Finger Gun",
        avoidance = "Move away from electric frontal cone direction",
        category = "frontal",
        boss = "Mug'Zee, Heads of Security",
        raid = "Liberation of Undermine"
    },
    [466545] = {
        name = "Spray and Pay",
        avoidance = "Reposition away from large frontal bullet cone",
        category = "frontal",
        boss = "Mug'Zee, Heads of Security",
        raid = "Liberation of Undermine"
    },
    [466518] = {
        name = "Molten Gold Knuckles",
        avoidance = "Tank faces boss away, remove debuff by walking through puddles",
        category = "frontal",
        boss = "Mug'Zee, Heads of Security",
        raid = "Liberation of Undermine"
    },
    [466476] = {
        name = "Frostshatter Boots",
        avoidance = "Block spears with rock walls/mines, step into lava pools on Mythic",
        category = "dodge",
        boss = "Mug'Zee, Heads of Security",
        raid = "Liberation of Undermine"
    },
    [469490] = {
        name = "Double Whammy Shot",
        avoidance = "Tank intercepts line attack with major defensive cooldowns",
        category = "soak",
        boss = "Mug'Zee, Heads of Security",
        raid = "Liberation of Undermine"
    },
    [472631] = {
        name = "Earthshatter Gaol",
        avoidance = "Keep marked circles separated, don't trap boss, kill adds in jails",
        category = "positioning",
        boss = "Mug'Zee, Heads of Security",
        raid = "Liberation of Undermine"
    },
    [466539] = {
        name = "Unstable Crawler Mines",
        avoidance = "Step into mines to trigger explosions, then soak resulting circles",
        category = "soak",
        boss = "Mug'Zee, Heads of Security",
        raid = "Liberation of Undermine"
    },
    [471574] = {
        name = "Bulletstorm",
        avoidance = "Rotate around boss to stay outside the spinning cones",
        category = "frontal",
        boss = "Mug'Zee, Heads of Security",
        raid = "Liberation of Undermine"
    },
    [1216495] = {
        name = "Electrocution Matrix",
        avoidance = "Avoid touching the line through center - instant kill",
        category = "ground",
        boss = "Mug'Zee, Heads of Security",
        raid = "Liberation of Undermine",
        difficulty = "mythic"
    },
    [466516] = {
        name = "Stormfury Cloud",
        avoidance = "Move out of the electric cloud zones",
        category = "ground",
        boss = "Mug'Zee, Heads of Security",
        raid = "Liberation of Undermine"
    },
    [467202] = {
        name = "Golden Drip",
        avoidance = "Avoid standing in molten gold puddles",
        category = "ground",
        boss = "Mug'Zee, Heads of Security",
        raid = "Liberation of Undermine"
    },
    [468658] = {
        name = "Elemental Carnage",
        avoidance = "Use heavy defensives during this phase",
        category = "soak",
        boss = "Mug'Zee, Heads of Security",
        raid = "Liberation of Undermine"
    },

    --------------------------------------------------------------------------------
    -- Chrome King Gallywix
    --------------------------------------------------------------------------------
    [466340] = {
        name = "Scatterblast Canisters",
        avoidance = "Avoid the frontal cone when canisters are launched",
        category = "frontal",
        boss = "Chrome King Gallywix",
        raid = "Liberation of Undermine"
    },
    [465952] = {
        name = "Big Bad Buncha Bombs",
        avoidance = "Move away from bomb impact zones",
        category = "ground",
        boss = "Chrome King Gallywix",
        raid = "Liberation of Undermine"
    },
    [471225] = {
        name = "Gatling Cannon",
        avoidance = "Move out of the cannon's targeting area",
        category = "dodge",
        boss = "Chrome King Gallywix",
        raid = "Liberation of Undermine"
    },
    [469286] = {
        name = "Giga Coils",
        avoidance = "Damage Giga Controls to interrupt - deals raid-wide damage",
        category = "interrupt",
        boss = "Chrome King Gallywix",
        raid = "Liberation of Undermine"
    },
    [469327] = {
        name = "Giga Blast",
        avoidance = "Spread out to minimize splash damage",
        category = "soak",
        boss = "Chrome King Gallywix",
        raid = "Liberation of Undermine"
    },
    [469362] = {
        name = "Charged Giga Bomb",
        avoidance = "Move away from the charged bomb before detonation",
        category = "ground",
        boss = "Chrome King Gallywix",
        raid = "Liberation of Undermine"
    },
    [466958] = {
        name = "Ego Check",
        avoidance = "Use major defensive cooldowns for this heavy hit",
        category = "soak",
        boss = "Chrome King Gallywix",
        raid = "Liberation of Undermine"
    },
    [1214226] = {
        name = "Cratering",
        avoidance = "Move away from crater impact zones",
        category = "ground",
        boss = "Chrome King Gallywix",
        raid = "Liberation of Undermine"
    },
    [1214369] = {
        name = "Total Destruction!!!",
        avoidance = "Position correctly during intermission phase",
        category = "positioning",
        boss = "Chrome King Gallywix",
        raid = "Liberation of Undermine"
    },
    [1220290] = {
        name = "Trick Shots",
        avoidance = "Dodge the bouncing projectiles",
        category = "dodge",
        boss = "Chrome King Gallywix",
        raid = "Liberation of Undermine"
    },
    [1214607] = {
        name = "Bigger Badder Bomb Blast",
        avoidance = "Move far away from enhanced bomb explosions",
        category = "ground",
        boss = "Chrome King Gallywix",
        raid = "Liberation of Undermine"
    },
    [466751] = {
        name = "Venting Heat",
        avoidance = "Avoid the venting steam zones",
        category = "ground",
        boss = "Chrome King Gallywix",
        raid = "Liberation of Undermine"
    },
    [467182] = {
        name = "Suppression",
        avoidance = "Use defensives during suppression phase",
        category = "soak",
        boss = "Chrome King Gallywix",
        raid = "Liberation of Undermine"
    },
}

--------------------------------------------------------------------------------
-- MANAFORGE OMEGA (8 bosses)
-- Spell IDs verified from Wowhead encounter journal
--------------------------------------------------------------------------------

DA.ManaforgeOmegaMechanics = {
    --------------------------------------------------------------------------------
    -- Plexus Sentinel
    --------------------------------------------------------------------------------
    [1219450] = {
        name = "Manifest Matrices",
        avoidance = "Drop circles against room walls, avoid stacking them in center",
        category = "ground",
        boss = "Plexus Sentinel",
        raid = "Manaforge Omega"
    },
    [1218625] = {
        name = "Displacement Matrix",
        avoidance = "Prepare for forced movement, avoid hazards",
        category = "positioning",
        boss = "Plexus Sentinel",
        raid = "Manaforge Omega"
    },
    [1219263] = {
        name = "Obliteration Arcanocannon",
        avoidance = "Tank moves to corner - damage reduced by distance",
        category = "positioning",
        boss = "Plexus Sentinel",
        raid = "Manaforge Omega"
    },
    [1219531] = {
        name = "Eradicating Salvo",
        avoidance = "Stack 5+ players to split missile damage, avoid knockback into hazards",
        category = "soak",
        boss = "Plexus Sentinel",
        raid = "Manaforge Omega"
    },
    [1220489] = {
        name = "Protocol: Purge",
        avoidance = "Follow the boss movement pattern to avoid purge damage",
        category = "dodge",
        boss = "Plexus Sentinel",
        raid = "Manaforge Omega"
    },
    [1234733] = {
        name = "Cleanse the Chamber",
        avoidance = "Use extra action button to cross the moving wall of lethal energy",
        category = "dodge",
        boss = "Plexus Sentinel",
        raid = "Manaforge Omega",
        difficulty = "mythic"
    },
    [1233110] = {
        name = "Purging Lightning",
        avoidance = "Dodge the lightning strike circles in the tunnel",
        category = "dodge",
        boss = "Plexus Sentinel",
        raid = "Manaforge Omega"
    },
    [1218668] = {
        name = "Energy Cutter",
        avoidance = "Dodge rotating beams and knockback orbs, use extra action button",
        category = "dodge",
        boss = "Plexus Sentinel",
        raid = "Manaforge Omega"
    },
    [1219354] = {
        name = "Arcane Pools",
        avoidance = "Don't stand in permanent ground hazards",
        category = "ground",
        boss = "Plexus Sentinel",
        raid = "Manaforge Omega"
    },
    [1219248] = {
        name = "Arcane Radiation",
        avoidance = "Minimize time spent in arcane radiation zones",
        category = "ground",
        boss = "Plexus Sentinel",
        raid = "Manaforge Omega"
    },

    --------------------------------------------------------------------------------
    -- Loom'ithar
    --------------------------------------------------------------------------------
    [1237272] = {
        name = "Lair Weaving",
        avoidance = "Kill one web to create safe passage, don't touch converging webs",
        category = "positioning",
        boss = "Loom'ithar",
        raid = "Manaforge Omega"
    },
    [1226395] = {
        name = "Overinfusion Burst",
        avoidance = "Move 40+ yards from boss before explosion, don't get rooted by webs",
        category = "positioning",
        boss = "Loom'ithar",
        raid = "Manaforge Omega"
    },
    [1226315] = {
        name = "Infusion Tether",
        avoidance = "Move 40 yards to break tether, avoid breaking it in web pools",
        category = "positioning",
        boss = "Loom'ithar",
        raid = "Manaforge Omega"
    },
    [1226867] = {
        name = "Primal Spellstorm",
        avoidance = "Dodge the circular indicators on the ground",
        category = "dodge",
        boss = "Loom'ithar",
        raid = "Manaforge Omega"
    },
    [1227226] = {
        name = "Writhing Wave",
        avoidance = "Stack with 5+ teammates to split cone damage",
        category = "soak",
        boss = "Loom'ithar",
        raid = "Manaforge Omega"
    },
    [1227782] = {
        name = "Arcane Outrage",
        avoidance = "Spread apart after channel ends to avoid explosion damage",
        category = "positioning",
        boss = "Loom'ithar",
        raid = "Manaforge Omega",
        difficulty = "mythic"
    },
    [1226366] = {
        name = "Pool of Webs",
        avoidance = "Avoid standing in web pools - causes stun",
        category = "ground",
        boss = "Loom'ithar",
        raid = "Manaforge Omega"
    },

    --------------------------------------------------------------------------------
    -- Soulbinder Naazindhri
    --------------------------------------------------------------------------------
    [1225616] = {
        name = "Soulfire Convergence",
        avoidance = "Move away from raid when marked - orbs shoot in multiple directions",
        category = "positioning",
        boss = "Soulbinder Naazindhri",
        raid = "Manaforge Omega",
        difficulty = "mythic"
    },
    [1227048] = {
        name = "Voidblade Ambush",
        avoidance = "Get out of the raid quickly when targeted by assassin add",
        category = "positioning",
        boss = "Soulbinder Naazindhri",
        raid = "Manaforge Omega"
    },
    [1223859] = {
        name = "Arcane Expulsion",
        avoidance = "Position to avoid knockback into orbs or off platform edge",
        category = "positioning",
        boss = "Soulbinder Naazindhri",
        raid = "Manaforge Omega"
    },
    [1226827] = {
        name = "Soulrend Orb",
        avoidance = "Dodge the orbs traveling across the platform",
        category = "dodge",
        boss = "Soulbinder Naazindhri",
        raid = "Manaforge Omega"
    },
    [1227052] = {
        name = "Void Burst",
        avoidance = "Interrupt the 3-second cast from mage adds",
        category = "interrupt",
        boss = "Soulbinder Naazindhri",
        raid = "Manaforge Omega"
    },
    [1227276] = {
        name = "Soulfray Annihilation",
        avoidance = "Dodge the frontal cone attack",
        category = "frontal",
        boss = "Soulbinder Naazindhri",
        raid = "Manaforge Omega"
    },
    [1235576] = {
        name = "Phase Blades",
        avoidance = "Dodge the blade projectiles from adds",
        category = "dodge",
        boss = "Soulbinder Naazindhri",
        raid = "Manaforge Omega"
    },

    --------------------------------------------------------------------------------
    -- Forgeweaver Araz
    --------------------------------------------------------------------------------
    [1228188] = {
        name = "Silencing Tempest",
        avoidance = "Spread away from boss and raid when targeted",
        category = "positioning",
        boss = "Forgeweaver Araz",
        raid = "Manaforge Omega"
    },
    [1231726] = {
        name = "Arcane Barrier",
        avoidance = "Break through the barrier to reach the boss",
        category = "positioning",
        boss = "Forgeweaver Araz",
        raid = "Manaforge Omega"
    },
    [1228218] = {
        name = "Arcane Obliteration",
        avoidance = "Move away from the heavy damage zone",
        category = "ground",
        boss = "Forgeweaver Araz",
        raid = "Manaforge Omega"
    },
    [1248171] = {
        name = "Void Tear",
        avoidance = "Spawn orbs behind void circles to remove their immunity",
        category = "positioning",
        boss = "Forgeweaver Araz",
        raid = "Manaforge Omega",
        difficulty = "mythic"
    },
    [1228214] = {
        name = "Astral Harvest",
        avoidance = "Spawn orbs under boss, CC and kill them before reaching pylons",
        category = "add",
        boss = "Forgeweaver Araz",
        raid = "Manaforge Omega"
    },
    [1234328] = {
        name = "Photon Blast",
        avoidance = "Dodge beams from pylons - they only extend as far as animation shows",
        category = "dodge",
        boss = "Forgeweaver Araz",
        raid = "Manaforge Omega"
    },
    [1232409] = {
        name = "Unstable Surge",
        avoidance = "Continuously dodge lightning strike circles",
        category = "dodge",
        boss = "Forgeweaver Araz",
        raid = "Manaforge Omega"
    },
    [1233076] = {
        name = "Dark Singularity",
        avoidance = "Manage positioning against black hole pull - kill boss before pull is too strong",
        category = "positioning",
        boss = "Forgeweaver Araz",
        raid = "Manaforge Omega"
    },
    [1243901] = {
        name = "Void Harvest",
        avoidance = "Stack orbs under boss and kill before reaching black hole",
        category = "add",
        boss = "Forgeweaver Araz",
        raid = "Manaforge Omega"
    },

    --------------------------------------------------------------------------------
    -- The Soul Hunters
    --------------------------------------------------------------------------------
    [1223725] = {
        name = "Fel Inferno",
        avoidance = "Stay within ring boundaries - moving beyond causes lethal damage",
        category = "positioning",
        boss = "The Soul Hunters",
        raid = "Manaforge Omega"
    },
    [1227355] = {
        name = "Voidstep",
        avoidance = "Move out of Adarus charge path",
        category = "dodge",
        boss = "The Soul Hunters",
        raid = "Manaforge Omega"
    },
    [1227809] = {
        name = "The Hunt",
        avoidance = "Stand in green lines to split damage - 3 groups needed on Mythic",
        category = "soak",
        boss = "The Soul Hunters",
        raid = "Manaforge Omega"
    },
    [1245743] = {
        name = "Eradicate",
        avoidance = "Dodge cone attacks from ghosts spawning behind players",
        category = "dodge",
        boss = "The Soul Hunters",
        raid = "Manaforge Omega",
        difficulty = "mythic"
    },
    [1241306] = {
        name = "Blade Dance",
        avoidance = "Position away from green lines before Velaryn dashes through them",
        category = "dodge",
        boss = "The Soul Hunters",
        raid = "Manaforge Omega"
    },
    [1233093] = {
        name = "Collapsing Star",
        avoidance = "Avoid center black hole, soak orbs before they reach it",
        category = "soak",
        boss = "The Soul Hunters",
        raid = "Manaforge Omega"
    },
    [1233863] = {
        name = "Fel Rush",
        avoidance = "Spread and dodge charging ghost lines, stop moving to let others dodge",
        category = "dodge",
        boss = "The Soul Hunters",
        raid = "Manaforge Omega"
    },
    [1227117] = {
        name = "Fel Devastation",
        avoidance = "Follow Ilyssa's jump location, position at arena edges outside cone",
        category = "positioning",
        boss = "The Soul Hunters",
        raid = "Manaforge Omega"
    },
    [1227113] = {
        name = "Infernal Strike",
        avoidance = "Dodge the landing zone of the infernal strike",
        category = "ground",
        boss = "The Soul Hunters",
        raid = "Manaforge Omega"
    },
    [1218103] = {
        name = "Eye Beam",
        avoidance = "Move out of the eye beam path immediately",
        category = "frontal",
        boss = "The Soul Hunters",
        raid = "Manaforge Omega"
    },
    [1225154] = {
        name = "Immolation Aura",
        avoidance = "Stay away from bosses with active auras",
        category = "ground",
        boss = "The Soul Hunters",
        raid = "Manaforge Omega"
    },

    --------------------------------------------------------------------------------
    -- Fractillus
    --------------------------------------------------------------------------------
    [1224414] = {
        name = "Crystalline Shockwave",
        avoidance = "Send targeted players to empty lanes away from raid's safe lane",
        category = "positioning",
        boss = "Fractillus",
        raid = "Manaforge Omega"
    },
    [1231871] = {
        name = "Shockwave Slam",
        avoidance = "Tank swap after each hit, maintain tank positioning in designated lane",
        category = "positioning",
        boss = "Fractillus",
        raid = "Manaforge Omega"
    },
    [1232130] = {
        name = "Nexus Shrapnel",
        avoidance = "Dodge projectiles from broken walls, spread away from marked players",
        category = "dodge",
        boss = "Fractillus",
        raid = "Manaforge Omega"
    },
    [1241137] = {
        name = "Crystal Beam",
        avoidance = "Distribute walls evenly across lanes - 6 walls in one lane causes wipe",
        category = "positioning",
        boss = "Fractillus",
        raid = "Manaforge Omega"
    },
    [1226089] = {
        name = "Crystal Nexus",
        avoidance = "Position walls carefully to avoid blocking escape routes",
        category = "positioning",
        boss = "Fractillus",
        raid = "Manaforge Omega"
    },
    [1227676] = {
        name = "Shard Slam",
        avoidance = "Move away from the slam impact zones",
        category = "ground",
        boss = "Fractillus",
        raid = "Manaforge Omega"
    },
    [1227378] = {
        name = "Crystal Encasement",
        avoidance = "Break encased players free quickly",
        category = "add",
        boss = "Fractillus",
        raid = "Manaforge Omega"
    },

    --------------------------------------------------------------------------------
    -- Nexus-King Salhadaar
    --------------------------------------------------------------------------------
    [1224812] = {
        name = "Vanquish",
        avoidance = "Tank positions cone away from raid, others dodge the frontal",
        category = "frontal",
        boss = "Nexus-King Salhadaar",
        raid = "Manaforge Omega"
    },
    [1225016] = {
        name = "Command: Besiege",
        avoidance = "Dodge laser beams crossing platform, bait beams away from boss on Mythic",
        category = "dodge",
        boss = "Nexus-King Salhadaar",
        raid = "Manaforge Omega"
    },
    [1225010] = {
        name = "Command: Behead",
        avoidance = "Spread behind raid, dodge knockback direction, avoid platform edges",
        category = "positioning",
        boss = "Nexus-King Salhadaar",
        raid = "Manaforge Omega"
    },
    [1247215] = {
        name = "Fractal Claw",
        avoidance = "Stay away from platform edges where dragons are positioned",
        category = "positioning",
        boss = "Nexus-King Salhadaar",
        raid = "Manaforge Omega"
    },
    [1228163] = {
        name = "Dimension Breath",
        avoidance = "Play opposite portal side to easily dodge dragon beams",
        category = "dodge",
        boss = "Nexus-King Salhadaar",
        raid = "Manaforge Omega"
    },
    [1248137] = {
        name = "Dark Star",
        avoidance = "Focus on dodging expanding spike rings from multiple directions",
        category = "dodge",
        boss = "Nexus-King Salhadaar",
        raid = "Manaforge Omega"
    },
    [1226024] = {
        name = "Starkiller Swing",
        avoidance = "Position missiles toward stars to destroy them, dodge other missiles",
        category = "positioning",
        boss = "Nexus-King Salhadaar",
        raid = "Manaforge Omega"
    },
    [1226042] = {
        name = "Starkiller Nova",
        avoidance = "Move away from the star explosion zones",
        category = "ground",
        boss = "Nexus-King Salhadaar",
        raid = "Manaforge Omega"
    },
    [1225319] = {
        name = "Galactic Smash",
        avoidance = "Move out of the smash impact zone",
        category = "ground",
        boss = "Nexus-King Salhadaar",
        raid = "Manaforge Omega"
    },

    --------------------------------------------------------------------------------
    -- Dimensius the All-Devouring
    --------------------------------------------------------------------------------
    [1230087] = {
        name = "Massive Smash",
        avoidance = "Maintain 20+ yard distance from tank, tank swap after vulnerability",
        category = "positioning",
        boss = "Dimensius the All-Devouring",
        raid = "Manaforge Omega"
    },
    [1243577] = {
        name = "Reverse Gravity",
        avoidance = "Players with Excess Mass position below floating allies to pull them down",
        category = "positioning",
        boss = "Dimensius the All-Devouring",
        raid = "Manaforge Omega"
    },
    [1243704] = {
        name = "Shattered Space",
        avoidance = "Split raid in half, stand in spheres to drain them before explosion",
        category = "soak",
        boss = "Dimensius the All-Devouring",
        raid = "Manaforge Omega"
    },
    [1230999] = {
        name = "Dark Matter",
        avoidance = "Spread across platform edges or near existing pools to conserve space",
        category = "positioning",
        boss = "Dimensius the All-Devouring",
        raid = "Manaforge Omega",
        difficulty = "heroic"
    },
    [1227665] = {
        name = "Fists of the Voidlord",
        avoidance = "Stay 15+ yards from tank except during Devour stack phase",
        category = "positioning",
        boss = "Dimensius the All-Devouring",
        raid = "Manaforge Omega"
    },
    [1238765] = {
        name = "Extinction",
        avoidance = "Kill Voidwarden add to access safe platform section, dodge asteroid",
        category = "dodge",
        boss = "Dimensius the All-Devouring",
        raid = "Manaforge Omega"
    },
    [1237319] = {
        name = "Gamma Burst",
        avoidance = "Kill Voidwarden adds to maximize platform space, resist pushback",
        category = "positioning",
        boss = "Dimensius the All-Devouring",
        raid = "Manaforge Omega"
    },
    [1237694] = {
        name = "Mass Ejection",
        avoidance = "Bait beam toward platform edges to save space, dodge beam",
        category = "dodge",
        boss = "Dimensius the All-Devouring",
        raid = "Manaforge Omega",
        difficulty = "heroic"
    },
    [1237695] = {
        name = "Stardust Nova",
        avoidance = "Move away from impact zone before detonation",
        category = "dodge",
        boss = "Dimensius the All-Devouring",
        raid = "Manaforge Omega",
        difficulty = "heroic"
    },
    [1234052] = {
        name = "Darkened Sky",
        avoidance = "Cross shockwaves early, wait for vulnerability debuff to expire before next",
        category = "dodge",
        boss = "Dimensius the All-Devouring",
        raid = "Manaforge Omega"
    },
    [1232973] = {
        name = "Supernova",
        avoidance = "Move away from exploding stars, avoid orbiting black holes",
        category = "dodge",
        boss = "Dimensius the All-Devouring",
        raid = "Manaforge Omega"
    },
    [1234263] = {
        name = "Cosmic Collapse",
        avoidance = "Resist pull toward tank, avoid being pulled into boss",
        category = "positioning",
        boss = "Dimensius the All-Devouring",
        raid = "Manaforge Omega",
        difficulty = "heroic"
    },
    [1229038] = {
        name = "Devour",
        avoidance = "Use defensive cooldowns during devour phase",
        category = "soak",
        boss = "Dimensius the All-Devouring",
        raid = "Manaforge Omega"
    },
    [1229327] = {
        name = "Oblivion",
        avoidance = "Move away from oblivion zones",
        category = "ground",
        boss = "Dimensius the All-Devouring",
        raid = "Manaforge Omega"
    },
    [1232987] = {
        name = "Black Hole",
        avoidance = "Stay away from the black hole pull zone",
        category = "positioning",
        boss = "Dimensius the All-Devouring",
        raid = "Manaforge Omega"
    },
    [1231716] = {
        name = "Extinguish The Stars",
        avoidance = "Focus down stars before they explode",
        category = "add",
        boss = "Dimensius the All-Devouring",
        raid = "Manaforge Omega"
    },
}

--------------------------------------------------------------------------------
-- Merge raid mechanics into main database
--------------------------------------------------------------------------------

function DA:BuildRaidDatabase()
    local function MergeTable(source)
        for spellID, data in pairs(source) do
            self.AvoidableDamageDB[spellID] = {
                name = data.name,
                avoidance = data.avoidance,
                category = data.category,
                dungeon = data.raid .. " - " .. data.boss,
            }
        end
    end

    MergeTable(self.NerubArPalaceMechanics)
    MergeTable(self.LiberationOfUndermineMechanics)
    MergeTable(self.ManaforgeOmegaMechanics)

    local count = 0
    for _ in pairs(self.NerubArPalaceMechanics) do count = count + 1 end
    for _ in pairs(self.LiberationOfUndermineMechanics) do count = count + 1 end
    for _ in pairs(self.ManaforgeOmegaMechanics) do count = count + 1 end

    self:Debug("Loaded " .. count .. " raid mechanics")
end

--------------------------------------------------------------------------------
-- Get raid mechanic info with boss context
--------------------------------------------------------------------------------

function DA:GetRaidMechanicInfo(spellID)
    local info = self.NerubArPalaceMechanics[spellID] or
                 self.LiberationOfUndermineMechanics[spellID] or
                 self.ManaforgeOmegaMechanics[spellID]

    if info then
        local category = self.AvoidanceCategories[info.category]
        return {
            name = info.name,
            avoidance = info.avoidance,
            category = info.category,
            categoryInfo = category,
            boss = info.boss,
            raid = info.raid,
        }
    end
    return nil
end
