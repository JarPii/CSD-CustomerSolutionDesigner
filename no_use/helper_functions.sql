-- HELPER FUNCTIONS - Aja vasta kun numbering migration on valmis
-- Nämä funktiot auttavat automaattisessa numeroinnissa

-- ===============================
-- FUNKTIO 1: SEURAAVA LINJANUMERO
-- ===============================

CREATE OR REPLACE FUNCTION get_next_line_number(p_plant_id INTEGER)
RETURNS INTEGER AS $$
DECLARE
    next_num INTEGER;
BEGIN
    SELECT COALESCE(MAX(number), 0) + 1 
    INTO next_num
    FROM line 
    WHERE plant_id = p_plant_id;
    
    RETURN next_num;
END;
$$ LANGUAGE plpgsql;

-- Testaa funktio:
-- SELECT get_next_line_number(1);

-- ===============================
-- FUNKTIO 2: SEURAAVA TANK GROUP NUMERO
-- ===============================

CREATE OR REPLACE FUNCTION get_next_tank_group_number(p_line_id INTEGER)
RETURNS INTEGER AS $$
DECLARE
    line_num INTEGER;
    next_seq INTEGER;
    next_num INTEGER;
BEGIN
    -- Hae linjan numero
    SELECT number INTO line_num FROM line WHERE id = p_line_id;
    
    IF line_num IS NULL THEN
        RAISE EXCEPTION 'Line not found: %', p_line_id;
    END IF;
    
    -- Laske seuraava sekvenssi tälle linjalle
    SELECT COALESCE(MAX(number - (line_num * 100)), 0) + 1 
    INTO next_seq
    FROM tank_group tg
    JOIN line l ON tg.line_id = l.id
    WHERE l.id = p_line_id;
    
    next_num := line_num * 100 + next_seq;
    
    RETURN next_num;
END;
$$ LANGUAGE plpgsql;

-- Testaa funktio:
-- SELECT get_next_tank_group_number(1);

-- ===============================
-- FUNKTIO 3: SEURAAVA TANK NUMERO
-- ===============================

CREATE OR REPLACE FUNCTION get_next_tank_number(p_tank_group_id INTEGER)
RETURNS INTEGER AS $$
DECLARE
    base_num INTEGER;
    next_seq INTEGER;
    next_num INTEGER;
BEGIN
    -- Hae tank groupin numero perusnumeroksi
    SELECT number INTO base_num FROM tank_group WHERE id = p_tank_group_id;
    
    IF base_num IS NULL THEN
        RAISE EXCEPTION 'Tank group not found: %', p_tank_group_id;
    END IF;
    
    -- Laske seuraava sekvenssi rinnakkaisille tankeille (0, 1, 2...)
    SELECT COALESCE(MAX(number - base_num), -1) + 1 
    INTO next_seq
    FROM tank 
    WHERE tank_group_id = p_tank_group_id;
    
    next_num := base_num + next_seq;
    
    RETURN next_num;
END;
$$ LANGUAGE plpgsql;

-- Testaa funktio:
-- SELECT get_next_tank_number(1);

-- ===============================
-- TESTAA KAIKKI FUNKTIOT
-- ===============================

-- Tarkista että funktiot on luotu
SELECT routine_name, routine_type 
FROM information_schema.routines 
WHERE routine_name LIKE 'get_next_%'
ORDER BY routine_name;

-- Pitäisi näyttää:
-- get_next_line_number | FUNCTION
-- get_next_tank_group_number | FUNCTION  
-- get_next_tank_number | FUNCTION

-- ===============================
-- LISÄÄ KOMMENTIT SARAKKEISIIN
-- ===============================

COMMENT ON COLUMN line.number IS 'Physical line number (1,2,3...) matching plant layout and documentation (renamed from line_number)';

COMMENT ON COLUMN tank_group.number IS 'Station number (101,102,201,202...) = line*100 + sequence, or minimum tank number in group';

COMMENT ON COLUMN tank.number IS 'Tank station number matching tank group for process identification';

-- ===============================
-- LOPULLINEN TARKISTUS
-- ===============================

SELECT 'Migration completed successfully!' as status;
