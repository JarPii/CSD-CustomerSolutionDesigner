# **Tietokantarakenteen suhteet: Linjan luominen ja Revision-hallinta**

## **🔄 REVISION-JÄRJESTELMÄ**

### **Revision-konsepti**
- **Revision**: Laitoksen versio tietyssä kehitysvaiheessa
- **Tarkoitus**: Estää vahingossa tapahtuva tietojen tuhoaminen ja mahdollistaa versioiden vertailu
- **Toiminta**: Kun merkittäviä muutoksia tarvitaan, luodaan uusi revision

### **Revision-säännöt**

#### 🔒 **LUKITUT MUUTOKSET (vaativat uuden revision)**:
- **Line**: Altaiden määrä, järjestys
- **Tank**: Asemien määrä (kun kerran luotu)
- **Tank**: Ryhmäjäsenyys (kun kerran liitetty ryhmään)
- **TankGroup**: Jäsenaltaat (kun kerran muodostettu)

#### ✏️ **SALLITUT MUUTOKSET (kaikissa revisioissa)**:
- **Tank**: Nimi, mitat (leveys, pituus, syvyys)
- **Station**: Nimi (jos asema on luotu)
- **Line**: Nimi
- **TankGroup**: Nimi

#### 🆕 **UUSI REVISION**:
- Luodaan tyhjänä (ei peritä edellisen revision dataa)
- Voidaan kopioida toisen revision pohjalta
- Itsenäinen kokonaisuus

### **1. Plant (Laitokset)**
- **Suhde TankGroup-, Tank- ja Station-tauluihin**:
  - Jokainen `plant` sisältää useita `tank_group`, `tank` ja `station`-rivejä.
- **Revision-hallinta**:
  - `revision` - Revision numero (1, 2, 3...)
  - `revision_name` - Revision nimi (esim. "Initial Design", "Updated Layout")
  - `base_revision_id` - Viittaus alkuperäiseen revisioniin
  - `created_from_revision` - Mistä revisionista kopioitu
  - `is_active_revision` - Onko aktiivinen revision
- **Kuvaus**:
  - `plant`-taulu määrittelee laitokset, jotka sisältävät tuotantolinjat ja niiden osat.

### **2. Line (Tuotantolinjat)**
- **Suhde TankGroup-tauluun**:
  - Jokainen `line` sisältää useita `tank_group`-rivejä.
- **Suhde Plant-tauluun**:
  - Jokainen `line` kuuluu **yhteen ja vain yhteen** `plant`-tauluun.
- **Kuvaus**:
  - `line`-taulu määrittelee tuotantolinjat, jotka koostuvat tankkiryhmistä.

### **3. TankGroup (Tankkiryhmät)**
- **Suhde Line-tauluun**:
  - Jokainen `tank_group` kuuluu **yhteen ja vain yhteen** `line`-tauluun.
  - Yksi `line` voi sisältää **useamman** `tank_group`-rivin.
- **Suhde Plant-tauluun**:
  - Jokainen `tank_group` kuuluu **yhteen ja vain yhteen** `plant`-tauluun.
- **Kuvaus**:
  - `tank_group`-taulu ryhmittelee tankit ja yhdistää ne tuotantolinjaan (`line`).

### **4. Tank (Tankit)**
- **Suhde TankGroup-tauluun**:
  - Jokainen `tank` kuuluu **yhteen ja vain yhteen** `tank_group`-tauluun.
  - Yksi `tank_group` voi sisältää **useamman** `tank`-rivin.
- **Suhde Station-tauluun**:
  - Tankki voi sisältää useita asemia (`station`).
- **Kuvaus**:
  - `tank`-taulu määrittelee yksittäiset tankit, jotka ryhmitellään `tank_group`-tauluun.
  - Tank-taulun kentät:
    - `tank_group_id` - Viittaus tankkiryhmään (**voi olla tyhjä**)
    - `plant_id` - Viittaus laitokseen
    - `name` - Altaan nimi
    - `number` - Altaan numero
    - `width` - Leveys (mm)
    - `length` - Pituus (mm)
    - `depth` - Syvyys (mm)
    - `x_position` - X-koordinaatti (vasen alakulma, **oletus 0, ei voi olla tyhjä**)
    - `y_position` - Y-koordinaatti (**oletus 0, ei voi olla tyhjä**)
    - `z_position` - Z-koordinaatti (**oletus 0, ei voi olla tyhjä**)
    - `space` - Altaiden välinen väli (mm)
    - `created_at` - Luontiaika
    - `updated_at` - Päivitysaika

### **5. Station (Asemat)**
- **Suhde Tank-tauluun**:
  - Jokainen `station` kuuluu **yhteen ja vain yhteen** `tank`-tauluun.
  - Yksi `tank` voi sisältää **useamman** `station`-rivin.
- **Kuvaus**:
  - `station`-taulu määrittelee yksittäiset asemat, jotka ovat osa tankkia.

### **6. Device (Laitteet)**
- **Kuvaus**:
  - `device`-taulu sisältää geneeristen ja spesifisten laitteiden määrittelyt.

### **7. Function (Toiminnot)**
- **Kuvaus**:
  - `function`-taulu sisältää laitteiden toiminnallisuuksien määrittelyt.

---

### **Yhteenveto suhteista**
- **Plant → Line → TankGroup → Tank → Station → Device → Function**
  - `Plant` sisältää `Line`-tauluja.
  - `Line` sisältää `TankGroup`-tauluja.
  - `TankGroup` sisältää `Tank`-tauluja.
  - `Tank` sisältää `Station`-tauluja.
  - `Device` ja `Function` liittyvät muihin tauluihin tarpeen mukaan.

### **Uuden linjan luominen**

Kun luodaan uutta linjaa, seuraavat vaiheet suoritetaan:

1. **Perusmittojen ja linjanumeron määrittely**:
   - Käyttäjä antaa lomakkeella yhden tankin perusmitat (esim. leveys, pituus, syvyys) ja linjanumeron.
   - Nämä tiedot liitetään automaattisesti aktiiviseen `plant`-tauluun.

2. **Tankkien luonti**:
   - Lomakkeella käyttäjä määrittää, kuinka monta samanlaista tankkia (perusmittojen mukaisesti) halutaan luoda.
   - Jokainen luotu tankki liitetään valittuun tai annettuun `line`-tauluun.

3. **Tietokantaan tallennus**:
   - Jokainen tankki tallennetaan `tank`-tauluun, ja ne linkitetään:
     - `line`-tauluun (valittu linja).
     - `plant`-tauluun (aktiivinen laitos).

4. **Tankkiryhmän luonti (valinnainen)**:
   - Jos tankit ryhmitellään, ne liitetään uuteen tai olemassa olevaan `tank_group`-tauluun.

### **Visualisointi ja tankkien muokkaus**

1. **Visualisointi**:
   - Luontivaiheessa luodut tankit visualisoidaan linjalle.
   - Visualisoinnissa jokaiselle tankille näytetään perusmitat ja oletusnimi (esim. "no name").

2. **Tankkien muokkaus**:
   - Jokaisen tankin kohdalla on "Edit"-nappi, jonka avulla käyttäjä voi muokata tankin tietoja.
   - Muokattavia tietoja ovat esimerkiksi:
     - Tankin nimi (korvataan oletusnimi "no name").
     - Muut perusmitat, jos tarpeen.

3. **Tietojen tallennus**:
   - Muutokset tallennetaan suoraan tietokantaan `tank`-tauluun.
   - Visualisointi päivittyy reaaliaikaisesti käyttäjän tekemien muutosten perusteella.

---

### **Esimerkki tietokantatoiminnasta**

1. **Lomakkeen tiedot**:
   - Tankin leveys: 2000 mm
   - Tankin pituus: 3000 mm
   - Tankin syvyys: 1500 mm
   - Linjanumero: 5
   - Tankkien määrä: 10

2. **Tietokantaan tallennus**:
   - Luodaan uusi rivi `line`-tauluun linjanumerolla 5.
   - Luodaan 10 riviä `tank`-tauluun, joissa kaikissa on samat perusmitat ja viittaus linjaan 5.

3. **Tankkiryhmän luonti (valinnainen)**:
   - Jos tankit ryhmitellään, luodaan uusi rivi `tank_group`-tauluun ja linkitetään tankit siihen.

### **Esimerkki visualisoinnista**

| Tank ID | Nimi       | Leveys (mm) | Pituus (mm) | Syvyys (mm) | Toiminnot |
|---------|------------|-------------|-------------|-------------|-----------|
| 1       | no name    | 2000        | 3000        | 1500        | [Edit]    |
| 2       | no name    | 2000        | 3000        | 1500        | [Edit]    |
| 3       | no name    | 2000        | 3000        | 1500        | [Edit]    |
| ...     | ...        | ...         | ...         | ...         | ...       |

- Käyttäjä voi klikata "Edit"-nappia muokatakseen tankin tietoja.

### **Huomio linjan alustuksessa**

- Linjan alustuksen alkuvaiheessa tankkien numerointia ei vielä suoriteta.
- Tankit luodaan ilman numeroita, ja niiden yksilöinti tapahtuu myöhemmin prosessin edetessä.
- Tämä mahdollistaa joustavan suunnittelun ja tankkien järjestyksen määrittelyn myöhemmässä vaiheessa.

### **Altaiden jakautuminen asemiin ja paikkojen päivitys**

1. **Altaiden jakautuminen asemiin**:
   - Jos altaassa on yksi asema, sen X-koordinaatiksi asetetaan altaan keskikohta leveyssuunnassa.
   - Jos altaassa on useampia asemia, ne jaetaan tasaisesti altaan leveyssuunnassa siten, että jokaisen aseman molemmin puolin jää yhtä paljon tilaa.

2. **Asemien paikkojen päivitys**:
   - Jos yhden altaan tietoja muutetaan (esim. leveys muuttuu), päivitetään:
     - Kyseisen altaan asemien paikat X-suunnassa.
     - Kaikkien altaiden ja asemien paikat X-suunnassa suurempaa päin.

3. **Päivityksen vaikutukset**:
   - Muutokset varmistavat, että asemat pysyvät tasaisesti ja symmetrisesti jaettuina altaiden sisällä.
   - Linjan kokonaislayout päivittyy automaattisesti muutosten perusteella.

### **Altaiden ryhmittely visualisoinnissa (Revision-säännöt)**

1. **Valintamahdollisuus**:
   - Visualisoinnissa käyttäjä voi valita yhden tai useamman tankin.
   - Valinta voidaan tehdä esimerkiksi valintaruutujen avulla jokaisen tankin kohdalla.
   - **Rajoitus**: Vain tankkilta, jotka eivät ole vielä ryhmässä, voidaan ryhmitellä.

2. **Ryhmän luonti**:
   - Valittujen tankkien perusteella käyttäjä voi luoda uuden ryhmän.
   - Ryhmä tallennetaan `tank_group`-tauluun, ja siihen linkitetään valitut tankit.
   - **🔒 Lukitus**: Kun tankki on kerran liitetty ryhmään, sitä ei enää voi muuttaa.

3. **Käyttöliittymän toiminnallisuus**:
   - "Luo ryhmä" -painike aktivoituu, kun vähintään yksi ryhmittämätön tankki on valittu.
   - Käyttäjä voi antaa ryhmälle nimen ennen sen tallentamista.
   - **Varoitus**: Jos yritetään muuttaa jo ryhmitetyn tankin ryhmää, näytetään viesti.

4. **Tietokantaan tallennus**:
   - Uusi rivi luodaan `tank_group`-tauluun.
   - Valittujen tankkien `tank_group_id`-kenttä päivitetään viittaamaan uuteen ryhmään.
   - **Revision-ehto**: Ryhmäjäsenyyden muutos vaatii uuden revision.

---

### **Esimerkki käyttöliittymästä**

| Tank ID | Nimi       | Leveys (mm) | Pituus (mm) | Syvyys (mm) | Valitse |
|---------|------------|-------------|-------------|-------------|---------|
| 1       | Tank 1     | 2000        | 3000        | 1500        | [ ]     |
| 2       | Tank 2     | 2000        | 3000        | 1500        | [x]     |
| 3       | Tank 3     | 2000        | 3000        | 1500        | [x]     |
| ...     | ...        | ...         | ...         | ...         | ...     |

- Käyttäjä valitsee tankit 2 ja 3 ja klikkaa "Luo ryhmä" -painiketta.
- Ryhmä tallennetaan tietokantaan, ja tankkien 2 ja 3 `tank_group_id`-kentät päivitetään.

### **Tankin editointilomake (Revision-säännöt huomioiden)**

1. **Tankin tiedot**:
   - **Tankin nimi** ✏️ (aina muokattavissa)
   - **Leveys (mm)** ✏️ (aina muokattavissa)
   - **Pituus (mm)** ✏️ (aina muokattavissa)
   - **Syvyys (mm)** ✏️ (aina muokattavissa)
   - **Asemien määrä** 🔒 (lukittu kun kerran luotu)

2. **Toiminnallisuus**:
   - **Sallitut muutokset**: Käyttäjä voi muokata tankin nimeä ja mittoja.
   - **Estetyt muutokset**: Asemien määrä on lukittu sen jälkeen kun asemat on kerran luotu.
   - **Ryhmäjäsenyys**: Kun tankki on liitetty ryhmään, sitä ei voi enää muuttaa.

3. **Tietokantaan tallennus**:
   - Sallitut muutokset tallennetaan `tank`-tauluun.
   - Asemien määrän muutos vaatii uuden revision luomisen.

4. **Käyttöliittymän viestit**:
   - Jos käyttäjä yrittää muuttaa lukittua kenttää, näytetään viesti:
     *"Tämä muutos vaatii uuden revision luomisen. Haluatko luoda uuden revision?"*

---

### **Revision-toiminnot käyttöliittymässä**

#### **Plant-valinta laajennettuna**:
```
Customer XYZ
└── Plant ABC
    ├── Revision 1 "Initial Design" [ACTIVE] 
    ├── Revision 2 "Layout Update" [DRAFT]
    └── Revision 3 "Final Version" [ARCHIVE]
```

#### **Revision-painikkeet**:
- **🆕 "Create New Revision"** - Luo uusi tyhjä revision
- **📋 "Copy from Revision X"** - Kopioi toisen revision pohjalta  
- **⚖️ "Compare Revisions"** - Vertaile revisioita
- **✅ "Set as Active"** - Aseta aktiiviseksi revisioniksi
- **🗂️ "Archive Revision"** - Arkistoi revision

#### **Revision-tiedot**:
- **Revision numero**: Automaattinen (1, 2, 3...)
- **Revision nimi**: Käyttäjän antama (esim. "Updated Layout")
- **Luontipäivä**: Automaattinen
- **Luoja**: Käyttäjätiedot
- **Status**: ACTIVE / DRAFT / ARCHIVE

---

### **Esimerkki editointilomakkeesta**

| Kenttä            | Arvo         |
|-------------------|--------------|
| Tankin nimi       | Tank 1       |
| Leveys (mm)       | 2000         |
| Pituus (mm)       | 3000         |
| Syvyys (mm)       | 1500         |
| Asemien määrä     | 1            |

- Käyttäjä voi muuttaa "Asemien määrä" -kentän arvon ja tallentaa muutokset.

### **Altaiden ja asemien numerointi**

1. **Numeroinnin aloitus**:
   - Kun kaikki altaat on muokattu (nimetty, asemat määritetty ja ryhmitelty), voidaan aloittaa altaiden ja asemien numerointi.
   - Käyttäjältä pyydetään aloitusnumero altaiden numerointia varten.
     - Oletusarvoisesti aloitusnumero on linjanumero + 1 (esim. linja 100 --> ensimmäinen asema 101).
     - Käyttäjä voi kuitenkin antaa haluamansa aloitusnumeron (esim. 110).

2. **Numerointilogiikka**:
   - Jokaiselle altaalle annetaan yksilöllinen numero aloitusnumerosta lähtien.
   - Altaiden sisällä asemat numeroidaan altaan numeron perusteella (esim. allas 101 --> asemat 101.1, 101.2 jne.).

3. **Tietokantaan tallennus**:
   - Numerointitiedot tallennetaan `tank`- ja `station`-tauluihin.
   - Altaiden ja asemien numerot päivitetään tietokantaan automaattisesti käyttäjän vahvistuksen jälkeen.

4. **Visualisoinnin päivitys**:
   - Numerointimuutokset näkyvät reaaliaikaisesti visualisoinnissa.
   - Altaiden ja asemien numerot päivitetään käyttöliittymässä vastaamaan tietokannan tietoja.

### **Numerointilogiikan tarkennus**

1. **Asemien numerointi**:
   - Numerointi alkaa annetusta (tai oletusarvoisesta) numerosta ja etenee nousevasti järjestyksessä.
   - Jokaiselle asemalle annetaan yksilöllinen numero, joka tallennetaan `station`-taulun `number`-kenttään.

2. **Altaiden numerointi**:
   - Altaan numeroksi annetaan sen aseman numero, jonka numero on kyseisessä altaassa pienin.
   - Tämä numero tallennetaan `tank`-taulun `number`-kenttään.

3. **Allasryhmien numerointi**:
   - Allasryhmän numeroksi annetaan sen altaan numero, mikä on kyseisessä ryhmässä pienin.
   - Tämä numero tallennetaan `tank_group`-taulun `number`-kenttään.

4. **Allasryhmien nimeäminen**:
   - Allasryhmän nimeksi annetaan sen altaan nimi, jonka numero on ryhmässä pienin.
   - Tämä nimi tallennetaan `tank_group`-taulun `name`-kenttään.

5. **Tietokantaan tallennus**:
   - Numerointi- ja nimeämistiedot tallennetaan `number`-kenttiin `tank`, `station` ja `tank_group`-tauluissa.
   - Muutokset päivitetään tietokantaan automaattisesti käyttäjän vahvistuksen jälkeen.

6. **Visualisoinnin päivitys**:
   - Numerointi- ja nimeämismuutokset näkyvät reaaliaikaisesti visualisoinnissa.
   - Altaiden, asemien ja ryhmien numerot sekä nimet päivitetään käyttöliittymässä vastaamaan tietokannan tietoja.

---

## **🗂️ REVISION-JÄRJESTELMÄN TIETOKANTARAKENNE**

### **Plant-taulun laajennukset**
```sql
ALTER TABLE plant ADD COLUMN revision INTEGER DEFAULT 1;
ALTER TABLE plant ADD COLUMN revision_name VARCHAR(255) DEFAULT 'Initial Design';
ALTER TABLE plant ADD COLUMN base_revision_id INTEGER REFERENCES plant(id);
ALTER TABLE plant ADD COLUMN created_from_revision INTEGER;
ALTER TABLE plant ADD COLUMN is_active_revision BOOLEAN DEFAULT true;
ALTER TABLE plant ADD COLUMN revision_status VARCHAR(20) DEFAULT 'DRAFT'; -- DRAFT/ACTIVE/ARCHIVE
ALTER TABLE plant ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE plant ADD COLUMN created_by VARCHAR(255);
```

### **Revision-hallintalogiikka**

#### **Uuden revision luominen**:
1. **Tyhjä revision**: 
   - Luodaan uusi plant-rivi samalla nimellä mutta revision+1
   - Ei kopioida dataa edellisestä revisionista
   
2. **Kopio toisesta revisionista**:
   - Luodaan uusi plant-rivi
   - Kopioidaan kaikki line, tank_group, tank, station -data valitusta revisionista
   - Asetetaan `created_from_revision` viittaamaan lähde-revisioniin

#### **Revision-statukset**:
- **DRAFT**: Kehitystyö kesken
- **ACTIVE**: Käytössä oleva versio  
- **ARCHIVE**: Arkistoitu versio

#### **Revision-rajoitukset**:
- Vain yksi ACTIVE revision per asiakkaan plant-nimi
- ARCHIVE-revisioita ei voi muokata
- DRAFT-revisioita voi muokata vapaasti

### **Revision-kyselyt**

#### **Hae asiakkaan kaikki plant-revisionit**:
```sql
SELECT id, name, revision, revision_name, revision_status, created_at
FROM plant 
WHERE customer_id = ? AND name = 'Plant Name'
ORDER BY revision DESC;
```

#### **Hae aktiivinen revision**:
```sql
SELECT * FROM plant 
WHERE customer_id = ? AND name = 'Plant Name' AND is_active_revision = true;
```

#### **Vertaile revisioita**:
```sql
-- Tankkien määrä revisioittain
SELECT p.revision, COUNT(t.id) as tank_count
FROM plant p
LEFT JOIN line l ON l.plant_id = p.id  
LEFT JOIN tank t ON t.line_id = l.id
WHERE p.customer_id = ? AND p.name = 'Plant Name'
GROUP BY p.revision;
```

### **Revision-toimintojen käyttöliittymä**

#### **Revision-varoitukset**:
- **Asemien määrän muutos**: *"Asemien määrän muuttaminen vaatii uuden revision. Luodaanko uusi revision?"*
- **Ryhmäjäsenyyden muutos**: *"Tankin ryhmäjäsenyyden muuttaminen vaatii uuden revision. Luodaanko uusi revision?"*
- **Altaiden määrän muutos**: *"Altaiden määrän muuttaminen vaatii uuden revision. Luodaanko uusi revision?"*

#### **Revision-vahvistukset**:
- **Uuden revision luominen**: *"Luodaan uusi revision 'X' plantille 'Y'. Jatketaanko?"*
- **Revision aktivointi**: *"Asetetaan revision X aktiiviseksi. Nykyinen aktiivinen revision Y arkistoidaan. Jatketaanko?"*
- **Revision arkistointi**: *"Arkistoidaan revision X. Tätä toimintoa ei voi peruuttaa. Jatketaanko?"*

---

**Revision-järjestelmän edut:**

- ✅ Estää vahingossa tapahtuvan datan tuhoamisen
- ✅ Mahdollistaa versioiden vertailun ja historian säilyttämisen  
- ✅ Noudattaa teollisuuden standardeja (CAD/PLM-järjestelmät)
- ✅ Selkeä muutostenhallinta ja työturvallisuus
- ✅ Mahdollistaa rinnakkaisen kehitystyön eri revisioissa
