'use client';

import { useState } from 'react';
import { useDashboardStore } from '@/lib/dashboard-store';
import { Button } from '@/components/ui/button';
import { ChevronLeft, ChevronRight, ChevronDown, ChevronUp, Activity, Leaf, Layers, Map, Lightbulb, Type, Table2, TableProperties } from 'lucide-react';
import { cn } from '@/lib/utils';
import { ChartThumbnail } from './ChartThumbnail';
import type { WidgetType, SugerenciaWidgetType } from '@/types/dashboard';
import type { LucideIcon } from 'lucide-react';

interface ChartOption {
  type: WidgetType | SugerenciaWidgetType;
  label: string;
  icon?: LucideIcon;
}

interface ChartCategory {
  id: string;
  nombre: string;
  icon: LucideIcon;
  charts: ChartOption[];
}

const chartCategories: ChartCategory[] = [
  {
    id: 'ise',
    nombre: 'ISE',
    icon: Activity,
    charts: [
      { type: 'ise-estrato-anual', label: 'ISE del año por estrato' },
      { type: 'ise-interanual-establecimiento', label: 'ISE interanual establecimiento' },
      { type: 'ise-interanual-estrato', label: 'ISE interanual por estrato' },
    ],
  },
  {
    id: 'procesos',
    nombre: 'Procesos del Ecosistema',
    icon: Leaf,
    charts: [
      { type: 'procesos-anual', label: 'Del año de monitoreo' },
      { type: 'procesos-interanual', label: 'Interanual' },
    ],
  },
  {
    id: 'determinantes',
    nombre: 'Determinantes',
    icon: Layers,
    charts: [
      { type: 'determinantes-interanual', label: 'Interanual' },
    ],
  },
  {
    id: 'estratos',
    nombre: 'Estratos',
    icon: Map,
    charts: [
      { type: 'estratos-distribucion', label: 'Distribución de área' },
      { type: 'estratos-comparativa', label: 'Comparativa por variable' },
    ],
  },
  {
    id: 'sugerencias',
    nombre: 'Sugerencias',
    icon: Lightbulb,
    charts: [
      { type: 'text-block-sugerencia', label: 'Cuadro de texto', icon: Type },
      { type: 'tabla-estrato', label: 'Tabla por estrato', icon: Table2 },
      { type: 'tabla-personalizable', label: 'Tabla personalizable', icon: TableProperties },
    ],
  },
];

export function Sidebar() {
  const { isEditing, sidebarCollapsed, setSidebarCollapsed } = useDashboardStore();
  const [expandedCategories, setExpandedCategories] = useState<Record<string, boolean>>({
    ise: true,
    procesos: true,
    determinantes: true,
    estratos: true,
    sugerencias: true,
  });

  if (!isEditing) {
    return null;
  }

  const toggleCategory = (categoryId: string) => {
    setExpandedCategories((prev) => ({
      ...prev,
      [categoryId]: !prev[categoryId],
    }));
  };

  return (
    <aside
      data-tour="sidebar"
      className={cn(
        'border-r border-gray-300 bg-gray-100 overflow-y-auto shrink-0 transition-all duration-300 relative',
        sidebarCollapsed ? 'w-16' : 'w-72'
      )}
    >
      {/* Toggle button */}
      <Button
        variant="outline"
        size="icon-sm"
        type="button"
        className="absolute -right-3 top-4 z-10 rounded-full shadow-md bg-white"
        onClick={() => setSidebarCollapsed(!sidebarCollapsed)}
        aria-label={sidebarCollapsed ? 'Expandir sidebar' : 'Colapsar sidebar'}
        aria-expanded={!sidebarCollapsed}
      >
        {sidebarCollapsed ? (
          <ChevronRight className="w-4 h-4" aria-hidden="true" />
        ) : (
          <ChevronLeft className="w-4 h-4" aria-hidden="true" />
        )}
      </Button>

      <div className="p-4">
        {!sidebarCollapsed && (
          <>
            <h2 className="font-semibold text-gray-900 mb-1">Gráficos</h2>
            <p className="text-xs text-gray-500 mb-4">
              Arrastra los gráficos al informe
            </p>
          </>
        )}

        <div className={cn('space-y-3', sidebarCollapsed && 'mt-8')}>
          {chartCategories.map((category) => {
            const Icon = category.icon;
            const isExpanded = expandedCategories[category.id];

            return (
              <div key={category.id} className="bg-white rounded-lg border border-gray-200 overflow-hidden">
                {/* Category header */}
                <button
                  type="button"
                  onClick={() => !sidebarCollapsed && toggleCategory(category.id)}
                  className={cn(
                    'w-full flex items-center gap-2 px-3 py-2.5 text-left hover:bg-gray-50 transition-colors',
                    sidebarCollapsed && 'justify-center'
                  )}
                  title={sidebarCollapsed ? category.nombre : undefined}
                  aria-expanded={!sidebarCollapsed && isExpanded}
                  aria-controls={`category-${category.id}`}
                >
                  <Icon className="w-4 h-4 text-[var(--grass-green-dark)] shrink-0" />
                  {!sidebarCollapsed && (
                    <>
                      <span className="font-medium text-sm text-gray-800 flex-1">
                        {category.nombre}
                      </span>
                      {isExpanded ? (
                        <ChevronUp className="w-4 h-4 text-gray-400" aria-hidden="true" />
                      ) : (
                        <ChevronDown className="w-4 h-4 text-gray-400" aria-hidden="true" />
                      )}
                    </>
                  )}
                </button>

                {/* Category charts */}
                {!sidebarCollapsed && isExpanded && (
                  <div id={`category-${category.id}`} className="px-3 pb-3 space-y-2">
                    {category.charts.map((chart) => {
                      const ChartIcon = chart.icon;
                      const isSugerenciaWidget = ['text-block-sugerencia', 'tabla-estrato', 'tabla-personalizable'].includes(chart.type);

                      return (
                        <div
                          key={chart.type}
                          className="cursor-grab active:cursor-grabbing"
                          draggable
                          onDragStart={(e) => {
                            e.dataTransfer.setData('widgetType', chart.type);
                            e.dataTransfer.effectAllowed = 'copy';
                          }}
                        >
                          <p className="text-xs text-gray-600 mb-1">{chart.label}</p>
                          {isSugerenciaWidget && ChartIcon ? (
                            <div className="h-16 bg-gray-50 rounded-md border border-gray-200 flex items-center justify-center hover:bg-gray-100 transition-colors">
                              <ChartIcon className="w-6 h-6 text-gray-400" />
                            </div>
                          ) : (
                            <ChartThumbnail chartType={chart.type as WidgetType} title={chart.label} />
                          )}
                        </div>
                      );
                    })}
                  </div>
                )}
              </div>
            );
          })}
        </div>

        {!sidebarCollapsed && (
          <div className="mt-6 pt-4 border-t border-gray-300">
            <h3 className="font-medium text-sm text-gray-700 mb-2">Consejos</h3>
            <ul className="text-xs text-gray-500 space-y-1">
              <li>- Arrastra para agregar al informe</li>
              <li>- Pasa el mouse y haz click en el ojo para ver en grande</li>
              <li>- Click en un gráfico del informe para seleccionarlo</li>
            </ul>
          </div>
        )}
      </div>
    </aside>
  );
}
