param([string]$InstallDir)

# ELOKESZITVE, de meg nem hasznalhato "out of the box":
# a MeshCentral kliens (MeshAgent) MINDIG egy konkret MeshCentral szerverhez
# kotott, egyedi letoltesi cimmel rendelkezik (sajat szervered "My Devices"
# oldalan generalt, meshid-et tartalmazo linkkel). Nincs egyetlen, mindenki
# szamara ervenyes kozvetlen letoltesi URL.
#
# Hasznalatba vetelehez:
#   1. Nyisd meg a sajat MeshCentral szerveredet, es a "My Devices" oldalon
#      generalj egy uj Windows agent letoltesi linket.
#   2. Told be azt a linket az Apps/AppsList.json "MeshCentral" bejegyzesenek
#      "downloadUrl" mezojebe.
#   3. Vedd ki a "notReady": true sort ugyanonnan az elembol.
#   4. A MeshAgent.exe altalaban parameter nelkul, nemán telepiti magat -
#      ha a sajat szervered mast ir elo, ird at az alabbi sort.

$appPath = Join-Path $PSScriptRoot "../Apps/MeshCentral.exe"

if(Test-Path $appPath) {
    Write-Host "MeshCentral agent telepitese..." -ForegroundColor Cyan
    Start-Process -FilePath $appPath -Wait
    Write-Host "MeshCentral kesz." -ForegroundColor Green
} else {
    Write-Host "MeshCentral: meg nincs beallitva sajat szerver-link (lasd a fajl elejen levo utmutatot)." -ForegroundColor Yellow
}
