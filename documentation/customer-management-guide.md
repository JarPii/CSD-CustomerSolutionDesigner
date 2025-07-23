# Customer Management System - Käyttöohje

## Yleiskatsaus

STL Backend -järjestelmä tarjoaa kattavan asiakashallintajärjestelmän, joka sisältää RESTful API:n ja dynaamisen web-käyttöliittymän. Järjestelmä on rakennettu FastAPI:lla ja PostgreSQL-tietokannalla.

## Järjestelmän Arkkitehtuuri

### Backend (FastAPI)
- **Modularisoidtu rakenne**: `app/` kansio sisältää kaikki backend-komponentit
- **Database**: PostgreSQL Azure-ympäristössä
- **API**: RESTful endpoints `/api/v1/customers` polun alla

### Frontend
- **Teknologia**: HTML5, Bootstrap 5, Vanilla JavaScript
- **Responsiivinen**: Toimii eri laitteilla
- **Dynaaminen**: Real-time haku ja CRUD-operaatiot

## Asennus ja Käynnistys

### 1. Ympäristön Valmistelu
```bash
# Siirry projektikansioon
cd "c:\Users\jarmo.piipponen\OneDrive - John Cockerill\Documents\Optimoinnin Visualisointi Proto\stl-backend"

# Asenna riippuvuudet
pip install -r requirements.txt
```

### 2. Tietokannan Konfigurointi
Luo `.env.local` tiedosto:
```
DATABASE_URL=postgresql://username:password@hostname:port/database
```

### 3. Backend-serverin Käynnistys
**TÄRKEÄÄ**: Käytä `py` komentoa, ei `python` tai `uvicorn` suoraan!
```bash
py -m uvicorn app.main:app --reload
```

Serveri käynnistyy osoitteeseen: `http://127.0.0.1:8000`

### 4. Frontend-käyttö
- **Pääsivu**: `http://127.0.0.1:8000/`
- **Asiakashallinta**: `http://127.0.0.1:8000/sales.html`

**HUOM**: JavaScript toimii vain täysillä selaimilla (Edge, Chrome, Firefox). VS Code Simple Browser ei tue kaikkia JS-ominaisuuksia.

## API Dokumentaatio

### Customer Endpoints

#### 1. Hae kaikki asiakkaat
```http
GET /api/v1/customers
```

**Vastaus:**
```json
[
  {
    "id": 1,
    "name": "Acme Corp",
    "town": "Helsinki", 
    "country": "Finland"
  }
]
```

#### 2. Etsi asiakkaita
```http
GET /api/v1/customers?search=acme
```

#### 3. Hae yksittäinen asiakas
```http
GET /api/v1/customers/{customer_id}
```

#### 4. Luo uusi asiakas
```http
POST /api/v1/customers
Content-Type: application/json

{
  "name": "New Company",
  "town": "Tampere",
  "country": "Finland"
}
```

#### 5. Päivitä asiakas
```http
PUT /api/v1/customers/{customer_id}
Content-Type: application/json

{
  "name": "Updated Company",
  "town": "Turku", 
  "country": "Finland"
}
```

#### 6. Poista asiakas
```http
DELETE /api/v1/customers/{customer_id}
```

## Web-käyttöliittymän Käyttö

### Asiakashaku
1. **Kirjoita asiakkaan nimi** hakukenttään
2. **Dynaaminen haku** alkaa 300ms viiveellä
3. **Erikoiskomennot**:
   - `*` tai `all` = näytä kaikki asiakkaat

### Asiakkaan Valinta
- **Klikkaa asiakasriviä** valitaksesi asiakkaan
- Valittu asiakas näkyy kortissa vasemmalla puolella
- **Ei erillistä "Select" painiketta** - intuitiivinen käyttö

### Uuden Asiakkaan Luominen
1. **Hae asiakasta** jota ei löydy
2. **"Create New Customer"** painike ilmestyy
3. **Täytä lomake**:
   - Nimi (pakollinen)
   - Kaupunki (valinnainen)
   - Maa (valinnainen)
4. **Lomakkeen lähetys** luo asiakkaan ja valitsee sen automaattisesti

### Asiakkaan Muokkaus
1. **Valitse asiakas**
2. **"Edit" painike** asiakaskortissa
3. **Muokkaa tietoja** lomakkeessa
4. **"Update Customer"** tallentaa muutokset

### Asiakkaan Poistaminen
1. **Valitse asiakas**
2. **"Delete" painike** asiakaskortissa
3. **Vahvista poisto** popup-ikkunassa

## Tekninen Toteutus

### Backend Rakenne
```
app/
├── main.py              # FastAPI sovellus
├── config.py            # Konfiguraatio
├── database.py          # Tietokantayhteys
├── models/
│   └── customer.py      # SQLAlchemy mallit
├── schemas/
│   └── customer.py      # Pydantic scheemat
├── routers/
│   └── customers.py     # API endpoint handlerit
├── services/
│   └── customer.py      # Business logic
└── core/
    └── exceptions.py    # Virheenkäsittely
```

### Tietokanta
- **PostgreSQL** Azure-ympäristössä
- **Customer-taulu**:
  - `id` (Primary Key, Auto-increment)
  - `name` (VARCHAR, NOT NULL)
  - `town` (VARCHAR, nullable)
  - `country` (VARCHAR, nullable)

### Frontend JavaScript
- **Vanilla JavaScript** - ei ulkoisia riippuvuuksia
- **Debounced search** - optimoitu hakutoiminto
- **AJAX/Fetch API** - asynkroniset API-kutsut
- **Bootstrap 5** - responsiivinen UI

## Käyttäjäkokemus

### Parannetut Ominaisuudet
1. **Ei ylimääräisiä popup-viestejä** - sujuva käyttö
2. **Automaattinen asiakkaan valinta** luonnin jälkeen
3. **Intuitiivinen riviclikkaus** - ei erillistä Select-painiketta
4. **Dynaaminen haku** - real-time tulokset
5. **Tyhjennys toiminto** - "Clear Selection" piilottaa listat

### Responsiivinen Design
- **Bootstrap Grid** - toimii mobiilissa ja desktop-ympäristössä
- **Card layout** - selkeä asiakastietojen esitys
- **Hover-efektit** - visuaalinen palaute käyttäjälle

## Vianmääritys

### Yleiset Ongelmat

#### 1. Backend ei käynnisty
- **Ratkaisu**: Varmista että käytät `py -m uvicorn app.main:app --reload`
- **EI TOIMI**: `python`, `uvicorn app.main:app` tai `python -m uvicorn`

#### 2. Tietokantayhteys epäonnistuu
- Tarkista `.env.local` tiedosto
- Varmista Azure PostgreSQL yhteys
- Tarkista DATABASE_URL muuttuja

#### 3. JavaScript ei toimi
- **Käytä täyttä selainta** (Edge, Chrome, Firefox)
- **ÄLKÄÄ käytä VS Code Simple Browser**
- Avaa Developer Tools (F12) Console-välilehti virheiden tarkistukseen

#### 4. CORS-virheet
- Backend tarjoilee staattiset tiedostot automaattisesti
- Käytä `http://127.0.0.1:8000/sales.html` eikä file:// protokollaa

### Debug-vinkkejä
1. **Console.log** viestit auttavat JavaScript-debuggauksessa
2. **Network tab** Developer Tools:ssa näyttää API-kutsut
3. **Backend logs** terminaalissa näyttävät serverin tilaa

## Seuraavat Kehitysvaiheet

### Plant Management (Seuraava prioriteetti)
- Plants per customer
- Plant CRUD operations
- Lines and stations hierarchy

### Mahdolliset Tulevat Ominaisuudet
- Käyttäjäauthentikointi
- Roolipohjainen käyttöoikeuksien hallinta
- Bulk operations (massatoiminnot)
- Export/Import toiminnot
- Audit trail (muutoshistoria)
- Advanced search filters

## Teknisiä Huomioita

### Turvallisuus
- Input validointi sekä frontend että backend
- SQL injection esto SQLAlchemy ORM:llä
- XSS esto proper escaping

### Suorituskyky
- Debounced search vähentää API-kutsuja
- Lazy loading - asiakkaat ladataan vain tarvittaessa
- Optimoidut tietokantakyselyt

### Ylläpidettävyys
- Modularisoidtu koodi
- Selkeä separation of concerns
- Dokumentoidut API:t
- Consistent coding style

## Yhteenveto

Asiakashallintajärjestelmä tarjoaa modernin, käyttäjäystävällisen tavan hallita asiakastietoja. Järjestelmä on rakennettu skaalautuvuutta ja ylläpidettävyyttä silmällä pitäen, ja se toimii pohjana laajemmalle teollisuuden hallintajärjestelmälle.
