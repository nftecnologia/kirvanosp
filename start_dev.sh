#!/bin/bash

# Kirvano Local Development Startup Script
# This script starts the complete local development environment

echo "🚀 Starting Kirvano Local Development Environment..."

# Ensure PostgreSQL and Redis are running
echo "📦 Checking services..."
brew services list | grep -q "postgresql@15.*started" || {
    echo "⚡ Starting PostgreSQL..."
    brew services start postgresql@15
}

brew services list | grep -q "redis.*started" || {
    echo "⚡ Starting Redis..."
    brew services start redis
}

# Export PostgreSQL path
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"

# Ensure we're using the local environment
cp .env.local .env

echo "✅ Services ready!"
echo ""
echo "🔧 Starting development servers..."
echo "   - Rails server will be available at: http://localhost:3000"
echo "   - Vite dev server will be available at: http://localhost:3036"
echo "   - Sidekiq worker will process background jobs"
echo ""
echo "📝 To stop all services, press Ctrl+C"
echo ""

# Start all services with overmind
overmind start -f ./Procfile.dev