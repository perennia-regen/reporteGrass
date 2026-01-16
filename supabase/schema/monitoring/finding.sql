-- Domain: Monitoring
-- Table: finding
-- Description: Quality issues/findings from monitoring events

CREATE TABLE finding (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    metric_event_id UUID,
    finding_type_id INTEGER NOT NULL REFERENCES ref_finding_type(id),
    metric_events_fields_observed JSONB[] NOT NULL,
    comment TEXT,
    resolved BOOLEAN DEFAULT FALSE,
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by VARCHAR(255),
    updated_by VARCHAR(255),
    is_deleted BOOLEAN DEFAULT FALSE
);

-- Indexes
CREATE INDEX idx_finding_metric_event ON finding(metric_event_id);
CREATE INDEX idx_finding_type ON finding(finding_type_id);
CREATE INDEX idx_finding_resolved ON finding(resolved);
CREATE INDEX idx_finding_not_deleted ON finding(id) WHERE is_deleted = FALSE;

COMMENT ON TABLE finding IS 'Quality issues/findings from monitoring events';
COMMENT ON COLUMN finding.metric_events_fields_observed IS 'Array of observed field data';

-- Finding Comment
CREATE TABLE finding_comment (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    finding_id UUID NOT NULL REFERENCES finding(id) ON DELETE CASCADE,
    comment TEXT NOT NULL,
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT NOW(),
    created_by VARCHAR(255),
    is_deleted BOOLEAN DEFAULT FALSE
);

-- Indexes
CREATE INDEX idx_finding_comment_finding ON finding_comment(finding_id);

COMMENT ON TABLE finding_comment IS 'Comments on findings';
