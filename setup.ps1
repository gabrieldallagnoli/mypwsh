# PowerShell Tweaks — Installation Script

# Get repo directory
$REPO = Get-Location

# Create symbolic link to $PROFILE
New-Item -Path $HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1 -ItemType SymbolicLink -Target $REPO\Microsoft.PowerShell_profile.ps1 -Force | Out-Null