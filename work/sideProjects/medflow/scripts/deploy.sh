#!/usr/bin/env bash
set -euo pipefail

# MedNext Deploy Script - Build, push Docker images and trigger Dokploy redeploy
# Usage: ./scripts/deploy.sh [backend|frontend|all]

DOCKER_REGISTRY="jordanlanch"
DOKPLOY_URL="http://138.197.89.224:3000"
DOKPLOY_API_KEY="${DOKPLOY_API_KEY:-cNuyOnaGWvfIdjIokrLfWoamcoLcQVyNIWvbOYLQNiWXVeIenIynVUoSNKvkrwZk}"

# Dokploy compose IDs
BACKEND_COMPOSE_ID="Le2uP9dm1qImrAe_Z8_yA"
FRONTEND_COMPOSE_ID="WSsXHlxcqGwpmQgiaU36W"

TARGET="${1:-all}"
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"

# Generate unique tag from git commit + timestamp to avoid Docker cache issues
GIT_HASH="$(cd "$ROOT_DIR" && git rev-parse --short HEAD 2>/dev/null || echo 'nogit')"
TIMESTAMP="$(date +%Y%m%d%H%M%S)"
DEFAULT_TAG="${GIT_HASH}-${TIMESTAMP}"
TAG="${2:-$DEFAULT_TAG}"

if [ "$TAG" = "latest" ]; then
    echo "⚠️  WARNING: Using 'latest' tag may cause Docker cache issues in Dokploy."
    echo "   Consider using a unique tag or the default generated tag."
    echo "   Usage: $0 [backend|frontend|all] [unique-tag]"
fi

dokploy_redeploy() {
    local compose_id="$1"
    local name="$2"
    echo "  Triggering Dokploy redeploy for $name..."
    local response
    response=$(curl -s -w "\n%{http_code}" -X POST \
        "${DOKPLOY_URL}/api/compose.deploy" \
        -H "x-api-key: ${DOKPLOY_API_KEY}" \
        -H "Content-Type: application/json" \
        -d "{\"composeId\": \"${compose_id}\"}")
    local http_code
    http_code=$(echo "$response" | tail -1)
    local body
    body=$(echo "$response" | sed '$d')
    if [ "$http_code" -ge 200 ] && [ "$http_code" -lt 300 ]; then
        echo "  ✓ $name redeploy triggered (HTTP $http_code)"
    else
        echo "  ✗ $name redeploy failed (HTTP $http_code): $body"
        return 1
    fi
}

deploy_backend() {
    echo "━━━ Backend ━━━"
    echo "  Building image (no cache)..."
    docker build --no-cache -t "${DOCKER_REGISTRY}/mednext-backend:${TAG}" -f "${ROOT_DIR}/backend/Dockerfile.prod" "${ROOT_DIR}/backend"
    echo "  Tagging as latest..."
    docker tag "${DOCKER_REGISTRY}/mednext-backend:${TAG}" "${DOCKER_REGISTRY}/mednext-backend:latest"
    echo "  Pushing to Docker Hub..."
    docker push "${DOCKER_REGISTRY}/mednext-backend:${TAG}"
    docker push "${DOCKER_REGISTRY}/mednext-backend:latest"
    echo "  ✓ Image pushed: ${DOCKER_REGISTRY}/mednext-backend:${TAG} and :latest"
    dokploy_redeploy "$BACKEND_COMPOSE_ID" "backend"
}

deploy_frontend() {
    echo "━━━ Frontend ━━━"
    echo "  Building image (no cache)..."
    docker build --no-cache -t "${DOCKER_REGISTRY}/mednext-frontend:${TAG}" \
        -f "${ROOT_DIR}/frontend/Dockerfile.prod" \
        --build-arg API_URL=https://api.mednext.cloud \
        "${ROOT_DIR}/frontend"
    echo "  Tagging as latest..."
    docker tag "${DOCKER_REGISTRY}/mednext-frontend:${TAG}" "${DOCKER_REGISTRY}/mednext-frontend:latest"
    echo "  Pushing to Docker Hub..."
    docker push "${DOCKER_REGISTRY}/mednext-frontend:${TAG}"
    docker push "${DOCKER_REGISTRY}/mednext-frontend:latest"
    echo "  ✓ Image pushed: ${DOCKER_REGISTRY}/mednext-frontend:${TAG} and :latest"
    dokploy_redeploy "$FRONTEND_COMPOSE_ID" "frontend"
}

echo "╔══════════════════════════════════════╗"
echo "║  MedNext Deploy — target: ${TARGET}        ║"
echo "╚══════════════════════════════════════╝"
echo ""

case "$TARGET" in
    backend)  deploy_backend ;;
    frontend) deploy_frontend ;;
    all)      deploy_backend; echo ""; deploy_frontend ;;
    *)        echo "Usage: $0 [backend|frontend|all] [tag]"; exit 1 ;;
esac

echo ""
echo "✓ Deploy complete!"
