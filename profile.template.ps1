# Enable colors in terminal
$env:CLICOLOR = 1
$env:LSCOLORS = "Gxfxcxdxbxegedabagacad"

# Tell the terminal we are using a 256-color/TrueColor environment
$env:TERM = "xterm-256color"

# Starship prompt
Invoke-Expression (&starship init powershell)

# Pretty ls
function l { eza --color=always --icons=always @args }
function ll { eza --color=always --icons=always -la @args }
Set-Alias -Name ls -Value l -Option AllScope

# fzf functions
function cdf {
    $dir = fd -t d '' "${args:-.}" 2>$null | `
        fzf --height 40% --reverse `
            --preview 'tree -C -L 2 {} 2>$null | Select-Object -First 200'
    if ($dir) {
        Set-Location $dir
    }
}

function cmdf {
    $cmd = Get-History -Count 90000 | ForEach-Object { $_.CommandLine } | `
        fzf --tac --height 40% --reverse
    if ($cmd) {
        [Microsoft.PowerShell.PSConsoleReadLine]::Insert($cmd)
    }
}

function cmdfe {
    param([switch]$Dry)

    $cmd = Get-History -Count 90000 | ForEach-Object { $_.CommandLine } | `
        fzf --tac --height 40% --reverse
    if (-not $cmd) { return }

    $tmp = [System.IO.Path]::GetTempFileName()
    $cmd | Set-Content -Path $tmp

    & "${env:EDITOR:-nvim}" $tmp
    if ($LASTEXITCODE -ne 0) { Remove-Item $tmp; return }

    $edited = Get-Content -Raw -Path $tmp
    Remove-Item $tmp

    if ($edited) {
        $edited = $edited.Trim()
        if ($Dry) {
            Write-Host "[DRY RUN] $edited"
        } else {
            Add-History -CommandLine $edited
            Invoke-Expression $edited
        }
    }
}

function killf {
    $proc = Get-Process | Select-Object Id, ProcessName, @{N='CPU';E={$_.CPU.ToString('F2')}}, WorkingSet | `
        fzf --height 40% --reverse --preview 'echo {}' | `
        ForEach-Object { ($_ -split '\s+')[0] }
    if ($proc) {
        Stop-Process -Id $proc -Force
    }
}

# Set default terminal editor
$env:VISUAL = "nvim"
$env:EDITOR = $env:VISUAL
$env:CVS_EDITOR = "nvim"

# PSReadLine options
if ($PSVersionTable.PSVersion -ge [version]"7.2") {
    Set-PSReadLineOption -PredictionSource History
}
Set-PSReadLineOption -EditMode Emacs
