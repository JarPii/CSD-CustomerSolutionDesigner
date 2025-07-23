# STL Backend - Käyttöohjeet

## Yleiskatsaus

STL Backend on Python/FastAPI-pohjainen järjestelmä asiakkaiden ja tehtaiden hallintaan. Järjestelmä koostuu backend-palvelimesta ja web-käyttöliittymästä.

## Järjestelmän käynnistäminen

### 1. Backend-palvelimen käynnistäminen

1. Avaa PowerShell ja navigoi projektikansioon:
   ```powershell
   cd "c:\Users\jarmo.piipponen\OneDrive - John Cockerill\Documents\Optimoinnin Visualisointi Proto\stl-backend"
   ```

2. Käynnistä backend-palvelin:
   ```powershell
   py -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
   ```

   **Huom!** Käytä aina `py -m uvicorn` -komentoa, ei pelkkää `uvicorn`.

3. Palvelin käynnistyy osoitteeseen: http://localhost:8000

### 2. Web-käyttöliittymän avaaminen

1. Avaa verkkoselain (Edge, Chrome, Firefox - **EI** VS Code Simple Browser)
2. Mene osoitteeseen: http://localhost:8000
3. Valitse "Sales" päästäksesi asiakashallintaan

## Asiakashallinta (Sales)

### Asiakkaan haku

1. **Kirjoita asiakkaan nimeä hakukenttään**
   - Haku tapahtuu automaattisesti kirjoittaessa
   - Vähintään yksi merkki aloittaa haun

2. **Näytä kaikki asiakkaat**
   - Kirjoita `*` tai `all` hakukenttään
   - Kaikki asiakkaat näkyvät listassa

3. **Hakutulokset**
   - Hakutulokset näkyvät reaaliajassa
   - Klikkaa asiakasriviä valitaksesi asiakkaan

### Uuden asiakkaan luominen

1. **Automaattinen tarjous**
   - Jos hakutuloksia ei löydy, järjestelmä tarjoaa uuden asiakkaan luomista
   - Hakutermi täytetään automaattisesti nimeen

2. **Manuaalinen luominen**
   - Klikkaa "Create New Customer" -painiketta
   - Täytä vaaditut tiedot:
     - **Nimi** (pakollinen)
     - **Kaupunki** (valinnainen)
     - **Maa** (valinnainen)
   - Klikkaa "Create Customer"

### Asiakkaan muokkaaminen

1. **Valitse asiakas** klikkaamalla asiakasriviä
2. **Klikkaa "Edit"** asiakkaan tiedoissa
3. **Muokkaa tietoja** lomakkeessa
4. **Tallenna** klikkaamalla "Update Customer"
5. **Peruuta** klikkaamalla "Cancel"

### Asiakkaan poistaminen

1. **Valitse asiakas** klikkaamalla asiakasriviä
2. **Klikkaa "Delete"** asiakkaan tiedoissa
3. **Vahvista poisto** ponnahdusikkunassa
4. Asiakas poistetaan välittömästi

### Asiakkaan valinta

1. **Klikkaa asiakasriviä** joko hakutuloksista tai kokonaislistasta
2. **Asiakkaan tiedot** näkyvät "Selected Customer" -kortissa
3. **Tyhjennä valinta** klikkaamalla "Clear Selection"

## Navigointi

- **Takaisin pääsivulle**: Klikkaa "Back to main page" -painiketta oikeassa yläkulmassa
- **Tyhjennä haku**: Tyhjennä hakukenttä piilottaaksesi tulokset

## Vinkkejä käyttöön

### Tehokas haku
- Kirjoita asiakkaan nimen alkukirjaimia nopeaan hakuun
- Käytä `*` nähdäksesi kaikki asiakkaat kerralla
- Haku toimii reaaliajassa - odota hetki ennen kuin kirjoitat lisää

### Asiakkaiden hallinta
- Asiakasrivit ovat klikattavia - ei tarvita erillistä "Valitse" -painiketta
- Muokkaus- ja poisto-toiminnot ovat saatavilla vasta asiakkaan valinnan jälkeen
- Uuden asiakkaan luominen on helpointa kun haku ei tuota tuloksia

### Käyttöliittymä
- Kaikki toiminnot tapahtuvat samalla sivulla ilman ponnahdusikkunoita
- Lomakkeet näkyvät ja piiloutuvat automaattisesti
- Hover-efekti asiakasriveillä helpottaa valintaa

## Vianmääritys

### Backend ei käynnisty
- Varmista että olet oikeassa kansiossa
- Käytä `py -m uvicorn` -komentoa, ei pelkkää `uvicorn`
- Tarkista että portti 8000 on vapaa

### JavaScript ei toimi
- **EI** käytä VS Code Simple Browser -selainta
- Käytä Edge, Chrome tai Firefox -selainta
- Varmista että backend on käynnissä

### Tietokantayhteys ei toimi
- Tarkista `.env.local` -tiedoston asetukset
- Varmista Azure PostgreSQL -yhteys
- Katso konsolista mahdolliset virheviestit

### Hakutoiminto ei toimi
- Varmista että backend on käynnissä
- Avaa selaimen kehittäjätyökalut (F12) ja tarkista Console-välilehti
- Päivitä sivu (F5) ja yritä uudelleen

## Tuetut selaimet

✅ **Toimivat:**
- Microsoft Edge
- Google Chrome
- Mozilla Firefox

❌ **Eivät toimi:**
- VS Code Simple Browser (JavaScript-rajoitukset)

## Tietokanta

Järjestelmä käyttää Azure PostgreSQL -tietokantaa:
- **Taulu**: `customer`
- **Kentät**: `id`, `name`, `town`, `country`, `created_at`, `updated_at`
- **Yhteys**: Määritelty `.env.local` -tiedostossa

## Jatkokehitys

Tällä hetkellä toteutettu:
- Asiakashallinta (CRUD-toiminnot)
- Reaaliaikainen haku
- Responsiivinen käyttöliittymä

Suunnitteilla:
- Tehtaiden hallinta asiakkaille
- Linjojen ja asemien hallinta
- Laajemmat myyntitoiminnot
