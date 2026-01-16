-- Domain: Areas
-- Table: paddock
-- Description: Physical land parcels (lotes) within a farm

CREATE TABLE paddock (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50),
    farm_id UUID NOT NULL REFERENCES farm(id) ON DELETE CASCADE,
    -- Spatial data
    geometry GEOMETRY(MultiPolygon, 4326),
    uncropped_geometry GEOMETRY(MultiPolygon, 4326),
    total_hectares DECIMAL(10, 2),
    -- Display
    color VARCHAR(20),
    is_in_project BOOLEAN DEFAULT TRUE,
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by VARCHAR(255),
    updated_by VARCHAR(255),
    is_deleted BOOLEAN DEFAULT FALSE
);

-- Indexes
CREATE INDEX idx_paddock_geometry ON paddock USING GIST (geometry);
CREATE INDEX idx_paddock_farm_id ON paddock(farm_id);
CREATE INDEX idx_paddock_not_deleted ON paddock(id) WHERE is_deleted = FALSE;

COMMENT ON TABLE paddock IS 'Physical land parcels (lotes) within a farm';
