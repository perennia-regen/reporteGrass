'use client';

import { useDashboardStore } from '@/lib/dashboard-store';
import { Card } from '@/components/ui/card';
import type { WidgetType } from '@/types/dashboard';

interface WidgetOption {
  type: WidgetType;
  name: string;
  icon: React.ReactNode;
  description: string;
}

const widgetOptions: WidgetOption[] = [
  {
    type: 'bar-chart',
    name: 'Gráfico de Barras',
    icon: (
      <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 19v-6a2 2 0 00-2-2H5a2 2 0 00-2 2v6a2 2 0 002 2h2a2 2 0 002-2zm0 0V9a2 2 0 012-2h2a2 2 0 012 2v10m-6 0a2 2 0 002 2h2a2 2 0 002-2m0 0V5a2 2 0 012-2h2a2 2 0 012 2v14a2 2 0 01-2 2h-2a2 2 0 01-2-2z" />
      </svg>
    ),
    description: 'ISE por estrato, procesos',
  },
  {
    type: 'line-chart',
    name: 'Gráfico de Líneas',
    icon: (
      <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M7 12l3-3 3 3 4-4M8 21l4-4 4 4M3 4h18M4 4h16v12a1 1 0 01-1 1H5a1 1 0 01-1-1V4z" />
      </svg>
    ),
    description: 'Evolución temporal',
  },
  {
    type: 'pie-chart',
    name: 'Gráfico Circular',
    icon: (
      <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M11 3.055A9.001 9.001 0 1020.945 13H11V3.055z" />
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M20.488 9H15V3.512A9.025 9.025 0 0120.488 9z" />
      </svg>
    ),
    description: 'Distribución de área',
  },
  {
    type: 'kpi-card',
    name: 'Tarjeta KPI',
    icon: (
      <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 7h6m0 10v-3m-3 3h.01M9 17h.01M9 14h.01M12 14h.01M15 11h.01M12 11h.01M9 11h.01M7 21h10a2 2 0 002-2V5a2 2 0 00-2-2H7a2 2 0 00-2 2v14a2 2 0 002 2z" />
      </svg>
    ),
    description: 'Métricas destacadas',
  },
  {
    type: 'data-table',
    name: 'Tabla de Datos',
    icon: (
      <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M3 10h18M3 14h18m-9-4v8m-7 0h14a2 2 0 002-2V8a2 2 0 00-2-2H5a2 2 0 00-2 2v8a2 2 0 002 2z" />
      </svg>
    ),
    description: 'Resultados por monitor',
  },
  {
    type: 'text-block',
    name: 'Bloque de Texto',
    icon: (
      <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 6h16M4 12h16M4 18h7" />
      </svg>
    ),
    description: 'Comentarios editables',
  },
  {
    type: 'map-widget',
    name: 'Mapa',
    icon: (
      <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 20l-5.447-2.724A1 1 0 013 16.382V5.618a1 1 0 011.447-.894L9 7m0 13l6-3m-6 3V7m6 10l4.553 2.276A1 1 0 0021 18.382V7.618a1 1 0 00-.553-.894L15 4m0 13V4m0 0L9 7" />
      </svg>
    ),
    description: 'Estratos y monitores',
  },
  {
    type: 'photo-carousel',
    name: 'Carrusel de Fotos',
    icon: (
      <svg className="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
      </svg>
    ),
    description: 'Galería de imágenes',
  },
];

export function Sidebar() {
  const { isEditing } = useDashboardStore();

  if (!isEditing) {
    return null;
  }

  return (
    <aside className="w-64 border-r bg-white p-4 overflow-y-auto shrink-0">
      <h2 className="font-semibold text-gray-900 mb-4">Componentes</h2>
      <p className="text-xs text-gray-500 mb-4">
        Arrastra los componentes al dashboard
      </p>

      <div className="space-y-2">
        {widgetOptions.map((widget) => (
          <Card
            key={widget.type}
            className="p-3 cursor-grab hover:bg-gray-50 transition-colors"
            draggable
            onDragStart={(e) => {
              e.dataTransfer.setData('widgetType', widget.type);
              e.dataTransfer.effectAllowed = 'copy';
            }}
          >
            <div className="flex items-center gap-3">
              <div className="text-[var(--grass-green-dark)]">{widget.icon}</div>
              <div>
                <p className="font-medium text-sm">{widget.name}</p>
                <p className="text-xs text-gray-500">{widget.description}</p>
              </div>
            </div>
          </Card>
        ))}
      </div>

      <div className="mt-6 pt-4 border-t">
        <h3 className="font-medium text-sm text-gray-700 mb-2">Consejos</h3>
        <ul className="text-xs text-gray-500 space-y-1">
          <li>- Arrastra para agregar</li>
          <li>- Click para seleccionar</li>
          <li>- Bordes para redimensionar</li>
        </ul>
      </div>
    </aside>
  );
}
