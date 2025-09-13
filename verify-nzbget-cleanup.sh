#!/bin/bash

# NZBGet Docker Verification Script
# This script checks if NZBGet is completely removed from Docker

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Function to check if Docker is running
check_docker() {
    if ! docker info >/dev/null 2>&1; then
        print_error "Docker is not running or not accessible."
        exit 1
    fi
}

# Function to check for NZBGet containers
check_containers() {
    print_status "Checking for NZBGet containers..."
    
    local containers=$(docker ps -a --filter "name=nzbget" --format "{{.Names}}" 2>/dev/null || true)
    containers="$containers $(docker ps -a --filter "ancestor=*nzbget*" --format "{{.Names}}" 2>/dev/null || true)"
    
    if [ -z "$containers" ]; then
        print_success "No NZBGet containers found"
        return 0
    else
        print_error "Found NZBGet containers: $containers"
        return 1
    fi
}

# Function to check for NZBGet volumes
check_volumes() {
    print_status "Checking for NZBGet volumes..."
    
    local volumes=$(docker volume ls --filter "name=nzbget" --format "{{.Name}}" 2>/dev/null || true)
    
    if [ -z "$volumes" ]; then
        print_success "No NZBGet volumes found"
        return 0
    else
        print_error "Found NZBGet volumes: $volumes"
        return 1
    fi
}

# Function to check for NZBGet images
check_images() {
    print_status "Checking for NZBGet images..."
    
    local images=$(docker images --filter "reference=*nzbget*" --format "{{.Repository}}:{{.Tag}}" 2>/dev/null || true)
    
    if [ -z "$images" ]; then
        print_success "No NZBGet images found"
        return 0
    else
        print_error "Found NZBGet images: $images"
        return 1
    fi
}

# Function to check for NZBGet networks
check_networks() {
    print_status "Checking for NZBGet networks..."
    
    local networks=$(docker network ls --filter "name=nzbget" --format "{{.Name}}" 2>/dev/null || true)
    
    if [ -z "$networks" ]; then
        print_success "No NZBGet networks found"
        return 0
    else
        print_error "Found NZBGet networks: $networks"
        return 1
    fi
}

# Function to show detailed Docker status
show_docker_status() {
    print_status "=== CURRENT DOCKER STATUS ==="
    
    echo
    print_status "All containers:"
    docker ps -a --format "  {{.Names}} ({{.Status}}) - {{.Image}}" 2>/dev/null || echo "  No containers found"
    
    echo
    print_status "All volumes:"
    docker volume ls --format "  {{.Name}}" 2>/dev/null || echo "  No volumes found"
    
    echo
    print_status "All images:"
    docker images --format "  {{.Repository}}:{{.Tag}}" 2>/dev/null || echo "  No images found"
    
    echo
    print_status "All networks:"
    docker network ls --format "  {{.Name}}" 2>/dev/null || echo "  No networks found"
    
    echo
}

# Main execution
main() {
    echo "=========================================="
    echo "    NZBGet Docker Verification"
    echo "=========================================="
    echo
    
    # Check if Docker is running
    check_docker
    
    local cleanup_needed=false
    
    # Check each component
    if ! check_containers; then
        cleanup_needed=true
    fi
    
    if ! check_volumes; then
        cleanup_needed=true
    fi
    
    if ! check_images; then
        cleanup_needed=true
    fi
    
    if ! check_networks; then
        cleanup_needed=true
    fi
    
    echo
    if [ "$cleanup_needed" = true ]; then
        print_warning "NZBGet cleanup is needed. Run ./wipe-nzbget.sh to clean up."
    else
        print_success "NZBGet is completely removed from Docker!"
    fi
    
    echo
    show_docker_status
}

# Run main function
main "$@"