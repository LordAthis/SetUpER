param([string]$AppId)

$config = Get-Content "Config.json" | ConvertFrom-Json
$appsList = Get-Content "../Apps/AppsList.json" | ConvertFrom-Json

$app = $appsList.apps | Where-Object { $_.id -eq $AppId }
if($app) {
    $appPath = "$($config.downloadDir)\$($app.id).exe"
    if(-not (Test-Path $appPath) -or ((Get-Item $appPath).Length -lt 1MB)) {
        Write-Output "Letöltés: $($app.name)"
        Invoke-WebRequest -Uri $app.downloadUrl -OutFile $appPath -UseBasicParsing
    }
}
