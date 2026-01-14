set -e

echo "Stopping existing containers..."
docker compose down

echo "Pulling latest images from registry..."
REPO_OWNER_LOWER=$(echo "${GITHUB_REPOSITORY_OWNER}" | tr '[:upper:]' '[:lower:]')

docker pull ghcr.io/$REPO_OWNER_LOWER/cloudnative-backend:${GITHUB_SHA}
docker pull ghcr.io/$REPO_OWNER_LOWER/cloudnative-frontend:${GITHUB_SHA}

echo "Starting containers..."
docker compose up -d

echo "Deployment completed successfully!"
