-- Domain: Core / Business
-- Tables for business entities (from ruuts-api dump)

-- Deals
CREATE TABLE public.deals (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    "hubspotId" character varying(255),
    "hsPipeline" character varying(255) NOT NULL,
    "hsStage" character varying(255) NOT NULL,
    "programId" integer NOT NULL,
    "farmId" uuid NOT NULL,
    "createdBy" character varying(255),
    "isDeleted" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT deals_pkey PRIMARY KEY (id)
);

-- Documents
CREATE TABLE public.documents (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    "farmId" uuid NOT NULL,
    "documentTypeId" integer NOT NULL,
    name character varying(255) NOT NULL,
    key character varying(255) NOT NULL,
    link character varying(255),
    "isDeleted" boolean DEFAULT false NOT NULL,
    "createdBy" character varying(255),
    "updatedBy" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT documents_pkey PRIMARY KEY (id)
);

-- Discarded Entities
CREATE TABLE public."discardedEntities" (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    "farmId" uuid NOT NULL,
    "entityTypeId" integer NOT NULL,
    "entityId" uuid NOT NULL,
    "reasonId" integer NOT NULL,
    geometry geometry,
    "totalHectares" double precision,
    "isDeleted" boolean DEFAULT false,
    "updatedBy" character varying(255),
    "updatedAt" timestamp with time zone,
    "createdBy" character varying(255),
    "createdAt" timestamp with time zone,
    CONSTRAINT "discardedEntities_pkey" PRIMARY KEY (id)
);

-- Indexes
CREATE INDEX idx_deals_farmId ON public.deals("farmId");
CREATE INDEX idx_deals_programId ON public.deals("programId");
CREATE INDEX idx_deals_hubspotId ON public.deals("hubspotId");
CREATE INDEX idx_documents_farmId ON public.documents("farmId");
CREATE INDEX idx_documents_typeId ON public.documents("documentTypeId");
CREATE INDEX "idx_discardedEntities_farmId" ON public."discardedEntities"("farmId");
CREATE INDEX "idx_discardedEntities_entityTypeId" ON public."discardedEntities"("entityTypeId");

COMMENT ON TABLE public.deals IS 'Business deals from HubSpot - from ruuts-api';
COMMENT ON TABLE public.documents IS 'Farm documents - from ruuts-api';
COMMENT ON TABLE public."discardedEntities" IS 'Discarded entities tracking - from ruuts-api';
