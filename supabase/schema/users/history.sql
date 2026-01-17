-- Domain: History/Audit
-- History tables for tracking changes (from ruuts-api dump)

-- Farms History
CREATE TABLE public."farmsHistory" (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    "farmId" uuid NOT NULL,
    "hubspotId" character varying(255),
    name character varying(255) NOT NULL,
    "programId" integer NOT NULL,
    "shortName" character varying(255),
    "ownerId" uuid,
    "hubId" uuid,
    address character varying(255),
    city character varying(255),
    province character varying(255),
    country character varying(255),
    "primaryContact" character varying(255),
    geolocation character varying(255),
    "totalHectares" double precision,
    "totalHectaresDeclared" double precision,
    lat double precision,
    lng double precision,
    "totalHectaresMgmt" double precision,
    "elegibleHectaresDeclared" double precision,
    "hasNonRuutsProjects" character varying(255),
    "localLawCompliance" character varying(255),
    "isDeleted" boolean DEFAULT false NOT NULL,
    geometry geometry,
    "uncroppedGeometry" geometry,
    color character varying(255),
    "phoneNumber" character varying(255),
    email character varying(255),
    "createdBy" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "ecoregionId" integer,
    CONSTRAINT "farmsHistory_pkey" PRIMARY KEY (id)
);

-- Paddocks History
CREATE TABLE public."paddocksHistory" (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    "paddockId" uuid NOT NULL,
    name character varying(255) NOT NULL,
    "farmId" uuid NOT NULL,
    "totalHectares" double precision,
    "isDeleted" boolean DEFAULT false NOT NULL,
    geometry geometry,
    "uncroppedGeometry" geometry,
    color character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "paddocksHistory_pkey" PRIMARY KEY (id)
);

-- Sampling Areas History
CREATE TABLE public."samplingAreasHistory" (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    "samplingAreaId" uuid NOT NULL,
    name character varying(255) NOT NULL,
    "farmId" uuid NOT NULL,
    geometry geometry,
    "uncroppedGeometry" geometry,
    "totalHectares" double precision,
    color character varying(255),
    "createdBy" character varying(255),
    "updatedBy" character varying(255),
    "isDeleted" boolean DEFAULT false,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    CONSTRAINT "samplingAreasHistory_pkey" PRIMARY KEY (id)
);

-- Monitoring Sites History
CREATE TABLE public."monitoringSitesHistory" (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    "monitoringSiteId" uuid DEFAULT uuid_generate_v4() NOT NULL,
    name character varying(255) NOT NULL,
    allocated boolean DEFAULT false,
    "samplingAreaId" uuid,
    "farmId" uuid,
    "plannedLocation" json NOT NULL,
    "actualLocation" json,
    "backupLocation" json,
    "locationConfirmed" boolean DEFAULT false,
    "locationMoved" boolean DEFAULT false,
    "locationMovedReason" text,
    "locationMovedComments" text,
    "allowContingencyOffset" boolean DEFAULT false,
    "isRandomSite" boolean DEFAULT false,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "offsetMts" integer DEFAULT 100,
    "distanceToPlannedLocation" double precision,
    pictures bytea[],
    "randomizeCounter" integer,
    "randomizeReason" character varying(255)[],
    color character varying(255),
    _rev uuid DEFAULT uuid_generate_v4(),
    "isValidationSite" boolean DEFAULT false,
    "updatedBy" character varying(255),
    "updatedAt" timestamp with time zone,
    "createdBy" character varying(255),
    "createdAt" timestamp with time zone,
    "deviceLocationData" json,
    "locationMovedReasonId" integer,
    CONSTRAINT "monitoringSitesHistory_pkey" PRIMARY KEY (id)
);

-- Monitoring Tasks History
CREATE TABLE public."monitoringTasksHistory" (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    "monitoringTaskId" uuid DEFAULT uuid_generate_v4() NOT NULL,
    key character varying(255) NOT NULL,
    "order" integer,
    enabled boolean NOT NULL,
    "monitoringSiteId" uuid,
    "monitoringActivityId" uuid NOT NULL,
    "monitoringEventId" uuid NOT NULL,
    "taskStatusId" integer DEFAULT 0 NOT NULL,
    "formName" character varying(255) DEFAULT 0,
    type character varying(255),
    "gridPositionKey" character varying(255),
    "actualLocation" json,
    "actionRangeMts" integer,
    "plannedLocation" json,
    dependencies integer[],
    description character varying(255) NOT NULL,
    "dataPayload" json,
    pictures character varying(255)[],
    _rev uuid DEFAULT uuid_generate_v4() NOT NULL,
    "isDeleted" boolean DEFAULT false,
    "deviceLocationData" json,
    "updatedBy" character varying(255),
    "updatedAt" timestamp with time zone,
    "createdBy" character varying(255),
    "createdAt" timestamp with time zone,
    CONSTRAINT "monitoringTasksHistory_pkey" PRIMARY KEY (id)
);

-- Indexes
CREATE INDEX "idx_farmsHistory_farmId" ON public."farmsHistory"("farmId");
CREATE INDEX "idx_paddocksHistory_paddockId" ON public."paddocksHistory"("paddockId");
CREATE INDEX "idx_samplingAreasHistory_areaId" ON public."samplingAreasHistory"("samplingAreaId");
CREATE INDEX "idx_monitoringSitesHistory_siteId" ON public."monitoringSitesHistory"("monitoringSiteId");
CREATE INDEX "idx_monitoringTasksHistory_taskId" ON public."monitoringTasksHistory"("monitoringTaskId");

COMMENT ON TABLE public."farmsHistory" IS 'Audit trail for farm changes - from ruuts-api';
COMMENT ON TABLE public."paddocksHistory" IS 'Audit trail for paddock changes - from ruuts-api';
COMMENT ON TABLE public."samplingAreasHistory" IS 'Audit trail for sampling area changes - from ruuts-api';
COMMENT ON TABLE public."monitoringSitesHistory" IS 'Audit trail for monitoring site changes - from ruuts-api';
COMMENT ON TABLE public."monitoringTasksHistory" IS 'Audit trail for monitoring task changes - from ruuts-api';
