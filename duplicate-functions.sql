-- ============================================================
--  SQL: get_duplicate_candidates()
--  PostGIS function called by the duplicate detection engine
-- ============================================================

CREATE OR REPLACE FUNCTION get_duplicate_candidates(
  p_city_id   INT,
  p_type_id   INT,
  p_operation TEXT,
  p_lat       NUMERIC DEFAULT NULL,
  p_lng       NUMERIC DEFAULT NULL,
  p_radius_m  INT     DEFAULT 500,
  p_limit     INT     DEFAULT 50
)
RETURNS TABLE (
  id             UUID,
  ref_code       TEXT,
  title_ar       TEXT,
  description_ar TEXT,
  price          NUMERIC,
  area_total     NUMERIC,
  bedrooms       INT,
  bathrooms      INT,
  floor          INT,
  latitude       NUMERIC,
  longitude      NUMERIC,
  image_hash     TEXT[]
)
LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
  RETURN QUERY
  SELECT
    p.id, p.ref_code, p.title_ar, p.description_ar,
    p.price, p.area_total, p.bedrooms, p.bathrooms, p.floor,
    ST_Y(p.location::geometry)::NUMERIC  AS latitude,
    ST_X(p.location::geometry)::NUMERIC  AS longitude,
    p.image_hash
  FROM properties p
  WHERE
    p.status    IN ('active', 'pending')
    AND p.city_id    = p_city_id
    AND p.type_id    = p_type_id
    AND p.operation  = p_operation
    -- Geo filter: only if lat/lng provided
    AND (
      p_lat IS NULL OR p_lng IS NULL OR
      ST_DWithin(
        p.location::geography,
        ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326)::geography,
        p_radius_m
      )
    )
  ORDER BY
    CASE
      WHEN p_lat IS NOT NULL AND p_lng IS NOT NULL
      THEN ST_Distance(
        p.location::geography,
        ST_SetSRID(ST_MakePoint(p_lng, p_lat), 4326)::geography
      )
      ELSE 0
    END ASC
  LIMIT p_limit;
END;
$$;


-- ============================================================
--  SQL: increment_views() and increment_contacts() RPCs
-- ============================================================

CREATE OR REPLACE FUNCTION increment_views(pid UUID)
RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
  UPDATE properties SET views_count = views_count + 1 WHERE id = pid;
END;
$$;

CREATE OR REPLACE FUNCTION increment_contacts(pid UUID)
RETURNS VOID LANGUAGE plpgsql AS $$
BEGIN
  UPDATE properties SET contacts_count = contacts_count + 1 WHERE id = pid;
END;
$$;


-- ============================================================
--  SQL: auto_reject_duplicate trigger
--  Fires BEFORE INSERT on properties
-- ============================================================

-- Note: actual scoring is done in TypeScript.
-- This trigger handles the fast-path: exact image hash match.

CREATE OR REPLACE FUNCTION check_exact_duplicate()
RETURNS TRIGGER AS $$
DECLARE
  existing_id UUID;
BEGIN
  -- Fast path: identical image hashes (MD5 level)
  IF NEW.image_hash IS NOT NULL AND array_length(NEW.image_hash, 1) > 0 THEN
    SELECT id INTO existing_id
    FROM properties
    WHERE
      status IN ('active', 'pending')
      AND city_id = NEW.city_id
      AND image_hash && NEW.image_hash   -- array overlap
    LIMIT 1;

    IF existing_id IS NOT NULL THEN
      -- Mark as duplicate, don't auto-reject — let TS engine score it
      NEW.duplicate_of := existing_id;
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_duplicate
  BEFORE INSERT ON properties
  FOR EACH ROW
  EXECUTE FUNCTION check_exact_duplicate();
