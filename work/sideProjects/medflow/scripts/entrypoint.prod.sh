#!/bin/sh
set -e

echo "=== MedNext Backend Entrypoint ==="

# Wait for PostgreSQL
echo "Waiting for PostgreSQL..."
until pg_isready -h "$MEDNEXT_DATABASE_HOST" -p "$MEDNEXT_DATABASE_PORT" -U "$MEDNEXT_DATABASE_USER"; do
  sleep 2
done
echo "PostgreSQL is ready!"

PSQL_CMD="PGPASSWORD=$MEDNEXT_DATABASE_PASSWORD psql -h $MEDNEXT_DATABASE_HOST -p $MEDNEXT_DATABASE_PORT -U $MEDNEXT_DATABASE_USER -d $MEDNEXT_DATABASE_DATABASE"

# Always run schema
echo "Running database schema..."
eval $PSQL_CMD -f /app/db/init/01_schema.sql || echo "Schema already exists"

# Run goose migrations
echo "Running goose migrations..."
DATABASE_URL="postgres://${MEDNEXT_DATABASE_USER}:${MEDNEXT_DATABASE_PASSWORD}@${MEDNEXT_DATABASE_HOST}:${MEDNEXT_DATABASE_PORT}/${MEDNEXT_DATABASE_DATABASE}?sslmode=${MEDNEXT_DATABASE_SSL_MODE:-disable}"
goose -dir /app/db/migrations postgres "$DATABASE_URL" up || echo "Goose migrations completed (or already applied)"

# Run seeds only if RUN_SEEDS=true
if [ "$RUN_SEEDS" = "true" ]; then
  echo "RUN_SEEDS=true - Running seed data..."

  # Run legacy init seeds
  eval $PSQL_CMD -f /app/db/init/02_users.sql || echo "Users seed exists"
  eval $PSQL_CMD -f /app/db/init/03_seed_data.sql || echo "Seed data exists"

  # Run comprehensive seeds (00_clean through 09_reviews)
  if [ -d /app/seeds ]; then
    echo "Running comprehensive seeds from /app/seeds/..."
    for f in /app/seeds/[0-9]*.sql; do
      if [ -f "$f" ]; then
        echo "  Running $(basename $f)..."
        eval $PSQL_CMD -f "$f" || echo "  Warning: $(basename $f) had errors (may be idempotent)"
      fi
    done
    echo "Comprehensive seeds completed!"
  fi

  echo "All seeds completed!"
else
  echo "RUN_SEEDS not set to 'true' - Skipping seed data"
fi

echo "Starting MedNext API..."
exec "$@"
