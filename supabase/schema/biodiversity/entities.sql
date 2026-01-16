-- Domain: Biodiversity
-- Entity tables for biodiversity

-- Species
CREATE TABLE biodiversity.species (
    id SERIAL PRIMARY KEY,
    scientific_name TEXT NOT NULL UNIQUE,
    common_name TEXT,
    common_names TEXT[],
    family TEXT,
    genre TEXT,
    reference_link TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by VARCHAR(255),
    updated_by VARCHAR(255),
    is_deleted BOOLEAN DEFAULT FALSE
);

CREATE INDEX idx_species_scientific_name ON biodiversity.species(scientific_name);
CREATE INDEX idx_species_family ON biodiversity.species(family);
CREATE INDEX idx_species_not_deleted ON biodiversity.species(id) WHERE is_deleted = FALSE;

COMMENT ON TABLE biodiversity.species IS 'Species registry (1,329+ species)';

-- Ecoregions (operational)
CREATE TABLE biodiversity.ecoregions (
    id SERIAL PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    country VARCHAR(100),
    geometry GEOMETRY(MultiPolygon, 4326),
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_ecoregions_geometry ON biodiversity.ecoregions USING GIST (geometry);
CREATE INDEX idx_ecoregions_country ON biodiversity.ecoregions(country);

COMMENT ON TABLE biodiversity.ecoregions IS 'Operational ecoregions with geometry';

-- Rel Ambient Matrix Biodiversity Indicator (junction table)
CREATE TABLE biodiversity.rel_ambient_matrix_biodiversity_indicator (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ref_ambient_matrix_id INTEGER NOT NULL REFERENCES biodiversity.ref_ambient_matrix(id) ON DELETE CASCADE,
    ref_biodiversity_indicator_id INTEGER NOT NULL REFERENCES biodiversity.ref_biodiversity_indicator(id) ON DELETE CASCADE,
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(ref_ambient_matrix_id, ref_biodiversity_indicator_id)
);

CREATE INDEX idx_rel_am_bi_matrix ON biodiversity.rel_ambient_matrix_biodiversity_indicator(ref_ambient_matrix_id);
CREATE INDEX idx_rel_am_bi_indicator ON biodiversity.rel_ambient_matrix_biodiversity_indicator(ref_biodiversity_indicator_id);

COMMENT ON TABLE biodiversity.rel_ambient_matrix_biodiversity_indicator IS 'Maps which indicators apply to each ambient matrix';

-- Rel Landscape Index Ambient Matrix (junction table with value ranges)
CREATE TABLE biodiversity.rel_landscape_index_ambient_matrix (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    ref_ambient_matrix_id INTEGER NOT NULL REFERENCES biodiversity.ref_ambient_matrix(id) ON DELETE CASCADE,
    ref_landscape_index_id INTEGER NOT NULL REFERENCES biodiversity.ref_landscape_index(id) ON DELETE CASCADE,
    min_value INTEGER,
    max_value INTEGER,
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    UNIQUE(ref_ambient_matrix_id, ref_landscape_index_id)
);

CREATE INDEX idx_rel_li_am_matrix ON biodiversity.rel_landscape_index_ambient_matrix(ref_ambient_matrix_id);
CREATE INDEX idx_rel_li_am_index ON biodiversity.rel_landscape_index_ambient_matrix(ref_landscape_index_id);

COMMENT ON TABLE biodiversity.rel_landscape_index_ambient_matrix IS 'Maps landscape indexes to ambient matrices with value ranges';
