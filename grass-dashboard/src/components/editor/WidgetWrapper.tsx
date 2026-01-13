'use client';

import { useSortable } from '@dnd-kit/sortable';
import { CSS } from '@dnd-kit/utilities';
import { useDashboardStore } from '@/lib/dashboard-store';
import type { WidgetConfig } from '@/types/dashboard';

interface WidgetWrapperProps {
  widget: WidgetConfig;
  tabId: string;
  isSelected: boolean;
  onSelect: () => void;
  children: React.ReactNode;
}

export function WidgetWrapper({
  widget,
  tabId,
  isSelected,
  onSelect,
  children,
}: WidgetWrapperProps) {
  const { isEditing, removeWidget, resizeWidget } = useDashboardStore();

  const {
    attributes,
    listeners,
    setNodeRef,
    transform,
    transition,
    isDragging,
  } = useSortable({ id: widget.id, disabled: !isEditing });

  const style = {
    transform: CSS.Transform.toString(transform),
    transition,
    gridColumn: `span ${widget.gridPosition.w}`,
    gridRow: `span ${widget.gridPosition.h}`,
  };

  // Opciones de tamaño predefinidas
  const sizeOptions = [
    { w: 3, h: 2, label: 'Pequeño' },
    { w: 6, h: 3, label: 'Mediano' },
    { w: 12, h: 4, label: 'Grande' },
    { w: 6, h: 6, label: 'Cuadrado' },
  ];

  return (
    <div
      ref={setNodeRef}
      style={style}
      className={`relative bg-white rounded-lg shadow-sm transition-all ${
        isDragging ? 'opacity-50 z-50' : ''
      } ${
        isEditing
          ? `cursor-move hover:shadow-md ${
              isSelected ? 'ring-2 ring-[var(--grass-green)] ring-offset-2' : 'hover:ring-1 hover:ring-gray-300'
            }`
          : ''
      }`}
      onClick={(e) => {
        if (isEditing) {
          e.stopPropagation();
          onSelect();
        }
      }}
      {...attributes}
      {...listeners}
    >
      {/* Toolbar de edición */}
      {isEditing && isSelected && (
        <div className="absolute -top-10 left-0 right-0 flex items-center justify-between bg-white rounded-t-lg shadow-md px-2 py-1 z-10">
          <span className="text-xs font-medium text-gray-600 truncate">
            {widget.title || widget.type}
          </span>
          <div className="flex items-center gap-1">
            {/* Selector de tamaño */}
            <select
              className="text-xs border rounded px-1 py-0.5"
              value={`${widget.gridPosition.w}-${widget.gridPosition.h}`}
              onChange={(e) => {
                const [w, h] = e.target.value.split('-').map(Number);
                resizeWidget(tabId, widget.id, { w, h });
              }}
              onClick={(e) => e.stopPropagation()}
            >
              {sizeOptions.map((size) => (
                <option key={`${size.w}-${size.h}`} value={`${size.w}-${size.h}`}>
                  {size.label}
                </option>
              ))}
            </select>

            {/* Botón eliminar */}
            {widget.editable && (
              <button
                className="p-1 hover:bg-red-100 rounded text-red-500"
                onClick={(e) => {
                  e.stopPropagation();
                  removeWidget(tabId, widget.id);
                }}
                title="Eliminar widget"
              >
                <svg className="w-4 h-4" fill="none" viewBox="0 0 24 24" stroke="currentColor">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                </svg>
              </button>
            )}
          </div>
        </div>
      )}

      {/* Contenido del widget */}
      <div className="h-full overflow-hidden rounded-lg">
        {children}
      </div>

      {/* Indicador de arrastre */}
      {isEditing && (
        <div className="absolute top-2 right-2 opacity-0 group-hover:opacity-100 transition-opacity">
          <svg className="w-4 h-4 text-gray-400" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M4 8h16M4 16h16" />
          </svg>
        </div>
      )}
    </div>
  );
}
