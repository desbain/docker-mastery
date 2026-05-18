# Module 5 — Docker Volumes: Completed

## Three Volume Types Proved

### Named Volume
- Data persists after container stops
- Two containers can share same volume simultaneously
- Docker manages storage at /var/lib/docker/volumes/
- Used by taskflow_postgres_data and taskflow_redis_data

### Bind Mount
- Mounts host directory directly into container
- :ro flag makes it read-only — write attempt blocked
- Used for development, code changes instantly visible

### tmpfs
- In-memory only, never written to disk
- Gone when container stops
- Used for secrets, session tokens, temp files

## Key Commands
- docker volume create name
- docker volume ls
- docker volume inspect name
- docker run -v volume:/path container
- docker run -v folder:/path:ro container
- docker run --tmpfs /tmp:rw,noexec,nosuid,size=64m container
- export MSYS_NO_PATHCONV=1 required on Windows Git Bash

## Volume Backup
docker run --rm -v volume:/data -v pwd:/backup alpine tar czf /backup/backup.tar.gz -C /data .
