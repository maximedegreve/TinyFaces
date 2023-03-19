#!/bin/bash

cd "$(dirname "$0")"

docker-compose up db --detach
ngrok http -subdomain=tinyfaces 8080 > /dev/null &

echo "🐬 Docker is running now."
echo "⛑  Note: You can stop docker by running: docker-compose stop"
