-- Domain: Security
-- Row Level Security Policies

-- Enable RLS on main tables
ALTER TABLE farm ENABLE ROW LEVEL SECURITY;
ALTER TABLE paddock ENABLE ROW LEVEL SECURITY;
ALTER TABLE sampling_area ENABLE ROW LEVEL SECURITY;
ALTER TABLE exclusion_area ENABLE ROW LEVEL SECURITY;
ALTER TABLE carbon_instance ENABLE ROW LEVEL SECURITY;
ALTER TABLE monitoring_site ENABLE ROW LEVEL SECURITY;
ALTER TABLE monitoring_event ENABLE ROW LEVEL SECURITY;
ALTER TABLE monitoring_activity ENABLE ROW LEVEL SECURITY;
ALTER TABLE monitoring_task ENABLE ROW LEVEL SECURITY;
ALTER TABLE monitoring_picture ENABLE ROW LEVEL SECURITY;
ALTER TABLE monitoring_soc_sample ENABLE ROW LEVEL SECURITY;
ALTER TABLE monitoring_report ENABLE ROW LEVEL SECURITY;
ALTER TABLE ise_reading ENABLE ROW LEVEL SECURITY;
ALTER TABLE ecosystem_processes ENABLE ROW LEVEL SECURITY;
ALTER TABLE indicator_reading ENABLE ROW LEVEL SECURITY;
ALTER TABLE recommendation ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_profile ENABLE ROW LEVEL SECURITY;
ALTER TABLE farm_access ENABLE ROW LEVEL SECURITY;

-- Helper function to check farm access
CREATE OR REPLACE FUNCTION has_farm_access(farm_uuid UUID)
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM farm_access
        WHERE user_id = auth.uid()
        AND farm_id = farm_uuid
        AND is_active = TRUE
        AND (expires_at IS NULL OR expires_at > NOW())
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Helper function to check if user is admin
CREATE OR REPLACE FUNCTION is_admin()
RETURNS BOOLEAN AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1 FROM user_profile
        WHERE id = auth.uid()
        AND role IN ('admin', 'hub_admin')
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Farm policies
CREATE POLICY farm_select ON farm FOR SELECT
    USING (has_farm_access(id) OR is_admin());

CREATE POLICY farm_insert ON farm FOR INSERT
    WITH CHECK (is_admin());

CREATE POLICY farm_update ON farm FOR UPDATE
    USING (has_farm_access(id) OR is_admin());

CREATE POLICY farm_delete ON farm FOR DELETE
    USING (is_admin());

-- Paddock policies (based on farm access)
CREATE POLICY paddock_select ON paddock FOR SELECT
    USING (has_farm_access(farm_id) OR is_admin());

CREATE POLICY paddock_all ON paddock FOR ALL
    USING (has_farm_access(farm_id) OR is_admin());

-- Sampling Area policies
CREATE POLICY sampling_area_select ON sampling_area FOR SELECT
    USING (has_farm_access(farm_id) OR is_admin());

CREATE POLICY sampling_area_all ON sampling_area FOR ALL
    USING (has_farm_access(farm_id) OR is_admin());

-- Exclusion Area policies
CREATE POLICY exclusion_area_select ON exclusion_area FOR SELECT
    USING (has_farm_access(farm_id) OR is_admin());

CREATE POLICY exclusion_area_all ON exclusion_area FOR ALL
    USING (has_farm_access(farm_id) OR is_admin());

-- Carbon Instance policies
CREATE POLICY carbon_instance_select ON carbon_instance FOR SELECT
    USING (has_farm_access(farm_id) OR is_admin());

CREATE POLICY carbon_instance_all ON carbon_instance FOR ALL
    USING (has_farm_access(farm_id) OR is_admin());

-- Monitoring Site policies
CREATE POLICY monitoring_site_select ON monitoring_site FOR SELECT
    USING (has_farm_access(farm_id) OR is_admin());

CREATE POLICY monitoring_site_all ON monitoring_site FOR ALL
    USING (has_farm_access(farm_id) OR is_admin());

-- Monitoring Event policies
CREATE POLICY monitoring_event_select ON monitoring_event FOR SELECT
    USING (has_farm_access(farm_id) OR is_admin());

CREATE POLICY monitoring_event_all ON monitoring_event FOR ALL
    USING (has_farm_access(farm_id) OR is_admin());

-- Monitoring Activity policies (via event)
CREATE POLICY monitoring_activity_select ON monitoring_activity FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM monitoring_event me
            WHERE me.id = monitoring_event_id
            AND (has_farm_access(me.farm_id) OR is_admin())
        )
    );

CREATE POLICY monitoring_activity_all ON monitoring_activity FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM monitoring_event me
            WHERE me.id = monitoring_event_id
            AND (has_farm_access(me.farm_id) OR is_admin())
        )
    );

-- Monitoring Task policies (via event)
CREATE POLICY monitoring_task_select ON monitoring_task FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM monitoring_event me
            WHERE me.id = monitoring_event_id
            AND (has_farm_access(me.farm_id) OR is_admin())
        )
    );

CREATE POLICY monitoring_task_all ON monitoring_task FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM monitoring_event me
            WHERE me.id = monitoring_event_id
            AND (has_farm_access(me.farm_id) OR is_admin())
        )
    );

-- Monitoring Picture policies (via event)
CREATE POLICY monitoring_picture_select ON monitoring_picture FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM monitoring_event me
            WHERE me.id = monitoring_event_id
            AND (has_farm_access(me.farm_id) OR is_admin())
        )
    );

CREATE POLICY monitoring_picture_all ON monitoring_picture FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM monitoring_event me
            WHERE me.id = monitoring_event_id
            AND (has_farm_access(me.farm_id) OR is_admin())
        )
    );

-- SOC Sample policies
CREATE POLICY monitoring_soc_sample_select ON monitoring_soc_sample FOR SELECT
    USING (has_farm_access(farm_id) OR is_admin());

CREATE POLICY monitoring_soc_sample_all ON monitoring_soc_sample FOR ALL
    USING (has_farm_access(farm_id) OR is_admin());

-- Monitoring Report policies
CREATE POLICY monitoring_report_select ON monitoring_report FOR SELECT
    USING (has_farm_access(farm_id) OR is_admin());

CREATE POLICY monitoring_report_all ON monitoring_report FOR ALL
    USING (has_farm_access(farm_id) OR is_admin());

-- ISE Reading policies
CREATE POLICY ise_reading_select ON ise_reading FOR SELECT
    USING (has_farm_access(farm_id) OR is_admin());

CREATE POLICY ise_reading_all ON ise_reading FOR ALL
    USING (has_farm_access(farm_id) OR is_admin());

-- Ecosystem Processes policies
CREATE POLICY ecosystem_processes_select ON ecosystem_processes FOR SELECT
    USING (has_farm_access(farm_id) OR is_admin());

CREATE POLICY ecosystem_processes_all ON ecosystem_processes FOR ALL
    USING (has_farm_access(farm_id) OR is_admin());

-- Indicator Reading policies
CREATE POLICY indicator_reading_select ON indicator_reading FOR SELECT
    USING (has_farm_access(farm_id) OR is_admin());

CREATE POLICY indicator_reading_all ON indicator_reading FOR ALL
    USING (has_farm_access(farm_id) OR is_admin());

-- Recommendation policies
CREATE POLICY recommendation_select ON recommendation FOR SELECT
    USING (has_farm_access(farm_id) OR is_admin());

CREATE POLICY recommendation_all ON recommendation FOR ALL
    USING (has_farm_access(farm_id) OR is_admin());

-- User Profile policies (users can view/edit their own profile)
CREATE POLICY user_profile_select ON user_profile FOR SELECT
    USING (id = auth.uid() OR is_admin());

CREATE POLICY user_profile_update ON user_profile FOR UPDATE
    USING (id = auth.uid() OR is_admin());

-- Farm Access policies (admins manage, users view their own)
CREATE POLICY farm_access_select ON farm_access FOR SELECT
    USING (user_id = auth.uid() OR is_admin());

CREATE POLICY farm_access_all ON farm_access FOR ALL
    USING (is_admin());

COMMENT ON FUNCTION has_farm_access(UUID) IS 'Check if current user has access to a farm';
COMMENT ON FUNCTION is_admin() IS 'Check if current user has admin privileges';
