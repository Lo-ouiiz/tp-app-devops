#!/bin/bash
set -e

cd "$(dirname "$0")/.."

if [ -z "$ACTIVE_COLOR" ]; then
  export ACTIVE_COLOR=blue
fi

REPO_OWNER_LOWER=$(echo "${GITHUB_REPOSITORY_OWNER}" | tr '[:upper:]' '[:lower:]')

echo "Pulling latest images from registry..."
docker pull ghcr.io/$REPO_OWNER_LOWER/cloudnative-backend:${GITHUB_SHA}
docker pull ghcr.io/$REPO_OWNER_LOWER/cloudnative-frontend:${GITHUB_SHA}

if [ "$ACTIVE_COLOR" = "blue" ]; then
  INACTIVE_COLOR="green"
else
  INACTIVE_COLOR="blue"
fi

echo "Deploying $INACTIVE_COLOR version..."
docker compose -f docker-compose.base.yml -f docker-compose.${INACTIVE_COLOR}.yml up -d

echo "Updating ACTIVE_COLOR to $INACTIVE_COLOR..."
export ACTIVE_COLOR=$INACTIVE_COLOR

echo "Restarting reverse proxy..."
docker compose -f docker-compose.base.yml restart reverse-proxy

echo "Blue/Green deployment completed. Active color: $INACTIVE_COLOR"
