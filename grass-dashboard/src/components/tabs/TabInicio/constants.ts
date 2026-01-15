import type { KPIType } from '@/lib/dashboard-store';

// Types for chart handling
export type ChartType = 'evolucion-ise' | 'ise-estrato' | 'procesos' | 'procesos-evolucion';

export interface ChartOption {
  id: ChartType;
  name: string;
  description: string;
}

export interface KPIOption {
  id: KPIType;
  name: string;
  shortName: string;
  requiresInteranual: boolean;
}

// Chart options available in TabInicio
export const CHART_OPTIONS: ChartOption[] = [
  { id: 'evolucion-ise', name: 'Evolución ISE Interanual', description: 'Tendencia histórica del ISE' },
  { id: 'ise-estrato', name: 'ISE por Estrato', description: 'Comparación entre ambientes' },
  { id: 'procesos', name: 'Procesos Ecosistémicos', description: 'Estado de los 4 procesos' },
  { id: 'procesos-evolucion', name: 'Evolución Procesos', description: 'Tendencia de procesos' },
] as const;

// KPI options available for selection
export const KPI_OPTIONS: KPIOption[] = [
  { id: 'ise-promedio', name: 'ISE Promedio del campo', shortName: 'ISE Promedio', requiresInteranual: false },
  { id: 'ise-evolucion', name: '% Evolución ISE', shortName: 'Evol. ISE', requiresInteranual: true },
  { id: 'hectareas', name: 'Hectáreas Totales monitoreadas', shortName: 'Hectáreas', requiresInteranual: false },
  { id: 'sitios-mcp', name: 'Número de Sitios MCP', shortName: 'Sitios MCP', requiresInteranual: false },
  { id: 'procesos-evolucion-prom', name: '% Evolución Procesos Ecosistémicos (promedio)', shortName: 'Evol. Procesos', requiresInteranual: true },
  { id: 'ciclo-agua', name: 'Ciclo del Agua', shortName: 'Ciclo Agua', requiresInteranual: false },
  { id: 'ciclo-agua-evolucion', name: '% Evolución Ciclo del Agua', shortName: 'Evol. Ciclo Agua', requiresInteranual: true },
  { id: 'dinamica-comunidades', name: 'Dinámica de las Comunidades', shortName: 'Dinámica Com.', requiresInteranual: false },
  { id: 'dinamica-evolucion', name: '% Evolución Dinámica de Comunidades', shortName: 'Evol. Dinámica', requiresInteranual: true },
  { id: 'ciclo-nutrientes', name: 'Ciclo de Nutrientes', shortName: 'Ciclo Nutrientes', requiresInteranual: false },
  { id: 'ciclo-nutrientes-evolucion', name: '% Evolución Ciclo de Nutrientes', shortName: 'Evol. Nutrientes', requiresInteranual: true },
  { id: 'flujo-energia', name: 'Flujo de Energía', shortName: 'Flujo Energía', requiresInteranual: false },
  { id: 'flujo-energia-evolucion', name: '% Evolución Flujo de Energía', shortName: 'Evol. Energía', requiresInteranual: true },
] as const;

// Quick navigation actions
export const QUICK_ACTIONS = [
  { id: 'plan-monitoreo', name: 'Plan de Monitoreo' },
  { id: 'resultados', name: 'Resultados' },
  { id: 'sobre-grass', name: 'Sobre GRASS' },
  { id: 'comunidad', name: 'Comunidad' },
] as const;
