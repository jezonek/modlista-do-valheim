#!/bin/bash
set -euo pipefail

_CREDS="$(cd "$(dirname "$0")" && pwd)/../.creds.sh"
[ -f "$_CREDS" ] && source "$_CREDS"
FTP_HOST="${FTP_HOST:?FTP_HOST not set — copy .creds.sh.example to .creds.sh}"
FTP_PORT="${FTP_PORT:?FTP_PORT not set — copy .creds.sh.example to .creds.sh}"
FTP_USER="${FTP_USER:?FTP_USER not set — copy .creds.sh.example to .creds.sh}"
FTP_PASS="${FTP_PASS:?FTP_PASS not set — copy .creds.sh.example to .creds.sh}"
FTP_BASE="ftp://${FTP_HOST}:${FTP_PORT}"
NETRC_TMP="$(mktemp)"
chmod 600 "$NETRC_TMP"
printf 'machine %s login %s password %s\n' "$FTP_HOST" "$FTP_USER" "$FTP_PASS" > "$NETRC_TMP"
trap 'rm -f "$NETRC_TMP"' EXIT
BACKUP_DIR="$1"

ERRORS=0
FILES_DOWNLOADED=0
BYTES_DOWNLOADED=0

download_dir() {
    local remote_path="$1"
    local local_path="$2"

    mkdir -p "$local_path"

    local listing
    listing=$(curl -s --netrc-file "$NETRC_TMP" --connect-timeout 15 "${FTP_BASE}${remote_path}" 2>&1) || {
        echo "  [WARN] Failed to list: ${remote_path}"
        ERRORS=$((ERRORS + 1))
        return
    }

    while IFS= read -r line; do
        [ -z "$line" ] && continue

        local permissions size filename
        permissions=$(echo "$line" | awk '{print $1}')
        size=$(echo "$line" | awk '{print $5}')
        filename=$(echo "$line" | awk '{print $NF}')

        # Skip . and ..
        [[ "$filename" == "." || "$filename" == ".." ]] && continue

        if [[ "$permissions" == d* ]]; then
            echo "  DIR  ${remote_path}${filename}/"
            download_dir "${remote_path}${filename}/" "${local_path}/${filename}/"
        else
            local local_file="${local_path}/${filename}"
            printf "  FILE %-60s %s bytes\n" "${remote_path}${filename}" "$size"
            if curl -s --netrc-file "$NETRC_TMP" --connect-timeout 30 \
                    -o "$local_file" "${FTP_BASE}${remote_path}${filename}"; then
                FILES_DOWNLOADED=$((FILES_DOWNLOADED + 1))
                BYTES_DOWNLOADED=$((BYTES_DOWNLOADED + size))
            else
                echo "  [ERROR] Failed to download: ${remote_path}${filename}"
                ERRORS=$((ERRORS + 1))
            fi
        fi
    done <<< "$listing"
}

echo "=== Valheim Server Backup ==="
echo "Target: ${BACKUP_DIR}"
echo "Started: $(date)"
echo ""

download_dir "/" "${BACKUP_DIR}/"

echo ""
echo "=== Backup Complete ==="
echo "Files: ${FILES_DOWNLOADED}"
echo "Bytes: ${BYTES_DOWNLOADED}"
echo "Errors: ${ERRORS}"
echo "Finished: $(date)"

if [ "$ERRORS" -gt 0 ]; then
    echo "[WARN] ${ERRORS} errors occurred — check output above"
    exit 1
fi
