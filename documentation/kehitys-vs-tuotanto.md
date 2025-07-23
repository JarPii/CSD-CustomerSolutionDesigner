# 🔄 Paikallinen kehitys vs Azure-tuotanto

## 🖥️ **Paikallinen kehitys** (NYKYINEN TILA)

### Konfiguraatio:
```
DEBUG=true
ENVIRONMENT=local
APP_NAME=STL Backend API (DEV)
VERSION=1.0.0-dev
```

### Edut:
- ✅ **API-dokumentaatio** näkyy: http://localhost:8000/api/docs
- ✅ **Virheviestit** ovat yksityiskohtaisia
- ✅ **Hot reload** toimii (`--reload`)
- ✅ **Development-friendly** asetukset

### Käynnistys:
```powershell
py -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

## ☁️ **Azure-tuotanto**

### Konfiguraatio (Azure App Service Application Settings):
```
DATABASE_URL=postgresql+psycopg2://...
DEBUG=false
ENVIRONMENT=production
APP_NAME=STL Backend API
VERSION=1.0.0
```

### Edut:
- ✅ **Suorituskyky** optimoitu
- ✅ **Turvallisuus** (ei API docs)
- ✅ **Gunicorn** multi-worker
- ✅ **Production-ready**

## 🔧 **Kehitystyökalut**

### Paikallisesti saatavilla:
1. **API-dokumentaatio**: http://localhost:8000/api/docs
2. **Interaktiivinen API**: http://localhost:8000/api/redoc
3. **Health check**: http://localhost:8000/health
4. **Ping test**: http://localhost:8000/ping

### Frontend-testaus:
1. **Etusivu**: http://localhost:8000/
2. **Sales**: http://localhost:8000/sales.html
3. **API-kutsut**: http://localhost:8000/api/v1/customers

## 📋 **Kehityksen workflow**

### 1. Paikallinen kehitys:
```powershell
# Käynnistä backend
py -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# Testaa frontend
# Selaimessa: http://localhost:8000/
```

### 2. Testaus:
```powershell
# API-testit
Invoke-RestMethod -Uri "http://localhost:8000/api/v1/customers" -Method GET

# Frontend-testit
# Selaimessa: http://localhost:8000/sales.html
```

### 3. Commit ja push:
```powershell
git add .
git commit -m "Feature: xyz"
git push
```

### 4. Azure deployment:
- Automaattinen deployment GitHub:sta
- Production-asetukset tulevat Azure App Service:stä

## ✅ **Nykyinen tilanne**

Kaikki on nyt valmista paikalliseen kehitykseen:

1. **debug=True** → API-dokumentaatio näkyy
2. **environment=local** → Kehitysystävälliset asetukset
3. **`.env.local`** → Priorisoidaan paikallisia asetuksia
4. **Hot reload** → Muutokset näkyvät heti

Voit nyt jatkaa kehitystä normaalisti! 🚀
