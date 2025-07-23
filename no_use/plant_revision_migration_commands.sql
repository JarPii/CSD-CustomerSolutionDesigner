-- PLANT REVISION SYSTEM MIGRATION - Yksi lause kerrallaan
-- Kopioi ja aja nämä yksi kerrallaan DBeaver:issa tai pgAdmin:issa
-- HUOM: DBeaver-yhteensopivat komennot (ei psql \d komentoja)

-- ===============================
-- VAIHE 1: TARKISTA LÄHTÖTILANNE
-- ===============================

-- 1.1 Tarkista plant-taulun rakenne (DBeaver-versio)
SELECT column_name, data_type, is_nullable, column_default
FROM information_schema.columns 
WHERE table_name = 'plant'
ORDER BY ordinal_position;

-- 1.2 Tarkista nykyiset constraintit
SELECT constraint_name, constraint_type 
FROM information_schema.table_constraints 
WHERE table_name = 'plant';

-- 1.3 Tarkista nykyinen data määrä
SELECT COUNT(*) as plant_count FROM plant;

-- ===============================
-- VAIHE 2: VARMUUSKOPIO
-- ===============================

-- 2.1 Luo varmuuskopio (DROP IF EXISTS turvallisuuden vuoksi)
DROP TABLE IF EXISTS plant_backup;

-- 2.2 Luo varmuuskopio
CREATE TABLE plant_backup AS SELECT * FROM plant;

-- 2.3 Varmista varmuuskopio
SELECT COUNT(*) as backup_count FROM plant_backup;

-- ===============================
-- VAIHE 3: LISÄÄ REVISION SARAKKEET
-- ===============================

-- 3.1 Lisää revision sarake
ALTER TABLE plant ADD COLUMN revision INTEGER;

-- 3.2 Lisää revision_name sarake
ALTER TABLE plant ADD COLUMN revision_name VARCHAR(255);

-- 3.3 Lisää base_revision_id sarake (viittaus toiseen plantiin)
ALTER TABLE plant ADD COLUMN base_revision_id INTEGER;

-- 3.4 Lisää created_from_revision sarake
ALTER TABLE plant ADD COLUMN created_from_revision INTEGER;

-- 3.5 Lisää is_active_revision sarake
ALTER TABLE plant ADD COLUMN is_active_revision BOOLEAN;

-- 3.6 Lisää revision_status sarake
ALTER TABLE plant ADD COLUMN revision_status VARCHAR(20);

-- 3.7 Lisää created_by sarake
ALTER TABLE plant ADD COLUMN created_by VARCHAR(255);

-- 3.8 Lisää archived_at sarake
ALTER TABLE plant ADD COLUMN archived_at TIMESTAMP;

-- 3.9 Tarkista lisätyt sarakkeet
SELECT column_name, data_type, is_nullable
FROM information_schema.columns 
WHERE table_name = 'plant' 
  AND column_name IN ('revision', 'revision_name', 'base_revision_id', 'created_from_revision', 
                      'is_active_revision', 'revision_status', 'created_by', 'archived_at')
ORDER BY column_name;

-- ===============================
-- VAIHE 4: ASETA DEFAULT ARVOT
-- ===============================

-- 4.1 Aseta revision default arvo
ALTER TABLE plant ALTER COLUMN revision SET DEFAULT 1;

-- 4.2 Aseta is_active_revision default arvo
ALTER TABLE plant ALTER COLUMN is_active_revision SET DEFAULT TRUE;

-- 4.3 Aseta revision_status default arvo
ALTER TABLE plant ALTER COLUMN revision_status SET DEFAULT 'ACTIVE';

-- 4.4 Aseta created_by default arvo
ALTER TABLE plant ALTER COLUMN created_by SET DEFAULT 'system';

-- ===============================
-- VAIHE 5: PÄIVITÄ OLEMASSA OLEVA DATA
-- ===============================

-- 5.1 Päivitä revision arvot olemassa olevalle datalle
UPDATE plant SET 
    revision = 1
WHERE revision IS NULL;

-- 5.2 Päivitä revision_name arvot
UPDATE plant SET 
    revision_name = 'Initial revision'
WHERE revision_name IS NULL;

-- 5.3 Päivitä is_active_revision arvot
UPDATE plant SET 
    is_active_revision = TRUE
WHERE is_active_revision IS NULL;

-- 5.4 Päivitä revision_status arvot
UPDATE plant SET 
    revision_status = 'ACTIVE'
WHERE revision_status IS NULL;

-- 5.5 Päivitä created_by arvot
UPDATE plant SET 
    created_by = 'system'
WHERE created_by IS NULL;

-- 5.6 Tarkista päivitykset
SELECT 
    COUNT(*) as total_plant,
    COUNT(CASE WHEN revision IS NOT NULL THEN 1 END) as has_revision,
    COUNT(CASE WHEN is_active_revision = TRUE THEN 1 END) as active_revisions
FROM plant;

-- ===============================
-- VAIHE 6: ASETA NOT NULL PAKOT
-- ===============================

-- 6.1 Tee revision pakolliseksi
ALTER TABLE plant ALTER COLUMN revision SET NOT NULL;

-- 6.2 Tee is_active_revision pakolliseksi
ALTER TABLE plant ALTER COLUMN is_active_revision SET NOT NULL;

-- 6.3 Tee revision_status pakolliseksi
ALTER TABLE plant ALTER COLUMN revision_status SET NOT NULL;

-- 6.4 Tee created_by pakolliseksi
ALTER TABLE plant ALTER COLUMN created_by SET NOT NULL;

-- 6.5 Varmista NOT NULL pakot
SELECT column_name, is_nullable
FROM information_schema.columns 
WHERE table_name = 'plant' 
  AND column_name IN ('revision', 'is_active_revision', 'revision_status', 'created_by')
ORDER BY column_name;

-- ===============================
-- VAIHE 7: LISÄÄ CHECK CONSTRAINTS
-- ===============================

-- 7.1 Lisää revision_status check constraint
ALTER TABLE plant 
ADD CONSTRAINT chk_plant_revision_status 
CHECK (revision_status IN ('DRAFT', 'ACTIVE', 'ARCHIVED'));

-- 7.2 Varmista check constraint
SELECT constraint_name, check_clause
FROM information_schema.check_constraints 
WHERE constraint_name = 'chk_plant_revision_status';

-- ===============================
-- VAIHE 8: LISÄÄ FOREIGN KEY
-- ===============================

-- 8.1 Lisää foreign key base_revision_id -> plant(id)
ALTER TABLE plant 
ADD CONSTRAINT fk_plant_base_revision 
FOREIGN KEY (base_revision_id) REFERENCES plant(id);

-- 8.2 Varmista foreign key
SELECT constraint_name, constraint_type
FROM information_schema.table_constraints 
WHERE table_name = 'plant' AND constraint_name = 'fk_plant_base_revision';

-- ===============================
-- VAIHE 9: LISÄÄ UNIQUE CONSTRAINTS
-- ===============================

-- 9.1 Lisää unique constraint: customer + name + revision
ALTER TABLE plant 
ADD CONSTRAINT uk_plant_customer_name_revision 
UNIQUE (customer_id, name, revision);

-- 9.2 Varmista unique constraint
SELECT constraint_name, constraint_type
FROM information_schema.table_constraints 
WHERE table_name = 'plant' AND constraint_name = 'uk_plant_customer_name_revision';

-- ===============================
-- VAIHE 10: LUO INDEKSIT
-- ===============================

-- 10.1 Indeksi aktiivisille revisioille
CREATE INDEX idx_plant_active_revision ON plant(customer_id, name, is_active_revision);

-- 10.2 Indeksi revision statusille
CREATE INDEX idx_plant_revision_status ON plant(revision_status);

-- 10.3 Indeksi base revision viittauksille
CREATE INDEX idx_plant_base_revision ON plant(base_revision_id);

-- 10.4 Indeksi customer + name hauille
CREATE INDEX idx_plant_customer_name ON plant(customer_id, name);

-- 10.5 Tarkista luodut indeksit
SELECT indexname, tablename 
FROM pg_indexes 
WHERE tablename = 'plant' 
  AND indexname LIKE 'idx_plant_%'
ORDER BY indexname;

-- ===============================
-- VAIHE 11: LOPULLINEN TARKISTUS
-- ===============================

-- 11.1 Kaikki revision sarakkeet
SELECT 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'plant' 
  AND column_name IN ('revision', 'revision_name', 'base_revision_id', 'created_from_revision',
                      'is_active_revision', 'revision_status', 'created_by', 'archived_at')
ORDER BY column_name;

-- 11.2 Kaikki constraintit
SELECT constraint_name, constraint_type 
FROM information_schema.table_constraints 
WHERE table_name = 'plant'
ORDER BY constraint_type, constraint_name;

-- 11.3 Data consistency tarkistus
SELECT 
    COUNT(*) as total_plant,
    COUNT(CASE WHEN revision_status = 'ACTIVE' THEN 1 END) as active_plant,
    COUNT(CASE WHEN is_active_revision = TRUE THEN 1 END) as active_revisions,
    COUNT(CASE WHEN revision IS NULL THEN 1 END) as null_revisions
FROM plant;

-- ===============================
-- ONNISTUMISVIESTIN PITÄISI NÄYTTÄÄ:
-- ===============================
-- 8 uutta saraketta lisätty:
-- - revision (integer, NOT NULL, DEFAULT 1)
-- - revision_name (varchar(255), nullable)
-- - base_revision_id (integer, nullable, FK to plant.id)
-- - created_from_revision (integer, nullable)
-- - is_active_revision (boolean, NOT NULL, DEFAULT TRUE)
-- - revision_status (varchar(20), NOT NULL, DEFAULT 'ACTIVE', CHECK constraint)
-- - created_by (varchar(255), NOT NULL, DEFAULT 'system')
-- - archived_at (timestamp, nullable)
--
-- Constraintit:
-- - uk_plant_customer_name_revision (UNIQUE)
-- - fk_plant_base_revision (FOREIGN KEY)
-- - chk_plant_revision_status (CHECK)
--
-- 4 uutta indeksiä luotu
-- Kaikki olemassa oleva data päivitetty revision = 1, status = 'ACTIVE'
-- ===============================
