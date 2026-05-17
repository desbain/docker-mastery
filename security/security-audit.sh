#!/usr/bin/env bash
# security/security-audit.sh
# MODULE 7 — Docker Security
# Audits running containers and images for security issues
# Usage: bash security/security-audit.sh [image:tag]

set -euo pipefail
GREEN='\033[0;32m'; RED='\033[0;31m'; YELLOW='\033[1;33m'; BLUE='\033[0;34m'; NC='\033[0m'

PASS=0; FAIL=0; WARN=0
TARGET_IMAGE="${1:-}"

pass() { PASS=$((PASS+1)); echo -e "${GREEN}[PASS]${NC} $1"; }
fail() { FAIL=$((FAIL+1)); echo -e "${RED}[FAIL]${NC} $1"; }
warn() { WARN=$((WARN+1)); echo -e "${YELLOW}[WARN]${NC} $1"; }
info() { echo -e "${BLUE}[INFO]${NC} $1"; }

echo -e "${BLUE}========================================"
echo "  Docker Security Audit"
echo "  George Awa — Docker Mastery Project"
echo "========================================${NC}"

# ── Audit running containers ───────────────────────────────────────────────
echo ""
info "=== Running Container Security Audit ==="

containers=$(docker ps -q 2>/dev/null)
if [[ -z "$containers" ]]; then
  info "No running containers found"
else
  while IFS= read -r cid; do
    name=$(docker inspect --format '{{.Name}}' "$cid" | tr -d '/')
    image=$(docker inspect --format '{{.Config.Image}}' "$cid")
    user=$(docker inspect --format '{{.Config.User}}' "$cid")
    privileged=$(docker inspect --format '{{.HostConfig.Privileged}}' "$cid")
    readonly_fs=$(docker inspect --format '{{.HostConfig.ReadonlyRootfs}}' "$cid")
    cap_add=$(docker inspect --format '{{.HostConfig.CapAdd}}' "$cid")
    mem_limit=$(docker inspect --format '{{.HostConfig.Memory}}' "$cid")
    security_opt=$(docker inspect --format '{{.HostConfig.SecurityOpt}}' "$cid")

    echo ""
    info "Container: $name ($image)"

    # Privileged check
    [[ "$privileged" == "true" ]] && \
      fail "$name: running PRIVILEGED — major security risk" || \
      pass "$name: not privileged"

    # Root user check
    [[ -z "$user" || "$user" == "root" || "$user" == "0" ]] && \
      fail "$name: running as root (user='${user:-unset}')" || \
      pass "$name: non-root user ($user)"

    # Read-only filesystem
    [[ "$readonly_fs" == "true" ]] && \
      pass "$name: read-only root filesystem" || \
      warn "$name: no read-only filesystem"

    # Capabilities
    [[ "$cap_add" == "[]" || -z "$cap_add" ]] && \
      pass "$name: no added capabilities" || \
      fail "$name: added capabilities: $cap_add"

    # no-new-privileges
    echo "$security_opt" | grep -q "no-new-privileges" && \
      pass "$name: no-new-privileges set" || \
      warn "$name: missing no-new-privileges"

    # Memory limit
    [[ "$mem_limit" -gt 0 ]] 2>/dev/null && \
      pass "$name: memory limit set ($((mem_limit / 1024 / 1024))MB)" || \
      warn "$name: no memory limit"

  done <<< "$containers"
fi

# ── Trivy image scan ───────────────────────────────────────────────────────
if [[ -n "$TARGET_IMAGE" ]]; then
  echo ""
  info "=== Trivy Image Scan: $TARGET_IMAGE ==="

  if command -v trivy &>/dev/null; then
    trivy image --severity HIGH,CRITICAL --ignore-unfixed "$TARGET_IMAGE"
  else
    info "Running Trivy via Docker..."
    docker run --rm \
      -v /var/run/docker.sock:/var/run/docker.sock \
      aquasec/trivy:latest image \
      --severity HIGH,CRITICAL \
      --ignore-unfixed \
      "$TARGET_IMAGE"
  fi
fi

# ── Summary ────────────────────────────────────────────────────────────────
echo ""
echo -e "${BLUE}========================================"
echo "  SECURITY AUDIT SUMMARY"
echo "========================================${NC}"
echo -e "${GREEN}  PASS: $PASS${NC}"
echo -e "${RED}  FAIL: $FAIL${NC}"
echo -e "${YELLOW}  WARN: $WARN${NC}"
echo "  TOTAL: $((PASS + FAIL + WARN))"
echo "========================================"
[[ $FAIL -gt 0 ]] && exit 1 || exit 0
