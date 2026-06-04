#!/bin/bash
#
# MedNext E2E Test Environment Manager
#
# This script manages the isolated E2E testing environment using docker-compose.test.yml
#
# Usage:
#   ./scripts/e2e-test.sh up        # Start E2E environment
#   ./scripts/e2e-test.sh down      # Stop and remove E2E environment
#   ./scripts/e2e-test.sh reset     # Reset (down + up)
#   ./scripts/e2e-test.sh status    # Check service status
#   ./scripts/e2e-test.sh logs      # View logs
#   ./scripts/e2e-test.sh run       # Run E2E tests
#   ./scripts/e2e-test.sh run:roles # Run role-based tests only
#   ./scripts/e2e-test.sh run:clinic # Run clinic day simulation
#   ./scripts/e2e-test.sh verify    # Verify environment is ready
#   ./scripts/e2e-test.sh full      # Full cycle: reset + run tests

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
COMPOSE_FILE="docker-compose.test.yml"
PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
FRONTEND_DIR="$PROJECT_ROOT/frontend"

# E2E Environment URLs
FRONTEND_URL="http://localhost:25200"
API_URL="http://localhost:25080"
POSTGRES_PORT="25432"
REDIS_PORT="25379"

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        log_error "Docker is not running. Please start Docker first."
        exit 1
    fi
}

# Start E2E environment
cmd_up() {
    log_info "Starting E2E test environment..."
    check_docker

    cd "$PROJECT_ROOT"
    docker compose -f "$COMPOSE_FILE" up -d --build --wait

    log_success "E2E environment started successfully!"
    echo ""
    log_info "Services available at:"
    echo "  Frontend:   $FRONTEND_URL"
    echo "  API:        $API_URL"
    echo "  PostgreSQL: localhost:$POSTGRES_PORT"
    echo "  Redis:      localhost:$REDIS_PORT"
}

# Stop E2E environment
cmd_down() {
    log_info "Stopping E2E test environment..."
    check_docker

    cd "$PROJECT_ROOT"
    docker compose -f "$COMPOSE_FILE" down -v --remove-orphans

    log_success "E2E environment stopped and volumes removed."
}

# Reset E2E environment (down + up)
cmd_reset() {
    log_info "Resetting E2E test environment..."
    cmd_down
    cmd_up
}

# Check status of services
cmd_status() {
    log_info "E2E environment status:"
    check_docker

    cd "$PROJECT_ROOT"
    docker compose -f "$COMPOSE_FILE" ps
}

# View logs
cmd_logs() {
    check_docker
    cd "$PROJECT_ROOT"

    if [ -n "$2" ]; then
        docker compose -f "$COMPOSE_FILE" logs -f "$2"
    else
        docker compose -f "$COMPOSE_FILE" logs -f
    fi
}

# Verify environment is ready
cmd_verify() {
    log_info "Verifying E2E environment..."

    # Check API health
    log_info "Checking API health..."
    if curl -s -f "$API_URL/health" > /dev/null 2>&1; then
        log_success "API is healthy"
    else
        log_error "API is not responding at $API_URL/health"
        return 1
    fi

    # Check Frontend
    log_info "Checking Frontend..."
    if curl -s -f "$FRONTEND_URL" > /dev/null 2>&1; then
        log_success "Frontend is accessible"
    else
        log_error "Frontend is not responding at $FRONTEND_URL"
        return 1
    fi

    # Check PostgreSQL
    log_info "Checking PostgreSQL..."
    if docker exec mednext-postgres-test pg_isready -U mednext_test > /dev/null 2>&1; then
        log_success "PostgreSQL is ready"
    else
        log_error "PostgreSQL is not ready"
        return 1
    fi

    # Check Redis
    log_info "Checking Redis..."
    if docker exec mednext-redis-test redis-cli ping > /dev/null 2>&1; then
        log_success "Redis is ready"
    else
        log_error "Redis is not ready"
        return 1
    fi

    # Verify seed data
    log_info "Verifying seed data..."
    USER_COUNT=$(docker exec mednext-postgres-test psql -U mednext_test -d mednext_test -t -c "SELECT COUNT(*) FROM users;" 2>/dev/null | tr -d ' ')
    if [ "$USER_COUNT" -gt 0 ]; then
        log_success "Seed data present ($USER_COUNT users found)"
    else
        log_warning "No seed data found"
    fi

    echo ""
    log_success "E2E environment is ready!"
    return 0
}

# Run E2E tests
cmd_run() {
    log_info "Running E2E tests..."

    # Verify environment first
    if ! cmd_verify; then
        log_error "Environment not ready. Run './scripts/e2e-test.sh up' first."
        exit 1
    fi

    cd "$FRONTEND_DIR"
    PLAYWRIGHT_BASE_URL="$FRONTEND_URL" API_URL="$API_URL" npx playwright test -c playwright.config.e2e.ts "$@"
}

# Run role-based tests only
cmd_run_roles() {
    log_info "Running role-based E2E tests..."

    cd "$FRONTEND_DIR"
    PLAYWRIGHT_BASE_URL="$FRONTEND_URL" API_URL="$API_URL" npx playwright test -c playwright.config.e2e.ts --grep '@role' "$@"
}

# Run workflow tests only
cmd_run_workflows() {
    log_info "Running workflow E2E tests..."

    cd "$FRONTEND_DIR"
    PLAYWRIGHT_BASE_URL="$FRONTEND_URL" API_URL="$API_URL" npx playwright test -c playwright.config.e2e.ts --grep '@workflow' "$@"
}

# Run clinic day simulation
cmd_run_clinic() {
    log_info "Running clinic day simulation E2E tests..."

    cd "$FRONTEND_DIR"
    PLAYWRIGHT_BASE_URL="$FRONTEND_URL" API_URL="$API_URL" npx playwright test -c playwright.config.e2e.ts clinic-day-simulation "$@"
}

# Full cycle: reset + run
cmd_full() {
    log_info "Running full E2E test cycle..."
    cmd_reset
    sleep 5  # Give services time to fully initialize
    cmd_run "$@"
}

# Show report
cmd_report() {
    log_info "Opening E2E test report..."
    cd "$FRONTEND_DIR"
    npx playwright show-report playwright-report-e2e
}

# Show usage
show_usage() {
    echo "MedNext E2E Test Environment Manager"
    echo ""
    echo "Usage: $0 <command> [options]"
    echo ""
    echo "Commands:"
    echo "  up          Start E2E test environment"
    echo "  down        Stop and remove E2E environment (including volumes)"
    echo "  reset       Reset environment (down + up)"
    echo "  status      Show status of E2E services"
    echo "  logs [svc]  View logs (optionally for specific service)"
    echo "  verify      Verify environment is ready for testing"
    echo "  run         Run all E2E tests"
    echo "  run:roles   Run role-based tests only (@role tag)"
    echo "  run:flows   Run workflow tests only (@workflow tag)"
    echo "  run:clinic  Run clinic day simulation"
    echo "  full        Full cycle: reset + run all tests"
    echo "  report      Open the test report"
    echo ""
    echo "Examples:"
    echo "  $0 up                    # Start environment"
    echo "  $0 run                   # Run all tests"
    echo "  $0 run --headed          # Run tests with browser visible"
    echo "  $0 run:roles             # Run only role tests"
    echo "  $0 logs api-test         # View API logs"
    echo "  $0 full --project=chromium  # Reset and run on Chromium only"
    echo ""
    echo "E2E Environment Ports:"
    echo "  Frontend:   25200"
    echo "  API:        25080"
    echo "  PostgreSQL: 25432"
    echo "  Redis:      25379"
}

# Main
case "${1:-}" in
    up)
        cmd_up
        ;;
    down)
        cmd_down
        ;;
    reset)
        cmd_reset
        ;;
    status)
        cmd_status
        ;;
    logs)
        cmd_logs "$@"
        ;;
    verify)
        cmd_verify
        ;;
    run)
        shift
        cmd_run "$@"
        ;;
    run:roles)
        shift
        cmd_run_roles "$@"
        ;;
    run:flows|run:workflows)
        shift
        cmd_run_workflows "$@"
        ;;
    run:clinic)
        shift
        cmd_run_clinic "$@"
        ;;
    full)
        shift
        cmd_full "$@"
        ;;
    report)
        cmd_report
        ;;
    help|--help|-h|"")
        show_usage
        ;;
    *)
        log_error "Unknown command: $1"
        show_usage
        exit 1
        ;;
esac
