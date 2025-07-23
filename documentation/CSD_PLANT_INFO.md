# CSD_PLANT_INFO.md

**Päivitetty:** 23. heinäkuuta 2025  
**Tehtävä:** Kuvaa laitoksen (Plant) informaatiorakenteen, siihen liittyvät tietokantataulut ja kentät sekä nykyisen käyttöliittymän toiminnan.

## YLEISKATSAUS

Laitos (Plant) on järjestelmän ydinentiteetti, joka kuvaa asiakaskohtaista tuotantolaitosta. Laitos sisältää perustiedot, revisionhallinnan sekä relaatiot linjoihin, tankkiryhmiin ja tankkeihin.

## TIETOKANTATAULUT JA KENTÄT

### Taulu: `plant`
- **id**: Laitoksen yksilöivä tunniste
- **customer_id**: Viite asiakas-tauluun
- **name**: Laitoksen nimi
- **town**: Paikkakunta
- **country**: Maa
- **created_at**: Luontiaika
- **updated_at**: Päivitysaika
- **revision**: Revisionumero
- **revision_name**: Revision nimi
- **base_revision_id**: Viite edelliseen revisioon
- **created_from_revision**: Luonti edellisestä revisiosta
- **is_active_revision**: Onko aktiivinen revisio
- **revision_status**: Revision tila (DRAFT, ACTIVE, ARCHIVED)
- **created_by**: Luoja
- **archived_at**: Arkistointiaika

### Relaatiot
- **lines**: Yhteys tuotantolinjoihin (`line`-taulu)
- **tank_groups**: Yhteys tankkiryhmiin (`tank_group`-taulu)
- **tanks**: Yhteys tankkeihin (`tank`-taulu)

## KÄYTTÖLIITTYMÄN TOIMINTA

- Käyttäjä näkee laitosten listauksen, jossa näkyvät nimi, paikkakunta, maa ja revisionumero
- Laitoksen tiedot avautuvat yksityiskohtaisessa näkymässä, jossa näkyvät kaikki kentät ja revisionhallinnan tila
- Käyttäjä voi luoda uuden laitoksen, muokata olemassa olevaa tai arkistoida revisioita
- Laitoksen näkymästä pääsee suoraan hallitsemaan linjoja, tankkiryhmiä ja tankkeja
- Revisionhallinta mahdollistaa rakenteen muokkaamisen ja versionhallinnan

## YHTEENVETO

Laitos on järjestelmän keskeinen tietorakenne, johon liittyvät kaikki tuotantorakenteen osat. Tietokantamalli ja käyttöliittymä tukevat laitoksen elinkaaren hallintaa, revisionhallintaa ja rakenteiden ylläpitoa.

**Muutosten tekijä:** GitHub Copilot  
**Päivämäärä:** 2025-07-23
