'use client';

import { useState, useMemo, useCallback, useEffect, useRef } from 'react';
import dynamic from 'next/dynamic';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from '@/components/ui/accordion';
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
import { mockDashboardData, calculateBiomasaByEstrato, forrajeData, pastoreoData, forrajeHistorico } from '@/lib/mock-data';
import { ISE_THRESHOLD, grassTheme } from '@/styles/grass-theme';

// Dynamic imports para charts pesados - reduce bundle inicial (bundle-dynamic-imports)
const ForrajeBiomasaChart = dynamic(
  () => import('@/components/charts/forraje').then((m) => m.ForrajeBiomasaChart),
  { ssr: false, loading: () => <ChartSkeleton /> }
);
const ForrajeCalidadChart = dynamic(
  () => import('@/components/charts/forraje').then((m) => m.ForrajeCalidadChart),
  { ssr: false, loading: () => <ChartSkeleton /> }
);
const ForrajeInteranualChart = dynamic(
  () => import('@/components/charts/forraje').then((m) => m.ForrajeInteranualChart),
  { ssr: false, loading: () => <ChartSkeleton /> }
);
const PatronPastoreoChart = dynamic(
  () => import('@/components/charts/pastoreo').then((m) => m.PatronPastoreoChart),
  { ssr: false, loading: () => <ChartSkeleton /> }
);
const IntensidadPastoreoChart = dynamic(
  () => import('@/components/charts/pastoreo').then((m) => m.IntensidadPastoreoChart),
  { ssr: false, loading: () => <ChartSkeleton /> }
);

// Skeleton de carga para charts
function ChartSkeleton() {
  return (
    <div className="h-64 flex items-center justify-center bg-gray-50 rounded animate-pulse">
      <span className="text-gray-400 text-sm">Cargando gráfico...</span>
    </div>
  );
}
import { useDashboardStore, useCustomSections, useAddCustomSection, useIsEditing, useRemoveCustomSection, useResultadosSectionOrder, useSetResultadosSectionOrder, useUpdateCustomSection } from '@/lib/dashboard-store';
import { EditableText } from '@/components/editor';
import { getEstratoColor } from '@/lib/utils';
import { Plus, GripVertical, Pencil } from 'lucide-react';
import { Input } from '@/components/ui/input';
import { CustomSectionEditor } from './TabResultados/';
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
  Cell,
} from 'recharts';

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

// Interface para la sección de Determinantes
interface DeterminantesSectionProps {
  monitores: typeof mockDashboardData.monitores;
}

// Componente para mostrar biomasa/materia seca por estrato (contenido sin título para acordeón)
function BiomasaSectionContent({ estratos }: { estratos: typeof mockDashboardData.estratos }) {
  const biomasaData = useMemo(() => calculateBiomasaByEstrato(), []);

  const chartData = useMemo(() =>
    estratos.map((e) => ({
      nombre: e.nombre,
      promedio: biomasaData[e.nombre]?.promedio || 0,
      sitios: biomasaData[e.nombre]?.sitios || 0,
      color: e.color,
    })), [estratos, biomasaData]);

  // Calcular total de materia seca (promedio * superficie para cada estrato)
  const totalMateriaSeca = useMemo(() => {
    let total = 0;
    estratos.forEach((e) => {
      const promedio = biomasaData[e.nombre]?.promedio || 0;
      // kg MS/ha * ha = kg MS total, luego convertir a toneladas
      total += (promedio * e.superficie) / 1000;
    });
    return Math.round(total);
  }, [estratos, biomasaData]);

  return (
    <>
      <p className="text-sm text-gray-600 mb-6">
        Estimación de biomasa forrajera (kg de materia seca por hectárea) por estrato,
        basada en los datos del evento de monitoreo de Marzo 2025.
      </p>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* KPI Card - Total estimado */}
        <Card className="lg:col-span-1">
          <CardHeader className="pb-2">
            <CardTitle className="text-base">Total Estimado</CardTitle>
          </CardHeader>
          <CardContent>
            <div className="text-center py-4">
              <p className="text-4xl font-bold text-[var(--grass-green-dark)]">
                {totalMateriaSeca.toLocaleString()}
              </p>
              <p className="text-sm text-gray-500 mt-1">toneladas de MS</p>
              <p className="text-xs text-gray-400 mt-3">
                Calculado como promedio por estrato × superficie
              </p>
            </div>

            <div className="mt-4 space-y-3">
              {estratos.map((e) => {
                const data = biomasaData[e.nombre];
                const totalEstrato = data ? Math.round((data.promedio * e.superficie) / 1000) : 0;
                return (
                  <div key={e.id} className="flex items-center justify-between text-sm">
                    <div className="flex items-center gap-2">
                      <div className="w-3 h-3 rounded" style={{ backgroundColor: e.color }} aria-hidden="true" />
                      <span>{e.nombre}</span>
                    </div>
                    <span className="font-medium">{totalEstrato.toLocaleString()} t</span>
                  </div>
                );
              })}
            </div>
          </CardContent>
        </Card>

        {/* Gráfico de barras */}
        <Card className="lg:col-span-2">
          <CardHeader className="pb-2">
            <CardTitle className="text-base">Biomasa Promedio por Estrato (kg MS/ha)</CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={250}>
              <BarChart data={chartData} layout="vertical" barSize={40} margin={{ top: 5, right: 30, left: 10, bottom: 5 }}>
                <CartesianGrid strokeDasharray="3 3" horizontal={false} />
                <XAxis type="number" domain={[0, 'auto']} tickFormatter={(v) => v.toLocaleString()} />
                <YAxis
                  dataKey="nombre"
                  type="category"
                  width={100}
                  tick={{ fontSize: 13 }}
                  tickLine={false}
                  axisLine={false}
                />
                <Tooltip
                  formatter={(value) => [`${(value as number).toLocaleString()} kg MS/ha`, 'Promedio']}
                />
                <Bar dataKey="promedio" radius={[4, 4, 4, 4]}>
                  {chartData.map((entry, index) => (
                    <Cell key={index} fill={entry.color} />
                  ))}
                </Bar>
              </BarChart>
            </ResponsiveContainer>

            <div className="mt-4 grid grid-cols-3 gap-4 text-center text-sm">
              {chartData.map((d) => (
                <div key={d.nombre} className="bg-gray-50 rounded-lg p-3">
                  <div className="flex items-center justify-center gap-2 mb-1">
                    <div className="w-2 h-2 rounded" style={{ backgroundColor: d.color }} aria-hidden="true" />
                    <span className="font-medium">{d.nombre}</span>
                  </div>
                  <p className="text-lg font-bold">{d.promedio.toLocaleString()}</p>
                  <p className="text-xs text-gray-500">kg MS/ha</p>
                  <p className="text-xs text-gray-400 mt-1">{d.sitios} sitios</p>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      </div>
    </>
  );
}

// Componente DeterminantesSection con contenido sin título para acordeón
function DeterminantesSectionContent({ monitores }: DeterminantesSectionProps) {
  const [estratoSeleccionado, setEstratoSeleccionado] = useState<string>('todos');

  // Memoize expensive estrato calculations - computed once per estrato set
  const promediosPorEstrato = useMemo(() => {
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

    return {
      Loma: calcularPromediosEstrato('Loma'),
      'Media Loma': calcularPromediosEstrato('Media Loma'),
      Bajo: calcularPromediosEstrato('Bajo'),
      todos: calcularPromediosEstrato('todos'),
    };
  }, [monitores]);

  // Memoize chart data preparation
  const prepararDatosGrafico = useCallback((procesoKey: keyof typeof procesosDeterminantes) => {
    const proceso = procesosDeterminantes[procesoKey];

    if (estratoSeleccionado === 'todos') {
      return proceso.indicadores.map((ind) => ({
        indicador: ind.name,
        Loma: promediosPorEstrato.Loma[ind.key] || 0,
        'Media Loma': promediosPorEstrato['Media Loma'][ind.key] || 0,
        Bajo: promediosPorEstrato.Bajo[ind.key] || 0,
      }));
    } else {
      const promedios = promediosPorEstrato[estratoSeleccionado as keyof typeof promediosPorEstrato] || {};
      return proceso.indicadores.map((ind) => ({
        indicador: ind.name,
        valor: promedios[ind.key] || 0,
      }));
    }
  }, [estratoSeleccionado, promediosPorEstrato]);

  // Pre-compute all chart data to avoid recalculation during render
  const chartData = useMemo(() => ({
    dinamicaComunidades: prepararDatosGrafico('dinamicaComunidades'),
    flujoEnergia: prepararDatosGrafico('flujoEnergia'),
    cicloMineral: prepararDatosGrafico('cicloMineral'),
    cicloAgua: prepararDatosGrafico('cicloAgua'),
  }), [prepararDatosGrafico]);

  const estratos = ['todos', 'Loma', 'Media Loma', 'Bajo'];

  return (
    <>
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center gap-2">
          <span className="text-sm text-gray-600">Filtrar por estrato:</span>
          <select
            value={estratoSeleccionado}
            onChange={(e) => setEstratoSeleccionado(e.target.value)}
            className="text-sm border rounded px-2 py-1 bg-white"
            name="estrato-filter"
            aria-label="Filtrar por estrato"
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
              <div className="w-3 h-3 rounded" style={{ backgroundColor: procesosDeterminantes.dinamicaComunidades.color }} aria-hidden="true" />
              {procesosDeterminantes.dinamicaComunidades.nombre}
            </CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={250}>
              <LineChart data={chartData.dinamicaComunidades}>
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
              <div className="w-3 h-3 rounded" style={{ backgroundColor: procesosDeterminantes.flujoEnergia.color }} aria-hidden="true" />
              {procesosDeterminantes.flujoEnergia.nombre}
            </CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={250}>
              <BarChart data={chartData.flujoEnergia} layout="vertical">
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
              <div className="w-3 h-3 rounded" style={{ backgroundColor: procesosDeterminantes.cicloMineral.color }} aria-hidden="true" />
              {procesosDeterminantes.cicloMineral.nombre}
            </CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={250}>
              <LineChart data={chartData.cicloMineral}>
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
              <div className="w-3 h-3 rounded" style={{ backgroundColor: procesosDeterminantes.cicloAgua.color }} aria-hidden="true" />
              {procesosDeterminantes.cicloAgua.nombre}
            </CardTitle>
          </CardHeader>
          <CardContent>
            <ResponsiveContainer width="100%" height={250}>
              <LineChart data={chartData.cicloAgua}>
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
    </>
  );
}

// Componente para título editable de sección personalizada
function EditableSectionTitle({
  title,
  sectionId,
  isEditing
}: {
  title: string;
  sectionId: string;
  isEditing: boolean;
}) {
  const [isEditingTitle, setIsEditingTitle] = useState(false);
  const [titleValue, setTitleValue] = useState(title);
  const updateCustomSection = useUpdateCustomSection();
  const inputRef = useRef<HTMLInputElement>(null);

  useEffect(() => {
    if (isEditingTitle && inputRef.current) {
      inputRef.current.focus();
      inputRef.current.select();
    }
  }, [isEditingTitle]);

  // Sincronizar valor cuando cambia externamente
  useEffect(() => {
    setTitleValue(title);
  }, [title]);

  const handleSave = () => {
    if (titleValue.trim()) {
      updateCustomSection(sectionId, { title: titleValue.trim() });
    } else {
      setTitleValue(title);
    }
    setIsEditingTitle(false);
  };

  if (!isEditing) {
    return <span className="flex-1 text-left">{title}</span>;
  }

  if (isEditingTitle) {
    return (
      <Input
        ref={inputRef}
        value={titleValue}
        onChange={(e) => setTitleValue(e.target.value)}
        onBlur={handleSave}
        onKeyDown={(e) => {
          if (e.key === 'Enter') handleSave();
          if (e.key === 'Escape') {
            setTitleValue(title);
            setIsEditingTitle(false);
          }
        }}
        onClick={(e) => e.stopPropagation()}
        className="flex-1 text-base font-semibold h-8"
      />
    );
  }

  return (
    <button
      onClick={(e) => {
        e.stopPropagation();
        setIsEditingTitle(true);
      }}
      className="flex-1 text-left flex items-center gap-2 group"
    >
      <span>{title}</span>
      <Pencil className="w-3 h-3 text-gray-400 opacity-0 group-hover:opacity-100 transition-opacity" />
    </button>
  );
}

export function TabResultados() {
  const { ise, procesos, procesosHistorico, estratos, monitores } = mockDashboardData;
  const { editableContent, updateContent, setActiveTab } = useDashboardStore();
  const customSections = useCustomSections();
  const addCustomSection = useAddCustomSection();
  const removeCustomSection = useRemoveCustomSection();
  const sectionOrder = useResultadosSectionOrder();
  const setSectionOrder = useSetResultadosSectionOrder();
  const isEditing = useIsEditing();

  // Estado para drag & drop de secciones (TODAS las secciones)
  const [draggedSectionId, setDraggedSectionId] = useState<string | null>(null);
  const [dragOverSectionId, setDragOverSectionId] = useState<string | null>(null);

  const quickActions = useMemo(() => [
    { id: 'inicio', name: 'Inicio' },
    { id: 'plan-monitoreo', name: 'Plan de Monitoreo' },
    { id: 'sobre-grass', name: 'Sobre GRASS' },
    { id: 'comunidad', name: 'Comunidad' },
  ], []);

  // Handlers para drag & drop de TODAS las secciones
  const handleSectionDragStart = useCallback((e: React.DragEvent, sectionId: string) => {
    setDraggedSectionId(sectionId);
    e.dataTransfer.effectAllowed = 'move';
  }, []);

  const handleSectionDragOver = useCallback((e: React.DragEvent, sectionId: string) => {
    e.preventDefault();
    setDragOverSectionId(sectionId);
  }, []);

  const handleSectionDrop = useCallback(() => {
    if (draggedSectionId !== null && dragOverSectionId !== null && draggedSectionId !== dragOverSectionId) {
      const fromIndex = sectionOrder.indexOf(draggedSectionId);
      const toIndex = sectionOrder.indexOf(dragOverSectionId);
      if (fromIndex !== -1 && toIndex !== -1) {
        const newOrder = [...sectionOrder];
        const [removed] = newOrder.splice(fromIndex, 1);
        newOrder.splice(toIndex, 0, removed);
        setSectionOrder(newOrder);
      }
    }
    setDraggedSectionId(null);
    setDragOverSectionId(null);
  }, [draggedSectionId, dragOverSectionId, sectionOrder, setSectionOrder]);

  const handleSectionDragEnd = useCallback(() => {
    setDraggedSectionId(null);
    setDragOverSectionId(null);
  }, []);

  // Memoize chart data preparations
  const iseEstratoData = useMemo(() =>
    Object.entries(ise.porEstrato).map(([nombre, valor]) => ({
      nombre,
      ISE: valor,
      color: getEstratoColor(nombre),
    })), [ise.porEstrato]);

  const iseEvolucionData = useMemo(() =>
    ise.historico.map((h) => ({
      fecha: h.fecha,
      ISE: h.valor,
    })), [ise.historico]);

  const iseEstratoEvolucionData = useMemo(() =>
    ise.historico.map((h) => ({
      fecha: h.fecha,
      ...h.porEstrato,
    })), [ise.historico]);

  const procesosData = useMemo(() => [
    { proceso: 'Ciclo del Agua', valor: procesos.cicloAgua, fill: grassTheme.colors.procesos.cicloAgua },
    { proceso: 'Ciclo Mineral', valor: procesos.cicloMineral, fill: grassTheme.colors.procesos.cicloMineral },
    { proceso: 'Flujo de Energía', valor: procesos.flujoEnergia, fill: grassTheme.colors.procesos.flujoEnergia },
    { proceso: 'Din. Comunidades', valor: procesos.dinamicaComunidades, fill: grassTheme.colors.procesos.dinamicaComunidades },
  ], [procesos]);

  const procesosEvolucionData = useMemo(() =>
    procesosHistorico.map((h) => ({
      fecha: h.fecha,
      'Ciclo Agua': h.valores.cicloAgua,
      'Ciclo Mineral': h.valores.cicloMineral,
      'Flujo Energía': h.valores.flujoEnergia,
      'Din. Comunidades': h.valores.dinamicaComunidades,
    })), [procesosHistorico]);

  return (
    <div className="space-y-8 max-w-6xl mx-auto">
      {/* Encabezado */}
      <div>
        <h2 className="text-2xl font-bold text-black" style={{ textWrap: 'balance' }}>
          Resultados del Monitoreo
        </h2>
        <p className="text-gray-600 mt-1">
          Índice de Salud Ecosistémica (ISE) y Procesos del Ecosistema
        </p>
      </div>

      {/* ACORDEÓN DE SECCIONES - Renderizadas según el orden */}
      <Accordion type="multiple" defaultValue={['ise']} className="space-y-4">
        {sectionOrder.map((sectionId) => {
          // Propiedades comunes de drag & drop para todas las secciones
          const dragProps = isEditing ? {
            draggable: true,
            onDragStart: (e: React.DragEvent) => handleSectionDragStart(e, sectionId),
            onDragOver: (e: React.DragEvent) => handleSectionDragOver(e, sectionId),
            onDrop: handleSectionDrop,
            onDragEnd: handleSectionDragEnd,
          } : {};

          const dragClasses = `${draggedSectionId === sectionId ? 'opacity-40' : ''} ${
            dragOverSectionId === sectionId ? 'border-t-4 border-[var(--grass-green)]' : ''
          }`;

          // Sección ISE
          if (sectionId === 'ise') {
            return (
              <div key={sectionId} {...dragProps} className={dragClasses}>
                <AccordionItem value="ise" className="border rounded-lg px-4">
                  <AccordionTrigger className="text-base font-semibold text-[var(--grass-green-dark)] hover:no-underline">
                    <div className="flex items-center gap-2 w-full">
                      {isEditing && <GripVertical className="w-4 h-4 text-gray-400 cursor-move shrink-0" />}
                      <span className="flex-1 text-left">Índice de Salud Ecosistémica (ISE)</span>
                    </div>
                  </AccordionTrigger>
                  <AccordionContent>
                    <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
                      <Card>
                        <CardHeader className="pb-2">
                          <CardTitle className="text-base">ISE por Estrato - Marzo 2025</CardTitle>
                        </CardHeader>
                        <CardContent>
                          <ResponsiveContainer width="100%" height={220}>
                            <BarChart data={iseEstratoData} layout="vertical" barSize={40} margin={{ top: 5, right: 30, left: 10, bottom: 5 }}>
                              <CartesianGrid strokeDasharray="3 3" horizontal={false} />
                              <XAxis type="number" domain={[0, 100]} />
                              <YAxis dataKey="nombre" type="category" width={100} tick={{ fontSize: 13 }} tickLine={false} axisLine={false} />
                              <Tooltip />
                              <ReferenceLine x={ISE_THRESHOLD} stroke="#666" strokeDasharray="5 5" label={{ value: 'Deseable', position: 'top' }} />
                              <ReferenceLine x={ise.promedio} stroke="#E65100" strokeDasharray="3 3" label={{ value: `Prom: ${ise.promedio}`, position: 'bottom' }} />
                              <Bar dataKey="ISE" radius={[4, 4, 4, 4]}>
                                {iseEstratoData.map((entry, index) => (
                                  <Cell key={index} fill={entry.color} />
                                ))}
                              </Bar>
                            </BarChart>
                          </ResponsiveContainer>
                          <EditableText
                            value={editableContent.comentarioISEEstrato || `ISE promedio de ${ise.promedio}, por debajo del umbral deseable (${ISE_THRESHOLD}). Loma con menor valor por uso agrícola.`}
                            onChange={(v) => updateContent('comentarioISEEstrato', v)}
                            placeholder="Comentario sobre ISE por estrato…"
                            className="text-xs text-gray-500 mt-2"
                            showPencilOnHover
                            multiline
                          />
                        </CardContent>
                      </Card>
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
                              <Bar dataKey="ISE" fill={grassTheme.colors.primary.green} radius={[4, 4, 0, 0]} />
                            </BarChart>
                          </ResponsiveContainer>
                          <EditableText
                            value={editableContent.comentarioEvolucionISE || 'Caída inicial marcada por sequía severa, con recuperación parcial posterior.'}
                            onChange={(v) => updateContent('comentarioEvolucionISE', v)}
                            placeholder="Comentario sobre evolución del ISE…"
                            className="text-xs text-gray-500 mt-2"
                            showPencilOnHover
                            multiline
                          />
                        </CardContent>
                      </Card>
                    </div>
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
                          value={editableContent.comentarioEvolucionISEEstrato || 'Loma estable en valores bajos por uso agrícola. Media Loma con tendencia negativa.'}
                          onChange={(v) => updateContent('comentarioEvolucionISEEstrato', v)}
                          placeholder="Comentario sobre evolución ISE por estrato…"
                          className="text-xs text-gray-500 mt-2"
                          showPencilOnHover
                          multiline
                        />
                      </CardContent>
                    </Card>
                  </AccordionContent>
                </AccordionItem>
              </div>
            );
          }

          // Sección Procesos
          if (sectionId === 'procesos') {
            return (
              <div key={sectionId} {...dragProps} className={dragClasses}>
                <AccordionItem value="procesos" className="border rounded-lg px-4">
                  <AccordionTrigger className="text-base font-semibold text-[var(--grass-green-dark)] hover:no-underline">
                    <div className="flex items-center gap-2 w-full">
                      {isEditing && <GripVertical className="w-4 h-4 text-gray-400 cursor-move shrink-0" />}
                      <span className="flex-1 text-left">Procesos del Ecosistema</span>
                    </div>
                  </AccordionTrigger>
                  <AccordionContent>
                    <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
                      <Card>
                        <CardHeader className="pb-2">
                          <CardTitle className="text-base">Procesos - Total Establecimiento (Marzo 2025)</CardTitle>
                        </CardHeader>
                        <CardContent>
                          <ResponsiveContainer width="100%" height={280}>
                            <BarChart data={procesosData} layout="vertical" barSize={40} margin={{ top: 5, right: 30, left: 10, bottom: 5 }}>
                              <CartesianGrid strokeDasharray="3 3" horizontal={false} />
                              <XAxis type="number" domain={[0, 100]} unit="%" />
                              <YAxis dataKey="proceso" type="category" width={140} tick={{ fontSize: 13 }} tickLine={false} axisLine={false} />
                              <Tooltip formatter={(value) => `${value}%`} />
                              <Bar dataKey="valor" radius={[4, 4, 4, 4]}>
                                {procesosData.map((entry, index) => (
                                  <Cell key={index} fill={entry.fill} />
                                ))}
                              </Bar>
                            </BarChart>
                          </ResponsiveContainer>
                          <div className="mt-4 grid grid-cols-2 gap-2 text-sm">
                            <div className="flex items-center gap-2">
                              <div className="w-3 h-3 rounded" style={{ backgroundColor: grassTheme.colors.procesos.cicloAgua }} aria-hidden="true" />
                              <span>Ciclo del Agua: {procesos.cicloAgua}%</span>
                            </div>
                            <div className="flex items-center gap-2">
                              <div className="w-3 h-3 rounded" style={{ backgroundColor: grassTheme.colors.procesos.cicloMineral }} aria-hidden="true" />
                              <span>Ciclo Mineral: {procesos.cicloMineral}%</span>
                            </div>
                            <div className="flex items-center gap-2">
                              <div className="w-3 h-3 rounded" style={{ backgroundColor: grassTheme.colors.procesos.flujoEnergia }} aria-hidden="true" />
                              <span>Flujo de Energía: {procesos.flujoEnergia}%</span>
                            </div>
                            <div className="flex items-center gap-2">
                              <div className="w-3 h-3 rounded" style={{ backgroundColor: grassTheme.colors.procesos.dinamicaComunidades }} aria-hidden="true" />
                              <span>Din. Comunidades: {procesos.dinamicaComunidades}%</span>
                            </div>
                          </div>
                          <EditableText
                            value={editableContent.comentarioProcesosActual || `Ciclo del agua adecuado (${procesos.cicloAgua}%). Dinámica de comunidades limitada (${procesos.dinamicaComunidades}%).`}
                            onChange={(v) => updateContent('comentarioProcesosActual', v)}
                            placeholder="Comentario sobre procesos ecosistémicos…"
                            className="text-xs text-gray-500 mt-3"
                            showPencilOnHover
                            multiline
                          />
                        </CardContent>
                      </Card>
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
                            value={editableContent.comentarioEvolucionProcesos || 'Ciclos del agua y mineral estables. Flujo de energía con caída inicial y recuperación parcial.'}
                            onChange={(v) => updateContent('comentarioEvolucionProcesos', v)}
                            placeholder="Comentario sobre evolución de procesos…"
                            className="text-xs text-gray-500 mt-2"
                            showPencilOnHover
                            multiline
                          />
                        </CardContent>
                      </Card>
                    </div>
                    <h4 className="text-sm font-semibold text-[var(--grass-green-dark)] mt-8 mb-4 border-b pb-2">
                      Determinantes de los Procesos del Ecosistema
                    </h4>
                    <DeterminantesSectionContent monitores={monitores} />
                  </AccordionContent>
                </AccordionItem>
              </div>
            );
          }

          // Sección Forraje
          if (sectionId === 'forraje') {
            return (
              <div key={sectionId} {...dragProps} className={dragClasses}>
                <AccordionItem value="forraje" className="border rounded-lg px-4">
                  <AccordionTrigger className="text-base font-semibold text-[var(--grass-green-dark)] hover:no-underline">
                    <div className="flex items-center gap-2 w-full">
                      {isEditing && <GripVertical className="w-4 h-4 text-gray-400 cursor-move shrink-0" />}
                      <span className="flex-1 text-left">Disponibilidad y Calidad Forrajera</span>
                    </div>
                  </AccordionTrigger>
                  <AccordionContent>
                    <BiomasaSectionContent estratos={estratos} />
                    <h4 className="text-sm font-semibold text-[var(--grass-green-dark)] mt-8 mb-4 border-b pb-2">
                      Análisis de Calidad Forrajera
                    </h4>
                    <p className="text-sm text-gray-600 mb-6">
                      Análisis de la biomasa disponible (kg de materia seca por hectárea) y calidad forrajera (escala 1-5)
                      por estrato, basado en los datos del evento de monitoreo.
                    </p>
                    <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
                      <Card>
                        <CardHeader className="pb-2">
                          <CardTitle className="text-base">Disponibilidad Forrajera por Estrato</CardTitle>
                        </CardHeader>
                        <CardContent>
                          <ForrajeBiomasaChart data={forrajeData} />
                          <EditableText
                            value={editableContent.comentarioForrajeBiomasa || 'Bajo con mayor disponibilidad por mejores condiciones hídricas y gestión de descansos.'}
                            onChange={(v) => updateContent('comentarioForrajeBiomasa', v)}
                            placeholder="Comentario sobre disponibilidad forrajera…"
                            className="text-xs text-gray-500 mt-2"
                            showPencilOnHover
                            multiline
                          />
                        </CardContent>
                      </Card>
                      <Card>
                        <CardHeader className="pb-2">
                          <CardTitle className="text-base">Calidad Forrajera por Estrato</CardTitle>
                        </CardHeader>
                        <CardContent>
                          <ForrajeCalidadChart data={forrajeData} />
                          <p className="text-xs text-gray-400 mt-2 mb-2">
                            Escala: 1 (muy baja) - 5 (muy buena). Línea punteada indica calidad media (3).
                          </p>
                          <EditableText
                            value={editableContent.comentarioForrajeCalidad || 'Valores superiores a 3 indican buena presencia de gramíneas perennes y leguminosas.'}
                            onChange={(v) => updateContent('comentarioForrajeCalidad', v)}
                            placeholder="Comentario sobre calidad forrajera…"
                            className="text-xs text-gray-500"
                            showPencilOnHover
                            multiline
                          />
                        </CardContent>
                      </Card>
                    </div>
                    <Card>
                      <CardHeader className="pb-2">
                        <CardTitle className="text-base">Evolución Interanual de Forraje por Estrato</CardTitle>
                      </CardHeader>
                      <CardContent>
                        <ForrajeInteranualChart data={forrajeHistorico} />
                        <EditableText
                          value={editableContent.comentarioForrajeInteranual || 'Las condiciones climáticas y decisiones de manejo inciden directamente en la biomasa acumulada.'}
                          onChange={(v) => updateContent('comentarioForrajeInteranual', v)}
                          placeholder="Comentario sobre evolución del forraje…"
                          className="text-xs text-gray-500 mt-2"
                          showPencilOnHover
                          multiline
                        />
                      </CardContent>
                    </Card>
                  </AccordionContent>
                </AccordionItem>
              </div>
            );
          }

          // Sección Pastoreo
          if (sectionId === 'pastoreo') {
            return (
              <div key={sectionId} {...dragProps} className={dragClasses}>
                <AccordionItem value="pastoreo" className="border rounded-lg px-4">
                  <AccordionTrigger className="text-base font-semibold text-[var(--grass-green-dark)] hover:no-underline">
                    <div className="flex items-center gap-2 w-full">
                      {isEditing && <GripVertical className="w-4 h-4 text-gray-400 cursor-move shrink-0" />}
                      <span className="flex-1 text-left">Patrón e Intensidad de Pastoreo</span>
                    </div>
                  </AccordionTrigger>
                  <AccordionContent>
                    <p className="text-sm text-gray-600 mb-6">
                      Distribución del patrón de uso del pastoreo a nivel de establecimiento y la intensidad de pastoreo
                      por estrato, basado en las observaciones del evento de monitoreo.
                    </p>
                    <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
                      <Card>
                        <CardHeader className="pb-2">
                          <CardTitle className="text-base">Patrón de Uso - Total Establecimiento</CardTitle>
                        </CardHeader>
                        <CardContent>
                          <PatronPastoreoChart data={pastoreoData.patronTotal} />
                          <EditableText
                            value={editableContent.comentarioPatronPastoreo || 'La carga animal y las salidas intensas de potreros pueden limitar la acumulación de biomasa.'}
                            onChange={(v) => updateContent('comentarioPatronPastoreo', v)}
                            placeholder="Comentario sobre patrón de pastoreo…"
                            className="text-xs text-gray-500 mt-2"
                            showPencilOnHover
                            multiline
                          />
                        </CardContent>
                      </Card>
                      <Card>
                        <CardHeader className="pb-2">
                          <CardTitle className="text-base">Intensidad de Pastoreo por Estrato</CardTitle>
                        </CardHeader>
                        <CardContent>
                          <IntensidadPastoreoChart data={pastoreoData.intensidadPorEstrato} />
                          <EditableText
                            value={editableContent.comentarioIntensidadPastoreo || 'Gestión cuidadosa de descansos favorece la recuperación ecológica.'}
                            onChange={(v) => updateContent('comentarioIntensidadPastoreo', v)}
                            placeholder="Comentario sobre intensidad de pastoreo…"
                            className="text-xs text-gray-500 mt-2"
                            showPencilOnHover
                            multiline
                          />
                        </CardContent>
                      </Card>
                    </div>
                  </AccordionContent>
                </AccordionItem>
              </div>
            );
          }

          // Sección Anexo
          if (sectionId === 'anexo') {
            return (
              <div key={sectionId} {...dragProps} className={dragClasses}>
                <AccordionItem value="anexo" className="border rounded-lg px-4">
                  <AccordionTrigger className="text-base font-semibold text-[var(--grass-green-dark)] hover:no-underline">
                    <div className="flex items-center gap-2 w-full">
                      {isEditing && <GripVertical className="w-4 h-4 text-gray-400 cursor-move shrink-0" />}
                      <span className="flex-1 text-left">Anexo</span>
                    </div>
                  </AccordionTrigger>
                  <AccordionContent>
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
                              <TableRow className="bg-gray-50">
                                <TableCell className="font-medium sticky left-0 bg-gray-50 z-10">Estrato</TableCell>
                                {monitores.map((m) => (
                                  <TableCell key={m.id} className="text-center font-medium" style={{ color: getEstratoColor(m.estrato) }}>
                                    {m.estratoCodigo}
                                  </TableCell>
                                ))}
                              </TableRow>
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
                  </AccordionContent>
                </AccordionItem>
              </div>
            );
          }

          // Secciones personalizadas
          const customSection = customSections.find(s => s.id === sectionId);
          if (customSection) {
            return (
              <div key={sectionId} {...dragProps} className={dragClasses}>
                <AccordionItem value={customSection.id} className="border rounded-lg px-4">
                  <AccordionTrigger className="text-base font-semibold text-[var(--grass-green-dark)] hover:no-underline">
                    <div className="flex items-center gap-2 w-full">
                      {isEditing && <GripVertical className="w-4 h-4 text-gray-400 cursor-move shrink-0" />}
                      <EditableSectionTitle
                        title={customSection.title}
                        sectionId={customSection.id}
                        isEditing={isEditing}
                      />
                    </div>
                  </AccordionTrigger>
                  <AccordionContent>
                    <CustomSectionEditor
                      section={customSection}
                      onDelete={() => removeCustomSection(customSection.id)}
                    />
                  </AccordionContent>
                </AccordionItem>
              </div>
            );
          }

          return null;
        })}
      </Accordion>

      {/* Botón para agregar nueva sección - solo en modo edición */}
      {isEditing && (
        <Button
          variant="outline"
          onClick={() => addCustomSection()}
          className="w-full border-dashed border-2 border-gray-300 hover:border-[var(--grass-green)] text-gray-500 hover:text-[var(--grass-green-dark)]"
        >
          <Plus className="w-4 h-4 mr-2" />
          Agregar nueva sección
        </Button>
      )}

      {/* Footer */}
      <div className="mt-8 pt-6 pb-8 border-t border-gray-200">
        <div className="grid grid-cols-2 md:grid-cols-4 gap-3 mb-8">
          {quickActions.map((action) => (
            <Button
              key={action.id}
              variant="outline"
              size="sm"
              className="text-gray-600 hover:text-gray-900 hover:bg-gray-50 border-gray-200 w-full"
              onClick={() => setActiveTab(action.id)}
            >
              {action.name}
            </Button>
          ))}
        </div>
        <p className="text-center text-xs text-gray-400">
          Grassland Regeneration and Sustainable Standard - 2025
        </p>
      </div>
    </div>
  );
}
