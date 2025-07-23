-- ==================================================
-- VERIFY TABLE STRUCTURE AND CONSISTENCY
-- ==================================================
-- This script verifies that all four tables follow the same principles

-- 1. Check all tables exist and their basic structure
SELECT 
    table_name,
    table_type
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('customer', 'plant', 'line', 'tank_group')
ORDER BY table_name;

-- 2. Check all columns in each table
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_schema = 'public' 
AND table_name IN ('customer', 'plant', 'line', 'tank_group')
ORDER BY table_name, ordinal_position;

-- 3. Check primary keys
SELECT 
    tc.table_name,
    kcu.column_name,
    tc.constraint_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu 
    ON tc.constraint_name = kcu.constraint_name
WHERE tc.table_schema = 'public' 
AND tc.constraint_type = 'PRIMARY KEY'
AND tc.table_name IN ('customer', 'plant', 'line', 'tank_group')
ORDER BY tc.table_name;

-- 4. Check foreign keys
SELECT 
    tc.table_name,
    kcu.column_name,
    ccu.table_name AS foreign_table_name,
    ccu.column_name AS foreign_column_name,
    tc.constraint_name
FROM information_schema.table_constraints tc
JOIN information_schema.key_column_usage kcu 
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage ccu 
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.table_schema = 'public' 
AND tc.constraint_type = 'FOREIGN KEY'
AND tc.table_name IN ('customer', 'plant', 'line', 'tank_group')
ORDER BY tc.table_name;

-- 5. Check indexes
SELECT 
    schemaname,
    tablename,
    indexname,
    indexdef
FROM pg_indexes 
WHERE schemaname = 'public' 
AND tablename IN ('customer', 'plant', 'line', 'tank_group')
ORDER BY tablename, indexname;

-- 6. Check triggers
SELECT 
    trigger_name,
    event_object_table,
    action_timing,
    event_manipulation,
    action_statement
FROM information_schema.triggers 
WHERE trigger_schema = 'public' 
AND event_object_table IN ('customer', 'plant', 'line', 'tank_group')
ORDER BY event_object_table;

-- 7. Check that all tables have required fields
-- This should return 4 rows (one for each table)
SELECT 
    table_name,
    COUNT(*) as total_columns,
    COUNT(CASE WHEN column_name = 'id' THEN 1 END) as has_id,
    COUNT(CASE WHEN column_name = 'name' THEN 1 END) as has_name,
    COUNT(CASE WHEN column_name = 'created_at' THEN 1 END) as has_created_at,
    COUNT(CASE WHEN column_name = 'updated_at' THEN 1 END) as has_updated_at
FROM information_schema.columns 
WHERE table_schema = 'public' 
AND table_name IN ('customer', 'plant', 'line', 'tank_group')
GROUP BY table_name
ORDER BY table_name;

-- 8. Check specific table relationships
-- Customer table should have no foreign keys
-- Plant table should reference customer
-- Line table should reference plant
-- Tank_group table should reference both plant and line

SELECT 
    'Expected relationships' as check_type,
    'customer: 0 FK, plant: 1 FK (customer), line: 1 FK (plant), tank_group: 2 FK (plant+line)' as expected;
