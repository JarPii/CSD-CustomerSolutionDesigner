-- Simplified Numbering System Migration for Empty Database
-- Since all tables are empty, we can directly modify structure without data concerns
-- Execute in order for safety

-- ====================================================================
-- PART 1: RENAME LINE COLUMN FOR CONSISTENCY  
-- ====================================================================

-- Rename line_number to number for consistency
ALTER TABLE line 
RENAME COLUMN line_number TO number;

-- Update constraint names to match new column
ALTER TABLE line 
DROP CONSTRAINT IF EXISTS line_plant_id_line_number_key;

ALTER TABLE line 
ADD CONSTRAINT uk_line_plant_number UNIQUE (plant_id, number);

ALTER TABLE line 
ADD CONSTRAINT uk_line_plant_name UNIQUE (plant_id, name);

-- ====================================================================
-- PART 2: SET NOT NULL CONSTRAINTS
-- ====================================================================

-- Make tank_group.number NOT NULL (already exists but may be nullable)
ALTER TABLE tank_group 
ALTER COLUMN number SET NOT NULL;

-- Make tank.number NOT NULL (already exists but may be nullable)  
ALTER TABLE tank 
ALTER COLUMN number SET NOT NULL;

-- ====================================================================
-- PART 3: ADD UNIQUE CONSTRAINTS FOR NUMBERING SYSTEM
-- ====================================================================

-- Tank group numbers must be unique within line
ALTER TABLE tank_group 
ADD CONSTRAINT uk_tank_group_line_number UNIQUE (line_id, number);

-- Tank numbers must be unique within tank group
ALTER TABLE tank 
ADD CONSTRAINT uk_tank_group_number UNIQUE (tank_group_id, number);

-- ====================================================================
-- PART 4: CREATE HELPER FUNCTIONS FOR NUMBERING
-- ====================================================================

-- Function to get next line number for a plant
CREATE OR REPLACE FUNCTION get_next_line_number(p_plant_id INTEGER)
RETURNS INTEGER AS $$
DECLARE
    next_num INTEGER;
BEGIN
    SELECT COALESCE(MAX(number), 0) + 1 
    INTO next_num
    FROM line 
    WHERE plant_id = p_plant_id;
    
    RETURN next_num;
END;
$$ LANGUAGE plpgsql;

-- Function to get next tank group number for a line
CREATE OR REPLACE FUNCTION get_next_tank_group_number(p_line_id INTEGER)
RETURNS INTEGER AS $$
DECLARE
    line_num INTEGER;
    next_seq INTEGER;
    next_num INTEGER;
BEGIN
    -- Get line number
    SELECT number INTO line_num FROM line WHERE id = p_line_id;
    
    IF line_num IS NULL THEN
        RAISE EXCEPTION 'Line not found: %', p_line_id;
    END IF;
    
    -- Get next sequence number for this line
    SELECT COALESCE(MAX(number - (line_num * 100)), 0) + 1 
    INTO next_seq
    FROM tank_group tg
    JOIN line l ON tg.line_id = l.id
    WHERE l.id = p_line_id;
    
    next_num := line_num * 100 + next_seq;
    
    RETURN next_num;
END;
$$ LANGUAGE plpgsql;

-- Function to get next tank number for a tank group
CREATE OR REPLACE FUNCTION get_next_tank_number(p_tank_group_id INTEGER)
RETURNS INTEGER AS $$
DECLARE
    base_num INTEGER;
    next_seq INTEGER;
    next_num INTEGER;
BEGIN
    -- Get tank group number as base
    SELECT number INTO base_num FROM tank_group WHERE id = p_tank_group_id;
    
    IF base_num IS NULL THEN
        RAISE EXCEPTION 'Tank group not found: %', p_tank_group_id;
    END IF;
    
    -- Get next sequence for parallel tanks (0, 1, 2...)
    SELECT COALESCE(MAX(number - base_num), -1) + 1 
    INTO next_seq
    FROM tank 
    WHERE tank_group_id = p_tank_group_id;
    
    next_num := base_num + next_seq;
    
    RETURN next_num;
END;
$$ LANGUAGE plpgsql;

-- ====================================================================
-- PART 5: CREATE PERFORMANCE INDEXES
-- ====================================================================

-- Performance indexes for numbering system
CREATE INDEX idx_line_plant_number ON line(plant_id, number);
CREATE INDEX idx_tank_group_line_number ON tank_group(line_id, number);
CREATE INDEX idx_tank_group_number ON tank(tank_group_id, number);

-- ====================================================================
-- PART 6: ADD HELPFUL COMMENTS TO COLUMNS
-- ====================================================================

COMMENT ON COLUMN line.number IS 'Physical line number (1,2,3...) matching plant layout and documentation (renamed from line_number)';
COMMENT ON COLUMN tank_group.number IS 'Station number (101,102,201,202...) = line*100 + sequence, or minimum tank number in group';
COMMENT ON COLUMN tank.number IS 'Tank station number matching tank group for process identification';

-- ====================================================================
-- PART 7: VERIFICATION QUERIES (Should all return 0 for empty DB)
-- ====================================================================

-- Verify structure is correct
SELECT 'Empty database check - All should be 0:' as info;

SELECT 'Lines' as table_name, COUNT(*) as row_count FROM line
UNION ALL
SELECT 'Tank Groups', COUNT(*) FROM tank_group  
UNION ALL
SELECT 'Tanks', COUNT(*) FROM tank;

-- Test helper functions with dummy data (optional)
-- SELECT 'Line 1 next number would be: ' || get_next_line_number(1);

-- Success message
SELECT 'Numbering system migration completed successfully!' as status;
