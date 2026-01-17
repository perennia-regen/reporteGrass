-- Domain: Monitoring
-- Table: monitoringSites (from ruuts-api dump)
-- Description: Specific point locations for field data collection

CREATE TABLE public."monitoringSites" (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(255) NOT NULL,
    allocated boolean DEFAULT false,
    "samplingAreaId" uuid,
    "farmId" uuid,
    "plannedLocation" json NOT NULL,
    "actualLocation" json,
    "backupLocation" json,
    "locationConfirmed" boolean DEFAULT false,
    "locationMoved" boolean DEFAULT false,
    "locationMovedReasonId" integer,
    "locationMovedComments" text,
    "allowContingencyOffset" boolean DEFAULT false,
    "isRandomSite" boolean DEFAULT false,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "offsetMts" integer DEFAULT 100,
    "distanceToPlannedLocation" double precision,
    pictures bytea[],
    "randomizeCounter" integer,
    "randomizeReason" character varying(255)[],
    color character varying(255),
    _rev uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "isValidationSite" boolean DEFAULT false,
    "updatedBy" character varying(255),
    "updatedAt" timestamp with time zone,
    "createdBy" character varying(255),
    "createdAt" timestamp with time zone,
    "deviceLocationData" json,
    "locationConfirmationTypeId" integer,
    "fieldRelocationMethodId" integer,
    seed integer,
    "randomizerTypeId" integer,
    CONSTRAINT "monitoringSites_pkey" PRIMARY KEY (id)
);

-- Indexes
CREATE INDEX "idx_monitoringSites_farmId" ON public."monitoringSites"("farmId");
CREATE INDEX "idx_monitoringSites_samplingAreaId" ON public."monitoringSites"("samplingAreaId");
CREATE INDEX "idx_monitoringSites_not_deleted" ON public."monitoringSites"(id) WHERE "isDeleted" = FALSE;

COMMENT ON TABLE public."monitoringSites" IS 'Monitoring sites for field data collection - from ruuts-api';
COMMENT ON COLUMN public."monitoringSites"._rev IS 'Revision UUID for mobile sync';
COMMENT ON COLUMN public."monitoringSites"."plannedLocation" IS 'JSON with lat/lng coordinates';
