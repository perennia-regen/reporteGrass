-- Domain: Areas
-- Table: carbon_instance
-- Description: Carbon monitoring instances/projects on farms

CREATE TABLE carbon_instance (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255),
    farm_id UUID NOT NULL REFERENCES farm(id) ON DELETE CASCADE,
    sampling_area_id UUID REFERENCES sampling_area(id),
    -- Timing
    init_date DATE,
    instance_year VARCHAR(10),
    -- Spatial data
    geometry GEOMETRY(MultiPolygon, 4326),
    total_hectares DECIMAL(10, 2),
    -- Related paddocks
    paddocks JSONB DEFAULT '[]'::jsonb,
    baseline_paddocks JSONB DEFAULT '[]'::jsonb,
    -- Verification
    verification_status_id INTEGER REFERENCES ref_verification_status(id),
    verified_by VARCHAR(255),
    verified_at TIMESTAMPTZ,
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
CREATE INDEX idx_carbon_instance_geometry ON carbon_instance USING GIST (geometry);
CREATE INDEX idx_carbon_instance_farm_id ON carbon_instance(farm_id);
CREATE INDEX idx_carbon_instance_sampling_area_id ON carbon_instance(sampling_area_id);
CREATE INDEX idx_carbon_instance_not_deleted ON carbon_instance(id) WHERE is_deleted = FALSE;

COMMENT ON TABLE carbon_instance IS 'Carbon monitoring instances/projects on farms';
COMMENT ON COLUMN carbon_instance.paddocks IS 'JSON array of related paddock IDs';
