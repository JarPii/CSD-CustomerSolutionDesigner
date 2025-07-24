# STL Customer Solution Designer (CSD)

## Frontend-koodin rakenne ja säännöt

- Kaikki JavaScript-koodi tulee sijoittaa ulkoisiin tiedostoihin kansioon `static/js/`.
- HTML-tiedostot eivät saa sisältää sisäistä `<script>...</script>`-osiota, vaan viittaavat aina ulkoisiin JS-tiedostoihin `<script src="/static/js/tiedosto.js"></script>`.
- Tämä koskee kaikkia sivuja (esim. customer-plant-selection.html, sales.html jne.).
- Tavoitteena on selkeä, ylläpidettävä ja moderni rakenne, jossa logiikka ja rakenne ovat erillään.

**Päivitetty:** 23. heinäkuuta 2025

## Yleiskuvaus

STL Customer Solution Designer (CSD) on FastAPI-pohjainen järjestelmä tuotantolaitosten suunnitteluun, hallintaan ja dokumentointiin. Järjestelmä hyödyntää Azure PostgreSQL -tietokantaa ja tarjoaa REST-rajapinnan frontendille. Kaikki dokumentaatio on keskitetty `documentation`-kansioon.

## Ohjelmointikielet
- Python (backend)
- HTML, JavaScript (frontend)
- SQL (tietokanta ja migraatiot)

## Asennettavat paketit
Kaikki tarvittavat paketit löytyvät `requirements.txt` ja `requirements-dev.txt` tiedostoista. Tärkeimmät:
- fastapi
- uvicorn[standard]
- psycopg2-binary
- sqlalchemy
- pandas
- python-dotenv
- pydantic-settings
- gunicorn
- openai
- pytest, pytest-asyncio, httpx (kehitykseen)

Asenna paketit komennolla:
```
pip install -r requirements.txt
pip install -r requirements-dev.txt  # kehitysympäristöön
```

## Käynnistys
Backend käynnistetään komennolla:
```
uvicorn app.main:app --reload
```

## Dokumentation-kansion tiedostojen tarkoitus

- **CSD_SYSTEM_OVERVIEW.md**: Kokonaiskuva järjestelmän toiminnasta, arkkitehtuurista ja tietovirroista
- **CSD_DATABASE_SCHEMA.md**: Tietokannan taulujen ja relaatiomallin kuvaus
- **CSD_TECHNICAL_DOCUMENTATION.md**: Tekninen toteutus, API-rakenteet ja integraatiot
- **CSD_BACKEND_FUNCTIONS.md**: Backendin päätoiminnot, mallit ja endpointit
- **CSD_PLANT_STRUCTURE.md**: Laitos-, linja-, tankkiryhmä- ja tankkirakenteen logiikka
- **CSD_AI_CHAT_OVERVIEW.md**: AI-chat-integraation kuvaus ja käyttötapaukset
- **CSD_ICON_GUIDELINES.md**: Ikonien ja käyttöliittymän visuaaliset ohjeet
- **CSD_BRAND_GUIDELINES.md**: Brändin visuaaliset ja viestinnälliset ohjeet

Kaikki dokumentit noudattavat yhtenäistä CSD_ alkuista nimeämiskäytäntöä.

## Lisätiedot
Katso tarkemmat ohjeet ja tekniset yksityiskohdat `documentation`-kansion tiedostoista.
