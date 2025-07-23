# STL PostgreSQL Database Schema

Tämä dokumentti kuvaa Azure-ympäristössä olevan STL-projektin PostgreSQL-tietokannan rakenteen.

## Yleistä
- **Tietokantatyyppi:** PostgreSQL (Azure Database for PostgreSQL)
- **Host:** stl.postgres.database.azure.com
- **Käyttäjä:** JarPii
- **Portti:** 5432
- **SSL Mode:** required

## Taulut

### customer
```sql
CREATE TABLE customer (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    town VARCHAR(255),
    country VARCHAR(255)
);
```

### plant
```sql
CREATE TABLE plant (
    id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customer(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    town VARCHAR(255),
    country VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    revision INTEGER NOT NULL DEFAULT 1,
    revision_name VARCHAR(255),
    base_revision_id INTEGER REFERENCES plant(id),
    created_from_revision INTEGER,
    is_active_revision BOOLEAN NOT NULL DEFAULT TRUE,
    revision_status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE' CHECK (revision_status IN ('DRAFT', 'ACTIVE', 'ARCHIVED')),
    created_by VARCHAR(255) NOT NULL DEFAULT 'system',
    archived_at TIMESTAMP,
    UNIQUE(customer_id, name, revision)
);
```

### line
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

### tank
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

### tank_group
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

### customer_product
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

### production_requirement
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

### chat_session
```sql
CREATE TABLE chat_session (
    id SERIAL PRIMARY KEY,
    session_name VARCHAR(255),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT TRUE
);
```

### chat_message
```sql
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

### device
```sql
CREATE TABLE device (
    id SERIAL PRIMARY KEY,
    name VARCHAR NOT NULL,
    manufacturer VARCHAR,
    model VARCHAR,
    type VARCHAR,
    generic BOOLEAN NOT NULL
);
```

### function
```sql
CREATE TABLE function (
    id SERIAL PRIMARY KEY,
    name VARCHAR NOT NULL,
    functional_description VARCHAR
);
```

### function_device
```sql
CREATE TABLE function_device (
    function_id INTEGER NOT NULL REFERENCES function(id) ON DELETE CASCADE,
    device_id INTEGER NOT NULL REFERENCES device(id) ON DELETE CASCADE,
    PRIMARY KEY (function_id, device_id)
);
```
