-- Domain: Monitoring
-- Table: monitoring_report
-- Description: Generated monitoring reports

CREATE TABLE monitoring_report (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    farm_id UUID NOT NULL REFERENCES farm(id) ON DELETE CASCADE,
    year INTEGER NOT NULL,
    report_type VARCHAR(50),
    monitoring_report_status_id INTEGER DEFAULT 0 REFERENCES ref_monitoring_report_status(id),
    -- Related events
    monitoring_event_ids UUID[],
    monitoring_activity_ids UUID[],
    -- Report data
    user_input JSONB DEFAULT '{}'::jsonb,
    calculated_data JSONB DEFAULT '{}'::jsonb,
    -- Cached files
    cached_files JSONB DEFAULT '{}'::jsonb,
    -- Status
    is_published BOOLEAN DEFAULT FALSE,
    published_at TIMESTAMPTZ,
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by VARCHAR(255),
    updated_by VARCHAR(255),
    is_deleted BOOLEAN DEFAULT FALSE,
    -- Unique constraint
    UNIQUE(farm_id, year, report_type)
);

-- Indexes
CREATE INDEX idx_monitoring_report_farm_id ON monitoring_report(farm_id);
CREATE INDEX idx_monitoring_report_year ON monitoring_report(year);
CREATE INDEX idx_monitoring_report_status ON monitoring_report(monitoring_report_status_id);
CREATE INDEX idx_monitoring_report_not_deleted ON monitoring_report(id) WHERE is_deleted = FALSE;

COMMENT ON TABLE monitoring_report IS 'Generated monitoring reports';
COMMENT ON COLUMN monitoring_report.report_type IS 'Type: mcp, linea_base, annual';
COMMENT ON COLUMN monitoring_report.user_input IS 'User-editable content';
COMMENT ON COLUMN monitoring_report.cached_files IS 'URLs to generated PDF/files';

-- Data Collection Statement
CREATE TABLE data_collection_statement (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    farm_subdivision_id UUID NOT NULL REFERENCES farm_subdivision(id) ON DELETE CASCADE,
    data_collection_statement_status_id INTEGER DEFAULT 0 REFERENCES ref_data_collection_statement_status(id),
    owner_user_role_id INTEGER NOT NULL REFERENCES ref_user_role(id),
    metrics_events_ids UUID[] DEFAULT ARRAY[]::UUID[],
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by VARCHAR(255),
    updated_by VARCHAR(255),
    is_deleted BOOLEAN DEFAULT FALSE,
    -- Unique constraint
    UNIQUE(farm_subdivision_id, is_deleted)
);

-- Indexes
CREATE INDEX idx_data_collection_statement_farm_sub ON data_collection_statement(farm_subdivision_id);
CREATE INDEX idx_data_collection_statement_status ON data_collection_statement(data_collection_statement_status_id);

COMMENT ON TABLE data_collection_statement IS 'Formal statements documenting data collection activities';

-- Form Definition
CREATE TABLE form_definition (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    program_id UUID REFERENCES program(id),
    namespace VARCHAR(100) NOT NULL,
    version VARCHAR(20) NOT NULL,
    label VARCHAR(255) NOT NULL,
    required BOOLEAN DEFAULT FALSE,
    required_message TEXT,
    show_map BOOLEAN DEFAULT FALSE,
    show_table BOOLEAN DEFAULT FALSE,
    allow_multiple_records BOOLEAN DEFAULT TRUE,
    fields JSONB NOT NULL DEFAULT '[]'::jsonb,
    dependencies JSONB NOT NULL DEFAULT '[]'::jsonb,
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by VARCHAR(255),
    updated_by VARCHAR(255),
    is_deleted BOOLEAN DEFAULT FALSE
);

-- Indexes
CREATE INDEX idx_form_definition_program_id ON form_definition(program_id);
CREATE INDEX idx_form_definition_namespace ON form_definition(namespace);

COMMENT ON TABLE form_definition IS 'Dynamic form definitions for data collection';
