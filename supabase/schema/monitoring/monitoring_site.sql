-- Domain: Monitoring
-- Table: monitoring_site
-- Description: Specific point locations for field data collection

CREATE TABLE monitoring_site (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255),
    code VARCHAR(50),
    farm_id UUID NOT NULL REFERENCES farm(id) ON DELETE CASCADE,
    sampling_area_id UUID REFERENCES sampling_area(id),
    -- Allocation
    allocated BOOLEAN DEFAULT FALSE,
    -- Location data
    planned_location JSONB,
    actual_location JSONB,
    backup_location JSONB,
    planned_geometry GEOMETRY(Point, 4326),
    actual_geometry GEOMETRY(Point, 4326),
    -- Location status
    location_confirmed BOOLEAN DEFAULT FALSE,
    location_moved BOOLEAN DEFAULT FALSE,
    location_moved_reason_id INTEGER REFERENCES ref_location_moved_reason(id),
    location_moved_comments TEXT,
    location_confirmation_type_id INTEGER REFERENCES ref_location_confirmation_type(id),
    field_relocation_method_id INTEGER REFERENCES ref_field_relocation_method(id),
    -- Offset settings
    allow_contingency_offset BOOLEAN DEFAULT FALSE,
    offset_mts INTEGER DEFAULT 100,
    distance_to_planned_location DECIMAL(10, 2),
    -- Site type
    is_random_site BOOLEAN DEFAULT TRUE,
    is_validation_site BOOLEAN DEFAULT FALSE,
    -- Randomizer
    randomize_counter INTEGER,
    randomize_reason TEXT[],
    seed INTEGER,
    randomizer_type_id INTEGER REFERENCES ref_randomizer(id),
    -- Device data
    device_location_data JSONB,
    pictures BYTEA[],
    -- Display
    color VARCHAR(20),
    -- Versioning
    _rev UUID,
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by VARCHAR(255),
    updated_by VARCHAR(255),
    is_deleted BOOLEAN DEFAULT FALSE
);

-- Indexes
CREATE INDEX idx_monitoring_site_planned_geometry ON monitoring_site USING GIST (planned_geometry);
CREATE INDEX idx_monitoring_site_actual_geometry ON monitoring_site USING GIST (actual_geometry);
CREATE INDEX idx_monitoring_site_farm_id ON monitoring_site(farm_id);
CREATE INDEX idx_monitoring_site_sampling_area_id ON monitoring_site(sampling_area_id);
CREATE INDEX idx_monitoring_site_not_deleted ON monitoring_site(id) WHERE is_deleted = FALSE;

COMMENT ON TABLE monitoring_site IS 'Specific point locations for field data collection';
COMMENT ON COLUMN monitoring_site.planned_location IS 'JSON with lat, lng coordinates';
COMMENT ON COLUMN monitoring_site._rev IS 'Revision UUID for optimistic concurrency';
