# QUICK START - EMPTY DATABASE MIGRATION

## 🚀 NOPEA RESTART (Tietokanta tyhjennetty)

Jos homma on jäänyt jumiin ja tietokanta on tyhjennetty kaikista riveistä:

### 1. TARKISTA TILANNE
```bash
cd "c:\Users\jarmo.piipponen\OneDrive - John Cockerill\Documents\Optimoinnin Visualisointi Proto\stl-backend"

# Tarkista yksinkertaistettu migration:
ls add_numbering_system_empty_db.sql
ls EMPTY_DB_MIGRATION_GUIDE.md
```

### 2. TIETOKANNAN TILA (TYHJÄ)
**Kaikki taulut ovat tyhjiä rivejä** - ei tarvita backup/rollback proseduureja!

### 3. SUORITA YKSINKERTAISET MIGRATIONS
```sql
-- HUOMATTAVASTI YKSINKERTAISEMPI! Ei dataa → ei huolia

-- 1. Numerointi-järjestelmä (line_number → number + constraints)
add_numbering_system_empty_db.sql

-- 2. Tank positioning kentät (x_position, y_position, color...)
enhance_tank_table.sql

-- 3. Plant revision control
enhance_plant_table.sql
```

### 4. RESTART BACKEND
```bash
# Sammuta nykyinen
Ctrl+C

# Käynnistä uudelleen  
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

### 5. TESTAA JÄRJESTELMÄ
```sql
-- Varmista numerointi toimii
SELECT get_next_line_number(1);
SELECT get_next_tank_group_number(1);
```

## ⚡ TYHJÄN TIETOKANNAN EDUT:

- ✅ **Ei backup-tarvetta** - ei menetettävää dataa
- ✅ **Yksinkertainen migration** - suora taulun muutos
- ✅ **Nopea suoritus** - ei datan päivitystä
- ✅ **Puhdas alku** - optimaalinen rakenne alusta

## 📋 LOPPUTULOS:

Numerointijärjestelmä valmis uudelle datalle!

1. **Tank migration** (15-30 min) - Korjaa layout-jumittumisen
2. **Plant migration** (10-20 min) - Lisää revision control
3. **Backend update** (30 min) - Päivitä mallit
4. **Frontend update** (30 min) - Päivitä UI

## 🎯 SEURAAVA ASKEL

**ALOITA TANKISTA** - se korjaa suurimman ongelman (layout-jumittuminen)

```sql
-- Kopioi tämä DBeaver/pgAdmin:iin:
CREATE TABLE tank_backup AS SELECT * FROM tank;

-- Sitten avaa enhance_tank_table.sql ja suorita STEP by STEP
```
