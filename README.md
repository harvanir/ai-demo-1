
# ai-demo-1

Minimal local demo wiring for n8n + Ollama. The repo includes helper workflows and a small node relay used to forward or emulate WhatsApp messages for testing.

Services (default ports)
- n8n — http://localhost:5678 (workflow editor/runtime)
- ollama — http://localhost:11434 (LLM HTTP API)
- nodejs — http://localhost:3000 (WA relay, optional)

Quick start

1. Start services (background):

```bash
docker compose up -d
```

2. Run n8n interactively (one-off):

```bash
docker compose run --rm --service-ports n8n
```

3. Restart only n8n after changes:

```bash
docker compose up -d --no-deps --build n8n
```

Persistent data
- n8n runtime: `./.n8n`
- ollama runtime/models: `./.ollama`
- node service: `./nodejs`

Node helper service
- Build & start only the node helper (after edits in `./nodejs`):

```bash
docker compose up -d --no-deps --build nodejs
```

View logs for the node helper:

```bash
docker compose logs -f nodejs
```

Troubleshooting
- See `.github/copilot-instructions.md` for common repository-specific troubleshooting notes (permissions, OOM, healthchecks).

Webhook testing (local)
- The main workflow exposes a webhook at path `wa/incoming`. When testing from the n8n editor the runtime webhook URL appears under `/webhook-test/<path>`.

Quick checks (from host):

```bash
# GET verification (simulate Facebook webhook verification)
curl -i "http://localhost:5678/webhook-test/wa/incoming?hub.mode=subscribe&hub.challenge=1234&hub.verify_token=VERIFY_TOKEN"

# POST sample payload (replace with your JSON sample)
curl -i -X POST "http://localhost:5678/webhook-test/wa/incoming" \
  -H 'Content-Type: application/json' \
  -d '{"entry":[{"changes":[{"value":{"messages":[{"from":"12345","text":{"body":"Halo"}}]}}]}]}'
```

If you need the end-to-end script, see `scripts/webhook_test.sh` and `scripts/test_ollama.sh`.

