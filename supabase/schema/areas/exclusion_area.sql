-- Domain: Areas
-- Table: exclusionAreas (from ruuts-api dump)
-- Description: Areas excluded from monitoring/management activities

CREATE TABLE public."exclusionAreas" (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    name character varying(255) NOT NULL,
    "otherName" character varying(255),
    "farmId" uuid NOT NULL,
    geometry geometry,
    "uncroppedGeometry" geometry,
    "exclusionAreaTypeId" integer NOT NULL,
    "totalHectares" double precision,
    color character varying(255),
    "createdBy" character varying(255),
    "updatedBy" character varying(255),
    "isDeleted" boolean DEFAULT false,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "hasGrazingManagement" boolean DEFAULT false NOT NULL,
    CONSTRAINT "exclusionAreas_pkey" PRIMARY KEY (id)
);

-- Exclusion Area History
CREATE TABLE public."exclusionAreaHistory" (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    "exclusionAreaId" uuid NOT NULL,
    name character varying(255) NOT NULL,
    "otherName" character varying(255),
    "farmId" uuid NOT NULL,
    geometry geometry,
    "uncroppedGeometry" geometry,
    "exclusionAreaTypeId" integer NOT NULL,
    "totalHectares" double precision,
    color character varying(255),
    "createdBy" character varying(255),
    "updatedBy" character varying(255),
    "isDeleted" boolean DEFAULT false,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "exclusionAreaHistory_pkey" PRIMARY KEY (id)
);

-- Indexes
CREATE INDEX "idx_exclusionAreas_geometry" ON public."exclusionAreas" USING GIST (geometry);
CREATE INDEX "idx_exclusionAreas_farmId" ON public."exclusionAreas"("farmId");
CREATE INDEX "idx_exclusionAreas_typeId" ON public."exclusionAreas"("exclusionAreaTypeId");
CREATE INDEX "idx_exclusionAreas_not_deleted" ON public."exclusionAreas"(id) WHERE "isDeleted" = FALSE;
CREATE INDEX "idx_exclusionAreaHistory_areaId" ON public."exclusionAreaHistory"("exclusionAreaId");

COMMENT ON TABLE public."exclusionAreas" IS 'Areas excluded from monitoring - from ruuts-api';
COMMENT ON TABLE public."exclusionAreaHistory" IS 'Exclusion area history - from ruuts-api';
