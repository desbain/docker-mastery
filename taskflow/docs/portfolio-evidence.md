# TaskFlow — Portfolio Evidence

## Live Application Screenshot

![TaskFlow Kanban Board](../taskflow-kanban.png)

## Proof of Concept — What Was Running

### Docker Compose Stack
- taskflow-frontend   (React + Nginx)    — healthy  port 3000
- taskflow-api        (Flask + Gunicorn) — healthy  port 5000
- taskflow-postgres   (PostgreSQL 16)    — healthy
- taskflow-redis      (Redis 7)          — healthy

### Key Docker Concepts Demonstrated
- Multi-stage builds (Node→Nginx, Python→Alpine)
- Docker secrets (DB password never in env vars)
- Network isolation (backend: internal: true)
- Health checks with depends_on condition
- Resource limits and cap_drop ALL
- Non-root containers (appuser UID 1000)
