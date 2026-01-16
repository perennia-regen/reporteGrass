'use client';

import { useState, useCallback, useRef, useEffect } from 'react';
import {
  Plus,
  Trash2,
  GripVertical,
  Type,
  TableProperties,
  BarChart3,
  Image,
  X,
} from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Card, CardContent } from '@/components/ui/card';
import {
  useDashboardStore,
  useIsEditing,
  useEditableContent,
  useUpdateContent,
} from '@/lib/dashboard-store';
import { EditableText } from '@/components/editor';
import { ChartThumbnail } from '@/components/layout/ChartThumbnail';
import { PhotoGalleryWidget } from './PhotoGalleryWidget';
import type { CustomSection, CustomSectionItem, SugerenciaLayout, WidgetType, TableRow } from '@/types/dashboard';

// Componente de tabla personalizable para secciones custom
function CustomTablaPersonalizable({ item, onUpdate }: { item: CustomSectionItem; onUpdate: (updates: Partial<CustomSectionItem>) => void }) {
  const isEditing = useIsEditing();
  const config = item.tableConfig || { columns: ['Columna 1'], rows: [] };

  const addColumn = () => {
    const newColumns = [...config.columns, `Columna ${config.columns.length + 1}`];
    onUpdate({ tableConfig: { ...config, columns: newColumns } });
  };

  const removeColumn = (index: number) => {
    if (config.columns.length <= 1) return;
    const removedColumn = config.columns[index];
    const newColumns = config.columns.filter((_, i) => i !== index);
    const newRows = config.rows.map((row) => {
      const newValues = { ...row.values };
      delete newValues[removedColumn];
      return { ...row, values: newValues };
    });
    onUpdate({ tableConfig: { columns: newColumns, rows: newRows } });
  };

  const updateColumnName = (index: number, name: string) => {
    const oldName = config.columns[index];
    const newColumns = [...config.columns];
    newColumns[index] = name;
    const newRows = config.rows.map((row) => {
      const newValues = { ...row.values };
      if (oldName in newValues) {
        newValues[name] = newValues[oldName];
        delete newValues[oldName];
      }
      return { ...row, values: newValues };
    });
    onUpdate({ tableConfig: { columns: newColumns, rows: newRows } });
  };

  const addRow = () => {
    const newRow: TableRow = {
      id: `row-${Date.now()}`,
      values: config.columns.reduce((acc, col) => ({ ...acc, [col]: '' }), {} as Record<string, string>),
    };
    onUpdate({ tableConfig: { ...config, rows: [...config.rows, newRow] } });
  };

  const removeRow = (rowId: string) => {
    onUpdate({ tableConfig: { ...config, rows: config.rows.filter((r) => r.id !== rowId) } });
  };

  const updateCell = (rowId: string, column: string, value: string) => {
    const newRows = config.rows.map((row) =>
      row.id === rowId ? { ...row, values: { ...row.values, [column]: value } } : row
    );
    onUpdate({ tableConfig: { ...config, rows: newRows } });
  };

  return (
    <div className="p-2 overflow-x-auto">
      <table className="w-full text-sm">
        <thead>
          <tr className="border-b">
            {config.columns.map((col, index) => (
              <th key={index} className="p-2 text-left font-medium">
                {isEditing ? (
                  <div className="flex items-center gap-1">
                    <input
                      value={col}
                      onChange={(e) => updateColumnName(index, e.target.value)}
                      className="w-full px-2 py-1 text-xs border rounded"
                      aria-label={`Nombre de columna ${index + 1}`}
                    />
                    {config.columns.length > 1 && (
                      <button
                        onClick={() => removeColumn(index)}
                        className="text-red-400 hover:text-red-600"
                        aria-label={`Eliminar columna ${col}`}
                      >
                        <X className="w-3 h-3" aria-hidden="true" />
                      </button>
                    )}
                  </div>
                ) : (
                  col
                )}
              </th>
            ))}
            {isEditing && <th className="w-8" />}
          </tr>
        </thead>
        <tbody>
          {config.rows.length === 0 && !isEditing && (
            <tr>
              <td colSpan={config.columns.length} className="text-center text-gray-400 italic py-4">
                Sin datos
              </td>
            </tr>
          )}
          {config.rows.map((row) => (
            <tr key={row.id} className="border-b">
              {config.columns.map((col) => (
                <td key={col} className="p-2">
                  {isEditing ? (
                    <input
                      value={row.values[col] || ''}
                      onChange={(e) => updateCell(row.id, col, e.target.value)}
                      className="w-full px-2 py-1 text-xs border rounded"
                      aria-label={`Valor para ${col}`}
                    />
                  ) : (
                    row.values[col] || '-'
                  )}
                </td>
              ))}
              {isEditing && (
                <td className="p-2">
                  <button
                    onClick={() => removeRow(row.id)}
                    className="text-red-400 hover:text-red-600"
                    aria-label="Eliminar fila"
                  >
                    <Trash2 className="w-4 h-4" aria-hidden="true" />
                  </button>
                </td>
              )}
            </tr>
          ))}
        </tbody>
      </table>
      {isEditing && (
        <div className="flex gap-2 mt-2">
          <Button variant="outline" size="sm" onClick={addRow}>
            <Plus className="w-3 h-3 mr-1" /> Fila
          </Button>
          <Button variant="outline" size="sm" onClick={addColumn}>
            <Plus className="w-3 h-3 mr-1" /> Columna
          </Button>
        </div>
      )}
    </div>
  );
}

interface CustomSectionEditorProps {
  section: CustomSection;
  onDelete: () => void;
}

// Opciones de menú para agregar contenido
const ADD_MENU_OPTIONS = [
  { type: 'text-block-sugerencia', label: 'Cuadro de texto', icon: Type },
  { type: 'tabla-personalizable', label: 'Tabla', icon: TableProperties },
  { type: 'photo-gallery', label: 'Fotos', icon: Image },
];

const CHART_OPTIONS = [
  { type: 'ise-estrato-anual', label: 'ISE por Estrato' },
  { type: 'ise-interanual-establecimiento', label: 'ISE Interanual' },
  { type: 'ise-interanual-estrato', label: 'ISE Interanual por Estrato' },
  { type: 'procesos-anual', label: 'Procesos Ecosistémicos' },
  { type: 'procesos-interanual', label: 'Procesos Interanual' },
  { type: 'determinantes-interanual', label: 'Determinantes' },
  { type: 'estratos-distribucion', label: 'Distribución de Estratos' },
  { type: 'estratos-comparativa', label: 'Comparativa de Estratos' },
];

const MAX_ITEMS = 8;

export function CustomSectionEditor({ section, onDelete }: CustomSectionEditorProps) {
  const isEditing = useIsEditing();
  const editableContent = useEditableContent();
  const updateContent = useUpdateContent();
  const {
    updateCustomSection,
    addItemToSection,
    updateItemInSection,
    removeItemFromSection,
    reorderItemsInSection,
  } = useDashboardStore();

  const [showAddMenu, setShowAddMenu] = useState(false);
  const [draggedIndex, setDraggedIndex] = useState<number | null>(null);
  const [dragOverIndex, setDragOverIndex] = useState<number | null>(null);
  const [showDeleteConfirm, setShowDeleteConfirm] = useState(false);
  const menuRef = useRef<HTMLDivElement>(null);

  // Cerrar menú al hacer click fuera
  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (menuRef.current && !menuRef.current.contains(event.target as Node)) {
        setShowAddMenu(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  // Obtener gráficos ya agregados para evitar duplicados
  const usedChartTypes = section.items
    .filter((item) => item.chartType)
    .map((item) => item.chartType);

  const addNewItem = useCallback(
    (widgetType: string) => {
      if (section.items.length >= MAX_ITEMS) return;

      const newItem: CustomSectionItem = {
        id: `custom-item-${Date.now()}`,
        type: widgetType as CustomSectionItem['type'],
        colSpan: 2,
      };

      if (widgetType === 'text-block-sugerencia') {
        newItem.content = '';
      } else if (widgetType === 'tabla-personalizable') {
        newItem.tableConfig = {
          columns: ['Columna 1', 'Columna 2'],
          rows: [],
        };
      } else if (widgetType === 'photo-gallery') {
        newItem.photos = [];
      } else {
        newItem.chartType = widgetType as WidgetType;
      }

      addItemToSection(section.id, newItem);
      setShowAddMenu(false);
    },
    [section.id, section.items.length, addItemToSection]
  );

  const handleDragStart = (e: React.DragEvent, index: number) => {
    setDraggedIndex(index);
    e.dataTransfer.effectAllowed = 'move';
  };

  const handleDragOver = (e: React.DragEvent, index: number) => {
    e.preventDefault();
    setDragOverIndex(index);
  };

  const handleDrop = () => {
    if (draggedIndex !== null && dragOverIndex !== null && draggedIndex !== dragOverIndex) {
      reorderItemsInSection(section.id, draggedIndex, dragOverIndex);
    }
    setDraggedIndex(null);
    setDragOverIndex(null);
  };

  const handleDragEnd = () => {
    setDraggedIndex(null);
    setDragOverIndex(null);
  };

  const getGridClass = (colSpan: SugerenciaLayout = 2) => {
    switch (colSpan) {
      case 1:
        return 'col-span-6';
      case 2:
        return 'col-span-6 md:col-span-3';
      case 3:
        return 'col-span-6 md:col-span-2';
      default:
        return 'col-span-6 md:col-span-3';
    }
  };

  const renderItemContent = (item: CustomSectionItem) => {
    switch (item.type) {
      case 'text-block-sugerencia':
        return (
          <EditableText
            value={editableContent[`custom_text_${item.id}`] || ''}
            onChange={(value) => updateContent(`custom_text_${item.id}`, value)}
            placeholder="Escriba su texto aquí..."
            multiline
            showPencilOnHover
          />
        );

      case 'tabla-personalizable':
        return (
          <CustomTablaPersonalizable
            item={item}
            onUpdate={(updates) => updateItemInSection(section.id, item.id, updates)}
          />
        );

      case 'photo-gallery':
        return (
          <PhotoGalleryWidget
            item={item}
            onUpdatePhotos={(photos) => updateItemInSection(section.id, item.id, { photos })}
          />
        );

      default:
        const chartType = item.chartType || item.type;
        const chartLabel = CHART_OPTIONS.find((c) => c.type === chartType)?.label || chartType;
        return (
          <div>
            <ChartThumbnail chartType={chartType} title={chartLabel} />
            <EditableText
              value={editableContent[`custom_chart_comment_${item.id}`] || ''}
              onChange={(value) => updateContent(`custom_chart_comment_${item.id}`, value)}
              placeholder="Agregar un comentario..."
              className="text-xs text-gray-500 mt-2"
              showPencilOnHover
              multiline
            />
          </div>
        );
    }
  };

  const handleDeleteSection = () => {
    onDelete();
    setShowDeleteConfirm(false);
  };

  return (
    <div className="space-y-4">
      {/* Botón eliminar sección - solo en modo edición */}
      {isEditing && (
        <div className="flex justify-end">
          <Button
            variant="ghost"
            size="sm"
            onClick={() => setShowDeleteConfirm(true)}
            className="text-red-500 hover:text-red-700 hover:bg-red-50"
          >
            <Trash2 className="w-4 h-4 mr-1" />
            Eliminar sección
          </Button>
        </div>
      )}

      {/* Grid de items */}
      {section.items.length > 0 && (
        <div className="grid grid-cols-6 gap-4">
          {section.items.map((item, index) => (
            <div
              key={item.id}
              className={`${getGridClass(item.colSpan)} ${
                draggedIndex === index ? 'opacity-40' : ''
              } ${dragOverIndex === index ? 'border-l-4 border-[var(--grass-green)]' : ''}`}
              draggable={isEditing}
              onDragStart={(e) => handleDragStart(e, index)}
              onDragOver={(e) => handleDragOver(e, index)}
              onDrop={handleDrop}
              onDragEnd={handleDragEnd}
            >
              <Card className="h-full">
                <CardContent className="pt-4 relative">
                  {isEditing && (
                    <div className="absolute top-2 right-2 flex items-center gap-1">
                      <select
                        value={item.colSpan || 2}
                        onChange={(e) =>
                          updateItemInSection(section.id, item.id, {
                            colSpan: Number(e.target.value) as SugerenciaLayout,
                          })
                        }
                        className="text-xs border rounded px-1 py-0.5 bg-white"
                      >
                        <option value={1}>Full</option>
                        <option value={2}>1/2</option>
                        <option value={3}>1/3</option>
                      </select>
                      <button
                        onClick={() => removeItemFromSection(section.id, item.id)}
                        className="p-1 text-red-400 hover:text-red-600 hover:bg-red-50 rounded"
                        aria-label="Eliminar elemento"
                      >
                        <X className="w-4 h-4" aria-hidden="true" />
                      </button>
                      <div className="cursor-move text-gray-400 hover:text-gray-600" aria-hidden="true">
                        <GripVertical className="w-4 h-4" />
                      </div>
                    </div>
                  )}
                  <div className={isEditing ? 'mt-6' : ''}>{renderItemContent(item)}</div>
                </CardContent>
              </Card>
            </div>
          ))}
        </div>
      )}

      {/* Botones para agregar contenido - siempre visibles en modo edición */}
      {isEditing && section.items.length < MAX_ITEMS && (
        <div className="relative" ref={menuRef}>
          <div className="flex flex-wrap gap-2">
            {/* Botones directos para tipos comunes */}
            {ADD_MENU_OPTIONS.map((option) => (
              <Button
                key={option.type}
                variant="outline"
                size="sm"
                onClick={() => addNewItem(option.type)}
                className="border-dashed"
              >
                <option.icon className="w-4 h-4 mr-1" />
                {option.label}
              </Button>
            ))}

            {/* Botón para gráficos con dropdown */}
            <div className="relative">
              <Button
                variant="outline"
                size="sm"
                onClick={() => setShowAddMenu(!showAddMenu)}
                className="border-dashed"
              >
                <BarChart3 className="w-4 h-4 mr-1" />
                Gráfico
              </Button>

              {showAddMenu && (
                <div className="absolute top-full left-0 mt-1 bg-white border rounded-lg shadow-lg z-20 p-2 min-w-[220px]">
                  {CHART_OPTIONS.map((chart) => {
                    const isUsed = usedChartTypes.includes(chart.type as WidgetType);
                    return (
                      <button
                        key={chart.type}
                        onClick={() => {
                          if (!isUsed) {
                            addNewItem(chart.type);
                          }
                        }}
                        disabled={isUsed}
                        className={`w-full text-left px-3 py-2 text-sm rounded ${
                          isUsed ? 'text-gray-400 cursor-not-allowed' : 'hover:bg-gray-100'
                        }`}
                      >
                        {chart.label}
                        {isUsed && <span className="text-xs ml-1 text-gray-400">(agregado)</span>}
                      </button>
                    );
                  })}
                </div>
              )}
            </div>
          </div>
        </div>
      )}

      {/* Mensaje si no hay items */}
      {section.items.length === 0 && !isEditing && (
        <p className="text-gray-400 text-sm italic text-center py-4">
          Esta sección no tiene contenido
        </p>
      )}

      {/* Modal de confirmación de eliminación */}
      {showDeleteConfirm && (
        <div
          role="dialog"
          aria-modal="true"
          aria-labelledby="delete-section-title"
          className="fixed inset-0 z-50 flex items-center justify-center"
        >
          <div className="absolute inset-0 bg-black/50" onClick={() => setShowDeleteConfirm(false)} />
          <div className="relative bg-white rounded-lg p-6 max-w-sm mx-4 shadow-xl">
            <h3 id="delete-section-title" className="text-lg font-semibold mb-2">Eliminar sección</h3>
            <p className="text-gray-600 text-sm mb-4">
              ¿Eliminar &quot;{section.title}&quot;? Esta acción no se puede deshacer.
            </p>
            <div className="flex justify-end gap-2">
              <Button variant="outline" onClick={() => setShowDeleteConfirm(false)}>
                Cancelar
              </Button>
              <Button
                onClick={handleDeleteSection}
                className="bg-red-500 hover:bg-red-600 text-white"
              >
                Eliminar
              </Button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
