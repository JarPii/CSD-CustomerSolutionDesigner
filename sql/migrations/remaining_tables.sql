-- Minimaalinen versio ilman triggereita
-- Luo loput taulut ensin

CREATE TABLE IF NOT EXISTS production_requirements (
    id SERIAL PRIMARY KEY,
    plant_id INTEGER NOT NULL REFERENCES plant(id),
    product_id INTEGER NOT NULL REFERENCES customer_products(id),
    annual_volume INTEGER NOT NULL,
    working_days_per_year INTEGER DEFAULT 250,
    working_hours_per_day DECIMAL(4,2) DEFAULT 8.0,
    shifts_per_day INTEGER DEFAULT 1,
    target_pieces_per_hour DECIMAL(10,2),
    target_cycle_time_minutes DECIMAL(8,2),
    priority_level INTEGER DEFAULT 1,
    notes TEXT,
    status VARCHAR(50) DEFAULT 'draft',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS treatment_programs (
    id SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL REFERENCES customer_products(id),
    program_name VARCHAR(255) NOT NULL,
    estimated_cycle_time_minutes DECIMAL(8,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Indeksit
CREATE INDEX IF NOT EXISTS idx_customer_products_plant_id ON customer_products(plant_id);
CREATE INDEX IF NOT EXISTS idx_production_requirements_plant_id ON production_requirements(plant_id);
CREATE INDEX IF NOT EXISTS idx_production_requirements_product_id ON production_requirements(product_id);
CREATE INDEX IF NOT EXISTS idx_treatment_programs_product_id ON treatment_programs(product_id);
