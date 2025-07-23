# CSD_PLANT_REVISION.md

**Päivitetty:** 23. heinäkuuta 2025  
**Tehtävä:** Kuvaa laitoksen (Plant) revisionhallinnan rakenteen, siihen liittyvät tietokantataulut ja kentät sekä nykyisen käyttöliittymän toiminnan.

## YLEISKATSAUS

Laitoksen revisionhallinta mahdollistaa tuotantolaitoksen rakenteen ja tietojen versionhallinnan. Jokaisella laitoksella voi olla useita revisioita, joilla hallitaan muutoksia, suunnittelua ja tuotantohistoriaa.

## REVISIONHALLINNAN TIETOKANTARAKENNE

### Taulu: `plant`
- **id**: Laitoksen yksilöivä tunniste
- **revision**: Revisionumero
- **revision_name**: Revision nimi
- **base_revision_id**: Viite edelliseen revisioon
- **created_from_revision**: Luonti edellisestä revisiosta
- **is_active_revision**: Onko aktiivinen revisio
- **revision_status**: Revision tila (DRAFT, ACTIVE, ARCHIVED)
- **created_by**: Revision luoja
- **archived_at**: Arkistointiaika

### Revisionin relaatiot
- Jokainen revisio liittyy laitokseen ja voi olla johdettu aiemmasta revisiosta
- Revisionit voivat olla tilassa DRAFT, ACTIVE tai ARCHIVED
- Vain yksi revisio voi olla aktiivinen kerrallaan

## KÄYTTÖLIITTYMÄN TOIMINTA

- Käyttäjä näkee laitoksen revision historian ja aktiivisen revision
- Uuden revision voi luoda kopioimalla olemassa olevan revision
- Revisionin tilaa voi muuttaa (DRAFT → ACTIVE → ARCHIVED)
- Revisionin tiedot ja muutokset näkyvät selkeästi laitoksen näkymässä
- Revisionhallinta mahdollistaa rakenteen ja tietojen versionhallinnan sekä palauttamisen aiempaan tilaan

## YHTEENVETO

Laitoksen revisionhallinta on keskeinen osa järjestelmän suunnittelu- ja tuotantoprosessia. Se mahdollistaa rakenteiden ja tietojen hallitun muutoksen, versionhallinnan ja tuotantohistorian ylläpidon.

**Muutosten tekijä:** GitHub Copilot  
**Päivämäärä:** 2025-07-23
