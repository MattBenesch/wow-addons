# Death Analyzer

**Analyzes your deaths and tells you what could have saved you.**

Unlike other death tracking addons that just show *what* killed you, Death Analyzer tells you *how to survive next time*.

## Features (Phase 1)

### ✅ Death Timeline
- Visual timeline of damage and healing in the 15 seconds before death
- Color-coded health bar showing your HP at each moment
- Flags avoidable damage

### ✅ Unused Defensive Detection
- Tracks all your defensive cooldowns
- Shows which defensives were available but not used when you died
- Class and spec-specific cooldown tracking

### ✅ "Would Have Survived" Calculator
- Calculates exactly how much each defensive would have saved
- Shows "You would have survived with X% HP" for each option
- Identifies the single best thing you could have done differently

### ✅ Death Verdict & Score
- **PREVENTABLE** - You had clear tools to survive
- **LIKELY PREVENTABLE** - Good chance you could have lived
- **DIFFICULT TO PREVENT** - Would have required optimal play
- **UNAVOIDABLE** - Not much you could have done

Score from 1-10 based on:
- Avoidable damage taken
- Defensive cooldowns unused
- Healing gaps

## Features (Phase 2)

### ✅ Avoidable Damage Database
- Comprehensive database of avoidable mechanics for The War Within content
- Automatic flagging with category icons (Frontal, Ground, Interrupt, Dodge, etc.)
- Hover tooltips showing "How to avoid" tips for each mechanic
- Coverage for all M+ dungeons, raids, and affixes

**Supported M+ Dungeons:**
- The Stonevault (E.D.N.A., Skarmorak, Master Machinists, Void Speaker Eirich)
- The Dawnbreaker (Speaker Shadowcrown, Anub'ikkaj, Rasha'nan)
- Ara-Kara, City of Echoes (Avanoxx, Anub'zekt, Ki'katal)
- City of Threads (Orator Krix'vizk, Fangs of the Queen, The Coaglamation, Izo)
- Grim Batol (General Umbriss, Forgemaster Throngus, Drahga Shadowburner, Erudax)
- Mists of Tirna Scithe (Ingra Maloch, Mistcaller, Tred'ova)
- The Necrotic Wake (Blightbone, Amarth, Surgeon Stitchflesh, Nalthor)
- Siege of Boralus (Chopper Redhook, Dread Captain Lockwood, Hadal Darkfathom, Viq'Goth)

**M+ Affixes:** Volcanic, Sanguine, Storming, Spiteful, Quaking, Bursting, Explosive, Grievous

## Features (v1.3.0)

### ✅ Raid Support
Full support for all three The War Within raids with boss-by-boss mechanic tracking:

**Nerub-ar Palace (8 bosses):**
- Ulgrax the Devourer
- The Bloodbound Horror
- Sikran, Captain of the Sureki
- Rasha'nan
- Broodtwister Ovi'nax
- Nexus-Princess Ky'veza
- The Silken Court (Anub'arash & Skeinspinner Takazj)
- Queen Ansurek

**Liberation of Undermine (8 bosses):**
- Vexie and the Geargrinders
- Cauldron of Carnage
- Rik Reverb
- Stix Bunkjunker
- Sprocketmonger Lockenstock
- The One-Armed Bandit
- Mug'Zee, Heads of Security
- Chrome King Gallywix

**Manaforge Omega (5 bosses):**
- Plexus Sentinel
- Soulbinder Naazindhri
- Vriskaala
- Throneguard Phaedon
- Dimensius, the All-Devouring

## Features (v1.2.0)

### ✅ Minimap Button
- Quick access to Death Analyzer from the minimap
- Left-click: Open main window
- Right-click: Open settings
- Middle-click: Show last death
- Tooltip shows death count and last death info
- Draggable position saved between sessions

### ✅ Settings Panel
- Native Blizzard interface options integration (`/da config`)
- **General Settings:**
  - Event buffer duration (5-30 seconds)
  - Maximum deaths stored (10-100)
- **Display Settings:**
  - Show popup on death toggle
  - Announce to chat toggle
  - Minimap button visibility
- **Data Management:**
  - Reset deaths with confirmation
  - Reset statistics with confirmation

### ✅ Death Statistics
- Long-term tracking of your death patterns (`/da stats`)
- **Overview:** Total deaths, session deaths, preventable %, average score
- **Top 5 Killers:** Abilities that kill you most often
- **Top 5 Enemies:** Sources that kill you most often
- **Death Locations:** Where you die most frequently
- **Unused Defensives:** Which cooldowns you forget to use
- **Time Patterns:** Deadliest hour and day of week

### ✅ Talent Cooldown Reduction Tracking
- Detects talents that reduce defensive cooldowns
- Calculates effective cooldowns based on your talent choices
- More accurate "was this defensive ready?" detection
- Supports all classes with CDR talents:
  - Paladin: Unbreakable Spirit (30% CDR on Divine Shield, etc.)
  - Hunter: Born To Be Wild (20% CDR on Turtle)
  - Mage: Ice Cold (30s CDR on Ice Block)
  - Priest: Angel's Mercy (20s CDR on Desperate Prayer)
  - And many more...

## Installation

1. Download the `DeathAnalyzer` folder
2. Place it in your `World of Warcraft/_retail_/Interface/AddOns/` directory
3. Restart WoW or `/reload`

## Usage

### Slash Commands
- `/da` - Toggle the main analysis window
- `/da last` - Show your most recent death
- `/da history` - List recent deaths in chat
- `/da stats` - Open death statistics window
- `/da guide` - Open mechanics guide (adventure book style)
- `/da config` - Open settings panel
- `/da minimap` - Toggle minimap button
- `/da reset` - Clear all death data
- `/da test` - Simulate a test death (not recorded in statistics)
- `/da debug` - Toggle debug mode
- `/da help` - Show all commands

### After You Die
A summary will print to chat automatically. Click the window or type `/da` to see:
- Full timeline of events
- List of unused defensives
- What would have saved you

### UI Buttons
The main window header contains:
- **Guide button** (📖) - Open mechanics guide (adventure book)
- **Stats button** (📊) - Open death statistics
- **Settings button** (⚙) - Open settings panel
- **Death navigation** (<  >) - Browse through death history

### Minimap Button
- **Left-Click** - Open main window
- **Right-Click** - Open settings
- **Middle-Click** - Show last death
- **Shift+Click** - Open mechanics guide

## Planned Features (Future Phases)

### Phase 3: Group Analysis
- Track party member defensive cooldowns
- "Your healer had Life Cocoon ready"
- Healing gap analysis

## Technical Notes

### Defensive Tracking
The addon tracks when you use defensive abilities and calculates if they were available at death. It accounts for:
- Base cooldown of each ability
- When you last used it
- Spec-specific defensives
- **Talent cooldown reductions** (new in v1.2.0!)

### Combat Log Events
The addon hooks into `COMBAT_LOG_EVENT_UNFILTERED` to track:
- All damage you take
- All healing you receive
- Buff applications/removals
- Your spell casts

A rolling buffer (configurable 5-30 seconds) is maintained and snapshot on death.

## Class Support

All classes and specs are supported with their defensive cooldowns:
- Death Knight (Blood, Frost, Unholy)
- Demon Hunter (Havoc, Vengeance)
- Druid (Balance, Feral, Guardian, Restoration)
- Evoker (Devastation, Preservation, Augmentation)
- Hunter (Beast Mastery, Marksmanship, Survival)
- Mage (Arcane, Fire, Frost)
- Monk (Brewmaster, Mistweaver, Windwalker)
- Paladin (Holy, Protection, Retribution)
- Priest (Discipline, Holy, Shadow)
- Rogue (Assassination, Outlaw, Subtlety)
- Shaman (Elemental, Enhancement, Restoration)
- Warlock (Affliction, Demonology, Destruction)
- Warrior (Arms, Fury, Protection)

## Contributing

### Adding Dungeon Mechanics
Edit `AvoidableDamageDatabase.lua` and add entries to the appropriate dungeon table:

```lua
DA.StonevaultMechanics = {
    [SPELL_ID] = { 
        name = "Spell Name", 
        avoidance = "How to avoid it",
        category = "frontal", -- frontal, ground, interrupt, soak, dodge, positioning, add
        dungeon = "The Stonevault"
    },
}
```

### Adding Raid Mechanics
Edit `RaidDatabase.lua` and add entries to the appropriate raid table:

```lua
DA.NerubArPalaceMechanics = {
    [SPELL_ID] = { 
        name = "Spell Name", 
        avoidance = "How to avoid it",
        category = "frontal", -- frontal, ground, interrupt, soak, dodge, positioning, add
        boss = "Boss Name",
        raid = "Nerub-ar Palace"
    },
}
```

### Adding Defensives
Edit `DefensiveDatabase.lua` and add to the appropriate class/spec table.

### Adding Talent CDR
Edit `DefensiveDatabase.lua` and add to `DA.TalentCDRDB`:

```lua
[TALENT_SPELL_ID] = { 
    affects = {DEFENSIVE_SPELL_ID, ...}, 
    reduction = 30 -- seconds reduced
    -- OR
    reductionPercent = 0.30 -- 30% reduction
},
```

## Changelog

### v1.3.0
- **Raid Support**
  - Added Nerub-ar Palace mechanics (8 bosses, 30+ abilities)
  - Added Liberation of Undermine mechanics (8 bosses, 35+ abilities)
  - Added Manaforge Omega mechanics (5 bosses, 25+ abilities)
  - Boss-specific context in death analysis tooltips
  - All raid mechanics organized by boss for easy reference
- **Mechanics Guide (Adventure Book UI)**
  - New `/da guide` command to browse all avoidable damage
  - Adventure book style interface with sidebar navigation
  - Browse by dungeon, raid, or affix category
  - Raid mechanics grouped by boss
  - Search functionality to find specific mechanics
  - Category icons and avoidance tips for each ability
- **Bug Fixes**
  - Test deaths (`/da test`) no longer recorded in statistics
  - Settings panel now displays as a proper custom window
  - Fixed settings not showing when opened from minimap

### v1.2.0
- **Minimap Button**
  - Added minimap icon with left/right/middle-click actions
  - Draggable position saved between sessions
  - Tooltip shows death count and last death summary
- **Settings Panel**
  - Native Blizzard interface options integration
  - Configurable buffer duration and max snapshots
  - Display toggles for popup, chat, and minimap
- **Death Statistics**
  - Long-term death pattern tracking
  - Top killers, enemies, zones, and unused defensives
  - Time pattern analysis (deadliest hour/day)
- **Talent CDR Tracking**
  - Detects cooldown reduction talents
  - Calculates effective cooldowns for accurate "ready" detection
  - Support for all classes

### v1.1.0
- **Phase 2: Avoidable Damage Database**
- Added comprehensive database of avoidable M+ dungeon mechanics
- All 8 The War Within Season dungeons covered
- M+ affix damage detection (Volcanic, Sanguine, Storming, etc.)
- Category-based icons for damage types (Frontal, Ground, Interrupt, etc.)
- Hover tooltips with "How to avoid" tips
- Enhanced verdict panel with avoidable damage summary
- Updated test death simulation with real spell IDs

### v1.0.0
- Initial release
- Death timeline tracking
- Unused defensive detection
- "Would have survived" calculator
- Basic UI

## License

MIT License - Feel free to modify and distribute.

## Credits

Created with love for the WoW community. Stop dying!
