-- Domain: Reference / Agriculture
-- Tables for crops, fertilizers, and pastures (from ruuts-api dump)

-- Crop Type
CREATE TABLE public."refCropType" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    CONSTRAINT "refCropType_pkey" PRIMARY KEY (id)
);

-- Tillage Type
CREATE TABLE public."refTillageType" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    CONSTRAINT "refTillageType_pkey" PRIMARY KEY (id)
);

-- Irrigation Type
CREATE TABLE public."refIrrigationType" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    CONSTRAINT "refIrrigationType_pkey" PRIMARY KEY (id)
);

-- Amendment Type
CREATE TABLE public."refAmmendmendType" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    CONSTRAINT "refAmmendmendType_pkey" PRIMARY KEY (id)
);

-- Mineral Fertilizer Type
CREATE TABLE public."refMineralFertilizerType" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    CONSTRAINT "refMineralFertilizerType_pkey" PRIMARY KEY (id)
);

-- Organic Fertilizer Type
CREATE TABLE public."refOrganicFertilizerType" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    CONSTRAINT "refOrganicFertilizerType_pkey" PRIMARY KEY (id)
);

-- Pastures Family
CREATE TABLE public."refPasturesFamily" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    CONSTRAINT "refPasturesFamily_pkey" PRIMARY KEY (id)
);

-- Pastures Growth Types
CREATE TABLE public."refPasturesGrowthTypes" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    CONSTRAINT "refPasturesGrowthTypes_pkey" PRIMARY KEY (id)
);

-- Pastures Types
CREATE TABLE public."refPasturesTypes" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    CONSTRAINT "refPasturesTypes_pkey" PRIMARY KEY (id)
);

-- Forage Source
CREATE TABLE public."refForageSource" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    CONSTRAINT "refForageSource_pkey" PRIMARY KEY (id)
);

-- Forage Use Intensity
CREATE TABLE public."refForageUseIntensity" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "pt_BR" character varying(255),
    "isDeleted" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "refForageUseIntensity_pkey" PRIMARY KEY (id)
);

-- Forage Use Pattern
CREATE TABLE public."refForageUsePattern" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "pt_BR" character varying(255),
    "isDeleted" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "refForageUsePattern_pkey" PRIMARY KEY (id)
);

COMMENT ON TABLE public."refCropType" IS 'Crop types - from ruuts-api';
COMMENT ON TABLE public."refTillageType" IS 'Tillage types - from ruuts-api';
COMMENT ON TABLE public."refIrrigationType" IS 'Irrigation types - from ruuts-api';
COMMENT ON TABLE public."refAmmendmendType" IS 'Soil amendment types - from ruuts-api';
COMMENT ON TABLE public."refMineralFertilizerType" IS 'Mineral fertilizer types - from ruuts-api';
COMMENT ON TABLE public."refOrganicFertilizerType" IS 'Organic fertilizer types - from ruuts-api';
COMMENT ON TABLE public."refPasturesFamily" IS 'Pasture family types - from ruuts-api';
COMMENT ON TABLE public."refPasturesGrowthTypes" IS 'Pasture growth types - from ruuts-api';
COMMENT ON TABLE public."refPasturesTypes" IS 'Pasture types - from ruuts-api';
COMMENT ON TABLE public."refForageSource" IS 'Forage source types - from ruuts-api';
COMMENT ON TABLE public."refForageUseIntensity" IS 'Forage use intensity levels - from ruuts-api';
COMMENT ON TABLE public."refForageUsePattern" IS 'Forage use patterns - from ruuts-api';
