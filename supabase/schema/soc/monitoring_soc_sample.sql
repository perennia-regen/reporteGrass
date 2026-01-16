-- Domain: SOC (Soil Organic Carbon)
-- Table: monitoring_soc_sample
-- Description: Soil Organic Carbon sampling records

CREATE TABLE monitoring_soc_sample (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    farm_id UUID NOT NULL REFERENCES farm(id) ON DELETE CASCADE,
    sample_date DATE NOT NULL,
    sampling_number_id INTEGER NOT NULL REFERENCES ref_sampling_number(id),
    laboratory_id INTEGER REFERENCES rel_laboratory(id),
    soc_protocol_id INTEGER NOT NULL REFERENCES rel_soc_protocol(id),
    is_completed BOOLEAN NOT NULL DEFAULT FALSE,
    uncompleted_reason TEXT,
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by VARCHAR(255),
    updated_by VARCHAR(255),
    is_deleted BOOLEAN DEFAULT FALSE
);

-- Indexes
CREATE INDEX idx_monitoring_soc_sample_farm_id ON monitoring_soc_sample(farm_id);
CREATE INDEX idx_monitoring_soc_sample_date ON monitoring_soc_sample(sample_date);
CREATE INDEX idx_monitoring_soc_sample_not_deleted ON monitoring_soc_sample(id) WHERE is_deleted = FALSE;

-- Validation: uncompleted_reason required when is_completed = false
ALTER TABLE monitoring_soc_sample
ADD CONSTRAINT chk_uncompleted_reason
CHECK (is_completed = TRUE OR uncompleted_reason IS NOT NULL);

COMMENT ON TABLE monitoring_soc_sample IS 'Soil Organic Carbon sampling records';

-- SOC Site Sample (per monitoring site)
CREATE TABLE monitoring_soc_site_sample (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    monitoring_soc_sample_id UUID NOT NULL REFERENCES monitoring_soc_sample(id) ON DELETE CASCADE,
    monitoring_soc_activity_id UUID REFERENCES monitoring_activity(id),
    name VARCHAR(255) NOT NULL,
    -- DAP (Densidad Aparente)
    dap_method_id INTEGER NOT NULL REFERENCES ref_dap_method(id),
    dap DECIMAL(10, 4) NOT NULL,
    sample_volume DECIMAL(10, 4) NOT NULL,
    -- Replica percentages (Walkley-Black method)
    wb_first_replica_percentage DECIMAL(5, 2) CHECK (wb_first_replica_percentage BETWEEN 0 AND 100),
    wb_second_replica_percentage DECIMAL(5, 2) CHECK (wb_second_replica_percentage BETWEEN 0 AND 100),
    -- Replica percentages (Combustión seca - CA method)
    ca_first_replica_percentage DECIMAL(5, 2) CHECK (ca_first_replica_percentage BETWEEN 0 AND 100),
    ca_second_replica_percentage DECIMAL(5, 2) CHECK (ca_second_replica_percentage BETWEEN 0 AND 100),
    -- Replica percentages (LECO method)
    leco_first_replica_percentage DECIMAL(5, 2) CHECK (leco_first_replica_percentage BETWEEN 0 AND 100),
    leco_second_replica_percentage DECIMAL(5, 2) CHECK (leco_second_replica_percentage BETWEEN 0 AND 100),
    -- Physical properties
    dry_weight DECIMAL(10, 4),
    gravel_weight DECIMAL(10, 4),
    gravel_volume DECIMAL(10, 4),
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by VARCHAR(255),
    updated_by VARCHAR(255),
    is_deleted BOOLEAN DEFAULT FALSE
);

-- Indexes
CREATE INDEX idx_monitoring_soc_site_sample_soc_sample ON monitoring_soc_site_sample(monitoring_soc_sample_id);
CREATE INDEX idx_monitoring_soc_site_sample_activity ON monitoring_soc_site_sample(monitoring_soc_activity_id);

COMMENT ON TABLE monitoring_soc_site_sample IS 'SOC samples at monitoring sites with replica measurements';

-- SOC Sampling Area Sample (aggregated by sampling area)
CREATE TABLE monitoring_soc_sampling_area_sample (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    monitoring_soc_sample_id UUID NOT NULL REFERENCES monitoring_soc_sample(id) ON DELETE CASCADE,
    sampling_area_id UUID NOT NULL REFERENCES sampling_area(id),
    stations_name VARCHAR(255) NOT NULL,
    sampling_area_name VARCHAR(255) NOT NULL,
    -- Soil chemistry
    ph DECIMAL(4, 2),
    nitrogen_percentage DECIMAL(5, 2) CHECK (nitrogen_percentage BETWEEN 0 AND 100),
    phosphorus_percentage DECIMAL(5, 2) CHECK (phosphorus_percentage BETWEEN 0 AND 100),
    -- Particle size distribution
    fine_sand_percentage DECIMAL(5, 2) CHECK (fine_sand_percentage BETWEEN 0 AND 100),
    coarse_sand_percentage DECIMAL(5, 2) CHECK (coarse_sand_percentage BETWEEN 0 AND 100),
    sand_percentage DECIMAL(5, 2) CHECK (sand_percentage BETWEEN 0 AND 100),
    silt_percentage DECIMAL(5, 2) CHECK (silt_percentage BETWEEN 0 AND 100),
    clay_percentage DECIMAL(5, 2) CHECK (clay_percentage BETWEEN 0 AND 100),
    -- Texture classification
    soil_texture_type_id INTEGER REFERENCES ref_soil_texture(id),
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by VARCHAR(255),
    updated_by VARCHAR(255),
    is_deleted BOOLEAN DEFAULT FALSE
);

-- Indexes
CREATE INDEX idx_monitoring_soc_sa_sample_soc ON monitoring_soc_sampling_area_sample(monitoring_soc_sample_id);
CREATE INDEX idx_monitoring_soc_sa_sample_area ON monitoring_soc_sampling_area_sample(sampling_area_id);

COMMENT ON TABLE monitoring_soc_sampling_area_sample IS 'SOC samples aggregated by sampling area with soil analysis';
