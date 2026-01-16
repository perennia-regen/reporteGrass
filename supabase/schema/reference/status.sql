-- Domain: Reference / Status
-- Tables for status enums and states

-- Task Status
CREATE TABLE ref_task_status (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    sort_order INTEGER DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO ref_task_status (id, code, name, sort_order) VALUES
    (0, 'pending', 'Pendiente', 0),
    (1, 'in_progress', 'En Curso', 1),
    (2, 'finished', 'Finalizado', 2),
    (3, 'cancelled', 'Cancelado', 3),
    (4, 'omitted', 'Omitido', 4);

-- Verification Status
CREATE TABLE ref_verification_status (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO ref_verification_status (code, name) VALUES
    ('pending', 'Pendiente'),
    ('verified', 'Verificado'),
    ('rejected', 'Rechazado'),
    ('needs_review', 'Requiere Revisión');

-- Monitoring Report Status
CREATE TABLE ref_monitoring_report_status (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    color VARCHAR(20),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO ref_monitoring_report_status (id, code, name, color) VALUES
    (0, 'in_progress', 'En Curso', 'primary'),
    (1, 'finished', 'Finalizado', 'success');

-- Data Collection Statement Status
CREATE TABLE ref_data_collection_statement_status (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    es_ar VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO ref_data_collection_statement_status (id, code, name, es_ar) VALUES
    (0, 'pending', 'Pending', 'Pendiente'),
    (1, 'in_process', 'In Process', 'En Proceso'),
    (2, 'to_review', 'To Review', 'Para Revisión'),
    (3, 'in_review', 'In Review', 'En Revisión'),
    (4, 'observed', 'Observed', 'Observado'),
    (5, 'approved', 'Approved', 'Aprobado'),
    (6, 'full_approved', 'Full Approved', 'Aprobado Completo'),
    (7, 'non_compliant', 'Non Compliant', 'No Cumple');

-- Finding Type
CREATE TABLE ref_finding_type (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    es_ar VARCHAR(100),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO ref_finding_type (id, code, name, es_ar) VALUES
    (0, 'observation', 'Observation', 'Observación'),
    (1, 'non_compliance_to_fix', 'Non Compliance To Fix', 'Incumplimiento a Corregir'),
    (2, 'non_compliance_severe', 'Non Compliance Severe', 'Incumplimiento Grave');

-- User Role
CREATE TABLE ref_user_role (
    id SERIAL PRIMARY KEY,
    code VARCHAR(50) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO ref_user_role (code, name) VALUES
    ('admin', 'Administrador'),
    ('hub_admin', 'Administrador de Hub'),
    ('technician', 'Técnico'),
    ('viewer', 'Visualizador'),
    ('owner', 'Propietario');
