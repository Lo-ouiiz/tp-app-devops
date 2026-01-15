#!/bin/bash
set -e

cd "$(dirname "$0")/.."

# Récupère l'image à déployer depuis la CI
REPO_OWNER_LOWER=$(echo "${GITHUB_REPOSITORY_OWNER}" | tr '[:upper:]' '[:lower:]')

echo "Pulling latest images from registry..."
docker pull ghcr.io/$REPO_OWNER_LOWER/cloudnative-backend:${GITHUB_SHA}
docker pull ghcr.io/$REPO_OWNER_LOWER/cloudnative-frontend:${GITHUB_SHA}

# Determine inactive color
if [ -f active_color.env ]; then
  source active_color.env
  if [ "$ACTIVE_COLOR" = "blue" ]; then
    INACTIVE_COLOR="green"
  else
    INACTIVE_COLOR="blue"
  fi
else
  # Default to green if file doesn't exist
  INACTIVE_COLOR="green"
fi

echo "Deploying $INACTIVE_COLOR version..."
docker compose -f docker-compose.base.yml -f docker-compose.${INACTIVE_COLOR}.yml up -d

# Update active color for the proxy
echo "Updating active color to $INACTIVE_COLOR..."
echo "ACTIVE_COLOR=$INACTIVE_COLOR" > active_color.env
docker compose -f docker-compose.base.yml -f docker-compose.proxy.yml exec reverse-proxy nginx -s reload

echo "Blue/Green deployment completed. Active color: $INACTIVE_COLOR"
