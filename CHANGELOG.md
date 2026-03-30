# Changelog — Badir Legal AI Platform

All notable changes to this project are documented here.

---

## [1.0.0] — 2025-Q1 — Initial Production Release

### 🎉 Core Platform
- Full self-hosted RAG pipeline with Qdrant + Ollama
- n8n workflow `Badir-Legal-RAG-Hybrid-v3` — stable production version
- Node.js/Express backend (port 3001) managed by PM2
- Next.js 16 frontend (port 3000) managed by PM2
- PostgreSQL 15 for auth, RBAC, and history
- Redis for session management

### 🧠 AI / RAG
- LLM: `qwen2.5:3b` via Ollama (on-premise, no cloud)
- Embeddings: `nomic-embed-text` via Ollama
- Qdrant collection `account_legal_docs` with 700+ indexed points
- Score threshold tuned to 0.62 for optimal relevance
- Language-aware response logic (Arabic / English / French)
- Source metadata preserved and surfaced to frontend
- Irrelevant source suppression on negative LLM responses

### 👥 Auth & RBAC
- Role-based access: admin / manager / supervisor / employee
- Department isolation: legal / hr / engineering
- Cross-department guidance for privileged roles
- JWT + session-based authentication

### 📱 Frontend
- Mobile-first responsive layout
- Hamburger menu with overlay drawer
- Sticky header with session info
- Conversation-style chat UI with follow-up buttons
- Source View / Download buttons per answer
- PDF text highlighting via `#:~:text=` URL fragments
- Conversation history with auto-save
- Full RTL support for Arabic
- i18n: Arabic, English, French

### 🏗️ Infrastructure
- Fully Dockerized (all services containerized)
- Cloudflare Zero Trust tunnel — domain: `dashboard.badir-it.online`
- Nextcloud document storage (port 8080)
- Bilingual documentation suite (14 DOCX files, AR + EN)

### 🔧 Verified Fixes Applied
- `ERR_INVALID_ARG_TYPE` on SESSION_SECRET — resolved by PM2 restart from correct working directory
- JSONB insert error in `/api/legal/complete` — resolved by `JSON.stringify()` on sources
- n8n internal networking — must use container names (`qdrant:6333`, `ollama:11434`)
- Ollama context window — capped at `num_ctx: 2048` for stability on 3-vCPU server
- n8n Code nodes — use `fetch()` not `$http.request` (not available in Code nodes)
- Qdrant score threshold — tuned from default to 0.62 after testing

---

## [Upcoming] — 1.1.0

- [ ] White-label Docker deployment template
- [ ] Automated server migration script
- [ ] Demo video + client presentation package
- [ ] Badir Chatbox embedded widget
- [ ] Dental clinic vertical
