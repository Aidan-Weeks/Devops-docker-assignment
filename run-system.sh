#!/bin/sh

set -e
L="project=music-agent"

docker network create --label $L agent-net

docker volume create --label $L chinook-pgdata

docker run -d --name chinook-db --network agent-net \
  -e POSTGRES_USER=musicAI -e POSTGRES_PASSWORD=Secret123! -e POSTGRES_DB=chinook \
  postgres:16

until docker exec chinook-db psql -h 127.0.0.1 -U musicAI -d chinook -c 'select 1' >/dev/null 2>&1; do sleep 1; done

docker build --target seeder --label $L -t chinook-seeder .
docker build --target agent  --label $L -t chinook-agent .
