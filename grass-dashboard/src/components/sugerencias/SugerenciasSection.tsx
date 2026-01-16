'use client';

import { useState, useRef } from 'react';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Button } from '@/components/ui/button';
import { useDashboardStore } from '@/lib/dashboard-store';
import {
  Lightbulb,
  Plus,
  Type,
  Table2,
  TableProperties,
  BarChart3,
  ChevronDown,
} from 'lucide-react';
import { SugerenciaWidget } from './SugerenciaWidget';
import type { SugerenciaItem, SugerenciaWidgetType, WidgetType, SugerenciaLayout } from '@/types/dashboard';

const MAX_ITEMS = 6;

// Tipos de widgets que son exclusivos de sugerencias (no gráficos)
const SUGERENCIA_ONLY_TYPES = ['text-block-sugerencia', 'tabla-estrato', 'tabla-personalizable'];

// Opciones del menú de agregar
const addMenuOptions = [
  { type: 'text-block-sugerencia', label: 'Cuadro de texto', icon: Type },
  { type: 'tabla-estrato', label: 'Tabla por estrato', icon: Table2 },
  { type: 'tabla-personalizable', label: 'Tabla personalizable', icon: TableProperties },
  { type: 'chart', label: 'Gráfico', icon: BarChart3, isSubmenu: true },
];

// Gráficos disponibles
const chartOptions = [
  { type: 'ise-estrato-anual', label: 'ISE por Estrato' },
  { type: 'ise-interanual-establecimiento', label: 'ISE Interanual' },
  { type: 'ise-interanual-estrato', label: 'ISE Interanual por Estrato' },
  { type: 'procesos-anual', label: 'Procesos del Año' },
  { type: 'procesos-interanual', label: 'Procesos Interanual' },
  { type: 'determinantes-interanual', label: 'Determinantes' },
  { type: 'estratos-distribucion', label: 'Distribución de Estratos' },
  { type: 'estratos-comparativa', label: 'Comparativa de Estratos' },
];

// Opciones de layout
const layoutOptions: { value: SugerenciaLayout; label: string }[] = [
  { value: 1, label: 'Ancho completo' },
  { value: 2, label: 'Dos columnas' },
  { value: 3, label: 'Tres columnas' },
];

// Props para el menú de agregar
interface AddMenuProps {
  className?: string;
  menuRef: React.RefObject<HTMLDivElement | null>;
  showAddMenu: boolean;
  setShowAddMenu: (show: boolean) => void;
  showChartSubmenu: boolean;
  setShowChartSubmenu: (show: boolean) => void;
  sugerenciaItems: SugerenciaItem[];
  addNewItem: (widgetType: SugerenciaWidgetType) => void;
}

// Componente del menú de agregar (fuera del render para evitar recreación)
function AddMenu({
  className = '',
  menuRef,
  showAddMenu,
  setShowAddMenu,
  showChartSubmenu,
  setShowChartSubmenu,
  sugerenciaItems,
  addNewItem,
}: AddMenuProps) {
  return (
    <div className={`relative ${className}`} ref={menuRef}>
      <Button
        variant="outline"
        size="sm"
        onClick={() => {
          setShowAddMenu(!showAddMenu);
          setShowChartSubmenu(false);
        }}
        className="gap-1"
      >
        <Plus className="w-4 h-4" />
        Agregar
        <ChevronDown className="w-3 h-3" />
      </Button>

      {/* Menú dropdown */}
      {showAddMenu && (
        <div className="absolute left-0 bottom-full mb-1 w-56 bg-white rounded-lg shadow-lg border z-50">
          {addMenuOptions.map((option) => {
            const Icon = option.icon;
            if (option.isSubmenu) {
              return (
                <div key={option.type} className="relative">
                  <button
                    className="w-full flex items-center gap-2 px-3 py-2 text-sm hover:bg-gray-100 text-left"
                    onClick={() => setShowChartSubmenu(!showChartSubmenu)}
                  >
                    <Icon className="w-4 h-4 text-gray-500" />
                    <span className="flex-1">{option.label}</span>
                    <ChevronDown className={`w-3 h-3 text-gray-400 transition-transform ${showChartSubmenu ? 'rotate-180' : ''}`} />
                  </button>

                  {/* Submenú de gráficos */}
                  {showChartSubmenu && (
                    <div className="border-t bg-gray-50">
                      {chartOptions.map((chart) => {
                        const isUsed = sugerenciaItems.some(item => item.chartType === chart.type);
                        return (
                          <button
                            key={chart.type}
                            className={`w-full flex items-center gap-2 px-4 py-2 text-sm text-left ${
                              isUsed
                                ? 'text-gray-400 cursor-not-allowed'
                                : 'hover:bg-gray-100'
                            }`}
                            onClick={() => !isUsed && addNewItem(chart.type as SugerenciaWidgetType)}
                            disabled={isUsed}
                          >
                            <span className="text-xs">•</span>
                            {chart.label}
                            {isUsed && <span className="text-xs text-gray-400 ml-auto">(agregado)</span>}
                          </button>
                        );
                      })}
                    </div>
                  )}
                </div>
              );
            }
            return (
              <button
                key={option.type}
                className="w-full flex items-center gap-2 px-3 py-2 text-sm hover:bg-gray-100 text-left"
                onClick={() => addNewItem(option.type as SugerenciaWidgetType)}
              >
                <Icon className="w-4 h-4 text-gray-500" />
                {option.label}
              </button>
            );
          })}
        </div>
      )}
    </div>
  );
}

export function SugerenciasSection() {
  const {
    isEditing,
    sugerenciaItems,
    addSugerenciaItem,
    removeSugerenciaItem,
    updateSugerenciaItem,
    setSugerenciaItems,
  } = useDashboardStore();
  const [isDraggingOver, setIsDraggingOver] = useState(false);
  const [showAddMenu, setShowAddMenu] = useState(false);
  const [showChartSubmenu, setShowChartSubmenu] = useState(false);
  const [draggedIndex, setDraggedIndex] = useState<number | null>(null);
  const [dragOverIndex, setDragOverIndex] = useState<number | null>(null);
  const menuRef = useRef<HTMLDivElement>(null);


  const handleDragOver = (e: React.DragEvent) => {
    e.preventDefault();
    if (sugerenciaItems.length < MAX_ITEMS) {
      setIsDraggingOver(true);
    }
  };

  const handleDragLeave = (e: React.DragEvent) => {
    e.preventDefault();
    setIsDraggingOver(false);
  };

  const handleDrop = (e: React.DragEvent) => {
    e.preventDefault();
    setIsDraggingOver(false);

    if (sugerenciaItems.length >= MAX_ITEMS) return;

    const widgetType = e.dataTransfer.getData('widgetType') as SugerenciaWidgetType;
    if (!widgetType) return;

    addNewItem(widgetType);
  };

  const addNewItem = (widgetType: SugerenciaWidgetType) => {
    if (sugerenciaItems.length >= MAX_ITEMS) return;

    // Verificar si ya existe este widget (evitar duplicados de gráficos)
    if (!SUGERENCIA_ONLY_TYPES.includes(widgetType)) {
      const exists = sugerenciaItems.some(item => item.chartType === widgetType);
      if (exists) return;
    }

    const newItem: SugerenciaItem = {
      id: `sug-${Date.now()}`,
      type: widgetType,
      colSpan: 2, // Por defecto mitad de ancho
    };

    // Configurar según el tipo
    if (widgetType === 'text-block-sugerencia') {
      newItem.content = '';
    } else if (widgetType === 'tabla-personalizable') {
      newItem.tableConfig = {
        columns: ['Columna 1', 'Columna 2'],
        rows: [],
      };
    } else if (widgetType === 'tabla-estrato') {
      newItem.tableConfig = {
        columns: ['Estrato', 'Recomendación'],
        rows: [],
      };
    } else {
      // Es un gráfico existente
      newItem.chartType = widgetType as WidgetType;
    }

    addSugerenciaItem(newItem);
    setShowAddMenu(false);
    setShowChartSubmenu(false);
  };

  // Handlers para reordenar widgets con preview visual
  const handleWidgetDragStart = (e: React.DragEvent, index: number) => {
    setDraggedIndex(index);
    e.dataTransfer.effectAllowed = 'move';
    // Necesario para Firefox
    e.dataTransfer.setData('text/plain', index.toString());
  };

  const handleWidgetDragOver = (e: React.DragEvent, targetIndex: number) => {
    e.preventDefault();
    e.stopPropagation();
    e.dataTransfer.dropEffect = 'move';
    if (draggedIndex !== null && targetIndex !== dragOverIndex) {
      setDragOverIndex(targetIndex);
    }
  };

  const handleWidgetDrop = (e: React.DragEvent) => {
    e.preventDefault();
    e.stopPropagation();

    // Calcular el nuevo orden directamente desde sugerenciaItems
    if (draggedIndex !== null && dragOverIndex !== null && draggedIndex !== dragOverIndex) {
      const items = [...sugerenciaItems];
      const [draggedItem] = items.splice(draggedIndex, 1);
      items.splice(dragOverIndex, 0, draggedItem);
      setSugerenciaItems(items);
    }
    setDraggedIndex(null);
    setDragOverIndex(null);
  };

  const handleWidgetDragEnd = () => {
    setDraggedIndex(null);
    setDragOverIndex(null);
  };

  const canAddMore = sugerenciaItems.length < MAX_ITEMS;

  // Calcular clases de grid según colSpan
  const getGridClass = (colSpan: SugerenciaLayout = 2) => {
    switch (colSpan) {
      case 1:
        return 'col-span-6'; // Full width
      case 2:
        return 'col-span-6 md:col-span-3'; // Half width
      case 3:
        return 'col-span-6 md:col-span-2'; // Third width
      default:
        return 'col-span-6 md:col-span-3';
    }
  };

  return (
    <Card>
      <CardHeader className="pb-2">
        <CardTitle className="text-lg text-[var(--grass-green-dark)] flex items-center gap-2">
          <Lightbulb className="w-5 h-5" />
          Sugerencias y Recomendaciones
        </CardTitle>
      </CardHeader>
      <CardContent>
        {/* Grid de items con layout dinámico */}
        {sugerenciaItems.length > 0 && (
          <div className="grid grid-cols-6 gap-4">
            {sugerenciaItems.map((item, index) => {
              const isDragging = draggedIndex === index;
              const isDropTarget = dragOverIndex === index && draggedIndex !== null && draggedIndex !== index;

              return (
                <div
                  key={item.id}
                  className={`${getGridClass(item.colSpan)} transition-opacity duration-150 relative ${
                    isDragging ? 'opacity-40' : ''
                  }`}
                  draggable={isEditing}
                  onDragStart={(e) => handleWidgetDragStart(e, index)}
                  onDragOver={(e) => handleWidgetDragOver(e, index)}
                  onDrop={handleWidgetDrop}
                  onDragEnd={handleWidgetDragEnd}
                >
                  {/* Indicador de drop a la izquierda */}
                  {isDropTarget && (
                    <div className="absolute -left-2 top-0 bottom-0 w-1 bg-[var(--grass-green)] rounded-full z-20" />
                  )}
                  <SugerenciaWidget
                    item={item}
                    onRemove={() => removeSugerenciaItem(item.id)}
                    onLayoutChange={(colSpan) => updateSugerenciaItem(item.id, { colSpan })}
                    showDragHandle={isEditing}
                    layoutOptions={layoutOptions}
                  />
                </div>
              );
            })}
          </div>
        )}

        {/* Zona de drop y botón agregar - solo en modo edición */}
        {isEditing && canAddMore && (
          <div
            className={`${sugerenciaItems.length > 0 ? 'mt-4' : ''} p-4 border-2 border-dashed rounded-lg transition-colors ${
              isDraggingOver
                ? 'border-[var(--grass-green)] bg-[var(--grass-green-light)]/20'
                : 'border-gray-300 hover:border-gray-400'
            }`}
            onDragOver={handleDragOver}
            onDragLeave={handleDragLeave}
            onDrop={handleDrop}
          >
            <div className="flex flex-col items-center gap-3 text-gray-500">
              {isDraggingOver ? (
                <>
                  <Plus className="w-6 h-6" />
                  <p className="text-sm">Soltar aquí para agregar</p>
                </>
              ) : (
                <>
                  <p className="text-sm text-center">
                    Arrastra desde la barra lateral o usa el botón para agregar
                  </p>
                  <AddMenu
                    menuRef={menuRef}
                    showAddMenu={showAddMenu}
                    setShowAddMenu={setShowAddMenu}
                    showChartSubmenu={showChartSubmenu}
                    setShowChartSubmenu={setShowChartSubmenu}
                    sugerenciaItems={sugerenciaItems}
                    addNewItem={addNewItem}
                  />
                  <p className="text-xs text-gray-400">
                    {sugerenciaItems.length}/{MAX_ITEMS} elementos
                  </p>
                </>
              )}
            </div>
          </div>
        )}

        {sugerenciaItems.length === 0 && !isEditing && (
          <p className="text-gray-400 italic text-center py-8">
            No hay sugerencias configuradas. Active el modo edición para agregar contenido.
          </p>
        )}
      </CardContent>
    </Card>
  );
}
