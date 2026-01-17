--
-- PostgreSQL database dump
--

-- Dumped from database version 16.3 (Debian 16.3-1.pgdg120+1)
-- Dumped by pg_dump version 16.8 (Ubuntu 16.8-1.pgdg20.04+1)

-- Started on 2026-01-14 17:28:41 -03

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 5708 (class 1262 OID 5)
-- Name: postgres; Type: DATABASE; Schema: -; Owner: -
--

CREATE DATABASE postgres WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_US.utf8';


\connect postgres

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 5709 (class 0 OID 0)
-- Dependencies: 5708
-- Name: DATABASE postgres; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON DATABASE postgres IS 'default administrative connection database';


--
-- TOC entry 7 (class 2615 OID 2200)
-- Name: public; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA public;


--
-- TOC entry 5710 (class 0 OID 0)
-- Dependencies: 7
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS 'standard public schema';


--
-- TOC entry 761 (class 1255 OID 379606)
-- Name: check_refexclusionareatype_programids(); Type: FUNCTION; Schema: public; Owner: -
--

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


--
-- TOC entry 484 (class 1255 OID 18921)
-- Name: f_intersect_geometries(public.geometry, public.geometry); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.f_intersect_geometries(geom1 public.geometry, geom2 public.geometry) RETURNS json
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


--
-- TOC entry 802 (class 1255 OID 18922)
-- Name: f_union_geometries(public.geometry, public.geometry); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.f_union_geometries(geom1 public.geometry, geom2 public.geometry) RETURNS json
    LANGUAGE plpgsql
    AS $$
BEGIN
  -- Perform union operation and return result as GeoJSON
  RETURN ST_AsGeoJSON(ST_Union(ST_UnaryUnion(ST_makevalid(geom1)), ST_UnaryUnion(ST_makevalid(geom2)), 0.00000001), 4326);
END;
$$;


--
-- TOC entry 1176 (class 1255 OID 1346321)
-- Name: generate_random_points(uuid, public.geometry, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.generate_random_points(p_samplingareaid uuid, p_geometry public.geometry, p_n integer) RETURNS TABLE(id uuid, "samplingAreaId" uuid, "farmId" uuid, seed integer, "createdAt" timestamp with time zone, geometry public.geometry)
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


--
-- TOC entry 1129 (class 1255 OID 445140)
-- Name: st_intersectionarray(public.geometry[]); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.st_intersectionarray(geoms public.geometry[]) RETURNS public.geometry
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


--
-- TOC entry 1269 (class 1255 OID 1567534)
-- Name: trigger_auto_link_carbon_instance_monitoring_period(); Type: FUNCTION; Schema: public; Owner: -
--

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


--
-- TOC entry 1043 (class 1255 OID 1567536)
-- Name: trigger_sync_carbon_instance_deleted_status(); Type: FUNCTION; Schema: public; Owner: -
--

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


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 398 (class 1259 OID 830227)
-- Name: RelLaboratory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."RelLaboratory" (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- TOC entry 397 (class 1259 OID 830226)
-- Name: RelLaboratory_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."RelLaboratory_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5711 (class 0 OID 0)
-- Dependencies: 397
-- Name: RelLaboratory_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."RelLaboratory_id_seq" OWNED BY public."RelLaboratory".id;


--
-- TOC entry 223 (class 1259 OID 16384)
-- Name: SequelizeMeta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."SequelizeMeta" (
    name character varying(255) NOT NULL
);


--
-- TOC entry 235 (class 1259 OID 17696)
-- Name: carbonInstances; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."carbonInstances" (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(255) NOT NULL,
    "farmId" uuid NOT NULL,
    "initDate" timestamp with time zone NOT NULL,
    "instanceYear" character varying(255) NOT NULL,
    "samplingAreaId" uuid NOT NULL,
    paddocks json,
    "baselinePaddocks" json,
    geometry public.geometry,
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


--
-- TOC entry 241 (class 1259 OID 17750)
-- Name: dataCollectionStatement; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."dataCollectionStatement" (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
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


--
-- TOC entry 242 (class 1259 OID 17777)
-- Name: dataCollectionStatementHistory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."dataCollectionStatementHistory" (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
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


--
-- TOC entry 243 (class 1259 OID 17807)
-- Name: deals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deals (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
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


--
-- TOC entry 244 (class 1259 OID 17828)
-- Name: deforestedAreas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."deforestedAreas" (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(255),
    "farmId" uuid NOT NULL,
    geometry public.geometry,
    "featureCollection" json,
    "totalHectares" double precision,
    color character varying(255),
    "createdBy" character varying(255),
    "updatedBy" character varying(255),
    "isDeleted" boolean DEFAULT false,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- TOC entry 385 (class 1259 OID 158360)
-- Name: discardedEntities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."discardedEntities" (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "farmId" uuid NOT NULL,
    "entityTypeId" integer NOT NULL,
    "entityId" uuid NOT NULL,
    "reasonId" integer NOT NULL,
    geometry public.geometry,
    "totalHectares" double precision,
    "isDeleted" boolean DEFAULT false,
    "updatedBy" character varying(255),
    "updatedAt" timestamp with time zone,
    "createdBy" character varying(255),
    "createdAt" timestamp with time zone
);


--
-- TOC entry 249 (class 1259 OID 17862)
-- Name: documents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.documents (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
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


--
-- TOC entry 251 (class 1259 OID 17895)
-- Name: exclusionAreaHistory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."exclusionAreaHistory" (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "exclusionAreaId" uuid NOT NULL,
    name character varying(255) NOT NULL,
    "otherName" character varying(255),
    "farmId" uuid NOT NULL,
    geometry public.geometry,
    "uncroppedGeometry" public.geometry,
    "exclusionAreaTypeId" integer NOT NULL,
    "totalHectares" double precision,
    color character varying(255),
    "createdBy" character varying(255),
    "updatedBy" character varying(255),
    "isDeleted" boolean DEFAULT false,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- TOC entry 250 (class 1259 OID 17881)
-- Name: exclusionAreas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."exclusionAreas" (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(255) NOT NULL,
    "otherName" character varying(255),
    "farmId" uuid NOT NULL,
    geometry public.geometry,
    "uncroppedGeometry" public.geometry,
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


--
-- TOC entry 253 (class 1259 OID 17938)
-- Name: farmOwners; Type: TABLE; Schema: public; Owner: -
--

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


--
-- TOC entry 240 (class 1259 OID 17736)
-- Name: farmSubdivisions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."farmSubdivisions" (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
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


--
-- TOC entry 232 (class 1259 OID 17646)
-- Name: farms; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.farms (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
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
    geometry public.geometry,
    "uncroppedGeometry" public.geometry,
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


--
-- TOC entry 252 (class 1259 OID 17914)
-- Name: farmsHistory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."farmsHistory" (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
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
    geometry public.geometry,
    "uncroppedGeometry" public.geometry,
    color character varying(255),
    "phoneNumber" character varying(255),
    email character varying(255),
    "createdBy" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "ecoregionId" integer
);


--
-- TOC entry 258 (class 1259 OID 17990)
-- Name: findingComments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."findingComments" (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    message character varying(255),
    "findingId" uuid NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "createdBy" character varying(255),
    "updatedBy" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- TOC entry 259 (class 1259 OID 18004)
-- Name: findingHistory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."findingHistory" (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
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


--
-- TOC entry 257 (class 1259 OID 17970)
-- Name: findings; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.findings (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
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


--
-- TOC entry 260 (class 1259 OID 18023)
-- Name: forestAreas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."forestAreas" (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(255),
    "farmId" uuid NOT NULL,
    geometry public.geometry,
    "featureCollection" json,
    "totalHectares" double precision,
    color character varying(255),
    "createdBy" character varying(255),
    "updatedBy" character varying(255),
    "isDeleted" boolean DEFAULT false,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- TOC entry 261 (class 1259 OID 18039)
-- Name: formDefinitions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."formDefinitions" (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
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


--
-- TOC entry 230 (class 1259 OID 17620)
-- Name: hubs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.hubs (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
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


--
-- TOC entry 269 (class 1259 OID 18124)
-- Name: monitoringActivity; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."monitoringActivity" (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
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
    _rev uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "isDeleted" boolean DEFAULT false,
    "updatedBy" character varying(255),
    "updatedAt" timestamp with time zone,
    "createdBy" character varying(255),
    "createdAt" timestamp with time zone
);


--
-- TOC entry 264 (class 1259 OID 18058)
-- Name: monitoringEvents; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."monitoringEvents" (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
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
    _rev uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "createdBy" character varying(255),
    "updatedBy" character varying(255),
    "isDeleted" boolean DEFAULT false,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isBackdatedEvent" boolean
);


--
-- TOC entry 270 (class 1259 OID 18165)
-- Name: monitoringPictures; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."monitoringPictures" (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(255) NOT NULL,
    key character varying(255) NOT NULL,
    "monitoringEventId" uuid,
    link character varying(255),
    entity character varying(255) NOT NULL,
    "entityId" uuid NOT NULL,
    "syncedToS3" boolean DEFAULT false,
    _rev uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "isDeleted" boolean DEFAULT false,
    "updatedBy" character varying(255),
    "updatedAt" timestamp with time zone,
    "createdBy" character varying(255),
    "createdAt" timestamp with time zone
);


--
-- TOC entry 273 (class 1259 OID 18190)
-- Name: monitoringReports; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."monitoringReports" (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
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


--
-- TOC entry 401 (class 1259 OID 830242)
-- Name: monitoringSOCSamples; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."monitoringSOCSamples" (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
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


--
-- TOC entry 402 (class 1259 OID 830271)
-- Name: monitoringSOCSamplingAreaSamples; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."monitoringSOCSamplingAreaSamples" (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
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


--
-- TOC entry 405 (class 1259 OID 830305)
-- Name: monitoringSOCSitesSamples; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."monitoringSOCSitesSamples" (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
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


--
-- TOC entry 267 (class 1259 OID 18090)
-- Name: monitoringSites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."monitoringSites" (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
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
    _rev uuid DEFAULT public.uuid_generate_v4() NOT NULL,
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


--
-- TOC entry 386 (class 1259 OID 207515)
-- Name: monitoringSitesHistory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."monitoringSitesHistory" (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "monitoringSiteId" uuid DEFAULT public.uuid_generate_v4() NOT NULL,
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
    _rev uuid DEFAULT public.uuid_generate_v4(),
    "isValidationSite" boolean DEFAULT false,
    "updatedBy" character varying(255),
    "updatedAt" timestamp with time zone,
    "createdBy" character varying(255),
    "createdAt" timestamp with time zone,
    "deviceLocationData" json,
    "locationMovedReasonId" integer
);


--
-- TOC entry 274 (class 1259 OID 18212)
-- Name: monitoringTasks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."monitoringTasks" (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
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
    _rev uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "isDeleted" boolean DEFAULT false,
    "updatedBy" character varying(255),
    "updatedAt" timestamp with time zone,
    "createdBy" character varying(255),
    "createdAt" timestamp with time zone,
    "deviceLocationData" json
);


--
-- TOC entry 387 (class 1259 OID 207543)
-- Name: monitoringTasksHistory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."monitoringTasksHistory" (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "monitoringTaskId" uuid DEFAULT public.uuid_generate_v4() NOT NULL,
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
    _rev uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "isDeleted" boolean DEFAULT false,
    "deviceLocationData" json,
    "updatedBy" character varying(255),
    "updatedAt" timestamp with time zone,
    "createdBy" character varying(255),
    "createdAt" timestamp with time zone
);


--
-- TOC entry 266 (class 1259 OID 18081)
-- Name: monitoringWorkflows; Type: TABLE; Schema: public; Owner: -
--

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


--
-- TOC entry 265 (class 1259 OID 18080)
-- Name: monitoringWorkflows_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."monitoringWorkflows_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5712 (class 0 OID 0)
-- Dependencies: 265
-- Name: monitoringWorkflows_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."monitoringWorkflows_id_seq" OWNED BY public."monitoringWorkflows".id;


--
-- TOC entry 275 (class 1259 OID 18234)
-- Name: otherPolygons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."otherPolygons" (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(255) NOT NULL,
    "farmId" uuid NOT NULL,
    geometry public.geometry,
    "totalHectares" double precision,
    color character varying(255),
    "createdBy" character varying(255),
    "updatedBy" character varying(255),
    "isDeleted" boolean DEFAULT false,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- TOC entry 276 (class 1259 OID 18248)
-- Name: otherSites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."otherSites" (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(255) NOT NULL,
    allocated boolean DEFAULT false,
    "farmId" uuid NOT NULL,
    "plannedLocation" json NOT NULL,
    "actualLocation" json,
    color character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- TOC entry 277 (class 1259 OID 18262)
-- Name: paddocks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.paddocks (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(255) NOT NULL,
    "farmId" uuid NOT NULL,
    "totalHectares" double precision,
    "isDeleted" boolean DEFAULT false NOT NULL,
    geometry public.geometry,
    "uncroppedGeometry" public.geometry,
    color character varying(255),
    "createdBy" character varying(255),
    "updatedBy" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isInProject" boolean
);


--
-- TOC entry 278 (class 1259 OID 18276)
-- Name: paddocksHistory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."paddocksHistory" (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "paddockId" uuid NOT NULL,
    name character varying(255) NOT NULL,
    "farmId" uuid NOT NULL,
    "totalHectares" double precision,
    "isDeleted" boolean DEFAULT false NOT NULL,
    geometry public.geometry,
    "uncroppedGeometry" public.geometry,
    color character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- TOC entry 279 (class 1259 OID 18295)
-- Name: programConfig; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."programConfig" (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
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


--
-- TOC entry 231 (class 1259 OID 17630)
-- Name: programMonitoringPeriods; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."programMonitoringPeriods" (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
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


--
-- TOC entry 229 (class 1259 OID 17613)
-- Name: programs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.programs (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    version character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);


--
-- TOC entry 268 (class 1259 OID 18112)
-- Name: refActivityLayouts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."refActivityLayouts" (
    id integer NOT NULL,
    "monitoringWorkflowId" integer NOT NULL,
    name character varying(255) NOT NULL,
    grid json NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);


--
-- TOC entry 281 (class 1259 OID 18311)
-- Name: refAmmendmendType; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."refAmmendmendType" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);


--
-- TOC entry 280 (class 1259 OID 18310)
-- Name: refAmmendmendType_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refAmmendmendType_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5713 (class 0 OID 0)
-- Dependencies: 280
-- Name: refAmmendmendType_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refAmmendmendType_id_seq" OWNED BY public."refAmmendmendType".id;


--
-- TOC entry 283 (class 1259 OID 18320)
-- Name: refBovineCattle; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."refBovineCattle" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);


--
-- TOC entry 282 (class 1259 OID 18319)
-- Name: refBovineCattle_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refBovineCattle_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5714 (class 0 OID 0)
-- Dependencies: 282
-- Name: refBovineCattle_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refBovineCattle_id_seq" OWNED BY public."refBovineCattle".id;


--
-- TOC entry 285 (class 1259 OID 18329)
-- Name: refBubalineCattle; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."refBubalineCattle" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);


--
-- TOC entry 284 (class 1259 OID 18328)
-- Name: refBubalineCattle_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refBubalineCattle_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5715 (class 0 OID 0)
-- Dependencies: 284
-- Name: refBubalineCattle_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refBubalineCattle_id_seq" OWNED BY public."refBubalineCattle".id;


--
-- TOC entry 287 (class 1259 OID 18338)
-- Name: refCamelidCattle; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."refCamelidCattle" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);


--
-- TOC entry 286 (class 1259 OID 18337)
-- Name: refCamelidCattle_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refCamelidCattle_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5716 (class 0 OID 0)
-- Dependencies: 286
-- Name: refCamelidCattle_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refCamelidCattle_id_seq" OWNED BY public."refCamelidCattle".id;


--
-- TOC entry 289 (class 1259 OID 18347)
-- Name: refCaprineCattle; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."refCaprineCattle" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);


--
-- TOC entry 288 (class 1259 OID 18346)
-- Name: refCaprineCattle_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refCaprineCattle_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5717 (class 0 OID 0)
-- Dependencies: 288
-- Name: refCaprineCattle_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refCaprineCattle_id_seq" OWNED BY public."refCaprineCattle".id;


--
-- TOC entry 291 (class 1259 OID 18356)
-- Name: refCattleClass; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."refCattleClass" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);


--
-- TOC entry 290 (class 1259 OID 18355)
-- Name: refCattleClass_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refCattleClass_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5718 (class 0 OID 0)
-- Dependencies: 290
-- Name: refCattleClass_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refCattleClass_id_seq" OWNED BY public."refCattleClass".id;


--
-- TOC entry 371 (class 1259 OID 133776)
-- Name: refCattleEmissionsFactors; Type: TABLE; Schema: public; Owner: -
--

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


--
-- TOC entry 370 (class 1259 OID 133775)
-- Name: refCattleEmissionsFactors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refCattleEmissionsFactors_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5719 (class 0 OID 0)
-- Dependencies: 370
-- Name: refCattleEmissionsFactors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refCattleEmissionsFactors_id_seq" OWNED BY public."refCattleEmissionsFactors".id;


--
-- TOC entry 373 (class 1259 OID 133784)
-- Name: refCattleEquivalences; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."refCattleEquivalences" (
    id integer NOT NULL,
    "cattleSubClassId" integer NOT NULL,
    "equivalentCattleSubClassId" integer NOT NULL,
    value double precision NOT NULL,
    "isDeleted" boolean NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- TOC entry 372 (class 1259 OID 133783)
-- Name: refCattleEquivalences_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refCattleEquivalences_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5720 (class 0 OID 0)
-- Dependencies: 372
-- Name: refCattleEquivalences_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refCattleEquivalences_id_seq" OWNED BY public."refCattleEquivalences".id;


--
-- TOC entry 293 (class 1259 OID 18365)
-- Name: refCattleSubClass; Type: TABLE; Schema: public; Owner: -
--

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


--
-- TOC entry 292 (class 1259 OID 18364)
-- Name: refCattleSubClass_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refCattleSubClass_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5721 (class 0 OID 0)
-- Dependencies: 292
-- Name: refCattleSubClass_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refCattleSubClass_id_seq" OWNED BY public."refCattleSubClass".id;


--
-- TOC entry 295 (class 1259 OID 18379)
-- Name: refCattleType; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."refCattleType" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);


--
-- TOC entry 294 (class 1259 OID 18378)
-- Name: refCattleType_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refCattleType_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5722 (class 0 OID 0)
-- Dependencies: 294
-- Name: refCattleType_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refCattleType_id_seq" OWNED BY public."refCattleType".id;


--
-- TOC entry 297 (class 1259 OID 18388)
-- Name: refCervidCattle; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."refCervidCattle" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);


--
-- TOC entry 296 (class 1259 OID 18387)
-- Name: refCervidCattle_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refCervidCattle_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5723 (class 0 OID 0)
-- Dependencies: 296
-- Name: refCervidCattle_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refCervidCattle_id_seq" OWNED BY public."refCervidCattle".id;


--
-- TOC entry 394 (class 1259 OID 690912)
-- Name: refCountries; Type: TABLE; Schema: public; Owner: -
--

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


--
-- TOC entry 299 (class 1259 OID 18397)
-- Name: refCropType; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."refCropType" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);


--
-- TOC entry 298 (class 1259 OID 18396)
-- Name: refCropType_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refCropType_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5724 (class 0 OID 0)
-- Dependencies: 298
-- Name: refCropType_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refCropType_id_seq" OWNED BY public."refCropType".id;


--
-- TOC entry 404 (class 1259 OID 830296)
-- Name: refDAPMethods; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."refDAPMethods" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "isDeleted" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- TOC entry 403 (class 1259 OID 830295)
-- Name: refDAPMethods_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refDAPMethods_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5725 (class 0 OID 0)
-- Dependencies: 403
-- Name: refDAPMethods_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refDAPMethods_id_seq" OWNED BY public."refDAPMethods".id;


--
-- TOC entry 237 (class 1259 OID 17721)
-- Name: refDataCollectionStatementStatus; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."refDataCollectionStatementStatus" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);


--
-- TOC entry 236 (class 1259 OID 17720)
-- Name: refDataCollectionStatementStatus_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refDataCollectionStatementStatus_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5726 (class 0 OID 0)
-- Dependencies: 236
-- Name: refDataCollectionStatementStatus_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refDataCollectionStatementStatus_id_seq" OWNED BY public."refDataCollectionStatementStatus".id;


--
-- TOC entry 301 (class 1259 OID 18406)
-- Name: refDegreeDegradationSoil; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."refDegreeDegradationSoil" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);


--
-- TOC entry 300 (class 1259 OID 18405)
-- Name: refDegreeDegradationSoil_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refDegreeDegradationSoil_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5727 (class 0 OID 0)
-- Dependencies: 300
-- Name: refDegreeDegradationSoil_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refDegreeDegradationSoil_id_seq" OWNED BY public."refDegreeDegradationSoil".id;


--
-- TOC entry 246 (class 1259 OID 17845)
-- Name: refDocumentType; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."refDocumentType" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);


--
-- TOC entry 245 (class 1259 OID 17844)
-- Name: refDocumentType_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refDocumentType_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5728 (class 0 OID 0)
-- Dependencies: 245
-- Name: refDocumentType_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refDocumentType_id_seq" OWNED BY public."refDocumentType".id;


--
-- TOC entry 384 (class 1259 OID 158352)
-- Name: refEntityDiscardReason; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."refEntityDiscardReason" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- TOC entry 383 (class 1259 OID 158351)
-- Name: refEntityDiscardReason_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refEntityDiscardReason_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5729 (class 0 OID 0)
-- Dependencies: 383
-- Name: refEntityDiscardReason_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refEntityDiscardReason_id_seq" OWNED BY public."refEntityDiscardReason".id;


--
-- TOC entry 248 (class 1259 OID 17854)
-- Name: refEntityType; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."refEntityType" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);


--
-- TOC entry 247 (class 1259 OID 17853)
-- Name: refEntityType_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refEntityType_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5730 (class 0 OID 0)
-- Dependencies: 247
-- Name: refEntityType_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refEntityType_id_seq" OWNED BY public."refEntityType".id;


--
-- TOC entry 303 (class 1259 OID 18415)
-- Name: refEquineCattle; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."refEquineCattle" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);


--
-- TOC entry 302 (class 1259 OID 18414)
-- Name: refEquineCattle_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refEquineCattle_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5731 (class 0 OID 0)
-- Dependencies: 302
-- Name: refEquineCattle_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refEquineCattle_id_seq" OWNED BY public."refEquineCattle".id;


--
-- TOC entry 305 (class 1259 OID 18424)
-- Name: refExclusionAreaType; Type: TABLE; Schema: public; Owner: -
--

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


--
-- TOC entry 304 (class 1259 OID 18423)
-- Name: refExclusionAreaType_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refExclusionAreaType_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5732 (class 0 OID 0)
-- Dependencies: 304
-- Name: refExclusionAreaType_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refExclusionAreaType_id_seq" OWNED BY public."refExclusionAreaType".id;


--
-- TOC entry 393 (class 1259 OID 559949)
-- Name: refFieldRelocationMethod; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."refFieldRelocationMethod" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255) NOT NULL,
    "en_US" character varying(255) NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- TOC entry 392 (class 1259 OID 559948)
-- Name: refFieldRelocationMethod_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refFieldRelocationMethod_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5733 (class 0 OID 0)
-- Dependencies: 392
-- Name: refFieldRelocationMethod_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refFieldRelocationMethod_id_seq" OWNED BY public."refFieldRelocationMethod".id;


--
-- TOC entry 307 (class 1259 OID 18433)
-- Name: refFieldUsage; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."refFieldUsage" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);


--
-- TOC entry 306 (class 1259 OID 18432)
-- Name: refFieldUsage_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refFieldUsage_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5734 (class 0 OID 0)
-- Dependencies: 306
-- Name: refFieldUsage_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refFieldUsage_id_seq" OWNED BY public."refFieldUsage".id;


--
-- TOC entry 256 (class 1259 OID 17962)
-- Name: refFindingType; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."refFindingType" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);


--
-- TOC entry 255 (class 1259 OID 17961)
-- Name: refFindingType_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refFindingType_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5735 (class 0 OID 0)
-- Dependencies: 255
-- Name: refFindingType_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refFindingType_id_seq" OWNED BY public."refFindingType".id;


--
-- TOC entry 309 (class 1259 OID 18442)
-- Name: refForageSource; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."refForageSource" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);


--
-- TOC entry 308 (class 1259 OID 18441)
-- Name: refForageSource_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refForageSource_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5736 (class 0 OID 0)
-- Dependencies: 308
-- Name: refForageSource_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refForageSource_id_seq" OWNED BY public."refForageSource".id;


--
-- TOC entry 411 (class 1259 OID 1149697)
-- Name: refForageUseIntensity; Type: TABLE; Schema: public; Owner: -
--

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


--
-- TOC entry 410 (class 1259 OID 1149696)
-- Name: refForageUseIntensity_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refForageUseIntensity_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5737 (class 0 OID 0)
-- Dependencies: 410
-- Name: refForageUseIntensity_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refForageUseIntensity_id_seq" OWNED BY public."refForageUseIntensity".id;


--
-- TOC entry 413 (class 1259 OID 1149707)
-- Name: refForageUsePattern; Type: TABLE; Schema: public; Owner: -
--

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


--
-- TOC entry 412 (class 1259 OID 1149706)
-- Name: refForageUsePattern_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refForageUsePattern_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5738 (class 0 OID 0)
-- Dependencies: 412
-- Name: refForageUsePattern_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refForageUsePattern_id_seq" OWNED BY public."refForageUsePattern".id;


--
-- TOC entry 375 (class 1259 OID 133801)
-- Name: refFuelEmissionsFactors; Type: TABLE; Schema: public; Owner: -
--

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


--
-- TOC entry 374 (class 1259 OID 133800)
-- Name: refFuelEmissionsFactors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refFuelEmissionsFactors_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5739 (class 0 OID 0)
-- Dependencies: 374
-- Name: refFuelEmissionsFactors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refFuelEmissionsFactors_id_seq" OWNED BY public."refFuelEmissionsFactors".id;


--
-- TOC entry 311 (class 1259 OID 18451)
-- Name: refFuelType; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."refFuelType" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);


--
-- TOC entry 310 (class 1259 OID 18450)
-- Name: refFuelType_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refFuelType_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5740 (class 0 OID 0)
-- Dependencies: 310
-- Name: refFuelType_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refFuelType_id_seq" OWNED BY public."refFuelType".id;


--
-- TOC entry 313 (class 1259 OID 18460)
-- Name: refGrazingIntensityTypes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."refGrazingIntensityTypes" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);


--
-- TOC entry 312 (class 1259 OID 18459)
-- Name: refGrazingIntensityTypes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refGrazingIntensityTypes_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5741 (class 0 OID 0)
-- Dependencies: 312
-- Name: refGrazingIntensityTypes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refGrazingIntensityTypes_id_seq" OWNED BY public."refGrazingIntensityTypes".id;


--
-- TOC entry 315 (class 1259 OID 18469)
-- Name: refGrazingPlanType; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."refGrazingPlanType" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);


--
-- TOC entry 314 (class 1259 OID 18468)
-- Name: refGrazingPlanType_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refGrazingPlanType_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5742 (class 0 OID 0)
-- Dependencies: 314
-- Name: refGrazingPlanType_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refGrazingPlanType_id_seq" OWNED BY public."refGrazingPlanType".id;


--
-- TOC entry 317 (class 1259 OID 18478)
-- Name: refGrazingType; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."refGrazingType" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);


--
-- TOC entry 316 (class 1259 OID 18477)
-- Name: refGrazingType_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refGrazingType_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5743 (class 0 OID 0)
-- Dependencies: 316
-- Name: refGrazingType_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refGrazingType_id_seq" OWNED BY public."refGrazingType".id;


--
-- TOC entry 377 (class 1259 OID 133815)
-- Name: refGreenHouseGasesGwp; Type: TABLE; Schema: public; Owner: -
--

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


--
-- TOC entry 376 (class 1259 OID 133814)
-- Name: refGreenHouseGasesGwp_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refGreenHouseGasesGwp_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5744 (class 0 OID 0)
-- Dependencies: 376
-- Name: refGreenHouseGasesGwp_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refGreenHouseGasesGwp_id_seq" OWNED BY public."refGreenHouseGasesGwp".id;


--
-- TOC entry 319 (class 1259 OID 18487)
-- Name: refHorizonCode; Type: TABLE; Schema: public; Owner: -
--

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


--
-- TOC entry 318 (class 1259 OID 18486)
-- Name: refHorizonCode_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refHorizonCode_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5745 (class 0 OID 0)
-- Dependencies: 318
-- Name: refHorizonCode_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refHorizonCode_id_seq" OWNED BY public."refHorizonCode".id;


--
-- TOC entry 234 (class 1259 OID 17689)
-- Name: refInstancesVerificationStatus; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."refInstancesVerificationStatus" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);


--
-- TOC entry 321 (class 1259 OID 18496)
-- Name: refIrrigationType; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."refIrrigationType" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);


--
-- TOC entry 320 (class 1259 OID 18495)
-- Name: refIrrigationType_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refIrrigationType_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5746 (class 0 OID 0)
-- Dependencies: 320
-- Name: refIrrigationType_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refIrrigationType_id_seq" OWNED BY public."refIrrigationType".id;


--
-- TOC entry 323 (class 1259 OID 18505)
-- Name: refLivestockRaisingTypes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."refLivestockRaisingTypes" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);


--
-- TOC entry 322 (class 1259 OID 18504)
-- Name: refLivestockRaisingTypes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refLivestockRaisingTypes_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5747 (class 0 OID 0)
-- Dependencies: 322
-- Name: refLivestockRaisingTypes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refLivestockRaisingTypes_id_seq" OWNED BY public."refLivestockRaisingTypes".id;


--
-- TOC entry 391 (class 1259 OID 559939)
-- Name: refLocationConfirmationType; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."refLocationConfirmationType" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255) NOT NULL,
    "en_US" character varying(255) NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- TOC entry 390 (class 1259 OID 559938)
-- Name: refLocationConfirmationType_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refLocationConfirmationType_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5748 (class 0 OID 0)
-- Dependencies: 390
-- Name: refLocationConfirmationType_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refLocationConfirmationType_id_seq" OWNED BY public."refLocationConfirmationType".id;


--
-- TOC entry 389 (class 1259 OID 559929)
-- Name: refLocationMovedReason; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."refLocationMovedReason" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255) NOT NULL,
    "en_US" character varying(255) NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- TOC entry 388 (class 1259 OID 559928)
-- Name: refLocationMovedReason_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refLocationMovedReason_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5749 (class 0 OID 0)
-- Dependencies: 388
-- Name: refLocationMovedReason_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refLocationMovedReason_id_seq" OWNED BY public."refLocationMovedReason".id;


--
-- TOC entry 369 (class 1259 OID 92725)
-- Name: refMetricStatus; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."refMetricStatus" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);


--
-- TOC entry 368 (class 1259 OID 92724)
-- Name: refMetricStatus_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refMetricStatus_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5750 (class 0 OID 0)
-- Dependencies: 368
-- Name: refMetricStatus_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refMetricStatus_id_seq" OWNED BY public."refMetricStatus".id;


--
-- TOC entry 325 (class 1259 OID 18514)
-- Name: refMineralFertilizerType; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."refMineralFertilizerType" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);


--
-- TOC entry 324 (class 1259 OID 18513)
-- Name: refMineralFertilizerType_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refMineralFertilizerType_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5751 (class 0 OID 0)
-- Dependencies: 324
-- Name: refMineralFertilizerType_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refMineralFertilizerType_id_seq" OWNED BY public."refMineralFertilizerType".id;


--
-- TOC entry 272 (class 1259 OID 18182)
-- Name: refMonitoringReportStatus; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."refMonitoringReportStatus" (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    color character varying(255) NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);


--
-- TOC entry 271 (class 1259 OID 18181)
-- Name: refMonitoringReportStatus_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refMonitoringReportStatus_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5752 (class 0 OID 0)
-- Dependencies: 271
-- Name: refMonitoringReportStatus_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refMonitoringReportStatus_id_seq" OWNED BY public."refMonitoringReportStatus".id;


--
-- TOC entry 327 (class 1259 OID 18523)
-- Name: refOrganicFertilizerType; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."refOrganicFertilizerType" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);


--
-- TOC entry 326 (class 1259 OID 18522)
-- Name: refOrganicFertilizerType_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refOrganicFertilizerType_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5753 (class 0 OID 0)
-- Dependencies: 326
-- Name: refOrganicFertilizerType_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refOrganicFertilizerType_id_seq" OWNED BY public."refOrganicFertilizerType".id;


--
-- TOC entry 329 (class 1259 OID 18532)
-- Name: refOvineCattle; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."refOvineCattle" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);


--
-- TOC entry 328 (class 1259 OID 18531)
-- Name: refOvineCattle_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refOvineCattle_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5754 (class 0 OID 0)
-- Dependencies: 328
-- Name: refOvineCattle_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refOvineCattle_id_seq" OWNED BY public."refOvineCattle".id;


--
-- TOC entry 331 (class 1259 OID 18541)
-- Name: refPasturesFamily; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."refPasturesFamily" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);


--
-- TOC entry 330 (class 1259 OID 18540)
-- Name: refPasturesFamily_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refPasturesFamily_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5755 (class 0 OID 0)
-- Dependencies: 330
-- Name: refPasturesFamily_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refPasturesFamily_id_seq" OWNED BY public."refPasturesFamily".id;


--
-- TOC entry 333 (class 1259 OID 18550)
-- Name: refPasturesGrowthTypes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."refPasturesGrowthTypes" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);


--
-- TOC entry 332 (class 1259 OID 18549)
-- Name: refPasturesGrowthTypes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refPasturesGrowthTypes_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5756 (class 0 OID 0)
-- Dependencies: 332
-- Name: refPasturesGrowthTypes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refPasturesGrowthTypes_id_seq" OWNED BY public."refPasturesGrowthTypes".id;


--
-- TOC entry 335 (class 1259 OID 18559)
-- Name: refPasturesTypes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."refPasturesTypes" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);


--
-- TOC entry 334 (class 1259 OID 18558)
-- Name: refPasturesTypes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refPasturesTypes_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5757 (class 0 OID 0)
-- Dependencies: 334
-- Name: refPasturesTypes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refPasturesTypes_id_seq" OWNED BY public."refPasturesTypes".id;


--
-- TOC entry 423 (class 1259 OID 1346305)
-- Name: refRandomizer; Type: TABLE; Schema: public; Owner: -
--

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


--
-- TOC entry 422 (class 1259 OID 1346304)
-- Name: refRandomizer_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refRandomizer_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5758 (class 0 OID 0)
-- Dependencies: 422
-- Name: refRandomizer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refRandomizer_id_seq" OWNED BY public."refRandomizer".id;


--
-- TOC entry 396 (class 1259 OID 830217)
-- Name: refSamplingNumbers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."refSamplingNumbers" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "isDeleted" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- TOC entry 395 (class 1259 OID 830216)
-- Name: refSamplingNumbers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refSamplingNumbers_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5759 (class 0 OID 0)
-- Dependencies: 395
-- Name: refSamplingNumbers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refSamplingNumbers_id_seq" OWNED BY public."refSamplingNumbers".id;


--
-- TOC entry 425 (class 1259 OID 1420521)
-- Name: refSoilSamplingDisturbance; Type: TABLE; Schema: public; Owner: -
--

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


--
-- TOC entry 424 (class 1259 OID 1420520)
-- Name: refSoilSamplingDisturbance_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refSoilSamplingDisturbance_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5760 (class 0 OID 0)
-- Dependencies: 424
-- Name: refSoilSamplingDisturbance_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refSoilSamplingDisturbance_id_seq" OWNED BY public."refSoilSamplingDisturbance".id;


--
-- TOC entry 427 (class 1259 OID 1420531)
-- Name: refSoilSamplingTools; Type: TABLE; Schema: public; Owner: -
--

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


--
-- TOC entry 426 (class 1259 OID 1420530)
-- Name: refSoilSamplingTools_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refSoilSamplingTools_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5761 (class 0 OID 0)
-- Dependencies: 426
-- Name: refSoilSamplingTools_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refSoilSamplingTools_id_seq" OWNED BY public."refSoilSamplingTools".id;


--
-- TOC entry 337 (class 1259 OID 18568)
-- Name: refSoilTexture; Type: TABLE; Schema: public; Owner: -
--

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


--
-- TOC entry 336 (class 1259 OID 18567)
-- Name: refSoilTexture_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refSoilTexture_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5762 (class 0 OID 0)
-- Dependencies: 336
-- Name: refSoilTexture_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refSoilTexture_id_seq" OWNED BY public."refSoilTexture".id;


--
-- TOC entry 339 (class 1259 OID 18577)
-- Name: refStructureGrade; Type: TABLE; Schema: public; Owner: -
--

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


--
-- TOC entry 338 (class 1259 OID 18576)
-- Name: refStructureGrade_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refStructureGrade_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5763 (class 0 OID 0)
-- Dependencies: 338
-- Name: refStructureGrade_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refStructureGrade_id_seq" OWNED BY public."refStructureGrade".id;


--
-- TOC entry 341 (class 1259 OID 18586)
-- Name: refStructureSize; Type: TABLE; Schema: public; Owner: -
--

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


--
-- TOC entry 340 (class 1259 OID 18585)
-- Name: refStructureSize_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refStructureSize_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5764 (class 0 OID 0)
-- Dependencies: 340
-- Name: refStructureSize_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refStructureSize_id_seq" OWNED BY public."refStructureSize".id;


--
-- TOC entry 343 (class 1259 OID 18595)
-- Name: refStructureType; Type: TABLE; Schema: public; Owner: -
--

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


--
-- TOC entry 342 (class 1259 OID 18594)
-- Name: refStructureType_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refStructureType_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5765 (class 0 OID 0)
-- Dependencies: 342
-- Name: refStructureType_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refStructureType_id_seq" OWNED BY public."refStructureType".id;


--
-- TOC entry 263 (class 1259 OID 18052)
-- Name: refTaskStatus; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."refTaskStatus" (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);


--
-- TOC entry 262 (class 1259 OID 18051)
-- Name: refTaskStatus_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refTaskStatus_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5766 (class 0 OID 0)
-- Dependencies: 262
-- Name: refTaskStatus_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refTaskStatus_id_seq" OWNED BY public."refTaskStatus".id;


--
-- TOC entry 345 (class 1259 OID 18604)
-- Name: refTillageType; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."refTillageType" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);


--
-- TOC entry 344 (class 1259 OID 18603)
-- Name: refTillageType_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refTillageType_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5767 (class 0 OID 0)
-- Dependencies: 344
-- Name: refTillageType_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refTillageType_id_seq" OWNED BY public."refTillageType".id;


--
-- TOC entry 379 (class 1259 OID 133826)
-- Name: refUnits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."refUnits" (
    id integer NOT NULL,
    "es_AR" character varying(255) NOT NULL,
    "es_PY" character varying(255),
    "en_US" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- TOC entry 378 (class 1259 OID 133825)
-- Name: refUnits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refUnits_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5768 (class 0 OID 0)
-- Dependencies: 378
-- Name: refUnits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refUnits_id_seq" OWNED BY public."refUnits".id;


--
-- TOC entry 239 (class 1259 OID 17730)
-- Name: refUserRole; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."refUserRole" (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL
);


--
-- TOC entry 238 (class 1259 OID 17729)
-- Name: refUserRole_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."refUserRole_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5769 (class 0 OID 0)
-- Dependencies: 238
-- Name: refUserRole_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."refUserRole_id_seq" OWNED BY public."refUserRole".id;


--
-- TOC entry 346 (class 1259 OID 18612)
-- Name: relInstanceMonitoringPeriod; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."relInstanceMonitoringPeriod" (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "carbonInstanceId" uuid NOT NULL,
    "monitoringPeriodId" uuid NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "createdBy" character varying(255) NOT NULL,
    "updatedBy" character varying(255),
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- TOC entry 400 (class 1259 OID 830235)
-- Name: relSOCProtocols; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."relSOCProtocols" (
    id integer NOT NULL,
    name character varying(255) NOT NULL,
    "isDeleted" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- TOC entry 399 (class 1259 OID 830234)
-- Name: relSOCProtocols_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public."relSOCProtocols_id_seq"
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- TOC entry 5770 (class 0 OID 0)
-- Dependencies: 399
-- Name: relSOCProtocols_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public."relSOCProtocols_id_seq" OWNED BY public."relSOCProtocols".id;


--
-- TOC entry 233 (class 1259 OID 17675)
-- Name: samplingAreas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."samplingAreas" (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(255) NOT NULL,
    "farmId" uuid NOT NULL,
    geometry public.geometry,
    "uncroppedGeometry" public.geometry,
    "totalHectares" double precision,
    color character varying(255),
    "createdBy" character varying(255),
    "updatedBy" character varying(255),
    "isDeleted" boolean DEFAULT false,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- TOC entry 347 (class 1259 OID 18633)
-- Name: samplingAreasHistory; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."samplingAreasHistory" (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    "samplingAreaId" uuid NOT NULL,
    name character varying(255) NOT NULL,
    "farmId" uuid NOT NULL,
    geometry public.geometry,
    "uncroppedGeometry" public.geometry,
    "totalHectares" double precision,
    color character varying(255),
    "createdBy" character varying(255),
    "updatedBy" character varying(255),
    "isDeleted" boolean DEFAULT false,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- TOC entry 348 (class 1259 OID 18652)
-- Name: wetlandAreas; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public."wetlandAreas" (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(255),
    "farmId" uuid NOT NULL,
    geometry public.geometry,
    "featureCollection" json,
    "totalHectares" double precision,
    color character varying(255),
    "createdBy" character varying(255),
    "updatedBy" character varying(255),
    "isDeleted" boolean DEFAULT false,
    "createdAt" timestamp with time zone NOT NULL,
    "updatedAt" timestamp with time zone NOT NULL
);


--
-- TOC entry 5031 (class 2604 OID 830230)
-- Name: RelLaboratory id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."RelLaboratory" ALTER COLUMN id SET DEFAULT nextval('public."RelLaboratory_id_seq"'::regclass);


--
-- TOC entry 4875 (class 2604 OID 18084)
-- Name: monitoringWorkflows id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."monitoringWorkflows" ALTER COLUMN id SET DEFAULT nextval('public."monitoringWorkflows_id_seq"'::regclass);


--
-- TOC entry 4923 (class 2604 OID 18314)
-- Name: refAmmendmendType id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refAmmendmendType" ALTER COLUMN id SET DEFAULT nextval('public."refAmmendmendType_id_seq"'::regclass);


--
-- TOC entry 4925 (class 2604 OID 18323)
-- Name: refBovineCattle id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refBovineCattle" ALTER COLUMN id SET DEFAULT nextval('public."refBovineCattle_id_seq"'::regclass);


--
-- TOC entry 4927 (class 2604 OID 18332)
-- Name: refBubalineCattle id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refBubalineCattle" ALTER COLUMN id SET DEFAULT nextval('public."refBubalineCattle_id_seq"'::regclass);


--
-- TOC entry 4929 (class 2604 OID 18341)
-- Name: refCamelidCattle id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refCamelidCattle" ALTER COLUMN id SET DEFAULT nextval('public."refCamelidCattle_id_seq"'::regclass);


--
-- TOC entry 4931 (class 2604 OID 18350)
-- Name: refCaprineCattle id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refCaprineCattle" ALTER COLUMN id SET DEFAULT nextval('public."refCaprineCattle_id_seq"'::regclass);


--
-- TOC entry 4933 (class 2604 OID 18359)
-- Name: refCattleClass id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refCattleClass" ALTER COLUMN id SET DEFAULT nextval('public."refCattleClass_id_seq"'::regclass);


--
-- TOC entry 4997 (class 2604 OID 133779)
-- Name: refCattleEmissionsFactors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refCattleEmissionsFactors" ALTER COLUMN id SET DEFAULT nextval('public."refCattleEmissionsFactors_id_seq"'::regclass);


--
-- TOC entry 4998 (class 2604 OID 133787)
-- Name: refCattleEquivalences id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refCattleEquivalences" ALTER COLUMN id SET DEFAULT nextval('public."refCattleEquivalences_id_seq"'::regclass);


--
-- TOC entry 4935 (class 2604 OID 18368)
-- Name: refCattleSubClass id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refCattleSubClass" ALTER COLUMN id SET DEFAULT nextval('public."refCattleSubClass_id_seq"'::regclass);


--
-- TOC entry 4937 (class 2604 OID 18382)
-- Name: refCattleType id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refCattleType" ALTER COLUMN id SET DEFAULT nextval('public."refCattleType_id_seq"'::regclass);


--
-- TOC entry 4939 (class 2604 OID 18391)
-- Name: refCervidCattle id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refCervidCattle" ALTER COLUMN id SET DEFAULT nextval('public."refCervidCattle_id_seq"'::regclass);


--
-- TOC entry 4941 (class 2604 OID 18400)
-- Name: refCropType id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refCropType" ALTER COLUMN id SET DEFAULT nextval('public."refCropType_id_seq"'::regclass);


--
-- TOC entry 5039 (class 2604 OID 830299)
-- Name: refDAPMethods id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refDAPMethods" ALTER COLUMN id SET DEFAULT nextval('public."refDAPMethods_id_seq"'::regclass);


--
-- TOC entry 4822 (class 2604 OID 17724)
-- Name: refDataCollectionStatementStatus id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refDataCollectionStatementStatus" ALTER COLUMN id SET DEFAULT nextval('public."refDataCollectionStatementStatus_id_seq"'::regclass);


--
-- TOC entry 4943 (class 2604 OID 18409)
-- Name: refDegreeDegradationSoil id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refDegreeDegradationSoil" ALTER COLUMN id SET DEFAULT nextval('public."refDegreeDegradationSoil_id_seq"'::regclass);


--
-- TOC entry 4839 (class 2604 OID 17848)
-- Name: refDocumentType id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refDocumentType" ALTER COLUMN id SET DEFAULT nextval('public."refDocumentType_id_seq"'::regclass);


--
-- TOC entry 5002 (class 2604 OID 158355)
-- Name: refEntityDiscardReason id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refEntityDiscardReason" ALTER COLUMN id SET DEFAULT nextval('public."refEntityDiscardReason_id_seq"'::regclass);


--
-- TOC entry 4841 (class 2604 OID 17857)
-- Name: refEntityType id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refEntityType" ALTER COLUMN id SET DEFAULT nextval('public."refEntityType_id_seq"'::regclass);


--
-- TOC entry 4945 (class 2604 OID 18418)
-- Name: refEquineCattle id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refEquineCattle" ALTER COLUMN id SET DEFAULT nextval('public."refEquineCattle_id_seq"'::regclass);


--
-- TOC entry 4947 (class 2604 OID 18427)
-- Name: refExclusionAreaType id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refExclusionAreaType" ALTER COLUMN id SET DEFAULT nextval('public."refExclusionAreaType_id_seq"'::regclass);


--
-- TOC entry 5026 (class 2604 OID 559952)
-- Name: refFieldRelocationMethod id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refFieldRelocationMethod" ALTER COLUMN id SET DEFAULT nextval('public."refFieldRelocationMethod_id_seq"'::regclass);


--
-- TOC entry 4949 (class 2604 OID 18436)
-- Name: refFieldUsage id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refFieldUsage" ALTER COLUMN id SET DEFAULT nextval('public."refFieldUsage_id_seq"'::regclass);


--
-- TOC entry 4852 (class 2604 OID 17965)
-- Name: refFindingType id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refFindingType" ALTER COLUMN id SET DEFAULT nextval('public."refFindingType_id_seq"'::regclass);


--
-- TOC entry 4951 (class 2604 OID 18445)
-- Name: refForageSource id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refForageSource" ALTER COLUMN id SET DEFAULT nextval('public."refForageSource_id_seq"'::regclass);


--
-- TOC entry 5043 (class 2604 OID 1149700)
-- Name: refForageUseIntensity id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refForageUseIntensity" ALTER COLUMN id SET DEFAULT nextval('public."refForageUseIntensity_id_seq"'::regclass);


--
-- TOC entry 5045 (class 2604 OID 1149710)
-- Name: refForageUsePattern id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refForageUsePattern" ALTER COLUMN id SET DEFAULT nextval('public."refForageUsePattern_id_seq"'::regclass);


--
-- TOC entry 4999 (class 2604 OID 133804)
-- Name: refFuelEmissionsFactors id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refFuelEmissionsFactors" ALTER COLUMN id SET DEFAULT nextval('public."refFuelEmissionsFactors_id_seq"'::regclass);


--
-- TOC entry 4953 (class 2604 OID 18454)
-- Name: refFuelType id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refFuelType" ALTER COLUMN id SET DEFAULT nextval('public."refFuelType_id_seq"'::regclass);


--
-- TOC entry 4955 (class 2604 OID 18463)
-- Name: refGrazingIntensityTypes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refGrazingIntensityTypes" ALTER COLUMN id SET DEFAULT nextval('public."refGrazingIntensityTypes_id_seq"'::regclass);


--
-- TOC entry 4957 (class 2604 OID 18472)
-- Name: refGrazingPlanType id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refGrazingPlanType" ALTER COLUMN id SET DEFAULT nextval('public."refGrazingPlanType_id_seq"'::regclass);


--
-- TOC entry 4959 (class 2604 OID 18481)
-- Name: refGrazingType id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refGrazingType" ALTER COLUMN id SET DEFAULT nextval('public."refGrazingType_id_seq"'::regclass);


--
-- TOC entry 5000 (class 2604 OID 133818)
-- Name: refGreenHouseGasesGwp id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refGreenHouseGasesGwp" ALTER COLUMN id SET DEFAULT nextval('public."refGreenHouseGasesGwp_id_seq"'::regclass);


--
-- TOC entry 4961 (class 2604 OID 18490)
-- Name: refHorizonCode id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refHorizonCode" ALTER COLUMN id SET DEFAULT nextval('public."refHorizonCode_id_seq"'::regclass);


--
-- TOC entry 4963 (class 2604 OID 18499)
-- Name: refIrrigationType id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refIrrigationType" ALTER COLUMN id SET DEFAULT nextval('public."refIrrigationType_id_seq"'::regclass);


--
-- TOC entry 4965 (class 2604 OID 18508)
-- Name: refLivestockRaisingTypes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refLivestockRaisingTypes" ALTER COLUMN id SET DEFAULT nextval('public."refLivestockRaisingTypes_id_seq"'::regclass);


--
-- TOC entry 5024 (class 2604 OID 559942)
-- Name: refLocationConfirmationType id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refLocationConfirmationType" ALTER COLUMN id SET DEFAULT nextval('public."refLocationConfirmationType_id_seq"'::regclass);


--
-- TOC entry 5022 (class 2604 OID 559932)
-- Name: refLocationMovedReason id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refLocationMovedReason" ALTER COLUMN id SET DEFAULT nextval('public."refLocationMovedReason_id_seq"'::regclass);


--
-- TOC entry 4995 (class 2604 OID 92728)
-- Name: refMetricStatus id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refMetricStatus" ALTER COLUMN id SET DEFAULT nextval('public."refMetricStatus_id_seq"'::regclass);


--
-- TOC entry 4967 (class 2604 OID 18517)
-- Name: refMineralFertilizerType id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refMineralFertilizerType" ALTER COLUMN id SET DEFAULT nextval('public."refMineralFertilizerType_id_seq"'::regclass);


--
-- TOC entry 4900 (class 2604 OID 18185)
-- Name: refMonitoringReportStatus id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refMonitoringReportStatus" ALTER COLUMN id SET DEFAULT nextval('public."refMonitoringReportStatus_id_seq"'::regclass);


--
-- TOC entry 4969 (class 2604 OID 18526)
-- Name: refOrganicFertilizerType id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refOrganicFertilizerType" ALTER COLUMN id SET DEFAULT nextval('public."refOrganicFertilizerType_id_seq"'::regclass);


--
-- TOC entry 4971 (class 2604 OID 18535)
-- Name: refOvineCattle id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refOvineCattle" ALTER COLUMN id SET DEFAULT nextval('public."refOvineCattle_id_seq"'::regclass);


--
-- TOC entry 4973 (class 2604 OID 18544)
-- Name: refPasturesFamily id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refPasturesFamily" ALTER COLUMN id SET DEFAULT nextval('public."refPasturesFamily_id_seq"'::regclass);


--
-- TOC entry 4975 (class 2604 OID 18553)
-- Name: refPasturesGrowthTypes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refPasturesGrowthTypes" ALTER COLUMN id SET DEFAULT nextval('public."refPasturesGrowthTypes_id_seq"'::regclass);


--
-- TOC entry 4977 (class 2604 OID 18562)
-- Name: refPasturesTypes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refPasturesTypes" ALTER COLUMN id SET DEFAULT nextval('public."refPasturesTypes_id_seq"'::regclass);


--
-- TOC entry 5047 (class 2604 OID 1346308)
-- Name: refRandomizer id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refRandomizer" ALTER COLUMN id SET DEFAULT nextval('public."refRandomizer_id_seq"'::regclass);


--
-- TOC entry 5029 (class 2604 OID 830220)
-- Name: refSamplingNumbers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refSamplingNumbers" ALTER COLUMN id SET DEFAULT nextval('public."refSamplingNumbers_id_seq"'::regclass);


--
-- TOC entry 5049 (class 2604 OID 1420524)
-- Name: refSoilSamplingDisturbance id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refSoilSamplingDisturbance" ALTER COLUMN id SET DEFAULT nextval('public."refSoilSamplingDisturbance_id_seq"'::regclass);


--
-- TOC entry 5051 (class 2604 OID 1420534)
-- Name: refSoilSamplingTools id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refSoilSamplingTools" ALTER COLUMN id SET DEFAULT nextval('public."refSoilSamplingTools_id_seq"'::regclass);


--
-- TOC entry 4979 (class 2604 OID 18571)
-- Name: refSoilTexture id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refSoilTexture" ALTER COLUMN id SET DEFAULT nextval('public."refSoilTexture_id_seq"'::regclass);


--
-- TOC entry 4981 (class 2604 OID 18580)
-- Name: refStructureGrade id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refStructureGrade" ALTER COLUMN id SET DEFAULT nextval('public."refStructureGrade_id_seq"'::regclass);


--
-- TOC entry 4983 (class 2604 OID 18589)
-- Name: refStructureSize id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refStructureSize" ALTER COLUMN id SET DEFAULT nextval('public."refStructureSize_id_seq"'::regclass);


--
-- TOC entry 4985 (class 2604 OID 18598)
-- Name: refStructureType id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refStructureType" ALTER COLUMN id SET DEFAULT nextval('public."refStructureType_id_seq"'::regclass);


--
-- TOC entry 4868 (class 2604 OID 18055)
-- Name: refTaskStatus id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refTaskStatus" ALTER COLUMN id SET DEFAULT nextval('public."refTaskStatus_id_seq"'::regclass);


--
-- TOC entry 4987 (class 2604 OID 18607)
-- Name: refTillageType id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refTillageType" ALTER COLUMN id SET DEFAULT nextval('public."refTillageType_id_seq"'::regclass);


--
-- TOC entry 5001 (class 2604 OID 133829)
-- Name: refUnits id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refUnits" ALTER COLUMN id SET DEFAULT nextval('public."refUnits_id_seq"'::regclass);


--
-- TOC entry 4824 (class 2604 OID 17733)
-- Name: refUserRole id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refUserRole" ALTER COLUMN id SET DEFAULT nextval('public."refUserRole_id_seq"'::regclass);


--
-- TOC entry 5033 (class 2604 OID 830238)
-- Name: relSOCProtocols id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."relSOCProtocols" ALTER COLUMN id SET DEFAULT nextval('public."relSOCProtocols_id_seq"'::regclass);


--
-- TOC entry 5685 (class 0 OID 830227)
-- Dependencies: 398
-- Data for Name: RelLaboratory; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public."RelLaboratory" VALUES (0, 'AGROLABCS - ex CSLAB (AR)', false, '2025-02-17 20:55:31.022+00', '2025-02-17 20:55:31.022+00');
INSERT INTO public."RelLaboratory" VALUES (1, 'CETAPAR (PY)', false, '2025-02-17 20:55:31.022+00', '2025-02-17 20:55:31.022+00');
INSERT INTO public."RelLaboratory" VALUES (2, 'UNIVERSIDAD AUSTRAL DE CHILE (CL)', false, '2025-02-17 20:55:31.022+00', '2025-02-17 20:55:31.022+00');
INSERT INTO public."RelLaboratory" VALUES (3, 'EXATA (BR)', false, '2025-08-06 19:43:42.738+00', '2025-08-06 19:43:42.738+00');


--
-- TOC entry 5129 (class 0 OID 18295)
-- Dependencies: 279
-- Data for Name: programConfig; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."programConfig" VALUES ('a1d05c59-754c-41c5-ae21-19b310825367', 2, '{"dataCollection":[{"id":"a1d05c59-751c-41c5-ae21-19b310825255","label":"General","namespace":"farm_management_general"},{"id":"a1d05c59-751c-41c5-ae21-19b310825257","label":"Lotes","namespace":"paddock_production"},{"id":"a1d05c59-751c-41c5-ae21-19b310825258","label":"Pastoreo","namespace":"farm_management_grazing"},{"id":"a1d05c59-751c-41c5-ae21-19b310825253","label":"Fertilizantes orgánicos","namespace":"paddock_organic_fertilizers"},{"id":"a1d05c59-751c-41c5-ae21-19b310825254","label":"Fertilizantes sintéticos","namespace":"paddock_synthetic_fertilizers"},{"id":"a1d05c59-751c-41c5-ae21-19b310825256","label":"Labranza","namespace":"paddock_tillage"},{"id":"a1d05c59-751c-41c5-ae21-19b310825250","label":"Agua","namespace":"farm_management_water"},{"id":"a1d05c59-751c-41c5-ae21-19b310825251","label":"Combustibles","namespace":"farm_management_fuels"},{"id":"a1d05c59-751c-41c5-ae21-19b310825252","label":"Cultivos","namespace":"paddock_crops"},{"id":"a1d05c59-751c-41c5-ae21-19b310836366","label":"Documentación","namespace":"farm_management_documentation"}],"farmManagementSupportiveDocumentation":{"id":"1a1ce978-daec-45d0-97ec-6194afa64bdc"},"reports":{"grass_v7_report_variables":{"id":"4f9c1e2d-8b3a-4e5f-9d6c-7a2b3c4d5e67","label":"Variables del Reporte GRASS v7","enabled":true}}}', 3, false, '{0,1,2}', '{manual}', '{manual,semi-automatic,automatic}', '{"config":{"program":"RETERRA","n_classes":"optimal"}}', false, '{2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022,2023,2024,2025}', 'ruuts-api', 'ruuts-api', '2025-03-10 14:33:11.171+00', '2025-03-10 14:33:11.906+00', '{0,3,5}', '4.0.0', '{grass-v7}', '{}');
INSERT INTO public."programConfig" VALUES ('a1d05c59-754c-41c5-ae21-19b310825365', 99, '{}', 8, false, '{0,1,2,3}', '{manual,semi-automatic}', '{manual,semi-automatic,automatic}', '{"config":{"program":"CUSTOM","n_classes":"optimal","custom_bands":["NDVI.*","elevation"]}}', false, '{2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022,2023,2024,2025}', 'ruuts-api', 'ruuts-api', '2024-06-03 20:55:40.427+00', '2025-03-10 14:33:11.906+00', '{}', '3.0.0', '{}', '{}');
INSERT INTO public."programConfig" VALUES ('a1d05c59-754c-41c5-ae21-19b310825369', 1, '{"dataCollection":[{"id":"002501bb-d13b-430a-a374-43242db01801","label":"General","namespace":"farm_management_general"},{"id":"a1d05c59-751c-52d6-ae21-19b310825257","label":"Lotes","namespace":"paddock_production"},{"id":"a1d05c59-751c-41c5-ae21-19b310825245","label":"Pastoreo","namespace":"farm_management_grazing"},{"id":"a1d05c59-751c-41c5-ae21-19b310825246","label":"Combustibles","namespace":"farm_management_fuels"},{"id":"a1d05c59-751c-41c5-ae21-19b310825247","label":"Fertilizantes sintéticos","namespace":"paddock_synthetic_fertilizers"},{"id":"a0a05c59-751c-41c5-ae21-19b310836366","label":"Documentación","namespace":"farm_management_documentation"}],"farmManagementSupportiveDocumentation":{"id":"1a1ce978-daec-45d0-97ec-6194afa64bdc"},"monitoringSOCSample":{"id":"1a1ce978-eeee-45d0-97ec-6194afa64bdc","enable":true},"reports":{"grass_v7_report_variables":{"id":"4f9c1e2d-8b3a-4e5f-9d6c-7a2b3c4d5e67","label":"Variables del Reporte GRASS v7","enabled":true}}}', 10, true, '{3,1,2,4}', '{manual}', '{semi-automatic,automatic}', '{"config":{"program":"POA","n_classes":"optimal"}}', false, '{2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022,2023,2024,2025,LP,TEMPLATE}', 'ruuts-api', 'ruuts-api', '2024-06-03 20:55:40.427+00', '2025-03-10 14:33:11.891+00', '{0}', '2.0.0', '{grass-v7}', '{}');
INSERT INTO public."programConfig" VALUES ('a1d05c59-754c-41c5-ae21-19b310825364', 0, '{"dataCollection":[{"id":"a1d05c59-751c-41c5-ae21-19b310825255","label":"General","namespace":"farm_management_general"},{"id":"a1d05c59-751c-41c5-ae21-19b310825257","label":"Lotes","namespace":"paddock_production"},{"id":"a1d05c59-751c-41c5-ae21-19b310825258","label":"Pastoreo","namespace":"farm_management_grazing"},{"id":"a1d05c59-751c-41c5-ae21-19b310825253","label":"Fertilizantes orgánicos","namespace":"paddock_organic_fertilizers"},{"id":"a1d05c59-751c-41c5-ae21-19b310825254","label":"Fertilizantes sintéticos","namespace":"paddock_synthetic_fertilizers"},{"id":"a1d05c59-751c-41c5-ae21-19b310825256","label":"Labranza","namespace":"paddock_tillage"},{"id":"a1d05c59-751c-41c5-ae21-19b310825250","label":"Agua","namespace":"farm_management_water"},{"id":"a1d05c59-751c-41c5-ae21-19b310825251","label":"Combustibles","namespace":"farm_management_fuels"},{"id":"a1d05c59-751c-41c5-ae21-19b310825252","label":"Cultivos","namespace":"paddock_crops"},{"id":"a1d05c59-751c-41c5-ae21-19b310836366","label":"Documentación","namespace":"farm_management_documentation"}],"farmManagementSupportiveDocumentation":{"id":"1a1ce978-daec-45d0-97ec-6194afa64bdc"},"monitoringSOCSample":{"id":"1a1ce978-eeee-45d0-97ec-6194afa64bdc","enable":true},"reports":{"grass_v7_report_variables":{"id":"4f9c1e2d-8b3a-4e5f-9d6c-7a2b3c4d5e67","label":"Variables del Reporte GRASS v7","enabled":true},"sara_instances_report_variables":{"id":"4f9c1e2d-8b3a-4e5f-9d6c-7a2b3c4d5e6f","label":"Variables del Reporte SARA Instances","enabled":true}}}', 8, true, '{0,1,2}', '{manual,semi-automatic}', '{manual,semi-automatic}', '{"config":{"program":"SARA","n_classes":"optimal"}}', false, '{2012,2013,2014,2015,2016,2017,2018,2019,2020,2021,2022,2023,2024,2025}', 'ruuts-api', 'ruuts-api', '2024-06-03 20:55:40.427+00', '2025-03-10 14:33:11.891+00', '{0,3,5}', '2.0.0', '{Attestation,grass-v7,sara-instances}', '{"{\"id\":\"18b8c3ee-a463-4bfd-8711-732c11ae81e6\",\"name\":\"MR1\"}"}');


--
-- TOC entry 5112 (class 0 OID 17630)
-- Dependencies: 231
-- Data for Name: programMonitoringPeriods; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."programMonitoringPeriods" VALUES ('77ac99af-009a-4ab7-bd94-3bb0643c7c1a', 0, 'MR3', '2024-09-01 03:00:00+00', '2025-06-30 00:00:00+00', false, 'jetadminconnection@ruuts.la', 'ruuts-api-migration-20251112', '2024-10-01 19:22:35.4+00', '2025-11-12 19:49:44.029886+00');
INSERT INTO public."programMonitoringPeriods" VALUES ('86fd20a9-dcec-4e92-9110-018f7d743ad4', 1, 'MR1', NULL, NULL, false, 'jetadminconnection@ruuts.la', NULL, '2024-10-08 15:13:56.805+00', '2024-10-08 15:13:56.805+00');
INSERT INTO public."programMonitoringPeriods" VALUES ('6ff16a35-8779-4d31-8080-180292107a39', 1, 'MR2', NULL, NULL, false, 'jetadminconnection@ruuts.la', NULL, '2024-10-08 15:14:19.551+00', '2024-10-08 15:14:19.551+00');
INSERT INTO public."programMonitoringPeriods" VALUES ('18b8c3ee-a463-4bfd-8711-732c11ae81e6', 0, 'MR1', '2019-10-01 00:00:00+00', '2023-06-30 00:00:00+00', false, 'ruuts-api', NULL, '2024-06-03 20:55:40.413+00', '2024-06-03 20:55:40.413+00');
INSERT INTO public."programMonitoringPeriods" VALUES ('b0929619-f4bc-4a90-a86e-8c02dbfed265', 0, 'MR2', '2023-07-01 00:00:00+00', '2024-06-30 00:00:00+00', false, 'ruuts-api', 'ruuts-api-migration-20251112', '2024-06-03 20:55:40.413+00', '2025-11-12 19:49:44.029886+00');


--
-- TOC entry 5111 (class 0 OID 17613)
-- Dependencies: 229
-- Data for Name: programs; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public.programs VALUES (0, 'SARA', '1', '2024-06-03 20:55:40.41+00', '2024-06-03 20:55:40.41+00', false);
INSERT INTO public.programs VALUES (2, 'ReTerra', '1', '2025-03-10 14:33:10.621+00', '2025-03-10 14:33:10.621+00', false);
INSERT INTO public.programs VALUES (1, 'POA', '1', '2024-06-03 20:55:40.41+00', '2024-06-03 20:55:40.41+00', false);
INSERT INTO public.programs VALUES (99, 'Sin programa', '1', '2024-06-03 20:55:40.41+00', '2024-06-03 20:55:40.41+00', false);


--
-- TOC entry 5126 (class 0 OID 18112)
-- Dependencies: 268
-- Data for Name: refActivityLayouts; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."refActivityLayouts" VALUES (0, 0, 'SOC-GRID-4-20', '[{"key":"P1","relativeCoords":[0,0]},{"key":"P2","relativeCoords":[20,0]},{"key":"P3","relativeCoords":[20,20]},{"key":"P4","relativeCoords":[0,20]}]', '2024-06-03 20:55:40.388+00', '2024-06-03 20:55:40.388+00', false);
INSERT INTO public."refActivityLayouts" VALUES (1, 2, 'LTM-GRID-V1', '[{"key":"P1","relativeCoords":[0,0]},{"key":"P2","relativeCoords":[8.5,2.5]},{"key":"P3","relativeCoords":[8.5,0]},{"key":"P4","relativeCoords":[8.5,-2.5]},{"key":"TRANSECT-3-START","relativeCoords":[22,-6.5]},{"key":"TRANSECT-2-START","relativeCoords":[22,0]},{"key":"TRANSECT-1-START","relativeCoords":[22,6.5]},{"key":"TRANSECT-3-END","relativeCoords":[47,-6.5]},{"key":"TRANSECT-2-END","relativeCoords":[47,0]},{"key":"TRANSECT-1-END","relativeCoords":[47,6.5]},{"key":"INFILT-1","relativeCoords":[22,-11.5]},{"key":"INFILT-2","relativeCoords":[22,11.5]},{"key":"INFILT-3","relativeCoords":[47,-11.5]},{"key":"INFILT-4","relativeCoords":[47,11.5]}]', '2024-06-03 20:55:40.388+00', '2024-06-03 20:55:40.388+00', false);


--
-- TOC entry 5131 (class 0 OID 18311)
-- Dependencies: 281
-- Data for Name: refAmmendmendType; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."refAmmendmendType" VALUES (0, 'Otro', 'Otro', 'Other', '2024-06-03 20:55:40.359+00', '2024-06-03 20:55:40.359+00', false);
INSERT INTO public."refAmmendmendType" VALUES (1, 'Dolomita', 'Dolomita', 'Dolomite', '2024-06-03 20:55:40.359+00', '2024-06-03 20:55:40.359+00', false);
INSERT INTO public."refAmmendmendType" VALUES (2, 'Yeso agrícola', 'Yeso agrícola', '', '2024-06-03 20:55:40.359+00', '2024-06-03 20:55:40.359+00', false);
INSERT INTO public."refAmmendmendType" VALUES (3, 'Carbonato de calcio', 'Carbonato de calcio', 'Calcium Carbonate', '2024-06-03 20:55:40.359+00', '2024-06-03 20:55:40.359+00', false);


--
-- TOC entry 5133 (class 0 OID 18320)
-- Dependencies: 283
-- Data for Name: refBovineCattle; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."refBovineCattle" VALUES (0, 'Vaca adulta', 'Vaca adulta', 'Old cow', '2024-06-03 20:55:40.312+00', '2024-06-03 20:55:40.312+00', false);
INSERT INTO public."refBovineCattle" VALUES (1, 'Vaca', 'Vaca', 'Cow', '2024-06-03 20:55:40.312+00', '2024-06-03 20:55:40.312+00', false);
INSERT INTO public."refBovineCattle" VALUES (2, 'Ternero', 'Ternero', 'Calf', '2024-06-03 20:55:40.312+00', '2024-06-03 20:55:40.312+00', false);
INSERT INTO public."refBovineCattle" VALUES (3, 'Toro adulto', 'Toro adulto', 'Old bull', '2024-06-03 20:55:40.312+00', '2024-06-03 20:55:40.312+00', false);
INSERT INTO public."refBovineCattle" VALUES (4, 'Toro', 'Toro', 'Bull', '2024-06-03 20:55:40.312+00', '2024-06-03 20:55:40.312+00', false);
INSERT INTO public."refBovineCattle" VALUES (5, 'Vaquillona', 'Vaquillona', 'Heifer', '2024-06-03 20:55:40.312+00', '2024-06-03 20:55:40.312+00', false);
INSERT INTO public."refBovineCattle" VALUES (6, 'Novillo', 'Novillo', 'Steer', '2024-06-03 20:55:40.312+00', '2024-06-03 20:55:40.312+00', false);


--
-- TOC entry 5135 (class 0 OID 18329)
-- Dependencies: 285
-- Data for Name: refBubalineCattle; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."refBubalineCattle" VALUES (0, 'Búfala', 'Búfala', '', '2024-06-03 20:55:40.325+00', '2024-06-03 20:55:40.325+00', false);
INSERT INTO public."refBubalineCattle" VALUES (1, 'Búfalo', 'Búfalo', 'Buffalo', '2024-06-03 20:55:40.325+00', '2024-06-03 20:55:40.325+00', false);


--
-- TOC entry 5137 (class 0 OID 18338)
-- Dependencies: 287
-- Data for Name: refCamelidCattle; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."refCamelidCattle" VALUES (0, 'Llama', 'Llama', 'Llama', '2024-06-03 20:55:40.333+00', '2024-06-03 20:55:40.333+00', false);
INSERT INTO public."refCamelidCattle" VALUES (1, 'Guanaco', 'Guanaco', 'Guanaco', '2024-06-03 20:55:40.333+00', '2024-06-03 20:55:40.333+00', false);


--
-- TOC entry 5139 (class 0 OID 18347)
-- Dependencies: 289
-- Data for Name: refCaprineCattle; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."refCaprineCattle" VALUES (0, 'Cabra', 'Cabra', 'Goat', '2024-06-03 20:55:40.329+00', '2024-06-03 20:55:40.329+00', false);
INSERT INTO public."refCaprineCattle" VALUES (1, 'Cabrito', 'Cabrito', '', '2024-06-03 20:55:40.329+00', '2024-06-03 20:55:40.329+00', false);
INSERT INTO public."refCaprineCattle" VALUES (2, 'Chivo', 'Chivo', 'Billy goat', '2024-06-03 20:55:40.329+00', '2024-06-03 20:55:40.329+00', false);


--
-- TOC entry 5141 (class 0 OID 18356)
-- Dependencies: 291
-- Data for Name: refCattleClass; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."refCattleClass" VALUES (0, 'Bovino', 'Bovino', 'Bovine', '2024-06-03 20:55:40.302+00', '2024-06-03 20:55:40.302+00', false);
INSERT INTO public."refCattleClass" VALUES (1, 'Ovino', 'Ovino', 'Ovine', '2024-06-03 20:55:40.302+00', '2024-06-03 20:55:40.302+00', false);
INSERT INTO public."refCattleClass" VALUES (2, 'Equino', 'Equino', 'Equine', '2024-06-03 20:55:40.302+00', '2024-06-03 20:55:40.302+00', false);
INSERT INTO public."refCattleClass" VALUES (3, 'Bubalino', 'Bubalino', 'Bubaline', '2024-06-03 20:55:40.302+00', '2024-06-03 20:55:40.302+00', true);
INSERT INTO public."refCattleClass" VALUES (4, 'Caprino', 'Caprino', 'Caprine', '2024-06-03 20:55:40.302+00', '2024-06-03 20:55:40.302+00', false);
INSERT INTO public."refCattleClass" VALUES (5, 'Camelido', 'Camelido', 'Camelid', '2024-06-03 20:55:40.302+00', '2024-06-03 20:55:40.302+00', true);
INSERT INTO public."refCattleClass" VALUES (6, 'Cérvido', 'Cérvido', 'Cervid', '2024-06-03 20:55:40.302+00', '2024-06-03 20:55:40.302+00', false);


--
-- TOC entry 5200 (class 0 OID 133776)
-- Dependencies: 371
-- Data for Name: refCattleEmissionsFactors; Type: TABLE DATA; Schema: public; Owner: postgres
--

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


--
-- TOC entry 5202 (class 0 OID 133784)
-- Dependencies: 373
-- Data for Name: refCattleEquivalences; Type: TABLE DATA; Schema: public; Owner: postgres
--

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


--
-- TOC entry 5143 (class 0 OID 18365)
-- Dependencies: 293
-- Data for Name: refCattleSubClass; Type: TABLE DATA; Schema: public; Owner: postgres
--

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


--
-- TOC entry 5145 (class 0 OID 18379)
-- Dependencies: 295
-- Data for Name: refCattleType; Type: TABLE DATA; Schema: public; Owner: postgres
--

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


--
-- TOC entry 5147 (class 0 OID 18388)
-- Dependencies: 297
-- Data for Name: refCervidCattle; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."refCervidCattle" VALUES (0, 'Ciervo', 'Ciervo', 'Deer', '2024-06-03 20:55:40.337+00', '2024-06-03 20:55:40.337+00', false);
INSERT INTO public."refCervidCattle" VALUES (1, 'Cierva', 'Cierva', 'Deer', '2024-06-03 20:55:40.337+00', '2024-06-03 20:55:40.337+00', false);
INSERT INTO public."refCervidCattle" VALUES (2, 'Cervatillo', 'Cervatillo', 'Fawn', '2024-06-03 20:55:40.337+00', '2024-06-03 20:55:40.337+00', false);


--
-- TOC entry 5217 (class 0 OID 690912)
-- Dependencies: 394
-- Data for Name: refCountries; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."refCountries" VALUES (0, 'AR', 'Argentina', 'AR', 'Argentina', 'AR', 'Argentina', 'AR', 'Argentina', false, '2025-01-08 23:22:36.685+00', '2025-01-08 23:22:36.685+00');
INSERT INTO public."refCountries" VALUES (1, 'PY', 'Paraguay', 'PY', 'Paraguai', 'PY', 'Paraguay', 'PY', 'Paraguay', false, '2025-01-08 23:22:36.685+00', '2025-01-08 23:22:36.685+00');
INSERT INTO public."refCountries" VALUES (2, 'BR', 'Brasil', 'BR', 'Brasil', 'BR', 'Brasil', 'BR', 'Brazil', false, '2025-01-08 23:22:36.685+00', '2025-01-08 23:22:36.685+00');
INSERT INTO public."refCountries" VALUES (3, 'CL', 'Chile', 'CL', 'Chile', 'CL', 'Chile', 'CL', 'Chile', false, '2025-01-08 23:22:36.685+00', '2025-01-08 23:22:36.685+00');
INSERT INTO public."refCountries" VALUES (4, 'UY', 'Uruguay', 'UY', 'Uruguai', 'UY', 'Uruguay', 'UY', 'Uruguay', false, '2025-01-08 23:22:36.685+00', '2025-01-08 23:22:36.685+00');


--
-- TOC entry 5149 (class 0 OID 18397)
-- Dependencies: 299
-- Data for Name: refCropType; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."refCropType" VALUES (0, 'Maíz', 'Maíz', 'Korn', '2024-06-03 20:55:40.38+00', '2024-06-03 20:55:40.38+00', false);
INSERT INTO public."refCropType" VALUES (1, 'Soja', 'Soja', 'Soy', '2024-06-03 20:55:40.38+00', '2024-06-03 20:55:40.38+00', false);
INSERT INTO public."refCropType" VALUES (2, 'Trigo', 'Trigo', 'Wheat', '2024-06-03 20:55:40.38+00', '2024-06-03 20:55:40.38+00', false);
INSERT INTO public."refCropType" VALUES (3, 'Maní', 'Maní', 'Peanut', '2024-06-03 20:55:40.38+00', '2024-06-03 20:55:40.38+00', false);
INSERT INTO public."refCropType" VALUES (4, 'Sorgo', 'Sorgo', '', '2024-06-03 20:55:40.38+00', '2024-06-03 20:55:40.38+00', false);
INSERT INTO public."refCropType" VALUES (5, 'Girasol', 'Girasol', 'Sunflower', '2024-06-03 20:55:40.38+00', '2024-06-03 20:55:40.38+00', false);
INSERT INTO public."refCropType" VALUES (6, 'Cultivo de cobertura', 'Cultivo de cobertura', '', '2024-06-03 20:55:40.38+00', '2024-06-03 20:55:40.38+00', false);
INSERT INTO public."refCropType" VALUES (7, 'Cultivos anuales para forraje', 'Cultivos anuales para forraje', '', '2024-06-03 20:55:40.38+00', '2024-06-03 20:55:40.38+00', false);


--
-- TOC entry 5223 (class 0 OID 830296)
-- Dependencies: 404
-- Data for Name: refDAPMethods; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."refDAPMethods" VALUES (0, 'Intacta', 'Intacta', 'Undisturbed', false, '2025-02-17 20:55:31.144+00', '2025-02-17 20:55:31.144+00');
INSERT INTO public."refDAPMethods" VALUES (1, 'Excavación', 'Excavación', 'Excavation', false, '2025-02-17 20:55:31.144+00', '2025-02-17 20:55:31.144+00');
INSERT INTO public."refDAPMethods" VALUES (2, 'Anillo', 'Anillo', 'Ring', false, '2025-07-29 22:11:32.025+00', '2025-07-29 22:11:32.025+00');


--
-- TOC entry 5115 (class 0 OID 17721)
-- Dependencies: 237
-- Data for Name: refDataCollectionStatementStatus; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."refDataCollectionStatementStatus" VALUES (0, 'Pendiente', 'Pendiente', 'Pending', '2024-06-03 20:55:40.455+00', '2024-06-03 20:55:40.455+00', false);
INSERT INTO public."refDataCollectionStatementStatus" VALUES (1, 'En proceso', 'En proceso', 'In process', '2024-06-03 20:55:40.455+00', '2024-06-03 20:55:40.455+00', false);
INSERT INTO public."refDataCollectionStatementStatus" VALUES (2, 'A revisar', 'A revisar', 'To review', '2024-06-03 20:55:40.455+00', '2024-06-03 20:55:40.455+00', false);
INSERT INTO public."refDataCollectionStatementStatus" VALUES (3, 'En revisión', 'En revisión', 'In review', '2024-06-03 20:55:40.455+00', '2024-06-03 20:55:40.455+00', false);
INSERT INTO public."refDataCollectionStatementStatus" VALUES (4, 'Observada', 'Observada', 'Observed', '2024-06-03 20:55:40.455+00', '2024-06-03 20:55:40.455+00', false);
INSERT INTO public."refDataCollectionStatementStatus" VALUES (5, 'Aprobada', 'Aprobada', 'Approved', '2024-06-03 20:55:40.455+00', '2024-06-03 20:55:40.455+00', false);
INSERT INTO public."refDataCollectionStatementStatus" VALUES (6, 'Aprobada completamente', 'Aprobada completamente', 'FullAprroved', '2024-06-03 20:55:40.455+00', '2024-06-03 20:55:40.455+00', false);
INSERT INTO public."refDataCollectionStatementStatus" VALUES (7, 'No conforme', 'No comforme', 'NonCompaint', '2024-06-03 20:55:40.455+00', '2024-06-03 20:55:40.455+00', false);


--
-- TOC entry 5151 (class 0 OID 18406)
-- Dependencies: 301
-- Data for Name: refDegreeDegradationSoil; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."refDegreeDegradationSoil" VALUES (0, 'Severa', 'Severa', 'Severe', '2024-06-03 20:55:40.463+00', '2024-06-03 20:55:40.463+00', false);
INSERT INTO public."refDegreeDegradationSoil" VALUES (1, 'Moderada', 'Moderada', 'Moderate', '2024-06-03 20:55:40.463+00', '2024-06-03 20:55:40.463+00', false);
INSERT INTO public."refDegreeDegradationSoil" VALUES (2, 'Sin degradación', 'Sin degradación', 'Without degradation', '2024-06-03 20:55:40.463+00', '2024-06-03 20:55:40.463+00', false);


--
-- TOC entry 5119 (class 0 OID 17845)
-- Dependencies: 246
-- Data for Name: refDocumentType; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."refDocumentType" VALUES (0, 'Facturas de compra de animales', 'Facturas de compra de animales', 'Animal purchase bills', '2024-06-03 20:55:40.585+00', '2024-06-03 20:55:40.585+00', false);
INSERT INTO public."refDocumentType" VALUES (1, 'Certificados de SENASA', 'Certificados de SENASA', 'Senasa certifaction', '2024-06-03 20:55:40.585+00', '2024-06-03 20:55:40.585+00', false);
INSERT INTO public."refDocumentType" VALUES (2, 'Facturas de fertilizantes', 'Facturas de fertilizantes', 'Fertilizers bills', '2024-06-03 20:55:40.585+00', '2024-06-03 20:55:40.585+00', false);
INSERT INTO public."refDocumentType" VALUES (3, 'Facturas de combustibles', 'Facturas de combustibles', 'Fuels bills', '2024-06-03 20:55:40.585+00', '2024-06-03 20:55:40.585+00', false);
INSERT INTO public."refDocumentType" VALUES (4, 'Facturas de monitoreo', 'Facturas de monitoreo', 'Monitoring bills', '2024-06-03 20:55:40.585+00', '2024-06-03 20:55:40.585+00', false);
INSERT INTO public."refDocumentType" VALUES (5, 'Certificado de análisis de suelo', 'Certificado de análisis de suelo', 'Soil analysis certificate', '2025-02-17 20:55:31.386+00', '2025-02-17 20:55:31.386+00', false);


--
-- TOC entry 5210 (class 0 OID 158352)
-- Dependencies: 384
-- Data for Name: refEntityDiscardReason; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."refEntityDiscardReason" VALUES (0, 'Manejo holistico con al menos un plan de Pastoreo Continuo u Otros Pastoreos Rotativos luego de nacimiento de instancia', 'Manejo holistico con al menos un plan de Pastoreo Continuo u Otros Pastoreos Rotativos luego de nacimiento de instancia', 'Holistic management with at least one Continuous Grazing or Other Rotational Grazing plan after instance is born', '2024-08-16 14:00:13.832+00', '2024-08-16 14:00:13.832+00');
INSERT INTO public."refEntityDiscardReason" VALUES (1, 'Área de descarte para instancia de carbono de SARA obtenida mediante un proceso de curaduría manual', 'Área de descarte para instancia de carbono de SARA obtenida mediante un proceso de curaduría manual', 'Discard area for SARA carbon instance obtained through a manual curation process', '2025-03-19 19:15:08.226+00', '2025-03-19 19:15:08.226+00');


--
-- TOC entry 5121 (class 0 OID 17854)
-- Dependencies: 248
-- Data for Name: refEntityType; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."refEntityType" VALUES (0, 'Loteo', 'Loteo', 'Farm subdivision', '2024-06-03 20:55:40.589+00', '2024-06-03 20:55:40.589+00', false);
INSERT INTO public."refEntityType" VALUES (1, 'Lote', 'Lote', 'Paddock', '2024-08-16 14:00:13.766+00', '2024-08-16 14:00:13.766+00', false);
INSERT INTO public."refEntityType" VALUES (2, 'Establecimiento', 'Establecimiento', 'Farm', '2024-11-27 22:09:34.01+00', '2024-11-27 22:09:34.01+00', false);
INSERT INTO public."refEntityType" VALUES (3, 'Instancia de Carbono', 'Instancia de Carbono', 'Carbon Instance', '2024-11-27 22:09:34.01+00', '2024-11-27 22:09:34.01+00', false);
INSERT INTO public."refEntityType" VALUES (4, 'Muestra de Monitorización de Carbono en Suelo', 'Muestra de Monitorización de Carbono en Suelo', 'Monitoring SOC Sample', '2025-02-17 20:55:31.393+00', '2025-02-17 20:55:31.393+00', false);


--
-- TOC entry 5153 (class 0 OID 18415)
-- Dependencies: 303
-- Data for Name: refEquineCattle; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."refEquineCattle" VALUES (0, 'Caballo', 'Caballo', 'Horse', '2024-06-03 20:55:40.321+00', '2024-06-03 20:55:40.321+00', false);
INSERT INTO public."refEquineCattle" VALUES (1, 'Potrillo 0-1 años', 'Potrillo 0-1 años', 'Foal 0-1 years', '2024-06-03 20:55:40.321+00', '2024-06-03 20:55:40.321+00', false);
INSERT INTO public."refEquineCattle" VALUES (2, 'Potrillo 1-2 años', 'Potrillo 1-2 años', 'Foal 1-2 years', '2024-06-03 20:55:40.321+00', '2024-06-03 20:55:40.321+00', false);
INSERT INTO public."refEquineCattle" VALUES (3, 'Yegua', 'Yegua', 'Mare', '2024-06-03 20:55:40.321+00', '2024-06-03 20:55:40.321+00', false);
INSERT INTO public."refEquineCattle" VALUES (4, 'Potro', 'Potro', 'Colt', '2024-06-03 20:55:40.321+00', '2024-06-03 20:55:40.321+00', false);
INSERT INTO public."refEquineCattle" VALUES (5, 'Burro', 'Burro', 'Donkey', '2024-06-03 20:55:40.321+00', '2024-06-03 20:55:40.321+00', false);
INSERT INTO public."refEquineCattle" VALUES (6, 'Mula', 'Mula', 'Mule', '2024-06-03 20:55:40.321+00', '2024-06-03 20:55:40.321+00', false);


--
-- TOC entry 5155 (class 0 OID 18424)
-- Dependencies: 305
-- Data for Name: refExclusionAreaType; Type: TABLE DATA; Schema: public; Owner: postgres
--

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


--
-- TOC entry 5216 (class 0 OID 559949)
-- Dependencies: 393
-- Data for Name: refFieldRelocationMethod; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."refFieldRelocationMethod" VALUES (0, 'Realeatorizado por MDC', 'Realeatorizado por MDC', 'MDC randomizer', false, '2024-11-27 22:09:34.098+00', '2024-11-27 22:09:34.098+00');
INSERT INTO public."refFieldRelocationMethod" VALUES (1, 'Manual', 'Manual', 'Manual', false, '2024-11-27 22:09:34.098+00', '2024-11-27 22:09:34.098+00');


--
-- TOC entry 5157 (class 0 OID 18433)
-- Dependencies: 307
-- Data for Name: refFieldUsage; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."refFieldUsage" VALUES (0, 'Ganadería', 'Ganadería', 'Grazing', '2024-06-03 20:55:40.272+00', '2024-06-03 20:55:40.272+00', false);
INSERT INTO public."refFieldUsage" VALUES (1, 'Agricultura', 'Agricultura', 'Agriculture', '2024-06-03 20:55:40.272+00', '2024-06-03 20:55:40.272+00', false);
INSERT INTO public."refFieldUsage" VALUES (2, 'Forestal', 'Forestal', 'Forest', '2024-06-03 20:55:40.272+00', '2024-06-03 20:55:40.272+00', false);
INSERT INTO public."refFieldUsage" VALUES (3, 'Mixto (agro-ganadero)', 'Mixto (agro-ganadero)', 'Mixed (agro-livestock)', '2024-06-03 20:55:40.272+00', '2024-06-03 20:55:40.272+00', false);
INSERT INTO public."refFieldUsage" VALUES (4, 'Sin uso', 'Sin uso', 'Without use', '2024-06-03 20:55:40.272+00', '2024-06-03 20:55:40.272+00', false);
INSERT INTO public."refFieldUsage" VALUES (5, 'Silvopastoril', 'Silvopastoril', 'Silvopastoral', '2024-06-03 20:55:40.272+00', '2024-06-03 20:55:40.272+00', false);
INSERT INTO public."refFieldUsage" VALUES (6, 'Agroforestal', 'Agroforestal', 'Agroforestry', '2024-06-03 20:55:40.272+00', '2024-06-03 20:55:40.272+00', false);
INSERT INTO public."refFieldUsage" VALUES (7, 'Área de sacrificio', 'Área de sacrificio', 'Sacrifice area', '2024-06-03 20:55:40.272+00', '2024-06-03 20:55:40.272+00', false);


--
-- TOC entry 5123 (class 0 OID 17962)
-- Dependencies: 256
-- Data for Name: refFindingType; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."refFindingType" VALUES (0, 'Observación', 'Observación', 'Observation', '2024-06-03 20:55:40.344+00', '2024-06-03 20:55:40.344+00', false);
INSERT INTO public."refFindingType" VALUES (1, 'Incumplimiento a corregir', 'Incumplimiento a corregir', 'Non-compliance to correct', '2024-06-03 20:55:40.344+00', '2024-06-03 20:55:40.344+00', false);
INSERT INTO public."refFindingType" VALUES (2, 'Incumplimiento grave', 'Incumplimiento grave', 'Serious non-compliance', '2024-06-03 20:55:40.344+00', '2024-06-03 20:55:40.344+00', false);


--
-- TOC entry 5159 (class 0 OID 18442)
-- Dependencies: 309
-- Data for Name: refForageSource; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."refForageSource" VALUES (0, 'Silvopastoril', '', '', '2024-06-03 20:55:40.276+00', '2024-06-03 20:55:40.276+00', false);
INSERT INTO public."refForageSource" VALUES (1, 'Campo natural', 'Campo natural', '', '2024-06-03 20:55:40.276+00', '2024-06-03 20:55:40.276+00', false);
INSERT INTO public."refForageSource" VALUES (2, 'Pasturas cultivadas', 'Pasturas cultivadas', 'Crop pastures', '2024-06-03 20:55:40.276+00', '2024-06-03 20:55:40.276+00', false);
INSERT INTO public."refForageSource" VALUES (3, 'Cultivos de invierno', 'Cultivos de invierno', 'Winter crops', '2024-06-03 20:55:40.276+00', '2024-06-03 20:55:40.276+00', false);
INSERT INTO public."refForageSource" VALUES (4, 'Cultivos de verano', 'Cultivos de verano', 'Summer crops', '2024-06-03 20:55:40.276+00', '2024-06-03 20:55:40.276+00', false);


--
-- TOC entry 5225 (class 0 OID 1149697)
-- Dependencies: 411
-- Data for Name: refForageUseIntensity; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."refForageUseIntensity" VALUES (1, 'Nulo', 'Nulo', 'Null', 'Nulo', false, '2025-06-11 18:14:31.15+00', '2025-06-11 18:14:31.15+00');
INSERT INTO public."refForageUseIntensity" VALUES (2, 'Liviano', 'Liviano', 'Light', 'Liviano', false, '2025-06-11 18:14:31.15+00', '2025-06-11 18:14:31.15+00');
INSERT INTO public."refForageUseIntensity" VALUES (3, 'Moderado', 'Moderado', 'Moderate', 'Moderado', false, '2025-06-11 18:14:31.15+00', '2025-06-11 18:14:31.15+00');
INSERT INTO public."refForageUseIntensity" VALUES (4, 'Intenso', 'Intenso', 'Intense', 'Intenso', false, '2025-06-11 18:14:31.15+00', '2025-06-11 18:14:31.15+00');


--
-- TOC entry 5227 (class 0 OID 1149707)
-- Dependencies: 413
-- Data for Name: refForageUsePattern; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."refForageUsePattern" VALUES (1, 'SP', 'SP', 'SP', 'SP', false, '2025-06-11 18:14:31.143+00', '2025-06-11 18:14:31.143+00');
INSERT INTO public."refForageUsePattern" VALUES (2, 'SD', 'SD', 'SD', 'SD', false, '2025-06-11 18:14:31.143+00', '2025-06-11 18:14:31.143+00');
INSERT INTO public."refForageUsePattern" VALUES (3, 'DP', 'DP', 'DP', 'DP', false, '2025-06-11 18:14:31.143+00', '2025-06-11 18:14:31.143+00');
INSERT INTO public."refForageUsePattern" VALUES (4, 'PP', 'PP', 'PP', 'PP', false, '2025-06-11 18:14:31.143+00', '2025-06-11 18:14:31.143+00');


--
-- TOC entry 5204 (class 0 OID 133801)
-- Dependencies: 375
-- Data for Name: refFuelEmissionsFactors; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."refFuelEmissionsFactors" VALUES (0, 0, '0.0693', '44.3', '2.86', 'GHG2006', '2024-08-13 15:11:54.226+00', '2024-08-13 15:11:54.226+00');
INSERT INTO public."refFuelEmissionsFactors" VALUES (1, 1, '0.0741', '43', '3.22', 'GHG2006', '2024-08-13 15:11:54.226+00', '2024-08-13 15:11:54.226+00');
INSERT INTO public."refFuelEmissionsFactors" VALUES (2, 2, '0.0561', '48', '0.6292', 'GHG2006', '2024-08-13 15:11:54.226+00', '2024-08-13 15:11:54.226+00');


--
-- TOC entry 5161 (class 0 OID 18451)
-- Dependencies: 311
-- Data for Name: refFuelType; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."refFuelType" VALUES (0, 'Nafta', 'Nafta', 'Gasoline', '2024-06-03 20:55:40.34+00', '2024-06-03 20:55:40.34+00', false);
INSERT INTO public."refFuelType" VALUES (1, 'Diesel', 'Diesel', 'Diesel', '2024-06-03 20:55:40.34+00', '2024-06-03 20:55:40.34+00', false);
INSERT INTO public."refFuelType" VALUES (2, 'Gas', 'Gas', 'Gas', '2024-06-03 20:55:40.34+00', '2024-06-03 20:55:40.34+00', false);


--
-- TOC entry 5163 (class 0 OID 18460)
-- Dependencies: 313
-- Data for Name: refGrazingIntensityTypes; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."refGrazingIntensityTypes" VALUES (0, 'Leve', 'Leve', 'Mild', '2024-06-03 20:55:40.618+00', '2024-06-03 20:55:40.618+00', false);
INSERT INTO public."refGrazingIntensityTypes" VALUES (1, 'Moderado', 'Moderado', 'Moderate', '2024-06-03 20:55:40.618+00', '2024-06-03 20:55:40.618+00', false);
INSERT INTO public."refGrazingIntensityTypes" VALUES (2, 'Intenso', 'Intenso', 'Intense', '2024-06-03 20:55:40.618+00', '2024-06-03 20:55:40.618+00', false);
INSERT INTO public."refGrazingIntensityTypes" VALUES (3, 'Nulo', 'Nulo', 'None', '2024-06-03 20:55:40.618+00', '2024-06-03 20:55:40.618+00', false);


--
-- TOC entry 5165 (class 0 OID 18469)
-- Dependencies: 315
-- Data for Name: refGrazingPlanType; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."refGrazingPlanType" VALUES (0, 'Abierto', 'Abierto', 'Open', '2024-06-03 20:55:40.356+00', '2024-06-03 20:55:40.356+00', false);
INSERT INTO public."refGrazingPlanType" VALUES (1, 'Cerrado', 'Cerrado', 'Closed', '2024-06-03 20:55:40.356+00', '2024-06-03 20:55:40.356+00', false);


--
-- TOC entry 5167 (class 0 OID 18478)
-- Dependencies: 317
-- Data for Name: refGrazingType; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."refGrazingType" VALUES (0, 'Manejo holístico', 'Manejo holístico', 'Holistic management', '2024-06-03 20:55:40.348+00', '2024-06-03 20:55:40.348+00', false);
INSERT INTO public."refGrazingType" VALUES (1, 'Pastoreo continuo', 'Pastoreo continuo', 'Continuous grazing', '2024-06-03 20:55:40.348+00', '2024-06-03 20:55:40.348+00', false);
INSERT INTO public."refGrazingType" VALUES (2, 'Otros pastoreos rotativos', 'Otros pastoreos rotativos', 'Other rotational grazing', '2024-06-03 20:55:40.348+00', '2024-06-03 20:55:40.348+00', false);


--
-- TOC entry 5206 (class 0 OID 133815)
-- Dependencies: 377
-- Data for Name: refGreenHouseGasesGwp; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."refGreenHouseGasesGwp" VALUES (0, 'C02', 'Dióxido de carbono', 'Carbon Dioxide', 1, 'AR5', '2024-08-13 15:11:54.216+00', '2024-08-13 15:11:54.216+00');
INSERT INTO public."refGreenHouseGasesGwp" VALUES (1, 'CH4', 'Metano', 'Methane', 28, 'AR5', '2024-08-13 15:11:54.216+00', '2024-08-13 15:11:54.216+00');
INSERT INTO public."refGreenHouseGasesGwp" VALUES (2, 'N2O', 'Oxido nitroso', 'Nitrous oxide', 265, 'AR5', '2024-08-13 15:11:54.216+00', '2024-08-13 15:11:54.216+00');


--
-- TOC entry 5169 (class 0 OID 18487)
-- Dependencies: 319
-- Data for Name: refHorizonCode; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."refHorizonCode" VALUES (6, 'R', 'Roca madre, contacto lítico', 'R', 'Roca madre, contacto lítico', '', '', '2024-06-03 20:55:40.433+00', '2024-06-03 20:55:40.433+00', false);
INSERT INTO public."refHorizonCode" VALUES (7, 'Ca', 'Horizonte cálcico, con acumulación de carbonatos', 'Ca', 'Horizonte cálcico, con acumulación de carbonatos', '', '', '2024-06-03 20:55:40.433+00', '2024-06-03 20:55:40.433+00', false);
INSERT INTO public."refHorizonCode" VALUES (0, 'Ao', 'Horizonte superficial orgánico (detritos)', 'Ao', 'Horizonte superficial orgánico (detritos)', '', '', '2024-06-03 20:55:40.433+00', '2024-06-03 20:55:40.433+00', false);
INSERT INTO public."refHorizonCode" VALUES (1, 'A', 'Horizonte superficial mas oscuro', 'A', 'Horizonte superficial mas oscuro', '', '', '2024-06-03 20:55:40.433+00', '2024-06-03 20:55:40.433+00', false);
INSERT INTO public."refHorizonCode" VALUES (2, 'A2', 'Horizonte mas claro, eluvial', 'A2', 'Horizonte mas claro, eluvial', '', '', '2024-06-03 20:55:40.433+00', '2024-06-03 20:55:40.433+00', false);
INSERT INTO public."refHorizonCode" VALUES (3, 'B', 'Horizonte de iluviación, usualmente con materiales arcillosos', 'B', 'Horizonte de iluviación, usualmente con materiales arcillosos', '', '', '2024-06-03 20:55:40.433+00', '2024-06-03 20:55:40.433+00', false);
INSERT INTO public."refHorizonCode" VALUES (4, 'AC', 'Horizonte que transiciona gradualmente entre la superficie y el material madre', 'AC', 'Horizonte que transiciona gradualmente entre la superficie y el material madre', '', '', '2024-06-03 20:55:40.433+00', '2024-06-03 20:55:40.433+00', false);
INSERT INTO public."refHorizonCode" VALUES (5, 'C', 'Horizonte poco alterado, similar al material madre', 'C', 'Horizonte poco alterado, similar al material madre', '', '', '2024-06-03 20:55:40.433+00', '2024-06-03 20:55:40.433+00', false);


--
-- TOC entry 5113 (class 0 OID 17689)
-- Dependencies: 234
-- Data for Name: refInstancesVerificationStatus; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."refInstancesVerificationStatus" VALUES (0, 'Rechazado', 'Rejected', '2024-06-03 20:55:40.623+00', '2024-06-03 20:55:40.623+00', false);
INSERT INTO public."refInstancesVerificationStatus" VALUES (1, 'Observado', 'Observed', '2024-06-03 20:55:40.623+00', '2024-06-03 20:55:40.623+00', false);
INSERT INTO public."refInstancesVerificationStatus" VALUES (2, 'Aprobado', 'Approved', '2024-06-03 20:55:40.623+00', '2024-06-03 20:55:40.623+00', false);


--
-- TOC entry 5171 (class 0 OID 18496)
-- Dependencies: 321
-- Data for Name: refIrrigationType; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."refIrrigationType" VALUES (0, 'Riego por superficie', 'Riego por superficie', '', '2024-06-03 20:55:40.376+00', '2024-06-03 20:55:40.376+00', false);
INSERT INTO public."refIrrigationType" VALUES (1, 'Riego presurizado', 'Riego presurizado', '', '2024-06-03 20:55:40.376+00', '2024-06-03 20:55:40.376+00', false);


--
-- TOC entry 5173 (class 0 OID 18505)
-- Dependencies: 323
-- Data for Name: refLivestockRaisingTypes; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."refLivestockRaisingTypes" VALUES (0, 'Cría', 'Cría', '', '2024-06-03 20:55:40.281+00', '2024-06-03 20:55:40.281+00', false);
INSERT INTO public."refLivestockRaisingTypes" VALUES (1, 'Recría', 'Recría', '', '2024-06-03 20:55:40.281+00', '2024-06-03 20:55:40.281+00', false);
INSERT INTO public."refLivestockRaisingTypes" VALUES (2, 'Invernada', 'Invernada', '', '2024-06-03 20:55:40.281+00', '2024-06-03 20:55:40.281+00', false);
INSERT INTO public."refLivestockRaisingTypes" VALUES (3, 'Tambo', 'Tambo', '', '2024-06-03 20:55:40.281+00', '2024-06-03 20:55:40.281+00', false);
INSERT INTO public."refLivestockRaisingTypes" VALUES (4, 'Feedlot', 'Feedlot', 'Feedlot', '2024-06-03 20:55:40.281+00', '2024-06-03 20:55:40.281+00', false);


--
-- TOC entry 5214 (class 0 OID 559939)
-- Dependencies: 391
-- Data for Name: refLocationConfirmationType; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."refLocationConfirmationType" VALUES (0, 'MDC', 'MDC', 'MDC', false, '2024-11-27 22:09:34.094+00', '2024-11-27 22:09:34.094+00');
INSERT INTO public."refLocationConfirmationType" VALUES (1, 'Dispositivo GPS externo', 'Dispositivo GPS externo', 'External GPS device', false, '2024-11-27 22:09:34.094+00', '2024-11-27 22:09:34.094+00');
INSERT INTO public."refLocationConfirmationType" VALUES (2, 'Manual', 'Manual', 'Manual', false, '2024-11-27 22:09:34.094+00', '2024-11-27 22:09:34.094+00');


--
-- TOC entry 5212 (class 0 OID 559929)
-- Dependencies: 389
-- Data for Name: refLocationMovedReason; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."refLocationMovedReason" VALUES (0, 'Inaccesible', 'Inaccesible', 'Inaccessible', false, '2024-11-27 22:09:34.09+00', '2024-11-27 22:09:34.09+00');
INSERT INTO public."refLocationMovedReason" VALUES (1, 'Cambio de uso del terreno', 'Cambio de uso del terreno', 'Land use changed', false, '2024-11-27 22:09:34.09+00', '2024-11-27 22:09:34.09+00');
INSERT INTO public."refLocationMovedReason" VALUES (2, 'No representativo del estrato', 'No representativo del estrato', 'Classification mismatch', false, '2024-11-27 22:09:34.09+00', '2024-11-27 22:09:34.09+00');


--
-- TOC entry 5198 (class 0 OID 92725)
-- Dependencies: 369
-- Data for Name: refMetricStatus; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."refMetricStatus" VALUES (0, 'Abierta', 'Abierta', 'Open', '2024-07-25 14:32:48.717+00', '2024-07-25 14:32:48.717+00', false);
INSERT INTO public."refMetricStatus" VALUES (1, 'Cerrada', 'Cerrada', 'Closed', '2024-07-25 14:32:48.717+00', '2024-07-25 14:32:48.717+00', false);


--
-- TOC entry 5175 (class 0 OID 18514)
-- Dependencies: 325
-- Data for Name: refMineralFertilizerType; Type: TABLE DATA; Schema: public; Owner: postgres
--

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


--
-- TOC entry 5128 (class 0 OID 18182)
-- Dependencies: 272
-- Data for Name: refMonitoringReportStatus; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."refMonitoringReportStatus" VALUES (0, 'En curso', 'primary', '2024-06-03 20:55:40.268+00', '2024-06-03 20:55:40.268+00', false);
INSERT INTO public."refMonitoringReportStatus" VALUES (1, 'Finalizado', 'success', '2024-06-03 20:55:40.268+00', '2024-06-03 20:55:40.268+00', false);


--
-- TOC entry 5177 (class 0 OID 18523)
-- Dependencies: 327
-- Data for Name: refOrganicFertilizerType; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."refOrganicFertilizerType" VALUES (0, 'Compost', 'Compost', 'Compost', '2024-06-03 20:55:40.373+00', '2024-06-03 20:55:40.373+00', false);
INSERT INTO public."refOrganicFertilizerType" VALUES (1, 'Estiercol', 'Estiercol', 'Manure', '2024-06-03 20:55:40.373+00', '2024-06-03 20:55:40.373+00', false);


--
-- TOC entry 5179 (class 0 OID 18532)
-- Dependencies: 329
-- Data for Name: refOvineCattle; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."refOvineCattle" VALUES (0, 'Oveja', 'Oveja', 'Sheep', '2024-06-03 20:55:40.317+00', '2024-06-03 20:55:40.317+00', false);
INSERT INTO public."refOvineCattle" VALUES (1, 'Carnero', 'Carnero', 'Ram', '2024-06-03 20:55:40.317+00', '2024-06-03 20:55:40.317+00', false);
INSERT INTO public."refOvineCattle" VALUES (2, 'Cordero 0-1 años', 'Cordero 0-1 años', 'Lamb 0-1 years', '2024-06-03 20:55:40.317+00', '2024-06-03 20:55:40.317+00', false);
INSERT INTO public."refOvineCattle" VALUES (3, 'Cordero 1-2 años', 'Cordero 1-2 años', 'Lamb 1-2 years', '2024-06-03 20:55:40.317+00', '2024-06-03 20:55:40.317+00', false);


--
-- TOC entry 5181 (class 0 OID 18541)
-- Dependencies: 331
-- Data for Name: refPasturesFamily; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."refPasturesFamily" VALUES (0, 'Graminea', 'Graminea', '', '2024-06-03 20:55:40.292+00', '2024-06-03 20:55:40.292+00', false);
INSERT INTO public."refPasturesFamily" VALUES (1, 'Leguminosa', 'Leguminosa', '', '2024-06-03 20:55:40.292+00', '2024-06-03 20:55:40.292+00', false);


--
-- TOC entry 5183 (class 0 OID 18550)
-- Dependencies: 333
-- Data for Name: refPasturesGrowthTypes; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."refPasturesGrowthTypes" VALUES (0, 'Anual', 'Anual', 'Annual', '2024-06-03 20:55:40.285+00', '2024-06-03 20:55:40.285+00', false);
INSERT INTO public."refPasturesGrowthTypes" VALUES (1, 'Perenne', 'Perenne', '', '2024-06-03 20:55:40.285+00', '2024-06-03 20:55:40.285+00', false);


--
-- TOC entry 5185 (class 0 OID 18559)
-- Dependencies: 335
-- Data for Name: refPasturesTypes; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."refPasturesTypes" VALUES (0, 'Natural', 'Natural', 'Natural', '2024-06-03 20:55:40.289+00', '2024-06-03 20:55:40.289+00', false);
INSERT INTO public."refPasturesTypes" VALUES (1, 'Implantado', 'Implantado', 'Planted', '2024-06-03 20:55:40.289+00', '2024-06-03 20:55:40.289+00', false);


--
-- TOC entry 5229 (class 0 OID 1346305)
-- Dependencies: 423
-- Data for Name: refRandomizer; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."refRandomizer" VALUES (0, 'Randomizador v1.0.0', 'Randomizador v1.0.0', 'Randomizer v1.0.0', '1.0.0', 'randomPointsInPolygonV1', false, '2025-08-20 19:03:41.348+00', '2025-08-20 19:03:41.348+00');
INSERT INTO public."refRandomizer" VALUES (1, 'Randomizador v2.0.0', 'Randomizador v2.0.0', 'Randomizer v2.0.0', '2.0.0', 'randomPointsInPolygonV2', false, '2025-08-20 19:03:41.348+00', '2025-08-20 19:03:41.348+00');
INSERT INTO public."refRandomizer" VALUES (2, 'Randomizador v3.0.0', 'Randomizador v3.0.0', 'Randomizer v3.0.0', '3.0.0', 'randomPointsInPolygonV3', false, '2025-08-20 19:03:41.348+00', '2025-08-20 19:03:41.348+00');
INSERT INTO public."refRandomizer" VALUES (3, 'Randomizador v4.0.0', 'Randomizador v4.0.0', 'Randomizer v4.0.0', '4.0.0', 'generate_random_points', false, '2025-08-20 19:03:41.348+00', '2025-08-20 19:03:41.348+00');


--
-- TOC entry 5219 (class 0 OID 830217)
-- Dependencies: 396
-- Data for Name: refSamplingNumbers; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."refSamplingNumbers" VALUES (0, '0-Línea de base', '0-Línea de base', '0-Baseline', false, '2025-02-17 20:55:31.151+00', '2025-02-17 20:55:31.151+00');
INSERT INTO public."refSamplingNumbers" VALUES (1, '1-Primer re-muestreo', '1-Primer re-muestreo', '1-First re-sampling', false, '2025-02-17 20:55:31.151+00', '2025-02-17 20:55:31.151+00');
INSERT INTO public."refSamplingNumbers" VALUES (2, '2-Segundo re-muestreo', '2-Segundo re-muestreo', '2-Second re-sampling', false, '2025-02-17 20:55:31.151+00', '2025-02-17 20:55:31.151+00');


--
-- TOC entry 5231 (class 0 OID 1420521)
-- Dependencies: 425
-- Data for Name: refSoilSamplingDisturbance; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."refSoilSamplingDisturbance" VALUES (1, 'Intacta', 'Intacta', 'Intacta', 'Intacta', 'Undisturbed', 'Undisturbed', 'Intacta', 'Intacta', false, '2025-09-10 19:18:23.036+00', '2025-09-10 19:18:23.036+00');
INSERT INTO public."refSoilSamplingDisturbance" VALUES (2, 'No intacta', 'No intacta', 'No intacta', 'No intacta', 'Disturbed', 'Disturbed', 'No intacta', 'No intacta', false, '2025-09-10 19:18:23.036+00', '2025-09-10 19:18:23.036+00');


--
-- TOC entry 5233 (class 0 OID 1420531)
-- Dependencies: 427
-- Data for Name: refSoilSamplingTools; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."refSoilSamplingTools" VALUES (1, 'Pala', 'Pala', 'Pala', 'Pala', 'Shovel', 'Shovel', 'Pala', 'Pala', false, '2025-09-10 19:18:23.032+00', '2025-09-10 19:18:23.032+00');
INSERT INTO public."refSoilSamplingTools" VALUES (2, 'Calador', 'Calador', 'Calador', 'Calador', 'Probe', 'Probe', 'Calador', 'Calador', false, '2025-09-10 19:18:23.032+00', '2025-09-10 19:18:23.032+00');


--
-- TOC entry 5187 (class 0 OID 18568)
-- Dependencies: 337
-- Data for Name: refSoilTexture; Type: TABLE DATA; Schema: public; Owner: postgres
--

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


--
-- TOC entry 5189 (class 0 OID 18577)
-- Dependencies: 339
-- Data for Name: refStructureGrade; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."refStructureGrade" VALUES (0, 'de', 'Débil', 'de', 'Débil', 'we', 'Weak', '2024-06-03 20:55:40.443+00', '2024-06-03 20:55:40.443+00', false);
INSERT INTO public."refStructureGrade" VALUES (1, 'mo', 'Moderada', 'mo', 'Moderada', 'mo', 'Moderate', '2024-06-03 20:55:40.443+00', '2024-06-03 20:55:40.443+00', false);
INSERT INTO public."refStructureGrade" VALUES (2, 'fu', 'Fuerte', 'fu', 'Fuerte', 'st', 'Strong', '2024-06-03 20:55:40.443+00', '2024-06-03 20:55:40.443+00', false);


--
-- TOC entry 5191 (class 0 OID 18586)
-- Dependencies: 341
-- Data for Name: refStructureSize; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."refStructureSize" VALUES (0, 'mf', 'Muy fina', 'mf', 'Muy fina', '', '', '2024-06-03 20:55:40.448+00', '2024-06-03 20:55:40.448+00', false);
INSERT INTO public."refStructureSize" VALUES (1, 'me', 'Mediana', 'me', 'Mediana', '', '', '2024-06-03 20:55:40.448+00', '2024-06-03 20:55:40.448+00', false);
INSERT INTO public."refStructureSize" VALUES (2, 'gr', 'Gruesa', 'gr', 'Gruesa', '', '', '2024-06-03 20:55:40.448+00', '2024-06-03 20:55:40.448+00', false);
INSERT INTO public."refStructureSize" VALUES (3, 'mg', 'Muy gruesa', 'mg', 'Muy gruesa', '', '', '2024-06-03 20:55:40.448+00', '2024-06-03 20:55:40.448+00', false);


--
-- TOC entry 5193 (class 0 OID 18595)
-- Dependencies: 343
-- Data for Name: refStructureType; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."refStructureType" VALUES (0, 'mig', 'Migajosa', 'mig', 'Migajosa', '', '', '2024-06-03 20:55:40.451+00', '2024-06-03 20:55:40.451+00', false);
INSERT INTO public."refStructureType" VALUES (1, 'gran', 'Granular', 'gran', 'Granular', '', '', '2024-06-03 20:55:40.451+00', '2024-06-03 20:55:40.451+00', false);
INSERT INTO public."refStructureType" VALUES (2, 'ba', 'Bloques angulares', 'ba', 'Bloques angulares', '', '', '2024-06-03 20:55:40.451+00', '2024-06-03 20:55:40.451+00', false);
INSERT INTO public."refStructureType" VALUES (3, 'bs', 'Bloques subangulares', 'bs', 'Bloques subangulares', '', '', '2024-06-03 20:55:40.451+00', '2024-06-03 20:55:40.451+00', false);
INSERT INTO public."refStructureType" VALUES (4, 'prs', 'Prismática', 'prs.', 'Prismática', '', '', '2024-06-03 20:55:40.451+00', '2024-06-03 20:55:40.451+00', false);
INSERT INTO public."refStructureType" VALUES (5, 'col', 'Columnar', 'col', 'Columnar', '', '', '2024-06-03 20:55:40.451+00', '2024-06-03 20:55:40.451+00', false);
INSERT INTO public."refStructureType" VALUES (6, 'lam', 'Laminar', 'lam', 'Laminar', '', '', '2024-06-03 20:55:40.451+00', '2024-06-03 20:55:40.451+00', false);
INSERT INTO public."refStructureType" VALUES (7, 'suel', 'De grano suelto', 'suel', 'De grano suelto', '', '', '2024-06-03 20:55:40.451+00', '2024-06-03 20:55:40.451+00', false);
INSERT INTO public."refStructureType" VALUES (8, 'masi', 'Masiva (sin estructura)', 'masi', 'Masiva (sin estructura)', '', '', '2024-06-03 20:55:40.451+00', '2024-06-03 20:55:40.451+00', false);


--
-- TOC entry 5125 (class 0 OID 18052)
-- Dependencies: 263
-- Data for Name: refTaskStatus; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."refTaskStatus" VALUES (0, 'Pendiente', '2024-06-03 20:55:40.26+00', '2024-06-03 20:55:40.26+00', false);
INSERT INTO public."refTaskStatus" VALUES (1, 'En curso', '2024-06-03 20:55:40.26+00', '2024-06-03 20:55:40.26+00', false);
INSERT INTO public."refTaskStatus" VALUES (2, 'Finalizado', '2024-06-03 20:55:40.26+00', '2024-06-03 20:55:40.26+00', false);
INSERT INTO public."refTaskStatus" VALUES (3, 'Cancelado', '2024-06-03 20:55:40.26+00', '2024-06-03 20:55:40.26+00', false);
INSERT INTO public."refTaskStatus" VALUES (4, 'Omitido', '2024-06-03 20:55:40.26+00', '2024-06-03 20:55:40.26+00', false);


--
-- TOC entry 5195 (class 0 OID 18604)
-- Dependencies: 345
-- Data for Name: refTillageType; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."refTillageType" VALUES (0, 'Rastra', 'Rastra', '', '2024-06-03 20:55:40.363+00', '2024-06-03 20:55:40.363+00', false);
INSERT INTO public."refTillageType" VALUES (1, 'Disco', 'Disco', '', '2024-06-03 20:55:40.363+00', '2024-06-03 20:55:40.363+00', false);
INSERT INTO public."refTillageType" VALUES (2, 'Cincel', 'Cincel', '', '2024-06-03 20:55:40.363+00', '2024-06-03 20:55:40.363+00', false);
INSERT INTO public."refTillageType" VALUES (3, 'Rolo', 'Rolo', '', '2024-06-03 20:55:40.363+00', '2024-06-03 20:55:40.363+00', false);
INSERT INTO public."refTillageType" VALUES (4, 'Escardillo', 'Escardillo', 'Hoe', '2024-07-25 19:39:48.98+00', '2024-07-25 19:39:48.98+00', false);
INSERT INTO public."refTillageType" VALUES (5, 'Subsolador', 'Subsolador', 'Subsoiler', '2024-07-25 19:39:48.98+00', '2024-07-25 19:39:48.98+00', false);


--
-- TOC entry 5208 (class 0 OID 133826)
-- Dependencies: 379
-- Data for Name: refUnits; Type: TABLE DATA; Schema: public; Owner: postgres
--

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


--
-- TOC entry 5117 (class 0 OID 17730)
-- Dependencies: 239
-- Data for Name: refUserRole; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."refUserRole" VALUES (0, 'Field Technician', '2024-06-03 20:55:40.459+00', '2024-06-03 20:55:40.459+00', false);
INSERT INTO public."refUserRole" VALUES (1, 'Auditor', '2024-06-03 20:55:40.459+00', '2024-06-03 20:55:40.459+00', false);
INSERT INTO public."refUserRole" VALUES (2, 'Admin', '2024-06-03 20:55:40.459+00', '2024-06-03 20:55:40.459+00', false);


--
-- TOC entry 5196 (class 0 OID 18612)
-- Dependencies: 346
-- Data for Name: relInstanceMonitoringPeriod; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."relInstanceMonitoringPeriod" VALUES ('b9163b22-50b4-457f-ab1b-00ff1f6d4027', '57f7321f-69c8-46b1-9072-c71f25f5fbe0', '18b8c3ee-a463-4bfd-8711-732c11ae81e6', false, 'ruuts-api', NULL, '2025-04-04 18:43:32.589+00', '2025-04-04 18:43:32.589+00');
INSERT INTO public."relInstanceMonitoringPeriod" VALUES ('63d0e7b0-9be9-4a21-9f98-0d2278769681', 'b56fa009-9feb-4fc5-bec6-ee09603d20fc', '18b8c3ee-a463-4bfd-8711-732c11ae81e6', false, 'ruuts-api', NULL, '2025-04-04 18:43:32.589+00', '2025-04-04 18:43:32.589+00');
INSERT INTO public."relInstanceMonitoringPeriod" VALUES ('11ee4ecc-322e-422a-ae48-8b6cc7376a91', '48b27017-1bf1-4c22-905e-224e48ae13a4', '18b8c3ee-a463-4bfd-8711-732c11ae81e6', false, 'ruuts-api-migration-20251027', 'ruuts-api-migration-20251027', '2025-10-27 20:43:59.576856+00', '2025-10-27 20:43:59.576856+00');
INSERT INTO public."relInstanceMonitoringPeriod" VALUES ('8bbb5164-cd0e-4117-b063-76c78d577fb3', 'e4d10d4f-3649-4f56-8627-01af00b0019f', '18b8c3ee-a463-4bfd-8711-732c11ae81e6', false, 'ruuts-api-migration-20251027', 'ruuts-api-migration-20251027', '2025-10-27 20:43:59.576856+00', '2025-10-27 20:43:59.576856+00');
INSERT INTO public."relInstanceMonitoringPeriod" VALUES ('84832674-de59-479d-b355-a03d29ba18ad', 'fc4defd8-f558-46ef-bc87-f843b00344ea', '18b8c3ee-a463-4bfd-8711-732c11ae81e6', false, 'ruuts-api-migration-20251027', NULL, '2025-10-27 20:43:59.576856+00', '2025-10-28 18:40:18.616128+00');
INSERT INTO public."relInstanceMonitoringPeriod" VALUES ('542cc549-7353-44b7-9ada-dcc92f689af5', '830bf9ba-3623-4b77-80a9-a42b2ba85e55', '18b8c3ee-a463-4bfd-8711-732c11ae81e6', true, 'fsrodrig', 'fsrodrig', '2025-10-28 18:46:47.781502+00', '2025-10-28 18:49:14.838193+00');


--
-- TOC entry 5221 (class 0 OID 830235)
-- Dependencies: 400
-- Data for Name: relSOCProtocols; Type: TABLE DATA; Schema: public; Owner: postgres
--

INSERT INTO public."relSOCProtocols" VALUES (0, 'Grass 6.0', false, '2025-02-17 20:55:31.03+00', '2025-02-17 20:55:31.03+00');
INSERT INTO public."relSOCProtocols" VALUES (1, 'Anterior a Grass 6.0', false, '2025-06-05 18:28:51.101+00', '2025-06-05 18:28:51.101+00');



--
-- TOC entry 5771 (class 0 OID 0)
-- Dependencies: 397
-- Name: RelLaboratory_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."RelLaboratory_id_seq"', 1, false);


--
-- TOC entry 5772 (class 0 OID 0)
-- Dependencies: 265
-- Name: monitoringWorkflows_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."monitoringWorkflows_id_seq"', 1, false);


--
-- TOC entry 5773 (class 0 OID 0)
-- Dependencies: 280
-- Name: refAmmendmendType_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refAmmendmendType_id_seq"', 1, false);


--
-- TOC entry 5774 (class 0 OID 0)
-- Dependencies: 282
-- Name: refBovineCattle_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refBovineCattle_id_seq"', 1, false);


--
-- TOC entry 5775 (class 0 OID 0)
-- Dependencies: 284
-- Name: refBubalineCattle_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refBubalineCattle_id_seq"', 1, false);


--
-- TOC entry 5776 (class 0 OID 0)
-- Dependencies: 286
-- Name: refCamelidCattle_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refCamelidCattle_id_seq"', 1, false);


--
-- TOC entry 5777 (class 0 OID 0)
-- Dependencies: 288
-- Name: refCaprineCattle_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refCaprineCattle_id_seq"', 1, false);


--
-- TOC entry 5778 (class 0 OID 0)
-- Dependencies: 290
-- Name: refCattleClass_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refCattleClass_id_seq"', 1, false);


--
-- TOC entry 5779 (class 0 OID 0)
-- Dependencies: 370
-- Name: refCattleEmissionsFactors_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refCattleEmissionsFactors_id_seq"', 1, false);


--
-- TOC entry 5780 (class 0 OID 0)
-- Dependencies: 372
-- Name: refCattleEquivalences_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refCattleEquivalences_id_seq"', 1, false);


--
-- TOC entry 5781 (class 0 OID 0)
-- Dependencies: 292
-- Name: refCattleSubClass_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refCattleSubClass_id_seq"', 1, false);


--
-- TOC entry 5782 (class 0 OID 0)
-- Dependencies: 294
-- Name: refCattleType_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refCattleType_id_seq"', 1, false);


--
-- TOC entry 5783 (class 0 OID 0)
-- Dependencies: 296
-- Name: refCervidCattle_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refCervidCattle_id_seq"', 1, false);


--
-- TOC entry 5784 (class 0 OID 0)
-- Dependencies: 298
-- Name: refCropType_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refCropType_id_seq"', 1, false);


--
-- TOC entry 5785 (class 0 OID 0)
-- Dependencies: 403
-- Name: refDAPMethods_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refDAPMethods_id_seq"', 1, false);


--
-- TOC entry 5786 (class 0 OID 0)
-- Dependencies: 236
-- Name: refDataCollectionStatementStatus_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refDataCollectionStatementStatus_id_seq"', 1, false);


--
-- TOC entry 5787 (class 0 OID 0)
-- Dependencies: 300
-- Name: refDegreeDegradationSoil_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refDegreeDegradationSoil_id_seq"', 1, false);


--
-- TOC entry 5788 (class 0 OID 0)
-- Dependencies: 245
-- Name: refDocumentType_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refDocumentType_id_seq"', 1, false);


--
-- TOC entry 5789 (class 0 OID 0)
-- Dependencies: 383
-- Name: refEntityDiscardReason_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refEntityDiscardReason_id_seq"', 1, false);


--
-- TOC entry 5790 (class 0 OID 0)
-- Dependencies: 247
-- Name: refEntityType_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refEntityType_id_seq"', 1, false);


--
-- TOC entry 5791 (class 0 OID 0)
-- Dependencies: 302
-- Name: refEquineCattle_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refEquineCattle_id_seq"', 1, false);


--
-- TOC entry 5792 (class 0 OID 0)
-- Dependencies: 304
-- Name: refExclusionAreaType_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refExclusionAreaType_id_seq"', 1, false);


--
-- TOC entry 5793 (class 0 OID 0)
-- Dependencies: 392
-- Name: refFieldRelocationMethod_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refFieldRelocationMethod_id_seq"', 1, false);


--
-- TOC entry 5794 (class 0 OID 0)
-- Dependencies: 306
-- Name: refFieldUsage_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refFieldUsage_id_seq"', 1, false);


--
-- TOC entry 5795 (class 0 OID 0)
-- Dependencies: 255
-- Name: refFindingType_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refFindingType_id_seq"', 1, false);


--
-- TOC entry 5796 (class 0 OID 0)
-- Dependencies: 308
-- Name: refForageSource_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refForageSource_id_seq"', 1, false);


--
-- TOC entry 5797 (class 0 OID 0)
-- Dependencies: 410
-- Name: refForageUseIntensity_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refForageUseIntensity_id_seq"', 1, false);


--
-- TOC entry 5798 (class 0 OID 0)
-- Dependencies: 412
-- Name: refForageUsePattern_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refForageUsePattern_id_seq"', 1, false);


--
-- TOC entry 5799 (class 0 OID 0)
-- Dependencies: 374
-- Name: refFuelEmissionsFactors_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refFuelEmissionsFactors_id_seq"', 1, false);


--
-- TOC entry 5800 (class 0 OID 0)
-- Dependencies: 310
-- Name: refFuelType_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refFuelType_id_seq"', 1, false);


--
-- TOC entry 5801 (class 0 OID 0)
-- Dependencies: 312
-- Name: refGrazingIntensityTypes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refGrazingIntensityTypes_id_seq"', 1, false);


--
-- TOC entry 5802 (class 0 OID 0)
-- Dependencies: 314
-- Name: refGrazingPlanType_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refGrazingPlanType_id_seq"', 1, false);


--
-- TOC entry 5803 (class 0 OID 0)
-- Dependencies: 316
-- Name: refGrazingType_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refGrazingType_id_seq"', 1, false);


--
-- TOC entry 5804 (class 0 OID 0)
-- Dependencies: 376
-- Name: refGreenHouseGasesGwp_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refGreenHouseGasesGwp_id_seq"', 1, false);


--
-- TOC entry 5805 (class 0 OID 0)
-- Dependencies: 318
-- Name: refHorizonCode_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refHorizonCode_id_seq"', 1, false);


--
-- TOC entry 5806 (class 0 OID 0)
-- Dependencies: 320
-- Name: refIrrigationType_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refIrrigationType_id_seq"', 1, false);


--
-- TOC entry 5807 (class 0 OID 0)
-- Dependencies: 322
-- Name: refLivestockRaisingTypes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refLivestockRaisingTypes_id_seq"', 1, false);


--
-- TOC entry 5808 (class 0 OID 0)
-- Dependencies: 390
-- Name: refLocationConfirmationType_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refLocationConfirmationType_id_seq"', 1, false);


--
-- TOC entry 5809 (class 0 OID 0)
-- Dependencies: 388
-- Name: refLocationMovedReason_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refLocationMovedReason_id_seq"', 1, false);


--
-- TOC entry 5810 (class 0 OID 0)
-- Dependencies: 368
-- Name: refMetricStatus_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refMetricStatus_id_seq"', 1, false);


--
-- TOC entry 5811 (class 0 OID 0)
-- Dependencies: 324
-- Name: refMineralFertilizerType_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refMineralFertilizerType_id_seq"', 1, false);


--
-- TOC entry 5812 (class 0 OID 0)
-- Dependencies: 271
-- Name: refMonitoringReportStatus_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refMonitoringReportStatus_id_seq"', 1, false);


--
-- TOC entry 5813 (class 0 OID 0)
-- Dependencies: 326
-- Name: refOrganicFertilizerType_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refOrganicFertilizerType_id_seq"', 1, false);


--
-- TOC entry 5814 (class 0 OID 0)
-- Dependencies: 328
-- Name: refOvineCattle_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refOvineCattle_id_seq"', 1, false);


--
-- TOC entry 5815 (class 0 OID 0)
-- Dependencies: 330
-- Name: refPasturesFamily_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refPasturesFamily_id_seq"', 1, false);


--
-- TOC entry 5816 (class 0 OID 0)
-- Dependencies: 332
-- Name: refPasturesGrowthTypes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refPasturesGrowthTypes_id_seq"', 1, false);


--
-- TOC entry 5817 (class 0 OID 0)
-- Dependencies: 334
-- Name: refPasturesTypes_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refPasturesTypes_id_seq"', 1, false);


--
-- TOC entry 5818 (class 0 OID 0)
-- Dependencies: 422
-- Name: refRandomizer_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refRandomizer_id_seq"', 1, false);


--
-- TOC entry 5819 (class 0 OID 0)
-- Dependencies: 395
-- Name: refSamplingNumbers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refSamplingNumbers_id_seq"', 1, false);


--
-- TOC entry 5820 (class 0 OID 0)
-- Dependencies: 424
-- Name: refSoilSamplingDisturbance_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refSoilSamplingDisturbance_id_seq"', 1, false);


--
-- TOC entry 5821 (class 0 OID 0)
-- Dependencies: 426
-- Name: refSoilSamplingTools_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refSoilSamplingTools_id_seq"', 1, false);


--
-- TOC entry 5822 (class 0 OID 0)
-- Dependencies: 336
-- Name: refSoilTexture_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refSoilTexture_id_seq"', 1, false);


--
-- TOC entry 5823 (class 0 OID 0)
-- Dependencies: 338
-- Name: refStructureGrade_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refStructureGrade_id_seq"', 1, false);


--
-- TOC entry 5824 (class 0 OID 0)
-- Dependencies: 340
-- Name: refStructureSize_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refStructureSize_id_seq"', 1, false);


--
-- TOC entry 5825 (class 0 OID 0)
-- Dependencies: 342
-- Name: refStructureType_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refStructureType_id_seq"', 1, false);


--
-- TOC entry 5826 (class 0 OID 0)
-- Dependencies: 262
-- Name: refTaskStatus_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refTaskStatus_id_seq"', 1, false);


--
-- TOC entry 5827 (class 0 OID 0)
-- Dependencies: 344
-- Name: refTillageType_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refTillageType_id_seq"', 1, false);


--
-- TOC entry 5828 (class 0 OID 0)
-- Dependencies: 378
-- Name: refUnits_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refUnits_id_seq"', 1, false);


--
-- TOC entry 5829 (class 0 OID 0)
-- Dependencies: 238
-- Name: refUserRole_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."refUserRole_id_seq"', 1, false);


--
-- TOC entry 5830 (class 0 OID 0)
-- Dependencies: 399
-- Name: relSOCProtocols_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public."relSOCProtocols_id_seq"', 1, false);


--
-- TOC entry 5277 (class 2606 OID 830233)
-- Name: RelLaboratory RelLaboratory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."RelLaboratory"
    ADD CONSTRAINT "RelLaboratory_pkey" PRIMARY KEY (id);


--
-- TOC entry 5056 (class 2606 OID 16388)
-- Name: SequelizeMeta SequelizeMeta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."SequelizeMeta"
    ADD CONSTRAINT "SequelizeMeta_pkey" PRIMARY KEY (name);


--
-- TOC entry 5082 (class 2606 OID 17704)
-- Name: carbonInstances carbonInstances_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."carbonInstances"
    ADD CONSTRAINT "carbonInstances_pkey" PRIMARY KEY (id);


--
-- TOC entry 5094 (class 2606 OID 17786)
-- Name: dataCollectionStatementHistory dataCollectionStatementHistory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."dataCollectionStatementHistory"
    ADD CONSTRAINT "dataCollectionStatementHistory_pkey" PRIMARY KEY (id);


--
-- TOC entry 5091 (class 2606 OID 17760)
-- Name: dataCollectionStatement dataCollectionStatement_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."dataCollectionStatement"
    ADD CONSTRAINT "dataCollectionStatement_pkey" PRIMARY KEY (id);


--
-- TOC entry 5096 (class 2606 OID 17817)
-- Name: deals deals_hubspotId_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deals
    ADD CONSTRAINT "deals_hubspotId_key" UNIQUE ("hubspotId");


--
-- TOC entry 5098 (class 2606 OID 17815)
-- Name: deals deals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deals
    ADD CONSTRAINT deals_pkey PRIMARY KEY (id);


--
-- TOC entry 5100 (class 2606 OID 17838)
-- Name: deforestedAreas deforestedAreas_farmId_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."deforestedAreas"
    ADD CONSTRAINT "deforestedAreas_farmId_key" UNIQUE ("farmId");


--
-- TOC entry 5102 (class 2606 OID 17836)
-- Name: deforestedAreas deforestedAreas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."deforestedAreas"
    ADD CONSTRAINT "deforestedAreas_pkey" PRIMARY KEY (id);


--
-- TOC entry 5261 (class 2606 OID 158368)
-- Name: discardedEntities discardedEntities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."discardedEntities"
    ADD CONSTRAINT "discardedEntities_pkey" PRIMARY KEY (id);


--
-- TOC entry 5108 (class 2606 OID 17870)
-- Name: documents documents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT documents_pkey PRIMARY KEY (id);


--
-- TOC entry 5112 (class 2606 OID 17903)
-- Name: exclusionAreaHistory exclusionAreaHistory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."exclusionAreaHistory"
    ADD CONSTRAINT "exclusionAreaHistory_pkey" PRIMARY KEY (id);


--
-- TOC entry 5110 (class 2606 OID 17889)
-- Name: exclusionAreas exclusionAreas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."exclusionAreas"
    ADD CONSTRAINT "exclusionAreas_pkey" PRIMARY KEY (id);


--
-- TOC entry 5116 (class 2606 OID 17946)
-- Name: farmOwners farmOwners_cuit_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."farmOwners"
    ADD CONSTRAINT "farmOwners_cuit_key" UNIQUE (cuit);


--
-- TOC entry 5118 (class 2606 OID 17944)
-- Name: farmOwners farmOwners_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."farmOwners"
    ADD CONSTRAINT "farmOwners_pkey" PRIMARY KEY (id);


--
-- TOC entry 5088 (class 2606 OID 17744)
-- Name: farmSubdivisions farmSubdivisions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."farmSubdivisions"
    ADD CONSTRAINT "farmSubdivisions_pkey" PRIMARY KEY (id);


--
-- TOC entry 5114 (class 2606 OID 17922)
-- Name: farmsHistory farmsHistory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."farmsHistory"
    ADD CONSTRAINT "farmsHistory_pkey" PRIMARY KEY (id);


--
-- TOC entry 5070 (class 2606 OID 17657)
-- Name: farms farms_hubspotId_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.farms
    ADD CONSTRAINT "farms_hubspotId_key" UNIQUE ("hubspotId");


--
-- TOC entry 5072 (class 2606 OID 17655)
-- Name: farms farms_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.farms
    ADD CONSTRAINT farms_pkey PRIMARY KEY (id);


--
-- TOC entry 5074 (class 2606 OID 17659)
-- Name: farms farms_shortName_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.farms
    ADD CONSTRAINT "farms_shortName_key" UNIQUE ("shortName");


--
-- TOC entry 5124 (class 2606 OID 17998)
-- Name: findingComments findingComments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."findingComments"
    ADD CONSTRAINT "findingComments_pkey" PRIMARY KEY (id);


--
-- TOC entry 5126 (class 2606 OID 18012)
-- Name: findingHistory findingHistory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."findingHistory"
    ADD CONSTRAINT "findingHistory_pkey" PRIMARY KEY (id);


--
-- TOC entry 5122 (class 2606 OID 17979)
-- Name: findings findings_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.findings
    ADD CONSTRAINT findings_pkey PRIMARY KEY (id);


--
-- TOC entry 5128 (class 2606 OID 18033)
-- Name: forestAreas forestAreas_farmId_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."forestAreas"
    ADD CONSTRAINT "forestAreas_farmId_key" UNIQUE ("farmId");


--
-- TOC entry 5130 (class 2606 OID 18031)
-- Name: forestAreas forestAreas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."forestAreas"
    ADD CONSTRAINT "forestAreas_pkey" PRIMARY KEY (id);


--
-- TOC entry 5132 (class 2606 OID 18050)
-- Name: formDefinitions formDefinitions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."formDefinitions"
    ADD CONSTRAINT "formDefinitions_pkey" PRIMARY KEY (id);


--
-- TOC entry 5062 (class 2606 OID 17629)
-- Name: hubs hubs_hubspotId_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hubs
    ADD CONSTRAINT "hubs_hubspotId_key" UNIQUE ("hubspotId");


--
-- TOC entry 5064 (class 2606 OID 17627)
-- Name: hubs hubs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hubs
    ADD CONSTRAINT hubs_pkey PRIMARY KEY (id);


--
-- TOC entry 5144 (class 2606 OID 18139)
-- Name: monitoringActivity monitoringActivity_key_monitoringEventId_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."monitoringActivity"
    ADD CONSTRAINT "monitoringActivity_key_monitoringEventId_key" UNIQUE (key, "monitoringEventId");


--
-- TOC entry 5146 (class 2606 OID 18137)
-- Name: monitoringActivity monitoringActivity_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."monitoringActivity"
    ADD CONSTRAINT "monitoringActivity_pkey" PRIMARY KEY (id);


--
-- TOC entry 5136 (class 2606 OID 18069)
-- Name: monitoringEvents monitoringEvents_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."monitoringEvents"
    ADD CONSTRAINT "monitoringEvents_pkey" PRIMARY KEY (id);


--
-- TOC entry 5148 (class 2606 OID 18175)
-- Name: monitoringPictures monitoringPictures_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."monitoringPictures"
    ADD CONSTRAINT "monitoringPictures_pkey" PRIMARY KEY (id);


--
-- TOC entry 5152 (class 2606 OID 18201)
-- Name: monitoringReports monitoringReports_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."monitoringReports"
    ADD CONSTRAINT "monitoringReports_pkey" PRIMARY KEY (id);


--
-- TOC entry 5281 (class 2606 OID 830250)
-- Name: monitoringSOCSamples monitoringSOCSamples_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."monitoringSOCSamples"
    ADD CONSTRAINT "monitoringSOCSamples_pkey" PRIMARY KEY (id);


--
-- TOC entry 5284 (class 2606 OID 830279)
-- Name: monitoringSOCSamplingAreaSamples monitoringSOCSamplingAreaSamples_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."monitoringSOCSamplingAreaSamples"
    ADD CONSTRAINT "monitoringSOCSamplingAreaSamples_pkey" PRIMARY KEY (id);


--
-- TOC entry 5290 (class 2606 OID 830313)
-- Name: monitoringSOCSitesSamples monitoringSOCSitesSamples_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."monitoringSOCSitesSamples"
    ADD CONSTRAINT "monitoringSOCSitesSamples_pkey" PRIMARY KEY (id);


--
-- TOC entry 5263 (class 2606 OID 207532)
-- Name: monitoringSitesHistory monitoringSitesHistory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."monitoringSitesHistory"
    ADD CONSTRAINT "monitoringSitesHistory_pkey" PRIMARY KEY (id, "monitoringSiteId");


--
-- TOC entry 5140 (class 2606 OID 18106)
-- Name: monitoringSites monitoringSites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."monitoringSites"
    ADD CONSTRAINT "monitoringSites_pkey" PRIMARY KEY (id);


--
-- TOC entry 5265 (class 2606 OID 207555)
-- Name: monitoringTasksHistory monitoringTasksHistory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."monitoringTasksHistory"
    ADD CONSTRAINT "monitoringTasksHistory_pkey" PRIMARY KEY (id, "monitoringTaskId");


--
-- TOC entry 5154 (class 2606 OID 18223)
-- Name: monitoringTasks monitoringTasks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."monitoringTasks"
    ADD CONSTRAINT "monitoringTasks_pkey" PRIMARY KEY (id);


--
-- TOC entry 5138 (class 2606 OID 18089)
-- Name: monitoringWorkflows monitoringWorkflows_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."monitoringWorkflows"
    ADD CONSTRAINT "monitoringWorkflows_pkey" PRIMARY KEY (id);


--
-- TOC entry 5156 (class 2606 OID 18242)
-- Name: otherPolygons otherPolygons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."otherPolygons"
    ADD CONSTRAINT "otherPolygons_pkey" PRIMARY KEY (id);


--
-- TOC entry 5158 (class 2606 OID 18256)
-- Name: otherSites otherSites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."otherSites"
    ADD CONSTRAINT "otherSites_pkey" PRIMARY KEY (id);


--
-- TOC entry 5162 (class 2606 OID 18284)
-- Name: paddocksHistory paddocksHistory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."paddocksHistory"
    ADD CONSTRAINT "paddocksHistory_pkey" PRIMARY KEY (id);


--
-- TOC entry 5160 (class 2606 OID 18270)
-- Name: paddocks paddocks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paddocks
    ADD CONSTRAINT paddocks_pkey PRIMARY KEY (id);


--
-- TOC entry 5164 (class 2606 OID 18304)
-- Name: programConfig programConfig_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."programConfig"
    ADD CONSTRAINT "programConfig_pkey" PRIMARY KEY (id);


--
-- TOC entry 5166 (class 2606 OID 854811)
-- Name: programConfig programId_unique_constraint; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."programConfig"
    ADD CONSTRAINT "programId_unique_constraint" UNIQUE ("programId");


--
-- TOC entry 5066 (class 2606 OID 17638)
-- Name: programMonitoringPeriods programMonitoringPeriods_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."programMonitoringPeriods"
    ADD CONSTRAINT "programMonitoringPeriods_pkey" PRIMARY KEY (id);


--
-- TOC entry 5068 (class 2606 OID 17640)
-- Name: programMonitoringPeriods programMonitoringPeriods_programId_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."programMonitoringPeriods"
    ADD CONSTRAINT "programMonitoringPeriods_programId_name_key" UNIQUE ("programId", name);


--
-- TOC entry 5060 (class 2606 OID 17619)
-- Name: programs programs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.programs
    ADD CONSTRAINT programs_pkey PRIMARY KEY (id);


--
-- TOC entry 5142 (class 2606 OID 18118)
-- Name: refActivityLayouts refActivityLayouts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refActivityLayouts"
    ADD CONSTRAINT "refActivityLayouts_pkey" PRIMARY KEY (id);


--
-- TOC entry 5168 (class 2606 OID 18318)
-- Name: refAmmendmendType refAmmendmendType_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refAmmendmendType"
    ADD CONSTRAINT "refAmmendmendType_pkey" PRIMARY KEY (id);


--
-- TOC entry 5170 (class 2606 OID 18327)
-- Name: refBovineCattle refBovineCattle_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refBovineCattle"
    ADD CONSTRAINT "refBovineCattle_pkey" PRIMARY KEY (id);


--
-- TOC entry 5172 (class 2606 OID 18336)
-- Name: refBubalineCattle refBubalineCattle_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refBubalineCattle"
    ADD CONSTRAINT "refBubalineCattle_pkey" PRIMARY KEY (id);


--
-- TOC entry 5174 (class 2606 OID 18345)
-- Name: refCamelidCattle refCamelidCattle_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refCamelidCattle"
    ADD CONSTRAINT "refCamelidCattle_pkey" PRIMARY KEY (id);


--
-- TOC entry 5176 (class 2606 OID 18354)
-- Name: refCaprineCattle refCaprineCattle_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refCaprineCattle"
    ADD CONSTRAINT "refCaprineCattle_pkey" PRIMARY KEY (id);


--
-- TOC entry 5178 (class 2606 OID 18363)
-- Name: refCattleClass refCattleClass_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refCattleClass"
    ADD CONSTRAINT "refCattleClass_pkey" PRIMARY KEY (id);


--
-- TOC entry 5247 (class 2606 OID 133781)
-- Name: refCattleEmissionsFactors refCattleEmissionsFactors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refCattleEmissionsFactors"
    ADD CONSTRAINT "refCattleEmissionsFactors_pkey" PRIMARY KEY (id);


--
-- TOC entry 5249 (class 2606 OID 133789)
-- Name: refCattleEquivalences refCattleEquivalences_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refCattleEquivalences"
    ADD CONSTRAINT "refCattleEquivalences_pkey" PRIMARY KEY (id);


--
-- TOC entry 5180 (class 2606 OID 18372)
-- Name: refCattleSubClass refCattleSubClass_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refCattleSubClass"
    ADD CONSTRAINT "refCattleSubClass_pkey" PRIMARY KEY (id);


--
-- TOC entry 5182 (class 2606 OID 18386)
-- Name: refCattleType refCattleType_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refCattleType"
    ADD CONSTRAINT "refCattleType_pkey" PRIMARY KEY (id);


--
-- TOC entry 5184 (class 2606 OID 18395)
-- Name: refCervidCattle refCervidCattle_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refCervidCattle"
    ADD CONSTRAINT "refCervidCattle_pkey" PRIMARY KEY (id);


--
-- TOC entry 5273 (class 2606 OID 690919)
-- Name: refCountries refCountries_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refCountries"
    ADD CONSTRAINT "refCountries_pkey" PRIMARY KEY (id);


--
-- TOC entry 5186 (class 2606 OID 18404)
-- Name: refCropType refCropType_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refCropType"
    ADD CONSTRAINT "refCropType_pkey" PRIMARY KEY (id);


--
-- TOC entry 5288 (class 2606 OID 830304)
-- Name: refDAPMethods refDAPMethods_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refDAPMethods"
    ADD CONSTRAINT "refDAPMethods_pkey" PRIMARY KEY (id);


--
-- TOC entry 5084 (class 2606 OID 17728)
-- Name: refDataCollectionStatementStatus refDataCollectionStatementStatus_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refDataCollectionStatementStatus"
    ADD CONSTRAINT "refDataCollectionStatementStatus_pkey" PRIMARY KEY (id);


--
-- TOC entry 5188 (class 2606 OID 18413)
-- Name: refDegreeDegradationSoil refDegreeDegradationSoil_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refDegreeDegradationSoil"
    ADD CONSTRAINT "refDegreeDegradationSoil_pkey" PRIMARY KEY (id);


--
-- TOC entry 5104 (class 2606 OID 17852)
-- Name: refDocumentType refDocumentType_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refDocumentType"
    ADD CONSTRAINT "refDocumentType_pkey" PRIMARY KEY (id);


--
-- TOC entry 5259 (class 2606 OID 158359)
-- Name: refEntityDiscardReason refEntityDiscardReason_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refEntityDiscardReason"
    ADD CONSTRAINT "refEntityDiscardReason_pkey" PRIMARY KEY (id);


--
-- TOC entry 5106 (class 2606 OID 17861)
-- Name: refEntityType refEntityType_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refEntityType"
    ADD CONSTRAINT "refEntityType_pkey" PRIMARY KEY (id);


--
-- TOC entry 5190 (class 2606 OID 18422)
-- Name: refEquineCattle refEquineCattle_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refEquineCattle"
    ADD CONSTRAINT "refEquineCattle_pkey" PRIMARY KEY (id);


--
-- TOC entry 5192 (class 2606 OID 18431)
-- Name: refExclusionAreaType refExclusionAreaType_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refExclusionAreaType"
    ADD CONSTRAINT "refExclusionAreaType_pkey" PRIMARY KEY (id);


--
-- TOC entry 5271 (class 2606 OID 559957)
-- Name: refFieldRelocationMethod refFieldRelocationMethod_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refFieldRelocationMethod"
    ADD CONSTRAINT "refFieldRelocationMethod_pkey" PRIMARY KEY (id);


--
-- TOC entry 5194 (class 2606 OID 18440)
-- Name: refFieldUsage refFieldUsage_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refFieldUsage"
    ADD CONSTRAINT "refFieldUsage_pkey" PRIMARY KEY (id);


--
-- TOC entry 5120 (class 2606 OID 17969)
-- Name: refFindingType refFindingType_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refFindingType"
    ADD CONSTRAINT "refFindingType_pkey" PRIMARY KEY (id);


--
-- TOC entry 5196 (class 2606 OID 18449)
-- Name: refForageSource refForageSource_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refForageSource"
    ADD CONSTRAINT "refForageSource_pkey" PRIMARY KEY (id);


--
-- TOC entry 5293 (class 2606 OID 1149705)
-- Name: refForageUseIntensity refForageUseIntensity_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refForageUseIntensity"
    ADD CONSTRAINT "refForageUseIntensity_pkey" PRIMARY KEY (id);


--
-- TOC entry 5295 (class 2606 OID 1149715)
-- Name: refForageUsePattern refForageUsePattern_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refForageUsePattern"
    ADD CONSTRAINT "refForageUsePattern_pkey" PRIMARY KEY (id);


--
-- TOC entry 5251 (class 2606 OID 133808)
-- Name: refFuelEmissionsFactors refFuelEmissionsFactors_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refFuelEmissionsFactors"
    ADD CONSTRAINT "refFuelEmissionsFactors_pkey" PRIMARY KEY (id);


--
-- TOC entry 5198 (class 2606 OID 18458)
-- Name: refFuelType refFuelType_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refFuelType"
    ADD CONSTRAINT "refFuelType_pkey" PRIMARY KEY (id);


--
-- TOC entry 5200 (class 2606 OID 18467)
-- Name: refGrazingIntensityTypes refGrazingIntensityTypes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refGrazingIntensityTypes"
    ADD CONSTRAINT "refGrazingIntensityTypes_pkey" PRIMARY KEY (id);


--
-- TOC entry 5202 (class 2606 OID 18476)
-- Name: refGrazingPlanType refGrazingPlanType_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refGrazingPlanType"
    ADD CONSTRAINT "refGrazingPlanType_pkey" PRIMARY KEY (id);


--
-- TOC entry 5204 (class 2606 OID 18485)
-- Name: refGrazingType refGrazingType_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refGrazingType"
    ADD CONSTRAINT "refGrazingType_pkey" PRIMARY KEY (id);


--
-- TOC entry 5253 (class 2606 OID 133824)
-- Name: refGreenHouseGasesGwp refGreenHouseGasesGwp_chemicalName_ipccAssessmentReport_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refGreenHouseGasesGwp"
    ADD CONSTRAINT "refGreenHouseGasesGwp_chemicalName_ipccAssessmentReport_key" UNIQUE ("chemicalName", "ipccAssessmentReport");


--
-- TOC entry 5255 (class 2606 OID 133822)
-- Name: refGreenHouseGasesGwp refGreenHouseGasesGwp_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refGreenHouseGasesGwp"
    ADD CONSTRAINT "refGreenHouseGasesGwp_pkey" PRIMARY KEY (id);


--
-- TOC entry 5206 (class 2606 OID 18494)
-- Name: refHorizonCode refHorizonCode_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refHorizonCode"
    ADD CONSTRAINT "refHorizonCode_pkey" PRIMARY KEY (id);


--
-- TOC entry 5080 (class 2606 OID 17695)
-- Name: refInstancesVerificationStatus refInstancesVerificationStatus_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refInstancesVerificationStatus"
    ADD CONSTRAINT "refInstancesVerificationStatus_pkey" PRIMARY KEY (id);


--
-- TOC entry 5208 (class 2606 OID 18503)
-- Name: refIrrigationType refIrrigationType_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refIrrigationType"
    ADD CONSTRAINT "refIrrigationType_pkey" PRIMARY KEY (id);


--
-- TOC entry 5210 (class 2606 OID 18512)
-- Name: refLivestockRaisingTypes refLivestockRaisingTypes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refLivestockRaisingTypes"
    ADD CONSTRAINT "refLivestockRaisingTypes_pkey" PRIMARY KEY (id);


--
-- TOC entry 5269 (class 2606 OID 559947)
-- Name: refLocationConfirmationType refLocationConfirmationType_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refLocationConfirmationType"
    ADD CONSTRAINT "refLocationConfirmationType_pkey" PRIMARY KEY (id);


--
-- TOC entry 5267 (class 2606 OID 559937)
-- Name: refLocationMovedReason refLocationMovedReason_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refLocationMovedReason"
    ADD CONSTRAINT "refLocationMovedReason_pkey" PRIMARY KEY (id);


--
-- TOC entry 5244 (class 2606 OID 92732)
-- Name: refMetricStatus refMetricStatus_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refMetricStatus"
    ADD CONSTRAINT "refMetricStatus_pkey" PRIMARY KEY (id);


--
-- TOC entry 5212 (class 2606 OID 18521)
-- Name: refMineralFertilizerType refMineralFertilizerType_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refMineralFertilizerType"
    ADD CONSTRAINT "refMineralFertilizerType_pkey" PRIMARY KEY (id);


--
-- TOC entry 5150 (class 2606 OID 18189)
-- Name: refMonitoringReportStatus refMonitoringReportStatus_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refMonitoringReportStatus"
    ADD CONSTRAINT "refMonitoringReportStatus_pkey" PRIMARY KEY (id);


--
-- TOC entry 5214 (class 2606 OID 18530)
-- Name: refOrganicFertilizerType refOrganicFertilizerType_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refOrganicFertilizerType"
    ADD CONSTRAINT "refOrganicFertilizerType_pkey" PRIMARY KEY (id);


--
-- TOC entry 5216 (class 2606 OID 18539)
-- Name: refOvineCattle refOvineCattle_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refOvineCattle"
    ADD CONSTRAINT "refOvineCattle_pkey" PRIMARY KEY (id);


--
-- TOC entry 5218 (class 2606 OID 18548)
-- Name: refPasturesFamily refPasturesFamily_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refPasturesFamily"
    ADD CONSTRAINT "refPasturesFamily_pkey" PRIMARY KEY (id);


--
-- TOC entry 5220 (class 2606 OID 18557)
-- Name: refPasturesGrowthTypes refPasturesGrowthTypes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refPasturesGrowthTypes"
    ADD CONSTRAINT "refPasturesGrowthTypes_pkey" PRIMARY KEY (id);


--
-- TOC entry 5222 (class 2606 OID 18566)
-- Name: refPasturesTypes refPasturesTypes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refPasturesTypes"
    ADD CONSTRAINT "refPasturesTypes_pkey" PRIMARY KEY (id);


--
-- TOC entry 5297 (class 2606 OID 1346313)
-- Name: refRandomizer refRandomizer_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refRandomizer"
    ADD CONSTRAINT "refRandomizer_pkey" PRIMARY KEY (id);


--
-- TOC entry 5299 (class 2606 OID 1346315)
-- Name: refRandomizer refRandomizer_version_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refRandomizer"
    ADD CONSTRAINT "refRandomizer_version_key" UNIQUE (version);


--
-- TOC entry 5275 (class 2606 OID 830225)
-- Name: refSamplingNumbers refSamplingNumbers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refSamplingNumbers"
    ADD CONSTRAINT "refSamplingNumbers_pkey" PRIMARY KEY (id);


--
-- TOC entry 5301 (class 2606 OID 1420529)
-- Name: refSoilSamplingDisturbance refSoilSamplingDisturbance_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refSoilSamplingDisturbance"
    ADD CONSTRAINT "refSoilSamplingDisturbance_pkey" PRIMARY KEY (id);


--
-- TOC entry 5303 (class 2606 OID 1420539)
-- Name: refSoilSamplingTools refSoilSamplingTools_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refSoilSamplingTools"
    ADD CONSTRAINT "refSoilSamplingTools_pkey" PRIMARY KEY (id);


--
-- TOC entry 5224 (class 2606 OID 18575)
-- Name: refSoilTexture refSoilTexture_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refSoilTexture"
    ADD CONSTRAINT "refSoilTexture_pkey" PRIMARY KEY (id);


--
-- TOC entry 5226 (class 2606 OID 18584)
-- Name: refStructureGrade refStructureGrade_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refStructureGrade"
    ADD CONSTRAINT "refStructureGrade_pkey" PRIMARY KEY (id);


--
-- TOC entry 5228 (class 2606 OID 18593)
-- Name: refStructureSize refStructureSize_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refStructureSize"
    ADD CONSTRAINT "refStructureSize_pkey" PRIMARY KEY (id);


--
-- TOC entry 5230 (class 2606 OID 18602)
-- Name: refStructureType refStructureType_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refStructureType"
    ADD CONSTRAINT "refStructureType_pkey" PRIMARY KEY (id);


--
-- TOC entry 5134 (class 2606 OID 18057)
-- Name: refTaskStatus refTaskStatus_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refTaskStatus"
    ADD CONSTRAINT "refTaskStatus_pkey" PRIMARY KEY (id);


--
-- TOC entry 5232 (class 2606 OID 18611)
-- Name: refTillageType refTillageType_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refTillageType"
    ADD CONSTRAINT "refTillageType_pkey" PRIMARY KEY (id);


--
-- TOC entry 5257 (class 2606 OID 133833)
-- Name: refUnits refUnits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refUnits"
    ADD CONSTRAINT "refUnits_pkey" PRIMARY KEY (id);


--
-- TOC entry 5086 (class 2606 OID 17735)
-- Name: refUserRole refUserRole_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refUserRole"
    ADD CONSTRAINT "refUserRole_pkey" PRIMARY KEY (id);


--
-- TOC entry 5234 (class 2606 OID 18622)
-- Name: relInstanceMonitoringPeriod relInstanceMonitoringPeriod_carbonInstanceId_monitoringPeri_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."relInstanceMonitoringPeriod"
    ADD CONSTRAINT "relInstanceMonitoringPeriod_carbonInstanceId_monitoringPeri_key" UNIQUE ("carbonInstanceId", "monitoringPeriodId");


--
-- TOC entry 5236 (class 2606 OID 18620)
-- Name: relInstanceMonitoringPeriod relInstanceMonitoringPeriod_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."relInstanceMonitoringPeriod"
    ADD CONSTRAINT "relInstanceMonitoringPeriod_pkey" PRIMARY KEY (id);


--
-- TOC entry 5279 (class 2606 OID 830241)
-- Name: relSOCProtocols relSOCProtocols_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."relSOCProtocols"
    ADD CONSTRAINT "relSOCProtocols_pkey" PRIMARY KEY (id);


--
-- TOC entry 5238 (class 2606 OID 18641)
-- Name: samplingAreasHistory samplingAreasHistory_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."samplingAreasHistory"
    ADD CONSTRAINT "samplingAreasHistory_pkey" PRIMARY KEY (id);


--
-- TOC entry 5076 (class 2606 OID 17683)
-- Name: samplingAreas samplingAreas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."samplingAreas"
    ADD CONSTRAINT "samplingAreas_pkey" PRIMARY KEY (id);


--
-- TOC entry 5240 (class 2606 OID 18662)
-- Name: wetlandAreas wetlandAreas_farmId_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."wetlandAreas"
    ADD CONSTRAINT "wetlandAreas_farmId_key" UNIQUE ("farmId");


--
-- TOC entry 5242 (class 2606 OID 18660)
-- Name: wetlandAreas wetlandAreas_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."wetlandAreas"
    ADD CONSTRAINT "wetlandAreas_pkey" PRIMARY KEY (id);


--
-- TOC entry 5245 (class 1259 OID 133782)
-- Name: cattle_assessment_report; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX cattle_assessment_report ON public."refCattleEmissionsFactors" USING btree ("cattleSubClassId", "ipccAssessmentReport");


--
-- TOC entry 5092 (class 1259 OID 17776)
-- Name: farmSubdivision; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX "farmSubdivision" ON public."dataCollectionStatement" USING btree ("farmSubdivisionId", "isDeleted");


--
-- TOC entry 5077 (class 1259 OID 559959)
-- Name: sampling_areas_geometry_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sampling_areas_geometry_idx ON public."samplingAreas" USING gist (geometry);


--
-- TOC entry 5078 (class 1259 OID 559958)
-- Name: sampling_areas_uncropped_geometry_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX sampling_areas_uncropped_geometry_idx ON public."samplingAreas" USING gist ("uncroppedGeometry");


--
-- TOC entry 5089 (class 1259 OID 18910)
-- Name: unique_active_farm_subdivision; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unique_active_farm_subdivision ON public."farmSubdivisions" USING btree ("farmId", year) WHERE ("isDeleted" = false);


--
-- TOC entry 5282 (class 1259 OID 830329)
-- Name: unq_monitoring_soc_sample; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unq_monitoring_soc_sample ON public."monitoringSOCSamples" USING btree ("farmId", "sampleDate", "laboratoryId", "socProtocolId") WHERE ("isDeleted" = false);


--
-- TOC entry 5285 (class 1259 OID 830332)
-- Name: unq_monitoring_soc_sampling_area_sample; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unq_monitoring_soc_sampling_area_sample ON public."monitoringSOCSamplingAreaSamples" USING btree ("monitoringSOCSampleId", "samplingAreaId") WHERE ("isDeleted" = false);


--
-- TOC entry 5286 (class 1259 OID 830331)
-- Name: unq_monitoring_soc_sampling_area_sample_names; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unq_monitoring_soc_sampling_area_sample_names ON public."monitoringSOCSamplingAreaSamples" USING btree ("monitoringSOCSampleId", "stationsName", "samplingAreaName") WHERE ("isDeleted" = false);


--
-- TOC entry 5291 (class 1259 OID 830330)
-- Name: unq_monitoring_soc_site_sample_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX unq_monitoring_soc_site_sample_name ON public."monitoringSOCSitesSamples" USING btree ("monitoringSOCSampleId", "monitoringSOCActivityId", name) WHERE ("isDeleted" = false);


--
-- TOC entry 5389 (class 2620 OID 379607)
-- Name: refExclusionAreaType check_refexclusionareatype_programids; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER check_refexclusionareatype_programids BEFORE INSERT OR UPDATE ON public."refExclusionAreaType" FOR EACH ROW EXECUTE FUNCTION public.check_refexclusionareatype_programids();


--
-- TOC entry 5387 (class 2620 OID 1567535)
-- Name: carbonInstances trigger_carbon_instance_auto_link; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_carbon_instance_auto_link AFTER INSERT ON public."carbonInstances" FOR EACH ROW EXECUTE FUNCTION public.trigger_auto_link_carbon_instance_monitoring_period();


--
-- TOC entry 5388 (class 2620 OID 1567537)
-- Name: carbonInstances trigger_carbon_instance_sync_deleted; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_carbon_instance_sync_deleted AFTER UPDATE ON public."carbonInstances" FOR EACH ROW WHEN ((old."isDeleted" IS DISTINCT FROM new."isDeleted")) EXECUTE FUNCTION public.trigger_sync_carbon_instance_deleted_status();


--
-- TOC entry 5310 (class 2606 OID 17705)
-- Name: carbonInstances carbonInstances_farmId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."carbonInstances"
    ADD CONSTRAINT "carbonInstances_farmId_fkey" FOREIGN KEY ("farmId") REFERENCES public.farms(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5311 (class 2606 OID 18911)
-- Name: carbonInstances carbonInstances_refInstancesVerificationStatus_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."carbonInstances"
    ADD CONSTRAINT "carbonInstances_refInstancesVerificationStatus_fkey" FOREIGN KEY ("verificationStatusId") REFERENCES public."refInstancesVerificationStatus"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5312 (class 2606 OID 17710)
-- Name: carbonInstances carbonInstances_samplingAreaId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."carbonInstances"
    ADD CONSTRAINT "carbonInstances_samplingAreaId_fkey" FOREIGN KEY ("samplingAreaId") REFERENCES public."samplingAreas"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5313 (class 2606 OID 17715)
-- Name: carbonInstances carbonInstances_verificationStatusId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."carbonInstances"
    ADD CONSTRAINT "carbonInstances_verificationStatusId_fkey" FOREIGN KEY ("verificationStatusId") REFERENCES public."refInstancesVerificationStatus"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5318 (class 2606 OID 17792)
-- Name: dataCollectionStatementHistory dataCollectionStatementHistor_dataCollectionStatementStatu_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."dataCollectionStatementHistory"
    ADD CONSTRAINT "dataCollectionStatementHistor_dataCollectionStatementStatu_fkey" FOREIGN KEY ("dataCollectionStatementStatusId") REFERENCES public."refDataCollectionStatementStatus"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5319 (class 2606 OID 17787)
-- Name: dataCollectionStatementHistory dataCollectionStatementHistory_dataCollectionStatementId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."dataCollectionStatementHistory"
    ADD CONSTRAINT "dataCollectionStatementHistory_dataCollectionStatementId_fkey" FOREIGN KEY ("dataCollectionStatementId") REFERENCES public."dataCollectionStatement"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5320 (class 2606 OID 17802)
-- Name: dataCollectionStatementHistory dataCollectionStatementHistory_farmSubdivisionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."dataCollectionStatementHistory"
    ADD CONSTRAINT "dataCollectionStatementHistory_farmSubdivisionId_fkey" FOREIGN KEY ("farmSubdivisionId") REFERENCES public."farmSubdivisions"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5321 (class 2606 OID 17797)
-- Name: dataCollectionStatementHistory dataCollectionStatementHistory_ownerUserRoleId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."dataCollectionStatementHistory"
    ADD CONSTRAINT "dataCollectionStatementHistory_ownerUserRoleId_fkey" FOREIGN KEY ("ownerUserRoleId") REFERENCES public."refUserRole"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5315 (class 2606 OID 17761)
-- Name: dataCollectionStatement dataCollectionStatement_dataCollectionStatementStatusId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."dataCollectionStatement"
    ADD CONSTRAINT "dataCollectionStatement_dataCollectionStatementStatusId_fkey" FOREIGN KEY ("dataCollectionStatementStatusId") REFERENCES public."refDataCollectionStatementStatus"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5316 (class 2606 OID 17771)
-- Name: dataCollectionStatement dataCollectionStatement_farmSubdivisionId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."dataCollectionStatement"
    ADD CONSTRAINT "dataCollectionStatement_farmSubdivisionId_fkey" FOREIGN KEY ("farmSubdivisionId") REFERENCES public."farmSubdivisions"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5317 (class 2606 OID 17766)
-- Name: dataCollectionStatement dataCollectionStatement_ownerUserRoleId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."dataCollectionStatement"
    ADD CONSTRAINT "dataCollectionStatement_ownerUserRoleId_fkey" FOREIGN KEY ("ownerUserRoleId") REFERENCES public."refUserRole"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5322 (class 2606 OID 17823)
-- Name: deals deals_farmId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deals
    ADD CONSTRAINT "deals_farmId_fkey" FOREIGN KEY ("farmId") REFERENCES public.farms(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5323 (class 2606 OID 17818)
-- Name: deals deals_programId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deals
    ADD CONSTRAINT "deals_programId_fkey" FOREIGN KEY ("programId") REFERENCES public.programs(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5324 (class 2606 OID 17839)
-- Name: deforestedAreas deforestedAreas_farmId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."deforestedAreas"
    ADD CONSTRAINT "deforestedAreas_farmId_fkey" FOREIGN KEY ("farmId") REFERENCES public.farms(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5370 (class 2606 OID 158374)
-- Name: discardedEntities discardedEntities_entityTypeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."discardedEntities"
    ADD CONSTRAINT "discardedEntities_entityTypeId_fkey" FOREIGN KEY ("entityTypeId") REFERENCES public."refEntityType"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5371 (class 2606 OID 158369)
-- Name: discardedEntities discardedEntities_farmId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."discardedEntities"
    ADD CONSTRAINT "discardedEntities_farmId_fkey" FOREIGN KEY ("farmId") REFERENCES public.farms(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5372 (class 2606 OID 158379)
-- Name: discardedEntities discardedEntities_reasonId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."discardedEntities"
    ADD CONSTRAINT "discardedEntities_reasonId_fkey" FOREIGN KEY ("reasonId") REFERENCES public."refEntityDiscardReason"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5325 (class 2606 OID 17871)
-- Name: documents documents_documentTypeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT "documents_documentTypeId_fkey" FOREIGN KEY ("documentTypeId") REFERENCES public."refDocumentType"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5326 (class 2606 OID 17876)
-- Name: documents documents_entityTypeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.documents
    ADD CONSTRAINT "documents_entityTypeId_fkey" FOREIGN KEY ("entityTypeId") REFERENCES public."refEntityType"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5328 (class 2606 OID 17904)
-- Name: exclusionAreaHistory exclusionAreaHistory_exclusionAreaId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."exclusionAreaHistory"
    ADD CONSTRAINT "exclusionAreaHistory_exclusionAreaId_fkey" FOREIGN KEY ("exclusionAreaId") REFERENCES public."exclusionAreas"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5329 (class 2606 OID 17909)
-- Name: exclusionAreaHistory exclusionAreaHistory_farmId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."exclusionAreaHistory"
    ADD CONSTRAINT "exclusionAreaHistory_farmId_fkey" FOREIGN KEY ("farmId") REFERENCES public.farms(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5327 (class 2606 OID 17890)
-- Name: exclusionAreas exclusionAreas_farmId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."exclusionAreas"
    ADD CONSTRAINT "exclusionAreas_farmId_fkey" FOREIGN KEY ("farmId") REFERENCES public.farms(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5314 (class 2606 OID 17745)
-- Name: farmSubdivisions farmSubdivisions_farmId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."farmSubdivisions"
    ADD CONSTRAINT "farmSubdivisions_farmId_fkey" FOREIGN KEY ("farmId") REFERENCES public.farms(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5330 (class 2606 OID 17923)
-- Name: farmsHistory farmsHistory_farmId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."farmsHistory"
    ADD CONSTRAINT "farmsHistory_farmId_fkey" FOREIGN KEY ("farmId") REFERENCES public.farms(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5331 (class 2606 OID 17933)
-- Name: farmsHistory farmsHistory_hubId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."farmsHistory"
    ADD CONSTRAINT "farmsHistory_hubId_fkey" FOREIGN KEY ("hubId") REFERENCES public.hubs(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5332 (class 2606 OID 17928)
-- Name: farmsHistory farmsHistory_programId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."farmsHistory"
    ADD CONSTRAINT "farmsHistory_programId_fkey" FOREIGN KEY ("programId") REFERENCES public.programs(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5305 (class 2606 OID 17665)
-- Name: farms farms_hubId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.farms
    ADD CONSTRAINT "farms_hubId_fkey" FOREIGN KEY ("hubId") REFERENCES public.hubs(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5306 (class 2606 OID 18905)
-- Name: farms farms_programId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.farms
    ADD CONSTRAINT "farms_programId_fkey" FOREIGN KEY ("programId") REFERENCES public.programs(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5307 (class 2606 OID 18916)
-- Name: farms farms_programMonitoringPeriods_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.farms
    ADD CONSTRAINT "farms_programMonitoringPeriods_fkey" FOREIGN KEY ("targetInitialMonitoringPeriodId") REFERENCES public."programMonitoringPeriods"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5308 (class 2606 OID 17670)
-- Name: farms farms_targetInitialMonitoringPeriodId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.farms
    ADD CONSTRAINT "farms_targetInitialMonitoringPeriodId_fkey" FOREIGN KEY ("targetInitialMonitoringPeriodId") REFERENCES public."programMonitoringPeriods"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5335 (class 2606 OID 17999)
-- Name: findingComments findingComments_findingId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."findingComments"
    ADD CONSTRAINT "findingComments_findingId_fkey" FOREIGN KEY ("findingId") REFERENCES public.findings(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5336 (class 2606 OID 18013)
-- Name: findingHistory findingHistory_findingId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."findingHistory"
    ADD CONSTRAINT "findingHistory_findingId_fkey" FOREIGN KEY ("findingId") REFERENCES public.findings(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5337 (class 2606 OID 18018)
-- Name: findingHistory findingHistory_metricEventId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."findingHistory"
    ADD CONSTRAINT "findingHistory_metricEventId_fkey" FOREIGN KEY ("metricEventId") REFERENCES metrics."metricEvents"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5333 (class 2606 OID 17980)
-- Name: findings findings_metricEventId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.findings
    ADD CONSTRAINT "findings_metricEventId_fkey" FOREIGN KEY ("metricEventId") REFERENCES metrics."metricEvents"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5334 (class 2606 OID 17985)
-- Name: findings findings_type_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.findings
    ADD CONSTRAINT findings_type_fkey FOREIGN KEY (type) REFERENCES public."refFindingType"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5338 (class 2606 OID 18034)
-- Name: forestAreas forestAreas_farmId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."forestAreas"
    ADD CONSTRAINT "forestAreas_farmId_fkey" FOREIGN KEY ("farmId") REFERENCES public.farms(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5344 (class 2606 OID 18160)
-- Name: monitoringActivity monitoringActivity_activityLayoutId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."monitoringActivity"
    ADD CONSTRAINT "monitoringActivity_activityLayoutId_fkey" FOREIGN KEY ("activityLayoutId") REFERENCES public."refActivityLayouts"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5345 (class 2606 OID 18145)
-- Name: monitoringActivity monitoringActivity_monitoringEventId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."monitoringActivity"
    ADD CONSTRAINT "monitoringActivity_monitoringEventId_fkey" FOREIGN KEY ("monitoringEventId") REFERENCES public."monitoringEvents"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5346 (class 2606 OID 18155)
-- Name: monitoringActivity monitoringActivity_monitoringSiteId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."monitoringActivity"
    ADD CONSTRAINT "monitoringActivity_monitoringSiteId_fkey" FOREIGN KEY ("monitoringSiteId") REFERENCES public."monitoringSites"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5347 (class 2606 OID 18150)
-- Name: monitoringActivity monitoringActivity_monitoringWorkflowId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."monitoringActivity"
    ADD CONSTRAINT "monitoringActivity_monitoringWorkflowId_fkey" FOREIGN KEY ("monitoringWorkflowId") REFERENCES public."monitoringWorkflows"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5348 (class 2606 OID 18140)
-- Name: monitoringActivity monitoringActivity_taskStatusId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."monitoringActivity"
    ADD CONSTRAINT "monitoringActivity_taskStatusId_fkey" FOREIGN KEY ("taskStatusId") REFERENCES public."refTaskStatus"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5339 (class 2606 OID 18075)
-- Name: monitoringEvents monitoringEvents_farmId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."monitoringEvents"
    ADD CONSTRAINT "monitoringEvents_farmId_fkey" FOREIGN KEY ("farmId") REFERENCES public.farms(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5340 (class 2606 OID 18070)
-- Name: monitoringEvents monitoringEvents_taskStatusId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."monitoringEvents"
    ADD CONSTRAINT "monitoringEvents_taskStatusId_fkey" FOREIGN KEY ("taskStatusId") REFERENCES public."refTaskStatus"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5349 (class 2606 OID 18176)
-- Name: monitoringPictures monitoringPictures_monitoringEventId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."monitoringPictures"
    ADD CONSTRAINT "monitoringPictures_monitoringEventId_fkey" FOREIGN KEY ("monitoringEventId") REFERENCES public."monitoringEvents"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5350 (class 2606 OID 18202)
-- Name: monitoringReports monitoringReports_farmId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."monitoringReports"
    ADD CONSTRAINT "monitoringReports_farmId_fkey" FOREIGN KEY ("farmId") REFERENCES public.farms(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5351 (class 2606 OID 18207)
-- Name: monitoringReports monitoringReports_monitoringReportStatusId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."monitoringReports"
    ADD CONSTRAINT "monitoringReports_monitoringReportStatusId_fkey" FOREIGN KEY ("monitoringReportStatusId") REFERENCES public."refMonitoringReportStatus"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5377 (class 2606 OID 830251)
-- Name: monitoringSOCSamples monitoringSOCSamples_farmId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."monitoringSOCSamples"
    ADD CONSTRAINT "monitoringSOCSamples_farmId_fkey" FOREIGN KEY ("farmId") REFERENCES public.farms(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5378 (class 2606 OID 830261)
-- Name: monitoringSOCSamples monitoringSOCSamples_laboratoryId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."monitoringSOCSamples"
    ADD CONSTRAINT "monitoringSOCSamples_laboratoryId_fkey" FOREIGN KEY ("laboratoryId") REFERENCES public."RelLaboratory"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5379 (class 2606 OID 830256)
-- Name: monitoringSOCSamples monitoringSOCSamples_samplingNumberId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."monitoringSOCSamples"
    ADD CONSTRAINT "monitoringSOCSamples_samplingNumberId_fkey" FOREIGN KEY ("samplingNumberId") REFERENCES public."refSamplingNumbers"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5380 (class 2606 OID 830266)
-- Name: monitoringSOCSamples monitoringSOCSamples_socProtocolId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."monitoringSOCSamples"
    ADD CONSTRAINT "monitoringSOCSamples_socProtocolId_fkey" FOREIGN KEY ("socProtocolId") REFERENCES public."relSOCProtocols"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5381 (class 2606 OID 830280)
-- Name: monitoringSOCSamplingAreaSamples monitoringSOCSamplingAreaSamples_monitoringSOCSampleId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."monitoringSOCSamplingAreaSamples"
    ADD CONSTRAINT "monitoringSOCSamplingAreaSamples_monitoringSOCSampleId_fkey" FOREIGN KEY ("monitoringSOCSampleId") REFERENCES public."monitoringSOCSamples"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5382 (class 2606 OID 830285)
-- Name: monitoringSOCSamplingAreaSamples monitoringSOCSamplingAreaSamples_samplingAreaId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."monitoringSOCSamplingAreaSamples"
    ADD CONSTRAINT "monitoringSOCSamplingAreaSamples_samplingAreaId_fkey" FOREIGN KEY ("samplingAreaId") REFERENCES public."samplingAreas"(id) ON UPDATE CASCADE;


--
-- TOC entry 5383 (class 2606 OID 830290)
-- Name: monitoringSOCSamplingAreaSamples monitoringSOCSamplingAreaSamples_soilTextureTypeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."monitoringSOCSamplingAreaSamples"
    ADD CONSTRAINT "monitoringSOCSamplingAreaSamples_soilTextureTypeId_fkey" FOREIGN KEY ("soilTextureTypeId") REFERENCES public."refSoilTexture"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5384 (class 2606 OID 830319)
-- Name: monitoringSOCSitesSamples monitoringSOCSitesSamples_dapMethodId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."monitoringSOCSitesSamples"
    ADD CONSTRAINT "monitoringSOCSitesSamples_dapMethodId_fkey" FOREIGN KEY ("dapMethodId") REFERENCES public."refDAPMethods"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5385 (class 2606 OID 830324)
-- Name: monitoringSOCSitesSamples monitoringSOCSitesSamples_monitoringSOCActivityId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."monitoringSOCSitesSamples"
    ADD CONSTRAINT "monitoringSOCSitesSamples_monitoringSOCActivityId_fkey" FOREIGN KEY ("monitoringSOCActivityId") REFERENCES public."monitoringActivity"(id) ON UPDATE CASCADE;


--
-- TOC entry 5386 (class 2606 OID 830314)
-- Name: monitoringSOCSitesSamples monitoringSOCSitesSamples_monitoringSOCSampleId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."monitoringSOCSitesSamples"
    ADD CONSTRAINT "monitoringSOCSitesSamples_monitoringSOCSampleId_fkey" FOREIGN KEY ("monitoringSOCSampleId") REFERENCES public."monitoringSOCSamples"(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- TOC entry 5373 (class 2606 OID 207538)
-- Name: monitoringSitesHistory monitoringSitesHistory_farmId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."monitoringSitesHistory"
    ADD CONSTRAINT "monitoringSitesHistory_farmId_fkey" FOREIGN KEY ("farmId") REFERENCES public.farms(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5374 (class 2606 OID 207533)
-- Name: monitoringSitesHistory monitoringSitesHistory_monitoringSiteId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."monitoringSitesHistory"
    ADD CONSTRAINT "monitoringSitesHistory_monitoringSiteId_fkey" FOREIGN KEY ("monitoringSiteId") REFERENCES public."monitoringSites"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5341 (class 2606 OID 18107)
-- Name: monitoringSites monitoringSites_farmId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."monitoringSites"
    ADD CONSTRAINT "monitoringSites_farmId_fkey" FOREIGN KEY ("farmId") REFERENCES public.farms(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5342 (class 2606 OID 1346316)
-- Name: monitoringSites monitoringSites_randomizerTypeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."monitoringSites"
    ADD CONSTRAINT "monitoringSites_randomizerTypeId_fkey" FOREIGN KEY ("randomizerTypeId") REFERENCES public."refRandomizer"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5375 (class 2606 OID 207561)
-- Name: monitoringTasksHistory monitoringTasksHistory_monitoringActivityId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."monitoringTasksHistory"
    ADD CONSTRAINT "monitoringTasksHistory_monitoringActivityId_fkey" FOREIGN KEY ("monitoringActivityId") REFERENCES public."monitoringActivity"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5376 (class 2606 OID 207556)
-- Name: monitoringTasksHistory monitoringTasksHistory_monitoringTaskId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."monitoringTasksHistory"
    ADD CONSTRAINT "monitoringTasksHistory_monitoringTaskId_fkey" FOREIGN KEY ("monitoringTaskId") REFERENCES public."monitoringTasks"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5352 (class 2606 OID 18224)
-- Name: monitoringTasks monitoringTasks_monitoringActivityId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."monitoringTasks"
    ADD CONSTRAINT "monitoringTasks_monitoringActivityId_fkey" FOREIGN KEY ("monitoringActivityId") REFERENCES public."monitoringActivity"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5353 (class 2606 OID 18229)
-- Name: monitoringTasks monitoringTasks_taskStatusId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."monitoringTasks"
    ADD CONSTRAINT "monitoringTasks_taskStatusId_fkey" FOREIGN KEY ("taskStatusId") REFERENCES public."refTaskStatus"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5354 (class 2606 OID 18243)
-- Name: otherPolygons otherPolygons_farmId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."otherPolygons"
    ADD CONSTRAINT "otherPolygons_farmId_fkey" FOREIGN KEY ("farmId") REFERENCES public.farms(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5355 (class 2606 OID 18257)
-- Name: otherSites otherSites_farmId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."otherSites"
    ADD CONSTRAINT "otherSites_farmId_fkey" FOREIGN KEY ("farmId") REFERENCES public.farms(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5357 (class 2606 OID 18290)
-- Name: paddocksHistory paddocksHistory_farmId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."paddocksHistory"
    ADD CONSTRAINT "paddocksHistory_farmId_fkey" FOREIGN KEY ("farmId") REFERENCES public.farms(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5358 (class 2606 OID 18285)
-- Name: paddocksHistory paddocksHistory_paddockId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."paddocksHistory"
    ADD CONSTRAINT "paddocksHistory_paddockId_fkey" FOREIGN KEY ("paddockId") REFERENCES public.paddocks(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5356 (class 2606 OID 18271)
-- Name: paddocks paddocks_farmId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.paddocks
    ADD CONSTRAINT "paddocks_farmId_fkey" FOREIGN KEY ("farmId") REFERENCES public.farms(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5359 (class 2606 OID 18305)
-- Name: programConfig programConfig_programId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."programConfig"
    ADD CONSTRAINT "programConfig_programId_fkey" FOREIGN KEY ("programId") REFERENCES public.programs(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5360 (class 2606 OID 18900)
-- Name: programConfig programConfigs_programId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."programConfig"
    ADD CONSTRAINT "programConfigs_programId_fkey" FOREIGN KEY ("programId") REFERENCES public.programs(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5304 (class 2606 OID 17641)
-- Name: programMonitoringPeriods programMonitoringPeriods_programId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."programMonitoringPeriods"
    ADD CONSTRAINT "programMonitoringPeriods_programId_fkey" FOREIGN KEY ("programId") REFERENCES public.programs(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5343 (class 2606 OID 18119)
-- Name: refActivityLayouts refActivityLayouts_monitoringWorkflowId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refActivityLayouts"
    ADD CONSTRAINT "refActivityLayouts_monitoringWorkflowId_fkey" FOREIGN KEY ("monitoringWorkflowId") REFERENCES public."monitoringWorkflows"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5367 (class 2606 OID 133790)
-- Name: refCattleEquivalences refCattleEquivalences_cattleSubClassId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refCattleEquivalences"
    ADD CONSTRAINT "refCattleEquivalences_cattleSubClassId_fkey" FOREIGN KEY ("cattleSubClassId") REFERENCES public."refCattleSubClass"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5368 (class 2606 OID 133795)
-- Name: refCattleEquivalences refCattleEquivalences_equivalentCattleSubClassId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refCattleEquivalences"
    ADD CONSTRAINT "refCattleEquivalences_equivalentCattleSubClassId_fkey" FOREIGN KEY ("equivalentCattleSubClassId") REFERENCES public."refCattleSubClass"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5361 (class 2606 OID 18373)
-- Name: refCattleSubClass refCattleSubClass_cattleClassId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refCattleSubClass"
    ADD CONSTRAINT "refCattleSubClass_cattleClassId_fkey" FOREIGN KEY ("cattleClassId") REFERENCES public."refCattleClass"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5369 (class 2606 OID 133809)
-- Name: refFuelEmissionsFactors refFuelEmissionsFactors_fuelTypeId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."refFuelEmissionsFactors"
    ADD CONSTRAINT "refFuelEmissionsFactors_fuelTypeId_fkey" FOREIGN KEY ("fuelTypeId") REFERENCES public."refFuelType"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5362 (class 2606 OID 18623)
-- Name: relInstanceMonitoringPeriod relInstanceMonitoringPeriod_carbonInstanceId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."relInstanceMonitoringPeriod"
    ADD CONSTRAINT "relInstanceMonitoringPeriod_carbonInstanceId_fkey" FOREIGN KEY ("carbonInstanceId") REFERENCES public."carbonInstances"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5363 (class 2606 OID 18628)
-- Name: relInstanceMonitoringPeriod relInstanceMonitoringPeriod_monitoringPeriodId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."relInstanceMonitoringPeriod"
    ADD CONSTRAINT "relInstanceMonitoringPeriod_monitoringPeriodId_fkey" FOREIGN KEY ("monitoringPeriodId") REFERENCES public."programMonitoringPeriods"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5364 (class 2606 OID 18647)
-- Name: samplingAreasHistory samplingAreasHistory_farmId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."samplingAreasHistory"
    ADD CONSTRAINT "samplingAreasHistory_farmId_fkey" FOREIGN KEY ("farmId") REFERENCES public.farms(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5365 (class 2606 OID 18642)
-- Name: samplingAreasHistory samplingAreasHistory_samplingAreaId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."samplingAreasHistory"
    ADD CONSTRAINT "samplingAreasHistory_samplingAreaId_fkey" FOREIGN KEY ("samplingAreaId") REFERENCES public."samplingAreas"(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5309 (class 2606 OID 17684)
-- Name: samplingAreas samplingAreas_farmId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."samplingAreas"
    ADD CONSTRAINT "samplingAreas_farmId_fkey" FOREIGN KEY ("farmId") REFERENCES public.farms(id) ON UPDATE CASCADE ON DELETE SET NULL;


--
-- TOC entry 5366 (class 2606 OID 18663)
-- Name: wetlandAreas wetlandAreas_farmId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public."wetlandAreas"
    ADD CONSTRAINT "wetlandAreas_farmId_fkey" FOREIGN KEY ("farmId") REFERENCES public.farms(id) ON UPDATE CASCADE ON DELETE SET NULL;


-- Completed on 2026-01-14 17:28:45 -03

--
-- PostgreSQL database dump complete
--

