-- Domain: Areas
-- Table: carbonInstances (from ruuts-api dump)
-- Description: Carbon monitoring instances/projects on farms

CREATE TABLE public."carbonInstances" (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    name character varying(255) NOT NULL,
    "farmId" uuid NOT NULL,
    "initDate" timestamp with time zone NOT NULL,
    "instanceYear" character varying(255) NOT NULL,
    "samplingAreaId" uuid NOT NULL,
    paddocks json,
    "baselinePaddocks" json,
    geometry geometry,
    "totalHectares" double precision,
    color character varying(255),
    "createdBy" character varying(255),
    "updatedBy" character varying(255),
    "isDeleted" boolean DEFAULT false,
    "verificationStatusId" integer,
    "verifiedBy" character varying(255),
    "verifiedAt" timestamp with time zone,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "carbonInstances_pkey" PRIMARY KEY (id)
);

-- Indexes
CREATE INDEX "idx_carbonInstances_geometry" ON public."carbonInstances" USING GIST (geometry);
CREATE INDEX "idx_carbonInstances_farmId" ON public."carbonInstances"("farmId");
CREATE INDEX "idx_carbonInstances_samplingAreaId" ON public."carbonInstances"("samplingAreaId");
CREATE INDEX "idx_carbonInstances_not_deleted" ON public."carbonInstances"(id) WHERE "isDeleted" = FALSE;

COMMENT ON TABLE public."carbonInstances" IS 'Carbon monitoring instances/projects - from ruuts-api';
COMMENT ON COLUMN public."carbonInstances".paddocks IS 'JSON array of related paddock IDs';
