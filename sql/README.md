# SQL Scripts Organization

This directory contains all SQL scripts organized by their purpose and lifecycle status.

## Directory Structure

### 📁 `migrations/`
**Active migration scripts** - Critical database structure changes
- `database_migration_products.sql` - Major product tables migration
- `remaining_tables.sql` - Production requirements table creation  
- `create_trigger_functions_and_triggers.sql` - Database triggers setup

### 📁 `maintenance/`
**Database maintenance utilities** - Scripts for ongoing database management
- `verify_table_structure.sql` - Verify database consistency and structure

### 📁 `testing/`
**Test scripts** - Scripts for testing database functionality
- `test_trigger_function.sql` - Test trigger functionality
- `test_triggers.sql` - Test trigger execution

### 📁 `archive/`
**Historical scripts** - Completed migrations and obsolete scripts
- `create_*_table.sql` - Table creation scripts (already applied)
- `add_*_columns.sql` - Column addition scripts (already applied)
- `test_customer_products.sql` - Completed test script

## Usage Guidelines

### For Migrations
- Scripts in `migrations/` represent major database changes
- These should be run in production environments with caution
- Always backup database before running migration scripts

### For Maintenance
- Scripts in `maintenance/` can be run safely for verification
- Use these for health checks and consistency validation

### For Testing
- Scripts in `testing/` are for development/testing environments
- Safe to run multiple times in test environments

### Archive Policy
- Scripts in `archive/` are kept for historical reference
- These scripts have typically already been applied to production
- Should not be run again unless specifically needed for new environments

## Migration History

1. **Phase 1**: Basic table creation (customer, plant, line, tank_group) ✅
2. **Phase 2**: Product tables and production requirements ✅  
3. **Phase 3**: Trigger functions for updated_at fields ✅
4. **Current**: Database is fully operational with all required tables

## Contact
For questions about these scripts, refer to the main project documentation in `/documentation/`.
