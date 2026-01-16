-- Domain: Biodiversity
-- Reference Tables for biodiversity

-- Ref Ecoregions
CREATE TABLE biodiversity.ref_ecoregions (
    id SERIAL PRIMARY KEY,
    es_ar VARCHAR(100) NOT NULL,
    es_py VARCHAR(100),
    en_us VARCHAR(100),
    pt_br VARCHAR(100),
    geometry GEOMETRY(MultiPolygon, 4326),
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO biodiversity.ref_ecoregions (id, es_ar, en_us) VALUES
    (1, 'Altos Andes', 'High Andes'),
    (2, 'Antártida', 'Antarctica'),
    (3, 'Bosques Patagónicos', 'Patagonian Forests'),
    (4, 'Chaco Húmedo', 'Humid Chaco'),
    (5, 'Chaco Seco', 'Dry Chaco'),
    (6, 'Delta de las Islas del Paraná', 'Paraná River Delta'),
    (7, 'Espinal', 'Espinal'),
    (8, 'Estepa Patagónica', 'Patagonian Steppe'),
    (9, 'Esteros del Iberá', 'Iberá Wetlands'),
    (10, 'Islas del Atlántico Sur', 'South Atlantic Islands'),
    (11, 'Mar Argentino', 'Argentine Sea'),
    (12, 'Monte de llanuras y mesetas', 'Plains and Plateaus Monte'),
    (13, 'Monte de sierras y bolsones', 'Mountains and Basins Monte'),
    (14, 'Pampa', 'Pampa'),
    (15, 'Puna', 'Puna'),
    (16, 'Selva Paranaense', 'Paranaense Forest'),
    (17, 'Yungas', 'Yungas');

-- Ref Biodiversity Indicator
CREATE TABLE biodiversity.ref_biodiversity_indicator (
    id SERIAL PRIMARY KEY,
    key VARCHAR(50) NOT NULL UNIQUE,
    es_ar VARCHAR(100) NOT NULL,
    es_py VARCHAR(100),
    en_us VARCHAR(100),
    pt_br VARCHAR(100),
    min_value INTEGER,
    max_value INTEGER,
    step INTEGER NOT NULL,
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO biodiversity.ref_biodiversity_indicator (id, key, es_ar, en_us, min_value, max_value, step) VALUES
    (1, 'liveCanopyAbundance', 'Abundancia de Canopeo', 'Live Canopy Abundance', -10, 10, 5),
    (2, 'livingOrganisms', 'Organismos Vivos', 'Living Organisms', -10, 10, 5),
    (3, 'warmSeasonGrasses', 'Pastos de Verano', 'Warm Season Grasses', -10, 10, 5),
    (4, 'coolSeasonGrasses', 'Pastos de Invierno', 'Cool Season Grasses', -10, 10, 5),
    (5, 'forbsAndLegumes', 'Hierbas y Leguminosas', 'Forbs and Legumes', -10, 10, 5),
    (6, 'treesAndShrubs', 'Árboles y Arbustos', 'Trees and Shrubs', -10, 10, 5),
    (7, 'desirableRareSpecies', 'Especies Deseables', 'Desirable Rare Species', 0, 10, 5),
    (8, 'nonDesirableRareSpecies', 'Especies Indeseables', 'Non-Desirable Rare Species', -10, 0, 5),
    (9, 'litterAbundance', 'Mantillo', 'Litter Abundance', 0, 10, 5),
    (10, 'litterDecomposition', 'Incorporación del Mantillo', 'Litter Decomposition', 0, 10, 5),
    (11, 'dungDecomposition', 'Desaparición de Excrementos', 'Dung Decomposition', 0, 10, 5),
    (12, 'bareSoil', 'Suelo Desnudo', 'Bare Soil', -20, 20, 10),
    (13, 'capping', 'Encostramiento', 'Capping', -10, 0, 5),
    (14, 'windErosion', 'Erosión Eólica', 'Wind Erosion', -20, 0, 10),
    (15, 'waterErosion', 'Erosión Hídrica', 'Water Erosion', -20, 0, 10);

-- Ref Functional Group
CREATE TABLE biodiversity.ref_functional_group (
    id SERIAL PRIMARY KEY,
    es_ar VARCHAR(100) NOT NULL,
    es_py VARCHAR(100),
    en_us VARCHAR(100),
    pt_br VARCHAR(100),
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO biodiversity.ref_functional_group (id, es_ar, en_us) VALUES
    (1, 'Anuales', 'Annuals'),
    (2, 'Otras hierbas', 'Other Herbs'),
    (3, 'Juncáceas y Graminoides', 'Rushes and Grass-like'),
    (4, 'Arbustos y subarbustos', 'Shrubs and Undershrubs'),
    (5, 'Efímeras', 'Ephemerals'),
    (6, 'Leguminosas', 'Legumes'),
    (7, 'Pastos Perennes de Estación Cálida', 'Warm Season Perennial Grasses'),
    (8, 'Hierbas', 'Herbs'),
    (9, 'Pastos Perennes de Estación Fría', 'Cool Season Perennial Grasses'),
    (10, 'Suculentas', 'Succulents'),
    (11, 'Gramíneas', 'Grasses');

-- Ref Ambient Matrix
CREATE TABLE biodiversity.ref_ambient_matrix (
    id SERIAL PRIMARY KEY,
    es_ar VARCHAR(100) NOT NULL,
    es_py VARCHAR(100),
    en_us VARCHAR(100),
    pt_br VARCHAR(100),
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO biodiversity.ref_ambient_matrix (id, es_ar, en_us) VALUES
    (1, 'Espinal', 'Espinal'),
    (2, 'Caldenal', 'Caldenal'),
    (3, 'Campos y Malezales', 'Campos y Malezales'),
    (4, 'Chaco Serrano', 'Chaco Serrano'),
    (5, 'Chaco Húmedo', 'Humid Chaco'),
    (6, 'Comechingones', 'Comechingones'),
    (7, 'Comechingones Pastizales de Altura', 'Comechingones Highland Grasslands'),
    (8, 'Chaco Seco', 'Dry Chaco'),
    (9, 'Monte Oriental', 'Eastern Monte'),
    (10, 'Estepa Magallánica Húmeda', 'Humid Magellanic Steppe'),
    (11, 'Estepa Magallánica Seca', 'Dry Magellanic Steppe'),
    (12, 'Matorral Mata Negra', 'Mata Negra Shrubland'),
    (13, 'Pampa Húmeda', 'Humid Pampa'),
    (14, 'Esteros del Iberá', 'Iberá Wetlands'),
    (15, 'Bajo dulce espinal y chaco húmedo', 'Sweet Lowland Espinal and Humid Chaco'),
    (16, 'Bajo salino espinal y chaco húmedo', 'Saline Lowland Espinal and Humid Chaco'),
    (17, 'Estepa de halófitas', 'Halophyte Steppe'),
    (18, 'Complejo andino húmedo', 'Humid Andean Complex'),
    (19, 'Golfo San Jorge', 'San Jorge Gulf'),
    (20, 'Mallín húmedo', 'Humid Mallín'),
    (21, 'Meseta central chubutense', 'Central Chubut Plateau'),
    (22, 'Monte austral', 'Southern Monte'),
    (23, 'Pastizal subandino', 'Sub-Andean Grassland'),
    (24, 'Península Valdés', 'Valdés Peninsula'),
    (25, 'Sierras y mesetas', 'Mountains and Plateaus');

-- Ref Landscape Index
CREATE TABLE biodiversity.ref_landscape_index (
    id SERIAL PRIMARY KEY,
    es_ar VARCHAR(100) NOT NULL,
    es_py VARCHAR(100),
    en_us VARCHAR(100),
    pt_br VARCHAR(100),
    is_deleted BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

INSERT INTO biodiversity.ref_landscape_index (id, es_ar, en_us) VALUES
    (1, 'Ciclo del Agua', 'Water Cycle'),
    (2, 'Ciclo de Minerales', 'Mineral Cycle'),
    (3, 'Dinámicas de comunidad', 'Community Dynamics'),
    (4, 'Flujo de Energía', 'Energy Flow');
