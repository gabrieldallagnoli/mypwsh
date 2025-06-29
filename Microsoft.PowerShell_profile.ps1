### PowerShell Tweaks — Clean, fast, and UNIX-inspired PowerShell profile.
### Version 1.0.1 (2025-06-29)

# =============================================
# ============ Definições Gerais ==============
# =============================================

$devmode = $false # Desabilita atualizações automáticas (útil para editar o perfil)

if ($devmode) {
    Write-Host "Modo de Desenvolvedor ativado." -ForegroundColor Magenta
}

# ---------------------------------------------
# -------- Desativação de Telemetria ----------
# ---------------------------------------------

[System.Environment]::SetEnvironmentVariable('POWERSHELL_TELEMETRY_OPTOUT', 'true', [System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable('POWERSHELL_TELEMETRY_OPTOUT', 'true', [System.EnvironmentVariableTarget]::User)

# =============================================
# ====== Gerenciamento de Atualizações ========
# =============================================

$autoUpdateFrequency = 7 # Vai buscar por atualizações a cada 7 dias (-1 para verificar sempre)
$autoUpdateLog = [Environment]::GetFolderPath("MyDocuments") + "\PowerShell\LastAutoUpdate.txt"

# ---------------------------------------------
# ---------- Atualização do Perfil ------------
# ---------------------------------------------

function Update-Profile {
    try {
        Write-Host "Verificando atualizações do perfil..." -ForegroundColor Cyan
        $url = "https://raw.githubusercontent.com/gabrieldallagnoli/powershell-tweaks/main/Microsoft.PowerShell_profile.ps1"
        $oldhash = Get-FileHash $PROFILE
        Invoke-RestMethod $url -OutFile "$env:temp/Microsoft.PowerShell_profile.ps1"
        $newhash = Get-FileHash "$env:temp/Microsoft.PowerShell_profile.ps1"
        if ($newhash.Hash -ne $oldhash.Hash) {
            Copy-Item -Path "$env:temp/Microsoft.PowerShell_profile.ps1" -Destination $PROFILE -Force
            Write-Host "Perfil atualizado. Reinicie o shell para aplicar as mudanças." -ForegroundColor Magenta
        } else {
            Write-Host "Perfil já está atualizado." -ForegroundColor Green
        }
    } catch {
        Write-Host "Falha ao atualizar o perfil: $_" -ForegroundColor Red
    } finally {
        Remove-Item "$env:temp/Microsoft.PowerShell_profile.ps1" -ErrorAction SilentlyContinue
    }
}

# ---------------------------------------------
# -------- Atualização do PowerShell ----------
# ---------------------------------------------

function Update-PowerShell {
    try {
        Write-Host "Verificando atualizações do PowerShell..." -ForegroundColor Cyan
        $updateNeeded = $false
        $currentVersion = $PSVersionTable.PSVersion.ToString()
        $gitHubApiUrl = "https://api.github.com/repos/PowerShell/PowerShell/releases/latest"
        $latestReleaseInfo = Invoke-RestMethod -Uri $gitHubApiUrl
        $latestVersion = $latestReleaseInfo.tag_name.Trim('v')
        if ($currentVersion -lt $latestVersion) {
            $updateNeeded = $true
        }

        if ($updateNeeded) {
            Write-Host "Atualizando PowerShell..." -ForegroundColor Yellow
            Start-Process powershell.exe -ArgumentList "-NoProfile -Command winget upgrade Microsoft.PowerShell --accept-source-agreements --accept-package-agreements" -Wait -NoNewWindow
            Write-Host "PowerShell atualizado. Reinicie o shell para aplicar as mudanças." -ForegroundColor Magenta
        } else {
            Write-Host "PowerShell já está atualizado." -ForegroundColor Green
        }
    } catch {
        Write-Host "Falha ao atualizar o PowerShell: $_" -ForegroundColor Red
    }
}

# ---------------------------------------------
# ---------- Atualização Automática -----------
# ---------------------------------------------

if (-not $devmode -and `
    ($autoUpdateFrequency -eq -1 -or `
      -not (Test-Path $autoUpdateLog) -or `
      ((Get-Date) - [datetime]::ParseExact((Get-Content -Path $autoUpdateLog), 'dd/MM/yyyy', $null)).TotalDays -gt $autoUpdateFrequency)) {

    Update-Profile
    Update-PowerShell
    $currentDate = Get-Date -Format 'dd/MM/yyyy'
    $currentDate | Out-File -FilePath $autoUpdateLog

} elseif ($devmode -and `
    ($autoUpdateFrequency -eq -1 -or `
      -not (Test-Path $autoUpdateLog) -or `
      ((Get-Date) - [datetime]::ParseExact((Get-Content -Path $autoUpdateLog), 'dd/MM/yyyy', $null)).TotalDays -gt $autoUpdateFrequency)) {

    Write-Host "Atualização automática bloqueada." -ForegroundColor Magenta
}

# Inicializa o Zoxide (cd inteligente)
Invoke-Expression (& { (zoxide init powershell | Out-String) })