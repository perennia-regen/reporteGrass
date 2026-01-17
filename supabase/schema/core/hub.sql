-- Domain: Core
-- Table: hubs (from ruuts-api dump)
-- Description: Regional organization managing multiple farms

CREATE TABLE public.hubs (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "hubspotId" character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    country character varying(255),
    province character varying(255),
    "createdBy" character varying(255),
    "referentsEmails" character varying(255)[],
    logo character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "countryId" integer,
    CONSTRAINT hubs_pkey PRIMARY KEY (id)
);

-- Indexes
CREATE INDEX idx_hubs_countryId ON public.hubs("countryId");

COMMENT ON TABLE public.hubs IS 'Regional organization managing multiple farms - from ruuts-api';
COMMENT ON COLUMN public.hubs."referentsEmails" IS 'Array of referent email addresses';
