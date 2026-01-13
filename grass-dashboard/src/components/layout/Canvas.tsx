'use client';

import { useState } from 'react';
import { useDashboardStore, generateWidgetId } from '@/lib/dashboard-store';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { cn } from '@/lib/utils';
import { Download } from 'lucide-react';
import type { WidgetConfig, WidgetType } from '@/types/dashboard';
import { TabInicio } from '@/components/tabs/TabInicio';
import { TabPlanMonitoreo } from '@/components/tabs/TabPlanMonitoreo';
import { TabResultados } from '@/components/tabs/TabResultados';
import { TabSobreGrass } from '@/components/tabs/TabSobreGrass';
import { TabComunidad } from '@/components/tabs/TabComunidad';

export function Canvas() {
  const { activeTab, setActiveTab, tabs, addWidget, isEditing } = useDashboardStore();
  const [isDraggingOver, setIsDraggingOver] = useState(false);

  const handleDrop = (e: React.DragEvent<HTMLDivElement>) => {
    e.preventDefault();
    setIsDraggingOver(false);
    const widgetType = e.dataTransfer.getData('widgetType') as WidgetType;

    if (widgetType) {
      const newWidget: WidgetConfig = {
        id: generateWidgetId(),
        type: widgetType,
        title: getDefaultTitle(widgetType),
        gridPosition: { x: 0, y: 0, w: 6, h: 4 },
        config: getDefaultConfig(widgetType),
        editable: true,
      };

      addWidget(activeTab, newWidget);
    }
  };

  const handleDragOver = (e: React.DragEvent<HTMLDivElement>) => {
    e.preventDefault();
    e.dataTransfer.dropEffect = 'copy';
  };

  const handleDragEnter = (e: React.DragEvent<HTMLDivElement>) => {
    e.preventDefault();
    if (isEditing) {
      setIsDraggingOver(true);
    }
  };

  const handleDragLeave = (e: React.DragEvent<HTMLDivElement>) => {
    // Only set to false if we're leaving the main container
    const rect = e.currentTarget.getBoundingClientRect();
    const x = e.clientX;
    const y = e.clientY;
    if (x < rect.left || x > rect.right || y < rect.top || y > rect.bottom) {
      setIsDraggingOver(false);
    }
  };

  return (
    <main
      data-tour="canvas"
      className={cn(
        'flex-1 overflow-auto bg-gray-50 transition-all duration-200',
        isDraggingOver && isEditing && 'bg-[var(--grass-green)]/5 ring-2 ring-inset ring-[var(--grass-green)] ring-opacity-50'
      )}
      onDrop={handleDrop}
      onDragOver={handleDragOver}
      onDragEnter={handleDragEnter}
      onDragLeave={handleDragLeave}
    >
      <Tabs value={activeTab} onValueChange={setActiveTab} className="h-full flex flex-col">
        {/* Tabs de navegación */}
        <div className="bg-white border-b px-4">
          <TabsList className="h-12 bg-transparent">
            {tabs.map((tab) => (
              <TabsTrigger
                key={tab.id}
                value={tab.id}
                className="data-[state=active]:bg-[var(--grass-green-light)]/20 data-[state=active]:text-[var(--grass-green-dark)] px-4"
              >
                {tab.name}
              </TabsTrigger>
            ))}
          </TabsList>
        </div>

        {/* Contenido de cada tab */}
        <div className="flex-1 overflow-auto p-6">
          <TabsContent value="inicio" className="m-0 h-full">
            <TabInicio />
          </TabsContent>

          <TabsContent value="plan-monitoreo" className="m-0 h-full">
            <TabPlanMonitoreo />
          </TabsContent>

          <TabsContent value="resultados" className="m-0 h-full">
            <TabResultados />
          </TabsContent>

          <TabsContent value="sobre-grass" className="m-0 h-full">
            <TabSobreGrass />
          </TabsContent>

          <TabsContent value="comunidad" className="m-0 h-full">
            <TabComunidad />
          </TabsContent>
        </div>

        {/* Indicador de modo edición / drop zone */}
        {isEditing && (
          <div
            className={cn(
              'absolute bottom-4 left-1/2 -translate-x-1/2 px-4 py-2 rounded-full text-sm font-medium shadow-lg transition-all',
              isDraggingOver
                ? 'bg-[var(--grass-green)] text-white scale-110'
                : 'bg-[var(--grass-green)] text-white'
            )}
          >
            {isDraggingOver ? (
              <span className="flex items-center gap-2">
                <Download className="w-4 h-4 animate-bounce" />
                Suelta aquí para agregar
              </span>
            ) : (
              'Modo edición activo - Arrastra componentes aquí'
            )}
          </div>
        )}
      </Tabs>
    </main>
  );
}

function getDefaultTitle(type: WidgetType): string {
  const titles: Record<WidgetType, string> = {
    'bar-chart': 'Gráfico de Barras',
    'line-chart': 'Evolución Temporal',
    'pie-chart': 'Distribución',
    'data-table': 'Tabla de Datos',
    'kpi-card': 'Indicador',
    'text-block': 'Comentario',
    'map-widget': 'Mapa',
    'photo-carousel': 'Galería',
    'timeline': 'Historial',
  };
  return titles[type];
}

function getDefaultConfig(type: WidgetType): Record<string, unknown> {
  const configs: Record<WidgetType, Record<string, unknown>> = {
    'bar-chart': { dataSource: 'ise', showLegend: true },
    'line-chart': { dataSource: 'iseHistorico', showLegend: true },
    'pie-chart': { dataSource: 'estratos' },
    'data-table': { dataSource: 'monitores' },
    'kpi-card': { metric: 'isePromedio', label: 'ISE Promedio' },
    'text-block': { content: 'Ingrese su comentario aquí...' },
    'map-widget': { showEstratos: true, showMonitores: true },
    'photo-carousel': { images: [] },
    'timeline': { events: [] },
  };
  return configs[type];
}
