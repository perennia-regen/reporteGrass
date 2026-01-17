-- Domain: Core
-- Table: programs (from ruuts-api dump)
-- Description: Monitoring program (e.g., GRASS)

CREATE TABLE public.programs (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    version character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    CONSTRAINT programs_pkey PRIMARY KEY (id)
);

-- Program Config
CREATE TABLE public."programConfig" (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    "programId" integer NOT NULL,
    "formDefinitions" json NOT NULL,
    "baselineYears" integer NOT NULL,
    "dataCollectionEnabled" boolean DEFAULT true NOT NULL,
    "monitoringWorkflowIds" integer[],
    "exclusionAreasModesAllowed" character varying(255)[] NOT NULL,
    "stratificationModesAllowed" character varying(255)[] NOT NULL,
    "stratasConfigEndpoint" json NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "farmSubdivisionsYearsAllowed" character varying(255)[] NOT NULL,
    "createdBy" character varying(255) NOT NULL,
    "updatedBy" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "allowedGrazingPaddockFieldUsages" integer[],
    "randomizeVersion" character varying(255),
    "enabledReports" character varying(255)[],
    "blockedMonitoringPeriods" json[],
    CONSTRAINT "programConfig_pkey" PRIMARY KEY (id)
);

-- Indexes
CREATE INDEX "idx_programConfig_programId" ON public."programConfig"("programId");

COMMENT ON TABLE public.programs IS 'Monitoring program definitions - from ruuts-api';
COMMENT ON TABLE public."programConfig" IS 'Program configuration - from ruuts-api';
