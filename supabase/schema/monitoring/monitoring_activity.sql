-- Domain: Monitoring
-- Table: monitoring_activity
-- Description: Individual activities within monitoring events

CREATE TABLE monitoring_activity (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    key VARCHAR(100) NOT NULL,
    monitoring_event_id UUID NOT NULL REFERENCES monitoring_event(id) ON DELETE CASCADE,
    monitoring_workflow_id INTEGER REFERENCES monitoring_workflow(id),
    sampling_area_id UUID REFERENCES sampling_area(id),
    monitoring_site_id UUID REFERENCES monitoring_site(id),
    -- Details
    description TEXT,
    -- Status
    task_status_id INTEGER REFERENCES ref_task_status(id) DEFAULT 0,
    total_tasks INTEGER DEFAULT 0,
    completed_tasks INTEGER DEFAULT 0,
    -- Location
    actual_location JSONB,
    -- Layout
    has_layout_pattern BOOLEAN DEFAULT FALSE,
    activity_layout_id INTEGER REFERENCES ref_activity_layout(id),
    activity_grid JSONB,
    -- Versioning
    _rev UUID,
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by VARCHAR(255),
    updated_by VARCHAR(255),
    is_deleted BOOLEAN DEFAULT FALSE,
    -- Constraints
    UNIQUE(key, monitoring_event_id)
);

-- Indexes
CREATE INDEX idx_monitoring_activity_event_id ON monitoring_activity(monitoring_event_id);
CREATE INDEX idx_monitoring_activity_workflow_id ON monitoring_activity(monitoring_workflow_id);
CREATE INDEX idx_monitoring_activity_site_id ON monitoring_activity(monitoring_site_id);
CREATE INDEX idx_monitoring_activity_not_deleted ON monitoring_activity(id) WHERE is_deleted = FALSE;

COMMENT ON TABLE monitoring_activity IS 'Individual activities within monitoring events';
COMMENT ON COLUMN monitoring_activity.key IS 'Unique key within the event';
