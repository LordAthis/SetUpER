param([string]$InstallDir = "C:\Program Files")

$appPath = "../Apps/HDS.exe"
if(Test-Path $appPath) {
    # H.D.Sentinel csendes telepítés Inno Setup installer-rel
    Start-Process -FilePath $appPath -ArgumentList "/VERYSILENT", "/SUPPRESSMSGBOXES", "/NORESTART" -Wait -NoNewWindow
    Write-Output "H.D.Sentinel telepítve"
} else {
    Write-Error "HDS.exe nem található!"
}
