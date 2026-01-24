#!/bin/bash
set -e

echo "Creating network if not exists..."
docker network create gym-network || true

echo "Stopping application..."
docker compose down || true

echo "Stopping monitoring (if exists)..."
docker compose -f docker-compose.monitoring.yml down || true

echo "Pulling application images..."
REPO_OWNER_LOWER=$(echo "${GITHUB_REPOSITORY_OWNER}" | tr '[:upper:]' '[:lower:]')

docker pull ghcr.io/$REPO_OWNER_LOWER/cloudnative-backend:${GITHUB_SHA}
docker pull ghcr.io/$REPO_OWNER_LOWER/cloudnative-frontend:${GITHUB_SHA}

echo "Starting application..."
docker compose up -d

echo "Starting monitoring..."
docker compose -f docker-compose.monitoring.yml up -d

echo "Deployment completed successfully!"

# set -e

# cd "$(dirname "$0")/.."

# if [ -z "$ACTIVE_COLOR" ]; then
#   export ACTIVE_COLOR=blue
# fi

# REPO_OWNER_LOWER=$(echo "${GITHUB_REPOSITORY_OWNER}" | tr '[:upper:]' '[:lower:]')

# echo "Pulling latest images from registry..."
# docker pull ghcr.io/$REPO_OWNER_LOWER/cloudnative-backend:${GITHUB_SHA}
# docker pull ghcr.io/$REPO_OWNER_LOWER/cloudnative-frontend:${GITHUB_SHA}

# if [ "$ACTIVE_COLOR" = "blue" ]; then
#   INACTIVE_COLOR="green"
# else
#   INACTIVE_COLOR="blue"
# fi

# echo "Deploying $INACTIVE_COLOR version..."
# docker compose -f docker-compose.base.yml -f docker-compose.${INACTIVE_COLOR}.yml up -d

# echo "Updating ACTIVE_COLOR to $INACTIVE_COLOR..."
# export ACTIVE_COLOR=$INACTIVE_COLOR

# echo "Restarting reverse proxy..."
# docker compose -f docker-compose.base.yml restart reverse-proxy

# echo "Blue/Green deployment completed. Active color: $INACTIVE_COLOR"
