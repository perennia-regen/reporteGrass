-- =============================================================================
-- RUUTS-API FULL SCHEMA
-- Extracted from: dump-postgres-202601141728.sql
-- Date: 2026-01-16
-- =============================================================================

-- Enable extensions (Supabase installs these in 'extensions' schema)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA extensions;
CREATE EXTENSION IF NOT EXISTS "postgis" WITH SCHEMA extensions;

-- Make geometry type available without schema prefix
SET search_path TO public, extensions;

CREATE FUNCTION public.check_refexclusionareatype_programids() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Check if every programId in the array exists in the programs table
    PERFORM 1
    FROM unnest(NEW."programIds") AS program_id
    WHERE NOT EXISTS (SELECT 1 FROM "programs" WHERE "id" = program_id);

    -- If any programId does not exist, raise an error
    IF FOUND THEN
        RAISE EXCEPTION 'Foreign key violation: Some programIds do not match any programs.id';
    END IF;

    RETURN NEW;
END;
$$;
CREATE FUNCTION public.f_intersect_geometries(geom1 geometry, geom2 geometry) RETURNS json
    LANGUAGE plpgsql
    AS $$
DECLARE 
	tempgeo geometry;
BEGIN
  tempgeo := ST_Intersection(geom1, geom2);
  IF ST_isEmpty(tempgeo) THEN 
  	RETURN NULL;
  ELSE 
 	RETURN ST_AsGeoJSON(tempgeo, 4326);
  END IF;
END;
$$;
CREATE FUNCTION public.f_union_geometries(geom1 geometry, geom2 geometry) RETURNS json
    LANGUAGE plpgsql
    AS $$
BEGIN
  -- Perform union operation and return result as GeoJSON
  RETURN ST_AsGeoJSON(ST_Union(ST_UnaryUnion(ST_makevalid(geom1)), ST_UnaryUnion(ST_makevalid(geom2)), 0.00000001), 4326);
END;
$$;
CREATE FUNCTION public.generate_random_points(p_samplingareaid uuid, p_geometry geometry, p_n integer) RETURNS TABLE(id uuid, "samplingAreaId" uuid, "farmId" uuid, seed integer, "createdAt" timestamp with time zone, geometry geometry)
    LANGUAGE plpgsql
    AS $$
    DECLARE
        seed_gen INTEGER := floor(random() * 1000000)::INTEGER;
    BEGIN
        IF GeometryType(p_geometry) NOT IN ('POLYGON','MULTIPOLYGON') THEN
            RAISE EXCEPTION
              'Expected POLYGON or MULTIPOLYGON, got %', GeometryType(p_geometry);
        END IF;

        IF p_n < 1 THEN
            RAISE EXCEPTION 'sampling size must be greater than or equal to 1, got %', p_n;
        END IF;
       
        IF p_geometry IS NULL OR ST_IsEmpty(p_geometry) THEN
            RAISE EXCEPTION 'stratum geometry cannot be NULL or empty';
        END IF;
       
        IF ST_SRID(p_geometry) <> 4326 THEN
            RAISE EXCEPTION 'Expected SRID 4326, got %', ST_SRID(p_geometry);
        END IF;
       
        IF NOT ST_IsValid(p_geometry) THEN
            RAISE EXCEPTION 'Invalid stratum geometry: %', ST_IsValidReason(p_geometry);
        END IF;

        RETURN QUERY
        WITH mp AS (
          SELECT
            p_samplingAreaId            AS "samplingAreaId",
            (SELECT sa."farmId" FROM "samplingAreas" sa WHERE sa.id = p_samplingAreaId) AS "farmId",
            seed_gen                    AS seed,
            now()                       AS "createdAt",
            ST_GeneratePoints(p_geometry, p_n, seed_gen) AS geom_mp
        )
        SELECT
          uuid_generate_v4()   AS id,
          mp."samplingAreaId" as "samplingAreaId",
          mp."farmId" as "farmId",
          mp.seed as seed,
          mp."createdAt" as "createdAt",
          (pt).geom           AS geometry
        FROM mp
        CROSS JOIN LATERAL ST_DumpPoints(mp.geom_mp) AS pt;
    END;
    $$;
CREATE FUNCTION public.st_intersectionarray(geoms geometry[]) RETURNS geometry
    LANGUAGE plpgsql
    AS $$
declare
   i integer;
   tmpGeom geometry;
begin
    tmpGeom := geoms[1];
    FOR i IN 1..array_length(geoms,1) LOOP
      tmpGeom:= ST_Intersection(tmpGeom,geoms[i]);
    END LOOP;
    return tmpGeom;
end;
$$;
CREATE FUNCTION public.trigger_auto_link_carbon_instance_monitoring_period() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  -- Insert records into relInstanceMonitoringPeriod for all matching monitoring periods
  INSERT INTO public."relInstanceMonitoringPeriod" (
    "carbonInstanceId",
    "monitoringPeriodId",
    "isDeleted",
    "createdBy",
    "createdAt",
    "updatedAt"
  )
  SELECT 
    NEW.id,
    pmp.id,
    false,
    NEW."createdBy",
    NOW(),
    NOW()
  FROM public."programMonitoringPeriods" pmp
  WHERE NEW."initDate" >= pmp."startDate"
    AND NEW."initDate" <= pmp."endDate"
    AND pmp."isDeleted" = false
    -- Avoid duplicates (shouldn't happen on INSERT, but defensive programming)
    AND NOT EXISTS (
      SELECT 1 
      FROM public."relInstanceMonitoringPeriod" rimp
      WHERE rimp."carbonInstanceId" = NEW.id
        AND rimp."monitoringPeriodId" = pmp.id
    );
  
  RETURN NEW;
END;
$$;
CREATE FUNCTION public.trigger_sync_carbon_instance_deleted_status() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  -- Only update if isDeleted has actually changed
  IF OLD."isDeleted" IS DISTINCT FROM NEW."isDeleted" THEN
    UPDATE public."relInstanceMonitoringPeriod"
    SET 
      "isDeleted" = NEW."isDeleted",
      "updatedBy" = NEW."updatedBy",
      "updatedAt" = NOW()
    WHERE "carbonInstanceId" = NEW.id;
  END IF;
  
  RETURN NEW;
END;
$$;

-- =============================================================================
-- SEQUENCES
-- =============================================================================

CREATE SEQUENCE public."RelLaboratory_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."monitoringWorkflows_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refAmmendmendType_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refBovineCattle_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refBubalineCattle_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refCamelidCattle_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refCaprineCattle_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refCattleClass_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refCattleEmissionsFactors_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refCattleEquivalences_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refCattleSubClass_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refCattleType_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refCervidCattle_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refCropType_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refDAPMethods_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refDataCollectionStatementStatus_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refDegreeDegradationSoil_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refDocumentType_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refEntityDiscardReason_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refEntityType_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refEquineCattle_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refExclusionAreaType_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refFieldRelocationMethod_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refFieldUsage_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refFindingType_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refForageSource_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refForageUseIntensity_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refForageUsePattern_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refFuelEmissionsFactors_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refFuelType_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refGrazingIntensityTypes_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refGrazingPlanType_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refGrazingType_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refGreenHouseGasesGwp_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refHorizonCode_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refIrrigationType_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refLivestockRaisingTypes_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refLocationConfirmationType_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refLocationMovedReason_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refMetricStatus_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refMineralFertilizerType_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refMonitoringReportStatus_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refOrganicFertilizerType_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refOvineCattle_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refPasturesFamily_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refPasturesGrowthTypes_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refPasturesTypes_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refRandomizer_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refSamplingNumbers_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refSoilSamplingDisturbance_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refSoilSamplingTools_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refSoilTexture_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refStructureGrade_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refStructureSize_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refStructureType_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refTaskStatus_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refTillageType_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refUnits_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."refUserRole_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
CREATE SEQUENCE public."relSOCProtocols_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

-- =============================================================================
-- TABLES
-- =============================================================================

CREATE TABLE public."RelLaboratory" (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);
CREATE TABLE public."SequelizeMeta" (
    name character varying(255) NOT NULL
);
CREATE TABLE public."carbonInstances" (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    name character varying(255) NOT NULL,
    "farmId" uuid NOT NULL,
    "initDate" timestamp with time zone NOT NULL,
    "instanceYear" character varying(255) NOT NULL,
    "samplingAreaId" uuid NOT NULL,
    paddocks json,
    "baselinePaddocks" json,
    geometry geometry,
    "totalHectares" double precision,
    color character varying(255),
    "createdBy" character varying(255),
    "updatedBy" character varying(255),
    "isDeleted" boolean DEFAULT false,
    "verificationStatusId" integer,
    "verifiedBy" character varying(255),
    "verifiedAt" timestamp with time zone,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);
CREATE TABLE public."dataCollectionStatement" (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    "dataCollectionStatementStatusId" integer DEFAULT 0,
    "ownerUserRoleId" integer NOT NULL,
    "farmSubdivisionId" uuid NOT NULL,
    "metricsEventsIds" uuid[] DEFAULT ARRAY[]::uuid[] NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "updatedBy" character varying(255),
    "updatedAt" timestamp with time zone,
    "createdBy" character varying(255),
    "createdAt" timestamp with time zone NOT NULL
);
CREATE TABLE public."dataCollectionStatementHistory" (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    "dataCollectionStatementId" uuid NOT NULL,
    "dataCollectionStatementStatusId" integer DEFAULT 0,
    "ownerUserRoleId" integer NOT NULL,
    "farmSubdivisionId" uuid NOT NULL,
    "metricsEventsIds" uuid[] DEFAULT ARRAY[]::uuid[] NOT NULL,
    "updatedBy" character varying(255),
    "updatedAt" timestamp with time zone,
    "createdBy" character varying(255),
    "createdAt" timestamp with time zone NOT NULL
);
CREATE TABLE public.deals (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    "hubspotId" character varying(255),
    "hsPipeline" character varying(255) NOT NULL,
    "hsStage" character varying(255) NOT NULL,
    "programId" integer NOT NULL,
    "farmId" uuid NOT NULL,
    "createdBy" character varying(255),
    "isDeleted" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);
CREATE TABLE public."deforestedAreas" (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    name character varying(255),
    "farmId" uuid NOT NULL,
    geometry geometry,
    "featureCollection" json,
    "totalHectares" double precision,
    color character varying(255),
    "createdBy" character varying(255),
    "updatedBy" character varying(255),
    "isDeleted" boolean DEFAULT false,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);
CREATE TABLE public."discardedEntities" (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    "farmId" uuid NOT NULL,
    "entityTypeId" integer NOT NULL,
    "entityId" uuid NOT NULL,
    "reasonId" integer NOT NULL,
    geometry geometry,
    "totalHectares" double precision,
    "isDeleted" boolean DEFAULT false,
    "updatedBy" character varying(255),
    "updatedAt" timestamp with time zone,
    "createdBy" character varying(255),
    "createdAt" timestamp with time zone
);
CREATE TABLE public.documents (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    "documentTypeId" integer NOT NULL,
    "entityTypeId" integer NOT NULL,
    "entityId" uuid NOT NULL,
    url character varying(300) NOT NULL,
    "isDeleted" boolean DEFAULT false,
    "updatedBy" character varying(255),
    "updatedAt" timestamp with time zone,
    "createdBy" character varying(255),
    "createdAt" timestamp with time zone
);
CREATE TABLE public."exclusionAreaHistory" (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    "exclusionAreaId" uuid NOT NULL,
    name character varying(255) NOT NULL,
    "otherName" character varying(255),
    "farmId" uuid NOT NULL,
    geometry geometry,
    "uncroppedGeometry" geometry,
    "exclusionAreaTypeId" integer NOT NULL,
    "totalHectares" double precision,
    color character varying(255),
    "createdBy" character varying(255),
    "updatedBy" character varying(255),
    "isDeleted" boolean DEFAULT false,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);
CREATE TABLE public."exclusionAreas" (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    name character varying(255) NOT NULL,
    "otherName" character varying(255),
    "farmId" uuid NOT NULL,
    geometry geometry,
    "uncroppedGeometry" geometry,
    "exclusionAreaTypeId" integer NOT NULL,
    "totalHectares" double precision,
    color character varying(255),
    "createdBy" character varying(255),
    "updatedBy" character varying(255),
    "isDeleted" boolean DEFAULT false,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "hasGrazingManagement" boolean DEFAULT false NOT NULL
);
CREATE TABLE public."farmOwners" (
    id uuid NOT NULL,
    name character varying(255) NOT NULL,
    "legalCompanyName" character varying(255) NOT NULL,
    cuit character varying(255) NOT NULL,
    "primaryContactName" character varying(255) NOT NULL,
    "legalAddress" character varying(255) NOT NULL,
    city character varying(255) NOT NULL,
    province character varying(255) NOT NULL,
    "primaryContactPhone" character varying(255),
    "primaryContactEmail" character varying(255) NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);
CREATE TABLE public."farmSubdivisions" (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    "paddockIds" uuid[],
    "activitiesStatus" json[],
    year character varying(255) NOT NULL,
    "farmId" uuid NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "createdBy" character varying(255),
    "updatedBy" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "templateFileName" character varying
);
CREATE TABLE public.farms (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
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
    "isPerimeterValidated" boolean DEFAULT false NOT NULL,
    geometry geometry,
    "uncroppedGeometry" geometry,
    color character varying(255),
    "phoneNumber" character varying(255),
    email character varying(255),
    "targetInitialMonitoringPeriodId" uuid,
    "createdBy" character varying(255),
    "updatedBy" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "countryId" integer,
    "ecoregionId" integer
);
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
    "ecoregionId" integer
);
CREATE TABLE public."findingComments" (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    message character varying(255),
    "findingId" uuid NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "createdBy" character varying(255),
    "updatedBy" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);
CREATE TABLE public."findingHistory" (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    "findingId" uuid NOT NULL,
    "metricEventId" uuid NOT NULL,
    type integer NOT NULL,
    "metricEventsFieldsObserved" json[] NOT NULL,
    comment character varying(255),
    resolved boolean DEFAULT false NOT NULL,
    "updatedBy" character varying(255),
    "updatedAt" timestamp with time zone,
    "createdBy" character varying(255),
    "createdAt" timestamp with time zone NOT NULL
);
CREATE TABLE public.findings (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    "metricEventId" uuid NOT NULL,
    type integer NOT NULL,
    "metricEventsFieldsObserved" json[] NOT NULL,
    comment character varying(255),
    resolved boolean DEFAULT false NOT NULL,
    "createdBy" character varying(255),
    "updatedBy" character varying(255),
    "isDeleted" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);
CREATE TABLE public."forestAreas" (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    name character varying(255),
    "farmId" uuid NOT NULL,
    geometry geometry,
    "featureCollection" json,
    "totalHectares" double precision,
    color character varying(255),
    "createdBy" character varying(255),
    "updatedBy" character varying(255),
    "isDeleted" boolean DEFAULT false,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);
CREATE TABLE public."formDefinitions" (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    "programId" integer NOT NULL,
    namespace character varying(255) NOT NULL,
    version character varying(255) NOT NULL,
    label character varying(255) NOT NULL,
    required boolean DEFAULT false NOT NULL,
    "requiredMessage" character varying(255),
    "showMap" boolean DEFAULT false NOT NULL,
    "showTable" boolean DEFAULT false NOT NULL,
    fields json NOT NULL,
    dependencies json NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "createdBy" character varying(255) NOT NULL,
    "updatedBy" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "allowMultipleRecords" boolean
);
CREATE TABLE public.hubs (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    "hubspotId" character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    country character varying(255),
    province character varying(255),
    "createdBy" character varying(255),
    "referentsEmails" character varying(255)[],
    logo character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "countryId" integer
);
CREATE TABLE public."monitoringActivity" (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    key character varying(255) NOT NULL,
    "taskStatusId" integer DEFAULT 0 NOT NULL,
    "totalTasks" integer DEFAULT 1,
    "completedTasks" integer DEFAULT 0,
    "monitoringEventId" uuid NOT NULL,
    "monitoringWorkflowId" integer NOT NULL,
    description character varying(255) NOT NULL,
    "samplingAreaId" uuid,
    "monitoringSiteId" uuid,
    "actualLocation" json,
    "hasLayoutPattern" boolean DEFAULT false,
    "activityLayoutId" integer,
    "activityGrid" json,
    _rev uuid DEFAULT uuid_generate_v4() NOT NULL,
    "isDeleted" boolean DEFAULT false,
    "updatedBy" character varying(255),
    "updatedAt" timestamp with time zone,
    "createdBy" character varying(255),
    "createdAt" timestamp with time zone
);
CREATE TABLE public."monitoringEvents" (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    name character varying(255) NOT NULL,
    "taskStatusId" integer NOT NULL,
    "completedActivities" integer DEFAULT 0,
    "totalActivities" integer DEFAULT 1,
    "farmId" uuid NOT NULL,
    date timestamp with time zone NOT NULL,
    "assignedTo" character varying(255),
    "monitoringWorkflowIds" integer[] NOT NULL,
    "samplingAreas" uuid[],
    "monitoringSitesIds" uuid[],
    _rev uuid DEFAULT uuid_generate_v4() NOT NULL,
    "createdBy" character varying(255),
    "updatedBy" character varying(255),
    "isDeleted" boolean DEFAULT false,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isBackdatedEvent" boolean
);
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
    "createdAt" timestamp with time zone
);
CREATE TABLE public."monitoringReports" (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    "farmId" uuid NOT NULL,
    "monitoringReportStatusId" integer DEFAULT 0,
    year integer NOT NULL,
    "monitoringEventIds" uuid[] DEFAULT ARRAY[]::uuid[] NOT NULL,
    "monitoringActivityIds" uuid[] DEFAULT ARRAY[]::uuid[] NOT NULL,
    "userInput" jsonb,
    "cachedFiles" jsonb,
    "updatedBy" character varying(255),
    "updatedAt" timestamp with time zone,
    "createdBy" character varying(255),
    "createdAt" timestamp with time zone,
    "isDeleted" boolean DEFAULT false NOT NULL
);
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
    CONSTRAINT chk_uncompleted_reason_required CHECK ((("isCompleted" = true) OR (("isCompleted" = false) AND ("uncompletedReason" IS NOT NULL) AND (("uncompletedReason")::text <> ''::text))))
);
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
    "createdAt" timestamp with time zone NOT NULL
);
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
    "sampleVolume" double precision NOT NULL
);
CREATE TABLE public."monitoringSites" (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    name character varying(255) NOT NULL,
    allocated boolean DEFAULT false,
    "samplingAreaId" uuid,
    "farmId" uuid,
    "plannedLocation" json NOT NULL,
    "actualLocation" json,
    "backupLocation" json,
    "locationConfirmed" boolean DEFAULT false,
    "locationMoved" boolean DEFAULT false,
    "locationMovedReasonId" integer,
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
    _rev uuid DEFAULT uuid_generate_v4() NOT NULL,
    "isValidationSite" boolean DEFAULT false,
    "updatedBy" character varying(255),
    "updatedAt" timestamp with time zone,
    "createdBy" character varying(255),
    "createdAt" timestamp with time zone,
    "deviceLocationData" json,
    "locationConfirmationTypeId" integer,
    "fieldRelocationMethodId" integer,
    seed integer,
    "randomizerTypeId" integer
);
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
    "locationMovedReasonId" integer
);
CREATE TABLE public."monitoringTasks" (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
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
    "updatedBy" character varying(255),
    "updatedAt" timestamp with time zone,
    "createdBy" character varying(255),
    "createdAt" timestamp with time zone,
    "deviceLocationData" json
);
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
    "createdAt" timestamp with time zone
);
CREATE TABLE public."monitoringWorkflows" (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    description character varying(255) NOT NULL,
    definition json,
    "activityLayoutId" integer,
    "siteRequired" boolean NOT NULL,
    "allowRepetitiveTasks" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);
CREATE TABLE public."otherPolygons" (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    name character varying(255) NOT NULL,
    "farmId" uuid NOT NULL,
    geometry geometry,
    "totalHectares" double precision,
    color character varying(255),
    "createdBy" character varying(255),
    "updatedBy" character varying(255),
    "isDeleted" boolean DEFAULT false,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);
CREATE TABLE public."otherSites" (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    name character varying(255) NOT NULL,
    allocated boolean DEFAULT false,
    "farmId" uuid NOT NULL,
    "plannedLocation" json NOT NULL,
    "actualLocation" json,
    color character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);
CREATE TABLE public.paddocks (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    name character varying(255) NOT NULL,
    "farmId" uuid NOT NULL,
    "totalHectares" double precision,
    "isDeleted" boolean DEFAULT false NOT NULL,
    geometry geometry,
    "uncroppedGeometry" geometry,
    color character varying(255),
    "createdBy" character varying(255),
    "updatedBy" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isInProject" boolean
);
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
    "updatedAt" timestamp with time zone NOT NULL
);
CREATE TABLE public."programConfig" (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    "programId" integer NOT NULL,
    "formDefinitions" json NOT NULL,
    "baselineYears" integer NOT NULL,
    "dataCollectionEnabled" boolean DEFAULT true NOT NULL,
    "monitoringWorkflowIds" integer[],
    "exclusionAreasModesAllowed" character varying(255)[] NOT NULL,
    "stratificationModesAllowed" character varying(255)[] NOT NULL,
    "stratasConfigEndpoint" json NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "farmSubdivisionsYearsAllowed" character varying(255)[] NOT NULL,
    "createdBy" character varying(255) NOT NULL,
    "updatedBy" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "allowedGrazingPaddockFieldUsages" integer[],
    "randomizeVersion" character varying(255),
    "enabledReports" character varying(255)[],
    "blockedMonitoringPeriods" json[]
);
CREATE TABLE public."programMonitoringPeriods" (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    "programId" integer NOT NULL,
    name character varying(255) NOT NULL,
    "startDate" timestamp with time zone,
    "endDate" timestamp with time zone,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "createdBy" character varying(255) NOT NULL,
    "updatedBy" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);
CREATE TABLE public.programs (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    version character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);
CREATE TABLE public."refActivityLayouts" (
    id integer NOT NULL,
    "monitoringWorkflowId" integer NOT NULL,
    name character varying(255) NOT NULL,
    grid json NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);
CREATE TABLE public."refAmmendmendType" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);
CREATE TABLE public."refBovineCattle" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);
CREATE TABLE public."refBubalineCattle" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);
CREATE TABLE public."refCamelidCattle" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);
CREATE TABLE public."refCaprineCattle" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);
CREATE TABLE public."refCattleClass" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);
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
    "updatedAt" timestamp with time zone NOT NULL
);
CREATE TABLE public."refCattleEquivalences" (
    id integer NOT NULL,
    "cattleSubClassId" integer NOT NULL,
    "equivalentCattleSubClassId" integer NOT NULL,
    value double precision NOT NULL,
    "isDeleted" boolean NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);
CREATE TABLE public."refCattleSubClass" (
    id integer NOT NULL,
    "cattleClassId" integer,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);
CREATE TABLE public."refCattleType" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);
CREATE TABLE public."refCervidCattle" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);
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
    "updatedAt" timestamp with time zone NOT NULL
);
CREATE TABLE public."refCropType" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);
CREATE TABLE public."refDAPMethods" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "isDeleted" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);
CREATE TABLE public."refDataCollectionStatementStatus" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);
CREATE TABLE public."refDegreeDegradationSoil" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);
CREATE TABLE public."refDocumentType" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);
CREATE TABLE public."refEntityDiscardReason" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);
CREATE TABLE public."refEntityType" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);
CREATE TABLE public."refEquineCattle" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);
CREATE TABLE public."refExclusionAreaType" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "programIds" integer[]
);
CREATE TABLE public."refFieldRelocationMethod" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255) NOT NULL,
    "en_US" character varying(255) NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);
CREATE TABLE public."refFieldUsage" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);
CREATE TABLE public."refFindingType" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);
CREATE TABLE public."refForageSource" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);
CREATE TABLE public."refForageUseIntensity" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "pt_BR" character varying(255),
    "isDeleted" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);
CREATE TABLE public."refForageUsePattern" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "pt_BR" character varying(255),
    "isDeleted" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);
CREATE TABLE public."refFuelEmissionsFactors" (
    id integer NOT NULL,
    "fuelTypeId" integer NOT NULL,
    "effectiveCo2Emissions_tGJ" character varying(255) NOT NULL,
    "netCalorificValue_tJGG" character varying(255),
    "kgFuelPerGallon" character varying(255),
    "ipccAssessmentReport" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);
CREATE TABLE public."refFuelType" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);
CREATE TABLE public."refGrazingIntensityTypes" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);
CREATE TABLE public."refGrazingPlanType" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);
CREATE TABLE public."refGrazingType" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);
CREATE TABLE public."refGreenHouseGasesGwp" (
    id integer NOT NULL,
    "chemicalName" character varying(255) NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "en_US" character varying(255) NOT NULL,
    gwp100 numeric NOT NULL,
    "ipccAssessmentReport" character varying(255) NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);
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
    "isDeleted" boolean DEFAULT false NOT NULL
);
CREATE TABLE public."refInstancesVerificationStatus" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);
CREATE TABLE public."refIrrigationType" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);
CREATE TABLE public."refLivestockRaisingTypes" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);
CREATE TABLE public."refLocationConfirmationType" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255) NOT NULL,
    "en_US" character varying(255) NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);
CREATE TABLE public."refLocationMovedReason" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255) NOT NULL,
    "en_US" character varying(255) NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);
CREATE TABLE public."refMetricStatus" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);
CREATE TABLE public."refMineralFertilizerType" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);
CREATE TABLE public."refMonitoringReportStatus" (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    color character varying(255) NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);
CREATE TABLE public."refOrganicFertilizerType" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);
CREATE TABLE public."refOvineCattle" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);
CREATE TABLE public."refPasturesFamily" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);
CREATE TABLE public."refPasturesGrowthTypes" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);
CREATE TABLE public."refPasturesTypes" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);
CREATE TABLE public."refRandomizer" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    version character varying(255) NOT NULL,
    model character varying(255) NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);
CREATE TABLE public."refSamplingNumbers" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "isDeleted" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);
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
    "updatedAt" timestamp with time zone NOT NULL
);
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
    "updatedAt" timestamp with time zone NOT NULL
);
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
    "isDeleted" boolean DEFAULT false NOT NULL
);
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
    "isDeleted" boolean DEFAULT false NOT NULL
);
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
    "isDeleted" boolean DEFAULT false NOT NULL
);
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
    "isDeleted" boolean DEFAULT false NOT NULL
);
CREATE TABLE public."refTaskStatus" (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);
CREATE TABLE public."refTillageType" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);
CREATE TABLE public."refUnits" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);
CREATE TABLE public."refUserRole" (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);
CREATE TABLE public."relInstanceMonitoringPeriod" (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    "carbonInstanceId" uuid NOT NULL,
    "monitoringPeriodId" uuid NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "createdBy" character varying(255) NOT NULL,
    "updatedBy" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);
CREATE TABLE public."relSOCProtocols" (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);
CREATE TABLE public."samplingAreas" (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
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
    "updatedAt" timestamp with time zone NOT NULL
);
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
    "updatedAt" timestamp with time zone NOT NULL
);
CREATE TABLE public."wetlandAreas" (
    id uuid DEFAULT uuid_generate_v4() NOT NULL,
    name character varying(255),
    "farmId" uuid NOT NULL,
    geometry geometry,
    "featureCollection" json,
    "totalHectares" double precision,
    color character varying(255),
    "createdBy" character varying(255),
    "updatedBy" character varying(255),
    "isDeleted" boolean DEFAULT false,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);

-- =============================================================================
-- ALTER TABLE (DEFAULTS & CONSTRAINTS)
-- =============================================================================

ALTER TABLE ONLY public."RelLaboratory" ALTER COLUMN id SET DEFAULT nextval('public."RelLaboratory_id_seq"'::regclass);
ALTER TABLE ONLY public."monitoringWorkflows" ALTER COLUMN id SET DEFAULT nextval('public."monitoringWorkflows_id_seq"'::regclass);
ALTER TABLE ONLY public."refAmmendmendType" ALTER COLUMN id SET DEFAULT nextval('public."refAmmendmendType_id_seq"'::regclass);
ALTER TABLE ONLY public."refBovineCattle" ALTER COLUMN id SET DEFAULT nextval('public."refBovineCattle_id_seq"'::regclass);
ALTER TABLE ONLY public."refBubalineCattle" ALTER COLUMN id SET DEFAULT nextval('public."refBubalineCattle_id_seq"'::regclass);
ALTER TABLE ONLY public."refCamelidCattle" ALTER COLUMN id SET DEFAULT nextval('public."refCamelidCattle_id_seq"'::regclass);
ALTER TABLE ONLY public."refCaprineCattle" ALTER COLUMN id SET DEFAULT nextval('public."refCaprineCattle_id_seq"'::regclass);
ALTER TABLE ONLY public."refCattleClass" ALTER COLUMN id SET DEFAULT nextval('public."refCattleClass_id_seq"'::regclass);
ALTER TABLE ONLY public."refCattleEmissionsFactors" ALTER COLUMN id SET DEFAULT nextval('public."refCattleEmissionsFactors_id_seq"'::regclass);
ALTER TABLE ONLY public."refCattleEquivalences" ALTER COLUMN id SET DEFAULT nextval('public."refCattleEquivalences_id_seq"'::regclass);
ALTER TABLE ONLY public."refCattleSubClass" ALTER COLUMN id SET DEFAULT nextval('public."refCattleSubClass_id_seq"'::regclass);
ALTER TABLE ONLY public."refCattleType" ALTER COLUMN id SET DEFAULT nextval('public."refCattleType_id_seq"'::regclass);
ALTER TABLE ONLY public."refCervidCattle" ALTER COLUMN id SET DEFAULT nextval('public."refCervidCattle_id_seq"'::regclass);
ALTER TABLE ONLY public."refCropType" ALTER COLUMN id SET DEFAULT nextval('public."refCropType_id_seq"'::regclass);
ALTER TABLE ONLY public."refDAPMethods" ALTER COLUMN id SET DEFAULT nextval('public."refDAPMethods_id_seq"'::regclass);
ALTER TABLE ONLY public."refDataCollectionStatementStatus" ALTER COLUMN id SET DEFAULT nextval('public."refDataCollectionStatementStatus_id_seq"'::regclass);
ALTER TABLE ONLY public."refDegreeDegradationSoil" ALTER COLUMN id SET DEFAULT nextval('public."refDegreeDegradationSoil_id_seq"'::regclass);
ALTER TABLE ONLY public."refDocumentType" ALTER COLUMN id SET DEFAULT nextval('public."refDocumentType_id_seq"'::regclass);
ALTER TABLE ONLY public."refEntityDiscardReason" ALTER COLUMN id SET DEFAULT nextval('public."refEntityDiscardReason_id_seq"'::regclass);
ALTER TABLE ONLY public."refEntityType" ALTER COLUMN id SET DEFAULT nextval('public."refEntityType_id_seq"'::regclass);
ALTER TABLE ONLY public."refEquineCattle" ALTER COLUMN id SET DEFAULT nextval('public."refEquineCattle_id_seq"'::regclass);
ALTER TABLE ONLY public."refExclusionAreaType" ALTER COLUMN id SET DEFAULT nextval('public."refExclusionAreaType_id_seq"'::regclass);
ALTER TABLE ONLY public."refFieldRelocationMethod" ALTER COLUMN id SET DEFAULT nextval('public."refFieldRelocationMethod_id_seq"'::regclass);
ALTER TABLE ONLY public."refFieldUsage" ALTER COLUMN id SET DEFAULT nextval('public."refFieldUsage_id_seq"'::regclass);
ALTER TABLE ONLY public."refFindingType" ALTER COLUMN id SET DEFAULT nextval('public."refFindingType_id_seq"'::regclass);
ALTER TABLE ONLY public."refForageSource" ALTER COLUMN id SET DEFAULT nextval('public."refForageSource_id_seq"'::regclass);
ALTER TABLE ONLY public."refForageUseIntensity" ALTER COLUMN id SET DEFAULT nextval('public."refForageUseIntensity_id_seq"'::regclass);
ALTER TABLE ONLY public."refForageUsePattern" ALTER COLUMN id SET DEFAULT nextval('public."refForageUsePattern_id_seq"'::regclass);
ALTER TABLE ONLY public."refFuelEmissionsFactors" ALTER COLUMN id SET DEFAULT nextval('public."refFuelEmissionsFactors_id_seq"'::regclass);
ALTER TABLE ONLY public."refFuelType" ALTER COLUMN id SET DEFAULT nextval('public."refFuelType_id_seq"'::regclass);
ALTER TABLE ONLY public."refGrazingIntensityTypes" ALTER COLUMN id SET DEFAULT nextval('public."refGrazingIntensityTypes_id_seq"'::regclass);
ALTER TABLE ONLY public."refGrazingPlanType" ALTER COLUMN id SET DEFAULT nextval('public."refGrazingPlanType_id_seq"'::regclass);
ALTER TABLE ONLY public."refGrazingType" ALTER COLUMN id SET DEFAULT nextval('public."refGrazingType_id_seq"'::regclass);
ALTER TABLE ONLY public."refGreenHouseGasesGwp" ALTER COLUMN id SET DEFAULT nextval('public."refGreenHouseGasesGwp_id_seq"'::regclass);
ALTER TABLE ONLY public."refHorizonCode" ALTER COLUMN id SET DEFAULT nextval('public."refHorizonCode_id_seq"'::regclass);
ALTER TABLE ONLY public."refIrrigationType" ALTER COLUMN id SET DEFAULT nextval('public."refIrrigationType_id_seq"'::regclass);
ALTER TABLE ONLY public."refLivestockRaisingTypes" ALTER COLUMN id SET DEFAULT nextval('public."refLivestockRaisingTypes_id_seq"'::regclass);
ALTER TABLE ONLY public."refLocationConfirmationType" ALTER COLUMN id SET DEFAULT nextval('public."refLocationConfirmationType_id_seq"'::regclass);
ALTER TABLE ONLY public."refLocationMovedReason" ALTER COLUMN id SET DEFAULT nextval('public."refLocationMovedReason_id_seq"'::regclass);
ALTER TABLE ONLY public."refMetricStatus" ALTER COLUMN id SET DEFAULT nextval('public."refMetricStatus_id_seq"'::regclass);
ALTER TABLE ONLY public."refMineralFertilizerType" ALTER COLUMN id SET DEFAULT nextval('public."refMineralFertilizerType_id_seq"'::regclass);
ALTER TABLE ONLY public."refMonitoringReportStatus" ALTER COLUMN id SET DEFAULT nextval('public."refMonitoringReportStatus_id_seq"'::regclass);
ALTER TABLE ONLY public."refOrganicFertilizerType" ALTER COLUMN id SET DEFAULT nextval('public."refOrganicFertilizerType_id_seq"'::regclass);
ALTER TABLE ONLY public."refOvineCattle" ALTER COLUMN id SET DEFAULT nextval('public."refOvineCattle_id_seq"'::regclass);
ALTER TABLE ONLY public."refPasturesFamily" ALTER COLUMN id SET DEFAULT nextval('public."refPasturesFamily_id_seq"'::regclass);
ALTER TABLE ONLY public."refPasturesGrowthTypes" ALTER COLUMN id SET DEFAULT nextval('public."refPasturesGrowthTypes_id_seq"'::regclass);
ALTER TABLE ONLY public."refPasturesTypes" ALTER COLUMN id SET DEFAULT nextval('public."refPasturesTypes_id_seq"'::regclass);
ALTER TABLE ONLY public."refRandomizer" ALTER COLUMN id SET DEFAULT nextval('public."refRandomizer_id_seq"'::regclass);
ALTER TABLE ONLY public."refSamplingNumbers" ALTER COLUMN id SET DEFAULT nextval('public."refSamplingNumbers_id_seq"'::regclass);
ALTER TABLE ONLY public."refSoilSamplingDisturbance" ALTER COLUMN id SET DEFAULT nextval('public."refSoilSamplingDisturbance_id_seq"'::regclass);
ALTER TABLE ONLY public."refSoilSamplingTools" ALTER COLUMN id SET DEFAULT nextval('public."refSoilSamplingTools_id_seq"'::regclass);
ALTER TABLE ONLY public."refSoilTexture" ALTER COLUMN id SET DEFAULT nextval('public."refSoilTexture_id_seq"'::regclass);
ALTER TABLE ONLY public."refStructureGrade" ALTER COLUMN id SET DEFAULT nextval('public."refStructureGrade_id_seq"'::regclass);
ALTER TABLE ONLY public."refStructureSize" ALTER COLUMN id SET DEFAULT nextval('public."refStructureSize_id_seq"'::regclass);
ALTER TABLE ONLY public."refStructureType" ALTER COLUMN id SET DEFAULT nextval('public."refStructureType_id_seq"'::regclass);
ALTER TABLE ONLY public."refTaskStatus" ALTER COLUMN id SET DEFAULT nextval('public."refTaskStatus_id_seq"'::regclass);
ALTER TABLE ONLY public."refTillageType" ALTER COLUMN id SET DEFAULT nextval('public."refTillageType_id_seq"'::regclass);
ALTER TABLE ONLY public."refUnits" ALTER COLUMN id SET DEFAULT nextval('public."refUnits_id_seq"'::regclass);
ALTER TABLE ONLY public."refUserRole" ALTER COLUMN id SET DEFAULT nextval('public."refUserRole_id_seq"'::regclass);
ALTER TABLE ONLY public."relSOCProtocols" ALTER COLUMN id SET DEFAULT nextval('public."relSOCProtocols_id_seq"'::regclass);

-- ADD CONSTRAINT (PRIMARY KEY, UNIQUE, FOREIGN KEY)
-- ADD CONSTRAINT statements (PRIMARY KEY, UNIQUE, FOREIGN KEY)
ALTER TABLE ONLY public."RelLaboratory" ADD CONSTRAINT "RelLaboratory_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."SequelizeMeta" ADD CONSTRAINT "SequelizeMeta_pkey" PRIMARY KEY (name);
ALTER TABLE ONLY public."carbonInstances" ADD CONSTRAINT "carbonInstances_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."dataCollectionStatementHistory" ADD CONSTRAINT "dataCollectionStatementHistory_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."dataCollectionStatement" ADD CONSTRAINT "dataCollectionStatement_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public.deals ADD CONSTRAINT "deals_hubspotId_key" UNIQUE ("hubspotId");
ALTER TABLE ONLY public.deals ADD CONSTRAINT deals_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public."deforestedAreas" ADD CONSTRAINT "deforestedAreas_farmId_key" UNIQUE ("farmId");
ALTER TABLE ONLY public."deforestedAreas" ADD CONSTRAINT "deforestedAreas_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."discardedEntities" ADD CONSTRAINT "discardedEntities_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public.documents ADD CONSTRAINT documents_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public."exclusionAreaHistory" ADD CONSTRAINT "exclusionAreaHistory_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."exclusionAreas" ADD CONSTRAINT "exclusionAreas_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."farmOwners" ADD CONSTRAINT "farmOwners_cuit_key" UNIQUE (cuit);
ALTER TABLE ONLY public."farmOwners" ADD CONSTRAINT "farmOwners_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."farmSubdivisions" ADD CONSTRAINT "farmSubdivisions_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."farmsHistory" ADD CONSTRAINT "farmsHistory_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public.farms ADD CONSTRAINT "farms_hubspotId_key" UNIQUE ("hubspotId");
ALTER TABLE ONLY public.farms ADD CONSTRAINT farms_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public.farms ADD CONSTRAINT "farms_shortName_key" UNIQUE ("shortName");
ALTER TABLE ONLY public."findingComments" ADD CONSTRAINT "findingComments_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."findingHistory" ADD CONSTRAINT "findingHistory_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public.findings ADD CONSTRAINT findings_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public."forestAreas" ADD CONSTRAINT "forestAreas_farmId_key" UNIQUE ("farmId");
ALTER TABLE ONLY public."forestAreas" ADD CONSTRAINT "forestAreas_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."formDefinitions" ADD CONSTRAINT "formDefinitions_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public.hubs ADD CONSTRAINT "hubs_hubspotId_key" UNIQUE ("hubspotId");
ALTER TABLE ONLY public.hubs ADD CONSTRAINT hubs_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public."monitoringActivity" ADD CONSTRAINT "monitoringActivity_key_monitoringEventId_key" UNIQUE (key, "monitoringEventId");
ALTER TABLE ONLY public."monitoringActivity" ADD CONSTRAINT "monitoringActivity_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."monitoringEvents" ADD CONSTRAINT "monitoringEvents_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."monitoringPictures" ADD CONSTRAINT "monitoringPictures_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."monitoringReports" ADD CONSTRAINT "monitoringReports_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."monitoringSOCSamples" ADD CONSTRAINT "monitoringSOCSamples_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."monitoringSOCSamplingAreaSamples" ADD CONSTRAINT "monitoringSOCSamplingAreaSamples_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."monitoringSOCSitesSamples" ADD CONSTRAINT "monitoringSOCSitesSamples_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."monitoringSitesHistory" ADD CONSTRAINT "monitoringSitesHistory_pkey" PRIMARY KEY (id, "monitoringSiteId");
ALTER TABLE ONLY public."monitoringSites" ADD CONSTRAINT "monitoringSites_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."monitoringTasksHistory" ADD CONSTRAINT "monitoringTasksHistory_pkey" PRIMARY KEY (id, "monitoringTaskId");
ALTER TABLE ONLY public."monitoringTasks" ADD CONSTRAINT "monitoringTasks_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."monitoringWorkflows" ADD CONSTRAINT "monitoringWorkflows_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."otherPolygons" ADD CONSTRAINT "otherPolygons_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."otherSites" ADD CONSTRAINT "otherSites_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."paddocksHistory" ADD CONSTRAINT "paddocksHistory_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public.paddocks ADD CONSTRAINT paddocks_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public."programConfig" ADD CONSTRAINT "programConfig_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."programConfig" ADD CONSTRAINT "programId_unique_constraint" UNIQUE ("programId");
ALTER TABLE ONLY public."programMonitoringPeriods" ADD CONSTRAINT "programMonitoringPeriods_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."programMonitoringPeriods" ADD CONSTRAINT "programMonitoringPeriods_programId_name_key" UNIQUE ("programId", name);
ALTER TABLE ONLY public.programs ADD CONSTRAINT programs_pkey PRIMARY KEY (id);
ALTER TABLE ONLY public."refActivityLayouts" ADD CONSTRAINT "refActivityLayouts_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refAmmendmendType" ADD CONSTRAINT "refAmmendmendType_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refBovineCattle" ADD CONSTRAINT "refBovineCattle_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refBubalineCattle" ADD CONSTRAINT "refBubalineCattle_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refCamelidCattle" ADD CONSTRAINT "refCamelidCattle_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refCaprineCattle" ADD CONSTRAINT "refCaprineCattle_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refCattleClass" ADD CONSTRAINT "refCattleClass_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refCattleEmissionsFactors" ADD CONSTRAINT "refCattleEmissionsFactors_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refCattleEquivalences" ADD CONSTRAINT "refCattleEquivalences_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refCattleSubClass" ADD CONSTRAINT "refCattleSubClass_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refCattleType" ADD CONSTRAINT "refCattleType_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refCervidCattle" ADD CONSTRAINT "refCervidCattle_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refCountries" ADD CONSTRAINT "refCountries_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refCropType" ADD CONSTRAINT "refCropType_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refDAPMethods" ADD CONSTRAINT "refDAPMethods_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refDataCollectionStatementStatus" ADD CONSTRAINT "refDataCollectionStatementStatus_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refDegreeDegradationSoil" ADD CONSTRAINT "refDegreeDegradationSoil_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refDocumentType" ADD CONSTRAINT "refDocumentType_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refEntityDiscardReason" ADD CONSTRAINT "refEntityDiscardReason_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refEntityType" ADD CONSTRAINT "refEntityType_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refEquineCattle" ADD CONSTRAINT "refEquineCattle_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refExclusionAreaType" ADD CONSTRAINT "refExclusionAreaType_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refFieldRelocationMethod" ADD CONSTRAINT "refFieldRelocationMethod_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refFieldUsage" ADD CONSTRAINT "refFieldUsage_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refFindingType" ADD CONSTRAINT "refFindingType_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refForageSource" ADD CONSTRAINT "refForageSource_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refForageUseIntensity" ADD CONSTRAINT "refForageUseIntensity_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refForageUsePattern" ADD CONSTRAINT "refForageUsePattern_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refFuelEmissionsFactors" ADD CONSTRAINT "refFuelEmissionsFactors_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refFuelType" ADD CONSTRAINT "refFuelType_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refGrazingIntensityTypes" ADD CONSTRAINT "refGrazingIntensityTypes_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refGrazingPlanType" ADD CONSTRAINT "refGrazingPlanType_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refGrazingType" ADD CONSTRAINT "refGrazingType_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refGreenHouseGasesGwp" ADD CONSTRAINT "refGreenHouseGasesGwp_chemicalName_ipccAssessmentReport_key" UNIQUE ("chemicalName", "ipccAssessmentReport");
ALTER TABLE ONLY public."refGreenHouseGasesGwp" ADD CONSTRAINT "refGreenHouseGasesGwp_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refHorizonCode" ADD CONSTRAINT "refHorizonCode_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refInstancesVerificationStatus" ADD CONSTRAINT "refInstancesVerificationStatus_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refIrrigationType" ADD CONSTRAINT "refIrrigationType_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refLivestockRaisingTypes" ADD CONSTRAINT "refLivestockRaisingTypes_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refLocationConfirmationType" ADD CONSTRAINT "refLocationConfirmationType_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refLocationMovedReason" ADD CONSTRAINT "refLocationMovedReason_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refMetricStatus" ADD CONSTRAINT "refMetricStatus_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refMineralFertilizerType" ADD CONSTRAINT "refMineralFertilizerType_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refMonitoringReportStatus" ADD CONSTRAINT "refMonitoringReportStatus_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refOrganicFertilizerType" ADD CONSTRAINT "refOrganicFertilizerType_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refOvineCattle" ADD CONSTRAINT "refOvineCattle_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refPasturesFamily" ADD CONSTRAINT "refPasturesFamily_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refPasturesGrowthTypes" ADD CONSTRAINT "refPasturesGrowthTypes_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refPasturesTypes" ADD CONSTRAINT "refPasturesTypes_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refRandomizer" ADD CONSTRAINT "refRandomizer_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refRandomizer" ADD CONSTRAINT "refRandomizer_version_key" UNIQUE (version);
ALTER TABLE ONLY public."refSamplingNumbers" ADD CONSTRAINT "refSamplingNumbers_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refSoilSamplingDisturbance" ADD CONSTRAINT "refSoilSamplingDisturbance_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refSoilSamplingTools" ADD CONSTRAINT "refSoilSamplingTools_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refSoilTexture" ADD CONSTRAINT "refSoilTexture_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refStructureGrade" ADD CONSTRAINT "refStructureGrade_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refStructureSize" ADD CONSTRAINT "refStructureSize_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refStructureType" ADD CONSTRAINT "refStructureType_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refTaskStatus" ADD CONSTRAINT "refTaskStatus_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refTillageType" ADD CONSTRAINT "refTillageType_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refUnits" ADD CONSTRAINT "refUnits_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."refUserRole" ADD CONSTRAINT "refUserRole_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."relInstanceMonitoringPeriod" ADD CONSTRAINT "relInstanceMonitoringPeriod_carbonInstanceId_monitoringPeri_key" UNIQUE ("carbonInstanceId", "monitoringPeriodId");
ALTER TABLE ONLY public."relInstanceMonitoringPeriod" ADD CONSTRAINT "relInstanceMonitoringPeriod_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."relSOCProtocols" ADD CONSTRAINT "relSOCProtocols_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."samplingAreasHistory" ADD CONSTRAINT "samplingAreasHistory_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."samplingAreas" ADD CONSTRAINT "samplingAreas_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."wetlandAreas" ADD CONSTRAINT "wetlandAreas_farmId_key" UNIQUE ("farmId");
ALTER TABLE ONLY public."wetlandAreas" ADD CONSTRAINT "wetlandAreas_pkey" PRIMARY KEY (id);
ALTER TABLE ONLY public."carbonInstances" ADD CONSTRAINT "carbonInstances_farmId_fkey" FOREIGN KEY ("farmId") REFERENCES public.farms(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."carbonInstances" ADD CONSTRAINT "carbonInstances_refInstancesVerificationStatus_fkey" FOREIGN KEY ("verificationStatusId") REFERENCES public."refInstancesVerificationStatus"(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."carbonInstances" ADD CONSTRAINT "carbonInstances_samplingAreaId_fkey" FOREIGN KEY ("samplingAreaId") REFERENCES public."samplingAreas"(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."carbonInstances" ADD CONSTRAINT "carbonInstances_verificationStatusId_fkey" FOREIGN KEY ("verificationStatusId") REFERENCES public."refInstancesVerificationStatus"(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."dataCollectionStatementHistory" ADD CONSTRAINT "dataCollectionStatementHistor_dataCollectionStatementStatu_fkey" FOREIGN KEY ("dataCollectionStatementStatusId") REFERENCES public."refDataCollectionStatementStatus"(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."dataCollectionStatementHistory" ADD CONSTRAINT "dataCollectionStatementHistory_dataCollectionStatementId_fkey" FOREIGN KEY ("dataCollectionStatementId") REFERENCES public."dataCollectionStatement"(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."dataCollectionStatementHistory" ADD CONSTRAINT "dataCollectionStatementHistory_farmSubdivisionId_fkey" FOREIGN KEY ("farmSubdivisionId") REFERENCES public."farmSubdivisions"(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."dataCollectionStatementHistory" ADD CONSTRAINT "dataCollectionStatementHistory_ownerUserRoleId_fkey" FOREIGN KEY ("ownerUserRoleId") REFERENCES public."refUserRole"(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."dataCollectionStatement" ADD CONSTRAINT "dataCollectionStatement_dataCollectionStatementStatusId_fkey" FOREIGN KEY ("dataCollectionStatementStatusId") REFERENCES public."refDataCollectionStatementStatus"(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."dataCollectionStatement" ADD CONSTRAINT "dataCollectionStatement_farmSubdivisionId_fkey" FOREIGN KEY ("farmSubdivisionId") REFERENCES public."farmSubdivisions"(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."dataCollectionStatement" ADD CONSTRAINT "dataCollectionStatement_ownerUserRoleId_fkey" FOREIGN KEY ("ownerUserRoleId") REFERENCES public."refUserRole"(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public.deals ADD CONSTRAINT "deals_farmId_fkey" FOREIGN KEY ("farmId") REFERENCES public.farms(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public.deals ADD CONSTRAINT "deals_programId_fkey" FOREIGN KEY ("programId") REFERENCES public.programs(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."deforestedAreas" ADD CONSTRAINT "deforestedAreas_farmId_fkey" FOREIGN KEY ("farmId") REFERENCES public.farms(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."discardedEntities" ADD CONSTRAINT "discardedEntities_entityTypeId_fkey" FOREIGN KEY ("entityTypeId") REFERENCES public."refEntityType"(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."discardedEntities" ADD CONSTRAINT "discardedEntities_farmId_fkey" FOREIGN KEY ("farmId") REFERENCES public.farms(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."discardedEntities" ADD CONSTRAINT "discardedEntities_reasonId_fkey" FOREIGN KEY ("reasonId") REFERENCES public."refEntityDiscardReason"(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public.documents ADD CONSTRAINT "documents_documentTypeId_fkey" FOREIGN KEY ("documentTypeId") REFERENCES public."refDocumentType"(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public.documents ADD CONSTRAINT "documents_entityTypeId_fkey" FOREIGN KEY ("entityTypeId") REFERENCES public."refEntityType"(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."exclusionAreaHistory" ADD CONSTRAINT "exclusionAreaHistory_exclusionAreaId_fkey" FOREIGN KEY ("exclusionAreaId") REFERENCES public."exclusionAreas"(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."exclusionAreaHistory" ADD CONSTRAINT "exclusionAreaHistory_farmId_fkey" FOREIGN KEY ("farmId") REFERENCES public.farms(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."exclusionAreas" ADD CONSTRAINT "exclusionAreas_farmId_fkey" FOREIGN KEY ("farmId") REFERENCES public.farms(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."farmSubdivisions" ADD CONSTRAINT "farmSubdivisions_farmId_fkey" FOREIGN KEY ("farmId") REFERENCES public.farms(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public."farmsHistory" ADD CONSTRAINT "farmsHistory_farmId_fkey" FOREIGN KEY ("farmId") REFERENCES public.farms(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."farmsHistory" ADD CONSTRAINT "farmsHistory_hubId_fkey" FOREIGN KEY ("hubId") REFERENCES public.hubs(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."farmsHistory" ADD CONSTRAINT "farmsHistory_programId_fkey" FOREIGN KEY ("programId") REFERENCES public.programs(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public.farms ADD CONSTRAINT "farms_hubId_fkey" FOREIGN KEY ("hubId") REFERENCES public.hubs(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public.farms ADD CONSTRAINT "farms_programId_fkey" FOREIGN KEY ("programId") REFERENCES public.programs(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public.farms ADD CONSTRAINT "farms_programMonitoringPeriods_fkey" FOREIGN KEY ("targetInitialMonitoringPeriodId") REFERENCES public."programMonitoringPeriods"(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public.farms ADD CONSTRAINT "farms_targetInitialMonitoringPeriodId_fkey" FOREIGN KEY ("targetInitialMonitoringPeriodId") REFERENCES public."programMonitoringPeriods"(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."findingComments" ADD CONSTRAINT "findingComments_findingId_fkey" FOREIGN KEY ("findingId") REFERENCES public.findings(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."findingHistory" ADD CONSTRAINT "findingHistory_findingId_fkey" FOREIGN KEY ("findingId") REFERENCES public.findings(id) ON UPDATE CASCADE ON DELETE SET NULL;
-- NOTE: Commented out - metrics schema not included in this dump
-- ALTER TABLE ONLY public."findingHistory" ADD CONSTRAINT "findingHistory_metricEventId_fkey" FOREIGN KEY ("metricEventId") REFERENCES metrics."metricEvents"(id) ON UPDATE CASCADE ON DELETE SET NULL;
-- ALTER TABLE ONLY public.findings ADD CONSTRAINT "findings_metricEventId_fkey" FOREIGN KEY ("metricEventId") REFERENCES metrics."metricEvents"(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public.findings ADD CONSTRAINT findings_type_fkey FOREIGN KEY (type) REFERENCES public."refFindingType"(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."forestAreas" ADD CONSTRAINT "forestAreas_farmId_fkey" FOREIGN KEY ("farmId") REFERENCES public.farms(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."monitoringActivity" ADD CONSTRAINT "monitoringActivity_activityLayoutId_fkey" FOREIGN KEY ("activityLayoutId") REFERENCES public."refActivityLayouts"(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."monitoringActivity" ADD CONSTRAINT "monitoringActivity_monitoringEventId_fkey" FOREIGN KEY ("monitoringEventId") REFERENCES public."monitoringEvents"(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."monitoringActivity" ADD CONSTRAINT "monitoringActivity_monitoringSiteId_fkey" FOREIGN KEY ("monitoringSiteId") REFERENCES public."monitoringSites"(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."monitoringActivity" ADD CONSTRAINT "monitoringActivity_monitoringWorkflowId_fkey" FOREIGN KEY ("monitoringWorkflowId") REFERENCES public."monitoringWorkflows"(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."monitoringActivity" ADD CONSTRAINT "monitoringActivity_taskStatusId_fkey" FOREIGN KEY ("taskStatusId") REFERENCES public."refTaskStatus"(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."monitoringEvents" ADD CONSTRAINT "monitoringEvents_farmId_fkey" FOREIGN KEY ("farmId") REFERENCES public.farms(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."monitoringEvents" ADD CONSTRAINT "monitoringEvents_taskStatusId_fkey" FOREIGN KEY ("taskStatusId") REFERENCES public."refTaskStatus"(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."monitoringPictures" ADD CONSTRAINT "monitoringPictures_monitoringEventId_fkey" FOREIGN KEY ("monitoringEventId") REFERENCES public."monitoringEvents"(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."monitoringReports" ADD CONSTRAINT "monitoringReports_farmId_fkey" FOREIGN KEY ("farmId") REFERENCES public.farms(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."monitoringReports" ADD CONSTRAINT "monitoringReports_monitoringReportStatusId_fkey" FOREIGN KEY ("monitoringReportStatusId") REFERENCES public."refMonitoringReportStatus"(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."monitoringSOCSamples" ADD CONSTRAINT "monitoringSOCSamples_farmId_fkey" FOREIGN KEY ("farmId") REFERENCES public.farms(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."monitoringSOCSamples" ADD CONSTRAINT "monitoringSOCSamples_laboratoryId_fkey" FOREIGN KEY ("laboratoryId") REFERENCES public."RelLaboratory"(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."monitoringSOCSamples" ADD CONSTRAINT "monitoringSOCSamples_samplingNumberId_fkey" FOREIGN KEY ("samplingNumberId") REFERENCES public."refSamplingNumbers"(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."monitoringSOCSamples" ADD CONSTRAINT "monitoringSOCSamples_socProtocolId_fkey" FOREIGN KEY ("socProtocolId") REFERENCES public."relSOCProtocols"(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."monitoringSOCSamplingAreaSamples" ADD CONSTRAINT "monitoringSOCSamplingAreaSamples_monitoringSOCSampleId_fkey" FOREIGN KEY ("monitoringSOCSampleId") REFERENCES public."monitoringSOCSamples"(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public."monitoringSOCSamplingAreaSamples" ADD CONSTRAINT "monitoringSOCSamplingAreaSamples_samplingAreaId_fkey" FOREIGN KEY ("samplingAreaId") REFERENCES public."samplingAreas"(id) ON UPDATE CASCADE;
ALTER TABLE ONLY public."monitoringSOCSamplingAreaSamples" ADD CONSTRAINT "monitoringSOCSamplingAreaSamples_soilTextureTypeId_fkey" FOREIGN KEY ("soilTextureTypeId") REFERENCES public."refSoilTexture"(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."monitoringSOCSitesSamples" ADD CONSTRAINT "monitoringSOCSitesSamples_dapMethodId_fkey" FOREIGN KEY ("dapMethodId") REFERENCES public."refDAPMethods"(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."monitoringSOCSitesSamples" ADD CONSTRAINT "monitoringSOCSitesSamples_monitoringSOCActivityId_fkey" FOREIGN KEY ("monitoringSOCActivityId") REFERENCES public."monitoringActivity"(id) ON UPDATE CASCADE;
ALTER TABLE ONLY public."monitoringSOCSitesSamples" ADD CONSTRAINT "monitoringSOCSitesSamples_monitoringSOCSampleId_fkey" FOREIGN KEY ("monitoringSOCSampleId") REFERENCES public."monitoringSOCSamples"(id) ON UPDATE CASCADE ON DELETE CASCADE;
ALTER TABLE ONLY public."monitoringSitesHistory" ADD CONSTRAINT "monitoringSitesHistory_farmId_fkey" FOREIGN KEY ("farmId") REFERENCES public.farms(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."monitoringSitesHistory" ADD CONSTRAINT "monitoringSitesHistory_monitoringSiteId_fkey" FOREIGN KEY ("monitoringSiteId") REFERENCES public."monitoringSites"(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."monitoringSites" ADD CONSTRAINT "monitoringSites_farmId_fkey" FOREIGN KEY ("farmId") REFERENCES public.farms(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."monitoringSites" ADD CONSTRAINT "monitoringSites_randomizerTypeId_fkey" FOREIGN KEY ("randomizerTypeId") REFERENCES public."refRandomizer"(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."monitoringTasksHistory" ADD CONSTRAINT "monitoringTasksHistory_monitoringActivityId_fkey" FOREIGN KEY ("monitoringActivityId") REFERENCES public."monitoringActivity"(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."monitoringTasksHistory" ADD CONSTRAINT "monitoringTasksHistory_monitoringTaskId_fkey" FOREIGN KEY ("monitoringTaskId") REFERENCES public."monitoringTasks"(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."monitoringTasks" ADD CONSTRAINT "monitoringTasks_monitoringActivityId_fkey" FOREIGN KEY ("monitoringActivityId") REFERENCES public."monitoringActivity"(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."monitoringTasks" ADD CONSTRAINT "monitoringTasks_taskStatusId_fkey" FOREIGN KEY ("taskStatusId") REFERENCES public."refTaskStatus"(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."otherPolygons" ADD CONSTRAINT "otherPolygons_farmId_fkey" FOREIGN KEY ("farmId") REFERENCES public.farms(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."otherSites" ADD CONSTRAINT "otherSites_farmId_fkey" FOREIGN KEY ("farmId") REFERENCES public.farms(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."paddocksHistory" ADD CONSTRAINT "paddocksHistory_farmId_fkey" FOREIGN KEY ("farmId") REFERENCES public.farms(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."paddocksHistory" ADD CONSTRAINT "paddocksHistory_paddockId_fkey" FOREIGN KEY ("paddockId") REFERENCES public.paddocks(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public.paddocks ADD CONSTRAINT "paddocks_farmId_fkey" FOREIGN KEY ("farmId") REFERENCES public.farms(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."programConfig" ADD CONSTRAINT "programConfig_programId_fkey" FOREIGN KEY ("programId") REFERENCES public.programs(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."programConfig" ADD CONSTRAINT "programConfigs_programId_fkey" FOREIGN KEY ("programId") REFERENCES public.programs(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."programMonitoringPeriods" ADD CONSTRAINT "programMonitoringPeriods_programId_fkey" FOREIGN KEY ("programId") REFERENCES public.programs(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."refActivityLayouts" ADD CONSTRAINT "refActivityLayouts_monitoringWorkflowId_fkey" FOREIGN KEY ("monitoringWorkflowId") REFERENCES public."monitoringWorkflows"(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."refCattleEquivalences" ADD CONSTRAINT "refCattleEquivalences_cattleSubClassId_fkey" FOREIGN KEY ("cattleSubClassId") REFERENCES public."refCattleSubClass"(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."refCattleEquivalences" ADD CONSTRAINT "refCattleEquivalences_equivalentCattleSubClassId_fkey" FOREIGN KEY ("equivalentCattleSubClassId") REFERENCES public."refCattleSubClass"(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."refCattleSubClass" ADD CONSTRAINT "refCattleSubClass_cattleClassId_fkey" FOREIGN KEY ("cattleClassId") REFERENCES public."refCattleClass"(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."refFuelEmissionsFactors" ADD CONSTRAINT "refFuelEmissionsFactors_fuelTypeId_fkey" FOREIGN KEY ("fuelTypeId") REFERENCES public."refFuelType"(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."relInstanceMonitoringPeriod" ADD CONSTRAINT "relInstanceMonitoringPeriod_carbonInstanceId_fkey" FOREIGN KEY ("carbonInstanceId") REFERENCES public."carbonInstances"(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."relInstanceMonitoringPeriod" ADD CONSTRAINT "relInstanceMonitoringPeriod_monitoringPeriodId_fkey" FOREIGN KEY ("monitoringPeriodId") REFERENCES public."programMonitoringPeriods"(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."samplingAreasHistory" ADD CONSTRAINT "samplingAreasHistory_farmId_fkey" FOREIGN KEY ("farmId") REFERENCES public.farms(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."samplingAreasHistory" ADD CONSTRAINT "samplingAreasHistory_samplingAreaId_fkey" FOREIGN KEY ("samplingAreaId") REFERENCES public."samplingAreas"(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."samplingAreas" ADD CONSTRAINT "samplingAreas_farmId_fkey" FOREIGN KEY ("farmId") REFERENCES public.farms(id) ON UPDATE CASCADE ON DELETE SET NULL;
ALTER TABLE ONLY public."wetlandAreas" ADD CONSTRAINT "wetlandAreas_farmId_fkey" FOREIGN KEY ("farmId") REFERENCES public.farms(id) ON UPDATE CASCADE ON DELETE SET NULL;

-- SEED DATA
-- =============================================================================

INSERT INTO public."RelLaboratory" VALUES (0, 'AGROLABCS - ex CSLAB (AR)', false, '2025-02-17 20:55:31.022+00', '2025-02-17 20:55:31.022+00');
INSERT INTO public."RelLaboratory" VALUES (1, 'CETAPAR (PY)', false, '2025-02-17 20:55:31.022+00', '2025-02-17 20:55:31.022+00');
INSERT INTO public."RelLaboratory" VALUES (2, 'UNIVERSIDAD AUSTRAL DE CHILE (CL)', false, '2025-02-17 20:55:31.022+00', '2025-02-17 20:55:31.022+00');
INSERT INTO public."RelLaboratory" VALUES (3, 'EXATA (BR)', false, '2025-08-06 19:43:42.738+00', '2025-08-06 19:43:42.738+00');
INSERT INTO public.programs VALUES (0, 'SARA', '1', '2024-06-03 20:55:40.41+00', '2024-06-03 20:55:40.41+00', false);
INSERT INTO public.programs VALUES (2, 'ReTerra', '1', '2025-03-10 14:33:10.621+00', '2025-03-10 14:33:10.621+00', false);
INSERT INTO public.programs VALUES (1, 'POA', '1', '2024-06-03 20:55:40.41+00', '2024-06-03 20:55:40.41+00', false);
INSERT INTO public.programs VALUES (99, 'Sin programa', '1', '2024-06-03 20:55:40.41+00', '2024-06-03 20:55:40.41+00', false);
INSERT INTO public."programConfig" VALUES ('a1d05c59-754c-41c5-ae21-19b310825367', 2, '{"dataCollection":[{"id":"a1d05c59-751c-41c5-ae21-19b310825255","label":"General","namespace":"farm_management_general"},{"id":"a1d05c59-751c-41c5-ae21-19b310825257","label":"Lotes","namespace":"paddock_production"},{"id":"a1d05c59-751c-41c5-ae21-19b310825258","label":"Pastoreo","namespace":"farm_management_grazing"},{"id":"a1d05c59-751c-41c5-ae21-19b310825253","label":"Fertilizantes orgánicos","namespace":"paddock_organic_fertilizers"},{"id":"a1d05c59-751c-41c5-ae21-19b310825254","label":"Fertilizantes sintéticos","namespace":"paddock_synthetic_fertilizers"},{"id":"a1d05c59-751c-41c5-ae21-19b310825256","label":"Labranza","namespace":"paddock_tillage"},{"id":"a1d05c59-751c-41c5-ae21-19b310825250","label":"Agua","namespace":"farm_management_water"},{"id":"a1d05c59-751c-41c5-ae21-19b310825251","label":"Combustibles","namespace":"farm_management_fuels"},{"id":"a1d05c59-751c-41c5-ae21-19b310825252","label":"Cultivos","namespace":"paddock_crops"},{"id":"a1d05c59-751c-41c5-ae21-19b310836366","label":"Documentación","namespace":"farm_management_documentation"}],"farmManagementSupportiveDocumentation":{"id":"1a1ce978-daec-45d0-97ec-6194afa64bdc"},"reports":{"grass_v7_report_variables":{"id":"4f9c1e2d-8b3a-4e5f-9d6c-7a2b3c4d5e67","label":"Variables del Reporte GRASS v7","enabled":true}}}', 3, false, '{0,1,2}', '{manual}', '{manual,semi-automatic,automatic}', '{"config":{"program":"RETERRA","n_classes":"optimal"}}', false, '{2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022,2023,2024,2025}', 'ruuts-api', 'ruuts-api', '2025-03-10 14:33:11.171+00', '2025-03-10 14:33:11.906+00', '{0,3,5}', '4.0.0', '{grass-v7}', '{}');
INSERT INTO public."programConfig" VALUES ('a1d05c59-754c-41c5-ae21-19b310825365', 99, '{}', 8, false, '{0,1,2,3}', '{manual,semi-automatic}', '{manual,semi-automatic,automatic}', '{"config":{"program":"CUSTOM","n_classes":"optimal","custom_bands":["NDVI.*","elevation"]}}', false, '{2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022,2023,2024,2025}', 'ruuts-api', 'ruuts-api', '2024-06-03 20:55:40.427+00', '2025-03-10 14:33:11.906+00', '{}', '3.0.0', '{}', '{}');
INSERT INTO public."programConfig" VALUES ('a1d05c59-754c-41c5-ae21-19b310825369', 1, '{"dataCollection":[{"id":"002501bb-d13b-430a-a374-43242db01801","label":"General","namespace":"farm_management_general"},{"id":"a1d05c59-751c-52d6-ae21-19b310825257","label":"Lotes","namespace":"paddock_production"},{"id":"a1d05c59-751c-41c5-ae21-19b310825245","label":"Pastoreo","namespace":"farm_management_grazing"},{"id":"a1d05c59-751c-41c5-ae21-19b310825246","label":"Combustibles","namespace":"farm_management_fuels"},{"id":"a1d05c59-751c-41c5-ae21-19b310825247","label":"Fertilizantes sintéticos","namespace":"paddock_synthetic_fertilizers"},{"id":"a0a05c59-751c-41c5-ae21-19b310836366","label":"Documentación","namespace":"farm_management_documentation"}],"farmManagementSupportiveDocumentation":{"id":"1a1ce978-daec-45d0-97ec-6194afa64bdc"},"monitoringSOCSample":{"id":"1a1ce978-eeee-45d0-97ec-6194afa64bdc","enable":true},"reports":{"grass_v7_report_variables":{"id":"4f9c1e2d-8b3a-4e5f-9d6c-7a2b3c4d5e67","label":"Variables del Reporte GRASS v7","enabled":true}}}', 10, true, '{3,1,2,4}', '{manual}', '{semi-automatic,automatic}', '{"config":{"program":"POA","n_classes":"optimal"}}', false, '{2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022,2023,2024,2025,LP,TEMPLATE}', 'ruuts-api', 'ruuts-api', '2024-06-03 20:55:40.427+00', '2025-03-10 14:33:11.891+00', '{0}', '2.0.0', '{grass-v7}', '{}');
INSERT INTO public."programConfig" VALUES ('a1d05c59-754c-41c5-ae21-19b310825364', 0, '{"dataCollection":[{"id":"a1d05c59-751c-41c5-ae21-19b310825255","label":"General","namespace":"farm_management_general"},{"id":"a1d05c59-751c-41c5-ae21-19b310825257","label":"Lotes","namespace":"paddock_production"},{"id":"a1d05c59-751c-41c5-ae21-19b310825258","label":"Pastoreo","namespace":"farm_management_grazing"},{"id":"a1d05c59-751c-41c5-ae21-19b310825253","label":"Fertilizantes orgánicos","namespace":"paddock_organic_fertilizers"},{"id":"a1d05c59-751c-41c5-ae21-19b310825254","label":"Fertilizantes sintéticos","namespace":"paddock_synthetic_fertilizers"},{"id":"a1d05c59-751c-41c5-ae21-19b310825256","label":"Labranza","namespace":"paddock_tillage"},{"id":"a1d05c59-751c-41c5-ae21-19b310825250","label":"Agua","namespace":"farm_management_water"},{"id":"a1d05c59-751c-41c5-ae21-19b310825251","label":"Combustibles","namespace":"farm_management_fuels"},{"id":"a1d05c59-751c-41c5-ae21-19b310825252","label":"Cultivos","namespace":"paddock_crops"},{"id":"a1d05c59-751c-41c5-ae21-19b310836366","label":"Documentación","namespace":"farm_management_documentation"}],"farmManagementSupportiveDocumentation":{"id":"1a1ce978-daec-45d0-97ec-6194afa64bdc"},"monitoringSOCSample":{"id":"1a1ce978-eeee-45d0-97ec-6194afa64bdc","enable":true},"reports":{"grass_v7_report_variables":{"id":"4f9c1e2d-8b3a-4e5f-9d6c-7a2b3c4d5e67","label":"Variables del Reporte GRASS v7","enabled":true},"sara_instances_report_variables":{"id":"4f9c1e2d-8b3a-4e5f-9d6c-7a2b3c4d5e6f","label":"Variables del Reporte SARA Instances","enabled":true}}}', 8, true, '{0,1,2}', '{manual,semi-automatic}', '{manual,semi-automatic}', '{"config":{"program":"SARA","n_classes":"optimal"}}', false, '{2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022,2023,2024,2025}', 'ruuts-api', 'ruuts-api', '2024-06-03 20:55:40.427+00', '2025-03-10 14:33:11.891+00', '{0,3,5}', '2.0.0', '{Attestation,grass-v7,sara-instances}', '{"{\"id\":\"18b8c3ee-a463-4bfd-8711-732c11ae81e6\",\"name\":\"MR1\"}"}');
INSERT INTO public."programMonitoringPeriods" VALUES ('77ac99af-009a-4ab7-bd94-3bb0643c7c1a', 0, 'MR3', '2024-09-01 03:00:00+00', '2025-06-30 00:00:00+00', false, 'jetadminconnection@ruuts.la', 'ruuts-api-migration-20251112', '2024-10-01 19:22:35.4+00', '2025-11-12 19:49:44.029886+00');
INSERT INTO public."programMonitoringPeriods" VALUES ('86fd20a9-dcec-4e92-9110-018f7d743ad4', 1, 'MR1', NULL, NULL, false, 'jetadminconnection@ruuts.la', NULL, '2024-10-08 15:13:56.805+00', '2024-10-08 15:13:56.805+00');
INSERT INTO public."programMonitoringPeriods" VALUES ('6ff16a35-8779-4d31-8080-180292107a39', 1, 'MR2', NULL, NULL, false, 'jetadminconnection@ruuts.la', NULL, '2024-10-08 15:14:19.551+00', '2024-10-08 15:14:19.551+00');
INSERT INTO public."programMonitoringPeriods" VALUES ('18b8c3ee-a463-4bfd-8711-732c11ae81e6', 0, 'MR1', '2019-10-01 00:00:00+00', '2023-06-30 00:00:00+00', false, 'ruuts-api', NULL, '2024-06-03 20:55:40.413+00', '2024-06-03 20:55:40.413+00');
INSERT INTO public."programMonitoringPeriods" VALUES ('b0929619-f4bc-4a90-a86e-8c02dbfed265', 0, 'MR2', '2023-07-01 00:00:00+00', '2024-06-30 00:00:00+00', false, 'ruuts-api', 'ruuts-api-migration-20251112', '2024-06-03 20:55:40.413+00', '2025-11-12 19:49:44.029886+00');

-- Seed data for monitoringWorkflows (required by refActivityLayouts FK)
INSERT INTO public."monitoringWorkflows" VALUES (0, 'SOC', 'Soil Organic Carbon Sampling', NULL, NULL, true, false, '2024-06-03 20:55:40.388+00', '2024-06-03 20:55:40.388+00', false);
INSERT INTO public."monitoringWorkflows" VALUES (1, 'Attestation', 'Attestation Workflow', NULL, NULL, false, false, '2024-06-03 20:55:40.388+00', '2024-06-03 20:55:40.388+00', false);
INSERT INTO public."monitoringWorkflows" VALUES (2, 'LTM', 'Land Terrain Monitoring', NULL, NULL, true, false, '2024-06-03 20:55:40.388+00', '2024-06-03 20:55:40.388+00', false);
INSERT INTO public."monitoringWorkflows" VALUES (3, 'Biodiversity', 'Biodiversity Assessment', NULL, NULL, true, false, '2024-06-03 20:55:40.388+00', '2024-06-03 20:55:40.388+00', false);
INSERT INTO public."monitoringWorkflows" VALUES (4, 'GRASS', 'GRASS Monitoring Protocol', NULL, NULL, true, true, '2024-06-03 20:55:40.388+00', '2024-06-03 20:55:40.388+00', false);
INSERT INTO public."monitoringWorkflows" VALUES (5, 'SARA-Instances', 'SARA Instances Report', NULL, NULL, false, false, '2024-06-03 20:55:40.388+00', '2024-06-03 20:55:40.388+00', false);

INSERT INTO public."refActivityLayouts" VALUES (0, 0, 'SOC-GRID-4-20', '[{"key":"P1","relativeCoords":[0,0]},{"key":"P2","relativeCoords":[20,0]},{"key":"P3","relativeCoords":[20,20]},{"key":"P4","relativeCoords":[0,20]}]', '2024-06-03 20:55:40.388+00', '2024-06-03 20:55:40.388+00', false);
INSERT INTO public."refActivityLayouts" VALUES (1, 2, 'LTM-GRID-V1', '[{"key":"P1","relativeCoords":[0,0]},{"key":"P2","relativeCoords":[8.5,2.5]},{"key":"P3","relativeCoords":[8.5,0]},{"key":"P4","relativeCoords":[8.5,-2.5]},{"key":"TRANSECT-3-START","relativeCoords":[22,-6.5]},{"key":"TRANSECT-2-START","relativeCoords":[22,0]},{"key":"TRANSECT-1-START","relativeCoords":[22,6.5]},{"key":"TRANSECT-3-END","relativeCoords":[47,-6.5]},{"key":"TRANSECT-2-END","relativeCoords":[47,0]},{"key":"TRANSECT-1-END","relativeCoords":[47,6.5]},{"key":"INFILT-1","relativeCoords":[22,-11.5]},{"key":"INFILT-2","relativeCoords":[22,11.5]},{"key":"INFILT-3","relativeCoords":[47,-11.5]},{"key":"INFILT-4","relativeCoords":[47,11.5]}]', '2024-06-03 20:55:40.388+00', '2024-06-03 20:55:40.388+00', false);
INSERT INTO public."refAmmendmendType" VALUES (0, 'Otro', 'Otro', 'Other', '2024-06-03 20:55:40.359+00', '2024-06-03 20:55:40.359+00', false);
INSERT INTO public."refAmmendmendType" VALUES (1, 'Dolomita', 'Dolomita', 'Dolomite', '2024-06-03 20:55:40.359+00', '2024-06-03 20:55:40.359+00', false);
INSERT INTO public."refAmmendmendType" VALUES (2, 'Yeso agrícola', 'Yeso agrícola', '', '2024-06-03 20:55:40.359+00', '2024-06-03 20:55:40.359+00', false);
INSERT INTO public."refAmmendmendType" VALUES (3, 'Carbonato de calcio', 'Carbonato de calcio', 'Calcium Carbonate', '2024-06-03 20:55:40.359+00', '2024-06-03 20:55:40.359+00', false);
INSERT INTO public."refBovineCattle" VALUES (0, 'Vaca adulta', 'Vaca adulta', 'Old cow', '2024-06-03 20:55:40.312+00', '2024-06-03 20:55:40.312+00', false);
INSERT INTO public."refBovineCattle" VALUES (1, 'Vaca', 'Vaca', 'Cow', '2024-06-03 20:55:40.312+00', '2024-06-03 20:55:40.312+00', false);
INSERT INTO public."refBovineCattle" VALUES (2, 'Ternero', 'Ternero', 'Calf', '2024-06-03 20:55:40.312+00', '2024-06-03 20:55:40.312+00', false);
INSERT INTO public."refBovineCattle" VALUES (3, 'Toro adulto', 'Toro adulto', 'Old bull', '2024-06-03 20:55:40.312+00', '2024-06-03 20:55:40.312+00', false);
INSERT INTO public."refBovineCattle" VALUES (4, 'Toro', 'Toro', 'Bull', '2024-06-03 20:55:40.312+00', '2024-06-03 20:55:40.312+00', false);
INSERT INTO public."refBovineCattle" VALUES (5, 'Vaquillona', 'Vaquillona', 'Heifer', '2024-06-03 20:55:40.312+00', '2024-06-03 20:55:40.312+00', false);
INSERT INTO public."refBovineCattle" VALUES (6, 'Novillo', 'Novillo', 'Steer', '2024-06-03 20:55:40.312+00', '2024-06-03 20:55:40.312+00', false);
INSERT INTO public."refBubalineCattle" VALUES (0, 'Búfala', 'Búfala', '', '2024-06-03 20:55:40.325+00', '2024-06-03 20:55:40.325+00', false);
INSERT INTO public."refBubalineCattle" VALUES (1, 'Búfalo', 'Búfalo', 'Buffalo', '2024-06-03 20:55:40.325+00', '2024-06-03 20:55:40.325+00', false);
INSERT INTO public."refCamelidCattle" VALUES (0, 'Llama', 'Llama', 'Llama', '2024-06-03 20:55:40.333+00', '2024-06-03 20:55:40.333+00', false);
INSERT INTO public."refCamelidCattle" VALUES (1, 'Guanaco', 'Guanaco', 'Guanaco', '2024-06-03 20:55:40.333+00', '2024-06-03 20:55:40.333+00', false);
INSERT INTO public."refCaprineCattle" VALUES (0, 'Cabra', 'Cabra', 'Goat', '2024-06-03 20:55:40.329+00', '2024-06-03 20:55:40.329+00', false);
INSERT INTO public."refCaprineCattle" VALUES (1, 'Cabrito', 'Cabrito', '', '2024-06-03 20:55:40.329+00', '2024-06-03 20:55:40.329+00', false);
INSERT INTO public."refCaprineCattle" VALUES (2, 'Chivo', 'Chivo', 'Billy goat', '2024-06-03 20:55:40.329+00', '2024-06-03 20:55:40.329+00', false);
INSERT INTO public."refCattleClass" VALUES (0, 'Bovino', 'Bovino', 'Bovine', '2024-06-03 20:55:40.302+00', '2024-06-03 20:55:40.302+00', false);
INSERT INTO public."refCattleClass" VALUES (1, 'Ovino', 'Ovino', 'Ovine', '2024-06-03 20:55:40.302+00', '2024-06-03 20:55:40.302+00', false);
INSERT INTO public."refCattleClass" VALUES (2, 'Equino', 'Equino', 'Equine', '2024-06-03 20:55:40.302+00', '2024-06-03 20:55:40.302+00', false);
INSERT INTO public."refCattleClass" VALUES (3, 'Bubalino', 'Bubalino', 'Bubaline', '2024-06-03 20:55:40.302+00', '2024-06-03 20:55:40.302+00', true);
INSERT INTO public."refCattleClass" VALUES (4, 'Caprino', 'Caprino', 'Caprine', '2024-06-03 20:55:40.302+00', '2024-06-03 20:55:40.302+00', false);
INSERT INTO public."refCattleClass" VALUES (5, 'Camelido', 'Camelido', 'Camelid', '2024-06-03 20:55:40.302+00', '2024-06-03 20:55:40.302+00', true);
INSERT INTO public."refCattleClass" VALUES (6, 'Cérvido', 'Cérvido', 'Cervid', '2024-06-03 20:55:40.302+00', '2024-06-03 20:55:40.302+00', false);
INSERT INTO public."refCattleSubClass" VALUES (28, 0, 'Vaca', 'Vaca', 'Cow', '2024-08-05 19:34:50.833+00', '2024-08-05 19:34:50.833+00', false);
INSERT INTO public."refCattleSubClass" VALUES (0, 0, 'Vaca sin cría', 'Vaca sin cría', 'Cow without calf', '2024-06-03 20:55:40.306+00', '2024-06-03 20:55:40.306+00', true);
INSERT INTO public."refCattleSubClass" VALUES (1, 0, 'Vaca con cría', 'Vaca con cría', 'Cow with calf', '2024-06-03 20:55:40.306+00', '2024-06-03 20:55:40.306+00', true);
INSERT INTO public."refCattleSubClass" VALUES (2, 0, 'Ternero/a recría de hasta 1 año', 'Ternero/a recría de hasta 1 año', 'Calf/calf rearing up to 1 year old', '2024-06-03 20:55:40.306+00', '2024-06-03 20:55:40.306+00', true);
INSERT INTO public."refCattleSubClass" VALUES (3, 0, 'Toro', 'Toro', 'Bull', '2024-06-03 20:55:40.306+00', '2024-06-03 20:55:40.306+00', false);
INSERT INTO public."refCattleSubClass" VALUES (4, 0, 'Vaquillona', 'Vaquillona', 'Heifer', '2024-06-03 20:55:40.306+00', '2024-06-03 20:55:40.306+00', false);
INSERT INTO public."refCattleSubClass" VALUES (5, 0, 'Novillo', 'Novillo', 'Steer', '2024-06-03 20:55:40.306+00', '2024-06-03 20:55:40.306+00', false);
INSERT INTO public."refCattleSubClass" VALUES (6, 3, 'Búfala', 'Búfala', 'Female buffalo', '2024-06-03 20:55:40.306+00', '2024-06-03 20:55:40.306+00', true);
INSERT INTO public."refCattleSubClass" VALUES (7, 3, 'Búfalo', 'Búfalo', 'Buffalo', '2024-06-03 20:55:40.306+00', '2024-06-03 20:55:40.306+00', true);
INSERT INTO public."refCattleSubClass" VALUES (8, 4, 'Cabra', 'Cabra', 'Doe', '2024-06-03 20:55:40.306+00', '2024-06-03 20:55:40.306+00', false);
INSERT INTO public."refCattleSubClass" VALUES (9, 4, 'Cabrito/Cabrilla', 'Cabrito/Cabrilla', 'Kid', '2024-06-03 20:55:40.306+00', '2024-06-03 20:55:40.306+00', false);
INSERT INTO public."refCattleSubClass" VALUES (10, 4, 'Castrón', 'Castrón', 'Buck', '2024-06-03 20:55:40.306+00', '2024-06-03 20:55:40.306+00', false);
INSERT INTO public."refCattleSubClass" VALUES (11, 5, 'Llama', 'Llama', 'Llama', '2024-06-03 20:55:40.306+00', '2024-06-03 20:55:40.306+00', true);
INSERT INTO public."refCattleSubClass" VALUES (12, 5, 'Guanaco', 'Guanaco', 'Guanaco', '2024-06-03 20:55:40.306+00', '2024-06-03 20:55:40.306+00', true);
INSERT INTO public."refCattleSubClass" VALUES (13, 1, 'Oveja', 'Oveja', 'Ewe', '2024-06-03 20:55:40.306+00', '2024-06-03 20:55:40.306+00', false);
INSERT INTO public."refCattleSubClass" VALUES (14, 1, 'Carnero', 'Carnero', 'Ram', '2024-06-03 20:55:40.306+00', '2024-06-03 20:55:40.306+00', false);
INSERT INTO public."refCattleSubClass" VALUES (15, 1, 'Borrego 0-1 años', 'Borrego 0-1 años', 'Sheep 0-1 years old', '2024-06-03 20:55:40.306+00', '2024-06-03 20:55:40.306+00', true);
INSERT INTO public."refCattleSubClass" VALUES (16, 1, 'Borrego/a', 'Borrego/a', 'Ewe hogget', '2024-06-03 20:55:40.306+00', '2024-06-03 20:55:40.306+00', false);
INSERT INTO public."refCattleSubClass" VALUES (27, 1, 'Capon', 'Capon', 'Wether', '2024-06-07 19:04:01.481+00', '2024-06-07 19:04:01.481+00', false);
INSERT INTO public."refCattleSubClass" VALUES (17, 2, 'Caballo', 'Caballo', 'Horse', '2024-06-03 20:55:40.306+00', '2024-06-03 20:55:40.306+00', false);
INSERT INTO public."refCattleSubClass" VALUES (18, 2, 'Potrillo 0-1 años', 'Potrillo 0-1 años', 'Foal 0-1 years', '2024-06-03 20:55:40.306+00', '2024-06-03 20:55:40.306+00', true);
INSERT INTO public."refCattleSubClass" VALUES (19, 2, 'Potrillo 1-2 años', 'Potrillo 1-2 años', 'Foal 1-2 years', '2024-06-03 20:55:40.306+00', '2024-06-03 20:55:40.306+00', true);
INSERT INTO public."refCattleSubClass" VALUES (20, 2, 'Yegua', 'Yegua', 'Mare', '2024-06-03 20:55:40.306+00', '2024-06-03 20:55:40.306+00', true);
INSERT INTO public."refCattleSubClass" VALUES (21, 2, 'Potro', 'Potro', 'Colt', '2024-06-03 20:55:40.306+00', '2024-06-03 20:55:40.306+00', true);
INSERT INTO public."refCattleSubClass" VALUES (22, 2, 'Burro', 'Burro', 'Donkey', '2024-06-03 20:55:40.306+00', '2024-06-03 20:55:40.306+00', true);
INSERT INTO public."refCattleSubClass" VALUES (23, 2, 'Mula', 'Mula', 'Mule', '2024-06-03 20:55:40.306+00', '2024-06-03 20:55:40.306+00', true);
INSERT INTO public."refCattleSubClass" VALUES (24, 6, 'Ciervo', 'Ciervo', 'Deer', '2024-06-03 20:55:40.306+00', '2024-06-03 20:55:40.306+00', false);
INSERT INTO public."refCattleSubClass" VALUES (25, 6, 'Cierva', 'Cierva', 'Hind', '2024-06-03 20:55:40.306+00', '2024-06-03 20:55:40.306+00', true);
INSERT INTO public."refCattleSubClass" VALUES (26, 6, 'Cervatillo', 'Cervatillo', 'Fawn', '2024-06-03 20:55:40.306+00', '2024-06-03 20:55:40.306+00', true);
INSERT INTO public."refCattleEmissionsFactors" VALUES (3, 14, 9, 0.9, 0.003, 0.01, 0.32, 0.21, 'SRCCL', '2024-08-13 15:11:54.221+00', '2024-08-13 15:11:54.221+00');
INSERT INTO public."refCattleEmissionsFactors" VALUES (4, 28, 55, 0.9, 0.004, 0.01, 0.31, 0.21, 'SRCCL', '2024-08-13 15:11:54.221+00', '2024-08-13 15:11:54.221+00');
INSERT INTO public."refCattleEmissionsFactors" VALUES (5, 4, 55, 0.9, 0.004, 0.01, 0.31, 0.21, 'SRCCL', '2024-08-13 15:11:54.221+00', '2024-08-13 15:11:54.221+00');
INSERT INTO public."refCattleEmissionsFactors" VALUES (6, 5, 55, 0.9, 0.004, 0.01, 0.31, 0.21, 'SRCCL', '2024-08-13 15:11:54.221+00', '2024-08-13 15:11:54.221+00');
INSERT INTO public."refCattleEmissionsFactors" VALUES (7, 3, 55, 0.9, 0.004, 0.01, 0.31, 0.21, 'SRCCL', '2024-08-13 15:11:54.221+00', '2024-08-13 15:11:54.221+00');
INSERT INTO public."refCattleEmissionsFactors" VALUES (8, 8, 9, 0.9, 0.003, 0.01, 0.34, 0.21, 'SRCCL', '2024-08-13 15:11:54.221+00', '2024-08-13 15:11:54.221+00');
INSERT INTO public."refCattleEmissionsFactors" VALUES (9, 10, 9, 0.9, 0.003, 0.01, 0.34, 0.21, 'SRCCL', '2024-08-13 15:11:54.221+00', '2024-08-13 15:11:54.221+00');
INSERT INTO public."refCattleEmissionsFactors" VALUES (10, 9, 9, 0.9, 0.003, 0.01, 0.34, 0.21, 'SRCCL', '2024-08-13 15:11:54.221+00', '2024-08-13 15:11:54.221+00');
INSERT INTO public."refCattleEmissionsFactors" VALUES (11, 17, 18, 1.7, 0.003, 0.01, 0.46, 0.21, 'SRCCL', '2024-08-13 15:11:54.221+00', '2024-08-13 15:11:54.221+00');
INSERT INTO public."refCattleEmissionsFactors" VALUES (12, 24, 20, 0.22, 0.003, 0.01, 0.67, 0.21, 'SRCCL', '2024-08-13 15:11:54.221+00', '2024-08-13 15:11:54.221+00');
INSERT INTO public."refCattleEmissionsFactors" VALUES (0, 13, 9, 0.9, 0.003, 0.01, 0.32, 0.21, 'SRCCL', '2024-08-13 15:11:54.221+00', '2024-08-13 15:11:54.221+00');
INSERT INTO public."refCattleEmissionsFactors" VALUES (1, 27, 9, 0.9, 0.003, 0.01, 0.32, 0.21, 'SRCCL', '2024-08-13 15:11:54.221+00', '2024-08-13 15:11:54.221+00');
INSERT INTO public."refCattleEmissionsFactors" VALUES (2, 16, 9, 0.9, 0.003, 0.01, 0.32, 0.21, 'SRCCL', '2024-08-13 15:11:54.221+00', '2024-08-13 15:11:54.221+00');
INSERT INTO public."refCattleEquivalences" VALUES (0, 13, 13, 1, false, '2024-08-13 15:11:54.211+00', '2024-08-13 15:11:54.211+00');
INSERT INTO public."refCattleEquivalences" VALUES (1, 14, 13, 1.2, false, '2024-08-13 15:11:54.211+00', '2024-08-13 15:11:54.211+00');
INSERT INTO public."refCattleEquivalences" VALUES (2, 16, 13, 0.7, false, '2024-08-13 15:11:54.211+00', '2024-08-13 15:11:54.211+00');
INSERT INTO public."refCattleEquivalences" VALUES (3, 27, 13, 1, false, '2024-08-13 15:11:54.211+00', '2024-08-13 15:11:54.211+00');
INSERT INTO public."refCattleEquivalences" VALUES (4, 28, 13, 7, false, '2024-08-13 15:11:54.211+00', '2024-08-13 15:11:54.211+00');
INSERT INTO public."refCattleEquivalences" VALUES (5, 3, 13, 8, false, '2024-08-13 15:11:54.211+00', '2024-08-13 15:11:54.211+00');
INSERT INTO public."refCattleEquivalences" VALUES (6, 4, 13, 5, false, '2024-08-13 15:11:54.211+00', '2024-08-13 15:11:54.211+00');
INSERT INTO public."refCattleEquivalences" VALUES (7, 5, 13, 5, false, '2024-08-13 15:11:54.211+00', '2024-08-13 15:11:54.211+00');
INSERT INTO public."refCattleEquivalences" VALUES (8, 8, 13, 0.8, false, '2024-08-13 15:11:54.211+00', '2024-08-13 15:11:54.211+00');
INSERT INTO public."refCattleEquivalences" VALUES (9, 10, 13, 0.9, false, '2024-08-13 15:11:54.211+00', '2024-08-13 15:11:54.211+00');
INSERT INTO public."refCattleEquivalences" VALUES (10, 9, 13, 0.5, false, '2024-08-13 15:11:54.211+00', '2024-08-13 15:11:54.211+00');
INSERT INTO public."refCattleEquivalences" VALUES (11, 17, 13, 9, false, '2024-08-13 15:11:54.211+00', '2024-08-13 15:11:54.211+00');
INSERT INTO public."refCattleEquivalences" VALUES (12, 24, 13, 1.7, false, '2024-08-13 15:11:54.211+00', '2024-08-13 15:11:54.211+00');
INSERT INTO public."refCattleType" VALUES (0, 'Toro', 'Toro', 'Bull', '2024-06-03 20:55:40.296+00', '2024-06-03 20:55:40.296+00', false);
INSERT INTO public."refCattleType" VALUES (1, 'Vaca de cría', 'Vaca de cría', 'Cow of calf', '2024-06-03 20:55:40.296+00', '2024-06-03 20:55:40.296+00', false);
INSERT INTO public."refCattleType" VALUES (2, 'Ternero/a recría de hasta 1 año', 'Ternero/a recría de hasta 1 año', 'Calf/calf rearing up to 1 year old', '2024-06-03 20:55:40.296+00', '2024-06-03 20:55:40.296+00', false);
INSERT INTO public."refCattleType" VALUES (3, 'Vaquillona de más de 1 año', 'Vaquillona de más de 1 año', 'Heifer over 1 year old', '2024-06-03 20:55:40.296+00', '2024-06-03 20:55:40.296+00', false);
INSERT INTO public."refCattleType" VALUES (4, 'Novillo de más de 1 año', 'Novillo de más de 1 año', 'Steer over 1 year old', '2024-06-03 20:55:40.296+00', '2024-06-03 20:55:40.296+00', false);
INSERT INTO public."refCattleType" VALUES (5, 'Oveja', 'Oveja', 'Sheep', '2024-06-03 20:55:40.296+00', '2024-06-03 20:55:40.296+00', false);
INSERT INTO public."refCattleType" VALUES (6, 'Cordero', 'Cordero', 'Lamb', '2024-06-03 20:55:40.296+00', '2024-06-03 20:55:40.296+00', false);
INSERT INTO public."refCattleType" VALUES (7, 'Carnero', 'Carnero', 'Ram', '2024-06-03 20:55:40.296+00', '2024-06-03 20:55:40.296+00', false);
INSERT INTO public."refCattleType" VALUES (8, 'Búfala', 'Búfala', 'Buffalo', '2024-06-03 20:55:40.296+00', '2024-06-03 20:55:40.296+00', false);
INSERT INTO public."refCattleType" VALUES (9, 'Búfalo', 'Búfalo', 'Buffalo', '2024-06-03 20:55:40.296+00', '2024-06-03 20:55:40.296+00', false);
INSERT INTO public."refCattleType" VALUES (10, 'Cabra', 'Cabra', 'Goat', '2024-06-03 20:55:40.296+00', '2024-06-03 20:55:40.296+00', false);
INSERT INTO public."refCattleType" VALUES (11, 'Cabrito', 'Cabrito', '', '2024-06-03 20:55:40.296+00', '2024-06-03 20:55:40.296+00', false);
INSERT INTO public."refCattleType" VALUES (12, 'Chivo', 'Chivo', '', '2024-06-03 20:55:40.296+00', '2024-06-03 20:55:40.296+00', false);
INSERT INTO public."refCattleType" VALUES (13, 'Llama', 'Llama', 'Llama', '2024-06-03 20:55:40.296+00', '2024-06-03 20:55:40.296+00', false);
INSERT INTO public."refCattleType" VALUES (14, 'Guanaco', 'Guanaco', 'Guanaco', '2024-06-03 20:55:40.296+00', '2024-06-03 20:55:40.296+00', false);
INSERT INTO public."refCattleType" VALUES (15, 'Yegua', 'Yegua', 'Mare', '2024-06-03 20:55:40.296+00', '2024-06-03 20:55:40.296+00', false);
INSERT INTO public."refCattleType" VALUES (16, 'Potro', 'Potro', 'Colt', '2024-06-03 20:55:40.296+00', '2024-06-03 20:55:40.296+00', false);
INSERT INTO public."refCattleType" VALUES (17, 'Potrillo', 'Potrillo', 'Foal', '2024-06-03 20:55:40.296+00', '2024-06-03 20:55:40.296+00', false);
INSERT INTO public."refCattleType" VALUES (18, 'Burro', 'Burro', 'Donkey', '2024-06-03 20:55:40.296+00', '2024-06-03 20:55:40.296+00', false);
INSERT INTO public."refCattleType" VALUES (19, 'Caballo', 'Caballo', 'Horse', '2024-06-03 20:55:40.296+00', '2024-06-03 20:55:40.296+00', false);
INSERT INTO public."refCattleType" VALUES (20, 'Mula', 'Mula', 'Mule', '2024-06-03 20:55:40.296+00', '2024-06-03 20:55:40.296+00', false);
INSERT INTO public."refCattleType" VALUES (21, 'Ciervo', 'Ciervo', 'Deer', '2024-06-03 20:55:40.296+00', '2024-06-03 20:55:40.296+00', false);
INSERT INTO public."refCattleType" VALUES (22, 'Vaca vacía', 'Vaca vacía', 'Cow empty', '2024-07-11 19:49:08.905+00', '2024-07-11 19:49:08.905+00', false);
INSERT INTO public."refCervidCattle" VALUES (0, 'Ciervo', 'Ciervo', 'Deer', '2024-06-03 20:55:40.337+00', '2024-06-03 20:55:40.337+00', false);
INSERT INTO public."refCervidCattle" VALUES (1, 'Cierva', 'Cierva', 'Deer', '2024-06-03 20:55:40.337+00', '2024-06-03 20:55:40.337+00', false);
INSERT INTO public."refCervidCattle" VALUES (2, 'Cervatillo', 'Cervatillo', 'Fawn', '2024-06-03 20:55:40.337+00', '2024-06-03 20:55:40.337+00', false);
INSERT INTO public."refCountries" VALUES (0, 'AR', 'Argentina', 'AR', 'Argentina', 'AR', 'Argentina', 'AR', 'Argentina', false, '2025-01-08 23:22:36.685+00', '2025-01-08 23:22:36.685+00');
INSERT INTO public."refCountries" VALUES (1, 'PY', 'Paraguay', 'PY', 'Paraguai', 'PY', 'Paraguay', 'PY', 'Paraguay', false, '2025-01-08 23:22:36.685+00', '2025-01-08 23:22:36.685+00');
INSERT INTO public."refCountries" VALUES (2, 'BR', 'Brasil', 'BR', 'Brasil', 'BR', 'Brasil', 'BR', 'Brazil', false, '2025-01-08 23:22:36.685+00', '2025-01-08 23:22:36.685+00');
INSERT INTO public."refCountries" VALUES (3, 'CL', 'Chile', 'CL', 'Chile', 'CL', 'Chile', 'CL', 'Chile', false, '2025-01-08 23:22:36.685+00', '2025-01-08 23:22:36.685+00');
INSERT INTO public."refCountries" VALUES (4, 'UY', 'Uruguay', 'UY', 'Uruguai', 'UY', 'Uruguay', 'UY', 'Uruguay', false, '2025-01-08 23:22:36.685+00', '2025-01-08 23:22:36.685+00');
INSERT INTO public."refCropType" VALUES (0, 'Maíz', 'Maíz', 'Korn', '2024-06-03 20:55:40.38+00', '2024-06-03 20:55:40.38+00', false);
INSERT INTO public."refCropType" VALUES (1, 'Soja', 'Soja', 'Soy', '2024-06-03 20:55:40.38+00', '2024-06-03 20:55:40.38+00', false);
INSERT INTO public."refCropType" VALUES (2, 'Trigo', 'Trigo', 'Wheat', '2024-06-03 20:55:40.38+00', '2024-06-03 20:55:40.38+00', false);
INSERT INTO public."refCropType" VALUES (3, 'Maní', 'Maní', 'Peanut', '2024-06-03 20:55:40.38+00', '2024-06-03 20:55:40.38+00', false);
INSERT INTO public."refCropType" VALUES (4, 'Sorgo', 'Sorgo', '', '2024-06-03 20:55:40.38+00', '2024-06-03 20:55:40.38+00', false);
INSERT INTO public."refCropType" VALUES (5, 'Girasol', 'Girasol', 'Sunflower', '2024-06-03 20:55:40.38+00', '2024-06-03 20:55:40.38+00', false);
INSERT INTO public."refCropType" VALUES (6, 'Cultivo de cobertura', 'Cultivo de cobertura', '', '2024-06-03 20:55:40.38+00', '2024-06-03 20:55:40.38+00', false);
INSERT INTO public."refCropType" VALUES (7, 'Cultivos anuales para forraje', 'Cultivos anuales para forraje', '', '2024-06-03 20:55:40.38+00', '2024-06-03 20:55:40.38+00', false);
INSERT INTO public."refDAPMethods" VALUES (0, 'Intacta', 'Intacta', 'Undisturbed', false, '2025-02-17 20:55:31.144+00', '2025-02-17 20:55:31.144+00');
INSERT INTO public."refDAPMethods" VALUES (1, 'Excavación', 'Excavación', 'Excavation', false, '2025-02-17 20:55:31.144+00', '2025-02-17 20:55:31.144+00');
INSERT INTO public."refDAPMethods" VALUES (2, 'Anillo', 'Anillo', 'Ring', false, '2025-07-29 22:11:32.025+00', '2025-07-29 22:11:32.025+00');
INSERT INTO public."refDataCollectionStatementStatus" VALUES (0, 'Pendiente', 'Pendiente', 'Pending', '2024-06-03 20:55:40.455+00', '2024-06-03 20:55:40.455+00', false);
INSERT INTO public."refDataCollectionStatementStatus" VALUES (1, 'En proceso', 'En proceso', 'In process', '2024-06-03 20:55:40.455+00', '2024-06-03 20:55:40.455+00', false);
INSERT INTO public."refDataCollectionStatementStatus" VALUES (2, 'A revisar', 'A revisar', 'To review', '2024-06-03 20:55:40.455+00', '2024-06-03 20:55:40.455+00', false);
INSERT INTO public."refDataCollectionStatementStatus" VALUES (3, 'En revisión', 'En revisión', 'In review', '2024-06-03 20:55:40.455+00', '2024-06-03 20:55:40.455+00', false);
INSERT INTO public."refDataCollectionStatementStatus" VALUES (4, 'Observada', 'Observada', 'Observed', '2024-06-03 20:55:40.455+00', '2024-06-03 20:55:40.455+00', false);
INSERT INTO public."refDataCollectionStatementStatus" VALUES (5, 'Aprobada', 'Aprobada', 'Approved', '2024-06-03 20:55:40.455+00', '2024-06-03 20:55:40.455+00', false);
INSERT INTO public."refDataCollectionStatementStatus" VALUES (6, 'Aprobada completamente', 'Aprobada completamente', 'FullAprroved', '2024-06-03 20:55:40.455+00', '2024-06-03 20:55:40.455+00', false);
INSERT INTO public."refDataCollectionStatementStatus" VALUES (7, 'No conforme', 'No comforme', 'NonCompaint', '2024-06-03 20:55:40.455+00', '2024-06-03 20:55:40.455+00', false);
INSERT INTO public."refDegreeDegradationSoil" VALUES (0, 'Severa', 'Severa', 'Severe', '2024-06-03 20:55:40.463+00', '2024-06-03 20:55:40.463+00', false);
INSERT INTO public."refDegreeDegradationSoil" VALUES (1, 'Moderada', 'Moderada', 'Moderate', '2024-06-03 20:55:40.463+00', '2024-06-03 20:55:40.463+00', false);
INSERT INTO public."refDegreeDegradationSoil" VALUES (2, 'Sin degradación', 'Sin degradación', 'Without degradation', '2024-06-03 20:55:40.463+00', '2024-06-03 20:55:40.463+00', false);
INSERT INTO public."refDocumentType" VALUES (0, 'Facturas de compra de animales', 'Facturas de compra de animales', 'Animal purchase bills', '2024-06-03 20:55:40.585+00', '2024-06-03 20:55:40.585+00', false);
INSERT INTO public."refDocumentType" VALUES (1, 'Certificados de SENASA', 'Certificados de SENASA', 'Senasa certifaction', '2024-06-03 20:55:40.585+00', '2024-06-03 20:55:40.585+00', false);
INSERT INTO public."refDocumentType" VALUES (2, 'Facturas de fertilizantes', 'Facturas de fertilizantes', 'Fertilizers bills', '2024-06-03 20:55:40.585+00', '2024-06-03 20:55:40.585+00', false);
INSERT INTO public."refDocumentType" VALUES (3, 'Facturas de combustibles', 'Facturas de combustibles', 'Fuels bills', '2024-06-03 20:55:40.585+00', '2024-06-03 20:55:40.585+00', false);
INSERT INTO public."refDocumentType" VALUES (4, 'Facturas de monitoreo', 'Facturas de monitoreo', 'Monitoring bills', '2024-06-03 20:55:40.585+00', '2024-06-03 20:55:40.585+00', false);
INSERT INTO public."refDocumentType" VALUES (5, 'Certificado de análisis de suelo', 'Certificado de análisis de suelo', 'Soil analysis certificate', '2025-02-17 20:55:31.386+00', '2025-02-17 20:55:31.386+00', false);
INSERT INTO public."refEntityDiscardReason" VALUES (0, 'Manejo holistico con al menos un plan de Pastoreo Continuo u Otros Pastoreos Rotativos luego de nacimiento de instancia', 'Manejo holistico con al menos un plan de Pastoreo Continuo u Otros Pastoreos Rotativos luego de nacimiento de instancia', 'Holistic management with at least one Continuous Grazing or Other Rotational Grazing plan after instance is born', '2024-08-16 14:00:13.832+00', '2024-08-16 14:00:13.832+00');
INSERT INTO public."refEntityDiscardReason" VALUES (1, 'Área de descarte para instancia de carbono de SARA obtenida mediante un proceso de curaduría manual', 'Área de descarte para instancia de carbono de SARA obtenida mediante un proceso de curaduría manual', 'Discard area for SARA carbon instance obtained through a manual curation process', '2025-03-19 19:15:08.226+00', '2025-03-19 19:15:08.226+00');
INSERT INTO public."refEntityType" VALUES (0, 'Loteo', 'Loteo', 'Farm subdivision', '2024-06-03 20:55:40.589+00', '2024-06-03 20:55:40.589+00', false);
INSERT INTO public."refEntityType" VALUES (1, 'Lote', 'Lote', 'Paddock', '2024-08-16 14:00:13.766+00', '2024-08-16 14:00:13.766+00', false);
INSERT INTO public."refEntityType" VALUES (2, 'Establecimiento', 'Establecimiento', 'Farm', '2024-11-27 22:09:34.01+00', '2024-11-27 22:09:34.01+00', false);
INSERT INTO public."refEntityType" VALUES (3, 'Instancia de Carbono', 'Instancia de Carbono', 'Carbon Instance', '2024-11-27 22:09:34.01+00', '2024-11-27 22:09:34.01+00', false);
INSERT INTO public."refEntityType" VALUES (4, 'Muestra de Monitorización de Carbono en Suelo', 'Muestra de Monitorización de Carbono en Suelo', 'Monitoring SOC Sample', '2025-02-17 20:55:31.393+00', '2025-02-17 20:55:31.393+00', false);
INSERT INTO public."refEquineCattle" VALUES (0, 'Caballo', 'Caballo', 'Horse', '2024-06-03 20:55:40.321+00', '2024-06-03 20:55:40.321+00', false);
INSERT INTO public."refEquineCattle" VALUES (1, 'Potrillo 0-1 años', 'Potrillo 0-1 años', 'Foal 0-1 years', '2024-06-03 20:55:40.321+00', '2024-06-03 20:55:40.321+00', false);
INSERT INTO public."refEquineCattle" VALUES (2, 'Potrillo 1-2 años', 'Potrillo 1-2 años', 'Foal 1-2 years', '2024-06-03 20:55:40.321+00', '2024-06-03 20:55:40.321+00', false);
INSERT INTO public."refEquineCattle" VALUES (3, 'Yegua', 'Yegua', 'Mare', '2024-06-03 20:55:40.321+00', '2024-06-03 20:55:40.321+00', false);
INSERT INTO public."refEquineCattle" VALUES (4, 'Potro', 'Potro', 'Colt', '2024-06-03 20:55:40.321+00', '2024-06-03 20:55:40.321+00', false);
INSERT INTO public."refEquineCattle" VALUES (5, 'Burro', 'Burro', 'Donkey', '2024-06-03 20:55:40.321+00', '2024-06-03 20:55:40.321+00', false);
INSERT INTO public."refEquineCattle" VALUES (6, 'Mula', 'Mula', 'Mule', '2024-06-03 20:55:40.321+00', '2024-06-03 20:55:40.321+00', false);
INSERT INTO public."refExclusionAreaType" VALUES (10, 'Deforestación', 'Deforestación', 'Deforestation', '2024-10-15 14:44:12.365+00', '2024-10-15 14:44:12.365+00', false, '{0,2}');
INSERT INTO public."refExclusionAreaType" VALUES (99, 'Otro', 'Otro', 'Other', '2024-06-03 20:55:40.352+00', '2024-06-03 20:55:40.352+00', false, '{2,0,1,99}');
INSERT INTO public."refExclusionAreaType" VALUES (0, 'Cuerpo de agua', 'Cuerpo de agua', 'Water body', '2024-06-03 20:55:40.352+00', '2024-06-03 20:55:40.352+00', false, '{2,0,1,99}');
INSERT INTO public."refExclusionAreaType" VALUES (1, 'Camino', 'Camino', 'Road', '2024-06-03 20:55:40.352+00', '2024-06-03 20:55:40.352+00', false, '{2,0,1,99}');
INSERT INTO public."refExclusionAreaType" VALUES (2, 'Instalaciones', 'Instalaciones', 'Building', '2024-06-03 20:55:40.352+00', '2024-06-03 20:55:40.352+00', false, '{2,0,1,99}');
INSERT INTO public."refExclusionAreaType" VALUES (3, 'Reserva natural', 'Reserva natural', 'Natural reserve', '2024-06-03 20:55:40.352+00', '2024-06-03 20:55:40.352+00', false, '{2,0,1,99}');
INSERT INTO public."refExclusionAreaType" VALUES (4, 'Monte nativo', 'Monte nativo', 'Native forest', '2024-06-03 20:55:40.352+00', '2024-06-03 20:55:40.352+00', false, '{2,0,1,99}');
INSERT INTO public."refExclusionAreaType" VALUES (5, 'Zona improductiva', 'Zona improductiva', 'Unproductive area', '2024-06-03 20:55:40.352+00', '2024-06-03 20:55:40.352+00', false, '{2,0,1,99}');
INSERT INTO public."refExclusionAreaType" VALUES (6, 'Humedal', 'Humedal', 'Wetland', '2024-06-03 20:55:40.352+00', '2024-06-03 20:55:40.352+00', false, '{2,0,1,99}');
INSERT INTO public."refExclusionAreaType" VALUES (7, 'Laguna seca', 'Laguna seca', 'Dry lagoon', '2024-09-23 18:16:07.832+00', '2024-09-23 18:16:07.832+00', false, '{1}');
INSERT INTO public."refExclusionAreaType" VALUES (8, 'Bosque implantado', 'Bosque implantado', 'Implanted forest', '2024-10-15 14:44:12.365+00', '2024-10-15 14:44:12.365+00', false, '{0,2}');
INSERT INTO public."refExclusionAreaType" VALUES (9, 'Curso de agua', 'Curso de agua', 'Watercourse', '2024-10-15 14:44:12.365+00', '2024-10-15 14:44:12.365+00', false, '{0,2}');
INSERT INTO public."refFieldRelocationMethod" VALUES (0, 'Realeatorizado por MDC', 'Realeatorizado por MDC', 'MDC randomizer', false, '2024-11-27 22:09:34.098+00', '2024-11-27 22:09:34.098+00');
INSERT INTO public."refFieldRelocationMethod" VALUES (1, 'Manual', 'Manual', 'Manual', false, '2024-11-27 22:09:34.098+00', '2024-11-27 22:09:34.098+00');
INSERT INTO public."refFieldUsage" VALUES (0, 'Ganadería', 'Ganadería', 'Grazing', '2024-06-03 20:55:40.272+00', '2024-06-03 20:55:40.272+00', false);
INSERT INTO public."refFieldUsage" VALUES (1, 'Agricultura', 'Agricultura', 'Agriculture', '2024-06-03 20:55:40.272+00', '2024-06-03 20:55:40.272+00', false);
INSERT INTO public."refFieldUsage" VALUES (2, 'Forestal', 'Forestal', 'Forest', '2024-06-03 20:55:40.272+00', '2024-06-03 20:55:40.272+00', false);
INSERT INTO public."refFieldUsage" VALUES (3, 'Mixto (agro-ganadero)', 'Mixto (agro-ganadero)', 'Mixed (agro-livestock)', '2024-06-03 20:55:40.272+00', '2024-06-03 20:55:40.272+00', false);
INSERT INTO public."refFieldUsage" VALUES (4, 'Sin uso', 'Sin uso', 'Without use', '2024-06-03 20:55:40.272+00', '2024-06-03 20:55:40.272+00', false);
INSERT INTO public."refFieldUsage" VALUES (5, 'Silvopastoril', 'Silvopastoril', 'Silvopastoral', '2024-06-03 20:55:40.272+00', '2024-06-03 20:55:40.272+00', false);
INSERT INTO public."refFieldUsage" VALUES (6, 'Agroforestal', 'Agroforestal', 'Agroforestry', '2024-06-03 20:55:40.272+00', '2024-06-03 20:55:40.272+00', false);
INSERT INTO public."refFieldUsage" VALUES (7, 'Área de sacrificio', 'Área de sacrificio', 'Sacrifice area', '2024-06-03 20:55:40.272+00', '2024-06-03 20:55:40.272+00', false);
INSERT INTO public."refFindingType" VALUES (0, 'Observación', 'Observación', 'Observation', '2024-06-03 20:55:40.344+00', '2024-06-03 20:55:40.344+00', false);
INSERT INTO public."refFindingType" VALUES (1, 'Incumplimiento a corregir', 'Incumplimiento a corregir', 'Non-compliance to correct', '2024-06-03 20:55:40.344+00', '2024-06-03 20:55:40.344+00', false);
INSERT INTO public."refFindingType" VALUES (2, 'Incumplimiento grave', 'Incumplimiento grave', 'Serious non-compliance', '2024-06-03 20:55:40.344+00', '2024-06-03 20:55:40.344+00', false);
INSERT INTO public."refForageSource" VALUES (0, 'Silvopastoril', '', '', '2024-06-03 20:55:40.276+00', '2024-06-03 20:55:40.276+00', false);
INSERT INTO public."refForageSource" VALUES (1, 'Campo natural', 'Campo natural', '', '2024-06-03 20:55:40.276+00', '2024-06-03 20:55:40.276+00', false);
INSERT INTO public."refForageSource" VALUES (2, 'Pasturas cultivadas', 'Pasturas cultivadas', 'Crop pastures', '2024-06-03 20:55:40.276+00', '2024-06-03 20:55:40.276+00', false);
INSERT INTO public."refForageSource" VALUES (3, 'Cultivos de invierno', 'Cultivos de invierno', 'Winter crops', '2024-06-03 20:55:40.276+00', '2024-06-03 20:55:40.276+00', false);
INSERT INTO public."refForageSource" VALUES (4, 'Cultivos de verano', 'Cultivos de verano', 'Summer crops', '2024-06-03 20:55:40.276+00', '2024-06-03 20:55:40.276+00', false);
INSERT INTO public."refForageUseIntensity" VALUES (1, 'Nulo', 'Nulo', 'Null', 'Nulo', false, '2025-06-11 18:14:31.15+00', '2025-06-11 18:14:31.15+00');
INSERT INTO public."refForageUseIntensity" VALUES (2, 'Liviano', 'Liviano', 'Light', 'Liviano', false, '2025-06-11 18:14:31.15+00', '2025-06-11 18:14:31.15+00');
INSERT INTO public."refForageUseIntensity" VALUES (3, 'Moderado', 'Moderado', 'Moderate', 'Moderado', false, '2025-06-11 18:14:31.15+00', '2025-06-11 18:14:31.15+00');
INSERT INTO public."refForageUseIntensity" VALUES (4, 'Intenso', 'Intenso', 'Intense', 'Intenso', false, '2025-06-11 18:14:31.15+00', '2025-06-11 18:14:31.15+00');
INSERT INTO public."refForageUsePattern" VALUES (1, 'SP', 'SP', 'SP', 'SP', false, '2025-06-11 18:14:31.143+00', '2025-06-11 18:14:31.143+00');
INSERT INTO public."refForageUsePattern" VALUES (2, 'SD', 'SD', 'SD', 'SD', false, '2025-06-11 18:14:31.143+00', '2025-06-11 18:14:31.143+00');
INSERT INTO public."refForageUsePattern" VALUES (3, 'DP', 'DP', 'DP', 'DP', false, '2025-06-11 18:14:31.143+00', '2025-06-11 18:14:31.143+00');
INSERT INTO public."refForageUsePattern" VALUES (4, 'PP', 'PP', 'PP', 'PP', false, '2025-06-11 18:14:31.143+00', '2025-06-11 18:14:31.143+00');
-- refFuelType must come BEFORE refFuelEmissionsFactors (FK dependency)
INSERT INTO public."refFuelType" VALUES (0, 'Nafta', 'Nafta', 'Gasoline', '2024-06-03 20:55:40.34+00', '2024-06-03 20:55:40.34+00', false);
INSERT INTO public."refFuelType" VALUES (1, 'Diesel', 'Diesel', 'Diesel', '2024-06-03 20:55:40.34+00', '2024-06-03 20:55:40.34+00', false);
INSERT INTO public."refFuelType" VALUES (2, 'Gas', 'Gas', 'Gas', '2024-06-03 20:55:40.34+00', '2024-06-03 20:55:40.34+00', false);
INSERT INTO public."refFuelEmissionsFactors" VALUES (0, 0, '0.0693', '44.3', '2.86', 'GHG2006', '2024-08-13 15:11:54.226+00', '2024-08-13 15:11:54.226+00');
INSERT INTO public."refFuelEmissionsFactors" VALUES (1, 1, '0.0741', '43', '3.22', 'GHG2006', '2024-08-13 15:11:54.226+00', '2024-08-13 15:11:54.226+00');
INSERT INTO public."refFuelEmissionsFactors" VALUES (2, 2, '0.0561', '48', '0.6292', 'GHG2006', '2024-08-13 15:11:54.226+00', '2024-08-13 15:11:54.226+00');
INSERT INTO public."refGrazingIntensityTypes" VALUES (0, 'Leve', 'Leve', 'Mild', '2024-06-03 20:55:40.618+00', '2024-06-03 20:55:40.618+00', false);
INSERT INTO public."refGrazingIntensityTypes" VALUES (1, 'Moderado', 'Moderado', 'Moderate', '2024-06-03 20:55:40.618+00', '2024-06-03 20:55:40.618+00', false);
INSERT INTO public."refGrazingIntensityTypes" VALUES (2, 'Intenso', 'Intenso', 'Intense', '2024-06-03 20:55:40.618+00', '2024-06-03 20:55:40.618+00', false);
INSERT INTO public."refGrazingIntensityTypes" VALUES (3, 'Nulo', 'Nulo', 'None', '2024-06-03 20:55:40.618+00', '2024-06-03 20:55:40.618+00', false);
INSERT INTO public."refGrazingPlanType" VALUES (0, 'Abierto', 'Abierto', 'Open', '2024-06-03 20:55:40.356+00', '2024-06-03 20:55:40.356+00', false);
INSERT INTO public."refGrazingPlanType" VALUES (1, 'Cerrado', 'Cerrado', 'Closed', '2024-06-03 20:55:40.356+00', '2024-06-03 20:55:40.356+00', false);
INSERT INTO public."refGrazingType" VALUES (0, 'Manejo holístico', 'Manejo holístico', 'Holistic management', '2024-06-03 20:55:40.348+00', '2024-06-03 20:55:40.348+00', false);
INSERT INTO public."refGrazingType" VALUES (1, 'Pastoreo continuo', 'Pastoreo continuo', 'Continuous grazing', '2024-06-03 20:55:40.348+00', '2024-06-03 20:55:40.348+00', false);
INSERT INTO public."refGrazingType" VALUES (2, 'Otros pastoreos rotativos', 'Otros pastoreos rotativos', 'Other rotational grazing', '2024-06-03 20:55:40.348+00', '2024-06-03 20:55:40.348+00', false);
INSERT INTO public."refGreenHouseGasesGwp" VALUES (0, 'C02', 'Dióxido de carbono', 'Carbon Dioxide', 1, 'AR5', '2024-08-13 15:11:54.216+00', '2024-08-13 15:11:54.216+00');
INSERT INTO public."refGreenHouseGasesGwp" VALUES (1, 'CH4', 'Metano', 'Methane', 28, 'AR5', '2024-08-13 15:11:54.216+00', '2024-08-13 15:11:54.216+00');
INSERT INTO public."refGreenHouseGasesGwp" VALUES (2, 'N2O', 'Oxido nitroso', 'Nitrous oxide', 265, 'AR5', '2024-08-13 15:11:54.216+00', '2024-08-13 15:11:54.216+00');
INSERT INTO public."refHorizonCode" VALUES (6, 'R', 'Roca madre, contacto lítico', 'R', 'Roca madre, contacto lítico', '', '', '2024-06-03 20:55:40.433+00', '2024-06-03 20:55:40.433+00', false);
INSERT INTO public."refHorizonCode" VALUES (7, 'Ca', 'Horizonte cálcico, con acumulación de carbonatos', 'Ca', 'Horizonte cálcico, con acumulación de carbonatos', '', '', '2024-06-03 20:55:40.433+00', '2024-06-03 20:55:40.433+00', false);
INSERT INTO public."refHorizonCode" VALUES (0, 'Ao', 'Horizonte superficial orgánico (detritos)', 'Ao', 'Horizonte superficial orgánico (detritos)', '', '', '2024-06-03 20:55:40.433+00', '2024-06-03 20:55:40.433+00', false);
INSERT INTO public."refHorizonCode" VALUES (1, 'A', 'Horizonte superficial mas oscuro', 'A', 'Horizonte superficial mas oscuro', '', '', '2024-06-03 20:55:40.433+00', '2024-06-03 20:55:40.433+00', false);
INSERT INTO public."refHorizonCode" VALUES (2, 'A2', 'Horizonte mas claro, eluvial', 'A2', 'Horizonte mas claro, eluvial', '', '', '2024-06-03 20:55:40.433+00', '2024-06-03 20:55:40.433+00', false);
INSERT INTO public."refHorizonCode" VALUES (3, 'B', 'Horizonte de iluviación, usualmente con materiales arcillosos', 'B', 'Horizonte de iluviación, usualmente con materiales arcillosos', '', '', '2024-06-03 20:55:40.433+00', '2024-06-03 20:55:40.433+00', false);
INSERT INTO public."refHorizonCode" VALUES (4, 'AC', 'Horizonte que transiciona gradualmente entre la superficie y el material madre', 'AC', 'Horizonte que transiciona gradualmente entre la superficie y el material madre', '', '', '2024-06-03 20:55:40.433+00', '2024-06-03 20:55:40.433+00', false);
INSERT INTO public."refHorizonCode" VALUES (5, 'C', 'Horizonte poco alterado, similar al material madre', 'C', 'Horizonte poco alterado, similar al material madre', '', '', '2024-06-03 20:55:40.433+00', '2024-06-03 20:55:40.433+00', false);
INSERT INTO public."refInstancesVerificationStatus" VALUES (0, 'Rechazado', 'Rejected', '2024-06-03 20:55:40.623+00', '2024-06-03 20:55:40.623+00', false);
INSERT INTO public."refInstancesVerificationStatus" VALUES (1, 'Observado', 'Observed', '2024-06-03 20:55:40.623+00', '2024-06-03 20:55:40.623+00', false);
INSERT INTO public."refInstancesVerificationStatus" VALUES (2, 'Aprobado', 'Approved', '2024-06-03 20:55:40.623+00', '2024-06-03 20:55:40.623+00', false);
INSERT INTO public."refIrrigationType" VALUES (0, 'Riego por superficie', 'Riego por superficie', '', '2024-06-03 20:55:40.376+00', '2024-06-03 20:55:40.376+00', false);
INSERT INTO public."refIrrigationType" VALUES (1, 'Riego presurizado', 'Riego presurizado', '', '2024-06-03 20:55:40.376+00', '2024-06-03 20:55:40.376+00', false);
INSERT INTO public."refLivestockRaisingTypes" VALUES (0, 'Cría', 'Cría', '', '2024-06-03 20:55:40.281+00', '2024-06-03 20:55:40.281+00', false);
INSERT INTO public."refLivestockRaisingTypes" VALUES (1, 'Recría', 'Recría', '', '2024-06-03 20:55:40.281+00', '2024-06-03 20:55:40.281+00', false);
INSERT INTO public."refLivestockRaisingTypes" VALUES (2, 'Invernada', 'Invernada', '', '2024-06-03 20:55:40.281+00', '2024-06-03 20:55:40.281+00', false);
INSERT INTO public."refLivestockRaisingTypes" VALUES (3, 'Tambo', 'Tambo', '', '2024-06-03 20:55:40.281+00', '2024-06-03 20:55:40.281+00', false);
INSERT INTO public."refLivestockRaisingTypes" VALUES (4, 'Feedlot', 'Feedlot', 'Feedlot', '2024-06-03 20:55:40.281+00', '2024-06-03 20:55:40.281+00', false);
INSERT INTO public."refLocationConfirmationType" VALUES (0, 'MDC', 'MDC', 'MDC', false, '2024-11-27 22:09:34.094+00', '2024-11-27 22:09:34.094+00');
INSERT INTO public."refLocationConfirmationType" VALUES (1, 'Dispositivo GPS externo', 'Dispositivo GPS externo', 'External GPS device', false, '2024-11-27 22:09:34.094+00', '2024-11-27 22:09:34.094+00');
INSERT INTO public."refLocationConfirmationType" VALUES (2, 'Manual', 'Manual', 'Manual', false, '2024-11-27 22:09:34.094+00', '2024-11-27 22:09:34.094+00');
INSERT INTO public."refLocationMovedReason" VALUES (0, 'Inaccesible', 'Inaccesible', 'Inaccessible', false, '2024-11-27 22:09:34.09+00', '2024-11-27 22:09:34.09+00');
INSERT INTO public."refLocationMovedReason" VALUES (1, 'Cambio de uso del terreno', 'Cambio de uso del terreno', 'Land use changed', false, '2024-11-27 22:09:34.09+00', '2024-11-27 22:09:34.09+00');
INSERT INTO public."refLocationMovedReason" VALUES (2, 'No representativo del estrato', 'No representativo del estrato', 'Classification mismatch', false, '2024-11-27 22:09:34.09+00', '2024-11-27 22:09:34.09+00');
INSERT INTO public."refMetricStatus" VALUES (0, 'Abierta', 'Abierta', 'Open', '2024-07-25 14:32:48.717+00', '2024-07-25 14:32:48.717+00', false);
INSERT INTO public."refMetricStatus" VALUES (1, 'Cerrada', 'Cerrada', 'Closed', '2024-07-25 14:32:48.717+00', '2024-07-25 14:32:48.717+00', false);
INSERT INTO public."refMineralFertilizerType" VALUES (0, 'Urea', 'Urea', 'Urea', '2024-06-03 20:55:40.368+00', '2024-06-03 20:55:40.368+00', false);
INSERT INTO public."refMineralFertilizerType" VALUES (1, 'NA - Nitrato de amonio', 'NA - Nitrato de amonio', '', '2024-06-03 20:55:40.368+00', '2024-06-03 20:55:40.368+00', false);
INSERT INTO public."refMineralFertilizerType" VALUES (2, 'CAN - Nitrato de amonio calcáreo', 'CAN - Nitrato de amonio calcáreo', '', '2024-06-03 20:55:40.368+00', '2024-06-03 20:55:40.368+00', false);
INSERT INTO public."refMineralFertilizerType" VALUES (3, 'SA - Sulfato de amonio', 'SA - Sulfato de amonio', '', '2024-06-03 20:55:40.368+00', '2024-06-03 20:55:40.368+00', false);
INSERT INTO public."refMineralFertilizerType" VALUES (4, 'FDA - Fosfato diamónico', 'FDA - Fosfato diamónico', '', '2024-06-03 20:55:40.368+00', '2024-06-03 20:55:40.368+00', false);
INSERT INTO public."refMineralFertilizerType" VALUES (5, 'FMA - Fosfato monoamónico', 'FMA - Fosfato monoamónico', '', '2024-06-03 20:55:40.368+00', '2024-06-03 20:55:40.368+00', false);
INSERT INTO public."refMineralFertilizerType" VALUES (6, 'SFS - Superfosfato simple', 'SFS - Superfosfato simple', '', '2024-06-03 20:55:40.368+00', '2024-06-03 20:55:40.368+00', false);
INSERT INTO public."refMineralFertilizerType" VALUES (7, 'SFT - Superfosfato triple', 'SFT - Superfosfato triple', '', '2024-06-03 20:55:40.368+00', '2024-06-03 20:55:40.368+00', false);
INSERT INTO public."refMineralFertilizerType" VALUES (8, 'Azufre elemental (grado variable)', 'Azufre elemental (grado variable)', '', '2024-06-03 20:55:40.368+00', '2024-06-03 20:55:40.368+00', false);
INSERT INTO public."refMineralFertilizerType" VALUES (9, 'Yeso agrícola (sulfato de calcio deshidratado)', 'Yeso agrícola (sulfato de calcio deshidratado)', '', '2024-06-03 20:55:40.368+00', '2024-06-03 20:55:40.368+00', false);
INSERT INTO public."refMineralFertilizerType" VALUES (10, 'Cloruro de potasio', 'Cloruro de potasio', '', '2024-06-03 20:55:40.368+00', '2024-06-03 20:55:40.368+00', false);
INSERT INTO public."refMineralFertilizerType" VALUES (11, 'UAN 32', 'UAN 32', '', '2024-06-03 20:55:40.368+00', '2024-06-03 20:55:40.368+00', false);
INSERT INTO public."refMineralFertilizerType" VALUES (12, 'TSA - Tiosulfato de amonio', 'TSA - Tiosulfato de amonio', '', '2024-06-03 20:55:40.368+00', '2024-06-03 20:55:40.368+00', false);
INSERT INTO public."refMineralFertilizerType" VALUES (13, 'Mezclas de UAN con TSA (80-20)', 'Mezclas de UAN con TSA (80-20)', '', '2024-06-03 20:55:40.368+00', '2024-06-03 20:55:40.368+00', false);
INSERT INTO public."refMineralFertilizerType" VALUES (14, 'Otro', 'Otro', 'Other', '2024-06-03 20:55:40.368+00', '2024-06-03 20:55:40.368+00', false);
INSERT INTO public."refMonitoringReportStatus" VALUES (0, 'En curso', 'primary', '2024-06-03 20:55:40.268+00', '2024-06-03 20:55:40.268+00', false);
INSERT INTO public."refMonitoringReportStatus" VALUES (1, 'Finalizado', 'success', '2024-06-03 20:55:40.268+00', '2024-06-03 20:55:40.268+00', false);
INSERT INTO public."refOrganicFertilizerType" VALUES (0, 'Compost', 'Compost', 'Compost', '2024-06-03 20:55:40.373+00', '2024-06-03 20:55:40.373+00', false);
INSERT INTO public."refOrganicFertilizerType" VALUES (1, 'Estiercol', 'Estiercol', 'Manure', '2024-06-03 20:55:40.373+00', '2024-06-03 20:55:40.373+00', false);
INSERT INTO public."refOvineCattle" VALUES (0, 'Oveja', 'Oveja', 'Sheep', '2024-06-03 20:55:40.317+00', '2024-06-03 20:55:40.317+00', false);
INSERT INTO public."refOvineCattle" VALUES (1, 'Carnero', 'Carnero', 'Ram', '2024-06-03 20:55:40.317+00', '2024-06-03 20:55:40.317+00', false);
INSERT INTO public."refOvineCattle" VALUES (2, 'Cordero 0-1 años', 'Cordero 0-1 años', 'Lamb 0-1 years', '2024-06-03 20:55:40.317+00', '2024-06-03 20:55:40.317+00', false);
INSERT INTO public."refOvineCattle" VALUES (3, 'Cordero 1-2 años', 'Cordero 1-2 años', 'Lamb 1-2 years', '2024-06-03 20:55:40.317+00', '2024-06-03 20:55:40.317+00', false);
INSERT INTO public."refPasturesFamily" VALUES (0, 'Graminea', 'Graminea', '', '2024-06-03 20:55:40.292+00', '2024-06-03 20:55:40.292+00', false);
INSERT INTO public."refPasturesFamily" VALUES (1, 'Leguminosa', 'Leguminosa', '', '2024-06-03 20:55:40.292+00', '2024-06-03 20:55:40.292+00', false);
INSERT INTO public."refPasturesGrowthTypes" VALUES (0, 'Anual', 'Anual', 'Annual', '2024-06-03 20:55:40.285+00', '2024-06-03 20:55:40.285+00', false);
INSERT INTO public."refPasturesGrowthTypes" VALUES (1, 'Perenne', 'Perenne', '', '2024-06-03 20:55:40.285+00', '2024-06-03 20:55:40.285+00', false);
INSERT INTO public."refPasturesTypes" VALUES (0, 'Natural', 'Natural', 'Natural', '2024-06-03 20:55:40.289+00', '2024-06-03 20:55:40.289+00', false);
INSERT INTO public."refPasturesTypes" VALUES (1, 'Implantado', 'Implantado', 'Planted', '2024-06-03 20:55:40.289+00', '2024-06-03 20:55:40.289+00', false);
INSERT INTO public."refRandomizer" VALUES (0, 'Randomizador v1.0.0', 'Randomizador v1.0.0', 'Randomizer v1.0.0', '1.0.0', 'randomPointsInPolygonV1', false, '2025-08-20 19:03:41.348+00', '2025-08-20 19:03:41.348+00');
INSERT INTO public."refRandomizer" VALUES (1, 'Randomizador v2.0.0', 'Randomizador v2.0.0', 'Randomizer v2.0.0', '2.0.0', 'randomPointsInPolygonV2', false, '2025-08-20 19:03:41.348+00', '2025-08-20 19:03:41.348+00');
INSERT INTO public."refRandomizer" VALUES (2, 'Randomizador v3.0.0', 'Randomizador v3.0.0', 'Randomizer v3.0.0', '3.0.0', 'randomPointsInPolygonV3', false, '2025-08-20 19:03:41.348+00', '2025-08-20 19:03:41.348+00');
INSERT INTO public."refRandomizer" VALUES (3, 'Randomizador v4.0.0', 'Randomizador v4.0.0', 'Randomizer v4.0.0', '4.0.0', 'generate_random_points', false, '2025-08-20 19:03:41.348+00', '2025-08-20 19:03:41.348+00');
INSERT INTO public."refSamplingNumbers" VALUES (0, '0-Línea de base', '0-Línea de base', '0-Baseline', false, '2025-02-17 20:55:31.151+00', '2025-02-17 20:55:31.151+00');
INSERT INTO public."refSamplingNumbers" VALUES (1, '1-Primer re-muestreo', '1-Primer re-muestreo', '1-First re-sampling', false, '2025-02-17 20:55:31.151+00', '2025-02-17 20:55:31.151+00');
INSERT INTO public."refSamplingNumbers" VALUES (2, '2-Segundo re-muestreo', '2-Segundo re-muestreo', '2-Second re-sampling', false, '2025-02-17 20:55:31.151+00', '2025-02-17 20:55:31.151+00');
INSERT INTO public."refSoilSamplingDisturbance" VALUES (1, 'Intacta', 'Intacta', 'Intacta', 'Intacta', 'Undisturbed', 'Undisturbed', 'Intacta', 'Intacta', false, '2025-09-10 19:18:23.036+00', '2025-09-10 19:18:23.036+00');
INSERT INTO public."refSoilSamplingDisturbance" VALUES (2, 'No intacta', 'No intacta', 'No intacta', 'No intacta', 'Disturbed', 'Disturbed', 'No intacta', 'No intacta', false, '2025-09-10 19:18:23.036+00', '2025-09-10 19:18:23.036+00');
INSERT INTO public."refSoilSamplingTools" VALUES (1, 'Pala', 'Pala', 'Pala', 'Pala', 'Shovel', 'Shovel', 'Pala', 'Pala', false, '2025-09-10 19:18:23.032+00', '2025-09-10 19:18:23.032+00');
INSERT INTO public."refSoilSamplingTools" VALUES (2, 'Calador', 'Calador', 'Calador', 'Calador', 'Probe', 'Probe', 'Calador', 'Calador', false, '2025-09-10 19:18:23.032+00', '2025-09-10 19:18:23.032+00');
INSERT INTO public."refSoilTexture" VALUES (0, 'a', 'Arcillosa', 'a', 'Arcillosa', '', '', '2024-06-03 20:55:40.437+00', '2024-06-03 20:55:40.437+00', false);
INSERT INTO public."refSoilTexture" VALUES (1, 'a.A', 'arcillo arenosa', 'a.A', 'arcillo arenosa', '', '', '2024-06-03 20:55:40.437+00', '2024-06-03 20:55:40.437+00', false);
INSERT INTO public."refSoilTexture" VALUES (2, 'a.li', 'arcillo limosa', 'a.li', 'arcillo limosa', '', '', '2024-06-03 20:55:40.437+00', '2024-06-03 20:55:40.437+00', false);
INSERT INTO public."refSoilTexture" VALUES (3, 'A', 'Arenosa', 'A', 'Arenosa', '', '', '2024-06-03 20:55:40.437+00', '2024-06-03 20:55:40.437+00', false);
INSERT INTO public."refSoilTexture" VALUES (4, 'A.fr', 'Arenosa franca', 'A.fr', 'Arenosa franca', '', '', '2024-06-03 20:55:40.437+00', '2024-06-03 20:55:40.437+00', false);
INSERT INTO public."refSoilTexture" VALUES (5, 'fr', 'Franca', 'fr', 'Franca', '', '', '2024-06-03 20:55:40.437+00', '2024-06-03 20:55:40.437+00', false);
INSERT INTO public."refSoilTexture" VALUES (6, 'fr.a', 'Franco arcillosa', 'fr.a', 'Franco arcillosa', '', '', '2024-06-03 20:55:40.437+00', '2024-06-03 20:55:40.437+00', false);
INSERT INTO public."refSoilTexture" VALUES (7, 'fr.a.A', 'Franco arcillo arenosa', 'fr.a.A', 'Franco arcillo arenosa', '', '', '2024-06-03 20:55:40.437+00', '2024-06-03 20:55:40.437+00', false);
INSERT INTO public."refSoilTexture" VALUES (8, 'fr.a.li', 'Franco arcillo limosa', 'fr.a.li', 'Franco arcillo limosa', '', '', '2024-06-03 20:55:40.437+00', '2024-06-03 20:55:40.437+00', false);
INSERT INTO public."refSoilTexture" VALUES (9, 'fr.A', 'Franco arenosa', 'fr.A', 'Franco arenosa', '', '', '2024-06-03 20:55:40.437+00', '2024-06-03 20:55:40.437+00', false);
INSERT INTO public."refSoilTexture" VALUES (10, 'fr.li', 'Franco limosa', 'fr.A', 'Franco limosa', '', '', '2024-06-03 20:55:40.437+00', '2024-06-03 20:55:40.437+00', false);
INSERT INTO public."refSoilTexture" VALUES (11, 'li', 'Limosa', 'fr.A', 'Limosa', '', '', '2024-06-03 20:55:40.437+00', '2024-06-03 20:55:40.437+00', false);
INSERT INTO public."refStructureGrade" VALUES (0, 'de', 'Débil', 'de', 'Débil', 'we', 'Weak', '2024-06-03 20:55:40.443+00', '2024-06-03 20:55:40.443+00', false);
INSERT INTO public."refStructureGrade" VALUES (1, 'mo', 'Moderada', 'mo', 'Moderada', 'mo', 'Moderate', '2024-06-03 20:55:40.443+00', '2024-06-03 20:55:40.443+00', false);
INSERT INTO public."refStructureGrade" VALUES (2, 'fu', 'Fuerte', 'fu', 'Fuerte', 'st', 'Strong', '2024-06-03 20:55:40.443+00', '2024-06-03 20:55:40.443+00', false);
INSERT INTO public."refStructureSize" VALUES (0, 'mf', 'Muy fina', 'mf', 'Muy fina', '', '', '2024-06-03 20:55:40.448+00', '2024-06-03 20:55:40.448+00', false);
INSERT INTO public."refStructureSize" VALUES (1, 'me', 'Mediana', 'me', 'Mediana', '', '', '2024-06-03 20:55:40.448+00', '2024-06-03 20:55:40.448+00', false);
INSERT INTO public."refStructureSize" VALUES (2, 'gr', 'Gruesa', 'gr', 'Gruesa', '', '', '2024-06-03 20:55:40.448+00', '2024-06-03 20:55:40.448+00', false);
INSERT INTO public."refStructureSize" VALUES (3, 'mg', 'Muy gruesa', 'mg', 'Muy gruesa', '', '', '2024-06-03 20:55:40.448+00', '2024-06-03 20:55:40.448+00', false);
INSERT INTO public."refStructureType" VALUES (0, 'mig', 'Migajosa', 'mig', 'Migajosa', '', '', '2024-06-03 20:55:40.451+00', '2024-06-03 20:55:40.451+00', false);
INSERT INTO public."refStructureType" VALUES (1, 'gran', 'Granular', 'gran', 'Granular', '', '', '2024-06-03 20:55:40.451+00', '2024-06-03 20:55:40.451+00', false);
INSERT INTO public."refStructureType" VALUES (2, 'ba', 'Bloques angulares', 'ba', 'Bloques angulares', '', '', '2024-06-03 20:55:40.451+00', '2024-06-03 20:55:40.451+00', false);
INSERT INTO public."refStructureType" VALUES (3, 'bs', 'Bloques subangulares', 'bs', 'Bloques subangulares', '', '', '2024-06-03 20:55:40.451+00', '2024-06-03 20:55:40.451+00', false);
INSERT INTO public."refStructureType" VALUES (4, 'prs', 'Prismática', 'prs.', 'Prismática', '', '', '2024-06-03 20:55:40.451+00', '2024-06-03 20:55:40.451+00', false);
INSERT INTO public."refStructureType" VALUES (5, 'col', 'Columnar', 'col', 'Columnar', '', '', '2024-06-03 20:55:40.451+00', '2024-06-03 20:55:40.451+00', false);
INSERT INTO public."refStructureType" VALUES (6, 'lam', 'Laminar', 'lam', 'Laminar', '', '', '2024-06-03 20:55:40.451+00', '2024-06-03 20:55:40.451+00', false);
INSERT INTO public."refStructureType" VALUES (7, 'suel', 'De grano suelto', 'suel', 'De grano suelto', '', '', '2024-06-03 20:55:40.451+00', '2024-06-03 20:55:40.451+00', false);
INSERT INTO public."refStructureType" VALUES (8, 'masi', 'Masiva (sin estructura)', 'masi', 'Masiva (sin estructura)', '', '', '2024-06-03 20:55:40.451+00', '2024-06-03 20:55:40.451+00', false);
INSERT INTO public."refTaskStatus" VALUES (0, 'Pendiente', '2024-06-03 20:55:40.26+00', '2024-06-03 20:55:40.26+00', false);
INSERT INTO public."refTaskStatus" VALUES (1, 'En curso', '2024-06-03 20:55:40.26+00', '2024-06-03 20:55:40.26+00', false);
INSERT INTO public."refTaskStatus" VALUES (2, 'Finalizado', '2024-06-03 20:55:40.26+00', '2024-06-03 20:55:40.26+00', false);
INSERT INTO public."refTaskStatus" VALUES (3, 'Cancelado', '2024-06-03 20:55:40.26+00', '2024-06-03 20:55:40.26+00', false);
INSERT INTO public."refTaskStatus" VALUES (4, 'Omitido', '2024-06-03 20:55:40.26+00', '2024-06-03 20:55:40.26+00', false);
INSERT INTO public."refTillageType" VALUES (0, 'Rastra', 'Rastra', '', '2024-06-03 20:55:40.363+00', '2024-06-03 20:55:40.363+00', false);
INSERT INTO public."refTillageType" VALUES (1, 'Disco', 'Disco', '', '2024-06-03 20:55:40.363+00', '2024-06-03 20:55:40.363+00', false);
INSERT INTO public."refTillageType" VALUES (2, 'Cincel', 'Cincel', '', '2024-06-03 20:55:40.363+00', '2024-06-03 20:55:40.363+00', false);
INSERT INTO public."refTillageType" VALUES (3, 'Rolo', 'Rolo', '', '2024-06-03 20:55:40.363+00', '2024-06-03 20:55:40.363+00', false);
INSERT INTO public."refTillageType" VALUES (4, 'Escardillo', 'Escardillo', 'Hoe', '2024-07-25 19:39:48.98+00', '2024-07-25 19:39:48.98+00', false);
INSERT INTO public."refTillageType" VALUES (5, 'Subsolador', 'Subsolador', 'Subsoiler', '2024-07-25 19:39:48.98+00', '2024-07-25 19:39:48.98+00', false);
INSERT INTO public."refUnits" VALUES (0, 'kg', 'kg', 'kg', '2024-08-13 15:11:54.197+00', '2024-08-13 15:11:54.197+00');
INSERT INTO public."refUnits" VALUES (1, 't', 't', 't', '2024-08-13 15:11:54.197+00', '2024-08-13 15:11:54.197+00');
INSERT INTO public."refUnits" VALUES (2, 'm', 'm', 'm', '2024-08-13 15:11:54.197+00', '2024-08-13 15:11:54.197+00');
INSERT INTO public."refUnits" VALUES (3, 'm2', 'm2', 'm2', '2024-08-13 15:11:54.197+00', '2024-08-13 15:11:54.197+00');
INSERT INTO public."refUnits" VALUES (4, 'ha', 'ha', 'ha', '2024-08-13 15:11:54.197+00', '2024-08-13 15:11:54.197+00');
INSERT INTO public."refUnits" VALUES (5, 'animales', 'animales', 'animals', '2024-08-13 15:11:54.197+00', '2024-08-13 15:11:54.197+00');
INSERT INTO public."refUnits" VALUES (6, 'equivalente oveja', 'equivalente oveja', 'sheep equivalent', '2024-08-13 15:11:54.197+00', '2024-08-13 15:11:54.197+00');
INSERT INTO public."refUnits" VALUES (7, 'animales/ha', 'animales/ha', 'animals/ha', '2024-08-13 15:11:54.197+00', '2024-08-13 15:11:54.197+00');
INSERT INTO public."refUnits" VALUES (8, 'kg/año', 'kg/año', 'kg/year', '2024-08-13 15:11:54.197+00', '2024-08-13 15:11:54.197+00');
INSERT INTO public."refUnits" VALUES (10, 'eventos', 'eventos', 'events', '2024-08-13 15:11:54.197+00', '2024-08-13 15:11:54.197+00');
INSERT INTO public."refUnits" VALUES (11, 'pasturas', 'pasturas', 'pastures', '2024-08-13 15:11:54.197+00', '2024-08-13 15:11:54.197+00');
INSERT INTO public."refUnits" VALUES (12, 'tCO2/año', 'tCO2/año', 'tCO2/year', '2024-08-13 15:11:54.197+00', '2024-08-13 15:11:54.197+00');
INSERT INTO public."refUserRole" VALUES (0, 'Field Technician', '2024-06-03 20:55:40.459+00', '2024-06-03 20:55:40.459+00', false);
INSERT INTO public."refUserRole" VALUES (1, 'Auditor', '2024-06-03 20:55:40.459+00', '2024-06-03 20:55:40.459+00', false);
INSERT INTO public."refUserRole" VALUES (2, 'Admin', '2024-06-03 20:55:40.459+00', '2024-06-03 20:55:40.459+00', false);
-- relInstanceMonitoringPeriod inserts commented out - reference carbonInstances which has no seed data
-- INSERT INTO public."relInstanceMonitoringPeriod" VALUES ('b9163b22-50b4-457f-ab1b-00ff1f6d4027', '57f7321f-69c8-46b1-9072-c71f25f5fbe0', '18b8c3ee-a463-4bfd-8711-732c11ae81e6', false, 'ruuts-api', NULL, '2025-04-04 18:43:32.589+00', '2025-04-04 18:43:32.589+00');
-- INSERT INTO public."relInstanceMonitoringPeriod" VALUES ('63d0e7b0-9be9-4a21-9f98-0d2278769681', 'b56fa009-9feb-4fc5-bec6-ee09603d20fc', '18b8c3ee-a463-4bfd-8711-732c11ae81e6', false, 'ruuts-api', NULL, '2025-04-04 18:43:32.589+00', '2025-04-04 18:43:32.589+00');
-- INSERT INTO public."relInstanceMonitoringPeriod" VALUES ('11ee4ecc-322e-422a-ae48-8b6cc7376a91', '48b27017-1bf1-4c22-905e-224e48ae13a4', '18b8c3ee-a463-4bfd-8711-732c11ae81e6', false, 'ruuts-api-migration-20251027', 'ruuts-api-migration-20251027', '2025-10-27 20:43:59.576856+00', '2025-10-27 20:43:59.576856+00');
-- INSERT INTO public."relInstanceMonitoringPeriod" VALUES ('8bbb5164-cd0e-4117-b063-76c78d577fb3', 'e4d10d4f-3649-4f56-8627-01af00b0019f', '18b8c3ee-a463-4bfd-8711-732c11ae81e6', false, 'ruuts-api-migration-20251027', 'ruuts-api-migration-20251027', '2025-10-27 20:43:59.576856+00', '2025-10-27 20:43:59.576856+00');
-- INSERT INTO public."relInstanceMonitoringPeriod" VALUES ('84832674-de59-479d-b355-a03d29ba18ad', 'fc4defd8-f558-46ef-bc87-f843b00344ea', '18b8c3ee-a463-4bfd-8711-732c11ae81e6', false, 'ruuts-api-migration-20251027', NULL, '2025-10-27 20:43:59.576856+00', '2025-10-28 18:40:18.616128+00');
-- INSERT INTO public."relInstanceMonitoringPeriod" VALUES ('542cc549-7353-44b7-9ada-dcc92f689af5', '830bf9ba-3623-4b77-80a9-a42b2ba85e55', '18b8c3ee-a463-4bfd-8711-732c11ae81e6', true, 'fsrodrig', 'fsrodrig', '2025-10-28 18:46:47.781502+00', '2025-10-28 18:49:14.838193+00');
INSERT INTO public."relSOCProtocols" VALUES (0, 'Grass 6.0', false, '2025-02-17 20:55:31.03+00', '2025-02-17 20:55:31.03+00');
INSERT INTO public."relSOCProtocols" VALUES (1, 'Anterior a Grass 6.0', false, '2025-06-05 18:28:51.101+00', '2025-06-05 18:28:51.101+00');
