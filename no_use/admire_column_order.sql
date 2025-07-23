-- Quick preview of the beautiful column organization
-- Run this after executing the enhancement script

-- Beautiful SELECT showcasing logical column order
SELECT 
    '📋 TANK DATA PREVIEW' as info;

SELECT 
    '=== CORE IDENTIFICATION ===' as section
UNION ALL
SELECT 'id, name, type' as section
UNION ALL
SELECT '=== DIMENSIONS ===' as section  
UNION ALL
SELECT 'width, length, depth, height, wall_thickness' as section
UNION ALL
SELECT '=== POSITION ===' as section
UNION ALL
SELECT 'x_position, y_position, z_position' as section
UNION ALL
SELECT '=== VISUAL ===' as section
UNION ALL
SELECT 'color' as section
UNION ALL
SELECT '=== REVISION CONTROL ===' as section
UNION ALL
SELECT 'revision, revision_status, is_active_revision' as section
UNION ALL
SELECT '=== RELATIONSHIPS ===' as section
UNION ALL
SELECT 'tank_group_id, plant_id' as section;

-- The actual beautiful query (after enhancement)
/*
SELECT 
    -- Core identification
    id, name, type,
    -- Dimensions
    width, length, depth, height, wall_thickness,
    -- Position
    x_position, y_position, z_position,
    -- Visualization
    color,
    -- Revision control
    revision, revision_status, is_active_revision,
    -- Relationships
    tank_group_id, plant_id
FROM tank 
ORDER BY tank_group_id, name;
*/
