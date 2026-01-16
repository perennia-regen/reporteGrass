-- Domain: Monitoring
-- Table: monitoring_task
-- Description: Specific tasks within monitoring activities

CREATE TABLE monitoring_task (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    key VARCHAR(100) NOT NULL,
    monitoring_activity_id UUID NOT NULL REFERENCES monitoring_activity(id) ON DELETE CASCADE,
    monitoring_event_id UUID NOT NULL REFERENCES monitoring_event(id) ON DELETE CASCADE,
    monitoring_site_id UUID REFERENCES monitoring_site(id),
    -- Order and state
    task_order INTEGER,
    enabled BOOLEAN NOT NULL DEFAULT TRUE,
    -- Status
    task_status_id INTEGER REFERENCES ref_task_status(id) DEFAULT 0,
    -- Details
    description TEXT,
    form_name VARCHAR(100),
    task_type VARCHAR(50),
    grid_position_key VARCHAR(50),
    -- Location
    actual_location JSONB,
    planned_location JSONB,
    action_range_mts INTEGER,
    device_location_data JSONB,
    -- Dependencies
    dependencies INTEGER[],
    -- Data
    data_payload JSONB DEFAULT '{}'::jsonb,
    pictures TEXT[],
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
CREATE INDEX idx_monitoring_task_activity_id ON monitoring_task(monitoring_activity_id);
CREATE INDEX idx_monitoring_task_event_id ON monitoring_task(monitoring_event_id);
CREATE INDEX idx_monitoring_task_site_id ON monitoring_task(monitoring_site_id);
CREATE INDEX idx_monitoring_task_status ON monitoring_task(task_status_id);
CREATE INDEX idx_monitoring_task_not_deleted ON monitoring_task(id) WHERE is_deleted = FALSE;

COMMENT ON TABLE monitoring_task IS 'Specific tasks within monitoring activities';
COMMENT ON COLUMN monitoring_task.data_payload IS 'Flexible JSONB for indicator data';
COMMENT ON COLUMN monitoring_task.pictures IS 'Array of picture URLs/keys';
