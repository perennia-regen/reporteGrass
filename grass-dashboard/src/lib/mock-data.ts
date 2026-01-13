// Mock data basado en el informe de La Unión - Marzo 2025

import type {
  DashboardData,
  ComunidadData,
  MonitorMCP,
} from '@/types/dashboard';
import { grassTheme } from '@/styles/grass-theme';

// Datos del establecimiento La Unión
export const mockDashboardData: DashboardData = {
  establecimiento: {
    nombre: 'La Unión',
    codigo: 'LU-001',
    fecha: '25 de Marzo de 2025',
    nodo: 'Perennia',
    tecnico: 'Juan Agüero, Gastón Codutti',
    areaTotal: 560,
    ubicacion: {
      provincia: 'Santa Fe',
      departamento: 'Iriondo',
      distrito: 'Bustinza',
    },
    coordenadas: [-32.45, -61.15],
  },

  estratos: [
    {
      id: 'loma',
      nombre: 'Loma',
      codigo: 'AG',
      superficie: 207,
      porcentaje: 37,
      estaciones: 7,
      areaPorEstacion: 30,
      color: grassTheme.colors.estratos.loma,
    },
    {
      id: 'media-loma',
      nombre: 'Media Loma',
      codigo: 'ML',
      superficie: 206,
      porcentaje: 37,
      estaciones: 7,
      areaPorEstacion: 29,
      color: grassTheme.colors.estratos.mediaLoma,
    },
    {
      id: 'bajo',
      nombre: 'Bajo',
      codigo: 'BD',
      superficie: 147,
      porcentaje: 26,
      estaciones: 6,
      areaPorEstacion: 24,
      color: grassTheme.colors.estratos.bajo,
    },
  ],

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

// Generar monitores con datos realistas
function generateMonitores(): MonitorMCP[] {
  const monitores: MonitorMCP[] = [];
  const baseCoords: [number, number] = [-32.45, -61.15];

  // Monitores para cada estrato
  const estratosConfig = [
    { codigo: 'AG', nombre: 'Loma', count: 7, offsetLat: 0.01 },
    { codigo: 'BD', nombre: 'Bajo', count: 6, offsetLat: -0.01 },
    { codigo: 'ML', nombre: 'Media Loma', count: 7, offsetLat: 0 },
  ];

  let id = 1;
  estratosConfig.forEach((estrato) => {
    for (let i = 0; i < estrato.count; i++) {
      const lat = baseCoords[0] + estrato.offsetLat + (Math.random() - 0.5) * 0.02;
      const lng = baseCoords[1] + (Math.random() - 0.5) * 0.03;

      // Valores base según estrato (basados en datos del PDF)
      const isLoma = estrato.codigo === 'AG';
      const isBajo = estrato.codigo === 'BD';

      monitores.push({
        id,
        estrato: estrato.nombre,
        estratoCodigo: estrato.codigo,
        coordenadas: [lat, lng],
        indicadores: {
          abundanciaCanopeo: isLoma ? -5 : isBajo ? 5 : 0,
          microfauna: isLoma ? -5 : isBajo ? 5 : 5,
          gf1PastosVerano: isLoma ? -10 : isBajo ? 5 : 0,
          gf2PastosInvierno: isLoma ? -10 : isBajo ? 0 : 5,
          gf3HierbasLeguminosas: isLoma ? 0 : isBajo ? 5 : 0,
          gf4ArbolesArbustos: 0,
          especiesDeseables: 0,
          especiesIndeseables: 0,
          abundanciaMantillo: 10,
          incorporacionMantillo: 10,
          descomposicionBostas: isLoma ? 0 : 10,
          sueloDesnudo: 20,
          encostramiento: 0,
          erosionEolica: 0,
          erosionHidrica: 0,
          estructuraSuelo: isLoma ? 0 : isBajo ? 10 : 0,
        },
        ise1: isLoma ? 15 : isBajo ? 55 : 40,
        ise2: isLoma ? 15 : isBajo ? 55 : 45,
      });
      id++;
    }
  });

  return monitores;
}

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
