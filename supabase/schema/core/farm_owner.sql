-- Domain: Core
-- Table: farm_owner
-- Description: Legal entity owning farms

CREATE TABLE farm_owner (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    legal_company_name VARCHAR(255),
    cuit VARCHAR(20),
    primary_contact_name VARCHAR(255),
    address TEXT,
    city VARCHAR(100),
    province VARCHAR(100),
    email VARCHAR(255),
    phone VARCHAR(50),
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    is_deleted BOOLEAN DEFAULT FALSE
);

-- Indexes
CREATE INDEX idx_farm_owner_cuit ON farm_owner(cuit) WHERE cuit IS NOT NULL;
CREATE INDEX idx_farm_owner_not_deleted ON farm_owner(id) WHERE is_deleted = FALSE;

COMMENT ON TABLE farm_owner IS 'Legal entity owning one or more farms';
COMMENT ON COLUMN farm_owner.cuit IS 'Tax ID (Argentina)';
