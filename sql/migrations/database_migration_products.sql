-- Korjattu SQL-skripti vastaamaan nykyistä tietokantarakennetta
-- Huom: Käytä taulun nimiä: customer, plant, line (ei customers, plants, lines)

-- 1. Ensin lisätään puuttuvat sarakkeet olemassa oleviin tauluihin
ALTER TABLE customer ADD COLUMN IF NOT EXISTS town VARCHAR(255);
ALTER TABLE customer ADD COLUMN IF NOT EXISTS country VARCHAR(255);
ALTER TABLE customer ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE customer ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

ALTER TABLE plant ADD COLUMN IF NOT EXISTS town VARCHAR(255);
ALTER TABLE plant ADD COLUMN IF NOT EXISTS country VARCHAR(255);
ALTER TABLE plant ADD COLUMN IF NOT EXISTS created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE plant ADD COLUMN IF NOT EXISTS updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- Lisätään uudet sarakkeet production_requirements tauluun
ALTER TABLE production_requirements ADD COLUMN IF NOT EXISTS batch_size INTEGER DEFAULT 1;
ALTER TABLE production_requirements ADD COLUMN IF NOT EXISTS target_batches_per_hour DECIMAL(10,2);

-- 2. Laitoksen tuotteet
CREATE TABLE IF NOT EXISTS customer_products (
    id SERIAL PRIMARY KEY,
    plant_id INTEGER NOT NULL REFERENCES plant(id),
    product_name VARCHAR(255) NOT NULL,
    product_code VARCHAR(100),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. Tuotantovaatimukset
CREATE TABLE IF NOT EXISTS production_requirements (
    id SERIAL PRIMARY KEY,
    plant_id INTEGER NOT NULL REFERENCES plant(id),
    product_id INTEGER NOT NULL REFERENCES customer_products(id),
    annual_volume INTEGER NOT NULL,
    working_days_per_year INTEGER DEFAULT 250,
    working_hours_per_day DECIMAL(4,2) DEFAULT 8.0,
    shifts_per_day INTEGER DEFAULT 1,
    batch_size INTEGER DEFAULT 1,
    target_pieces_per_hour DECIMAL(10,2),
    target_batches_per_hour DECIMAL(10,2),
    target_cycle_time_minutes DECIMAL(8,2),
    priority_level INTEGER DEFAULT 1,
    notes TEXT,
    status VARCHAR(50) DEFAULT 'draft',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. Käsittelyohjelmat (tulevaisuutta varten)
CREATE TABLE IF NOT EXISTS treatment_programs (
    id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL REFERENCES customer_products(id),
    program_name VARCHAR(255) NOT NULL,
    estimated_cycle_time_minutes DECIMAL(8,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. Trigger-funktio päivitysajan automaattiseen päivittämiseen
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ language 'plpgsql';

-- 6. Triggerit päivitysajan automaattiseen päivittämiseen (jos ei ole jo olemassa)
DROP TRIGGER IF EXISTS update_customer_updated_at ON customer;
CREATE TRIGGER update_customer_updated_at 
    BEFORE UPDATE ON customer 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_plant_updated_at ON plant;
CREATE TRIGGER update_plant_updated_at 
    BEFORE UPDATE ON plant 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_customer_products_updated_at ON customer_products;
CREATE TRIGGER update_customer_products_updated_at 
    BEFORE UPDATE ON customer_products 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_production_requirements_updated_at ON production_requirements;
CREATE TRIGGER update_production_requirements_updated_at 
    BEFORE UPDATE ON production_requirements 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

DROP TRIGGER IF EXISTS update_treatment_programs_updated_at ON treatment_programs;
CREATE TRIGGER update_treatment_programs_updated_at 
    BEFORE UPDATE ON treatment_programs 
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- 7. Indeksit suorituskyvyn parantamiseksi
CREATE INDEX IF NOT EXISTS idx_customer_products_plant_id ON customer_products(plant_id);
CREATE INDEX IF NOT EXISTS idx_production_requirements_plant_id ON production_requirements(plant_id);
CREATE INDEX IF NOT EXISTS idx_production_requirements_product_id ON production_requirements(product_id);
CREATE INDEX IF NOT EXISTS idx_treatment_programs_product_id ON treatment_programs(product_id);
