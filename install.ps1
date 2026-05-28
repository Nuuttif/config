#!/usr/bin/env pwsh
#requires -Version 5.1

<#
.SYNOPSIS
    Dotfiles Install Script for Windows 11 (via winget, with Scoop for select packages)

.DESCRIPTION
    Installs all dependencies and configuration files for the dotfiles repository.
    Uses winget as the primary package manager. Scoop is retained for win32yank
    and the JetBrainsMono Nerd Font.

.PARAMETER Fonts
    Install JetBrainsMono Nerd Font

.PARAMETER DryRun
    Show what would be done without executing

.PARAMETER Help
    Show this help message

.EXAMPLE
    .\install.ps1
    .\install.ps1 -Fonts
    .\install.ps1 -DryRun
#>

[CmdletBinding()]
param(
    [switch]$Fonts,
    [switch]$DryRun,
    [switch]$Help
)

# Stop on error
$ErrorActionPreference = "Stop"

# Colors (Windows PowerShell 5.1 compatible)
$ESC = [char]27
$Red    = "$ESC[31m"
$Green  = "$ESC[32m"
$Yellow = "$ESC[33m"
$Blue   = "$ESC[34m"
$Reset  = "$ESC[0m"

# Script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

if ($Help) {
    Get-Help $MyInvocation.MyCommand.Definition -Detailed
    exit 0
}

if ($DryRun) {
    Write-Host "${Yellow}DRY RUN MODE - No changes will be made${Reset}"
}

# ── Helpers ──────────────────────────────────────────────────────────

function Print-Section {
    param([string]$Title)
    Write-Host ""
    Write-Host "${Blue}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${Reset}"
    Write-Host "${Blue}  $Title${Reset}"
    Write-Host "${Blue}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${Reset}"
}

function Run-Cmd {
    param([string]$Command, [string]$Arguments = "")
    if ($DryRun) {
        Write-Host "${Yellow}[DRY RUN] Would execute: $Command $Arguments${Reset}"
    } else {
        if (-not (Command-Exists $Command)) {
            Write-Host "${Red}Error: Command not found: $Command${Reset}"
            return
        }
        $psi = New-Object System.Diagnostics.ProcessStartInfo
        $psi.FileName = $Command
        $psi.Arguments = $Arguments
        $psi.UseShellExecute = $false
        $psi.RedirectStandardOutput = $true
        $psi.RedirectStandardError = $true
        $proc = [System.Diagnostics.Process]::Start($psi)
        # Read streams before WaitForExit to avoid deadlocks on full buffers
        $out = $proc.StandardOutput.ReadToEnd()
        $err = $proc.StandardError.ReadToEnd()
        $proc.WaitForExit()
        if ($proc.ExitCode -ne 0) {
            if ($err) { Write-Host "${Red}$err${Reset}" }
        }
    }
}

function Command-Exists {
    param([string]$Name)
    return [bool](Get-Command -Name $Name -ErrorAction SilentlyContinue)
}

function Backup-File {
    param([string]$Path)
    if ((Test-Path $Path) -and -not $DryRun) {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $backup = "$Path.backup.$timestamp"
        Write-Host "${Yellow}Backing up $Path to $backup${Reset}"
        Copy-Item -Recurse -Path $Path -Destination $backup
    }
}

# ── Scoop ────────────────────────────────────────────────────────────

function Install-Scoop {
    if (Command-Exists "scoop") {
        Write-Host "${Green}Scoop already installed${Reset}"
        return
    }
    Write-Host "${Yellow}Installing Scoop...${Reset}"
    if (-not $DryRun) {
        Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
        Invoke-RestMethod -Uri https://get.scoop.sh | Invoke-Expression
    }
}

function Install-PowerShell7 {
    Print-Section "Installing PowerShell 7"
    if (Command-Exists "pwsh") {
        Write-Host "${Green}PowerShell 7 already installed${Reset}"
        return
    }
    if (Command-Exists "winget") {
        Write-Host "${Yellow}Installing PowerShell 7 via winget...${Reset}"
        if (-not $DryRun) {
            winget install --id Microsoft.PowerShell --source winget --accept-package-agreements --accept-source-agreements
        }
    } else {
        Write-Host "${Red}winget not found. Please install PowerShell 7 manually from https://github.com/PowerShell/PowerShell/releases${Reset}"
    }
}

function Install-WingetPackage {
    param([string]$Id, [string]$CommandName = "")
    if ($DryRun) {
        Write-Host "${Yellow}[DRY RUN] Would install via winget: $Id${Reset}"
        return
    }
    $cmd = if ($CommandName) { $CommandName } else { $Id }
    if ($cmd -and (Command-Exists $cmd)) {
        Write-Host "${Green}$Id already available in PATH${Reset}"
        return
    }
    Write-Host "${Yellow}Installing $Id via winget...${Reset}"
    & winget install --id $Id --source winget --accept-package-agreements --accept-source-agreements --disable-interactivity
    $exit = $LASTEXITCODE
    if ($exit -ne 0) {
        if ($cmd -and (Command-Exists $cmd)) {
            Write-Host "${Green}$Id already installed (winget exit $exit, but command found)${Reset}"
        } else {
            Write-Host "${Red}winget install failed for $Id (exit code $exit)${Reset}"
        }
    } else {
        Write-Host "${Green}$Id installed${Reset}"
    }
}

# ── Packages ─────────────────────────────────────────────────────────

function Install-BasicTools {
    Print-Section "Installing Basic Tools"
    $tools = @(
        @{ Id = "BurntSushi.ripgrep.MSVC"; Cmd = "rg" },
        @{ Id = "Git.Git"; Cmd = "git" },
        @{ Id = "junegunn.fzf"; Cmd = "fzf" },
        @{ Id = "sharkdp.fd"; Cmd = "fd" },
        @{ Id = "eza-community.eza"; Cmd = "eza" },
        @{ Id = "lsd-rs.lsd"; Cmd = "lsd" },
        @{ Id = "7zip.7zip"; Cmd = "7z" }
    )
    foreach ($tool in $tools) {
        Install-WingetPackage -Id $tool.Id -CommandName $tool.Cmd
    }
}

function Install-Neovim {
    Print-Section "Installing Neovim"
    if (Command-Exists "nvim") {
        Write-Host "${Green}Neovim already installed${Reset}"
    } else {
        Install-WingetPackage -Id "Neovim.Neovim" -CommandName "nvim"
    }
    # win32yank enables the + clipboard register on Windows
    if (-not (Command-Exists "win32yank")) {
        if (-not $DryRun) {
            Write-Host "${Yellow}Installing win32yank via scoop...${Reset}"
            scoop install win32yank
        } else {
            Write-Host "${Yellow}[DRY RUN] Would install win32yank via scoop${Reset}"
        }
    } else {
        Write-Host "${Green}win32yank already installed${Reset}"
    }
}

function Install-LazyGit {
    Print-Section "Installing LazyGit"
    if (Command-Exists "lazygit") {
        Write-Host "${Green}LazyGit already installed${Reset}"
        return
    }
    Install-WingetPackage -Id "JesseDuffield.Lazygit" -CommandName "lazygit"
}

function Install-Go {
    Print-Section "Installing Go"
    if (Command-Exists "go") {
        Write-Host "${Green}Go already installed${Reset}"
        return
    }
    Install-WingetPackage -Id "GoLang.Go" -CommandName "go"
}

function Refresh-Path {
    if ($DryRun) { return }
    # Rebuild PATH from User + Machine (winget and scoop shims are added to User PATH by their installers)
    $userPath = [System.Environment]::GetEnvironmentVariable("PATH", "User")
    $machinePath = [System.Environment]::GetEnvironmentVariable("PATH", "Machine")
    $env:PATH = (@($userPath, $machinePath) | Where-Object { $_ } | Select-Object -Unique) -join ";"
}

function Install-Node {
    Print-Section "Installing Node.js"
    if (Command-Exists "node") {
        Write-Host "${Green}Node.js already installed: $(node --version)${Reset}"
        return
    }
    Install-WingetPackage -Id "OpenJS.NodeJS.LTS" -CommandName "node"
    if (-not $DryRun) {
        Refresh-Path
    }
}

function Install-Prettier {
    Print-Section "Installing Prettier"
    if (-not (Command-Exists "npm")) {
        Write-Host "${Yellow}npm not found. Skipping Prettier. Restart your terminal and re-run the script, or install Node.js manually.${Reset}"
        return
    }
    if (Command-Exists "prettier") {
        Write-Host "${Green}Prettier already installed${Reset}"
        return
    }
    Run-Cmd "npm" "install -g prettier"
}

function Install-WezTerm {
    Print-Section "Installing WezTerm"
    if (Command-Exists "wezterm") {
        Write-Host "${Green}WezTerm already installed${Reset}"
        return
    }
    Install-WingetPackage -Id "wez.wezterm" -CommandName "wezterm"
}

function Install-Starship {
    Print-Section "Installing Starship"
    if (Command-Exists "starship") {
        Write-Host "${Green}Starship already installed${Reset}"
        return
    }
    Install-WingetPackage -Id "Starship.Starship" -CommandName "starship"
}

function Install-Java {
    Print-Section "Installing Java (for Mason formatters)"
    if (Command-Exists "java") {
        Write-Host "${Green}Java already installed${Reset}"
        return
    }
    Install-WingetPackage -Id "Microsoft.OpenJDK.21" -CommandName "java"
}

# ── Fonts ────────────────────────────────────────────────────────────

function Install-Fonts {
    Print-Section "Installing JetBrainsMono Nerd Font"
    if ($DryRun) {
        Write-Host "${Yellow}[DRY RUN] Would install: JetBrainsMono-NF${Reset}"
        return
    }
    # Check if scoop bucket 'nerd-fonts' is added
    $buckets = scoop bucket list 2>$null
    if ($buckets -notcontains "nerd-fonts") {
        Write-Host "${Yellow}Adding nerd-fonts bucket...${Reset}"
        scoop bucket add nerd-fonts
    }
    $installed = scoop list 2>$null | Where-Object { $_ -match "^\s*JetBrainsMono-NF\s+" }
    if (-not $installed) {
        Write-Host "${Yellow}Installing JetBrainsMono-NF...${Reset}"
        scoop install nerd-fonts/JetBrainsMono-NF
    } else {
        Write-Host "${Green}JetBrainsMono-NF already installed${Reset}"
    }
    Write-Host "${Yellow}Remember to set the font in your terminal preferences!${Reset}"
}

# ── Configs ──────────────────────────────────────────────────────────

function Install-Configs {
    Print-Section "Installing Configuration Files"

    $nvimTarget = "$env:LOCALAPPDATA\nvim"
    $starshipTarget = "$HOME\.config\starship.toml"
    $weztermTarget = "$HOME\.wezterm.lua"

    # Neovim
    if (Test-Path "$ScriptDir\.config\nvim") {
        Write-Host "${Yellow}Installing nvim config...${Reset}"
        Backup-File $nvimTarget
        if (-not $DryRun) {
            if (Test-Path $nvimTarget) { Remove-Item -Recurse -Force $nvimTarget }
            New-Item -ItemType Directory -Force -Path $nvimTarget | Out-Null
            # Copy contents (not the folder itself) so init.lua lands directly in $nvimTarget
            Get-ChildItem -Path "$ScriptDir\.config\nvim" -Force | Copy-Item -Destination $nvimTarget -Recurse -Force
        }
    }

    # Starship — skip if already exists
    if (Test-Path "$ScriptDir\.config\starship.toml") {
        if (Test-Path $starshipTarget) {
            Write-Host "${Green}Starship config already exists, skipping${Reset}"
        } else {
            Write-Host "${Yellow}Installing starship config...${Reset}"
            if (-not $DryRun) {
                New-Item -ItemType Directory -Force -Path "$HOME\.config" | Out-Null
                Copy-Item -Path "$ScriptDir\.config\starship.toml" -Destination $starshipTarget -Force
            }
        }
    }

    # WezTerm — skip if already exists
    if (Test-Path "$ScriptDir\.wezterm.lua") {
        if (Test-Path $weztermTarget) {
            Write-Host "${Green}WezTerm config already exists, skipping${Reset}"
        } else {
            Write-Host "${Yellow}Installing wezterm config...${Reset}"
            if (-not $DryRun) {
                Copy-Item -Path "$ScriptDir\.wezterm.lua" -Destination $weztermTarget -Force
            }
        }
    }
}

# ── PowerShell Profile ───────────────────────────────────────────────

function Update-Profile {
    Print-Section "Updating PowerShell Profile"

    # Target PowerShell 7+ all-hosts profile explicitly
    $ps7Profile = "$HOME\Documents\PowerShell\Profile.ps1"
    # Clean up stale dotfiles block from Windows PowerShell 5.1 profile
    $ps51Profile = "$HOME\Documents\WindowsPowerShell\Profile.ps1"
    $marker = "# === DOTFILES CONFIG START ==="

    if (Test-Path $ps51Profile) {
        $content51 = Get-Content -Raw -Path $ps51Profile
        if ($content51 -and $content51.Contains($marker)) {
            Write-Host "${Yellow}Removing stale dotfiles block from Windows PowerShell 5.1 profile...${Reset}"
            if (-not $DryRun) {
                $cleaned = $content51 -replace "(?s)\r?\n?# === DOTFILES CONFIG START ===.*?# === DOTFILES CONFIG END ===\r?\n?"
                Set-Content -Path $ps51Profile -Value $cleaned.Trim() -NoNewline
            }
        }
    }

    if (Test-Path $ps7Profile) {
        $content7 = Get-Content -Raw -Path $ps7Profile
        if ($content7 -and $content7.Contains($marker)) {
            Write-Host "${Green}PowerShell 7 profile already contains dotfiles config${Reset}"
            return
        }
    }

    $templateFile = "$ScriptDir\profile.template.ps1"
    if (-not (Test-Path $templateFile)) {
        Write-Host "${Red}Error: profile.template.ps1 not found at $templateFile${Reset}"
        return
    }

    $template = Get-Content -Raw -Path $templateFile

    $block = @"
# === DOTFILES CONFIG START ===
$template
# === DOTFILES CONFIG END ===
"@

    if ($DryRun) {
        Write-Host "${Yellow}[DRY RUN] Would append to $ps7Profile`:${Reset}"
        Write-Host $block
    } else {
        $profileDir = Split-Path -Parent $ps7Profile
        if (-not (Test-Path $profileDir)) {
            New-Item -ItemType Directory -Force -Path $profileDir | Out-Null
        }
        if (-not (Test-Path $ps7Profile)) {
            New-Item -ItemType File -Path $ps7Profile | Out-Null
        }
        Add-Content -Path $ps7Profile -Value "`n$block"
        Write-Host "${Green}Configuration added to PowerShell 7 profile${Reset}"
    }
}

# ── Plugin Sync ────────────────────────────────────────────────────

function Sync-NvimPlugins {
    Print-Section "Syncing Neovim Plugins"
    if ($DryRun) {
        Write-Host "${Yellow}[DRY RUN] Would run: nvim --headless +Lazy! sync +qa${Reset}"
        return
    }
    if (Command-Exists "nvim") {
        Write-Host "${Yellow}Installing neovim plugins (this may take a while)...${Reset}"
        & nvim --headless "+Lazy! sync" "+qa" 2>$null
        Write-Host "${Green}Plugins installed${Reset}"
    } else {
        Write-Host "${Red}Neovim not found, skipping plugin installation${Reset}"
    }
}

# ── Main ───────────────────────────────────────────────────────────

Write-Host @"
${Green}
  ___        _      _     _       _       _       _
 / _ \ _   _| |_ __| | __| | __ _| |_ ___| |__   (_)_ __
| | | | | | | __/ _\ |/ _\ |/ _\ | __/ __| '_ \  | | '_ \
| |_| | |_| | || (_| | (_| | (_| | || (__| | | | | | | | |
 \___/ \__,_|\__\__,_|\__,_|\__,_|\__\___|_| |_| |_|_| |_|
${Reset}
"@

try {
    Install-Scoop
    Install-PowerShell7
    Refresh-Path
    Install-BasicTools
    Install-Neovim
    Install-LazyGit
    Install-Go
    Install-Node
    Install-WezTerm
    Install-Starship
    Install-Java
    Refresh-Path

    if ($Fonts) {
        Install-Fonts
    }

    Install-Configs
    Update-Profile
    Sync-NvimPlugins

    # Summary
    Print-Section "Installation Complete!"
} catch {
    Write-Host "${Red}ERROR: $_${Reset}"
    Write-Host "${Red}At line: $($_.InvocationInfo.ScriptLineNumber)${Reset}"
    exit 1
}

if (-not $Fonts) {
    Write-Host "${Yellow}Nerd Font not installed. Run with -Fonts to install (required for icons)${Reset}"
}

Write-Host "${Green}Next steps:${Reset}"
Write-Host "  1. ${Yellow}Restart your terminal${Reset} and run: ${Blue}pwsh${Reset} to start PowerShell 7"
Write-Host "  2. ${Yellow}Open nvim${Reset} and wait for Mason to install LSP servers"

if ($Fonts) {
    Write-Host "  3. ${Yellow}Set your terminal font${Reset} to JetBrainsMono Nerd Font"
}

Write-Host ""
Write-Host "${Green}Happy coding!${Reset}"
