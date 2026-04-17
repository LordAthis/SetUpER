# Starter.ps1 - Fő indító

# Jogosultság ellenőrzés és emelés
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -Elevated" -Verb RunAs
    exit $LASTEXITCODE
}

# Mappa létrehozás
New-Item -ItemType Directory -Force -Path "LOG", "Scripts", "Apps" | Out-Null

function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    Write-Host $logMessage -ForegroundColor $(if($Level -eq "ERROR"){"Red"}elseif($Level -eq "WARN"){"Yellow"}else{"White"})
    Add-Content -Path "LOG/setup.log" -Value $logMessage
}

# Config betöltés
$config = Get-Content "Config.json" | ConvertFrom-Json
$appsList = Get-Content "AppsList.json" | ConvertFrom-Json

# Alapértelmezett meghajtó választás
$drives = $config.defaultDrives
Write-Host "Alapértelmezett telepítési meghajtó választás:"
for($i=0; $i -lt $drives.Length; $i++) { Write-Host "$($i+1). $($drives[$i])" }
$driveChoice = Read-Host "Válassz (Enter = 1. $($drives[0]))"
if([string]::IsNullOrEmpty($driveChoice)) { $driveChoice = 0 }
$config.installDir = "$($drives[$driveChoice-1])\\Program Files"
Write-Log "Telepítési útvonal: $($config.installDir)"

# Telepített app-ek lekérdezés
$installedApps = @{}
Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" | ForEach-Object {
    $name = $_.GetValue('DisplayName')
    if($name) { $installedApps[$name] = $true }
}

# Kategóriák csoportosítása
$cats = @{}
foreach($app in $appsList.apps) {
    if(-not $installedApps[$app.name]) {
        if(-not $cats[$app.category]) { $cats[$app.category] = @() }
        $cats[$app.category] += $app
    }
}

# Menü kiírás
Clear-Host
Write-Host "===== SetUpER Telepítési Segéd =====" -ForegroundColor Cyan
Write-Host "0. Összes telepítés" -ForegroundColor Green
foreach($cat in $cats.Keys | Sort-Object) {
    Write-Host "$cat`:" -ForegroundColor Yellow
    $i = 1
    foreach($app in $cats[$cat]) {
        Write-Host "  $cat$i`: $($app.name)" -ForegroundColor White
        $i++
    }
}
Write-Host "X. Kilépés" -ForegroundColor Red

$choice = Read-Host "`nVálassz (pl. A1, 0, X)"
if($choice -eq "X" -or $choice -eq "x") { exit }

if($choice -eq "0") {
    # Összes
    foreach($cat in $cats.Keys | Sort-Object) {
        foreach($app in $cats[$cat]) {
            Install-App $app $config
        }
    }
} else {
    # Egyedi
    foreach($cat in $cats.Keys) {
        $apps = $cats[$cat]
        $target = $apps | Where-Object { $_.id -eq $choice -or $choice -eq "${cat}$($apps.IndexOf($_)+1)" }
        if($target) { Install-App $target $config; break }
    }
}

Write-Log "Telepítés befejezve"

function Install-App($app, $config) {
    Write-Log "Telepítés indítása: $($app.name)"
    Show-Progress "Letöltés..." { & Scripts/UpDateR.ps1 -AppId $app.id }
    Show-Progress "Telepítés..." { & Scripts/Install-$($app.id.Split('-')[0]).ps1 -InstallDir $config.installDir }
    Write-Log "Sikeresen telepítve: $($app.name)"
}

function Show-Progress($text, $scriptBlock) {
    $job = Start-Job -ScriptBlock $scriptBlock
    while($job.State -eq "Running") {
        Write-Host "$text [$('.' * ((Get-Date).Second % 4 + 1))]" -NoNewline
        Start-Sleep 1
        Write-Host "`r$((' ' * 50))`r" -NoNewline
    }
    Receive-Job $job
    Remove-Job $job
}
