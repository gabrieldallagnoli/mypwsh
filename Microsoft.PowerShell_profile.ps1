### PowerShell Tweaks — Clean, fast, and UNIX-inspired PowerShell profile.
### Version 1.0.0 (2025-06-28)

# Remove telemtria se executado como SYSTEM - bom para servidores e ambientes de produção
if ([bool]([System.Security.Principal.WindowsIdentity]::GetCurrent()).IsSystem) {
    [System.Environment]::SetEnvironmentVariable('POWERSHELL_TELEMETRY_OPTOUT', 'true', [System.EnvironmentVariableTarget]::Machine)
}

# Define um prompt minimalista
function prompt {
    $path = (Get-Location).Path.Replace($HOME, "~")

    $branch = ""
    try {
        $branch = git rev-parse --abbrev-ref HEAD 2>$null
    } catch {
        $branch = ""
    }

    if ($branch -and $branch -ne "HEAD") {
        $branch = " on  $branch"
    } else {
        $branch = ""
    }

    Write-Host ""
    Write-Host "" -NoNewline -ForegroundColor Blue
    Write-Host "$path " -NoNewline -ForegroundColor Black -BackgroundColor Blue
    Write-Host "" -NoNewline -ForegroundColor Blue -BackgroundColor Green
    Write-Host "$branch" -NoNewline -ForegroundColor Black -BackgroundColor Green
    Write-Host "" -NoNewline -ForegroundColor Green
    return " "
}

# Verifica atualizações do perfil
function Update-Profile {
    try {
        $url = "https://raw.githubusercontent.com/gabrieldallagnoli/powershell-tweaks/main/Microsoft.PowerShell_profile.ps1"
        $oldhash = Get-FileHash $PROFILE
        Invoke-RestMethod $url -OutFile "$env:temp/Microsoft.PowerShell_profile.ps1"
        $newhash = Get-FileHash "$env:temp/Microsoft.PowerShell_profile.ps1"
        if ($newhash.Hash -ne $oldhash.Hash) {
            Copy-Item -Path "$env:temp/Microsoft.PowerShell_profile.ps1" -Destination $PROFILE -Force
            Write-Host "O perfil foi atualizado. Reinicie o shell para aplicar as mudanças." -ForegroundColor Magenta
        } else {
            Write-Host "O perfil já está atualizado." -ForegroundColor Green
        }
    } catch {
        Write-Error "Não foi possível verificar atualizações do perfil — $_."
    } finally {
        Remove-Item "$env:temp/Microsoft.PowerShell_profile.ps1" -ErrorAction SilentlyContinue
    }
}

# Inicializa o zoxide (cd inteligente)
Invoke-Expression (& { (zoxide init powershell | Out-String) })