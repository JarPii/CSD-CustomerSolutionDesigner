# CSD_BACKEND_FUNCTIONS

**Päivitetty:** 11. heinäkuuta 2025  
**Tehtävä:** Varmistaa, että backendin toteutus, tietokantakuvaus ja dokumentaatio ovat täysin synkronissa.

## YLEISKATSAUS

Tämä dokumentti kuvaa backendin päätoiminnot, mallien ja endpointien rakenteen sekä niiden vastaavuuden tietokantaan ja dokumentaatioon.

### Mallit (SQLAlchemy)
- Customer
- Plant
- Line
- TankGroup
- Tank
- Device
- Function
- FunctionDevice

### CRUD-endpointit
- customer
- plant
- line
- tank_group
- tank
- device
- function
- function_device

## TOTEUTUKSEN VASTAVUUS

- Kaikki dokumentoidut taulut on toteutettu backendissä
- Sarakkeet ja viiteavaimet vastaavat dokumentaatiota
- Tietotyypit ja relaatiot ovat yhdenmukaiset
- CRUD-operaatiot kattavat kaikki päätaulut

## TESTAUS JA LAATU

- Backend käynnistyy ongelmitta
- Kaikki endpointit palauttavat oikean muotoista dataa
- Viiteavaimet ja relaatiot toimivat
- Uudet endpointit (tank-groups, tanks) testattu

## YHTEENVETO

Backend, tietokantakuvaus ja dokumentaatio ovat **täysin synkronissa**. Kaikki päätoiminnot ja taulut on toteutettu ja testattu tuotantokäyttöön.

**Muutosten tekijä:** GitHub Copilot  
**Testausympäristö:** Azure PostgreSQL + FastAPI + Uvicorn  
**Päivämäärä:** 2025-07-11
