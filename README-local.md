README — Menjalankan lokal (n8n + Ollama)

Tujuan singkat
- Jalankan n8n dan Ollama secara lokal lewat Docker Compose.
Import workflow n8n yang ada di folder `supports/n8n` (hanya dua file yang disarankan untuk di-import).
- Tes end-to-end: webhook → n8n → Ollama → kirim pesan via WhatsApp Graph API (atau relay).

3. Import workflow ke n8n
- Buka n8n Editor (http://localhost:5678).
- Import dua file JSON yang disediakan di folder `supports/n8n`:
	- `supports/n8n/WA Local Agent - Evolution API - messages upsert.json` (message upsert / sender flows)
	- `supports/n8n/WA Local Agent (Receiver).json` (receiver / incoming webhook flow)
- Aktifkan kedua file JSON yang ingin dipakai agar webhook terdaftar dan runtime aktif.
Langkah cepat
1. Jalankan layanan

```bash
# jalankan semua service
docker compose up -d
# lihat logs (opsional)
docker compose logs -f n8n
```

2. (Opsional) Instal model di Ollama jika belum ada
- Dari host: `ollama pull llama3:8b-instruct-q4_0` atau model lain yang Anda pilih.

3. Import workflow ke n8n
- Buka n8n Editor (http://localhost:5678).
- Import dua file JSON yang disediakan di folder `supports/n8n`:
	- `supports/n8n/WA Local Agent - Evolution API - messages upsert.json` (message upsert / sender flows)
	- `supports/n8n/WA Local Agent (Receiver).json` (receiver / incoming webhook flow)
- Aktifkan workflow yang ingin dipakai agar webhook terdaftar dan runtime aktif.

4. Konfigurasi environment / kredensial
- Jika ingin pakai Facebook Graph API, tetapkan `PHONE_NUMBER_ID` di environment n8n atau pada ekspresi node.
- Atur credential `WA Header Auth` di n8n (gunakan token dari Facebook/Meta).
- Jika perlu ubah model, set `OLLAMA_MODEL` di environment (contoh: `llama3:8b-instruct-q4_0`).

5. Tes
- Tes langsung ke Ollama:

```bash
./scripts/test_ollama.sh -v
```

- Tes end-to-end webhook (mengirim payload contoh ke workflow sender):

```bash
./scripts/webhook_test.sh
```

Catatan & debugging cepat
- Pastikan workflow "active" di n8n, karena webhook hanya terdaftar saat aktif.
- Jika n8n melaporkan "unknown webhook", refresh Editor dan aktifkan ulang workflow.
- Periksa node Function `Build Ollama Body` untuk melihat `bodyObject` yang dikirim ke Ollama ketika debugging.

Kontak
- Repo ini dibuat untuk development lokal. Jika butuh bantuan untuk melakukan import otomatis atau menjalankan tes end-to-end, beri tahu saya dan saya akan bantu menjalankannya.

pgAdmin servers.json (local setup)

If you want pgAdmin to auto-register a set of servers on startup, copy the included `servers-sample.json` into the `.pgadmin` folder as `servers.json`.

Steps:

1. Create the folder and copy the sample:

```bash
mkdir -p .pgadmin
cp servers-sample.json .pgadmin/servers.json
```

2. Prepare working directories and permissions (recommended)

Run the provided helper script to create the common runtime directories and set ownership/permissions in a safe, repeatable way:

```bash
./scripts/init_workdirs.sh
```

If you need to set ownership to a specific UID/GID used by container users (for example `999:999`), run:

```bash
./scripts/init_workdirs.sh --uid 999 --gid 999
```

Use `--force-777` only as a last-resort development fallback:

```bash
./scripts/init_workdirs.sh --force-777
```

3. Keep secrets out of the repo:

- Do NOT commit `.pgadmin/servers.json` if it contains credentials. If `servers.json` contains passwords, prefer removing them and use environment variables.
- Ensure `PGADMIN_DEFAULT_EMAIL` and `PGADMIN_DEFAULT_PASSWORD` are set in your `.env` (this is the default pgAdmin account used on first start).

4. Troubleshooting

- If pgAdmin fails to write the file or load the servers list, check container logs:

```bash
docker compose logs pgadmin
ls -la .pgadmin
```

That’s all — copying `servers-sample.json` to `.pgadmin/servers.json` will pre-register servers when pgAdmin starts.
