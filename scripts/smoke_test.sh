#!/bin/bash
# Simple smoke test: POST a sample payload to the nodejs webhook, print body and HTTP code
set -euo pipefail

URL="http://localhost:3000/webhook/wa"
PAYLOAD='{"test":"ok"}'

echo "POSTing to $URL"
# Capture body + HTTP code (body followed by newline + code)
resp=$(curl -s -w $'\n%{http_code}' -X POST -H "Content-Type: application/json" -d "$PAYLOAD" "$URL")
http_code="${resp##*$'\n'}"
body="${resp%$'\n'*}"

# Pretty-print if jq exists
if command -v jq >/dev/null 2>&1; then
  echo "$body" | jq . || echo "$body"
else
  echo "$body"
fi

echo
echo "HTTP $http_code"

if [ "$http_code" -ne 200 ]; then
  echo "Smoke test failed"
  exit 1
fi

echo "Smoke test passed"
