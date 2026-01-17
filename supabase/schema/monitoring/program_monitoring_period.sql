-- Domain: Monitoring
-- Tables: programMonitoringPeriods, relInstanceMonitoringPeriod (from ruuts-api dump)

-- Program Monitoring Periods
CREATE TABLE public."programMonitoringPeriods" (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    "programId" integer NOT NULL,
    name character varying(255) NOT NULL,
    "startDate" timestamp with time zone,
    "endDate" timestamp with time zone,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "createdBy" character varying(255) NOT NULL,
    "updatedBy" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "programMonitoringPeriods_pkey" PRIMARY KEY (id)
);

-- Junction table: Carbon Instance to Monitoring Period
CREATE TABLE public."relInstanceMonitoringPeriod" (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    "carbonInstanceId" uuid NOT NULL,
    "monitoringPeriodId" uuid NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "createdBy" character varying(255) NOT NULL,
    "updatedBy" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "relInstanceMonitoringPeriod_pkey" PRIMARY KEY (id)
);

-- Indexes
CREATE INDEX "idx_programMonitoringPeriods_programId" ON public."programMonitoringPeriods"("programId");
CREATE INDEX "idx_relInstanceMonitoringPeriod_carbonInstanceId" ON public."relInstanceMonitoringPeriod"("carbonInstanceId");
CREATE INDEX "idx_relInstanceMonitoringPeriod_periodId" ON public."relInstanceMonitoringPeriod"("monitoringPeriodId");

COMMENT ON TABLE public."programMonitoringPeriods" IS 'Temporal monitoring periods within programs - from ruuts-api';
COMMENT ON TABLE public."relInstanceMonitoringPeriod" IS 'Links carbon instances to monitoring periods - from ruuts-api';
