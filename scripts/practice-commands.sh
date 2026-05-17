#!/usr/bin/env bash
# scripts/practice-commands.sh
# MODULE 1 — Docker Basics: core commands to run in order
# This is your hands-on practice guide — run each command and observe
# Usage: Run commands ONE BY ONE in Git Bash — not the whole script

echo "========================================="
echo "  Docker Mastery — Practice Commands"
echo "  Run each command one at a time!"
echo "========================================="

# ── SECTION 1: Images ─────────────────────────────────────────────────────
echo ""
echo "=== SECTION 1: Working with Images ==="

# Pull an image from Docker Hub
docker pull nginx:alpine
docker pull python:3.12-alpine
docker pull redis:7-alpine

# List images
docker images
docker image ls

# Image details
docker image inspect nginx:alpine
docker image inspect nginx:alpine --format '{{.Os}} {{.Architecture}}'
docker image inspect nginx:alpine --format '{{.Config.ExposedPorts}}'

# Image history (see each layer)
docker image history nginx:alpine
docker image history python:3.12-alpine

# Remove an image
docker image rm nginx:alpine
docker image ls

# Remove all unused images
docker image prune -f

# ── SECTION 2: Build your images ──────────────────────────────────────────
echo ""
echo "=== SECTION 2: Build Your Images ==="

# Build the basic image
docker build -t docker-mastery-basic:v1 -f dockerfiles/basic/Dockerfile .

# Build the multi-stage image
docker build -t docker-mastery-multistage:v1 -f dockerfiles/multi-stage/Dockerfile .

# Build the hardened image
docker build -t docker-mastery-hardened:v1 -f dockerfiles/hardened/Dockerfile .

# Compare sizes — the key lesson of multi-stage builds
docker images | grep docker-mastery

# Build with build arguments
docker build \
  --build-arg APP_VERSION=2.0.0 \
  -t docker-mastery-basic:v2 \
  -f dockerfiles/basic/Dockerfile .

# Build with no cache (forces fresh build)
docker build --no-cache -t docker-mastery-basic:fresh -f dockerfiles/basic/Dockerfile .

# ── SECTION 3: Running containers ─────────────────────────────────────────
echo ""
echo "=== SECTION 3: Running Containers ==="

# Run basic container
docker run docker-mastery-basic:v1

# Run in detached mode (background)
docker run -d --name myapp docker-mastery-basic:v1

# Run with port mapping (host:container)
docker run -d -p 5000:5000 --name myapp-web docker-mastery-basic:v1

# Test it works
curl http://localhost:5000
curl http://localhost:5000/health

# Run with environment variables
docker run -d -p 5001:5000 \
  -e APP_ENV=development \
  -e APP_VERSION=2.0.0 \
  --name myapp-dev \
  docker-mastery-basic:v1

# Run interactively (get a shell)
docker run -it alpine sh
docker run -it python:3.12-alpine python

# Run and remove when done (--rm)
docker run --rm alpine echo "Hello from container"

# Run with resource limits
docker run -d \
  --name myapp-limited \
  --memory="256m" \
  --cpus="0.5" \
  -p 5002:5000 \
  docker-mastery-basic:v1

# ── SECTION 4: Managing containers ────────────────────────────────────────
echo ""
echo "=== SECTION 4: Managing Containers ==="

# List running containers
docker ps

# List ALL containers (including stopped)
docker ps -a

# List container IDs only
docker ps -q

# Container details
docker inspect myapp

# Container logs
docker logs myapp
docker logs -f myapp          # follow
docker logs --tail 20 myapp   # last 20 lines
docker logs --since 5m myapp  # last 5 minutes

# Container stats (live resource usage)
docker stats
docker stats myapp --no-stream   # snapshot only

# Execute command in running container
docker exec myapp ls -la
docker exec myapp ps aux
docker exec -it myapp sh    # interactive shell

# Copy files to/from container
docker cp myapp:/app/app.py ./app-from-container.py
docker cp ./newfile.txt myapp:/app/

# Stop containers
docker stop myapp
docker stop myapp myapp-web myapp-dev   # multiple at once

# Start stopped container
docker start myapp

# Restart container
docker restart myapp

# Remove container (must be stopped)
docker rm myapp

# Force remove running container
docker rm -f myapp-web

# Remove all stopped containers
docker container prune -f

# ── SECTION 5: Security hardening commands ────────────────────────────────
echo ""
echo "=== SECTION 5: Run Hardened Container ==="

# Run with all security flags
docker run -d \
  --name secure-app \
  --user 1000:1000 \
  --read-only \
  --tmpfs /tmp:rw,noexec,nosuid,size=64m \
  --security-opt no-new-privileges \
  --cap-drop ALL \
  --memory="256m" \
  --cpus="0.5" \
  -p 5000:5000 \
  docker-mastery-hardened:v1

# Verify it's running as non-root
docker exec secure-app whoami
docker exec secure-app id

# Verify read-only filesystem
docker exec secure-app sh -c "echo test > /tmp/test.txt && echo 'tmpfs writable OK'"
docker exec secure-app sh -c "echo test > /app/test.txt 2>&1 || echo 'Root FS is read-only OK'"

# Check running process
docker exec secure-app ps aux

# ── SECTION 6: Cleanup ────────────────────────────────────────────────────
echo ""
echo "=== SECTION 6: Cleanup ==="

# Stop all running containers
docker stop $(docker ps -q) 2>/dev/null || true

# Remove all stopped containers
docker container prune -f

# Remove all unused images
docker image prune -f

# Remove everything (careful!)
# docker system prune -af   # removes ALL unused containers, images, networks, volumes

# Show disk usage
docker system df
