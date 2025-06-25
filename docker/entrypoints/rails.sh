#!/bin/sh

set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -rf /app/tmp/pids/server.pid
rm -rf /app/tmp/cache/*

echo "Waiting for postgres to become ready...."

# Let DATABASE_URL env take presedence over individual connection params.
# This is done to avoid printing the DATABASE_URL in the logs
if [ -f "docker/entrypoints/helpers/pg_database_url.rb" ]; then
  $(docker/entrypoints/helpers/pg_database_url.rb)
fi

PG_READY="pg_isready -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USERNAME"

until $PG_READY
do
  echo "Waiting for PostgreSQL..."
  sleep 2;
done

echo "Database ready to accept connections."

# Install missing gems for local dev
echo "Installing gems..."
bundle install

# Wait for bundle to be ready
BUNDLE="bundle check"
until $BUNDLE
do
  echo "Waiting for bundle..."
  sleep 2;
done

# Setup database if needed
if [ "$RAILS_ENV" = "development" ]; then
  echo "Setting up development database..."
  bundle exec rails db:create db:migrate db:seed 2>/dev/null || true
fi

# Precompile assets in development if needed
if [ "$RAILS_ENV" = "development" ] && [ ! -d "public/vite" ]; then
  echo "Precompiling assets for development..."
  bundle exec rails assets:precompile 2>/dev/null || true
fi

echo "Rails application starting..."

# Execute the main process of the container
exec "$@"
