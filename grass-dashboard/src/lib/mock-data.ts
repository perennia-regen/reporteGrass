// Mock data basado en el informe de La Unión - Marzo 2025
// Geometrías reales importadas del GeoJSON de regen-project-dev

import type {
  DashboardData,
  ComunidadData,
  MonitorMCP,
  EstratoGeometry,
  LaUnionGeoJSON,
  Perimetro,
  AreaExclusion,
  ForrajeData,
  SiteFotos,
  ForrajeEstrato,
  PastoreoData,
  IntensidadPastoreoEstrato,
  ForrajeHistoricoItem,
} from '@/types/dashboard';
import { grassTheme } from '@/styles/grass-theme';
import laUnionGeoJSONRaw from '@/data/la-union.json';
import monitoringEventData from '@/data/monitoring-event-2025.json';

// Cast del JSON importado
const laUnionGeoJSON = laUnionGeoJSONRaw as LaUnionGeoJSON;

// Type for monitoring event data
interface MonitoringEventSite {
  sitio: string;
  lat: number;
  lng: number;
  estrato: string;
  scoreTotal: number;
  indicadores: {
    abundanciaCanopeo: number | null;
    organismosVivos: number | null;
    pastosVerano: number | null;
    pastosInvierno: number | null;
    hierbasLeguminosas: number | null;
    arbolesArbustos: number | null;
    especiesDeseables: number | null;
    especiesIndeseables: number | null;
    mantillo: number | null;
    incorporacionMantillo: number | null;
    desaparicionExcrementos: number | null;
    sueloDesnudo: number | null;
    encostramiento: number | null;
    erosionEolica: number | null;
    erosionHidrica: number | null;
  };
  forraje: {
    biomasaKgMSHa: number | null;
    biomasaM2DiaAnimal: number | null;
    calidadForraje: number | null;
    patronUso: string | null;
    intensidad: string | null;
  };
  fechaMonitoreo: string;
}

interface MonitoringEventFotos {
  panoramic?: string;
  degrees45?: string;
  degrees90?: string;
}

interface MonitoringEventJSON {
  eventoNombre: string;
  fecha: string;
  sitios: MonitoringEventSite[];
  fotos: Record<string, MonitoringEventFotos>;
}

// Cast monitoring event data
const eventData = monitoringEventData as MonitoringEventJSON;

// Create a lookup map for monitoring event sites by name
const eventSiteMap = new Map<string, MonitoringEventSite>();
eventData.sitios.forEach((site) => {
  // Normalize site name (remove spaces, handle "LAU 14" vs "LAU14")
  const normalizedName = site.sitio.replace(/\s+/g, '');
  eventSiteMap.set(normalizedName, site);
  // Also store with original name for exact matches
  eventSiteMap.set(site.sitio, site);
});

// ============================================
// Parseo del GeoJSON real de La Unión
// Coordenadas centro: ~[-32.68, -61.36] (lat, lng)
// ============================================

// Extraer features por tipo
const perimeterFeature = laUnionGeoJSON.features.find(
  (f) => f.properties.type === 'perimeter'
);
const strataFeatures = laUnionGeoJSON.features.filter(
  (f) => f.properties.type === 'strata'
);
const exclusionFeatures = laUnionGeoJSON.features.filter(
  (f) => f.properties.type === 'exclusion_area'
);
const siteFeatures = laUnionGeoJSON.features.filter(
  (f) => f.properties.type === 'monitoring_site'
);

// Perímetro del establecimiento
const perimetroData: Perimetro | undefined = perimeterFeature
  ? {
      nombre: perimeterFeature.properties.name || 'La Unión',
      area: perimeterFeature.properties.area || 591,
      geometry: perimeterFeature.geometry as EstratoGeometry,
      color: perimeterFeature.properties.color || 'hsl(61, 90%, 71%)',
    }
  : undefined;

// Áreas de exclusión
const areasExclusionData: AreaExclusion[] = exclusionFeatures.map((f, idx) => ({
  id: `exclusion-${idx + 1}`,
  area: f.properties.area || 0,
  geometry: f.geometry as EstratoGeometry,
  color: f.properties.color || 'hsl(0, 0%, 20%)',
  descripcion: f.properties.exclusionAreaTypeDescription,
  hasGrazingManagement: f.properties.hasGrazingManagement,
}));

// Mapeo de nombres de estratos del GeoJSON a IDs del sistema
const estratoNameMap: Record<string, { id: string; codigo: string }> = {
  LOMA: { id: 'loma', codigo: 'AG' },
  'MEDIA LOMA': { id: 'media-loma', codigo: 'ML' },
  BAJO: { id: 'bajo', codigo: 'BD' },
};

// Extraer geometrías y áreas de estratos del GeoJSON real (un solo loop)
const estratoGeometries: Record<string, EstratoGeometry> = {};
const estratoAreas: Record<string, number> = {};
strataFeatures.forEach((f) => {
  const name = f.properties.name || '';
  const mapping = estratoNameMap[name];
  if (mapping) {
    estratoGeometries[mapping.id] = f.geometry as EstratoGeometry;
    estratoAreas[mapping.id] = Math.round(f.properties.area || 0);
  }
});

// Calcular centro del establecimiento desde el perímetro
function calculateCenter(): [number, number] {
  if (!perimeterFeature) return [-32.68, -61.36];
  const coords = perimeterFeature.geometry.coordinates as number[][][];
  const points = coords[0];
  const sumLat = points.reduce((sum, p) => sum + p[1], 0);
  const sumLng = points.reduce((sum, p) => sum + p[0], 0);
  return [sumLat / points.length, sumLng / points.length];
}

// Mapeo de estratos del CSV al sistema
const estratoCSVMap: Record<string, { codigo: string; nombre: string }> = {
  'LOMA': { codigo: 'AG', nombre: 'Loma' },
  'MEDIA LOMA': { codigo: 'ML', nombre: 'Media Loma' },
  'BAJO': { codigo: 'BD', nombre: 'Bajo' },
};

// Generar monitores desde el evento de monitoreo real
// Usa datos del CSV con ISE, forraje y fotos reales
function generateMonitores(): MonitorMCP[] {
  // Usar datos del evento de monitoreo (prioridad sobre GeoJSON)
  return eventData.sitios.map((site) => {
    const estratoMapping = estratoCSVMap[site.estrato] || { codigo: 'BD', nombre: 'Bajo' };

    // Buscar fotos para este sitio
    const siteKey = site.sitio;
    const normalizedKey = site.sitio.replace(/\s+/g, '');
    const fotos = eventData.fotos[siteKey] || eventData.fotos[normalizedKey];

    // Mapear datos de forraje
    const forraje: ForrajeData = {
      biomasaKgMSHa: site.forraje.biomasaKgMSHa,
      biomasaM2DiaAnimal: site.forraje.biomasaM2DiaAnimal,
      calidadForraje: site.forraje.calidadForraje,
      patronUso: site.forraje.patronUso as 'PP' | 'SD' | 'SP' | null,
      intensidad: site.forraje.intensidad as 'none' | 'moderate' | 'intense' | null,
    };

    // Mapear fotos
    const siteFotos: SiteFotos | undefined = fotos ? {
      panoramic: fotos.panoramic,
      degrees45: fotos.degrees45,
      degrees90: fotos.degrees90,
    } : undefined;

    return {
      id: site.sitio, // Usar el nombre del sitio como ID (LAU01, LAU02, etc.)
      nombre: site.sitio,
      estrato: estratoMapping.nombre,
      estratoCodigo: estratoMapping.codigo,
      coordenadas: [site.lat, site.lng] as [number, number],
      indicadores: {
        abundanciaCanopeo: site.indicadores.abundanciaCanopeo ?? 0,
        microfauna: site.indicadores.organismosVivos ?? 0,
        gf1PastosVerano: site.indicadores.pastosVerano ?? 0,
        gf2PastosInvierno: site.indicadores.pastosInvierno ?? 0,
        gf3HierbasLeguminosas: site.indicadores.hierbasLeguminosas ?? 0,
        gf4ArbolesArbustos: site.indicadores.arbolesArbustos ?? 0,
        especiesDeseables: site.indicadores.especiesDeseables ?? 0,
        especiesIndeseables: site.indicadores.especiesIndeseables ?? 0,
        abundanciaMantillo: site.indicadores.mantillo ?? 0,
        incorporacionMantillo: site.indicadores.incorporacionMantillo ?? 0,
        descomposicionBostas: site.indicadores.desaparicionExcrementos ?? 0,
        sueloDesnudo: site.indicadores.sueloDesnudo ?? 0,
        encostramiento: site.indicadores.encostramiento ?? 0,
        erosionEolica: site.indicadores.erosionEolica ?? 0,
        erosionHidrica: site.indicadores.erosionHidrica ?? 0,
        estructuraSuelo: 0, // No está en el CSV
      },
      ise1: site.scoreTotal,
      ise2: site.scoreTotal,
      forraje,
      fotos: siteFotos,
      fechaMonitoreo: site.fechaMonitoreo,
    };
  });
}

// Calcular biomasa promedio por estrato (kg MS/ha)
export function calculateBiomasaByEstrato(): Record<string, { promedio: number; total: number; sitios: number }> {
  const estratoBiomasa: Record<string, number[]> = {
    'Bajo': [],
    'Media Loma': [],
    'Loma': [],
  };

  eventData.sitios.forEach((site) => {
    const mapping = estratoCSVMap[site.estrato];
    if (mapping && site.forraje.biomasaKgMSHa !== null) {
      estratoBiomasa[mapping.nombre].push(site.forraje.biomasaKgMSHa);
    }
  });

  const result: Record<string, { promedio: number; total: number; sitios: number }> = {};
  Object.entries(estratoBiomasa).forEach(([nombre, biomasas]) => {
    if (biomasas.length > 0) {
      const total = biomasas.reduce((a, b) => a + b, 0);
      result[nombre] = {
        promedio: Math.round(total / biomasas.length),
        total: Math.round(total),
        sitios: biomasas.length,
      };
    } else {
      result[nombre] = { promedio: 0, total: 0, sitios: 0 };
    }
  });

  return result;
}

// Datos del establecimiento La Unión
export const mockDashboardData: DashboardData = {
  establecimiento: {
    nombre: 'La Unión',
    codigo: 'LU-001',
    fecha: '25 de Marzo de 2025',
    nodo: 'Perennia',
    tecnico: 'Juan Agüero, Gastón Codutti',
    areaTotal: Math.round(perimetroData?.area || 591),
    ubicacion: {
      provincia: 'Santa Fe',
      departamento: 'Iriondo',
      distrito: 'Bustinza',
    },
    coordenadas: calculateCenter(),
  },

  estratos: [
    {
      id: 'loma',
      nombre: 'Loma',
      codigo: 'AG',
      superficie: estratoAreas.loma || 206,
      porcentaje: Math.round(((estratoAreas.loma || 206) / (perimetroData?.area || 591)) * 100),
      estaciones: siteFeatures.length > 0 ? Math.round(siteFeatures.length / 3) : 7,
      areaPorEstacion: Math.round((estratoAreas.loma || 206) / 7),
      color: grassTheme.colors.estratos.loma,
      geometry: estratoGeometries.loma,
    },
    {
      id: 'media-loma',
      nombre: 'Media Loma',
      codigo: 'ML',
      superficie: estratoAreas['media-loma'] || 206,
      porcentaje: Math.round(((estratoAreas['media-loma'] || 206) / (perimetroData?.area || 591)) * 100),
      estaciones: siteFeatures.length > 0 ? Math.round(siteFeatures.length / 3) : 7,
      areaPorEstacion: Math.round((estratoAreas['media-loma'] || 206) / 7),
      color: grassTheme.colors.estratos.mediaLoma,
      geometry: estratoGeometries['media-loma'],
    },
    {
      id: 'bajo',
      nombre: 'Bajo',
      codigo: 'BD',
      superficie: estratoAreas.bajo || 146,
      porcentaje: Math.round(((estratoAreas.bajo || 146) / (perimetroData?.area || 591)) * 100),
      estaciones: siteFeatures.length > 0 ? Math.round(siteFeatures.length / 3) : 6,
      areaPorEstacion: Math.round((estratoAreas.bajo || 146) / 6),
      color: grassTheme.colors.estratos.bajo,
      geometry: estratoGeometries.bajo,
    },
  ],

  // Perímetro y áreas de exclusión del GeoJSON real
  perimetro: perimetroData,
  areasExclusion: areasExclusionData,

  ise: {
    promedio: 34.6,
    porEstrato: {
      'Bajo': 49.2,
      'Media Loma': 46.4,
      'Loma': 14.3,
    },
    historico: [
      {
        fecha: 'mar 2022',
        valor: 64.2,
        porEstrato: { 'Bajo': 71, 'Media Loma': 93, 'Loma': 30 },
      },
      {
        fecha: 'may 2023',
        valor: 25.9,
        porEstrato: { 'Bajo': 48, 'Media Loma': 55, 'Loma': -19 },
      },
      {
        fecha: 'mar 2024',
        valor: 39.8,
        porEstrato: { 'Bajo': 38, 'Media Loma': 66, 'Loma': 14 },
      },
      {
        fecha: 'mar 2025',
        valor: 34.6,
        porEstrato: { 'Bajo': 49, 'Media Loma': 46, 'Loma': 14 },
      },
    ],
  },

  procesos: {
    cicloAgua: 56,
    cicloMineral: 48,
    flujoEnergia: 46,
    dinamicaComunidades: 36,
  },

  procesosHistorico: [
    {
      fecha: 'mar 2022',
      valores: { cicloAgua: 53, cicloMineral: 50, flujoEnergia: 75, dinamicaComunidades: 56 },
    },
    {
      fecha: 'may 2023',
      valores: { cicloAgua: 48, cicloMineral: 43, flujoEnergia: 0, dinamicaComunidades: 50 },
    },
    {
      fecha: 'feb 2024',
      valores: { cicloAgua: 50, cicloMineral: 44, flujoEnergia: 36, dinamicaComunidades: 36 },
    },
    {
      fecha: 'mar 2025',
      valores: { cicloAgua: 56, cicloMineral: 48, flujoEnergia: 46, dinamicaComunidades: 36 },
    },
  ],

  monitores: generateMonitores(),

  eventos: [
    {
      id: '1',
      fecha: 'Marzo 2022',
      tipo: 'linea_base',
      descripcion: 'Instalación de línea de base con 10 monitores',
      iseResultado: 64.2,
    },
    {
      id: '2',
      fecha: 'Mayo 2023',
      tipo: 'mcp',
      descripcion: 'Primera lectura MCP - Afectada por sequía severa',
      iseResultado: 25.9,
    },
    {
      id: '3',
      fecha: 'Febrero 2024',
      tipo: 'mcp',
      descripcion: 'Segunda lectura MCP - Ampliación a 20 sitios',
      iseResultado: 39.8,
    },
    {
      id: '4',
      fecha: 'Marzo 2025',
      tipo: 'mcp',
      descripcion: 'Tercera lectura MCP - Monitoreo anual',
      iseResultado: 34.6,
    },
  ],

  recomendaciones: [
    {
      estrato: 'Loma',
      sugerencia: 'Mantener e incorporar prácticas agrícolas alineadas con el propósito de regeneración, tales como el uso de cultivos de cobertura, intersiembras y rotaciones que contribuyan a mejorar la cobertura del suelo y reducir el impacto sobre los procesos ecológicos.',
    },
    {
      estrato: 'Media Loma',
      sugerencia: 'Sostener la planificación del pastoreo, ajustando los tiempos de recuperación según la época del año y evaluando la carga animal. Promover la incorporación y mantenimiento de especies perennes, así como asegurar remanentes post-pastoreo suficientemente altos y voluminosos.',
    },
    {
      estrato: 'Bajo',
      sugerencia: 'Priorizar la acumulación de cobertura, aprovechando los buenos resultados observados para consolidar las mejoras en el funcionamiento de los procesos ecosistémicos.',
    },
  ],

  observacionGeneral: 'La evaluación muestra avances diferenciados entre los estratos. El estrato Loma continúa siendo el más limitado en su salud ecosistémica, aunque presenta mejoras puntuales en la cobertura del suelo. En Media Loma, los procesos básicos se mantienen estables, pero se observa una pérdida de diversidad vegetal y un deterioro en las pasturas. El estrato Bajo evidencia la evolución más positiva, con mejoras sostenidas en la cobertura, diversidad funcional y funcionamiento del ecosistema.',

  fotos: [
    { url: '/placeholder-foto-1.jpg', sitio: 'Loma AG-01', comentario: 'Vista general del estrato loma' },
    { url: '/placeholder-foto-2.jpg', sitio: 'Media Loma ML-03', comentario: 'Cobertura vegetal en recuperación' },
    { url: '/placeholder-foto-3.jpg', sitio: 'Bajo BD-02', comentario: 'Abundante mantillo observado' },
    { url: '/placeholder-foto-4.jpg', sitio: 'Loma AG-05', comentario: 'Pastos perennes de verano' },
  ],
};

// Datos de la comunidad GRASS
export const mockComunidadData: ComunidadData = {
  establecimientos: [
    { id: '1', nombre: 'La Unión', provincia: 'Santa Fe', coordenadas: [-32.45, -61.15], ise: 34.6, anosMonitoreando: 4, areaTotal: 560 },
    { id: '2', nombre: 'El Amanecer', provincia: 'Córdoba', coordenadas: [-31.42, -64.18], ise: 52.3, anosMonitoreando: 3, areaTotal: 1200 },
    { id: '3', nombre: 'Los Alamos', provincia: 'Buenos Aires', coordenadas: [-35.57, -58.67], ise: 68.1, anosMonitoreando: 5, areaTotal: 850 },
    { id: '4', nombre: 'Campo Verde', provincia: 'Entre Ríos', coordenadas: [-31.73, -60.52], ise: 45.8, anosMonitoreando: 2, areaTotal: 420 },
    { id: '5', nombre: 'La Esperanza', provincia: 'Santa Fe', coordenadas: [-33.12, -61.89], ise: 71.2, anosMonitoreando: 6, areaTotal: 980 },
    { id: '6', nombre: 'San Miguel', provincia: 'Córdoba', coordenadas: [-32.15, -63.45], ise: 58.4, anosMonitoreando: 4, areaTotal: 750 },
    { id: '7', nombre: 'El Progreso', provincia: 'Buenos Aires', coordenadas: [-36.23, -59.12], ise: 42.1, anosMonitoreando: 2, areaTotal: 380 },
    { id: '8', nombre: 'Las Margaritas', provincia: 'La Pampa', coordenadas: [-36.62, -64.29], ise: 55.7, anosMonitoreando: 3, areaTotal: 1500 },
  ],
  estadisticas: {
    totalHectareas: 6640,
    totalEstablecimientos: 8,
    isePromedio: 53.5,
  },
};

// Datos para la tabla de indicadores del protocolo GRASS
export const indicadoresBiologicos = [
  {
    proceso: 'Flujo de Energía',
    criterio: 'Máxima fotosíntesis por alta cobertura, área foliar y días de crecimiento.',
    indicadores: ['Abundancia del canopeo vivo'],
  },
  {
    proceso: 'Ciclo del Agua',
    criterio: 'El agua queda donde cae: mínimo escurrimiento y evaporación, máxima transpiración.',
    indicadores: ['% suelo Desnudo', 'Abundancia de mantillo', 'Encostramiento', 'Erosión eólica', 'Erosión hídrica', 'Estructura del suelo'],
  },
  {
    proceso: 'Ciclo de los minerales',
    criterio: 'Sistemas radiculares profundos y diversos, abundante mantillo que se descompone, suelo biológicamente activo.',
    indicadores: ['% suelo desnudo', 'Abundancia de mantillo', 'Descomposición de mantillo', 'Descomposición de bostas', 'Abundancia de microfauna', 'Estructura del suelo'],
  },
  {
    proceso: 'Dinámica de la comunidad',
    criterio: 'Un ecosistema que tiene todos sus grupos funcionales presentes y prosperando (con vigor y reproducción).',
    indicadores: ['Pastos perennes de verano', 'Pastos perennes de invierno', 'Hierbas y leguminosas', 'Arbustos y Árboles', 'Plantas raras contextualmente deseables', 'Plantas contextualmente indeseables'],
  },
];

// ============================================
// Datos de Forraje y Pastoreo (para gráficos Grafana)
// ============================================

// Calcular forraje por estrato desde datos del evento
export function calculateForrajeByEstrato(): ForrajeEstrato[] {
  const estratoData: Record<string, { biomasa: number[]; calidad: number[] }> = {
    'Loma': { biomasa: [], calidad: [] },
    'Media Loma': { biomasa: [], calidad: [] },
    'Bajo': { biomasa: [], calidad: [] },
  };

  eventData.sitios.forEach((site) => {
    const mapping = estratoCSVMap[site.estrato];
    if (mapping) {
      if (site.forraje.biomasaKgMSHa !== null) {
        estratoData[mapping.nombre].biomasa.push(site.forraje.biomasaKgMSHa);
      }
      if (site.forraje.calidadForraje !== null) {
        estratoData[mapping.nombre].calidad.push(site.forraje.calidadForraje);
      }
    }
  });

  const codigoMap: Record<string, string> = {
    'Loma': 'AG',
    'Media Loma': 'ML',
    'Bajo': 'BD',
  };

  return Object.entries(estratoData).map(([estrato, data]) => ({
    estrato,
    codigo: codigoMap[estrato],
    biomasa: data.biomasa.length > 0
      ? Math.round(data.biomasa.reduce((a, b) => a + b, 0) / data.biomasa.length)
      : 0,
    calidad: data.calidad.length > 0
      ? Number((data.calidad.reduce((a, b) => a + b, 0) / data.calidad.length).toFixed(1))
      : 0,
  }));
}

// Calcular patrón e intensidad de pastoreo
export function calculatePastoreoData(): PastoreoData {
  // Mapeo de intensidades del CSV a categorías
  const intensidadMap: Record<string, 'intenso' | 'moderado' | 'leve' | 'nulo'> = {
    'intense': 'intenso',
    'moderate': 'moderado',
    'light': 'leve',
    'none': 'nulo',
  };

  // Contador total para el patrón
  const totalCounts = { intenso: 0, moderado: 0, leve: 0, nulo: 0 };
  let totalSites = 0;

  // Contador por estrato
  const estratoCounts: Record<string, { intenso: number; moderado: number; leve: number; nulo: number; total: number }> = {
    'Loma': { intenso: 0, moderado: 0, leve: 0, nulo: 0, total: 0 },
    'Media Loma': { intenso: 0, moderado: 0, leve: 0, nulo: 0, total: 0 },
    'Bajo': { intenso: 0, moderado: 0, leve: 0, nulo: 0, total: 0 },
  };

  eventData.sitios.forEach((site) => {
    const mapping = estratoCSVMap[site.estrato];
    if (mapping && site.forraje.intensidad) {
      const categoria = intensidadMap[site.forraje.intensidad];
      if (categoria) {
        totalCounts[categoria]++;
        totalSites++;
        estratoCounts[mapping.nombre][categoria]++;
        estratoCounts[mapping.nombre].total++;
      }
    }
  });

  // Calcular porcentajes del patrón total
  const patronTotal = {
    intenso: totalSites > 0 ? Math.round((totalCounts.intenso / totalSites) * 100) : 0,
    moderado: totalSites > 0 ? Math.round((totalCounts.moderado / totalSites) * 100) : 0,
    leve: totalSites > 0 ? Math.round((totalCounts.leve / totalSites) * 100) : 0,
    nulo: totalSites > 0 ? Math.round((totalCounts.nulo / totalSites) * 100) : 0,
  };

  // Calcular intensidad por estrato
  const codigoMap: Record<string, string> = {
    'Loma': 'AG',
    'Media Loma': 'ML',
    'Bajo': 'BD',
  };

  const intensidadPorEstrato: IntensidadPastoreoEstrato[] = Object.entries(estratoCounts).map(([estrato, counts]) => ({
    estrato,
    codigo: codigoMap[estrato],
    intenso: counts.total > 0 ? Math.round((counts.intenso / counts.total) * 100) : 0,
    moderado: counts.total > 0 ? Math.round((counts.moderado / counts.total) * 100) : 0,
    leve: counts.total > 0 ? Math.round((counts.leve / counts.total) * 100) : 0,
    nulo: counts.total > 0 ? Math.round((counts.nulo / counts.total) * 100) : 0,
  }));

  return { patronTotal, intensidadPorEstrato };
}

// Datos históricos de forraje (mock data basado en evolución simulada)
export const forrajeHistorico: ForrajeHistoricoItem[] = [
  {
    año: 2022,
    estratos: [
      { estrato: 'Loma', codigo: 'AG', biomasa: 1800, calidad: 2.5 },
      { estrato: 'Media Loma', codigo: 'ML', biomasa: 2200, calidad: 3.0 },
      { estrato: 'Bajo', codigo: 'BD', biomasa: 2800, calidad: 3.2 },
    ],
  },
  {
    año: 2023,
    estratos: [
      { estrato: 'Loma', codigo: 'AG', biomasa: 1200, calidad: 2.0 }, // Sequía
      { estrato: 'Media Loma', codigo: 'ML', biomasa: 1800, calidad: 2.5 },
      { estrato: 'Bajo', codigo: 'BD', biomasa: 2400, calidad: 2.8 },
    ],
  },
  {
    año: 2024,
    estratos: [
      { estrato: 'Loma', codigo: 'AG', biomasa: 2100, calidad: 2.8 },
      { estrato: 'Media Loma', codigo: 'ML', biomasa: 2600, calidad: 3.2 },
      { estrato: 'Bajo', codigo: 'BD', biomasa: 3200, calidad: 3.5 },
    ],
  },
  {
    año: 2025,
    estratos: calculateForrajeByEstrato(), // Datos reales del evento actual
  },
];

// Export datos calculados para uso directo
export const forrajeData = calculateForrajeByEstrato();
export const pastoreoData = calculatePastoreoData();

// ============================================
// Fotos de sitios con datos de ISE (para galería de fotos en Inicio)
// ============================================

export interface SitePhotoWithISE {
  siteId: string;
  siteName: string;
  estrato: string;
  ise: number;
  url: string;
  photoType: 'panoramic' | '45°' | '90°';
}

/**
 * Get site photos with ISE data for the photo gallery
 * Returns photos from sites with the highest variability in ISE scores
 */
export function getSitePhotosForGallery(count = 4): SitePhotoWithISE[] {
  const photos: SitePhotoWithISE[] = [];

  // Get all sites with photos and sort by ISE to show variety
  const sitesWithPhotos: Array<{
    sitio: string;
    estrato: string;
    ise: number;
    fotos: typeof eventData.fotos[string];
  }> = [];

  eventData.sitios.forEach((site) => {
    const normalizedName = site.sitio.replace(/\s+/g, '');
    const sitePhotos = eventData.fotos[site.sitio] || eventData.fotos[normalizedName];
    if (sitePhotos?.panoramic) {
      sitesWithPhotos.push({
        sitio: site.sitio,
        estrato: site.estrato,
        ise: site.scoreTotal,
        fotos: sitePhotos,
      });
    }
  });

  // Sort by ISE to get variety (mix of high and low ISE sites)
  sitesWithPhotos.sort((a, b) => b.ise - a.ise);

  const estratoNameMap: Record<string, string> = {
    LOMA: 'Loma',
    'MEDIA LOMA': 'Media Loma',
    BAJO: 'Bajo',
  };

  // If requesting more than 4, return all photos sorted by ISE
  if (count > 4) {
    for (let i = 0; i < Math.min(count, sitesWithPhotos.length); i++) {
      const site = sitesWithPhotos[i];
      photos.push({
        siteId: site.sitio.replace(/\s+/g, ''),
        siteName: site.sitio,
        estrato: estratoNameMap[site.estrato] || site.estrato,
        ise: site.ise,
        url: site.fotos.panoramic!,
        photoType: 'panoramic',
      });
    }
  } else {
    // Select sites with variety: best, worst, and some in between
    const selectedIndices = [
      0, // Best ISE
      Math.floor(sitesWithPhotos.length / 3),
      Math.floor(sitesWithPhotos.length * 2 / 3),
      sitesWithPhotos.length - 1, // Worst ISE
    ];

    for (let i = 0; i < count && i < selectedIndices.length; i++) {
      const idx = selectedIndices[i];
      if (idx < sitesWithPhotos.length) {
        const site = sitesWithPhotos[idx];
        photos.push({
          siteId: site.sitio.replace(/\s+/g, ''),
          siteName: site.sitio,
          estrato: estratoNameMap[site.estrato] || site.estrato,
          ise: site.ise,
          url: site.fotos.panoramic!,
          photoType: 'panoramic',
        });
      }
    }
  }

  return photos;
}

// Pre-calculated site photos for gallery
export const sitePhotosGallery = getSitePhotosForGallery(4);

// All site photos for the full gallery modal
export const allSitePhotos = getSitePhotosForGallery(999);
