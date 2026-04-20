param([string]$InstallDir) # A Starter-tol kapott utvonal (pl. D:\Program Files)

# Futó folyamat ellenőrzése
$_running = Get-Process "vlc" -ErrorAction SilentlyContinue
if ($_running) {
    Write-Host ""
    Write-Host "FIGYELEM: VLC jelenleg fut!" -ForegroundColor Yellow
    $valasz = Read-Host "Zarjuk be a telepites elott? (I/N)"
    if ($valasz -match "^[Ii]$") {
        Stop-Process -Name "vlc" -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        Write-Host "VLC bezarva." -ForegroundColor Green
    } else {
        Write-Host "A telepites folytatodik, de hibat okozhat!" -ForegroundColor Yellow
    }
}


$vlcDir = Join-Path $InstallDir "VideoLAN\VLC"
$appPath = Join-Path $PSScriptRoot "../Apps/VLC.exe"

if(Test-Path $appPath) {
    Write-Host "VLC telepitese: $vlcDir" -ForegroundColor Cyan
    # /L=1038 a magyar nyelv
    Start-Process -FilePath $appPath -ArgumentList "/S /L=1038 /D=$vlcDir" -Wait
    Write-Host "VLC kesz." -ForegroundColor Green
}
