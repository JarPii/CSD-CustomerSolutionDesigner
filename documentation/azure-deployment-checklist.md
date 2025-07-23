# Azure App Service Deployment Checklist

## ✅ Azure-valmis konfiguraatio

### Backend-asetukset:

1. **startup.txt** ✅
   - Päivitetty oikeaan module-pathiin: `app.main:app`
   - Gunicorn-konfiguraatio Azurea varten

2. **requirements.txt** ✅  
   - Lisätty `pydantic-settings` ja `gunicorn`
   - Kaikki riippuvuudet määritelty

3. **config.py** ✅
   - Muutettu `debug=False` oletuksena
   - `database_url` luetaan ympäristömuuttujista
   - Environment = "production"

4. **main.py** ✅
   - API docs piilotettu tuotannossa (`debug=False`)
   - Static files -palvelu toimii
   - Health check -endpointit (/health, /ping)

### Azure App Service -asetukset:

#### Application Settings (ympäristömuuttujat):
```
DATABASE_URL=postgresql+psycopg2://JarPii:!V41k33!@stl.postgres.database.azure.com:5432/postgres?sslmode=require
DEBUG=false
ENVIRONMENT=production
APP_NAME=STL Backend API
VERSION=1.0.0
```

#### Startup Command:
```
startup.txt
```

#### Python Version:
- Varmista että Python 3.11+ on valittu

### Frontend-asetukset:

1. **API-kutsut** ✅
   - Käyttää suhteellisia URL:eitä (`/api/v1`)
   - Toimii automaattisesti samassa domainissa

2. **Static files** ✅
   - Palvellaan FastAPI:n kautta
   - Polut toimivat Azuressa

## 🚀 Deployment-vaiheet:

1. **Git commit & push**
   ```bash
   git add .
   git commit -m "Azure deployment ready - fixed startup, config, requirements"
   git push
   ```

2. **Azure App Service deployment**
   - Deployment Center → GitHub
   - Valitse repository ja branch
   - Build provider: App Service Build

3. **Application Settings**
   - Lisää ympäristömuuttujat Azure portaaliin
   - Configuration → Application settings

4. **Startup Command**  
   - Configuration → General settings
   - Startup Command: `startup.txt`

## ⚠️ Huomioitavaa:

### Tietokanta:
- Azure PostgreSQL on jo käytössä
- Connection string on oikea
- SSL on pakollinen (`sslmode=require`)

### CORS:
- Sallii kaikki originit (`*`)
- Soveltuu kehitykseen
- Tuotannossa kannattaa rajoittaa tiettyihin domaineihin

### Logging:
- Azure tarjoaa automaattisen loggingin
- Katso lokit: Log stream tai Diagnose and solve problems

### Performance:
- Gunicorn 4 workeria
- Uvicorn ASGI worker
- Soveltuu keskikokoiselle kuormalle

## 🔍 Testaus Azuressa:

1. **Health check:**
   `https://your-app.azurewebsites.net/health`

2. **API documentation (jos debug=true):**
   `https://your-app.azurewebsites.net/api/docs`

3. **Frontend:**
   `https://your-app.azurewebsites.net/`

4. **API endpoints:**
   `https://your-app.azurewebsites.net/api/v1/customers`

## ✅ Valmis deploymentiin!

Kaikki tarvittavat muutokset on tehty. Sovellus on valmis Azure App Service -deploymentiin.
