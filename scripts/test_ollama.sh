#!/usr/bin/env bash
# scripts/test_ollama.sh
# Simple helper to POST a chat completion to local Ollama HTTP API
# Usage:
#   ./scripts/test_ollama.sh "Halo"            # send a short user message
#   ./scripts/test_ollama.sh -m model_name "Halo"
#   ./scripts/test_ollama.sh -f payload.json     # use payload file
#   ./scripts/test_ollama.sh -v                  # verbose curl output

set -euo pipefail

MODEL="llama3:8b-instruct-q4_0"
VERBOSE=0
PAYLOAD_FILE=""
USER_MSG="Halo dari test script"

while getopts ":m:vf:" opt; do
  case ${opt} in
    m ) MODEL="$OPTARG" ;;
    v ) VERBOSE=1 ;;
    f ) PAYLOAD_FILE="$OPTARG" ;;
    \? ) echo "Usage: $0 [-m model] [-v] [-f payload.json] [message]"; exit 1 ;;
  esac
done
shift $((OPTIND -1))

if [ "$#" -ge 1 ]; then
  USER_MSG="$*"
fi

if [ -n "$PAYLOAD_FILE" ]; then
  DATA_ARG=("-d" "@${PAYLOAD_FILE}")
else
  PAYLOAD=$(cat <<EOF
{
  "model": "${MODEL}",
  "messages": [
    { "role": "system", "content": "Kamu adalah agen lokal. Jawab singkat, jelas, sopan. Jika perlu langkah, beri bullet. Bahasa Indonesia." },
    { "role": "user",   "content": "${USER_MSG}" }
  ],
  "temperature": 0.2
}
EOF
)
  DATA_ARG=("-d" "$PAYLOAD")
fi

# Allow overriding the full URL with OLLAMA_URL, otherwise default to localhost
URL="${OLLAMA_URL:-http://localhost:11434/v1/chat/completions}"

if [ "$VERBOSE" -eq 1 ]; then
  curl -v -X POST "$URL" -H 'Content-Type: application/json' "${DATA_ARG[@]}"
else
  # Try to pretty-print JSON output if jq is installed
  if command -v jq >/dev/null 2>&1; then
    curl -sS -X POST "$URL" -H 'Content-Type: application/json' "${DATA_ARG[@]}" | jq .
  else
    curl -sS -X POST "$URL" -H 'Content-Type: application/json' "${DATA_ARG[@]}"
  fi
fi
