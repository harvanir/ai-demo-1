README — Menjalankan lokal (n8n + Ollama)

Tujuan singkat
- Jalankan n8n dan Ollama secara lokal lewat Docker Compose.
- Import workflow n8n yang ada di folder `supports/n8n`.
- Tes end-to-end: webhook → n8n → Ollama → kirim pesan via WhatsApp Graph API (atau relay).

Prasyarat
- Docker & Docker Compose terpasang.
- Port 11434 (Ollama) dan 5678 (n8n) tidak diblokir.
- Jika menggunakan Facebook Graph API, siapkan `PHONE_NUMBER_ID` dan token yang sesuai (credential `WA Header Auth` di n8n).

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
- Import file JSON: `supports/n8n/workflow.json` (utama) dan/atau `supports/n8n/workflow_sender.json`.
- Aktifkan workflow agar webhook terdaftar.

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
