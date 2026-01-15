'use client';

import { memo, useMemo } from 'react';
import { mockDashboardData } from '@/lib/mock-data';
import { ISE_THRESHOLD } from '@/styles/grass-theme';
import { getEstratoColor } from '@/lib/utils';

export const ISEEstratoChart = memo(function ISEEstratoChart() {
  const { ise } = mockDashboardData;

  const estratoData = useMemo(() => {
    return Object.entries(ise.porEstrato).map(([estrato, valor]) => ({
      estrato,
      valor,
      porcentaje: (valor / 100) * 100,
      color: getEstratoColor(estrato),
    }));
  }, [ise.porEstrato]);

  return (
    <div className="space-y-3 p-4">
      {estratoData.map(({ estrato, valor, porcentaje, color }) => (
        <div key={estrato} className="flex items-center gap-4">
          <span className="w-24 text-sm font-medium">{estrato}</span>
          <div className="flex-1 bg-gray-100 rounded-full h-6 relative overflow-hidden">
            <div
              className="h-full rounded-full transition-all duration-500"
              style={{
                width: `${Math.max(porcentaje, 0)}%`,
                backgroundColor: color,
              }}
            />
            <div
              className="absolute top-0 bottom-0 w-0.5 bg-gray-400"
              style={{ left: `${ISE_THRESHOLD}%` }}
            />
          </div>
          <span className="w-12 text-right font-semibold">{valor.toFixed(1)}</span>
        </div>
      ))}
      <p className="text-xs text-gray-500 mt-2">
        Linea vertical indica umbral deseable ({ISE_THRESHOLD} puntos)
      </p>
    </div>
  );
});
