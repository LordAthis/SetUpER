## SetUpER
# Setup Tool's - Telepítési segéd


## Önnmagában is használható repó, a Starter.ps1 is képes indítani és kezelni.
A SetUpER egy professzionális, PowerShell-alapú keretrendszer, amely menüvezérelt felületen keresztül teszi lehetővé a Windows alkalmazások csendes telepítését, frissítését és rendszerezését.
Teszi mindezt kategóriákra bontott, interaktív menüvel, részletes logolással.

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



## 📂 Projekt struktúra

A rendszer a következő felépítést használja (a `Starter.ps1` automatikusan létrehozza a hiányzó mappákat):

```text
SetUpER/
├── Starter.ps1             # Fő indítófájl (Admin jog, Menü, Logika)
├── Apps/                   # Alkalmazások tárolója
│   ├── AppsList.json       # Alkalmazások adatbázisa (id, név, kategória)
│   └── [app].exe           # A letöltött telepítőfájlok
├── Scripts/                # Működtető szkriptek
│   ├── Config.json         # Telepítési útvonalak és beállítások
│   ├── UpDateR.ps1         # Letöltő és frissítő modul
│   ├── Install-7Zip.ps1    # Egyedi telepítő szkriptek...
│   ├── Install-Brave.ps1
│   ├── Install-HDS.ps1
│   ├── Install-VLC.ps1
│   └── Install-WinZip.ps1
├── LOG/                    # Automatikusan generált naplófájlok
│   └── setup.log           # Telepítési napló időbélyeggel
└── README.md               # Dokumentáció

```

## 🚀 Főbb jellemzők

- Intelligens Menü: Kategóriákba sorolt alkalmazások (pl. A1, B2 választási lehetőség).
- Adminisztrátor ellenőrzés: A Starter.ps1 automatikusan kéri az emelt szintű jogosultságot.
- Telepítés-ellenőrzés: Csak azokat az appokat ajánlja fel, amik még nincsenek a gépen.
- Rugalmas útvonalak: Meghajtó-választási lehetőség a telepítés elején.
- Logolás: Minden eseményt (letöltés, telepítés, hibák) rögzít a LOG/setup.log fájlba.
- Progress jelzés: Vizuális visszajelzés a folyamatban lévő műveletekről.


## 🛠 Használat
1. Indítsd el a Starter.ps1 fájlt PowerShell-ben.
2. Válaszd ki a célmeghajtót a listából.
3. A menüben add meg a telepíteni kívánt szoftver kódját (pl. A1), vagy válaszd a 0 opciót az összes telepítéséhez.


## 📝 Támogatott szoftverek (példa)
- Brave Browser
- Hard Disk Sentinel
- VLC Media Player
- WinZip
- 7-Zip
--------------------------------------------
Megjegyzés: A telepítőfájlokat a Scripts/UpDateR.ps1 kezeli, míg a tényleges telepítést az Install-[ID].ps1 szkriptek végzik.


## ✨ Funkciók

- ✅ **Admin jogok** automatikus emelése
- ✅ **Telepítetlen app-ek** csak megjelenítése
- ✅ **Kategóriás menü** (A1, B2, C3...)
- ✅ **Meghajtó választás** (C:/D:/E:)
- ✅ **Háttér progress** indikátor
- ✅ **Teljesen néma** telepítés
- ✅ **Részletes LOG-olás** (LOG/setup.log)
- ✅ **Könnyen bővíthető** (új sor AppsList.json-ba)



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





---
*Készült az RTS ([Reparing's - Tuning's - Setting's](https://github.com/LordAthis/RTS)) projekt keretében. Használható önállóan vagy a keretrendszer moduljaként is!*
