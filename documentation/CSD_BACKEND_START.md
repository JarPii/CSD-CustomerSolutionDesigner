# CSD_BACKEND_START.md

**Päivitetty:** 23. heinäkuuta 2025

## Backendin käynnistys PowerShellissä

### 1. Luo ja aktivoi virtuaaliympäristö

Avaa PowerShell ja siirry projektin juureen:

```powershell
cd C:/Dev/CSD-CustomerSolutionDesigner
```

Luo virtuaaliympäristö (vain kerran):

```powershell
python -m venv venv
```

Aktivoi virtuaaliympäristö:

```powershell
.\venv\Scripts\Activate.ps1
```

### 2. Asenna tarvittavat paketit

Varmista, että vaaditut paketit ovat asennettu:

```powershell
pip install -r requirements.txt
```

### 3. Käynnistä backend-palvelin

Käynnistä FastAPI-backend PowerShellissä:

```powershell
python -m uvicorn app.main:app --host 127.0.0.1 --port 8000
```

Backend käynnistyy osoitteessa http://127.0.0.1:8000.

**Huom:**
- Jos käytät toista polkua, vaihda polku vastaamaan omaa venv-hakemistoasi.
- Azure-workflow on toistaiseksi poistettu tästä ohjeesta.

**Muutosten tekijä:** GitHub Copilot
**Päivämäärä:** 2025-07-23
