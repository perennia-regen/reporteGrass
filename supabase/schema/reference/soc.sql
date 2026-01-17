-- Domain: Reference / SOC (Soil Organic Carbon)
-- Tables for SOC sampling and soil analysis (from ruuts-api dump)

-- DAP Methods (Densidad Aparente)
CREATE TABLE public."refDAPMethods" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "isDeleted" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "refDAPMethods_pkey" PRIMARY KEY (id)
);

-- Sampling Numbers
CREATE TABLE public."refSamplingNumbers" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "isDeleted" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "refSamplingNumbers_pkey" PRIMARY KEY (id)
);

-- Soil Texture
CREATE TABLE public."refSoilTexture" (
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
    CONSTRAINT "refSoilTexture_pkey" PRIMARY KEY (id)
);

-- Soil Sampling Disturbance
CREATE TABLE public."refSoilSamplingDisturbance" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_AR_long" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "es_PY_long" character varying(255),
    "en_US" character varying(255),
    "en_US_long" character varying(255),
    "pt_BR" character varying(255),
    "pt_BR_long" character varying(255),
    "isDeleted" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "refSoilSamplingDisturbance_pkey" PRIMARY KEY (id)
);

-- Soil Sampling Tools
CREATE TABLE public."refSoilSamplingTools" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_AR_long" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "es_PY_long" character varying(255),
    "en_US" character varying(255),
    "en_US_long" character varying(255),
    "pt_BR" character varying(255),
    "pt_BR_long" character varying(255),
    "isDeleted" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "refSoilSamplingTools_pkey" PRIMARY KEY (id)
);

-- Laboratory
CREATE TABLE public."RelLaboratory" (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "RelLaboratory_pkey" PRIMARY KEY (id)
);

-- SOC Protocols
CREATE TABLE public."relSOCProtocols" (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "relSOCProtocols_pkey" PRIMARY KEY (id)
);

-- Horizon Code
CREATE TABLE public."refHorizonCode" (
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
    CONSTRAINT "refHorizonCode_pkey" PRIMARY KEY (id)
);

-- Degree Degradation Soil
CREATE TABLE public."refDegreeDegradationSoil" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    CONSTRAINT "refDegreeDegradationSoil_pkey" PRIMARY KEY (id)
);

COMMENT ON TABLE public."refDAPMethods" IS 'DAP methods for soil sampling - from ruuts-api';
COMMENT ON TABLE public."refSamplingNumbers" IS 'Sampling number types - from ruuts-api';
COMMENT ON TABLE public."refSoilTexture" IS 'Soil texture types - from ruuts-api';
COMMENT ON TABLE public."RelLaboratory" IS 'Laboratory reference - from ruuts-api';
COMMENT ON TABLE public."relSOCProtocols" IS 'SOC protocols - from ruuts-api';
