-- Domain: GRASS
-- Table: recommendation
-- Description: Per stratum recommendations

CREATE TABLE recommendation (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    farm_id UUID NOT NULL REFERENCES farm(id) ON DELETE CASCADE,
    sampling_area_id UUID REFERENCES sampling_area(id),
    monitoring_report_id UUID REFERENCES monitoring_report(id),
    -- Content
    suggestion TEXT NOT NULL,
    priority INTEGER DEFAULT 1,
    category VARCHAR(50),
    -- Status
    is_implemented BOOLEAN DEFAULT FALSE,
    implemented_at TIMESTAMPTZ,
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by VARCHAR(255),
    updated_by VARCHAR(255),
    is_deleted BOOLEAN DEFAULT FALSE
);

-- Indexes
CREATE INDEX idx_recommendation_farm_id ON recommendation(farm_id);
CREATE INDEX idx_recommendation_sampling_area ON recommendation(sampling_area_id);
CREATE INDEX idx_recommendation_report ON recommendation(monitoring_report_id);
CREATE INDEX idx_recommendation_priority ON recommendation(priority);
CREATE INDEX idx_recommendation_not_deleted ON recommendation(id) WHERE is_deleted = FALSE;

COMMENT ON TABLE recommendation IS 'Per stratum recommendations';
COMMENT ON COLUMN recommendation.priority IS '1=high, 2=medium, 3=low';
COMMENT ON COLUMN recommendation.category IS 'Category: manejo_pastoreo, cobertura, regeneracion';
