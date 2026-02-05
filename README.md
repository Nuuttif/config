# Install keyboard layout linux:
```
sudo cp fi /usr/share/X11/xkb/symbols
```

# Install neovim
## Ubuntu
### [Install dependencies](#install-neovim-dependencies-on-ubuntu)

Use snap because apt package is too outdated.
```
sudo snap install nvim --classic
```

**[Install neovim config files](#install-neovim-config)**


## MacOS
### [Install dependencies](#install-neovim-dependencies-on-macos)

Install neovim
```
brew install neovim
```

**[Install neovim config files](#install-neovim-config)**


# Install neovim dependencies
## Install neovim dependencies on Ubuntu
### LazyGit
```
LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | \grep -Po '"tag_name": *"v\K[^"]*')
curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
tar xf lazygit.tar.gz lazygit
sudo install lazygit -D -t /usr/local/bin/
```

### Apt packages
```
sudo apt install ripgrep tree git
```

### Snaps
```
sudo snap install go --classic
```

## Install neovim dependencies on MacOs
```
brew install ripgrep lazygit tree go
```

### For AI
```
brew install copilot-cli
```

## Install neovim config
```
cp -R .config/nvim ~/.config/
```

