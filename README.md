<div align="center">

<img src="https://img.shields.io/badge/Badir%20IT%20Solutions-Legal%20AI%20Platform-1a1a2e?style=for-the-badge&logo=scales&logoColor=white" alt="Badir Legal AI" />

# ⚖️ Badir Legal AI Platform

**منصة الذكاء الاصطناعي القانونية — بادر للاتصالات وتقنية المعلومات**

A fully self-hosted, on-premise AI platform for intelligent document retrieval across Legal, HR, and Engineering departments — built for enterprise clients who demand data privacy, multilingual support, and role-based access control.

[![License](https://img.shields.io/badge/License-Proprietary-red?style=flat-square)](LICENSE)
[![Stack](https://img.shields.io/badge/Stack-Node.js%20%7C%20Next.js%20%7C%20Ollama%20%7C%20Qdrant-blue?style=flat-square)]()
[![Languages](https://img.shields.io/badge/Languages-Arabic%20%7C%20English%20%7C%20French-green?style=flat-square)]()
[![Deployment](https://img.shields.io/badge/Deployment-Docker%20%7C%20Self--Hosted-orange?style=flat-square)]()

</div>

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Key Features](#-key-features)
- [Architecture](#-architecture)
- [Tech Stack](#-tech-stack)
- [Repository Structure](#-repository-structure)
- [Quick Start](#-quick-start)
- [Environment Variables](#-environment-variables)
- [API Reference](#-api-reference)
- [Role-Based Access](#-role-based-access)
- [Deployment](#-deployment)
- [Contributing](#-contributing)
- [License](#-license)

---

## 🔍 Overview

The **Badir Legal AI Platform** is a production-grade, fully on-premise Retrieval-Augmented Generation (RAG) system designed for enterprise use. It enables employees to query internal legal documents, HR policies, and engineering references using natural language — in Arabic, English, or French — with answers grounded exclusively in the organization's own knowledge base.

**No cloud. No data leakage. Total control.**

> Built and maintained by **Badir IT Solutions** (بادر المتميزة للاتصالات وتقنية المعلومات), Tripoli, Libya.

---

## ✨ Key Features

| Feature | Description |
|---|---|
| 🧠 **On-Premise RAG** | All AI processing runs locally — zero external API calls |
| 🌍 **Multilingual** | Full support for Arabic (RTL), English, and French |
| 🔐 **Role-Based Access** | Admin / Manager / Supervisor / Employee tiers with department isolation |
| 📄 **Source Highlighting** | Answers link directly to PDF pages with text highlighting |
| 📱 **Mobile-First UI** | Responsive design with hamburger menu and overlay drawer |
| 🏢 **Cross-Department** | Unified platform for Legal, HR, and Engineering documents |
| 🔄 **Conversation History** | Full session persistence with auto-save |
| 🐳 **Fully Dockerized** | One-command deployment for new clients |

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────┐
│                   Client Browser                     │
│              (Mobile / Desktop)                      │
└──────────────────────┬──────────────────────────────┘
                       │ HTTPS (Cloudflare Zero Trust)
┌──────────────────────▼──────────────────────────────┐
│            Next.js 16 Frontend  :3000                │
│     (React / Tailwind / RTL / i18n)                  │
└──────────────────────┬──────────────────────────────┘
                       │ REST API
┌──────────────────────▼──────────────────────────────┐
│          Node.js / Express Backend  :3001            │
│        (Auth / RBAC / Session / History)             │
└──────────┬───────────────────────┬──────────────────┘
           │                       │
┌──────────▼───────┐   ┌───────────▼──────────────────┐
│   PostgreSQL 15  │   │      n8n RAG Workflow         │
│  (Auth / Users / │   │  Badir-Legal-RAG-Hybrid-v3   │
│   History / RBAC)│   └──────────┬───────────────────┘
└──────────────────┘              │
                      ┌───────────┴──────────────────┐
                      │                              │
           ┌──────────▼──────┐          ┌────────────▼──────┐
           │   Qdrant  :6333 │          │  Ollama  :11434   │
           │ (Vector Store)  │          │  qwen2.5:3b (LLM) │
           │ 700+ doc points │          │  nomic-embed-text  │
           └─────────────────┘          └───────────────────┘
                                                  │
                                       ┌──────────▼──────────┐
                                       │   Nextcloud  :8080   │
                                       │ (Document Storage)   │
                                       └─────────────────────┘
```

---

## 🛠️ Tech Stack

### AI / RAG Layer
| Component | Technology | Purpose |
|---|---|---|
| LLM | `qwen2.5:3b` via Ollama | Local language model |
| Embeddings | `nomic-embed-text` via Ollama | Document vectorization |
| Vector DB | Qdrant | Semantic search & retrieval |
| Workflow | n8n (`Badir-Legal-RAG-Hybrid-v3`) | RAG orchestration |

### Application Layer
| Component | Technology | Details |
|---|---|---|
| Frontend | Next.js 16 + React | Port 3000, PM2 managed |
| Backend | Node.js + Express | Port 3001, PM2 managed |
| Database | PostgreSQL 15 | Auth, RBAC, history |
| Cache | Redis | Session management |
| Storage | Nextcloud | Document management |

### Infrastructure
| Component | Technology | Details |
|---|---|---|
| Containerization | Docker + Compose | All services containerized |
| Process Manager | PM2 | Frontend & backend lifecycle |
| Tunnel | Cloudflare Zero Trust | Secure public access |
| Domain | `dashboard.badir-it.online` | Production endpoint |

---

## 📁 Repository Structure

```
badir-legal-ai/
│
├── 📄 README.md                    # This file
├── 📄 .gitignore                   # Git ignore rules
├── 📄 .env.example                 # Environment template (no secrets)
├── 📄 docker-compose.yml           # Full service orchestration
├── 📄 DEPLOYMENT.md                # Step-by-step deployment guide
├── 📄 CHANGELOG.md                 # Version history
│
├── 🗂️ backend/                     # Node.js / Express API server
│   ├── src/
│   │   ├── routes/
│   │   │   ├── auth.js             # Login, register, change-password
│   │   │   ├── legal.js            # RAG query, history, download
│   │   │   └── admin.js            # User management
│   │   ├── middleware/
│   │   │   ├── auth.middleware.js  # JWT verification
│   │   │   └── rbac.middleware.js  # Role-based access control
│   │   └── index.js                # Express app entry point
│   ├── package.json
│   └── ecosystem.config.js         # PM2 configuration
│
├── 🗂️ frontend/                    # Next.js 16 application
│   ├── app/
│   │   ├── (auth)/                 # Login / register pages
│   │   ├── (protected)/            # Authenticated routes
│   │   │   ├── layout.tsx          # Mobile-responsive shell
│   │   │   ├── dashboard/          # Main chat interface
│   │   │   └── history/            # Conversation history
│   │   └── api/                    # Next.js API routes
│   ├── components/
│   │   ├── ui/                     # Shared UI components
│   │   └── chat/                   # Chat-specific components
│   ├── public/
│   │   └── locales/                # i18n translation files (AR/EN/FR)
│   ├── package.json
│   └── next.config.js
│
├── 🗂️ scripts/                     # Operational utilities
│   ├── bulk_ingest.py              # Document indexing pipeline
│   ├── setup.sh                    # Fresh server setup script
│   └── backup.sh                   # Database + vector backup
│
├── 🗂️ n8n/
│   └── workflows/
│       └── Badir-Legal-RAG-Hybrid-v3.json   # n8n RAG workflow export
│
├── 🗂️ nginx/
│   └── nginx.conf                  # Reverse proxy config (optional)
│
└── 🗂️ docs/
    ├── architecture.md             # Deep-dive system architecture
    ├── api-reference.md            # All API endpoints documented
    ├── rbac-model.md               # Role & permission matrix
    ├── ingestion-guide.md          # How to add/update documents
    └── troubleshooting.md          # Common issues & verified fixes
```

---

## 🚀 Quick Start

### Prerequisites

- Docker & Docker Compose installed
- Node.js 18+ (for frontend/backend)
- PM2 (`npm install -g pm2`)
- 4GB+ RAM, 3+ CPU cores recommended

### 1. Clone the Repository

```bash
git clone https://github.com/badir-it/badir-legal-ai.git
cd badir-legal-ai
```

### 2. Configure Environment

```bash
cp .env.example .env
# Edit .env with your values — see Environment Variables section
nano .env
```

### 3. Start Infrastructure Services

```bash
docker compose up -d
```

This starts: PostgreSQL, Redis, Qdrant, Ollama, n8n, Nextcloud.

### 4. Pull AI Models

```bash
docker exec -it ollama ollama pull qwen2.5:3b
docker exec -it ollama ollama pull nomic-embed-text
```

### 5. Initialize Database

```bash
cd backend
npm install
npm run db:init
```

### 6. Start Application

```bash
# Backend
cd backend && pm2 start ecosystem.config.js

# Frontend
cd frontend && npm install && npm run build
pm2 start ecosystem.config.js

pm2 save
pm2 startup
```

### 7. Index Documents

```bash
cd scripts
pip install -r requirements.txt
python bulk_ingest.py --source /path/to/documents
```

### 8. Access the Platform

Open your browser at `http://YOUR_SERVER_IP:3000`

---

## 🔑 Environment Variables

Copy `.env.example` to `.env` and fill in the values:

```env
# Application
NODE_ENV=production
PORT=3001
FRONTEND_URL=http://localhost:3000

# Security — generate strong random strings
SESSION_SECRET=change_this_to_a_long_random_string
JWT_SECRET=change_this_to_another_long_random_string

# Database
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_DB=legal_dashboard
POSTGRES_USER=legal_user
POSTGRES_PASSWORD=your_secure_password

# Redis
REDIS_URL=redis://localhost:6379

# AI Services (Docker internal)
OLLAMA_URL=http://ollama:11434
QDRANT_URL=http://qdrant:6333
N8N_WEBHOOK_URL=http://localhost:5678/webhook/YOUR_WEBHOOK_ID

# Nextcloud
NEXTCLOUD_URL=http://localhost:8080
NEXTCLOUD_USER=admin
NEXTCLOUD_PASSWORD=your_nextcloud_password
```

> ⚠️ **Never commit `.env` to version control.** Only `.env.example` (with no real values) should be in the repo.

---

## 📡 API Reference

### Authentication

| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/api/auth/login` | Login with email + password |
| `POST` | `/api/auth/logout` | End session |
| `POST` | `/api/auth/change-password` | Update user password |

### Legal AI

| Method | Endpoint | Description |
|---|---|---|
| `POST` | `/api/legal/query` | Submit a question to the RAG pipeline |
| `POST` | `/api/legal/complete` | Save completed Q&A to history |
| `GET` | `/api/legal/history` | Retrieve user conversation history |
| `GET` | `/api/legal/download?file=X` | Stream PDF for inline viewing |

### Admin

| Method | Endpoint | Description |
|---|---|---|
| `GET` | `/api/admin/users` | List all users |
| `POST` | `/api/admin/users` | Create new user |
| `PUT` | `/api/admin/users/:id` | Update user role/department |
| `DELETE` | `/api/admin/users/:id` | Remove user |

---

## 🔐 Role-Based Access

```
┌──────────────┬──────────────────────────────────────────────────┐
│ Role         │ Permissions                                      │
├──────────────┼──────────────────────────────────────────────────┤
│ admin        │ Full access — all departments + user management  │
│ manager      │ Full document access — own department + cross    │
│ supervisor   │ Extended access — can view cross-dept summaries  │
│ employee     │ Own department only — standard queries           │
└──────────────┴──────────────────────────────────────────────────┘

Departments: legal | hr | engineering
```

Roles are assigned at user creation and control:
- Which documents appear in RAG results
- Level of detail in AI responses
- Access to admin interface

---

## 🐳 Deployment

See **[DEPLOYMENT.md](DEPLOYMENT.md)** for the full production deployment guide including:

- Fresh server setup
- Cloudflare Zero Trust tunnel configuration
- SSL/TLS setup
- PM2 process management
- Backup & restore procedures
- White-label client deployment

---

## 🗺️ Roadmap

- [ ] White-label Docker template for new clients
- [ ] Server migration automation script
- [ ] Advanced analytics dashboard
- [ ] Badir Chatbox integration (embedded widget)
- [ ] Dental clinic vertical (scheduling + AI)
- [ ] Document versioning & audit trail

---

## 🤝 Contributing

This is a proprietary project maintained by Badir IT Solutions. Internal contribution guidelines are in [CONTRIBUTING.md](CONTRIBUTING.md).

---

## 📞 Contact

**Badir IT Solutions**
بادر المتميزة للاتصالات وتقنية المعلومات
📍 Tripoli, Libya
🌐 [badir-it.online](https://badir-it.online)

---

## 📜 License

**Proprietary & Confidential**

This software is the intellectual property of Badir IT Solutions. Unauthorized copying, distribution, or modification is strictly prohibited.

© 2025 Badir IT Solutions. All rights reserved.

---

<div align="center">
  <sub>Built with ❤️ by the Badir IT Solutions engineering team</sub>
</div>
