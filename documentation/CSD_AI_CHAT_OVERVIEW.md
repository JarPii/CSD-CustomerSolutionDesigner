# CSD AI-CHAT - YHTEENVETO JA VISIO

## Nykyinen toteutus

CSD-järjestelmässä AI-chat on integroitu Knowledge Hub -sivulle, mahdollistaen käyttäjän keskustelun järjestelmän kanssa ja tietojen analysoinnin. Toteutus perustuu seuraaviin teknisiin ratkaisuihin:

### Backend
- **SQLAlchemy-mallit**: ChatSession ja ChatMessage tallentavat keskustelut ja viestit.
- **Pydantic-mallit**: ChatMessageCreate, ChatMessageOut, ChatSessionOut, ChatResponse.
- **API-endpointit**:
  - `POST /api/chat`: AI-keskustelun käsittely
  - `GET /api/chat/{session_id}/history`: keskusteluhistorian haku
  - `GET /api/chat/sessions`: keskustelujen listaus
- **OpenAI GPT-3.5-turbo integraatio** (API-avaimella)
- **Fallback-vastaukset**: Jos OpenAI ei ole käytettävissä
- **Session management**: Keskustelujen jatkuvuus
- **Keskusteluhistorian tallennus**: Viestit ja sessiot tietokantaan
- **Virheenkäsittely ja lokitus**
- **Token-seuranta ja suorituskyvyn mittaus**
- **Aikakenttien yhtenäistäminen**: TIMESTAMP-tyyppi, tietokannan oletusarvot
- **Pydantic-validointi**: Optional-tyypit endpointien palautuksessa

### Frontend
- **Knowledge Hub -sivu**: Käyttöliittymä chatille
- **Keskusteluhistorian näyttö**
- **Viestien lähetys ja vastaanotto**
- **Virheiden ja tilojen informointi käyttäjälle**

## Visio tulevasta

AI-chatin rooli CSD:ssä laajenee pelkästä keskustelusta kohti älykästä analysointia ja arviointia:

- **Tietojen analysointi**: Chat voi hyödyntää CSD:n tietokantaan tallennettuja projektitietoja, asiakastietoja, laite- ja prosessidataa sekä historiatietoja.
- **Arviointi ja suositukset**: AI voi antaa suosituksia prosessien optimointiin, laitevalintoihin, tuotantolinjojen rakenteeseen ja huoltotoimenpiteisiin.
- **Raportointi**: Käyttäjä voi pyytää chatilta yhteenvetoja, tilastoja ja visuaalisia raportteja järjestelmän datasta.
- **Kyselyt ja haku**: Chat voi hakea ja suodattaa tietoja, esimerkiksi "Näytä kaikki tankit, joiden syvyys > 1500 mm".
- **Integraatio muihin CSD-ominaisuuksiin**: Chat voi ohjata käyttäjää oikeisiin näkymiin, käynnistää prosesseja ja auttaa dokumentaation haussa.
- **Kehittynyt virheiden ja poikkeamien tunnistus**: AI voi analysoida datasta poikkeamia ja ehdottaa korjaavia toimenpiteitä.
- **Käyttäjäkohtainen oppiminen**: Chat voi oppia käyttäjän tarpeista ja mukauttaa vastauksiaan.

## Esimerkkejä tulevista käyttötapauksista
- "Analysoi viimeisimmän revision muutokset ja kerro riskit."
- "Suosittele optimaaliset tankkiryhmät tämän linjan mittojen perusteella."
- "Laadi yhteenveto laitoksen tuotantokapasiteetista."
- "Etsi kaikki laitteet, joilla on huoltohistoriassa poikkeamia."
- "Arvioi prosessimuutoksen vaikutus energiankulutukseen."

---

**AI-chatista tulee CSD:n älykäs analyysi- ja arviointityökalu, joka tukee käyttäjää päätöksenteossa ja tiedon hyödyntämisessä.**

**Päivitetty:** 2025-07-23
**Ylläpitäjä:** Development Team
