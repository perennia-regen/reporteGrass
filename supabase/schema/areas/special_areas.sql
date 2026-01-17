-- Domain: Areas / Special Areas
-- Tables for special area types (from ruuts-api dump)

-- Deforested Areas
CREATE TABLE public."deforestedAreas" (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    name character varying(255),
    "farmId" uuid NOT NULL,
    geometry geometry,
    "featureCollection" json,
    "totalHectares" double precision,
    color character varying(255),
    "createdBy" character varying(255),
    "updatedBy" character varying(255),
    "isDeleted" boolean DEFAULT false,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "deforestedAreas_pkey" PRIMARY KEY (id)
);

-- Forest Areas
CREATE TABLE public."forestAreas" (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    name character varying(255),
    "farmId" uuid NOT NULL,
    geometry geometry,
    "featureCollection" json,
    "totalHectares" double precision,
    color character varying(255),
    "createdBy" character varying(255),
    "updatedBy" character varying(255),
    "isDeleted" boolean DEFAULT false,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "forestAreas_pkey" PRIMARY KEY (id)
);

-- Wetland Areas
CREATE TABLE public."wetlandAreas" (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    name character varying(255),
    "farmId" uuid NOT NULL,
    geometry geometry,
    "featureCollection" json,
    "totalHectares" double precision,
    color character varying(255),
    "createdBy" character varying(255),
    "updatedBy" character varying(255),
    "isDeleted" boolean DEFAULT false,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "wetlandAreas_pkey" PRIMARY KEY (id)
);

-- Other Polygons
CREATE TABLE public."otherPolygons" (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    name character varying(255) NOT NULL,
    "farmId" uuid NOT NULL,
    geometry geometry,
    "totalHectares" double precision,
    color character varying(255),
    "createdBy" character varying(255),
    "updatedBy" character varying(255),
    "isDeleted" boolean DEFAULT false,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "otherPolygons_pkey" PRIMARY KEY (id)
);

-- Other Sites
CREATE TABLE public."otherSites" (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    name character varying(255) NOT NULL,
    allocated boolean DEFAULT false,
    "farmId" uuid NOT NULL,
    "plannedLocation" json NOT NULL,
    "actualLocation" json,
    color character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "otherSites_pkey" PRIMARY KEY (id)
);

-- Indexes
CREATE INDEX "idx_deforestedAreas_geometry" ON public."deforestedAreas" USING GIST (geometry);
CREATE INDEX "idx_deforestedAreas_farmId" ON public."deforestedAreas"("farmId");
CREATE INDEX "idx_forestAreas_geometry" ON public."forestAreas" USING GIST (geometry);
CREATE INDEX "idx_forestAreas_farmId" ON public."forestAreas"("farmId");
CREATE INDEX "idx_wetlandAreas_geometry" ON public."wetlandAreas" USING GIST (geometry);
CREATE INDEX "idx_wetlandAreas_farmId" ON public."wetlandAreas"("farmId");
CREATE INDEX "idx_otherPolygons_geometry" ON public."otherPolygons" USING GIST (geometry);
CREATE INDEX "idx_otherPolygons_farmId" ON public."otherPolygons"("farmId");
CREATE INDEX "idx_otherSites_farmId" ON public."otherSites"("farmId");

COMMENT ON TABLE public."deforestedAreas" IS 'Areas with deforestation history - from ruuts-api';
COMMENT ON TABLE public."forestAreas" IS 'Forest areas on farm - from ruuts-api';
COMMENT ON TABLE public."wetlandAreas" IS 'Wetland areas on farm - from ruuts-api';
COMMENT ON TABLE public."otherPolygons" IS 'Other polygon areas - from ruuts-api';
COMMENT ON TABLE public."otherSites" IS 'Other site locations - from ruuts-api';
