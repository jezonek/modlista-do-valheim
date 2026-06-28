# Valheim Mods Project

## Project Notes

- Server: REDACTED_SERVER_IP (FTP port REDACTED_FTP_PORT). Credentials in `.creds`.
- Three install scripts must stay in sync: `server_install_mods.sh`, `install_valheim_mods.sh` (Linux/Deck), `install_valheim_mods.ps1` (Windows)
- vsFTPd blocks `.so` file uploads. Workaround: rename to `.dll` (Linux LD_PRELOAD ignores extension).
- Never install Valheim+ (incompatible with OdinArchitect/OdinCampsite).
- Always test new mods for Unity 6000.0.61f1 compatibility before adding.
- PS1 scripts must be ASCII-safe (no Unicode) for PowerShell 5.1 compatibility.
- `unzip` exits 1 on Windows-built zips in `set -e` scripts. Allow exit code <= 1.
