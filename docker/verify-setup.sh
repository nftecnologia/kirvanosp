#!/bin/bash

# Docker Development Environment Verification Script
# This script verifies that the Docker setup is working correctly

set -e

echo "🐳 Kirvano Docker Development Environment Verification"
echo "=================================================="
echo ""

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    if [ $2 -eq 0 ]; then
        echo -e "${GREEN}✅ $1${NC}"
    else
        echo -e "${RED}❌ $1${NC}"
    fi
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "ℹ️  $1"
}

# Check if Docker is installed and running
echo "Checking Docker installation..."
if command -v docker &> /dev/null; then
    if docker info &> /dev/null; then
        print_status "Docker is installed and running" 0
    else
        print_status "Docker is installed but not running" 1
        echo "Please start Docker Desktop or Docker daemon"
        exit 1
    fi
else
    print_status "Docker is not installed" 1
    echo "Please install Docker Desktop or Docker Engine"
    exit 1
fi

# Check if Docker Compose is available
echo ""
echo "Checking Docker Compose..."
if docker-compose --version &> /dev/null || docker compose version &> /dev/null; then
    print_status "Docker Compose is available" 0
else
    print_status "Docker Compose is not available" 1
    exit 1
fi

# Check if environment file exists
echo ""
echo "Checking environment configuration..."
if [ -f ".env.docker" ]; then
    print_status "Environment file (.env.docker) exists" 0
else
    print_warning "Environment file (.env.docker) not found"
    echo "Creating from template..."
    cp .env.docker.example .env.docker
    print_status "Created .env.docker from template" 0
fi

# Check if SSL certificates exist
echo ""
echo "Checking SSL certificates..."
if [ -f "docker/nginx/ssl/dev.crt" ] && [ -f "docker/nginx/ssl/dev.key" ]; then
    print_status "SSL certificates exist" 0
else
    print_warning "SSL certificates not found"
    echo "Run 'docker/nginx/ssl/generate-certs.sh' to create them"
fi

# Check available memory
echo ""
echo "Checking system resources..."
if command -v docker &> /dev/null; then
    DOCKER_MEMORY=$(docker system info --format '{{.MemTotal}}' 2>/dev/null || echo "0")
    if [ "$DOCKER_MEMORY" -gt 8000000000 ]; then
        print_status "Docker has sufficient memory allocated (>8GB)" 0
    else
        print_warning "Docker may have insufficient memory allocated"
        echo "Consider increasing Docker memory allocation to 8GB or more"
    fi
fi

# Check for port conflicts
echo ""
echo "Checking for port conflicts..."
PORTS=(3000 3036 5432 6379 80 443 1025 1080 8080)
CONFLICTS=0

for port in "${PORTS[@]}"; do
    if lsof -i :$port &> /dev/null; then
        print_warning "Port $port is already in use"
        CONFLICTS=$((CONFLICTS + 1))
    fi
done

if [ $CONFLICTS -eq 0 ]; then
    print_status "No port conflicts detected" 0
else
    print_warning "$CONFLICTS port(s) may conflict with Docker services"
    echo "Consider stopping conflicting services or modifying port mappings"
fi

# Verify Docker Compose file syntax
echo ""
echo "Validating Docker Compose configuration..."
if docker-compose -f docker-compose.dev.yml config &> /dev/null; then
    print_status "Docker Compose configuration is valid" 0
else
    print_status "Docker Compose configuration has errors" 1
    echo "Run 'docker-compose -f docker-compose.dev.yml config' to see details"
fi

# Check if images need to be built
echo ""
echo "Checking Docker images..."
if docker images | grep -q "kirvano.*development"; then
    print_status "Development images exist" 0
else
    print_warning "Development images not found"
    echo "Run 'docker-compose -f docker-compose.dev.yml build' to build them"
fi

# Test basic functionality if services are running
echo ""
echo "Testing running services..."
if docker-compose -f docker-compose.dev.yml ps | grep -q "Up"; then
    print_info "Some services are running, testing connectivity..."
    
    # Test Rails application
    if curl -f http://localhost:3000/up &> /dev/null; then
        print_status "Rails application is responding" 0
    else
        print_warning "Rails application is not responding"
    fi
    
    # Test Vite dev server
    if curl -f http://localhost:3036/ &> /dev/null; then
        print_status "Vite dev server is responding" 0
    else
        print_warning "Vite dev server is not responding"
    fi
    
    # Test PostgreSQL
    if docker-compose -f docker-compose.dev.yml exec -T postgres pg_isready -U kirvano &> /dev/null; then
        print_status "PostgreSQL is responding" 0
    else
        print_warning "PostgreSQL is not responding"
    fi
    
    # Test Redis
    if docker-compose -f docker-compose.dev.yml exec -T redis redis-cli ping &> /dev/null; then
        print_status "Redis is responding" 0
    else
        print_warning "Redis is not responding"
    fi
else
    print_info "No services are currently running"
    echo "Run 'docker-compose -f docker-compose.dev.yml up -d' to start services"
fi

echo ""
echo "=================================================="
echo "🎉 Verification complete!"
echo ""
echo "Next steps:"
echo "1. If not already done, run: make -f Makefile.docker setup"
echo "2. Start services: make -f Makefile.docker up"
echo "3. Access the application: http://localhost:3000"
echo ""
echo "For more commands, run: make -f Makefile.docker help"
echo "For detailed documentation, see: DOCKER_DEVELOPMENT.md"