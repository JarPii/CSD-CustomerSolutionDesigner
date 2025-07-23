-- ================================================================
-- TANK TABLE ENHANCEMENT SCRIPT
-- ================================================================
-- Adds positioning, type, and revision control fields to tank table
-- This script brings tank table closer to documentation expectations
-- 
-- EXECUTE THESE STATEMENTS ONE BY ONE IN DBeaver/pgAdmin
-- Always backup before running migrations!

-- ================================================================
-- STEP 1: Add core tank properties (logical grouping order)
-- ================================================================

-- Tank type and classification (after name, before dimensions)
ALTER TABLE tank 
ADD COLUMN type VARCHAR(50) DEFAULT 'storage';

-- Add height field (documentation expects this instead of depth)
ALTER TABLE tank 
ADD COLUMN height DECIMAL(10,2) DEFAULT 100;

-- Add wall thickness for engineering calculations
ALTER TABLE tank 
ADD COLUMN wall_thickness DECIMAL(8,2) DEFAULT 10.0;

-- ================================================================
-- STEP 2: Add positioning and visualization fields
-- ================================================================

-- Position coordinates (X, Y, Z order)
ALTER TABLE tank 
ADD COLUMN x_position DECIMAL(10,2) DEFAULT 0;

ALTER TABLE tank 
ADD COLUMN y_position DECIMAL(10,2) DEFAULT 0;

ALTER TABLE tank 
ADD COLUMN z_position DECIMAL(10,2) DEFAULT 0;

-- Visual properties
ALTER TABLE tank 
ADD COLUMN color VARCHAR(7) DEFAULT '#3498db';

-- ================================================================
-- STEP 3: Add revision control fields (grouped logically)
-- ================================================================

-- Basic revision info
ALTER TABLE tank 
ADD COLUMN revision INTEGER NOT NULL DEFAULT 1;

ALTER TABLE tank 
ADD COLUMN revision_name VARCHAR(255);

-- Revision relationships
ALTER TABLE tank 
ADD COLUMN base_revision_id INTEGER REFERENCES tank(id);

ALTER TABLE tank 
ADD COLUMN created_from_revision INTEGER;

-- Revision status and control
ALTER TABLE tank 
ADD COLUMN is_active_revision BOOLEAN NOT NULL DEFAULT TRUE;

ALTER TABLE tank 
ADD COLUMN revision_status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' 
CHECK (revision_status IN ('DRAFT', 'ACTIVE', 'ARCHIVED'));

-- Revision metadata
ALTER TABLE tank 
ADD COLUMN created_by VARCHAR(255) NOT NULL DEFAULT 'system';

ALTER TABLE tank 
ADD COLUMN archived_at TIMESTAMP;

-- ================================================================
-- STEP 3: Create indexes for performance
-- ================================================================

-- Index for position-based queries (spatial lookups)
CREATE INDEX idx_tank_position ON tank(x_position, y_position);

-- Index for tank type filtering
CREATE INDEX idx_tank_type ON tank(type);

-- Index for revision queries
CREATE INDEX idx_tank_active_revision ON tank(tank_group_id, name, is_active_revision);

-- Index for revision status
CREATE INDEX idx_tank_revision_status ON tank(revision_status);

-- Index for base revision lookups
CREATE INDEX idx_tank_base_revision ON tank(base_revision_id);

-- ================================================================
-- STEP 4: Add unique constraints for revision system
-- ================================================================

-- Ensure unique revision numbers per tank name within tank group
ALTER TABLE tank 
ADD CONSTRAINT uq_tank_revision 
UNIQUE(tank_group_id, name, revision);

-- ================================================================
-- STEP 5: Update existing data with default values
-- ================================================================

-- Set default positions for existing tanks (spread them out)
UPDATE tank 
SET 
    x_position = (id % 10) * 150,  -- Spread horizontally
    y_position = (id / 10) * 120,  -- Spread vertically  
    height = COALESCE(depth, 100), -- Use depth as height if available
    type = CASE 
        WHEN name ILIKE '%acid%' THEN 'acid'
        WHEN name ILIKE '%wash%' THEN 'wash'
        WHEN name ILIKE '%rinse%' THEN 'rinse'
        WHEN name ILIKE '%dry%' THEN 'dry'
        WHEN name ILIKE '%heat%' OR name ILIKE '%hot%' THEN 'heating'
        WHEN name ILIKE '%cool%' OR name ILIKE '%cold%' THEN 'cooling'
        ELSE 'storage'
    END,
    color = CASE 
        WHEN name ILIKE '%acid%' THEN '#e74c3c'  -- Red for acid
        WHEN name ILIKE '%wash%' THEN '#3498db'  -- Blue for wash
        WHEN name ILIKE '%rinse%' THEN '#2ecc71' -- Green for rinse
        WHEN name ILIKE '%dry%' THEN '#f39c12'   -- Orange for dry
        WHEN name ILIKE '%heat%' OR name ILIKE '%hot%' THEN '#e67e22' -- Dark orange for heating
        WHEN name ILIKE '%cool%' OR name ILIKE '%cold%' THEN '#9b59b6' -- Purple for cooling
        ELSE '#34495e'  -- Dark gray for storage
    END,
    revision_name = 'Initial configuration'
WHERE x_position IS NULL OR y_position IS NULL;

-- ================================================================
-- STEP 6: Add check constraints for data integrity
-- ================================================================

-- Ensure positive dimensions
ALTER TABLE tank 
ADD CONSTRAINT chk_tank_width_positive 
CHECK (width > 0);

ALTER TABLE tank 
ADD CONSTRAINT chk_tank_height_positive 
CHECK (height > 0);

-- Ensure valid color format (hex color)
ALTER TABLE tank 
ADD CONSTRAINT chk_tank_color_format 
CHECK (color ~ '^#[0-9A-Fa-f]{6}$');

-- Ensure revision number is positive
ALTER TABLE tank 
ADD CONSTRAINT chk_tank_revision_positive 
CHECK (revision > 0);

-- ================================================================
-- STEP 7: Create functions for revision management
-- ================================================================

-- Function: Get next revision number for a tank
CREATE OR REPLACE FUNCTION get_next_tank_revision_number(
    p_tank_group_id INTEGER, 
    p_tank_name VARCHAR
) RETURNS INTEGER AS $$
DECLARE
    next_rev INTEGER;
BEGIN
    SELECT COALESCE(MAX(revision), 0) + 1 
    INTO next_rev
    FROM tank 
    WHERE tank_group_id = p_tank_group_id AND name = p_tank_name;
    
    RETURN next_rev;
END;
$$ LANGUAGE plpgsql;

-- Function: Create new tank revision
CREATE OR REPLACE FUNCTION create_new_tank_revision(
    p_source_tank_id INTEGER,
    p_revision_name VARCHAR DEFAULT NULL,
    p_created_by VARCHAR DEFAULT 'system'
) RETURNS INTEGER AS $$
DECLARE
    source_tank RECORD;
    new_tank_id INTEGER;
    next_rev INTEGER;
BEGIN
    -- Get source tank details
    SELECT * INTO source_tank FROM tank WHERE id = p_source_tank_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Source tank not found: %', p_source_tank_id;
    END IF;
    
    -- Get next revision number
    next_rev := get_next_tank_revision_number(source_tank.tank_group_id, source_tank.name);
    
    -- Create new revision (copy all fields except id and revision info)
    -- Logical field order: core properties, dimensions, position, visual, revision, relationships
    INSERT INTO tank (
        -- Core properties
        name, type,
        -- Dimensions  
        width, length, depth, height, wall_thickness,
        -- Position
        x_position, y_position, z_position,
        -- Visual
        color,
        -- Revision control
        revision, revision_name, base_revision_id, created_from_revision,
        is_active_revision, revision_status, created_by,
        -- Relationships and legacy fields
        tank_group_id, plant_id, number, space
    ) VALUES (
        -- Core properties
        source_tank.name, source_tank.type,
        -- Dimensions
        source_tank.width, source_tank.length, source_tank.depth, source_tank.height, source_tank.wall_thickness,
        -- Position
        source_tank.x_position, source_tank.y_position, source_tank.z_position,
        -- Visual
        source_tank.color,
        -- Revision control
        next_rev, COALESCE(p_revision_name, 'Revision ' || next_rev),
        p_source_tank_id, source_tank.revision,
        FALSE, 'DRAFT', p_created_by,
        -- Relationships and legacy fields
        source_tank.tank_group_id, source_tank.plant_id, source_tank.number, source_tank.space
    ) RETURNING id INTO new_tank_id;
    
    RETURN new_tank_id;
END;
$$ LANGUAGE plpgsql;

-- Function: Activate tank revision
CREATE OR REPLACE FUNCTION activate_tank_revision(p_tank_id INTEGER) 
RETURNS BOOLEAN AS $$
DECLARE
    target_tank RECORD;
    current_active_id INTEGER;
BEGIN
    -- Get target tank details
    SELECT * INTO target_tank FROM tank WHERE id = p_tank_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Tank not found: %', p_tank_id;
    END IF;
    
    IF target_tank.revision_status = 'ACTIVE' THEN
        RETURN TRUE; -- Already active
    END IF;
    
    IF target_tank.revision_status = 'ARCHIVED' THEN
        RAISE EXCEPTION 'Cannot activate archived revision';
    END IF;
    
    -- Find current active revision for this tank name
    SELECT id INTO current_active_id 
    FROM tank 
    WHERE tank_group_id = target_tank.tank_group_id 
      AND name = target_tank.name 
      AND is_active_revision = TRUE;
    
    -- Deactivate current active revision
    IF current_active_id IS NOT NULL THEN
        UPDATE tank 
        SET is_active_revision = FALSE, 
            revision_status = 'ARCHIVED',
            archived_at = CURRENT_TIMESTAMP
        WHERE id = current_active_id;
    END IF;
    
    -- Activate target revision
    UPDATE tank 
    SET is_active_revision = TRUE, 
        revision_status = 'ACTIVE'
    WHERE id = p_tank_id;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- ================================================================
-- STEP 8: Verification queries
-- ================================================================

-- Check that all tanks have position data
SELECT 'Position data check' as test_name, 
       COUNT(*) as total_tanks,
       COUNT(*) FILTER (WHERE x_position IS NOT NULL) as tanks_with_x,
       COUNT(*) FILTER (WHERE y_position IS NOT NULL) as tanks_with_y,
       COUNT(*) FILTER (WHERE type IS NOT NULL) as tanks_with_type
FROM tank;

-- Check revision data
SELECT 'Revision data check' as test_name,
       COUNT(*) as total_tanks,
       COUNT(*) FILTER (WHERE revision IS NOT NULL) as tanks_with_revision,
       COUNT(*) FILTER (WHERE is_active_revision = TRUE) as active_revisions
FROM tank;

-- Show sample of enhanced tank data (logical column order)
SELECT 
    -- Core identification
    id, name, type,
    -- Dimensions
    width, length, depth, height, wall_thickness,
    -- Position
    x_position, y_position, z_position,
    -- Visualization
    color,
    -- Revision control
    revision, revision_status, is_active_revision,
    -- Relationships
    tank_group_id, plant_id
FROM tank 
ORDER BY tank_group_id, name
LIMIT 5;

-- ================================================================
-- NOTES:
-- ================================================================
-- COLUMN LOGICAL ORDER (for better readability):
-- 1. Core identification: id, name, type
-- 2. Dimensions: width, length, depth, height, wall_thickness  
-- 3. Position: x_position, y_position, z_position
-- 4. Visual: color
-- 5. Revision control: revision, revision_name, revision_status, etc.
-- 6. Relationships: tank_group_id, plant_id
-- 7. Legacy/utility: number, space, created_at, updated_at
--
-- FEATURES ADDED:
-- 1. This script adds positioning fields needed for layout visualization
-- 2. Adds revision control system similar to plants table (future use)
-- 3. Automatically categorizes existing tanks by name patterns
-- 4. Creates indexes for performance
-- 5. Includes data integrity constraints
-- 6. Provides functions for revision management
-- 
-- BACKUP RECOMMENDATION:
-- Before running this script, create a backup:
-- CREATE TABLE tank_backup AS SELECT * FROM tank;
-- 
-- ROLLBACK (if needed):
-- To remove added columns (USE WITH CAUTION):
-- ALTER TABLE tank DROP COLUMN IF EXISTS x_position CASCADE;
-- ALTER TABLE tank DROP COLUMN IF EXISTS y_position CASCADE;
-- (repeat for other added columns)
-- ================================================================
