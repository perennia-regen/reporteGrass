-- Domain: Core
-- Table: farm
-- Description: Agricultural property (establecimiento)

CREATE TABLE farm (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    short_name VARCHAR(50),
    hub_id UUID REFERENCES hub(id) ON DELETE SET NULL,
    program_id UUID REFERENCES program(id) ON DELETE SET NULL,
    owner_id UUID REFERENCES farm_owner(id) ON DELETE SET NULL,
    -- Spatial data
    geometry GEOMETRY(MultiPolygon, 4326),
    uncropped_geometry GEOMETRY(MultiPolygon, 4326),
    total_hectares DECIMAL(10, 2),
    total_hectares_declared DECIMAL(10, 2),
    elegible_hectares_declared DECIMAL(10, 2),
    lat DECIMAL(10, 7),
    lng DECIMAL(10, 7),
    -- Location
    country_id INTEGER REFERENCES ref_country(id),
    country VARCHAR(100),
    province VARCHAR(100),
    city VARCHAR(100),
    department VARCHAR(100),
    district VARCHAR(100),
    address TEXT,
    geolocation VARCHAR(255),
    ecoregion_id INTEGER,
    -- Contact
    primary_contact VARCHAR(255),
    phone_number VARCHAR(50),
    email VARCHAR(255),
    -- Status
    is_perimeter_validated BOOLEAN DEFAULT FALSE,
    has_non_ruuts_projects VARCHAR(50),
    local_law_compliance VARCHAR(50),
    -- Integration
    hubspot_id VARCHAR(100) UNIQUE,
    color VARCHAR(20),
    -- Monitoring
    target_initial_monitoring_period_id UUID,
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by VARCHAR(255),
    updated_by VARCHAR(255),
    is_deleted BOOLEAN DEFAULT FALSE
);

-- Indexes
CREATE INDEX idx_farm_geometry ON farm USING GIST (geometry);
CREATE INDEX idx_farm_hub_id ON farm(hub_id);
CREATE INDEX idx_farm_program_id ON farm(program_id);
CREATE INDEX idx_farm_owner_id ON farm(owner_id);
CREATE INDEX idx_farm_country_id ON farm(country_id);
CREATE INDEX idx_farm_not_deleted ON farm(id) WHERE is_deleted = FALSE;

COMMENT ON TABLE farm IS 'Agricultural property (establecimiento) with geospatial boundaries';
COMMENT ON COLUMN farm.geometry IS 'Farm perimeter as MultiPolygon in WGS84';
COMMENT ON COLUMN farm.short_name IS 'Short alphanumeric code (3-4 chars)';
