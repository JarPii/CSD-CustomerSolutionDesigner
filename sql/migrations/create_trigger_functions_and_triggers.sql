-- ==================================================
-- TRIGGER FUNCTIONS AND TRIGGERS FOR UPDATED_AT FIELDS
-- ==================================================
-- 
-- Execute these statements ONE BY ONE in DBeaver
-- DO NOT run them all at once - run each section separately
--
-- Order of execution:
-- 1. First run all 4 CREATE FUNCTION statements
-- 2. Then run all 4 CREATE TRIGGER statements
--

-- ==================================================
-- STEP 1: CREATE ALL TRIGGER FUNCTIONS FIRST
-- ==================================================

-- Function for customer table
CREATE OR REPLACE FUNCTION update_customer_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function for plant table
CREATE OR REPLACE FUNCTION update_plant_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function for line table
CREATE OR REPLACE FUNCTION update_line_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Function for tank_group table
CREATE OR REPLACE FUNCTION update_tank_group_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ==================================================
-- STEP 2: CREATE ALL TRIGGERS (AFTER FUNCTIONS ARE CREATED)
-- ==================================================

-- Trigger for customer table
CREATE TRIGGER trigger_update_customer_updated_at
    BEFORE UPDATE ON customer
    FOR EACH ROW
    EXECUTE FUNCTION update_customer_updated_at();

-- Trigger for plant table
CREATE TRIGGER trigger_update_plant_updated_at
    BEFORE UPDATE ON plant
    FOR EACH ROW
    EXECUTE FUNCTION update_plant_updated_at();

-- Trigger for line table
CREATE TRIGGER trigger_update_line_updated_at
    BEFORE UPDATE ON line
    FOR EACH ROW
    EXECUTE FUNCTION update_line_updated_at();

-- Trigger for tank_group table
CREATE TRIGGER trigger_update_tank_group_updated_at
    BEFORE UPDATE ON tank_group
    FOR EACH ROW
    EXECUTE FUNCTION update_tank_group_updated_at();

-- ==================================================
-- VERIFICATION QUERIES
-- ==================================================
-- Run these to verify everything was created successfully:

-- Check if all functions exist
SELECT 
    routine_name,
    routine_type,
    routine_definition
FROM information_schema.routines 
WHERE routine_name IN (
    'update_customer_updated_at',
    'update_plant_updated_at', 
    'update_line_updated_at',
    'update_tank_group_updated_at'
)
AND routine_schema = 'public';

-- Check if all triggers exist
SELECT 
    trigger_name,
    event_object_table,
    action_timing,
    event_manipulation
FROM information_schema.triggers
WHERE trigger_name IN (
    'trigger_update_customer_updated_at',
    'trigger_update_plant_updated_at',
    'trigger_update_line_updated_at', 
    'trigger_update_tank_group_updated_at'
)
AND trigger_schema = 'public';
