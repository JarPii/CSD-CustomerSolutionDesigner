# CSD_Theme_and_Navigation.md

Tämä dokumentti kuvaa Customer Solution Designer (CSD) -sovelluksen teeman (värimaailma) ja navigaation hallinnan periaatteet sekä vaatimukset, jotta käyttäjäkokemus on yhtenäinen ja looginen kaikissa käyttötilanteissa.

## 1. Teeman kulku ja periytyminen

- **Teema valitaan etusivulla** (esim. "sales", "engineering", "simulation", 'knowledge hub') korttivalinnan yhteydessä.
- **Teema välitetään URL-parametrina** (esim. `?theme=sales`) kaikkiin niihin sivuihin, joihin käyttäjä siirtyy etusivulta tai hierarkkisesti etenevistä valinnoista.
- **Kaikkien alasivujen** (esim. asiakas- ja laitoksen valintasivu, lomakkeet, yms.) tulee lukea teema aina URL-parametrista ja käyttää sitä ulkoasun ja värien määritykseen.
- Jos teema-parametri puuttuu, käytetään oletusteemaa (esim. "engineering").
- Teeman tulee vaikuttaa:
  - Headerin ja navigaation ulkoasuun
  - Kaikkien lomakkeiden, korttien ja painikkeiden väreihin
  - Sivun taustaväriin ja teksteihin

## 2. Navigaation periaatteet

- **Back-painike** (selain tai sovelluksen oma) palauttaa käyttäjän aina hierarkkisesti edelliselle tasolle, ei välttämättä teknisesti edelliselle sivulle.
  - Esim. jos käyttäjä on "sales"-teemassa laitoksen valintasivulla ja painaa back, hän palaa sales-pääsivulle, ei välttämättä selaimen historiaan edelliseen URL:iin.
- **Navigaatio toteutetaan niin, että teema säilyy** kaikissa siirtymissä (myös back-painikkeella), eikä käyttäjä pääse vahingossa väärään teemaan.
- Sivujen tulee aina lukea teema-parametri ja palauttaa käyttäjä oikeaan teemaan kuuluvalle sivulle.

## 3. Toteutusohjeet kehittäjille

- Kaikki navigaatiossa käytettävät linkit ja painikkeet lisäävät `theme`-parametrin URL:iin.
- Sivun JavaScript lukee aina teeman URL-parametrista ja asettaa ulkoasun sen mukaan.
- Jos käyttäjä palaa back-painikkeella, sivun on tarkistettava teema-parametri ja tarvittaessa ohjattava oikeaan teemaan.
- Headerin ja muiden yhteisten komponenttien tulee tukea teemaa dynaamisesti.
- Testaa navigaatio ja teeman säilyminen kaikissa käyttöpoluissa (myös selaimen back/forward-näppäimillä).

## 4. Esimerkkipolku

1. Käyttäjä valitsee etusivulta "Sales"-kortin → siirtyy sales-sivulle: `sales.html?theme=sales`
2. Sales-sivulta siirrytään asiakasvalintasivulle: `customer-plant-selection.html?theme=sales`
3. Asiakasvalintasivulla kaikki värit ja header noudattavat sales-teemaa.
4. Käyttäjä painaa back → palaa sales-sivulle, teema säilyy.

## 5. Yhteenveto

- Teema-parametri on pakollinen osa URL:ia kaikissa navigaatiossa.
- Sivujen tulee olla teemariippuvaisia ja asettaa ulkoasu dynaamisesti.
- Navigaatio on hierarkkista, ei pelkkää selaimen historiaa.
- Näin varmistetaan yhtenäinen ja looginen käyttäjäkokemus.
