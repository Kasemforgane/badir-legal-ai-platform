# Troubleshooting Guide — Badir Legal AI Platform

All fixes in this document are **verified and tested** on the production server.
Do not attempt unverified solutions — follow these exactly.

---

## 🔴 Critical Issues

### 1. Backend crashes immediately after PM2 start

**Symptom:** `pm2 list` shows `badir-backend` in `errored` state. Logs show `ERR_INVALID_ARG_TYPE` related to SESSION_SECRET.

**Root Cause:** PM2 started from wrong working directory — Express couldn't find `.env`.

**Verified Fix:**
```bash
# Stop everything
pm2 delete all

# Go to the exact backend directory
cd /home/YOUR_USER/badir-legal-ai/backend

# Re-register PM2 from correct directory
pm2 start ecosystem.config.js --env production
pm2 save
pm2 startup
```

---

### 2. JSONB error when saving conversation history

**Symptom:** `POST /api/legal/complete` returns 500. PostgreSQL logs show invalid JSONB input.

**Root Cause:** `sources` array was being inserted as a JavaScript object, not a JSON string.

**Verified Fix** (in `routes/legal.js`):
```javascript
// ✅ CORRECT — wrap sources with JSON.stringify()
await pool.query(
  'INSERT INTO auth.conversations (user_id, question, answer, sources) VALUES ($1, $2, $3, $4)',
  [userId, question, answer, JSON.stringify(sources)]
);

// ❌ WRONG — do not pass sources directly
// VALUES ($1, $2, $3, $4) with sources as array object
```

---

### 3. n8n workflow can't connect to Qdrant or Ollama

**Symptom:** n8n HTTP Request nodes return `ECONNREFUSED` when using `localhost`.

**Root Cause:** n8n runs inside a Docker container. `localhost` refers to the n8n container itself, not the host.

**Verified Fix:** Always use Docker container names inside n8n:
```
# ✅ CORRECT
http://qdrant:6333
http://ollama:11434

# ❌ WRONG
http://localhost:6333
http://localhost:11434
http://127.0.0.1:6333
```

---

### 4. n8n Code node — fetch() vs $http.request

**Symptom:** Code node throws `$http.request is not a function` or similar.

**Root Cause:** `$http.request` is not available inside n8n Code nodes.

**Verified Fix:** Use the native `fetch()` API in all Code nodes:
```javascript
// ✅ CORRECT
const response = await fetch('http://qdrant:6333/collections/account_legal_docs/points/search', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify({ vector: embedding, limit: 5 })
});
const data = await response.json();

// ❌ WRONG
const data = await $http.request({ ... });
```

---

### 5. Ollama timeout or server crash under load

**Symptom:** Ollama returns 504 or the server becomes unresponsive after several queries.

**Root Cause:** Context window or thread count set too high for the 3-vCPU/4GB server.

**Verified Fix:** Cap Ollama parameters in n8n Ollama nodes:
```json
{
  "num_ctx": 2048,
  "num_thread": 3
}
```
Do not set `num_ctx` above 2048 on this server configuration.

---

### 6. RAG returns answers with no sources / wrong sources

**Symptom:** AI answers reference documents that don't exist, or source list is empty.

**Root Cause:** Build Context node was reading wrong property from Qdrant response.

**Verified Fix:** The Build Context node must read `item.payload.text` (not `item.text`) from Qdrant results:
```javascript
// ✅ CORRECT — read from payload
const context = results.map(item => item.payload.text).join('\n\n');

// ❌ WRONG
const context = results.map(item => item.text).join('\n\n');
```

---

### 7. Frontend changes not reflecting after edit

**Symptom:** UI shows old version after code changes.

**Root Cause:** Next.js requires a production build for changes to take effect.

**Verified Fix:**
```bash
cd /home/YOUR_USER/badir-legal-ai/frontend
npm run build
pm2 restart badir-frontend
pm2 save
```

---

### 8. Nextcloud — trusted domain error

**Symptom:** Nextcloud shows "Access through untrusted domain" error.

**Verified Fix:**
```bash
docker exec -it nextcloud bash
nano /var/www/html/config/config.php

# Add your server IP to trusted_domains array:
# 'trusted_domains' => ['localhost', '192.168.1.24', 'your-domain.com']

# Also fix overwrite.cli.url if needed:
# 'overwrite.cli.url' => 'http://192.168.1.24:8080'
```

---

## 🟡 Common Warnings

### Score threshold too low / too high

- Too low (< 0.5): Returns irrelevant documents, AI hallucinates
- Too high (> 0.80): Returns no results for valid questions
- **Production setting: 0.62** — tested and tuned for `account_legal_docs` collection

### n8n webhook URL format

The n8n webhook URL must be the **production webhook** (not the test webhook):
```
# ✅ Production
http://localhost:5678/webhook/YOUR_WEBHOOK_ID

# ❌ Test only — doesn't persist
http://localhost:5678/webhook-test/YOUR_WEBHOOK_ID
```

---

## 🔍 Diagnostic Commands

```bash
# Check all PM2 processes
pm2 list

# View backend logs
pm2 logs badir-backend --lines 50

# View frontend logs
pm2 logs badir-frontend --lines 50

# Check Docker containers
docker ps

# Check Qdrant collection
curl http://localhost:6333/collections/account_legal_docs

# Check Ollama models
docker exec -it ollama ollama list

# Test RAG endpoint directly
curl -X POST http://localhost:5678/webhook/YOUR_WEBHOOK_ID \
  -H "Content-Type: application/json" \
  -d '{
    "question": "ما هي سياسة الإجازات؟",
    "userId": "test",
    "role": "employee",
    "department": "hr",
    "language": "ar"
  }'

# Test backend health
curl http://localhost:3001/api/health
```
