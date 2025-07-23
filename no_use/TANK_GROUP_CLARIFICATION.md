# TANK_GROUP KONSEPTIN SELITYS JA MIGRATION PÄÄTÖS

## 🎯 TANK_GROUP:N TARKOITUS (selkeni keskustelussa)

### **PROSESSIKESKEINEN MALLI:**

Tank_group **EI OLE** pelkkä hierarkinen ryhmittely, vaan **prosessivaiheen määrittely**:

```
Line: "Acid Pickling Line"
├── Tank_Group: "Pre-wash Stage" (Prosessivaihe 1)
│   ├── Tank: "Pre-wash A" (Rinnakkainen allas)
│   ├── Tank: "Pre-wash B" (Rinnakkainen allas)
│   └── Tank: "Pre-wash C" (Rinnakkainen allas)
├── Tank_Group: "Acid Bath Stage" (Prosessivaihe 2)  
│   ├── Tank: "Acid Bath 1"
│   └── Tank: "Acid Bath 2"
└── Tank_Group: "Rinse Stage" (Prosessivaihe 3)
    ├── Tank: "Rinse A"
    └── Tank: "Rinse B"
```

## 🔧 KÄYTÄNNÖN HYÖDYT:

### 1. **TREATMENT PROGRAMS**
- Käsittelyohjelma kohdistuu **tank_group:iin**, ei yksittäisiin tankeihin
- "Suorita happopesua 15 min Pre-wash Stage:ssä" 
- Järjestelmä valitsee automaattisesti vapaan tankin ryhmästä

### 2. **RINNAKKAISET ALTAAT**
- Sama kemikaalisekoitus kaikissa ryhmän altaissa
- Samanlaiset toimilaitteet (pumput, lämmittimet)
- **Load balancing**: työ jakautuu vapaiden altaiden kesken
- **Redundancy**: jos yksi allas rikkoutuu, muut jatkavat

### 3. **PROSESSIN HALLINTA**
- Kemikaalireseptit määritellään ryhmätasolla
- Huolto-ohjelmat kohdistetaan prosessiryhmiin
- Tuotannon optimointi ryhmätasolla

## 📋 MIGRATION PÄÄTÖS:

### ✅ **SÄILYTETÄÄN TANK_GROUP MALLI**

Koska tank_group tarjoaa **toiminnallista arvoa** treatment programeissa:

1. **EI muuteta hierarkiaa** tank → line 
2. **Säilytetään** tank → tank_group → line
3. **Päivitetään dokumentaatio** selittämään prosessikeskeisyys
4. **Enhancement scriptit** toimivat nykyisen mallin kanssa

### 🔄 **MIKSI TÄMÄ ON PAREMPI:**

#### **Dokumentaation alkuperäinen malli:**
```
tanks → lines (yksinkertainen, mutta ei tue prosessinhallintaa)
```

#### **Nykyinen prosessikeskeinen malli:**
```
tanks → tank_groups → lines (monimutkainen, mutta tukee treatment programs)
```

## 🎯 **ENHANCEMENT SCRIPT MUUTOKSET:**

Tank enhancement script **EI TARVITSE** muutoksia, koska:

1. ✅ Positioning kentät (x_position, y_position) lisätään tankeihin
2. ✅ Visual kentät (color, type) lisätään tankeihin  
3. ✅ Revision control lisätään tankeihin
4. ✅ Tank_group hierarkia säilyy ennallaan

## 🔧 **TREATMENT PROGRAM INTEGRAATIO:**

```sql
-- Treatment program step kohdistuu tank_group:iin
CREATE TABLE program_step (
    id SERIAL PRIMARY KEY,
    treatment_program_id INTEGER NOT NULL,
    stage INTEGER NOT NULL,
    min_station INTEGER, -- tank_group.number (min)
    max_station INTEGER, -- tank_group.number (max)
    min_treatment_time INTEGER,
    max_treatment_time INTEGER,
    description TEXT
);
```

### **Käytännön esimerkki:**
```sql
-- Program step: "15 min happopesua asemilla 2-3"
-- Tämä tarkoittaa tank_group.number = 2 TAI 3
-- Järjestelmä valitsee vapaan tankin näistä ryhmistä
```

## 📝 **LOPPUTULOS:**

1. **Tank_group säilyy** - se on olennainen prosessinhallinnalle
2. **Enhancement scriptit toimivat** sellaisenaan
3. **Dokumentaatio päivitetty** selittämään prosessikeskeisyys
4. **Ei tarvitse refaktorointia** - nykyinen malli on järkevä

**Tämä oli erinomainen huomio! Tank_group ei ole "ylimääräinen kerros" vaan olennainen osa prosessinhallintaa.**
