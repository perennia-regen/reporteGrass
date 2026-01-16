-- Domain: Views
-- Views for reporting and data access

-- Farm Summary View
CREATE OR REPLACE VIEW v_farm_summary AS
SELECT
    f.id,
    f.name,
    f.short_name,
    f.total_hectares,
    f.lat,
    f.lng,
    f.country,
    f.province,
    f.city,
    f.is_perimeter_validated,
    h.name AS hub_name,
    p.name AS program_name,
    fo.name AS owner_name,
    (SELECT COUNT(*) FROM paddock pd WHERE pd.farm_id = f.id AND pd.is_deleted = FALSE) AS paddock_count,
    (SELECT COUNT(*) FROM sampling_area sa WHERE sa.farm_id = f.id AND sa.is_deleted = FALSE) AS strata_count,
    (SELECT COUNT(*) FROM monitoring_site ms WHERE ms.farm_id = f.id AND ms.is_deleted = FALSE) AS site_count,
    (SELECT ise_value FROM ise_reading ir WHERE ir.farm_id = f.id ORDER BY ir.reading_date DESC LIMIT 1) AS latest_ise,
    f.created_at,
    f.updated_at
FROM farm f
LEFT JOIN hub h ON f.hub_id = h.id
LEFT JOIN program p ON f.program_id = p.id
LEFT JOIN farm_owner fo ON f.owner_id = fo.id
WHERE f.is_deleted = FALSE;

-- Strata (Sampling Area) Summary View
CREATE OR REPLACE VIEW v_strata_summary AS
SELECT
    sa.id,
    sa.name,
    sa.code,
    sa.farm_id,
    f.name AS farm_name,
    sa.total_hectares,
    sa.percentage,
    sa.stations_count,
    sa.color,
    (SELECT COUNT(*) FROM monitoring_site ms WHERE ms.sampling_area_id = sa.id AND ms.is_deleted = FALSE) AS site_count,
    (SELECT AVG(ise_value) FROM ise_reading ir WHERE ir.sampling_area_id = sa.id) AS avg_ise,
    (SELECT ise_value FROM ise_reading ir WHERE ir.sampling_area_id = sa.id ORDER BY ir.reading_date DESC LIMIT 1) AS latest_ise,
    sa.created_at
FROM sampling_area sa
JOIN farm f ON sa.farm_id = f.id
WHERE sa.is_deleted = FALSE;

-- ISE Historical View
CREATE OR REPLACE VIEW v_ise_historical AS
SELECT
    ir.id,
    ir.farm_id,
    f.name AS farm_name,
    ir.sampling_area_id,
    sa.name AS sampling_area_name,
    ir.monitoring_site_id,
    ms.name AS site_name,
    ir.ise_value,
    ir.ise_1,
    ir.ise_2,
    ir.reading_date,
    me.name AS event_name
FROM ise_reading ir
JOIN farm f ON ir.farm_id = f.id
LEFT JOIN sampling_area sa ON ir.sampling_area_id = sa.id
LEFT JOIN monitoring_site ms ON ir.monitoring_site_id = ms.id
LEFT JOIN monitoring_event me ON ir.monitoring_event_id = me.id
WHERE ir.is_deleted = FALSE
ORDER BY ir.reading_date DESC;

-- Ecosystem Processes Historical View
CREATE OR REPLACE VIEW v_ecosystem_processes_historical AS
SELECT
    ep.id,
    ep.farm_id,
    f.name AS farm_name,
    ep.sampling_area_id,
    sa.name AS sampling_area_name,
    ep.monitoring_site_id,
    ms.name AS site_name,
    ep.ciclo_agua,
    ep.ciclo_mineral,
    ep.flujo_energia,
    ep.dinamica_comunidades,
    ep.reading_date,
    me.name AS event_name
FROM ecosystem_processes ep
JOIN farm f ON ep.farm_id = f.id
LEFT JOIN sampling_area sa ON ep.sampling_area_id = sa.id
LEFT JOIN monitoring_site ms ON ep.monitoring_site_id = ms.id
LEFT JOIN monitoring_event me ON ep.monitoring_event_id = me.id
WHERE ep.is_deleted = FALSE
ORDER BY ep.reading_date DESC;

-- Monitoring Sites with Data View
CREATE OR REPLACE VIEW v_monitoring_sites_with_data AS
SELECT
    ms.id,
    ms.name,
    ms.code,
    ms.farm_id,
    f.name AS farm_name,
    ms.sampling_area_id,
    sa.name AS sampling_area_name,
    ms.actual_location,
    ms.planned_location,
    ms.location_confirmed,
    ms.is_random_site,
    ms.is_validation_site,
    ms.color,
    (SELECT ise_value FROM ise_reading ir WHERE ir.monitoring_site_id = ms.id ORDER BY ir.reading_date DESC LIMIT 1) AS latest_ise,
    (SELECT reading_date FROM ise_reading ir WHERE ir.monitoring_site_id = ms.id ORDER BY ir.reading_date DESC LIMIT 1) AS latest_reading_date
FROM monitoring_site ms
JOIN farm f ON ms.farm_id = f.id
LEFT JOIN sampling_area sa ON ms.sampling_area_id = sa.id
WHERE ms.is_deleted = FALSE;

-- Monitoring Events Summary View
CREATE OR REPLACE VIEW v_monitoring_events_summary AS
SELECT
    me.id,
    me.name,
    me.farm_id,
    f.name AS farm_name,
    me.event_date,
    ts.name AS status,
    me.completed_activities,
    me.total_activities,
    CASE
        WHEN me.total_activities > 0
        THEN ROUND((me.completed_activities::DECIMAL / me.total_activities) * 100, 2)
        ELSE 0
    END AS progress_percentage,
    me.assigned_to,
    me.is_backdated_event,
    me.created_at
FROM monitoring_event me
JOIN farm f ON me.farm_id = f.id
LEFT JOIN ref_task_status ts ON me.task_status_id = ts.id
WHERE me.is_deleted = FALSE
ORDER BY me.event_date DESC;

-- SOC Samples Summary View
CREATE OR REPLACE VIEW v_soc_samples_summary AS
SELECT
    mss.id,
    mss.farm_id,
    f.name AS farm_name,
    mss.sample_date,
    sn.es_ar AS sampling_number,
    lab.name AS laboratory,
    sp.name AS soc_protocol,
    mss.is_completed,
    mss.uncompleted_reason,
    (SELECT COUNT(*) FROM monitoring_soc_site_sample msss WHERE msss.monitoring_soc_sample_id = mss.id) AS site_samples_count,
    (SELECT COUNT(*) FROM monitoring_soc_sampling_area_sample mssas WHERE mssas.monitoring_soc_sample_id = mss.id) AS area_samples_count
FROM monitoring_soc_sample mss
JOIN farm f ON mss.farm_id = f.id
LEFT JOIN ref_sampling_number sn ON mss.sampling_number_id = sn.id
LEFT JOIN rel_laboratory lab ON mss.laboratory_id = lab.id
LEFT JOIN rel_soc_protocol sp ON mss.soc_protocol_id = sp.id
WHERE mss.is_deleted = FALSE
ORDER BY mss.sample_date DESC;

-- Indicator Readings Full View
CREATE OR REPLACE VIEW v_indicator_readings AS
SELECT
    ir.id,
    ir.farm_id,
    f.name AS farm_name,
    ir.monitoring_site_id,
    ms.name AS site_name,
    ir.abundancia_canopeo,
    ir.microfauna,
    ir.gf1_pastos_verano,
    ir.gf2_pastos_invierno,
    ir.gf3_hierbas_leguminosas,
    ir.gf4_arboles_arbustos,
    ir.especies_deseables,
    ir.especies_indeseables,
    ir.abundancia_mantillo,
    ir.incorporacion_mantillo,
    ir.descomposicion_bostas,
    ir.suelo_desnudo,
    ir.encostramiento,
    ir.erosion_eolica,
    ir.erosion_hidrica,
    ir.estructura_suelo,
    ir.reading_date,
    me.name AS event_name
FROM indicator_reading ir
JOIN farm f ON ir.farm_id = f.id
LEFT JOIN monitoring_site ms ON ir.monitoring_site_id = ms.id
LEFT JOIN monitoring_event me ON ir.monitoring_event_id = me.id
WHERE ir.is_deleted = FALSE
ORDER BY ir.reading_date DESC;

COMMENT ON VIEW v_farm_summary IS 'Summary of farms with latest ISE and counts';
COMMENT ON VIEW v_strata_summary IS 'Summary of sampling areas with statistics';
COMMENT ON VIEW v_ise_historical IS 'Historical ISE readings for charts';
COMMENT ON VIEW v_ecosystem_processes_historical IS 'Historical ecosystem process data';
COMMENT ON VIEW v_monitoring_sites_with_data IS 'Monitoring sites with latest readings for maps';
COMMENT ON VIEW v_monitoring_events_summary IS 'Monitoring events with progress';
COMMENT ON VIEW v_soc_samples_summary IS 'SOC sample summaries';
COMMENT ON VIEW v_indicator_readings IS 'Full indicator readings with context';
