# STL Project Documentation

This directory contains all project documentation for the John Cockerill Surface Treatment Plants solution.

## Documentation Files

### Core Documentation
- **`database-schema-documentation.md`** - Complete database schema documentation
- **`technical-documentation.md`** - Technical implementation details
- **`backend-sync-summary.md`** - Backend and database synchronization summary

### Management Guides
- **`customer-management-guide.md`** - Customer management system guide
- **`kayttoohjeet.md`** - User instructions (Finnish)
- **`kehitys-vs-tuotanto.md`** - Development vs production guide (Finnish)

### Project Planning & Branding
- **`projektin-tila-ja-roadmap.md`** - Project status and roadmap (Finnish)
- **`john-cockerill-brand-guidelines.md`** - John Cockerill brand guidelines

### Deployment & Development
- **`azure-deployment-checklist.md`** - Azure deployment checklist
- **`tekninen-dokumentaatio.md`** - Technical documentation (Finnish)

### Configuration
- **`stl-database.txt`** - Database connection configuration

### SQL Scripts Analysis
- **`sql-files-analysis.md`** - Analysis of SQL scripts and organization recommendations

## SQL Scripts Organization

All SQL scripts have been organized into the `/sql/` directory with the following structure:
- `/sql/migrations/` - Critical database migration scripts
- `/sql/maintenance/` - Database maintenance and verification utilities  
- `/sql/testing/` - Test scripts for database functionality
- `/sql/archive/` - Historical scripts and completed migrations

See `/sql/README.md` for detailed information about SQL script organization.

## Document Organization

All documentation is now centralized in this single `documentation/` directory to maintain clarity and avoid confusion. Previously, there was a misspelled `documenatation/` directory that has been cleaned up.

## Maintenance

When adding new documentation, please:
1. Place files in this directory
2. Update this README.md
3. Follow the existing naming conventions
4. Include both English and Finnish versions when appropriate
