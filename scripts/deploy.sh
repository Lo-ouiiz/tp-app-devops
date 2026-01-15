#!/bin/bash
set -e

cd "$(dirname "$0")/.."

if [ ! -f active_color.env ]; then
  echo "ACTIVE_COLOR=blue" > active_color.env
fi

REPO_OWNER_LOWER=$(echo "${GITHUB_REPOSITORY_OWNER}" | tr '[:upper:]' '[:lower:]')

echo "Pulling latest images from registry..."
docker pull ghcr.io/$REPO_OWNER_LOWER/cloudnative-backend:${GITHUB_SHA}
docker pull ghcr.io/$REPO_OWNER_LOWER/cloudnative-frontend:${GITHUB_SHA}

source active_color.env
if [ "$ACTIVE_COLOR" = "blue" ]; then
  INACTIVE_COLOR="green"
else
  INACTIVE_COLOR="blue"
fi

echo "Deploying $INACTIVE_COLOR version..."
docker compose -f docker-compose.base.yml -f docker-compose.${INACTIVE_COLOR}.yml up -d

echo "Updating active color to $INACTIVE_COLOR..."
echo "ACTIVE_COLOR=$INACTIVE_COLOR" > active_color.env

docker compose -f docker-compose.base.yml exec reverse-proxy nginx -s reload

echo "Blue/Green deployment completed. Active color: $INACTIVE_COLOR"
