'use client';

import { memo, useMemo } from 'react';
import { mockDashboardData } from '@/lib/mock-data';
import { getISEGradientColor } from '../utils';

export const EvolucionISEChart = memo(function EvolucionISEChart() {
  const { ise } = mockDashboardData;

  const chartData = useMemo(() => ({
    historico: ise.historico,
    maxISE: Math.max(...ise.historico.map(p => p.valor)),
    minISE: Math.min(...ise.historico.map(p => p.valor)),
  }), [ise.historico]);

  return (
    <div className="h-48">
      <div className="flex items-end justify-between h-full gap-2 px-4 pb-4">
        {chartData.historico.map((punto, index) => (
          <div key={index} className="flex flex-col items-center flex-1">
            <div
              className="w-full rounded-t transition-all duration-500"
              style={{
                height: `${Math.max(punto.valor * 1.5, 10)}px`,
                backgroundColor: getISEGradientColor(punto.valor),
              }}
            />
            <span className="text-xs mt-2 text-gray-600">{punto.fecha}</span>
            <span className="text-sm font-semibold">{punto.valor.toFixed(1)}</span>
          </div>
        ))}
      </div>
      <div className="px-4 mt-2 border-t pt-2">
        <div className="flex items-center justify-center gap-2 text-xs text-gray-500">
          <div
            className="w-16 h-3 rounded"
            style={{
              background: `linear-gradient(to right, ${getISEGradientColor(0)}, ${getISEGradientColor(50)}, ${getISEGradientColor(100)})`
            }}
          />
          <span>0</span>
          <span className="mx-1">-&gt;</span>
          <span>100 (Mayor = Mejor)</span>
        </div>
      </div>
    </div>
  );
});
