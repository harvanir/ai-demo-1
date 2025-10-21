#!/usr/bin/env bash
set -euo pipefail

# scripts/setup_pgadmin.sh
# Idempotent helper to copy servers-sample.json -> .pgadmin/servers.json
# and set safe permissions. Does not commit anything.

usage(){
  cat <<EOF
Usage: $0 [--force] [--uid UID] [--gid GID]

Options:
  --force       Overwrite existing .pgadmin/servers.json if present
  --uid UID     Owner UID for the target file (optional)
  --gid GID     Owner GID for the target file (optional)
  --help        Show this help

This script will:
 - create .pgadmin/ if missing
 - copy servers-sample.json to .pgadmin/servers.json (unless exists)
 - set conservative permissions (owner rw, group rx)
 - optionally chown to UID:GID if provided

EOF
}

FORCE=0
TARGET_UID=
TARGET_GID=

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force) FORCE=1; shift;;
    --uid) shift; TARGET_UID="$1"; shift;;
    --gid) shift; TARGET_GID="$1"; shift;;
    --help) usage; exit 0;;
    *) echo "Unknown option: $1"; usage; exit 2;;
  esac
done

SAMPLE=servers-sample.json
TARGET_DIR=.pgadmin
TARGET_FILE="$TARGET_DIR/servers.json"

if [[ ! -f "$SAMPLE" ]]; then
  echo "Error: $SAMPLE not found in repo root." >&2
  exit 1
fi

mkdir -p "$TARGET_DIR"

if [[ -f "$TARGET_FILE" ]] && [[ "$FORCE" -ne 1 ]]; then
  echo "$TARGET_FILE already exists. Use --force to overwrite."
  exit 0
fi

cp "$SAMPLE" "$TARGET_FILE"
echo "Copied $SAMPLE -> $TARGET_FILE"

# set permissions: owner read/write, group read, others none
chmod 0640 "$TARGET_FILE" || true

if [[ -n "$TARGET_UID" || -n "$TARGET_GID" ]]; then
  # default missing values to current uid/gid
  if [[ -z "$TARGET_UID" ]]; then TARGET_UID=$(id -u); fi
  if [[ -z "$TARGET_GID" ]]; then TARGET_GID=$(id -g); fi
  if chown "$TARGET_UID:$TARGET_GID" "$TARGET_FILE" 2>/dev/null; then
    echo "Chown applied to $TARGET_FILE -> $TARGET_UID:$TARGET_GID"
  else
    echo "Warning: chown failed (you may need sudo)" >&2
  fi
fi

echo "Wrote $TARGET_FILE (permissions: $(stat -c '%A %u:%g' "$TARGET_FILE"))"

echo "Note: Do not commit .pgadmin/servers.json if it contains credentials."
