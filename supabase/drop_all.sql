-- =====================================================
-- DROP ALL - Limpieza completa del schema public
-- Ejecutar ANTES de aplicar ruuts_full_schema.sql
-- =====================================================

-- Desactivar restricciones de FK temporalmente
SET session_replication_role = 'replica';

-- =====================================================
-- DROP TABLES (CASCADE para manejar dependencias)
-- =====================================================

-- History tables
DROP TABLE IF EXISTS public."monitoringSitesHistory" CASCADE;
DROP TABLE IF EXISTS public."monitoringTasksHistory" CASCADE;
DROP TABLE IF EXISTS public."dataCollectionStatementHistory" CASCADE;
DROP TABLE IF EXISTS public."findingHistory" CASCADE;
DROP TABLE IF EXISTS public."farmsHistory" CASCADE;
DROP TABLE IF EXISTS public."paddocksHistory" CASCADE;
DROP TABLE IF EXISTS public."samplingAreasHistory" CASCADE;
DROP TABLE IF EXISTS public."exclusionAreaHistory" CASCADE;

-- SOC tables
DROP TABLE IF EXISTS public."monitoringSOCSamplingAreaSamples" CASCADE;
DROP TABLE IF EXISTS public."monitoringSOCSitesSamples" CASCADE;
DROP TABLE IF EXISTS public."monitoringSOCSamples" CASCADE;

-- Monitoring tables
DROP TABLE IF EXISTS public."monitoringPictures" CASCADE;
DROP TABLE IF EXISTS public."monitoringTasks" CASCADE;
DROP TABLE IF EXISTS public."monitoringActivity" CASCADE;
DROP TABLE IF EXISTS public."monitoringEvents" CASCADE;
DROP TABLE IF EXISTS public."monitoringSites" CASCADE;
DROP TABLE IF EXISTS public."monitoringReports" CASCADE;
DROP TABLE IF EXISTS public."programMonitoringPeriods" CASCADE;
DROP TABLE IF EXISTS public."relInstanceMonitoringPeriod" CASCADE;

-- Findings and statements
DROP TABLE IF EXISTS public."findingComments" CASCADE;
DROP TABLE IF EXISTS public.findings CASCADE;
DROP TABLE IF EXISTS public."dataCollectionStatement" CASCADE;

-- Areas tables
DROP TABLE IF EXISTS public."forestAreas" CASCADE;
DROP TABLE IF EXISTS public."wetlandAreas" CASCADE;
DROP TABLE IF EXISTS public."deforestedAreas" CASCADE;
DROP TABLE IF EXISTS public."otherPolygons" CASCADE;
DROP TABLE IF EXISTS public."otherSites" CASCADE;
DROP TABLE IF EXISTS public."exclusionAreas" CASCADE;
DROP TABLE IF EXISTS public."carbonInstances" CASCADE;
DROP TABLE IF EXISTS public."farmSubdivisions" CASCADE;
DROP TABLE IF EXISTS public."samplingAreas" CASCADE;
DROP TABLE IF EXISTS public.paddocks CASCADE;

-- Core tables
DROP TABLE IF EXISTS public.farms CASCADE;
DROP TABLE IF EXISTS public."farmOwners" CASCADE;
DROP TABLE IF EXISTS public.programs CASCADE;
DROP TABLE IF EXISTS public.hubs CASCADE;
DROP TABLE IF EXISTS public.deals CASCADE;
DROP TABLE IF EXISTS public.documents CASCADE;
DROP TABLE IF EXISTS public."discardedEntities" CASCADE;
DROP TABLE IF EXISTS public."programConfig" CASCADE;
DROP TABLE IF EXISTS public."formDefinitions" CASCADE;

-- Reference tables - Status
DROP TABLE IF EXISTS public."refTaskStatus" CASCADE;
DROP TABLE IF EXISTS public."refMonitoringReportStatus" CASCADE;
DROP TABLE IF EXISTS public."refDataCollectionStatementStatus" CASCADE;
DROP TABLE IF EXISTS public."refFindingType" CASCADE;
DROP TABLE IF EXISTS public."refInstancesVerificationStatus" CASCADE;
DROP TABLE IF EXISTS public."refMetricStatus" CASCADE;

-- Reference tables - Location
DROP TABLE IF EXISTS public."refCountries" CASCADE;
DROP TABLE IF EXISTS public."refLocationMovedReason" CASCADE;
DROP TABLE IF EXISTS public."refLocationConfirmationType" CASCADE;
DROP TABLE IF EXISTS public."refFieldRelocationMethod" CASCADE;

-- Reference tables - SOC/Soil
DROP TABLE IF EXISTS public."refDAPMethods" CASCADE;
DROP TABLE IF EXISTS public."refSamplingNumbers" CASCADE;
DROP TABLE IF EXISTS public."refSoilTexture" CASCADE;
DROP TABLE IF EXISTS public."refSoilSamplingDisturbance" CASCADE;
DROP TABLE IF EXISTS public."refSoilSamplingTools" CASCADE;
DROP TABLE IF EXISTS public."refHorizonCode" CASCADE;
DROP TABLE IF EXISTS public."refStructureGrade" CASCADE;
DROP TABLE IF EXISTS public."refStructureSize" CASCADE;
DROP TABLE IF EXISTS public."refStructureType" CASCADE;
DROP TABLE IF EXISTS public."refDegreeDegradationSoil" CASCADE;
DROP TABLE IF EXISTS public."relSOCProtocols" CASCADE;
DROP TABLE IF EXISTS public."RelLaboratory" CASCADE;

-- Reference tables - Cattle/Livestock
DROP TABLE IF EXISTS public."refBovineCattle" CASCADE;
DROP TABLE IF EXISTS public."refOvineCattle" CASCADE;
DROP TABLE IF EXISTS public."refEquineCattle" CASCADE;
DROP TABLE IF EXISTS public."refCaprineCattle" CASCADE;
DROP TABLE IF EXISTS public."refBubalineCattle" CASCADE;
DROP TABLE IF EXISTS public."refCamelidCattle" CASCADE;
DROP TABLE IF EXISTS public."refCervidCattle" CASCADE;
DROP TABLE IF EXISTS public."refCattleClass" CASCADE;
DROP TABLE IF EXISTS public."refCattleSubClass" CASCADE;
DROP TABLE IF EXISTS public."refCattleType" CASCADE;
DROP TABLE IF EXISTS public."refCattleEmissionsFactors" CASCADE;
DROP TABLE IF EXISTS public."refCattleEquivalences" CASCADE;
DROP TABLE IF EXISTS public."refLivestockRaisingTypes" CASCADE;

-- Reference tables - Agriculture
DROP TABLE IF EXISTS public."refCropType" CASCADE;
DROP TABLE IF EXISTS public."refTillageType" CASCADE;
DROP TABLE IF EXISTS public."refMineralFertilizerType" CASCADE;
DROP TABLE IF EXISTS public."refOrganicFertilizerType" CASCADE;
DROP TABLE IF EXISTS public."refAmmendmendType" CASCADE;
DROP TABLE IF EXISTS public."refIrrigationType" CASCADE;
DROP TABLE IF EXISTS public."refFieldUsage" CASCADE;

-- Reference tables - Pastures/Grazing
DROP TABLE IF EXISTS public."refPasturesFamily" CASCADE;
DROP TABLE IF EXISTS public."refPasturesGrowthTypes" CASCADE;
DROP TABLE IF EXISTS public."refPasturesTypes" CASCADE;
DROP TABLE IF EXISTS public."refGrazingType" CASCADE;
DROP TABLE IF EXISTS public."refGrazingIntensityTypes" CASCADE;
DROP TABLE IF EXISTS public."refGrazingPlanType" CASCADE;
DROP TABLE IF EXISTS public."refForageSource" CASCADE;
DROP TABLE IF EXISTS public."refForageUseIntensity" CASCADE;
DROP TABLE IF EXISTS public."refForageUsePattern" CASCADE;

-- Reference tables - Emissions
DROP TABLE IF EXISTS public."refFuelType" CASCADE;
DROP TABLE IF EXISTS public."refFuelEmissionsFactors" CASCADE;
DROP TABLE IF EXISTS public."refGreenHouseGasesGwp" CASCADE;

-- Reference tables - Other
DROP TABLE IF EXISTS public."refActivityLayouts" CASCADE;
DROP TABLE IF EXISTS public."refDocumentType" CASCADE;
DROP TABLE IF EXISTS public."refEntityType" CASCADE;
DROP TABLE IF EXISTS public."refEntityDiscardReason" CASCADE;
DROP TABLE IF EXISTS public."refExclusionAreaType" CASCADE;
DROP TABLE IF EXISTS public."refRandomizer" CASCADE;
DROP TABLE IF EXISTS public."refUnits" CASCADE;
DROP TABLE IF EXISTS public."refUserRole" CASCADE;
DROP TABLE IF EXISTS public."monitoringWorkflows" CASCADE;

-- =====================================================
-- DROP SEQUENCES
-- =====================================================
DROP SEQUENCE IF EXISTS public."refActivityLayouts_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refAmmendmendType_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refBovineCattle_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refBubalineCattle_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refCamelidCattle_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refCaprineCattle_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refCattleClass_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refCattleEmissionsFactors_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refCattleEquivalences_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refCattleSubClass_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refCattleType_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refCervidCattle_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refCountries_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refCropType_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refDAPMethods_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refDataCollectionStatementStatus_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refDegreeDegradationSoil_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refDocumentType_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refEntityDiscardReason_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refEntityType_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refEquineCattle_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refExclusionAreaType_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refFieldRelocationMethod_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refFieldUsage_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refFindingType_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refForageSource_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refForageUseIntensity_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refForageUsePattern_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refFuelEmissionsFactors_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refFuelType_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refGrazingIntensityTypes_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refGrazingPlanType_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refGrazingType_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refGreenHouseGasesGwp_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refHorizonCode_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refInstancesVerificationStatus_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refIrrigationType_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refLivestockRaisingTypes_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refLocationConfirmationType_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refLocationMovedReason_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refMetricStatus_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refMineralFertilizerType_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refMonitoringReportStatus_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refOrganicFertilizerType_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refOvineCattle_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refPasturesFamily_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refPasturesGrowthTypes_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refPasturesTypes_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refRandomizer_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refSamplingNumbers_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refSoilSamplingDisturbance_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refSoilSamplingTools_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refSoilTexture_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refStructureGrade_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refStructureSize_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refStructureType_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refTaskStatus_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refTillageType_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refUnits_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."refUserRole_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."RelLaboratory_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."relSOCProtocols_id_seq" CASCADE;
DROP SEQUENCE IF EXISTS public."monitoringWorkflows_id_seq" CASCADE;

-- =====================================================
-- DROP FUNCTIONS
-- =====================================================
DROP FUNCTION IF EXISTS public.create_monitoring_site_history() CASCADE;
DROP FUNCTION IF EXISTS public.create_monitoring_task_history() CASCADE;
DROP FUNCTION IF EXISTS public.create_data_collection_statement_history() CASCADE;
DROP FUNCTION IF EXISTS public.create_finding_history() CASCADE;
DROP FUNCTION IF EXISTS public.create_farm_history() CASCADE;
DROP FUNCTION IF EXISTS public.create_paddock_history() CASCADE;
DROP FUNCTION IF EXISTS public.create_sampling_area_history() CASCADE;

-- =====================================================
-- Restaurar restricciones de FK
-- =====================================================
SET session_replication_role = 'origin';

-- =====================================================
-- Verificación
-- =====================================================
-- Ejecuta esto para verificar que todo se eliminó:
-- SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';
