-- Domain: Core
-- Table: hub
-- Description: Regional organization managing multiple farms

CREATE TABLE hub (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    country_id INTEGER REFERENCES ref_country(id),
    province VARCHAR(100),
    referent_emails TEXT[],
    logo_url TEXT,
    hubspot_id VARCHAR(100) UNIQUE,
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    is_deleted BOOLEAN DEFAULT FALSE
);

-- Indexes
CREATE INDEX idx_hub_country_id ON hub(country_id);
CREATE INDEX idx_hub_not_deleted ON hub(id) WHERE is_deleted = FALSE;

COMMENT ON TABLE hub IS 'Regional organization managing multiple farms';
COMMENT ON COLUMN hub.referent_emails IS 'Array of referent email addresses';
