-- Database Schema Creation Script
-- Creates all tables for STL Plant Management System with revision control
-- Run this on empty Azure PostgreSQL database

-- Create customers table
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    email VARCHAR(255),
    phone VARCHAR(50),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create plants table with revision control system
CREATE TABLE plants (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    town VARCHAR(255),
    country VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Revision Control Fields
    revision INTEGER NOT NULL DEFAULT 1,
    revision_name VARCHAR(255),
    base_revision_id INTEGER REFERENCES plants(id),
    created_from_revision INTEGER,
    is_active_revision BOOLEAN NOT NULL DEFAULT TRUE,
    revision_status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' 
        CHECK (revision_status IN ('DRAFT', 'ACTIVE', 'ARCHIVED')),
    created_by VARCHAR(255) NOT NULL DEFAULT 'system',
    archived_at TIMESTAMP,
    
    -- Unique constraints for revision system
    UNIQUE(customer_id, name, revision)
);

-- Create lines table
CREATE TABLE lines (
    id SERIAL PRIMARY KEY,
    plant_id INTEGER NOT NULL REFERENCES plants(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(plant_id, name)
);

-- Create tanks table
CREATE TABLE tanks (
    id SERIAL PRIMARY KEY,
    line_id INTEGER NOT NULL REFERENCES lines(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    x_position DECIMAL(10,2) DEFAULT 0,
    y_position DECIMAL(10,2) DEFAULT 0,
    width DECIMAL(10,2) DEFAULT 100,
    height DECIMAL(10,2) DEFAULT 100,
    tank_type VARCHAR(50) DEFAULT 'storage',
    color VARCHAR(7) DEFAULT '#3498db',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(line_id, name)
);

-- Create indexes for performance
CREATE INDEX idx_plants_active_revision ON plants(customer_id, name, is_active_revision);
CREATE INDEX idx_plants_revision_status ON plants(revision_status);
CREATE INDEX idx_plants_base_revision ON plants(base_revision_id);
CREATE INDEX idx_plants_customer_name ON plants(customer_id, name);
CREATE INDEX idx_lines_plant_id ON lines(plant_id);
CREATE INDEX idx_tanks_line_id ON tanks(line_id);
CREATE INDEX idx_customers_name ON customers(name);

-- Function: Get next revision number for a plant
CREATE OR REPLACE FUNCTION get_next_revision_number(p_customer_id INTEGER, p_plant_name VARCHAR)
RETURNS INTEGER AS $$
DECLARE
    next_rev INTEGER;
BEGIN
    SELECT COALESCE(MAX(revision), 0) + 1 
    INTO next_rev
    FROM plants 
    WHERE customer_id = p_customer_id AND name = p_plant_name;
    
    RETURN next_rev;
END;
$$ LANGUAGE plpgsql;

-- Function: Create new revision from existing plant
CREATE OR REPLACE FUNCTION create_new_revision(
    p_source_plant_id INTEGER,
    p_revision_name VARCHAR DEFAULT NULL,
    p_created_by VARCHAR DEFAULT 'system'
) RETURNS INTEGER AS $$
DECLARE
    source_plant RECORD;
    new_plant_id INTEGER;
    next_rev INTEGER;
BEGIN
    -- Get source plant details
    SELECT * INTO source_plant FROM plants WHERE id = p_source_plant_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Source plant not found: %', p_source_plant_id;
    END IF;
    
    -- Get next revision number
    next_rev := get_next_revision_number(source_plant.customer_id, source_plant.name);
    
    -- Create new revision
    INSERT INTO plants (
        customer_id, name, town, country,
        revision, revision_name, base_revision_id, created_from_revision,
        is_active_revision, revision_status, created_by
    ) VALUES (
        source_plant.customer_id, source_plant.name, source_plant.town, source_plant.country,
        next_rev, COALESCE(p_revision_name, 'Revision ' || next_rev), 
        p_source_plant_id, source_plant.revision,
        FALSE, 'DRAFT', p_created_by
    ) RETURNING id INTO new_plant_id;
    
    RETURN new_plant_id;
END;
$$ LANGUAGE plpgsql;

-- Function: Activate a revision (make it the active version)
CREATE OR REPLACE FUNCTION activate_revision(p_plant_id INTEGER) 
RETURNS BOOLEAN AS $$
DECLARE
    target_plant RECORD;
    current_active_id INTEGER;
BEGIN
    -- Get target plant details
    SELECT * INTO target_plant FROM plants WHERE id = p_plant_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Plant not found: %', p_plant_id;
    END IF;
    
    IF target_plant.revision_status = 'ACTIVE' THEN
        RETURN TRUE; -- Already active
    END IF;
    
    IF target_plant.revision_status = 'ARCHIVED' THEN
        RAISE EXCEPTION 'Cannot activate archived revision';
    END IF;
    
    -- Find current active revision
    SELECT id INTO current_active_id 
    FROM plants 
    WHERE customer_id = target_plant.customer_id 
      AND name = target_plant.name 
      AND is_active_revision = TRUE;
    
    -- Deactivate current active revision
    IF current_active_id IS NOT NULL THEN
        UPDATE plants 
        SET is_active_revision = FALSE, 
            revision_status = 'ARCHIVED',
            archived_at = CURRENT_TIMESTAMP
        WHERE id = current_active_id;
    END IF;
    
    -- Activate target revision
    UPDATE plants 
    SET is_active_revision = TRUE, 
        revision_status = 'ACTIVE'
    WHERE id = p_plant_id;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Insert sample data for testing
INSERT INTO customers (name, email, phone, address) VALUES 
('John Cockerill Group', 'contact@johncockerill.com', '+32-4-330-2111', 'Rue de la Fusée 64, 1130 Brussels, Belgium'),
('ArcelorMittal', 'info@arcelormittal.com', '+352-4792-1', '24-26 Boulevard d''Avranches, L-1160 Luxembourg'),
('Outotec', 'info@outotec.com', '+358-20-529-211', 'Rauhalanpuisto 9, 02230 Espoo, Finland');

-- Insert sample plants
INSERT INTO plants (customer_id, name, town, country, revision_name) VALUES 
(1, 'Liège Steel Plant', 'Liège', 'Belgium', 'Initial configuration'),
(1, 'Seraing Works', 'Seraing', 'Belgium', 'Initial configuration'),
(2, 'Ghent Steel Works', 'Ghent', 'Belgium', 'Initial configuration'),
(3, 'Kokkola Zinc Plant', 'Kokkola', 'Finland', 'Initial configuration');

-- Insert sample lines
INSERT INTO lines (plant_id, name) VALUES 
(1, 'Hot Rolling Line 1'),
(1, 'Cold Rolling Line 1'),
(2, 'Blast Furnace Line'),
(3, 'Pickling Line'),
(4, 'Zinc Roasting Line');

-- Insert sample tanks
INSERT INTO tanks (line_id, name, x_position, y_position, width, height, tank_type, color) VALUES 
(1, 'Heating Tank A1', 100, 100, 120, 80, 'heating', '#e74c3c'),
(1, 'Cooling Tank A2', 250, 100, 120, 80, 'cooling', '#3498db'),
(1, 'Storage Tank A3', 400, 100, 100, 100, 'storage', '#95a5a6'),
(2, 'Pickling Tank B1', 100, 250, 150, 90, 'pickling', '#f39c12'),
(2, 'Rinse Tank B2', 280, 250, 120, 80, 'rinse', '#1abc9c'),
(3, 'Iron Tank C1', 150, 400, 140, 100, 'storage', '#8e44ad'),
(4, 'Acid Tank D1', 100, 550, 130, 85, 'acid', '#e67e22'),
(5, 'Roasting Tank E1', 200, 700, 160, 110, 'roasting', '#c0392b');

-- Verification queries
SELECT 'Database schema created successfully!' as status;
SELECT COUNT(*) as customer_count FROM customers;
SELECT COUNT(*) as plant_count FROM plants;
SELECT COUNT(*) as line_count FROM lines;
SELECT COUNT(*) as tank_count FROM tanks;
