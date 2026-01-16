-- Domain: Reference / Workflows
-- Tables for monitoring workflows and activity layouts

-- Activity Layout
CREATE TABLE ref_activity_layout (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    monitoring_workflow_id INTEGER,
    grid JSONB,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO ref_activity_layout (id, code, name, description, grid) VALUES
    (0, 'soc_grid_4_20', 'SOC-GRID-4-20', '4 puntos de muestreo a 20m',
     '{"points": 4, "distance_m": 20, "pattern": "cross"}'),
    (1, 'ltm_grid_v1', 'LTM-GRID-V1', '14 puntos con transectos e infiltración',
     '{"points": 14, "transects": 3, "infiltration_points": 2}');

-- Monitoring Workflow
CREATE TABLE monitoring_workflow (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    definition JSONB DEFAULT '{}'::jsonb,
    activity_layout_id INTEGER REFERENCES ref_activity_layout(id),
    site_required BOOLEAN NOT NULL DEFAULT TRUE,
    allow_repetitive_tasks BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO monitoring_workflow (id, code, name, description, activity_layout_id, site_required, allow_repetitive_tasks) VALUES
    (0, 'soc', 'SOC', 'Monitoreo de carbono en suelo', 0, TRUE, FALSE),
    (1, 'stm', 'STM', 'Monitoreo de corto plazo', NULL, TRUE, FALSE),
    (2, 'ltm', 'LTM', 'Monitoreo de largo plazo', 1, TRUE, FALSE),
    (3, 'socpoa', 'SOCPOA', 'Monitoreo de carbono en suelo programa POA', 0, TRUE, FALSE),
    (4, 'fbc', 'FBC', 'Validación de perímetro', 0, FALSE, TRUE);
