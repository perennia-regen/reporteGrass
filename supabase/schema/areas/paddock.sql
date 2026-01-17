-- Domain: Areas
-- Table: paddocks (from ruuts-api dump)
-- Description: Physical land parcels (lotes) within a farm

CREATE TABLE public.paddocks (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(255) NOT NULL,
    "farmId" uuid NOT NULL,
    "totalHectares" double precision,
    "isDeleted" boolean DEFAULT false NOT NULL,
    geometry public.geometry,
    "uncroppedGeometry" public.geometry,
    color character varying(255),
    "createdBy" character varying(255),
    "updatedBy" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isInProject" boolean,
    CONSTRAINT paddocks_pkey PRIMARY KEY (id)
);

-- Indexes
CREATE INDEX idx_paddocks_geometry ON public.paddocks USING GIST (geometry);
CREATE INDEX idx_paddocks_farmId ON public.paddocks("farmId");
CREATE INDEX idx_paddocks_not_deleted ON public.paddocks(id) WHERE "isDeleted" = FALSE;

COMMENT ON TABLE public.paddocks IS 'Physical land parcels (lotes) within a farm - from ruuts-api';
