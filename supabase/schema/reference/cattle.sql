-- Domain: Reference / Cattle
-- Tables for cattle/livestock types and related data (from ruuts-api dump)

-- Cattle Class
CREATE TABLE public."refCattleClass" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    CONSTRAINT "refCattleClass_pkey" PRIMARY KEY (id)
);

-- Cattle Sub Class
CREATE TABLE public."refCattleSubClass" (
    id integer NOT NULL,
    "cattleClassId" integer,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    CONSTRAINT "refCattleSubClass_pkey" PRIMARY KEY (id)
);

-- Cattle Type
CREATE TABLE public."refCattleType" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    CONSTRAINT "refCattleType_pkey" PRIMARY KEY (id)
);

-- Bovine Cattle
CREATE TABLE public."refBovineCattle" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    CONSTRAINT "refBovineCattle_pkey" PRIMARY KEY (id)
);

-- Bubaline Cattle (Buffalo)
CREATE TABLE public."refBubalineCattle" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    CONSTRAINT "refBubalineCattle_pkey" PRIMARY KEY (id)
);

-- Camelid Cattle (Llamas, Alpacas)
CREATE TABLE public."refCamelidCattle" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    CONSTRAINT "refCamelidCattle_pkey" PRIMARY KEY (id)
);

-- Caprine Cattle (Goats)
CREATE TABLE public."refCaprineCattle" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    CONSTRAINT "refCaprineCattle_pkey" PRIMARY KEY (id)
);

-- Cervid Cattle (Deer)
CREATE TABLE public."refCervidCattle" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    CONSTRAINT "refCervidCattle_pkey" PRIMARY KEY (id)
);

-- Equine Cattle (Horses)
CREATE TABLE public."refEquineCattle" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    CONSTRAINT "refEquineCattle_pkey" PRIMARY KEY (id)
);

-- Ovine Cattle (Sheep)
CREATE TABLE public."refOvineCattle" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    CONSTRAINT "refOvineCattle_pkey" PRIMARY KEY (id)
);

-- Cattle Emissions Factors
CREATE TABLE public."refCattleEmissionsFactors" (
    id integer NOT NULL,
    "cattleSubClassId" integer NOT NULL,
    "ch4Emissions_KgYear" double precision NOT NULL,
    "ch4EmissionsForManure_KgYear" double precision NOT NULL,
    "n2oEmissions_KgYear" double precision NOT NULL,
    "n2oEmissionsForManure_KgYear" double precision NOT NULL,
    "nitrogenExcretion_KgYear" double precision NOT NULL,
    "nitrogenFractionOfVolatilization_pct" double precision NOT NULL,
    "ipccAssessmentReport" character varying(255) NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "refCattleEmissionsFactors_pkey" PRIMARY KEY (id)
);

-- Cattle Equivalences
CREATE TABLE public."refCattleEquivalences" (
    id integer NOT NULL,
    "cattleSubClassId" integer NOT NULL,
    "equivalentCattleSubClassId" integer NOT NULL,
    value double precision NOT NULL,
    "isDeleted" boolean NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "refCattleEquivalences_pkey" PRIMARY KEY (id)
);

-- Indexes
CREATE INDEX "idx_refCattleSubClass_classId" ON public."refCattleSubClass"("cattleClassId");
CREATE INDEX "idx_refCattleEmissionsFactors_subClassId" ON public."refCattleEmissionsFactors"("cattleSubClassId");
CREATE INDEX "idx_refCattleEquivalences_subClassId" ON public."refCattleEquivalences"("cattleSubClassId");

COMMENT ON TABLE public."refCattleClass" IS 'Cattle class types - from ruuts-api';
COMMENT ON TABLE public."refCattleSubClass" IS 'Cattle sub-class types - from ruuts-api';
COMMENT ON TABLE public."refCattleType" IS 'Cattle type reference - from ruuts-api';
COMMENT ON TABLE public."refBovineCattle" IS 'Bovine cattle categories - from ruuts-api';
COMMENT ON TABLE public."refCattleEmissionsFactors" IS 'IPCC emissions factors for cattle - from ruuts-api';
COMMENT ON TABLE public."refCattleEquivalences" IS 'Cattle equivalence factors - from ruuts-api';
