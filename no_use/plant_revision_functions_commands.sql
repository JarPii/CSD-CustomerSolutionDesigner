-- PLANT REVISION FUNCTIONS - Yksi funktio kerrallaan
-- Kopioi ja aja nämä yksi kerrallaan DBeaver:issa tai pgAdmin:issa
-- HUOM: Nämä funktiot helpottavat plant revision hallintaa

-- ===============================
-- VAIHE 1: GET_NEXT_REVISION_NUMBER FUNKTIO
-- ===============================

-- 1.1 Luo funktio seuraavan revision numeron hakemiseen
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

-- 1.2 Testaa funktio (pitäisi palauttaa 1 tyhjälle taululle)
SELECT get_next_revision_number(1, 'Test Plant') as next_revision;

-- ===============================
-- VAIHE 2: CREATE_NEW_REVISION FUNKTIO  
-- ===============================

-- 2.1 Luo funktio uuden revision luomiseen
DO $$
BEGIN
    EXECUTE '
    CREATE OR REPLACE FUNCTION create_new_revision(
        p_source_plant_id INTEGER,
        p_revision_name VARCHAR DEFAULT NULL,
        p_created_by VARCHAR DEFAULT ''system''
    ) RETURNS INTEGER AS $func$
    DECLARE
        source_plant RECORD;
        new_plant_id INTEGER;
        next_rev INTEGER;
    BEGIN
        -- Hae lähde plant tiedot
        SELECT * INTO source_plant FROM plant WHERE id = p_source_plant_id;
        
        IF NOT FOUND THEN
            RAISE EXCEPTION ''Source plant not found: %'', p_source_plant_id;
        END IF;
        
        -- Hae seuraava revision numero
        next_rev := get_next_revision_number(source_plant.customer_id, source_plant.name);
        
        -- Luo uusi revision
        INSERT INTO plant (
            customer_id, name, town, country,
            revision, revision_name, base_revision_id, created_from_revision,
            is_active_revision, revision_status, created_by
        ) VALUES (
            source_plant.customer_id, source_plant.name, source_plant.town, source_plant.country,
            next_rev, COALESCE(p_revision_name, ''Revision '' || next_rev), 
            p_source_plant_id, source_plant.revision,
            FALSE, ''DRAFT'', p_created_by
        ) RETURNING id INTO new_plant_id;
        
        RETURN new_plant_id;
    END;
    $func$ LANGUAGE plpgsql;';
END $$;

-- 2.2 Varmista funktio luotu
SELECT proname FROM pg_proc WHERE proname = 'create_new_revision';

-- ===============================
-- VAIHE 3: ACTIVATE_REVISION FUNKTIO
-- ===============================

-- 3.1 Luo funktio revision aktivointiin
CREATE OR REPLACE FUNCTION activate_revision(p_plant_id INTEGER) 
RETURNS BOOLEAN AS $$
DECLARE
    target_plant RECORD;
    current_active_id INTEGER;
BEGIN
    -- Hae kohde plant tiedot
    SELECT * INTO target_plant FROM plant WHERE id = p_plant_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Plant not found: %', p_plant_id;
    END IF;
    
    IF target_plant.revision_status = 'ACTIVE' THEN
        RETURN TRUE; -- Jo aktiivinen
    END IF;
    
    IF target_plant.revision_status = 'ARCHIVED' THEN
        RAISE EXCEPTION 'Cannot activate archived revision';
    END IF;
    
    -- Etsi nykyinen aktiivinen revision
    SELECT id INTO current_active_id 
    FROM plant 
    WHERE customer_id = target_plant.customer_id 
      AND name = target_plant.name 
      AND is_active_revision = TRUE;
    
    -- Deaktivoi nykyinen aktiivinen revision
    IF current_active_id IS NOT NULL THEN
        UPDATE plant 
        SET is_active_revision = FALSE, 
            revision_status = 'ARCHIVED',
            archived_at = CURRENT_TIMESTAMP
        WHERE id = current_active_id;
    END IF;
    
    -- Aktivoi kohde revision
    UPDATE plant 
    SET is_active_revision = TRUE, 
        revision_status = 'ACTIVE'
    WHERE id = p_plant_id;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- 3.2 Varmista funktio luotu
SELECT proname FROM pg_proc WHERE proname = 'activate_revision';

-- ===============================
-- VAIHE 4: ARCHIVE_REVISION FUNKTIO
-- ===============================

-- 4.1 Luo funktio revision arkistointiin
CREATE OR REPLACE FUNCTION archive_revision(p_plant_id INTEGER)
RETURNS BOOLEAN AS $$
DECLARE
    target_plant RECORD;
BEGIN
    -- Hae kohde plant tiedot
    SELECT * INTO target_plant FROM plant WHERE id = p_plant_id;
    
    IF NOT FOUND THEN
        RAISE EXCEPTION 'Plant not found: %', p_plant_id;
    END IF;
    
    IF target_plant.revision_status = 'ARCHIVED' THEN
        RETURN TRUE; -- Jo arkistoitu
    END IF;
    
    IF target_plant.is_active_revision = TRUE THEN
        RAISE EXCEPTION 'Cannot archive active revision. Activate another revision first.';
    END IF;
    
    -- Arkistoi revision
    UPDATE plant 
    SET revision_status = 'ARCHIVED',
        archived_at = CURRENT_TIMESTAMP
    WHERE id = p_plant_id;
    
    RETURN TRUE;
END;
$$ LANGUAGE plpgsql;

-- 4.2 Varmista funktio luotu
SELECT proname FROM pg_proc WHERE proname = 'archive_revision';

-- ===============================
-- VAIHE 5: GET_ACTIVE_PLANT FUNKTIO
-- ===============================

-- 5.1 Luo funktio aktiivisen plantin hakemiseen
CREATE OR REPLACE FUNCTION get_active_plant(p_customer_id INTEGER, p_plant_name VARCHAR)
RETURNS INTEGER AS $$
DECLARE
    active_plant_id INTEGER;
BEGIN
    SELECT id INTO active_plant_id
    FROM plant 
    WHERE customer_id = p_customer_id 
      AND name = p_plant_name 
      AND is_active_revision = TRUE
      AND revision_status = 'ACTIVE';
    
    RETURN active_plant_id;
END;
$$ LANGUAGE plpgsql;

-- 5.2 Varmista funktio luotu
SELECT proname FROM pg_proc WHERE proname = 'get_active_plant';

-- ===============================
-- VAIHE 6: LIST_PLANT_REVISIONS FUNKTIO
-- ===============================

-- 6.1 Luo funktio kaikkien revision listauksen (table function)
CREATE OR REPLACE FUNCTION list_plant_revisions(p_customer_id INTEGER, p_plant_name VARCHAR)
RETURNS TABLE(
    id INTEGER,
    revision INTEGER,
    revision_name VARCHAR,
    revision_status VARCHAR,
    is_active_revision BOOLEAN,
    created_by VARCHAR,
    created_at TIMESTAMP,
    archived_at TIMESTAMP
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id,
        p.revision,
        p.revision_name,
        p.revision_status,
        p.is_active_revision,
        p.created_by,
        p.created_at,
        p.archived_at
    FROM plant p
    WHERE p.customer_id = p_customer_id 
      AND p.name = p_plant_name
    ORDER BY p.revision DESC;
END;
$$ LANGUAGE plpgsql;

-- 6.2 Varmista funktio luotu
SELECT proname FROM pg_proc WHERE proname = 'list_plant_revisions';

-- ===============================
-- VAIHE 7: LOPULLINEN TARKISTUS
-- ===============================

-- 7.1 Tarkista kaikki luodut funktiot
SELECT proname, proargnames 
FROM pg_proc 
WHERE proname IN (
    'get_next_revision_number',
    'create_new_revision', 
    'activate_revision',
    'archive_revision',
    'get_active_plant',
    'list_plant_revisions'
)
ORDER BY proname;

-- 7.2 Testaa get_next_revision_number funktio
SELECT get_next_revision_number(999, 'NonExistent') as should_be_1;

-- ===============================
-- ONNISTUMISVIESTIN PITÄISI NÄYTTÄÄ:
-- ===============================
-- 6 uutta funktiota luotu:
-- - get_next_revision_number(customer_id, plant_name) -> INTEGER
-- - create_new_revision(source_id, [name], [created_by]) -> INTEGER
-- - activate_revision(plant_id) -> BOOLEAN  
-- - archive_revision(plant_id) -> BOOLEAN
-- - get_active_plant(customer_id, plant_name) -> INTEGER
-- - list_plant_revisions(customer_id, plant_name) -> TABLE
--
-- Kaikki funktiot valmiita käyttöön!
-- ===============================
