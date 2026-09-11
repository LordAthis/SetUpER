# Verzio: v1.1.0 - 2026-09-11
param([string]$InstallDir)

$_running = Get-Process "chrome" -ErrorAction SilentlyContinue
if ($_running) {
    Write-Host ""
    Write-Host "FIGYELEM: Chrome jelenleg fut!" -ForegroundColor Yellow
    $valasz = Read-Host "Zarjuk be a telepites elott? (I/N)"
    if ($valasz -match "^[Ii]$") {
        Stop-Process -Name "chrome" -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        Write-Host "Chrome bezarva." -ForegroundColor Green
    } else {
        Write-Host "A telepites folytatodik, de hibat okozhat!" -ForegroundColor Yellow
    }
}

$appPath = Join-Path $PSScriptRoot "../Apps/Chrome.exe"

if(Test-Path $appPath) {
    Write-Host "Chrome csendes telepitese..." -ForegroundColor Cyan
    Start-Process -FilePath $appPath -ArgumentList "/silent /install" -Wait
    Write-Host "Chrome kesz." -ForegroundColor Green
}
