# ============================================================
# dockerfiles/basic/Dockerfile
# MODULE 1 — Basic Dockerfile
# Purpose: Learn the core Dockerfile instructions
# Build:   docker build -t docker-mastery-basic -f dockerfiles/basic/Dockerfile .
# Run:     docker run -p 5000:5000 docker-mastery-basic
# ============================================================

# FROM — base image to build on top of
# python:3.12-slim = Python 3.12 on Debian slim (smaller than full)
FROM python:3.12-slim

# LABEL — metadata about the image (good practice)
LABEL maintainer="George Awa <gewa11281@gmail.com>"
LABEL version="1.0"
LABEL description="Basic Dockerfile for learning Docker fundamentals"

# WORKDIR — sets the working directory inside the container
# All subsequent commands run from here
WORKDIR /app

# COPY — copy files from host to container
# COPY <source> <destination>
# Copy requirements first for better layer caching
COPY app/requirements.txt .

# RUN — execute a command during image build
# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application source code
COPY app/app.py .

# ENV — set environment variables inside the container
ENV APP_ENV=development
ENV PORT=5000

# EXPOSE — document which port the container listens on
# (does NOT actually publish the port — that's done with -p when running)
EXPOSE 5000

# HEALTHCHECK — tell Docker how to test if container is healthy
HEALTHCHECK --interval=30s --timeout=10s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')"

# CMD — the default command to run when container starts
# Only ONE CMD per Dockerfile (last one wins)
CMD ["python", "app.py"]
