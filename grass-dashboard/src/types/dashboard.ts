// Tipos para el Dashboard GRASS

// ============================================
// Tipos GeoJSON (compatibles con ruuts-api/PostGIS)
// ============================================

export interface EstratoGeometry {
  type: 'Polygon' | 'MultiPolygon';
  coordinates: number[][][] | number[][][][];
}

export interface EstratoGeoJSON {
  type: 'Feature';
  properties: {
    id: string;
    nombre: string;
    codigo: string;
    color: string;
    superficie: number;
  };
  geometry: EstratoGeometry;
}

// Perímetro del establecimiento
export interface Perimetro {
  nombre: string;
  area: number;
  geometry: EstratoGeometry;
  color: string;
}

// Áreas de exclusión (zonas sin pastoreo)
export interface AreaExclusion {
  id: string;
  area: number;
  geometry: EstratoGeometry;
  color: string;
  descripcion?: string;
  hasGrazingManagement?: boolean;
}

// GeoJSON Feature Collection type
export interface LaUnionGeoJSON {
  type: 'FeatureCollection';
  features: Array<{
    type: 'Feature';
    properties: {
      type: 'perimeter' | 'strata' | 'exclusion_area' | 'monitoring_site';
      name?: string;
      area?: number;
      color?: string;
      lat?: number;
      lon?: number;
      exclusionAreaTypeDescription?: string;
      hasGrazingManagement?: boolean;
    };
    geometry: {
      type: 'Polygon' | 'MultiPolygon' | 'Point';
      coordinates: unknown;
    };
  }>;
}

// ============================================
// Tipos del Dashboard
// ============================================

export interface Establecimiento {
  nombre: string;
  codigo: string;
  fecha: string;
  nodo: string;
  tecnico: string;
  areaTotal: number;
  ubicacion: {
    provincia: string;
    departamento: string;
    distrito: string;
  };
  coordenadas: [number, number]; // [lat, lng]
}

export interface Estrato {
  id: string;
  nombre: string;
  codigo: string; // AG, ML, BD
  superficie: number;
  porcentaje: number;
  estaciones: number;
  areaPorEstacion: number;
  color: string;
  coordenadas?: Array<[number, number]>; // Legacy: Polígono simple
  geometry?: EstratoGeometry; // GeoJSON geometry (compatible con SamplingArea de ruuts-api)
}

// Datos de forraje del evento de monitoreo
export interface ForrajeData {
  biomasaKgMSHa: number | null; // kg de materia seca por hectárea
  biomasaM2DiaAnimal: number | null; // m2 para un día animal
  calidadForraje: number | null; // 1-5 scale
  patronUso: 'PP' | 'SD' | 'SP' | null; // Pastoreo Parejo, Sin Datos, Sin Pastoreo
  intensidad: 'none' | 'moderate' | 'intense' | null;
}

// Fotos del sitio de monitoreo
export interface SiteFotos {
  panoramic?: string;
  degrees45?: string;
  degrees90?: string;
}

export interface MonitorMCP {
  id: number | string;
  nombre?: string; // Nombre del sitio (LAU001, LAU002, etc.)
  estrato: string;
  estratoCodigo: string;
  coordenadas: [number, number];
  indicadores: {
    abundanciaCanopeo: number;
    microfauna: number;
    gf1PastosVerano: number;
    gf2PastosInvierno: number;
    gf3HierbasLeguminosas: number;
    gf4ArbolesArbustos: number;
    especiesDeseables: number;
    especiesIndeseables: number;
    abundanciaMantillo: number;
    incorporacionMantillo: number;
    descomposicionBostas: number;
    sueloDesnudo: number;
    encostramiento: number;
    erosionEolica: number;
    erosionHidrica: number;
    estructuraSuelo: number;
  };
  ise1: number;
  ise2: number;
  // Datos de forraje (del evento de monitoreo)
  forraje?: ForrajeData;
  // Fotos del sitio
  fotos?: SiteFotos;
  // Fecha del monitoreo
  fechaMonitoreo?: string;
}

export interface ISEData {
  promedio: number;
  porEstrato: Record<string, number>;
  historico: Array<{
    fecha: string;
    valor: number;
    porEstrato?: Record<string, number>;
  }>;
}

export interface ProcesosEcosistemicos {
  cicloAgua: number;
  cicloMineral: number;
  flujoEnergia: number;
  dinamicaComunidades: number;
}

export interface EventoMonitoreo {
  id: string;
  fecha: string;
  tipo: 'linea_base' | 'mcp' | 'mlp';
  descripcion: string;
  iseResultado?: number;
}

export interface Recomendacion {
  estrato: string;
  sugerencia: string;
}

export interface FotoMonitoreo {
  url: string;
  sitio: string;
  comentario: string;
}

// Tipos para el editor de dashboard
export type WidgetType =
  // Tipos genéricos (legacy)
  | 'bar-chart'
  | 'line-chart'
  | 'pie-chart'
  | 'data-table'
  | 'kpi-card'
  | 'text-block'
  | 'map-widget'
  | 'photo-carousel'
  | 'timeline'
  // ISE
  | 'ise-estrato-anual'
  | 'ise-interanual-establecimiento'
  | 'ise-interanual-estrato'
  // Procesos del ecosistema
  | 'procesos-anual'
  | 'procesos-interanual'
  // Determinantes
  | 'determinantes-interanual'
  // Estratos
  | 'estratos-distribucion'
  | 'estratos-comparativa';

export interface WidgetConfig {
  id: string;
  type: WidgetType;
  title?: string;
  gridPosition: {
    x: number;
    y: number;
    w: number;
    h: number;
  };
  config: Record<string, unknown>;
  editable: boolean;
}

export interface TabConfig {
  id: string;
  name: string;
  icon?: string;
  widgets: WidgetConfig[];
  locked?: boolean; // Para tabs que no se pueden eliminar
}

export interface DashboardConfig {
  id: string;
  nombre: string;
  establecimientoId: string;
  tabs: TabConfig[];
  createdAt: string;
  updatedAt: string;
}

// Datos completos del dashboard
export interface DashboardData {
  establecimiento: Establecimiento;
  estratos: Estrato[];
  monitores: MonitorMCP[];
  perimetro?: Perimetro;
  areasExclusion?: AreaExclusion[];
  ise: ISEData;
  procesos: ProcesosEcosistemicos;
  procesosHistorico: Array<{
    fecha: string;
    valores: ProcesosEcosistemicos;
  }>;
  eventos: EventoMonitoreo[];
  recomendaciones: Recomendacion[];
  observacionGeneral: string;
  fotos: FotoMonitoreo[];
}

// Para la comunidad
export interface EstablecimientoComunidad {
  id: string;
  nombre: string;
  provincia: string;
  coordenadas: [number, number];
  ise: number;
  anosMonitoreando: number;
  areaTotal: number;
}

export interface ComunidadData {
  establecimientos: EstablecimientoComunidad[];
  estadisticas: {
    totalHectareas: number;
    totalEstablecimientos: number;
    isePromedio: number;
  };
}

// Tipos para la sección de Sugerencias y Recomendaciones
export type SugerenciaWidgetType =
  | WidgetType
  | 'text-block-sugerencia'
  | 'tabla-estrato'
  | 'tabla-personalizable';

export interface TableRow {
  id: string;
  estrato?: {
    nombre: string;
    color: string;
  };
  values: Record<string, string>;
}

export type SugerenciaLayout = 1 | 2 | 3; // 1=full, 2=half, 3=third

export interface SugerenciaItem {
  id: string;
  type: SugerenciaWidgetType;
  content?: string;
  tableConfig?: {
    columns: string[];
    rows: TableRow[];
  };
  chartType?: WidgetType;
  colSpan?: SugerenciaLayout; // Cuántas columnas ocupa (1=full, 2=mitad, 3=tercio)
  order?: number; // Para reordenar
}

// ============================================
// Tipos para Forraje y Pastoreo (Grafana)
// ============================================

// Datos de forraje agregados por estrato
export interface ForrajeEstrato {
  estrato: string;
  codigo: string; // AG, ML, BD
  biomasa: number; // kgMS/ha
  calidad: number; // 1-5 scale
}

// Patrón de pastoreo total del establecimiento (para PieChart)
export interface PastoreoPatron {
  intenso: number;   // % de sitios con pastoreo intenso
  moderado: number;  // % de sitios con pastoreo moderado
  leve: number;      // % de sitios con pastoreo leve
  nulo: number;      // % de sitios sin pastoreo
}

// Intensidad de pastoreo por estrato (para barras apiladas)
export interface IntensidadPastoreoEstrato {
  estrato: string;
  codigo: string;
  intenso: number;   // %
  moderado: number;  // %
  leve: number;      // %
  nulo: number;      // %
}

// Datos de pastoreo completos
export interface PastoreoData {
  patronTotal: PastoreoPatron;
  intensidadPorEstrato: IntensidadPastoreoEstrato[];
}

// Datos históricos de forraje por estrato (para gráfico interanual)
export interface ForrajeHistoricoItem {
  año: number;
  estratos: {
    estrato: string;
    codigo: string;
    biomasa: number;
    calidad: number;
  }[];
}
