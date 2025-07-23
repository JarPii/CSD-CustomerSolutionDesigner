# STL-backend paikallisen käynnistyksen komento

Käynnistä backend PowerShellissä seuraavalla komennolla:

```
py -m uvicorn app.main:app --host 127.0.0.1 --port 8000
```

Vaihtoehtoisesti, jos haluat käyttää virtuaaliympäristön pythonia suoraan:

```
& "C:/Users/jarmo.piipponen/OneDrive - John Cockerill/Documents/Optimoinnin Visualisointi Proto/stl-backend/venv/Scripts/python.exe" -m uvicorn app.main:app --host 127.0.0.1 --port 8000
```

Varmista, että .env.local-tiedostossa ei ole ylimääräisiä DB_*-muuttujia, vain seuraavat asetukset:

```
DATABASE_URL=postgresql+psycopg2://JarPii:!V41k33!@stl.postgres.database.azure.com:5432/postgres?sslmode=require
DEBUG=false
APP_NAME=STL Backend API
VERSION=1.0.0
CORS_ORIGINS=["*"]
CORS_CREDENTIALS=true
```

Tämä dokumentti löytyy jatkossa tiedostosta backend_local_start.md.
## Backendin pysäyttäminen ja uudelleenkäynnistäminen

### Pysäytä backend

PowerShellissä voit pysäyttää backendin painamalla `Ctrl + C` siinä ikkunassa, jossa backend on käynnissä.

### Käynnistä backend uudelleen (restart)

1. Pysäytä backend painamalla `Ctrl + C`.
2. Käynnistä backend uudelleen käyttämällä yllä olevaa käynnistyskomentoa:

```
py -m uvicorn app.main:app --host 127.0.0.1 --port 8000
```

Tai virtuaaliympäristön pythonilla:

```
& "C:/Users/jarmo.piipponen/OneDrive - John Cockerill/Documents/Optimoinnin Visualisointi Proto/stl-backend/venv/Scripts/python.exe" -m uvicorn app.main:app --host 127.0.0.1 --port 8000
```
