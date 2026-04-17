# UpDateR.ps1 - Frissítések és letöltések

$compatibility = Get-Content "Compatibility.json" | ConvertFrom-Json
$config = Get-Content "Config.json" | ConvertFrom-Json
$appsList = Get-Content "AppsList.json" | ConvertFrom-Json

foreach ($app in $appsList.apps) {
    $compatApp = $compatibility.apps[$app.name]
    $currentVersion = Get-CurrentVersion $app.uninstallKey
    if ($currentVersion -lt $compatApp.latestVersion) {
        Write-Log "Updating $($app.name): $currentVersion -> $($compatApp.latestVersion)"
        Invoke-WebRequest -Uri $compatApp.downloadUrl -OutFile "$($config.downloadDir)\$($app.id).exe"
        # Telepítés hívása
    }
}

function Get-CurrentVersion($appName) {
    # Registry-ből verzió lekérdezés
    $uninstall = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*" | 
                 Where-Object { $_.GetValue('DisplayName') -like "*$appName*" }
    return $uninstall.DisplayVersion
}
