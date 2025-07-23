# STL Backend - Tekninen dokumentaatio

## Arkkitehtuuri

### Yleisrakenne

```
stl-backend/
├── app/
│   ├── main.py              # FastAPI sovellus
│   ├── config.py            # Konfiguraatio
│   ├── database.py          # Tietokantayhteydet
│   ├── models/
│   │   └── customer.py      # SQLAlchemy mallit
│   ├── schemas/
│   │   └── customer.py      # Pydantic skeemat
│   ├── routers/
│   │   └── customers.py     # API reitit
│   └── core/
│       └── exceptions.py    # Poikkeuskäsittely
├── static/                  # Frontend tiedostot
├── documentation/           # Dokumentaatio
├── .env.local              # Ympäristömuuttujat
└── requirements.txt        # Python riippuvuudet
```

### Teknologiat

- **Backend**: Python 3.11, FastAPI, SQLAlchemy, Pydantic
- **Tietokanta**: PostgreSQL (Azure)
- **Frontend**: HTML5, Bootstrap 5, Vanilla JavaScript
- **Hosting**: Uvicorn ASGI server

## Backend-komponentit

### 1. Sovelluksen ydin (app/main.py)

```python
from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from app.routers import customers
from app.database import engine
from app.models import customer

# Luo taulut
customer.Base.metadata.create_all(bind=engine)

app = FastAPI(title="STL Backend", version="1.0.0")

# Rekisteröi reitit
app.include_router(customers.router, prefix="/api/v1")

# Staattisten tiedostojen palvelu
app.mount("/static", StaticFiles(directory="static"), name="static")
```

### 2. Tietokantamalli (app/models/customer.py)

```python
from sqlalchemy import Column, Integer, String, DateTime
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.sql import func

Base = declarative_base()

class Customer(Base):
    __tablename__ = "customer"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False, index=True)
    town = Column(String, nullable=True)
    country = Column(String, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
```

### 3. Pydantic skeemat (app/schemas/customer.py)

```python
from pydantic import BaseModel
from datetime import datetime
from typing import Optional

class CustomerBase(BaseModel):
    name: str
    town: Optional[str] = None
    country: Optional[str] = None

class CustomerCreate(CustomerBase):
    pass

class CustomerUpdate(BaseModel):
    name: Optional[str] = None
    town: Optional[str] = None
    country: Optional[str] = None

class CustomerOut(CustomerBase):
    id: int
    created_at: datetime
    updated_at: Optional[datetime] = None
    
    class Config:
        from_attributes = True
```

### 4. API-reitit (app/routers/customers.py)

#### GET /api/v1/customers
- **Kuvaus**: Hae kaikki asiakkaat tai hae hakusanalla
- **Parametrit**: `search` (optional) - hakusana
- **Vastaus**: Lista asiakkaista

#### POST /api/v1/customers
- **Kuvaus**: Luo uusi asiakas
- **Payload**: `CustomerCreate` objekti
- **Vastaus**: Luotu asiakas

#### PUT /api/v1/customers/{customer_id}
- **Kuvaus**: Päivitä asiakas
- **Parametrit**: `customer_id` - asiakkaan ID
- **Payload**: `CustomerUpdate` objekti
- **Vastaus**: Päivitetty asiakas

#### DELETE /api/v1/customers/{customer_id}
- **Kuvaus**: Poista asiakas
- **Parametrit**: `customer_id` - asiakkaan ID
- **Vastaus**: Poistovahvistus

### 5. Tietokantayhteys (app/database.py)

```python
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.config import settings

engine = create_engine(settings.database_url)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
```

## Frontend-arkkitehtuuri

### 1. Käyttöliittymä (static/sales.html)

#### Komponentit:
- **Hakukenttä**: Reaaliaikainen haku
- **Asiakasluettelo**: Dynaaminen lista hakutuloksista
- **Asiakaskortti**: Valitun asiakkaan tiedot
- **Lomakkeet**: Uuden asiakkaan luominen ja muokkaus

#### JavaScript-toiminnot:
- `searchCustomers()`: Hakutoiminto
- `selectCustomer()`: Asiakkaan valinta
- `createCustomer()`: Uuden asiakkaan luominen
- `editCustomer()`: Asiakkaan muokkaus
- `deleteCustomer()`: Asiakkaan poistaminen

### 2. API-kutsut

```javascript
// Haku
const response = await fetch(`/api/v1/customers?search=${encodeURIComponent(searchTerm)}`);

// Luominen
const response = await fetch('/api/v1/customers', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(customerData)
});

// Päivittäminen
const response = await fetch(`/api/v1/customers/${customerId}`, {
    method: 'PUT',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(updateData)
});

// Poistaminen
const response = await fetch(`/api/v1/customers/${customerId}`, {
    method: 'DELETE'
});
```

## Tietokanta

### Azure PostgreSQL -asetukset

```env
# .env.local
DB_HOST=your-azure-postgres-server.postgres.database.azure.com
DB_PORT=5432
DB_NAME=postgres
DB_USER=your-username
DB_PASSWORD=your-password
DB_SSLMODE=require
```

### Taulun rakenne

```sql
CREATE TABLE customer (
    id SERIAL PRIMARY KEY,
    name VARCHAR NOT NULL,
    town VARCHAR,
    country VARCHAR,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE
);

CREATE INDEX idx_customer_name ON customer(name);
```

## Käyttöönotto

### 1. Riippuvuuksien asentaminen

```powershell
pip install -r requirements.txt
```

### 2. Ympäristömuuttujien määrittäminen

Luo `.env.local` -tiedosto ja määritä tietokantayhteys.

### 3. Tietokannan alustaminen

```python
# create_db.py
from app.database import engine
from app.models.customer import Base

Base.metadata.create_all(bind=engine)
```

### 4. Palvelimen käynnistäminen

```powershell
py -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

## Testaaminen

### Backend-testit

```powershell
# Hae kaikki asiakkaat
$response = Invoke-RestMethod -Uri "http://localhost:8000/api/v1/customers" -Method GET

# Luo uusi asiakas
$customer = @{
    name = "Test Customer"
    town = "Test Town"
    country = "Test Country"
}
$response = Invoke-RestMethod -Uri "http://localhost:8000/api/v1/customers" -Method POST -Body ($customer | ConvertTo-Json) -ContentType "application/json"

# Päivitä asiakas
$update = @{ name = "Updated Name" }
$response = Invoke-RestMethod -Uri "http://localhost:8000/api/v1/customers/1" -Method PUT -Body ($update | ConvertTo-Json) -ContentType "application/json"

# Poista asiakas
$response = Invoke-RestMethod -Uri "http://localhost:8000/api/v1/customers/1" -Method DELETE
```

### Frontend-testit

1. Avaa http://localhost:8000 selaimessa
2. Testaa hakutoiminto
3. Testaa asiakkaan luominen
4. Testaa asiakkaan muokkaaminen
5. Testaa asiakkaan poistaminen

## Vianmääritys

### Yleiset ongelmat

1. **ModuleNotFoundError**: Käytä `py -m uvicorn` komentoa
2. **Tietokantayhteys epäonnistuu**: Tarkista `.env.local` asetukset
3. **JavaScript ei toimi**: Käytä oikeaa selainta (ei VS Code Simple Browser)
4. **CORS-virheet**: Tarkista että backend on käynnissä

### Lokitiedostot

```python
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Käytä loggeria virhetilanteissa
logger.error(f"Database error: {str(e)}")
```

## Jatkokehitys

### Suunnitellut toiminnot

1. **Tehtaiden hallinta**
   - Uudet taulut: `plant`, `plant_customer` (liitostaulut)
   - API-reitit tehtaiden CRUD-toiminnoille
   - Frontend-komponentit tehtaiden hallintaan

2. **Linjojen ja asemien hallinta**
   - Hierarkkinen rakenne: Customer -> Plant -> Line -> Station
   - Dynaaminen puunäkymä frontend:ssä
   - Massamuokkaus-toiminnot

3. **Käyttöliittymän parannukset**
   - Validointi ja virheenkäsittely
   - Latausilmaisimet
   - Animaatiot ja siirtymät
   - Responsiivinen design

### Tekninen velka

1. **Testaus**
   - Yksikkötestit (pytest)
   - Integraatiotestit
   - Frontend-testit (Jest)

2. **Dokumentaatio**
   - API-dokumentaatio (Swagger/OpenAPI)
   - Koodin kommentointi
   - Arkkitehtuuridiagrammit

3. **Suorituskyky**
   - Tietokantakyselyjen optimointi
   - Välimuistin käyttö
   - Pakkauksien optimointi

## Yhteenveto

STL Backend on moderni, skaalautuva asiakashallintajärjestelmä, joka tarjoaa:

- **RESTful API** asiakashallintaan
- **Reaaliaikainen haku** ja suodatus
- **Responsiivinen käyttöliittymä**
- **Tietokantaintegraatio** Azure PostgreSQL:n kanssa
- **Modulaarinen arkkitehtuuri** jatkokehitystä varten

Järjestelmä on valmis tuotantokäyttöön ja tarjoaa hyvän pohjan jatkokehitykselle.
