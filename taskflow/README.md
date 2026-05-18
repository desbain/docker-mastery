# TaskFlow — DevSecOps Task Manager

> **Docker Mastery Project** | George Awa, CISSP | DevSecOps Engineer

A full-stack task management application built to demonstrate production-grade
Docker practices — multi-stage builds, Docker Compose multi-tier stacks,
network isolation, secrets management, and health checks.

## Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| Frontend | React 18 + Nginx | Kanban board + Dashboard UI |
| API | Python Flask + Gunicorn | REST API |
| Database | PostgreSQL 16 | Tasks, users, audit logs |
| Cache | Redis 7 | API response caching |
| Reverse Proxy | Nginx (in frontend container) | Routes /api to Flask |

## Features

- Kanban board — Backlog / In Progress / In Review / Done
- Create, edit, delete, assign tasks
- Priority levels — Critical / High / Medium / Low
- Due dates with overdue detection
- Dashboard with live stats and completion rate
- Audit log — every change tracked
- Redis caching — fast repeated reads

## Quick Start

```bash
# Clone
git clone https://github.com/desbain/docker-mastery.git
cd docker-mastery/taskflow

# Create secrets
mkdir -p secrets
echo "TaskFlowDBPass2024!" > secrets/db_password.txt

# Start everything
docker compose up -d --build

# Open in browser
open http://localhost:3000
```

## Docker Concepts Demonstrated

| Concept | Where |
|---------|-------|
| Multi-stage build | frontend/Dockerfile (Node builder → Nginx), backend/Dockerfile |
| Named volumes | postgres_data, redis_data |
| Network isolation | frontend (bridge), backend (internal — no internet) |
| Docker secrets | db_password mounted at /run/secrets/ |
| Health checks | all 4 services |
| depends_on + condition | api waits for postgres + redis healthy |
| Resource limits | memory limits on all services |
| Non-root containers | backend runs as appuser (UID 1000) |
| Security options | no-new-privileges, cap_drop ALL |

## API Endpoints

```
GET    /api/tasks              List tasks (filter by status, priority)
POST   /api/tasks              Create task
GET    /api/tasks/:id          Get task
PUT    /api/tasks/:id          Update task
DELETE /api/tasks/:id          Delete task
GET    /api/tasks/:id/audit    Audit log for task
GET    /api/users              List users
POST   /api/users              Create user
GET    /api/stats              Dashboard statistics
GET    /health                 Liveness probe
GET    /ready                  Readiness probe (checks DB + Redis)
```

## Author

**George Awa, CISSP** | DevSecOps Engineer  
[LinkedIn](https://linkedin.com/in/georgeawa) · [GitHub](https://github.com/desbain)
