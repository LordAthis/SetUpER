param([string]$InstallDir = "C:\Program Files")

# --- Útvonalak előkészítése ---
$InstallDir = $InstallDir.Trim().TrimEnd('\').TrimEnd('"')
if ($InstallDir -notlike "*totalcmd*") {
    $InstallDir = Join-Path $InstallDir "totalcmd"
}
$InstallDir = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($InstallDir)

$appPath   = [System.IO.Path]::GetFullPath("$PSScriptRoot/../Apps/TC.exe")
$iniSource = [System.IO.Path]::GetFullPath("$PSScriptRoot/../Apps/Conf/wincmd.ini")
$infSource = [System.IO.Path]::GetFullPath("$PSScriptRoot/../Apps/Conf/TC_install.inf")
$tempDir    = "C:\Temp"
$tempIni    = Join-Path $tempDir "wincmd_backup.ini"
$logFile    = "$PSScriptRoot/../LOG/setup.log"

# --- Log-függvény (helyi, ha a Starter nem hí­vta be) ---
function Write-TCLog {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "[$timestamp] [$Level] [TC] $Message"
    Write-Host $entry -ForegroundColor $(if($Level -eq "ERROR"){"Red"}elseif($Level -eq "WARN"){"Yellow"}else{"Cyan"})
    if (!(Test-Path (Split-Path $logFile))) { New-Item -ItemType Directory -Force -Path (Split-Path $logFile) | Out-Null }
    Add-Content -Path $logFile -Value $entry
}

Write-TCLog "=== Total Commander telepí­és kezdete ==="
Write-TCLog "Célkönyvtár: $InstallDir"

# -------------------------------------------------------
# 1. Registry-ellenőrzés: telepítve van-e már a TC?
# -------------------------------------------------------
$regPaths = @(
    "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*",
    "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
)

$existingInstall = $null
foreach ($rp in $regPaths) {
    $existingInstall = Get-ChildItem $rp -ErrorAction SilentlyContinue |
        Where-Object { $_.GetValue('DisplayName') -like "*Total Commander*" } |
        Select-Object -First 1
    if ($existingInstall) { break }
}

$alreadyInstalled = $false
$existingPath     = $null

if ($existingInstall) {
    $existingPath = $existingInstall.GetValue('InstallLocation')
    if ([string]::IsNullOrEmpty($existingPath)) {
        $uninstStr = $existingInstall.GetValue('UninstallString')
        if ($uninstStr) {
            $existingPath = Split-Path $uninstStr -Parent
        }
    }
    $alreadyInstalled = $true
    Write-TCLog "TC már telepítve van. Helye: $existingPath"
} else {
    Write-TCLog "TC nincs telepí­tve, friss telepí­tés következik."
}

# -------------------------------------------------------
# 2. Ha már telepítve: INI mentés ajánlata
# -------------------------------------------------------
$savedIni = $false
if ($alreadyInstalled -and $existingPath -and (Test-Path $existingPath)) {
    $currentIni = Join-Path $existingPath "wincmd.ini"
    if (Test-Path $currentIni) {
        Write-Host ""
        Write-Host "Létező wincmd.ini található: $currentIni" -ForegroundColor Yellow
        $answer = Read-Host "Mentsük el a felhasználói wincmd.ini fájlt a telepítés előtt? (I/N)"
        if ($answer -match "^[Ii]$") {
            if (!(Test-Path $tempDir)) { New-Item -ItemType Directory -Force -Path $tempDir | Out-Null }
            Copy-Item -Path $currentIni -Destination $tempIni -Force
            if (Test-Path $tempIni) {
                Write-TCLog "wincmd.ini elmentve ide: $tempIni"
                $savedIni = $true
            } else {
                Write-TCLog "wincmd.ini mentése SIKERTELEN!" "ERROR"
            }
        } else {
            Write-TCLog "Felhasználó nem kérte az INI mentését." "WARN"
        }
    } else {
        Write-TCLog "Nem található wincmd.ini a meglévő telepí­tési mappában." "WARN"
    }
}

# -------------------------------------------------------
# 3. install.inf előkészítése és telepí­tés
# -------------------------------------------------------
Write-TCLog "appPath feloldva: $appPath"
Write-TCLog "infSource feloldva: $infSource"

if (!(Test-Path $appPath)) {
    Write-TCLog "TC telepí­tő nem található: $appPath" "ERROR"
    Read-Host "Nyomj Entert a kilépéshez"
    exit 1
}

$appsDir = Split-Path $appPath -Parent

# install.inf: dinamikusan generáljuk a tényleges InstallDir-rel
$infUsed = $false
if (Test-Path $infSource) {
    # Beolvassuk a sablon INF-et, és felülí­rjuk a directory= sort
    $infContent = Get-Content $infSource -Raw
    $infContent = $infContent -replace '(?m)^directory=.*$', "directory=$InstallDir"
    # [Version] szekció ver= sorát konkrétra cseréljük (wildcard-ot nem fogad el a TC)
    $infContent = $infContent -replace '(?m)^ver=.*$', "ver=11.03"
    $infTarget = Join-Path $appsDir "install.inf"
    # PS 5.1 kompatibilis BOM-mentes UTF-8 í­rás
    [System.IO.File]::WriteAllText($infTarget, $infContent, [System.Text.UTF8Encoding]::new($false))
    Write-TCLog "install.inf generálva: $infTarget (directory=$InstallDir)"
    $infUsed = $true
} else {
    Write-TCLog "install.inf sablon nem található ($infSource), csak /S /D kapcsolókkal fut a telepítő." "WARN"
}

Write-TCLog "Telepítő indí­tása: $appPath /S /D=$InstallDir (WorkingDir: $appsDir)"
$argList = "/S /D=$InstallDir"
$process = Start-Process -FilePath $appPath -ArgumentList $argList -WorkingDirectory $appsDir -Wait -NoNewWindow -PassThru

Write-TCLog "Telepítő kilépési kód: $($process.ExitCode)"

if ($process.ExitCode -ne 0) {
    Write-TCLog "Telepítés hibával zárult (ExitCode: $($process.ExitCode))!" "ERROR"
    exit $process.ExitCode
}

# install.inf ideiglenes másolatának tárlása
if ($infUsed) {
    $infTarget = Join-Path (Split-Path $appPath -Parent) "install.inf"
    Remove-Item $infTarget -ErrorAction SilentlyContinue
}

# Rövid várakozás a telepítő utáni zárásra
Start-Sleep -Seconds 5

# -------------------------------------------------------
# 4. INI kezelés a telepítés után
# -------------------------------------------------------
# Ellenőrzés: tényleg települt-e a program (nem csak a mappa)?
$tcExe = Join-Path $InstallDir "TOTALCMD.EXE"
if (!(Test-Path $tcExe)) {
    Write-TCLog "TOTALCMD.EXE nem található a célmappában - a telepírés nem sikerült, INI másolás kihagyva." "ERROR"
    exit 1
}

$destIni = Join-Path $InstallDir "wincmd.ini"

if ($savedIni) {
    # --- Visszamásoljuk a mentett felhasználói INI-t ---
    Copy-Item -Path $tempIni -Destination $destIni -Force
    if (Test-Path $destIni) {
        Write-TCLog "Felhasználói wincmd.ini visszamásolva: $destIni"
        Remove-Item $tempIni -ErrorAction SilentlyContinue
        Write-TCLog "Ideiglenes mentés törölve: $tempIni"
    } else {
        Write-TCLog "Visszamásolás SIKERTELEN: $destIni" "ERROR"
    }
} elseif (!$alreadyInstalled -and (Test-Path $iniSource)) {
    # --- Friss telepítés: Apps\Conf\wincmd.ini másolása ---
    Copy-Item -Path $iniSource -Destination $destIni -Force
    if (Test-Path $destIni) {
        Write-TCLog "Alapértelmezett wincmd.ini alkalmazva: $destIni"
    } else {
        Write-TCLog "wincmd.ini másolása SIKERTELEN: $destIni" "ERROR"
    }
} else {
    Write-TCLog "INI másolás kihagyva (felhasználó döntése vagy forrásfájl hiánya)." "WARN"
}

Write-TCLog "=== Total Commander telepítés befejezve ==="
