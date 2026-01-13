// Mock data de establecimientos para la pantalla de selección

export interface EstablecimientoOption {
  id: string;
  nombre: string;
  provincia: string;
  ultimoMonitoreo: string;
  hectareas: number;
}

export const establecimientosMock: EstablecimientoOption[] = [
  {
    id: 'la-union',
    nombre: 'La Unión',
    provincia: 'Santa Fe',
    ultimoMonitoreo: '25 Mar 2025',
    hectareas: 560,
  },
  {
    id: 'el-amanecer',
    nombre: 'El Amanecer',
    provincia: 'Córdoba',
    ultimoMonitoreo: '15 Feb 2025',
    hectareas: 1200,
  },
  {
    id: 'los-alamos',
    nombre: 'Los Álamos',
    provincia: 'Buenos Aires',
    ultimoMonitoreo: '10 Ene 2025',
    hectareas: 850,
  },
  {
    id: 'campo-verde',
    nombre: 'Campo Verde',
    provincia: 'Entre Ríos',
    ultimoMonitoreo: '20 Dic 2024',
    hectareas: 420,
  },
  {
    id: 'la-esperanza',
    nombre: 'La Esperanza',
    provincia: 'Santa Fe',
    ultimoMonitoreo: '05 Mar 2025',
    hectareas: 980,
  },
];

export type DashboardType = 'monitoreo-corto' | 'linea-base' | 'plan-pastoreo';

export interface DashboardTypeOption {
  id: DashboardType;
  nombre: string;
  descripcion: string;
  enabled: boolean;
}

export const dashboardTypes: DashboardTypeOption[] = [
  {
    id: 'monitoreo-corto',
    nombre: 'Monitoreo Corto Plazo',
    descripcion: 'Informe MCP - Lectura anual de indicadores',
    enabled: true,
  },
  {
    id: 'linea-base',
    nombre: 'Línea de Base',
    descripcion: 'Evaluación inicial completa del establecimiento',
    enabled: false,
  },
  {
    id: 'plan-pastoreo',
    nombre: 'Plan de Pastoreo',
    descripcion: 'Planificación y seguimiento del pastoreo',
    enabled: false,
  },
];
