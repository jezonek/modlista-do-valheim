# Valheim Mod Setup -- Player Instructions

These instructions will get you connected to the modded server on both **Steam Deck** and **Windows**.

---

## What's Installed

The server runs the following mods. **You must install all of them** -- the server enforces matching mods on connect.

### Utility Mods
| Mod | What It Does |
|-----|-------------|
| **Recycle N Reclaim** | Adds a "Reclaim" tab to crafting stations -- break down items to recover 75% of materials |
| **CraftFromContainers** | Craft using items in nearby chests (25m range) without moving them to your inventory |
| **TeleportEverything** | Teleport through portals with ores, ingots, and dragon eggs -- no restrictions |
| **AzuAutoStore** | Auto-deposit items into matching nearby chests (20m range). Press the hotkey to store all. |
| **AzuExtendedPlayerInventory** | Extra inventory rows, 10 equipment loadout sets, and quick slots |
| **AdventureBackpacks** | Wearable backpacks with storage -- equip in the cape slot |
| **AutoRepair** | Automatically repairs all items when you interact with a workbench (every 15 seconds) |
| **TargetPortal** | Choose your portal destination from a dropdown -- no need to name-match portals |
| **PlantEverything** | Plant any seed, berry, mushroom, or sapling. Crops grow 2x faster. |

### Combat Mods
| Mod | What It Does |
|-----|-------------|
| **EpicLoot** | Diablo-style magic loot with colored rarity tiers, enchantments, and bounties. 50% more magic drops. |

### Skill Mods
| Mod | What It Does |
|-----|-------------|
| **Mining** | Adds a Mining skill -- higher skill = bonus ore yield. Deposits explode at skill 50+ (toggle with CTRL+T) |
| **Cooking** | Enhanced cooking skill with progression |

### Building Mods
| Mod | What It Does |
|-----|-------------|
| **OdinArchitect** | 205+ extra building pieces in the hammer menu |
| **MissingPieces** | Additional building pieces that fill gaps in vanilla |
| **OdinCampsite** | Camping-themed building pieces (tents, logs, campfire items) |
| **OdinsFoodBarrels** | Decorative food storage barrels |

### Server Settings
| Setting | Value | Effect |
|---------|-------|--------|
| Death Penalty | Casual | No skill loss on death -- you keep your items |
| Resources | More (1.5x) | 50% more resources from all sources |
| Raids | Less | Fewer base raid interruptions |
| Combat | Default | Normal enemy difficulty |

---

## Steam Deck

### Step 1 -- Switch to Desktop Mode

Press the **Steam button** -> Power -> **Switch to Desktop**

### Step 2 -- Open a Terminal

On the Desktop, open **Konsole** (search in the taskbar if you don't see it).

### Step 3 -- Get the Installer

Copy `install_valheim_mods.sh` to your Steam Deck. The easiest way is from the same network:

```bash
# Run this on your Mac/PC (replace steamdeck.local with your deck's IP if needed):
scp install_valheim_mods.sh deck@steamdeck.local:~/
```

Or copy it via USB drive or microSD card, then in Konsole navigate to where you put it.

### Step 4 -- Run the Installer

```bash
bash ~/install_valheim_mods.sh
```

The script will:
1. Find your Valheim installation automatically
2. Back up your existing mods (if any)
3. Download and install BepInEx (the mod loader)
4. Download and install all mods listed above
5. Try to set the Steam launch option automatically

> **If you see a yellow warning box** saying "MANUAL STEP REQUIRED", the automatic launch option setup didn't work. Follow Step 5 below.

### Step 5 -- Set the Steam Launch Option (if needed)

If the script couldn't set it automatically, do it manually:

1. Open **Steam** in Desktop Mode
2. Find **Valheim** in your library -> right-click -> **Properties**
3. Under **General**, find the **Launch Options** field
4. Paste this (replace `/home/deck` with your actual home directory if different):
   ```
   "/home/deck/.local/share/Steam/steamapps/common/Valheim/start_game_bepinex.sh" %command%
   ```
5. Close Properties

> **Valheim on a microSD card?** The path will be different. Run `find /run/media -name "start_game_bepinex.sh" 2>/dev/null` in Konsole to find the correct path.

### Step 6 -- Switch Back to Gaming Mode

Press the **Return to Gaming Mode** shortcut on the desktop, or restart.

### Step 7 -- Launch and Connect

Launch Valheim normally through Steam. BepInEx loads silently in the background.

1. **Start Game** -> select your character
2. **Join Game**
3. Click **Join by code** at the bottom of the screen
4. Enter the current join code (ask the server admin -- it changes on every server restart)

> **Can't find "Join by code"?** Make sure crossplay is enabled in Valheim settings.

---

## Windows

### Step 1 -- Get the Installer Files

You need two files in the same folder:
- `install_valheim_mods.bat`
- `install_valheim_mods.ps1`

Copy them somewhere easy to find, like your Desktop.

### Step 2 -- Run the Installer

**Double-click `install_valheim_mods.bat`**

A window will open and the installer will:
1. Find your Valheim installation automatically (searches all Steam libraries)
2. Back up your existing mods (if any)
3. Download and install BepInEx
4. Download and install all mods listed above

> **If Windows Defender blocks it:** Click "More info" -> "Run anyway". The scripts only download from Thunderstore (the official Valheim mod platform) and write files to your Valheim folder.

> **If Valheim is not found automatically:** The installer will ask you to enter the path manually. In Steam, right-click Valheim -> Manage -> Browse local files -- that opens the folder. Copy that path and paste it in.

### Step 3 -- No Launch Option Needed on Windows

On Windows, BepInEx uses a file called `winhttp.dll` placed in the Valheim folder. This makes BepInEx load automatically when you start Valheim -- no Steam launch option changes needed.

### Step 4 -- Launch and Connect

Launch Valheim normally through Steam. BepInEx and all mods load silently on startup.

1. **Start Game** -> select your character
2. **Join Game**
3. Click **Join by code** at the bottom
4. Enter the current join code (ask the server admin -- it changes on every server restart)

---

## In-Game Tips

Once you're connected, here's how to use the mods:

- **Recycle/Reclaim**: Open any crafting station -> look for the **Reclaim** tab
- **Craft from chests**: Just craft normally -- items in nearby chests (25m) are used automatically
- **Auto-store**: Press the store-all hotkey to deposit inventory into matching chests (20m range)
- **Adventure Backpack**: Craft at a workbench, equip in the **cape slot**
- **TargetPortal**: Interact with a portal -> choose destination from the dropdown
- **PlantEverything**: Plant seeds, berries, mushrooms directly from your inventory
- **EpicLoot**: Colored item names indicate rarity tier (white -> green -> blue -> purple -> gold)
- **Mining/Cooking**: Gain XP from mining and cooking -- higher skill = better results
- **OdinArchitect**: Open the hammer menu -- new build pieces appear in existing categories
- **Quick Slots**: Drag items to the quick-slot bar below your inventory for fast access
- **Loadouts**: Use the loadout buttons (1-10) in inventory to save and swap equipment sets
- **Death**: No skill loss! You keep your items. Just run back to your tombstone.

---

## Troubleshooting

### "Version incompatible" or kicked immediately on connect

BepInEx is not running on your machine, or your mod versions don't match the server.

- **Steam Deck**: Check that the Steam launch option is set (Step 5 above). In Gaming Mode: gear icon on Valheim -> Properties -> General -> Launch Options -- it should not be empty.
- **Windows**: Make sure `winhttp.dll` is present in your Valheim folder.
- **Both**: Re-run the installer script. It's safe to re-run anytime and will update all mods to the correct versions.

### Script fails to download

Check your internet connection. The script downloads from `thunderstore.io` -- if that site is temporarily down, wait a few minutes and re-run. The script is safe to re-run at any time.

### Valheim was on a different drive (Windows)

Steam libraries on drives other than C: are detected automatically via `libraryfolders.vdf`. If it's still not found, enter the path manually when prompted.

### Updating the mods

Re-run the installer script. It safely overwrites existing files. The mod versions are pinned in the script -- when new versions are released, a new version of the installer will be provided.

### Uninstalling

**Steam Deck / Linux:**
Delete from your Valheim folder:
- `BepInEx/`
- `doorstop_libs/`
- `doorstop_config.ini`
- `start_game_bepinex.sh`

Then remove the launch option from Steam (clear the Launch Options field in Properties).

**Windows:**
Delete from your Valheim folder:
- `BepInEx/`
- `winhttp.dll`
- `doorstop_config.ini`

---

## Getting the Server Join Code

The join code is a 6-digit number that changes every time the server restarts. Ask the server admin for the current code, or check the server control panel -- it's listed under the active session.
