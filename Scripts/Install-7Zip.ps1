param([string]$InstallDir = "C:\Program Files")

# Futó folyamat ellenőrzése
$_running = Get-Process "7zG" -ErrorAction SilentlyContinue
if ($_running) {
    Write-Host ""
    Write-Host "FIGYELEM: 7-Zip jelenleg fut!" -ForegroundColor Yellow
    $valasz = Read-Host "Zarjuk be a telepites elott? (I/N)"
    if ($valasz -match "^[Ii]$") {
        Stop-Process -Name "7zG" -Force -ErrorAction SilentlyContinue
        Start-Sleep -Seconds 2
        Write-Host "7-Zip bezarva." -ForegroundColor Green
    } else {
        Write-Host "A telepites folytatodik, de hibat okozhat!" -ForegroundColor Yellow
    }
}


$appPath = Join-Path $PSScriptRoot "../Apps/7Zip.exe"
$appPath = [System.IO.Path]::GetFullPath($appPath)

if(Test-Path $appPath) {
    Write-Host "7-Zip csendes telepítése folyamatban..." -ForegroundColor Cyan
    
    # 7-Zip speciális szabály: 
    # 1. A /D kapcsoló az utolsó kell legyen a sorban.
    # 2. Nem lehet szóköz az = jel után.
    # 3. NEM lehet idézőjel a /D után, még akkor sem, ha szóköz van az útvonalban.
    
    $targetPath = Join-Path $InstallDir "7-Zip"
    $argList = "/S /D=$targetPath"
    
    $process = Start-Process -FilePath $appPath -ArgumentList $argList -Wait -NoNewWindow -PassThru
    
    if ($process.ExitCode -eq 0) {
        Write-Host "7-Zip sikeresen telepítve: $targetPath" -ForegroundColor Green
    } else {
        Write-Warning "A telepítő hibakóddal állt le: $($process.ExitCode). Megpróbáljuk alapértelmezett helyre..."
        # Második próbálkozás paraméterek nélkül a gyökérbe
        Start-Process -FilePath $appPath -ArgumentList "/S" -Wait
    }
} else {
    Write-Error "7Zip.exe nem található: $appPath"
}
