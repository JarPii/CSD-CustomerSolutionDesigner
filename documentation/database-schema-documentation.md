# Database Schema Documentation

This document provides comprehensive documentation for the STL Optimization Visualization database schema, including the revision control system for plant configurations.

## Database Overview

- **Database Type**: PostgreSQL (Azure Database for PostgreSQL)
- **Host**: stl.postgres.database.azure.com
- **Database**: postgres
- **User**: JarPii
- **Password**: !V41k33!
- **Port**: 5432
- **SSL Mode**: required

## Core Tables


### customer
Customer information and management.

```sql
CREATE TABLE customer (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    town VARCHAR(255),
    country VARCHAR(255)
    -- created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    -- updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Key Features:**
- Unique customer identification
- Geographic location information (`town`, `country`)
- Name is required, location fields are optional

**Note:** This table uses singular naming convention and stores location information instead of contact details.

### plant
Plant facilities belonging to customers with full revision control system.

```sql
CREATE TABLE plant (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customer(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    town VARCHAR(255),
    country VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- Revision Control Fields
    revision INTEGER NOT NULL DEFAULT 1,
    revision_name VARCHAR(255),
    base_revision_id INTEGER REFERENCES plant(id),
    created_from_revision INTEGER,
    is_active_revision BOOLEAN NOT NULL DEFAULT TRUE,
    revision_status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' 
        CHECK (revision_status IN ('DRAFT', 'ACTIVE', 'ARCHIVED')),
    created_by VARCHAR(255) NOT NULL DEFAULT 'system',
    archived_at TIMESTAMP,
    
    -- Unique constraints for revision system
    UNIQUE(customer_id, name, revision)
);
```

**Revision Control Features:**
- **revision**: Sequential revision number for each plant name within customer
- **revision_name**: Human-readable description of the revision
- **base_revision_id**: Reference to the original plant this revision was created from
- **created_from_revision**: Revision number this was created from (for tracking history)
- **is_active_revision**: Boolean flag indicating the currently active revision
- **revision_status**: DRAFT (editable), ACTIVE (current), ARCHIVED (historical)
- **created_by**: User who created this revision
- **archived_at**: Timestamp when revision was archived

**Revision Rules:**
- Only one revision per plant can be ACTIVE at a time
- New revisions start as DRAFT
- Only ACTIVE revisions can be activated (made current)
- Only DRAFT revisions can be deleted
- ARCHIVED revisions are read-only historical records

### line
Production lines within plants.

```sql
CREATE TABLE line (
    id SERIAL PRIMARY KEY,
    plant_id INTEGER NOT NULL REFERENCES plant(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    number INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(plant_id, name),
    UNIQUE(plant_id, number)
);
```

**Key Features:**
- Belongs to a specific plant
- Unique name and number within each plant
- **Physical line numbering**: Sequential numbering for physical layout and documentation consistency
- **Cross-reference compatibility**: Line numbers match P&ID, mechanical, electrical, and UI documentation
- Cascade deletion with plant

**Numbering Convention:**
- **Default starting point**: Line 1, 2, 3... (user configurable)
- **Physical layout**: Numbers reflect actual physical position in plant
- **Documentation consistency**: Same numbers used across all engineering documents

### tank
Individual storage/process tanks within tank groups (process stages).

```sql
CREATE TABLE tank (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    tank_group_id INTEGER NOT NULL REFERENCES tank_group(id) ON DELETE CASCADE,
    plant_id INTEGER NOT NULL REFERENCES plant(id) ON DELETE CASCADE,
    number INTEGER NOT NULL,
    width INTEGER,
    length INTEGER, 
    depth INTEGER,
    space INTEGER,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(name, tank_group_id),
    UNIQUE(tank_group_id, number)
);
```

**Key Features:**
- **Individual tank within process group**: Each tank belongs to specific process stage
- **Parallel processing capability**: Multiple tanks in same group work in parallel
- **Physical dimensions**: width, length, depth for engineering calculations
- **Unique naming**: Tank names unique within their process group
- **Process interchangeability**: Tanks in same group can substitute each other

**Numbering Logic:**
- **Numbering Logic:**
- **Station-based numbering**: Tank numbers are station numbers within the tank group
- **Sequential within group**: 101, 102, 103... for parallel tanks in same process stage
- **Tank group inherits**: Group number = MIN(tank numbers) in that group
- **Physical positioning**: Numbers reflect actual tank positions in line
- **Documentation consistency**: Same numbers across P&ID, mechanical, electrical docs

**Process Integration:**
- Treatment programs target tank_group, not individual tanks
- Load balancing distributes work across parallel tanks in group
- Chemical recipes defined at group level, applied to all tanks
- Maintenance scheduling can target entire process groups

### tank_group
Process stage grouping for parallel tanks in production lines.

```sql
CREATE TABLE tank_group (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    plant_id INTEGER NOT NULL REFERENCES plant(id) ON DELETE CASCADE,
    line_id INTEGER NOT NULL REFERENCES line(id) ON DELETE CASCADE, 
    number INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(line_id, number)
);
```

**Key Features:**
- **Process stage definition**: Groups tanks that perform the same process step
- **Parallel tank support**: Multiple tanks can belong to same process group
- **Treatment program targeting**: Programs can target entire tank groups
- **Chemical compatibility**: All tanks in group use same chemicals/procedures

**Numbering Logic:**
- **Sequential stations**: Continuous numbering along the production line
- **Default starting**: Typically starts from line.number * 100 + 1 (e.g., Line 1 → stations 101, 102, 103...)
- **User configurable**: Can be manually set for non-standard layouts
- **Tank group number = MIN(tank numbers in group)**: Group inherits the smallest tank number within it

**Process Examples:**
- "Pre-wash Tanks" (Station 101) - Multiple parallel pre-washing tanks
- "Acid Bath Group" (Station 102) - Parallel acid treatment tanks  
- "Rinse Station" (Station 103) - Multiple rinse tanks working in parallel
- "Drying Chamber" (Station 104) - Parallel drying tanks

**Business Logic:**
- Tanks in same group are **interchangeable** in production
- Treatment programs apply to **entire groups**, not individual tanks
- Simplifies process control and chemical management
- Enables load balancing across parallel tanks

## Additional Tables

### customer_product
Customer-specific products that are manufactured in plants.

```sql
CREATE TABLE customer_product (
    id SERIAL PRIMARY KEY,
    plant_id INTEGER NOT NULL REFERENCES plant(id),
    product_name VARCHAR(255) NOT NULL,
    product_code VARCHAR(100),
    description TEXT,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

**Key Features:**
- Links products to specific manufacturing plants
- Supports product codes and detailed descriptions
- Used for production planning and requirements

### production_requirement
Production planning and capacity requirements for customer products.

```sql
CREATE TABLE production_requirement (
    id SERIAL PRIMARY KEY,
    plant_id INTEGER NOT NULL REFERENCES plant(id),
    product_id INTEGER NOT NULL REFERENCES customer_product(id),
    annual_volume INTEGER NOT NULL,
    working_days_per_year INTEGER DEFAULT 250,
    working_hours_per_day NUMERIC(4,2) DEFAULT 8.0,
    shifts_per_day INTEGER DEFAULT 1,
    target_pieces_per_hour NUMERIC(10,2),
    target_cycle_time_minutes NUMERIC(8,2),
    batch_size INTEGER DEFAULT 1 NOT NULL,
    target_batches_per_hour NUMERIC(10,2),
    priority_level INTEGER DEFAULT 1,
    status VARCHAR(50) DEFAULT 'draft',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Key Features:**
- Detailed production planning parameters
- Supports both piece-based and batch-based production
- Flexible working schedule configuration
- Priority-based production planning

### chat_session and chat_message
AI chat system for plant optimization assistance.

```sql
CREATE TABLE chat_session (
    id SERIAL PRIMARY KEY,
    session_name VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT TRUE
);

CREATE TABLE chat_message (
    id SERIAL PRIMARY KEY,
    session_id INTEGER NOT NULL REFERENCES chat_session(id) ON DELETE CASCADE,
    message_type VARCHAR(20) NOT NULL CHECK (message_type IN ('user', 'assistant')),
    content TEXT NOT NULL,
    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    tokens_used INTEGER,
    model_name VARCHAR(100)
);
```

**Key Features:**
- Session-based chat history
- Tracks AI model usage and token consumption
- Supports both user and assistant messages

### device and function
Generic device and function modeling system.

```sql
CREATE TABLE device (
    id SERIAL PRIMARY KEY,
    name VARCHAR NOT NULL,
    manufacturer VARCHAR,
    model VARCHAR,
    type VARCHAR,
    generic BOOLEAN NOT NULL
);

CREATE TABLE function (
    id SERIAL PRIMARY KEY,
    name VARCHAR NOT NULL,
    functional_description VARCHAR
);

CREATE TABLE function_device (
    function_id INTEGER NOT NULL REFERENCES function(id) ON DELETE CASCADE,
    device_id INTEGER NOT NULL REFERENCES device(id) ON DELETE CASCADE,
    PRIMARY KEY (function_id, device_id)
);
```

**Key Features:**
- Device catalog with manufacturer and model information
- Function-based device categorization
- Many-to-many relationship between functions and devices
- Supports both generic and specific device types

## Revision Control System

### PostgreSQL Functions

The following functions automate revision management:

#### get_next_revision_number(customer_id, plant_name)
```sql
CREATE OR REPLACE FUNCTION get_next_revision_number(p_customer_id INTEGER, p_plant_name VARCHAR)
RETURNS INTEGER AS $$
DECLARE
    next_rev INTEGER;
BEGIN
    SELECT COALESCE(MAX(revision), 0) + 1 
    INTO next_rev
    FROM plant 
    WHERE customer_id = p_customer_id AND name = p_plant_name;
    
    RETURN next_rev;
END;
$$ LANGUAGE plpgsql;
```

#### create_new_revision(source_plant_id, revision_name, created_by)
```sql
CREATE OR REPLACE FUNCTION create_new_revision(
    p_source_plant_id INTEGER,
    p_revision_name VARCHAR DEFAULT NULL,
    p_created_by VARCHAR DEFAULT 'system'
) RETURNS INTEGER AS $$
DECLARE
    source_plant RECORD;
    new_plant_id INTEGER;
    next_rev INTEGER;
BEGIN
    -- Get source plant details
    SELECT * INTO source_plant FROM plant WHERE id = p_source_plant_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Source plant not found: %', p_source_plant_id;
    END IF;
    
    -- Get next revision number
    next_rev := get_next_revision_number(source_plant.customer_id, source_plant.name);
    
    -- Create new revision
    INSERT INTO plant (
        customer_id, name, town, country,
        revision, revision_name, base_revision_id, created_from_revision,
        is_active_revision, revision_status, created_by
    ) VALUES (
        source_plant.customer_id, source_plant.name, source_plant.town, source_plant.country,
        next_rev, COALESCE(p_revision_name, 'Revision ' || next_rev), 
        p_source_plant_id, source_plant.revision,
        FALSE, 'DRAFT', p_created_by
    ) RETURNING id INTO new_plant_id;
    
    RETURN new_plant_id;
END;
$$ LANGUAGE plpgsql;
```

#### activate_revision(plant_id)
```sql
CREATE OR REPLACE FUNCTION activate_revision(p_plant_id INTEGER) 
RETURNS BOOLEAN AS $$
DECLARE
    target_plant RECORD;
    current_active_id INTEGER;
BEGIN
    -- Get target plant details
    SELECT * INTO target_plant FROM plant WHERE id = p_plant_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Plant not found: %', p_plant_id;
    END IF;
    
    IF target_plant.revision_status = 'ACTIVE' THEN
        RETURN TRUE; -- Already active
    END IF;
    
    IF target_plant.revision_status = 'ARCHIVED' THEN
        RAISE EXCEPTION 'Cannot activate archived revision';
    END IF;
    
    -- Find current active revision
    SELECT id INTO current_active_id 
    FROM plant 
    WHERE customer_id = target_plant.customer_id 
      AND name = target_plant.name 
      AND is_active_revision = TRUE;
    
    -- Deactivate current active revision
    IF current_active_id IS NOT NULL THEN
        UPDATE plant 
        SET is_active_revision = FALSE, 
            revision_status = 'ARCHIVED',
            archived_at = CURRENT_TIMESTAMP
        WHERE id = current_active_id;
    END IF;
    
    -- Activate target revision
    UPDATE plant 
    SET is_active_revision = TRUE, 
        revision_status = 'ACTIVE'
    WHERE id = p_plant_id;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;
```

## Relationships and Constraints

### Foreign Key Relationships
```
customer (1) ──→ (N) plant
plant (1) ──→ (N) line  
line (1) ──→ (N) tank_group (process stages)
tank_group (1) ──→ (N) tank (parallel tanks in same process)
plant (1) ──→ (N) plant (self-referencing for revisions)
```

**Process Hierarchy Explanation:**
- **tank_group**: Represents a process stage (e.g., "Pre-wash", "Acid Bath", "Rinse")
- **tank**: Individual parallel tanks within the same process stage
- This enables treatment programs to target entire process groups
- Parallel tanks in same group can be used interchangeably in production

### Unique Constraints
- `customer.name` (in practice, enforced by business logic)
- `plant(customer_id, name, revision)` - Full revision control implemented
- `line(plant_id, name)` - Unique line names within plant
- `line(plant_id, number)` - Unique line numbers within plant
- `tank_group(line_id, number)` - Unique tank group numbers within line
- `tank(name, tank_group_id)` - Unique tank names within tank group
- `tank(tank_group_id, number)` - Unique tank numbers within tank group

### Check Constraints
- `plant.revision_status` must be one of: 'DRAFT', 'ACTIVE', 'ARCHIVED'
- Only one active revision per plant name within customer

## Common Queries

### Get Active Plants for Customer
```sql
SELECT p.*, c.name as customer_name 
FROM plant p 
JOIN customer c ON p.customer_id = c.id 
WHERE p.customer_id = ? 
ORDER BY p.name;
```

### Get All Revisions of a Plant
```sql
SELECT * FROM plant 
WHERE customer_id = ? AND name = ?
ORDER BY revision DESC;
```

### Get Plant Structure with Process Groups and Tanks
```sql
SELECT 
    p.name as plant_name,
    l.number as line_number,
    l.name as line_name,
    tg.number as tank_group_number,
    tg.name as process_group_name,
    t.number as tank_number,
    t.name as tank_name,
    t.width, t.length, t.depth,
    COUNT(*) OVER (PARTITION BY tg.id) as parallel_tanks_in_group
FROM plant p
LEFT JOIN line l ON p.id = l.plant_id
LEFT JOIN tank_group tg ON l.id = tg.line_id
LEFT JOIN tank t ON tg.id = t.tank_group_id
WHERE p.id = ?
ORDER BY l.number, tg.number, t.number;
```

**Numbering Example Output:**
```
Line 1 → Tank Groups 101,102,103 → Tanks 101,102,103
Line 2 → Tank Groups 201,202,203 → Tanks 201,202,203
```

### Get Parallel Tanks for Process Stage
```sql
-- Get all parallel tanks in same process group
SELECT 
    tg.name as process_stage,
    t.name as tank_name,
    t.width, t.length, t.depth,
    'Available for parallel processing' as status
FROM tank_group tg
JOIN tank t ON tg.id = t.tank_group_id 
WHERE tg.id = ?
ORDER BY t.number;
```

### Treatment Program to Tank Group Mapping
```sql
-- Treatment programs target tank groups (process stages), not individual tanks
SELECT 
    tp.program_name,
    ps.stage as process_step,
    ps.description,
    tg.name as target_tank_group,
    COUNT(t.id) as available_parallel_tanks
FROM treatment_program tp
JOIN program_step ps ON tp.id = ps.treatment_program_id
JOIN tank_group tg ON ps.min_station <= tg.number AND ps.max_station >= tg.number
LEFT JOIN tank t ON tg.id = t.tank_group_id
WHERE tp.plant_id = ?
GROUP BY tp.program_name, ps.stage, ps.description, tg.name
ORDER BY ps.stage;
```

### Create New Plant Revision
```sql
-- Using function
SELECT create_new_revision(?, 'Feature enhancement', 'user@example.com');

-- Manual approach
INSERT INTO plant (customer_id, name, town, country, revision, revision_name, base_revision_id, created_from_revision, is_active_revision, revision_status, created_by)
SELECT customer_id, name, town, country, 
       (SELECT MAX(revision) + 1 FROM plant p2 WHERE p2.customer_id = p1.customer_id AND p2.name = p1.name),
       'New revision name',
       p1.id,
       p1.revision,
       FALSE,
       'DRAFT',
       'username'
FROM plant p1 WHERE p1.id = ?;
```

### Activate Revision
```sql
-- Using function
SELECT activate_revision(?);

-- Manual approach (more complex, use function instead)
UPDATE plant SET is_active_revision = FALSE WHERE customer_id = ? AND name = ? AND is_active_revision = TRUE;
UPDATE plant SET is_active_revision = TRUE, revision_status = 'ACTIVE' WHERE id = ?;
```

## Indexes for Performance

```sql
-- Revision system indexes
CREATE INDEX idx_plant_active_revision ON plant(customer_id, name, is_active_revision);
CREATE INDEX idx_plant_revision_status ON plant(revision_status);
CREATE INDEX idx_plant_base_revision ON plant(base_revision_id);
CREATE INDEX idx_plant_customer_name ON plant(customer_id, name);

-- General performance indexes
CREATE INDEX idx_line_plant_id ON line(plant_id);
CREATE INDEX idx_customer_name ON customer(name);
```

## Migration Notes

### Revision System Implementation Status
The revision system has been successfully implemented:

1. All existing plants have `revision = 1`
2. All existing plants have `is_active_revision = TRUE`
3. All existing plants have `revision_status = 'ACTIVE'`
4. `created_by` defaults to 'system'

### Backup Before Major Changes
```sql
-- Create backup of existing plants
CREATE TABLE plant_backup AS SELECT * FROM plant;
```

### Verification Queries
```sql
-- Verify all plants have revision fields
SELECT COUNT(*) FROM plant WHERE revision IS NULL OR is_active_revision IS NULL;

-- Should return 0 if everything is correct
SELECT COUNT(*) FROM plant WHERE revision_status NOT IN ('DRAFT', 'ACTIVE', 'ARCHIVED');
```

## API Integration

The revision system integrates with the FastAPI backend through:

- **Models**: `app/models/plant.py` - SQLAlchemy model with revision fields
- **Schemas**: `app/schemas/plant.py` - Pydantic validation with revision schemas
- **Routes**: `app/routers/plants.py` - API endpoints for revision management

Key API endpoints:
- `GET /plants/{plant_id}/revisions` - List all revisions
- `POST /plants/{plant_id}/revisions` - Create new revision
- `PUT /plants/{plant_id}/revisions/activate` - Activate revision
- `GET /plants/{plant_id}/active` - Get active revision
- `DELETE /plants/{plant_id}/revisions` - Delete draft revision

## Numbering Convention System

### Physical Layout Numbering Logic

The numbering system reflects physical plant layout and ensures consistency across all documentation types (P&ID, mechanical, electrical, UI):

#### Line Numbering
- **Default**: Sequential numbering starting from 1
- **User configurable**: Can be set to any starting number
- **Physical correspondence**: Numbers match actual physical line positions

#### Tank Group (Station) Numbering  
- **Default formula**: `line.number * 100 + station_sequence`
- **Line 1**: Stations 101, 102, 103, 104...
- **Line 2**: Stations 201, 202, 203, 204...
- **Line 3**: Stations 301, 302, 303, 304...
- **User override**: Can be manually configured for non-standard layouts

#### Tank Numbering
- **Station-based**: Tank numbers are the station numbers (same as tank group)
- **Parallel tanks**: Use same base number with optional suffixes (101A, 101B) or sequential (101, 102, 103)
- **Tank group inherits**: Group number = MIN(tank numbers in that group)
- **Example**: Tanks 101, 102, 103 in parallel → Tank Group 101

#### Practical Example
```
Plant: "Galvanizing Line A"
├── Line 1 (number: 1)
│   ├── Station 101: Pre-wash (Tank Group)
│   │   ├── Tank 101: Pre-wash Tank A
│   │   └── Tank 102: Pre-wash Tank B
│   ├── Station 102: Acid Bath (Tank Group) ← Group number = MIN(103) = 103
│   │   └── Tank 103: Acid Tank
│   └── Station 104: Rinse (Tank Group)
│       ├── Tank 104: Rinse Tank A  
│       └── Tank 105: Rinse Tank B
└── Line 2 (number: 2)
    ├── Station 201: Pre-wash (Tank Group)
    └── Station 202: Acid Bath (Tank Group)
```

### Documentation Benefits
- **Cross-reference consistency**: Same numbers in P&ID, mechanical drawings, electrical schematics
- **Maintenance clarity**: Clear station/tank identification for work orders
- **Process control**: Simple station-based programming and monitoring
- **Operator interface**: Intuitive numbering for plant floor displays
- **Engineering coordination**: Unified numbering across all disciplines

## Security Considerations

1. **User Authentication**: `created_by` field should be populated from authenticated user context
2. **Authorization**: Users should only modify plants they have permission for
3. **Audit Trail**: All revision changes are tracked with timestamps and user information
4. **Data Integrity**: Foreign key constraints prevent orphaned records
5. **Backup Strategy**: Regular backups before major revision operations

## Future Enhancements

1. **Revision Comments**: Add detailed change descriptions
2. **Diff Functionality**: Compare revisions to see changes
3. **Approval Workflow**: Require approval before activating revisions
4. **Branching**: Allow multiple development branches from same base
5. **Merge Conflicts**: Handle conflicts when merging revisions
6. **Automated Backups**: Trigger backups before activation
7. **Rollback**: Quick rollback to previous active revision
