'use client';

import { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from '@/components/ui/table';
import {
  Tooltip as UITooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from '@/components/ui/tooltip';
import { mockDashboardData } from '@/lib/mock-data';
import { ISE_THRESHOLD, grassTheme } from '@/styles/grass-theme';
import { useDashboardStore } from '@/lib/dashboard-store';
import { EditableText } from '@/components/editor';
import {
  BarChart,
  Bar,
  XAxis,
  YAxis,
  CartesianGrid,
  Tooltip,
  Legend,
  ResponsiveContainer,
  ReferenceLine,
  LineChart,
  Line,
} from 'recharts';

// Mapeo de abreviaciones a descripciones completas para tooltips
const indicadorDescripciones: Record<string, string> = {
  'Canopeo': 'Abundancia del Canopeo Vivo',
  'Microf.': 'Abundancia de Microfauna',
  'GF1': 'GF1 - Pastos Perennes de Verano',
  'GF2': 'GF2 - Pastos Perennes de Invierno',
  'GF3': 'GF3 - Hierbas y Leguminosas',
  'GF4': 'GF4 - Árboles y Arbustos',
  'Esp.D': 'Especies Contextualmente Deseables',
  'Esp.I': 'Especies Contextualmente Indeseables',
  'Ab.M': 'Abundancia de Mantillo',
  'Inc.M': 'Incorporación de Mantillo',
  'D.Bos': 'Descomposición de Bostas',
  'S.Des': 'Suelo Desnudo',
  'Enc.': 'Encostramiento',
  'Er.E': 'Erosión Eólica',
  'Er.H': 'Erosión Hídrica',
  'Est.S': 'Estructura del Suelo',
  'ISE1': 'Índice de Salud Ecosistémica - Lectura 1',
  'ISE2': 'Índice de Salud Ecosistémica - Lectura 2',
};

// Definición de indicadores con sus claves y abreviaciones
const indicadoresConfig = [
  { key: 'abundanciaCanopeo', abbr: 'Canopeo', name: 'Abundancia del Canopeo Vivo' },
  { key: 'microfauna', abbr: 'Microf.', name: 'Abundancia de Microfauna' },
  { key: 'gf1PastosVerano', abbr: 'GF1', name: 'GF1 - Pastos Perennes de Verano' },
  { key: 'gf2PastosInvierno', abbr: 'GF2', name: 'GF2 - Pastos Perennes de Invierno' },
  { key: 'gf3HierbasLeguminosas', abbr: 'GF3', name: 'GF3 - Hierbas y Leguminosas' },
  { key: 'gf4ArbolesArbustos', abbr: 'GF4', name: 'GF4 - Árboles y Arbustos' },
  { key: 'especiesDeseables', abbr: 'Esp.D', name: 'Especies Contextualmente Deseables' },
  { key: 'especiesIndeseables', abbr: 'Esp.I', name: 'Especies Contextualmente Indeseables' },
  { key: 'abundanciaMantillo', abbr: 'Ab.M', name: 'Abundancia de Mantillo' },
  { key: 'incorporacionMantillo', abbr: 'Inc.M', name: 'Incorporación de Mantillo' },
  { key: 'descomposicionBostas', abbr: 'D.Bos', name: 'Descomposición de Bostas' },
  { key: 'sueloDesnudo', abbr: 'S.Des', name: 'Suelo Desnudo' },
  { key: 'encostramiento', abbr: 'Enc.', name: 'Encostramiento' },
  { key: 'erosionEolica', abbr: 'Er.E', name: 'Erosión Eólica' },
  { key: 'erosionHidrica', abbr: 'Er.H', name: 'Erosión Hídrica' },
  { key: 'estructuraSuelo', abbr: 'Est.S', name: 'Estructura del Suelo' },
];

// Helper para obtener color de estrato por nombre
const getEstratoColor = (nombre: string) => {
  const map: Record<string, string> = {
    'Loma': grassTheme.colors.estratos.loma,
    'Media Loma': grassTheme.colors.estratos.mediaLoma,
    'Bajo': grassTheme.colors.estratos.bajo,
  };
  return map[nombre] || '#888';
};

// Configuración de indicadores por proceso ecosistémico
const procesosDeterminantes = {
  dinamicaComunidades: {
    nombre: 'Dinámica de las Comunidades',
    color: grassTheme.colors.procesos.dinamicaComunidades,
    indicadores: [
      { key: 'gf1PastosVerano', name: 'GF1 - Pastos Verano' },
      { key: 'gf2PastosInvierno', name: 'GF2 - Pastos Invierno' },
      { key: 'gf3HierbasLeguminosas', name: 'GF3 - Hierbas/Leguminosas' },
      { key: 'gf4ArbolesArbustos', name: 'GF4 - Árboles/Arbustos' },
      { key: 'especiesDeseables', name: 'Esp. Deseables' },
      { key: 'especiesIndeseables', name: 'Esp. Indeseables' },
    ],
  },
  flujoEnergia: {
    nombre: 'Flujo de Energía',
    color: grassTheme.colors.procesos.flujoEnergia,
    indicadores: [
      { key: 'abundanciaCanopeo', name: 'Abundancia Canopeo' },
    ],
  },
  cicloMineral: {
    nombre: 'Ciclo de los Minerales',
    color: grassTheme.colors.procesos.cicloMineral,
    indicadores: [
      { key: 'sueloDesnudo', name: 'Suelo Desnudo' },
      { key: 'abundanciaMantillo', name: 'Ab. Mantillo' },
      { key: 'incorporacionMantillo', name: 'Inc. Mantillo' },
      { key: 'microfauna', name: 'Microfauna' },
      { key: 'descomposicionBostas', name: 'Desc. Bostas' },
      { key: 'estructuraSuelo', name: 'Estructura Suelo' },
    ],
  },
  cicloAgua: {
    nombre: 'Ciclo del Agua',
    color: grassTheme.colors.procesos.cicloAgua,
    indicadores: [
      { key: 'sueloDesnudo', name: 'Suelo Desnudo' },
      { key: 'abundanciaMantillo', name: 'Ab. Mantillo' },
      { key: 'encostramiento', name: 'Encostramiento' },
      { key: 'erosionEolica', name: 'Erosión Eólica' },
      { key: 'erosionHidrica', name: 'Erosión Hídrica' },
      { key: 'estructuraSuelo', name: 'Estructura Suelo' },
    ],
  },
};

// Colores para líneas en gráficos de determinantes
const lineColors = [
  '#2563eb', // blue
  '#dc2626', // red
  '#16a34a', // green
  '#ca8a04', // yellow
  '#9333ea', // purple
  '#0891b2', // cyan
];

// Componente para la sección de Determinantes con selector de estrato
interface DeterminantesSectionProps {
  monitores: typeof mockDashboardData.monitores;
  procesosHistorico: typeof mockDashboardData.procesosHistorico;
}

function DeterminantesSection({ monitores, procesosHistorico }: DeterminantesSectionProps) {
  const [estratoSeleccionado, setEstratoSeleccionado] = useState<string>('todos');

  // Calcular promedios por indicador según estrato seleccionado
  const calcularPromedios = (estratoFiltro: string) => {
    const filtrados = estratoFiltro === 'todos'
      ? monitores
      : monitores.filter(m => m.estrato === estratoFiltro);

    if (filtrados.length === 0) return {};

    const sumas: Record<string, number> = {};
    const counts: Record<string, number> = {};

    filtrados.forEach(m => {
      Object.entries(m.indicadores).forEach(([key, value]) => {
        if (!sumas[key]) {
          sumas[key] = 0;
          counts[key] = 0;
        }
        sumas[key] += value;
        counts[key]++;
      });
    });

    const promedios: Record<string, number> = {};
    Object.keys(sumas).forEach(key => {
      promedios[key] = Math.round((sumas[key] / counts[key]) * 10) / 10;
    });

    return promedios;
  };

  // Preparar datos para gráficos de líneas mostrando evolución por estrato
  const prepararDatosEvolucion = (procesoKey: keyof typeof procesosDeterminantes) => {
    const proceso = procesosDeterminantes[procesoKey];

    // Crear datos simulados de evolución usando fechas del histórico
    // En un caso real, estos datos vendrían de múltiples monitoreos
    const fechas = ['mar 2022', 'may 2023', 'feb 2024', 'mar 2025'];

    // Calcular promedios actuales por estrato
    const promedioLoma = calcularPromediosEstrato('Loma');
    const promedioMediaLoma = calcularPromediosEstrato('Media Loma');
    const promedioBajo = calcularPromediosEstrato('Bajo');

    return proceso.indicadores.map((ind) => ({
      indicador: ind.name,
      Loma: promedioLoma[ind.key] || 0,
      'Media Loma': promedioMediaLoma[ind.key] || 0,
      Bajo: promedioBajo[ind.key] || 0,
    }));
  };

  const calcularPromediosEstrato = (estrato: string) => {
    const filtrados = monitores.filter(m => m.estrato === estrato);
    if (filtrados.length === 0) return {};

    const sumas: Record<string, number> = {};
    filtrados.forEach(m => {
      Object.entries(m.indicadores).forEach(([key, value]) => {
        sumas[key] = (sumas[key] || 0) + value;
      });
    });

    const promedios: Record<string, number> = {};
    Object.keys(sumas).forEach(key => {
      promedios[key] = Math.round((sumas[key] / filtrados.length) * 10) / 10;
    });
    return promedios;
  };

  // Preparar datos para un gráfico específico
  const prepararDatosGrafico = (procesoKey: keyof typeof procesosDeterminantes) => {
    const proceso = procesosDeterminantes[procesoKey];

    if (estratoSeleccionado === 'todos') {
      // Mostrar comparación por estrato
      return proceso.indicadores.map((ind) => {
        const promedioLoma = calcularPromediosEstrato('Loma');
        const promedioMediaLoma = calcularPromediosEstrato('Media Loma');
        const promedioBajo = calcularPromediosEstrato('Bajo');

        return {
          indicador: ind.name,
          Loma: promedioLoma[ind.key] || 0,
          'Media Loma': promedioMediaLoma[ind.key] || 0,
          Bajo: promedioBajo[ind.key] || 0,
        };
      });
    } else {
      // Mostrar solo el estrato seleccionado
      const promedios = calcularPromediosEstrato(estratoSeleccionado);
      return proceso.indicadores.map((ind) => ({
        indicador: ind.name,
        valor: promedios[ind.key] || 0,
      }));
    }
  };

  const estratos = ['todos', 'Loma', 'Media Loma', 'Bajo'];

  return (
    <section>
      <div className="flex items-center justify-between mb-4 border-b pb-2">
        <h3 className="text-xl font-semibold text-[var(--grass-green-dark)]">
          Determinantes de los Procesos del Ecosistema
        </h3>
        <div className="flex items-center gap-2">
          <span className="text-sm text-gray-600">Filtrar por estrato:</span>
          <select
            value={estratoSeleccionado}
            onChange={(e) => setEstratoSeleccionado(e.target.value)}
            className="text-sm border rounded px-2 py-1 bg-white"
          >
            {estratos.map((e) => (
              <option key={e} value={e}>
                {e === 'todos' ? 'Todos los estratos' : e}
              </option>
            ))}
          </select>
        </div>
      </div>
      <p className="text-sm text-gray-600 mb-6">
        Los siguientes gráficos muestran los indicadores biológicos agrupados por cada proceso ecosistémico,
        permitiendo identificar los factores que determinan el funcionamiento del ecosistema.
      </p>

      <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
        {/* Dinámica de las Comunidades */}
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-base flex items-center gap-2">
              <div className="w-3 h-3 rounded" style={{ backgroundColor: procesosDeterminantes.dinamicaComunidades.color }} />
              {procesosDeterminantes.dinamicaComunidades.nombre}
            </CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={250}>
              <LineChart data={prepararDatosGrafico('dinamicaComunidades')}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="indicador" angle={-45} textAnchor="end" height={80} tick={{ fontSize: 10 }} />
                <YAxis domain={[-20, 20]} />
                <Tooltip />
                {estratoSeleccionado === 'todos' ? (
                  <>
                    <Legend />
                    <Line type="monotone" dataKey="Loma" stroke={getEstratoColor('Loma')} strokeWidth={2} dot={{ r: 4 }} />
                    <Line type="monotone" dataKey="Media Loma" stroke={getEstratoColor('Media Loma')} strokeWidth={2} dot={{ r: 4 }} />
                    <Line type="monotone" dataKey="Bajo" stroke={getEstratoColor('Bajo')} strokeWidth={2} dot={{ r: 4 }} />
                  </>
                ) : (
                  <Line type="monotone" dataKey="valor" stroke={getEstratoColor(estratoSeleccionado)} strokeWidth={2} dot={{ r: 4 }} name={estratoSeleccionado} />
                )}
              </LineChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        {/* Flujo de Energía */}
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-base flex items-center gap-2">
              <div className="w-3 h-3 rounded" style={{ backgroundColor: procesosDeterminantes.flujoEnergia.color }} />
              {procesosDeterminantes.flujoEnergia.nombre}
            </CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={250}>
              <BarChart data={prepararDatosGrafico('flujoEnergia')} layout="vertical">
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis type="number" domain={[-20, 20]} />
                <YAxis dataKey="indicador" type="category" width={120} tick={{ fontSize: 11 }} />
                <Tooltip />
                {estratoSeleccionado === 'todos' ? (
                  <>
                    <Legend />
                    <Bar dataKey="Loma" fill={getEstratoColor('Loma')} />
                    <Bar dataKey="Media Loma" fill={getEstratoColor('Media Loma')} />
                    <Bar dataKey="Bajo" fill={getEstratoColor('Bajo')} />
                  </>
                ) : (
                  <Bar dataKey="valor" fill={getEstratoColor(estratoSeleccionado)} name={estratoSeleccionado} />
                )}
              </BarChart>
            </ResponsiveContainer>
            <p className="text-xs text-gray-500 mt-2">
              Este proceso se evalúa mediante un único indicador que refleja la máxima fotosíntesis
              por alta cobertura, área foliar y días de crecimiento.
            </p>
          </CardContent>
        </Card>

        {/* Ciclo de los Minerales */}
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-base flex items-center gap-2">
              <div className="w-3 h-3 rounded" style={{ backgroundColor: procesosDeterminantes.cicloMineral.color }} />
              {procesosDeterminantes.cicloMineral.nombre}
            </CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={250}>
              <LineChart data={prepararDatosGrafico('cicloMineral')}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="indicador" angle={-45} textAnchor="end" height={80} tick={{ fontSize: 10 }} />
                <YAxis domain={[-20, 30]} />
                <Tooltip />
                {estratoSeleccionado === 'todos' ? (
                  <>
                    <Legend />
                    <Line type="monotone" dataKey="Loma" stroke={getEstratoColor('Loma')} strokeWidth={2} dot={{ r: 4 }} />
                    <Line type="monotone" dataKey="Media Loma" stroke={getEstratoColor('Media Loma')} strokeWidth={2} dot={{ r: 4 }} />
                    <Line type="monotone" dataKey="Bajo" stroke={getEstratoColor('Bajo')} strokeWidth={2} dot={{ r: 4 }} />
                  </>
                ) : (
                  <Line type="monotone" dataKey="valor" stroke={getEstratoColor(estratoSeleccionado)} strokeWidth={2} dot={{ r: 4 }} name={estratoSeleccionado} />
                )}
              </LineChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>

        {/* Ciclo del Agua */}
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-base flex items-center gap-2">
              <div className="w-3 h-3 rounded" style={{ backgroundColor: procesosDeterminantes.cicloAgua.color }} />
              {procesosDeterminantes.cicloAgua.nombre}
            </CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={250}>
              <LineChart data={prepararDatosGrafico('cicloAgua')}>
                <CartesianGrid strokeDasharray="3 3" />
                <XAxis dataKey="indicador" angle={-45} textAnchor="end" height={80} tick={{ fontSize: 10 }} />
                <YAxis domain={[-20, 30]} />
                <Tooltip />
                {estratoSeleccionado === 'todos' ? (
                  <>
                    <Legend />
                    <Line type="monotone" dataKey="Loma" stroke={getEstratoColor('Loma')} strokeWidth={2} dot={{ r: 4 }} />
                    <Line type="monotone" dataKey="Media Loma" stroke={getEstratoColor('Media Loma')} strokeWidth={2} dot={{ r: 4 }} />
                    <Line type="monotone" dataKey="Bajo" stroke={getEstratoColor('Bajo')} strokeWidth={2} dot={{ r: 4 }} />
                  </>
                ) : (
                  <Line type="monotone" dataKey="valor" stroke={getEstratoColor(estratoSeleccionado)} strokeWidth={2} dot={{ r: 4 }} name={estratoSeleccionado} />
                )}
              </LineChart>
            </ResponsiveContainer>
          </CardContent>
        </Card>
      </div>
    </section>
  );
}

export function TabResultados() {
  const { ise, procesos, procesosHistorico, recomendaciones, estratos, monitores } = mockDashboardData;
  const { editableContent, updateContent } = useDashboardStore();

  // Preparar datos para gráfico ISE por estrato
  const iseEstratoData = Object.entries(ise.porEstrato).map(([nombre, valor]) => ({
    nombre,
    ISE: valor,
    fill: valor >= ISE_THRESHOLD ? '#4CAF50' : '#8D6E63',
  }));

  // Preparar datos para evolución ISE
  const iseEvolucionData = ise.historico.map((h) => ({
    fecha: h.fecha,
    ISE: h.valor,
  }));

  // Preparar datos para evolución ISE por estrato
  const iseEstratoEvolucionData = ise.historico.map((h) => ({
    fecha: h.fecha,
    ...h.porEstrato,
  }));

  // Preparar datos para procesos ecosistémicos
  const procesosData = [
    { proceso: 'Ciclo del Agua', valor: procesos.cicloAgua, fill: '#E65100' },
    { proceso: 'Ciclo Mineral', valor: procesos.cicloMineral, fill: '#8D6E63' },
    { proceso: 'Flujo de Energía', valor: procesos.flujoEnergia, fill: '#2E7D32' },
    { proceso: 'Din. Comunidades', valor: procesos.dinamicaComunidades, fill: '#FFC107' },
  ];

  // Preparar datos para evolución de procesos
  const procesosEvolucionData = procesosHistorico.map((h) => ({
    fecha: h.fecha,
    'Ciclo Agua': h.valores.cicloAgua,
    'Ciclo Mineral': h.valores.cicloMineral,
    'Flujo Energía': h.valores.flujoEnergia,
    'Din. Comunidades': h.valores.dinamicaComunidades,
  }));

  return (
    <div className="space-y-8 max-w-6xl mx-auto">
      {/* Encabezado */}
      <div>
        <h2 className="text-2xl font-bold text-black">
          Resultados del Monitoreo
        </h2>
        <p className="text-gray-600 mt-1">
          Índice de Salud Ecosistémica (ISE) y Procesos del Ecosistema
        </p>
      </div>

      {/* SECCIÓN ISE */}
      <section>
        <h3 className="text-xl font-semibold text-[var(--grass-green-dark)] mb-4 border-b pb-2">
          Índice de Salud Ecosistémica (ISE)
        </h3>

        {/* ISE por Estrato */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-base">ISE por Estrato - Marzo 2025</CardTitle>
            </CardHeader>
            <CardContent>
              <ResponsiveContainer width="100%" height={250}>
                <BarChart data={iseEstratoData} layout="vertical">
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis type="number" domain={[0, 100]} />
                  <YAxis dataKey="nombre" type="category" width={80} />
                  <Tooltip />
                  <ReferenceLine x={ISE_THRESHOLD} stroke="#666" strokeDasharray="5 5" label={{ value: 'Deseable', position: 'top' }} />
                  <ReferenceLine x={ise.promedio} stroke="#E65100" strokeDasharray="3 3" label={{ value: `Prom: ${ise.promedio}`, position: 'bottom' }} />
                  <Bar dataKey="ISE" fill="#8D6E63" radius={[0, 4, 4, 0]} />
                </BarChart>
              </ResponsiveContainer>
              <EditableText
                value={editableContent.comentarioISEEstrato || `El valor promedio del ISE fue de ${ise.promedio}, por debajo del umbral deseable de ${ISE_THRESHOLD} puntos.`}
                onChange={(v) => updateContent('comentarioISEEstrato', v)}
                placeholder="Comentario sobre ISE por estrato..."
                className="text-xs text-gray-500 mt-2"
                showPencilOnHover
                multiline
              />
            </CardContent>
          </Card>

          {/* Evolución ISE Total */}
          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-base">Evolución ISE - Total Establecimiento</CardTitle>
            </CardHeader>
            <CardContent>
              <ResponsiveContainer width="100%" height={250}>
                <BarChart data={iseEvolucionData}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="fecha" />
                  <YAxis domain={[0, 100]} />
                  <Tooltip />
                  <ReferenceLine y={ISE_THRESHOLD} stroke="#666" strokeDasharray="5 5" label="Deseable" />
                  <Bar dataKey="ISE" fill="#8D6E63" radius={[4, 4, 0, 0]} />
                </BarChart>
              </ResponsiveContainer>
              <EditableText
                value={editableContent.comentarioEvolucionISE || 'Se observa una marcada disminución inicial por sequía severa (2023), con recuperación parcial posterior.'}
                onChange={(v) => updateContent('comentarioEvolucionISE', v)}
                placeholder="Comentario sobre evolución del ISE..."
                className="text-xs text-gray-500 mt-2"
                showPencilOnHover
                multiline
              />
            </CardContent>
          </Card>
        </div>

        {/* Evolución ISE por Estrato - Barras si ≤2 monitoreos, Líneas si >2 */}
        <Card>
          <CardHeader className="pb-2">
            <CardTitle className="text-base">Evolución ISE por Estrato</CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={300}>
              {ise.historico.length > 2 ? (
                <LineChart data={iseEstratoEvolucionData}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="fecha" />
                  <YAxis domain={[-30, 100]} />
                  <Tooltip />
                  <Legend />
                  <ReferenceLine y={ISE_THRESHOLD} stroke="#666" strokeDasharray="5 5" />
                  <Line type="monotone" dataKey="Bajo" stroke={getEstratoColor('Bajo')} strokeWidth={2} dot={{ r: 4 }} />
                  <Line type="monotone" dataKey="Media Loma" stroke={getEstratoColor('Media Loma')} strokeWidth={2} dot={{ r: 4 }} />
                  <Line type="monotone" dataKey="Loma" stroke={getEstratoColor('Loma')} strokeWidth={2} dot={{ r: 4 }} />
                </LineChart>
              ) : (
                <BarChart data={iseEstratoEvolucionData}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="fecha" />
                  <YAxis domain={[-30, 100]} />
                  <Tooltip />
                  <Legend />
                  <ReferenceLine y={ISE_THRESHOLD} stroke="#666" strokeDasharray="5 5" />
                  <Bar dataKey="Bajo" fill={getEstratoColor('Bajo')} />
                  <Bar dataKey="Media Loma" fill={getEstratoColor('Media Loma')} />
                  <Bar dataKey="Loma" fill={getEstratoColor('Loma')} />
                </BarChart>
              )}
            </ResponsiveContainer>
            <EditableText
              value={editableContent.comentarioEvolucionISEEstrato || 'Al analizar la evolución por estratos, se identifican situaciones diferenciadas. El estrato Bajo muestra una leve mejora, mientras que Media Loma presenta una tendencia negativa más marcada.'}
              onChange={(v) => updateContent('comentarioEvolucionISEEstrato', v)}
              placeholder="Comentario sobre evolución ISE por estrato..."
              className="text-xs text-gray-500 mt-2"
              showPencilOnHover
              multiline
            />
          </CardContent>
        </Card>
      </section>

      {/* SECCIÓN PROCESOS ECOSISTÉMICOS */}
      <section>
        <h3 className="text-xl font-semibold text-[var(--grass-green-dark)] mb-4 border-b pb-2">
          Procesos del Ecosistema
        </h3>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
          {/* Procesos Actual */}
          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-base">Procesos - Total Establecimiento (Marzo 2025)</CardTitle>
            </CardHeader>
            <CardContent>
              <ResponsiveContainer width="100%" height={250}>
                <BarChart data={procesosData} layout="vertical">
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis type="number" domain={[0, 100]} unit="%" />
                  <YAxis dataKey="proceso" type="category" width={110} />
                  <Tooltip formatter={(value) => `${value}%`} />
                  <Bar dataKey="valor" radius={[0, 4, 4, 0]}>
                    {procesosData.map((entry, index) => (
                      <Bar key={index} dataKey="valor" fill={entry.fill} />
                    ))}
                  </Bar>
                </BarChart>
              </ResponsiveContainer>
              <div className="mt-4 grid grid-cols-2 gap-2 text-sm">
                <div className="flex items-center gap-2">
                  <div className="w-3 h-3 rounded" style={{ backgroundColor: grassTheme.colors.procesos.cicloAgua }} />
                  <span>Ciclo del Agua: {procesos.cicloAgua}%</span>
                </div>
                <div className="flex items-center gap-2">
                  <div className="w-3 h-3 rounded" style={{ backgroundColor: grassTheme.colors.procesos.cicloMineral }} />
                  <span>Ciclo Mineral: {procesos.cicloMineral}%</span>
                </div>
                <div className="flex items-center gap-2">
                  <div className="w-3 h-3 rounded" style={{ backgroundColor: grassTheme.colors.procesos.flujoEnergia }} />
                  <span>Flujo de Energía: {procesos.flujoEnergia}%</span>
                </div>
                <div className="flex items-center gap-2">
                  <div className="w-3 h-3 rounded" style={{ backgroundColor: grassTheme.colors.procesos.dinamicaComunidades }} />
                  <span>Din. Comunidades: {procesos.dinamicaComunidades}%</span>
                </div>
              </div>
              <EditableText
                value={editableContent.comentarioProcesosActual || `A nivel de todo el establecimiento, se observa un funcionamiento relativamente adecuado del ciclo del agua (${procesos.cicloAgua}%), y un desempeño intermedio en el ciclo mineral (${procesos.cicloMineral}%) y el flujo de energía (${procesos.flujoEnergia}%).`}
                onChange={(v) => updateContent('comentarioProcesosActual', v)}
                placeholder="Comentario sobre procesos ecosistémicos..."
                className="text-xs text-gray-500 mt-3"
                showPencilOnHover
                multiline
              />
            </CardContent>
          </Card>

          {/* Evolución Procesos */}
          <Card>
            <CardHeader className="pb-2">
              <CardTitle className="text-base">Evolución de Procesos</CardTitle>
            </CardHeader>
            <CardContent>
              <ResponsiveContainer width="100%" height={250}>
                <LineChart data={procesosEvolucionData}>
                  <CartesianGrid strokeDasharray="3 3" />
                  <XAxis dataKey="fecha" />
                  <YAxis domain={[0, 100]} unit="%" />
                  <Tooltip />
                  <Legend />
                  <Line type="monotone" dataKey="Ciclo Agua" stroke={grassTheme.colors.procesos.cicloAgua} strokeWidth={2} dot={{ r: 4 }} />
                  <Line type="monotone" dataKey="Ciclo Mineral" stroke={grassTheme.colors.procesos.cicloMineral} strokeWidth={2} dot={{ r: 4 }} />
                  <Line type="monotone" dataKey="Flujo Energía" stroke={grassTheme.colors.procesos.flujoEnergia} strokeWidth={2} dot={{ r: 4 }} />
                  <Line type="monotone" dataKey="Din. Comunidades" stroke={grassTheme.colors.procesos.dinamicaComunidades} strokeWidth={2} dot={{ r: 4 }} />
                </LineChart>
              </ResponsiveContainer>
              <EditableText
                value={editableContent.comentarioEvolucionProcesos || 'En los tres años evaluados, se observa una relativa estabilidad en los ciclos del agua y mineral. El flujo de energía mostró una fuerte caída inicial, con recuperación parcial posterior.'}
                onChange={(v) => updateContent('comentarioEvolucionProcesos', v)}
                placeholder="Comentario sobre evolución de procesos..."
                className="text-xs text-gray-500 mt-2"
                showPencilOnHover
                multiline
              />
            </CardContent>
          </Card>
        </div>
      </section>

      {/* SECCIÓN DETERMINANTES DE LOS PROCESOS DEL ECOSISTEMA */}
      <DeterminantesSection monitores={monitores} procesosHistorico={procesosHistorico} />

      {/* SECCIÓN SÍNTESIS Y RECOMENDACIONES */}
      <section>
        <h3 className="text-xl font-semibold text-[var(--grass-green-dark)] mb-4 border-b pb-2">
          Síntesis y Recomendaciones
        </h3>

        <Card>
          <CardContent className="pt-6">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead className="w-[120px]">Estrato</TableHead>
                  <TableHead>Sugerencias de Manejo</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {recomendaciones.map((rec) => {
                  const estrato = estratos.find((e) => e.nombre === rec.estrato);
                  // Mapear nombre de estrato a clave del store
                  const estratoKey = rec.estrato === 'Media Loma' ? 'media_loma' : rec.estrato.toLowerCase();
                  const contentKey = `recomendacion_${estratoKey}`;
                  const editableValue = editableContent[contentKey] || rec.sugerencia;

                  return (
                    <TableRow key={rec.estrato}>
                      <TableCell className="font-medium align-top pt-4">
                        <div className="flex items-center gap-2">
                          <div
                            className="w-3 h-3 rounded"
                            style={{ backgroundColor: estrato?.color || '#757575' }}
                          />
                          {rec.estrato}
                        </div>
                      </TableCell>
                      <TableCell className="text-sm text-gray-700">
                        <EditableText
                          value={editableValue}
                          onChange={(value) => updateContent(contentKey, value)}
                          placeholder="Ingrese sugerencias de manejo..."
                          className="leading-relaxed"
                          multiline
                        />
                      </TableCell>
                    </TableRow>
                  );
                })}
              </TableBody>
            </Table>
          </CardContent>
        </Card>

        {/* Comentario Final */}
        <Card className="mt-6">
          <CardHeader className="pb-2">
            <CardTitle className="text-base">Comentario Final del Técnico</CardTitle>
          </CardHeader>
          <CardContent>
            <EditableText
              value={editableContent.comentarioFinal}
              onChange={(value) => updateContent('comentarioFinal', value)}
              placeholder="Ingrese un comentario final sobre los resultados..."
              className="text-gray-700 leading-relaxed"
              multiline
            />
          </CardContent>
        </Card>
      </section>

      {/* SECCIÓN ANEXO - TABLA DE RESULTADOS POR MONITOR (TRANSPUESTA) */}
      <section>
        <h3 className="text-xl font-semibold text-[var(--grass-green-dark)] mb-4 border-b pb-2">
          Anexo - Tabla con resultados por monitor
        </h3>
        <p className="text-sm text-gray-600 mb-4">
          Resultados por MCP en Marzo 2025. Los estratos se encuentran abreviados: AG (Agricultura/Loma), ML (Media Loma), BD (Bajo Dulce).
        </p>

        <Card>
          <CardContent className="pt-4 overflow-x-auto">
            <TooltipProvider>
              <Table className="text-xs">
                <TableHeader>
                  <TableRow>
                    <TableHead className="text-left whitespace-nowrap sticky left-0 bg-white z-10 min-w-[140px]">Indicador</TableHead>
                    {monitores.map((m) => (
                      <TableHead key={m.id} className="text-center whitespace-nowrap px-2">
                        <UITooltip>
                          <TooltipTrigger asChild>
                            <span className="cursor-help" style={{ color: getEstratoColor(m.estrato) }}>
                              {m.estratoCodigo}-{m.id}
                            </span>
                          </TooltipTrigger>
                          <TooltipContent>
                            <p>Monitor {m.id} - Estrato {m.estrato}</p>
                          </TooltipContent>
                        </UITooltip>
                      </TableHead>
                    ))}
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {/* Fila de Estrato */}
                  <TableRow className="bg-gray-50">
                    <TableCell className="font-medium sticky left-0 bg-gray-50 z-10">Estrato</TableCell>
                    {monitores.map((m) => (
                      <TableCell key={m.id} className="text-center font-medium" style={{ color: getEstratoColor(m.estrato) }}>
                        {m.estratoCodigo}
                      </TableCell>
                    ))}
                  </TableRow>
                  {/* Filas de indicadores */}
                  {indicadoresConfig.map((ind) => (
                    <TableRow key={ind.key}>
                      <TableCell className="sticky left-0 bg-white z-10">
                        <UITooltip>
                          <TooltipTrigger asChild>
                            <span className="cursor-help underline decoration-dotted decoration-gray-400">{ind.abbr}</span>
                          </TooltipTrigger>
                          <TooltipContent>
                            <p>{ind.name}</p>
                          </TooltipContent>
                        </UITooltip>
                      </TableCell>
                      {monitores.map((m) => (
                        <TableCell key={m.id} className="text-center">
                          {m.indicadores[ind.key as keyof typeof m.indicadores]}
                        </TableCell>
                      ))}
                    </TableRow>
                  ))}
                  {/* Filas de ISE */}
                  <TableRow className="bg-gray-50 font-bold">
                    <TableCell className="sticky left-0 bg-gray-50 z-10">
                      <UITooltip>
                        <TooltipTrigger asChild>
                          <span className="cursor-help underline decoration-dotted decoration-gray-400">ISE1</span>
                        </TooltipTrigger>
                        <TooltipContent>
                          <p>Índice de Salud Ecosistémica - Lectura 1</p>
                        </TooltipContent>
                      </UITooltip>
                    </TableCell>
                    {monitores.map((m) => (
                      <TableCell key={m.id} className="text-center">{m.ise1}</TableCell>
                    ))}
                  </TableRow>
                  <TableRow className="bg-gray-50 font-bold">
                    <TableCell className="sticky left-0 bg-gray-50 z-10">
                      <UITooltip>
                        <TooltipTrigger asChild>
                          <span className="cursor-help underline decoration-dotted decoration-gray-400">ISE2</span>
                        </TooltipTrigger>
                        <TooltipContent>
                          <p>Índice de Salud Ecosistémica - Lectura 2</p>
                        </TooltipContent>
                      </UITooltip>
                    </TableCell>
                    {monitores.map((m) => (
                      <TableCell key={m.id} className="text-center">{m.ise2}</TableCell>
                    ))}
                  </TableRow>
                </TableBody>
              </Table>
            </TooltipProvider>
          </CardContent>
        </Card>
      </section>
    </div>
  );
}
