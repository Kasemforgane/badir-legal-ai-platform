#  Deployment Guide — Badir Legal AI Platform

This guide covers production deployment on a fresh Ubuntu server.

---

## Prerequisites

| Requirement | Minimum | Recommended |
|---|---|---|
| OS | Ubuntu 22.04 LTS | Ubuntu 22.04 LTS |
| RAM | 4 GB | 8 GB |
| CPU | 3 cores | 4+ cores |
| Disk | 40 GB | 100 GB SSD |
| Docker | 24.x | Latest |
| Node.js | 18.x | 20.x LTS |

---

## Step 1 — Server Setup

```bash
# Update system
sudo apt update && sudo apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
newgrp docker

# Install Node.js 20
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Install PM2
npm install -g pm2

# Install Python (for ingestion script)
sudo apt install -y python3 python3-pip tesseract-ocr tesseract-ocr-ara
```

---

## Step 2 — Clone & Configure

```bash
git clone https://github.com/badir-it/badir-legal-ai.git
cd badir-legal-ai

# Set up environment
cp .env.example .env
nano .env   # Fill in all values
```

---

## Step 3 — Start Docker Services

```bash
docker compose up -d

# Verify all containers running
docker ps
```

Expected containers:
- `postgres` (or `legal_dashboard_postgres`)
- `redis`
- `qdrant`
- `ollama`
- `n8n`
- `nextcloud`

---

## Step 4 — Pull AI Models

```bash
# This may take 5–15 minutes on first run
docker exec -it ollama ollama pull qwen2.5:3b
docker exec -it ollama ollama pull nomic-embed-text

# Verify models loaded
docker exec -it ollama ollama list
```

---

## Step 5 — Database Initialization

```bash
cd backend
npm install
npm run db:init
# Creates schema, tables, and default admin user
```

---

## Step 6 — Import n8n Workflow

1. Open n8n at `http://YOUR_SERVER_IP:5678`
2. Go to **Workflows → Import**
3. Select `n8n/workflows/Badir-Legal-RAG-Hybrid-v3.json`
4. Activate the workflow
5. Copy the webhook URL and update `N8N_WEBHOOK_URL` in `.env`

---

## Step 7 — Start Application Services

```bash
# Backend
cd backend
pm2 start ecosystem.config.js --env production
pm2 save

# Frontend
cd ../frontend
npm install
npm run build
pm2 start ecosystem.config.js --env production
pm2 save

# Register PM2 startup
pm2 startup
# Run the command it outputs (with sudo)
```

---

## Step 8 — Index Documents

```bash
cd scripts
pip3 install -r requirements.txt

# Place your PDF/DOCX files in a folder, then:
python3 bulk_ingest.py --source /path/to/your/documents

# Verify indexing
# Check Qdrant points count at: http://localhost:6333/collections/account_legal_docs
```

---

## Step 9 — Cloudflare Zero Trust (Production)

1. Install `cloudflared`:
   ```bash
   curl -L --output cloudflared.deb \
     https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64.deb
   sudo dpkg -i cloudflared.deb
   ```

2. Login and create tunnel:
   ```bash
   cloudflared tunnel login
   cloudflared tunnel create badir-legal-ai
   ```

3. Configure routes pointing to `localhost:3000`

4. Run as service:
   ```bash
   sudo cloudflared service install
   sudo systemctl start cloudflared
   ```

---

## Verify Installation

```bash
# Check all PM2 processes
pm2 list

# Test backend health
curl http://localhost:3001/api/health

# Test frontend
curl -I http://localhost:3000

# Test RAG pipeline
curl -X POST http://localhost:5678/webhook/YOUR_WEBHOOK_ID \
  -H "Content-Type: application/json" \
  -d '{"question":"ما هي سياسة الإجازات؟","userId":"test","role":"employee","department":"hr","language":"ar"}'
```

---

## Backup & Restore

```bash
# Backup
./scripts/backup.sh

# Restore
./scripts/restore.sh --date 2025-01-15
```

Backups include:
- PostgreSQL dump
- Qdrant collection snapshot
- Uploaded documents reference

---

## White-Label Deployment (New Client)

See the `white-label/` directory for the automated client deployment script.

```bash
cd white-label
./deploy-client.sh --client-name "ClientName" --server-ip "192.168.1.X"
```

---

## Troubleshooting

See [docs/troubleshooting.md](docs/troubleshooting.md) for verified fixes to common issues.

| Issue | Quick Fix |
|---|---|
| Backend crashes on start | Check SESSION_SECRET is set in correct working dir |
| n8n can't reach Qdrant | Use `qdrant:6333` not `localhost:6333` inside n8n |
| Ollama timeout | Reduce `num_ctx` to 2048, `num_thread` to 3 |
| PDF download fails | Verify `/api/legal/download` endpoint and Nextcloud path |
| JSONB error on save | Ensure sources are `JSON.stringify()`'d before insert |
