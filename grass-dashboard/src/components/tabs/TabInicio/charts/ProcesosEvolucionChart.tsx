'use client';

import { memo, useMemo } from 'react';
import { mockDashboardData } from '@/lib/mock-data';
import { grassTheme } from '@/styles/grass-theme';

export const ProcesosEvolucionChart = memo(function ProcesosEvolucionChart() {
  const { procesosHistorico } = mockDashboardData;

  const chartData = useMemo(() => procesosHistorico, [procesosHistorico]);

  return (
    <div className="h-48 p-4">
      <div className="flex items-end justify-between h-full gap-4">
        {chartData.map((punto, index) => (
          <div key={index} className="flex flex-col items-center flex-1">
            <div className="flex items-end gap-0.5 h-32">
              <div
                className="w-3 rounded-t"
                style={{
                  height: `${punto.valores.cicloAgua}%`,
                  backgroundColor: grassTheme.colors.procesos.cicloAgua
                }}
                title="Ciclo Agua"
              />
              <div
                className="w-3 rounded-t"
                style={{
                  height: `${punto.valores.cicloMineral}%`,
                  backgroundColor: grassTheme.colors.procesos.cicloMineral
                }}
                title="Ciclo Mineral"
              />
              <div
                className="w-3 rounded-t"
                style={{
                  height: `${punto.valores.flujoEnergia}%`,
                  backgroundColor: grassTheme.colors.procesos.flujoEnergia
                }}
                title="Flujo Energia"
              />
              <div
                className="w-3 rounded-t"
                style={{
                  height: `${punto.valores.dinamicaComunidades}%`,
                  backgroundColor: grassTheme.colors.procesos.dinamicaComunidades
                }}
                title="Dinamica"
              />
            </div>
            <span className="text-xs mt-2 text-gray-600">{punto.fecha}</span>
          </div>
        ))}
      </div>
    </div>
  );
});
