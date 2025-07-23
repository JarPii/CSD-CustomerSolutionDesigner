# Scripts Directory

This directory contains utility and helper scripts organized by their purpose.

## Directory Structure

### 📁 `archive/`
**Completed/Historical Scripts** - Scripts that have been successfully applied
- `create_db.py` - Database creation script (applied ✅)
- `create_plant_table.py` - Plant table creation via SQLAlchemy (applied ✅)
- `create_tank_group_table.py` - Tank group table creation (applied ✅)
- `migrate_customer_table.py` - Customer table migration (applied ✅)

### 📁 `debug/`
**Debug and Development Scripts** - Temporary tools for debugging
- `debug_lines.py` - Debug tool for lines endpoints

### 📁 `deployment/`
**Deployment Scripts** - Scripts and configs for deployment
- `startup.txt` - Gunicorn startup command

### 📁 `testing/`
**Test and Verification Scripts** - Scripts for testing functionality
- `test_db.py` - Database connectivity test script

## Usage Guidelines

### Archive Scripts
- Scripts in `archive/` have typically been run successfully in production
- Keep for historical reference and documentation
- Should not be run again unless setting up new environments

### Debug Scripts
- Scripts in `debug/` are temporary development tools
- Safe to run in development environments
- Used for troubleshooting specific issues

### Testing Scripts
- Scripts in `testing/` are for verification and testing
- Can be run safely multiple times
- Useful for health checks and connectivity testing

## Script Execution

When running scripts from this directory, ensure you:
1. Are in the correct environment (development/production)
2. Have proper database credentials configured
3. Understand the script's purpose and impact
4. Back up data before running any modification scripts

## Main Application

The main application entry point `customer_api.py` remains in the project root directory for easy access and deployment.
