param([string]$InstallDir = "C:\Program Files")

$appPath = "../Apps/VLC.exe"
if(Test-Path $appPath) {
    # VLC csendes telepítés (NSIS installer)
    Start-Process -FilePath $appPath -ArgumentList "/S", "/L=1038" -Wait -NoNewWindow
    Write-Output "VLC Media Player telepítve"
} else {
    Write-Error "VLC.exe nem található!"
}
