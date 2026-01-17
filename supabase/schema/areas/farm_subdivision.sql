-- Domain: Areas
-- Table: farmSubdivisions (from ruuts-api dump)
-- Description: Annual grouping of paddocks for monitoring purposes

CREATE TABLE public."farmSubdivisions" (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    "paddockIds" uuid[],
    "activitiesStatus" json[],
    year character varying(255) NOT NULL,
    "farmId" uuid NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "createdBy" character varying(255),
    "updatedBy" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "templateFileName" character varying,
    CONSTRAINT "farmSubdivisions_pkey" PRIMARY KEY (id)
);

-- Indexes
CREATE INDEX "idx_farmSubdivisions_farmId" ON public."farmSubdivisions"("farmId");
CREATE INDEX "idx_farmSubdivisions_year" ON public."farmSubdivisions"(year);
CREATE INDEX "idx_farmSubdivisions_not_deleted" ON public."farmSubdivisions"(id) WHERE "isDeleted" = FALSE;

COMMENT ON TABLE public."farmSubdivisions" IS 'Annual grouping of paddocks for monitoring - from ruuts-api';
