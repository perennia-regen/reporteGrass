import { useMemo } from 'react';
import { mockDashboardData } from '@/lib/mock-data';
import { ISE_THRESHOLD } from '@/styles/grass-theme';
import type { KPIType } from '@/lib/dashboard-store';
import { calcularEvolucion } from '../utils';

export interface KPIData {
  value: string;
  label: string;
  sublabel: string;
  color: string;
  isPositive?: boolean;
}

export function useKPIData() {
  const { ise, establecimiento, estratos, procesos, procesosHistorico } = mockDashboardData;

  const getKPIData = useMemo(() => {
    const lastISE = ise.historico[ise.historico.length - 1];
    const prevISE = ise.historico[ise.historico.length - 2];
    const lastProcesos = procesosHistorico[procesosHistorico.length - 1];
    const prevProcesos = procesosHistorico[procesosHistorico.length - 2];

    return (type: KPIType): KPIData => {
      switch (type) {
        case 'ise-promedio':
          return {
            value: ise.promedio.toFixed(1),
            label: 'ISE Promedio',
            sublabel: ise.promedio >= ISE_THRESHOLD ? 'Deseable' : `${(ISE_THRESHOLD - ise.promedio).toFixed(1)} pts bajo umbral`,
            color: 'var(--grass-green-dark)',
          };

        case 'ise-evolucion': {
          const evol = calcularEvolucion(lastISE.valor, prevISE.valor);
          return {
            value: `${evol > 0 ? '+' : ''}${evol.toFixed(1)}%`,
            label: 'Evolución ISE',
            sublabel: `vs ${prevISE.fecha}`,
            color: evol >= 0 ? 'var(--grass-green-dark)' : 'var(--grass-brown)',
            isPositive: evol >= 0,
          };
        }

        case 'hectareas':
          return {
            value: establecimiento.areaTotal.toString(),
            label: 'Hectáreas',
            sublabel: 'Área total monitoreada',
            color: 'var(--grass-brown)',
          };

        case 'sitios-mcp':
          return {
            value: estratos.reduce((sum, e) => sum + e.estaciones, 0).toString(),
            label: 'Sitios MCP',
            sublabel: 'Puntos de monitoreo',
            color: 'var(--estrato-loma)',
          };

        case 'procesos-evolucion-prom': {
          const promActual = (lastProcesos.valores.cicloAgua + lastProcesos.valores.cicloMineral + lastProcesos.valores.flujoEnergia + lastProcesos.valores.dinamicaComunidades) / 4;
          const promAnterior = (prevProcesos.valores.cicloAgua + prevProcesos.valores.cicloMineral + prevProcesos.valores.flujoEnergia + prevProcesos.valores.dinamicaComunidades) / 4;
          const evol = calcularEvolucion(promActual, promAnterior);
          return {
            value: `${evol > 0 ? '+' : ''}${evol.toFixed(1)}%`,
            label: 'Evol. Procesos',
            sublabel: `Promedio vs ${prevProcesos.fecha}`,
            color: evol >= 0 ? 'var(--grass-green-dark)' : 'var(--grass-brown)',
            isPositive: evol >= 0,
          };
        }

        case 'ciclo-agua':
          return {
            value: `${procesos.cicloAgua}%`,
            label: 'Ciclo del Agua',
            sublabel: 'Proceso ecosistémico',
            color: '#3B82F6',
          };

        case 'ciclo-agua-evolucion': {
          const evol = calcularEvolucion(lastProcesos.valores.cicloAgua, prevProcesos.valores.cicloAgua);
          return {
            value: `${evol > 0 ? '+' : ''}${evol.toFixed(1)}%`,
            label: 'Evol. Ciclo Agua',
            sublabel: `vs ${prevProcesos.fecha}`,
            color: evol >= 0 ? 'var(--grass-green-dark)' : 'var(--grass-brown)',
            isPositive: evol >= 0,
          };
        }

        case 'dinamica-comunidades':
          return {
            value: `${procesos.dinamicaComunidades}%`,
            label: 'Dinámica Comunidades',
            sublabel: 'Proceso ecosistémico',
            color: '#10B981',
          };

        case 'dinamica-evolucion': {
          const evol = calcularEvolucion(lastProcesos.valores.dinamicaComunidades, prevProcesos.valores.dinamicaComunidades);
          return {
            value: `${evol > 0 ? '+' : ''}${evol.toFixed(1)}%`,
            label: 'Evol. Dinámica',
            sublabel: `vs ${prevProcesos.fecha}`,
            color: evol >= 0 ? 'var(--grass-green-dark)' : 'var(--grass-brown)',
            isPositive: evol >= 0,
          };
        }

        case 'ciclo-nutrientes':
          return {
            value: `${procesos.cicloMineral}%`,
            label: 'Ciclo Nutrientes',
            sublabel: 'Proceso ecosistémico',
            color: '#8B5CF6',
          };

        case 'ciclo-nutrientes-evolucion': {
          const evol = calcularEvolucion(lastProcesos.valores.cicloMineral, prevProcesos.valores.cicloMineral);
          return {
            value: `${evol > 0 ? '+' : ''}${evol.toFixed(1)}%`,
            label: 'Evol. Nutrientes',
            sublabel: `vs ${prevProcesos.fecha}`,
            color: evol >= 0 ? 'var(--grass-green-dark)' : 'var(--grass-brown)',
            isPositive: evol >= 0,
          };
        }

        case 'flujo-energia':
          return {
            value: `${procesos.flujoEnergia}%`,
            label: 'Flujo de Energía',
            sublabel: 'Proceso ecosistémico',
            color: '#F59E0B',
          };

        case 'flujo-energia-evolucion': {
          const evol = calcularEvolucion(lastProcesos.valores.flujoEnergia, prevProcesos.valores.flujoEnergia);
          return {
            value: `${evol > 0 ? '+' : ''}${evol.toFixed(1)}%`,
            label: 'Evol. Flujo Energía',
            sublabel: `vs ${prevProcesos.fecha}`,
            color: evol >= 0 ? 'var(--grass-green-dark)' : 'var(--grass-brown)',
            isPositive: evol >= 0,
          };
        }

        default:
          return {
            value: '-',
            label: 'Sin datos',
            sublabel: '',
            color: 'gray',
          };
      }
    };
  }, [ise, establecimiento, estratos, procesos, procesosHistorico]);

  return { getKPIData };
}
