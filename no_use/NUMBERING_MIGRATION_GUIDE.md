# Numbering System Migration Guide

## Overview
This migration renames `line.line_number` to `line.number` for consistency and implements the physical layout numbering convention across all tables.

**IMPORTANT**: Table name is `line` (singular), not `lines` (plural)

## Execution Steps

### Step 1: Rename Line Column for Consistency
```sql
-- Rename line_number to number for consistency with tank_group and tank tables
ALTER TABLE line RENAME COLUMN line_number TO number;

-- Update unique constraint
ALTER TABLE line DROP CONSTRAINT IF EXISTS line_plant_id_line_number_key;
ALTER TABLE line ADD CONSTRAINT uk_line_plant_number UNIQUE (plant_id, number);
ALTER TABLE line ADD CONSTRAINT uk_line_plant_name UNIQUE (plant_id, name);
```

### Step 2: Fix Tank Group Numbers
```sql
-- Ensure tank_group.number is NOT NULL
UPDATE tank_group 
SET number = 100 + ROW_NUMBER() OVER (PARTITION BY line_id ORDER BY id)
WHERE number IS NULL;

ALTER TABLE tank_group ALTER COLUMN number SET NOT NULL;
```

### Step 3: Fix Tank Numbers  
```sql
-- Ensure tank.number is NOT NULL
UPDATE tank 
SET number = 100 + ROW_NUMBER() OVER (PARTITION BY tank_group_id ORDER BY id)
WHERE number IS NULL;

ALTER TABLE tank ALTER COLUMN number SET NOT NULL;
```

### Step 4: Implement Numbering Logic
```sql
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

-- Update tank numbers to match their tank_group station
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

-- Apply inheritance rule: tank_group.number = MIN(tank.number) in group
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
```

### Step 5: Add Unique Constraints
```sql
-- Prevent duplicate numbers within scope (line constraints already added in Step 1)
ALTER TABLE tank_group ADD CONSTRAINT uk_tank_group_line_number UNIQUE (line_id, number);
ALTER TABLE tank ADD CONSTRAINT uk_tank_group_number UNIQUE (tank_group_id, number);
```

### Step 6: Create Helper Functions
```sql
-- Function for next line number
CREATE OR REPLACE FUNCTION get_next_line_number(p_plant_id INTEGER)
RETURNS INTEGER AS $$
BEGIN
    RETURN (SELECT COALESCE(MAX(number), 0) + 1 FROM line WHERE plant_id = p_plant_id);
END;
$$ LANGUAGE plpgsql;

-- Function for next tank group number  
CREATE OR REPLACE FUNCTION get_next_tank_group_number(p_line_id INTEGER)
RETURNS INTEGER AS $$
DECLARE
    line_num INTEGER;
    next_seq INTEGER;
BEGIN
    SELECT number INTO line_num FROM line WHERE id = p_line_id;
    SELECT COALESCE(MAX(number - (line_num * 100)), 0) + 1 
    INTO next_seq FROM tank_group tg JOIN line l ON tg.line_id = l.id WHERE l.id = p_line_id;
    RETURN line_num * 100 + next_seq;
END;
$$ LANGUAGE plpgsql;
```

### Step 7: Verification
```sql
-- Check for missing numbers (should all return 0)
SELECT 'Line' as table_name, COUNT(*) as missing_numbers FROM line WHERE number IS NULL
UNION ALL
SELECT 'Tank Groups', COUNT(*) FROM tank_group WHERE number IS NULL  
UNION ALL
SELECT 'Tanks', COUNT(*) FROM tank WHERE number IS NULL;

-- View the numbering hierarchy
SELECT 
    p.name as plant,
    l.number as line_num, l.name as line_name,
    tg.number as station_num, tg.name as station_name,
    t.number as tank_num, t.name as tank_name
FROM plant p
JOIN line l ON p.id = l.plant_id  -- Using correct table name: line
JOIN tank_group tg ON l.id = tg.line_id
JOIN tank t ON tg.id = t.tank_group_id
ORDER BY p.name, l.number, tg.number, t.number;
```

## Expected Results

After migration, the numbering should follow this pattern:

```
Plant: "Example Plant"
├── Line 1
│   ├── Station 101 (Tank Group: "Pre-wash")
│   │   ├── Tank 101 
│   │   └── Tank 102
│   └── Station 103 (Tank Group: "Rinse") ← Group number = MIN(103) = 103
│       └── Tank 103
└── Line 2  
    ├── Station 201 (Tank Group: "Pre-wash")
    └── Station 202 (Tank Group: "Acid Bath")
```

## Rollback (If Needed)
```sql
-- Remove constraints
ALTER TABLE line DROP CONSTRAINT IF EXISTS uk_line_plant_number;
ALTER TABLE line DROP CONSTRAINT IF EXISTS uk_line_plant_name;
ALTER TABLE tank_group DROP CONSTRAINT IF EXISTS uk_tank_group_line_number;
ALTER TABLE tank DROP CONSTRAINT IF EXISTS uk_tank_group_number;

-- Rename column back to original name
ALTER TABLE line RENAME COLUMN number TO line_number;

-- Reset tank_group and tank numbers to NULL (optional)
-- ALTER TABLE tank_group ALTER COLUMN number DROP NOT NULL;
-- ALTER TABLE tank ALTER COLUMN number DROP NOT NULL;
```
