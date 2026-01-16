import { create } from 'zustand';
import { persist } from 'zustand/middleware';
import type { WidgetConfig, TabConfig, SugerenciaItem, CustomSection, CustomSectionItem } from '@/types/dashboard';

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
  updateBulkContent: (updates: Record<string, string>) => void;

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

  // Reordenar widgets
  reorderWidgets: (tabId: string, fromIndex: number, toIndex: number) => void;

  // Secciones personalizadas en Resultados
  customSections: CustomSection[];
  addCustomSection: (title?: string) => void;
  updateCustomSection: (id: string, updates: Partial<CustomSection>) => void;
  removeCustomSection: (id: string) => void;
  addItemToSection: (sectionId: string, item: CustomSectionItem) => void;
  updateItemInSection: (sectionId: string, itemId: string, updates: Partial<CustomSectionItem>) => void;
  removeItemFromSection: (sectionId: string, itemId: string) => void;
  reorderItemsInSection: (sectionId: string, fromIndex: number, toIndex: number) => void;

  // Orden de TODAS las secciones en Resultados (fijas + personalizadas)
  resultadosSectionOrder: string[];
  setResultadosSectionOrder: (order: string[]) => void;
}

// Configuración inicial de tabs
const defaultTabs: TabConfig[] = [
  {
    id: 'inicio',
    name: 'Resumen',
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
    name: 'Detalle',
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
      updateBulkContent: (updates) => {
        const { editableContent } = get();
        set({
          editableContent: { ...editableContent, ...updates },
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
        const { updateWidget, tabs } = get();
        const currentWidget = tabs.find((t) => t.id === tabId)?.widgets.find((w) => w.id === widgetId);
        if (!currentWidget?.gridPosition) return;
        updateWidget(tabId, widgetId, {
          gridPosition: {
            ...currentWidget.gridPosition,
            x: newPosition.x,
            y: newPosition.y,
          },
        });
      },

      resizeWidget: (tabId, widgetId, newSize) => {
        const { updateWidget, tabs } = get();
        const currentWidget = tabs.find((t) => t.id === tabId)?.widgets.find((w) => w.id === widgetId);
        if (!currentWidget?.gridPosition) return;
        updateWidget(tabId, widgetId, {
          gridPosition: {
            ...currentWidget.gridPosition,
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
        customSections: [],
        resultadosSectionOrder: ['ise', 'procesos', 'forraje', 'pastoreo', 'anexo'],
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

      reorderWidgets: (tabId, fromIndex, toIndex) => {
        const { tabs } = get();
        const newTabs = tabs.map((tab) => {
          if (tab.id === tabId) {
            const newWidgets = [...tab.widgets];
            const [removed] = newWidgets.splice(fromIndex, 1);
            newWidgets.splice(toIndex, 0, removed);
            return {
              ...tab,
              widgets: newWidgets,
            };
          }
          return tab;
        });
        set({ tabs: newTabs });
      },

      // Secciones personalizadas en Resultados
      customSections: [],

      // Orden de todas las secciones en Resultados (incluye fijas: ise, procesos, forraje, pastoreo, anexo)
      resultadosSectionOrder: ['ise', 'procesos', 'forraje', 'pastoreo', 'anexo'],

      setResultadosSectionOrder: (order) => {
        set({ resultadosSectionOrder: order });
      },

      addCustomSection: (title) => {
        const { customSections, resultadosSectionOrder } = get();
        const sectionNumber = customSections.length + 1;
        const newSectionId = `custom-section-${Date.now()}`;
        const newSection: CustomSection = {
          id: newSectionId,
          title: title || `Nueva Sección ${sectionNumber}`,
          items: [],
          position: customSections.length,
        };
        // Agregar al orden antes del anexo
        const anexoIndex = resultadosSectionOrder.indexOf('anexo');
        const newOrder = [...resultadosSectionOrder];
        if (anexoIndex !== -1) {
          newOrder.splice(anexoIndex, 0, newSectionId);
        } else {
          newOrder.push(newSectionId);
        }
        set({
          customSections: [...customSections, newSection],
          resultadosSectionOrder: newOrder,
        });
      },

      updateCustomSection: (id, updates) => {
        const { customSections } = get();
        set({
          customSections: customSections.map((section) =>
            section.id === id ? { ...section, ...updates } : section
          ),
        });
      },

      removeCustomSection: (id) => {
        const { customSections, editableContent, resultadosSectionOrder } = get();
        const newContent = { ...editableContent };
        // Limpiar contenido editable asociado a la sección
        Object.keys(newContent).forEach((key) => {
          if (key.includes(id)) {
            delete newContent[key];
          }
        });
        set({
          customSections: customSections.filter((section) => section.id !== id),
          editableContent: newContent,
          resultadosSectionOrder: resultadosSectionOrder.filter((sId) => sId !== id),
        });
      },

      addItemToSection: (sectionId, item) => {
        const { customSections } = get();
        set({
          customSections: customSections.map((section) =>
            section.id === sectionId
              ? { ...section, items: [...section.items, item] }
              : section
          ),
        });
      },

      updateItemInSection: (sectionId, itemId, updates) => {
        const { customSections } = get();
        set({
          customSections: customSections.map((section) =>
            section.id === sectionId
              ? {
                  ...section,
                  items: section.items.map((item) =>
                    item.id === itemId ? { ...item, ...updates } : item
                  ),
                }
              : section
          ),
        });
      },

      removeItemFromSection: (sectionId, itemId) => {
        const { customSections, editableContent } = get();
        const newContent = { ...editableContent };
        // Limpiar contenido editable asociado al item
        Object.keys(newContent).forEach((key) => {
          if (key.includes(itemId)) {
            delete newContent[key];
          }
        });
        set({
          customSections: customSections.map((section) =>
            section.id === sectionId
              ? { ...section, items: section.items.filter((item) => item.id !== itemId) }
              : section
          ),
          editableContent: newContent,
        });
      },

      reorderItemsInSection: (sectionId, fromIndex, toIndex) => {
        const { customSections } = get();
        set({
          customSections: customSections.map((section) => {
            if (section.id === sectionId) {
              const newItems = [...section.items];
              const [removed] = newItems.splice(fromIndex, 1);
              newItems.splice(toIndex, 0, removed);
              return { ...section, items: newItems };
            }
            return section;
          }),
        });
      },
    }),
    {
      name: 'grass-dashboard-storage',
    }
  )
);

// Helper para generar IDs únicos
export const generateWidgetId = () => `widget-${Date.now()}-${Math.random().toString(36).substr(2, 9)}`;

// ============================================================================
// SELECTORES GRANULARES - Usar estos para evitar re-renders innecesarios
// ============================================================================
// Cada selector suscribe al componente SOLO al slice de estado que necesita.
// Ejemplo: useIsEditing() solo re-renderiza cuando isEditing cambia.

// Estado de edición
export const useIsEditing = () => useDashboardStore((s) => s.isEditing);
export const useSetIsEditing = () => useDashboardStore((s) => s.setIsEditing);

// Tab activa
export const useActiveTab = () => useDashboardStore((s) => s.activeTab);
export const useSetActiveTab = () => useDashboardStore((s) => s.setActiveTab);

// KPIs
export const useSelectedKPIs = () => useDashboardStore((s) => s.selectedKPIs);
export const useUpdateKPI = () => useDashboardStore((s) => s.updateKPI);

// Contenido editable
export const useEditableContent = () => useDashboardStore((s) => s.editableContent);
export const useUpdateContent = () => useDashboardStore((s) => s.updateContent);
export const useUpdateBulkContent = () => useDashboardStore((s) => s.updateBulkContent);

// Widget seleccionado
export const useSelectedWidget = () => useDashboardStore((s) => s.selectedWidget);
export const useSetSelectedWidget = () => useDashboardStore((s) => s.setSelectedWidget);

// Tabs y widgets
export const useTabs = () => useDashboardStore((s) => s.tabs);
export const useSetTabs = () => useDashboardStore((s) => s.setTabs);

// Sidebar
export const useSidebarCollapsed = () => useDashboardStore((s) => s.sidebarCollapsed);
export const useSetSidebarCollapsed = () => useDashboardStore((s) => s.setSidebarCollapsed);

// Tour
export const useTourCompleted = () => useDashboardStore((s) => s.tourCompleted);
export const useSetTourCompleted = () => useDashboardStore((s) => s.setTourCompleted);

// Sugerencias
export const useSugerenciaItems = () => useDashboardStore((s) => s.sugerenciaItems);
export const useAddSugerenciaItem = () => useDashboardStore((s) => s.addSugerenciaItem);
export const useUpdateSugerenciaItem = () => useDashboardStore((s) => s.updateSugerenciaItem);
export const useRemoveSugerenciaItem = () => useDashboardStore((s) => s.removeSugerenciaItem);
export const useReorderSugerenciaItems = () => useDashboardStore((s) => s.reorderSugerenciaItems);
export const useSetSugerenciaItems = () => useDashboardStore((s) => s.setSugerenciaItems);

// Widget actions
export const useAddWidget = () => useDashboardStore((s) => s.addWidget);
export const useUpdateWidget = () => useDashboardStore((s) => s.updateWidget);
export const useRemoveWidget = () => useDashboardStore((s) => s.removeWidget);
export const useMoveWidget = () => useDashboardStore((s) => s.moveWidget);
export const useResizeWidget = () => useDashboardStore((s) => s.resizeWidget);
export const useReorderWidgets = () => useDashboardStore((s) => s.reorderWidgets);

// Reset
export const useResetDashboard = () => useDashboardStore((s) => s.resetDashboard);

// Custom Sections (Resultados)
export const useCustomSections = () => useDashboardStore((s) => s.customSections);
export const useAddCustomSection = () => useDashboardStore((s) => s.addCustomSection);
export const useUpdateCustomSection = () => useDashboardStore((s) => s.updateCustomSection);
export const useRemoveCustomSection = () => useDashboardStore((s) => s.removeCustomSection);
export const useAddItemToSection = () => useDashboardStore((s) => s.addItemToSection);
export const useUpdateItemInSection = () => useDashboardStore((s) => s.updateItemInSection);
export const useRemoveItemFromSection = () => useDashboardStore((s) => s.removeItemFromSection);
export const useReorderItemsInSection = () => useDashboardStore((s) => s.reorderItemsInSection);

// Orden de secciones en Resultados (todas las secciones: fijas + personalizadas)
export const useResultadosSectionOrder = () => useDashboardStore((s) => s.resultadosSectionOrder);
export const useSetResultadosSectionOrder = () => useDashboardStore((s) => s.setResultadosSectionOrder);
