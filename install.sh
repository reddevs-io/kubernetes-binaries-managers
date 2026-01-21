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

# Available binaries
ALL_BINARIES="helmenv helm-wrapper kbenv kubectl-wrapper ocenv oc-wrapper"

# Selected binaries (empty means install all)
SELECTED_BINARIES=""

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

# Display usage information
show_help() {
    cat << EOF
Kubernetes Binaries Managers Installer

Usage: $0 [OPTIONS]

Options:
  -b, --binaries <list>    Comma-separated list of binaries to install
                           Available binaries:
                             - helmenv
                             - helm-wrapper
                             - kbenv
                             - kubectl-wrapper
                             - ocenv
                             - oc-wrapper
                           Example: --binaries helmenv,kbenv
                           
  -h, --help               Display this help message

If no binaries are specified, all binaries will be installed.

Examples:
  $0                                    # Install all binaries
  $0 --binaries helmenv,helm-wrapper   # Install only helmenv and helm-wrapper
  $0 -b kbenv,kubectl-wrapper          # Install only kbenv and kubectl-wrapper
EOF
    exit 0
}

# Validate that a binary name is in the available list
is_valid_binary() {
    local binary=$1
    for valid in $ALL_BINARIES; do
        if [ "$binary" = "$valid" ]; then
            return 0
        fi
    done
    return 1
}

# Parse command-line arguments
parse_arguments() {
    while [ $# -gt 0 ]; do
        case "$1" in
            -h|--help)
                show_help
                ;;
            -b|--binaries)
                if [ -z "$2" ] || [ "${2:0:1}" = "-" ]; then
                    print_error "Option -b/--binaries requires a comma-separated list of binaries"
                    echo ""
                    show_help
                fi
                SELECTED_BINARIES="$2"
                shift 2
                ;;
            *)
                print_error "Unknown option: $1"
                echo ""
                show_help
                ;;
        esac
    done
    
    # Validate selected binaries if any were specified
    if [ -n "$SELECTED_BINARIES" ]; then
        # Convert comma-separated list to space-separated
        local binaries_to_validate=$(echo "$SELECTED_BINARIES" | tr ',' ' ')
        for binary in $binaries_to_validate; do
            if ! is_valid_binary "$binary"; then
                print_error "Invalid binary name: $binary"
                echo ""
                print_error "Available binaries: $ALL_BINARIES"
                exit 1
            fi
        done
    fi
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
    print_info "Fetching latest release information..." >&2
    
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
    
    # Strip 'v' prefix from version for filename (e.g., v1.0.5 -> 1.0.5)
    local version_without_v="${version#v}"
    
    # Construct download URL
    local archive_name="${REPO_NAME}_${version_without_v}_${os}_${arch}.tar.gz"
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
    local installed_list=""
    
    # Determine which binaries to install
    local binaries_to_install
    if [ -z "$SELECTED_BINARIES" ]; then
        binaries_to_install="$ALL_BINARIES"
    else
        # Convert comma-separated to space-separated
        binaries_to_install=$(echo "$SELECTED_BINARIES" | tr ',' ' ')
    fi
    
    for dir in "$tmp_dir"/*-"${os}"-"${arch}"; do
        if [ -d "$dir" ]; then
            for binary in "$dir"/*; do
                if [ -f "$binary" ] && [ -x "$binary" ]; then
                    local binary_name=$(basename "$binary")
                    
                    # Check if this binary should be installed
                    local should_install=0
                    for selected in $binaries_to_install; do
                        if [ "$binary_name" = "$selected" ]; then
                            should_install=1
                            break
                        fi
                    done
                    
                    if [ $should_install -eq 1 ]; then
                        print_info "Installing ${binary_name} to ${INSTALL_DIR}..."
                        if $USE_SUDO cp "$binary" "${INSTALL_DIR}/${binary_name}"; then
                            $USE_SUDO chmod +x "${INSTALL_DIR}/${binary_name}"
                            ((installed_count++))
                            if [ -z "$installed_list" ]; then
                                installed_list="$binary_name"
                            else
                                installed_list="$installed_list $binary_name"
                            fi
                        else
                            print_error "Failed to install ${binary_name}"
                        fi
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
    
    # Return the list of installed binaries
    echo "$installed_list"
}

# Main installation flow
main() {
    # Parse command-line arguments
    parse_arguments "$@"
    
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
    installed_binaries=$(download_and_install "$VERSION" "$OS" "$ARCH")
    
    echo ""
    echo "=========================================="
    print_info "Installation complete!"
    echo "=========================================="
    echo ""
    print_info "Installed binaries:"
    
    # Display information about each installed binary
    for binary in $installed_binaries; do
        case "$binary" in
            helmenv)
                print_info "  - helmenv: Helm version manager"
                ;;
            helm-wrapper)
                print_info "  - helm-wrapper: Helm wrapper"
                ;;
            kbenv)
                print_info "  - kbenv: kubectl version manager"
                ;;
            kubectl-wrapper)
                print_info "  - kubectl-wrapper: kubectl wrapper"
                ;;
            ocenv)
                print_info "  - ocenv: oc (OpenShift CLI) version manager"
                ;;
            oc-wrapper)
                print_info "  - oc-wrapper: oc wrapper"
                ;;
        esac
    done
    
    echo ""
    
    # Display helpful usage message based on which binaries were installed
    local help_msg=""
    for binary in $installed_binaries; do
        if [ "$binary" = "helmenv" ] || [ "$binary" = "kbenv" ] || [ "$binary" = "ocenv" ]; then
            if [ -z "$help_msg" ]; then
                help_msg="$binary --help"
            else
                help_msg="$help_msg, $binary --help"
            fi
        fi
    done
    
    if [ -n "$help_msg" ]; then
        print_info "Run '$help_msg' to get started"
    fi
}

# Run main function
main "$@"
