# KORJAUKSET TIETOKANTARAKENTEEN DOKUMENTAATIOON

## 📋 TEHDYT KORJAUKSET

### 1. **Taulun nimi korjattu**
- **Väärä**: `lines` (monikko)
- **Oikea**: `line` (yksikkö)
- **Korjattu**: Kaikki SQL-esimerkit ja viittaukset

### 2. **Sarakkeen nimi korjattu**
- **Nykyinen**: `line_number`
- **Uusi**: `number` (yhtenäisyys `tank_group.number` ja `tank.number` kanssa)
- **Migration**: `ALTER TABLE line RENAME COLUMN line_number TO number`

### 3. **Dokumentaatio päivitetty**
- `database-schema-documentation.md` korjattu vastaamaan todellisuutta
- SQL-esimerkit käyttävät oikeaa taulun nimeä `line`
- Foreign key viittaukset korjattu
- Unique constraints päivitetty

### 4. **Migration-skriptit korjattu**
- `add_numbering_system.sql` - korjattu käyttämään oikeaa taulun nimeä
- `NUMBERING_MIGRATION_GUIDE.md` - päivitetty step-by-step ohje
- Helper-funktiot korjattu

## 🎯 LOPPUTULOS

### Yhtenäinen numerointi-järjestelmä:
```sql
-- Line table (oikea nimi ja sarake)
line.number         -- Fyysinen linjanumero (1, 2, 3...)

-- Tank group table  
tank_group.number   -- Asema-numero (101, 102, 201, 202...)

-- Tank table
tank.number         -- Tankki-numero (101, 102, 103...)
```

### Numerointi-logiikka:
1. **Line**: 1, 2, 3... (käyttäjän asettama)
2. **Tank Group**: line * 100 + sequence (101, 102, 103... tai 201, 202, 203...)
3. **Tank**: Aseman numero + sequence (rinnakkaiset tankit)
4. **Tank Group periytyminen**: MIN(tank numeroista ryhmässä)

## ✅ VALMIUS SUORITUKSEEN

Kaikki skriptit on nyt korjattu vastaamaan todellista tietokannan rakennetta:

1. **`add_numbering_system.sql`** - Täydellinen migration (korjattu)
2. **`NUMBERING_MIGRATION_GUIDE.md`** - Vaiheittainen ohje (korjattu)
3. **`database-schema-documentation.md`** - Ajantasainen dokumentaatio (korjattu)

Voit nyt suorittaa migration-skriptit turvallisesti!
