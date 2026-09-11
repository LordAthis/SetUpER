# Verzio: v1.1.0 - 2026-09-11
param([string]$InstallDir)

$appPath = Join-Path $PSScriptRoot "../Apps/RustDesk.exe"

if(Test-Path $appPath) {
    Write-Host "RustDesk csendes telepitese..." -ForegroundColor Cyan
    # A RustDesk telepito a --silent-install kapcsolot tamogatja (nincs sajat
    # celmappa-valasztas, a program a sajat alapertelmezett helyere telepul).
    Start-Process -FilePath $appPath -ArgumentList "--silent-install" -Wait
    Write-Host "RustDesk kesz." -ForegroundColor Green
    Write-Host "Megjegyzes: a RustDesk elso inditasakor generalodik egy egyedi Azonosito+Jelszo -" -ForegroundColor Yellow
    Write-Host "ezt kell megadni a masik oldalon a tavoli eleresehez." -ForegroundColor Yellow
}
