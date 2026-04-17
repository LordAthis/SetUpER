# Starter.ps1 - Fő indí­tó

# Jogosultság emelés
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -Elevated" -Verb RunAs
    exit $LASTEXITCODE
}

# Mappák létrehozása
New-Item -ItemType Directory -Force -Path "LOG", "Scripts", "Apps" | Out-Null

function Install-App($app, $config) {
    Write-Log "TelepĂ­tĂ©s indĂ­tĂˇsa: $($app.name)"
    
    # Elmentjük a főkönyvtárat, hogy vissza tudjunk találni
    $mainDir = Get-Location
    
    # Belépünk a Scripts mappába, hogy az al-szkriptek lássák a fájljaikat
    Set-Location ".\Scripts"
    
    Write-Host "Folyamatban: LetĂ¶ltĂ©s/FrissĂ­tĂ©s..." -ForegroundColor Cyan
    & ".\UpDateR.ps1" -AppId $app.id
    
    Write-Host "Folyamatban: TelepĂ­tĂ©s..." -ForegroundColor Cyan
    & ".\Install-$($app.id).ps1" -InstallDir $config.installDir
    
    # Visszalépünk a főkönyvtárba a következő app vagy a naplózás miatt
    Set-Location $mainDir
    
    Write-Log "Sikeresen telepĂ­tve: $($app.name)"
}


function Show-Progress($text, $scriptBlock, $argumente) {
    # Itt az -ArgumentList kapja meg a tömböt
    $job = Start-Job -ScriptBlock $scriptBlock -ArgumentList $argumente
    while($job.State -eq "Running") {
        Write-Host "$text [$('.' * ((Get-Date).Second % 4 + 1))]" -NoNewline
        Start-Sleep 1
        Write-Host "`r$((' ' * 50))`r" -NoNewline
    }
    Receive-Job $job
    Remove-Job $job
}


function Write-Log {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $logMessage = "[$timestamp] [$Level] $Message"
    Write-Host $logMessage -ForegroundColor $(if($Level -eq "ERROR"){"Red"}elseif($Level -eq "WARN"){"Yellow"}else{"White"})
    Add-Content -Path "LOG/setup.log" -Value $logMessage
}

# Config Ă©s AppsList betĂ¶ltĂ©s (javĂ­tott Ăştvonalak)
$config = Get-Content "Scripts/Config.json" | ConvertFrom-Json
$appsList = Get-Content "Apps/AppsList.json" | ConvertFrom-Json

# AlapĂ©rtelmezett meghajtĂł vĂˇlasztĂˇs
$drives = $config.defaultDrives
Write-Host "AlapĂ©rtelmezett telepĂ­tĂ©si meghajtĂł vĂˇlasztĂˇs:"
for($i=0; $i -lt $drives.Length; $i++) { Write-Host "$($i+1). $($drives[$i])" }
$driveChoice = Read-Host "VĂˇlassz (Enter = 1. $($drives[0]))"
if([string]::IsNullOrEmpty($driveChoice)) { $driveChoice = 0 }
$config.installDir = "$($drives[$driveChoice])\Program Files"
Write-Log "TelepĂ­tĂ©si Ăştvonal: $($config.installDir)"

# TelepĂ­tett app-ek lekĂ©rdezĂ©s
$installedApps = @{}
Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" | ForEach-Object {
    $name = $_.GetValue('DisplayName')
    if($name) { $installedApps[$name] = $true }
}

# KategĂłriĂˇk csoportosĂ­tĂˇsa
$cats = @{}
foreach($app in $appsList.apps) {
    if(-not $installedApps[$app.name]) {
        if(-not $cats[$app.category]) { $cats[$app.category] = @() }
        $cats[$app.category] += $app
    }
}

# MenĂĽ kiĂ­rĂˇs
Clear-Host
Write-Host "===== SetUpER TelepĂ­tĂ©si SegĂ©d =====" -ForegroundColor Cyan
Write-Host "0. Ă–sszes telepĂ­tĂ©s" -ForegroundColor Green
foreach($cat in $cats.Keys | Sort-Object) {
    Write-Host "$cat`:" -ForegroundColor Yellow
    $i = 1
    foreach($app in $cats[$cat]) {
        Write-Host "  $cat$i`: $($app.name)" -ForegroundColor White
        $i++
    }
}
Write-Host "X. KilĂ©pĂ©s" -ForegroundColor Red

$choice = Read-Host "`nVĂˇlassz (pl. A1, 0, X)"
if($choice -eq "X" -or $choice -eq "x") { exit }

if($choice -eq "0") {
    foreach($cat in $cats.Keys | Sort-Object) {
        foreach($app in $cats[$cat]) {
            Install-App $app $config
        }
    }
} else {
    foreach($cat in $cats.Keys) {
        $apps = $cats[$cat]
        $target = $apps | Where-Object { $_.id -eq $choice -or $choice -eq "${cat}$($apps.IndexOf($_)+1)" }
        if($target) { Install-App $target $config; break }
    }
}

Write-Log "Telepítés befejezve"

