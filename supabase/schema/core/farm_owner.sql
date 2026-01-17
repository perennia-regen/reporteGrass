-- Domain: Core
-- Table: farmOwners (from ruuts-api dump)
-- Description: Legal entity owning farms

CREATE TABLE public."farmOwners" (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    "legalCompanyName" character varying(255) NOT NULL,
    cuit character varying(255) NOT NULL,
    "primaryContactName" character varying(255) NOT NULL,
    "legalAddress" character varying(255) NOT NULL,
    city character varying(255) NOT NULL,
    province character varying(255) NOT NULL,
    "primaryContactPhone" character varying(255),
    "primaryContactEmail" character varying(255) NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "farmOwners_pkey" PRIMARY KEY (id)
);

-- Indexes
CREATE INDEX "idx_farmOwners_cuit" ON public."farmOwners"(cuit);

COMMENT ON TABLE public."farmOwners" IS 'Legal entity owning farms - from ruuts-api';
COMMENT ON COLUMN public."farmOwners".cuit IS 'Tax ID (Argentina)';
