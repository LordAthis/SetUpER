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



Ez a repó is az RTS keretrendszer része.
