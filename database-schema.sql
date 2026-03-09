-- ============================================================
--  AQARIO – DATABASE SCHEMA (Supabase / PostgreSQL)
--  Version: 1.0 MVP
--  Date: 2026-03-01
-- ============================================================

-- Extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "postgis";        -- for geolocation
CREATE EXTENSION IF NOT EXISTS "pg_trgm";        -- for fuzzy search

-- ============================================================
-- 1. USERS
-- ============================================================
CREATE TABLE users (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  email           TEXT UNIQUE NOT NULL,
  phone           TEXT UNIQUE,
  full_name       TEXT NOT NULL,
  avatar_url      TEXT,
  role            TEXT NOT NULL DEFAULT 'individual'
                  CHECK (role IN ('individual', 'agency', 'admin')),
  lang            TEXT NOT NULL DEFAULT 'ar'
                  CHECK (lang IN ('ar', 'fr')),

  -- Verification
  phone_verified      BOOLEAN DEFAULT FALSE,
  identity_verified   BOOLEAN DEFAULT FALSE,
  ownership_verified  BOOLEAN DEFAULT FALSE,
  verified_at         TIMESTAMPTZ,

  -- Stats
  total_listings  INT DEFAULT 0,
  response_rate   NUMERIC(5,2) DEFAULT 0,     -- percentage 0-100
  avg_response_h  NUMERIC(5,1) DEFAULT 0,     -- hours

  -- Plan
  plan            TEXT NOT NULL DEFAULT 'free'
                  CHECK (plan IN ('free', 'premium', 'agency')),
  plan_expires_at TIMESTAMPTZ,

  created_at      TIMESTAMPTZ DEFAULT NOW(),
  updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
CREATE POLICY "users_own" ON users
  USING (auth.uid() = id);

-- ============================================================
-- 2. AGENCIES (extends users)
-- ============================================================
CREATE TABLE agencies (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id         UUID REFERENCES users(id) ON DELETE CASCADE,
  name            TEXT NOT NULL,
  name_fr         TEXT,
  logo_url        TEXT,
  license_number  TEXT UNIQUE,               -- numéro agrément
  city_id         INT REFERENCES cities(id),
  address         TEXT,
  website         TEXT,
  verified        BOOLEAN DEFAULT FALSE,
  listing_count   INT DEFAULT 0,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 3. CITIES
-- ============================================================
CREATE TABLE cities (
  id          SERIAL PRIMARY KEY,
  name_ar     TEXT NOT NULL,
  name_fr     TEXT NOT NULL,
  slug        TEXT UNIQUE NOT NULL,          -- ex: casablanca
  region      TEXT,
  latitude    NUMERIC(9,6),
  longitude   NUMERIC(9,6),
  active      BOOLEAN DEFAULT TRUE
);

-- Seed data
INSERT INTO cities (name_ar, name_fr, slug, region, latitude, longitude) VALUES
  ('الدار البيضاء', 'Casablanca',  'casablanca',  'Grand Casablanca', 33.5731,  -7.5898),
  ('الرباط',        'Rabat',        'rabat',        'Rabat-Salé',       34.0209,  -6.8416),
  ('مراكش',         'Marrakech',    'marrakech',    'Marrakech-Safi',   31.6295,  -7.9811),
  ('فاس',           'Fès',          'fes',          'Fès-Meknès',       34.0181,  -5.0078),
  ('طنجة',          'Tanger',       'tanger',       'Tanger-Tétouan',   35.7595,  -5.8340),
  ('أكادير',        'Agadir',       'agadir',       'Souss-Massa',      30.4278,  -9.5981),
  ('مكناس',         'Meknès',       'meknes',       'Fès-Meknès',       33.8935,  -5.5473),
  ('وجدة',          'Oujda',        'oujda',        'Oriental',         34.6867,  -1.9114),
  ('القنيطرة',      'Kénitra',      'kenitra',      'Rabat-Salé',       34.2610,  -6.5802),
  ('تطوان',         'Tétouan',      'tetouan',      'Tanger-Tétouan',   35.5785,  -5.3684);

-- ============================================================
-- 4. PROPERTY_TYPES
-- ============================================================
CREATE TABLE property_types (
  id       SERIAL PRIMARY KEY,
  name_ar  TEXT NOT NULL,
  name_fr  TEXT NOT NULL,
  slug     TEXT UNIQUE NOT NULL,
  icon     TEXT                   -- emoji or icon key
);

INSERT INTO property_types (name_ar, name_fr, slug, icon) VALUES
  ('شقة',               'Appartement',         'appartement',  '🏢'),
  ('فيلا',              'Villa',                'villa',        '🏡'),
  ('أرض',               'Terrain',              'terrain',      '🌿'),
  ('محل تجاري',          'Local commercial',     'local',        '🏪'),
  ('عقار استثماري',      'Bien d''investissement','investissement','📈'),
  ('بيت',               'Maison',               'maison',       '🏠'),
  ('مكتب',              'Bureau',               'bureau',       '🏛'),
  ('إقامة سياحية',      'Résidence touristique', 'touristique',  '🏨');

-- ============================================================
-- 5. PROPERTIES  (core table)
-- ============================================================
CREATE TABLE properties (
  id                UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  ref_code          TEXT UNIQUE NOT NULL,     -- ex: AQ-2026-00041

  -- Owner
  owner_id          UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  agency_id         UUID REFERENCES agencies(id),

  -- Classification
  type_id           INT NOT NULL REFERENCES property_types(id),
  operation         TEXT NOT NULL CHECK (operation IN ('sale', 'rent', 'both')),
  city_id           INT NOT NULL REFERENCES cities(id),

  -- Location (bilingual)
  address_ar        TEXT,
  address_fr        TEXT,
  neighborhood_ar   TEXT,
  neighborhood_fr   TEXT,
  location          GEOGRAPHY(POINT, 4326),   -- PostGIS point
  location_hidden   BOOLEAN DEFAULT FALSE,    -- hide exact address

  -- Titles & Descriptions (bilingual)
  title_ar          TEXT NOT NULL,
  title_fr          TEXT,
  description_ar    TEXT,
  description_fr    TEXT,

  -- Pricing
  price             NUMERIC(14,2) NOT NULL,   -- in MAD
  price_negotiable  BOOLEAN DEFAULT FALSE,
  price_per_month   BOOLEAN DEFAULT FALSE,    -- TRUE = rental price
  price_ai_estimate NUMERIC(14,2),            -- AI fair-price estimate
  price_ai_min      NUMERIC(14,2),
  price_ai_max      NUMERIC(14,2),

  -- Specs
  area_total        NUMERIC(8,2),             -- m²
  area_living       NUMERIC(8,2),
  floor             INT,
  total_floors      INT,
  rooms             INT,
  bedrooms          INT,
  bathrooms         INT,
  parking_spots     INT DEFAULT 0,
  year_built        INT,
  orientation       TEXT,                     -- N, S, E, W, SE…

  -- Features (boolean flags)
  has_elevator      BOOLEAN DEFAULT FALSE,
  has_pool          BOOLEAN DEFAULT FALSE,
  has_garden        BOOLEAN DEFAULT FALSE,
  has_terrace       BOOLEAN DEFAULT FALSE,
  has_balcony       BOOLEAN DEFAULT FALSE,
  has_ac            BOOLEAN DEFAULT FALSE,
  has_heating       BOOLEAN DEFAULT FALSE,
  has_security      BOOLEAN DEFAULT FALSE,
  has_fiber         BOOLEAN DEFAULT FALSE,
  furnished         BOOLEAN DEFAULT FALSE,

  -- Status & Moderation
  status            TEXT NOT NULL DEFAULT 'pending'
                    CHECK (status IN ('pending', 'active', 'rejected', 'sold', 'rented', 'expired', 'paused')),
  rejection_reason  TEXT,
  featured          BOOLEAN DEFAULT FALSE,    -- paid top listing
  map_highlighted   BOOLEAN DEFAULT FALSE,    -- paid map highlight

  -- Anti-duplicate fingerprint
  image_hash        TEXT[],                   -- array of perceptual hashes
  duplicate_of      UUID REFERENCES properties(id),

  -- Counters
  views_count       INT DEFAULT 0,
  favorites_count   INT DEFAULT 0,
  contacts_count    INT DEFAULT 0,

  -- Timestamps
  published_at      TIMESTAMPTZ,
  expires_at        TIMESTAMPTZ,
  created_at        TIMESTAMPTZ DEFAULT NOW(),
  updated_at        TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_properties_city     ON properties(city_id);
CREATE INDEX idx_properties_type     ON properties(type_id);
CREATE INDEX idx_properties_status   ON properties(status);
CREATE INDEX idx_properties_price    ON properties(price);
CREATE INDEX idx_properties_location ON properties USING GIST(location);
CREATE INDEX idx_properties_owner    ON properties(owner_id);
CREATE INDEX idx_properties_created  ON properties(created_at DESC);

-- Full-text search (Arabic + French)
CREATE INDEX idx_properties_fts_ar ON properties
  USING GIN(to_tsvector('arabic', coalesce(title_ar,'') || ' ' || coalesce(description_ar,'')));
CREATE INDEX idx_properties_fts_fr ON properties
  USING GIN(to_tsvector('french',  coalesce(title_fr,'') || ' ' || coalesce(description_fr,'')));

-- ============================================================
-- 6. PROPERTY_IMAGES
-- ============================================================
CREATE TABLE property_images (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  property_id   UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
  url           TEXT NOT NULL,
  storage_path  TEXT NOT NULL,               -- Supabase Storage path
  order_index   INT DEFAULT 0,
  is_cover      BOOLEAN DEFAULT FALSE,
  width         INT,
  height        INT,
  size_kb       INT,
  perceptual_hash TEXT,                      -- for duplicate detection
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_images_property ON property_images(property_id);

-- ============================================================
-- 7. FAVORITES
-- ============================================================
CREATE TABLE favorites (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  property_id UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
  created_at  TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, property_id)
);

CREATE INDEX idx_favorites_user     ON favorites(user_id);
CREATE INDEX idx_favorites_property ON favorites(property_id);

-- ============================================================
-- 8. CONTACT_REQUESTS
-- ============================================================
CREATE TABLE contact_requests (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  property_id   UUID NOT NULL REFERENCES properties(id),
  requester_id  UUID REFERENCES users(id),
  owner_id      UUID NOT NULL REFERENCES users(id),
  channel       TEXT NOT NULL CHECK (channel IN ('call', 'whatsapp', 'message')),
  message       TEXT,
  requester_phone TEXT,
  requester_name  TEXT,
  seen_by_owner BOOLEAN DEFAULT FALSE,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_contacts_property ON contact_requests(property_id);
CREATE INDEX idx_contacts_owner    ON contact_requests(owner_id);

-- ============================================================
-- 9. MESSAGES (in-app chat)
-- ============================================================
CREATE TABLE messages (
  id            UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  contact_id    UUID NOT NULL REFERENCES contact_requests(id) ON DELETE CASCADE,
  sender_id     UUID NOT NULL REFERENCES users(id),
  content       TEXT NOT NULL,
  read_at       TIMESTAMPTZ,
  created_at    TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_messages_contact ON messages(contact_id);

-- ============================================================
-- 10. REVIEWS (owner ratings)
-- ============================================================
CREATE TABLE reviews (
  id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  reviewer_id  UUID NOT NULL REFERENCES users(id),
  owner_id     UUID NOT NULL REFERENCES users(id),
  property_id  UUID REFERENCES properties(id),
  rating       INT NOT NULL CHECK (rating BETWEEN 1 AND 5),
  comment      TEXT,
  created_at   TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(reviewer_id, property_id)
);

-- ============================================================
-- 11. PROPERTY_VIEWS (analytics)
-- ============================================================
CREATE TABLE property_views (
  id          BIGSERIAL PRIMARY KEY,
  property_id UUID NOT NULL REFERENCES properties(id) ON DELETE CASCADE,
  user_id     UUID REFERENCES users(id),
  ip_hash     TEXT,                          -- hashed for privacy
  source      TEXT,                          -- map | list | search | share
  device      TEXT,                          -- mobile | desktop | tablet
  viewed_at   TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_views_property ON property_views(property_id);
CREATE INDEX idx_views_date     ON property_views(viewed_at DESC);

-- ============================================================
-- 12. SAVED_SEARCHES (alerts)
-- ============================================================
CREATE TABLE saved_searches (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  name        TEXT,
  city_id     INT REFERENCES cities(id),
  type_id     INT REFERENCES property_types(id),
  operation   TEXT CHECK (operation IN ('sale', 'rent', 'both')),
  price_min   NUMERIC(14,2),
  price_max   NUMERIC(14,2),
  area_min    NUMERIC(8,2),
  area_max    NUMERIC(8,2),
  rooms_min   INT,
  alert_email BOOLEAN DEFAULT TRUE,
  alert_push  BOOLEAN DEFAULT FALSE,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 13. NOTIFICATIONS
-- ============================================================
CREATE TABLE notifications (
  id          UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id     UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  type        TEXT NOT NULL,
  -- types: new_message | new_contact | listing_approved |
  --        listing_rejected | price_alert | new_match | review
  title_ar    TEXT,
  title_fr    TEXT,
  body_ar     TEXT,
  body_fr     TEXT,
  link        TEXT,
  read        BOOLEAN DEFAULT FALSE,
  created_at  TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_notifs_user ON notifications(user_id, read);

-- ============================================================
-- 14. PLANS & SUBSCRIPTIONS
-- ============================================================
CREATE TABLE subscriptions (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id         UUID NOT NULL REFERENCES users(id),
  plan            TEXT NOT NULL CHECK (plan IN ('premium_individual', 'agency_monthly', 'featured_listing')),
  property_id     UUID REFERENCES properties(id),   -- for per-listing features
  amount_mad      NUMERIC(10,2) NOT NULL,
  payment_method  TEXT,                              -- CMI | PayPal | cash
  payment_ref     TEXT,
  status          TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'active', 'expired', 'cancelled')),
  starts_at       TIMESTAMPTZ,
  expires_at      TIMESTAMPTZ,
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- 15. DUPLICATE_REPORTS
-- ============================================================
CREATE TABLE duplicate_reports (
  id              UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  reporter_id     UUID REFERENCES users(id),
  property_id     UUID NOT NULL REFERENCES properties(id),
  duplicate_of_id UUID REFERENCES properties(id),
  reason          TEXT,
  status          TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'dismissed')),
  reviewed_by     UUID REFERENCES users(id),
  created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================================
-- FUNCTIONS & TRIGGERS
-- ============================================================

-- Auto-update updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN NEW.updated_at = NOW(); RETURN NEW; END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated       BEFORE UPDATE ON users       FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_properties_updated  BEFORE UPDATE ON properties  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Auto-increment favorites_count
CREATE OR REPLACE FUNCTION sync_favorites_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE properties SET favorites_count = favorites_count + 1 WHERE id = NEW.property_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE properties SET favorites_count = GREATEST(favorites_count - 1, 0) WHERE id = OLD.property_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_favorites_count
  AFTER INSERT OR DELETE ON favorites
  FOR EACH ROW EXECUTE FUNCTION sync_favorites_count();

-- Auto-increment total_listings
CREATE OR REPLACE FUNCTION sync_user_listing_count()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'INSERT' THEN
    UPDATE users SET total_listings = total_listings + 1 WHERE id = NEW.owner_id;
  ELSIF TG_OP = 'DELETE' THEN
    UPDATE users SET total_listings = GREATEST(total_listings - 1, 0) WHERE id = OLD.owner_id;
  END IF;
  RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_user_listing_count
  AFTER INSERT OR DELETE ON properties
  FOR EACH ROW EXECUTE FUNCTION sync_user_listing_count();

-- Generate ref_code  (AQ-2026-XXXXX)
CREATE OR REPLACE FUNCTION generate_ref_code()
RETURNS TRIGGER AS $$
BEGIN
  NEW.ref_code := 'AQ-' || EXTRACT(YEAR FROM NOW()) || '-' ||
                  LPAD(CAST(nextval('ref_seq') AS TEXT), 5, '0');
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE SEQUENCE ref_seq START 1;
CREATE TRIGGER trg_ref_code
  BEFORE INSERT ON properties
  FOR EACH ROW WHEN (NEW.ref_code IS NULL)
  EXECUTE FUNCTION generate_ref_code();

-- ============================================================
-- USEFUL VIEWS
-- ============================================================

-- Active listings with city + type info
CREATE OR REPLACE VIEW v_active_listings AS
SELECT
  p.*,
  c.name_ar   AS city_ar,
  c.name_fr   AS city_fr,
  c.slug      AS city_slug,
  pt.name_ar  AS type_ar,
  pt.name_fr  AS type_fr,
  pt.icon     AS type_icon,
  u.full_name AS owner_name,
  u.phone     AS owner_phone,
  u.identity_verified AS owner_verified,
  (SELECT url FROM property_images WHERE property_id = p.id AND is_cover = TRUE LIMIT 1) AS cover_image
FROM properties p
JOIN cities c         ON p.city_id = c.id
JOIN property_types pt ON p.type_id = pt.id
JOIN users u          ON p.owner_id = u.id
WHERE p.status = 'active';

-- User dashboard summary
CREATE OR REPLACE VIEW v_user_dashboard AS
SELECT
  u.id,
  u.full_name,
  u.plan,
  u.total_listings,
  u.response_rate,
  COUNT(CASE WHEN p.status = 'active'  THEN 1 END) AS active_count,
  COUNT(CASE WHEN p.status = 'pending' THEN 1 END) AS pending_count,
  COALESCE(SUM(p.views_count), 0)                  AS total_views,
  COALESCE(SUM(p.favorites_count), 0)              AS total_favorites,
  COALESCE(SUM(p.contacts_count), 0)               AS total_contacts
FROM users u
LEFT JOIN properties p ON p.owner_id = u.id
GROUP BY u.id;
