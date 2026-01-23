#!/bin/bash
set -e

cd "$(dirname "$0")/.."

if [ ! -f .env ]; then
  echo "Generating .env file..."
  echo "POSTGRES_USER=${POSTGRES_USER}" > .env
  echo "POSTGRES_PASSWORD=${POSTGRES_PASSWORD}" >> .env
  echo "POSTGRES_DB=${POSTGRES_DB}" >> .env
  echo "DATABASE_URL=${DATABASE_URL}" >> .env
  echo "VITE_API_URL=${VITE_API_URL}" >> .env
  echo "SEED_DB=${SEED_DB}" >> .env
  echo "COMMIT_SHA=${COMMIT_SHA}" >> .env
fi

if [ -f active_color.env ]; then
  source active_color.env
else
  echo "ACTIVE_COLOR=blue" > active_color.env
  ACTIVE_COLOR=blue
fi

echo "Current active color: $ACTIVE_COLOR"

if [ "$ACTIVE_COLOR" = "blue" ]; then
  INACTIVE_COLOR="green"
else
  INACTIVE_COLOR="blue"
fi

echo "Deploying $INACTIVE_COLOR stack..."

REPO_OWNER_LOWER=$(echo "${GITHUB_REPOSITORY_OWNER}" | tr '[:upper:]' '[:lower:]')

docker pull ghcr.io/$REPO_OWNER_LOWER/cloudnative-backend:${COMMIT_SHA}
docker pull ghcr.io/$REPO_OWNER_LOWER/cloudnative-frontend:${COMMIT_SHA}

docker compose -f docker-compose.base.yml -f docker-compose.${INACTIVE_COLOR}.yml up -d

echo "Switching active color to $INACTIVE_COLOR"

echo "ACTIVE_COLOR=$INACTIVE_COLOR" > active_color.env

echo "Restarting reverse proxy..."
docker compose -f docker-compose.base.yml restart reverse-proxy

echo "Deployment done. Active color is now $INACTIVE_COLOR"
