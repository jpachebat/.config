#!/usr/bin/env bash

###############################################################################
# Neovim Cluster Config Setup Script
#
# This script helps you set up the simplified Neovim configuration on your
# cluster system. It provides options for different installation methods.
###############################################################################

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_header() {
    echo -e "\n${BLUE}===${NC} $1 ${BLUE}===${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# Check if we're in the right directory
check_directory() {
    if [[ ! -f "init.cluster.lua" ]]; then
        print_error "init.cluster.lua not found in current directory!"
        print_info "Please run this script from ~/.config/nvim/"
        exit 1
    fi
}

# Check Neovim version
check_nvim_version() {
    if ! command -v nvim &> /dev/null; then
        print_error "Neovim is not installed!"
        exit 1
    fi

    local nvim_version=$(nvim --version | head -n1 | grep -oP 'v\K[0-9.]+')
    local major=$(echo "$nvim_version" | cut -d. -f1)
    local minor=$(echo "$nvim_version" | cut -d. -f2)

    print_info "Detected Neovim version: v$nvim_version"

    if [[ "$major" -eq 0 ]] && [[ "$minor" -lt 10 ]]; then
        print_warning "Neovim 0.10+ is recommended for this config"
        print_warning "You have v$nvim_version - some features may not work"
        read -p "Continue anyway? [y/N] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        print_success "Neovim version is compatible"
    fi
}

# Method 1: Using NVIM_APPNAME (recommended)
setup_nvim_appname() {
    print_header "Setting up with NVIM_APPNAME"

    local target_dir="${HOME}/.config/nvim-cluster"

    print_info "This will create a separate Neovim config at: $target_dir"
    print_info "Your current config will remain untouched"

    # Create directory
    mkdir -p "$target_dir"
    print_success "Created directory: $target_dir"

    # Copy the cluster config
    cp init.cluster.lua "$target_dir/init.lua"
    print_success "Copied cluster config to $target_dir/init.lua"

    # Check if shell config exists and offer to add alias
    for shell_rc in "${HOME}/.bashrc" "${HOME}/.bash_profile" "${HOME}/.zshrc"; do
        if [[ -f "$shell_rc" ]]; then
            print_info "Found shell config: $shell_rc"
            read -p "Add NVIM_APPNAME alias to this file? [y/N] " -n 1 -r
            echo
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                # Check if alias already exists
                if ! grep -q "NVIM_APPNAME=nvim-cluster" "$shell_rc"; then
                    echo "" >> "$shell_rc"
                    echo "# Neovim cluster config" >> "$shell_rc"
                    echo 'export NVIM_APPNAME=nvim-cluster' >> "$shell_rc"
                    echo 'alias nvc="NVIM_APPNAME=nvim-cluster nvim"' >> "$shell_rc"
                    print_success "Added alias to $shell_rc"
                    print_info "Run: source $shell_rc (or restart your shell)"
                    print_info "Then use: nvc <file> to open with cluster config"
                else
                    print_warning "Alias already exists in $shell_rc"
                fi
            fi
        fi
    done

    print_success "Setup complete!"
    print_info "To use the cluster config:"
    print_info "  1. Run: export NVIM_APPNAME=nvim-cluster"
    print_info "  2. Or use the alias: nvc"
    print_info "  3. Or run: NVIM_APPNAME=nvim-cluster nvim"
}

# Method 2: Replace main config
setup_replace() {
    print_header "Replacing main config"

    local nvim_dir="${HOME}/.config/nvim"

    print_warning "This will replace your current init.lua"
    print_info "Your current config files will remain, but init.lua will be replaced"

    read -p "Do you want to backup your current init.lua? [Y/n] " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Nn]$ ]]; then
        if [[ -f "$nvim_dir/init.lua" ]]; then
            local backup="$nvim_dir/init.lua.backup.$(date +%Y%m%d_%H%M%S)"
            cp "$nvim_dir/init.lua" "$backup"
            print_success "Backed up to: $backup"
        fi
    fi

    # Copy the cluster config
    cp init.cluster.lua "$nvim_dir/init.lua"
    print_success "Replaced init.lua with cluster config"

    print_success "Setup complete!"
    print_info "Your Neovim will now use the cluster config"
}

# Method 3: Create symlink
setup_symlink() {
    print_header "Creating symlink"

    local nvim_dir="${HOME}/.config/nvim"

    print_info "This will create a symlink: init.lua -> init.cluster.lua"

    # Check if init.lua exists and is not a symlink
    if [[ -f "$nvim_dir/init.lua" ]] && [[ ! -L "$nvim_dir/init.lua" ]]; then
        print_warning "init.lua exists and is not a symlink"
        read -p "Backup and replace with symlink? [Y/n] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            local backup="$nvim_dir/init.lua.backup.$(date +%Y%m%d_%H%M%S)"
            mv "$nvim_dir/init.lua" "$backup"
            print_success "Backed up to: $backup"
        else
            print_error "Aborted"
            return 1
        fi
    elif [[ -L "$nvim_dir/init.lua" ]]; then
        print_warning "init.lua is already a symlink"
        rm "$nvim_dir/init.lua"
    fi

    # Create symlink
    ln -s "$nvim_dir/init.cluster.lua" "$nvim_dir/init.lua"
    print_success "Created symlink: init.lua -> init.cluster.lua"

    print_success "Setup complete!"
    print_info "Your Neovim will now use the cluster config"
}

# Show usage info
show_usage() {
    cat << EOF
Neovim Cluster Config Setup

Usage: $0 [METHOD]

Methods:
  appname   - Use NVIM_APPNAME (recommended, keeps both configs)
  replace   - Replace current init.lua
  symlink   - Create symlink to init.cluster.lua
  help      - Show this help message

If no method is specified, you'll be prompted to choose.

EOF
}

# Interactive menu
interactive_menu() {
    print_header "Neovim Cluster Config Setup"

    echo "Choose installation method:"
    echo ""
    echo "  1) NVIM_APPNAME (Recommended)"
    echo "     - Keeps both configs separate"
    echo "     - Switch between configs easily"
    echo "     - Safest option"
    echo ""
    echo "  2) Replace init.lua"
    echo "     - Uses cluster config as main"
    echo "     - Can backup current config"
    echo ""
    echo "  3) Symlink"
    echo "     - Creates init.lua -> init.cluster.lua"
    echo "     - Easy to switch back"
    echo ""
    echo "  4) Cancel"
    echo ""

    read -p "Select option [1-4]: " -n 1 -r
    echo

    case $REPLY in
        1)
            setup_nvim_appname
            ;;
        2)
            setup_replace
            ;;
        3)
            setup_symlink
            ;;
        4)
            print_info "Cancelled"
            exit 0
            ;;
        *)
            print_error "Invalid option"
            exit 1
            ;;
    esac
}

# Main script
main() {
    print_header "Neovim Cluster Config Setup"

    # Check if we're in the right place
    check_directory

    # Check Neovim version
    check_nvim_version

    # Parse arguments
    case "${1:-}" in
        appname)
            setup_nvim_appname
            ;;
        replace)
            setup_replace
            ;;
        symlink)
            setup_symlink
            ;;
        help|--help|-h)
            show_usage
            exit 0
            ;;
        "")
            interactive_menu
            ;;
        *)
            print_error "Unknown method: $1"
            show_usage
            exit 1
            ;;
    esac

    # Final instructions
    print_header "Next Steps"
    print_info "1. Open Neovim (it will install plugins automatically)"
    print_info "2. Wait for plugin installation to complete"
    print_info "3. Run :checkhealth to verify setup"
    print_info "4. Read CLUSTER_README.md for more information"
    print_info ""
    print_info "Enjoy your streamlined Neovim config! 🚀"
}

# Run main function
main "$@"
