#!/bin/bash

# NZBGet Docker Complete Cleanup Script
# This script will completely remove NZBGet from your Docker setup
# Use with caution - this will delete all data!

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
        print_error "Docker is not running or not accessible. Please start Docker first."
        exit 1
    fi
    print_success "Docker is running"
}

# Function to confirm action
confirm_action() {
    local message="$1"
    echo
    print_warning "$message"
    read -p "Are you sure you want to continue? (yes/no): " -r
    echo
    if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
        print_status "Operation cancelled by user"
        exit 0
    fi
}

# Function to stop and remove NZBGet containers
remove_containers() {
    print_status "Looking for NZBGet containers..."
    
    # Find containers with nzbget in name or image
    local containers=$(docker ps -a --filter "name=nzbget" --format "{{.Names}}" 2>/dev/null || true)
    containers="$containers $(docker ps -a --filter "ancestor=*nzbget*" --format "{{.Names}}" 2>/dev/null || true)"
    
    if [ -z "$containers" ]; then
        print_status "No NZBGet containers found"
        return 0
    fi
    
    print_status "Found NZBGet containers: $containers"
    
    # Stop containers first
    for container in $containers; do
        if [ ! -z "$container" ]; then
            print_status "Stopping container: $container"
            docker stop "$container" 2>/dev/null || true
        fi
    done
    
    # Remove containers
    for container in $containers; do
        if [ ! -z "$container" ]; then
            print_status "Removing container: $container"
            docker rm "$container" 2>/dev/null || true
        fi
    done
    
    print_success "NZBGet containers removed"
}

# Function to remove NZBGet volumes
remove_volumes() {
    print_status "Looking for NZBGet volumes..."
    
    # Find volumes with nzbget in name
    local volumes=$(docker volume ls --filter "name=nzbget" --format "{{.Name}}" 2>/dev/null || true)
    
    if [ -z "$volumes" ]; then
        print_status "No NZBGet volumes found"
        return 0
    fi
    
    print_status "Found NZBGet volumes: $volumes"
    
    for volume in $volumes; do
        if [ ! -z "$volume" ]; then
            print_status "Removing volume: $volume"
            docker volume rm "$volume" 2>/dev/null || true
        fi
    done
    
    print_success "NZBGet volumes removed"
}

# Function to remove NZBGet images
remove_images() {
    print_status "Looking for NZBGet images..."
    
    # Find images with nzbget in name
    local images=$(docker images --filter "reference=*nzbget*" --format "{{.Repository}}:{{.Tag}}" 2>/dev/null || true)
    
    if [ -z "$images" ]; then
        print_status "No NZBGet images found"
        return 0
    fi
    
    print_status "Found NZBGet images: $images"
    
    for image in $images; do
        if [ ! -z "$image" ]; then
            print_status "Removing image: $image"
            docker rmi "$image" 2>/dev/null || true
        fi
    done
    
    print_success "NZBGet images removed"
}

# Function to remove NZBGet networks
remove_networks() {
    print_status "Looking for NZBGet networks..."
    
    # Find networks with nzbget in name
    local networks=$(docker network ls --filter "name=nzbget" --format "{{.Name}}" 2>/dev/null || true)
    
    if [ -z "$networks" ]; then
        print_status "No NZBGet networks found"
        return 0
    fi
    
    print_status "Found NZBGet networks: $networks"
    
    for network in $networks; do
        if [ ! -z "$network" ]; then
            print_status "Removing network: $network"
            docker network rm "$network" 2>/dev/null || true
        fi
    done
    
    print_success "NZBGet networks removed"
}

# Function to clean up orphaned resources
cleanup_orphaned() {
    print_status "Cleaning up orphaned Docker resources..."
    
    # Remove unused volumes
    print_status "Removing unused volumes..."
    docker volume prune -f 2>/dev/null || true
    
    # Remove unused networks
    print_status "Removing unused networks..."
    docker network prune -f 2>/dev/null || true
    
    # Remove unused images
    print_status "Removing unused images..."
    docker image prune -f 2>/dev/null || true
    
    print_success "Orphaned resources cleaned up"
}

# Function to show what will be removed
show_preview() {
    print_status "=== PREVIEW OF WHAT WILL BE REMOVED ==="
    
    echo
    print_status "Containers:"
    docker ps -a --filter "name=nzbget" --format "  {{.Names}} ({{.Status}})" 2>/dev/null || echo "  None found"
    docker ps -a --filter "ancestor=*nzbget*" --format "  {{.Names}} ({{.Status}})" 2>/dev/null || echo "  None found"
    
    echo
    print_status "Volumes:"
    docker volume ls --filter "name=nzbget" --format "  {{.Name}}" 2>/dev/null || echo "  None found"
    
    echo
    print_status "Images:"
    docker images --filter "reference=*nzbget*" --format "  {{.Repository}}:{{.Tag}}" 2>/dev/null || echo "  None found"
    
    echo
    print_status "Networks:"
    docker network ls --filter "name=nzbget" --format "  {{.Name}}" 2>/dev/null || echo "  None found"
    
    echo
}

# Main execution
main() {
    echo "=========================================="
    echo "    NZBGet Docker Complete Cleanup"
    echo "=========================================="
    echo
    
    # Check if Docker is running
    check_docker
    
    # Show preview of what will be removed
    show_preview
    
    # Confirm the action
    confirm_action "This will PERMANENTLY DELETE all NZBGet containers, volumes, images, and networks. All your NZBGet data will be lost!"
    
    # Execute cleanup
    print_status "Starting NZBGet cleanup..."
    
    remove_containers
    remove_volumes
    remove_images
    remove_networks
    cleanup_orphaned
    
    echo
    print_success "NZBGet cleanup completed successfully!"
    print_status "You can now start fresh with NZBGet"
    
    echo
    print_status "To verify cleanup, you can run:"
    echo "  docker ps -a | grep nzbget"
    echo "  docker volume ls | grep nzbget"
    echo "  docker images | grep nzbget"
    echo "  docker network ls | grep nzbget"
}

# Run main function
main "$@"