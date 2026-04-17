param([string]$InstallDir = "C:\Program Files")

$appPath = "../Apps/WinZip.exe"
if(Test-Path $appPath) {
    # WinZip csendes telepítés (MSI alapú paraméterek)
    Start-Process -FilePath $appPath -ArgumentList "/no-silent", "/no-reboot" -Wait -NoNewWindow
    Write-Output "WinZip telepítve"
} else {
    Write-Error "WinZip.exe nem található!"
}
