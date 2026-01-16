# Supabase Schema - Reporte GRASS

## Resumen

Schema de base de datos para el sistema de reportes GRASS, basado en la estructura de ruuts-api.

**Fecha de creación:** 2026-01-16
**Migraciones aplicadas:** 18

---

## Estructura de Archivos Locales

```
supabase/schema/
├── reference/          # Tablas de referencia (enums)
│   ├── status.sql      # ref_task_status, ref_verification_status, etc.
│   ├── location.sql    # ref_location_moved_reason, ref_country, etc.
│   ├── areas.sql       # ref_exclusion_area_type
│   ├── soc.sql         # ref_dap_method, ref_soil_texture, rel_laboratory, etc.
│   └── workflows.sql   # ref_activity_layout, monitoring_workflow
├── core/               # Entidades principales
│   ├── hub.sql
│   ├── program.sql
│   ├── farm_owner.sql
│   └── farm.sql
├── areas/              # Áreas espaciales (PostGIS)
│   ├── paddock.sql
│   ├── sampling_area.sql
│   ├── exclusion_area.sql
│   ├── carbon_instance.sql
│   └── farm_subdivision.sql
├── monitoring/         # Sistema de monitoreo
│   ├── monitoring_site.sql
│   ├── monitoring_event.sql
│   ├── monitoring_activity.sql
│   ├── monitoring_task.sql
│   ├── monitoring_picture.sql
│   ├── program_monitoring_period.sql
│   ├── monitoring_report.sql
│   └── finding.sql
├── soc/                # Carbono orgánico del suelo
│   └── monitoring_soc_sample.sql
├── grass/              # Datos específicos GRASS
│   ├── ise_reading.sql
│   ├── ecosystem_processes.sql
│   ├── indicator_reading.sql
│   └── recommendation.sql
├── biodiversity/       # Schema biodiversity
│   ├── ref_tables.sql
│   └── entities.sql
├── users/              # Usuarios y seguridad
│   ├── user_profile.sql
│   ├── history.sql
│   ├── triggers.sql
│   ├── rls_policies.sql
│   └── security_fixes.sql
└── users/              # (último directorio)
```

---

## Migraciones Aplicadas

| # | Nombre | Descripción |
|---|--------|-------------|
| 001 | enable_extensions_and_schemas | uuid-ossp, postgis, schema biodiversity |
| 002 | ref_tables_status | ref_task_status, ref_verification_status, etc. |
| 003 | ref_tables_location | ref_location_moved_reason, ref_country, etc. |
| 004 | ref_tables_areas_soc | ref_exclusion_area_type, ref_dap_method, etc. |
| 005 | ref_workflows | ref_activity_layout, monitoring_workflow |
| 006 | core_entities | hub, program, farm_owner, farm |
| 007 | areas_spatial | paddock, sampling_area, exclusion_area, carbon_instance |
| 008 | monitoring_tables | monitoring_site |
| 009 | monitoring_events_activities | monitoring_event, monitoring_activity, monitoring_task |
| 010 | soc_and_reports | monitoring_soc_sample, monitoring_report, form_definition |
| 011 | grass_specific_tables | ise_reading, ecosystem_processes, indicator_reading |
| 012 | biodiversity_tables | species, ecoregions, ref tables biodiversity |
| 013 | user_tables | user_profile, farm_access |
| 014 | history_tables | monitoring_site_history, monitoring_task_history, etc. |
| 015 | triggers_and_functions | update_updated_at_column trigger |
| 016 | rls_policies | Row Level Security policies |
| 017 | views | ~~DROPPEADAS~~ (no eran de ruuts-api) |
| 018 | security_fixes | RLS para ref tables, function search paths |
| 019 | drop_views | **PENDIENTE** - Ejecutar DROP de vistas |

---

## Tablas por Dominio

### Reference (21 tablas)
- `ref_task_status` - Estados de tareas (Pendiente, En Curso, Finalizado, etc.)
- `ref_verification_status` - Estados de verificación
- `ref_monitoring_report_status` - Estados de reportes
- `ref_data_collection_statement_status` - Estados de declaraciones
- `ref_finding_type` - Tipos de hallazgos
- `ref_user_role` - Roles de usuario
- `ref_location_moved_reason` - Razones de reubicación
- `ref_location_confirmation_type` - Tipos de confirmación GPS
- `ref_field_relocation_method` - Métodos de reubicación
- `ref_randomizer` - Versiones del randomizer
- `ref_country` - Países (ARG, URY, PRY, BRA, CHL)
- `ref_exclusion_area_type` - Tipos de áreas de exclusión
- `ref_dap_method` - Métodos DAP
- `ref_sampling_number` - Números de muestreo
- `ref_soil_texture` - Texturas de suelo (12 tipos)
- `ref_soil_sampling_disturbance` - Perturbación del muestreo
- `ref_soil_sampling_tools` - Herramientas de muestreo
- `ref_activity_layout` - Layouts de actividad
- `monitoring_workflow` - Workflows (SOC, STM, LTM, SOCPOA, FBC)
- `rel_laboratory` - Laboratorios
- `rel_soc_protocol` - Protocolos SOC

### Core (4 tablas)
- `hub` - Centros regionales
- `program` - Programas de monitoreo
- `farm_owner` - Propietarios
- `farm` - Establecimientos (con geometría PostGIS)

### Areas (5 tablas)
- `paddock` - Potreros/lotes
- `sampling_area` - Estratos de muestreo
- `exclusion_area` - Áreas de exclusión
- `carbon_instance` - Instancias de carbono
- `farm_subdivision` - Subdivisiones

### Monitoring (10 tablas)
- `monitoring_site` - Sitios de monitoreo
- `monitoring_event` - Eventos/campañas
- `monitoring_activity` - Actividades
- `monitoring_task` - Tareas
- `monitoring_picture` - Fotos
- `program_monitoring_period` - Períodos de monitoreo
- `rel_instance_monitoring_period` - Relación instancia-período
- `monitoring_soc_sample` - Muestras SOC
- `monitoring_soc_site_sample` - Muestras por sitio
- `monitoring_soc_sampling_area_sample` - Muestras por estrato

### Reports (5 tablas)
- `monitoring_report` - Reportes de monitoreo
- `form_definition` - Definiciones de formularios
- `data_collection_statement` - Declaraciones de datos
- `finding` - Hallazgos
- `finding_comment` - Comentarios de hallazgos

### GRASS (4 tablas)
- `ise_reading` - Lecturas ISE
- `ecosystem_processes` - Procesos ecosistémicos
- `indicator_reading` - Lecturas de indicadores
- `recommendation` - Recomendaciones

### Biodiversity (8 tablas en schema `biodiversity`)
- `ref_ecoregions` - 17 ecoregiones
- `ref_biodiversity_indicator` - 15 indicadores
- `ref_functional_group` - 11 grupos funcionales
- `ref_ambient_matrix` - 25 matrices ambientales
- `ref_landscape_index` - 4 índices de paisaje
- `species` - Especies (pendiente cargar ~1,329)
- `ecoregions` - Ecoregiones con geometría
- `rel_ambient_matrix_biodiversity_indicator` - Relación matriz-indicador
- `rel_landscape_index_ambient_matrix` - Relación índice-matriz

### Users & History (6 tablas)
- `user_profile` - Perfiles de usuario
- `farm_access` - Control de acceso a farms
- `monitoring_site_history` - Historial de sitios
- `monitoring_task_history` - Historial de tareas
- `data_collection_statement_history` - Historial de declaraciones
- `finding_history` - Historial de hallazgos

---

## Características Técnicas

- **PostGIS**: Geometrías SRID 4326 (WGS84)
- **Índices GIST**: En columnas geometry
- **Soft Deletes**: Campo `is_deleted` en tablas principales
- **Audit Trail**: `created_at`, `updated_at`, `created_by`, `updated_by`
- **Versionado**: Campo `_rev` (UUID) para sync móvil
- **Triggers**: Auto-update de `updated_at`
- **RLS**: Row Level Security basado en `farm_access`

---

## Funciones Helper

```sql
-- Verificar acceso a farm
has_farm_access(farm_uuid UUID) RETURNS BOOLEAN

-- Verificar si es admin
is_admin() RETURNS BOOLEAN

-- Auto-update timestamp
update_updated_at_column() RETURNS TRIGGER
```

---

## Pendiente

1. Cargar especies en `biodiversity.species` (~1,329 registros)
2. Poblar `rel_landscape_index_ambient_matrix` con rangos default
3. Insertar datos de prueba
4. Verificar vistas con datos reales
