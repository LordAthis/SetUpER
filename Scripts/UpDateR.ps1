param([string]$AppId)

$config   = Get-Content "Config.json" | ConvertFrom-Json
$appsList = Get-Content "../Apps/AppsList.json" | ConvertFrom-Json
$app      = $appsList.apps | Where-Object { $_.id -eq $AppId }

if (!$app) {
    Write-Host "Hiba: AppId nem talalhato a listaban: $AppId" -ForegroundColor Red
    exit 1
}

# Letoltesi utvonal: Config.json downloadDir ha van, egyebkent ../Apps/
$downloadDir = if ($config.downloadDir) { $config.downloadDir } else { "../Apps" }
$appPath     = Join-Path $downloadDir "$($app.id).exe"
$userAgent   = "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"

# Csak akkor toltjuk le, ha hianyzik vagy serult (kisebb mint 1MB)
if ((Test-Path $appPath) -and (Get-Item $appPath).Length -ge 1MB) {
    Write-Host "$($app.name) mar letoltve, kihagyva." -ForegroundColor Green
    exit 0
}

# Ha serult fajl van, toroljuk
if (Test-Path $appPath) {
    Remove-Item $appPath -Force
    Write-Host "Serult fajl torolve: $appPath" -ForegroundColor Yellow
}

Write-Host "Letoltes: $($app.name)..." -ForegroundColor Cyan

try {
    Invoke-WebRequest -Uri $app.downloadUrl -OutFile $appPath -UserAgent $userAgent -MaximumRedirection 5 -UseBasicParsing -ErrorAction Stop

    if ((Get-Item $appPath).Length -lt 10KB) {
        throw "A letoltott fajl merete tul kicsi, valoszinuleg hibas."
    }

    Write-Host "Sikeres letoltes: $($app.name)" -ForegroundColor Green

} catch {
    Write-Host "Sima letoltes sikertelen, probalkozas BITS-el..." -ForegroundColor Yellow
    try {
        Start-BitsTransfer -Source $app.downloadUrl -Destination $appPath -ErrorAction Stop

        if ((Get-Item $appPath).Length -lt 10KB) {
            throw "BITS: A letoltott fajl merete tul kicsi."
        }

        Write-Host "BITS letoltes sikeres: $($app.name)" -ForegroundColor Green

    } catch {
        Write-Host "HIBA: Minden letoltesi mod kudarcot vallott: $($app.name)" -ForegroundColor Red
        if (Test-Path $appPath) { Remove-Item $appPath -Force }
        exit 1
    }
}
