param([string]$InstallDir)

# Futó folyamat ellenőrzése
$_running = Get-Process "wzqkpick" -ErrorAction SilentlyContinue
if ($_running) {
    Write-Host ""
    Write-Host "FIGYELEM: WinZip jelenleg fut!" -ForegroundColor Yellow
    $valasz = Read-Host "Zarjuk be a telepites elott? (I/N)"
    if ($valasz -match "^[Ii]$") {
        Stop-Process -Name "wzqkpick" -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        Write-Host "WinZip bezarva." -ForegroundColor Green
    } else {
        Write-Host "A telepites folytatodik, de hibat okozhat!" -ForegroundColor Yellow
    }
}

$wzDir = Join-Path $InstallDir "WinZip"
$appPath = Join-Path $PSScriptRoot "../Apps/WinZip.exe"

if(Test-Path $appPath) {
    Write-Host "WinZip csendes telepitese: $wzDir" -ForegroundColor Cyan
    # Alternativ megoldas: /s /a /silent kapcsolok
    Start-Process -FilePath $appPath -ArgumentList "/s /a /silent /targetfolder=`"$wzDir`"" -Wait
    Write-Host "WinZip kesz." -ForegroundColor Green
}
