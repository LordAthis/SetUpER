# Starter.ps1
# Telepítési segédprogram starter

param(
    [switch]$Interactive
)

# Logolás függvény
function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    Write-Output $logMessage
    Add-Content -Path "setup.log" -Value $logMessage
}

# Config betöltése
$configPath = "Config.json"
if (-not (Test-Path $configPath)) {
    Write-Log "Config.json not found!" "ERROR"
    exit 1
}
$config = Get-Content $configPath | ConvertFrom-Json

# Compatibility és AppsList betöltése
$compatPath = "Compatibility.json"
$appsPath = "AppsList.json"

if (-not (Test-Path $compatPath)) { Write-Log "Compatibility.json not found!" "ERROR"; exit 1 }
if (-not (Test-Path $appsPath)) { Write-Log "AppsList.json not found!" "ERROR"; exit 1 }

$compatibility = Get-Content $compatPath | ConvertFrom-Json
$appsList = Get-Content $appsPath | ConvertFrom-Json

Write-Log "Configuration loaded from $configPath, $compatPath, $appsPath"

# Rendszer információ lekérdezés
$osVersion = [Environment]::OSVersion.Version
$osCaption = (Get-WmiObject -Class Win32_OperatingSystem).Caption
Write-Log "OS Version: $osCaption ($osVersion)"

# Compatibility ellenőrzések
foreach ($check in $compatibility.systemChecks) {
    $result = Invoke-Expression $check.command
    Write-Log "Compatibility check '$($check.name)': $result"
    if (-not $result) {
        Write-Log "Failed compatibility check: $($check.name)" "WARN"
    }
}

# Műveletek listája - könnyen bővíthető
$actions = @(
    @{Id="A1"; Name="Total Commander telepítés/frissítés"; Script="Install-TC.ps1"},
    @{Id="A2"; Name="H.D.Sentinel telepítés/frissítés"; Script="Install-HDS.ps1"},
    @{Id="B1"; Name="VLC MediaPlayer telepítés/frissítés"; Script="Install-VLC.ps1"},
    @{Id="B2"; Name="Brave böngésző telepítés/frissítés"; Script="Install-Brave.ps1"},
    @{Id="C1"; Name="WinZip telepítés/frissítés"; Script="Install-WinZip.ps1"},
    @{Id="C2"; Name="7-Zip telepítés/frissítés"; Script="Install-7Zip.ps1"}
    # Új elem hozzáadása: csak új sorok beszúrása ide
)

if ($Interactive) {
    Write-Host "Elérhető műveletek:"
    $actions | ForEach-Object { Write-Host "$($_.Id) - $($_.Name)" }
    
    $selected = Read-Host "Válassz ID-t (pl. A1) vagy 'all' mindhez"
    if ($selected -eq "all") {
        foreach ($action in $actions) {
            Invoke-Action $action
        }
    } else {
        $action = $actions | Where-Object { $_.Id -eq $selected }
        if ($action) { Invoke-Action $action }
    }
} else {
    # Alapértelmezetten mindent lefuttat
    foreach ($action in $actions) {
        Invoke-Action $action
    }
}

function Invoke-Action {
    param($action)
    Write-Log "Executing $($action.Name)"
    if (Test-Path $action.Script) {
        & $action.Script
        if ($LASTEXITCODE -ne 0) {
            Write-Log "Failed: $($action.Script)" "ERROR"
        }
    } else {
        Write-Log "Script not found: $($action.Script)" "ERROR"
    }
}

Write-Log "Starter.ps1 befejezve"
