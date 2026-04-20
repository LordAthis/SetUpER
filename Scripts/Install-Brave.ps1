param([string]$InstallDir = "C:\Program Files")

$appPath = [System.IO.Path]::GetFullPath("$PSScriptRoot/../Apps/Brave.exe")
$logFile = [System.IO.Path]::GetFullPath("$PSScriptRoot/../LOG/setup.log")
$regUrl  = "https://raw.githubusercontent.com/LordAthis/CleanBrave_WinReg/refs/heads/main/cleanbrave.reg"
$tempReg = Join-Path $env:TEMP "cleanbrave.reg"

function Write-BraveLog {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "[$timestamp] [$Level] [Brave] $Message"
    $color = if ($Level -eq "ERROR") { "Red" } elseif ($Level -eq "WARN") { "Yellow" } else { "Cyan" }
    Write-Host $entry -ForegroundColor $color
    Add-Content -Path $logFile -Value $entry -ErrorAction SilentlyContinue
}

# Futó folyamat ellenőrzése
function Test-AndStopProcess {
    param([string]$ProcessName, [string]$AppName)
    $running = Get-Process $ProcessName -ErrorAction SilentlyContinue
    if ($running) {
        Write-Host ""
        Write-Host "FIGYELEM: $AppName jelenleg fut!" -ForegroundColor Yellow
        $valasz = Read-Host "Zarjuk be a telepites elott? (I/N)"
        if ($valasz -match "^[Ii]$") {
            Stop-Process -Name $ProcessName -Force -ErrorAction SilentlyContinue
            Start-Sleep -Seconds 2
            Write-BraveLog "Brave folyamat leallitva."
        } else {
            Write-BraveLog "Felhasznalo nem zaratta be a Brave-et - telepites folytatodik." "WARN"
        }
    }
}

Write-BraveLog "=== Brave telepites kezdete ==="

if (!(Test-Path $appPath)) {
    Write-BraveLog "Brave.exe nem talalhato: $appPath" "ERROR"
    exit 1
}

# Futó Brave ellenőrzése
Test-AndStopProcess "brave" "Brave"

# Telepítés
Write-BraveLog "Telepito inditasa: $appPath"
$process = Start-Process -FilePath $appPath -ArgumentList "--silent --install" -Wait -NoNewWindow -PassThru
Write-BraveLog "Telepito kilepesi kod: $($process.ExitCode)"

if ($process.ExitCode -ne 0) {
    Write-BraveLog "Telepites hibával zarult: $($process.ExitCode)" "ERROR"
    exit $process.ExitCode
}

# Registry beállítások (CleanBrave)
Write-BraveLog "Registry beallitasok letoltese..."
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

try {
    try {
        Invoke-WebRequest -Uri $regUrl -OutFile $tempReg -UseBasicParsing -ErrorAction Stop
    } catch {
        Write-BraveLog "Sima letoltes sikertelen, BITS..." "WARN"
        Start-BitsTransfer -Source $regUrl -Destination $tempReg -ErrorAction Stop
    }

    Start-Process "reg.exe" -ArgumentList "import `"$tempReg`"" -Wait -NoNewWindow
    Write-BraveLog "Registry beallitasok alkalmazva."

    # Ellenőrzés
    $regContent = Get-Content $tempReg -Raw
    if ($regContent -match "
