#!/bin/sh
L="project=music-agent"


docker ps -aq --filter label=$L | xargs -r docker rm -vf

#mcp gateway remove with label
docker ps -aq --filter ancestor=mcp/cockroachdb | xargs -r docker rm -vf

#cleanup for network with label
docker network ls -q --filter label=$L | xargs -r docker network rm

docker image ls -q --filter label=$L | xargs -r docker rmi -f