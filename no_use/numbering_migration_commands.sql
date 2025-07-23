-- NUMBERING SYSTEM MIGRATION - Yksi lause kerrallaan
-- Kopioi ja aja nämä yksi kerrallaan DBeaver:issa tai pgAdmin:issa
-- HUOM: DBeaver-yhteensopivat komennot (ei psql \d komentoja)

-- ===============================
-- VAIHE 1: TARKISTA LÄHTÖTILANNE
-- ===============================

-- 1.1 Tarkista line-taulun rakenne (DBeaver-versio)
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'line'
ORDER BY ordinal_position;

-- ===============================
-- VAIHE 2: SARAKKEEN UUDELLEENNIMEÄMINEN
-- ===============================

-- 2.1 Nimeä line_number → number
ALTER TABLE line RENAME COLUMN line_number TO number;

-- 2.2 Varmista muutos (DBeaver-versio)
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'line' AND column_name = 'number';

-- ===============================
-- VAIHE 3: POISTA VANHAT CONSTRAINTIT
-- ===============================

-- 3.1 Tarkista nykyiset constraintit
SELECT constraint_name, constraint_type 
FROM information_schema.table_constraints 
WHERE table_name = 'line';

-- 3.2 Poista vanha constraint
ALTER TABLE line DROP CONSTRAINT IF EXISTS line_plant_id_line_number_key;

-- ===============================
-- VAIHE 4: LISÄÄ UUDET CONSTRAINTIT
-- ===============================

-- 4.1 Unique constraint numeroille
ALTER TABLE line ADD CONSTRAINT uk_line_plant_number UNIQUE (plant_id, number);

-- 4.2 OHITETAAN name constraint - name-sarake ei ole olemassa line-taulussa
-- ALTER TABLE line ADD CONSTRAINT uk_line_plant_name UNIQUE (plant_id, name); -- SKIP

-- 4.3 Varmista constraintit
SELECT constraint_name, constraint_type 
FROM information_schema.table_constraints 
WHERE table_name = 'line' AND constraint_type = 'UNIQUE';

-- ===============================
-- VAIHE 5: TANK_GROUP NOT NULL
-- ===============================

-- 5.1 Tarkista tank_group.number
SELECT column_name, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'tank_group' AND column_name = 'number';

-- 5.2 Tee pakolliseksi
ALTER TABLE tank_group ALTER COLUMN number SET NOT NULL;

-- 5.3 Varmista
SELECT column_name, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'tank_group' AND column_name = 'number';

-- ===============================
-- VAIHE 6: TANK NOT NULL
-- ===============================

-- 6.1 Tarkista tank.number
SELECT column_name, is_nullable 
FROM information_schema.columns 
WHERE table_name = 'tank' AND column_name = 'number';

-- 6.2 Tee pakolliseksi
ALTER TABLE tank ALTER COLUMN number SET NOT NULL;

-- ===============================
-- VAIHE 7: TANK_GROUP JA TANK CONSTRAINTIT
-- ===============================

-- 7.1 Tank_group unique constraint
ALTER TABLE tank_group ADD CONSTRAINT uk_tank_group_line_number UNIQUE (line_id, number);

-- 7.2 Tank unique constraint
ALTER TABLE tank ADD CONSTRAINT uk_tank_group_number UNIQUE (tank_group_id, number);

-- ===============================
-- VAIHE 8: LOPULLINEN TARKISTUS
-- ===============================

-- 8.1 Kaikki constraintit
SELECT table_name, constraint_name, constraint_type 
FROM information_schema.table_constraints 
WHERE table_name IN ('line', 'tank_group', 'tank') 
  AND constraint_type = 'UNIQUE'
ORDER BY table_name, constraint_name;

-- 8.2 Kaikki number-sarakkeet
SELECT 
    table_name, 
    column_name, 
    is_nullable, 
    data_type 
FROM information_schema.columns 
WHERE table_name IN ('line', 'tank_group', 'tank') 
  AND column_name = 'number'
ORDER BY table_name;

-- ===============================
-- ONNISTUMISVIESTIN PITÄISI NÄYTTÄÄ:
-- ===============================
-- line        | number | NO   | integer
-- tank        | number | NO   | integer  
-- tank_group  | number | NO   | integer
--
-- Ja 3 UNIQUE constraintia yhteensä (EI line.name constraintia)
-- uk_line_plant_number, uk_tank_group_line_number, uk_tank_group_number
-- ===============================
