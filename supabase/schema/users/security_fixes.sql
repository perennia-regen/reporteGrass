-- Security fixes: RLS for reference tables, function search paths, and history tables

-- Fix function search paths
CREATE OR REPLACE FUNCTION has_farm_access(farm_uuid UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.farm_access
        WHERE user_id = auth.uid()
        AND farm_id = farm_uuid
        AND is_active = TRUE
        AND (expires_at IS NULL OR expires_at > NOW())
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM public.user_profile
        WHERE id = auth.uid()
        AND role IN ('admin', 'hub_admin')
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SET search_path = public;

-- Enable RLS on reference tables (public read access)
ALTER TABLE ref_task_status ENABLE ROW LEVEL SECURITY;
ALTER TABLE ref_verification_status ENABLE ROW LEVEL SECURITY;
ALTER TABLE ref_monitoring_report_status ENABLE ROW LEVEL SECURITY;
ALTER TABLE ref_data_collection_statement_status ENABLE ROW LEVEL SECURITY;
ALTER TABLE ref_finding_type ENABLE ROW LEVEL SECURITY;
ALTER TABLE ref_user_role ENABLE ROW LEVEL SECURITY;
ALTER TABLE ref_location_moved_reason ENABLE ROW LEVEL SECURITY;
ALTER TABLE ref_location_confirmation_type ENABLE ROW LEVEL SECURITY;
ALTER TABLE ref_field_relocation_method ENABLE ROW LEVEL SECURITY;
ALTER TABLE ref_randomizer ENABLE ROW LEVEL SECURITY;
ALTER TABLE ref_country ENABLE ROW LEVEL SECURITY;
ALTER TABLE ref_exclusion_area_type ENABLE ROW LEVEL SECURITY;
ALTER TABLE ref_dap_method ENABLE ROW LEVEL SECURITY;
ALTER TABLE ref_sampling_number ENABLE ROW LEVEL SECURITY;
ALTER TABLE ref_soil_texture ENABLE ROW LEVEL SECURITY;
ALTER TABLE ref_soil_sampling_disturbance ENABLE ROW LEVEL SECURITY;
ALTER TABLE ref_soil_sampling_tools ENABLE ROW LEVEL SECURITY;
ALTER TABLE ref_activity_layout ENABLE ROW LEVEL SECURITY;
ALTER TABLE monitoring_workflow ENABLE ROW LEVEL SECURITY;
ALTER TABLE rel_laboratory ENABLE ROW LEVEL SECURITY;
ALTER TABLE rel_soc_protocol ENABLE ROW LEVEL SECURITY;

-- Public read policies for reference tables
CREATE POLICY ref_task_status_select ON ref_task_status FOR SELECT USING (true);
CREATE POLICY ref_verification_status_select ON ref_verification_status FOR SELECT USING (true);
CREATE POLICY ref_monitoring_report_status_select ON ref_monitoring_report_status FOR SELECT USING (true);
CREATE POLICY ref_data_collection_statement_status_select ON ref_data_collection_statement_status FOR SELECT USING (true);
CREATE POLICY ref_finding_type_select ON ref_finding_type FOR SELECT USING (true);
CREATE POLICY ref_user_role_select ON ref_user_role FOR SELECT USING (true);
CREATE POLICY ref_location_moved_reason_select ON ref_location_moved_reason FOR SELECT USING (true);
CREATE POLICY ref_location_confirmation_type_select ON ref_location_confirmation_type FOR SELECT USING (true);
CREATE POLICY ref_field_relocation_method_select ON ref_field_relocation_method FOR SELECT USING (true);
CREATE POLICY ref_randomizer_select ON ref_randomizer FOR SELECT USING (true);
CREATE POLICY ref_country_select ON ref_country FOR SELECT USING (true);
CREATE POLICY ref_exclusion_area_type_select ON ref_exclusion_area_type FOR SELECT USING (true);
CREATE POLICY ref_dap_method_select ON ref_dap_method FOR SELECT USING (true);
CREATE POLICY ref_sampling_number_select ON ref_sampling_number FOR SELECT USING (true);
CREATE POLICY ref_soil_texture_select ON ref_soil_texture FOR SELECT USING (true);
CREATE POLICY ref_soil_sampling_disturbance_select ON ref_soil_sampling_disturbance FOR SELECT USING (true);
CREATE POLICY ref_soil_sampling_tools_select ON ref_soil_sampling_tools FOR SELECT USING (true);
CREATE POLICY ref_activity_layout_select ON ref_activity_layout FOR SELECT USING (true);
CREATE POLICY monitoring_workflow_select ON monitoring_workflow FOR SELECT USING (true);
CREATE POLICY rel_laboratory_select ON rel_laboratory FOR SELECT USING (true);
CREATE POLICY rel_soc_protocol_select ON rel_soc_protocol FOR SELECT USING (true);

-- Enable RLS on other tables
ALTER TABLE hub ENABLE ROW LEVEL SECURITY;
ALTER TABLE program ENABLE ROW LEVEL SECURITY;
ALTER TABLE farm_owner ENABLE ROW LEVEL SECURITY;
ALTER TABLE farm_subdivision ENABLE ROW LEVEL SECURITY;
ALTER TABLE program_monitoring_period ENABLE ROW LEVEL SECURITY;
ALTER TABLE rel_instance_monitoring_period ENABLE ROW LEVEL SECURITY;
ALTER TABLE monitoring_soc_site_sample ENABLE ROW LEVEL SECURITY;
ALTER TABLE monitoring_soc_sampling_area_sample ENABLE ROW LEVEL SECURITY;
ALTER TABLE data_collection_statement ENABLE ROW LEVEL SECURITY;
ALTER TABLE form_definition ENABLE ROW LEVEL SECURITY;
ALTER TABLE finding ENABLE ROW LEVEL SECURITY;
ALTER TABLE finding_comment ENABLE ROW LEVEL SECURITY;

-- Policies for hub, program, farm_owner
CREATE POLICY hub_select ON hub FOR SELECT USING (true);
CREATE POLICY hub_all ON hub FOR ALL USING (is_admin());

CREATE POLICY program_select ON program FOR SELECT USING (true);
CREATE POLICY program_all ON program FOR ALL USING (is_admin());

CREATE POLICY farm_owner_select ON farm_owner FOR SELECT USING (is_admin());
CREATE POLICY farm_owner_all ON farm_owner FOR ALL USING (is_admin());

-- Farm subdivision policies
CREATE POLICY farm_subdivision_select ON farm_subdivision FOR SELECT USING (has_farm_access(farm_id) OR is_admin());
CREATE POLICY farm_subdivision_all ON farm_subdivision FOR ALL USING (has_farm_access(farm_id) OR is_admin());

-- Program monitoring period policies
CREATE POLICY program_monitoring_period_select ON program_monitoring_period FOR SELECT USING (true);
CREATE POLICY program_monitoring_period_all ON program_monitoring_period FOR ALL USING (is_admin());

-- Instance monitoring period policies
CREATE POLICY rel_instance_monitoring_period_select ON rel_instance_monitoring_period FOR SELECT USING (true);
CREATE POLICY rel_instance_monitoring_period_all ON rel_instance_monitoring_period FOR ALL USING (is_admin());

-- SOC site sample policies
CREATE POLICY monitoring_soc_site_sample_select ON monitoring_soc_site_sample FOR SELECT USING (
    EXISTS (SELECT 1 FROM monitoring_soc_sample mss WHERE mss.id = monitoring_soc_sample_id AND (has_farm_access(mss.farm_id) OR is_admin()))
);
CREATE POLICY monitoring_soc_site_sample_all ON monitoring_soc_site_sample FOR ALL USING (
    EXISTS (SELECT 1 FROM monitoring_soc_sample mss WHERE mss.id = monitoring_soc_sample_id AND (has_farm_access(mss.farm_id) OR is_admin()))
);

-- SOC sampling area sample policies
CREATE POLICY monitoring_soc_sampling_area_sample_select ON monitoring_soc_sampling_area_sample FOR SELECT USING (
    EXISTS (SELECT 1 FROM monitoring_soc_sample mss WHERE mss.id = monitoring_soc_sample_id AND (has_farm_access(mss.farm_id) OR is_admin()))
);
CREATE POLICY monitoring_soc_sampling_area_sample_all ON monitoring_soc_sampling_area_sample FOR ALL USING (
    EXISTS (SELECT 1 FROM monitoring_soc_sample mss WHERE mss.id = monitoring_soc_sample_id AND (has_farm_access(mss.farm_id) OR is_admin()))
);

-- Data collection statement policies
CREATE POLICY data_collection_statement_select ON data_collection_statement FOR SELECT USING (
    EXISTS (SELECT 1 FROM farm_subdivision fs WHERE fs.id = farm_subdivision_id AND (has_farm_access(fs.farm_id) OR is_admin()))
);
CREATE POLICY data_collection_statement_all ON data_collection_statement FOR ALL USING (
    EXISTS (SELECT 1 FROM farm_subdivision fs WHERE fs.id = farm_subdivision_id AND (has_farm_access(fs.farm_id) OR is_admin()))
);

-- Form definition policies
CREATE POLICY form_definition_select ON form_definition FOR SELECT USING (true);
CREATE POLICY form_definition_all ON form_definition FOR ALL USING (is_admin());

-- Finding policies
CREATE POLICY finding_select ON finding FOR SELECT USING (is_admin());
CREATE POLICY finding_all ON finding FOR ALL USING (is_admin());

CREATE POLICY finding_comment_select ON finding_comment FOR SELECT USING (is_admin());
CREATE POLICY finding_comment_all ON finding_comment FOR ALL USING (is_admin());

-- History tables RLS
ALTER TABLE monitoring_site_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE monitoring_task_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE data_collection_statement_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE finding_history ENABLE ROW LEVEL SECURITY;

CREATE POLICY monitoring_site_history_select ON monitoring_site_history FOR SELECT USING (is_admin());
CREATE POLICY monitoring_task_history_select ON monitoring_task_history FOR SELECT USING (is_admin());
CREATE POLICY data_collection_statement_history_select ON data_collection_statement_history FOR SELECT USING (is_admin());
CREATE POLICY finding_history_select ON finding_history FOR SELECT USING (is_admin());
