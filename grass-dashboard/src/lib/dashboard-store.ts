import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import type { WidgetConfig, TabConfig } from '@/types/dashboard';

interface DashboardState {
  // Tab activa
  activeTab: string;
  setActiveTab: (tabId: string) => void;

  // Modo de edición
  isEditing: boolean;
  setIsEditing: (editing: boolean) => void;

  // Widget seleccionado para editar
  selectedWidget: string | null;
  setSelectedWidget: (widgetId: string | null) => void;

  // Configuración de tabs y widgets
  tabs: TabConfig[];
  setTabs: (tabs: TabConfig[]) => void;

  // Acciones sobre widgets
  addWidget: (tabId: string, widget: WidgetConfig) => void;
  updateWidget: (tabId: string, widgetId: string, updates: Partial<WidgetConfig>) => void;
  removeWidget: (tabId: string, widgetId: string) => void;
  moveWidget: (tabId: string, widgetId: string, newPosition: { x: number; y: number }) => void;
  resizeWidget: (tabId: string, widgetId: string, newSize: { w: number; h: number }) => void;

  // Reset
  resetDashboard: () => void;
}

// Configuración inicial de tabs
const defaultTabs: TabConfig[] = [
  {
    id: 'inicio',
    name: 'Inicio',
    locked: true,
    widgets: [],
  },
  {
    id: 'plan-monitoreo',
    name: 'Plan de Monitoreo',
    locked: true,
    widgets: [],
  },
  {
    id: 'resultados',
    name: 'Resultados',
    locked: true,
    widgets: [],
  },
  {
    id: 'sobre-grass',
    name: 'Sobre GRASS',
    locked: true,
    widgets: [],
  },
  {
    id: 'comunidad',
    name: 'Comunidad',
    locked: true,
    widgets: [],
  },
];

export const useDashboardStore = create<DashboardState>()(
  persist(
    (set, get) => ({
      activeTab: 'inicio',
      setActiveTab: (tabId) => set({ activeTab: tabId }),

      isEditing: false,
      setIsEditing: (editing) => set({ isEditing: editing, selectedWidget: editing ? get().selectedWidget : null }),

      selectedWidget: null,
      setSelectedWidget: (widgetId) => set({ selectedWidget: widgetId }),

      tabs: defaultTabs,
      setTabs: (tabs) => set({ tabs }),

      addWidget: (tabId, widget) => {
        const { tabs } = get();
        const newTabs = tabs.map((tab) => {
          if (tab.id === tabId) {
            return {
              ...tab,
              widgets: [...tab.widgets, widget],
            };
          }
          return tab;
        });
        set({ tabs: newTabs });
      },

      updateWidget: (tabId, widgetId, updates) => {
        const { tabs } = get();
        const newTabs = tabs.map((tab) => {
          if (tab.id === tabId) {
            return {
              ...tab,
              widgets: tab.widgets.map((widget) =>
                widget.id === widgetId ? { ...widget, ...updates } : widget
              ),
            };
          }
          return tab;
        });
        set({ tabs: newTabs });
      },

      removeWidget: (tabId, widgetId) => {
        const { tabs, selectedWidget } = get();
        const newTabs = tabs.map((tab) => {
          if (tab.id === tabId) {
            return {
              ...tab,
              widgets: tab.widgets.filter((widget) => widget.id !== widgetId),
            };
          }
          return tab;
        });
        set({
          tabs: newTabs,
          selectedWidget: selectedWidget === widgetId ? null : selectedWidget,
        });
      },

      moveWidget: (tabId, widgetId, newPosition) => {
        const { updateWidget } = get();
        updateWidget(tabId, widgetId, {
          gridPosition: {
            ...get().tabs.find((t) => t.id === tabId)?.widgets.find((w) => w.id === widgetId)?.gridPosition!,
            x: newPosition.x,
            y: newPosition.y,
          },
        });
      },

      resizeWidget: (tabId, widgetId, newSize) => {
        const { updateWidget } = get();
        updateWidget(tabId, widgetId, {
          gridPosition: {
            ...get().tabs.find((t) => t.id === tabId)?.widgets.find((w) => w.id === widgetId)?.gridPosition!,
            w: newSize.w,
            h: newSize.h,
          },
        });
      },

      resetDashboard: () => set({ tabs: defaultTabs, activeTab: 'inicio', selectedWidget: null }),
    }),
    {
      name: 'grass-dashboard-storage',
    }
  )
);

// Helper para generar IDs únicos
export const generateWidgetId = () => `widget-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
