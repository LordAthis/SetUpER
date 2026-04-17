param([string]$InstallDir = "C:\Program Files")

$appPath = "../Apps/TC.exe"
if(Test-Path $appPath) {
    # Total Commander csendes telepítés
    Start-Process -FilePath $appPath -ArgumentList "/S" -Wait -NoNewWindow
    Write-Output "Total Commander telepítve"
} else {
    Write-Error "TC.exe nem található!"
}
