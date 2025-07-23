# PLANT REVISION SYSTEM - Step-by-Step Migration Guide

## OVERVIEW
Tämä migraatio lisää revisiointi-järjestelmän plant-tauluun. Revision system mahdollistaa:
- Useat versiot samasta plantista
- Versioiden hallinta (DRAFT/ACTIVE/ARCHIVED)
- Versioiden linkitys (base_revision_id)
- Aktiivisen version merkintä

## SAFETY FIRST
⚠️ **TÄRKEÄÄ**: Aja komennot yksi kerrallaan DBeaver:issa
⚠️ **VARMUUSKOPIO**: Luodaan automaattisesti plant_backup taulu

## STEP-BY-STEP EXECUTION

### VAIHE 1: Lähtötilanteen tarkistus
**Mitä tehdään**: Tarkistetaan plant-taulun nykyinen rakenne
**Komennot**: 1.1 - 1.3
**Odotettu tulos**: Nähdään nykyiset sarakkeet ja data määrä

### VAIHE 2: Varmuuskopio
**Mitä tehdään**: Luodaan plant_backup taulu
**Komennot**: 2.1 - 2.3
**Odotettu tulos**: plant_backup sisältää saman määrän rivejä kuin plant

### VAIHE 3: Uusien sarakkeiden lisäys
**Mitä tehdään**: Lisätään 8 uutta saraketta revision-järjestelmää varten
**Komennot**: 3.1 - 3.9
**Odotettu tulos**: 8 uutta saraketta näkyy, kaikki nullable ja ilman default arvoja

**SARAKKEET**:
- `revision` - Revision numero (1, 2, 3...)
- `revision_name` - Kuvaileva nimi ("Initial revision", "V2 with tanks"...)
- `base_revision_id` - Viittaus "vanhempaan" revisioon
- `created_from_revision` - Mistä revision numerosta kopioitu
- `is_active_revision` - Onko tämä aktiivinen versio
- `revision_status` - DRAFT/ACTIVE/ARCHIVED
- `created_by` - Kuka loi revision
- `archived_at` - Milloin arkistoitu

### VAIHE 4: Default arvojen asetus
**Mitä tehdään**: Asetetaan default arvot uusille sarakkeille
**Komennot**: 4.1 - 4.4
**Odotettu tulos**: Default arvot asetettu

### VAIHE 5: Olemassa olevan datan päivitys
**Mitä tehdään**: Täytetään uudet sarakkeet olemassa olevalle datalle
**Komennot**: 5.1 - 5.6
**Odotettu tulos**: Kaikki olemassa olevat plantit saavat revision=1, status=ACTIVE

### VAIHE 6: NOT NULL pakkojen asetus
**Mitä tehdään**: Tehdään tärkeimmät sarakkeet pakollisiksi
**Komennot**: 6.1 - 6.5
**Odotettu tulos**: revision, is_active_revision, revision_status, created_by = NOT NULL

### VAIHE 7: CHECK constraints
**Mitä tehdään**: Varmistetaan että revision_status on vain sallituissa arvoissa
**Komennot**: 7.1 - 7.2
**Odotettu tulos**: CHECK constraint hyväksyy vain DRAFT/ACTIVE/ARCHIVED

### VAIHE 8: Foreign Key
**Mitä tehdään**: Luodaan base_revision_id -> plant.id viittaus
**Komennot**: 8.1 - 8.2
**Odotettu tulos**: Foreign key constraint luotu

### VAIHE 9: Unique Constraints
**Mitä tehdään**: Varmistetaan että customer + name + revision yhdistelmä on uniikki
**Komennot**: 9.1 - 9.2
**Odotettu tulos**: Ei voi olla kahta samaa revision numeroa samalle plantille

### VAIHE 10: Indeksit suorituskyvyn parantamiseksi
**Mitä tehdään**: Luodaan 4 indeksiä nopeampaa hakua varten
**Komennot**: 10.1 - 10.5
**Odotettu tulos**: 4 uutta indeksiä luotu

### VAIHE 11: Lopullinen tarkistus
**Mitä tehdään**: Varmistetaan että kaikki meni oikein
**Komennot**: 11.1 - 11.3
**Odotettu tulos**: Kaikki sarakkeet, constraintit ja data kunnossa

## TROUBLESHOOTING

### Jos joku komento epäonnistuu:
1. **PYSÄYTÄ** - älä jatka seuraavaan vaiheeseen
2. **KOPIOI virheviesti** ja kysy apua
3. **Palauta varmuuskopiosta** tarvittaessa:
   ```sql
   DROP TABLE plant;
   ALTER TABLE plant_backup RENAME TO plant;
   ```

### Jos data menee "pieleen":
- `plant_backup` taulu sisältää alkuperäisen datan
- Voit palauttaa sen milloin tahansa

### Jos migraatio keskeytyy:
- Tarkista missä vaiheessa olet: katso mitä sarakkeita/constrainteja on jo lisätty
- Voit jatkaa siitä missä jäit, mutta ohita jo tehdyt kohdat

## SUCCESS CRITERIA

✅ **Onnistuneen migraation merkit**:
- 8 uutta saraketta plant-taulussa
- 3 uutta constraint:ia (UNIQUE, FOREIGN KEY, CHECK)
- 4 uutta indeksiä
- Kaikki olemassa oleva data revision=1, status=ACTIVE
- Ei NULL arvoja pakollisissa sarakkeissa

## NEXT STEPS

Kun migraatio on valmis, voidaan:
1. **Luoda helper-funktiot** revision hallintaan (seuraava vaihe)
2. **Testata revision creation** toiminnallisuutta
3. **Päivittää Python API** käyttämään revision järjestelmää

---
**MUISTA**: Yksi komento kerrallaan, tarkista tulos ennen jatkamista! 🎯
