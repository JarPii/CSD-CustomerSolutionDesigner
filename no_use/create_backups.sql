-- ================================================================
-- BACKUP SCRIPT - RUN BEFORE MIGRATIONS
-- ================================================================
-- Creates backups of critical tables before running enhancement scripts
-- Run this FIRST before any migrations!

-- Backup tank table
CREATE TABLE tank_backup AS SELECT * FROM tank;

-- Backup plant table  
CREATE TABLE plant_backup AS SELECT * FROM plant;

-- Backup line table (in case we need to modify it later)
CREATE TABLE line_backup AS SELECT * FROM line;

-- Backup customer table
CREATE TABLE customer_backup AS SELECT * FROM customer;

-- Verify backups were created
SELECT 
    'tank_backup' as table_name,
    COUNT(*) as row_count
FROM tank_backup
UNION ALL
SELECT 
    'plant_backup' as table_name,
    COUNT(*) as row_count  
FROM plant_backup
UNION ALL
SELECT 
    'line_backup' as table_name,
    COUNT(*) as row_count
FROM line_backup
UNION ALL
SELECT 
    'customer_backup' as table_name,
    COUNT(*) as row_count
FROM customer_backup;

-- Show table sizes for reference
SELECT 
    schemaname,
    tablename,
    attname,
    n_distinct,
    correlation
FROM pg_stats 
WHERE schemaname = 'public' 
AND tablename IN ('tank', 'plant', 'line', 'customer')
ORDER BY tablename, attname;

SELECT 'Backup completed successfully!' as status;
