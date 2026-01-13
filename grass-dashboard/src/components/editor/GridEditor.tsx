'use client';

import { useState } from 'react';
import {
  DndContext,
  DragOverlay,
  closestCenter,
  KeyboardSensor,
  PointerSensor,
  useSensor,
  useSensors,
  DragEndEvent,
  DragStartEvent,
} from '@dnd-kit/core';
import {
  SortableContext,
  sortableKeyboardCoordinates,
  rectSortingStrategy,
} from '@dnd-kit/sortable';
import { useDashboardStore } from '@/lib/dashboard-store';
import { WidgetWrapper } from './WidgetWrapper';
import { WidgetRenderer } from './WidgetRenderer';
import type { WidgetConfig } from '@/types/dashboard';

interface GridEditorProps {
  widgets: WidgetConfig[];
  tabId: string;
}

export function GridEditor({ widgets, tabId }: GridEditorProps) {
  const { isEditing, reorderWidgets, selectedWidget, setSelectedWidget } = useDashboardStore();
  const [activeId, setActiveId] = useState<string | null>(null);

  const sensors = useSensors(
    useSensor(PointerSensor, {
      activationConstraint: {
        distance: 8,
      },
    }),
    useSensor(KeyboardSensor, {
      coordinateGetter: sortableKeyboardCoordinates,
    })
  );

  const handleDragStart = (event: DragStartEvent) => {
    setActiveId(event.active.id as string);
  };

  const handleDragEnd = (event: DragEndEvent) => {
    const { active, over } = event;
    setActiveId(null);

    if (over && active.id !== over.id) {
      const oldIndex = widgets.findIndex((w) => w.id === active.id);
      const newIndex = widgets.findIndex((w) => w.id === over.id);

      if (oldIndex !== -1 && newIndex !== -1) {
        reorderWidgets(tabId, oldIndex, newIndex);
      }
    }
  };

  const activeWidget = activeId ? widgets.find((w) => w.id === activeId) : null;

  if (!isEditing && widgets.length === 0) {
    return null;
  }

  return (
    <DndContext
      sensors={sensors}
      collisionDetection={closestCenter}
      onDragStart={handleDragStart}
      onDragEnd={handleDragEnd}
    >
      <SortableContext items={widgets.map((w) => w.id)} strategy={rectSortingStrategy}>
        <div
          className={`grid grid-cols-12 gap-4 ${
            isEditing ? 'min-h-[200px] border-2 border-dashed border-gray-300 rounded-lg p-4 bg-gray-50/50' : ''
          }`}
        >
          {widgets.map((widget) => (
            <WidgetWrapper
              key={widget.id}
              widget={widget}
              tabId={tabId}
              isSelected={selectedWidget === widget.id}
              onSelect={() => setSelectedWidget(widget.id)}
            >
              <WidgetRenderer widget={widget} />
            </WidgetWrapper>
          ))}

          {isEditing && widgets.length === 0 && (
            <div className="col-span-12 flex items-center justify-center h-32 text-gray-400">
              <p>Arrastra widgets desde el panel izquierdo</p>
            </div>
          )}
        </div>
      </SortableContext>

      <DragOverlay>
        {activeWidget ? (
          <div className="opacity-80 shadow-xl">
            <WidgetRenderer widget={activeWidget} />
          </div>
        ) : null}
      </DragOverlay>
    </DndContext>
  );
}
