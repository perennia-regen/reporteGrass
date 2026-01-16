-- Domain: Areas
-- Table: farm_subdivision
-- Description: Annual grouping of paddocks for monitoring purposes

CREATE TABLE farm_subdivision (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    farm_id UUID NOT NULL REFERENCES farm(id) ON DELETE CASCADE,
    -- Paddocks for this subdivision
    paddock_ids UUID[],
    year VARCHAR(10) NOT NULL,
    -- Template
    template_file_name VARCHAR(255),
    -- Activities tracking
    activities_status JSONB[] DEFAULT ARRAY[]::JSONB[],
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by VARCHAR(255),
    updated_by VARCHAR(255),
    is_deleted BOOLEAN DEFAULT FALSE
);

-- Indexes
CREATE INDEX idx_farm_subdivision_farm_id ON farm_subdivision(farm_id);
CREATE INDEX idx_farm_subdivision_year ON farm_subdivision(year);
CREATE INDEX idx_farm_subdivision_not_deleted ON farm_subdivision(id) WHERE is_deleted = FALSE;

COMMENT ON TABLE farm_subdivision IS 'Annual grouping of paddocks for monitoring';
