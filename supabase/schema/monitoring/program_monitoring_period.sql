-- Domain: Monitoring
-- Table: program_monitoring_period
-- Description: Temporal monitoring periods within programs

CREATE TABLE program_monitoring_period (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    program_id UUID NOT NULL REFERENCES program(id),
    name VARCHAR(100) NOT NULL,
    start_date DATE,
    end_date DATE,
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by VARCHAR(255),
    updated_by VARCHAR(255),
    is_deleted BOOLEAN DEFAULT FALSE,
    -- Constraints
    UNIQUE(program_id, name)
);

-- Indexes
CREATE INDEX idx_program_monitoring_period_program_id ON program_monitoring_period(program_id);

COMMENT ON TABLE program_monitoring_period IS 'Temporal monitoring periods within programs';

-- Junction table: Carbon Instance to Monitoring Period
CREATE TABLE rel_instance_monitoring_period (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    carbon_instance_id UUID NOT NULL REFERENCES carbon_instance(id) ON DELETE CASCADE,
    monitoring_period_id UUID NOT NULL REFERENCES program_monitoring_period(id) ON DELETE CASCADE,
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by VARCHAR(255),
    updated_by VARCHAR(255),
    is_deleted BOOLEAN DEFAULT FALSE,
    -- Constraints
    UNIQUE(carbon_instance_id, monitoring_period_id)
);

-- Indexes
CREATE INDEX idx_rel_instance_monitoring_period_carbon ON rel_instance_monitoring_period(carbon_instance_id);
CREATE INDEX idx_rel_instance_monitoring_period_period ON rel_instance_monitoring_period(monitoring_period_id);

COMMENT ON TABLE rel_instance_monitoring_period IS 'Links carbon instances to monitoring periods';
