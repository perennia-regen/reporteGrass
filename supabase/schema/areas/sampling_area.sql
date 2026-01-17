-- Domain: Areas
-- Table: samplingAreas (from ruuts-api dump)
-- Description: Strata/sampling units within farms for monitoring

CREATE TABLE public."samplingAreas" (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(255) NOT NULL,
    "farmId" uuid NOT NULL,
    geometry public.geometry,
    "uncroppedGeometry" public.geometry,
    "totalHectares" double precision,
    color character varying(255),
    "createdBy" character varying(255),
    "updatedBy" character varying(255),
    "isDeleted" boolean DEFAULT false,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "samplingAreas_pkey" PRIMARY KEY (id)
);

-- Indexes
CREATE INDEX "idx_samplingAreas_geometry" ON public."samplingAreas" USING GIST (geometry);
CREATE INDEX "idx_samplingAreas_farmId" ON public."samplingAreas"("farmId");
CREATE INDEX "idx_samplingAreas_not_deleted" ON public."samplingAreas"(id) WHERE "isDeleted" = FALSE;

COMMENT ON TABLE public."samplingAreas" IS 'Strata/sampling units within farms (estratos) - from ruuts-api';
