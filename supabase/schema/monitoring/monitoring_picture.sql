-- Domain: Monitoring
-- Table: monitoringPictures (from ruuts-api dump)
-- Description: Photo attachments from monitoring activities

CREATE TABLE public."monitoringPictures" (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    name character varying(255) NOT NULL,
    key character varying(255) NOT NULL,
    "monitoringEventId" uuid,
    link character varying(255),
    entity character varying(255) NOT NULL,
    "entityId" uuid NOT NULL,
    "syncedToS3" boolean DEFAULT false,
    _rev uuid DEFAULT uuid_generate_v4() NOT NULL,
    "isDeleted" boolean DEFAULT false,
    "updatedBy" character varying(255),
    "updatedAt" timestamp with time zone,
    "createdBy" character varying(255),
    "createdAt" timestamp with time zone,
    CONSTRAINT "monitoringPictures_pkey" PRIMARY KEY (id)
);

-- Indexes
CREATE INDEX "idx_monitoringPictures_entity" ON public."monitoringPictures"(entity, "entityId");
CREATE INDEX "idx_monitoringPictures_eventId" ON public."monitoringPictures"("monitoringEventId");
CREATE INDEX "idx_monitoringPictures_not_deleted" ON public."monitoringPictures"(id) WHERE "isDeleted" = FALSE;

COMMENT ON TABLE public."monitoringPictures" IS 'Photo attachments from monitoring activities - from ruuts-api';
COMMENT ON COLUMN public."monitoringPictures"._rev IS 'Revision UUID for mobile sync';
