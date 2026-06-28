#!/bin/bash
# =============================================================================
#  Valheim Mod Installer -- Steam Deck / Linux / macOS
# =============================================================================
#
#  WHAT THIS SCRIPT INSTALLS
#  --------------------------
#  Framework:
#    BepInEx 5.4.2333           Mod loader (required by all mods)
#
#  Library dependencies (installed first -- required by other mods):
#    Jotunn 2.29.1              Valheim modding library
#                               (required by OdinArchitect, AdventureBackpacks,
#                               MissingPieces, EpicLoot)
#    JsonDotNET 13.0.4          JSON serialisation library
#                               (required by MissingPieces, EpicLoot)
#    YamlDotNet 16.3.1          YAML serialisation library
#                               (required by AdventureBackpacks)
#
#  Utility mods:
#    Recycle N Reclaim 1.3.6    Reclaim tab in crafting stations
#    CraftFromContainers 3.8.1  Craft using nearby chest items
#    TeleportEverything 2.9.1   Teleport through portals with ore/ingots
#    AzuAutoStore 3.0.14        Auto-deposit items to matching nearby chests
#    AzuExtendedPlayerInventory 2.4.1
#                               Extra inventory rows, 10 loadout sets, quick slots
#    AdventureBackpacks 1.9.12  Wearable backpacks with storage (equip as armor)
#    AutoRepair 5.4.1602        Auto-repair items when interacting with workbench
#    TargetPortal 1.2.3         Choose portal destination from the map
#    PlantEverything 1.20.0     Plant seeds, berries, mushrooms, and saplings
#    PlantEasily 2.1.1          Grid planting + bulk harvest (companion to PlantEverything)
#    Waystones 1.0.14           Place waystones + teleport to last death position
#    Server devcommands 1.105.0 Admin console commands (cheats, spawn, event, tp, etc.)
#    ChestSearch 1.0.6          Search chests by item name (Windows only; F3 hotkey)
#                               Not installed on Linux/Deck -- use ChestContents instead
#    ChestContents 1.1.0        Search ANY item in chests (no inventory needed): F5 console -> cs <name> (no slash)
#                               Works on Linux/Steam Deck/Windows; requires Jotunn
#    Venture Floating Items 0.3.3  Dropped items float on water surface
#    AutomaticFuel 1.4.8        Auto-fuels furnaces, kilns, smelters from nearby chests
#
#  Combat mods:
#    EpicLoot 0.12.11           Diablo-style magic loot, enchantments, bounties
#
#  Skill mods:
#    Mining 1.1.6               Mining skill with bonus ore yield; deposits
#                               explode at skill 50+ (toggle with CTRL+T)
#    Cooking 1.2.2              Enhanced cooking skill
#
#  Building mods:
#    OdinArchitect 1.6.5        205+ building pieces
#    MissingPieces 2.2.2        Additional building pieces
#    OdinCampsite 1.6.3         Camping-themed building pieces
#    OdinsFoodBarrels 1.2.2     Food storage barrels (install on server + client)
#
#  COMPATIBILITY NOTES
#  -------------------
#  INCOMPATIBLE combinations (do not install together):
#    - AzuExtendedPlayerInventory + ExtraSlots / ExtraSlotsCustomSlots
#    - OdinArchitect + Valheim+
#    - OdinCampsite  + Valheim+
#    - EpicLoot      + BetterUI custom tooltips (disable them in BetterUI config)
#
#  Conditional compatibility:
#    - MissingPieces: if the build menu runs out of space, install SearsCatalog
#
#  Removed mods (incompatible with Unity 6000.0.61f1):
#    - Warfare 1.8.9 + Armory 1.3.1: corrupted 79 GB asset bundle allocation
#    - BetterArchery 1.9.82: NullRef in TryRegisterRecipes on ObjectDB.Awake
#
#  BACKUP
#  ------
#  Before touching any files, a timestamped copy of your existing BepInEx/
#  folder is saved to:  ~/valheim_mods_backup_YYYYMMDD_HHMMSS/
#
# =============================================================================
#  Usage:  bash install_valheim_mods.sh
#  Re-run anytime to update or repair an existing installation.
# =============================================================================

set -euo pipefail

# ── Versions ──────────────────────────────────────────────────────────────────
BEPINEX_VERSION="5.4.2333"

# Library dependencies
JOTUNN_VERSION="2.29.1"   # bumped 2026-06-27 from 2.27.1: Moonforged/OCDheim need >=2.29.0
JSONDOTNET_VERSION="13.0.4"
YAMLDOTNET_VERSION="16.3.1"

# Utility mods
RECYCLE_VERSION="1.3.6"
CFC_VERSION="3.8.1"
TE_VERSION="2.9.1"
AUTOSTORE_VERSION="3.0.14"
AZUEPI_VERSION="2.4.1"
BACKPACKS_VERSION="1.9.12"
AUTOREPAIR_VERSION="5.4.1602"
TARGETPORTAL_VERSION="1.2.3"
PLANTEVERYTHING_VERSION="1.20.0"
WAYSTONES_VERSION="1.0.14"
SERVERDEVCOMMANDS_VERSION="1.105.0"
CHESTSEARCH_VERSION="1.0.6"
CHESTCONTENTS_VERSION="1.1.0"
FLOATINGITEMS_VERSION="0.3.3"
PLANTEASILY_VERSION="2.1.1"
AUTOFUEL_VERSION="1.4.8"

# Combat mods
EPICLOOT_VERSION="0.12.11"

# Skill mods
MINING_VERSION="1.1.6"
COOKING_VERSION="1.2.2"

# Building mods
ODINARCHITECT_VERSION="1.6.5"
MISSINGPIECES_VERSION="2.2.2"
ODINCAMPSITE_VERSION="1.6.3"
ODINSFOODBARRELS_VERSION="1.2.2"

# Building / decoration expansion (Nexus build-pack, added 2026-06-27)
COREWOODPIECES_VERSION="1.2.4"
REFINEDSTONE_VERSION="1.1.0"
CRYSTALCOLLECTOR_VERSION="1.1.7"
FEATHERCOLLECTOR_VERSION="1.1.9"
TARCOLLECTOR_VERSION="1.1.8"
SIMPLEELEVATORS_VERSION="1.3.0"
MOONFORGEDBUILD_VERSION="1.0.6"
MOONFORGEDGATES_VERSION="1.0.9"
BASEMENTS_VERSION="1.4.1"
OCDHEIM_VERSION="0.2.2"
COREWOODEXTRAS_VERSION="2.1.8"
MYZENGARDEN_VERSION="1.0.3"
WEEDHEIM_VERSION="2.0.4"
WEEDHEIMDECOR_VERSION="1.0.3"
VALKEA_VERSION="3.0.0"

# ── Download URLs ─────────────────────────────────────────────────────────────
BASE="https://thunderstore.io/package/download"

BEPINEX_URL="${BASE}/denikson/BepInExPack_Valheim/${BEPINEX_VERSION}/"

JOTUNN_URL="${BASE}/ValheimModding/Jotunn/${JOTUNN_VERSION}/"
JSONDOTNET_URL="${BASE}/ValheimModding/JsonDotNET/${JSONDOTNET_VERSION}/"
YAMLDOTNET_URL="${BASE}/ValheimModding/YamlDotNet/${YAMLDOTNET_VERSION}/"

RECYCLE_URL="${BASE}/Azumatt/Recycle_N_Reclaim/${RECYCLE_VERSION}/"
CFC_URL="${BASE}/Grizzzly/CraftFromContainers/${CFC_VERSION}/"
TE_URL="${BASE}/OdinPlus/TeleportEverything/${TE_VERSION}/"
AUTOSTORE_URL="${BASE}/Azumatt/AzuAutoStore/${AUTOSTORE_VERSION}/"
AZUEPI_URL="${BASE}/Azumatt/AzuExtendedPlayerInventory/${AZUEPI_VERSION}/"
BACKPACKS_URL="${BASE}/Vapok/AdventureBackpacks/${BACKPACKS_VERSION}/"
AUTOREPAIR_URL="${BASE}/Tekla/AutoRepair/${AUTOREPAIR_VERSION}/"
TARGETPORTAL_URL="${BASE}/Smoothbrain/TargetPortal/${TARGETPORTAL_VERSION}/"
PLANTEVERYTHING_URL="${BASE}/Advize/PlantEverything/${PLANTEVERYTHING_VERSION}/"
WAYSTONES_URL="${BASE}/shudnal/Waystones/${WAYSTONES_VERSION}/"
SERVERDEVCOMMANDS_URL="${BASE}/JereKuusela/Server_devcommands/${SERVERDEVCOMMANDS_VERSION}/"
CHESTSEARCH_URL="${BASE}/Channel2NewsTeam/ChestSearch/${CHESTSEARCH_VERSION}/"
CHESTCONTENTS_URL="${BASE}/Sticky/ChestContents/${CHESTCONTENTS_VERSION}/"
FLOATINGITEMS_URL="${BASE}/VentureValheim/Venture_Floating_Items/${FLOATINGITEMS_VERSION}/"
PLANTEASILY_URL="${BASE}/Advize/PlantEasily/${PLANTEASILY_VERSION}/"
AUTOFUEL_URL="${BASE}/TastyChickenLegs/AutomaticFuel/${AUTOFUEL_VERSION}/"

EPICLOOT_URL="${BASE}/RandyKnapp/EpicLoot/${EPICLOOT_VERSION}/"

MINING_URL="${BASE}/Smoothbrain/Mining/${MINING_VERSION}/"
COOKING_URL="${BASE}/Smoothbrain/Cooking/${COOKING_VERSION}/"

ODINARCHITECT_URL="${BASE}/OdinPlus/OdinArchitect/${ODINARCHITECT_VERSION}/"
MISSINGPIECES_URL="${BASE}/BentoG/MissingPieces/${MISSINGPIECES_VERSION}/"
ODINCAMPSITE_URL="${BASE}/OdinPlus/OdinCampsite/${ODINCAMPSITE_VERSION}/"
ODINSFOODBARRELS_URL="${BASE}/OdinPlus/OdinsFoodBarrels/${ODINSFOODBARRELS_VERSION}/"

# Building / decoration expansion
COREWOODPIECES_URL="${BASE}/blacks7ar/CoreWoodPieces/${COREWOODPIECES_VERSION}/"
REFINEDSTONE_URL="${BASE}/blacks7ar/RefinedStonePieces/${REFINEDSTONE_VERSION}/"
CRYSTALCOLLECTOR_URL="${BASE}/blacks7ar/CrystalCollector/${CRYSTALCOLLECTOR_VERSION}/"
FEATHERCOLLECTOR_URL="${BASE}/blacks7ar/FeatherCollector/${FEATHERCOLLECTOR_VERSION}/"
TARCOLLECTOR_URL="${BASE}/blacks7ar/TarCollector/${TARCOLLECTOR_VERSION}/"
SIMPLEELEVATORS_URL="${BASE}/blacks7ar/SimpleElevators/${SIMPLEELEVATORS_VERSION}/"
MOONFORGEDBUILD_URL="${BASE}/Caenos/MoonforgedBuildPieces/${MOONFORGEDBUILD_VERSION}/"
MOONFORGEDGATES_URL="${BASE}/Caenos/MoonforgedGatesAndFences/${MOONFORGEDGATES_VERSION}/"
BASEMENTS_URL="${BASE}/OdinPlus/Basements/${BASEMENTS_VERSION}/"
OCDHEIM_URL="${BASE}/javadevils/OCDheim/${OCDHEIM_VERSION}/"
COREWOODEXTRAS_URL="${BASE}/MagicMike/CoreWoodExtras/${COREWOODEXTRAS_VERSION}/"
MYZENGARDEN_URL="${BASE}/MagicMike/MyZenGarden/${MYZENGARDEN_VERSION}/"
WEEDHEIM_URL="${BASE}/MagicMike/Weedheim/${WEEDHEIM_VERSION}/"
WEEDHEIMDECOR_URL="${BASE}/MagicMike/WeedheimDecor/${WEEDHEIMDECOR_VERSION}/"
VALKEA_URL="${BASE}/The_Bees_Decree/VALKEA/${VALKEA_VERSION}/"

VALHEIM_APP_ID="892970"
VALHEIM_DIR=""
BACKUP_DIR=""


# ── Colors ────────────────────────────────────────────────────────────────────
if [ -t 1 ]; then
    RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
    BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; DIM='\033[2m'; NC='\033[0m'
else
    RED=''; GREEN=''; YELLOW=''; BLUE=''; CYAN=''; BOLD=''; DIM=''; NC=''
fi

# ── Helpers ───────────────────────────────────────────────────────────────────
banner() {
    echo ""
    echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${CYAN}║        Valheim Mod Installer - Steam Deck Edition        ║${NC}"
    echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

step() { echo -e "\n${BOLD}${BLUE}▶ $1${NC}"; }
ok()   { echo -e "  ${GREEN}✔  $1${NC}"; }
warn() { echo -e "  ${YELLOW}⚠  $1${NC}"; }
fail() { echo -e "\n${RED}${BOLD}✘  ERROR: $1${NC}\n"; exit 1; }
info() { echo -e "  ${DIM}   $1${NC}"; }

# ── Find Valheim ──────────────────────────────────────────────────────────────
# Returns true if $1 looks like a Valheim installation directory.
is_valheim_dir() {
    local path="$1"
    [ -f "${path}/valheim.x86_64" ] \
        || [ -d "${path}/Valheim.app" ] \
        || [ -f "${path}/valheim_server" ]
}

find_valheim() {
    step "Locating Valheim installation"

    local candidates=(
        # Linux / Steam Deck (standard)
        "$HOME/.local/share/Steam/steamapps/common/Valheim"
        "$HOME/.steam/steam/steamapps/common/Valheim"
        # Steam Deck specific home
        "/home/deck/.local/share/Steam/steamapps/common/Valheim"
        # macOS
        "$HOME/Library/Application Support/Steam/steamapps/common/Valheim"
    )

    # Also search microSD cards and other media mounts (Steam Deck)
    if [ -d /run/media/deck ]; then
        for mount in /run/media/deck/*/; do
            [ -d "$mount" ] && candidates+=("${mount}steamapps/common/Valheim")
        done
    fi

    for path in "${candidates[@]}"; do
        if is_valheim_dir "$path"; then
            VALHEIM_DIR="$path"
            ok "Found at: ${VALHEIM_DIR}"
            return 0
        fi
    done

    # Manual fallback
    echo ""
    warn "Could not auto-detect Valheim. Please enter the path manually."
    echo -e "  ${DIM}(Tip: Steam -> right-click Valheim -> Manage -> Browse local files)${NC}"
    echo -n "  Path: "
    read -r VALHEIM_DIR || fail "No input received. Please run this script in an interactive terminal."
    VALHEIM_DIR="${VALHEIM_DIR%/}"

    is_valheim_dir "$VALHEIM_DIR" \
        || fail "No Valheim executable found at '${VALHEIM_DIR}'. Is the path correct?"
    ok "Found at: ${VALHEIM_DIR}"
}

# ── Backup ────────────────────────────────────────────────────────────────────
backup_bepinex() {
    step "Backing up existing BepInEx installation"

    local bepinex_dir="${VALHEIM_DIR}/BepInEx"
    if [ ! -d "$bepinex_dir" ]; then
        info "No existing BepInEx directory found -- skipping backup."
        return 0
    fi

    BACKUP_DIR="${HOME}/valheim_mods_backup_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$BACKUP_DIR"
    cp -r "$bepinex_dir" "${BACKUP_DIR}/"
    ok "Backup saved to: ${BACKUP_DIR}"
    info "To restore: cp -r '${BACKUP_DIR}/BepInEx' '${VALHEIM_DIR}/'"
}

# ── Download ──────────────────────────────────────────────────────────────────
download() {
    local url="$1" dest="$2" label="$3"
    info "Downloading ${label}..."
    if curl -fsSL --retry 3 --retry-delay 2 --max-time 120 -o "$dest" "$url"; then
        local size
        size=$(du -sh "$dest" 2>/dev/null | cut -f1)
        # unzip -tq exits 1 for warnings (e.g. Windows-built zips with backslash paths).
        # Exit codes >1 are genuine errors (corrupt file, not a zip, etc.).
        local urc=0
        unzip -tq "$dest" &>/dev/null || urc=$?
        if [ "$urc" -gt 1 ]; then
            fail "Downloaded file for ${label} is not a valid zip. The download may be corrupted or the URL may have changed."
        fi
        ok "${label} (${size})"
    else
        fail "Failed to download ${label} from ${url}\n         Check your internet connection and try again."
    fi
}

# ── Check prerequisites ───────────────────────────────────────────────────────
check_prereqs() {
    step "Checking prerequisites"
    for cmd in curl unzip; do
        command -v "$cmd" &>/dev/null || fail "'${cmd}' is required but not installed."
        ok "$cmd"
    done
}

# ── Install BepInEx ───────────────────────────────────────────────────────────
# On first run: extracts and installs BepInEx core files + start_game_bepinex.sh.
# On re-run (update): skips if BepInEx core DLL already exists to preserve
# existing BepInEx/config/ settings.
# To force a clean reinstall, delete BepInEx/core/BepInEx.dll first.
install_bepinex() {
    step "Installing BepInEx ${BEPINEX_VERSION}"

    # Skip reinstall if BepInEx is already present -- preserves user configs
    local core_dll="${VALHEIM_DIR}/BepInEx/core/BepInEx.dll"
    local launch_sh="${VALHEIM_DIR}/start_game_bepinex.sh"
    if [ -f "$core_dll" ] && [ -f "$launch_sh" ]; then
        ok "BepInEx already installed -- skipping reinstall"
        info "Your BepInEx/config/ settings are preserved."
        info "To force a clean reinstall, delete BepInEx/core/BepInEx.dll first."
        mkdir -p "${VALHEIM_DIR}/BepInEx/plugins"
        return
    fi

    local tmp_zip="${TMP_DIR}/bepinex.zip"
    local tmp_extract="${TMP_DIR}/bepinex"

    download "$BEPINEX_URL" "$tmp_zip" "BepInExPack_Valheim-${BEPINEX_VERSION}"

    mkdir -p "$tmp_extract"
    unzip -q -o "$tmp_zip" -d "$tmp_extract" 2>/dev/null || { local rc=$?; [ $rc -le 1 ] || fail "BepInEx extraction failed (unzip exit ${rc})"; }

    local src="${tmp_extract}/BepInExPack_Valheim"
    [ -d "$src" ] || fail "Unexpected BepInEx zip structure -- expected BepInExPack_Valheim/ subfolder."

    cp -r "${src}/BepInEx"             "${VALHEIM_DIR}/"
    [ -d "${src}/doorstop_libs" ] && cp -r "${src}/doorstop_libs" "${VALHEIM_DIR}/"
    cp    "${src}/doorstop_config.ini" "${VALHEIM_DIR}/"
    cp    "${src}/start_game_bepinex.sh" "${VALHEIM_DIR}/"
    chmod +x "${VALHEIM_DIR}/start_game_bepinex.sh"

    mkdir -p "${VALHEIM_DIR}/BepInEx/plugins"

    ok "BepInEx core files installed"
    ok "start_game_bepinex.sh installed"
}

# ── Install mod ───────────────────────────────────────────────────────────────
# Thunderstore packages use one of three layouts -- detection order matters:
#
#   Layout A: BepInEx/ at zip root (e.g. OdinArchitect, AdventureBackpacks)
#             -> merges full BepInEx/ tree into game dir (preserves assets/)
#
#   Layout B: plugins/ at zip root (e.g. Jotunn, JsonDotNET, YamlDotNet, AutoRepair)
#             -> copies plugins/ tree into BepInEx/plugins/
#             -> required for mods shipping DLL + extra files (PDB, MDB, XML)
#
#   Layout C: DLL at zip root alongside manifest/icon/README (most simple mods)
#             -> locates $dll_name anywhere in the extracted tree
#             -> copies it to BepInEx/plugins/
#
# Idempotent: re-running updates mod files in-place; configs in BepInEx/config/
# are never touched.
install_mod() {
    local url="$1" dll_name="$2" label="$3"
    local safe_name="${dll_name%.dll}"
    local tmp_zip="${TMP_DIR}/${safe_name}.zip"
    local tmp_extract="${TMP_DIR}/${safe_name}_ext"

    download "$url" "$tmp_zip" "$label"
    mkdir -p "$tmp_extract"
    # unzip exits 1 for warnings (e.g. Windows-built zips with backslash paths).
    # With set -e that kills the script even though extraction succeeded.
    # Exit codes >1 are genuine errors; exit code 1 is safe to ignore.
    unzip -q -o "$tmp_zip" -d "$tmp_extract" 2>/dev/null || { local rc=$?; [ $rc -le 1 ] || fail "Extraction failed for ${label} (unzip exit ${rc})"; }

    if [ -d "${tmp_extract}/BepInEx" ]; then
        # Layout A: zip contains BepInEx/ tree (e.g. some OdinPlus mods)
        cp -r "${tmp_extract}/BepInEx/." "${VALHEIM_DIR}/BepInEx/"
        ok "${label} installed (layout A)"
    elif [ -d "${tmp_extract}/plugins" ]; then
        # Layout B: zip contains plugins/ at root (e.g. Jotunn, OdinArchitect, AutoRepair)
        # Copies the full plugins tree including subdirectories and asset files
        cp -r "${tmp_extract}/plugins/." "${VALHEIM_DIR}/BepInEx/plugins/"
        ok "${label} installed (layout B)"
    else
        # Layout C: DLL (and maybe README/icon) at zip root
        local found_dll
        found_dll=$(find "$tmp_extract" -name "${dll_name}" -type f 2>/dev/null | head -1)
        if [ -n "$found_dll" ]; then
            cp "$found_dll" "${VALHEIM_DIR}/BepInEx/plugins/${dll_name}"
            ok "${dll_name} installed to BepInEx/plugins/ (layout C)"
        else
            fail "Could not find ${dll_name} in the downloaded zip for ${label}."
        fi
    fi
}

# ── Auto-set Steam launch options ─────────────────────────────────────────────
set_launch_options() {
    step "Configuring Steam launch options"

    # Warn if Steam is running -- VDF edits will be overwritten when Steam closes
    if pgrep -x steam &>/dev/null || pgrep -x steamwebhelper &>/dev/null; then
        warn "Steam appears to be running. Please close Steam first, then re-run this script."
        warn "If Steam is open, it will overwrite the launch options when it exits."
        print_manual_instructions "\"${VALHEIM_DIR}/start_game_bepinex.sh\" %command%"
        return
    fi

    local launch_cmd="\"${VALHEIM_DIR}/start_game_bepinex.sh\" %command%"
    local vdf_updated=false

    # Find all Steam user directories
    local userdata_base="$HOME/.local/share/Steam/userdata"
    if [ ! -d "$userdata_base" ]; then
        userdata_base="$HOME/.steam/steam/userdata"
    fi

    if [ ! -d "$userdata_base" ]; then
        warn "Could not find Steam userdata directory -- set launch options manually."
        print_manual_instructions "$launch_cmd"
        return
    fi

    for user_dir in "${userdata_base}"/*/; do
        local vdf="${user_dir}config/localconfig.vdf"
        [ -f "$vdf" ] || continue

        # Check if Valheim entry exists in this user's config
        if ! grep -q "\"${VALHEIM_APP_ID}\"" "$vdf"; then
            continue
        fi

        # Back up the file
        cp "$vdf" "${vdf}.bak_$(date +%Y%m%d_%H%M%S)"
        info "Backed up: ${vdf}"

        # Use Python to update the VDF safely (available on SteamOS)
        python3 - "$vdf" "$VALHEIM_APP_ID" "$launch_cmd" <<'PYEOF'
import sys, re

vdf_path = sys.argv[1]
app_id   = sys.argv[2]
new_opts = sys.argv[3]

with open(vdf_path, 'r', encoding='utf-8') as f:
    lines = f.readlines()

# Walk the file line-by-line tracking brace depth to find the app block.
# This correctly handles nested VDF structures unlike a single regex.
found_app = False
depth = 0
app_start = -1
app_end = -1
launch_line = -1

for i, line in enumerate(lines):
    stripped = line.strip()
    if not found_app:
        if f'"{app_id}"' in stripped:
            found_app = True
            if '{' in stripped:
                depth = 1
                app_start = i
        continue

    if app_start == -1:
        # Still looking for the opening brace after the app_id key line
        if '{' in stripped:
            depth = 1
            app_start = i
        continue

    # Inside the app block -- track depth
    depth += stripped.count('{') - stripped.count('}')
    if '"LaunchOptions"' in stripped:
        launch_line = i
    if depth <= 0:
        app_end = i
        break

if app_start == -1:
    # App not found in this VDF -- skip
    sys.exit(2)

if launch_line != -1:
    # Replace existing LaunchOptions value in-place
    lines[launch_line] = re.sub(
        r'"LaunchOptions"\s*"[^"]*"',
        f'"LaunchOptions"\t\t"{new_opts}"',
        lines[launch_line]
    )
else:
    # Insert LaunchOptions before the closing brace of the app block
    indent = '\t' * 4  # typical VDF nesting depth
    new_line = f'{indent}"LaunchOptions"\t\t"{new_opts}"\n'
    lines.insert(app_end, new_line)

with open(vdf_path, 'w', encoding='utf-8') as f:
    f.writelines(lines)

sys.exit(0)
PYEOF

        local rc=$?
        if [ $rc -eq 0 ]; then
            ok "Launch options set automatically for Steam user: $(basename "$user_dir")"
            vdf_updated=true
        fi
    done

    if [ "$vdf_updated" = false ]; then
        warn "Could not update Steam config automatically."
        print_manual_instructions "$launch_cmd"
    else
        echo ""
        warn "Steam was not restarted -- the new launch options take effect after Steam restarts."
    fi
}

print_manual_instructions() {
    local launch_cmd="$1"
    echo ""
    echo -e "${BOLD}${YELLOW}+-------------------------------------------------------------+${NC}"
    echo -e "${BOLD}${YELLOW}|  MANUAL STEP REQUIRED -- takes about 20 seconds            |${NC}"
    echo -e "${BOLD}${YELLOW}+-------------------------------------------------------------+${NC}"
    echo ""
    echo -e "  1. Open ${BOLD}Steam${NC} (Desktop Mode)"
    echo -e "  2. Find ${BOLD}Valheim${NC} in your library"
    echo -e "  3. Right-click -> ${BOLD}Properties${NC}"
    echo -e "  4. Under ${BOLD}Launch Options${NC}, paste exactly:"
    echo ""
    echo -e "     ${BOLD}${CYAN}${launch_cmd}${NC}"
    echo ""
    echo -e "  5. Close the window -- done!"
    echo ""
    # Try to copy to clipboard
    if command -v xclip &>/dev/null; then
        echo "$launch_cmd" | xclip -selection clipboard
        ok "Launch command copied to clipboard"
    elif command -v wl-copy &>/dev/null; then
        echo "$launch_cmd" | wl-copy
        ok "Launch command copied to clipboard"
    fi
}

# ── Summary ───────────────────────────────────────────────────────────────────
print_summary() {
    echo ""
    echo -e "${BOLD}${GREEN}╔══════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BOLD}${GREEN}║                  Installation Complete!                  ║${NC}"
    echo -e "${BOLD}${GREEN}╚══════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  ${GREEN}✔${NC}  BepInEx ${BEPINEX_VERSION}"
    echo ""
    echo -e "  ${CYAN}Dependencies:${NC}"
    echo -e "  ${GREEN}✔${NC}  Jotunn ${JOTUNN_VERSION}"
    echo -e "  ${GREEN}✔${NC}  JsonDotNET ${JSONDOTNET_VERSION}"
    echo -e "  ${GREEN}✔${NC}  YamlDotNet ${YAMLDOTNET_VERSION}"
    echo ""
    echo -e "  ${CYAN}Utility mods:${NC}"
    echo -e "  ${GREEN}✔${NC}  Recycle N Reclaim ${RECYCLE_VERSION}  ${DIM}(Reclaim tab in crafting stations)${NC}"
    echo -e "  ${GREEN}✔${NC}  CraftFromContainers ${CFC_VERSION}  ${DIM}(craft using nearby chest items)${NC}"
    echo -e "  ${GREEN}✔${NC}  TeleportEverything ${TE_VERSION}  ${DIM}(teleport with ores and ingots)${NC}"
    echo -e "  ${GREEN}✔${NC}  AzuAutoStore ${AUTOSTORE_VERSION}  ${DIM}(auto-deposit items to matching chests)${NC}"
    echo -e "  ${GREEN}✔${NC}  AzuExtendedPlayerInventory ${AZUEPI_VERSION}  ${DIM}(extra rows, 10 loadout sets, quick slots)${NC}"
    echo -e "  ${GREEN}✔${NC}  AdventureBackpacks ${BACKPACKS_VERSION}  ${DIM}(wearable backpacks -- equip as armor)${NC}"
    echo -e "  ${GREEN}✔${NC}  AutoRepair ${AUTOREPAIR_VERSION}  ${DIM}(auto-repair at workbenches)${NC}"
    echo -e "  ${GREEN}✔${NC}  TargetPortal ${TARGETPORTAL_VERSION}  ${DIM}(choose portal destination on map)${NC}"
    echo -e "  ${GREEN}✔${NC}  PlantEverything ${PLANTEVERYTHING_VERSION}  ${DIM}(plant seeds, berries, mushrooms, saplings)${NC}"
    echo -e "  ${GREEN}✔${NC}  PlantEasily ${PLANTEASILY_VERSION}  ${DIM}(grid planting + bulk harvest)${NC}"
    echo -e "  ${GREEN}✔${NC}  Waystones ${WAYSTONES_VERSION}  ${DIM}(waystone network + teleport to last death)${NC}"
    echo -e "  ${GREEN}✔${NC}  Server devcommands ${SERVERDEVCOMMANDS_VERSION}  ${DIM}(admin console: cheats, spawn, event, tp...)${NC}"
    echo -e "  ${GREEN}✔${NC}  ChestContents ${CHESTCONTENTS_VERSION}  ${DIM}(F5 console -> type: cs <name>  -- no slash -- to find any item in chests)${NC}"
    echo -e "  ${GREEN}✔${NC}  Venture Floating Items ${FLOATINGITEMS_VERSION}  ${DIM}(dropped items float on water)${NC}"
    echo -e "  ${GREEN}✔${NC}  AutomaticFuel ${AUTOFUEL_VERSION}  ${DIM}(auto-fuels furnaces, kilns, smelters)${NC}"
    echo ""
    echo -e "  ${CYAN}Combat mods:${NC}"
    echo -e "  ${GREEN}✔${NC}  EpicLoot ${EPICLOOT_VERSION}  ${DIM}(magic loot, enchantments, bounties)${NC}"
    echo ""
    echo -e "  ${CYAN}Skill mods:${NC}"
    echo -e "  ${GREEN}✔${NC}  Mining ${MINING_VERSION}  ${DIM}(mining skill with bonus ore yield)${NC}"
    echo -e "  ${GREEN}✔${NC}  Cooking ${COOKING_VERSION}  ${DIM}(enhanced cooking skill)${NC}"
    echo ""
    echo -e "  ${CYAN}Building mods:${NC}"
    echo -e "  ${GREEN}✔${NC}  OdinArchitect ${ODINARCHITECT_VERSION}  ${DIM}(205+ building pieces)${NC}"
    echo -e "  ${GREEN}✔${NC}  MissingPieces ${MISSINGPIECES_VERSION}  ${DIM}(additional building pieces)${NC}"
    echo -e "  ${GREEN}✔${NC}  OdinCampsite ${ODINCAMPSITE_VERSION}  ${DIM}(camping-themed building pieces)${NC}"
    echo -e "  ${GREEN}✔${NC}  OdinsFoodBarrels ${ODINSFOODBARRELS_VERSION}  ${DIM}(food storage barrels)${NC}"
    echo ""
    echo -e "  ${CYAN}Building / decoration expansion:${NC}"
    echo -e "  ${GREEN}✔${NC}  CoreWoodPieces ${COREWOODPIECES_VERSION} + CoreWoodExtras ${COREWOODEXTRAS_VERSION}  ${DIM}(corewood build set + HD furniture/clutter)${NC}"
    echo -e "  ${GREEN}✔${NC}  RefinedStonePieces ${REFINEDSTONE_VERSION}  ${DIM}(103 refined-stone pieces)${NC}"
    echo -e "  ${GREEN}✔${NC}  MoonforgedBuildPieces ${MOONFORGEDBUILD_VERSION} + GatesAndFences ${MOONFORGEDGATES_VERSION}  ${DIM}(90+ decor; gates/fences/walls)${NC}"
    echo -e "  ${GREEN}✔${NC}  VALKEA ${VALKEA_VERSION}  ${DIM}(300+ homestead build pieces)${NC}"
    echo -e "  ${GREEN}✔${NC}  MyZenGarden ${MYZENGARDEN_VERSION}  ${DIM}(zen garden HD pieces)${NC}"
    echo -e "  ${GREEN}✔${NC}  Weedheim ${WEEDHEIM_VERSION} + WeedheimDecor ${WEEDHEIMDECOR_VERSION}  ${DIM}(themed content + decor)${NC}"
    echo -e "  ${GREEN}✔${NC}  Basements ${BASEMENTS_VERSION}  ${DIM}(placeable underground basements)${NC}"
    echo -e "  ${GREEN}✔${NC}  SimpleElevators ${SIMPLEELEVATORS_VERSION}  ${DIM}(working elevators + platforms)${NC}"
    echo -e "  ${GREEN}✔${NC}  Crystal/Feather/Tar Collectors  ${DIM}(passive resource collectors)${NC}"
    echo -e "  ${GREEN}✔${NC}  OCDheim ${OCDHEIM_VERSION}  ${DIM}(furniture snapping + precision build mode)${NC}"
    echo ""
    echo -e "  ${BOLD}Installed to:${NC} ${VALHEIM_DIR}"
    if [ -n "${BACKUP_DIR}" ]; then
        echo -e "  ${BOLD}Backup at:${NC}    ${BACKUP_DIR}"
    fi
    echo ""
    echo -e "  ${CYAN}In-game tips:${NC}"
    echo -e "  * Recycle:              open any crafting station -> Reclaim tab"
    echo -e "  * Craft from chests:    craft normally -- nearby chest items are used automatically"
    echo -e "  * Adventure Backpack:   equip in the cape slot"
    echo -e "  * TargetPortal:         open map, click a portal to choose its destination"
    echo -e "  * PlantEverything:      plant seeds, berries, mushrooms from inventory"
    echo -e "  * PlantEasily:          hold Ctrl while planting to fill a grid; swing cultivator to bulk-harvest"
    echo -e "  * ChestContents:        F5 (console) -> type  cs <partial name>  (NO leading slash) -- finds items in chests you don't have"
    echo -e "  * AzuAutoStore search:  hold Y + left-click an item in inventory to find its chest"
    echo -e "  * AutomaticFuel:        furnaces/kilns/smelters pull fuel automatically from nearby chests"
    echo -e "  * EpicLoot:             colored item names indicate magic tier"
    echo -e "  * Mining/Cooking:       skill XP gained from the respective activities"
    echo -e "  * OdinArchitect:        new build pieces in the hammer menu"
    echo ""
    echo -e "  ${DIM}To uninstall: delete BepInEx/, doorstop_libs/, doorstop_config.ini${NC}"
    echo -e "  ${DIM}and remove the launch option from Steam.${NC}"
    echo ""
}

# ── Main ──────────────────────────────────────────────────────────────────────
main() {
    banner

    TMP_DIR="$(mktemp -d)"
    trap 'rm -rf "$TMP_DIR"' EXIT

    check_prereqs

    find_valheim
    backup_bepinex

    # Base framework
    install_bepinex

    # Library dependencies -- install before any mod that needs them
    step "Installing library dependencies"
    install_mod "$JOTUNN_URL"     "Jotunn.dll"          "Jotunn ${JOTUNN_VERSION}"
    install_mod "$JSONDOTNET_URL" "Newtonsoft.Json.dll" "JsonDotNET ${JSONDOTNET_VERSION}"
    install_mod "$YAMLDOTNET_URL" "YamlDotNet.dll"      "YamlDotNet ${YAMLDOTNET_VERSION}"

    # Utility mods
    step "Installing utility mods"
    install_mod "$RECYCLE_URL"      "Recycle_N_Reclaim.dll"           "Recycle N Reclaim ${RECYCLE_VERSION}"
    install_mod "$CFC_URL"          "CraftFromContainers.dll"          "CraftFromContainers ${CFC_VERSION}"
    install_mod "$TE_URL"           "TeleportEverything.dll"           "TeleportEverything ${TE_VERSION}"
    install_mod "$AUTOSTORE_URL"    "AzuAutoStore.dll"                 "AzuAutoStore ${AUTOSTORE_VERSION}"
    install_mod "$AZUEPI_URL"       "AzuExtendedPlayerInventory.dll"   "AzuExtendedPlayerInventory ${AZUEPI_VERSION}"
    install_mod "$BACKPACKS_URL"    "AdventureBackpacks.dll"           "AdventureBackpacks ${BACKPACKS_VERSION}"
    install_mod "$AUTOREPAIR_URL"   "AutoRepair.dll"                   "AutoRepair ${AUTOREPAIR_VERSION}"
    install_mod "$TARGETPORTAL_URL"     "TargetPortal.dll"                 "TargetPortal ${TARGETPORTAL_VERSION}"
    install_mod "$PLANTEVERYTHING_URL" "Advize_PlantEverything.dll"              "PlantEverything ${PLANTEVERYTHING_VERSION}"
    install_mod "$PLANTEASILY_URL"  "Advize_PlantEasily.dll"           "PlantEasily ${PLANTEASILY_VERSION}"
    install_mod "$WAYSTONES_URL"    "Waystones.dll"                    "Waystones ${WAYSTONES_VERSION}"
    install_mod "$SERVERDEVCOMMANDS_URL" "ServerDevcommands.dll"       "Server devcommands ${SERVERDEVCOMMANDS_VERSION}"
    # ChestSearch uses Windows-only user32.dll for key detection -- crashes on Linux/Steam Deck.
    # ChestContents works cross-platform: F5 console -> cs <itemname> (no slash; no inventory needed)
    install_mod "$CHESTCONTENTS_URL" "ChestContents.dll"               "ChestContents ${CHESTCONTENTS_VERSION}"
    install_mod "$FLOATINGITEMS_URL" "VentureValheim.FloatingItems.dll" "Venture Floating Items ${FLOATINGITEMS_VERSION}"
    install_mod "$AUTOFUEL_URL"     "AutomaticFuel.dll"                "AutomaticFuel ${AUTOFUEL_VERSION}"

    # Combat mods
    step "Installing combat mods"
    install_mod "$EPICLOOT_URL"      "EpicLoot.dll"      "EpicLoot ${EPICLOOT_VERSION}"

    # Skill mods
    step "Installing skill mods"
    install_mod "$MINING_URL"  "Mining.dll"  "Mining ${MINING_VERSION}"
    install_mod "$COOKING_URL" "Cooking.dll" "Cooking ${COOKING_VERSION}"

    # Building mods
    step "Installing building mods"
    install_mod "$ODINARCHITECT_URL"    "OdinArchitect.dll"    "OdinArchitect ${ODINARCHITECT_VERSION}"
    install_mod "$MISSINGPIECES_URL"    "MissingPieces.dll"    "MissingPieces ${MISSINGPIECES_VERSION}"
    install_mod "$ODINCAMPSITE_URL"     "OdinCampsite.dll"     "OdinCampsite ${ODINCAMPSITE_VERSION}"
    install_mod "$ODINSFOODBARRELS_URL" "OdinsFoodBarrels.dll" "OdinsFoodBarrels ${ODINSFOODBARRELS_VERSION}"

    # Building / decoration expansion (added 2026-06-27)
    # Must be installed on BOTH server and client so custom build pieces sync in MP.
    # All require Jotunn (installed above, bumped to 2.29.1).
    step "Installing building / decoration expansion"
    install_mod "$COREWOODPIECES_URL"   "CoreWoodPieces.dll"           "CoreWoodPieces ${COREWOODPIECES_VERSION}"
    install_mod "$REFINEDSTONE_URL"     "RefinedStonePieces.dll"        "RefinedStonePieces ${REFINEDSTONE_VERSION}"
    install_mod "$CRYSTALCOLLECTOR_URL" "CrystalCollector.dll"          "CrystalCollector ${CRYSTALCOLLECTOR_VERSION}"
    install_mod "$FEATHERCOLLECTOR_URL" "FeatherCollector.dll"          "FeatherCollector ${FEATHERCOLLECTOR_VERSION}"
    install_mod "$TARCOLLECTOR_URL"     "TarCollector.dll"              "TarCollector ${TARCOLLECTOR_VERSION}"
    install_mod "$SIMPLEELEVATORS_URL"  "SimpleElevators.dll"           "SimpleElevators ${SIMPLEELEVATORS_VERSION}"
    install_mod "$MOONFORGEDBUILD_URL"  "MoonforgedBuildPieces.dll"     "MoonforgedBuildPieces ${MOONFORGEDBUILD_VERSION}"
    install_mod "$MOONFORGEDGATES_URL"  "MoonforgedGatesAndFences.dll"  "MoonforgedGatesAndFences ${MOONFORGEDGATES_VERSION}"
    install_mod "$BASEMENTS_URL"        "Basements.dll"                 "Basements ${BASEMENTS_VERSION}"
    install_mod "$OCDHEIM_URL"          "OCDheim.dll"                   "OCDheim ${OCDHEIM_VERSION}"
    install_mod "$COREWOODEXTRAS_URL"   "CoreWoodExtras.dll"            "CoreWoodExtras ${COREWOODEXTRAS_VERSION}"
    install_mod "$MYZENGARDEN_URL"      "ZenGarden.dll"                 "MyZenGarden ${MYZENGARDEN_VERSION}"
    # WeedheimDecor requires base Weedheim -- install base first
    install_mod "$WEEDHEIM_URL"         "Weedheim.dll"                  "Weedheim ${WEEDHEIM_VERSION} (base for WeedheimDecor)"
    install_mod "$WEEDHEIMDECOR_URL"    "WeedheimDecor.dll"             "WeedheimDecor ${WEEDHEIMDECOR_VERSION}"
    install_mod "$VALKEA_URL"           "VALKEA.dll"                    "VALKEA ${VALKEA_VERSION}"

    set_launch_options
    print_summary
}

main "$@"
