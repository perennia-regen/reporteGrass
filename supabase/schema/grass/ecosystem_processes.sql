-- Domain: GRASS
-- Table: ecosystem_processes
-- Description: Ecosystem processes data (4 cycles)

CREATE TABLE ecosystem_processes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    monitoring_event_id UUID REFERENCES monitoring_event(id) ON DELETE CASCADE,
    monitoring_site_id UUID REFERENCES monitoring_site(id),
    sampling_area_id UUID REFERENCES sampling_area(id),
    farm_id UUID NOT NULL REFERENCES farm(id) ON DELETE CASCADE,
    -- Process values (0-100 scale)
    ciclo_agua DECIMAL(5, 2),
    ciclo_mineral DECIMAL(5, 2),
    flujo_energia DECIMAL(5, 2),
    dinamica_comunidades DECIMAL(5, 2),
    -- Reading date
    reading_date DATE NOT NULL,
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by VARCHAR(255),
    is_deleted BOOLEAN DEFAULT FALSE
);

-- Indexes
CREATE INDEX idx_ecosystem_processes_farm_id ON ecosystem_processes(farm_id);
CREATE INDEX idx_ecosystem_processes_event_id ON ecosystem_processes(monitoring_event_id);
CREATE INDEX idx_ecosystem_processes_site_id ON ecosystem_processes(monitoring_site_id);
CREATE INDEX idx_ecosystem_processes_date ON ecosystem_processes(reading_date);
CREATE INDEX idx_ecosystem_processes_not_deleted ON ecosystem_processes(id) WHERE is_deleted = FALSE;

COMMENT ON TABLE ecosystem_processes IS 'Ecosystem processes data (4 cycles)';
COMMENT ON COLUMN ecosystem_processes.ciclo_agua IS 'Water cycle process value';
COMMENT ON COLUMN ecosystem_processes.ciclo_mineral IS 'Mineral cycle process value';
COMMENT ON COLUMN ecosystem_processes.flujo_energia IS 'Energy flow process value';
COMMENT ON COLUMN ecosystem_processes.dinamica_comunidades IS 'Community dynamics process value';
