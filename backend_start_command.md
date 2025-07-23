# Backend Start Command


To start the backend server, use the following command in PowerShell:

```powershell
& "C:/Users/jarmo.piipponen/OneDrive - John Cockerill/Documents/Optimoinnin Visualisointi Proto/stl-backend/venv/Scripts/python.exe" -m uvicorn app.main:app --host 127.0.0.1 --port 8000
```

This command ensures the backend server runs using the configured Python virtual environment and käynnistää sovelluksen oikeasta entrypointista (app/main.py).
