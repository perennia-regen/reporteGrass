-- Domain: Monitoring
-- Table: monitoringActivity (from ruuts-api dump)
-- Description: Individual activities within monitoring events

CREATE TABLE public."monitoringActivity" (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    key character varying(255) NOT NULL,
    "taskStatusId" integer DEFAULT 0 NOT NULL,
    "totalTasks" integer DEFAULT 1,
    "completedTasks" integer DEFAULT 0,
    "monitoringEventId" uuid NOT NULL,
    "monitoringWorkflowId" integer NOT NULL,
    description character varying(255) NOT NULL,
    "samplingAreaId" uuid,
    "monitoringSiteId" uuid,
    "actualLocation" json,
    "hasLayoutPattern" boolean DEFAULT false,
    "activityLayoutId" integer,
    "activityGrid" json,
    _rev uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "isDeleted" boolean DEFAULT false,
    "updatedBy" character varying(255),
    "updatedAt" timestamp with time zone,
    "createdBy" character varying(255),
    "createdAt" timestamp with time zone,
    CONSTRAINT "monitoringActivity_pkey" PRIMARY KEY (id)
);

-- Indexes
CREATE INDEX "idx_monitoringActivity_eventId" ON public."monitoringActivity"("monitoringEventId");
CREATE INDEX "idx_monitoringActivity_workflowId" ON public."monitoringActivity"("monitoringWorkflowId");
CREATE INDEX "idx_monitoringActivity_siteId" ON public."monitoringActivity"("monitoringSiteId");
CREATE INDEX "idx_monitoringActivity_not_deleted" ON public."monitoringActivity"(id) WHERE "isDeleted" = FALSE;

COMMENT ON TABLE public."monitoringActivity" IS 'Individual activities within monitoring events - from ruuts-api';
COMMENT ON COLUMN public."monitoringActivity".key IS 'Unique key within the event';
COMMENT ON COLUMN public."monitoringActivity"._rev IS 'Revision UUID for mobile sync';
