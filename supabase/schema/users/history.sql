-- Domain: History/Audit
-- History tables for tracking changes

-- Monitoring Site History
CREATE TABLE monitoring_site_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    monitoring_site_id UUID NOT NULL REFERENCES monitoring_site(id) ON DELETE CASCADE,
    -- Mirror all monitoring_site fields
    name VARCHAR(255),
    code VARCHAR(50),
    farm_id UUID,
    sampling_area_id UUID,
    allocated BOOLEAN,
    planned_location JSONB,
    actual_location JSONB,
    backup_location JSONB,
    location_confirmed BOOLEAN,
    location_moved BOOLEAN,
    location_moved_reason_id INTEGER,
    location_moved_comments TEXT,
    location_confirmation_type_id INTEGER,
    field_relocation_method_id INTEGER,
    allow_contingency_offset BOOLEAN,
    is_random_site BOOLEAN,
    is_validation_site BOOLEAN,
    offset_mts DECIMAL(10,2),
    distance_to_planned_location DECIMAL(10,2),
    randomize_counter INTEGER,
    randomize_reason TEXT[],
    color VARCHAR(20),
    seed INTEGER,
    randomizer_type_id INTEGER,
    device_location_data JSONB,
    _rev UUID,
    -- History metadata
    changed_at TIMESTAMPTZ DEFAULT NOW(),
    changed_by VARCHAR(255),
    change_type VARCHAR(20) -- 'INSERT', 'UPDATE', 'DELETE'
);

CREATE INDEX idx_monitoring_site_history_site ON monitoring_site_history(monitoring_site_id);
CREATE INDEX idx_monitoring_site_history_changed_at ON monitoring_site_history(changed_at);

-- Monitoring Task History
CREATE TABLE monitoring_task_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    monitoring_task_id UUID NOT NULL REFERENCES monitoring_task(id) ON DELETE CASCADE,
    -- Mirror all monitoring_task fields
    key VARCHAR(100),
    "order" INTEGER,
    enabled BOOLEAN,
    monitoring_site_id UUID,
    monitoring_activity_id UUID,
    monitoring_event_id UUID,
    task_status_id INTEGER,
    form_name VARCHAR(100),
    type VARCHAR(50),
    grid_position_key VARCHAR(50),
    actual_location JSONB,
    planned_location JSONB,
    action_range_mts DECIMAL(10,2),
    dependencies TEXT[],
    description TEXT,
    data_payload JSONB,
    pictures TEXT[],
    device_location_data JSONB,
    _rev UUID,
    -- History metadata
    changed_at TIMESTAMPTZ DEFAULT NOW(),
    changed_by VARCHAR(255),
    change_type VARCHAR(20)
);

CREATE INDEX idx_monitoring_task_history_task ON monitoring_task_history(monitoring_task_id);
CREATE INDEX idx_monitoring_task_history_changed_at ON monitoring_task_history(changed_at);

-- Data Collection Statement History
CREATE TABLE data_collection_statement_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    data_collection_statement_id UUID NOT NULL REFERENCES data_collection_statement(id) ON DELETE CASCADE,
    -- Mirror fields
    data_collection_statement_status_id INTEGER,
    owner_user_role_id INTEGER,
    farm_subdivision_id UUID,
    metrics_events_ids UUID[],
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    created_by VARCHAR(255),
    updated_by VARCHAR(255),
    is_deleted BOOLEAN,
    -- History metadata
    changed_at TIMESTAMPTZ DEFAULT NOW(),
    changed_by VARCHAR(255),
    change_type VARCHAR(20)
);

CREATE INDEX idx_dcs_history_dcs ON data_collection_statement_history(data_collection_statement_id);
CREATE INDEX idx_dcs_history_changed_at ON data_collection_statement_history(changed_at);

-- Finding History
CREATE TABLE finding_history (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    finding_id UUID NOT NULL REFERENCES finding(id) ON DELETE CASCADE,
    -- Mirror fields
    metric_event_id UUID,
    type INTEGER,
    metric_events_fields_observed JSONB[],
    comment TEXT,
    resolved BOOLEAN,
    created_at TIMESTAMPTZ,
    updated_at TIMESTAMPTZ,
    created_by VARCHAR(255),
    updated_by VARCHAR(255),
    is_deleted BOOLEAN,
    -- History metadata
    changed_at TIMESTAMPTZ DEFAULT NOW(),
    changed_by_user VARCHAR(255),
    change_type VARCHAR(20)
);

CREATE INDEX idx_finding_history_finding ON finding_history(finding_id);
CREATE INDEX idx_finding_history_changed_at ON finding_history(changed_at);

COMMENT ON TABLE monitoring_site_history IS 'Audit trail for monitoring site changes';
COMMENT ON TABLE monitoring_task_history IS 'Audit trail for monitoring task changes';
COMMENT ON TABLE data_collection_statement_history IS 'Audit trail for data collection statement changes';
COMMENT ON TABLE finding_history IS 'Audit trail for finding changes';
