-- Domain: Reference / Workflows
-- Tables for monitoring workflows and activity layouts (from ruuts-api dump)

-- Activity Layouts
CREATE TABLE public."refActivityLayouts" (
    id integer NOT NULL,
    "monitoringWorkflowId" integer NOT NULL,
    name character varying(255) NOT NULL,
    grid json NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    CONSTRAINT "refActivityLayouts_pkey" PRIMARY KEY (id)
);

-- Monitoring Workflows
CREATE TABLE public."monitoringWorkflows" (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(255) NOT NULL,
    definition json,
    "activityLayoutId" integer,
    "siteRequired" boolean NOT NULL,
    "allowRepetitiveTasks" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    CONSTRAINT "monitoringWorkflows_pkey" PRIMARY KEY (id)
);

-- Indexes
CREATE INDEX "idx_refActivityLayouts_workflowId" ON public."refActivityLayouts"("monitoringWorkflowId");

COMMENT ON TABLE public."refActivityLayouts" IS 'Activity layout definitions - from ruuts-api';
COMMENT ON TABLE public."monitoringWorkflows" IS 'Monitoring workflow definitions - from ruuts-api';
