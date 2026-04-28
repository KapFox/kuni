#!/bin/bash

# Kuni Setup Script for Ubuntu and Arch Linux
# This script automates the initial setup process

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Detect distribution
detect_distro() {
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        DISTRO=$ID
        echo -e "${GREEN}Detected distribution: ${DISTRO}${NC}"
    else
        echo -e "${RED}Cannot detect distribution. Please run manually.${NC}"
        exit 1
    fi
}

# Install dependencies based on distribution
install_dependencies() {
    echo -e "${YELLOW}Installing dependencies...${NC}"
    
    case $DISTRO in
        ubuntu|debian)
            echo -e "${GREEN}Installing packages for Ubuntu/Debian...${NC}"
            sudo apt update
            sudo apt install -y \
                pkg-config \
                libfontconfig-dev \
                libxcursor-dev \
                libxi-dev \
                libxrandr-dev \
                libglew-dev \
                libpulse-dev \
                libdbus-1-dev \
                libepoxy-dev \
                gperf \
                cmake \
                git \
                build-essential
            ;;
        arch|manjaro|endeavouros)
            echo -e "${GREEN}Installing packages for Arch Linux...${NC}"
            sudo pacman -Sy --noconfirm \
                pkgconf \
                fontconfig \
                libxcursor \
                libxi \
                libxrandr \
                glew \
                gcc \
                pulseaudio \
                libepoxy \
                gperf \
                cmake \
                git \
                base-devel
            ;;
        fedora)
            echo -e "${GREEN}Installing packages for Fedora...${NC}"
            sudo dnf install -y \
                fontconfig-devel \
                libXi \
                libglvnd-devel \
                glew-devel \
                pulseaudio-libs-devel \
                libepoxy-devel \
                gperf \
                cmake \
                git \
                gcc-c++
            ;;
        *)
            echo -e "${RED}Unsupported distribution: ${DISTRO}${NC}"
            echo "Please install dependencies manually."
            exit 1
            ;;
    esac
    
    echo -e "${GREEN}Dependencies installed successfully!${NC}"
}

# Check and install Docker
setup_docker() {
    echo -e "${YELLOW}Checking Docker installation...${NC}"
    
    if ! command -v docker &> /dev/null; then
        echo -e "${YELLOW}Docker not found. Installing Docker...${NC}"
        
        case $DISTRO in
            ubuntu|debian)
                curl -fsSL https://get.docker.com -o get-docker.sh
                sudo sh get-docker.sh
                rm get-docker.sh
                ;;
            arch|manjaro|endeavouros)
                sudo pacman -S --noconfirm docker docker-compose
                ;;
            fedora)
                sudo dnf install -y docker docker-compose
                ;;
            *)
                echo -e "${RED}Please install Docker manually for ${DISTRO}${NC}"
                return 1
                ;;
        esac
        
        echo -e "${GREEN}Docker installed successfully!${NC}"
    else
        echo -e "${GREEN}Docker is already installed.${NC}"
    fi
    
    # Add user to docker group (if not already added)
    if ! groups | grep -q docker; then
        echo -e "${YELLOW}Adding user to docker group...${NC}"
        sudo usermod -aG docker $USER
        echo -e "${GREEN}User added to docker group. Please log out and log back in.${NC}"
    fi
    
    # Start and enable Docker service
    if systemctl is-active --quiet docker; then
        echo -e "${GREEN}Docker service is running.${NC}"
    else
        echo -e "${YELLOW}Starting Docker service...${NC}"
        sudo systemctl start docker
        sudo systemctl enable docker
        echo -e "${GREEN}Docker service started and enabled.${NC}"
    fi
}

# Setup environment file
setup_env() {
    echo -e "${YELLOW}Setting up environment file...${NC}"
    
    if [ ! -f .env ]; then
        cp .env.example .env
        echo -e "${GREEN}Created .env file from .env.example${NC}"
        echo -e "${YELLOW}Please edit .env to configure your setup:${NC}"
        echo "  - Set ENABLE_OLLAMA=false if using external LLM server"
        echo "  - Set ENABLE_SD=false if using external Stable Diffusion server"
        echo "  - Configure GPU settings if needed"
    else
        echo -e "${GREEN}.env file already exists.${NC}"
    fi
}

# Build instructions
show_build_instructions() {
    echo -e "\n${GREEN}========================================${NC}"
    echo -e "${GREEN}Setup complete! Next steps:${NC}"
    echo -e "${GREEN}========================================${NC}\n"
    
    echo -e "${YELLOW}1. Create secrets file:${NC}"
    echo "   mkdir -p build/secrets"
    echo "   nano build/secrets/secrets.h"
    echo "   (Add your Telegram API credentials)"
    echo ""
    
    echo -e "${YELLOW}2. Build the project:${NC}"
    echo "   cmake -B build -DCMAKE_BUILD_TYPE=Release"
    echo "   cmake --build build"
    echo ""
    
    echo -e "${YELLOW}3. Run AI services (if using local containers):${NC}"
    echo "   docker compose up -d"
    echo "   (Skip if using external servers)"
    echo ""
    
    echo -e "${YELLOW}4. Run the application:${NC}"
    echo "   ./build/bin/kuni"
    echo ""
    
    echo -e "${YELLOW}5. Run tests (optional):${NC}"
    echo "   cmake --build build --target Tests"
    echo "   cd build/bin && ./Tests"
    echo ""
}

# Main execution
main() {
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}Kuni Setup Script${NC}"
    echo -e "${GREEN}========================================${NC}\n"
    
    detect_distro
    install_dependencies
    setup_docker
    setup_env
    show_build_instructions
    
    echo -e "${GREEN}Setup completed successfully!${NC}"
    echo -e "${YELLOW}Note: If you were added to the docker group, please log out and log back in.${NC}"
}

# Run main function
main "$@"
