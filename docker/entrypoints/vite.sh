#!/bin/sh
set -e

echo "Starting Vite development server setup..."

# Clean up temporary files
rm -rf /app/tmp/pids/server.pid
rm -rf /app/tmp/cache/*

# Clean pnpm store and reinstall dependencies
echo "Installing Node dependencies..."
pnpm store prune
pnpm install --frozen-lockfile

# Ensure Vite can write to cache directory
mkdir -p /app/.vite
chmod 755 /app/.vite

# Wait a moment for Rails server to be available
echo "Waiting for Rails server to be ready..."
sleep 10

echo "Starting Vite development server with HMR..."

exec "$@"
