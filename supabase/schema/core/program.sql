-- Domain: Core
-- Table: program
-- Description: Monitoring program (e.g., GRASS)

CREATE TABLE program (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50) UNIQUE,
    description TEXT,
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by UUID,
    updated_by UUID,
    is_deleted BOOLEAN DEFAULT FALSE
);

-- Seed data
INSERT INTO program (name, code, description) VALUES
    ('GRASS', 'GRASS', 'Programa de monitoreo regenerativo de pastizales');

COMMENT ON TABLE program IS 'Monitoring program definitions';
