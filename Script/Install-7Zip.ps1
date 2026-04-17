param([string]$InstallDir = "C:\Program Files")

$appPath = "../Apps/7Zip.exe"
if(Test-Path $appPath) {
    # 7-Zip csendes telepítés
    Start-Process -FilePath $appPath -ArgumentList "/S", "/D=$InstallDir\7-Zip" -Wait -NoNewWindow
    Write-Output "7-Zip telepítve"
} else {
    Write-Error "7Zip.exe nem található!"
}
