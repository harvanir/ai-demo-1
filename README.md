

# ai-demo-1

Minimal local demo wiring for n8n + Ollama. The repo includes helper workflows and a small node relay used to forward or emulate WhatsApp messages for testing.

## Quick start

1. Initialize working directories (recommended):

```bash
./scripts/init_workdirs.sh
```

2. Start services (background):

```bash
docker compose up -d
```

3. Run n8n interactively (one-off):

```bash
docker compose run --rm --service-ports n8n
```

4. Restart only n8n after changes:

```bash
docker compose up -d --no-deps --build n8n
```

## Services (default ports)

- n8n — http://localhost:5678 (workflow editor/runtime)
- ollama — http://localhost:11434 (LLM HTTP API)
- nodejs — http://localhost:3000 (WA relay, optional)
 - evolution-api — http://localhost:8080 (app service)
 - evolution-api-manager — http://localhost:8080/manager/login (manager dashboard)
 - pgAdmin — http://localhost:5050 -> container port 80 (pgAdmin web UI)
 - Postgres — container port 5432 (not published by default; accessible to services on the compose network)
 - Redis — container port 6379 (not published by default; used internally unless you publish it)

## Persistent data

- n8n runtime: `./.n8n`
- ollama runtime/models: `./.ollama`
- node service: `./nodejs`
 - pgAdmin data: `./.pgadmin` and `./.pgadmin_data`
 - Postgres data (bind mount): `./.pgdata` (or use a named volume in prod)
 - Redis data (if enabled): `./.redis`
 - Evolution app instances/data: `./.evolution_instances`

Note: Run `./scripts/init_workdirs.sh` to create these directories with sensible defaults for local development.

## Local pgAdmin setup

- To pre-register servers for pgAdmin, run:

```bash
./scripts/setup_pgadmin.sh
```

This copies `servers-sample.json` to `.pgadmin/servers.json` (safe, idempotent). Don't commit that file if it contains credentials — `.pgadmin/servers.json` is ignored by `.gitignore`.

## Running helper services

- Node helper service (build & start only):

```bash
docker compose up -d --no-deps --build nodejs
```

- View logs for the node helper:

```bash
docker compose logs -f nodejs
```

## Webhook testing (local)

- The main workflow exposes a webhook at path `wa/incoming`. When testing from the n8n editor the runtime webhook URL appears under `/webhook-test/<path>`.

The main workflow exposes a webhook at path `wa/incoming`. When testing from the n8n editor the runtime webhook URL appears under `/webhook-test/<path>`.

Importing n8n workflows

- Open the n8n Editor at http://localhost:5678.
- Import these two JSON files from `supports/n8n` (these are the canonical, actively maintained workflows):
  - `WA Local Agent - Evolution API - messages upsert.json` (sender / message upsert flows)
  - `WA Local Agent (Receiver).json` (receiver / incoming webhook flow)
- Activate the workflow(s) you want to use so webhooks register with the runtime. Make sure both workflows are active if you plan to test end-to-end flows.

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

## Troubleshooting

- See `.github/copilot-instructions.md` for repository-specific notes (permissions, OOM, healthchecks).

