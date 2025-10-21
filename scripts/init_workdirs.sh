#!/usr/bin/env bash
set -euo pipefail

# scripts/init_workdirs.sh
# Create common runtime directories and set ownership/permissions for local development.
# Defaults to current user UID/GID. You may override with --uid/--gid or env TARGET_UID/TARGET_GID.

usage() {
  cat <<EOF
Usage: $0 [--uid UID] [--gid GID] [--force-777]

Creates these folders (if missing): .n8n, .ollama, .pgadmin, .pgadmin_data, .pgdata, .redis
Default ownership: current user (id -u/id -g) or TARGET_UID/TARGET_GID env vars.

Options:
  --uid UID        Set owner UID for created directories (overrides TARGET_UID)
  --gid GID        Set owner GID for created directories (overrides TARGET_GID)
  --force-777      Set permissions to 0777 for all created directories (dev fallback)
  --help           Show this help

Examples:
  # default: use current user
  ./scripts/init_workdirs.sh

  # set ownership to a specific UID:GID (for containers)
  ./scripts/init_workdirs.sh --uid 999 --gid 999

  # use environment variables
  TARGET_UID=999 TARGET_GID=999 ./scripts/init_workdirs.sh

EOF
}

TARGET_UID=${TARGET_UID:-}
TARGET_GID=${TARGET_GID:-}
FORCE_777=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --uid)
      shift; TARGET_UID="$1"; shift;;
    --gid)
      shift; TARGET_GID="$1"; shift;;
    --force-777)
      FORCE_777=1; shift;;
    --help)
      usage; exit 0;;
    *)
      echo "Unknown option: $1" >&2; usage; exit 2;;
  esac
done

# Use current user if not set
if [[ -z "$TARGET_UID" ]]; then
  TARGET_UID=$(id -u)
fi
if [[ -z "$TARGET_GID" ]]; then
  TARGET_GID=$(id -g)
fi

dirs=(.n8n .ollama .pgadmin .pgadmin_data .pgdata .redis)

echo "Creating runtime directories and setting ownership/permissions"
for d in "${dirs[@]}"; do
  if [[ ! -d "$d" ]]; then
    mkdir -p "$d"
    echo "  created $d"
  else
    echo "  exists  $d"
  fi
done

if [[ "$FORCE_777" -eq 1 ]]; then
  echo "Applying 0777 to all directories (dev fallback)"
  chmod -R 0777 "${dirs[@]}" || true
else
  echo "Chown to ${TARGET_UID}:${TARGET_GID} and set conservative perms"
  # try chown (may require sudo)
  if chown -R "${TARGET_UID}:${TARGET_GID}" "${dirs[@]}" 2>/dev/null; then
    echo "chown succeeded"
  else
    echo "chown failed (you may need sudo). Continuing with permission changes"
  fi

  # conservative permissions: owner rwx, group rwx for data dirs, tighter for app dirs
  chmod 0700 .n8n || true
  chmod 0700 .ollama || true
  chmod 0770 .pgadmin .pgadmin_data .pgdata .redis || true
fi

echo
echo "Resulting permissions:"
ls -ld .n8n .ollama .pgadmin .pgadmin_data .pgdata .redis || true

echo
echo "Done. If you used chown and it failed, re-run with sudo or set TARGET_UID/TARGET_GID to the desired container UID:GID."
