-- Domain: Monitoring
-- Table: monitoring_event
-- Description: Monitoring campaigns/surveys on specific dates

CREATE TABLE monitoring_event (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255),
    farm_id UUID NOT NULL REFERENCES farm(id) ON DELETE CASCADE,
    -- Timing
    event_date DATE NOT NULL,
    event_year INTEGER GENERATED ALWAYS AS (EXTRACT(YEAR FROM event_date)) STORED,
    -- Status
    task_status_id INTEGER REFERENCES ref_task_status(id),
    completed_activities INTEGER DEFAULT 0,
    total_activities INTEGER DEFAULT 1,
    -- Assignment
    assigned_to VARCHAR(255),
    technician_names TEXT,
    -- Workflows and areas
    monitoring_workflow_ids INTEGER[],
    sampling_areas UUID[],
    monitoring_sites_ids UUID[],
    -- Event type
    event_type VARCHAR(50),
    description TEXT,
    is_backdated_event BOOLEAN DEFAULT FALSE,
    -- Aggregated results
    ise_result DECIMAL(5, 2),
    -- Versioning
    _rev UUID,
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by VARCHAR(255),
    updated_by VARCHAR(255),
    is_deleted BOOLEAN DEFAULT FALSE
);

-- Indexes
CREATE INDEX idx_monitoring_event_farm_id ON monitoring_event(farm_id);
CREATE INDEX idx_monitoring_event_date ON monitoring_event(event_date);
CREATE INDEX idx_monitoring_event_year ON monitoring_event(event_year);
CREATE INDEX idx_monitoring_event_status ON monitoring_event(task_status_id);
CREATE INDEX idx_monitoring_event_not_deleted ON monitoring_event(id) WHERE is_deleted = FALSE;

COMMENT ON TABLE monitoring_event IS 'Monitoring campaigns/surveys on specific dates';
COMMENT ON COLUMN monitoring_event.event_type IS 'Type: linea_base, mcp, mlp';
COMMENT ON COLUMN monitoring_event.ise_result IS 'Aggregated ISE result for the event';
