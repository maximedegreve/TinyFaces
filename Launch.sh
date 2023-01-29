#!/bin/bash

cd "$(dirname "$0")"

docker-compose up db --detach

echo "🐬 Docker is running now."
echo "⛑  Note: You can stop docker by running: docker-compose stop"
