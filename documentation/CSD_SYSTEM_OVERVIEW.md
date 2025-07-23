# CSD_SYSTEM_OVERVIEW

**Päivitetty:** 23. heinäkuuta 2025  
**Tehtävä:** Kuvaa STL-järjestelmän päätoiminnallisuudet, arkkitehtuurin ja tietovirrat.

## YLEISKATSAUS

STL-järjestelmä on asiakaskohtainen tuotantolaitosten suunnittelu- ja hallintaratkaisu, joka koostuu seuraavista pääkomponenteista:

- **Backend:** FastAPI-pohjainen palvelin, joka hallinnoi tietokantaa, liiketoimintalogiikkaa ja REST-rajapintoja.
- **Tietokanta:** Azure PostgreSQL, jossa on relaatiomalli tuotantolaitoksille, linjoille, tankkiryhmille, tankeille, laitteille ja toiminnoille.
- **Frontend:** HTML/JS-pohjainen käyttöliittymä, joka mahdollistaa laitosten, linjojen ja tankkien hallinnan sekä visualisoinnin.
- **Dokumentaatio:** Kaikki tekninen ja toiminnallinen dokumentaatio on keskitetty documentation-kansioon.

## PÄÄTOIMINNOT

- Asiakkaiden, laitosten, linjojen, tankkiryhmien ja tankkien CRUD-hallinta
- Revisionhallinta laitosten rakenteille
- Laitteiden ja toimintojen hallinta sekä niiden kytkentä
- Tuotantovaatimusten ja tuotteiden hallinta
- Chat-integraatio (AI-avustettu suunnittelu ja tuki)
- Tietojen validointi ja viiteavainten ylläpito

## TIETOVIRRAT JA ARKKITEHTUURI

1. Käyttäjä käyttää frontendia selaimella
2. Frontend lähettää HTTP-pyynnöt backendille (REST API)
3. Backend käsittelee pyynnöt, validoi tiedot ja päivittää Azure PostgreSQL -tietokantaa
4. Kaikki muutokset ja toiminnot dokumentoidaan ja synkronoidaan documentation-kansioon

## TURVALLISUUS JA LAATU

- Kaikki tiedonsiirto tapahtuu SSL-suojattuna
- Käyttäjäoikeudet ja validoinnit toteutettu backendissä
- Tietokannan viiteavaimet ja relaatiot takaavat datan eheyden
- Testattu Azure-ympäristössä tuotantovalmiiksi

## YHTEENVETO

STL-järjestelmä tarjoaa kattavan ja skaalautuvan ratkaisun tuotantolaitosten suunnitteluun, hallintaan ja dokumentointiin. Kaikki komponentit ja dokumentaatio ovat synkronissa ja noudattavat yhtenäistä nimeämiskäytäntöä.

**Muutosten tekijä:** GitHub Copilot  
**Päivämäärä:** 2025-07-23
