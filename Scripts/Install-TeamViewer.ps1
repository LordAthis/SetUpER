# Verzio: v1.1.0 - 2026-09-11
param([string]$InstallDir)

$_running = Get-Process "TeamViewer" -ErrorAction SilentlyContinue
if ($_running) {
    Write-Host ""
    Write-Host "FIGYELEM: TeamViewer jelenleg fut!" -ForegroundColor Yellow
    $valasz = Read-Host "Zarjuk be a telepites elott? (I/N)"
    if ($valasz -match "^[Ii]$") {
        Stop-Process -Name "TeamViewer" -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        Write-Host "TeamViewer bezarva." -ForegroundColor Green
    } else {
        Write-Host "A telepites folytatodik, de hibat okozhat!" -ForegroundColor Yellow
    }
}

$appPath = Join-Path $PSScriptRoot "../Apps/TeamViewer.exe"

if(Test-Path $appPath) {
    Write-Host "TeamViewer csendes telepitese..." -ForegroundColor Cyan
    Start-Process -FilePath $appPath -ArgumentList "/S" -Wait
    Write-Host "TeamViewer kesz." -ForegroundColor Green
    Write-Host "Megjegyzes: ingyenes/nem-uzleti hasznalatra a TeamViewer sajat licencfeltetelei vonatkoznak - uzleti hasznalathoz elofizetes szukseges." -ForegroundColor Yellow
}
