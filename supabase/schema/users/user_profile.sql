-- Domain: Users
-- Table: user_profile
-- Description: Extended user info

CREATE TABLE user_profile (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    full_name VARCHAR(255),
    avatar_url TEXT,
    phone VARCHAR(50),
    role VARCHAR(50) DEFAULT 'viewer',
    hub_id UUID REFERENCES hub(id),
    preferences JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Indexes
CREATE INDEX idx_user_profile_hub ON user_profile(hub_id);
CREATE INDEX idx_user_profile_role ON user_profile(role);

COMMENT ON TABLE user_profile IS 'Extended user profile information';
COMMENT ON COLUMN user_profile.role IS 'User role: admin, hub_admin, technician, viewer';

-- Farm Access
CREATE TABLE farm_access (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    farm_id UUID NOT NULL REFERENCES farm(id) ON DELETE CASCADE,
    access_level VARCHAR(50) NOT NULL DEFAULT 'viewer',
    granted_at TIMESTAMPTZ DEFAULT NOW(),
    granted_by UUID REFERENCES auth.users(id),
    expires_at TIMESTAMPTZ,
    is_active BOOLEAN DEFAULT TRUE,
    UNIQUE(user_id, farm_id)
);

-- Indexes
CREATE INDEX idx_farm_access_user_id ON farm_access(user_id);
CREATE INDEX idx_farm_access_farm_id ON farm_access(farm_id);
CREATE INDEX idx_farm_access_active ON farm_access(is_active) WHERE is_active = TRUE;

COMMENT ON TABLE farm_access IS 'User access control for farms';
COMMENT ON COLUMN farm_access.access_level IS 'Access level: owner, editor, viewer';
