# Module 2 — Dockerfile and Multi-Stage Builds: Completed

## What I Built

### Three Dockerfiles
- basic/Dockerfile — single stage, python:3.12-slim, runs as root, 133MB
- multi-stage/Dockerfile — two stages, gcc left behind in builder, 125MB
- hardened/Dockerfile — Alpine base, non-root user, locked permissions, 60MB

## Key Lessons

### Layer Caching
- COPY requirements.txt BEFORE app.py so pip install is cached
- Only changes after the changed layer get rebuilt

### Multi-Stage Builds
- Stage 1 (builder): has gcc, build tools, pip cache — never shipped
- Stage 2 (final): only copies installed packages from builder
- COPY --from=builder /install /usr/local — the key instruction

### Security Hardening Results
- whoami: appuser (UID 1000) — not root
- /app write: BLOCKED — chmod 550 enforced
- /tmp/app write: allowed — gunicorn can write worker files
- Image size: 133MB → 60MB (55% reduction)

### Size Comparison
- docker-mastery-basic:       133MB
- docker-mastery-multistage:  125MB
- docker-mastery-hardened:     60MB

## Commands Learned
docker build -t name:tag -f Dockerfile .
docker build --no-cache
docker images | grep name
docker exec container whoami
docker exec container id
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Ports}}"
