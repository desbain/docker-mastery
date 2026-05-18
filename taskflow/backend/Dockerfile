# ── Stage 1: Builder ──────────────────────────────────────────
FROM python:3.12-alpine AS builder
WORKDIR /build
RUN apk add --no-cache gcc musl-dev libffi-dev postgresql-dev
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# ── Stage 2: Hardened final image ─────────────────────────────
FROM python:3.12-alpine AS final

LABEL maintainer="George Awa <gewa11281@gmail.com>"
LABEL org.opencontainers.image.title="taskflow-api"

RUN apk add --no-cache curl libpq

RUN addgroup -S appgroup && adduser -S -G appgroup -u 1000 appuser

COPY --from=builder /install /usr/local

RUN mkdir -p /app /tmp/app && chown -R appuser:appgroup /app /tmp/app

WORKDIR /app

COPY --chown=appuser:appgroup app/ ./app/
COPY --chown=appuser:appgroup wsgi.py .

RUN chmod -R 550 /app

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    APP_ENV=production \
    APP_VERSION=1.0.0

USER appuser
EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=10s --start-period=20s --retries=3 \
    CMD curl -f http://localhost:5000/health || exit 1

CMD ["gunicorn", \
     "--bind", "0.0.0.0:5000", \
     "--workers", "2", \
     "--threads", "4", \
     "--timeout", "60", \
     "--access-logfile", "-", \
     "--error-logfile", "-", \
     "wsgi:app"]
