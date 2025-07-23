# CSD_MVP_OVERVIEW.md

**Päivitetty:** 23. heinäkuuta 2025  
**Tehtävä:** Kuvaa CSD-järjestelmän MVP-version (Minimum Viable Product) – käyttökelpoisen end-to-end rungon, joka voidaan esitellä yrityksen johdolle jatkokehityksen pohjaksi.

## MVP-TAVOITTEET

- Tarjota selkeä, toimiva kokonaisuus tuotantolaitosten hallintaan
- Mahdollistaa asiakkaiden, laitosten, linjojen ja tankkien perustiedon hallinta
- Sisältää revisionhallinnan laitoksille
- Tarjota yksinkertainen, mutta laajennettava käyttöliittymä
- Tukea Azure PostgreSQL -tietokantaa ja modernia backend-arkkitehtuuria

## MVP-KOMPONENTIT

- **Backend (FastAPI):**
  - CRUD-rajapinnat asiakkaille, laitoksille, linjoille ja tankeille
  - Revisionhallinta laitoksille
  - Tietojen validointi ja viiteavainten ylläpito

- **Tietokanta (Azure PostgreSQL):**
  - Relaatiomalli: customer, plant, line, tank
  - Revisionhallinnan kentät plant-taulussa

- **Frontend (HTML/JS):**
  - Laitosten listaus ja yksityiskohtainen näkymä
  - Laitoksen revisionhallinnan perustoiminnot
  - Linjojen ja tankkien hallinta laitoksen näkymästä

- **Dokumentaatio:**
  - Yleiskuvaus järjestelmästä ja MVP:stä
  - Tietokantamalli ja API-kuvaus
  - Käyttöliittymän toimintalogiikka

## MVP-PROSESSI

1. Käyttäjä kirjautuu järjestelmään ja näkee laitosten listauksen
2. Käyttäjä voi luoda uuden laitoksen, muokata tietoja ja hallita revisioita
3. Laitoksen näkymästä hallitaan linjoja ja tankkeja
4. Kaikki muutokset tallentuvat Azure PostgreSQL -tietokantaan
5. Dokumentaatio ja tekninen kuvaus ovat saatavilla johdolle ja kehittäjille

## YHTEENVETO

MVP tarjoaa yrityksen johdolle konkreettisen, käyttökelpoisen rungon CSD-prosessista. Se osoittaa järjestelmän potentiaalin ja laajennettavuuden, mutta pysyy yksinkertaisena ja helposti esiteltävänä.

**Muutosten tekijä:** GitHub Copilot  
**Päivämäärä:** 2025-07-23
