# ----------------- v1.02 — 02/07/2025 ------------------
# https://github.com/gabrieldallagnoli/powershell-profile

# =============================================
# =============== Parâmetros ==================
# =============================================

$devmode = $false # Defina como $true caso for editar o perfil, caso contrário, suas alterações serão sobrescritas

if ($devmode) {
    Write-Host "Modo de Desenvolvedor ativado." -ForegroundColor Magenta
}

# =============================================
# =============== Atualizações ================
# =============================================

$autoUpdateFrequency = 7 # Busca por atualizações a cada x dias, defina como -1 para verificar sempre
$autoUpdateLog = [Environment]::GetFolderPath("MyDocuments") + "\PowerShell\LastAutoUpdate.txt"

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
# ---------- Atualização do Perfil ------------
# ---------------------------------------------

function Update-Profile {
    try {
        Write-Host "Verificando atualizações do perfil..." -ForegroundColor Cyan
        $url = "https://raw.githubusercontent.com/gabrieldallagnoli/powershell-profile/main/Microsoft.PowerShell_profile.ps1"
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
# ---------- Atualização Automática -----------
# ---------------------------------------------

if (-not $devmode -and `
    ($autoUpdateFrequency -eq -1 -or `
      -not (Test-Path $autoUpdateLog) -or `
      ((Get-Date) - [datetime]::ParseExact((Get-Content -Path $autoUpdateLog), 'dd-MM-yyyy', $null)).TotalDays -gt $autoUpdateFrequency)) {

    Update-PowerShell
    Update-Profile
    $currentDate = Get-Date -Format 'dd-MM-yyyy'
    $currentDate | Out-File -FilePath $autoUpdateLog

} elseif ($devmode -and `
    ($autoUpdateFrequency -eq -1 -or `
      -not (Test-Path $autoUpdateLog) -or `
      ((Get-Date) - [datetime]::ParseExact((Get-Content -Path $autoUpdateLog), 'dd-MM-yyyy', $null)).TotalDays -gt $autoUpdateFrequency)) {

    Write-Host "Atualização automática bloqueada." -ForegroundColor Magenta
}

# Inicializa o Zoxide
Invoke-Expression (& { (zoxide init powershell | Out-String) })