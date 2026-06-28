#!/usr/bin/env bash
# Backs up /BepInEx/ from the Valheim server, then installs all mods via FTP.
set -euo pipefail

# Load credentials from .creds.sh (gitignored); copy .creds.sh.example to create it
CREDS_FILE="$(cd "$(dirname "$0")" && pwd)/../.creds.sh"
[ -f "$CREDS_FILE" ] && source "$CREDS_FILE"
FTP_HOST="${FTP_HOST:?FTP_HOST not set — copy .creds.sh.example to .creds.sh}"
FTP_PORT="${FTP_PORT:?FTP_PORT not set — copy .creds.sh.example to .creds.sh}"
FTP_USER="${FTP_USER:?FTP_USER not set — copy .creds.sh.example to .creds.sh}"
FTP_PASS="${FTP_PASS:?FTP_PASS not set — copy .creds.sh.example to .creds.sh}"
FTP_BASE="ftp://${FTP_HOST}:${FTP_PORT}"
# Credentials go in a temp netrc so they never appear in ps aux or log files
NETRC_TMP="$(mktemp)"
chmod 600 "$NETRC_TMP"
printf 'machine %s login %s password %s\n' "$FTP_HOST" "$FTP_USER" "$FTP_PASS" > "$NETRC_TMP"
BASE_URL="https://thunderstore.io/package/download"

BEPINEX_VERSION="5.4.2333"

TIMESTAMP="$(date +%Y%m%d_%H%M%S)"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BACKUP_DIR="${SCRIPT_DIR}/server_backup_${TIMESTAMP}"
WORK_DIR="$(mktemp -d)"
LOG_FILE="${SCRIPT_DIR}/server_install_${TIMESTAMP}.log"

exec > >(tee -a "$LOG_FILE") 2>&1

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'
BLUE='\033[0;34m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

step() { echo -e "\n${BOLD}${BLUE}>> $*${NC}"; }
ok()   { echo -e "  ${GREEN}OK  $*${NC}"; }
warn() { echo -e "  ${YELLOW}!!  $*${NC}"; }
fail() { echo -e "\n${RED}ERROR: $*${NC}\n"; exit 1; }
info() { echo -e "       $*"; }

trap 'rm -rf "$WORK_DIR" "$NETRC_TMP"' EXIT

# ── FTP helpers ───────────────────────────────────────────────────────────────
ftp_list() {
    curl -s --netrc-file "$NETRC_TMP" --connect-timeout 15 "${FTP_BASE}$1" 2>&1 || true
}

ftp_download_file() {
    local remote="$1" local_path="$2"
    mkdir -p "$(dirname "$local_path")"
    curl -s --netrc-file "$NETRC_TMP" --connect-timeout 30 \
        -o "$local_path" "${FTP_BASE}${remote}" || {
        warn "Failed to download: ${remote}"
        return 1
    }
}

ftp_download_dir() {
    local remote="$1" local_path="$2"
    mkdir -p "$local_path"
    local listing
    listing=$(ftp_list "$remote") || return 0
    while IFS= read -r line; do
        [ -z "$line" ] && continue
        local perms size name
        perms=$(awk '{print $1}' <<< "$line")
        size=$(awk '{print $5}'  <<< "$line")
        name=$(awk '{print $NF}' <<< "$line")
        [[ "$name" == "." || "$name" == ".." ]] && continue
        if [[ "$perms" == d* ]]; then
            ftp_download_dir "${remote}${name}/" "${local_path}/${name}/"
        else
            printf "  DL  %-55s %s B\n" "${remote}${name}" "$size"
            ftp_download_file "${remote}${name}" "${local_path}/${name}"
        fi
    done <<< "$listing"
}

ftp_upload_file() {
    local local_file="$1" remote_path="$2"
    info "  -> ${remote_path}"
    curl -s --netrc-file "$NETRC_TMP" --connect-timeout 30 \
        --ftp-create-dirs \
        -T "$local_file" \
        "${FTP_BASE}${remote_path}" \
        || fail "Upload failed: $(basename "$local_file")"
}

# Upload a directory tree, skipping .so files (blocked by vsFTPd on server)
ftp_upload_dir() {
    local local_dir="$1" remote_base="$2"
    while IFS= read -r -d '' file; do
        if [[ "$file" == *.so || "$file" =~ \.so\.[0-9] ]]; then
            info "  skip (blocked ext): $(basename "$file")"
            continue
        fi
        local rel="${file#${local_dir}/}"
        ftp_upload_file "$file" "${remote_base}/${rel}"
    done < <(find "$local_dir" -type f -print0)
}

# ── Download + install one mod ────────────────────────────────────────────────
# Handles three Thunderstore zip layouts:
#   A) BepInEx/  at root  -> upload BepInEx/ tree to /BepInEx/
#   B) plugins/  at root  -> upload plugins/ tree to /BepInEx/plugins/
#   C) DLL only at root   -> upload DLL to /BepInEx/plugins/
install_mod_server() {
    local url="$1" dll_name="$2" label="$3"
    local safe="${dll_name%.dll}"
    local zip="${WORK_DIR}/${safe}.zip"
    local ext="${WORK_DIR}/${safe}_ext"

    info "Downloading ${label}..."
    curl -fsSL --retry 3 --retry-delay 2 --max-time 120 \
        -H 'User-Agent: ValheimModInstaller/2.0' \
        -o "$zip" "$url" \
        || fail "Download failed: ${label}"
    # unzip -tq exits 1 for warnings (e.g. Windows-built zips); only fail on >1
    local urc=0
    unzip -tq "$zip" &>/dev/null || urc=$?
    [ "$urc" -le 1 ] || fail "Invalid zip for ${label}"
    local size; size=$(du -sh "$zip" | cut -f1)
    info "  downloaded ${size}"

    mkdir -p "$ext"
    # unzip exit code 1 = success with warnings (e.g. Windows backslash paths) -- allow it
    unzip -q -o "$zip" -d "$ext" 2>/dev/null || { local rc=$?; [ $rc -le 1 ] || fail "Extraction failed for ${label} (exit $rc)"; }

    if [ -d "${ext}/BepInEx" ]; then
        # Layout A: full BepInEx tree
        ftp_upload_dir "${ext}/BepInEx" "/BepInEx"
        ok "${label} installed (layout A: BepInEx tree)"
    elif [ -d "${ext}/plugins" ]; then
        # Layout B: plugins/ at root (e.g. Jotunn, many Smoothbrain mods)
        ftp_upload_dir "${ext}/plugins" "/BepInEx/plugins"
        ok "${label} installed (layout B: plugins tree)"
    else
        # Layout C: find the DLL anywhere in the archive
        local found
        found=$(find "$ext" -name "${dll_name}" -type f 2>/dev/null | head -1) || true
        if [ -n "$found" ]; then
            ftp_upload_file "$found" "/BepInEx/plugins/${dll_name}"
            ok "${dll_name} -> /BepInEx/plugins/ (layout C: DLL)"
        else
            warn "Could not find ${dll_name} in zip - skipping ${label}"
        fi
    fi

    rm -rf "$ext" "$zip"
}

# ── Banner ────────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}${CYAN}+----------------------------------------------------------+${NC}"
echo -e "${BOLD}${CYAN}|  Valheim Server Mod Installer  ${FTP_HOST}:${FTP_PORT}        |${NC}"
echo -e "${BOLD}${CYAN}+----------------------------------------------------------+${NC}"
echo ""
echo "  Log: ${LOG_FILE}"

# ── 1. Backup /BepInEx/ ───────────────────────────────────────────────────────
step "Backing up server BepInEx (${FTP_HOST}:${FTP_PORT} -> ${BACKUP_DIR})"
mkdir -p "$BACKUP_DIR"
ftp_download_dir "/BepInEx/" "${BACKUP_DIR}/BepInEx/"
# Verify backup is non-empty -- ftp_download_dir silently produces empty dirs on auth failure
backup_count=$(find "$BACKUP_DIR" -type f | wc -l)
if [ "$backup_count" -eq 0 ]; then
    fail "Backup is empty (${backup_count} files) -- check FTP credentials before continuing"
fi
ok "Backup complete: ${BACKUP_DIR} (${backup_count} files)"

# ── 2. Update BepInEx core ───────────────────────────────────────────────────
step "Updating BepInEx to ${BEPINEX_VERSION}"
local bepinex_zip="${WORK_DIR}/bepinex.zip"
local bepinex_ext="${WORK_DIR}/bepinex_ext"
curl -fsSL --retry 3 --retry-delay 2 --max-time 120 \
    -H 'User-Agent: ValheimModInstaller/2.0' \
    -o "$bepinex_zip" "${BASE_URL}/denikson/BepInExPack_Valheim/${BEPINEX_VERSION}/" \
    || fail "BepInEx download failed"
mkdir -p "$bepinex_ext"
unzip -q -o "$bepinex_zip" -d "$bepinex_ext" 2>/dev/null || { local rc=$?; [ $rc -le 1 ] || fail "BepInEx extraction failed (exit $rc)"; }
local bepinex_src="${bepinex_ext}/BepInExPack_Valheim"
[ -d "$bepinex_src" ] || fail "Unexpected BepInEx zip structure"
# Upload BepInEx/core/ (preserves config/ and plugins/)
for f in "${bepinex_src}"/BepInEx/core/*; do
    ftp_upload_file "$f" "/BepInEx/core/$(basename "$f")"
done
# NOTE: doorstop_config.ini and doorstop_libs/ are managed by ScalaCube.
# vsFTPd blocks .so uploads, and BepInEx core 5.4.2333 requires matching
# doorstop v4.4.0 .so which we cannot upload. Do NOT overwrite these files.
# Only update BepInEx/core/ DLLs once ScalaCube updates doorstop on their end.
warn "Skipping doorstop_config.ini and doorstop_libs/ (managed by hosting provider)"
rm -rf "$bepinex_ext" "$bepinex_zip"
ok "BepInEx ${BEPINEX_VERSION} installed on server"

# ── 3. Library dependencies ───────────────────────────────────────────────────
step "Installing library dependencies"
install_mod_server "${BASE_URL}/ValheimModding/Jotunn/2.29.1/"     "Jotunn.dll"          "Jotunn 2.29.1"
install_mod_server "${BASE_URL}/ValheimModding/JsonDotNET/13.0.4/" "Newtonsoft.Json.dll" "JsonDotNET 13.0.4"
install_mod_server "${BASE_URL}/ValheimModding/YamlDotNet/16.3.1/" "YamlDotNet.dll"      "YamlDotNet 16.3.1"

# ── 4. Utility mods ───────────────────────────────────────────────────────────
step "Installing utility mods"
install_mod_server "${BASE_URL}/Azumatt/Recycle_N_Reclaim/1.3.6/"              "Recycle_N_Reclaim.dll"          "Recycle N Reclaim 1.3.6"
install_mod_server "${BASE_URL}/Grizzzly/CraftFromContainers/3.8.1/"           "CraftFromContainers.dll"         "CraftFromContainers 3.8.1"
install_mod_server "${BASE_URL}/OdinPlus/TeleportEverything/2.9.1/"            "TeleportEverything.dll"          "TeleportEverything 2.9.1"
install_mod_server "${BASE_URL}/Azumatt/AzuAutoStore/3.0.14/"                  "AzuAutoStore.dll"                "AzuAutoStore 3.0.14"
install_mod_server "${BASE_URL}/Azumatt/AzuExtendedPlayerInventory/2.4.1/"     "AzuExtendedPlayerInventory.dll"  "AzuExtendedPlayerInventory 2.4.1"
install_mod_server "${BASE_URL}/Vapok/AdventureBackpacks/1.9.12/"              "AdventureBackpacks.dll"          "AdventureBackpacks 1.9.12"
install_mod_server "${BASE_URL}/Tekla/AutoRepair/5.4.1602/"                    "AutoRepair.dll"                  "AutoRepair 5.4.1602"
install_mod_server "${BASE_URL}/Smoothbrain/TargetPortal/1.2.3/"               "TargetPortal.dll"                "TargetPortal 1.2.3"
install_mod_server "${BASE_URL}/Advize/PlantEverything/1.20.0/"                "Advize_PlantEverything.dll"      "PlantEverything 1.20.0"
install_mod_server "${BASE_URL}/shudnal/Waystones/1.0.14/"                     "Waystones.dll"                   "Waystones 1.0.14"
install_mod_server "${BASE_URL}/JereKuusela/Server_devcommands/1.105.0/"       "ServerDevcommands.dll"           "Server devcommands 1.105.0"
install_mod_server "${BASE_URL}/VentureValheim/Venture_Floating_Items/0.3.3/"  "VentureValheim.FloatingItems.dll" "Venture Floating Items 0.3.3"
install_mod_server "${BASE_URL}/TastyChickenLegs/AutomaticFuel/1.4.8/"        "AutomaticFuel.dll"               "AutomaticFuel 1.4.8"

# ── 5. Combat mods ───────────────────────────────────────────────────────────
step "Installing combat mods"
# Warfare + Armory REMOVED -- Unity 6 asset bundle crash (79 GB corrupted allocation)
# Warfare 1.8.9 hasn't been updated for Unity 6000.0.61f1
# BetterArchery SKIPPED -- crashes headless server (NullRef in Start/FejdStartup)
# Install on clients only. See memory: reference_server_mod_compatibility.md
install_mod_server "${BASE_URL}/RandyKnapp/EpicLoot/0.12.11/" "EpicLoot.dll"      "EpicLoot 0.12.11"

# ── 6. Skill mods ─────────────────────────────────────────────────────────────
step "Installing skill mods"
install_mod_server "${BASE_URL}/Smoothbrain/Mining/1.1.6/"  "Mining.dll"  "Mining 1.1.6"
install_mod_server "${BASE_URL}/Smoothbrain/Cooking/1.2.2/" "Cooking.dll" "Cooking 1.2.2"

# ── 7. Building mods ──────────────────────────────────────────────────────────
step "Installing building mods"
install_mod_server "${BASE_URL}/OdinPlus/OdinArchitect/1.6.5/"    "OdinArchitect.dll"    "OdinArchitect 1.6.5"
install_mod_server "${BASE_URL}/BentoG/MissingPieces/2.2.2/"      "MissingPieces.dll"    "MissingPieces 2.2.2"
install_mod_server "${BASE_URL}/OdinPlus/OdinCampsite/1.6.3/"     "OdinCampsite.dll"     "OdinCampsite 1.6.3"
install_mod_server "${BASE_URL}/OdinPlus/OdinsFoodBarrels/1.2.2/" "OdinsFoodBarrels.dll" "OdinsFoodBarrels 1.2.2"

# ── 8. Building / decoration expansion (Nexus build-pack, added 2026-06-27) ────
# All verified on Thunderstore: current (2025-2026 updates), not deprecated,
# built for the BepInEx 5.4.2333 / Jotunn 2.29.x era (Jotunn bumped above).
# Server install is REQUIRED so custom build-piece prefabs spawn and sync in MP.
# Compat assessed via dependency manifests -- confirm in-game after a restart.
# NOTE: Moonforged*, VALKEA, CoreWoodExtras carry large embedded asset bundles
# (~80-145 MB each); the FTP upload of this section is slow.
step "Installing building / decoration expansion"
install_mod_server "${BASE_URL}/blacks7ar/CoreWoodPieces/1.2.4/"             "CoreWoodPieces.dll"            "CoreWoodPieces 1.2.4"
install_mod_server "${BASE_URL}/blacks7ar/RefinedStonePieces/1.1.0/"         "RefinedStonePieces.dll"        "RefinedStonePieces 1.1.0"
install_mod_server "${BASE_URL}/blacks7ar/CrystalCollector/1.1.7/"           "CrystalCollector.dll"          "CrystalCollector 1.1.7"
install_mod_server "${BASE_URL}/blacks7ar/FeatherCollector/1.1.9/"           "FeatherCollector.dll"          "FeatherCollector 1.1.9"
install_mod_server "${BASE_URL}/blacks7ar/TarCollector/1.1.8/"               "TarCollector.dll"              "TarCollector 1.1.8"
install_mod_server "${BASE_URL}/blacks7ar/SimpleElevators/1.3.0/"            "SimpleElevators.dll"           "SimpleElevators 1.3.0"
install_mod_server "${BASE_URL}/Caenos/MoonforgedBuildPieces/1.0.6/"         "MoonforgedBuildPieces.dll"     "MoonforgedBuildPieces 1.0.6"
install_mod_server "${BASE_URL}/Caenos/MoonforgedGatesAndFences/1.0.9/"      "MoonforgedGatesAndFences.dll"  "MoonforgedGatesAndFences 1.0.9"
install_mod_server "${BASE_URL}/OdinPlus/Basements/1.4.1/"                   "Basements.dll"                 "Basements 1.4.1"
install_mod_server "${BASE_URL}/javadevils/OCDheim/0.2.2/"                   "OCDheim.dll"                   "OCDheim 0.2.2"
install_mod_server "${BASE_URL}/MagicMike/CoreWoodExtras/2.1.8/"             "CoreWoodExtras.dll"            "CoreWoodExtras 2.1.8"
install_mod_server "${BASE_URL}/MagicMike/MyZenGarden/1.0.3/"                "ZenGarden.dll"                 "MyZenGarden 1.0.3"
# WeedheimDecor REQUIRES base Weedheim -- install base first so the dependency loads
install_mod_server "${BASE_URL}/MagicMike/Weedheim/2.0.4/"                   "Weedheim.dll"                  "Weedheim 2.0.4 (base for WeedheimDecor)"
install_mod_server "${BASE_URL}/MagicMike/WeedheimDecor/1.0.3/"              "WeedheimDecor.dll"             "WeedheimDecor 1.0.3"
install_mod_server "${BASE_URL}/The_Bees_Decree/VALKEA/3.0.0/"               "VALKEA.dll"                    "VALKEA 3.0.0"

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}${GREEN}+----------------------------------------------------------+${NC}"
echo -e "${BOLD}${GREEN}|                 Server Update Complete!                  |${NC}"
echo -e "${BOLD}${GREEN}+----------------------------------------------------------+${NC}"
echo ""
echo "  Backup:  ${BACKUP_DIR}"
echo "  Log:     ${LOG_FILE}"
echo ""
echo -e "  ${YELLOW}IMPORTANT: Restart the server to load the new mods.${NC}"
echo ""
