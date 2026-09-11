# Starter.ps1 - Fő indító

# Konzol UTF-8 kimenet beallitasa (ekezetes karakterek helyes megjelenitesehez -
# a fajl maga mar UTF-8 BOM-mal van mentve, ez itt csak a konzol-ablak sajat
# kodlapjat allitja at, hogy a Write-Host altal kiirt szoveg is helyesen
# jelenjen meg, ne csak a fajlban legyen helyes). Windows 7 SP1-tol felfele
# mukodik, XP-n a legtobb konzol mar tamogatja a 65001-es kodlapot is - ha
# nem, a szoveg legrosszabb esetben is csak olvashatatlan lesz, de a program
# ettol meg lefut.
try {
    [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
    chcp 65001 > $null
} catch {
    # Regi rendszereken (pl. PowerShell 2.0) nem minden eleres el ez a mod -
    # ez esetben a program a rendszer alapertelmezett kodlapjaval fut tovabb.
}

# Jogosultság emelés
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -Elevated" -Verb RunAs
    exit $LASTEXITCODE
}

# Munkakönyvtár beállítása (admin Újraindítás után C:\Windows\system32 lesz)
Set-Location $PSScriptRoot

# Mappák létrehozása
New-Item -ItemType Directory -Force -Path "LOG", "Scripts", "Apps" | Out-Null

function Install-App($app, $config) {
    Write-Log "Telepítés indítása: $($app.name)"
    
    # Elmentjük a főkönyvtárat, hogy vissza tudjunk találni
    $mainDir = Get-Location
    
    # Belépünk a Scripts mappába, hogy az al-szkriptek lássák a fájljaikat
    Set-Location ".\Scripts"
    
    Write-Host "Folyamatban: Letötés/Frissítés..." -ForegroundColor Cyan
    powershell.exe -ExecutionPolicy Bypass -File ".\UpDateR.ps1" -AppId $app.id
    
    Write-Host "Folyamatban: Telepítés..." -ForegroundColor Cyan
    powershell.exe -ExecutionPolicy Bypass -File ".\Install-$($app.id).ps1" -InstallDir $config.installDir
    
    # Visszalépünk a főkönyvtárba a következő app vagy a naplózás miatt
    Set-Location $mainDir
    
    Write-Log "Sikeresen telepítve: $($app.name)"
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

# Config és AppsList betötés (javított útvonalak)
$config = Get-Content "Scripts/Config.json" | ConvertFrom-Json
$appsList = Get-Content "Apps/AppsList.json" | ConvertFrom-Json

# Alapértelmezett meghajtó választás
$drives = $config.defaultDrives
Write-Host "Alapértelmezett telepítési meghajtó választás:"
for($i=0; $i -lt $drives.Length; $i++) { Write-Host "$($i+1). $($drives[$i])" }
$driveChoice = Read-Host "Válassz (Enter = 1. $($drives[0]))"
if([string]::IsNullOrEmpty($driveChoice)) { $driveChoice = 0 }
$config.installDir = "$($drives[$driveChoice])\Program Files"
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

# Kategoria-betuk emberi olvasasu nevei a menuben
$catLabels = @{
    "E" = "Eszkozok / Kellekek"
    "M" = "Medialejatszok"
    "I" = "Internet"
    "K" = "Karbantartas"
}

# Menü kiírás
Clear-Host
Write-Host "===== SetUpER Telepítési Segéd =====" -ForegroundColor Cyan
Write-Host "0. Ajanlott telepites (csak a preferalt tetelek - lasd AppsList.json 'recommended' mezo)" -ForegroundColor Green
foreach($cat in $cats.Keys | Sort-Object) {
    $label = if($catLabels.ContainsKey($cat)) { $catLabels[$cat] } else { $cat }
    Write-Host "$cat`: $label" -ForegroundColor Yellow
    $i = 1
    foreach($app in $cats[$cat]) {
        $notReadyTag = if($app.notReady) { " [MEG NEM ELERHETO - lasd lent]" } else { "" }
        Write-Host "  $cat$i`: $($app.name)$notReadyTag" -ForegroundColor White
        $i++
    }
}
Write-Host "X. Kilépés" -ForegroundColor Green

$choice = Read-Host "`nVálassz (pl. E1, 0, X)"
if($choice -eq "X" -or $choice -eq "x") { exit }

if($choice -eq "0") {
    # "0" NEM az osszes tetelt telepiti, csak az AppsList.json-ban
    # "recommended": true-ra allitott, ajanlott tetelt kategorianként -
    # igy pl. a 4 tavfelugyeleti eszkoz kozul csak 1 (az ajanlott) telepul,
    # nem mind a negy. A preferalt tetel a JSON-ban egyenkent atallithato.
    foreach($cat in $cats.Keys | Sort-Object) {
        foreach($app in $cats[$cat]) {
            if($app.recommended -and -not $app.notReady) { Install-App $app $config }
        }
    }
} else {
    foreach($cat in $cats.Keys) {
        $apps = $cats[$cat]
        $target = $apps | Where-Object { $_.id -eq $choice -or $choice -eq "${cat}$($apps.IndexOf($_)+1)" }
        if($target) {
            if($target.notReady) {
                Write-Host "`nEz a tetel meg nincs teljesen bekotve (hianyzik hozza a kozvetlen telepito-link vagy sajat konfiguracio - pl. sajat szerver cime). Nezd meg a Scripts\Install-$($target.id).ps1 fajlt a reszletekert." -ForegroundColor Yellow
            } else {
                Install-App $target $config
            }
            break
        }
    }
}

Write-Log "Telepítés befejezve"
