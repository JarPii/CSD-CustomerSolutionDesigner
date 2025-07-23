# SQL Files Analysis - STL Project

## Analysis Date: July 11, 2025

### 📊 Summary of SQL Files in Root Directory

| File | Status | Purpose | Current Relevance |
|------|--------|---------|-------------------|
| `add_number_columns.sql` | 🟡 Historical | Add number columns to tank_group/tank | Possibly outdated |
| `add_space_column_to_tank.sql` | 🟡 Historical | Add space column to tank table | Possibly outdated |
| `create_line_table.sql` | 🔴 Obsolete | Create line table | **Applied to DB** |
| `create_plant_table.sql` | 🔴 Obsolete | Create plant table | **Applied to DB** |
| `create_tank_group_table.sql` | 🟡 Historical | Create tank_group table | **Applied to DB** |
| `create_tank_table.sql` | 🔴 Obsolete | Create tank table (v1) | **Superseded** |
| `create_tank_table_revised.sql` | 🟡 Historical | Create tank table (v2) | **Applied to DB** |
| `create_trigger_functions_and_triggers.sql` | 🟠 Legacy | Database triggers and functions | Unknown status |
| `database_migration_products.sql` | 🟢 **IMPORTANT** | Major migration script | **Successfully applied** |
| `remaining_tables.sql` | 🟢 **IMPORTANT** | Create production_requirements | **Successfully applied** |
| `test_customer_products.sql` | 🔴 Obsolete | Test customer_products creation | **Applied to DB** |
| `test_trigger_function.sql` | 🟠 Test | Test trigger functionality | Possibly useful |
| `test_triggers.sql` | 🟠 Test | Test trigger execution | Possibly useful |
| `verify_table_structure.sql` | 🟢 **USEFUL** | Verify DB structure consistency | **Keep for maintenance** |

### 🎯 Recommendations

#### ✅ Keep These Files (Move to migrations/ or sql/)
1. **`database_migration_products.sql`** - Major migration history
2. **`remaining_tables.sql`** - Important table creation
3. **`verify_table_structure.sql`** - Useful for maintenance
4. **`test_trigger_function.sql`** - Useful for testing
5. **`test_triggers.sql`** - Useful for testing

#### ❌ Can be Archived/Removed
1. **`create_*_table.sql`** - Tables already exist in production
2. **`test_customer_products.sql`** - Test completed successfully
3. **`add_*_columns.sql`** - Columns likely already added

#### 🤔 Need Investigation
1. **`create_trigger_functions_and_triggers.sql`** - Check if triggers are in use

### 📁 Proposed Organization

Create organized structure:
```
sql/
├── migrations/
│   ├── database_migration_products.sql
│   └── remaining_tables.sql
├── maintenance/
│   └── verify_table_structure.sql
├── testing/
│   ├── test_trigger_function.sql
│   └── test_triggers.sql
└── archive/
    ├── create_line_table.sql
    ├── create_plant_table.sql
    ├── create_tank_*.sql
    ├── add_*_columns.sql
    └── test_customer_products.sql
```

This would clean up the root directory while preserving important SQL history.

---

## 🐍 Python Files Analysis - Root Directory

### Analysis Date: July 11, 2025

### 📊 Summary of Python Files in Root Directory

| File | Status | Purpose | Current Relevance |
|------|--------|---------|-------------------|
| `customer_api.py` | 🟢 **ACTIVE** | Main FastAPI application | **In use - KEEP** |
| `create_db.py` | 🟡 Historical | Create database and initial tables | **Applied to DB** |
| `create_plant_table.py` | 🔴 Obsolete | Create plant table using SQLAlchemy | **Applied to DB** |
| `create_tank_group_table.py` | 🔴 Obsolete | Create tank_group table | **Applied to DB** |
| `debug_lines.py` | 🟠 Debug | Debug lines endpoints | **Temporary tool** |
| `migrate_customer_table.py` | 🟡 Historical | Customer table structure migration | **Applied to DB** |
| `test_db.py` | 🟠 Test | Test database connectivity | **Useful for testing** |

### 🎯 Python Files Recommendations

#### ✅ Keep These Files (Active/Useful)
1. **`customer_api.py`** - Main application entry point (CRITICAL)
2. **`test_db.py`** - Useful for connection testing

#### 🗂️ Move to Scripts/Utilities
1. **`debug_lines.py`** - Move to `/scripts/debug/`

#### 📦 Move to Archive/Scripts
1. **`create_db.py`** - Move to `/scripts/archive/`
2. **`create_plant_table.py`** - Move to `/scripts/archive/`
3. **`create_tank_group_table.py`** - Move to `/scripts/archive/`
4. **`migrate_customer_table.py`** - Move to `/scripts/archive/`

### 📁 Proposed Python Organization

```
scripts/
├── debug/
│   └── debug_lines.py
├── testing/
│   └── test_db.py
└── archive/
    ├── create_db.py
    ├── create_plant_table.py
    ├── create_tank_group_table.py
    └── migrate_customer_table.py
```

### Current Root Directory Status
- **`customer_api.py`** should remain in root (main application)
- All other Python files can be organized into scripts directory
- This will keep the root clean while preserving useful scripts

---

## 📄 Text Files Analysis - Root Directory

### Analysis Date: July 11, 2025

### 📊 Summary of Text Files in Root Directory

| File | Status | Purpose | Current Relevance |
|------|--------|---------|-------------------|
| `requirements.txt` | 🟢 **CRITICAL** | Python dependencies (production) | **In use - KEEP** |
| `requirements-new.txt` | 🟡 Draft | Updated dependencies list | **Redundant** |
| `startup.txt` | 🟠 Legacy | Gunicorn startup command | **Possibly outdated** |
| `documentation/stl-database.txt` | 🔴 **SECURITY RISK** | Database credentials | **Move to .env** |

### 🎯 Text Files Recommendations

#### ✅ Keep These Files (Critical/Active)
1. **`requirements.txt`** - Essential for deployment (KEEP IN ROOT)

#### ⚠️ Security Issue
1. **`documentation/stl-database.txt`** - Contains plaintext passwords
   - **Action:** Move credentials to `.env` file
   - **Remove:** This file after migration

#### 🧹 Clean Up Needed
1. **`requirements-new.txt`** - Duplicate/draft version
   - **Action:** Merge improvements into `requirements.txt`, then delete
2. **`startup.txt`** - Legacy startup command
   - **Action:** Move to `scripts/deployment/` or delete if unused

### 📁 Proposed Text Files Organization

```
# Keep in root:
requirements.txt ✅

# Move to scripts/deployment/:
startup.txt (if still needed)

# Security fix:
documentation/stl-database.txt → DELETE (move credentials to .env)

# Remove:
requirements-new.txt (after merging useful changes)
```

---

## 🧪 Test Files Analysis - Project Wide

### Analysis Date: July 11, 2025

### 📊 Summary of Test Files

| File | Location | Status | Purpose | Current Relevance |
|------|----------|--------|---------|-------------------|
| `test-simple.ps1` | Root | 🔴 Empty | PowerShell test script | **Empty - DELETE** |
| `test-local.ps1` | Root | 🔴 Empty | Local PowerShell test | **Empty - DELETE** |
| `test-local.sh` | Root | 🔴 Empty | Local bash test script | **Empty - DELETE** |
| `static/test_layout.html` | Static | 🟡 Debug | Layout testing HTML | **Development tool** |
| `tests/__init__.py` | Tests | 🟡 Minimal | Test package init | **Basic setup** |
| `scripts/testing/test_db.py` | Scripts | 🟢 Active | Database connectivity test | **Useful - KEEP** |
| `sql/testing/test_trigger*.sql` | SQL | 🟡 Utility | Database trigger tests | **Useful - KEEP** |
| `sql/archive/test_customer*.sql` | SQL | 🔴 Obsolete | Completed test script | **Archived ✅** |

### 🎯 Test Files Recommendations

#### ❌ Delete These Files (Empty/Obsolete)
1. **`test-simple.ps1`** - Empty file, no content
2. **`test-local.ps1`** - Empty file, no content  
3. **`test-local.sh`** - Empty file, no content

#### ✅ Keep These Files (Useful/Active)
1. **`scripts/testing/test_db.py`** - Database connectivity testing
2. **`sql/testing/test_trigger*.sql`** - Database functionality tests
3. **`tests/__init__.py`** - Test package structure

#### 🔧 Move/Organize These Files
1. **`static/test_layout.html`** - Move to `/scripts/testing/` (development tool)

### 📁 Proposed Test Organization

```
scripts/testing/
├── test_db.py ✅ (already organized)
├── test_layout.html (move from static/)
└── README.md (create test documentation)

sql/testing/
├── test_trigger_function.sql ✅ (already organized)
└── test_triggers.sql ✅ (already organized)

tests/
├── __init__.py ✅ (keep for future proper tests)
└── (future: proper unit tests)

# Delete from root:
❌ test-simple.ps1 (empty)
❌ test-local.ps1 (empty)  
❌ test-local.sh (empty)
```

### 🧹 Test Infrastructure Status

**Current Testing:**
- ✅ Database connectivity testing available
- ✅ SQL trigger testing available  
- ✅ Layout development testing available
- ❌ No proper unit tests yet

**Recommended Next Steps:**
1. Delete empty test scripts from root
2. Move `test_layout.html` to scripts/testing
3. Consider adding proper pytest-based unit tests in `/tests/` directory
4. Create test documentation and running instructions
