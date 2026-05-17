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

# ── Stage 2: Hardened final image ─────────────────────────────
FROM python:3.12-alpine AS final

# Image metadata
LABEL maintainer="George Awa <gewa11281@gmail.com>"
LABEL org.opencontainers.image.title="docker-mastery-hardened"
LABEL org.opencontainers.image.description="Hardened Flask app — Docker Mastery Project"
LABEL org.opencontainers.image.version="1.0.0"

# Security: install curl for health check only — nothing else
RUN apk add --no-cache curl

# Security: create non-root user
# Never run as root inside a container
RUN addgroup -S appgroup && \
    adduser -S -G appgroup -u 1000 appuser

WORKDIR /app

# Copy dependencies from builder
COPY --from=builder /install /usr/local

# Copy source with correct ownership
COPY --chown=appuser:appgroup app/app.py .

# Security: lock down file permissions
# 550 = owner can read+execute, group can read+execute, others nothing
RUN chmod -R 550 /app

# Create writable temp directory (needed by gunicorn)
RUN mkdir -p /tmp/app && chown appuser:appgroup /tmp/app

# Security: never hardcode secrets — use environment variables
# These are safe non-sensitive defaults
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PYTHONFAULTHANDLER=1 \
    APP_ENV=production \
    APP_VERSION=1.0.0 \
    PORT=5000

# Security: drop to non-root user
USER appuser

EXPOSE 5000

# Health check using curl
HEALTHCHECK --interval=30s --timeout=10s --start-period=10s --retries=3 \
    CMD curl -f http://localhost:5000/health || exit 1

# Run with gunicorn — production WSGI server
CMD ["gunicorn", \
     "--bind", "0.0.0.0:5000", \
     "--workers", "2", \
     "--threads", "4", \
     "--timeout", "60", \
     "--access-logfile", "-", \
     "--error-logfile", "-", \
     "--log-level", "info", \
     "app:app"]
