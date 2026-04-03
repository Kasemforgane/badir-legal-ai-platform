#!/bin/bash
# ============================================================
# Badir Legal AI Platform — White-Label Deployment Script
# Version: 1.0 — April 2026
# Author: Badir IT Solutions
# ============================================================
# Usage:
#   chmod +x deploy-client.sh
#   ./deploy-client.sh
# ============================================================

set -e

# ── Colors ────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# ── Banner ────────────────────────────────────────────────
clear
echo -e "${BLUE}"
echo "╔══════════════════════════════════════════════════════╗"
echo "║     BADIR LEGAL AI — White-Label Deployment          ║"
echo "║     بادر للاتصالات وتقنية المعلومات                   ║"
echo "╚══════════════════════════════════════════════════════╝"
echo -e "${NC}"

# ── Step 1: Collect Client Info ───────────────────────────
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  STEP 1 — Client Information${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

read -p "  Client name (e.g. lawfirm, hospital): " CLIENT_NAME
CLIENT_NAME=$(echo "$CLIENT_NAME" | tr '[:upper:]' '[:lower:]' | tr ' ' '-')

read -p "  Client display name (e.g. Al-Adala Law Firm): " CLIENT_DISPLAY
read -p "  Domain or subdomain (e.g. client.badir-it.online): " CLIENT_DOMAIN
read -p "  Primary color hex (e.g. 1E3A8A): " CLIENT_COLOR
read -p "  Logo URL (leave empty for default): " CLIENT_LOGO

# Deployment type
echo ""
echo "  Deployment type:"
echo "  [1] Our server (subdomain for client)"
echo "  [2] Client's server (export package)"
read -p "  Choose (1 or 2): " DEPLOY_TYPE

# Ports
FRONTEND_PORT=$((3000 + RANDOM % 1000 + 100))
BACKEND_PORT=$((3001 + RANDOM % 1000 + 100))

# If our server — use next available ports
if [ "$DEPLOY_TYPE" = "1" ]; then
  # Find next available port starting from 3100
  FRONTEND_PORT=3100
  while lsof -i :$FRONTEND_PORT &>/dev/null 2>&1; do
    FRONTEND_PORT=$((FRONTEND_PORT + 10))
  done
  BACKEND_PORT=$((FRONTEND_PORT + 1))
fi

echo ""
echo -e "${GREEN}  ✓ Client: ${CLIENT_DISPLAY}${NC}"
echo -e "${GREEN}  ✓ Slug:   ${CLIENT_NAME}${NC}"
echo -e "${GREEN}  ✓ Domain: ${CLIENT_DOMAIN}${NC}"
echo -e "${GREEN}  ✓ Ports:  Frontend ${FRONTEND_PORT} / Backend ${BACKEND_PORT}${NC}"
echo ""
read -p "  Confirm and continue? (y/n): " CONFIRM
[ "$CONFIRM" != "y" ] && echo "Aborted." && exit 0

# ── Step 2: Generate Secrets ──────────────────────────────
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  STEP 2 — Generating Secrets${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

SESSION_SECRET=$(openssl rand -hex 32)
N8N_SECRET=$(openssl rand -hex 32)
N8N_WORKFLOW_SECRET=$(openssl rand -hex 32)
DB_PASSWORD=$(openssl rand -hex 16)
DB_NAME="${CLIENT_NAME}_legal"
DB_USER="${CLIENT_NAME}_user"
NEXTCLOUD_USER="admin_${CLIENT_NAME}"
NEXTCLOUD_PASS=$(openssl rand -hex 12)

echo -e "${GREEN}  ✓ Secrets generated${NC}"

# ── Step 3: Create Directory Structure ────────────────────
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  STEP 3 — Creating Client Directory${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

CLIENT_DIR="$HOME/clients/${CLIENT_NAME}"
mkdir -p "$CLIENT_DIR"/{frontend,backend,nginx}

echo -e "${GREEN}  ✓ Directory: ${CLIENT_DIR}${NC}"

# ── Step 4: Clone and Customize Frontend ─────────────────
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  STEP 4 — Customizing Frontend${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Copy frontend source
cp -r "$HOME/legal-dashboard-ui/." "$CLIENT_DIR/frontend/"
rm -rf "$CLIENT_DIR/frontend/node_modules"
rm -rf "$CLIENT_DIR/frontend/.next"

# Create frontend .env
cat > "$CLIENT_DIR/frontend/.env.local" << EOF
NEXT_PUBLIC_API_URL=http://localhost:${BACKEND_PORT}
NEXT_PUBLIC_SESSION_SECRET=${SESSION_SECRET}
NEXT_PUBLIC_CLIENT_NAME=${CLIENT_DISPLAY}
NEXT_PUBLIC_PRIMARY_COLOR=#${CLIENT_COLOR}
NEXT_PUBLIC_LOGO_URL=${CLIENT_LOGO}
NEXT_PUBLIC_DOMAIN=${CLIENT_DOMAIN}
EOF

# Replace branding in layout
LAYOUT_FILE="$CLIENT_DIR/frontend/app/layout.tsx"
if [ -f "$LAYOUT_FILE" ]; then
  sed -i "s/Badir IT – Legal AI Dashboard/${CLIENT_DISPLAY} – Legal AI/g" "$LAYOUT_FILE"
  sed -i "s/Enterprise Legal AI Platform/${CLIENT_DISPLAY} AI Platform/g" "$LAYOUT_FILE"
fi

# Replace color in tailwind config if exists
TAILWIND_FILE="$CLIENT_DIR/frontend/tailwind.config.js"
if [ -f "$TAILWIND_FILE" ]; then
  sed -i "s/1E3A8A/${CLIENT_COLOR}/g" "$TAILWIND_FILE"
fi

echo -e "${GREEN}  ✓ Frontend customized${NC}"

# ── Step 5: Clone and Customize Backend ──────────────────
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  STEP 5 — Customizing Backend${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

cp -r "$HOME/legal-dashboard-backend/." "$CLIENT_DIR/backend/"
rm -rf "$CLIENT_DIR/backend/node_modules"

# Create backend .env
cat > "$CLIENT_DIR/backend/.env" << EOF
PORT=${BACKEND_PORT}
DB_HOST=localhost
DB_PORT=5432
DB_NAME=${DB_NAME}
DB_USER=${DB_USER}
DB_PASSWORD=${DB_PASSWORD}
SESSION_SECRET=${SESSION_SECRET}
N8N_INTERNAL_SECRET=${N8N_SECRET}
N8N_WORKFLOW_SECRET=${N8N_WORKFLOW_SECRET}
NEXTCLOUD_URL=http://localhost:8080
NEXTCLOUD_USER=${NEXTCLOUD_USER}
NEXTCLOUD_PASS=${NEXTCLOUD_PASS}
NEXTCLOUD_BASE_PATH=/var/www/html/data/${NEXTCLOUD_USER}/files
CLIENT_NAME=${CLIENT_NAME}
CLIENT_DISPLAY=${CLIENT_DISPLAY}
EOF

echo -e "${GREEN}  ✓ Backend customized${NC}"

# ── Step 6: Create Docker Compose ────────────────────────
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  STEP 6 — Creating Docker Compose${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

cat > "$CLIENT_DIR/docker-compose.yml" << EOF
version: '3.8'

# ============================================================
# ${CLIENT_DISPLAY} — Legal AI Platform
# Generated by Badir IT Solutions — $(date +%Y-%m-%d)
# ============================================================

networks:
  ${CLIENT_NAME}_network:
    driver: bridge

volumes:
  ${CLIENT_NAME}_postgres_data:
  ${CLIENT_NAME}_qdrant_data:
  ${CLIENT_NAME}_ollama_data:
  ${CLIENT_NAME}_redis_data:
  ${CLIENT_NAME}_nextcloud_data:
  ${CLIENT_NAME}_n8n_data:

services:

  # ── Database ──────────────────────────────────────────
  ${CLIENT_NAME}_postgres:
    image: postgres:15
    container_name: ${CLIENT_NAME}_postgres
    restart: always
    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - ${CLIENT_NAME}_postgres_data:/var/lib/postgresql/data
    networks:
      - ${CLIENT_NAME}_network

  # ── Redis ─────────────────────────────────────────────
  ${CLIENT_NAME}_redis:
    image: redis:7
    container_name: ${CLIENT_NAME}_redis
    restart: always
    volumes:
      - ${CLIENT_NAME}_redis_data:/data
    networks:
      - ${CLIENT_NAME}_network

  # ── Qdrant ────────────────────────────────────────────
  ${CLIENT_NAME}_qdrant:
    image: qdrant/qdrant:latest
    container_name: ${CLIENT_NAME}_qdrant
    restart: always
    volumes:
      - ${CLIENT_NAME}_qdrant_data:/qdrant/storage
    networks:
      - ${CLIENT_NAME}_network

  # ── Ollama ────────────────────────────────────────────
  ${CLIENT_NAME}_ollama:
    image: ollama/ollama:latest
    container_name: ${CLIENT_NAME}_ollama
    restart: always
    volumes:
      - ${CLIENT_NAME}_ollama_data:/root/.ollama
    networks:
      - ${CLIENT_NAME}_network

  # ── n8n ───────────────────────────────────────────────
  ${CLIENT_NAME}_n8n:
    image: n8nio/n8n:latest
    container_name: ${CLIENT_NAME}_n8n
    restart: always
    environment:
      DB_TYPE: postgresdb
      DB_POSTGRESDB_HOST: ${CLIENT_NAME}_postgres
      DB_POSTGRESDB_DATABASE: ${DB_NAME}
      DB_POSTGRESDB_USER: ${DB_USER}
      DB_POSTGRESDB_PASSWORD: ${DB_PASSWORD}
      N8N_BASIC_AUTH_ACTIVE: "true"
      N8N_BASIC_AUTH_USER: admin
      N8N_BASIC_AUTH_PASSWORD: ${N8N_SECRET}
    volumes:
      - ${CLIENT_NAME}_n8n_data:/home/node/.n8n
    depends_on:
      - ${CLIENT_NAME}_postgres
    networks:
      - ${CLIENT_NAME}_network

  # ── Nextcloud ─────────────────────────────────────────
  ${CLIENT_NAME}_nextcloud:
    image: nextcloud:32-apache
    container_name: ${CLIENT_NAME}_nextcloud
    restart: always
    environment:
      NEXTCLOUD_ADMIN_USER: ${NEXTCLOUD_USER}
      NEXTCLOUD_ADMIN_PASSWORD: ${NEXTCLOUD_PASS}
    volumes:
      - ${CLIENT_NAME}_nextcloud_data:/var/www/html
    networks:
      - ${CLIENT_NAME}_network
EOF

echo -e "${GREEN}  ✓ Docker Compose created${NC}"

# ── Step 7: Create PM2 Ecosystem ─────────────────────────
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  STEP 7 — Creating PM2 Config${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

cat > "$CLIENT_DIR/ecosystem.config.js" << EOF
module.exports = {
  apps: [
    {
      name: '${CLIENT_NAME}-frontend',
      cwd: '${CLIENT_DIR}/frontend',
      script: 'node_modules/.bin/next',
      args: 'start -p ${FRONTEND_PORT}',
      env: { NODE_ENV: 'production' }
    },
    {
      name: '${CLIENT_NAME}-backend',
      cwd: '${CLIENT_DIR}/backend',
      script: 'src/server.js',
      env: { NODE_ENV: 'production' }
    }
  ]
};
EOF

echo -e "${GREEN}  ✓ PM2 config created${NC}"

# ── Step 8: Create Credentials File ──────────────────────
cat > "$CLIENT_DIR/CREDENTIALS.txt" << EOF
============================================================
${CLIENT_DISPLAY} — Legal AI Platform Credentials
Generated: $(date)
KEEP THIS FILE SECURE — DO NOT SHARE
============================================================

CLIENT NAME:     ${CLIENT_DISPLAY}
DOMAIN:          ${CLIENT_DOMAIN}
FRONTEND PORT:   ${FRONTEND_PORT}
BACKEND PORT:    ${BACKEND_PORT}

── Database ────────────────────────────────────────────────
DB_NAME:         ${DB_NAME}
DB_USER:         ${DB_USER}
DB_PASSWORD:     ${DB_PASSWORD}

── Nextcloud ───────────────────────────────────────────────
NEXTCLOUD_USER:  ${NEXTCLOUD_USER}
NEXTCLOUD_PASS:  ${NEXTCLOUD_PASS}

── Secrets ─────────────────────────────────────────────────
SESSION_SECRET:  ${SESSION_SECRET}
N8N_SECRET:      ${N8N_SECRET}

── PM2 Process Names ───────────────────────────────────────
Frontend:  ${CLIENT_NAME}-frontend
Backend:   ${CLIENT_NAME}-backend

============================================================
EOF
chmod 600 "$CLIENT_DIR/CREDENTIALS.txt"

# ── Step 9: Create install.sh ────────────────────────────
cat > "$CLIENT_DIR/install.sh" << 'INSTALLEOF'
#!/bin/bash
# Run this script on the NEW server to install the client platform

set -e
echo "Starting installation..."

# Docker services
docker compose up -d
echo "Waiting for services to start..."
sleep 30

# Pull AI models
docker exec $(docker ps -qf "name=ollama") ollama pull qwen2.5:3b
docker exec $(docker ps -qf "name=ollama") ollama pull nomic-embed-text

# Install dependencies
cd frontend && npm install && npm run build && cd ..
cd backend && npm install && cd ..

# Start PM2
pm2 start ecosystem.config.js
pm2 save

echo "✅ Installation complete!"
echo "Check CREDENTIALS.txt for login details."
INSTALLEOF
chmod +x "$CLIENT_DIR/install.sh"

# ── Step 10: If our server — start services ───────────────
if [ "$DEPLOY_TYPE" = "1" ]; then
  echo ""
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${CYAN}  STEP 8 — Starting Services (Our Server)${NC}"
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

  cd "$CLIENT_DIR"
  docker compose up -d

  echo "  Waiting 20 seconds for DB to initialize..."
  sleep 20

  # Install and build
  cd frontend && npm install && npm run build && cd ..
  cd backend && npm install && cd ..

  # Start PM2
  pm2 start "$CLIENT_DIR/ecosystem.config.js"
  pm2 save

  echo -e "${GREEN}  ✓ Services started${NC}"
fi

# ── Step 11: If client server — create package ────────────
if [ "$DEPLOY_TYPE" = "2" ]; then
  echo ""
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${CYAN}  STEP 8 — Creating Deployment Package${NC}"
  echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

  PACKAGE_NAME="${CLIENT_NAME}-legal-ai-$(date +%Y%m%d).tar.gz"
  tar -czf "$HOME/$PACKAGE_NAME" -C "$HOME/clients" "$CLIENT_NAME" \
    --exclude="${CLIENT_NAME}/frontend/node_modules" \
    --exclude="${CLIENT_NAME}/backend/node_modules" \
    --exclude="${CLIENT_NAME}/frontend/.next"

  echo -e "${GREEN}  ✓ Package created: ~/${PACKAGE_NAME}${NC}"
  echo -e "${YELLOW}  → Transfer to client server with:${NC}"
  echo -e "    scp ~/${PACKAGE_NAME} user@CLIENT_SERVER:~/"
  echo -e "    ssh user@CLIENT_SERVER 'tar -xzf ${PACKAGE_NAME} && cd ${CLIENT_NAME} && bash install.sh'"
fi

# ── Done ─────────────────────────────────────────────────
echo ""
echo -e "${GREEN}"
echo "╔══════════════════════════════════════════════════════╗"
echo "║              ✅ DEPLOYMENT COMPLETE                  ║"
echo "╚══════════════════════════════════════════════════════╝"
echo -e "${NC}"
echo -e "  Client:    ${BLUE}${CLIENT_DISPLAY}${NC}"
echo -e "  Directory: ${BLUE}${CLIENT_DIR}${NC}"
echo -e "  Domain:    ${BLUE}${CLIENT_DOMAIN}${NC}"
if [ "$DEPLOY_TYPE" = "1" ]; then
echo -e "  Frontend:  ${BLUE}http://localhost:${FRONTEND_PORT}${NC}"
echo -e "  Backend:   ${BLUE}http://localhost:${BACKEND_PORT}${NC}"
fi
echo ""
echo -e "  ${YELLOW}Next steps:${NC}"
echo -e "  1. Add Cloudflare tunnel route for ${CLIENT_DOMAIN} → localhost:${FRONTEND_PORT}"
echo -e "  2. Import n8n workflow for this client"
echo -e "  3. Index client documents via bulk_ingest.py"
echo -e "  4. Create admin user in the platform"
echo ""
echo -e "  Credentials saved in: ${CLIENT_DIR}/CREDENTIALS.txt"
echo ""
