-- Domain: Areas
-- Table: sampling_area
-- Description: Strata/sampling units within farms for monitoring

CREATE TABLE sampling_area (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    code VARCHAR(10),
    farm_id UUID NOT NULL REFERENCES farm(id) ON DELETE CASCADE,
    -- Spatial data
    geometry GEOMETRY(MultiPolygon, 4326),
    uncropped_geometry GEOMETRY(MultiPolygon, 4326),
    total_hectares DECIMAL(10, 2),
    percentage DECIMAL(5, 2),
    -- Monitoring config
    stations_count INTEGER DEFAULT 0,
    area_per_station DECIMAL(10, 2),
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
CREATE INDEX idx_sampling_area_geometry ON sampling_area USING GIST (geometry);
CREATE INDEX idx_sampling_area_farm_id ON sampling_area(farm_id);
CREATE INDEX idx_sampling_area_not_deleted ON sampling_area(id) WHERE is_deleted = FALSE;

COMMENT ON TABLE sampling_area IS 'Strata/sampling units within farms (estratos)';
COMMENT ON COLUMN sampling_area.code IS 'Short code like AG, ML, BD';
COMMENT ON COLUMN sampling_area.percentage IS 'Percentage of total farm area';
