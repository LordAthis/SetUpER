## SetUpER
# Setup Tool's - Telepítési segéd


## Önnmagában is használható repó, a Starter.ps1 is képes indítani és kezelni.
Automatizált Windows alkalmazás telepítő és frissítő rendszer. Kategóriákra bontott, interaktív menüvel, részletes logolással.

## 🚀 Gyors kezdés

1. **Töltsd le a repót**
   ```bash
   git clone https://github.com/LordAthis/SetUpER.git
   cd SetUpER
   ```

2. **Futtasd admin joggal**
   ```powershell
   .\Starter.ps1
   ```

3. **Válassz meghajtót** (C:/D:/E:)
4. **Válassz programot** (A1, B2, 0=mind, X=kilép)

## 📁 Mappa struktúra
SetUpER/
├── Starter.ps1
├── LOG/
├── Scripts/
│   ├── Config.json
│   ├── Compatibility.json
│   ├── UpDateR.ps1
│   ├── Install-TC.ps1
│   ├── Install-HDS.ps1
│   └── ...
└── Apps/
    ├── AppsList.json
    └── *.exe (letöltött telepítők)


## ✨ Funkciók

- ✅ **Admin jogok** automatikus emelése
- ✅ **Telepítetlen app-ek** csak megjelenítése
- ✅ **Kategóriás menü** (A1, B2, C3...)
- ✅ **Meghajtó választás** (C:/D:/E:)
- ✅ **Háttér progress** indikátor
- ✅ **Teljesen néma** telepítés
- ✅ **Részletes LOG-olás** (LOG/setup.log)
- ✅ **Könnyen bővíthető** (új sor AppsList.json-ba)

## 📋 Alapértelmezett programok

| Kategória | Programok |
|-----------|-----------|
| **A** | Total Commander, H.D.Sentinel |
| **B** | VLC MediaPlayer, Brave |
| **C** | WinZip, 7-Zip |

## ⚙️ Új program hozzáadása

1. **Apps/AppsList.json**-ba új sor:
```json
{
  "id": "Notepad++",
  "name": "Notepad++",
  "category": "D",
  "downloadUrl": "https://github.com/notepad-plus-plus/notepad-plus-plus/releases/latest/download/npp.x64.installer.exe",
  "installer": "/S",
  "uninstallKey": "Notepad++"
}
```

2. **Scripts/Install-NPP.ps1** létrehozása:
```powershell
param([string]$InstallDir)
$appPath = "../Apps/NPP.exe"
Start-Process $appPath -ArgumentList "/S" -Wait -NoNewWindow
```

3. **Starter.ps1 actions**-be automatikusan bekerül (D1-ként)

## 🔧 Konfiguráció

**Scripts/Config.json**
```json
{
  "defaultDrives": ["C:", "D:", "E:"],
  "silentInstall": true
}
```

## 📊 Példa kimenet
===== SetUpER Telepítési Segéd =====

Összes telepítés
A:
A1: Total Commander
A2: H.D.Sentinel
B:
B1: VLC MediaPlayer
B2: Brave
X. Kilépés

Válassz (pl. A1, 0, X): A1
Letöltés [....]
Telepítés [....]
Sikeresen telepítve: Total Commander


## 🐛 Hibaelhárítás

- **"Script execution is disabled"**: `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`
- **Letöltés sikertelen**: Ellenőrizd internet kapcsolatot és tűzfalat
- **Telepítés hibás**: Nézd meg `LOG/setup.log`-ot





Ez a repó is az RTS keretrendszer része.
