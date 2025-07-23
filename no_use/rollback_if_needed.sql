-- ================================================================
-- ROLLBACK SCRIPT - EMERGENCY USE ONLY
-- ================================================================
-- Restores tables from backups if migrations fail
-- ONLY USE IF MIGRATIONS HAVE FAILED AND YOU NEED TO RESTORE!

-- WARNING: This will delete current tables and restore from backups
-- Make sure backups exist before running!

-- Check that backups exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'tank_backup') THEN
        RAISE EXCEPTION 'tank_backup table does not exist! Cannot rollback.';
    END IF;
    
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'plant_backup') THEN
        RAISE EXCEPTION 'plant_backup table does not exist! Cannot rollback.';
    END IF;
    
    RAISE NOTICE 'Backup tables found. Ready for rollback if needed.';
END $$;

-- UNCOMMENT THESE LINES ONLY IF YOU NEED TO ROLLBACK:

-- Rollback tank table
-- DROP TABLE IF EXISTS tank CASCADE;
-- ALTER TABLE tank_backup RENAME TO tank;

-- Rollback plant table  
-- DROP TABLE IF EXISTS plant CASCADE;
-- ALTER TABLE plant_backup RENAME TO plant;

-- Rollback line table
-- DROP TABLE IF EXISTS line CASCADE; 
-- ALTER TABLE line_backup RENAME TO line;

-- Rollback customer table
-- DROP TABLE IF EXISTS customer CASCADE;
-- ALTER TABLE customer_backup RENAME TO customer;

-- Verify rollback (uncomment if you ran the rollback)
-- SELECT 'Rollback completed' as status;
-- SELECT COUNT(*) as tank_count FROM tank;
-- SELECT COUNT(*) as plant_count FROM plant;

SELECT 'Rollback script ready (but not executed)' as status;
