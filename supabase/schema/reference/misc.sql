-- Domain: Reference / Miscellaneous
-- Additional reference tables (from ruuts-api dump)

-- Document Type
CREATE TABLE public."refDocumentType" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    CONSTRAINT "refDocumentType_pkey" PRIMARY KEY (id)
);

-- Entity Type
CREATE TABLE public."refEntityType" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    CONSTRAINT "refEntityType_pkey" PRIMARY KEY (id)
);

-- Entity Discard Reason
CREATE TABLE public."refEntityDiscardReason" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "refEntityDiscardReason_pkey" PRIMARY KEY (id)
);

-- Fuel Type
CREATE TABLE public."refFuelType" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    CONSTRAINT "refFuelType_pkey" PRIMARY KEY (id)
);

-- Fuel Emissions Factors
CREATE TABLE public."refFuelEmissionsFactors" (
    id integer NOT NULL,
    "fuelTypeId" integer NOT NULL,
    "effectiveCo2Emissions_tGJ" character varying(255) NOT NULL,
    "netCalorificValue_tJGG" character varying(255),
    "kgFuelPerGallon" character varying(255),
    "ipccAssessmentReport" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "refFuelEmissionsFactors_pkey" PRIMARY KEY (id)
);

-- Green House Gases GWP
CREATE TABLE public."refGreenHouseGasesGwp" (
    id integer NOT NULL,
    "chemicalName" character varying(255) NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "en_US" character varying(255) NOT NULL,
    gwp100 numeric NOT NULL,
    "ipccAssessmentReport" character varying(255) NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "refGreenHouseGasesGwp_pkey" PRIMARY KEY (id)
);

-- Units
CREATE TABLE public."refUnits" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "refUnits_pkey" PRIMARY KEY (id)
);

-- Indexes
CREATE INDEX "idx_refFuelEmissionsFactors_fuelTypeId" ON public."refFuelEmissionsFactors"("fuelTypeId");

COMMENT ON TABLE public."refDocumentType" IS 'Document types - from ruuts-api';
COMMENT ON TABLE public."refEntityType" IS 'Entity types - from ruuts-api';
COMMENT ON TABLE public."refEntityDiscardReason" IS 'Entity discard reasons - from ruuts-api';
COMMENT ON TABLE public."refFuelType" IS 'Fuel types - from ruuts-api';
COMMENT ON TABLE public."refFuelEmissionsFactors" IS 'IPCC fuel emissions factors - from ruuts-api';
COMMENT ON TABLE public."refGreenHouseGasesGwp" IS 'GHG Global Warming Potentials - from ruuts-api';
COMMENT ON TABLE public."refUnits" IS 'Unit of measurement types - from ruuts-api';
