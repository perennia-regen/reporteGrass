// Tipos para el Dashboard GRASS

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
  coordenadas?: Array<[number, number]>; // Polígono para el mapa
}

export interface MonitorMCP {
  id: number;
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
