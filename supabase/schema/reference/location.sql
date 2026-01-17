-- Domain: Reference / Location
-- Tables for location-related references (from ruuts-api dump)

-- Location Moved Reason
CREATE TABLE public."refLocationMovedReason" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "refLocationMovedReason_pkey" PRIMARY KEY (id)
);

-- Location Confirmation Type
CREATE TABLE public."refLocationConfirmationType" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "refLocationConfirmationType_pkey" PRIMARY KEY (id)
);

-- Field Relocation Method
CREATE TABLE public."refFieldRelocationMethod" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255) NOT NULL,
    "en_US" character varying(255) NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "refFieldRelocationMethod_pkey" PRIMARY KEY (id)
);

-- Randomizer
CREATE TABLE public."refRandomizer" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    version character varying(255) NOT NULL,
    model character varying(255) NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "refRandomizer_pkey" PRIMARY KEY (id)
);

-- Countries
CREATE TABLE public."refCountries" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_AR_long" character varying(255) NOT NULL,
    "pt_BR" character varying(255),
    "pt_BR_long" character varying(255),
    "es_PY" character varying(255),
    "es_PY_long" character varying(255),
    "en_US" character varying(255),
    "en_US_long" character varying(255),
    "isDeleted" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "refCountries_pkey" PRIMARY KEY (id)
);

COMMENT ON TABLE public."refLocationMovedReason" IS 'Location moved reasons - from ruuts-api';
COMMENT ON TABLE public."refLocationConfirmationType" IS 'Location confirmation types - from ruuts-api';
COMMENT ON TABLE public."refFieldRelocationMethod" IS 'Field relocation methods - from ruuts-api';
COMMENT ON TABLE public."refRandomizer" IS 'Randomizer options - from ruuts-api';
COMMENT ON TABLE public."refCountries" IS 'Countries reference - from ruuts-api';
