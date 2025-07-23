-- Migration Script: Add Revision Control System to Plants Table
-- This script adds revision control functionality to the existing plants table
-- Run this script on the Azure PostgreSQL database

-- First, create a backup of the existing plants table
CREATE TABLE plants_backup AS SELECT * FROM plants;

-- Add revision control columns to the plants table
ALTER TABLE plants 
ADD COLUMN revision INTEGER NOT NULL DEFAULT 1,
ADD COLUMN revision_name VARCHAR(255),
ADD COLUMN base_revision_id INTEGER REFERENCES plants(id),
ADD COLUMN created_from_revision INTEGER,
ADD COLUMN is_active_revision BOOLEAN NOT NULL DEFAULT TRUE,
ADD COLUMN revision_status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' 
    CHECK (revision_status IN ('DRAFT', 'ACTIVE', 'ARCHIVED')),
ADD COLUMN created_by VARCHAR(255) NOT NULL DEFAULT 'system',
ADD COLUMN archived_at TIMESTAMP;

-- Add unique constraint for revision system
ALTER TABLE plants 
ADD CONSTRAINT unique_customer_plant_revision 
UNIQUE(customer_id, name, revision);

-- Create indexes for performance
CREATE INDEX idx_plants_active_revision ON plants(customer_id, name, is_active_revision);
CREATE INDEX idx_plants_revision_status ON plants(revision_status);
CREATE INDEX idx_plants_base_revision ON plants(base_revision_id);
CREATE INDEX idx_plants_customer_name ON plants(customer_id, name);

-- Update existing plants to have proper revision values
UPDATE plants SET 
    revision = 1,
    revision_name = 'Initial revision',
    is_active_revision = TRUE,
    revision_status = 'ACTIVE',
    created_by = 'system'
WHERE revision IS NULL OR revision = 0;

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

-- Verification queries (these will be run at the end to confirm success)
-- SELECT COUNT(*) FROM plants WHERE revision IS NULL;
-- SELECT COUNT(*) FROM plants WHERE revision_status NOT IN ('DRAFT', 'ACTIVE', 'ARCHIVED');
-- SELECT proname FROM pg_proc WHERE proname IN ('get_next_revision_number', 'create_new_revision', 'activate_revision');
