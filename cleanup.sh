#!/bin/sh
L="project=music-agent"

#cleanup for network
docker network ls -q --filter label=$L | xargs -r docker network rm

docker volume ls -q --filter label=$L | xargs -r docker volume rm

docker stop chinook-db 2>/dev/null || true
docker rm chinook-db 2>/dev/null || true