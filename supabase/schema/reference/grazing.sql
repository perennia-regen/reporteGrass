-- Domain: Reference / Grazing
-- Tables for grazing management (from ruuts-api dump)

-- Grazing Type
CREATE TABLE public."refGrazingType" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    CONSTRAINT "refGrazingType_pkey" PRIMARY KEY (id)
);

-- Grazing Intensity Types
CREATE TABLE public."refGrazingIntensityTypes" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    CONSTRAINT "refGrazingIntensityTypes_pkey" PRIMARY KEY (id)
);

-- Grazing Plan Type
CREATE TABLE public."refGrazingPlanType" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    CONSTRAINT "refGrazingPlanType_pkey" PRIMARY KEY (id)
);

-- Livestock Raising Types
CREATE TABLE public."refLivestockRaisingTypes" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    CONSTRAINT "refLivestockRaisingTypes_pkey" PRIMARY KEY (id)
);

COMMENT ON TABLE public."refGrazingType" IS 'Grazing types - from ruuts-api';
COMMENT ON TABLE public."refGrazingIntensityTypes" IS 'Grazing intensity levels - from ruuts-api';
COMMENT ON TABLE public."refGrazingPlanType" IS 'Grazing plan types - from ruuts-api';
COMMENT ON TABLE public."refLivestockRaisingTypes" IS 'Livestock raising types - from ruuts-api';
