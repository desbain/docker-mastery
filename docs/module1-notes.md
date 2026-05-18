# Module 1 — Docker Basics: Completed

## What I Practiced

### Images
- Pulled nginx:alpine, python:3.12-alpine, redis:7-alpine
- Alpine images are 40-60MB vs 1GB+ for full images
- Used docker image history to see every layer
- Used docker image inspect to extract OS, architecture, exposed ports
- Shared layers save disk space across images

### Running Containers
- docker run -d -p 8080:80 --name my-nginx nginx:alpine
- Mapped host port 8080 to container port 80
- Verified nginx serving traffic with curl http://localhost:8080

### Container Management
- docker ps — list running containers
- docker logs my-nginx — view container output
- docker stats --no-stream — live CPU/memory usage
- docker exec -it my-nginx sh — shell inside container
- docker cp — copy files from container to host
- docker inspect — full container metadata in JSON

### Key Security Observations
- nginx ran as root — fixed in Module 3
- ReadonlyRootfs: false — fixed in Module 3
- Memory: 0 (no limit) — fixed in Module 3
- Privileged: false — good default

### Commands Learned
docker pull, docker images, docker image history, docker image inspect,
docker run, docker ps, docker logs, docker stats, docker exec,
docker cp, docker inspect, docker stop, docker rm, docker system df
