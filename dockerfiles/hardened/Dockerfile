# ============================================================
# dockerfiles/hardened/Dockerfile
# MODULE 3 — Hardened production image
# Purpose: Apply all security best practices
# Build:   docker build -t docker-mastery-hardened -f dockerfiles/hardened/Dockerfile .
# Run:     docker run -p 5000:5000 --read-only --tmpfs /tmp docker-mastery-hardened
# ============================================================

# ── Stage 1: Builder ──────────────────────────────────────────
FROM python:3.12-alpine AS builder

WORKDIR /build

# Alpine uses apk instead of apt-get — much smaller base
RUN apk add --no-cache gcc musl-dev libffi-dev

COPY app/requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# ── Stage 2: Final hardened image ─────────────────────────────────────────
# Start fresh from Alpine — nothing from builder stage carries over except
# what we explicitly copy with COPY --from=builder
FROM python:3.12-alpine AS final

# Document who built and maintains this image
# These show up in docker inspect and container registries
LABEL maintainer="George Awa <gewa11281@gmail.com>"
LABEL org.opencontainers.image.title="docker-mastery-hardened"
LABEL org.opencontainers.image.description="Hardened Flask app — Docker Mastery Project"

# Install curl for health check ONLY — nothing else
# apk = Alpine's package manager (like apt-get on Debian)
# --no-cache = don't store the package index on disk (keeps image smaller)
RUN apk add --no-cache curl

# Security: create a non-root group and user
# -S = system account (no password, no home directory, no shell)
# -G = assign to appgroup
# -u 1000 = explicit UID so it's predictable and auditable
# Never run production apps as root inside a container
RUN addgroup -S appgroup && \
    adduser -S -G appgroup -u 1000 appuser

# Copy ONLY the installed Python packages from the builder stage
# --from=builder = pull from Stage 1, not from the host machine
# /install = where pip installed packages in builder (--prefix=/install)
# /usr/local = where Python looks for packages in the final image
# gcc, build tools, pip cache — all left behind in builder, never shipped
COPY --from=builder /install /usr/local

# Create the app directory and tmp directory
# Both must be owned by appuser BEFORE we switch to that user
# mkdir -p = create parent directories if they don't exist
# chown -R = change ownership recursively
# /tmp/app = gunicorn needs a writable directory for its worker files
RUN mkdir -p /app /tmp/app && \
    chown -R appuser:appgroup /app /tmp/app

# Set working directory — all subsequent commands run from /app
# Must come AFTER chown so appuser already owns it
WORKDIR /app

# Copy app source code with correct ownership set at copy time
# --chown=appuser:appgroup = set owner during copy (more efficient than chown after)
# app/app.py = source on host machine
# . = destination is current WORKDIR (/app)
COPY --chown=appuser:appgroup app/app.py .

# Set file permissions on the app
# 550 = owner can read+execute, group can read+execute, others have NO access
# No write permission even for the owner — app cannot modify itself at runtime
RUN chmod 550 /app/app.py

# Environment variables — safe non-sensitive config only
# PYTHONDONTWRITEBYTECODE=1 = don't create .pyc files (cleaner filesystem)
# PYTHONUNBUFFERED=1 = print logs immediately (don't buffer — important for Docker logs)
# PYTHONFAULTHANDLER=1 = show full Python traceback on crash
# APP_ENV=production = tells our Flask app it's in production mode
# PORT=5000 = documents which port we use (referenced in CMD below)
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    APP_ENV=production \
    APP_VERSION=1.0.0 \
    PORT=5000

# Security: drop to non-root user for all subsequent commands
# Everything after this line runs as appuser (UID 1000)
# If an attacker breaks in they get appuser privileges, not root
USER appuser

# Document which port the app listens on
# This does NOT publish the port — you still need -p 5000:5000 when running
EXPOSE 5000

# Health check — Kubernetes uses this to know if the container is alive
# --interval=30s = check every 30 seconds
# --timeout=10s = fail if no response within 10 seconds
# --start-period=10s = give the app 10 seconds to start before checking
# --retries=3 = mark unhealthy after 3 consecutive failures
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:5000/health || exit 1

# Run gunicorn — production-grade WSGI server
# Never use flask's built-in server (app.run) in production — single threaded
# --bind 0.0.0.0:5000 = listen on all interfaces inside the container
# --workers 2 = 2 worker processes handle requests in parallel
# --threads 4 = 4 threads per worker = 8 concurrent requests
# --timeout 60 = kill worker if it takes more than 60 seconds
# --access-logfile - = send access logs to stdout (Docker captures it)
# --error-logfile - = send error logs to stdout (Docker captures it)
# --log-level info = log INFO and above (not DEBUG)
# app:app = module name : Flask app object name inside app.py
CMD ["gunicorn", \
     "--bind", "0.0.0.0:5000", \
     "--workers", "2", \
     "--threads", "4", \
     "--timeout", "60", \
     "--access-logfile", "-", \
     "--error-logfile", "-", \
     "--log-level", "info", \
     "app:app"]