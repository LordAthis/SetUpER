param([string]$InstallDir)

# ELOKESZITVE, de meg nincs bekotve: az RTS keretrendszernek
# (github.com/LordAthis/RTS) meg nincs kiadott GitHub Release-je, csak
# CI build-artifact (ami bejelentkezes nelkul nem tolthetot le kozvetlen
# linkkel). Amint keszul egy elso hivatalos "Release" az RTS repoban:
#   1. Told be a release .exe (vagy .zip) linkjet az Apps/AppsList.json
#      "RTS" bejegyzesenek "downloadUrl" mezojebe.
#   2. Vedd ki a "notReady": true sort.
#   3. Ha .zip-kent erkezik, itt ki kell csomagolni celmappaba telepites
#      helyett futtatas elott (Expand-Archive).

$appPath = Join-Path $PSScriptRoot "../Apps/RTS.exe"

if(Test-Path $appPath) {
    Write-Host "RTS telepitese: $InstallDir" -ForegroundColor Cyan
    $rtsDir = Join-Path $InstallDir "RTS"
    New-Item -ItemType Directory -Force -Path $rtsDir | Out-Null
    Copy-Item $appPath -Destination $rtsDir -Force
    Write-Host "RTS kesz: $rtsDir" -ForegroundColor Green
} else {
    Write-Host "RTS: meg nincs kiadott hivatalos release, igy nincs mit letolteni (lasd a fajl elejen levo utmutatot)." -ForegroundColor Yellow
}
