# Docker Mastery Project
## George Awa, CISSP | DevSecOps Engineer | Project 5

A hands-on Docker project covering everything from basic container
commands to production-grade hardened images, multi-container Compose
stacks, network isolation, volume management, and automated security
scanning — all with a working GitHub Actions pipeline.

---

## Project Structure

```
docker-mastery/
├── app/
│   ├── app.py                          # Flask app used across all modules
│   └── requirements.txt
├── dockerfiles/
│   ├── basic/Dockerfile                # Module 1 — Learn Dockerfile instructions
│   ├── multi-stage/Dockerfile          # Module 2 — Reduce image size
│   └── hardened/Dockerfile             # Module 3 — Production security hardening
├── compose/
│   ├── web-stack/docker-compose.yml    # Module 4 — Flask + PostgreSQL + Redis + Nginx
│   └── monitoring-stack/docker-compose.yml  # Module 4b — Prometheus + Grafana
├── networking/
│   └── networking-demo.sh              # Module 5 — Bridge, internal, zero-trust
├── volumes/
│   └── volumes-demo.sh                 # Module 6 — Named, bind, tmpfs
├── security/
│   └── security-audit.sh              # Module 7 — Container security audit
├── scripts/
│   └── practice-commands.sh           # Module 1 — All basic Docker commands
└── .github/workflows/pipeline.yml     # CI/CD — lint, build, Trivy, push to GHCR
```

---

## Modules

| Module | File | What You Learn |
|--------|------|---------------|
| 1 — Basics | `scripts/practice-commands.sh` | images, run, ps, logs, exec, stats |
| 2 — Dockerfile | `dockerfiles/basic/Dockerfile` | FROM, RUN, COPY, CMD, EXPOSE, ENV |
| 3 — Multi-stage | `dockerfiles/multi-stage/Dockerfile` | Reduce image size, separate build/runtime |
| 4 — Hardened | `dockerfiles/hardened/Dockerfile` | Non-root, read-only FS, Alpine, least privilege |
| 5 — Compose | `compose/web-stack/` | Multi-container, secrets, networks, volumes |
| 6 — Monitoring | `compose/monitoring-stack/` | Prometheus, Grafana, cAdvisor |
| 7 — Networking | `networking/networking-demo.sh` | Bridge, internal, zero-trust connectivity |
| 8 — Volumes | `volumes/volumes-demo.sh` | Named, bind mount, tmpfs |
| 9 — Security | `security/security-audit.sh` | Container audit, Trivy scanning |

---

## Step-by-Step Setup

### 1. Clone the repo
```bash
git clone https://github.com/desbain/docker-mastery.git
cd docker-mastery
```

### 2. Start with Module 1 — Docker basics
```bash
# Run commands one by one from this file
cat scripts/practice-commands.sh
```

### 3. Build all three images and compare sizes
```bash
docker build -t docker-mastery-basic:v1 -f dockerfiles/basic/Dockerfile .
docker build -t docker-mastery-multistage:v1 -f dockerfiles/multi-stage/Dockerfile .
docker build -t docker-mastery-hardened:v1 -f dockerfiles/hardened/Dockerfile .
docker images | grep docker-mastery
```

### 4. Run the web stack
```bash
cd compose/web-stack
mkdir -p secrets
echo "MySecureDBPass123" > secrets/db_password.txt
echo "MySecureRedisPass" > secrets/redis_password.txt
docker compose up -d
docker compose ps
curl http://localhost
docker compose logs -f app
docker compose down -v
```

### 5. Run the monitoring stack
```bash
cd compose/monitoring-stack
docker compose up -d
# Grafana:    http://localhost:3000  (admin/admin123)
# Prometheus: http://localhost:9090
# cAdvisor:   http://localhost:8080
docker compose down
```

### 6. Test networking
```bash
bash networking/networking-demo.sh
```

### 7. Test volumes
```bash
bash volumes/volumes-demo.sh
```

### 8. Run security audit
```bash
bash security/security-audit.sh docker-mastery-hardened:v1
```

---

## Key Security Concepts Demonstrated

| Concept | Implementation |
|---------|---------------|
| Non-root user | `adduser -S appuser`, `USER appuser` |
| Read-only filesystem | `--read-only` + `--tmpfs /tmp` |
| Drop capabilities | `--cap-drop ALL` |
| No privilege escalation | `--security-opt no-new-privileges` |
| Resource limits | `--memory`, `--cpus` |
| Network isolation | `internal: true` networks per tier |
| Secrets management | Docker secrets (not env vars) |
| Image scanning | Trivy in GitHub Actions |
| Dockerfile linting | hadolint in GitHub Actions |
| Multi-stage builds | Separate builder and final stages |

---

## GitHub Actions Pipeline

Every push triggers:
1. **hadolint** — Dockerfile lint (catches bad practices)
2. **Docker build** — builds all 3 images
3. **Image size comparison** — shows the benefit of multi-stage
4. **Trivy scan** — scans hardened image for CVEs
5. **Push to GHCR** — pushes to GitHub Container Registry (main only)

---

## Author

**George Awa, CISSP** | DevSecOps Engineer  
[LinkedIn](https://linkedin.com/in/georgeawa) · [GitHub](https://github.com/desbain)
