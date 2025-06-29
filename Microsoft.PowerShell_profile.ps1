### PowerShell Tweaks — Clean, fast, and UNIX-inspired PowerShell profile.
### Version 1.0.1 (2025-06-29)

# =============================================
# ============ Definições Gerais ==============
# =============================================

$devmode = $false

if ($devmode) {
    Write-Host "Modo de Desenvolvedor" -ForegroundColor Magenta
}

# ---------------------------------------------
# -------- Desativação de Telemetria ----------
# ---------------------------------------------

[System.Environment]::SetEnvironmentVariable('POWERSHELL_TELEMETRY_OPTOUT', 'true', [System.EnvironmentVariableTarget]::Machine)
[System.Environment]::SetEnvironmentVariable('POWERSHELL_TELEMETRY_OPTOUT', 'true', [System.EnvironmentVariableTarget]::User)

# =============================================
# ====== Gerenciamento de Atualizações ========
# =============================================

$updateFrequency = 7 # Vai buscar por atualizações a cada 7 dias (-1 para verificar sempre)
$updateLog = [Environment]::GetFolderPath("MyDocuments") + "\PowerShell\LastUpdate.txt"

# ---------------------------------------------
# ---------- Atualização do Perfil ------------
# ---------------------------------------------

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
        Write-Error "Falha ao atualizar o perfil — $_."
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
            Write-Host "O PowerShell foi atualizado. Reinicie o shell para aplicar as mudanças." -ForegroundColor Magenta
        } else {
            Write-Host "O PowerShell já está atualizado." -ForegroundColor Green
        }
    } catch {
        Write-Error "Falha ao atualizar o PowerShell — $_."
    }
}

# ---------------------------------------------
# --------- Atualizações Automáticas ----------
# ---------------------------------------------

if (-not $devmode -and `
    ($updateFrequency -eq -1 -or `
      -not (Test-Path $updateLog) -or `
      ((Get-Date) - [datetime]::ParseExact((Get-Content -Path $updateLog), 'yyyy-MM-dd', $null)).TotalDays -gt $updateFrequency)) {

    Update-Profile
    Update-PowerShell
    $currentDate = Get-Date -Format 'yyyy-MM-dd'
    $currentDate | Out-File -FilePath $updateLog

} elseif ($devmode -and `
    ($updateFrequency -eq -1 -or `
      -not (Test-Path $updateLog) -or `
      ((Get-Date) - [datetime]::ParseExact((Get-Content -Path $updateLog), 'yyyy-MM-dd', $null)).TotalDays -gt $updateFrequency)) {

    Write-Host "Atualizações automáticas ignoradas" -ForegroundColor Cyan
}

# Inicializa o Zoxide
Invoke-Expression (& { (zoxide init powershell | Out-String) })