#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Repository information
REPO_OWNER="reddevs-io"
REPO_NAME="kubernetes-binaries-managers"
GITHUB_REPO="${REPO_OWNER}/${REPO_NAME}"

# Installation directory
INSTALL_DIR="/usr/local/bin"

# Helper functions
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect OS
detect_os() {
    case "$(uname -s)" in
        Linux*)
            echo "linux"
            ;;
        Darwin*)
            echo "darwin"
            ;;
        *)
            print_error "Unsupported operating system: $(uname -s)"
            print_error "Supported OS: Linux, Darwin (macOS)"
            exit 1
            ;;
    esac
}

# Detect architecture
detect_arch() {
    local arch=$(uname -m)
    case "$arch" in
        x86_64)
            echo "amd64"
            ;;
        amd64)
            echo "amd64"
            ;;
        arm64)
            echo "arm64"
            ;;
        aarch64)
            echo "arm64"
            ;;
        *)
            print_error "Unsupported architecture: $arch"
            print_error "Supported architectures: amd64, arm64"
            exit 1
            ;;
    esac
}

# Get latest release version from GitHub API
get_latest_version() {
    print_info "Fetching latest release information..."
    
    local api_url="https://api.github.com/repos/${GITHUB_REPO}/releases/latest"
    local version
    
    # Try to get version using curl
    if command -v curl >/dev/null 2>&1; then
        version=$(curl -sSf "$api_url" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    # Fallback to wget
    elif command -v wget >/dev/null 2>&1; then
        version=$(wget -qO- "$api_url" | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/')
    else
        print_error "Neither curl nor wget is installed. Please install one of them."
        exit 1
    fi
    
    if [ -z "$version" ]; then
        print_error "Failed to fetch the latest release version"
        print_error "Please check your internet connection and try again"
        exit 1
    fi
    
    echo "$version"
}

# Download and extract the archive
download_and_install() {
    local version=$1
    local os=$2
    local arch=$3
    
    # Construct download URL
    local archive_name="${REPO_NAME}_${version}_${os}_${arch}.tar.gz"
    local download_url="https://github.com/${GITHUB_REPO}/releases/download/${version}/${archive_name}"
    
    print_info "Downloading ${archive_name}..."
    
    # Create temporary directory
    local tmp_dir=$(mktemp -d)
    trap "rm -rf $tmp_dir" EXIT
    
    local archive_path="${tmp_dir}/${archive_name}"
    
    # Download the archive
    if command -v curl >/dev/null 2>&1; then
        if ! curl -sSfL "$download_url" -o "$archive_path"; then
            print_error "Failed to download from: $download_url"
            exit 1
        fi
    elif command -v wget >/dev/null 2>&1; then
        if ! wget -q "$download_url" -O "$archive_path"; then
            print_error "Failed to download from: $download_url"
            exit 1
        fi
    fi
    
    print_info "Extracting binaries..."
    
    # Extract to temporary directory
    if ! tar -xzf "$archive_path" -C "$tmp_dir"; then
        print_error "Failed to extract archive"
        exit 1
    fi
    
    # Check if we have permission to write to INSTALL_DIR
    if [ ! -w "$INSTALL_DIR" ]; then
        print_warning "No write permission to $INSTALL_DIR"
        print_info "Attempting to install with sudo..."
        USE_SUDO="sudo"
    else
        USE_SUDO=""
    fi
    
    # Install binaries from all subdirectories
    local installed_count=0
    for dir in "$tmp_dir"/*-"${os}"-"${arch}"; do
        if [ -d "$dir" ]; then
            for binary in "$dir"/*; do
                if [ -f "$binary" ] && [ -x "$binary" ]; then
                    local binary_name=$(basename "$binary")
                    print_info "Installing ${binary_name} to ${INSTALL_DIR}..."
                    if $USE_SUDO cp "$binary" "${INSTALL_DIR}/${binary_name}"; then
                        $USE_SUDO chmod +x "${INSTALL_DIR}/${binary_name}"
                        ((installed_count++))
                    else
                        print_error "Failed to install ${binary_name}"
                    fi
                fi
            done
        fi
    done
    
    if [ $installed_count -eq 0 ]; then
        print_error "No binaries were installed"
        exit 1
    fi
    
    print_info "Successfully installed $installed_count binary/binaries"
}

# Main installation flow
main() {
    echo "=========================================="
    echo "Kubernetes Binaries Managers Installer"
    echo "=========================================="
    echo ""
    
    # Detect system
    OS=$(detect_os)
    ARCH=$(detect_arch)
    
    print_info "Detected OS: $OS"
    print_info "Detected Architecture: $ARCH"
    echo ""
    
    # Get latest version
    VERSION=$(get_latest_version)
    print_info "Latest version: $VERSION"
    echo ""
    
    # Download and install
    download_and_install "$VERSION" "$OS" "$ARCH"
    
    echo ""
    echo "=========================================="
    print_info "Installation complete!"
    echo "=========================================="
    echo ""
    print_info "Installed binaries:"
    print_info "  - helmenv: Helm version manager"
    print_info "  - helm-wrapper: Helm wrapper"
    print_info "  - kbenv: kubectl version manager"
    print_info "  - kubectl-wrapper: kubectl wrapper"
    print_info "  - ocenv: oc (OpenShift CLI) version manager"
    print_info "  - oc-wrapper: oc wrapper"
    echo ""
    print_info "Run 'helmenv --help', 'kbenv --help', or 'ocenv --help' to get started"
}

# Run main function
main
