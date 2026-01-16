-- Domain: Reference / Location
-- Tables for location and site related enums

-- Location Moved Reason
CREATE TABLE ref_location_moved_reason (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    es_ar VARCHAR(100) NOT NULL,
    es_py VARCHAR(100),
    en_us VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO ref_location_moved_reason (id, code, es_ar, en_us) VALUES
    (0, 'inaccessible', 'Inaccesible', 'Inaccessible'),
    (1, 'land_use_changed', 'Cambio de uso de terreno', 'Land Use Changed'),
    (2, 'not_representative', 'No representativo del estrato', 'Not Representative of Stratum');

-- Location Confirmation Type
CREATE TABLE ref_location_confirmation_type (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    es_ar VARCHAR(100) NOT NULL,
    es_py VARCHAR(100),
    en_us VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO ref_location_confirmation_type (id, code, es_ar, en_us) VALUES
    (0, 'mdc', 'MDC', 'MDC'),
    (1, 'external_gps', 'GPS Externo', 'External GPS'),
    (2, 'manual', 'Manual', 'Manual');

-- Field Relocation Method
CREATE TABLE ref_field_relocation_method (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    es_ar VARCHAR(100) NOT NULL,
    es_py VARCHAR(100),
    en_us VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO ref_field_relocation_method (id, code, es_ar, en_us) VALUES
    (0, 'mdc_randomizer', 'MDC Randomizer', 'MDC Randomizer'),
    (1, 'manual', 'Manual', 'Manual');

-- Randomizer
CREATE TABLE ref_randomizer (
    id SERIAL PRIMARY KEY,
    version VARCHAR(20) NOT NULL UNIQUE,
    model VARCHAR(50),
    es_ar VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO ref_randomizer (id, version, model) VALUES
    (1, 'v1.0.0', 'legacy'),
    (2, 'v2.0.0', 'improved'),
    (3, 'v3.0.0', 'weighted'),
    (4, 'v4.0.0', 'current');

-- Country
CREATE TABLE ref_country (
    id SERIAL PRIMARY KEY,
    code VARCHAR(3) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO ref_country (code, name) VALUES
    ('ARG', 'Argentina'),
    ('URY', 'Uruguay'),
    ('PRY', 'Paraguay'),
    ('BRA', 'Brasil'),
    ('CHL', 'Chile');
