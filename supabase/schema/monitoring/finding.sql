-- Domain: Monitoring
-- Table: findings (from ruuts-api dump)
-- Description: Quality issues/findings from monitoring events

CREATE TABLE public.findings (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    "metricEventId" uuid NOT NULL,
    type integer NOT NULL,
    "metricEventsFieldsObserved" json[] NOT NULL,
    comment character varying(255),
    resolved boolean DEFAULT false NOT NULL,
    "createdBy" character varying(255),
    "updatedBy" character varying(255),
    "isDeleted" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT findings_pkey PRIMARY KEY (id)
);

-- Finding Comments
CREATE TABLE public."findingComments" (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    message character varying(255),
    "findingId" uuid NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "createdBy" character varying(255),
    "updatedBy" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "findingComments_pkey" PRIMARY KEY (id)
);

-- Finding History
CREATE TABLE public."findingHistory" (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    "findingId" uuid NOT NULL,
    "metricEventId" uuid NOT NULL,
    type integer NOT NULL,
    "metricEventsFieldsObserved" json[] NOT NULL,
    comment character varying(255),
    resolved boolean DEFAULT false NOT NULL,
    "updatedBy" character varying(255),
    "updatedAt" timestamp with time zone,
    "createdBy" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    CONSTRAINT "findingHistory_pkey" PRIMARY KEY (id)
);

-- Indexes
CREATE INDEX idx_findings_metricEventId ON public.findings("metricEventId");
CREATE INDEX idx_findings_resolved ON public.findings(resolved);
CREATE INDEX idx_findings_not_deleted ON public.findings(id) WHERE "isDeleted" = FALSE;
CREATE INDEX "idx_findingComments_findingId" ON public."findingComments"("findingId");
CREATE INDEX "idx_findingHistory_findingId" ON public."findingHistory"("findingId");

COMMENT ON TABLE public.findings IS 'Quality issues/findings from monitoring events - from ruuts-api';
COMMENT ON TABLE public."findingComments" IS 'Comments on findings - from ruuts-api';
COMMENT ON TABLE public."findingHistory" IS 'Finding history for auditing - from ruuts-api';
