# Dotfiles

This repository contains my personal configuration files for Neovim, terminal tools, and the Compound-vim-fi keyboard layout.

## Quick Install

The easiest way to install everything is using the provided install script:

```bash
git clone git@github.com:Nuuttif/config.git
cd config
./install.sh
```

### Install Options

```bash
./install.sh --help          # Show help
./install.sh --dry-run       # Preview what would be installed
./install.sh --fonts         # Include JetBrainsMono Nerd Font
./install.sh --keyboard      # Include Compound-vim-fi keyboard layout (macOS only)
./install.sh --all           # Install everything including optional components
```

## What's Included

### Core Tools
- **Neovim** - Modern Vim-based editor with extensive plugin ecosystem
- **WezTerm** - GPU-accelerated terminal emulator
- **Starship** - Cross-shell prompt
- **zsh** with syntax highlighting and custom configuration

### Development Tools
- **ripgrep** - Fast search tool
- **lazygit** - Terminal UI for git
- **Go** - Go programming language
- **Node.js** (via nvm) - JavaScript runtime

### Neovim Plugins
- **lazy.nvim** - Plugin manager
- **telescope.nvim** - Fuzzy finder
- **nvim-lspconfig + mason.nvim** - LSP configuration
- **nvim-cmp** - Autocompletion
- **conform.nvim** - Code formatting
- **catppuccin** - Color scheme
- **copilot.lua** - GitHub Copilot integration
- **lazygit.nvim** - LazyGit integration
- And more...

## Manual Installation

If you prefer to install manually or the script doesn't work for your system:

### macOS

```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install dependencies
brew install neovim ripgrep lazygit tree go wezterm starship lsd zsh-syntax-highlighting

# Install nvm and Node.js
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
nvm install --lts
nvm use --lts

# Install Copilot CLI (optional)
brew install copilot-cli

# Install configs
cp -R .config/nvim ~/.config/
cp .config/starship.toml ~/.config/
cp .wezterm.lua ~/
```

### Ubuntu

```bash
# Update package list
sudo apt-get update

# Install apt packages
sudo apt-get install -y ripgrep tree git wezterm lsd zsh-syntax-highlighting

# Install snap packages
sudo snap install nvim --classic
sudo snap install go --classic

# Install LazyGit
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": *"v\K[^"]*')
curl -Lo /tmp/lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf /tmp/lazygit.tar.gz -C /tmp lazygit
sudo install /tmp/lazygit -D -t /usr/local/bin/
rm /tmp/lazygit.tar.gz /tmp/lazygit

# Install nvm and Node.js
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.nvm/nvm.sh
nvm install --lts
nvm use --lts

# Install Starship
curl -sS https://starship.rs/install.sh | sh -s -- -y

# Install configs
cp -R .config/nvim ~/.config/
cp .config/starship.toml ~/.config/
cp .wezterm.lua ~/
```

## Keyboard Layout (Compound-vim-fi)

A custom keyboard layout optimized for Finnish and Vim usage.

### macOS
Copy the keyboard layout to the system:
```bash
cp "Compound-vim-fi.keylayout" ~/Library/Keyboard\ Layouts/
```
Then add it in **System Preferences > Keyboard > Input Sources**

### Linux (Ubuntu)
Install the Compound-vim-fi layout:
```bash
sudo cp fi /usr/share/X11/xkb/symbols/fi
```
Then add it via system settings or using `setxkbmap fi`.

## Post-Installation

1. **Restart your terminal** or run `source ~/.zshrc`
2. **Open Neovim** for the first time to trigger plugin installation:
   ```bash
   nvim
   ```
   Wait for Mason to install LSP servers
3. **Configure GitHub Copilot** (if installed):
   ```vim
   :Copilot auth
   ```
4. **Set your terminal font** to a Nerd Font (e.g., JetBrainsMono Nerd Font) for proper icon display

## Nerd Font Installation

### macOS
```bash
brew tap homebrew/cask-fonts
brew install --cask font-jetbrains-mono-nerd-font
```

### Ubuntu
```bash
mkdir -p ~/.local/share/fonts
curl -Lo /tmp/JetBrainsMono.zip "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
unzip -o /tmp/JetBrainsMono.zip -d ~/.local/share/fonts
fc-cache -fv
rm /tmp/JetBrainsMono.zip
```

## Repository Structure

```
.
├── .config/
│   ├── nvim/              # Neovim configuration
│   │   ├── init.lua
│   │   └── lua/
│   │       ├── config/
│   │       └── plugins/
│   └── starship.toml      # Starship prompt config
├── .wezterm.lua           # WezTerm terminal config
├── fi                     # Compound-vim-fi keyboard layout (Linux)
├── Compound-vim-fi.keylayout  # Compound-vim-fi keyboard layout (macOS)
├── install.sh             # Automated install script
└── README.md
```

## License

Feel free to use and modify these configurations for your own setup.
