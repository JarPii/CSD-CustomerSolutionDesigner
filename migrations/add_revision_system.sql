-- Migration: Add revision system to plant table
-- Date: 2025-07-18
-- Description: Implements revision control system for plant configurations

-- 1. Add revision columns to plant table
ALTER TABLE plant 
ADD COLUMN revision integer NOT NULL DEFAULT 1,
ADD COLUMN revision_name varchar(255) DEFAULT 'Initial Design',
ADD COLUMN base_revision_id integer,
ADD COLUMN created_from_revision integer,
ADD COLUMN is_active_revision boolean DEFAULT true,
ADD COLUMN revision_status varchar(20) DEFAULT 'DRAFT',
ADD COLUMN created_by varchar(255);

-- 2. Add foreign key constraint for base_revision_id
ALTER TABLE plant 
ADD CONSTRAINT plant_base_revision_id_fkey 
FOREIGN KEY (base_revision_id) REFERENCES plant(id) ON DELETE SET NULL;

-- 3. Add unique constraints
ALTER TABLE plant 
ADD CONSTRAINT unique_revision_per_plant 
UNIQUE (customer_id, name, revision);

ALTER TABLE plant 
ADD CONSTRAINT unique_active_revision_per_plant 
UNIQUE (customer_id, name, is_active_revision) 
WHERE (is_active_revision = true);

-- 4. Add check constraints
ALTER TABLE plant 
ADD CONSTRAINT check_revision_status 
CHECK (revision_status IN ('DRAFT', 'ACTIVE', 'ARCHIVE'));

ALTER TABLE plant 
ADD CONSTRAINT check_revision_positive 
CHECK (revision > 0);

-- 5. Add indexes for performance
CREATE INDEX idx_plant_revision ON plant(revision);
CREATE INDEX idx_plant_active_revision ON plant(is_active_revision);
CREATE INDEX idx_plant_name_revision ON plant(name, revision);
CREATE INDEX idx_plant_revision_status ON plant(revision_status);

-- 6. Update existing plants to have proper revision data
UPDATE plant SET 
    revision = 1,
    revision_name = 'Initial Design',
    is_active_revision = true,
    revision_status = 'ACTIVE'
WHERE revision IS NULL OR revision = 0;

-- 7. Create function for automatic revision numbering
CREATE OR REPLACE FUNCTION get_next_revision_number(p_customer_id integer, p_name varchar)
RETURNS integer AS $$
DECLARE
    next_revision integer;
BEGIN
    SELECT COALESCE(MAX(revision), 0) + 1 
    INTO next_revision
    FROM plant 
    WHERE customer_id = p_customer_id AND name = p_name;
    
    RETURN next_revision;
END;
$$ LANGUAGE plpgsql;

-- 8. Create function for creating new revision
CREATE OR REPLACE FUNCTION create_new_revision(
    p_customer_id integer,
    p_name varchar,
    p_revision_name varchar DEFAULT 'New Revision',
    p_created_by varchar DEFAULT NULL,
    p_copy_from_revision_id integer DEFAULT NULL
)
RETURNS integer AS $$
DECLARE
    new_plant_id integer;
    next_revision integer;
    source_plant_id integer;
BEGIN
    -- Get next revision number
    next_revision := get_next_revision_number(p_customer_id, p_name);
    
    -- If copying from another revision, get its ID
    IF p_copy_from_revision_id IS NOT NULL THEN
        source_plant_id := p_copy_from_revision_id;
    ELSE
        -- Get the latest revision as source
        SELECT id INTO source_plant_id
        FROM plant 
        WHERE customer_id = p_customer_id AND name = p_name
        ORDER BY revision DESC
        LIMIT 1;
    END IF;
    
    -- Create new plant revision
    INSERT INTO plant (
        customer_id, name, town, country,
        revision, revision_name, base_revision_id, created_from_revision,
        is_active_revision, revision_status, created_by
    )
    SELECT 
        customer_id, name, town, country,
        next_revision, p_revision_name, 
        CASE WHEN revision = 1 THEN id ELSE base_revision_id END,
        source_plant_id,
        false, 'DRAFT', p_created_by
    FROM plant 
    WHERE id = source_plant_id
    RETURNING id INTO new_plant_id;
    
    -- Copy lines if source exists
    IF source_plant_id IS NOT NULL THEN
        INSERT INTO line (plant_id, line_number, min_x, max_x, min_y, max_y)
        SELECT new_plant_id, line_number, min_x, max_x, min_y, max_y
        FROM line WHERE plant_id = source_plant_id;
        
        -- Copy tank groups and tanks would go here
        -- This is a simplified version - full implementation would copy all related data
    END IF;
    
    RETURN new_plant_id;
END;
$$ LANGUAGE plpgsql;

-- 9. Create function for activating revision
CREATE OR REPLACE FUNCTION activate_revision(p_plant_id integer)
RETURNS void AS $$
DECLARE
    plant_customer_id integer;
    plant_name varchar;
BEGIN
    -- Get plant details
    SELECT customer_id, name INTO plant_customer_id, plant_name
    FROM plant WHERE id = p_plant_id;
    
    -- Deactivate current active revision
    UPDATE plant 
    SET is_active_revision = false, revision_status = 'ARCHIVE'
    WHERE customer_id = plant_customer_id 
      AND name = plant_name 
      AND is_active_revision = true;
    
    -- Activate the specified revision
    UPDATE plant 
    SET is_active_revision = true, revision_status = 'ACTIVE'
    WHERE id = p_plant_id;
END;
$$ LANGUAGE plpgsql;

-- Migration complete
-- Remember to update your backend code to handle revision parameters
