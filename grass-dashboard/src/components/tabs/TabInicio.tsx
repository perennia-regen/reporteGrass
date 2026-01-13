'use client';

import { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { mockDashboardData } from '@/lib/mock-data';
import { ISE_THRESHOLD, grassTheme } from '@/styles/grass-theme';
import { useDashboardStore, type KPIType } from '@/lib/dashboard-store';
import { EditableText } from '@/components/editor';
import { getEstratoColor } from '@/lib/utils';
import { SugerenciasSection } from '@/components/sugerencias';
import { PhotoGalleryModal } from '@/components/PhotoGalleryModal';
import type { FotoMonitoreo } from '@/types/dashboard';
import {
  ArrowRight,
  Map,
  BarChart3,
  Info,
  Users,
  TrendingUp,
  Layers,
  Plus,
  X,
  Camera,
} from 'lucide-react';

// Tipos locales para los gráficos predeterminados de la página inicio
type ChartType = 'evolucion-ise' | 'ise-estrato' | 'procesos' | 'procesos-evolucion';

interface ChartOption {
  id: ChartType;
  name: string;
  description: string;
}

const chartOptions: ChartOption[] = [
  { id: 'evolucion-ise', name: 'Evolución ISE Interanual', description: 'Tendencia histórica del ISE' },
  { id: 'ise-estrato', name: 'ISE por Estrato', description: 'Comparación entre ambientes' },
  { id: 'procesos', name: 'Procesos Ecosistémicos', description: 'Estado de los 4 procesos' },
  { id: 'procesos-evolucion', name: 'Evolución Procesos', description: 'Tendencia de procesos' },
];

// Opciones de KPIs (el tipo viene del store)
interface KPIOption {
  id: KPIType;
  name: string;
  shortName: string;
  requiresInteranual: boolean;
}

const kpiOptions: KPIOption[] = [
  { id: 'ise-promedio', name: 'ISE Promedio del campo', shortName: 'ISE Promedio', requiresInteranual: false },
  { id: 'ise-evolucion', name: '% Evolución ISE', shortName: 'Evol. ISE', requiresInteranual: true },
  { id: 'hectareas', name: 'Hectáreas Totales monitoreadas', shortName: 'Hectáreas', requiresInteranual: false },
  { id: 'sitios-mcp', name: 'Número de Sitios MCP', shortName: 'Sitios MCP', requiresInteranual: false },
  { id: 'procesos-evolucion-prom', name: '% Evolución Procesos Ecosistémicos (promedio)', shortName: 'Evol. Procesos', requiresInteranual: true },
  { id: 'ciclo-agua', name: 'Ciclo del Agua', shortName: 'Ciclo Agua', requiresInteranual: false },
  { id: 'ciclo-agua-evolucion', name: '% Evolución Ciclo del Agua', shortName: 'Evol. Ciclo Agua', requiresInteranual: true },
  { id: 'dinamica-comunidades', name: 'Dinámica de las Comunidades', shortName: 'Dinámica Com.', requiresInteranual: false },
  { id: 'dinamica-evolucion', name: '% Evolución Dinámica de Comunidades', shortName: 'Evol. Dinámica', requiresInteranual: true },
  { id: 'ciclo-nutrientes', name: 'Ciclo de Nutrientes', shortName: 'Ciclo Nutrientes', requiresInteranual: false },
  { id: 'ciclo-nutrientes-evolucion', name: '% Evolución Ciclo de Nutrientes', shortName: 'Evol. Nutrientes', requiresInteranual: true },
  { id: 'flujo-energia', name: 'Flujo de Energía', shortName: 'Flujo Energía', requiresInteranual: false },
  { id: 'flujo-energia-evolucion', name: '% Evolución Flujo de Energía', shortName: 'Evol. Energía', requiresInteranual: true },
];

// Función para calcular evolución porcentual
const calcularEvolucion = (actual: number, anterior: number): number => {
  if (anterior === 0) return actual > 0 ? 100 : 0;
  return ((actual - anterior) / Math.abs(anterior)) * 100;
};

export function TabInicio() {
  const { establecimiento, ise, estratos, fotos, procesos, procesosHistorico } = mockDashboardData;
  const { isEditing, editableContent, updateContent, setActiveTab, selectedKPIs, updateKPI } = useDashboardStore();

  // Estado para los gráficos principales (siempre 2) y adicionales (máximo 2 más = 4 total)
  const [chart1, setChart1] = useState<ChartType>('evolucion-ise');
  const [chart2, setChart2] = useState<ChartType>('ise-estrato');
  const [additionalCharts, setAdditionalCharts] = useState<ChartType[]>([]);

  // KPIs del store (persistidos)
  const [kpi1, kpi2, kpi3] = selectedKPIs;

  // Estado para la galería de fotos
  const [showGallery, setShowGallery] = useState(false);
  const [selectedPhotoIndex, setSelectedPhotoIndex] = useState<number | null>(null);
  const [localFotos, setLocalFotos] = useState<FotoMonitoreo[]>(fotos);

  const getChartName = (chartType: ChartType) => {
    return chartOptions.find(opt => opt.id === chartType)?.name || '';
  };

  const getUsedCharts = () => {
    return [chart1, chart2, ...additionalCharts];
  };

  const getAvailableCharts = () => {
    const used = getUsedCharts();
    return chartOptions.filter(opt => !used.includes(opt.id));
  };

  const addChart = (chartType?: ChartType) => {
    if (chartType) {
      // Si se especifica un tipo, verificar que no esté en uso
      if (!getUsedCharts().includes(chartType)) {
        setAdditionalCharts([...additionalCharts, chartType]);
      }
    } else {
      // Si no se especifica, usar el primer disponible
      const available = getAvailableCharts();
      if (available.length > 0) {
        setAdditionalCharts([...additionalCharts, available[0].id]);
      }
    }
  };

  const removeChart = (index: number) => {
    setAdditionalCharts(additionalCharts.filter((_, i) => i !== index));
  };

  // Handler para seleccionar foto de la galería
  const handlePhotoSelect = (foto: FotoMonitoreo) => {
    if (selectedPhotoIndex !== null) {
      const newFotos = [...localFotos];
      newFotos[selectedPhotoIndex] = foto;
      setLocalFotos(newFotos);
    }
    setSelectedPhotoIndex(null);
  };

  // Ubicación para mostrar en la galería
  const ubicacionStr = `${establecimiento.ubicacion.distrito}, ${establecimiento.ubicacion.departamento}`;

  // Función para obtener los datos de un KPI
  const getKPIData = (type: KPIType): { value: string; label: string; sublabel: string; color: string; isPositive?: boolean } => {
    const lastISE = ise.historico[ise.historico.length - 1];
    const prevISE = ise.historico[ise.historico.length - 2];
    const lastProcesos = procesosHistorico[procesosHistorico.length - 1];
    const prevProcesos = procesosHistorico[procesosHistorico.length - 2];

    switch (type) {
      case 'ise-promedio':
        return {
          value: ise.promedio.toFixed(1),
          label: 'ISE Promedio',
          sublabel: ise.promedio >= ISE_THRESHOLD ? 'Deseable' : `${(ISE_THRESHOLD - ise.promedio).toFixed(1)} pts bajo umbral`,
          color: 'var(--grass-green-dark)',
        };

      case 'ise-evolucion': {
        const evol = calcularEvolucion(lastISE.valor, prevISE.valor);
        return {
          value: `${evol > 0 ? '+' : ''}${evol.toFixed(1)}%`,
          label: 'Evolución ISE',
          sublabel: `vs ${prevISE.fecha}`,
          color: evol >= 0 ? 'var(--grass-green-dark)' : 'var(--grass-brown)',
          isPositive: evol >= 0,
        };
      }

      case 'hectareas':
        return {
          value: establecimiento.areaTotal.toString(),
          label: 'Hectáreas',
          sublabel: 'Área total monitoreada',
          color: 'var(--grass-brown)',
        };

      case 'sitios-mcp':
        return {
          value: estratos.reduce((sum, e) => sum + e.estaciones, 0).toString(),
          label: 'Sitios MCP',
          sublabel: 'Puntos de monitoreo',
          color: 'var(--estrato-loma)',
        };

      case 'procesos-evolucion-prom': {
        const promActual = (lastProcesos.valores.cicloAgua + lastProcesos.valores.cicloMineral + lastProcesos.valores.flujoEnergia + lastProcesos.valores.dinamicaComunidades) / 4;
        const promAnterior = (prevProcesos.valores.cicloAgua + prevProcesos.valores.cicloMineral + prevProcesos.valores.flujoEnergia + prevProcesos.valores.dinamicaComunidades) / 4;
        const evol = calcularEvolucion(promActual, promAnterior);
        return {
          value: `${evol > 0 ? '+' : ''}${evol.toFixed(1)}%`,
          label: 'Evol. Procesos',
          sublabel: `Promedio vs ${prevProcesos.fecha}`,
          color: evol >= 0 ? 'var(--grass-green-dark)' : 'var(--grass-brown)',
          isPositive: evol >= 0,
        };
      }

      case 'ciclo-agua':
        return {
          value: `${procesos.cicloAgua}%`,
          label: 'Ciclo del Agua',
          sublabel: 'Proceso ecosistémico',
          color: '#3B82F6',
        };

      case 'ciclo-agua-evolucion': {
        const evol = calcularEvolucion(lastProcesos.valores.cicloAgua, prevProcesos.valores.cicloAgua);
        return {
          value: `${evol > 0 ? '+' : ''}${evol.toFixed(1)}%`,
          label: 'Evol. Ciclo Agua',
          sublabel: `vs ${prevProcesos.fecha}`,
          color: evol >= 0 ? 'var(--grass-green-dark)' : 'var(--grass-brown)',
          isPositive: evol >= 0,
        };
      }

      case 'dinamica-comunidades':
        return {
          value: `${procesos.dinamicaComunidades}%`,
          label: 'Dinámica Comunidades',
          sublabel: 'Proceso ecosistémico',
          color: '#10B981',
        };

      case 'dinamica-evolucion': {
        const evol = calcularEvolucion(lastProcesos.valores.dinamicaComunidades, prevProcesos.valores.dinamicaComunidades);
        return {
          value: `${evol > 0 ? '+' : ''}${evol.toFixed(1)}%`,
          label: 'Evol. Dinámica',
          sublabel: `vs ${prevProcesos.fecha}`,
          color: evol >= 0 ? 'var(--grass-green-dark)' : 'var(--grass-brown)',
          isPositive: evol >= 0,
        };
      }

      case 'ciclo-nutrientes':
        return {
          value: `${procesos.cicloMineral}%`,
          label: 'Ciclo Nutrientes',
          sublabel: 'Proceso ecosistémico',
          color: '#8B5CF6',
        };

      case 'ciclo-nutrientes-evolucion': {
        const evol = calcularEvolucion(lastProcesos.valores.cicloMineral, prevProcesos.valores.cicloMineral);
        return {
          value: `${evol > 0 ? '+' : ''}${evol.toFixed(1)}%`,
          label: 'Evol. Nutrientes',
          sublabel: `vs ${prevProcesos.fecha}`,
          color: evol >= 0 ? 'var(--grass-green-dark)' : 'var(--grass-brown)',
          isPositive: evol >= 0,
        };
      }

      case 'flujo-energia':
        return {
          value: `${procesos.flujoEnergia}%`,
          label: 'Flujo de Energía',
          sublabel: 'Proceso ecosistémico',
          color: '#F59E0B',
        };

      case 'flujo-energia-evolucion': {
        const evol = calcularEvolucion(lastProcesos.valores.flujoEnergia, prevProcesos.valores.flujoEnergia);
        return {
          value: `${evol > 0 ? '+' : ''}${evol.toFixed(1)}%`,
          label: 'Evol. Flujo Energía',
          sublabel: `vs ${prevProcesos.fecha}`,
          color: evol >= 0 ? 'var(--grass-green-dark)' : 'var(--grass-brown)',
          isPositive: evol >= 0,
        };
      }

      default:
        return {
          value: '-',
          label: 'Sin datos',
          sublabel: '',
          color: 'gray',
        };
    }
  };

  // Componente KPICard configurable
  const KPICard = ({
    value,
    onChange,
    usedKPIs,
  }: {
    value: KPIType;
    onChange: (v: KPIType) => void;
    usedKPIs: KPIType[];
  }) => {
    const data = getKPIData(value);
    const option = kpiOptions.find(o => o.id === value);

    return (
      <Card className="bg-white">
        <CardContent className="pt-6">
          {isEditing && (
            <div className="mb-3">
              <select
                value={value}
                onChange={(e) => onChange(e.target.value as KPIType)}
                className="w-full text-xs border rounded px-2 py-1.5 bg-gray-50 text-gray-700"
              >
                {kpiOptions.map((opt) => (
                  <option
                    key={opt.id}
                    value={opt.id}
                    disabled={usedKPIs.includes(opt.id) && opt.id !== value}
                  >
                    {opt.name}
                  </option>
                ))}
              </select>
            </div>
          )}
          <div className="text-center">
            <p
              className="text-3xl font-bold"
              style={{ color: data.color }}
            >
              {data.value}
            </p>
            <p className="text-sm text-gray-500 mt-1">{data.label}</p>
            <p className={`text-xs mt-2 ${data.isPositive === false ? 'text-orange-500' : data.isPositive === true ? 'text-green-600' : 'text-gray-400'}`}>
              {data.sublabel}
            </p>
          </div>
        </CardContent>
      </Card>
    );
  };

  // KPIs actualmente en uso
  const getUsedKPIs = () => [kpi1, kpi2, kpi3];

  // Función para calcular color de gradiente basado en valor ISE (0-100)
  // Verde brillante (#22c55e) para valores altos → Verde oscuro (#14532d) para valores bajos
  const getISEGradientColor = (valor: number): string => {
    // Normalizar valor entre 0 y 100
    const normalized = Math.max(0, Math.min(100, valor)) / 100;

    // Colores: verde brillante (alto) → verde oscuro (bajo)
    // #22c55e (RGB: 34, 197, 94) → #14532d (RGB: 20, 83, 45)
    const r = Math.round(20 + (34 - 20) * normalized);
    const g = Math.round(83 + (197 - 83) * normalized);
    const b = Math.round(45 + (94 - 45) * normalized);

    return `rgb(${r}, ${g}, ${b})`;
  };

  const renderChart = (chartType: ChartType) => {
    switch (chartType) {
      case 'evolucion-ise':
        // Encontrar el valor máximo y mínimo para la leyenda del gradiente
        const maxISE = Math.max(...ise.historico.map(p => p.valor));
        const minISE = Math.min(...ise.historico.map(p => p.valor));

        return (
          <div className="h-48">
            <div className="flex items-end justify-between h-full gap-2 px-4 pb-4">
              {ise.historico.map((punto, index) => (
                <div key={index} className="flex flex-col items-center flex-1">
                  <div
                    className="w-full rounded-t transition-all duration-500"
                    style={{
                      height: `${Math.max(punto.valor * 1.5, 10)}px`,
                      backgroundColor: getISEGradientColor(punto.valor),
                    }}
                  />
                  <span className="text-xs mt-2 text-gray-600">{punto.fecha}</span>
                  <span className="text-sm font-semibold">{punto.valor.toFixed(1)}</span>
                </div>
              ))}
            </div>
            <div className="px-4 mt-2 border-t pt-2">
              <div className="flex items-center justify-center gap-2 text-xs text-gray-500">
                <div
                  className="w-16 h-3 rounded"
                  style={{
                    background: `linear-gradient(to right, ${getISEGradientColor(0)}, ${getISEGradientColor(50)}, ${getISEGradientColor(100)})`
                  }}
                />
                <span>0</span>
                <span className="mx-1">→</span>
                <span>100 (Mayor = Mejor)</span>
              </div>
            </div>
          </div>
        );

      case 'ise-estrato':
        return (
          <div className="space-y-3 p-4">
            {Object.entries(ise.porEstrato).map(([estrato, valor]) => {
              const porcentaje = (valor / 100) * 100;
              return (
                <div key={estrato} className="flex items-center gap-4">
                  <span className="w-24 text-sm font-medium">{estrato}</span>
                  <div className="flex-1 bg-gray-100 rounded-full h-6 relative overflow-hidden">
                    <div
                      className="h-full rounded-full transition-all duration-500"
                      style={{
                        width: `${Math.max(porcentaje, 0)}%`,
                        backgroundColor: getEstratoColor(estrato),
                      }}
                    />
                    <div
                      className="absolute top-0 bottom-0 w-0.5 bg-gray-400"
                      style={{ left: `${ISE_THRESHOLD}%` }}
                    />
                  </div>
                  <span className="w-12 text-right font-semibold">{valor.toFixed(1)}</span>
                </div>
              );
            })}
            <p className="text-xs text-gray-500 mt-2">
              Línea vertical indica umbral deseable ({ISE_THRESHOLD} puntos)
            </p>
          </div>
        );

      case 'procesos':
        const procesos = mockDashboardData.procesos;
        const procesosLabels = [
          { key: 'cicloAgua', label: 'Ciclo del Agua', color: grassTheme.colors.procesos.cicloAgua },
          { key: 'cicloMineral', label: 'Ciclo Mineral', color: grassTheme.colors.procesos.cicloMineral },
          { key: 'flujoEnergia', label: 'Flujo de Energía', color: grassTheme.colors.procesos.flujoEnergia },
          { key: 'dinamicaComunidades', label: 'Dinámica Comunidades', color: grassTheme.colors.procesos.dinamicaComunidades },
        ];
        return (
          <div className="space-y-3 p-4">
            {procesosLabels.map(({ key, label, color }) => (
              <div key={key} className="flex items-center gap-4">
                <span className="w-40 text-sm font-medium">{label}</span>
                <div className="flex-1 bg-gray-100 rounded-full h-5 overflow-hidden">
                  <div
                    className="h-full rounded-full transition-all duration-500"
                    style={{
                      width: `${procesos[key as keyof typeof procesos]}%`,
                      backgroundColor: color,
                    }}
                  />
                </div>
                <span className="w-10 text-right font-semibold">{procesos[key as keyof typeof procesos]}%</span>
              </div>
            ))}
          </div>
        );

      case 'procesos-evolucion':
        const historico = mockDashboardData.procesosHistorico;
        return (
          <div className="h-48 p-4">
            <div className="flex items-end justify-between h-full gap-4">
              {historico.map((punto, index) => (
                <div key={index} className="flex flex-col items-center flex-1">
                  <div className="flex items-end gap-0.5 h-32">
                    <div
                      className="w-3 rounded-t"
                      style={{ 
                        height: `${punto.valores.cicloAgua}%`,
                        backgroundColor: grassTheme.colors.procesos.cicloAgua
                      }}
                      title="Ciclo Agua"
                    />
                    <div
                      className="w-3 rounded-t"
                      style={{ 
                        height: `${punto.valores.cicloMineral}%`,
                        backgroundColor: grassTheme.colors.procesos.cicloMineral
                      }}
                      title="Ciclo Mineral"
                    />
                    <div
                      className="w-3 rounded-t"
                      style={{ 
                        height: `${punto.valores.flujoEnergia}%`,
                        backgroundColor: grassTheme.colors.procesos.flujoEnergia
                      }}
                      title="Flujo Energía"
                    />
                    <div
                      className="w-3 rounded-t"
                      style={{ 
                        height: `${punto.valores.dinamicaComunidades}%`,
                        backgroundColor: grassTheme.colors.procesos.dinamicaComunidades
                      }}
                      title="Dinámica"
                    />
                  </div>
                  <span className="text-xs mt-2 text-gray-600">{punto.fecha}</span>
                </div>
              ))}
            </div>
          </div>
        );
    }
  };

  // Componente para el header del gráfico (modo edición vs visualización)
  const ChartHeader = ({
    value,
    onChange,
    usedCharts,
    canRemove = false,
    onRemove
  }: {
    value: ChartType;
    onChange: (v: ChartType) => void;
    usedCharts: ChartType[];
    canRemove?: boolean;
    onRemove?: () => void;
  }) => {
    if (isEditing) {
      return (
        <div className="bg-gray-50 px-4 py-2 flex items-center justify-between border-b">
          <select
            value={value}
            onChange={(e) => onChange(e.target.value as ChartType)}
            className="text-xs border rounded px-2 py-1 bg-white"
          >
            {chartOptions.map((opt) => (
              <option key={opt.id} value={opt.id} disabled={usedCharts.includes(opt.id) && opt.id !== value}>
                {opt.name}
              </option>
            ))}
          </select>
          {canRemove && onRemove && (
            <button
              onClick={onRemove}
              className="p-1 hover:bg-red-100 rounded text-red-500"
              title="Eliminar gráfico"
            >
              <X className="w-4 h-4" />
            </button>
          )}
        </div>
      );
    }

    return (
      <div className="bg-gray-50 px-4 py-2 flex items-center justify-between border-b">
        <span className="text-sm font-medium text-gray-700">{getChartName(value)}</span>
      </div>
    );
  };

  const quickActions = [
    { id: 'plan-monitoreo', name: 'Plan de Monitoreo', icon: Map, color: 'var(--grass-green)' },
    { id: 'resultados', name: 'Resultados', icon: BarChart3, color: 'var(--grass-brown)' },
    { id: 'sobre-grass', name: 'Sobre GRASS', icon: Info, color: 'var(--grass-orange)' },
    { id: 'comunidad', name: 'Comunidad', icon: Users, color: 'var(--estrato-loma)' },
  ];

  return (
    <div className="space-y-6 max-w-6xl mx-auto">
      {/* Datos Destacados - KPIs configurables (3 cards) */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <KPICard value={kpi1} onChange={(v) => updateKPI(0, v)} usedKPIs={getUsedKPIs()} />
        <KPICard value={kpi2} onChange={(v) => updateKPI(1, v)} usedKPIs={getUsedKPIs()} />
        <KPICard value={kpi3} onChange={(v) => updateKPI(2, v)} usedKPIs={getUsedKPIs()} />
      </div>

      {/* Principales Resultados - Gráficos */}
      <Card>
        <CardHeader className="pb-2">
          <div className="flex items-center justify-between">
            <CardTitle className="text-lg text-[var(--grass-green-dark)] flex items-center gap-2">
              <TrendingUp className="w-5 h-5" />
              Principales Resultados
            </CardTitle>
            <Button
              variant="outline"
              size="sm"
              onClick={() => setActiveTab('resultados')}
              className="text-[var(--grass-green-dark)] border-[var(--grass-green)] hover:bg-[var(--grass-green-light)]"
            >
              Ver resultados completos
              <ArrowRight className="w-4 h-4 ml-2" />
            </Button>
          </div>
        </CardHeader>
        <CardContent>
          {/* Gráficos principales (2 columnas) */}
          <div className="grid grid-cols-1 md:grid-cols-2 gap-6">
            {/* Gráfico 1 */}
            <div className="border rounded-lg overflow-hidden">
              <ChartHeader
                value={chart1}
                onChange={setChart1}
                usedCharts={getUsedCharts()}
              />
              {renderChart(chart1)}
            </div>

            {/* Gráfico 2 */}
            <div className="border rounded-lg overflow-hidden">
              <ChartHeader
                value={chart2}
                onChange={setChart2}
                usedCharts={getUsedCharts()}
              />
              {renderChart(chart2)}
            </div>
          </div>

          {/* Gráficos adicionales */}
          {additionalCharts.length > 0 && (
            <div className="grid grid-cols-1 md:grid-cols-2 gap-6 mt-6">
              {additionalCharts.map((chartType, index) => (
                <div key={index} className="border rounded-lg overflow-hidden">
                  <ChartHeader
                    value={chartType}
                    onChange={(newType) => {
                      const newCharts = [...additionalCharts];
                      newCharts[index] = newType;
                      setAdditionalCharts(newCharts);
                    }}
                    usedCharts={getUsedCharts()}
                    canRemove={true}
                    onRemove={() => removeChart(index)}
                  />
                  {renderChart(chartType)}
                </div>
              ))}
            </div>
          )}

          {/* Botón agregar gráfico - solo en modo edición y máximo 4 gráficos totales */}
          {isEditing && getAvailableCharts().length > 0 && additionalCharts.length < 2 && (
            <div className="mt-6 flex justify-center p-6 border-2 border-dashed rounded-lg border-gray-300 hover:border-gray-400 transition-colors">
              <Button
                variant="ghost"
                onClick={() => addChart()}
                className="text-gray-500 hover:text-[var(--grass-green-dark)]"
              >
                <Plus className="w-4 h-4 mr-2" />
                Agregar gráfico ({2 + additionalCharts.length}/4)
              </Button>
            </div>
          )}
        </CardContent>
      </Card>

      {/* Observación General */}
      <Card>
        <CardHeader className="pb-2">
          <CardTitle className="text-lg text-[var(--grass-green-dark)]">
            Observación General
          </CardTitle>
        </CardHeader>
        <CardContent>
          <EditableText
            value={editableContent.observacionGeneral}
            onChange={(value) => updateContent('observacionGeneral', value)}
            placeholder="Ingrese una observación general del monitoreo..."
            className="text-gray-700 leading-relaxed"
            multiline
          />
        </CardContent>
      </Card>

      {/* Sugerencias y Recomendaciones */}
      <SugerenciasSection />

      {/* Fotos del Monitoreo */}
      <Card>
        <CardHeader className="pb-2">
          <CardTitle className="text-lg text-[var(--grass-green-dark)]">
            Fotos del Monitoreo
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            {localFotos.map((foto, index) => (
              <div key={index} className="group">
                {/* Foto con opción de cambiar en modo edición */}
                <div
                  className={`aspect-video bg-gray-100 rounded-lg flex items-center justify-center text-gray-400 relative overflow-hidden ${
                    isEditing ? 'cursor-pointer hover:bg-gray-200 transition-colors' : ''
                  }`}
                  onClick={() => {
                    if (isEditing) {
                      setSelectedPhotoIndex(index);
                      setShowGallery(true);
                    }
                  }}
                >
                  <div className="text-center">
                    <svg
                      className="w-8 h-8 mx-auto mb-2"
                      fill="none"
                      viewBox="0 0 24 24"
                      stroke="currentColor"
                    >
                      <path
                        strokeLinecap="round"
                        strokeLinejoin="round"
                        strokeWidth={1.5}
                        d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z"
                      />
                    </svg>
                  </div>
                  {/* Overlay de edición */}
                  {isEditing && (
                    <div className="absolute inset-0 bg-black/0 group-hover:bg-black/30 flex items-center justify-center transition-colors">
                      <Camera className="w-6 h-6 text-white opacity-0 group-hover:opacity-100 transition-opacity" />
                    </div>
                  )}
                </div>
                {/* Pie de foto con comentario editable */}
                <div className="mt-2">
                  <p className="text-sm font-medium text-[var(--grass-green-dark)]">{foto.sitio}</p>
                  <p className="text-xs text-gray-400 mb-1">{ubicacionStr}</p>
                  <EditableText
                    value={editableContent[`foto_comentario_${index}`] || foto.comentario}
                    onChange={(value) => updateContent(`foto_comentario_${index}`, value)}
                    placeholder="Agregar comentario..."
                    className="text-xs text-gray-500"
                  />
                </div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>

      {/* Footer con Quick Actions */}
      <div className="mt-8 pt-6 border-t-2 border-gray-100">
        <div className="flex items-center justify-center gap-2 mb-4">
          <Layers className="w-4 h-4 text-gray-400" />
          <span className="text-sm text-gray-500 font-medium">Explorar Secciones</span>
        </div>
        <div className="grid grid-cols-2 md:grid-cols-4 gap-3">
          {quickActions.map((action) => {
            const Icon = action.icon;
            return (
              <Button
                key={action.id}
                variant="ghost"
                className="h-auto py-3 flex flex-col items-center gap-1.5 hover:bg-gray-50 rounded-xl transition-all group"
                onClick={() => setActiveTab(action.id)}
              >
                <div
                  className="p-2 rounded-lg transition-colors"
                  style={{ backgroundColor: `${action.color}15` }}
                >
                  <Icon className="w-5 h-5" style={{ color: action.color }} />
                </div>
                <span className="text-xs font-medium text-gray-600 group-hover:text-gray-900">{action.name}</span>
              </Button>
            );
          })}
        </div>
      </div>

      {/* Modal de galería de fotos */}
      <PhotoGalleryModal
        isOpen={showGallery}
        onClose={() => {
          setShowGallery(false);
          setSelectedPhotoIndex(null);
        }}
        onSelect={handlePhotoSelect}
        currentPhotoUrl={selectedPhotoIndex !== null ? localFotos[selectedPhotoIndex]?.url : undefined}
      />
    </div>
  );
}
