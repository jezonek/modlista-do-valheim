#Requires -Version 5.1
<#
.SYNOPSIS
    Valheim Mod Installer for Windows

.DESCRIPTION
    Automatically finds your Valheim installation, backs up existing mods,
    downloads all required mod files from Thunderstore, and installs them.
    No Steam launch option changes needed on Windows (winhttp.dll handles it).

    INSTALLED MODS
    --------------
    Framework:
      BepInEx 5.4.2333           Mod loader (required by all mods)

    Library dependencies (installed first -- required by other mods):
      Jotunn 2.29.1              Valheim modding library
                                 (required by OdinArchitect, AdventureBackpacks,
                                 MissingPieces, EpicLoot)
      JsonDotNET 13.0.4          JSON serialisation library
                                 (required by MissingPieces, EpicLoot)
      YamlDotNet 16.3.1          YAML serialisation library
                                 (required by AdventureBackpacks)

    Utility mods:
      Recycle N Reclaim 1.3.6    Reclaim tab in crafting stations
      CraftFromContainers 3.8.1  Craft using nearby chest items
      TeleportEverything 2.9.1   Teleport through portals with ore/ingots
      AzuAutoStore 3.0.14        Auto-deposit items to matching nearby chests
      AzuExtendedPlayerInventory 2.4.1
                                 Extra inventory rows, 10 loadout sets, quick slots
      AdventureBackpacks 1.9.12  Wearable backpacks with storage (equip as armor)
      AutoRepair 5.4.1602        Auto-repair items when interacting with workbench
      TargetPortal 1.2.3         Choose portal destination from the map
      PlantEverything 1.20.0     Plant seeds, berries, mushrooms, and saplings
      PlantEasily 2.1.1          Grid planting + bulk harvest (companion to PlantEverything)
      Waystones 1.0.14           Place waystones + teleport to last death position
      Server devcommands 1.105.0 Admin console commands (cheats, spawn, event, tp, etc.)
      ChestSearch 1.0.6          Search chests by item name (F3 hotkey)
      Venture Floating Items 0.3.3  Dropped items float on water surface
      AutomaticFuel 1.4.8        Auto-fuels furnaces, kilns, smelters from nearby chests

    Combat mods:
      EpicLoot 0.12.11           Diablo-style magic loot, enchantments, bounties

    Skill mods:
      Mining 1.1.6               Mining skill with bonus ore yield
      Cooking 1.2.2              Enhanced cooking skill

    Building mods:
      OdinArchitect 1.6.5        205+ building pieces
      MissingPieces 2.2.2        Additional building pieces
      OdinCampsite 1.6.3         Camping-themed building pieces
      OdinsFoodBarrels 1.2.2     Food storage barrels (install on server + client)

    COMPATIBILITY NOTES
    -------------------
    INCOMPATIBLE combinations (do not install together):
      - AzuExtendedPlayerInventory + ExtraSlots / ExtraSlotsCustomSlots
      - OdinArchitect + Valheim+
      - OdinCampsite  + Valheim+
      - EpicLoot      + BetterUI custom tooltips (disable them in BetterUI config)

    Conditional compatibility:
      - MissingPieces: if build menu runs out of space, add SearsCatalog mod

    Removed mods (incompatible with Unity 6000.0.61f1):
      - Warfare 1.8.9 + Armory 1.3.1: corrupted 79 GB asset bundle allocation
      - BetterArchery 1.9.82: NullRef in TryRegisterRecipes on ObjectDB.Awake

    BACKUP
    ------
    Before touching any files, a timestamped copy of your existing BepInEx\
    folder is saved to: %USERPROFILE%\valheim_mods_backup_YYYYMMDD_HHMMSS\

.USAGE
    Double-click install_valheim_mods.bat (recommended - handles permissions automatically)
    OR open PowerShell as Administrator and run:
        Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
        .\install_valheim_mods.ps1
#>

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

# -- Versions ------------------------------------------------------------------
$BEPINEX_VERSION = "5.4.2333"

# Library dependencies
$JOTUNN_VERSION      = "2.29.1"   # bumped 2026-06-27 from 2.27.1: Moonforged/OCDheim need >=2.29.0
$JSONDOTNET_VERSION  = "13.0.4"
$YAMLDOTNET_VERSION  = "16.3.1"

# Utility mods
$RECYCLE_VERSION     = "1.3.6"
$CFC_VERSION         = "3.8.1"
$TE_VERSION          = "2.9.1"
$AUTOSTORE_VERSION   = "3.0.14"
$AZUEPI_VERSION      = "2.4.1"
$BACKPACKS_VERSION   = "1.9.12"
$AUTOREPAIR_VERSION  = "5.4.1602"
$TARGETPORTAL_VERSION = "1.2.3"
$PLANTEVERYTHING_VERSION = "1.20.0"
$WAYSTONES_VERSION   = "1.0.14"
$SERVERDEVCOMMANDS_VERSION = "1.105.0"
$CHESTSEARCH_VERSION  = "1.0.6"
$CHESTCONTENTS_VERSION = "1.1.0"
$FLOATINGITEMS_VERSION = "0.3.3"
$PLANTEASILY_VERSION  = "2.1.1"
$AUTOFUEL_VERSION     = "1.4.8"

# Combat mods
$EPICLOOT_VERSION     = "0.12.11"

# Skill mods
$MINING_VERSION  = "1.1.6"
$COOKING_VERSION = "1.2.2"

# Building mods
$ODINARCHITECT_VERSION    = "1.6.5"
$MISSINGPIECES_VERSION    = "2.2.2"
$ODINCAMPSITE_VERSION     = "1.6.3"
$ODINSFOODBARRELS_VERSION = "1.2.2"

# Building / decoration expansion (Nexus build-pack, added 2026-06-27)
$COREWOODPIECES_VERSION   = "1.2.4"
$REFINEDSTONE_VERSION     = "1.1.0"
$CRYSTALCOLLECTOR_VERSION = "1.1.7"
$FEATHERCOLLECTOR_VERSION = "1.1.9"
$TARCOLLECTOR_VERSION     = "1.1.8"
$SIMPLEELEVATORS_VERSION  = "1.3.0"
$MOONFORGEDBUILD_VERSION  = "1.0.6"
$MOONFORGEDGATES_VERSION  = "1.0.9"
$BASEMENTS_VERSION        = "1.4.1"
$OCDHEIM_VERSION          = "0.2.2"
$COREWOODEXTRAS_VERSION   = "2.1.8"
$MYZENGARDEN_VERSION      = "1.0.3"
$WEEDHEIM_VERSION         = "2.0.4"
$WEEDHEIMDECOR_VERSION    = "1.0.3"
$VALKEA_VERSION           = "3.0.0"

# -- Download URLs -------------------------------------------------------------
$BASE = "https://thunderstore.io/package/download"

$BEPINEX_URL = "$BASE/denikson/BepInExPack_Valheim/$BEPINEX_VERSION/"

$JOTUNN_URL     = "$BASE/ValheimModding/Jotunn/$JOTUNN_VERSION/"
$JSONDOTNET_URL = "$BASE/ValheimModding/JsonDotNET/$JSONDOTNET_VERSION/"
$YAMLDOTNET_URL = "$BASE/ValheimModding/YamlDotNet/$YAMLDOTNET_VERSION/"

$RECYCLE_URL      = "$BASE/Azumatt/Recycle_N_Reclaim/$RECYCLE_VERSION/"
$CFC_URL          = "$BASE/Grizzzly/CraftFromContainers/$CFC_VERSION/"
$TE_URL           = "$BASE/OdinPlus/TeleportEverything/$TE_VERSION/"
$AUTOSTORE_URL    = "$BASE/Azumatt/AzuAutoStore/$AUTOSTORE_VERSION/"
$AZUEPI_URL       = "$BASE/Azumatt/AzuExtendedPlayerInventory/$AZUEPI_VERSION/"
$BACKPACKS_URL    = "$BASE/Vapok/AdventureBackpacks/$BACKPACKS_VERSION/"
$AUTOREPAIR_URL   = "$BASE/Tekla/AutoRepair/$AUTOREPAIR_VERSION/"
$TARGETPORTAL_URL     = "$BASE/Smoothbrain/TargetPortal/$TARGETPORTAL_VERSION/"
$PLANTEVERYTHING_URL  = "$BASE/Advize/PlantEverything/$PLANTEVERYTHING_VERSION/"
$WAYSTONES_URL        = "$BASE/shudnal/Waystones/$WAYSTONES_VERSION/"
$SERVERDEVCOMMANDS_URL = "$BASE/JereKuusela/Server_devcommands/$SERVERDEVCOMMANDS_VERSION/"
$CHESTSEARCH_URL    = "$BASE/Channel2NewsTeam/ChestSearch/$CHESTSEARCH_VERSION/"
$CHESTCONTENTS_URL  = "$BASE/Sticky/ChestContents/$CHESTCONTENTS_VERSION/"
$FLOATINGITEMS_URL  = "$BASE/VentureValheim/Venture_Floating_Items/$FLOATINGITEMS_VERSION/"
$PLANTEASILY_URL   = "$BASE/Advize/PlantEasily/$PLANTEASILY_VERSION/"
$AUTOFUEL_URL      = "$BASE/TastyChickenLegs/AutomaticFuel/$AUTOFUEL_VERSION/"

$EPICLOOT_URL      = "$BASE/RandyKnapp/EpicLoot/$EPICLOOT_VERSION/"

$MINING_URL  = "$BASE/Smoothbrain/Mining/$MINING_VERSION/"
$COOKING_URL = "$BASE/Smoothbrain/Cooking/$COOKING_VERSION/"

$ODINARCHITECT_URL    = "$BASE/OdinPlus/OdinArchitect/$ODINARCHITECT_VERSION/"
$MISSINGPIECES_URL    = "$BASE/BentoG/MissingPieces/$MISSINGPIECES_VERSION/"
$ODINCAMPSITE_URL     = "$BASE/OdinPlus/OdinCampsite/$ODINCAMPSITE_VERSION/"
$ODINSFOODBARRELS_URL = "$BASE/OdinPlus/OdinsFoodBarrels/$ODINSFOODBARRELS_VERSION/"

# Building / decoration expansion
$COREWOODPIECES_URL   = "$BASE/blacks7ar/CoreWoodPieces/$COREWOODPIECES_VERSION/"
$REFINEDSTONE_URL     = "$BASE/blacks7ar/RefinedStonePieces/$REFINEDSTONE_VERSION/"
$CRYSTALCOLLECTOR_URL = "$BASE/blacks7ar/CrystalCollector/$CRYSTALCOLLECTOR_VERSION/"
$FEATHERCOLLECTOR_URL = "$BASE/blacks7ar/FeatherCollector/$FEATHERCOLLECTOR_VERSION/"
$TARCOLLECTOR_URL     = "$BASE/blacks7ar/TarCollector/$TARCOLLECTOR_VERSION/"
$SIMPLEELEVATORS_URL  = "$BASE/blacks7ar/SimpleElevators/$SIMPLEELEVATORS_VERSION/"
$MOONFORGEDBUILD_URL  = "$BASE/Caenos/MoonforgedBuildPieces/$MOONFORGEDBUILD_VERSION/"
$MOONFORGEDGATES_URL  = "$BASE/Caenos/MoonforgedGatesAndFences/$MOONFORGEDGATES_VERSION/"
$BASEMENTS_URL        = "$BASE/OdinPlus/Basements/$BASEMENTS_VERSION/"
$OCDHEIM_URL          = "$BASE/javadevils/OCDheim/$OCDHEIM_VERSION/"
$COREWOODEXTRAS_URL   = "$BASE/MagicMike/CoreWoodExtras/$COREWOODEXTRAS_VERSION/"
$MYZENGARDEN_URL      = "$BASE/MagicMike/MyZenGarden/$MYZENGARDEN_VERSION/"
$WEEDHEIM_URL         = "$BASE/MagicMike/Weedheim/$WEEDHEIM_VERSION/"
$WEEDHEIMDECOR_URL    = "$BASE/MagicMike/WeedheimDecor/$WEEDHEIMDECOR_VERSION/"
$VALKEA_URL           = "$BASE/The_Bees_Decree/VALKEA/$VALKEA_VERSION/"

# -- Output helpers ------------------------------------------------------------
function Write-Banner {
    Write-Host ""
    Write-Host "  +----------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host "  |      Valheim Mod Installer - Windows Edition             |" -ForegroundColor Cyan
    Write-Host "  +----------------------------------------------------------+" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Step   { param($msg) Write-Host "`n  >> $msg" -ForegroundColor Blue }
function Write-Ok     { param($msg) Write-Host "     OK  $msg" -ForegroundColor Green }
function Write-Warn   { param($msg) Write-Host "     !!  $msg" -ForegroundColor Yellow }
function Write-Info   { param($msg) Write-Host "         $msg" -ForegroundColor DarkGray }
function Write-Fail   {
    param($msg)
    Write-Host "`n  ERROR: $msg" -ForegroundColor Red
    Write-Host ""
    # Clean up temp dir now -- exit 1 bypasses the finally block in the main try/finally
    if ($script:tmpDir -and (Test-Path $script:tmpDir)) {
        Remove-Item -Path $script:tmpDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    Read-Host "  Press Enter to close"
    exit 1
}

# -- Find Steam ----------------------------------------------------------------
function Find-SteamPath {
    $regPaths = @(
        'HKLM:\SOFTWARE\WOW6432Node\Valve\Steam',
        'HKLM:\SOFTWARE\Valve\Steam',
        'HKCU:\SOFTWARE\Valve\Steam'
    )
    foreach ($reg in $regPaths) {
        try {
            $val = Get-ItemPropertyValue -Path $reg -Name 'InstallPath' -ErrorAction SilentlyContinue
            if ($val -and (Test-Path $val)) { return $val }
        } catch {}
    }
    return $null
}

# -- Find Valheim across all Steam libraries -----------------------------------
function Find-Valheim {
    Write-Step "Locating Valheim installation"

    $steamPath   = Find-SteamPath
    $searchRoots = @()

    if ($steamPath) {
        $searchRoots += $steamPath

        # Parse libraryfolders.vdf for additional library paths
        $vdfPath = Join-Path $steamPath 'steamapps\libraryfolders.vdf'
        if (Test-Path $vdfPath) {
            $vdfContent = Get-Content $vdfPath -Raw
            $libMatches = [regex]::Matches($vdfContent, '"path"\s+"([^"]+)"')
            foreach ($m in $libMatches) {
                $libPath = $m.Groups[1].Value -replace '\\\\', '\'
                if (Test-Path $libPath) { $searchRoots += $libPath }
            }
        }
    }

    # Common fallback paths
    $searchRoots += @(
        "$env:ProgramFiles\Steam",
        "${env:ProgramFiles(x86)}\Steam",
        "C:\Steam",
        "D:\Steam",
        "E:\Steam"
    )

    foreach ($root in $searchRoots) {
        $candidate = Join-Path $root "steamapps\common\Valheim"
        if (Test-Path (Join-Path $candidate "valheim.exe")) {
            Write-Ok "Found at: $candidate"
            return $candidate
        }
    }

    # Manual fallback
    Write-Host ""
    Write-Warn "Could not auto-detect Valheim."
    Write-Host "         Tip: In Steam right-click Valheim -> Manage -> Browse local files" -ForegroundColor DarkGray
    Write-Host ""
    $manualPath = Read-Host "  Enter Valheim folder path"
    $manualPath = $manualPath.Trim().Trim('"')

    if (-not (Test-Path (Join-Path $manualPath "valheim.exe"))) {
        Write-Fail "No valheim.exe found at '$manualPath'. Is the path correct?"
    }
    Write-Ok "Found at: $manualPath"
    return $manualPath
}

# -- Backup existing BepInEx ---------------------------------------------------
function Backup-BepInEx {
    param([string]$ValheimDir)

    Write-Step "Backing up existing BepInEx installation"

    $bepinexDir = Join-Path $ValheimDir "BepInEx"
    if (-not (Test-Path $bepinexDir)) {
        Write-Info "No existing BepInEx directory found - skipping backup."
        return $null
    }

    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupDir = Join-Path $env:USERPROFILE "valheim_mods_backup_$timestamp"
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    Copy-Item -Path $bepinexDir -Destination $backupDir -Recurse -Force
    Write-Ok "Backup saved to: $backupDir"
    Write-Info "To restore: Copy-Item -Path '$backupDir\BepInEx' -Destination '$ValheimDir' -Recurse -Force"
    return $backupDir
}

# -- Download ------------------------------------------------------------------
function Get-ModFile {
    param([string]$Url, [string]$Dest, [string]$Label)

    Write-Info "Downloading $Label..."
    $maxRetries = 3
    $retryDelay = 2

    for ($attempt = 1; $attempt -le $maxRetries; $attempt++) {
        try {
            Invoke-WebRequest -Uri $Url -OutFile $Dest -UseBasicParsing -TimeoutSec 120 `
                -Headers @{ 'User-Agent' = 'ValheimModInstaller/2.0' }
            $size = [math]::Round((Get-Item $Dest).Length / 1KB)
            if ($size -eq 0) { throw "Downloaded file is empty (0 KB)" }
            Write-Ok "$Label  ($size KB)"
            return
        } catch {
            if ($attempt -lt $maxRetries) {
                Write-Info "Attempt $attempt failed, retrying in $retryDelay seconds..."
                Start-Sleep -Seconds $retryDelay
            } else {
                Write-Fail "Failed to download $Label after $maxRetries attempts.`n         $_`n         Check your internet connection and try again."
            }
        }
    }
}

# -- Install BepInEx -----------------------------------------------------------
# On first run: extracts and installs BepInEx core files + winhttp.dll.
# On re-run (update): skips if the installed version matches $BEPINEX_VERSION
# to avoid overwriting configs. Force-reinstall by deleting winhttp.dll first.
function Install-BepInEx {
    param([string]$ValheimDir, [string]$TmpDir)

    Write-Step "Installing BepInEx $BEPINEX_VERSION"

    # Check for an existing BepInEx installation.
    # If winhttp.dll already exists in the Valheim folder, BepInEx is installed.
    # Skip reinstall to preserve existing BepInEx\config\ settings.
    # To force a clean reinstall, delete winhttp.dll from the Valheim folder first.
    $winhttpDst = Join-Path $ValheimDir "winhttp.dll"
    $bepinexCore = Join-Path $ValheimDir "BepInEx\core\BepInEx.dll"
    if ((Test-Path $winhttpDst) -and (Test-Path $bepinexCore)) {
        Write-Ok "BepInEx already installed -- skipping reinstall"
        Write-Info "Your BepInEx\config\ settings are preserved."
        Write-Info "To force a clean reinstall, delete winhttp.dll from your Valheim folder."

        # Ensure plugins directory exists on older installs that may lack it
        $pluginsDir = Join-Path $ValheimDir "BepInEx\plugins"
        New-Item -ItemType Directory -Path $pluginsDir -Force | Out-Null
        return
    }

    $zipPath     = Join-Path $TmpDir "bepinex.zip"
    $extractPath = Join-Path $TmpDir "bepinex"

    Get-ModFile -Url $BEPINEX_URL -Dest $zipPath -Label "BepInExPack_Valheim-$BEPINEX_VERSION"

    # Validate zip integrity before extracting
    try {
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        $testZip = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
        $testZip.Dispose()
    } catch {
        Write-Fail "Downloaded BepInEx file is corrupted or not a valid zip. Delete it and try again."
    }

    Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force
    $src = Join-Path $extractPath "BepInExPack_Valheim"

    if (-not (Test-Path $src)) {
        Write-Fail "Unexpected BepInEx zip structure -- BepInExPack_Valheim\ subfolder not found."
    }

    Copy-Item -Path (Join-Path $src "BepInEx")             -Destination $ValheimDir -Recurse -Force
    Copy-Item -Path (Join-Path $src "winhttp.dll")         -Destination $ValheimDir -Force
    Copy-Item -Path (Join-Path $src "doorstop_config.ini") -Destination $ValheimDir -Force

    $pluginsDir = Join-Path $ValheimDir "BepInEx\plugins"
    New-Item -ItemType Directory -Path $pluginsDir -Force | Out-Null

    Write-Ok "BepInEx core files installed"
    Write-Ok "winhttp.dll installed  (auto-loads BepInEx - no launch options needed)"
}

# -- Install mod (smart: handles all three Thunderstore zip layouts) -------------
# Thunderstore packages use one of three layouts -- detection order matters:
#
#   Layout A: BepInEx\ at zip root (e.g. OdinArchitect, AdventureBackpacks)
#             -> merges full BepInEx\ tree into the game directory
#             -> preserves subdirs like BepInEx\plugins\OdinArchitect\Assets\
#
#   Layout B: plugins\ at zip root (e.g. Jotunn, JsonDotNET, YamlDotNet, AutoRepair)
#             -> copies the plugins\ tree into BepInEx\plugins\
#             -> necessary for mods that ship multiple files (DLL + PDB + XML)
#
#   Layout C: DLL at zip root alongside manifest/icon/README (most simple mods)
#             -> locates $DllName anywhere in the extracted tree
#             -> copies it to BepInEx\plugins\
#
# This function is idempotent: re-running it on an existing installation updates
# the mod files in-place without touching configs (those live in BepInEx\config\).
function Install-Mod {
    param(
        [string]$Url,
        [string]$DllName,
        [string]$Label,
        [string]$ValheimDir,
        [string]$TmpDir
    )

    $safeName    = [System.IO.Path]::GetFileNameWithoutExtension($DllName)
    $zipPath     = Join-Path $TmpDir "$safeName.zip"
    $extractPath = Join-Path $TmpDir "${safeName}_ext"

    Get-ModFile -Url $Url -Dest $zipPath -Label $Label

    # Validate zip integrity
    try {
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        $testZip = [System.IO.Compression.ZipFile]::OpenRead($zipPath)
        $testZip.Dispose()
    } catch {
        Write-Fail "Downloaded file for $Label is corrupted or not a valid zip."
    }

    Expand-Archive -Path $zipPath -DestinationPath $extractPath -Force

    $bepinexSrc = Join-Path $extractPath "BepInEx"
    $pluginsSrc = Join-Path $extractPath "plugins"
    $bepinexDst = Join-Path $ValheimDir  "BepInEx"
    $pluginsDst = Join-Path $ValheimDir  "BepInEx\plugins"

    if (Test-Path $bepinexSrc) {
        # Layout A: zip has BepInEx\ at root -- merge entire tree (preserves assets, translations, etc.)
        Get-ChildItem -Path $bepinexSrc | ForEach-Object {
            Copy-Item -Path $_.FullName -Destination $bepinexDst -Recurse -Force
        }
        Write-Ok "$Label installed (layout A - full BepInEx tree)"
    } elseif (Test-Path $pluginsSrc) {
        # Layout B: zip has plugins\ at root -- copy tree into BepInEx\plugins\
        # Required for: Jotunn (DLL+PDB+MDB+XML), JsonDotNET, YamlDotNet, AutoRepair
        Get-ChildItem -Path $pluginsSrc | ForEach-Object {
            Copy-Item -Path $_.FullName -Destination $pluginsDst -Recurse -Force
        }
        Write-Ok "$Label installed (layout B - plugins tree)"
    } else {
        # Layout C: DLL (and optional extras) at zip root -- find and copy the DLL
        $found = Get-ChildItem -Path $extractPath -Filter $DllName -Recurse `
                 | Select-Object -First 1
        if ($found) {
            $destPath = Join-Path $pluginsDst $DllName
            Copy-Item -Path $found.FullName -Destination $destPath -Force
            Write-Ok "$DllName installed (layout C - plugins\)"
        } else {
            Write-Fail "Could not find $DllName in the downloaded zip for $Label."
        }
    }
}

# -- Summary -------------------------------------------------------------------
function Write-Summary {
    param([string]$ValheimDir, [string]$BackupDir)

    Write-Host ""
    Write-Host "  +----------------------------------------------------------+" -ForegroundColor Green
    Write-Host "  |                 Installation Complete!                   |" -ForegroundColor Green
    Write-Host "  +----------------------------------------------------------+" -ForegroundColor Green
    Write-Host ""
    Write-Host "     OK  BepInEx $BEPINEX_VERSION" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Dependencies:" -ForegroundColor Cyan
    Write-Host "     OK  Jotunn $JOTUNN_VERSION" -ForegroundColor Green
    Write-Host "     OK  JsonDotNET $JSONDOTNET_VERSION" -ForegroundColor Green
    Write-Host "     OK  YamlDotNet $YAMLDOTNET_VERSION" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Utility mods:" -ForegroundColor Cyan
    Write-Host "     OK  Recycle N Reclaim $RECYCLE_VERSION  (Reclaim tab in crafting stations)" -ForegroundColor Green
    Write-Host "     OK  CraftFromContainers $CFC_VERSION  (craft using items in nearby chests)" -ForegroundColor Green
    Write-Host "     OK  TeleportEverything $TE_VERSION  (teleport through portals with ores/ingots)" -ForegroundColor Green
    Write-Host "     OK  AzuAutoStore $AUTOSTORE_VERSION  (auto-deposit items to matching chest stacks)" -ForegroundColor Green
    Write-Host "     OK  AzuExtendedPlayerInventory $AZUEPI_VERSION  (extra rows, 10 loadouts, quick slots)" -ForegroundColor Green
    Write-Host "     OK  AdventureBackpacks $BACKPACKS_VERSION  (wearable backpacks -- equip as armor)" -ForegroundColor Green
    Write-Host "     OK  AutoRepair $AUTOREPAIR_VERSION  (auto-repair at workbenches)" -ForegroundColor Green
    Write-Host "     OK  TargetPortal $TARGETPORTAL_VERSION  (choose portal destination on map)" -ForegroundColor Green
    Write-Host "     OK  PlantEverything $PLANTEVERYTHING_VERSION  (plant seeds, berries, mushrooms, saplings)" -ForegroundColor Green
    Write-Host "     OK  PlantEasily $PLANTEASILY_VERSION  (grid planting + bulk harvest)" -ForegroundColor Green
    Write-Host "     OK  Waystones $WAYSTONES_VERSION  (waystone network + teleport to last death)" -ForegroundColor Green
    Write-Host "     OK  Server devcommands $SERVERDEVCOMMANDS_VERSION  (admin console: cheats, spawn, event, tp...)" -ForegroundColor Green
    Write-Host "     OK  ChestSearch $CHESTSEARCH_VERSION  (F3 hotkey to search chests for items -- Windows GUI)" -ForegroundColor Green
    Write-Host "     OK  ChestContents $CHESTCONTENTS_VERSION  (F5 console -> type 'cs <name>' with NO slash -- find any item incl. not in inventory)" -ForegroundColor Green
    Write-Host "     OK  Venture Floating Items $FLOATINGITEMS_VERSION  (dropped items float on water)" -ForegroundColor Green
    Write-Host "     OK  AutomaticFuel $AUTOFUEL_VERSION  (auto-fuels furnaces, kilns, smelters)" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Combat mods:" -ForegroundColor Cyan
    Write-Host "     OK  EpicLoot $EPICLOOT_VERSION  (magic loot, enchantments, bounties)" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Skill mods:" -ForegroundColor Cyan
    Write-Host "     OK  Mining $MINING_VERSION  (mining skill with bonus ore yield)" -ForegroundColor Green
    Write-Host "     OK  Cooking $COOKING_VERSION  (enhanced cooking skill)" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Building mods:" -ForegroundColor Cyan
    Write-Host "     OK  OdinArchitect $ODINARCHITECT_VERSION  (205+ building pieces)" -ForegroundColor Green
    Write-Host "     OK  MissingPieces $MISSINGPIECES_VERSION  (additional building pieces)" -ForegroundColor Green
    Write-Host "     OK  OdinCampsite $ODINCAMPSITE_VERSION  (camping-themed building pieces)" -ForegroundColor Green
    Write-Host "     OK  OdinsFoodBarrels $ODINSFOODBARRELS_VERSION  (food storage barrels)" -ForegroundColor Green
    Write-Host ""
    Write-Host "  Building / decoration expansion:" -ForegroundColor Cyan
    Write-Host "     OK  CoreWoodPieces $COREWOODPIECES_VERSION + CoreWoodExtras $COREWOODEXTRAS_VERSION  (corewood build set + HD furniture/clutter)" -ForegroundColor Green
    Write-Host "     OK  RefinedStonePieces $REFINEDSTONE_VERSION  (103 refined-stone pieces)" -ForegroundColor Green
    Write-Host "     OK  MoonforgedBuildPieces $MOONFORGEDBUILD_VERSION + GatesAndFences $MOONFORGEDGATES_VERSION  (90+ decor; gates/fences/walls)" -ForegroundColor Green
    Write-Host "     OK  VALKEA $VALKEA_VERSION  (300+ homestead build pieces)" -ForegroundColor Green
    Write-Host "     OK  MyZenGarden $MYZENGARDEN_VERSION  (zen garden HD pieces)" -ForegroundColor Green
    Write-Host "     OK  Weedheim $WEEDHEIM_VERSION + WeedheimDecor $WEEDHEIMDECOR_VERSION  (themed content + decor)" -ForegroundColor Green
    Write-Host "     OK  Basements $BASEMENTS_VERSION  (placeable underground basements)" -ForegroundColor Green
    Write-Host "     OK  SimpleElevators $SIMPLEELEVATORS_VERSION  (working elevators + platforms)" -ForegroundColor Green
    Write-Host "     OK  Crystal/Feather/Tar Collectors  (passive resource collectors)" -ForegroundColor Green
    Write-Host "     OK  OCDheim $OCDHEIM_VERSION  (furniture snapping + precision build mode)" -ForegroundColor Green
    Write-Host ""
    Write-Host "         Installed to: $ValheimDir" -ForegroundColor DarkGray
    if ($BackupDir) {
        Write-Host "         Backup at:    $BackupDir" -ForegroundColor DarkGray
    }
    Write-Host ""
    Write-Host "  In-game tips:" -ForegroundColor Cyan
    Write-Host "    Recycle:              open any crafting station -> Reclaim tab"
    Write-Host "    Craft from chests:    craft normally - nearby chest items are used automatically"
    Write-Host "    Adventure Backpack:   equip in the cape slot"
    Write-Host "    TargetPortal:         open map, click a portal to choose its destination"
    Write-Host "    PlantEverything:      plant seeds, berries, mushrooms from inventory"
    Write-Host "    PlantEasily:          hold Ctrl while planting to fill a grid; swing cultivator to bulk-harvest"
    Write-Host "    ChestSearch:          press F3 to search chests by item name"
    Write-Host "    AutomaticFuel:        furnaces/kilns/smelters pull fuel from nearby chests automatically"
    Write-Host "    EpicLoot:             colored item names indicate magic tier"
    Write-Host "    Mining/Cooking:       skill XP gained from the respective activities"
    Write-Host "    OdinArchitect:        new build pieces in the hammer menu"
    Write-Host ""
    Write-Host "  No Steam launch option changes needed on Windows." -ForegroundColor DarkGray
    Write-Host "  Just launch Valheim normally through Steam." -ForegroundColor DarkGray
    Write-Host ""
    Write-Host "  To uninstall: delete BepInEx\, winhttp.dll, doorstop_config.ini" -ForegroundColor DarkGray
    Write-Host "  from your Valheim folder." -ForegroundColor DarkGray
    Write-Host ""
    Read-Host "  Press Enter to close"
}

# -- Main ----------------------------------------------------------------------
Write-Banner

$tmpDir    = Join-Path $env:TEMP "valheim_mod_install_$(Get-Random)"
$backupDir = $null
# Store in script scope so Write-Fail can clean up before calling exit 1
$script:tmpDir = $tmpDir
New-Item -ItemType Directory -Path $tmpDir -Force | Out-Null

try {
    $valheimDir = Find-Valheim

    # Abort if Valheim is running (files would be locked)
    if (Get-Process -Name "valheim" -ErrorAction SilentlyContinue) {
        Write-Fail "Valheim is currently running. Please close the game and try again."
    }

    $backupDir = Backup-BepInEx -ValheimDir $valheimDir

    # Base framework
    Install-BepInEx -ValheimDir $valheimDir -TmpDir $tmpDir

    # Library dependencies -- install before any mod that needs them
    Write-Step "Installing library dependencies"
    Install-Mod -Url $JOTUNN_URL     -DllName "Jotunn.dll"          -Label "Jotunn $JOTUNN_VERSION"         -ValheimDir $valheimDir -TmpDir $tmpDir
    Install-Mod -Url $JSONDOTNET_URL -DllName "Newtonsoft.Json.dll" -Label "JsonDotNET $JSONDOTNET_VERSION"  -ValheimDir $valheimDir -TmpDir $tmpDir
    Install-Mod -Url $YAMLDOTNET_URL -DllName "YamlDotNet.dll"      -Label "YamlDotNet $YAMLDOTNET_VERSION"  -ValheimDir $valheimDir -TmpDir $tmpDir

    # Utility mods
    Write-Step "Installing utility mods"
    Install-Mod -Url $RECYCLE_URL      -DllName "Recycle_N_Reclaim.dll"          -Label "Recycle N Reclaim $RECYCLE_VERSION"             -ValheimDir $valheimDir -TmpDir $tmpDir
    Install-Mod -Url $CFC_URL          -DllName "CraftFromContainers.dll"         -Label "CraftFromContainers $CFC_VERSION"               -ValheimDir $valheimDir -TmpDir $tmpDir
    Install-Mod -Url $TE_URL           -DllName "TeleportEverything.dll"          -Label "TeleportEverything $TE_VERSION"                 -ValheimDir $valheimDir -TmpDir $tmpDir
    Install-Mod -Url $AUTOSTORE_URL    -DllName "AzuAutoStore.dll"                -Label "AzuAutoStore $AUTOSTORE_VERSION"                -ValheimDir $valheimDir -TmpDir $tmpDir
    Install-Mod -Url $AZUEPI_URL       -DllName "AzuExtendedPlayerInventory.dll"  -Label "AzuExtendedPlayerInventory $AZUEPI_VERSION"     -ValheimDir $valheimDir -TmpDir $tmpDir
    Install-Mod -Url $BACKPACKS_URL    -DllName "AdventureBackpacks.dll"          -Label "AdventureBackpacks $BACKPACKS_VERSION"          -ValheimDir $valheimDir -TmpDir $tmpDir
    Install-Mod -Url $AUTOREPAIR_URL   -DllName "AutoRepair.dll"                  -Label "AutoRepair $AUTOREPAIR_VERSION"                 -ValheimDir $valheimDir -TmpDir $tmpDir
    Install-Mod -Url $TARGETPORTAL_URL     -DllName "TargetPortal.dll"     -Label "TargetPortal $TARGETPORTAL_VERSION"         -ValheimDir $valheimDir -TmpDir $tmpDir
    Install-Mod -Url $PLANTEVERYTHING_URL  -DllName "Advize_PlantEverything.dll"  -Label "PlantEverything $PLANTEVERYTHING_VERSION"   -ValheimDir $valheimDir -TmpDir $tmpDir
    Install-Mod -Url $PLANTEASILY_URL     -DllName "Advize_PlantEasily.dll"      -Label "PlantEasily $PLANTEASILY_VERSION"            -ValheimDir $valheimDir -TmpDir $tmpDir
    Install-Mod -Url $WAYSTONES_URL        -DllName "Waystones.dll"               -Label "Waystones $WAYSTONES_VERSION"               -ValheimDir $valheimDir -TmpDir $tmpDir
    Install-Mod -Url $SERVERDEVCOMMANDS_URL -DllName "ServerDevcommands.dll"      -Label "Server devcommands $SERVERDEVCOMMANDS_VERSION" -ValheimDir $valheimDir -TmpDir $tmpDir
    Install-Mod -Url $CHESTSEARCH_URL     -DllName "ChestSearch.dll"             -Label "ChestSearch $CHESTSEARCH_VERSION"           -ValheimDir $valheimDir -TmpDir $tmpDir
    Install-Mod -Url $CHESTCONTENTS_URL   -DllName "ChestContents.dll"           -Label "ChestContents $CHESTCONTENTS_VERSION"       -ValheimDir $valheimDir -TmpDir $tmpDir
    Install-Mod -Url $FLOATINGITEMS_URL   -DllName "VentureValheim.FloatingItems.dll" -Label "Venture Floating Items $FLOATINGITEMS_VERSION" -ValheimDir $valheimDir -TmpDir $tmpDir
    Install-Mod -Url $AUTOFUEL_URL        -DllName "AutomaticFuel.dll"           -Label "AutomaticFuel $AUTOFUEL_VERSION"            -ValheimDir $valheimDir -TmpDir $tmpDir

    # Combat mods
    Write-Step "Installing combat mods"
    Install-Mod -Url $EPICLOOT_URL      -DllName "EpicLoot.dll"      -Label "EpicLoot $EPICLOOT_VERSION"           -ValheimDir $valheimDir -TmpDir $tmpDir

    # Skill mods
    Write-Step "Installing skill mods"
    Install-Mod -Url $MINING_URL  -DllName "Mining.dll"  -Label "Mining $MINING_VERSION"   -ValheimDir $valheimDir -TmpDir $tmpDir
    Install-Mod -Url $COOKING_URL -DllName "Cooking.dll" -Label "Cooking $COOKING_VERSION" -ValheimDir $valheimDir -TmpDir $tmpDir

    # Building mods
    Write-Step "Installing building mods"
    Install-Mod -Url $ODINARCHITECT_URL    -DllName "OdinArchitect.dll"    -Label "OdinArchitect $ODINARCHITECT_VERSION"       -ValheimDir $valheimDir -TmpDir $tmpDir
    Install-Mod -Url $MISSINGPIECES_URL    -DllName "MissingPieces.dll"    -Label "MissingPieces $MISSINGPIECES_VERSION"       -ValheimDir $valheimDir -TmpDir $tmpDir
    Install-Mod -Url $ODINCAMPSITE_URL     -DllName "OdinCampsite.dll"     -Label "OdinCampsite $ODINCAMPSITE_VERSION"         -ValheimDir $valheimDir -TmpDir $tmpDir
    Install-Mod -Url $ODINSFOODBARRELS_URL -DllName "OdinsFoodBarrels.dll" -Label "OdinsFoodBarrels $ODINSFOODBARRELS_VERSION" -ValheimDir $valheimDir -TmpDir $tmpDir

    # Building / decoration expansion (added 2026-06-27)
    # Must be on BOTH server and client so custom build pieces sync in MP.
    # All require Jotunn (installed above, bumped to 2.29.1).
    Write-Step "Installing building / decoration expansion"
    Install-Mod -Url $COREWOODPIECES_URL   -DllName "CoreWoodPieces.dll"           -Label "CoreWoodPieces $COREWOODPIECES_VERSION"           -ValheimDir $valheimDir -TmpDir $tmpDir
    Install-Mod -Url $REFINEDSTONE_URL     -DllName "RefinedStonePieces.dll"        -Label "RefinedStonePieces $REFINEDSTONE_VERSION"         -ValheimDir $valheimDir -TmpDir $tmpDir
    Install-Mod -Url $CRYSTALCOLLECTOR_URL -DllName "CrystalCollector.dll"          -Label "CrystalCollector $CRYSTALCOLLECTOR_VERSION"       -ValheimDir $valheimDir -TmpDir $tmpDir
    Install-Mod -Url $FEATHERCOLLECTOR_URL -DllName "FeatherCollector.dll"          -Label "FeatherCollector $FEATHERCOLLECTOR_VERSION"       -ValheimDir $valheimDir -TmpDir $tmpDir
    Install-Mod -Url $TARCOLLECTOR_URL     -DllName "TarCollector.dll"              -Label "TarCollector $TARCOLLECTOR_VERSION"               -ValheimDir $valheimDir -TmpDir $tmpDir
    Install-Mod -Url $SIMPLEELEVATORS_URL  -DllName "SimpleElevators.dll"           -Label "SimpleElevators $SIMPLEELEVATORS_VERSION"         -ValheimDir $valheimDir -TmpDir $tmpDir
    Install-Mod -Url $MOONFORGEDBUILD_URL  -DllName "MoonforgedBuildPieces.dll"     -Label "MoonforgedBuildPieces $MOONFORGEDBUILD_VERSION"   -ValheimDir $valheimDir -TmpDir $tmpDir
    Install-Mod -Url $MOONFORGEDGATES_URL  -DllName "MoonforgedGatesAndFences.dll"  -Label "MoonforgedGatesAndFences $MOONFORGEDGATES_VERSION" -ValheimDir $valheimDir -TmpDir $tmpDir
    Install-Mod -Url $BASEMENTS_URL        -DllName "Basements.dll"                 -Label "Basements $BASEMENTS_VERSION"                     -ValheimDir $valheimDir -TmpDir $tmpDir
    Install-Mod -Url $OCDHEIM_URL          -DllName "OCDheim.dll"                   -Label "OCDheim $OCDHEIM_VERSION"                         -ValheimDir $valheimDir -TmpDir $tmpDir
    Install-Mod -Url $COREWOODEXTRAS_URL   -DllName "CoreWoodExtras.dll"            -Label "CoreWoodExtras $COREWOODEXTRAS_VERSION"           -ValheimDir $valheimDir -TmpDir $tmpDir
    Install-Mod -Url $MYZENGARDEN_URL      -DllName "ZenGarden.dll"                 -Label "MyZenGarden $MYZENGARDEN_VERSION"                 -ValheimDir $valheimDir -TmpDir $tmpDir
    # WeedheimDecor requires base Weedheim -- install base first
    Install-Mod -Url $WEEDHEIM_URL         -DllName "Weedheim.dll"                  -Label "Weedheim $WEEDHEIM_VERSION (base for WeedheimDecor)" -ValheimDir $valheimDir -TmpDir $tmpDir
    Install-Mod -Url $WEEDHEIMDECOR_URL    -DllName "WeedheimDecor.dll"             -Label "WeedheimDecor $WEEDHEIMDECOR_VERSION"             -ValheimDir $valheimDir -TmpDir $tmpDir
    Install-Mod -Url $VALKEA_URL           -DllName "VALKEA.dll"                    -Label "VALKEA $VALKEA_VERSION"                           -ValheimDir $valheimDir -TmpDir $tmpDir

    Write-Summary -ValheimDir $valheimDir -BackupDir $backupDir
} finally {
    Remove-Item -Path $tmpDir -Recurse -Force -ErrorAction SilentlyContinue
}
