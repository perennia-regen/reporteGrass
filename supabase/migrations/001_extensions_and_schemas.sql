-- Migration: 001_extensions_and_schemas
-- Domain: Infrastructure
-- Description: Enable required extensions and create schemas

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create biodiversity schema
CREATE SCHEMA IF NOT EXISTS biodiversity;

-- Grant usage on schemas
GRANT USAGE ON SCHEMA biodiversity TO postgres, anon, authenticated, service_role;
