# Valheim Modpack — Installed Mods

**Total: 38 mods** (3 deps + 35 gameplay)  
**BepInEx:** denikson/BepInExPack_Valheim 5.4.2333  
**Game:** Unity 6000.0.61f1  
**Source:** all mods via Thunderstore (`https://thunderstore.io/package/download/<ns>/<name>/<version>/`)

---

## Dependencies

| Mod | Version | Thunderstore |
|-----|---------|-------------|
| Jotunn | 2.29.1 | ValheimModding/Jotunn |
| JsonDotNET | 13.0.4 | ValheimModding/JsonDotNET |
| YamlDotNET | 16.3.1 | ValheimModding/YamlDotNET |

---

## Quality of Life

| Mod | Version | Thunderstore |
|-----|---------|-------------|
| Recycle N Reclaim | 1.3.6 | Azumatt/Recycle_N_Reclaim |
| CraftFromContainers | 3.8.1 | Grizzzly/CraftFromContainers |
| TeleportEverything | 2.9.1 | OdinPlus/TeleportEverything |
| AzuAutoStore | 3.0.14 | Azumatt/AzuAutoStore |
| AzuExtendedPlayerInventory | 2.4.1 | Azumatt/AzuExtendedPlayerInventory |
| AdventureBackpacks | 1.9.12 | Vapok/AdventureBackpacks |
| AutoRepair | 5.4.1602 | Tekla/AutoRepair |
| TargetPortal | 1.2.3 | Smoothbrain/TargetPortal |
| PlantEverything | 1.20.0 | Advize/PlantEverything |
| Waystones | 1.0.14 | shudnal/Waystones |

---

## Server Utility

| Mod | Version | Thunderstore |
|-----|---------|-------------|
| Server devcommands | 1.105.0 | JereKuusela/Server_devcommands |
| Venture Floating Items | 0.3.3 | VentureValheim/Venture_Floating_Items |
| AutomaticFuel | 1.4.8 | TastyChickenLegs/AutomaticFuel |

---

## Client-Side Only (not installed on server)

These are in the client installers (`install_valheim_mods.sh` / `.ps1`) but **not** in `server_install_mods.sh` — they are purely local (UI / visual / input) and the headless server gains nothing from them.

| Mod | Version | Thunderstore | Notes |
|-----|---------|-------------|-------|
| ParticleConfig | 1.0.0 | PatricNox/ParticleConfig | Disable weather/effect particles via `BepInEx/config` (`false` = off). Deck performance. |
| ChestContents | 1.1.0 | Sticky/ChestContents | Search any item in chests: F5 console -> `cs <name>` (no slash). Cross-platform. |
| PlantEasily | 2.1.1 | Advize/PlantEasily | Grid planting + bulk harvest. |
| ChestSearch | 1.0.6 | Channel2NewsTeam/ChestSearch | **Windows only** — uses user32.dll; crashes on Linux/Steam Deck. |

---

## Gameplay Expansion

| Mod | Version | Thunderstore |
|-----|---------|-------------|
| EpicLoot | 0.12.11 | RandyKnapp/EpicLoot |
| Mining | 1.1.6 | Smoothbrain/Mining |
| Cooking | 1.2.2 | Smoothbrain/Cooking |

---

## Building — Core

| Mod | Version | Thunderstore |
|-----|---------|-------------|
| OdinArchitect | 1.6.5 | OdinPlus/OdinArchitect |
| MissingPieces | 2.2.2 | BentoG/MissingPieces |
| OdinCampsite | 1.6.3 | OdinPlus/OdinCampsite |
| OdinsFoodBarrels | 1.2.2 | OdinPlus/OdinsFoodBarrels |

---

## Building — Expansion (added 2026-06-27)

| Mod | Version | Thunderstore | Notes |
|-----|---------|-------------|-------|
| CoreWoodPieces | 1.2.4 | blacks7ar/CoreWoodPieces | |
| RefinedStonePieces | 1.1.0 | blacks7ar/RefinedStonePieces | |
| CrystalCollector | 1.1.7 | blacks7ar/CrystalCollector | |
| FeatherCollector | 1.1.9 | blacks7ar/FeatherCollector | |
| TarCollector | 1.1.8 | blacks7ar/TarCollector | |
| SimpleElevators | 1.3.0 | blacks7ar/SimpleElevators | |
| MoonforgedBuildPieces | 1.0.6 | Caenos/MoonforgedBuildPieces | requires Jotunn >=2.29.0 |
| MoonforgedGatesAndFences | 1.0.9 | Caenos/MoonforgedGatesAndFences | requires Jotunn >=2.29.0 |
| Basements | 1.4.1 | OdinPlus/Basements | |
| OCDheim | 0.2.2 | javadevils/OCDheim | ships with UniTask.dll + icon PNGs |
| CoreWoodExtras | 2.1.8 | MagicMike/CoreWoodExtras | |
| MyZenGarden | 1.0.3 | MagicMike/MyZenGarden | DLL name: ZenGarden.dll |
| Weedheim | 2.0.4 | MagicMike/Weedheim | required base for WeedheimDecor |
| WeedheimDecor | 1.0.3 | MagicMike/WeedheimDecor | requires Weedheim 2.0.4 |
| VALKEA | 3.0.0 | The_Bees_Decree/VALKEA | |

---

## Excluded / Incompatible

| Mod | Reason |
|-----|--------|
| Valheim+ | Incompatible with OdinArchitect and OdinCampsite |
| BetterArchery | Server crash: NullRef in Start/FejdStartup (client-only mod) |
| ChestSearch | Uses user32.dll P/Invoke — Windows only; crashes on Linux/Steam Deck |
| BuildIt Castle Structures | Outdated, BepInEx pin 5.4.2102 (pre-Unity6) — crash risk |
