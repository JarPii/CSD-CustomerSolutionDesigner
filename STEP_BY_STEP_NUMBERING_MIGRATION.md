# STEP-BY-STEP MIGRATION - Yksi SQL-lause kerrallaan

## 🛡️ TURVALLINEN LÄHESTYMISTAPA

Koska aikaisemmat yritykset ovat jääneet jumiin, edetään **yksi SQL-lause kerrallaan** ja tarkistetaan tulos ennen seuraavaa.

## 📋 VAIHE 1: SARAKKEEN UUDELLEENNIMEÄMINEN

### Askel 1.1: Tarkista nykyinen tilanne
```sql
-- Tarkista line-taulun rakenne
\d line;
```
**Odotettu tulos**: Näet `line_number` sarakkeen listassa

### Askel 1.2: Nimeä sarake uudelleen
```sql
ALTER TABLE line RENAME COLUMN line_number TO number;
```
**Odotettu tulos**: "ALTER TABLE" vastaus

### Askel 1.3: Varmista muutos
```sql
\d line;
```
**Odotettu tulos**: Näet `number` sarakkeen (ei enää `line_number`)

## 📋 VAIHE 2: POISTA VANHAT RAJOITTEET

### Askel 2.1: Tarkista nykyiset rajoitteet
```sql
SELECT constraint_name, constraint_type 
FROM information_schema.table_constraints 
WHERE table_name = 'line';
```
**Odotettu tulos**: Lista nykyisistä constrainteista

### Askel 2.2: Poista vanha unique constraint (jos on)
```sql
ALTER TABLE line DROP CONSTRAINT IF EXISTS line_plant_id_line_number_key;
```
**Odotettu tulos**: "ALTER TABLE" vastaus (tai "NOTICE: constraint does not exist")

## 📋 VAIHE 3: LISÄÄ UUDET RAJOITTEET

### Askel 3.1: Lisää unique constraint numeroille
```sql
ALTER TABLE line ADD CONSTRAINT uk_line_plant_number UNIQUE (plant_id, number);
```
**Odotettu tulos**: "ALTER TABLE" vastaus

### Askel 3.2: Lisää unique constraint nimille
```sql
ALTER TABLE line ADD CONSTRAINT uk_line_plant_name UNIQUE (plant_id, name);
```
**Odotettu tulos**: "ALTER TABLE" vastaus

### Askel 3.3: Varmista constraintit
```sql
SELECT constraint_name, constraint_type 
FROM information_schema.table_constraints 
WHERE table_name = 'line' AND constraint_type = 'UNIQUE';
```
**Odotettu tulos**: 2 UNIQUE constraintia (`uk_line_plant_number`, `uk_line_plant_name`)

## 📋 VAIHE 4: TANK_GROUP TAULUN KORJAUS

### Askel 4.1: Tarkista tank_group.number sarake
```sql
SELECT column_name, is_nullable, data_type 
FROM information_schema.columns 
WHERE table_name = 'tank_group' AND column_name = 'number';
```
**Odotettu tulos**: `is_nullable = YES` (koska se ei ole vielä NOT NULL)

### Askel 4.2: Tee tank_group.number pakolliseksi
```sql
ALTER TABLE tank_group ALTER COLUMN number SET NOT NULL;
```
**Odotettu tulos**: "ALTER TABLE" vastaus

### Askel 4.3: Varmista muutos
```sql
SELECT column_name, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'tank_group' AND column_name = 'number';
```
**Odotettu tulos**: `is_nullable = NO`

## 📋 VAIHE 5: TANK TAULUN KORJAUS

### Askel 5.1: Tarkista tank.number sarake
```sql
SELECT column_name, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'tank' AND column_name = 'number';
```

### Askel 5.2: Tee tank.number pakolliseksi
```sql
ALTER TABLE tank ALTER COLUMN number SET NOT NULL;
```
**Odotettu tulos**: "ALTER TABLE" vastaus

## 📋 VAIHE 6: UNIQUE CONSTRAINTIT TANK_GROUP JA TANK

### Askel 6.1: Lisää tank_group unique constraint
```sql
ALTER TABLE tank_group ADD CONSTRAINT uk_tank_group_line_number UNIQUE (line_id, number);
```
**Odotettu tulos**: "ALTER TABLE" vastaus

### Askel 6.2: Lisää tank unique constraint
```sql
ALTER TABLE tank ADD CONSTRAINT uk_tank_group_number UNIQUE (tank_group_id, number);
```
**Odotettu tulos**: "ALTER TABLE" vastaus

## 📋 VAIHE 7: TARKISTA LOPPUTULOS

### Askel 7.1: Tarkista kaikki constraintit
```sql
SELECT table_name, constraint_name, constraint_type 
FROM information_schema.table_constraints 
WHERE table_name IN ('line', 'tank_group', 'tank') 
  AND constraint_type = 'UNIQUE'
ORDER BY table_name, constraint_name;
```
**Odotettu tulos**: 4 UNIQUE constraintia yhteensä

### Askel 7.2: Tarkista sarakkeiden tilanne
```sql
SELECT 
    table_name, 
    column_name, 
    is_nullable, 
    data_type 
FROM information_schema.columns 
WHERE table_name IN ('line', 'tank_group', 'tank') 
  AND column_name = 'number'
ORDER BY table_name;
```
**Odotettu tulos**: Kaikki `number` sarakkeet ovat `NOT NULL`

## 🚨 MITÄ TEHDÄ JOS JOKIN MENEE PIELEEN:

### Jos saat virheen:
1. **KOPIOI VIRHEVIESTI** kokonaan
2. **ÄLÄN JATKA** seuraavaan askeleeseen
3. **KYSY APUA** ennen jatkamista

### Jos constraint-virhe:
```sql
-- Tarkista onko ristiriitaista dataa
SELECT plant_id, number, COUNT(*) 
FROM line 
GROUP BY plant_id, number 
HAVING COUNT(*) > 1;
```

### Jos tietokanta jumittaa:
- Sulje yhteys ja avaa uudelleen
- Tarkista onko transaktio keskeneräinen

## ✅ KUN KAIKKI ON VALMIS:

Migration on valmis ja voit jatkaa seuraaviin vaiheisiin (tank enhancement, plant enhancement).
