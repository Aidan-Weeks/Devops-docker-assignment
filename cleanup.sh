#!/bin/sh
L="project=music-agent"

#cleanup for network
docker network ls -q --filter label=$L | xargs -r docker network rm