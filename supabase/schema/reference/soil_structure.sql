-- Domain: Reference / Soil Structure
-- Tables for soil structure classifications (from ruuts-api dump)

-- Structure Grade
CREATE TABLE public."refStructureGrade" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_AR_long" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "es_PY_long" character varying(255),
    "en_US" character varying(255),
    "en_US_long" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    CONSTRAINT "refStructureGrade_pkey" PRIMARY KEY (id)
);

-- Structure Size
CREATE TABLE public."refStructureSize" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_AR_long" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "es_PY_long" character varying(255),
    "en_US" character varying(255),
    "en_US_long" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    CONSTRAINT "refStructureSize_pkey" PRIMARY KEY (id)
);

-- Structure Type
CREATE TABLE public."refStructureType" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_AR_long" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "es_PY_long" character varying(255),
    "en_US" character varying(255),
    "en_US_long" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    CONSTRAINT "refStructureType_pkey" PRIMARY KEY (id)
);

COMMENT ON TABLE public."refStructureGrade" IS 'Soil structure grade - from ruuts-api';
COMMENT ON TABLE public."refStructureSize" IS 'Soil structure size - from ruuts-api';
COMMENT ON TABLE public."refStructureType" IS 'Soil structure type - from ruuts-api';
