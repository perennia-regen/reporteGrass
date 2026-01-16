-- Domain: Reference / Areas
-- Tables for area types and exclusions

-- Exclusion Area Type
CREATE TABLE ref_exclusion_area_type (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    es_ar VARCHAR(100) NOT NULL,
    es_py VARCHAR(100),
    en_us VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO ref_exclusion_area_type (id, code, es_ar, en_us) VALUES
    (0, 'water_body', 'Cuerpo de agua', 'Water Body'),
    (1, 'road', 'Camino', 'Road'),
    (2, 'infrastructure', 'Instalaciones', 'Infrastructure'),
    (3, 'natural_reserve', 'Reserva natural', 'Natural Reserve'),
    (4, 'native_forest', 'Monte nativo', 'Native Forest'),
    (5, 'unproductive', 'Zona improductiva', 'Unproductive Zone'),
    (6, 'wetland', 'Humedal', 'Wetland'),
    (7, 'dry_lagoon', 'Laguna seca', 'Dry Lagoon'),
    (8, 'planted_forest', 'Bosque implantado', 'Planted Forest'),
    (9, 'watercourse', 'Curso de agua', 'Watercourse'),
    (10, 'deforestation', 'Deforestación', 'Deforestation'),
    (99, 'other', 'Otro', 'Other');
