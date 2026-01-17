-- Domain: Reference / Status
-- Tables for status enums and states (from ruuts-api dump)

-- Task Status
CREATE TABLE public."refTaskStatus" (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    CONSTRAINT "refTaskStatus_pkey" PRIMARY KEY (id)
);

-- Monitoring Report Status
CREATE TABLE public."refMonitoringReportStatus" (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    color character varying(255) NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    CONSTRAINT "refMonitoringReportStatus_pkey" PRIMARY KEY (id)
);

-- Data Collection Statement Status
CREATE TABLE public."refDataCollectionStatementStatus" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    CONSTRAINT "refDataCollectionStatementStatus_pkey" PRIMARY KEY (id)
);

-- Finding Type
CREATE TABLE public."refFindingType" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    CONSTRAINT "refFindingType_pkey" PRIMARY KEY (id)
);

-- User Role
CREATE TABLE public."refUserRole" (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    CONSTRAINT "refUserRole_pkey" PRIMARY KEY (id)
);

-- Instances Verification Status
CREATE TABLE public."refInstancesVerificationStatus" (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "refInstancesVerificationStatus_pkey" PRIMARY KEY (id)
);

-- Metric Status
CREATE TABLE public."refMetricStatus" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    CONSTRAINT "refMetricStatus_pkey" PRIMARY KEY (id)
);

COMMENT ON TABLE public."refTaskStatus" IS 'Task status values - from ruuts-api';
COMMENT ON TABLE public."refMonitoringReportStatus" IS 'Monitoring report status values - from ruuts-api';
COMMENT ON TABLE public."refDataCollectionStatementStatus" IS 'Data collection statement status - from ruuts-api';
COMMENT ON TABLE public."refFindingType" IS 'Finding type values - from ruuts-api';
COMMENT ON TABLE public."refUserRole" IS 'User role values - from ruuts-api';
