-- Domain: Monitoring
-- Table: monitoringEvents (from ruuts-api dump)
-- Description: Monitoring campaigns/surveys on specific dates

CREATE TABLE public."monitoringEvents" (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(255) NOT NULL,
    "taskStatusId" integer NOT NULL,
    "completedActivities" integer DEFAULT 0,
    "totalActivities" integer DEFAULT 1,
    "farmId" uuid NOT NULL,
    date timestamp with time zone NOT NULL,
    "assignedTo" character varying(255),
    "monitoringWorkflowIds" integer[] NOT NULL,
    "samplingAreas" uuid[],
    "monitoringSitesIds" uuid[],
    _rev uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "createdBy" character varying(255),
    "updatedBy" character varying(255),
    "isDeleted" boolean DEFAULT false,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isBackdatedEvent" boolean,
    CONSTRAINT "monitoringEvents_pkey" PRIMARY KEY (id)
);

-- Indexes
CREATE INDEX "idx_monitoringEvents_farmId" ON public."monitoringEvents"("farmId");
CREATE INDEX "idx_monitoringEvents_date" ON public."monitoringEvents"(date);
CREATE INDEX "idx_monitoringEvents_taskStatusId" ON public."monitoringEvents"("taskStatusId");
CREATE INDEX "idx_monitoringEvents_not_deleted" ON public."monitoringEvents"(id) WHERE "isDeleted" = FALSE;

COMMENT ON TABLE public."monitoringEvents" IS 'Monitoring campaigns/surveys - from ruuts-api';
COMMENT ON COLUMN public."monitoringEvents"._rev IS 'Revision UUID for mobile sync';
