-- Domain: Areas
-- Table: exclusion_area
-- Description: Areas excluded from monitoring/management activities

CREATE TABLE exclusion_area (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255),
    other_name VARCHAR(255),
    farm_id UUID NOT NULL REFERENCES farm(id) ON DELETE CASCADE,
    exclusion_area_type_id INTEGER REFERENCES ref_exclusion_area_type(id),
    -- Spatial data
    geometry GEOMETRY(MultiPolygon, 4326),
    uncropped_geometry GEOMETRY(MultiPolygon, 4326),
    total_hectares DECIMAL(10, 2),
    -- Grazing info
    has_grazing_management BOOLEAN DEFAULT FALSE,
    -- Display
    color VARCHAR(20),
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by VARCHAR(255),
    updated_by VARCHAR(255),
    is_deleted BOOLEAN DEFAULT FALSE
);

-- Indexes
CREATE INDEX idx_exclusion_area_geometry ON exclusion_area USING GIST (geometry);
CREATE INDEX idx_exclusion_area_farm_id ON exclusion_area(farm_id);
CREATE INDEX idx_exclusion_area_type_id ON exclusion_area(exclusion_area_type_id);
CREATE INDEX idx_exclusion_area_not_deleted ON exclusion_area(id) WHERE is_deleted = FALSE;

COMMENT ON TABLE exclusion_area IS 'Areas excluded from monitoring (water bodies, infrastructure, etc.)';
