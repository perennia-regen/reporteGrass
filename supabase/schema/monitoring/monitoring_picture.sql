-- Domain: Monitoring
-- Table: monitoring_picture
-- Description: Photo attachments from monitoring activities

CREATE TABLE monitoring_picture (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255),
    key VARCHAR(255) NOT NULL,
    monitoring_event_id UUID REFERENCES monitoring_event(id),
    -- Polymorphic association
    entity VARCHAR(50) NOT NULL,
    entity_id UUID NOT NULL,
    -- Storage
    link TEXT,
    storage_bucket VARCHAR(100) DEFAULT 'monitoring-pictures',
    synced_to_s3 BOOLEAN DEFAULT FALSE,
    -- Metadata
    taken_at TIMESTAMPTZ,
    lat DECIMAL(10, 7),
    lng DECIMAL(10, 7),
    -- Versioning
    _rev UUID,
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by VARCHAR(255),
    is_deleted BOOLEAN DEFAULT FALSE
);

-- Indexes
CREATE INDEX idx_monitoring_picture_entity ON monitoring_picture(entity, entity_id);
CREATE INDEX idx_monitoring_picture_event_id ON monitoring_picture(monitoring_event_id);
CREATE INDEX idx_monitoring_picture_not_deleted ON monitoring_picture(id) WHERE is_deleted = FALSE;

COMMENT ON TABLE monitoring_picture IS 'Photo attachments from monitoring activities';
COMMENT ON COLUMN monitoring_picture.entity IS 'Entity type: monitoring_task, monitoring_site, sampling_area';
