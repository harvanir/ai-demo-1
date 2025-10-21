# Guidance for AI coding agents working on this repository

Summary (big picture)
- This repo runs two main services by design: n8n (workflow automation) and ollama (local LLM). They are run together via `docker-compose.yml` and coordinated as separate containers.
- n8n stores runtime state under `./.n8n` (settings, sqlite DB, keys). ollama uses `./.ollama` for models/keys.

How to run & common dev workflows
- Start both services (background): `docker compose up -d`
- Tail logs: `docker compose logs -f n8n` or `docker compose logs -f ollama`
- Run n8n interactively (like `docker run -it --rm ...` in `run.sh`):
  `docker compose run --rm --service-ports n8n`
- Restart only n8n after changes: `docker compose up -d --no-deps --build n8n`

Project-specific patterns and conventions
- Persistent data: `./.n8n` and `./.ollama` are bind-mounted into containers. Agents should prefer editing compose and README rather than removing mounts.
- Permissions: n8n enforces settings file permissions. See `N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS` in `docker-compose.yml`. Typical UID/GID for the image user is 1000:1000; the host folder should be owned by the same UID to avoid permission errors.
- Memory/OOM: avoid adding very small memory limits in `docker-compose.yml` for n8n (we removed `128m` limits). If you need limits, pick reasonable values (>=512m) or use host controls.
- Healthcheck: n8n contains a simple healthcheck (HTTP probe to 127.0.0.1:5678). Use `docker compose ps` and `docker inspect ... State.Health` to check status.

Important files to inspect (quick map)
- `run.sh` - original convenience script using `docker run` for both services.
- `docker-compose.yml` - canonical way to run services now. Primary place to change env, ports, volumes, and healthchecks.
- `README.md` - contains run & troubleshooting notes; update if workflows change.
- `./.n8n/*` - runtime data for n8n (config, sqlite database). Check ownership & permissions when debugging.
- `./.ollama/*` - runtime data and models for ollama.

Common issues & how an agent should fix them (concrete)
- "Permissions 0644 for n8n settings file": set `N8N_ENFORCE_SETTINGS_FILE_PERMISSIONS=true` in compose (already present) and ensure host `./.n8n` allows chmod/chown. Example fix on host:
  `sudo chown -R 1000:1000 .n8n && chmod -R 600 .n8n/config`
- Repeated "exited with code 137": usually SIGKILL / OOM. Remove overly low memory limits and restart container. Use `docker compose up -d --no-deps --build n8n` to apply.

What to change and what not to change
- Safe: update `docker-compose.yml`, `README.md`, or add small helper scripts. Adjust healthcheck, env vars, or volumes.
- Caution: don't delete `./.n8n` or `./.ollama` lightly — they hold state and models. If you must reset them, document the reset in `README.md`.

Examples (copyable)
- Tail logs:
  `docker compose logs --no-color --tail=200 n8n`
- Inspect permissions:
  `ls -la .n8n && stat .n8n/config`

If something is missing
- If you can't find a service definition or run command, check `run.sh` and `docker-compose.yml` first. Prefer compose when both exist.

When in doubt, provide these details in the PR/issue
- Steps to reproduce
- Exact commands run and their outputs (logs)
- Output of `ls -la .n8n` and `docker compose ps`

Keep this file concise. Update when you add new services, change volume layout, or change the n8n image/version.
