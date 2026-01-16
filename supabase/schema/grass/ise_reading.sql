-- Domain: GRASS
-- Table: ise_reading
-- Description: ISE (Índice de Salud Ecosistémica) historical data

CREATE TABLE ise_reading (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    monitoring_event_id UUID REFERENCES monitoring_event(id) ON DELETE CASCADE,
    monitoring_site_id UUID REFERENCES monitoring_site(id),
    sampling_area_id UUID REFERENCES sampling_area(id),
    farm_id UUID NOT NULL REFERENCES farm(id) ON DELETE CASCADE,
    -- ISE Values
    ise_value DECIMAL(5, 2),
    ise_1 DECIMAL(5, 2),
    ise_2 DECIMAL(5, 2),
    -- Reading date
    reading_date DATE NOT NULL,
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by VARCHAR(255),
    is_deleted BOOLEAN DEFAULT FALSE
);

-- Indexes
CREATE INDEX idx_ise_reading_farm_id ON ise_reading(farm_id);
CREATE INDEX idx_ise_reading_event_id ON ise_reading(monitoring_event_id);
CREATE INDEX idx_ise_reading_site_id ON ise_reading(monitoring_site_id);
CREATE INDEX idx_ise_reading_sampling_area_id ON ise_reading(sampling_area_id);
CREATE INDEX idx_ise_reading_date ON ise_reading(reading_date);
CREATE INDEX idx_ise_reading_not_deleted ON ise_reading(id) WHERE is_deleted = FALSE;

COMMENT ON TABLE ise_reading IS 'ISE (Índice de Salud Ecosistémica) historical data';
COMMENT ON COLUMN ise_reading.ise_1 IS 'First ISE calculation (ecosystem health)';
COMMENT ON COLUMN ise_reading.ise_2 IS 'Second ISE calculation (community dynamics)';
