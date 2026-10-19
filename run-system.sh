#!/bin/sh

set -e
L="project=music-agent"

docker network create --label $L agent-net

docker volume create --label $L chinook-pgdata

docker run -d --name chinook-db --network agent-net \
  -e POSTGRES_USER=musicAI -e POSTGRES_PASSWORD=Secret123! -e POSTGRES_DB=chinook \
  postgres:16
