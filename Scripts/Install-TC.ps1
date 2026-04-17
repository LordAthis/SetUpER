param([string]$InstallDir = "C:\Program Files")

# Ha az útvonal nem tartalmazza a totalcmd mappát, adjuk hozzá
if ($InstallDir -notlike "*totalcmd*") {
    $InstallDir = Join-Path $InstallDir "totalcmd"
}

$appPath = "../Apps/TC.exe"
$iniSource = "../Apps/Conf/wincmd.ini"

if(Test-Path $appPath) {
    Write-Output "Total Commander telepítése folyamatban..."
    
    # Kényszerítjük a célmappát a telepítőnek a /D kapcsolóval (ha támogatja)
    Start-Process -FilePath $appPath -ArgumentList "/S", "/D=$InstallDir" -Wait -NoNewWindow

    if(Test-Path $iniSource) {
        Write-Output "Konfiguráció alkalmazása a következő helyen: $InstallDir"
        
        if(!(Test-Path $InstallDir)) { 
            New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null 
        }
        
        Copy-Item -Path $iniSource -Destination $InstallDir -Force
        Write-Output "wincmd.ini sikeresen másolva."
    }
}
