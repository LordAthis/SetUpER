param([string]$InstallDir)

# ELOKESZITVE, de meg nincs bekotve konkret letoltesi link:
# az aktivan fejlesztett kozossegi fork a github.com/clsid2/mpc-hc, legutobb
# 2.8.1 verzioval - de a kiadasi oldal (github.com/clsid2/mpc-hc/releases/tag/2.8.1)
# az assetek pontos fajlnevet JavaScript-tel tolti be, innen nem volt
# biztonsagosan (fabrikalas nelkul) kiolvashato.
#
# Hasznalatba vetelehez:
#   1. Nyisd meg: https://github.com/clsid2/mpc-hc/releases/tag/2.8.1
#   2. Masold ki a 64-bites Windows .exe telepito pontos linkjet.
#   3. Told be az Apps/AppsList.json "MPCHC" bejegyzesenek "downloadUrl"
#      mezojebe, es vedd ki a "notReady": true sort.
#   4. A telepito valoszinuleg /S vagy /VERYSILENT kapcsolot hasznal (Inno
#      Setup / NSIS alapu installerek szoktak) - ellenorizd, majd ird at az
#      alabbi sort, ha mas kell.

$appPath = Join-Path $PSScriptRoot "../Apps/MPCHC.exe"

if(Test-Path $appPath) {
    Write-Host "MPC-HC csendes telepitese..." -ForegroundColor Cyan
    Start-Process -FilePath $appPath -ArgumentList "/VERYSILENT /NORESTART" -Wait
    Write-Host "MPC-HC kesz." -ForegroundColor Green
} else {
    Write-Host "MPC-HC: meg nincs beallitva letoltesi link (lasd a fajl elejen levo utmutatot)." -ForegroundColor Yellow
}
