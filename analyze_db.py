#!/usr/bin/env python3
"""
Analyze current database structure and compare with documentation
"""
import os
from sqlalchemy import create_engine, text
from dotenv import load_dotenv

# Load environment variables
load_dotenv('.env.local')

def analyze_database_structure():
    """Analyze current database structure"""
    engine = create_engine(os.getenv('DATABASE_URL'))
    
    print('=== ANALYZING DATABASE STRUCTURE ===\n')
    
    with engine.connect() as conn:
        # Get all tables
        result = conn.execute(text("""
            SELECT table_name 
            FROM information_schema.tables 
            WHERE table_schema = 'public' 
            ORDER BY table_name
        """))
        tables = [row[0] for row in result.fetchall()]
        
        print(f'📋 Found {len(tables)} tables: {tables}\n')
        
        # For each table, get detailed structure
        for table in tables:
            print(f'=== TABLE: {table.upper()} ===')
            
            # Get columns
            result = conn.execute(text(f"""
                SELECT 
                    column_name,
                    data_type,
                    is_nullable,
                    column_default,
                    character_maximum_length
                FROM information_schema.columns 
                WHERE table_name = '{table}' 
                ORDER BY ordinal_position
            """))
            
            columns = result.fetchall()
            print('Columns:')
            for col in columns:
                nullable = 'NULL' if col[2] == 'YES' else 'NOT NULL'
                default = f' DEFAULT {col[3]}' if col[3] else ''
                length = f'({col[4]})' if col[4] else ''
                print(f'  - {col[0]}: {col[1]}{length} {nullable}{default}')
            
            # Get constraints
            result = conn.execute(text(f"""
                SELECT 
                    tc.constraint_name,
                    tc.constraint_type,
                    kcu.column_name,
                    ccu.table_name AS foreign_table_name,
                    ccu.column_name AS foreign_column_name
                FROM information_schema.table_constraints tc
                LEFT JOIN information_schema.key_column_usage kcu 
                    ON tc.constraint_name = kcu.constraint_name
                LEFT JOIN information_schema.constraint_column_usage ccu 
                    ON tc.constraint_name = ccu.constraint_name
                WHERE tc.table_name = '{table}'
                ORDER BY tc.constraint_type, tc.constraint_name
            """))
            
            constraints = result.fetchall()
            if constraints:
                print('Constraints:')
                for constraint in constraints:
                    if constraint[1] == 'PRIMARY KEY':
                        print(f'  - PRIMARY KEY: {constraint[2]}')
                    elif constraint[1] == 'FOREIGN KEY':
                        print(f'  - FOREIGN KEY: {constraint[2]} -> {constraint[3]}.{constraint[4]}')
                    elif constraint[1] == 'UNIQUE':
                        print(f'  - UNIQUE: {constraint[2]}')
                    elif constraint[1] == 'CHECK':
                        print(f'  - CHECK: {constraint[0]}')
            
            # Get indexes
            result = conn.execute(text(f"""
                SELECT indexname, indexdef 
                FROM pg_indexes 
                WHERE tablename = '{table}' 
                AND indexname NOT LIKE '%_pkey'
                ORDER BY indexname
            """))
            
            indexes = result.fetchall()
            if indexes:
                print('Indexes:')
                for idx in indexes:
                    print(f'  - {idx[0]}: {idx[1]}')
            
            print()

if __name__ == "__main__":
    analyze_database_structure()
