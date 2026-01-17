-- Domain: SOC (Soil Organic Carbon)
-- Tables: monitoringSOCSamples and related (from ruuts-api dump)

-- SOC Samples
CREATE TABLE public."monitoringSOCSamples" (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    "farmId" uuid NOT NULL,
    "sampleDate" date NOT NULL,
    "samplingNumberId" integer NOT NULL,
    "laboratoryId" integer,
    "socProtocolId" integer NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "updatedBy" character varying(255),
    "updatedAt" timestamp with time zone,
    "createdBy" character varying(255) NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "isCompleted" boolean NOT NULL,
    "uncompletedReason" character varying(255),
    CONSTRAINT "monitoringSOCSamples_pkey" PRIMARY KEY (id),
    CONSTRAINT chk_uncompleted_reason_required CHECK ((("isCompleted" = true) OR (("isCompleted" = false) AND ("uncompletedReason" IS NOT NULL) AND (("uncompletedReason")::text <> ''::text))))
);

-- SOC Sampling Area Samples (aggregated by sampling area)
CREATE TABLE public."monitoringSOCSamplingAreaSamples" (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    "monitoringSOCSampleId" uuid NOT NULL,
    "stationsName" character varying(255) NOT NULL,
    "samplingAreaName" character varying(255) NOT NULL,
    "samplingAreaId" uuid NOT NULL,
    ph double precision,
    "nitrogenPercentage" double precision,
    "phosphorusPercentage" double precision,
    "fineSandPercentage" double precision,
    "coarseSandPercentage" double precision,
    "sandPercentage" double precision,
    "siltPercentage" double precision,
    "clayPercentage" double precision,
    "soilTextureTypeId" integer,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "updatedBy" character varying(255),
    "updatedAt" timestamp with time zone,
    "createdBy" character varying(255) NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    CONSTRAINT "monitoringSOCSamplingAreaSamples_pkey" PRIMARY KEY (id)
);

-- SOC Sites Samples (per monitoring site)
CREATE TABLE public."monitoringSOCSitesSamples" (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    "monitoringSOCSampleId" uuid NOT NULL,
    "dapMethodId" integer NOT NULL,
    name character varying(255) NOT NULL,
    "monitoringSOCActivityId" uuid NOT NULL,
    "wbFirstReplicaPercentage" double precision NOT NULL,
    "wbSecondReplicaPercentage" double precision,
    "caFirstReplicaPercentage" double precision,
    "caSecondReplicaPercentage" double precision,
    "lecoFirstReplicaPercentage" double precision,
    "lecoSecondReplicaPercentage" double precision,
    "dryWeight" double precision,
    "gravelWeight" double precision,
    "gravelVolume" double precision,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "updatedBy" character varying(255),
    "updatedAt" timestamp with time zone,
    "createdBy" character varying(255) NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    dap double precision NOT NULL,
    "sampleVolume" double precision NOT NULL,
    CONSTRAINT "monitoringSOCSitesSamples_pkey" PRIMARY KEY (id)
);

-- Indexes
CREATE INDEX "idx_monitoringSOCSamples_farmId" ON public."monitoringSOCSamples"("farmId");
CREATE INDEX "idx_monitoringSOCSamples_date" ON public."monitoringSOCSamples"("sampleDate");
CREATE INDEX "idx_monitoringSOCSamples_not_deleted" ON public."monitoringSOCSamples"(id) WHERE "isDeleted" = FALSE;
CREATE INDEX "idx_monitoringSOCSamplingAreaSamples_sampleId" ON public."monitoringSOCSamplingAreaSamples"("monitoringSOCSampleId");
CREATE INDEX "idx_monitoringSOCSamplingAreaSamples_areaId" ON public."monitoringSOCSamplingAreaSamples"("samplingAreaId");
CREATE INDEX "idx_monitoringSOCSitesSamples_sampleId" ON public."monitoringSOCSitesSamples"("monitoringSOCSampleId");
CREATE INDEX "idx_monitoringSOCSitesSamples_activityId" ON public."monitoringSOCSitesSamples"("monitoringSOCActivityId");

COMMENT ON TABLE public."monitoringSOCSamples" IS 'SOC sampling records - from ruuts-api';
COMMENT ON TABLE public."monitoringSOCSamplingAreaSamples" IS 'SOC samples by sampling area with soil analysis - from ruuts-api';
COMMENT ON TABLE public."monitoringSOCSitesSamples" IS 'SOC samples at monitoring sites with replicas - from ruuts-api';
