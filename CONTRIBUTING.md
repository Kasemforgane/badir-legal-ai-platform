# Contributing — Badir Legal AI Platform

Internal engineering guidelines for the Badir IT Solutions development team.

---

## 🔒 Core Rules (Non-Negotiable)

1. **Verified solutions only** — No random experiments on production. Test with `curl` before applying to n8n or any live service.
2. **No breaking changes** to working features — always check impact before modifying shared code.
3. **Complete code blocks** — Never submit partial snippets. Every code submission must be complete and runnable.
4. **Label everything** — Every code block must clearly state which file/node/service it belongs to.
5. **Document before implement** — Architecture decisions must be documented before code is written.
6. **Never commit credentials** — `.env` is gitignored. Keep it that way.

---

## 🌿 Branch Strategy

```
main          → Production-ready code only
develop       → Integration branch for new features
feature/*     → Individual features (e.g., feature/white-label-template)
fix/*         → Bug fixes (e.g., fix/qdrant-score-threshold)
docs/*        → Documentation updates only
```

---

## 📝 Commit Message Format

```
type(scope): short description

Types: feat | fix | docs | refactor | test | chore
Scope: backend | frontend | n8n | docker | scripts | docs

Examples:
feat(backend): add change-password endpoint to auth.js
fix(n8n): correct Build Context node to read Qdrant results
docs(deployment): add Cloudflare Zero Trust setup steps
```

---

## 🧪 Before Merging to Main

- [ ] All PM2 processes running without errors: `pm2 list`
- [ ] Backend health check passes: `curl localhost:3001/api/health`
- [ ] RAG pipeline returns valid response via curl
- [ ] Frontend builds without errors: `npm run build`
- [ ] No credentials in any committed file
- [ ] `.env.example` updated if new variables added
- [ ] CHANGELOG.md entry added

---

## 🗺️ Key Technical Constraints

| Constraint | Value | Reason |
|---|---|---|
| Ollama `num_ctx` | Max 2048 | 3-vCPU server RAM limit |
| Ollama `num_thread` | Max 3 | Server CPU constraint |
| n8n networking | Container names only | n8n runs inside Docker |
| n8n Code nodes | Use `fetch()` | `$http.request` unavailable |
| Qdrant score threshold | ~0.62 | Tuned for this collection |
| Frontend changes | Require rebuild | `npm run build && pm2 restart` |

---

## 📞 Engineering Contact

Lead Engineer: Systems & AI Platform Team
Organization: Badir IT Solutions, Tripoli, Libya
