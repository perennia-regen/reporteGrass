'use client';

import { useDashboardStore } from '@/lib/dashboard-store';
import { EditableText } from '@/components/editor/EditableText';
import { TablaEstrato } from './TablaEstrato';
import { TablaPersonalizable } from './TablaPersonalizable';
import { X, Type, Table2, TableProperties, BarChart3, GripVertical, Columns2, Columns3, Square } from 'lucide-react';
import type { SugerenciaItem, SugerenciaLayout } from '@/types/dashboard';
import { ChartThumbnail } from '@/components/layout/ChartThumbnail';

interface SugerenciaWidgetProps {
  item: SugerenciaItem;
  onRemove: () => void;
  onLayoutChange?: (colSpan: SugerenciaLayout) => void;
  showDragHandle?: boolean;
  layoutOptions?: { value: SugerenciaLayout; label: string }[];
}

// Nombres de los tipos de gráficos
const chartLabels: Record<string, string> = {
  'ise-estrato-anual': 'ISE por Estrato',
  'ise-interanual-establecimiento': 'ISE Interanual',
  'ise-interanual-estrato': 'ISE Interanual por Estrato',
  'procesos-anual': 'Procesos del Año',
  'procesos-interanual': 'Procesos Interanual',
  'determinantes-interanual': 'Determinantes',
  'estratos-distribucion': 'Distribución de Estratos',
  'estratos-comparativa': 'Comparativa de Estratos',
};

export function SugerenciaWidget({
  item,
  onRemove,
  onLayoutChange,
  showDragHandle = false,
  layoutOptions = [],
}: SugerenciaWidgetProps) {
  const { isEditing, editableContent, updateContent } = useDashboardStore();

  const getWidgetTitle = () => {
    switch (item.type) {
      case 'text-block-sugerencia':
        return 'Cuadro de texto';
      case 'tabla-estrato':
        return 'Tabla por estrato';
      case 'tabla-personalizable':
        return 'Tabla personalizable';
      default:
        return chartLabels[item.type] || 'Gráfico';
    }
  };

  const getWidgetIcon = () => {
    switch (item.type) {
      case 'text-block-sugerencia':
        return <Type className="w-4 h-4" />;
      case 'tabla-estrato':
        return <Table2 className="w-4 h-4" />;
      case 'tabla-personalizable':
        return <TableProperties className="w-4 h-4" />;
      default:
        return <BarChart3 className="w-4 h-4" />;
    }
  };

  const getLayoutIcon = (colSpan: SugerenciaLayout) => {
    switch (colSpan) {
      case 1:
        return <Square className="w-3 h-3" />;
      case 2:
        return <Columns2 className="w-3 h-3" />;
      case 3:
        return <Columns3 className="w-3 h-3" />;
    }
  };

  const renderContent = () => {
    switch (item.type) {
      case 'text-block-sugerencia':
        return (
          <div className="p-4">
            <EditableText
              value={editableContent[`sugerencia_text_${item.id}`] || ''}
              onChange={(value) => updateContent(`sugerencia_text_${item.id}`, value)}
              placeholder="Escriba su sugerencia o recomendación..."
              multiline
              className="text-gray-700 text-sm"
            />
          </div>
        );

      case 'tabla-estrato':
        return <TablaEstrato item={item} />;

      case 'tabla-personalizable':
        return <TablaPersonalizable item={item} />;

      default:
        // Es un gráfico con comentario editable
        if (item.chartType || item.type) {
          const chartType = item.chartType || item.type;
          const commentValue = editableContent[`sugerencia_comment_${item.id}`] || '';
          const showCommentSection = isEditing || commentValue.trim() !== '';

          return (
            <div className="p-3">
              <div className="h-[200px]">
                <ChartThumbnail chartType={chartType} title={chartLabels[chartType] || 'Gráfico'} />
              </div>
              {/* Comentario editable del gráfico - solo mostrar si hay contenido o estamos editando */}
              {showCommentSection && (
                <div className="mt-3 pt-3 border-t">
                  <EditableText
                    value={commentValue}
                    onChange={(value) => updateContent(`sugerencia_comment_${item.id}`, value)}
                    placeholder="Agregue un comentario sobre este gráfico..."
                    multiline
                    className="text-gray-600 text-sm"
                  />
                </div>
              )}
            </div>
          );
        }
        return null;
    }
  };

  return (
    <div className="relative border rounded-lg bg-white shadow-sm">
      {/* Header - sin overflow-hidden para que se vean los tooltips */}
      <div className="flex items-center justify-between px-3 py-2 bg-gray-50 border-b rounded-t-lg">
        <div className="flex items-center gap-2 text-gray-600">
          {/* Drag handle */}
          {showDragHandle && (
            <div className="cursor-grab active:cursor-grabbing text-gray-400 hover:text-gray-600">
              <GripVertical className="w-4 h-4" />
            </div>
          )}
          {getWidgetIcon()}
          <span className="text-xs font-medium">{getWidgetTitle()}</span>
        </div>

        {isEditing && (
          <div className="flex items-center gap-2">
            {/* Layout selector con tooltips mejorados */}
            {onLayoutChange && layoutOptions.length > 0 && (
              <div className="flex items-center gap-0.5 bg-gray-100 p-0.5 rounded-md">
                {layoutOptions.map((option) => (
                  <div key={option.value} className="relative group">
                    <button
                      onClick={() => onLayoutChange(option.value)}
                      className={`p-1.5 rounded transition-all ${
                        item.colSpan === option.value
                          ? 'bg-[var(--grass-green)] text-white shadow-sm'
                          : 'bg-transparent text-gray-500 hover:bg-white hover:text-gray-700 hover:shadow-sm'
                      }`}
                    >
                      {getLayoutIcon(option.value)}
                    </button>
                    {/* Tooltip */}
                    <div className="absolute bottom-full left-1/2 -translate-x-1/2 mb-1 px-2 py-1 bg-gray-800 text-white text-xs rounded whitespace-nowrap opacity-0 group-hover:opacity-100 transition-opacity pointer-events-none z-10">
                      {option.label}
                      <div className="absolute top-full left-1/2 -translate-x-1/2 border-4 border-transparent border-t-gray-800" />
                    </div>
                  </div>
                ))}
              </div>
            )}

            {/* Remove button */}
            <button
              onClick={onRemove}
              className="p-1.5 hover:bg-red-100 rounded-md transition-colors"
              title="Eliminar"
            >
              <X className="w-4 h-4 text-red-500" />
            </button>
          </div>
        )}
      </div>

      {renderContent()}
    </div>
  );
}
