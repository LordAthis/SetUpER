param([string]$InstallDir = "C:\Program Files")

# Dinamikus latest letöltés (nem fix verzió)
$config = Get-Content "Config.json" | ConvertFrom-Json
$appsList = Get-Content "../Apps/AppsList.json" | ConvertFrom-Json
$app = $appsList.apps | Where-Object { $_.id -eq "Brave" }

$appPath = "../Apps/Brave.exe"
if(Test-Path $appPath) {
    # Brave csendes telepítés (standalone installer)
    Start-Process -FilePath $appPath -ArgumentList "--chrome-silent-install", "--no-first-run", "--disable-first-run-ui" -Wait -NoNewWindow
    Write-Output "Brave telepítve"
} else {
    Write-Error "Brave.exe nem található!"
}
