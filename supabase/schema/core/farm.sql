-- Domain: Core
-- Table: farms (from ruuts-api dump)
-- Description: Agricultural property (establecimiento)

CREATE TABLE public.farms (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "hubspotId" character varying(255),
    name character varying(255) NOT NULL,
    "programId" integer NOT NULL,
    "shortName" character varying(255),
    "ownerId" uuid,
    "hubId" uuid,
    address character varying(255),
    city character varying(255),
    province character varying(255),
    country character varying(255),
    "primaryContact" character varying(255),
    geolocation character varying(255),
    "totalHectares" double precision,
    "totalHectaresDeclared" double precision,
    lat double precision,
    lng double precision,
    "totalHectaresMgmt" double precision,
    "elegibleHectaresDeclared" double precision,
    "hasNonRuutsProjects" character varying(255),
    "localLawCompliance" character varying(255),
    "isDeleted" boolean DEFAULT false NOT NULL,
    "isPerimeterValidated" boolean DEFAULT false NOT NULL,
    geometry public.geometry,
    "uncroppedGeometry" public.geometry,
    color character varying(255),
    "phoneNumber" character varying(255),
    email character varying(255),
    "targetInitialMonitoringPeriodId" uuid,
    "createdBy" character varying(255),
    "updatedBy" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "countryId" integer,
    "ecoregionId" integer,
    CONSTRAINT farms_pkey PRIMARY KEY (id)
);

-- Indexes
CREATE INDEX idx_farms_geometry ON public.farms USING GIST (geometry);
CREATE INDEX idx_farms_hubId ON public.farms("hubId");
CREATE INDEX idx_farms_programId ON public.farms("programId");
CREATE INDEX idx_farms_ownerId ON public.farms("ownerId");
CREATE INDEX idx_farms_countryId ON public.farms("countryId");
CREATE INDEX idx_farms_not_deleted ON public.farms(id) WHERE "isDeleted" = FALSE;

COMMENT ON TABLE public.farms IS 'Agricultural property (establecimiento) with geospatial boundaries - from ruuts-api';
