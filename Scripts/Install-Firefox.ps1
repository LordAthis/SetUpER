# Verzio: v1.1.0 - 2026-09-11
param([string]$InstallDir)

$_running = Get-Process "firefox" -ErrorAction SilentlyContinue
if ($_running) {
    Write-Host ""
    Write-Host "FIGYELEM: Firefox jelenleg fut!" -ForegroundColor Yellow
    $valasz = Read-Host "Zarjuk be a telepites elott? (I/N)"
    if ($valasz -match "^[Ii]$") {
        Stop-Process -Name "firefox" -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        Write-Host "Firefox bezarva." -ForegroundColor Green
    } else {
        Write-Host "A telepites folytatodik, de hibat okozhat!" -ForegroundColor Yellow
    }
}

$appPath = Join-Path $PSScriptRoot "../Apps/Firefox.exe"

if(Test-Path $appPath) {
    Write-Host "Firefox csendes telepitese..." -ForegroundColor Cyan
    Start-Process -FilePath $appPath -ArgumentList "/S" -Wait
    Write-Host "Firefox kesz." -ForegroundColor Green
}
