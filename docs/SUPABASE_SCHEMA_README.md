# Schema ruuts-api - Reporte GRASS

## Resumen

Schema de base de datos basado en el **dump real de ruuts-api** (`dump-postgres-202601141728.sql`).

**Actualizado:** 2026-01-16
**Fuente:** Dump PostgreSQL del CTO de ruuts

---

## Convenciones de ruuts-api

| Aspecto | Convención |
|---------|------------|
| Nombres de tablas | **camelCase** (`monitoringSites`, `monitoringTasks`) |
| Nombres de columnas | **camelCase** (`farmId`, `samplingAreaId`) |
| Tipo JSON | `json` (no jsonb) |
| ORM | Sequelize |
| IDs | UUID con `uuid_generate_v4()` |

---

## Estructura de Archivos Locales

```
supabase/schema/
├── reference/          # Tablas de referencia (enums)
│   ├── status.sql
│   ├── location.sql
│   ├── areas.sql
│   ├── soc.sql
│   └── workflows.sql
├── core/               # Entidades principales (ACTUALIZADOS camelCase)
│   ├── hub.sql         # hubs
│   ├── program.sql     # programs
│   ├── farm_owner.sql  # farmOwners
│   └── farm.sql        # farms ✅
├── areas/              # Áreas espaciales (ACTUALIZADOS camelCase)
│   ├── paddock.sql     # paddocks ✅
│   ├── sampling_area.sql # samplingAreas ✅
│   ├── exclusion_area.sql
│   ├── carbon_instance.sql
│   └── farm_subdivision.sql
├── monitoring/         # Sistema de monitoreo (ACTUALIZADOS camelCase)
│   ├── monitoring_site.sql     # monitoringSites ✅
│   ├── monitoring_event.sql    # monitoringEvents ✅
│   ├── monitoring_activity.sql # monitoringActivity ✅
│   ├── monitoring_task.sql     # monitoringTasks ✅
│   ├── monitoring_picture.sql
│   ├── program_monitoring_period.sql
│   ├── monitoring_report.sql
│   └── finding.sql
├── soc/                # Carbono orgánico del suelo
│   └── monitoring_soc_sample.sql
└── users/              # Historial y seguridad
    ├── history.sql
    ├── triggers.sql
    ├── rls_policies.sql
    └── security_fixes.sql
```

**ELIMINADOS** (no existen en ruuts-api):
- ~~`grass/`~~ - ISE, indicadores están en `monitoringTasks.dataPayload`
- ~~`biodiversity/`~~ - No existe schema biodiversity en ruuts
- ~~`users/user_profile.sql`~~ - Usuarios gestionados externamente

---

## Tablas Principales de ruuts-api

### Core (4 tablas)
| Tabla ruuts | Descripción |
|-------------|-------------|
| `hubs` | Centros regionales (con hubspotId) |
| `programs` | Programas de monitoreo |
| `farmOwners` | Propietarios |
| `farms` | Establecimientos con geometría PostGIS |

### Areas (5+ tablas)
| Tabla ruuts | Descripción |
|-------------|-------------|
| `paddocks` | Potreros/lotes |
| `samplingAreas` | Estratos de muestreo |
| `exclusionAreas` | Áreas de exclusión |
| `carbonInstances` | Instancias de carbono |
| `farmSubdivisions` | Subdivisiones |
| `forestAreas` | Áreas forestales |
| `wetlandAreas` | Humedales |
| `deforestedAreas` | Áreas deforestadas |

### Monitoring (10 tablas)
| Tabla ruuts | Descripción |
|-------------|-------------|
| `monitoringSites` | Sitios de monitoreo |
| `monitoringEvents` | Eventos/campañas |
| `monitoringActivity` | Actividades |
| `monitoringTasks` | Tareas (contiene `dataPayload` con datos GRASS) |
| `monitoringPictures` | Fotos |
| `programMonitoringPeriods` | Períodos de monitoreo |
| `monitoringReports` | Reportes |
| `formDefinitions` | Definiciones de formularios |

### SOC (3 tablas)
| Tabla ruuts | Descripción |
|-------------|-------------|
| `monitoringSOCSamples` | Muestras SOC |
| `monitoringSOCSitesSamples` | Muestras por sitio |
| `monitoringSOCSamplingAreaSamples` | Muestras por estrato |

---

## Datos GRASS/ISE

**IMPORTANTE**: Los datos de ISE, indicadores y procesos ecosistémicos **NO** están en tablas separadas.

Están almacenados como JSON en:
```
monitoringTasks.dataPayload (json)
```

Los formularios se definen en:
```
formDefinitions.fields (json)
```

---

## Tablas de Referencia (60+ tablas ref*)

### Status y Estados
- `refTaskStatus` - Estados de tareas
- `refMonitoringReportStatus` - Estados de reportes
- `refDataCollectionStatementStatus` - Estados de declaraciones
- `refFindingType` - Tipos de hallazgos
- `refInstancesVerificationStatus` - Estados de verificación

### Ubicación
- `refCountries` - Países
- `refLocationMovedReason` - Razones de reubicación
- `refLocationConfirmationType` - Tipos de confirmación GPS
- `refFieldRelocationMethod` - Métodos de reubicación

### SOC y Suelos
- `refDAPMethods` - Métodos DAP
- `refSamplingNumbers` - Números de muestreo
- `refSoilTexture` - Texturas de suelo
- `refSoilSamplingDisturbance` - Perturbación del muestreo
- `refSoilSamplingTools` - Herramientas de muestreo
- `refHorizonCode` - Códigos de horizonte
- `refStructureGrade/Size/Type` - Estructura del suelo
- `refDegreeDegradationSoil` - Degradación del suelo

### Ganadería (Sistema completo)
- `refBovineCattle` - Bovinos
- `refOvineCattle` - Ovinos
- `refEquineCattle` - Equinos
- `refCaprineCattle` - Caprinos
- `refBubalineCattle` - Búfalos
- `refCamelidCattle` - Camélidos
- `refCervidCattle` - Cérvidos
- `refCattleClass/SubClass/Type` - Clasificación
- `refCattleEmissionsFactors` - Factores de emisión
- `refCattleEquivalences` - Equivalencias
- `refLivestockRaisingTypes` - Tipos de cría

### Agricultura
- `refCropType` - Tipos de cultivo
- `refTillageType` - Tipos de labranza
- `refMineralFertilizerType` - Fertilizantes minerales
- `refOrganicFertilizerType` - Fertilizantes orgánicos
- `refAmmendmendType` - Tipos de enmienda
- `refIrrigationType` - Tipos de riego
- `refFieldUsage` - Uso del campo

### Pasturas y Forrajeo
- `refPasturesFamily/GrowthTypes/Types` - Pasturas
- `refGrazingType/IntensityTypes/PlanType` - Pastoreo
- `refForageSource/UseIntensity/UsePattern` - Forraje

### Emisiones
- `refFuelType` - Tipos de combustible
- `refFuelEmissionsFactors` - Factores de emisión
- `refGreenHouseGasesGwp` - GWP gases invernadero

---

## Tablas de Historial
- `monitoringSitesHistory`
- `monitoringTasksHistory`
- `dataCollectionStatementHistory`
- `findingHistory`
- `farmsHistory`
- `paddocksHistory`
- `samplingAreasHistory`
- `exclusionAreaHistory`

---

## Características Técnicas

- **PostGIS**: Geometrías sin SRID específico en dump (usar 4326)
- **JSON**: Usa `json` no `jsonb`
- **Soft Deletes**: Campo `isDeleted`
- **Audit Trail**: `createdAt`, `updatedAt`, `createdBy`, `updatedBy`
- **Versionado**: Campo `_rev` (UUID) para sync móvil
- **Sequelize**: ORM usado en ruuts-api

---

## Archivo de Referencia

El dump completo de ruuts-api está en:
```
docs/dump-postgres-202601141728.sql (263KB)
```

Contiene:
- Todas las definiciones de tablas (CREATE TABLE)
- Funciones PostgreSQL
- Constraints y foreign keys
- Datos semilla de tablas ref*
