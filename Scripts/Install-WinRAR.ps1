# Verzio: v1.1.0 - 2026-09-11
param([string]$InstallDir)

$_running = Get-Process "winrar" -ErrorAction SilentlyContinue
if ($_running) {
    Write-Host ""
    Write-Host "FIGYELEM: WinRAR jelenleg fut!" -ForegroundColor Yellow
    $valasz = Read-Host "Zarjuk be a telepites elott? (I/N)"
    if ($valasz -match "^[Ii]$") {
        Stop-Process -Name "winrar" -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        Write-Host "WinRAR bezarva." -ForegroundColor Green
    } else {
        Write-Host "A telepites folytatodik, de hibat okozhat!" -ForegroundColor Yellow
    }
}

$appPath = Join-Path $PSScriptRoot "../Apps/WinRAR.exe"

if(Test-Path $appPath) {
    Write-Host "WinRAR csendes telepitese: $InstallDir" -ForegroundColor Cyan
    Start-Process -FilePath $appPath -ArgumentList "/S" -Wait
    Write-Host "WinRAR kesz." -ForegroundColor Green
}
