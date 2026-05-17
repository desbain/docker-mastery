#!/usr/bin/env bash
# volumes/volumes-demo.sh
# MODULE 6 — Docker Volumes
# Demonstrates: named volumes, bind mounts, tmpfs
# Usage: bash volumes/volumes-demo.sh

set -euo pipefail
GREEN='\033[0;32m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'

info() { echo -e "${BLUE}[INFO]${NC} $1"; }
ok()   { echo -e "${GREEN}[OK]${NC}   $1"; }
demo() { echo -e "${YELLOW}[DEMO]${NC} $1"; }

echo -e "${BLUE}========================================"
echo "  Docker Volumes Demo"
echo "  George Awa — Docker Mastery Project"
echo "========================================${NC}"

# ── Named Volume ──────────────────────────────────────────────────────────
echo ""
demo "=== 1. Named Volume (persistent across container restarts) ==="

docker volume create demo-data 2>/dev/null || true

info "Writing data to named volume..."
docker run --rm \
  -v demo-data:/data \
  --security-opt no-new-privileges \
  alpine sh -c "echo 'persistent data written at $(date)' > /data/test.txt && cat /data/test.txt"

info "Starting NEW container — data should still be there..."
docker run --rm \
  -v demo-data:/data \
  --security-opt no-new-privileges \
  alpine cat /data/test.txt

ok "Named volume: data persists between container runs"

# ── Bind Mount ────────────────────────────────────────────────────────────
echo ""
demo "=== 2. Bind Mount (mount host directory into container) ==="

mkdir -p /tmp/docker-bind-demo
echo "This file lives on the HOST machine" > /tmp/docker-bind-demo/host.txt

info "Mounting host directory into container (read-only)..."
docker run --rm \
  -v /tmp/docker-bind-demo:/data:ro \
  --security-opt no-new-privileges \
  alpine sh -c "echo 'Inside container:' && cat /data/host.txt"

info "Testing read-only enforcement..."
docker run --rm \
  -v /tmp/docker-bind-demo:/data:ro \
  --security-opt no-new-privileges \
  alpine sh -c "echo 'trying to write' > /data/test.txt 2>&1 || echo 'Write blocked — read-only mount working'"

ok "Bind mount: host files visible inside container, write blocked"

# ── tmpfs (in-memory) ─────────────────────────────────────────────────────
echo ""
demo "=== 3. tmpfs (in-memory storage — disappears when container stops) ==="

info "Writing to tmpfs (in memory, noexec, nosuid)..."
docker run --rm \
  --tmpfs /tmp:rw,noexec,nosuid,size=64m \
  --security-opt no-new-privileges \
  alpine sh -c "
    echo 'temp secret data' > /tmp/secret.txt
    echo 'Written to tmpfs:'
    cat /tmp/secret.txt
    echo 'tmpfs is in-memory — gone when container stops'
  "

ok "tmpfs: ideal for sensitive temporary files (tokens, session data)"

# ── Volume inspection ─────────────────────────────────────────────────────
echo ""
demo "=== 4. Volume inspection commands ==="

info "List all volumes:"
docker volume ls

info "Inspect the demo-data volume:"
docker volume inspect demo-data

info "Find where the volume data lives on the host:"
docker volume inspect demo-data --format '{{.Mountpoint}}'

# ── Cleanup ────────────────────────────────────────────────────────────────
echo ""
read -rp "Clean up demo volume? [y/N] " confirm
if [[ "${confirm,,}" == "y" ]]; then
  docker volume rm demo-data 2>/dev/null || true
  rm -rf /tmp/docker-bind-demo
  ok "Cleanup complete"
fi
