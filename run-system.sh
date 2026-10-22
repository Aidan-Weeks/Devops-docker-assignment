#!/bin/sh

set -e
L="project=music-agent"

docker network create --label $L agent-net

docker volume create --label $L chinook-pgdata

docker run -d --name chinook-db --network agent-net --label $L \
  -e POSTGRES_USER=musicAI -e POSTGRES_PASSWORD='Secret123!' -e POSTGRES_DB=chinook \
  -v chinook-pgdata:/var/lib/postgresql/data \
  postgres:16

until docker exec chinook-db psql -h 127.0.0.1 -U musicAI -d chinook -c 'select 1' >/dev/null 2>&1; do sleep 1; done

docker build --target seeder --label $L -t chinook-seeder .
docker build --target agent  --label $L -t chinook-agent .

docker run --rm --name chinook-seeder --network agent-net --label $L \
  -v "$PWD/Chinook.db:/app/Chinook.db:ro" \
  -e SQLITE_FILE=/app/Chinook.db \
  -e "DATABASE_URL=postgres://musicAI:Secret123!@chinook-db:5432/chinook" \
  chinook-seeder 

  docker run -d --name mcp-gateway --network agent-net --label $L \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v "$PWD/mcp_config.yaml:/mcp_config.yaml:ro" \
  -v "$PWD/mcp_secret.env:/run/secrets/database-url:ro" \
  docker/mcp-gateway:latest \
  --transport=sse --secrets=/run/secrets/database-url --allow-unauthenticated \
  --servers=cockroachdb --tools=execute_query --config=/mcp_config.yaml

  until docker logs mcp-gateway 2>&1 | grep -qi "Gateway URL"; do sleep 2; done

  docker run --rm --name chinook-agent --network agent-net --label $L \
  -v "$PWD/secret.ollama-api-key:/run/secrets/openai-api-key:ro" \
  -e MCP_SERVER_URL=http://mcp-gateway:8811/sse \
  -e DATABASE_DIALECT=PostgreSQL \
  -e "QUESTION=What are the top 3 albums by sales?" \
  -e OPENAI_API_BASE_URL=https://ollama.com/v1 \
  -e OPENAI_MODEL_NAME=gpt-oss:20b \
  chinook-agent
