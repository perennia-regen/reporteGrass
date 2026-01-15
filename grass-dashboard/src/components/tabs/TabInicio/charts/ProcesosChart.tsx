'use client';

import { memo, useMemo } from 'react';
import { mockDashboardData } from '@/lib/mock-data';
import { grassTheme } from '@/styles/grass-theme';

const PROCESOS_CONFIG = [
  { key: 'cicloAgua' as const, label: 'Ciclo del Agua', color: grassTheme.colors.procesos.cicloAgua },
  { key: 'cicloMineral' as const, label: 'Ciclo Mineral', color: grassTheme.colors.procesos.cicloMineral },
  { key: 'flujoEnergia' as const, label: 'Flujo de Energia', color: grassTheme.colors.procesos.flujoEnergia },
  { key: 'dinamicaComunidades' as const, label: 'Dinamica Comunidades', color: grassTheme.colors.procesos.dinamicaComunidades },
];

export const ProcesosChart = memo(function ProcesosChart() {
  const { procesos } = mockDashboardData;

  const procesosData = useMemo(() => {
    return PROCESOS_CONFIG.map(config => ({
      ...config,
      valor: procesos[config.key],
    }));
  }, [procesos]);

  return (
    <div className="space-y-3 p-4">
      {procesosData.map(({ key, label, color, valor }) => (
        <div key={key} className="flex items-center gap-4">
          <span className="w-40 text-sm font-medium">{label}</span>
          <div className="flex-1 bg-gray-100 rounded-full h-5 overflow-hidden">
            <div
              className="h-full rounded-full transition-all duration-500"
              style={{
                width: `${valor}%`,
                backgroundColor: color,
              }}
            />
          </div>
          <span className="w-10 text-right font-semibold">{valor}%</span>
        </div>
      ))}
    </div>
  );
});
