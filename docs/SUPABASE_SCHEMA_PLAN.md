# Plan: Crear Schema Supabase para Reporte GRASS

## Resumen

Crear el schema de base de datos en Supabase basado en la estructura de ruuts-api, incluyendo todas las entidades necesarias para el sistema de reportes GRASS.

---

## 1. Tablas de Referencia

### Status y Estados
| Tabla | Valores |
|-------|---------|
| `ref_task_status` | 0:Pendiente, 1:En curso, 2:Finalizado, 3:Cancelado, 4:Omitido |
| `ref_verification_status` | pending, verified, rejected, needs_review |
| `ref_monitoring_report_status` | 0:En Curso (primary), 1:Finalizado (success) |
| `ref_data_collection_statement_status` | 0:Pending, 1:InProcess, 2:ToReview, 3:InReview, 4:Observed, 5:Approved, 6:FullApproved, 7:NonCompliant |
| `ref_finding_type` | 0:Observación, 1:Incumplimiento a corregir, 2:Incumplimiento grave |

### Ubicación y Sitios
| Tabla | Valores |
|-------|---------|
| `ref_location_moved_reason` | 0:Inaccesible, 1:Cambio uso terreno, 2:No representativo del estrato |
| `ref_location_confirmation_type` | 0:MDC, 1:GPS externo, 2:Manual |
| `ref_field_relocation_method` | 0:MDC Randomizer, 1:Manual |
| `ref_randomizer` | v1.0.0, v2.0.0, v3.0.0, v4.0.0 (con modelo asociado) |

### Áreas y Exclusiones
| Tabla | Valores |
|-------|---------|
| `ref_exclusion_area_type` | 0:Cuerpo agua, 1:Camino, 2:Instalaciones, 3:Reserva natural, 4:Monte nativo, 5:Zona improductiva, 6:Humedal, 7:Laguna seca, 8:Bosque implantado, 9:Curso agua, 10:Deforestación, 99:Otro |
| `ref_country` | ARG, URY, PRY, BRA, CHL |

### SOC y Suelos
| Tabla | Valores |
|-------|---------|
| `ref_dap_method` | 0:Intacta, 1:Excavación, 2:Anillo |
| `ref_sampling_number` | 0:Línea base, 1:Primer re-muestreo, 2:Segundo re-muestreo |
| `ref_soil_texture` | 12 tipos (Arcillosa, Arenosa, Franca, Limosa, combinaciones) |
| `ref_soil_sampling_disturbance` | 1:Intacta, 2:No intacta |
| `ref_soil_sampling_tools` | 1:Pala, 2:Calador |
| `rel_laboratory` | 0:AGROLABCS, 1:CETAPAR, 2:UNIV_AUSTRAL_CHILE, 3:EXATA |
| `rel_soc_protocol` | 0:Grass6_0, 1:BeforeGrass6_0 |

### Workflows y Layouts
| Tabla | Valores |
|-------|---------|
| `ref_activity_layout` | 0:SOC-GRID-4-20 (4 puntos), 1:LTM-GRID-V1 (14 puntos con transectos) |

---

## 2. Entidades Core

| Tabla | Campos Clave |
|-------|--------------|
| `hub` | id, name, country_id, province, referent_emails[], logo_url |
| `program` | id, name, code, description |
| `farm_owner` | id, name, legal_company_name, cuit, email, phone |
| `farm` | id, name, short_name, hub_id, program_id, owner_id, geometry, total_hectares, lat/lng, country_id, province, city, is_perimeter_validated |

---

## 3. Áreas Espaciales

| Tabla | Campos Clave |
|-------|--------------|
| `paddock` | id, name, code, farm_id, geometry, total_hectares, color, is_in_project |
| `sampling_area` | id, name, code, farm_id, geometry, total_hectares, percentage, stations_count, area_per_station, color |
| `exclusion_area` | id, name, other_name, farm_id, geometry, total_hectares, exclusion_area_type_id, has_grazing_management |
| `carbon_instance` | id, name, farm_id, sampling_area_id, init_date, instance_year, geometry, total_hectares, paddocks (JSONB), baseline_paddocks (JSONB), verification_status_id, verified_by, verified_at |
| `farm_subdivision` | id, farm_id, paddock_ids[], year, template_file_name, activities_status (JSONB[]) |

---

## 4. Monitoreo - Workflows y Sitios

| Tabla | Campos Clave |
|-------|--------------|
| `monitoring_workflow` | id (INT), name, code, description, definition (JSONB), activity_layout_id, site_required, allow_repetitive_tasks |
| `monitoring_site` | id, name, code, farm_id, sampling_area_id, allocated, planned_location (JSONB), actual_location (JSONB), backup_location (JSONB), location_confirmed, location_moved, location_moved_reason_id, location_moved_comments, location_confirmation_type_id, field_relocation_method_id, allow_contingency_offset, is_random_site, is_validation_site, offset_mts, distance_to_planned_location, randomize_counter, randomize_reason[], color, seed, randomizer_type_id, device_location_data (JSONB), _rev |
| `program_monitoring_period` | id, program_id, name, start_date, end_date |
| `rel_instance_monitoring_period` | id, carbon_instance_id, monitoring_period_id |

**Workflows Semilla:**
- 0: SOC (Monitoreo carbono suelo) - layout 0, site required
- 1: STM (Monitoreo corto plazo) - no layout, site required
- 2: LTM (Monitoreo largo plazo) - layout 1, site required
- 3: SOCPOA (SOC programa POA) - layout 0, site required
- 4: FBC (Validación perímetro) - layout 0, no site required, allows repetitive

---

## 5. Monitoreo - Eventos, Actividades y Tareas

| Tabla | Campos Clave |
|-------|--------------|
| `monitoring_event` | id, name, farm_id, date, task_status_id, completed_activities, total_activities, assigned_to, monitoring_workflow_ids[], sampling_areas[], monitoring_sites_ids[], is_backdated_event, _rev |
| `monitoring_activity` | id, key (unique con event_id), monitoring_event_id, monitoring_workflow_id, description, task_status_id, total_tasks, completed_tasks, sampling_area_id, monitoring_site_id, actual_location (JSONB), has_layout_pattern, activity_layout_id, activity_grid (JSONB), _rev |
| `monitoring_task` | id, key, order, enabled, monitoring_site_id, monitoring_activity_id, monitoring_event_id, task_status_id, form_name, type, grid_position_key, actual_location (JSONB), planned_location (JSONB), action_range_mts, dependencies[], description, data_payload (JSONB), pictures[], device_location_data (JSONB), _rev |
| `monitoring_picture` | id, name, key, monitoring_event_id, link, entity, entity_id, synced_to_s3, _rev |

---

## 6. Monitoreo SOC (Carbono Orgánico del Suelo)

| Tabla | Campos Clave |
|-------|--------------|
| `monitoring_soc_sample` | id, farm_id, sample_date, sampling_number_id, laboratory_id, soc_protocol_id, is_completed, uncompleted_reason |
| `monitoring_soc_site_sample` | id, monitoring_soc_sample_id, dap_method_id, dap, sample_volume, name, monitoring_soc_activity_id, wb_first_replica_percentage, wb_second_replica_percentage, ca_first_replica_percentage, ca_second_replica_percentage, leco_first_replica_percentage, leco_second_replica_percentage, dry_weight, gravel_weight, gravel_volume |
| `monitoring_soc_sampling_area_sample` | id, monitoring_soc_sample_id, stations_name, sampling_area_name, sampling_area_id, ph, nitrogen_percentage, phosphorus_percentage, fine_sand_percentage, coarse_sand_percentage, sand_percentage, silt_percentage, clay_percentage, soil_texture_type_id |

---

## 7. Reportes y Data Collection

| Tabla | Campos Clave |
|-------|--------------|
| `monitoring_report` | id, farm_id, monitoring_report_status_id, year, monitoring_event_ids[], monitoring_activity_ids[], user_input (JSONB), cached_files (JSONB) |
| `data_collection_statement` | id, data_collection_statement_status_id, owner_user_role_id, farm_subdivision_id (unique), metrics_events_ids[] |
| `form_definition` | id, program_id, namespace, version, label, required, required_message, show_map, show_table, allow_multiple_records, fields (JSONB), dependencies (JSONB) |

---

## 8. Hallazgos (Findings)

| Tabla | Campos Clave |
|-------|--------------|
| `finding` | id, metric_event_id, type (ref_finding_type), metric_events_fields_observed (JSONB[]), comment, resolved |
| `finding_comment` | id, finding_id, comment, created_by, created_at |

---

## 9. Datos GRASS Específicos (Para Reportes)

| Tabla | Campos Clave |
|-------|--------------|
| `ise_reading` | id, monitoring_event_id, monitoring_site_id, sampling_area_id, farm_id, ise_value, ise_1, ise_2, reading_date |
| `ecosystem_processes` | id, monitoring_event_id, monitoring_site_id, sampling_area_id, farm_id, ciclo_agua, ciclo_mineral, flujo_energia, dinamica_comunidades, reading_date |
| `indicator_reading` | id, monitoring_event_id, monitoring_site_id, farm_id, abundancia_canopeo, microfauna, gf1_pastos_verano, gf2_pastos_invierno, gf3_hierbas_leguminosas, gf4_arboles_arbustos, especies_deseables, especies_indeseables, abundancia_mantillo, incorporacion_mantillo, descomposicion_bostas, suelo_desnudo, encostramiento, erosion_eolica, erosion_hidrica, estructura_suelo, reading_date |
| `recommendation` | id, farm_id, sampling_area_id, monitoring_report_id, suggestion, priority, category, is_implemented, implemented_at |

---

## 10. Biodiversidad (Schema: biodiversity)

### Tablas de Referencia Biodiversidad
| Tabla | Valores/Cantidad |
|-------|------------------|
| `ref_ecoregions` | 17 ecoregiones (Pampa, Chaco Húmedo/Seco, Espinal, Yungas, Patagonia, etc.) |
| `ref_biodiversity_indicator` | 15 indicadores con key, min/max value, step |
| `ref_functional_group` | 11 grupos (Anuales, Gramíneas, Leguminosas, Arbustos, etc.) |
| `ref_ambient_matrix` | 25 matrices ambientales (Pampa Húmeda, Espinal, Caldenal, Monte, etc.) |
| `ref_landscape_index` | 4 índices: Ciclo Agua, Ciclo Minerales, Dinámica Comunidades, Flujo Energía |

### Indicadores de Biodiversidad (ref_biodiversity_indicator)
| ID | Key | Nombre | Min | Max | Step |
|----|-----|--------|-----|-----|------|
| 1 | liveCanopyAbundance | Abundancia de Canopeo | -10 | 10 | 5 |
| 2 | livingOrganisms | Organismos Vivos | -10 | 10 | 5 |
| 3 | warmSeasonGrasses | Pastos de Verano | -10 | 10 | 5 |
| 4 | coolSeasonGrasses | Pastos de Invierno | -10 | 10 | 5 |
| 5 | forbsAndLegumes | Hierbas y Leguminosas | -10 | 10 | 5 |
| 6 | treesAndShrubs | Árboles y Arbustos | -10 | 10 | 5 |
| 7 | desirableRareSpecies | Especies Deseables | 0 | 10 | 5 |
| 8 | nonDesirableRareSpecies | Especies Indeseables | -10 | 0 | 5 |
| 9 | litterAbundance | Mantillo | 0 | 10 | 5 |
| 10 | litterDecomposition | Incorporación del Mantillo | 0 | 10 | 5 |
| 11 | dungDecomposition | Desaparición de Excrementos | 0 | 10 | 5 |
| 12 | bareSoil | Suelo Desnudo | -20 | 20 | 10 |
| 13 | capping | Encostramiento | -10 | 0 | 5 |
| 14 | windErosion | Erosión Eólica | -20 | 0 | 10 |
| 15 | waterErosion | Erosión Hídrica | -20 | 0 | 10 |

### Entidades de Biodiversidad
| Tabla | Campos Clave |
|-------|--------------|
| `species` | id, scientific_name (unique), common_name, common_names[], family, genre, reference_link |
| `ecoregions` | id, name, country, geometry (PostGIS) |
| `rel_ambient_matrix_biodiversity_indicator` | id, ref_ambient_matrix_id, ref_biodiversity_indicator_id (unique pair) |
| `rel_landscape_index_ambient_matrix` | id, ref_ambient_matrix_id, ref_landscape_index_id, min_value, max_value (unique pair) |

### Rangos por Defecto (rel_landscape_index_ambient_matrix)
| Landscape Index | Min | Max |
|-----------------|-----|-----|
| Ciclo Minerales | -30 | 60 |
| Ciclo Agua | -70 | 30 |
| Dinámica Comunidades | -50 | 50 (o -40/40 para algunas matrices) |
| Flujo Energía | -10 | 10 |

**Nota:** La tabla `species` contiene 1,329+ especies con nombres científicos y comunes.

---

## 11. Tablas de Historial

| Tabla | Campos |
|-------|--------|
| `monitoring_site_history` | Espejo de monitoring_site + monitoring_site_id |
| `monitoring_task_history` | Espejo de monitoring_task + monitoring_task_id |
| `data_collection_statement_history` | Espejo + data_collection_statement_id |
| `finding_history` | Espejo de finding + finding_id |

---

## 12. Usuarios y Acceso

| Tabla | Campos Clave |
|-------|--------------|
| `user_profile` | id (refs auth.users), full_name, avatar_url, phone, role, hub_id, preferences (JSONB) |
| `farm_access` | id, user_id, farm_id, access_level (owner/editor/viewer), granted_at, granted_by, expires_at, is_active |
| `ref_user_role` | id, name (admin, hub_admin, technician, viewer, owner) |

---

## 13. Características Técnicas

1. **PostGIS**: Geometrías con SRID 4326 (WGS84), campos geometry y _geometry para Point
2. **Índices GIST**: En todas las columnas geometry
3. **Soft Deletes**: Campo `is_deleted` en todas las tablas principales
4. **Audit Trail**: `created_at`, `updated_at`, `created_by`, `updated_by`
5. **Versionado**: Campo `_rev` (UUID) en entidades con sync móvil
6. **Triggers**: Auto-update de `updated_at`
7. **RLS Policies**: Basadas en `farm_access` y roles de usuario
8. **Constraints Únicos**:
   - (monitoring_activity.key, monitoring_event_id)
   - (data_collection_statement.farm_subdivision_id, is_deleted)
   - (program_monitoring_period.program_id, name)

---

## 14. Vistas para Reportes

- `v_farm_summary` - Resumen de establecimiento con ISE más reciente
- `v_strata_summary` - Resumen por estrato con estadísticas
- `v_ise_historical` - Histórico de ISE para gráficos
- `v_ecosystem_processes_historical` - Histórico de procesos ecosistémicos
- `v_monitoring_sites_with_data` - Sitios con sus indicadores para el mapa
- `v_monitoring_events_summary` - Resumen de eventos con progreso
- `v_soc_samples_summary` - Resumen de muestras SOC

---

## 15. Orden de Migraciones

1. Extensiones (uuid-ossp, postgis)
2. Schema `biodiversity`
3. Tablas de referencia (ref_*) con datos semilla
4. Tablas de relación (rel_laboratory, rel_soc_protocol)
5. Core: hub → program → farm_owner → farm
6. Áreas: paddock, sampling_area, exclusion_area, carbon_instance, farm_subdivision
7. Monitoreo base: monitoring_workflow, ref_activity_layout, program_monitoring_period
8. Monitoreo sitios: monitoring_site
9. Monitoreo eventos: monitoring_event → monitoring_activity → monitoring_task
10. Monitoreo SOC: monitoring_soc_sample → site_sample, sampling_area_sample
11. Reportes: monitoring_report, monitoring_picture, form_definition
12. Data collection: data_collection_statement
13. Findings: finding, finding_comment
14. GRASS específico: ise_reading, ecosystem_processes, indicator_reading, recommendation
15. Biodiversidad: ref tables → species, ecoregions → rel tables
16. Usuarios: user_profile, farm_access
17. Tablas de historial
18. Índices y triggers
19. RLS policies
20. Vistas

---

## 16. Verificación

1. `mcp__supabase__list_tables` - Verificar todas las tablas creadas
2. `mcp__supabase__get_advisors` type="security" - Verificar RLS
3. Insertar datos de prueba en tablas principales
4. Verificar vistas retornan datos correctamente
5. Probar funciones de cálculo ISE
