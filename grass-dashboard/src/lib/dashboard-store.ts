import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import type { WidgetConfig, TabConfig, SugerenciaItem } from '@/types/dashboard';

// Contenido editable del dashboard
interface EditableContent {
  observacionGeneral: string;
  comentarioISE: string;
  comentarioFinal: string;
  // Recomendaciones por estrato
  recomendacion_loma: string;
  recomendacion_media_loma: string;
  recomendacion_bajo: string;
  // Comentarios de gráficos en Resultados
  comentarioISEEstrato: string;
  comentarioEvolucionISE: string;
  comentarioEvolucionISEEstrato: string;
  comentarioProcesosActual: string;
  comentarioEvolucionProcesos: string;
  [key: string]: string; // Para campos dinámicos
}

// Tipos de KPIs disponibles
export type KPIType =
  | 'ise-promedio'
  | 'ise-evolucion'
  | 'hectareas'
  | 'sitios-mcp'
  | 'procesos-evolucion-prom'
  | 'ciclo-agua'
  | 'ciclo-agua-evolucion'
  | 'dinamica-comunidades'
  | 'dinamica-evolucion'
  | 'ciclo-nutrientes'
  | 'ciclo-nutrientes-evolucion'
  | 'flujo-energia'
  | 'flujo-energia-evolucion';

interface DashboardState {
  // Tab activa
  activeTab: string;
  setActiveTab: (tabId: string) => void;

  // Modo de edición
  isEditing: boolean;
  setIsEditing: (editing: boolean) => void;

  // KPIs configurables (3 tarjetas en inicio)
  selectedKPIs: [KPIType, KPIType, KPIType];
  setSelectedKPIs: (kpis: [KPIType, KPIType, KPIType]) => void;
  updateKPI: (index: 0 | 1 | 2, kpi: KPIType) => void;

  // Widget seleccionado para editar
  selectedWidget: string | null;
  setSelectedWidget: (widgetId: string | null) => void;

  // Configuración de tabs y widgets
  tabs: TabConfig[];
  setTabs: (tabs: TabConfig[]) => void;

  // Contenido editable
  editableContent: EditableContent;
  updateContent: (key: string, value: string) => void;

  // Sidebar colapsable
  sidebarCollapsed: boolean;
  setSidebarCollapsed: (collapsed: boolean) => void;

  // Tour guiado
  tourCompleted: boolean;
  setTourCompleted: (completed: boolean) => void;

  // Acciones sobre widgets
  addWidget: (tabId: string, widget: WidgetConfig) => void;
  updateWidget: (tabId: string, widgetId: string, updates: Partial<WidgetConfig>) => void;
  removeWidget: (tabId: string, widgetId: string) => void;
  moveWidget: (tabId: string, widgetId: string, newPosition: { x: number; y: number }) => void;
  resizeWidget: (tabId: string, widgetId: string, newSize: { w: number; h: number }) => void;

  // Reset
  resetDashboard: () => void;

  // Sugerencias y recomendaciones
  sugerenciaItems: SugerenciaItem[];
  addSugerenciaItem: (item: SugerenciaItem) => void;
  updateSugerenciaItem: (id: string, updates: Partial<SugerenciaItem>) => void;
  removeSugerenciaItem: (id: string) => void;
  reorderSugerenciaItems: (fromIndex: number, toIndex: number) => void;
  setSugerenciaItems: (items: SugerenciaItem[]) => void;
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

// Contenido editable por defecto
const defaultEditableContent: EditableContent = {
  observacionGeneral: 'La evaluación muestra avances diferenciados entre los estratos. El estrato Loma continúa siendo el más limitado en su salud ecosistémica, aunque presenta mejoras puntuales en la cobertura del suelo. En Media Loma, los procesos básicos se mantienen estables, pero se observa una pérdida de diversidad vegetal y un deterioro en las pasturas. El estrato Bajo evidencia la evolución más positiva, con mejoras sostenidas en la cobertura, diversidad funcional y funcionamiento del ecosistema.',
  comentarioISE: 'El Índice de Salud Ecosistémica (ISE) muestra una ligera disminución respecto al año anterior, principalmente debido a las condiciones climáticas. Se recomienda continuar con las prácticas de manejo regenerativo.',
  comentarioFinal: 'El establecimiento muestra un compromiso sostenido con la regeneración del ecosistema. Se sugiere continuar con el monitoreo anual para evaluar la evolución de los indicadores.',
  // Recomendaciones por estrato
  recomendacion_loma: 'Mantener e incorporar prácticas agrícolas alineadas con el propósito de regeneración, tales como el uso de cultivos de cobertura, intersiembras y rotaciones que contribuyan a mejorar la cobertura del suelo y reducir el impacto sobre los procesos ecológicos.',
  recomendacion_media_loma: 'Sostener la planificación del pastoreo, ajustando los tiempos de recuperación según la época del año y evaluando la carga animal. Promover la incorporación y mantenimiento de especies perennes, así como asegurar remanentes post-pastoreo suficientemente altos y voluminosos.',
  recomendacion_bajo: 'Priorizar la acumulación de cobertura, aprovechando los buenos resultados observados para consolidar las mejoras en el funcionamiento de los procesos ecosistémicos.',
  // Comentarios de gráficos en Resultados
  comentarioISEEstrato: 'El valor promedio del ISE fue de 34,6, por debajo del umbral deseable de 70 puntos. El estrato Loma presenta la menor puntuación (14,3), reflejando el impacto del uso intensivo para agricultura.',
  comentarioEvolucionISE: 'Se observa una marcada disminución inicial por sequía severa (2023), con recuperación parcial posterior. Este comportamiento refleja una tendencia general negativa en la salud ecosistémica.',
  comentarioEvolucionISEEstrato: 'Al analizar la evolución por estratos, se identifican situaciones diferenciadas. El estrato Bajo muestra una leve mejora, mientras que Media Loma presenta una tendencia negativa más marcada.',
  comentarioProcesosActual: 'A nivel de todo el establecimiento, se observa un funcionamiento relativamente adecuado del ciclo del agua (56%), y un desempeño intermedio en el ciclo mineral (48%) y el flujo de energía (46%).',
  comentarioEvolucionProcesos: 'En los tres años evaluados, se observa una relativa estabilidad en los ciclos del agua y mineral. El flujo de energía mostró una fuerte caída inicial, con recuperación parcial posterior.',
};

export const useDashboardStore = create<DashboardState>()(
  persist(
    (set, get) => ({
      activeTab: 'inicio',
      setActiveTab: (tabId) => set({ activeTab: tabId }),

      isEditing: true,
      setIsEditing: (editing) => set({ isEditing: editing, selectedWidget: editing ? get().selectedWidget : null }),

      // KPIs configurables - valores por defecto
      selectedKPIs: ['ise-promedio', 'hectareas', 'sitios-mcp'] as [KPIType, KPIType, KPIType],
      setSelectedKPIs: (kpis) => set({ selectedKPIs: kpis }),
      updateKPI: (index, kpi) => {
        const { selectedKPIs } = get();
        const newKPIs = [...selectedKPIs] as [KPIType, KPIType, KPIType];
        newKPIs[index] = kpi;
        set({ selectedKPIs: newKPIs });
      },

      selectedWidget: null,
      setSelectedWidget: (widgetId) => set({ selectedWidget: widgetId }),

      tabs: defaultTabs,
      setTabs: (tabs) => set({ tabs }),

      editableContent: defaultEditableContent,
      updateContent: (key, value) => {
        const { editableContent } = get();
        set({
          editableContent: {
            ...editableContent,
            [key]: value,
          },
        });
      },

      sidebarCollapsed: false,
      setSidebarCollapsed: (collapsed) => set({ sidebarCollapsed: collapsed }),

      tourCompleted: false,
      setTourCompleted: (completed) => set({ tourCompleted: completed }),

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

      resetDashboard: () => set({
        tabs: defaultTabs,
        activeTab: 'inicio',
        selectedWidget: null,
        editableContent: defaultEditableContent,
        sidebarCollapsed: false,
        tourCompleted: false,
        sugerenciaItems: [],
        selectedKPIs: ['ise-promedio', 'hectareas', 'sitios-mcp'] as [KPIType, KPIType, KPIType],
      }),

      // Sugerencias y recomendaciones
      sugerenciaItems: [],

      addSugerenciaItem: (item) => {
        const { sugerenciaItems } = get();
        if (sugerenciaItems.length < 6) {
          set({ sugerenciaItems: [...sugerenciaItems, item] });
        }
      },

      updateSugerenciaItem: (id, updates) => {
        const { sugerenciaItems } = get();
        set({
          sugerenciaItems: sugerenciaItems.map((item) =>
            item.id === id ? { ...item, ...updates } : item
          ),
        });
      },

      removeSugerenciaItem: (id) => {
        const { sugerenciaItems, editableContent } = get();
        const newContent = { ...editableContent };
        // Limpiar contenido editable asociado
        Object.keys(newContent).forEach((key) => {
          if (key.includes(id)) {
            delete newContent[key];
          }
        });
        set({
          sugerenciaItems: sugerenciaItems.filter((item) => item.id !== id),
          editableContent: newContent,
        });
      },

      reorderSugerenciaItems: (fromIndex, toIndex) => {
        const { sugerenciaItems } = get();
        const newItems = [...sugerenciaItems];
        const [removed] = newItems.splice(fromIndex, 1);
        newItems.splice(toIndex, 0, removed);
        set({ sugerenciaItems: newItems });
      },

      setSugerenciaItems: (items) => {
        set({ sugerenciaItems: items });
      },
    }),
    {
      name: 'grass-dashboard-storage',
    }
  )
);

// Helper para generar IDs únicos
export const generateWidgetId = () => `widget-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;
