-- Domain: Functions and Triggers
-- Auto-update updated_at timestamp

-- Function to update updated_at
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to all tables with updated_at column
CREATE TRIGGER tr_hub_updated_at BEFORE UPDATE ON hub FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER tr_program_updated_at BEFORE UPDATE ON program FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER tr_farm_owner_updated_at BEFORE UPDATE ON farm_owner FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER tr_farm_updated_at BEFORE UPDATE ON farm FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER tr_paddock_updated_at BEFORE UPDATE ON paddock FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER tr_sampling_area_updated_at BEFORE UPDATE ON sampling_area FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER tr_exclusion_area_updated_at BEFORE UPDATE ON exclusion_area FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER tr_carbon_instance_updated_at BEFORE UPDATE ON carbon_instance FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER tr_farm_subdivision_updated_at BEFORE UPDATE ON farm_subdivision FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER tr_monitoring_site_updated_at BEFORE UPDATE ON monitoring_site FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER tr_monitoring_event_updated_at BEFORE UPDATE ON monitoring_event FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER tr_monitoring_activity_updated_at BEFORE UPDATE ON monitoring_activity FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER tr_monitoring_task_updated_at BEFORE UPDATE ON monitoring_task FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER tr_monitoring_picture_updated_at BEFORE UPDATE ON monitoring_picture FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER tr_monitoring_soc_sample_updated_at BEFORE UPDATE ON monitoring_soc_sample FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER tr_monitoring_soc_site_sample_updated_at BEFORE UPDATE ON monitoring_soc_site_sample FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER tr_monitoring_soc_sampling_area_sample_updated_at BEFORE UPDATE ON monitoring_soc_sampling_area_sample FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER tr_monitoring_report_updated_at BEFORE UPDATE ON monitoring_report FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER tr_form_definition_updated_at BEFORE UPDATE ON form_definition FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER tr_data_collection_statement_updated_at BEFORE UPDATE ON data_collection_statement FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER tr_finding_updated_at BEFORE UPDATE ON finding FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER tr_ise_reading_updated_at BEFORE UPDATE ON ise_reading FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER tr_ecosystem_processes_updated_at BEFORE UPDATE ON ecosystem_processes FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER tr_indicator_reading_updated_at BEFORE UPDATE ON indicator_reading FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER tr_recommendation_updated_at BEFORE UPDATE ON recommendation FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER tr_user_profile_updated_at BEFORE UPDATE ON user_profile FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER tr_program_monitoring_period_updated_at BEFORE UPDATE ON program_monitoring_period FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER tr_rel_instance_monitoring_period_updated_at BEFORE UPDATE ON rel_instance_monitoring_period FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Biodiversity triggers
CREATE TRIGGER tr_species_updated_at BEFORE UPDATE ON biodiversity.species FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER tr_ecoregions_updated_at BEFORE UPDATE ON biodiversity.ecoregions FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

COMMENT ON FUNCTION update_updated_at_column() IS 'Auto-updates the updated_at column on row changes';
