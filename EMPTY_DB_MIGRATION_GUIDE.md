# Simplified Numbering Migration for Empty Database

## 🎯 TILANNE: Tietokanta tyhjennetty

Koska kaikki taulut on tyhjennetty riveistä, migration on huomattavasti yksinkertaisempi!

## ✅ MITÄ TEHDÄÄN:

### 1. **Sarakkeen uudelleennimeäminen**
```sql
-- line_number → number (yhtenäisyys)
ALTER TABLE line RENAME COLUMN line_number TO number;
```

### 2. **NOT NULL rajoitteet**
```sql
-- Varmistetaan että numerot ovat pakollisia
ALTER TABLE tank_group ALTER COLUMN number SET NOT NULL;
ALTER TABLE tank ALTER COLUMN number SET NOT NULL;
```

### 3. **Unique rajoitteet**
```sql
-- Estetään duplikaatti numerot
ALTER TABLE line ADD CONSTRAINT uk_line_plant_number UNIQUE (plant_id, number);
ALTER TABLE tank_group ADD CONSTRAINT uk_tank_group_line_number UNIQUE (line_id, number);
ALTER TABLE tank ADD CONSTRAINT uk_tank_group_number UNIQUE (tank_group_id, number);
```

### 4. **Helper funktiot**
```sql
-- Automaattinen numerointi uusille riveille
get_next_line_number(plant_id)
get_next_tank_group_number(line_id)  
get_next_tank_number(tank_group_id)
```

## 🚀 SUORITUS:

Aja yksinkertainen skripti:
```bash
# DBeaver:ssä tai pgAdmin:issa
add_numbering_system_empty_db.sql
```

## 📋 LOPPUTULOS:

### Numerointi-järjestelmä valmis:
- **Line**: 1, 2, 3... (käyttäjän asettama)
- **Tank Group**: 101, 102, 201, 202... (line * 100 + sequence)
- **Tank**: 101, 102, 103... (parallel tanks same group)

### Ei huolia datasta:
- ❌ Ei tarvitse säilöä vanhaa dataa
- ❌ Ei tarvitse monimutkaista numerolaskentaa
- ❌ Ei tarvitse backup/rollback proseduureja
- ✅ Suora taulurakenteen muutos

## ⚡ SEURAAVAT ASKELEET:

1. Aja `add_numbering_system_empty_db.sql`
2. Aja `enhance_tank_table.sql` (positioning-kentät)
3. Aja `enhance_plant_table.sql` (revision control)
4. Aloita datan syöttäminen oikealla numeroinnilla!

Paljon nopeampi ja yksinkertaisempi! 🎯
