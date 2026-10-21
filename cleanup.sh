#!/bin/sh
L="project=music-agent"


docker ps -aq --filter label=$L | xargs -r docker rm -vf

#cleanup for network
docker network ls -q --filter label=$L | xargs -r docker network rm

docker image ls -q --filter label=$L | xargs -r docker rmi -f