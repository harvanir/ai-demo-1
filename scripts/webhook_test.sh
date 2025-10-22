#!/usr/bin/env bash
# Simple webhook tester for the canonical n8n workflows in `supports/n8n` (path: wa/incoming)
set -euo pipefail
BASE_URL="http://localhost:5678/webhook/wa/incoming"

echo "GET verification"
curl -sS -D - "${BASE_URL}?hub.mode=subscribe&hub.challenge=1234567890&hub.verify_token=VERIFY_TOKEN" | sed -n '1,20p'

echo -e "\nPOST sample payload"
curl -sS -D - -X POST "${BASE_URL}" \
  -H 'Content-Type: application/json' \
  -d '{"entry":[{"changes":[{"value":{"messages":[{"from":"6285691285642","text":{"body":"Halo dari test script"}}]}}]}]}' | sed -n '1,60p'
