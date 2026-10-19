#!/bin/sh

set -e
L="project=music-agent"

docker network create --label $L agent-net

