-- Domain: GRASS
-- Table: indicator_reading
-- Description: Individual indicator values per site (GRASS protocol)

CREATE TABLE indicator_reading (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    monitoring_event_id UUID REFERENCES monitoring_event(id) ON DELETE CASCADE,
    monitoring_site_id UUID NOT NULL REFERENCES monitoring_site(id),
    farm_id UUID NOT NULL REFERENCES farm(id) ON DELETE CASCADE,
    -- GRASS Protocol Indicators
    abundancia_canopeo DECIMAL(5, 2),
    microfauna DECIMAL(5, 2),
    gf1_pastos_verano DECIMAL(5, 2),
    gf2_pastos_invierno DECIMAL(5, 2),
    gf3_hierbas_leguminosas DECIMAL(5, 2),
    gf4_arboles_arbustos DECIMAL(5, 2),
    especies_deseables DECIMAL(5, 2),
    especies_indeseables DECIMAL(5, 2),
    abundancia_mantillo DECIMAL(5, 2),
    incorporacion_mantillo DECIMAL(5, 2),
    descomposicion_bostas DECIMAL(5, 2),
    suelo_desnudo DECIMAL(5, 2),
    encostramiento DECIMAL(5, 2),
    erosion_eolica DECIMAL(5, 2),
    erosion_hidrica DECIMAL(5, 2),
    estructura_suelo DECIMAL(5, 2),
    -- Reading date
    reading_date DATE NOT NULL,
    -- Audit fields
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    created_by VARCHAR(255),
    is_deleted BOOLEAN DEFAULT FALSE
);

-- Indexes
CREATE INDEX idx_indicator_reading_farm_id ON indicator_reading(farm_id);
CREATE INDEX idx_indicator_reading_site_id ON indicator_reading(monitoring_site_id);
CREATE INDEX idx_indicator_reading_event_id ON indicator_reading(monitoring_event_id);
CREATE INDEX idx_indicator_reading_date ON indicator_reading(reading_date);
CREATE INDEX idx_indicator_reading_not_deleted ON indicator_reading(id) WHERE is_deleted = FALSE;

COMMENT ON TABLE indicator_reading IS 'Individual indicator values per site (GRASS protocol)';
COMMENT ON COLUMN indicator_reading.abundancia_canopeo IS 'Live canopy abundance';
COMMENT ON COLUMN indicator_reading.gf1_pastos_verano IS 'Warm season grasses (GF1)';
COMMENT ON COLUMN indicator_reading.gf2_pastos_invierno IS 'Cool season grasses (GF2)';
COMMENT ON COLUMN indicator_reading.gf3_hierbas_leguminosas IS 'Forbs and legumes (GF3)';
COMMENT ON COLUMN indicator_reading.gf4_arboles_arbustos IS 'Trees and shrubs (GF4)';
