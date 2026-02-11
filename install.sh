#!/bin/bash

# Dotfiles Install Script
# Supports macOS and Ubuntu

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Flags
INSTALL_FONTS=false
INSTALL_KEYBOARD=false
DRY_RUN=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --fonts)
            INSTALL_FONTS=true
            shift
            ;;
        --keyboard)
            INSTALL_KEYBOARD=true
            shift
            ;;
        --dry-run)
            DRY_RUN=true
            shift
            ;;
        --all)
            INSTALL_FONTS=true
            INSTALL_KEYBOARD=true
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --fonts       Install JetBrainsMono Nerd Font"
            echo "  --keyboard    Install Compound-vim-fi keyboard layout (macOS)"
            echo "  --dry-run     Show what would be done without executing"
            echo "  --all         Enable all optional features"
            echo "  --help        Show this help message"
            exit 0
            ;;
        *)
            echo -e "${RED}Unknown option: $1${NC}"
            exit 1
            ;;
    esac
done

# Detect OS
detect_os() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command -v apt-get &> /dev/null; then
            OS="ubuntu"
        else
            echo -e "${RED}Error: This script only supports Ubuntu/Debian on Linux${NC}"
            exit 1
        fi
    else
        echo -e "${RED}Error: Unsupported operating system: $OSTYPE${NC}"
        exit 1
    fi
    echo -e "${BLUE}Detected OS: $OS${NC}"
}

# Print section header
print_section() {
    echo -e "\n${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  $1${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Execute command or print in dry-run mode
run_cmd() {
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}[DRY RUN] Would execute: $*${NC}"
    else
        eval "$@"
    fi
}

# Check if command exists
command_exists() {
    command -v "$1" &> /dev/null
}

# Backup file with timestamp
backup_file() {
    local file="$1"
    if [ -e "$file" ] && [ "$DRY_RUN" = false ]; then
        local timestamp=$(date +%Y%m%d_%H%M%S)
        local backup="${file}.backup.${timestamp}"
        echo -e "${YELLOW}Backing up $file to $backup${NC}"
        cp -r "$file" "$backup"
    fi
}

# Install Homebrew on macOS
install_homebrew() {
    if ! command_exists brew; then
        echo -e "${YELLOW}Installing Homebrew...${NC}"
        if [ "$DRY_RUN" = false ]; then
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            if [[ "$(uname -m)" == "arm64" ]]; then
                eval "$(/opt/homebrew/bin/brew shellenv)"
            else
                eval "$(/usr/local/bin/brew shellenv)"
            fi
        fi
    else
        echo -e "${GREEN}Homebrew already installed${NC}"
    fi
}

# Install packages based on OS
install_package() {
    local mac_pkg="$1"
    local ubuntu_pkg="$2"
    
    if [ "$OS" = "macos" ]; then
        if ! brew list "$mac_pkg" &> /dev/null; then
            echo -e "${YELLOW}Installing $mac_pkg...${NC}"
            run_cmd "brew install $mac_pkg"
        else
            echo -e "${GREEN}$mac_pkg already installed${NC}"
        fi
    else
        if ! dpkg -l | grep -q "^ii  $ubuntu_pkg "; then
            echo -e "${YELLOW}Installing $ubuntu_pkg...${NC}"
            run_cmd "sudo apt-get install -y $ubuntu_pkg"
        else
            echo -e "${GREEN}$ubuntu_pkg already installed${NC}"
        fi
    fi
}

# Install Neovim
install_neovim() {
    print_section "Installing Neovim"
    
    if command_exists nvim; then
        echo -e "${GREEN}Neovim already installed${NC}"
        return
    fi
    
    if [ "$OS" = "macos" ]; then
        run_cmd "brew install neovim"
    else
        run_cmd "sudo snap install nvim --classic"
    fi
}

# Install lazygit
install_lazygit() {
    print_section "Installing LazyGit"
    
    if command_exists lazygit; then
        echo -e "${GREEN}LazyGit already installed${NC}"
        return
    fi
    
    if [ "$OS" = "macos" ]; then
        run_cmd "brew install lazygit"
    else
        echo -e "${YELLOW}Installing LazyGit from GitHub release...${NC}"
        if [ "$DRY_RUN" = false ]; then
            LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": *"v\K[^"]*')
            curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
            tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
            sudo install /tmp/lazygit -D -t /usr/local/bin/
            rm /tmp/lazygit.tar.gz /tmp/lazygit
        fi
    fi
}

# Install Go
install_go() {
    print_section "Installing Go"
    
    if command_exists go; then
        echo -e "${GREEN}Go already installed${NC}"
        return
    fi
    
    if [ "$OS" = "macos" ]; then
        run_cmd "brew install go"
    else
        run_cmd "sudo snap install go --classic"
    fi
}

# Install nvm and Node.js
install_node() {
    print_section "Installing Node.js (via nvm)"
    
    if command_exists nvm; then
        echo -e "${GREEN}nvm already installed${NC}"
    else
        echo -e "${YELLOW}Installing nvm...${NC}"
        if [ "$DRY_RUN" = false ]; then
            curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
            export NVM_DIR="$HOME/.nvm"
            [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
        fi
    fi
    
    if command_exists node; then
        echo -e "${GREEN}Node.js already installed: $(node --version)${NC}"
    else
        echo -e "${YELLOW}Installing Node.js LTS...${NC}"
        if [ "$DRY_RUN" = false ]; then
            export NVM_DIR="$HOME/.nvm"
            [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
            nvm install --lts
            nvm use --lts
            nvm alias default lts/*
        fi
    fi
}

# Install WezTerm
install_wezterm() {
    print_section "Installing WezTerm"
    
    if command_exists wezterm; then
        echo -e "${GREEN}WezTerm already installed${NC}"
        return
    fi
    
    if [ "$OS" = "macos" ]; then
        run_cmd "brew install --cask wezterm"
    else
        run_cmd "sudo apt-get install -y wezterm"
    fi
}

# Install Starship
install_starship() {
    print_section "Installing Starship"
    
    if command_exists starship; then
        echo -e "${GREEN}Starship already installed${NC}"
        return
    fi
    
    if [ "$OS" = "macos" ]; then
        run_cmd "brew install starship"
    else
        echo -e "${YELLOW}Installing Starship...${NC}"
        run_cmd "curl -sS https://starship.rs/install.sh | sh -s -- -y"
    fi
}

# Install lsd
install_lsd() {
    print_section "Installing lsd (pretty ls)"
    
    if command_exists lsd; then
        echo -e "${GREEN}lsd already installed${NC}"
        return
    fi
    
    if [ "$OS" = "macos" ]; then
        run_cmd "brew install lsd"
    else
        run_cmd "sudo apt-get install -y lsd"
    fi
}

# Install zsh-syntax-highlighting
install_zsh_syntax_highlighting() {
    print_section "Installing zsh-syntax-highlighting"
    
    if [ "$OS" = "macos" ]; then
        if ! brew list zsh-syntax-highlighting &> /dev/null; then
            run_cmd "brew install zsh-syntax-highlighting"
        else
            echo -e "${GREEN}zsh-syntax-highlighting already installed${NC}"
        fi
    else
        if ! dpkg -l | grep -q "^ii  zsh-syntax-highlighting "; then
            run_cmd "sudo apt-get install -y zsh-syntax-highlighting"
        else
            echo -e "${GREEN}zsh-syntax-highlighting already installed${NC}"
        fi
    fi
}

# Install ripgrep and tree
install_basic_tools() {
    print_section "Installing Basic Tools"
    
    if [ "$OS" = "macos" ]; then
        install_package "ripgrep" "ripgrep"
        install_package "tree" "tree"
    else
        if ! command_exists rg; then
            run_cmd "sudo apt-get install -y ripgrep"
        else
            echo -e "${GREEN}ripgrep already installed${NC}"
        fi
        
        if ! command_exists tree; then
            run_cmd "sudo apt-get install -y tree"
        else
            echo -e "${GREEN}tree already installed${NC}"
        fi
        
        if ! command_exists git; then
            run_cmd "sudo apt-get install -y git"
        else
            echo -e "${GREEN}git already installed${NC}"
        fi
    fi
}

# Install Nerd Font
install_fonts() {
    print_section "Installing JetBrainsMono Nerd Font"
    
    if [ "$OS" = "macos" ]; then
        if brew list font-jetbrains-mono-nerd-font &> /dev/null; then
            echo -e "${GREEN}JetBrainsMono Nerd Font already installed${NC}"
        else
            run_cmd "brew tap homebrew/cask-fonts"
            run_cmd "brew install --cask font-jetbrains-mono-nerd-font"
        fi
    else
        echo -e "${YELLOW}Installing JetBrainsMono Nerd Font manually...${NC}"
        if [ "$DRY_RUN" = false ]; then
            local font_url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
            local font_dir="$HOME/.local/share/fonts"
            mkdir -p "$font_dir"
            
            curl -Lo /tmp/JetBrainsMono.zip "$font_url"
            unzip -o /tmp/JetBrainsMono.zip -d "$font_dir"
            rm /tmp/JetBrainsMono.zip
            
            fc-cache -fv
        fi
    fi
    
    echo -e "${YELLOW}⚠️  Remember to set the font in your terminal preferences!${NC}"
}

# Install Compound-vim-fi keyboard layout
install_keyboard() {
    print_section "Installing Compound-vim-fi Keyboard Layout"
    
    if [ "$OS" = "macos" ]; then
        local keyboard_file="$SCRIPT_DIR/Compound-vim-fi.keylayout"
        if [ -f "$keyboard_file" ]; then
            echo -e "${YELLOW}Installing Compound-vim-fi.keylayout...${NC}"
            run_cmd "cp '$keyboard_file' '$HOME/Library/Keyboard Layouts/'"
            echo -e "${GREEN}Compound-vim-fi keyboard layout installed. Add it in System Preferences > Keyboard > Input Sources${NC}"
        else
            echo -e "${RED}Warning: Compound-vim-fi.keylayout not found in repository${NC}"
        fi
    else
        echo -e "${YELLOW}Linux Compound-vim-fi layout installation not automated.${NC}"
        echo -e "${YELLOW}Run manually: sudo cp '$SCRIPT_DIR/fi' /usr/share/X11/xkb/symbols/fi${NC}"
    fi
}

# Install config files
install_configs() {
    print_section "Installing Configuration Files"
    
    # Create .config directory if it doesn't exist
    run_cmd "mkdir -p $HOME/.config"
    
    # Install nvim config
    if [ -d "$SCRIPT_DIR/.config/nvim" ]; then
        echo -e "${YELLOW}Installing nvim config...${NC}"
        backup_file "$HOME/.config/nvim"
        run_cmd "cp -R '$SCRIPT_DIR/.config/nvim' '$HOME/.config/'"
    fi
    
    # Install starship config
    if [ -f "$SCRIPT_DIR/.config/starship.toml" ]; then
        echo -e "${YELLOW}Installing starship config...${NC}"
        backup_file "$HOME/.config/starship.toml"
        run_cmd "cp '$SCRIPT_DIR/.config/starship.toml' '$HOME/.config/'"
    fi
    
    # Install wezterm config
    if [ -f "$SCRIPT_DIR/.wezterm.lua" ]; then
        echo -e "${YELLOW}Installing wezterm config...${NC}"
        backup_file "$HOME/.wezterm.lua"
        run_cmd "cp '$SCRIPT_DIR/.wezterm.lua' '$HOME/'"
    fi
}

# Update zshrc
update_zshrc() {
    print_section "Updating .zshrc"
    
    local zshrc="$HOME/.zshrc"
    local marker="# === DOTFILES CONFIG ==="
    
    # Check if our config is already present
    if [ -f "$zshrc" ] && grep -q "$marker" "$zshrc"; then
        echo -e "${GREEN}.zshrc already contains dotfiles config${NC}"
        return
    fi
    
    echo -e "${YELLOW}Adding configuration to .zshrc...${NC}"
    
    # Determine zsh-syntax-highlighting path
    local zsh_syntax_path
    if [ "$OS" = "macos" ]; then
        zsh_syntax_path="/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
        # Check for Intel Mac
        if [[ "$(uname -m)" != "arm64" ]]; then
            zsh_syntax_path="/usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
        fi
    else
        zsh_syntax_path="/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    fi
    
    # Use a temporary file to build the config block (avoids escaping issues)
    local temp_config=$(mktemp)
    cat > "$temp_config" << EOF
# === DOTFILES CONFIG START ===
# Enable colors in terminal
export CLICOLOR=1
export LSCOLORS=Gxfxcxdxbxegedabagacad

# Tell the terminal we are using a 256-color/TrueColor environment
export TERM=xterm-256color

# zsh-syntax-highlighting
if [ -f $zsh_syntax_path ]; then
    source $zsh_syntax_path
fi

# Starship prompt
eval "\$(starship init zsh)"

# Pretty ls
alias ls='lsd --color always --icon always'

# Set default terminal editor
export VISUAL=nvim
export EDITOR="\$VISUAL"
export CVS_EDITOR=nvim
# === DOTFILES CONFIG END ===
EOF

    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}[DRY RUN] Would append to $zshrc:${NC}"
        cat "$temp_config"
    else
        if [ ! -f "$zshrc" ]; then
            touch "$zshrc"
        fi
        echo "" >> "$zshrc"
        cat "$temp_config" >> "$zshrc"
        echo -e "${GREEN}Configuration added to .zshrc${NC}"
    fi
    
    rm -f "$temp_config"
}

# Sync nvim plugins
sync_nvim_plugins() {
    print_section "Syncing Neovim Plugins"
    
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}[DRY RUN] Would run: nvim --headless +Lazy! sync +qa${NC}"
    else
        if command_exists nvim; then
            echo -e "${YELLOW}Installing neovim plugins (this may take a while)...${NC}"
            nvim --headless "+Lazy! sync" +qa || true
            echo -e "${GREEN}Plugins installed${NC}"
        else
            echo -e "${RED}Neovim not found, skipping plugin installation${NC}"
        fi
    fi
}

# Main installation
main() {
    echo -e "${GREEN}"
    echo "  ___        _      _     _       _       _       _"
    echo " / _ \ _   _| |_ __| | __| | __ _| |_ ___| |__   (_)_ __"
    echo "| | | | | | | __/ _\ |/ _\ |/ _\ | __/ __| '_ \  | | '_ \\"
    echo "| |_| | |_| | || (_| | (_| | (_| | || (__| | | | | | | | |"
    echo " \___/ \__,_|\__\__,_|\__,_|\__,_|\__\___|_| |_| |_|_| |_|"
    echo -e "${NC}"
    
    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}⚠️  DRY RUN MODE - No changes will be made${NC}"
    fi
    
    detect_os
    
    if [ "$OS" = "macos" ]; then
        install_homebrew
    else
        echo -e "${YELLOW}Updating apt package list...${NC}"
        run_cmd "sudo apt-get update"
    fi
    
    # Install all dependencies
    install_basic_tools
    install_neovim
    install_lazygit
    install_go
    install_node
    install_wezterm
    install_starship
    install_lsd
    install_zsh_syntax_highlighting
    
    # Optional installations
    if [ "$INSTALL_FONTS" = true ]; then
        install_fonts
    fi
    
    if [ "$INSTALL_KEYBOARD" = true ]; then
        install_keyboard
    fi
    
    # Install configs
    install_configs
    update_zshrc
    
    # Sync plugins
    sync_nvim_plugins
    
    # Summary
    print_section "Installation Complete!"
    
    if [ "$INSTALL_FONTS" = false ]; then
        echo -e "${YELLOW}⚠️  Nerd Font not installed. Run with --fonts to install (required for icons)${NC}"
    fi
    
    echo -e "${GREEN}Next steps:${NC}"
    echo -e "  1. ${YELLOW}Restart your terminal${NC} or run: ${BLUE}source ~/.zshrc${NC}"
    echo -e "  2. ${YELLOW}Open nvim${NC} and wait for Mason to install LSP servers"
    echo -e "  3. ${YELLOW}Configure GitHub Copilot${NC} in nvim: ${BLUE}:Copilot auth${NC}"
    
    if [ "$INSTALL_FONTS" = true ]; then
        echo -e "  4. ${YELLOW}Set your terminal font${NC} to JetBrainsMono Nerd Font"
    fi
    
    echo -e "\n${GREEN}Happy coding! 🚀${NC}"
}

main "$@"
