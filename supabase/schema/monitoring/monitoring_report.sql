-- Domain: Monitoring
-- Tables: monitoringReports, dataCollectionStatement, formDefinitions (from ruuts-api dump)

-- Monitoring Reports
CREATE TABLE public."monitoringReports" (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    "farmId" uuid NOT NULL,
    "monitoringReportStatusId" integer DEFAULT 0,
    year integer NOT NULL,
    "monitoringEventIds" uuid[] DEFAULT ARRAY[]::uuid[] NOT NULL,
    "monitoringActivityIds" uuid[] DEFAULT ARRAY[]::uuid[] NOT NULL,
    "userInput" jsonb,
    "cachedFiles" jsonb,
    "updatedBy" character varying(255),
    "updatedAt" timestamp with time zone,
    "createdBy" character varying(255),
    "createdAt" timestamp with time zone,
    "isDeleted" boolean DEFAULT false NOT NULL,
    CONSTRAINT "monitoringReports_pkey" PRIMARY KEY (id)
);

-- Data Collection Statement
CREATE TABLE public."dataCollectionStatement" (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    "dataCollectionStatementStatusId" integer DEFAULT 0,
    "ownerUserRoleId" integer NOT NULL,
    "farmSubdivisionId" uuid NOT NULL,
    "metricsEventsIds" uuid[] DEFAULT ARRAY[]::uuid[] NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "updatedBy" character varying(255),
    "updatedAt" timestamp with time zone,
    "createdBy" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    CONSTRAINT "dataCollectionStatement_pkey" PRIMARY KEY (id)
);

-- Data Collection Statement History
CREATE TABLE public."dataCollectionStatementHistory" (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    "dataCollectionStatementId" uuid NOT NULL,
    "dataCollectionStatementStatusId" integer DEFAULT 0,
    "ownerUserRoleId" integer NOT NULL,
    "farmSubdivisionId" uuid NOT NULL,
    "metricsEventsIds" uuid[] DEFAULT ARRAY[]::uuid[] NOT NULL,
    "updatedBy" character varying(255),
    "updatedAt" timestamp with time zone,
    "createdBy" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    CONSTRAINT "dataCollectionStatementHistory_pkey" PRIMARY KEY (id)
);

-- Form Definitions
CREATE TABLE public."formDefinitions" (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    "programId" integer NOT NULL,
    namespace character varying(255) NOT NULL,
    version character varying(255) NOT NULL,
    label character varying(255) NOT NULL,
    required boolean DEFAULT false NOT NULL,
    "requiredMessage" character varying(255),
    "showMap" boolean DEFAULT false NOT NULL,
    "showTable" boolean DEFAULT false NOT NULL,
    fields json NOT NULL,
    dependencies json NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "createdBy" character varying(255) NOT NULL,
    "updatedBy" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "allowMultipleRecords" boolean,
    CONSTRAINT "formDefinitions_pkey" PRIMARY KEY (id)
);

-- Indexes
CREATE INDEX "idx_monitoringReports_farmId" ON public."monitoringReports"("farmId");
CREATE INDEX "idx_monitoringReports_year" ON public."monitoringReports"(year);
CREATE INDEX "idx_monitoringReports_statusId" ON public."monitoringReports"("monitoringReportStatusId");
CREATE INDEX "idx_dataCollectionStatement_farmSubId" ON public."dataCollectionStatement"("farmSubdivisionId");
CREATE INDEX "idx_dataCollectionStatement_statusId" ON public."dataCollectionStatement"("dataCollectionStatementStatusId");
CREATE INDEX "idx_formDefinitions_programId" ON public."formDefinitions"("programId");
CREATE INDEX "idx_formDefinitions_namespace" ON public."formDefinitions"(namespace);

COMMENT ON TABLE public."monitoringReports" IS 'Generated monitoring reports - from ruuts-api';
COMMENT ON TABLE public."dataCollectionStatement" IS 'Data collection statements - from ruuts-api';
COMMENT ON TABLE public."dataCollectionStatementHistory" IS 'Data collection statement history - from ruuts-api';
COMMENT ON TABLE public."formDefinitions" IS 'Dynamic form definitions - from ruuts-api';
