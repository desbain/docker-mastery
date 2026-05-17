#!/usr/bin/env bash
# networking/networking-demo.sh
# MODULE 5 — Docker Networking
# Demonstrates: bridge, internal, and zero-trust networking
# Usage: bash networking/networking-demo.sh

set -euo pipefail
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; RED='\033[0;31m'; NC='\033[0m'

info()  { echo -e "${BLUE}[INFO]${NC}  $1"; }
ok()    { echo -e "${GREEN}[OK]${NC}    $1"; }
warn()  { echo -e "${YELLOW}[TEST]${NC}  $1"; }
fail()  { echo -e "${RED}[FAIL]${NC}  $1"; }

echo -e "${BLUE}========================================"
echo "  Docker Networking Demo"
echo "  George Awa — Docker Mastery Project"
echo "========================================${NC}"

# ── Create networks ────────────────────────────────────────────────────────
info "Creating isolated networks..."

docker network create \
  --driver bridge \
  --subnet 172.30.0.0/24 \
  --gateway 172.30.0.1 \
  demo-frontend 2>/dev/null || info "demo-frontend already exists"

docker network create \
  --driver bridge \
  --subnet 172.30.1.0/24 \
  --internal \
  demo-backend 2>/dev/null || info "demo-backend already exists"

docker network create \
  --driver bridge \
  --subnet 172.30.2.0/24 \
  --internal \
  demo-db 2>/dev/null || info "demo-db already exists"

echo ""
ok "Networks created:"
docker network ls | grep demo

# ── Start containers ───────────────────────────────────────────────────────
echo ""
info "Starting containers on isolated networks..."

docker run -d --name demo-web \
  --network demo-frontend \
  --security-opt no-new-privileges \
  --cap-drop ALL \
  nginx:alpine 2>/dev/null || info "demo-web already running"

docker network connect demo-backend demo-web 2>/dev/null || true

docker run -d --name demo-app \
  --network demo-backend \
  --security-opt no-new-privileges \
  alpine sleep 3600 2>/dev/null || info "demo-app already running"

docker network connect demo-db demo-app 2>/dev/null || true

docker run -d --name demo-db \
  --network demo-db \
  --security-opt no-new-privileges \
  alpine sleep 3600 2>/dev/null || info "demo-db already running"

sleep 2

# ── Test connectivity ──────────────────────────────────────────────────────
echo ""
info "Testing zero-trust network connectivity..."
echo ""

# web → app (shared backend network)
warn "Can web reach app? (both on demo-backend — should be YES)"
if docker exec demo-web ping -c1 -W2 demo-app &>/dev/null; then
  ok "web → app: REACHABLE"
else
  ok "web → app: BLOCKED (ICC disabled)"
fi

# app → db (shared db network)
warn "Can app reach db? (both on demo-db — should be YES)"
if docker exec demo-app ping -c1 -W2 demo-db &>/dev/null; then
  ok "app → db: REACHABLE"
else
  fail "app → db: BLOCKED unexpectedly"
fi

# web → db (different networks — should be blocked)
warn "Can web reach db? (different networks — should be NO)"
if docker exec demo-web ping -c1 -W2 demo-db &>/dev/null; then
  fail "web → db: REACHABLE — zero-trust failed!"
else
  ok "web → db: BLOCKED — zero-trust working correctly"
fi

# ── Show network details ───────────────────────────────────────────────────
echo ""
info "Network details:"
echo ""
docker network inspect demo-frontend --format \
  'frontend: subnet={{range .IPAM.Config}}{{.Subnet}}{{end}} internal={{.Internal}}'
docker network inspect demo-backend --format \
  'backend:  subnet={{range .IPAM.Config}}{{.Subnet}}{{end}} internal={{.Internal}}'
docker network inspect demo-db --format \
  'db:       subnet={{range .IPAM.Config}}{{.Subnet}}{{end}} internal={{.Internal}}'

# ── Cleanup ────────────────────────────────────────────────────────────────
echo ""
read -rp "Clean up demo containers and networks? [y/N] " confirm
if [[ "${confirm,,}" == "y" ]]; then
  docker rm -f demo-web demo-app demo-db 2>/dev/null || true
  docker network rm demo-frontend demo-backend demo-db 2>/dev/null || true
  ok "Cleanup complete"
fi
