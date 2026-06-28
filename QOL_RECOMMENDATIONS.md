# Valheim QoL Recommendations

Generated 2026-03-31 from a structured multi-perspective debate.

Playstyle: **Casual / low grind** multiplayer group.

---

## Phase 1: Config Tweaks (Zero Risk)

Edit these in `BepInEx/config/` on the server. Most are server-authoritative (ServerSync).
After editing, restart the server. Client configs auto-sync for ServerSync mods.

### AzuAutoStore (`Azumatt.AzuAutoStore.cfg`)

```ini
[General]
Player Range = 20
Fallback Range = 20
Player Ignore Quick Slots = true
Must Have Existing Item To Pull = true
IntervalSeconds = 5
```

- Range 20m covers a workshop area without vacuuming the whole base.
- `Must Have Existing Item = true` forces players to organize chests once; after that, items auto-sort.
- `Ignore Quick Slots = true` prevents AzuExtendedPlayerInventory quick-slot items from being stored.

### CraftFromContainers (`aedenthorn.CraftFromContainers.cfg`)

```ini
[General]
ContainerRange = 25
LeaveOne = true
```

- 25m range covers a well-designed crafting hall.
- `LeaveOne = true` keeps at least 1 of each item in chests, cooperating with AutoStore's "must have existing" rule.

### Recycle_N_Reclaim (`Azumatt.Recycle_N_Reclaim.cfg`)

```ini
[General]
RecyclingRate = 0.75
```

- 75% material return: generous for experimentation, but crafting the wrong item still costs something.

### PlantEverything (`advize.PlantEverything.cfg`)

```ini
[Crops]
EnableCropOverrides = true
CropGrowTimeMin = 2000
CropGrowTimeMax = 2500
```

- Crops grow 2x faster (halved from defaults 4000/5000). Eliminates the "stare at barley for 30 minutes" problem.
- `EnableCropOverrides` must be set to `true` or the grow time settings are ignored.

### TeleportEverything (`com.kpro.TeleportEverything.cfg`)

```ini
[Transport]
Transport Ores = true
Transport fee = 0
Transport Dragon Eggs = true
```

- Free ore teleportation for casual group. Boats remain useful for large hauls and exploration.
- Dragon eggs teleportable (one-time boss items, carrying them is just tedious).

### AutoRepair

AutoRepair does not have a server-side config file. It uses built-in defaults (auto-repair at workbenches). No config changes needed.

### EpicLoot (`randyknapp.mods.epicloot.cfg`)

```ini
[Balance]
Global Drop Rate Modifier = 1.5
```

- 50% more magic item drops. Rewards combat without flooding inventory.

---

## Phase 2: Vanilla World Modifiers (Low Risk)

These are built into Valheim 0.218+. Set via console commands on the dedicated server.
Some may require world recreation -- verify before applying.

| Modifier | Recommended | Console Command | Notes |
|----------|-------------|-----------------|-------|
| Death Penalty | **Casual** | `setkey DeathPenalty casual` | No skill loss on death. Unanimous recommendation. |
| Resources | **More** (1.5x) | `setkey ResourceRate more` | Reduces gathering time without trivializing |
| Raids | **Less** | `setkey Raids less` | Fewer base defense interruptions while building |
| Combat | **Default** | (no change) | Keep combat meaningful -- EpicLoot handles power curve |
| Portals | **Default** | (no change) | TeleportEverything already handles this better with more control |

---

## Phase 3: New Mods to Add (3-4 max)

Ranked by impact and risk. All have been verified for compatibility with the existing mod set.

### Priority 1: Quick Stack Store Sort Trash Restock (by Goldenrevolver)

- **What:** One-button quick-stack all non-favorited items into nearby chests, restock ammo/food, sort inventories, trash junk items
- **Why:** Complements AzuAutoStore (passive storage) with active inventory management. 722K+ downloads.
- **Risk:** Low. Tested compatible with AzuExtendedPlayerInventory.
- **Install:** Server + all clients
- **Thunderstore:** Goldenrevolver/Quick_Stack_Store_Sort_Trash_Restock

### Priority 2: BowsBeforeHoes (by Azumatt)

- **What:** Quivers (visible gear), configurable arrow recovery (default 50%), archery improvements
- **Why:** Replaces BetterArchery which was removed (Unity 6 NullRef crash). Same author as AzuAutoStore/AzuExtendedPlayerInventory.
- **Risk:** Low. Azumatt mods have been reliable on this server.
- **Install:** Server + all clients (ServerSync)
- **Thunderstore:** Azumatt/BowsBeforeHoes

### Priority 3: BetterUI ForeverMaintained (by Azumatt)

- **What:** XP tracking, enemy HP/level display, food timer bars, durability color coding, crafting info on hover
- **Why:** Pure information layer. Shows data vanilla hides.
- **Risk:** Very low. Client-only -- no server install needed.
- **Install:** Clients only (optional per player)
- **Thunderstore:** BetterUI_ForeverMaintained/BetterUI_ForeverMaintained

### Priority 4: Sailing (by Smoothbrain)

- **What:** Sailing skill (faster ships at higher skill), ship nudge (Left Shift), fog-of-war reveal
- **Why:** Makes sailing rewarding instead of tedious. Same author/framework as Mining and Cooking (already installed).
- **Risk:** Low. Same SkillManager framework already running.
- **Install:** Server + all clients
- **Thunderstore:** Smoothbrain/Sailing

### Considered but deferred

| Mod | Why Deferred |
|-----|-------------|
| ServerSideMap | Requires server+client install, potential PlayFab conflicts, adds complexity |
| SkilledCarryWeight | Useful but backpacks + extended inventory already address carry capacity |
| ControlTime / LongerDays | Nice-to-have but not a core pain point |
| Vitality / Tenacity | Combat difficulty is being kept at default; these are unnecessary |

---

## Compatibility Notes

### INCOMPATIBLE (do not install)

- AzuExtendedPlayerInventory + ExtraSlots / ExtraSlotsCustomSlots
- OdinArchitect + Valheim+
- OdinCampsite + Valheim+
- EpicLoot + BetterUI custom tooltips (disable them in BetterUI config if both installed)
- BetterArchery (any version) -- crashes on Unity 6000.0.61f1
- Warfare + Armory (any version) -- 79GB asset allocation crash on Unity 6

### Testing protocol for new mods

1. Check mod's issue tracker for "headless", "dedicated", "NullReference"
2. Verify Thunderstore "last updated" is 2025+
3. Test on local headless instance first
4. Pin exact version in all 3 install scripts simultaneously
5. Backup live server via FTP (verify backup count > 0) before deploying
6. Monitor server logs for 15 minutes after first boot

---

## Decision Log

| Date | Decision | Rationale |
|------|----------|-----------|
| 2026-03-31 | Phase 1 configs recommended | Zero risk, immediate QoL improvement |
| 2026-03-31 | Death Penalty: Casual | Unanimous across all debate perspectives |
| 2026-03-31 | Resources: More (1.5x) | Balanced -- enough reduction for casual without trivializing |
| 2026-03-31 | Max 4 new mods | Limit crash risk and coordination overhead |
| 2026-03-31 | BetterUI is client-only optional | Players can choose to install or skip |
