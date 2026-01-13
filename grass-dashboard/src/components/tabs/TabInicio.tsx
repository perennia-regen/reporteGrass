'use client';

import { useState } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { mockDashboardData } from '@/lib/mock-data';
import { ISE_THRESHOLD } from '@/styles/grass-theme';
import { useDashboardStore } from '@/lib/dashboard-store';
import { EditableText } from '@/components/editor';
import { SugerenciasSection } from '@/components/sugerencias';
import type { WidgetType } from '@/types/dashboard';
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
} from 'lucide-react';

// Tipos locales para los gráficos predeterminados de la página inicio
type ChartType = 'evolucion-ise' | 'ise-estrato' | 'procesos' | 'procesos-evolucion';

// Mapa de WidgetType de sidebar a ChartType local (todos los gráficos permitidos)
const widgetToLocalChart: Partial<Record<WidgetType, ChartType>> = {
  'ise-estrato-anual': 'ise-estrato',
  'ise-interanual-establecimiento': 'evolucion-ise',
  'ise-interanual-estrato': 'evolucion-ise',
  'procesos-anual': 'procesos',
  'procesos-interanual': 'procesos-evolucion',
  'determinantes-interanual': 'procesos', // Usa misma visualización
  'estratos-distribucion': 'ise-estrato', // Usa misma visualización
  'estratos-comparativa': 'ise-estrato', // Usa misma visualización
};

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

export function TabInicio() {
  const { establecimiento, ise, estratos, fotos } = mockDashboardData;
  const { isEditing, editableContent, updateContent, setActiveTab } = useDashboardStore();

  // Estado para los gráficos principales (siempre 2) y adicionales
  const [chart1, setChart1] = useState<ChartType>('evolucion-ise');
  const [chart2, setChart2] = useState<ChartType>('ise-estrato');
  const [additionalCharts, setAdditionalCharts] = useState<ChartType[]>([]);
  const [isDraggingOver, setIsDraggingOver] = useState(false);

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

  // Handlers para drag & drop
  const handleDragOver = (e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
    setIsDraggingOver(true);
  };

  const handleDragLeave = (e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
    setIsDraggingOver(false);
  };

  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();
    setIsDraggingOver(false);

    const widgetType = e.dataTransfer.getData('widgetType') as WidgetType;
    if (widgetType) {
      // Convertir WidgetType de sidebar a ChartType local
      const localChartType = widgetToLocalChart[widgetType];
      if (localChartType && !getUsedCharts().includes(localChartType)) {
        addChart(localChartType);
      }
    }
  };

  const renderChart = (chartType: ChartType) => {
    switch (chartType) {
      case 'evolucion-ise':
        return (
          <div className="h-48">
            <div className="flex items-end justify-between h-full gap-2 px-4 pb-4">
              {ise.historico.map((punto, index) => (
                <div key={index} className="flex flex-col items-center flex-1">
                  <div
                    className="w-full rounded-t transition-all duration-500"
                    style={{
                      height: `${Math.max(punto.valor * 1.5, 10)}px`,
                      backgroundColor: punto.valor >= ISE_THRESHOLD ? 'var(--grass-green)' : 'var(--grass-brown)',
                    }}
                  />
                  <span className="text-xs mt-2 text-gray-600">{punto.fecha}</span>
                  <span className="text-sm font-semibold">{punto.valor.toFixed(1)}</span>
                </div>
              ))}
            </div>
            <div className="px-4 mt-2 border-t pt-2">
              <div className="flex items-center justify-center gap-2 text-xs text-gray-500">
                <div className="w-3 h-3 bg-[var(--grass-green)] rounded" />
                <span>≥ {ISE_THRESHOLD} (Deseable)</span>
                <div className="w-3 h-3 bg-[var(--grass-brown)] rounded ml-4" />
                <span>&lt; {ISE_THRESHOLD}</span>
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
                        backgroundColor: valor >= ISE_THRESHOLD ? 'var(--grass-green)' : 'var(--grass-brown)',
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
          { key: 'cicloAgua', label: 'Ciclo del Agua', color: '#3B82F6' },
          { key: 'cicloMineral', label: 'Ciclo Mineral', color: '#8B5CF6' },
          { key: 'flujoEnergia', label: 'Flujo de Energía', color: '#F59E0B' },
          { key: 'dinamicaComunidades', label: 'Dinámica Comunidades', color: '#10B981' },
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
                      className="w-3 rounded-t bg-blue-500"
                      style={{ height: `${punto.valores.cicloAgua}%` }}
                      title="Ciclo Agua"
                    />
                    <div
                      className="w-3 rounded-t bg-purple-500"
                      style={{ height: `${punto.valores.cicloMineral}%` }}
                      title="Ciclo Mineral"
                    />
                    <div
                      className="w-3 rounded-t bg-amber-500"
                      style={{ height: `${punto.valores.flujoEnergia}%` }}
                      title="Flujo Energía"
                    />
                    <div
                      className="w-3 rounded-t bg-emerald-500"
                      style={{ height: `${punto.valores.dinamicaComunidades}%` }}
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
      {/* Datos Destacados - KPIs (3 cards) */}
      <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
        <Card className="bg-white">
          <CardContent className="pt-6">
            <div className="text-center">
              <p className="text-3xl font-bold text-[var(--grass-green-dark)]">
                {ise.promedio.toFixed(1)}
              </p>
              <p className="text-sm text-gray-500 mt-1">ISE Promedio</p>
              <div className="mt-2 text-xs">
                <span className={ise.promedio >= ISE_THRESHOLD ? 'text-green-600' : 'text-orange-500'}>
                  {ise.promedio >= ISE_THRESHOLD ? 'Deseable' : `${(ISE_THRESHOLD - ise.promedio).toFixed(1)} pts bajo umbral`}
                </span>
              </div>
            </div>
          </CardContent>
        </Card>

        <Card className="bg-white">
          <CardContent className="pt-6">
            <div className="text-center">
              <p className="text-3xl font-bold text-[var(--grass-brown)]">
                {establecimiento.areaTotal}
              </p>
              <p className="text-sm text-gray-500 mt-1">Hectáreas</p>
              <p className="text-xs text-gray-400 mt-2">Área total monitoreada</p>
            </div>
          </CardContent>
        </Card>

        <Card className="bg-white">
          <CardContent className="pt-6">
            <div className="text-center">
              <p className="text-3xl font-bold text-[var(--estrato-loma)]">
                {estratos.reduce((sum, e) => sum + e.estaciones, 0)}
              </p>
              <p className="text-sm text-gray-500 mt-1">Sitios MCP</p>
              <p className="text-xs text-gray-400 mt-2">Puntos de monitoreo</p>
            </div>
          </CardContent>
        </Card>
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

          {/* Zona de drop y botón agregar gráfico - solo en modo edición */}
          {isEditing && getAvailableCharts().length > 0 && (
            <div
              className={`mt-6 flex justify-center p-6 border-2 border-dashed rounded-lg transition-colors ${
                isDraggingOver
                  ? 'border-[var(--grass-green)] bg-[var(--grass-green-light)]'
                  : 'border-gray-300 hover:border-gray-400'
              }`}
              onDragOver={handleDragOver}
              onDragLeave={handleDragLeave}
              onDrop={handleDrop}
            >
              <Button
                variant="ghost"
                onClick={() => addChart()}
                className="text-gray-500 hover:text-[var(--grass-green-dark)]"
              >
                <Plus className="w-4 h-4 mr-2" />
                {isDraggingOver ? 'Soltar aquí para agregar' : 'Agregar gráfico o arrastrar desde la barra lateral'}
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
            {fotos.map((foto, index) => (
              <div key={index} className="group">
                <div className="aspect-video bg-gray-100 rounded-lg flex items-center justify-center text-gray-400 relative overflow-hidden">
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
                </div>
                {/* Pie de foto */}
                <div className="mt-2">
                  <p className="text-sm font-medium text-[var(--grass-green-dark)]">{foto.sitio}</p>
                  <p className="text-xs text-gray-500">{foto.comentario}</p>
                </div>
              </div>
            ))}
          </div>
        </CardContent>
      </Card>

      {/* Botones de Quick Action */}
      <Card>
        <CardHeader className="pb-2">
          <CardTitle className="text-lg text-[var(--grass-green-dark)] flex items-center gap-2">
            <Layers className="w-5 h-5" />
            Explorar Secciones
          </CardTitle>
        </CardHeader>
        <CardContent>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            {quickActions.map((action) => {
              const Icon = action.icon;
              return (
                <Button
                  key={action.id}
                  variant="outline"
                  className="h-auto py-4 flex flex-col items-center gap-2 hover:bg-gray-50 border-2 transition-all hover:border-[var(--grass-green)]"
                  onClick={() => setActiveTab(action.id)}
                >
                  <Icon className="w-6 h-6" style={{ color: action.color }} />
                  <span className="text-sm font-medium">{action.name}</span>
                </Button>
              );
            })}
          </div>
        </CardContent>
      </Card>
    </div>
  );
}
