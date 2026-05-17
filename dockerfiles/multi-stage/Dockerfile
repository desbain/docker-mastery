# ============================================================
# dockerfiles/multi-stage/Dockerfile
# MODULE 2 — Multi-stage build
# Purpose: Reduce image size by separating build from runtime
# Build:   docker build -t docker-mastery-multistage -f dockerfiles/multi-stage/Dockerfile .
# Run:     docker run -p 5000:5000 docker-mastery-multistage
# ============================================================

# ── Stage 1: Builder ──────────────────────────────────────────
# Full image with build tools — this stage is NOT in the final image
FROM python:3.12-slim AS builder

LABEL stage="builder"

WORKDIR /build

# Install build dependencies (gcc needed for some packages)
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Install packages into /install prefix (separate from system Python)
COPY app/requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# ── Stage 2: Final runtime image ──────────────────────────────
# Only copies what it needs from the builder — gcc never ships
FROM python:3.12-slim AS final

LABEL maintainer="George Awa <gewa11281@gmail.com>"
LABEL description="Multi-stage build — smaller and more secure"

WORKDIR /app

# Copy ONLY the installed packages from builder stage
# Everything else (gcc, build tools) stays behind
COPY --from=builder /install /usr/local

# Copy app source
COPY app/app.py .

ENV APP_ENV=production
ENV PORT=5000

EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')"

CMD ["gunicorn", "--bind", "0.0.0.0:5000", "--workers", "2", "app:app"]
