-- ================================================================
-- PLANT TABLE ENHANCEMENT SCRIPT
-- ================================================================
-- Adds revision control fields to plant table as specified in documentation
-- This brings plant table to match the documented specification
-- 
-- EXECUTE THESE STATEMENTS ONE BY ONE IN DBeaver/pgAdmin
-- Always backup before running migrations!

-- ================================================================
-- STEP 1: Add revision control fields (grouped logically)
-- ================================================================

-- Basic revision info
ALTER TABLE plant 
ADD COLUMN revision INTEGER NOT NULL DEFAULT 1;

ALTER TABLE plant 
ADD COLUMN revision_name VARCHAR(255);

-- Revision relationships
ALTER TABLE plant 
ADD COLUMN base_revision_id INTEGER REFERENCES plant(id);

ALTER TABLE plant 
ADD COLUMN created_from_revision INTEGER;

-- Revision status and control
ALTER TABLE plant 
ADD COLUMN is_active_revision BOOLEAN NOT NULL DEFAULT TRUE;

ALTER TABLE plant 
ADD COLUMN revision_status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' 
CHECK (revision_status IN ('DRAFT', 'ACTIVE', 'ARCHIVED'));

-- Revision metadata
ALTER TABLE plant 
ADD COLUMN created_by VARCHAR(255) NOT NULL DEFAULT 'system';

ALTER TABLE plant 
ADD COLUMN archived_at TIMESTAMP;

-- ================================================================
-- STEP 2: Create indexes for performance
-- ================================================================

-- Index for active revision queries (most common)
CREATE INDEX idx_plant_active_revision ON plant(customer_id, name, is_active_revision);

-- Index for revision status
CREATE INDEX idx_plant_revision_status ON plant(revision_status);

-- Index for base revision lookups
CREATE INDEX idx_plant_base_revision ON plant(base_revision_id);

-- Index for customer-name combination
CREATE INDEX idx_plant_customer_name ON plant(customer_id, name);

-- ================================================================
-- STEP 3: Add unique constraints for revision system
-- ================================================================

-- Ensure unique revision numbers per plant name within customer
ALTER TABLE plant 
ADD CONSTRAINT uq_plant_revision 
UNIQUE(customer_id, name, revision);

-- ================================================================
-- STEP 4: Update existing data with default values
-- ================================================================

-- Set default revision information for existing plants
UPDATE plant 
SET 
    revision_name = 'Initial configuration',
    created_by = 'migration_script'
WHERE revision_name IS NULL;

-- ================================================================
-- STEP 5: Add check constraints for data integrity
-- ================================================================

-- Ensure revision number is positive
ALTER TABLE plant 
ADD CONSTRAINT chk_plant_revision_positive 
CHECK (revision > 0);

-- Ensure valid revision status
-- (Already added in ALTER TABLE above, but documenting here)

-- ================================================================
-- STEP 6: Create functions for revision management
-- ================================================================

-- Function: Get next revision number for a plant
CREATE OR REPLACE FUNCTION get_next_plant_revision_number(
    p_customer_id INTEGER, 
    p_plant_name VARCHAR
) RETURNS INTEGER AS $$
DECLARE
    next_rev INTEGER;
BEGIN
    SELECT COALESCE(MAX(revision), 0) + 1 
    INTO next_rev
    FROM plant 
    WHERE customer_id = p_customer_id AND name = p_plant_name;
    
    RETURN next_rev;
END;
$$ LANGUAGE plpgsql;

-- Function: Create new plant revision
CREATE OR REPLACE FUNCTION create_new_plant_revision(
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
    SELECT * INTO source_plant FROM plant WHERE id = p_source_plant_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Source plant not found: %', p_source_plant_id;
    END IF;
    
    -- Get next revision number
    next_rev := get_next_plant_revision_number(source_plant.customer_id, source_plant.name);
    
    -- Create new revision (copy all fields except id and revision info)
    -- Logical field order: core properties, location, revision control, relationships
    INSERT INTO plant (
        -- Core properties
        name, 
        -- Location
        town, country,
        -- Revision control
        revision, revision_name, base_revision_id, created_from_revision,
        is_active_revision, revision_status, created_by,
        -- Relationships
        customer_id
    ) VALUES (
        -- Core properties
        source_plant.name,
        -- Location
        source_plant.town, source_plant.country,
        -- Revision control
        next_rev, COALESCE(p_revision_name, 'Revision ' || next_rev),
        p_source_plant_id, source_plant.revision,
        FALSE, 'DRAFT', p_created_by,
        -- Relationships
        source_plant.customer_id
    ) RETURNING id INTO new_plant_id;
    
    RETURN new_plant_id;
END;
$$ LANGUAGE plpgsql;

-- Function: Activate plant revision
CREATE OR REPLACE FUNCTION activate_plant_revision(p_plant_id INTEGER) 
RETURNS BOOLEAN AS $$
DECLARE
    target_plant RECORD;
    current_active_id INTEGER;
BEGIN
    -- Get target plant details
    SELECT * INTO target_plant FROM plant WHERE id = p_plant_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Plant not found: %', p_plant_id;
    END IF;
    
    IF target_plant.revision_status = 'ACTIVE' THEN
        RETURN TRUE; -- Already active
    END IF;
    
    IF target_plant.revision_status = 'ARCHIVED' THEN
        RAISE EXCEPTION 'Cannot activate archived revision';
    END IF;
    
    -- Find current active revision for this plant name
    SELECT id INTO current_active_id 
    FROM plant 
    WHERE customer_id = target_plant.customer_id 
      AND name = target_plant.name 
      AND is_active_revision = TRUE;
    
    -- Deactivate current active revision
    IF current_active_id IS NOT NULL THEN
        UPDATE plant 
        SET is_active_revision = FALSE, 
            revision_status = 'ARCHIVED',
            archived_at = CURRENT_TIMESTAMP
        WHERE id = current_active_id;
    END IF;
    
    -- Activate target revision
    UPDATE plant 
    SET is_active_revision = TRUE, 
        revision_status = 'ACTIVE'
    WHERE id = p_plant_id;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- Function: Get active plant revision
CREATE OR REPLACE FUNCTION get_active_plant_revision(
    p_customer_id INTEGER,
    p_plant_name VARCHAR
) RETURNS INTEGER AS $$
DECLARE
    active_plant_id INTEGER;
BEGIN
    SELECT id INTO active_plant_id
    FROM plant 
    WHERE customer_id = p_customer_id 
      AND name = p_plant_name 
      AND is_active_revision = TRUE;
    
    RETURN active_plant_id;
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- STEP 7: Create triggers for automatic timestamp updates
-- ================================================================

-- Function for updating timestamps
CREATE OR REPLACE FUNCTION update_plant_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger for plant table
DROP TRIGGER IF EXISTS tr_plant_update_timestamp ON plant;
CREATE TRIGGER tr_plant_update_timestamp
    BEFORE UPDATE ON plant
    FOR EACH ROW
    EXECUTE FUNCTION update_plant_timestamp();

-- ================================================================
-- STEP 8: Verification queries
-- ================================================================

-- Check that all plants have revision data
SELECT 'Plant revision data check' as test_name, 
       COUNT(*) as total_plants,
       COUNT(*) FILTER (WHERE revision IS NOT NULL) as plants_with_revision,
       COUNT(*) FILTER (WHERE is_active_revision = TRUE) as active_revisions,
       COUNT(*) FILTER (WHERE revision_status = 'ACTIVE') as status_active
FROM plant;

-- Check for potential duplicate active revisions (should be 0)
SELECT 'Duplicate active revisions check' as test_name,
       COUNT(*) as duplicate_active_count
FROM (
    SELECT customer_id, name, COUNT(*) as active_count
    FROM plant 
    WHERE is_active_revision = TRUE
    GROUP BY customer_id, name
    HAVING COUNT(*) > 1
) duplicates;

-- Show sample of enhanced plant data (logical column order)
SELECT 
    -- Core identification
    id, name,
    -- Location
    town, country,
    -- Revision control
    revision, revision_status, is_active_revision, revision_name,
    -- Metadata
    created_by, created_at, updated_at,
    -- Relationships
    customer_id
FROM plant 
ORDER BY customer_id, name, revision DESC
LIMIT 10;

-- Show revision hierarchy for plants
SELECT 
    p.name as plant_name,
    p.revision,
    p.revision_name,
    p.revision_status,
    p.is_active_revision,
    bp.revision as base_revision,
    p.created_from_revision,
    c.name as customer_name
FROM plant p
LEFT JOIN plant bp ON p.base_revision_id = bp.id
JOIN customer c ON p.customer_id = c.id
ORDER BY c.name, p.name, p.revision;

-- ================================================================
-- STEP 9: Business logic constraints and rules
-- ================================================================

-- Create function to ensure only one active revision per plant name
CREATE OR REPLACE FUNCTION check_single_active_plant_revision()
RETURNS TRIGGER AS $$
BEGIN
    -- If setting is_active_revision to TRUE
    IF NEW.is_active_revision = TRUE THEN
        -- Deactivate other revisions of the same plant
        UPDATE plant 
        SET is_active_revision = FALSE,
            revision_status = CASE 
                WHEN revision_status = 'ACTIVE' THEN 'ARCHIVED'
                ELSE revision_status
            END,
            archived_at = CASE 
                WHEN revision_status = 'ACTIVE' THEN CURRENT_TIMESTAMP
                ELSE archived_at
            END
        WHERE customer_id = NEW.customer_id 
          AND name = NEW.name 
          AND id != NEW.id 
          AND is_active_revision = TRUE;
          
        -- Set status to ACTIVE if it was DRAFT
        IF NEW.revision_status = 'DRAFT' THEN
            NEW.revision_status = 'ACTIVE';
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger for automatic active revision management
DROP TRIGGER IF EXISTS tr_plant_single_active_revision ON plant;
CREATE TRIGGER tr_plant_single_active_revision
    BEFORE INSERT OR UPDATE ON plant
    FOR EACH ROW
    EXECUTE FUNCTION check_single_active_plant_revision();

-- ================================================================
-- NOTES:
-- ================================================================
-- COLUMN LOGICAL ORDER (for better readability):
-- 1. Core identification: id, name
-- 2. Location: town, country
-- 3. Revision control: revision, revision_name, revision_status, etc.
-- 4. Metadata: created_by, created_at, updated_at, archived_at
-- 5. Relationships: customer_id
--
-- FEATURES ADDED:
-- 1. Complete revision control system as per documentation
-- 2. Automatic active revision management (only one active per plant name)
-- 3. Revision hierarchy tracking (base_revision_id, created_from_revision)
-- 4. Automatic timestamp updates
-- 5. Business logic constraints via triggers
-- 6. Helper functions for revision management
-- 7. Comprehensive indexing for performance
-- 
-- BACKUP RECOMMENDATION:
-- Before running this script, create a backup:
-- CREATE TABLE plant_backup AS SELECT * FROM plant;
-- 
-- ROLLBACK (if needed):
-- To remove added columns (USE WITH CAUTION):
-- ALTER TABLE plant DROP COLUMN IF EXISTS revision CASCADE;
-- ALTER TABLE plant DROP COLUMN IF EXISTS revision_name CASCADE;
-- (repeat for other added columns)
-- 
-- USAGE EXAMPLES:
-- 1. Create new revision: SELECT create_new_plant_revision(1, 'New layout design', 'john.doe');
-- 2. Activate revision: SELECT activate_plant_revision(5);
-- 3. Get active revision: SELECT get_active_plant_revision(1, 'Main Plant');
-- ================================================================
