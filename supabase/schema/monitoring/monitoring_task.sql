-- Domain: Monitoring
-- Table: monitoringTasks (from ruuts-api dump)
-- Description: Individual monitoring tasks with dataPayload containing GRASS data

CREATE TABLE public."monitoringTasks" (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    key character varying(255) NOT NULL,
    "order" integer,
    enabled boolean NOT NULL,
    "monitoringSiteId" uuid,
    "monitoringActivityId" uuid NOT NULL,
    "monitoringEventId" uuid NOT NULL,
    "taskStatusId" integer DEFAULT 0 NOT NULL,
    "formName" character varying(255) DEFAULT 0,
    type character varying(255),
    "gridPositionKey" character varying(255),
    "actualLocation" json,
    "actionRangeMts" integer,
    "plannedLocation" json,
    dependencies integer[],
    description character varying(255) NOT NULL,
    "dataPayload" json,
    pictures character varying(255)[],
    _rev uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "isDeleted" boolean DEFAULT false,
    "updatedBy" character varying(255),
    "updatedAt" timestamp with time zone,
    "createdBy" character varying(255),
    "createdAt" timestamp with time zone,
    "deviceLocationData" json,
    CONSTRAINT "monitoringTasks_pkey" PRIMARY KEY (id)
);

-- Indexes
CREATE INDEX "idx_monitoringTasks_eventId" ON public."monitoringTasks"("monitoringEventId");
CREATE INDEX "idx_monitoringTasks_activityId" ON public."monitoringTasks"("monitoringActivityId");
CREATE INDEX "idx_monitoringTasks_siteId" ON public."monitoringTasks"("monitoringSiteId");
CREATE INDEX "idx_monitoringTasks_formName" ON public."monitoringTasks"("formName");
CREATE INDEX "idx_monitoringTasks_not_deleted" ON public."monitoringTasks"(id) WHERE "isDeleted" = FALSE;

COMMENT ON TABLE public."monitoringTasks" IS 'Individual monitoring tasks - dataPayload contains GRASS/ISE data';
COMMENT ON COLUMN public."monitoringTasks"."dataPayload" IS 'JSON containing form data including ISE, indicators, ecosystem processes';
COMMENT ON COLUMN public."monitoringTasks"._rev IS 'Revision UUID for mobile sync';
