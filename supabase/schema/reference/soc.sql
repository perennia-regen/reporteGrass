-- Domain: Reference / SOC (Soil Organic Carbon)
-- Tables for SOC sampling and soil analysis

-- DAP Method (Densidad Aparente)
CREATE TABLE ref_dap_method (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    es_ar VARCHAR(100) NOT NULL,
    es_py VARCHAR(100),
    en_us VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO ref_dap_method (id, code, es_ar, en_us) VALUES
    (0, 'undisturbed', 'Intacta', 'Undisturbed'),
    (1, 'excavation', 'Excavación', 'Excavation'),
    (2, 'ring', 'Anillo', 'Ring');

-- Sampling Number
CREATE TABLE ref_sampling_number (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    es_ar VARCHAR(100) NOT NULL,
    es_py VARCHAR(100),
    en_us VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO ref_sampling_number (id, code, es_ar, en_us) VALUES
    (0, 'baseline', 'Línea base', 'Baseline'),
    (1, 'first_resampling', 'Primer re-muestreo', 'First Resampling'),
    (2, 'second_resampling', 'Segundo re-muestreo', 'Second Resampling');

-- Soil Texture
CREATE TABLE ref_soil_texture (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    es_ar VARCHAR(100) NOT NULL,
    es_ar_long VARCHAR(200),
    en_us VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO ref_soil_texture (id, code, es_ar, en_us) VALUES
    (1, 'clay', 'Arcillosa', 'Clay'),
    (2, 'sandy_clay', 'Arcillo arenosa', 'Sandy Clay'),
    (3, 'silty_clay', 'Arcillo limosa', 'Silty Clay'),
    (4, 'clay_loam', 'Franco arcillosa', 'Clay Loam'),
    (5, 'sandy_clay_loam', 'Franco arcillo arenosa', 'Sandy Clay Loam'),
    (6, 'silty_clay_loam', 'Franco arcillo limosa', 'Silty Clay Loam'),
    (7, 'loam', 'Franca', 'Loam'),
    (8, 'sandy_loam', 'Franco arenosa', 'Sandy Loam'),
    (9, 'silt_loam', 'Franco limosa', 'Silt Loam'),
    (10, 'silt', 'Limosa', 'Silt'),
    (11, 'loamy_sand', 'Arenosa franca', 'Loamy Sand'),
    (12, 'sand', 'Arenosa', 'Sand');

-- Soil Sampling Disturbance
CREATE TABLE ref_soil_sampling_disturbance (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    es_ar VARCHAR(100) NOT NULL,
    en_us VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO ref_soil_sampling_disturbance (id, code, es_ar, en_us) VALUES
    (1, 'undisturbed', 'Intacta', 'Undisturbed'),
    (2, 'disturbed', 'No intacta', 'Disturbed');

-- Soil Sampling Tools
CREATE TABLE ref_soil_sampling_tools (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    es_ar VARCHAR(100) NOT NULL,
    en_us VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO ref_soil_sampling_tools (id, code, es_ar, en_us) VALUES
    (1, 'shovel', 'Pala', 'Shovel'),
    (2, 'auger', 'Calador', 'Auger');

-- Laboratory
CREATE TABLE rel_laboratory (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    country VARCHAR(50),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO rel_laboratory (id, code, name, country) VALUES
    (0, 'agrolabcs', 'AGROLABCS', 'Argentina'),
    (1, 'cetapar', 'CETAPAR', 'Paraguay'),
    (2, 'univ_austral_chile', 'Universidad Austral de Chile', 'Chile'),
    (3, 'exata', 'EXATA', 'Brasil');

-- SOC Protocol
CREATE TABLE rel_soc_protocol (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO rel_soc_protocol (id, code, name) VALUES
    (0, 'grass_6_0', 'Grass 6.0', 'Protocolo GRASS versión 6.0'),
    (1, 'before_grass_6_0', 'Before Grass 6.0', 'Protocolo anterior a GRASS 6.0');
