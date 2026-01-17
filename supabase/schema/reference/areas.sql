-- Domain: Reference / Areas
-- Tables for area types and exclusions (from ruuts-api dump)

-- Exclusion Area Type
CREATE TABLE public."refExclusionAreaType" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "programIds" integer[],
    CONSTRAINT "refExclusionAreaType_pkey" PRIMARY KEY (id)
);

-- Field Usage
CREATE TABLE public."refFieldUsage" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    CONSTRAINT "refFieldUsage_pkey" PRIMARY KEY (id)
);

COMMENT ON TABLE public."refExclusionAreaType" IS 'Exclusion area types - from ruuts-api';
COMMENT ON TABLE public."refFieldUsage" IS 'Field usage types - from ruuts-api';
