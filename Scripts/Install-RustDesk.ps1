# Verzio: v1.2.0 - 2026-09-15
# v1.2.0 - UJ: opcionalis sajat-szerver konfiguracio (Apps\Conf\rustdesk-
# server.json, sablon: rustdesk-server.json.example) - ha a felhasznalo
# kitolti, a telepites utan a RustDesk automatikusan a sajat kozvetito
# (relay/ID) szerveret hasznalja + opcionalisan allando jelszot kap
# (felugyelet nelkuli eleres). Konfig nelkul VALTOZATLANUL a nyilvanos
# RustDesk-szerverrel mukodik, ahogy eddig. Forras/minta: a felhasznalo
# altal hozott Gemini-beszelgetes RustDesk telepito scriptje (lasd az RTS
# projekt "Gemini_RustDesk_beszelgetes_2026-09-15.md" jegyzetet).
param([string]$InstallDir)

$logFile = "$PSScriptRoot/../LOG/setup.log"

function Write-RustDeskLog {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $entry = "[$timestamp] [$Level] [RustDesk] $Message"
    Write-Host $entry -ForegroundColor $(if($Level -eq "ERROR"){"Red"}elseif($Level -eq "WARN"){"Yellow"}else{"Cyan"})
    $logDir = Split-Path $logFile
    if (!(Test-Path $logDir)) { New-Item -ItemType Directory -Force -Path $logDir | Out-Null }
    Add-Content -Path $logFile -Value $entry
}

$appPath = Join-Path $PSScriptRoot "../Apps/RustDesk.exe"

if (!(Test-Path $appPath)) {
    Write-RustDeskLog "A telepito fajl nem talalhato: $appPath - futtasd eloszor az UpDateR.ps1-et." "ERROR"
    exit 1
}

Write-RustDeskLog "RustDesk csendes telepitese..."
# A RustDesk telepito a --silent-install kapcsolot tamogatja (nincs sajat
# celmappa-valasztas, a program a sajat alapertelmezett helyere telepul).
$installProcess = Start-Process -FilePath $appPath -ArgumentList "--silent-install" -Wait -PassThru
if ($installProcess.ExitCode -ne 0) {
    Write-RustDeskLog "A telepito hibakoddal fejezodott be: $($installProcess.ExitCode)" "WARN"
} else {
    Write-RustDeskLog "RustDesk sikeresen telepitve."
}

$rustdeskExe = "C:\Program Files\RustDesk\rustdesk.exe"
if (!(Test-Path $rustdeskExe)) {
    Write-RustDeskLog "A RustDesk nem talalhato a vart helyen ($rustdeskExe) - a sajat-szerver konfiguracio kimarad." "ERROR"
    exit 1
}

# --- Opcionalis sajat-szerver konfiguracio ---
$configPath = Join-Path $PSScriptRoot "../Apps/Conf/rustdesk-server.json"
if (!(Test-Path $configPath)) {
    Write-RustDeskLog "Nincs egyedi szerver-konfig (Apps\Conf\rustdesk-server.json) - a nyilvanos RustDesk-szerver marad aktiv (alapertelmezett)."
    Write-RustDeskLog "Megjegyzes: a Apps\Conf\rustdesk-server.json.example fajlbol keszitheto sajat konfig, ha kesobb szukseg lenne ra."
} else {
    try {
        $config = Get-Content -Raw -Path $configPath | ConvertFrom-Json
    } catch {
        Write-RustDeskLog "A rustdesk-server.json ervenytelen JSON - a sajat-szerver konfiguracio kimarad, a nyilvanos szerver marad aktiv." "ERROR"
        $config = $null
    }

    if ($config -and $config.host) {
        Write-RustDeskLog "Sajat szerver beallitasa: $($config.host)"
        $serverArg = "--custom-config host=$($config.host)"
        if ($config.key) { $serverArg += ",key=$($config.key)" }
        if ($config.api_server) { $serverArg += ",api_server=$($config.api_server)" }

        Start-Process -FilePath $rustdeskExe -ArgumentList $serverArg -Wait
        Write-RustDeskLog "Szerver adatok beallitva."

        if ($config.password -and $config.password.Trim() -ne "") {
            Write-RustDeskLog "Allando jelszo beallitasa (felugyelet nelkuli eleres)..."
            Start-Process -FilePath $rustdeskExe -ArgumentList "--password `"$($config.password)`"" -Wait
            Write-RustDeskLog "Allando jelszo beallitva."
        }

        Write-RustDeskLog "RustDesk szolgaltatas ujrainditasa a beallitasok ervenyesitesehez..."
        Restart-Service -Name "rustdesk" -ErrorAction SilentlyContinue
    } elseif ($config) {
        Write-RustDeskLog "A rustdesk-server.json letezik, de nincs kitoltve 'host' mezo - a nyilvanos szerver marad aktiv." "WARN"
    }
}

Write-RustDeskLog "=== RustDesk telepites/konfiguralas befejezve ==="
