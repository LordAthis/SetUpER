param([string]$InstallDir)

$appPath = Join-Path $PSScriptRoot "../Apps/DWService.exe"

if(Test-Path $appPath) {
    Write-Host "DWService (DWAgent) telepitese..." -ForegroundColor Cyan
    # A dwagent.exe -silent kapcsolot tamogatja. Ha egy tetel geppark eseten
    # egy konkret DWService fiokhoz szeretned automatikusan kotni a gepet,
    # tovabbi -user / -pass / -group parametereket ad a DWService (lasd a
    # sajat DWService fiokod "Deployment" oldalat) - ez a legegyszerubb,
    # fiok nelkuli valtozat.
    Start-Process -FilePath $appPath -ArgumentList "-silent" -Wait
    Write-Host "DWService kesz." -ForegroundColor Green
    Write-Host "Megjegyzes: fiok nelkuli telepites eseten a gep egyedi, ideiglenes eleresi kodot kap - ez a DWAgent felulet elso megnyitasakor jelenik meg." -ForegroundColor Yellow
}
