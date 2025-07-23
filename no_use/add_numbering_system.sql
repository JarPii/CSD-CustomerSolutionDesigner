-- Add Numbering System to Lines, Tank Groups, and Tanks
-- Implements the physical layout numbering convention
-- IMPORTANT: Table name is 'line' (singular), column is 'line_number' → rename to 'number'
-- Execute in the following order for safety

-- ====================================================================
-- PART 1: RENAME LINE_NUMBER COLUMN FOR CONSISTENCY
-- ====================================================================

-- Rename line_number to number for consistency with tank_group and tank tables
ALTER TABLE line 
RENAME COLUMN line_number TO number;

-- Update unique constraint name to match new column name
ALTER TABLE line 
DROP CONSTRAINT IF EXISTS line_plant_id_line_number_key;

ALTER TABLE line 
ADD CONSTRAINT uk_line_plant_number UNIQUE (plant_id, number);

-- Ensure line.name is also unique within plant
ALTER TABLE line 
ADD CONSTRAINT uk_line_plant_name UNIQUE (plant_id, name);

-- Add NOT NULL constraint to tank_group.number (already exists as nullable)
-- First set default values, then make it NOT NULL
UPDATE tank_group 
SET number = 100 + ROW_NUMBER() OVER (PARTITION BY line_id ORDER BY id)
WHERE number IS NULL;

ALTER TABLE tank_group 
ALTER COLUMN number SET NOT NULL;

-- Tank table already has number column, but make it NOT NULL
UPDATE tank 
SET number = 100 + ROW_NUMBER() OVER (PARTITION BY tank_group_id ORDER BY id)
WHERE number IS NULL;

ALTER TABLE tank 
ALTER COLUMN number SET NOT NULL;

-- ====================================================================
-- PART 2: UPDATE TANK_GROUP AND TANK NUMBER COLUMNS
-- ====================================================================

-- Add NOT NULL constraint to tank_group.number (already exists as nullable)
-- First set default values, then make it NOT NULL
UPDATE tank_group 
SET number = 100 + ROW_NUMBER() OVER (PARTITION BY line_id ORDER BY id)
WHERE number IS NULL;

ALTER TABLE tank_group 
ALTER COLUMN number SET NOT NULL;

-- Tank table already has number column, but make it NOT NULL
UPDATE tank 
SET number = 100 + ROW_NUMBER() OVER (PARTITION BY tank_group_id ORDER BY id)
WHERE number IS NULL;

ALTER TABLE tank 
ALTER COLUMN number SET NOT NULL;

-- ====================================================================
-- PART 3: IMPLEMENT NUMBERING LOGIC
-- ====================================================================

-- Update tank_group numbers based on line numbers (line * 100 + sequence)
WITH group_numbering AS (
    SELECT 
        tg.id,
        l.number * 100 + ROW_NUMBER() OVER (PARTITION BY l.id ORDER BY tg.id) as group_num
    FROM tank_group tg
    JOIN line l ON tg.line_id = l.id  -- Using correct table name: line
)
UPDATE tank_group 
SET number = gn.group_num
FROM group_numbering gn
WHERE tank_group.id = gn.id;

-- Update tank numbers to match their tank_group numbers (plus sequence for parallel tanks)
WITH tank_numbering AS (
    SELECT 
        t.id,
        tg.number + ROW_NUMBER() OVER (PARTITION BY tg.id ORDER BY t.id) - 1 as tank_num
    FROM tank t
    JOIN tank_group tg ON t.tank_group_id = tg.id
)
UPDATE tank 
SET number = tn.tank_num
FROM tank_numbering tn
WHERE tank.id = tn.id;

-- Update tank_group numbers to minimum tank number in group (inheritance rule)
WITH group_min_numbers AS (
    SELECT 
        tg.id,
        MIN(t.number) as min_tank_number
    FROM tank_group tg
    JOIN tank t ON tg.id = t.tank_group_id
    GROUP BY tg.id
)
UPDATE tank_group 
SET number = gmn.min_tank_number
FROM group_min_numbers gmn
WHERE tank_group.id = gmn.id;

-- ====================================================================
-- PART 4: ADD ADDITIONAL UNIQUE CONSTRAINTS
-- ====================================================================

-- Add unique constraints for proper numbering system
ALTER TABLE tank_group 
ADD CONSTRAINT uk_tank_group_line_number UNIQUE (line_id, number);

ALTER TABLE tank 
ADD CONSTRAINT uk_tank_group_number UNIQUE (tank_group_id, number);

-- ====================================================================
-- PART 5: CREATE HELPER FUNCTIONS
-- ====================================================================

-- Function to get next line number for a plant
CREATE OR REPLACE FUNCTION get_next_line_number(p_plant_id INTEGER)
RETURNS INTEGER AS $$
DECLARE
    next_num INTEGER;
BEGIN
    SELECT COALESCE(MAX(number), 0) + 1 
    INTO next_num
    FROM line  -- Using correct table name: line
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
    SELECT number INTO line_num FROM line WHERE id = p_line_id;  -- Using correct table name
    
    IF line_num IS NULL THEN
        RAISE EXCEPTION 'Line not found: %', p_line_id;
    END IF;
    
    -- Get next sequence number for this line
    SELECT COALESCE(MAX(number - (line_num * 100)), 0) + 1 
    INTO next_seq
    FROM tank_group tg
    JOIN line l ON tg.line_id = l.id  -- Using correct table name
    WHERE l.id = p_line_id;
    
    next_num := line_num * 100 + next_seq;
    
    RETURN next_num;
END;
$$ LANGUAGE plpgsql;

-- Function to get next tank number for a tank group
CREATE OR REPLACE FUNCTION get_next_tank_number(p_tank_group_id INTEGER)
RETURNS INTEGER AS $$
DECLARE
    next_num INTEGER;
BEGIN
    SELECT COALESCE(MAX(number), 0) + 1 
    INTO next_num
    FROM tank 
    WHERE tank_group_id = p_tank_group_id;
    
    RETURN next_num;
END;
$$ LANGUAGE plpgsql;

-- ====================================================================
-- PART 6: CREATE INDEXES FOR PERFORMANCE
-- ====================================================================

-- Performance indexes for numbering system
CREATE INDEX idx_line_plant_number ON line(plant_id, number);  -- Using correct table name
CREATE INDEX idx_tank_group_line_number ON tank_group(line_id, number);
CREATE INDEX idx_tank_group_number ON tank(tank_group_id, number);

-- ====================================================================
-- PART 7: VERIFICATION QUERIES
-- ====================================================================

-- Verify all tables have proper numbering
SELECT 'Line numbers missing:' as check_type, COUNT(*) as count
FROM line WHERE number IS NULL  -- Using correct table name
UNION ALL
SELECT 'Tank groups missing numbers:' as check_type, COUNT(*) as count
FROM tank_group WHERE number IS NULL
UNION ALL
SELECT 'Tanks missing numbers:' as check_type, COUNT(*) as count
FROM tank WHERE number IS NULL;

-- Show numbering hierarchy example
SELECT 
    p.name as plant_name,
    l.number as line_number,
    l.name as line_name,
    tg.number as tank_group_number,
    tg.name as tank_group_name,
    t.number as tank_number,
    t.name as tank_name
FROM plant p
LEFT JOIN line l ON p.id = l.plant_id  -- Using correct table name
LEFT JOIN tank_group tg ON l.id = tg.line_id  
LEFT JOIN tank t ON tg.id = t.tank_group_id
ORDER BY p.name, l.number, tg.number, t.number
LIMIT 20;

COMMENT ON COLUMN line.number IS 'Physical line number (1,2,3...) matching plant layout and documentation (renamed from line_number)';
COMMENT ON COLUMN tank_group.number IS 'Station number (101,102,201,202...) = line*100 + sequence, or minimum tank number in group';
COMMENT ON COLUMN tank.number IS 'Tank station number matching tank group for process identification';
